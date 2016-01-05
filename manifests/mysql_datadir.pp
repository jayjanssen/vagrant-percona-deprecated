class { 'mysql::datadir':
	datadir_dev => $datadir_dev,
	datadir_dev_scheduler => $datadir_dev_scheduler,
	datadir_fs => $datadir_fs,
	datadir_fs_opts => $datadir_fs_opts,
	datadir_mkfs_opts => $datadir_mkfs_opts
}
