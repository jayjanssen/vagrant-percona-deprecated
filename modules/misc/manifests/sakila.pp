class misc::sakila {
	exec {
			"wget http://downloads.mysql.com/docs/sakila-db.zip":
				cwd => "/root",
				creates => "/root/sakila-db.zip",
				path => ['/bin','/usr/bin','/usr/local/bin'],
				require => Package['wget'];
	}
}

class misc::sakila::install {

	exec {
	"sakila-unzip":
		cwd 	=> "/root",
		command => "unzip sakila-db.zip",
		creates => "/root/sakila-db",
		path 	=> ['/bin','/usr/bin/','/usr/local/bin'],
		require => Class['misc::sakila'];
	"sakila-load":
		cwd 	=> "/root/sakila-db/",
		command => "cat sakila-schema.sql sakila-data.sql | mysql",
		creates => "/var/lib/mysql/sakila/",
		path 	=> ['/bin','/usr/bin/','/usr/local/bin'],
		require => Exec['sakila-unzip'];
	}
}