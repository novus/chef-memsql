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

attrib = node.memsql.backups
backup_server = attrib.backup_server

# Create directories to hold the shellscript and backups.
basedir   = attrib.basedir
bindir    = "#{basedir}/bin"
latest    = "#{basedir}/latest"
databases = attrib.databases
overrides = {}

directory basedir do
  owner "memsql"
  group "memsql"
end

mount basedir do
  device "#{attrib.nfs_volume}/#{node.environment}"
  fstype "nfs"
  options "rw,hard,vers=3,timeo=3,retrans=10,rsize=32768,wsize=32768"
  action [:mount, :enable]
end

[latest, bindir].each do |dir|
  directory dir do
    owner "memsql"
    group "memsql"
  end
end

databases.each do |d|
  db = d.is_a?(String) ? d : d.keys[0]
  directory "#{latest}/#{db}" do
    owner "memsql"
    group "memsql"
  end
end

base_template_variables = {
  :databases => databases,
  :backup_server => backup_server,
  :latest => latest,
  :bindir => bindir,
  :basedir => basedir,
  :hours => attrib.hours,
  :hourly_backup_hour => attrib.hourly_backup_hour,
  :weekly_backup_day => attrib.weekly_backup_day,
  :max_weekly_backups => attrib.max_weekly_backups
}

# Am I the node assigned to run backups for my cluster? (Usually master aggregator)
if %x(hostname).strip == backup_server

  # cleanup
  template "#{bindir}/backup-databases.sh" do
    source "backup_database.sh.erb"
    action :delete
  end

  cron "memsql backup" do
    action :delete
  end
  cron "rotate memsql backups" do
    action :delete
  end
  file "/etc/default/rotate-backups" do
    action :delete
  end
  # end cleanup


  # loop over the databases to configure cron and create the backup script from the template
  # Each element of the array can be either a string (using uniform settings) or a hash
  # (which can include overrides to any memsql.backups subattributes).
  databases.each do |d|
    if d.is_a?(String)
      db = d
      overrides[db] = {}
    elsif d.is_a?(Hash)
      db = d.keys[0].to_s
      overrides[db] = d.values[0]
      log "==> #{db} is a hash with #{overrides[db].inspect}"
    end

   template_variables = base_template_variables.merge(overrides[db])

   template_variables['database'] = db
   backup_script = "#{bindir}/backup-database-#{db}.sh"
   rotate_config = "/etc/default/rotate-backups.#{db}"
   rotate_script = "#{bindir}/rotate-backups-#{db}.py"

   template backup_script do
     source "backup_database.sh.erb"
     mode 0755
     owner "root"
     group "root"
     variables template_variables
   end

   template rotate_config do
     source "rotate-backups.erb"
     owner "root"
     group "root"
     variables template_variables
   end

   template rotate_script do
     source "rotate-backups.py.erb"
     owner "root"
     group "root"
     mode 755
     variables template_variables
   end

   cron "rotate memsql backups for #{db}" do
     hour '*'
     minute '30'
     weekday '*'
     command rotate_script
   end

   cron "memsql backup #{db}" do
     hour "#{template_variables[:hours]}"
     minute '0'
     weekday '*'
     command backup_script
   end
  end
end



