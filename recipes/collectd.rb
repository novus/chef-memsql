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

collectd_pkg = "#{Chef::Config[:file_cache_path]}/#{node[:memsql][:collectd][:package]}"

remote_file collectd_pkg do
  source "#{node[:memsql][:collectd][:url]}/#{node[:memsql][:collectd][:package]}"
  action :create_if_missing
end

dpkg_package 'collectd' do
  source collectd_pkg
  action [:install, :upgrade]
  options "--force-all"
end

filtered = node.memsql.node_scope.enabled ? node.memsql.node_scope.filter : ""
ops_collector = search(:node, "role:memsql_ops #{filtered}").first || node
master_aggregator = node.run_list.roles.include?("memsql_master_aggregator")
standalone = node.run_list.roles.include?("memsql_standalone")

#if (node.run_list.roles.include?("memsql_ops")) && !standalone && !master_aggregator
if false
  service "collectd" do
    action [ :disable, :stop ]
  end
else
  template "/etc/collectd.conf" do
    source "collectd.conf.erb"
    mode 0640
    variables({
                  :collector_ip => standalone ? node.ipaddress : ops_collector.ipaddress
    })
    notifies :restart, "service[collectd]"
  end

  #start collectd
  service "collectd" do
    supports :status => true, :restart => true, :reload => true, :start => true, :stop => true
    action [ :enable ]
  end
end
