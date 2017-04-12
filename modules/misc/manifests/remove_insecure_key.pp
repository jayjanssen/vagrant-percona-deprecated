class misc::remove_insecure_key {
	exec {
		"remove_insecure_key":
			path	=> "/bin:/usr/bin:/sbin:/usr/sbin",
			command	=> "sed -ie 's/.*vagrant insecure public key.*//' /root/.ssh/authorized_keys";
	}
}
