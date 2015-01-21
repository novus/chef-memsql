default[:memsql][:owner] = 'memsql'
default[:memsql][:group] = node.memsql.owner
default[:memsql][:uid] = 2027
default[:memsql][:gid] = node.memsql.uid
default[:memsql][:license] = nil
default[:memsql][:version] = "3.1.x86_64.deb"
default[:memsql][:redundancy_level] = 1
default[:memsql][:url] = "http://download.memsql.com"
default[:memsql][:users] = [{:name => 'developer', :password => 'password'}]
default[:memsql][:node_scope][:enabled] = true
default[:memsql][:node_scope][:filter] = " AND chef_environment:#{node.chef_environment}"

# Backups
default[:memsql][:backups][:nfs_volume] = nil
default[:memsql][:backups][:basedir] = '/backups'
default[:memsql][:backups][:databases] = []
default[:memsql][:backups][:backup_server] = nil

# memsql-ops

default[:memsql][:ops][:enabled] = false
default[:memsql][:ops][:url] = 'http://download.memsql.com/ops-3.1.2'
default[:memsql][:ops][:package] = 'memsql-ops-3.1.2.x86_64.deb'
default[:memsql][:ops][:http_host] = '0.0.0.0'
default[:memsql][:ops][:http_port] = 9000

default[:memsql][:collectd][:url] = "http://download.memsql.com/ops-3.1.2"
default[:memsql][:collectd][:package] = "collectd-5.4.0-6.x86_64.deb"
