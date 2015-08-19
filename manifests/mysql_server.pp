include stdlib 

include base::hostname
include base::packages
include base::insecure

class {'base::swappiness':
	swappiness => $swappiness
}


# 5.6 enabled by default.  Client is reponsible to only have one of these 
# enabled and to disable the default.
if( $enable_55 == undef ) {
	$enable_55 = 0
}
if( $enable_56 == undef ) {
	$enable_56 = 1
}
if( $enable_57 == undef ) {
	$enable_57 = 0
}


class { 'mysql::repository':
	55_enabled => $enable_55,
	56_enabled => $enable_56,
	57_enabled => $enable_57
}

include mysql::server
include mysql::config
include mysql::service

if $datadir_dev {
	class { 'mysql::datadir':
		datadir_dev => $datadir_dev,
		datadir_dev_scheduler => $datadir_dev_scheduler,
		datadir_fs => $datadir_fs,
		datadir_fs_opts => $datadir_fs_opts,
		datadir_mkfs_opts => $datadir_mkfs_opts
	}

	Class['mysql::datadir'] -> Class['mysql::server']
}

Class['mysql::repository'] -> Class['mysql::server'] -> Class['mysql::config'] -> Class['mysql::service']


include misc::myq_gadgets
include misc::myq_tools

include test::user

include percona::repository
include percona::toolkit
include percona::sysbench

Class['base::packages'] -> Class['misc::myq_gadgets']
Class['base::packages'] -> Class['misc::myq_tools']

Class['base::packages'] -> Class['percona::repository']
Class['base::insecure'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::toolkit']
Class['percona::repository'] -> Class['percona::sysbench']

Class['mysql::server'] -> Class['percona::toolkit']
Class['mysql::server'] -> Class['percona::sysbench']

Class['mysql::service'] -> Class['test::user']


if $sysbench_load == 'true' {
	class { 'test::sysbench_load':
		schema => $schema,
		tables => $tables,
		rows => $rows,
		threads => $threads,
		engine => $engine
	}
	
	Class['percona::sysbench'] -> Class['test::sysbench_load']
	Class['test::user'] -> Class['test::sysbench_load']
}

if $sysbench_skip_test_client != 'true' {
    include test::sysbench_test_script
}

if $softraid == 'true' {
	class { 'misc::softraid':
		softraid_dev => $softraid_dev,
		softraid_level => $softraid_level,
		softraid_devices => $softraid_devices,
		softraid_dev_str => $softraid_dev_str
	}

	Class['misc::softraid'] -> Class['mysql::datadir']
}

if ( $vividcortex_api_key ) {
	class { 'misc::vividcortex':
		api_key => $vividcortex_api_key
	}
    
    Class['percona::cluster::service'] -> Class['misc::vividcortex']
}
