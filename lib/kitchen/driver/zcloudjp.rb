# -*- encoding: utf-8 -*-
#
# Author:: Yukihiko Sawanobori (sawanoboriyu@higanworks.com)
#
# Copyright (C) 2013, HiganWorks LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require 'zcloudjp'

require 'benchmark'
require 'kitchen'
require 'kitchen/busser'


module Kitchen

  module Driver
    class Zcloudjp < Kitchen::Driver::SSHBase
      default_config :dataset, 'sdc:sdc:base64:13.4.2' # base64 image
      default_config :package, 'Small_1GB'
      default_config :with_gcc, true

      required_config :api_key

      def create(state)
        server = create_server(state)
        state[:server_id] = server.id

        info("SmartMachine <#{state[:server_id]}> created.")
        debug(server)
        server.wait_for { print "."; ready? } ; print "(provision queued)"
        state[:hostname] = server.ips.first
        ssh_args = build_ssh_args(state)
        wait_for_sshd_vm(ssh_args)      ; print "(first reboot)\n"
        sleep 10
        debug("waiting for second")
        wait_for_sshd_vm(ssh_args)      ; print "(second reboot)\n"
        sleep 10

        unless server.os == "SmartOS"
          info("wait for SSH Connection. It takes few minutes. (Only VirtualMachine)")
          ssh_args = build_ssh_args(state)
          sleep 5 until wait_for_sshd_vm(ssh_args)
          print "(ssh ready)\n"
        else
          wait_for_sshd_vm(ssh_args)      ; print "(ssh ready)\n"
        end
      end


      def destroy(state)
        return if state[:server_id].nil?
        server = client.machine.show(:id => state[:server_id])
        server.stop unless server.nil?
        until server.reload.state == "stopped"
          sleep 3
          debug(server.to_s)
          info("SmartMachine <#{state[:server_id]}> is stopping, wait for minutes...")
        end
        sleep 5
        server.delete unless server.nil?
        info("SmartMachine <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end


      def converge(state)
        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = Dir.glob("#{provisioner.sandbox_path}/*")

        server = client.machine.show(:id => state[:server_id])
        info("--> Updating metadata...")
        server.metadata.update(:metadata => build_metadata)
        ssh_args = build_ssh_args(state)

        if server.os == "SmartOS"
          install_chef_for_smartos(ssh_args)
        else
          fix_monkey_dataset(ssh_args)
          # install_omnibus(ssh_args) if config[:require_chef_omnibus]
        end

        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(provisioner.install_command, conn)
          run_remote(provisioner.init_command, conn)
          transfer_path(sandbox_dirs, provisioner[:root_path], conn)
          run_remote(provisioner.prepare_command, conn)
          puts provisioner[:test_base_path]
          puts '-------------'
          run_remote(provisioner.run_command, conn)
        end
      ensure
        provisioner && provisioner.cleanup_sandbox
      end

      def client
        ::Zcloudjp::Client.new(
          :api_key => config[:api_key]
        )
      end

      def create_server(state)
        debug(JSON.pretty_generate(config))
        debug("Send as Metadata => #{build_metadata}")
        client.machine.create(
          :dataset => config[:dataset],
          :package => config[:package],
          :name =>  ['tk', @instance.suite.name.to_s, @instance.platform.name.to_s].join('-').slice(0,20),
          :metadata => build_metadata
        )
      end

      def build_metadata
        if config[:metadata_file]
          JSON.parse(::File.read(config[:metadata_file]))
        else
          {}
        end
      end

      def install_chef_for_smartos(ssh_args)
        if config[:with_gcc]
          install_pkgs = "gcc47 gcc47-runtime scmgit-base scmgit-docs gmake ruby193-base ruby193-yajl ruby193-nokogiri ruby193-readline pkg-config"
        else
          install_pkgs = "scmgit-base scmgit-docs ruby193-base ruby193-yajl ruby193-nokogiri ruby193-readline"
        end

        ssh(ssh_args, <<-INSTALL.gsub(/^ {10}/, ''))
          if [ ! -f /opt/local/bin/chef-client ]; then
            pkgin -y install #{install_pkgs}

          ## for smf cookbook
            pkgin -y install libxslt

          ## install chef
            gem update --system --no-ri --no-rdoc
            gem install -f --no-ri --no-rdoc ohai #{config[:ohai_version] ? '--version ' + %Q{'=  #{config[:ohai_version]}'} : nil }
            gem install -f --no-ri --no-rdoc chef #{config[:chef_version] ? '--version ' + %Q{'=  #{config[:chef_version]}'} : nil }
            gem install -f --no-ri --no-rdoc rb-readline
          fi
        INSTALL
      end

      def fix_monkey_dataset(ssh_args)
        ssh(ssh_args, <<-__PATCH__.gsub(/^ {10}/, ''))
          ## set sticky bit for /tmp
          chmod 01777 /tmp
        __PATCH__
      end

      def wait_for_sshd_vm(ssh_args)
        ssh(ssh_args, <<-__PATCH__.gsub(/^ {10}/, ''))
          id
        __PATCH__
        true
      rescue => ex
        debug([ex.class,ex.message].join(': '))
        logger << "x"
        false
      end

    end
  end
end


module Kitchen
  class Busser
    class_eval do
      alias :orig_setup_cmd :setup_cmd
      def setup_cmd
        @setup_cmd ||= if local_suite_files.empty?
          nil
        else
          setup_cmd  = []
          setup_cmd << busser_setup_env
          setup_cmd << "if ! #{sudo}#{config[:ruby_bindir]}/gem list busser -i >/dev/null"
          setup_cmd << "then #{sudo}#{config[:ruby_bindir]}/gem install #{gem_install_args}"
          setup_cmd << "fi"
          setup_cmd << "gem_bindir=`#{config[:ruby_bindir]}/ruby -rrubygems -e \"puts Gem.bindir\"`"
          setup_cmd << "#{sudo}${gem_bindir}/busser setup"
          setup_cmd << "#{sudo}sed -e 's@sh@bash@' #{config[:busser_bin]} -i"
          setup_cmd << "#{sudo}#{config[:busser_bin]} plugin install #{plugins.join(' ')}"

          "bash -c '#{setup_cmd.join('; ')}'"
        end
      end
    end
  end
end
