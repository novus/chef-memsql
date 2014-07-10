#
# Cookbook Name:: memsql
# Recipe:: collectd
#
# Copyright 2014, Chris Molle
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#        node.run_list.roles.include?('base')

package 'libtool'

remote_file "#{Chef::Config[:file_cache_path]}/#{node[:memsql][:collectd][:package]}" do
  source "#{node[:memsql][:url]}/#{node[:memsql][:collectd][:package]}"
  action :create_if_missing
end

dpkg_package node[:memsql][:collectd][:package] do
  source  "#{Chef::Config[:file_cache_path]}/#{node[:memsql][:collectd][:package]}"
  action :install
end

#find the master aggregator
#TODO refactor
filtered = node.memsql.node_scope.enabled ? node.memsql.node_scope.filter : ""
master_aggregator = search(:node, "role:memsql_master_aggregator #{filtered}").first || node

template "/etc/collectd.conf" do
  source "collectd.conf.erb"
  mode 0640
  variables({
                :master_aggregator_ip => node.run_list.roles.include?("memsql_child_aggregator") ? master_aggregator["ipaddress"] : nil
  })
end
