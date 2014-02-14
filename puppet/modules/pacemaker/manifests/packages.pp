class pacemaker::packages {

	package {
		"pacemaker.$hardwaremodel":
			alias  => "pacemaker",
			ensure => "installed";
	}

}
