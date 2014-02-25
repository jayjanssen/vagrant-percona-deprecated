class pacemaker::mysql_monitor {
	
	file{ '/usr/lib/ocf/resource.d/percona':
		ensure => 'directory'
	}

	exec {
			"mysql_monitor":
				command => "wget -O mysql_monitor https://raw.github.com/percona/percona-pacemaker-agents/master/agents/mysql_monitor && chmod u+x mysql_monitor",
				cwd => "/usr/lib/ocf/resource.d/percona",
				creates => "/usr/lib/ocf/resource.d/percona/mysql_monitor",
				path => ['/bin','/usr/bin','/usr/local/bin'],
				require => File['/usr/lib/ocf/resource.d/percona'];
	}

}
