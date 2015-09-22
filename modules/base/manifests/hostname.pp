class base::hostname {
	exec {
		"set_hostname":
			command => "hostname $vagrant_hostname",
			unless => "test `hostname` = $vagrant_hostname",
			path => ["/bin", "/usr/bin"];
		"remove_hostname_from_localhost_ip":
			command	=> "sed -ie 's/127.0.0.1.*/127.0.0.1\tlocalhost localhost.localdomain localhost4 localhost4.localdomain4/' /etc/hosts",
			path => ["/bin", "/usr/bin"];
	}
}
