class training::pxc_exercises {
	
	file {
		"/root/bin/reproduce_lcf.sh":
			ensure	=> present,
			content	=> template('training/reproduce_lcf.sh.erb'),
			mode	=> 0755;
		"/root/bin/last_node_to_dc2.sh":
			ensure	=> present,
			mode 	=> 0755,
			content	=> template('training/last_node_to_dc2.sh.erb');
	}

}