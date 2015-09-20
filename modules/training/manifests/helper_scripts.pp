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
		"/root/galeraWaitUntilEmptyRecvQueue.func.sql":
			ensure	=> present,
			mode	=> 755,
			source	=> "puppet:///modules/training/galeraWaitUntilEmptyRecvQueue.func.sql";
	}

	exec {
		"createfunctiongaleraWaitUntilEmptyRecvQueue":
			command => "cat /root/galeraWaitUntilEmptyRecvQueue.func.sql | mysql test && touch /root/galeraWaitUntilEmptyRecvQueue.func.sql.applied",
			path	=> ["/bin/","/usr/bin/"],
			creates	=> "/root/galeraWaitUntilEmptyRecvQueue.func.sql.applied",
			require => [ Service['mysql'], File["/root/galeraWaitUntilEmptyRecvQueue.func.sql"] ];
	}

	# we need to ensure the anonymous users aren't there anymore or the run_app won't work;
	include percona::remove_anonymous_user

	package {
		"sshpass":
			ensure	=> installed;
	}
}