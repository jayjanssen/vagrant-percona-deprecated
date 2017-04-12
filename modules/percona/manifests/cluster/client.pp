class percona::cluster::client {
	# Default PS version is 55 for now
	if( $percona_server_version == undef or $percona_server_version == 55 ) {
		$percona_server_version = '-55'
	} elsif( $percona_server_version == 56 ) {
		$percona_server_version = '-56'
	} elsif( $percona_server_version == 57 ) {
		$percona_server_version = '-57'
	}

	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if $percona_server_version == '' or $percona_server_version == '-57' {
		$other_percona_server_version="-55"
		$other_percona_server_version2="-56"
	} elsif $percona_server_version == "-56" {
		$other_percona_server_version="-55"
		$other_percona_server_version2="-57"
	} elsif $percona_server_version == "-55" {
		$other_percona_server_version="-56"
		$other_percona_server_version2="-57"
	}

    
	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-client$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-shared$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-devel$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-client$other_percona_server_version2.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-shared$other_percona_server_version2.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-devel$other_percona_server_version2.$hardwaremodel":
					ensure => "absent";
                    
				"Percona-XtraDB-Cluster-client$percona_server_version.$hardwaremodel":
					alias => "MySQL-client",
					ensure => "latest";
				"Percona-XtraDB-Cluster-shared$percona_server_version.$hardwaremodel":
					alias => "MySQL-shared",
					ensure => "latest";
			}
		}
		ubuntu: {
			package {
				"percona-server-client":
					alias => "MySQL-client";
			}
		}
	}	
}
