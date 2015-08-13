#
# Cookbook Name:: memsql
# Recipe:: default
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


# Create user and group first, so we have control over uid and gid instead of leaving it to fate
if %x(grep #{node.memsql.owner} /etc/passwd | wc -l).strip.to_i == 0
  group node.memsql.group do
    gid node.memsql.gid
  end

  user node.memsql.owner do
    uid node.memsql.uid
    group node.memsql.group
    home "/home/#{node.memsql.owner}/"
    shell '/bin/bash'
  end

  execute "add user to sudoers" do
    command "/usr/sbin/adduser #{node.memsql.owner} sudo"
    user 'root'
    action :run
    not_if "grep -Po '^sudo.+:\K.*$' /etc/group | grep memsql"
  end

end

#TODO refactor
filtered = node.memsql.node_scope.enabled ? node.memsql.node_scope.filter : ""
mailto = node.memsql.mailto
is_master      = node.run_list.roles.include?("memsql_master_aggregator") ? true : false
is_child_agg   = node.run_list.roles.include?("memsql_child_aggregator") ? true : false
is_leaf        = node.run_list.roles.include?("memsql_leaf") ? true : false

#leaves     = search(:node, "role:memsql_leaf AND name:#{node['name']}-*")
#child_aggs = search(:node, "role:memsql_child_aggregator AND name:#{node['name']}-*")

memsql_keys = Chef::EncryptedDataBagItem.load( 'secrets', 'memsql_ssh' )
memsql_lic  = Chef::EncryptedDataBagItem.load( 'secrets', 'memsql' )

directory "/home/memsql" do
  owner 'memsql'
  group 'memsql'
  mode '0700'
  not_if { File.exists?("/home/#{node.memsql.owner}/") }
end

directory "/home/memsql/.ssh" do
  owner 'memsql'
  group 'memsql'
  mode '0700'
  not_if { File.exists?("/home/#{node.memsql.owner}/.ssh") }
end


cookbook_file '/opt/memsql-ops-4.0.32.tar.gz' do
  source 'memsql-ops-4.0.32.tar.gz'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'memsql_untar' do
  command 'tar xzvf /opt/memsql-ops-4.0.32.tar.gz'
  cwd '/opt/'
  action :run
  not_if { File.exists?("/opt/memsql-ops-4.0.32") }
end

file '/opt/memsql-ops-4.0.32/' do
  mode '0755'
  user 'root'
  group 'root'
  action :create_if_missing
end

execute 'install_memsql' do
  command './install.sh -n'
  cwd '/opt/memsql-ops-4.0.32/'
  user 'root'
  group 'root'
  action :run
  not_if { File.exists?("/var/lib/memsql-ops") }
end

file "/home/memsql/.ssh/memsql" do
  owner 'memsql'
  group 'memsql'
  mode '0600'
  content memsql_keys['memsql_pem']
end

file "/home/memsql/.ssh/authorized_keys" do
  owner 'memsql'
  group 'memsql'
  mode '644'
  content memsql_keys['memsql_pub']
end

#find the master aggregator
master_aggregator   = search(:node, "role:memsql_master_aggregator AND chef_environment:#{node.chef_environment}")
master_ip_address   = ""

if master_aggregator.length < 1 and is_master
  master_ip_address = node.ipaddress
else
  master_ip_address = master_aggregator[0]['ipaddress']
end

# Install public keys into authorized_keys on leaf nodes to configure things
# with the aggregator:
if is_leaf == true or is_child_agg == true

  execute 'deploy_to_hosts_in_cluster' do
    command "/usr/bin/memsql-ops follow -h #{master_ip_address}"
    user 'root'
    group 'root'
    ignore_failure true
  end

  if is_leaf == true 
    execute 'deploy_memsql_node' do
      command "/usr/bin/memsql-ops memsql-deploy --role leaf --license #{memsql_lic['license']}"
      user 'memsql'
      group 'memsql'
      not_if "/usr/bin/memsql-ops memsql-list | grep #{node['ipaddress']}"
    end
  else
    execute 'deploy_memsql_node' do
      command "/usr/bin/memsql-ops memsql-deploy --role aggregator --license #{memsql_lic['license']}"
      user 'memsql'
      group 'memsql'
      not_if "/usr/bin/memsql-ops memsql-list | grep #{node['ipaddress']}"
    end
  end
end

#install client libs
if node.platform_family == 'debian'
  include_recipe 'apt::default'
  execute 'apt-get update'
end
%w(g++ mysql-client libmysqlclient-dev python-dev).each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

if is_master == true

  remote_file '/opt/memsqlbin_amd64.tar.gz' do
    source 'http://download.memsql.com/62c0f338a5ea4beea8c360cb215741ce/memsqlbin_amd64.tar.gz'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  execute 'add_memsql_to_primary_agent' do
    command '/usr/bin/memsql-ops file-add -f -t memsql /opt/memsqlbin_amd64.tar.gz'
    user 'root'
    group 'root'
    action :run
  end

  # Get private key onto master:
  file "/home/memsql/.ssh/memsql" do
    owner 'memsql'
    group 'memsql'
    mode '0600'
    content memsql_keys['memsql_pem']
  end

  execute 'deploy_memsql_node' do
    command "/usr/bin/memsql-ops memsql-deploy --role master --license #{memsql_lic['license']}"
    user 'root'
    group 'root'
    not_if "/usr/bin/memsql-ops memsql-list | grep #{node['ipaddress']}"
  end

end

template "/var/lib/memsql/memsql.cnf" do
  source "memsql.cnf.erb"
  mode 0600
  owner "memsql"
  group "memsql"
  variables({
    :master_aggregator_ip => node.run_list.roles.include?("memsql_child_aggregator") ? master_ip_address : nil,
    :is_master => is_master,
    :is_child_agg => is_child_agg,
    :is_leaf => is_leaf,
    :redundancy_level => node.memsql.redundancy_level
  })
end

bash 'restart memsql' do
  code <<-EOH
    export id=`/usr/bin/memsql-ops memsql-list --local | /usr/bin/head -2 | /usr/bin/tail -1 | /usr/bin/perl -e 'while(<>) { $test = $_; $test =~ /([[a-zA-Z0-9]+)\s/g; print $1; }'`;
    /usr/bin/memsql-ops memsql-restart $id
  EOH

  user 'root'
  action :run
end

if is_master && node.memsql.bugs.broken_replication_in_31
  replication_unmesser_upper = '/usr/local/sbin/broken_replication_in_31.sh'

  template replication_unmesser_upper do
    source 'broken_replication_in_31.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  cron 'Fix Broken Replication in MemSQL 3.1' do
    minute '*/15'
    command replication_unmesser_upper
    mailto mailto
    path '/usr/local/sbin:/bin:/usr/bin'
  end

end


if is_leaf or is_child_agg
# 14 default[:memsql][:users] = [{:name 
  execute 'add grants' do
    command "/usr/bin/mysql -u root -h #{master_ip_address} -e \"grant all on *.* to '#{node[:memsql][:users][0][:name]}'@'localhost' identified by '#{node[:memsql][:users][0][:password]}'; flush privileges;\""
    user 'root'
    group 'root'
  end

  execute 'add grants' do
    command "/usr/bin/mysql -u root -h #{master_ip_address} -e \"grant all on *.* to '#{node[:memsql][:users][1][:name]}'@'%' IDENTIFIED by '#{node[:memsql][:users][1][:password]}';\""
    user 'root'
    group 'root'
  end
  
else is_master
  execute 'add grants' do
    command "/usr/bin/mysql -u root -h 0.0.0.0 -e \"grant all on *.* to '#{node[:memsql][:users][0][:name]}'@'localhost' identified by '#{node[:memsql][:users][0][:password]}'; flush privileges;\""
    user 'root'
    group 'root'
  end

  execute 'add grants' do
    command "/usr/bin/mysql -u root -h 0.0.0.0 -e \"grant all on *.* to '#{node[:memsql][:users][1][:name]}'@'%' IDENTIFIED by '#{node[:memsql][:users][1][:password]}';\""
    user 'root'
    group 'root'
  end
end

if node.memsql.ops.enabled
  include_recipe "memsql::collectd"
end

if node.memsql.backups.nfs_volume && node.memsql.backups.backup_server
  include_recipe "memsql::backup"
end

logrotate_app 'memsqld' do
  path '/var/lib/memsql/tracelogs/*.log'
  rotate 7
  options %w(missingok sharedscripts compress)
  postrotate ['killall -q -s1 memsqld']
end
