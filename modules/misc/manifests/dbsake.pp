class misc::dbsake {
	file {
		'/usr/local/bin/dbsake':
			ensure	=> present,
			mode 	=> 0755,
			source  => "puppet:///modules/misc/dbsake";
	}
}