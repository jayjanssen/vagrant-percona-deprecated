class mysql::server {
	package { 
		'mysql-community-server':
			ensure => 'installed',
			require => Package['mariadb-libs'];	
		'mysql-community-libs':
			ensure => 'installed',
			require => Package['mariadb-libs'];
		'mariadb-libs':
			ensure => 'purged';
	}
	
}
