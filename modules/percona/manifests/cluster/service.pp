class percona::cluster::service {

	# We bootstrap the bootstrap-ed node.
	# This means that when we provision happens on that node,
	# MySQL will (re)start, bootstrap, and potentially create
	# a new cluster. This can have nasty consequences for your environment
	# if you don't understand all the pieces.

	if( $pxc_bootstrap_node == "true" or $pxc_bootstrap_node == true) {
		# We do not use the redhat provider but the old fashioned init scripts
		# by using the 'base' provider. this allows sending pxc-bootstrap as
		# command instead of 'start'

		if( $operatingsystem == 'centos' and $operatingsystemrelease =~ /^7/ ) {
			service {
				"mysql":
					enable		=> true,
					ensure		=> 'running',
					provider	=> 'base',
					start		=> "(test -f /var/lib/mysql/grastate.dat && systemctl start mysql) || systemctl start mysql@bootstrap",
					require		=> Package['MySQL-server'],
					subscribe	=> File["/etc/my.cnf"];
			}
		} else {
			service {
				"mysql":
					enable		=> true,
					ensure		=> 'running',
					provider	=> 'base',
					status		=> "/etc/init.d/mysql status",
					start		=> "(test -f /var/lib/mysql/grastate.dat && /etc/init.d/mysql start) || /etc/init.d/mysql bootstrap-pxc",
					stop		=> "/etc/init.d/mysql stop",
					require		=> Package['MySQL-server'],
					subscribe	=> File["/etc/my.cnf"];
			}
		}
	} else {
		service {
			'mysql':
				ensure 			=> 'running',
				subscribe 		=> File["/etc/my.cnf"];
		}
	}
}