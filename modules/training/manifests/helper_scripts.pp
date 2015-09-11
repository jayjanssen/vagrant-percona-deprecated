class training::helper_scripts {

	file {
		"/root/bin":
			ensure	=> directory;
		"/root/bin/ssh_keygen_and_distribute.sh":
			ensure	=> present,
			content	=> template("training/ssh_keygen_and_distribute.sh.erb"),
			mode	=> 755;
		"/root/bin/run_app.sh":
			ensure	=> present,
			content	=> template("training/run_app.sh.erb"),
			mode	=> 755;
	}

	package {
		"sshpass":
			ensure	=> installed;
	}
}