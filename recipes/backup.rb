#
# Cookbook Name:: memsql
# Recipe:: default
#
# Copyright 2014-2015, Chris Molle, Steve Koppelman
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

backup_server = node.memsql.backups.backup_server

# Create directories to hold the shellscript and backups.
basedir = node.memsql.backups.basedir
bindir  = "#{basedir}/bin"
latest  = "#{basedir}/latest"

mount basedir do
  device "#{node.memsql.backups.nfs_volume}/#{node.environment}"
  fstype "nfs"
  options "rw"
  action [:mount, :enable]
end

[latest bindir].each do |dir|
  directory dir do
    owner "memsql"
    group "memsql"
  end
end

template_variables = {
  :databases => node[:memsql][:backups][:databases],
  :latest => latest,
  :bindir => bindir,
  :basedir => basedir,
}

# Am I the node assigned to run backups for my cluster? (Usually master aggregator)
if %x(hostname).strip == backup_server

  #loop over the databases to configure cron and create the backup script from the template
  template "#{bindir}/backup-databases.sh" do
    source "backup_database.sh.erb"
    mode 0755
    owner "memsql"
    group "memsql"
    variables template_variables
  end

  template "#{bindir}/rotate-backups.py" do
    source "rotate-backups.py.erb"
    owner "root"
    group "root"
    mode 755
    variables template_variables
  end

  template "/etc/default/rotate-backups" do
    source "rotate-backups.erb"
    owner "root"
    group "root"
    variables template_variables
 end

  # cron "memsql backup" do
  #   hour '*'
  #   minute '0'
  #   weekday '*'
  #   command "#{bindir}/backup-databases.sh"
  # end
end



