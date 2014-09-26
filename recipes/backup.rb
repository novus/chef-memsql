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

include_recipe "memsql::nfs"

#create directories to hold the shellscript and backups.
%x(sudo mkdir -p #{node[:memsql][:backups][:nfs_path]}/#{node[:memsql][:backups][:local_backup_directory]}/) if !Dir.exists?("#{node[:memsql][:backups][:nfs_path]}/#{node[:memsql][:backups][:local_backup_directory]}/")
%x(sudo ln -s #{node[:memsql][:backups][:nfs_path]}/#{node[:memsql][:backups][:local_backup_directory]}/ /backups) if !File.exists?('/backups')

%w(latest bin).each do |directory|
  directory "/backups/#{directory}" do
    owner "memsql"
    group "memsql"
    recursive true
  end
end

if %x(hostname).strip == node[:memsql][:backups][:backup_server]
#loop over the databases to configure cron and create the backup script from the template

  template "/backups/bin/backup-databases.sh" do
    source "backup_database.sh.erb"
    mode 0755
    owner "memsql"
    group "memsql"
    variables ({:databases => node[:memsql][:backups][:databases]})
  end

  template "/backups/bin/rotate-backups.py" do
    source "rotate-backups.py.erb"
    owner "root"
    group "root"
    mode 755
  end

  template "/etc/default/rotate-backups" do
    source "rotate-backups.erb"
    owner "root"
    group "root"
  end

  cron "memsql backup" do
    hour '*'
    minute '0'
    weekday '*'
    command "/backups/bin/backup-databases.sh"
  end
end



