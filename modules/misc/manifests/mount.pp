class misc::mount (
	$mount_point,
    $mount_dev, 
    $mount_dev_scheduler = 'noop', 
    $mount_fs = 'xfs', 
    $mount_fs_opts = 'noatime',
    $mount_mkfs_opts = '-f',
    $mount_owner = 'root',
    $mount_group = 'root',
    $mount_mode = '0775'
) {
	# Need to set $mount_dev from Vagrantfile for this to work right

	package {
    	'xfsprogs': ensure => 'present';
	}
	exec {
		"mkfs_mount":
			command => "mkfs.$mount_fs $mount_mkfs_opts /dev/$mount_dev",
			require => Package['xfsprogs'],
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "mount | grep '$mount_point'";
	}
	mount {
		'mount point': 
			name => $mount_point,
			ensure => "mounted",
			device => "/dev/$mount_dev",
			fstype => $mount_fs,
			options => $mount_fs_opts,
			atboot => "true",
			require => [Exec["mkfs_mount"], File[$mount_point]];

	}
	# IO scheduler
	exec {
		"mount_dev_scheduler":
			command => "echo '$mount_dev_scheduler' > /sys/block/$mount_dev/queue/scheduler",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "grep -E '\\[$mount_dev_scheduler\\]|none' /sys/block/$mount_dev/queue/scheduler";
		"fix_perms":
			command => "chown $mount_owner.$mount_group $mount_point && chmod $mount_mode $mount_point && touch $mount_point/.perms_set",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			creates => "$mount_point/.perms_set",
			require => Mount['mount point'];

	}
    
    file {
		$mount_point:
			ensure => 'directory',
			owner => $mount_user,
			group => $mount_group,
			mode => $mount_mode;

    }

}