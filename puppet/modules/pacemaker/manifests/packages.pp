class pacemaker::packages {

	package {
		"pacemaker.$hardwaremodel":
			alias  => "pacemaker",
			ensure => "installed";
	}

	# Get crmsh from opensuse repo
	case $operatingsystem {
		centos: {
			yumrepo{ 'network_ha-clustering_Stable':
				descr => "Stable High Availability/Clustering packages (CentOS_CentOS-6)",
				gpgcheck => "1",
				enabled => "1",
				baseurl => "http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/
",
				gpgkey => "http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/repodata/repomd.xml.key"
				
			}
			
			package {
				"crmsh":
					require => Yumrepo['network_ha-clustering_Stable'],
					ensure => "present";
			}
		}
	}

}
