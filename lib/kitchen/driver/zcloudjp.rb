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
      default_config :dataset, 'sdc:sdc:base64:13.1.0' # base64 image
      default_config :package, 'Small_1GB'

      required_config :api_key

      def create(state)
        server = create_server
        state[:server_id] = server.id

        info("SmartMachine <#{state[:server_id]}> created.")
        server.wait_for { print "."; ready? } ; print "(provision queued)"
        state[:hostname] = server.ips.first
        wait_for_sshd(state[:hostname])      ; print "(first reboot)\n"
        sleep 10
        wait_for_sshd(state[:hostname])      ; print "(second reboot)\n"
        sleep 10

        unless server.os == "SmartOS"
          info("wait for SSH Connection. It takes few minutes. (Only VirtualMachine)")
          ssh_args = build_ssh_args(state)
          sleep 5 until wait_for_sshd_vm(ssh_args)
          print "(ssh ready)\n"
          ## Override ruby_binpath to default
          ::Kitchen::Busser.const_set(:DEFAULT_RUBY_BINPATH, '/opt/chef/embedded/bin')
        else
          wait_for_sshd(state[:hostname])      ; print "(ssh ready)\n"
          ## Override ruby_binpath
          ::Kitchen::Busser.const_set(:DEFAULT_RUBY_BINPATH, '/opt/local/bin')
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
        ssh_args = build_ssh_args(state)

        if server.os == "SmartOS"
          install_chef_for_smartos(ssh_args)
        else
          fix_monkey_dataset(ssh_args)
          install_omnibus(ssh_args) if config[:require_chef_omnibus]
        end
        prepare_chef_home(ssh_args)
        upload_chef_data(ssh_args)
        run_chef_solo(ssh_args)
      end

      def client
        ::Zcloudjp::Client.new(
          :api_key => config[:api_key]
        )
      end

      def create_server
        client.machine.create(
          :dataset => config[:dataset],
          :package => config[:package]
        )
      end

      def install_chef_for_smartos(ssh_args)
        ssh(ssh_args, <<-INSTALL.gsub(/^ {10}/, ''))
          if [ ! -f /opt/local/bin/chef-client ]; then
            # pkgin -y install gcc47 gcc47-runtime scmgit-base scmgit-docs gmake ruby193-base ruby193-yajl ruby193-nokogiri ruby193-readline pkg-config
            pkgin -y install ruby193-base ruby193-yajl ruby193-nokogiri ruby193-readline

          ## for smf cookbook
            pkgin -y install libxslt

          ## install chef
            gem update --system --no-ri --no-rdoc
            gem install --no-ri --no-rdoc ohai
            gem install --no-ri --no-rdoc chef
            gem install --no-ri --no-rdoc rb-readline
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
