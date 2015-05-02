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


require 'active_support'
require 'zcloudjp'

require 'benchmark'
require 'kitchen'

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
        server = client.machine.show(:id => state[:server_id])
        info("--> Updating metadata...")
        server.metadata.update(:metadata => build_metadata)
        if server.os == "SmartOS"
          overrides =  instance.provisioner.instance_variable_get(:@config)
          overrides[:require_chef_omnibus] = false
          overrides[:ohai_version] = config[:ohai_version] ||= "7.0.4"
          overrides[:chef_version] = config[:chef_version] ||= "11.4"
          overrides[:chef_solo_path] = config[:chef_solo_path] ||= "/opt/local/bin/chef-solo"
          overrides[:client_path] = config[:client_path] ||= "/opt/local/bin/chef-client"
          instance.provisioner.instance_variable_set(:@config, overrides)

          ## Install chef to smartos
          instance.transport.connection(backcompat_merged_state(state)) do |conn|
            conn.execute(env_cmd(install_chef_for_smartos))
          end
        else
          instance.transport.connection(backcompat_merged_state(state)) do |conn|
            conn.execute(env_cmd("sudo chmod 01777 /tmp"))
          end
        end
        super
      end

      private
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

      def install_chef_for_smartos
        if config[:with_gcc]
          install_pkgs = "gcc47 gcc47-runtime scmgit-base scmgit-docs gmake ruby193-base ruby193-yajl ruby193-nokogiri ruby193-readline pkg-config"
        else
          install_pkgs = "scmgit-base scmgit-docs ruby193-base ruby193-yajl ruby193-nokogiri ruby193-readline"
        end

        install_cmd = []
        install_cmd <<  "if [ ! -f /opt/local/bin/chef-client ]; then"
        install_cmd <<  "   pkgin -y install #{install_pkgs}"
        install_cmd <<  "   pkgin -y install libxslt"
        install_cmd <<  "   gem update --system --no-ri --no-rdoc"
        install_cmd <<  "   gem install -f --no-ri --no-rdoc ohai #{config[:ohai_version] ? %Q{--version "#{config[:ohai_version]}"} : nil }"
        install_cmd <<  "   gem install -f --no-ri --no-rdoc chef #{config[:chef_version] ? %Q{--version "#{config[:chef_version]}"} : nil }"
        install_cmd <<  "   gem install -f --no-ri --no-rdoc rb-readline"
        install_cmd <<  "fi"
        "sh -c '#{install_cmd.join("\n")}'"
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


# module Kitchen
#   class Busser
#     class_eval do
#       alias :orig_setup_cmd :setup_cmd
#       def setup_cmd
#         @setup_cmd ||= if local_suite_files.empty?
#           nil
#         else
#           setup_cmd  = []
#           setup_cmd << busser_setup_env
#           setup_cmd << "if ! #{sudo}#{config[:ruby_bindir]}/gem list busser -i >/dev/null"
#           setup_cmd << "then #{sudo}#{config[:ruby_bindir]}/gem install #{gem_install_args}"
#           setup_cmd << "fi"
#           setup_cmd << "gem_bindir=`#{config[:ruby_bindir]}/ruby -rrubygems -e \"puts Gem.bindir\"`"
#           setup_cmd << "#{sudo}${gem_bindir}/busser setup"
#           setup_cmd << "#{sudo}sed -e 's@sh@bash@' #{config[:busser_bin]} -i"
#           setup_cmd << "#{sudo}#{config[:busser_bin]} plugin install #{plugins.join(' ')}"
#
#           "bash -c '#{setup_cmd.join('; ')}'"
#         end
#       end
#     end
#   end
# end
