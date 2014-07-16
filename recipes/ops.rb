#
# Cookbook Name:: memsql
# Recipe:: ops
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

ops_pkg = "#{Chef::Config[:file_cache_path]}/#{node[:memsql][:ops][:package]}"

remote_file ops_pkg do
  source "#{node[:memsql][:ops][:url]}/#{node[:memsql][:ops][:package]}"
  action :create_if_missing
end

dpkg_package 'ops' do
  source ops_pkg
  action :install
end

#find the master aggregator
#TODO refactor
filtered = node.memsql.node_scope.enabled ? node.memsql.node_scope.filter : ""
master_aggregator = search(:node, "role:memsql_master_aggregator #{filtered}").first

# What does this Ops instance monitor?
# 1. If node[:memsql][:ops][:monitored_instance] contains a node, that's what it will be monitoring
# 2. No? Look for a master aggregator in the same chef_environment, and monitor that, or
# 3. Otherwise, assume this is a standalone and we want to monitor it
monitored_instance = node.run_list.roles.include?("memsql_standalone") ? node || master_aggregator

template "/var/lib/memsql-ops/memsql_ops.cnf" do
  source "memsql_ops.cnf.erb"
  mode 0640
  variables({
                :monitored_instance => monitored_instance
  })
end

#start ops
service "memsql-ops" do
  supports :status => true, :restart => true, :reload => true, :start => true, :stop => true
  action [ :enable, :start ]
end
