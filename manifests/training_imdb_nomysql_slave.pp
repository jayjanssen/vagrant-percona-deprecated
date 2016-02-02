

class { 'mysql::datadir':
	datadir_dev => $datadir_dev
}
class { 'mysql::backupdir':
        backupdir_dev => $backupdir_dev
}
Class['mysql::datadir'] -> Class['mysql::backupdir']

include base::packages
include percona::repository

include training::ssh_key

include percona::config

