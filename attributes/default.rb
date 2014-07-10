default[:memsql][:owner] = 'memsql'
default[:memsql][:group] = node.memsql.owner
default[:memsql][:uid] = 2027
default[:memsql][:gid] = node.memsql.uid
default[:memsql][:license] = nil
default[:memsql][:version] = "2.6.x86_64.deb"
default[:memsql][:redundancy_level] = 1
default[:memsql][:url]  = "http://download.memsql.com"
default[:memsql][:backups][:databases] = []
default[:memsql][:backups][:nfs_host] = nil
default[:memsql][:backups][:nfs_path] = nil
default[:memsql][:backups][:remote_mount_path] = nil
default[:memsql][:users] = [{:name => 'developer', :password => 'password'}]
default[:memsql][:node_scope][:enabled] = true
default[:memsql][:node_scope][:filter] = " AND chef_environment:#{node.chef_environment}"
default[:memsql][:ops][:enabled] = false
default[:memsql][:collectd][:url] = "http://download.memsql.com/ops-latest"
default[:memsql][:collectd][:package] = "collectd-5.4.0.x86_64.deb"
