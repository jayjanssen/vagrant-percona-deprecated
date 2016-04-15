class haproxy::server {
	package { 
		'haproxy':
			ensure => 'installed';	
	}

	service {
		'haproxy':
			enable => true,
			ensure => 'running';
	}
	
	file {
		'/etc/haproxy/haproxy.cfg':
			ensure => 'present',
			require => Package['haproxy'],
			content => template('haproxy/haproxy.cfg.erb');
	}

}
