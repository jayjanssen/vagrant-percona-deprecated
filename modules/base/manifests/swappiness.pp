class base::swappiness( $swappiness = 1) {
	exec{ 
		'swappiness_sysctl_conf':
			command => "echo 'vm.swappiness = $swappiness' >> /etc/sysctl.conf",
			cwd => '/root',
			unless => "grep '^vm.swappiness = $swappiness' /etc/sysctl.conf",
			path => ['/usr/bin', '/bin'];
		'apply_sysctl':
			# We use -w instead of -p to avoid unknown key errors
			command => "sysctl -w vm.swappiness=$swappiness",
			path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
			unless => "sysctl vm.swappiness | egrep '^vm.swappiness = $swappiness$'";
 	}
}

