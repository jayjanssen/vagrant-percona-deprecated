class percona::cluster::server {
	# Default PS version is 57
	if( $percona_server_version == undef or $percona_server_version == 57 ) {
		$percona_server_version = '-57'
	} elsif( $percona_server_version == 55 ) {
		$percona_server_version = '-55'
	} elsif( $percona_server_version == 56 ) {
		$percona_server_version = '-56'
	}

	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if ( $percona_server_version == '' or $percona_server_version == '-57' ) {
		$other_percona_server_version="-55"
		$other_percona_server_version2="-56"
	} elsif $percona_server_version == "-55" {
		$other_percona_server_version="-56"
		$other_percona_server_version2="-57"
	} elsif $percona_server_version == "-56" {
		$other_percona_server_version="-55"
		$other_percona_server_version2="-57"
	}
	
	# You can set the $galera_version to 2 or 3 for either 55 or 56, but if it is not set it defaults like this:
	if( $galera_version == undef ) {
		if( $percona_server_version == "-55" ) {
			$galera_version = '2'
		} elsif( $percona_server_version == "-56" or $percona_server_version == "-57" ) {
			$galera_version = '3'
		}
	}
	
	if( $galera_version == '2' ) {
		$other_galera_version = '3'
	} elsif( $galera_version == '3' ) {
		$other_galera_version = '2'
	}

	if ( $percona_server_version == "-57" ) {
		# temp fix for https://bugs.launchpad.net/percona-xtradb-cluster/+bug/1615089
		exec {"update_ld_so_conf_shared_path":
			command => "/usr/bin/echo '/usr/lib64/mysql' > /etc/ld.so.conf.d/percona-xtradb-cluster-shared-5.7.12-x86_64.conf ; /sbin/ldconfig",
			onlyif  => "/usr/bin/md5sum /etc/ld.so.conf.d/percona-xtradb-cluster-shared-5.7.12-x86_64.conf | /usr/bin/grep b74fdfa1c279dd2f8ec5febc0588a538",
			require => Package["MySQL-server"];
		}
	}

	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-server$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-server$other_percona_server_version2.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-galera-$other_galera_version":
					ensure => "absent";
			}
			# 57 does not requrie galera package anymore. it's builtin.
			if ( $percona_server_version != "-57" ) {
				package {
					"Percona-XtraDB-Cluster-server$percona_server_version.$hardwaremodel":
						require => [ Package['galera'], Package["MySQL-shared"] ],
						alias => "MySQL-server",
						ensure => "latest",
						notify => Service['mysql'];
					"Percona-XtraDB-Cluster-galera-$galera_version":
						alias => "galera",
						ensure => "latest",
						notify => Service['mysql'];
				}
			} else {
				package {
					"Percona-XtraDB-Cluster-galera-$galera_version":
						alias => "galera",
						before => Package["MySQL-server"],
						ensure => "absent";
					"Percona-XtraDB-Cluster-server$percona_server_version.$hardwaremodel":
						require => [ Package["MySQL-shared"] ],
						alias => "MySQL-server",
						ensure => "latest",
						notify => Service['mysql'];
				}
			}
		}
		ubuntu: {
			package {
				"percona-xtradb-cluster-server-5.5":
					alias => "MySQL-server";
				"percona-xtradb-cluster-client-5.5":
					alias => "MySQL-client";
			}
		}
	}
	
	
	if $enable_consul == 'true' {
		consul::service {'pxc': checks => [{
				port           => 3306,
				script   => '/usr/bin/clustercheck || (exit 2)',
				interval => '5s'
			}];
		}
	}
}
