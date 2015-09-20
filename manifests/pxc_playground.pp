# different tools which are used to setup lot's of stuff for pxc and to test/train...

include test::sysbench_custom_lua

Class['percona::cluster::service'] -> Class['test::user']
include test::user


# all other defaults
include percona::repository
include percona::cluster::client

Class['percona::repository'] -> Class['percona::cluster::client']

Class['percona::cluster::client'] -> Class['test::sysbench_pkg'] -> Class['test::sysbench_test_script']
include test::sysbench_pkg
include test::sysbench_test_script


include percona::toolkit

Class['percona::repository'] -> Class['percona::toolkit']

include base::packages
include base::hostname
include base::motd

include misc::speedometer
include misc::myq_gadgets
include misc::dbsake

Class['base::packages'] -> Class['misc::myq_gadgets']

include haproxy::server-pxc


include percona::cluster::server
include percona::cluster::config
include percona::cluster::service
include percona::cluster::sstuser

class { 'mysql::datadir':
	datadir_dev => $datadir_dev,
	datadir_dev_scheduler => $datadir_dev_scheduler,
	datadir_fs => $datadir_fs,
	datadir_fs_opts => $datadir_fs_opts,
	datadir_mkfs_opts => $datadir_mkfs_opts
}

Class['mysql::datadir'] -> Class['percona::cluster::server']

Class['percona::repository'] -> Class['percona::cluster::server'] -> Class['percona::cluster::config'] -> Class['percona::cluster::service']


include base::packages
include base::insecure

include mariadb::maxscale

Class['base::insecure'] -> Class['percona::cluster::service']

if ( $percona_agent_enabled == true or $percona_agent_enabled == 'true' ) {
	include percona::agent
}

include training::helper_scripts
include training::pxc_exercises
