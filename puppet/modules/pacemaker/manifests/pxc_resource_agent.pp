class pacemaker::pxc_resource_agent {
	file { 
		'/usr/lib/ocf/resource.d/percona':
			ensure => 'directory';
		'/usr/lib/ocf/resource.d/percona/pxc_resource_agent':
			ensure => 'link',
			target => "/vagrant/percona-pacemaker-agents/agents/pxc_resource_agent",
			require => File['/usr/lib/ocf/resource.d/percona'];
	}
}
