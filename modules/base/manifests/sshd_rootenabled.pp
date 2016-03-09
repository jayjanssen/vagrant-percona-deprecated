class base::sshd_rootenabled {

	file {
		"/etc/ssh/sshd_config":
			mode	=> 0644,
			owner	=> root,
			group	=> root,
			source	=> "puppet:///modules/base/sshd_config_rootenabled",
			notify	=> Service["sshd"]
	}

	exec {
		"changerootpassword":
			command	=> "/usr/bin/echo -n 'perconapassword' | /usr/bin/passwd root --stdin && touch /root/perconapassword.ok",
			creates	=> "/root/perconapassword.ok"
	}

	service{
		"sshd":
			ensure	=> running
	}
}