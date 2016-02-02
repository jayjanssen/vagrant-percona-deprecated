

class { 'mysql::datadir':
	datadir_dev => $datadir_dev
}
include base::packages
include percona::repository

include training::ssh_key

include percona::config

