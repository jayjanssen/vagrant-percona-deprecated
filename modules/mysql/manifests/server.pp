class mysql::server {
	package { 
		'mysql-community-server':
			ensure => 'installed',
			require => Package['mariadb-libs'];	
		'mysql-community-libs-compat':
			ensure => 'installed',
			require => Package['mariadb-libs'];
		'mariadb-libs':
			ensure => 'purged';
	}
	
}
