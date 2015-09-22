class mha::user {
	exec {
		'create_mha_user_all':
			command => "mysql -e \"GRANT ALL ON *.* TO 'mha'@'%' IDENTIFIED BY 'mha'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT ALL PRIVILEGES ON *.* TO 'mha'@'%'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'], Service['mysql'] ];
		'create_mha_user_localhost':
			command => "mysql -e \"GRANT ALL ON *.* TO 'mha'@'localhost' IDENTIFIED BY 'mha'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT ALL PRIVILEGES ON *.* TO 'mha'@'localhost'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'], Service['mysql'] ];
	}
}
