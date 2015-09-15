class training::pxc_exercises {
	
	file {
		"/root/bin/reproduce_lcf.sh":
			ensure	=> present,
			content	=> template('training/reproduce_lcf.sh.erb'),
			mode	=> 0755;
	}

}