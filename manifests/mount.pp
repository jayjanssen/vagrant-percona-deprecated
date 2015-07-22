class { 'misc::mount':
	mount_point => $mount_point,
    mount_dev => $mount_dev, 
    mount_dev_scheduler => $mount_dev_scheduler, 
    mount_fs => $mount_fs, 
    mount_fs_opts => $mount_fs_opts,
    mount_mkfs_opts => $mount_mkfs_opts,
    mount_owner => $mount_owner,
    mount_group => $mount_group,
    mount_mode => $mount_mode
}