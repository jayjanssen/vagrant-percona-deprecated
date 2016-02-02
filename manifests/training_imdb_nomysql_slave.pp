

class { 'mysql::datadir':
	datadir_dev => $datadir_dev
}
class { 'mysql::backupdir':
        backupdir_dev => $backupdir_dev
}
include base::packages
include percona::repository

include training::ssh_key

include percona::config

