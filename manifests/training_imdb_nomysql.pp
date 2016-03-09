

include test::imdb
include test::imdb_ignore_indexes
include training::imdb::workload

class { 'mysql::datadir':
	datadir_dev => $datadir_dev
}

class { 'mysql::backupdir':
	backupdir_dev => $backupdir_dev
}

Class['mysql::datadir'] -> Class['mysql::backupdir']


include misc::innotop

include percona::repository

include training::imdb::optimization

include base::packages

include percona::server
include percona::config
include percona::service

include training::imdb::erase_perconaserverinstall
include training::ssh_key

include misc::sakila
include misc::sakila::install
include percona::agent

Class['test::imdb_ignore_indexes'] -> Class['test::imdb']

Class['mysql::datadir'] -> Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service'] -> Class['percona::agent'] -> Class['misc::innotop'] -> Class ['misc::sakila'] -> Class ['misc::sakila::install'] -> Class ['test::imdb'] -> Class['training::imdb::workload'] -> Class['training::imdb::erase_perconaserverinstall']


