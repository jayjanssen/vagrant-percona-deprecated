

class { 'mysql::datadir':
	datadir_dev => $datadir_dev
}
include base::packages
include percona::repository

include percona::config

