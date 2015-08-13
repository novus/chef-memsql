default[:memsql][:owner] = 'memsql'
default[:memsql][:group] = node.memsql.owner
default[:memsql][:uid] = 2027
default[:memsql][:gid] = node.memsql.uid

# Create the following data bags for use here:
memsql_creds     = Chef::EncryptedDataBagItem.load("secrets", "memsql")
datacrunch_creds = Chef::EncryptedDataBagItem.load("secrets", "datacrunch")
developer_creds  = Chef::EncryptedDataBagItem.load("secrets", "developer")

default[:memsql][:license] = "#{memsql_creds['license']}"
default[:memsql][:version] = "3.1.x86_64.deb"
default[:memsql][:redundancy_level] = 2
default[:memsql][:url] = "http://download.memsql.com"

default[:memsql][:users] = [{:name => "#{developer_creds['user']}", :password => "#{developer_creds['password']}"}, {:name => "#{datacrunch_creds['user']}", :password => "#{datacrunch_creds['password']}"}]
default[:memsql][:node_scope][:enabled] = true
default[:memsql][:node_scope][:filter] = " AND chef_environment:#{node.chef_environment}"
default[:memsql][:mailto] = nil
default[:memsql][:bugs][:broken_replication_in_31] = false

### Backups
# If all of these attributes are populated in the environment/role, backup
# will be set up automatically

default[:memsql][:backups][:nfs_volume] = nil         # NFS URL "HOST:/EXPORT_PATH"
default[:memsql][:backups][:basedir] = '/backups'     # Mount point
default[:memsql][:backups][:databases] = []           # Array of database names
default[:memsql][:backups][:backup_server] = nil      # FQDN
default[:memsql][:backups][:hourly_backup_hour] = 10  # Make sure a backup takes place at LEAST at this hour
default[:memsql][:backups][:weekly_backup_day] = 6    # 0-6 Mon-Sun
default[:memsql][:backups][:max_weekly_backups] = 10  #
default[:memsql][:backups][:hours] = "*"              # cron expression

### memsql-ops

default[:memsql][:ops][:enabled] = false
default[:memsql][:ops][:url] = 'http://download.memsql.com/ops-3.1.2'
default[:memsql][:ops][:package] = 'memsql-ops-3.1.2.x86_64.deb'
default[:memsql][:ops][:http_host] = '0.0.0.0'
default[:memsql][:ops][:http_port] = 9000
# Retention is in hours
default[:memsql][:ops][:retention] = 6
default[:memsql][:ops][:events_retention] = 6
default[:memsql][:ops][:facts_retention] = 6


default[:memsql][:collectd][:url] = "http://download.memsql.com/ops-3.1.2"
default[:memsql][:collectd][:package] = "collectd-5.4.0-6.x86_64.deb"
