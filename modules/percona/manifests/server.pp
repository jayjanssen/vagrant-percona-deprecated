class percona::server {
	# Default PS version is 57 for now
	if( $percona_server_version == undef ) {
		$percona_server_version = '57'
	}
	
	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if $percona_server_version == 55 {
		$other_percona_server_version="56"
		$other_percona_server_version2="57"
	} elsif $percona_server_version == 56 {
		$other_percona_server_version="55"
		$other_percona_server_version2="57"
	} elsif $percona_server_version == 57 {
		$other_percona_server_version="55"
		$other_percona_server_version2="56"
	}

	case $operatingsystem {
		centos: {
			package {
				"mariadb-libs":
					ensure => purged;
				"Percona-Server-client-$percona_server_version.$hardwaremodel":
					alias => "MySQL-client",
					ensure => latest;
				"Percona-Server-client-$other_percona_server_version.$hardwaremodel":
					before => Package["Percona-Server-client-$percona_server_version.$hardwaremodel"],
					require => Package["Percona-Server-server-$other_percona_server_version.$hardwaremodel"],
					ensure => absent;
				"Percona-Server-client-$other_percona_server_version2.$hardwaremodel":
					before => Package["Percona-Server-client-$percona_server_version.$hardwaremodel"],
					require => Package["Percona-Server-server-$other_percona_server_version2.$hardwaremodel"],
					ensure => absent;
				"Percona-Server-server-$percona_server_version.$hardwaremodel":
					alias => "MySQL-server",
					require => Package["MySQL-client"],
					ensure => latest;
				"Percona-Server-server-$other_percona_server_version.$hardwaremodel":
					before => Package["Percona-Server-server-$percona_server_version.$hardwaremodel"],
					ensure => absent;
				"Percona-Server-server-$other_percona_server_version2.$hardwaremodel":
					before => Package["Percona-Server-server-$percona_server_version.$hardwaremodel"],
					ensure => absent;
				"Percona-Server-shared-$percona_server_version.$hardwaremodel":
					alias => "MySQL-shared",
					ensure => latest;
				"Percona-Server-shared-$other_percona_server_version.$hardwaremodel":
					before => Package["MySQL-client"],
					ensure => absent;
				"Percona-Server-shared-$other_percona_server_version2.$hardwaremodel":
					before => Package["MySQL-client"],
					ensure => absent;
			}
		}

		ubuntu: {
			package {
				"percona-server-client":
					alias => "MySQL-client";
				"percona-server-server":
					name => $percona_server_version ? {
						'55' => "percona-server-server-5.5",
						'56' => "percona-server-server-5.6",
						'57' => "percona-server-server-5.7"
					},
					alias => "MySQL-server",
					ensure => latest;
			}
		}
	}	
}
