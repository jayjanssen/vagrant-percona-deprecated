class mysql::backupdir (
    $backupdir_dev, 
    $backupdir_dev_scheduler = 'noop', 
    $backupdir_fs = 'xfs', 
    $backupdir_fs_opts = 'noatime',
    $backupdir_mkfs_opts = ''
) {
	# Need to set $backupdir_dev from Vagrantfile for this to work right

	exec {
		"mkfs_mysql_backupdir":
			command => "mkfs.$backupdir_fs $backupdir_mkfs_opts /dev/$backupdir_dev",
			require => $backupdir_fs ? {
				'xfs'	=> Package['xfsprogs'],
				default	=> []
			},
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "mount | grep '/var/backup'";
	}

	mount {
		"/var/backup":
			ensure => "mounted",
			device => "/dev/$backupdir_dev",
			fstype => $backupdir_fs,
			options => $backupdir_fs_opts,
			atboot => "true",
			require => Exec["mkfs_mysql_backupdir", "mkdir_mysql_backupdir"];

	}

	# IO scheduler
	exec {
		"backupdir_dev_scheduler":
			command => "echo '$backupdir_dev_scheduler' > /sys/block/$backupdir_dev/queue/scheduler",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "grep -E '\\[$backupdir_dev_scheduler\\]|none' /sys/block/$backupdir_dev/queue/scheduler";
	}
    
    exec {
		"mkdir_mysql_backupdir":
			command => "mkdir /var/backup",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "test -d /var/backup";

    }


}
