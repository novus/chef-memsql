#lets mount a shared NFS location for placing backups to be archived
puts "looking for #{node[:memsql][:backups][:nfs_host]} in /etc/mtab"
if %x(grep #{node[:memsql][:backups][:nfs_host]} /etc/mtab |wc -l).strip.to_i == 0
  puts "#{node[:memsql][:backups][:nfs_host]} not found, creating directories"
  %x(sudo mkdir -p #{node[:memsql][:backups][:nfs_path]})
  puts "#{node[:memsql][:backups][:nfs_path]} created"
  %x(sudo mount #{node[:memsql][:backups][:nfs_host]}:/#{node[:memsql][:backups][:remote_mount_path]} #{node[:memsql][:backups][:nfs_path]})
  puts "#{node[:memsql][:backups][:nfs_host]}:/#{node[:memsql][:backups][:remote_mount_path]} #{node[:memsql][:backups][:nfs_path]} mounted"
  %x(sudo mkdir -p #{node[:memsql][:backups][:nfs_path]}/)
  %x(sudo chown -Rh #{node[:memsql][:owner]}. #{node[:memsql][:backups][:nfs_path]}/backups)
  %x(ln -s #{node[:memsql][:backups][:nfs_path]}/backups/ /backups)
  %x(grep #{node[:memsql][:backups][:nfs_host]} /etc/mtab >> /etc/fstab) if %x(grep #{node[:memsql][:backups][:nfs_host]} /etc/fstab |wc -l).strip.to_i == 0
end
