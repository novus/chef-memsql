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

default[:memsql][:backups][:databases] = []
default[:memsql][:backups][:nfs_host] = nil
default[:memsql][:backups][:nfs_path] = nil
default[:memsql][:backups][:remote_mount_path] = nil
default[:memsql][:backups][:backup_server] = nil
default[:memsql][:backups][:local_backup_directory] = "memsql_backups"
# memsql-ops

default[:memsql][:ops][:enabled] = false
default[:memsql][:ops][:url] = 'http://download.memsql.com/ops-2.10.0'
default[:memsql][:ops][:package] = 'memsql-ops-2.10.0.x86_64.deb'
default[:memsql][:ops][:http_host] = '0.0.0.0'
default[:memsql][:ops][:http_port] = 9000

default[:memsql][:collectd][:url] = "http://download.memsql.com/ops-latest"
default[:memsql][:collectd][:package] = "collectd-5.4.0.x86_64.deb"
