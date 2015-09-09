class mariadb::maxscale {
	
	if $architecture == 'i386' {
		package {
			"maxscale":
				ensure		=> present,
				provider	=> 'rpm',
				source		=> 'https://s3-eu-west-1.amazonaws.com/gryp/tutorial-pxc-advanced/maxscale-1.2.0-i686-.rpm'
		}
	} elsif $architecture == 'x86_64' {
		package {
			"maxscale":
				ensure		=> latest,
				require		=> Class["mariadb::repository::maxscale"]
		}	
	}

	file {
		"/etc/maxscale.cnf":
			ensure  => present,
			content => template("mariadb/maxscale/maxscale.cnf.erb"),
			require => Package["maxscale"]
	}

	service {
		"maxscale":
			ensure	=> 'running',
			require	=> [ Package["maxscale"], File["/etc/maxscale.cnf"] ]
	}

}