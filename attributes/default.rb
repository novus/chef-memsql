default[:memsql][:license] = nil
default[:memsql][:version] = "2.6.x86_64.deb"
default[:memsql][:url]  = "http://download.memsql.com"
default[:memsql][:backups][:databases] = []
default[:memsql][:backups][:nfs_host] = nil
default[:memsql][:backups][:nfs_path] = nil
default[:memsql][:backups][:remote_mount_path] = nil
default[:memsql][:users] = [{:name => 'developer', :password => 'password'}]
