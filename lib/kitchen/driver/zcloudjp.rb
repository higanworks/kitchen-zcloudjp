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
        wait_for_sshd(state[:hostname])      ; print "(ssh ready)\n"
      end

      def destroy(state)
        return if state[:server_id].nil?

        server = client.machine.show(state[:server_id])
        server.stop unless server.nil?
        #server.destroy unless server.nil?
        info("SmartMachine <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      def converge(state)
        ssh_args = build_ssh_args(state)

        install_chef_for_smartos(ssh_args)
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
            gem update --system
            gem install --no-ri --no-rdoc ohai
            gem install --no-ri --no-rdoc chef
            gem install --no-ri --no-rdoc rb-readline
          fi
        INSTALL
      end
    end
  end
end
