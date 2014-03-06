class pacemaker::packages {

	package {
		"pacemaker.$hardwaremodel":
			alias  => "pacemaker",
			ensure => "installed";
	}

	# Get crmsh from opensuse repo
	case $operatingsystem {
		centos: {
			
			exec {
				"opensuse_ha_repo":
					command => "wget -O opensuse_ha.repo http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo",
					cwd => "/etc/yum.repos.d",
					creates => "/etc/yum.repos.d/opensuse_ha.repo",
					path => ['/bin','/usr/bin','/usr/local/bin']
			}
			
			package {
				"crmsh":
					require => Exec['opensuse_ha_repo'],
					ensure => "present";
			}
		}
	}

}
