class base::motd {

	file {
		"/etc/motd":
			ensure	=> present,
			source	=> "puppet:///modules/base/motd"
	}	
	
}