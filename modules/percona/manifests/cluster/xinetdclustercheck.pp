class percona::cluster::xinetdclustercheck {
	include percona::cluster::clustercheckuser
	
	package {
		"xinetd":
			ensure => latest;
	}

	service {
		"xinetd":
			ensure => running;
	}
}

