class percona::remove_anonymous_user {

	exec {
		'remove_anonymous_user':
			command	=> "mysql -Ne \"select concat('DROP USER \\'', user, '\\'@', host, ';') from mysql.user where user='';\" | mysql ",
			cwd 	=> "/root",
			path 	=> ['/usr/bin', '/bin'],
			require => [ Service['mysql'] ];
	}	
}