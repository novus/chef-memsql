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


#create directories to hold the shellscript and backups.
%w(latest bin).each do |directory|
  if !Dir.exists?("/backups/memsql_backups/#{directory}")
    %x(mkdir -p /backups/memsql_backups/#{directory})
    %x(chown -Rh memsql. /backups/memsql_backups)
  end
end

#loop over the databases to configure cron and create the backup script from the template
node[:memsql][:backups][:databases].each do |database|

  template "/backups/memsql_backups/bin/backup-#{database}.sh" do
    source "backup_database.sh.erb"
    mode 0755
    owner "memsql"
    group "memsql"
    variables ({:database => database})
  end



  cron "memsql backup" do
    hour '*'
    minute '0,30'
    weekday '*'
    command "/backups/memsql_backups/bin/backup-#{database}.sh"
  end



end
