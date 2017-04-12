class docker::server (
    $docker_device = undef,
)  {

	package {
		"docker": ensure => installed
	}


	if ( $docker_device ) {
		file {
			"/etc/sysconfig/docker-storage-setup":
				ensure	=> present,
				content	=> "DEVS=$docker_device
VG=docker"
		}
	} else {
		file {
			"/etc/sysconfig/docker-storage-setup":
				ensure	=> present,
				content	=> ""
		}
	}

	service {
		"docker": ensure => running, require => File["/etc/sysconfig/docker-storage-setup"];
	}
}
