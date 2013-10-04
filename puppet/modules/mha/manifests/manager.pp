class mha::manager {


	case $operatingsystem {
		centos: {
			exec {  
				"mha4mysql-manager":
					command => "/usr/bin/yum localinstall -y https://mysql-master-ha.googlecode.com/files/mha4mysql-manager-0.55-0.el6.noarch.rpm",
					cwd => "/tmp",
					unless => "/bin/rpm -q mha4mysql-manager",
					require => [Package['MySQL-shared-compat'], File['/tmp/sysbench.rpm']];
			}
		}
		ubuntu: {
			exec {
				"mha4mysql-manager":
					command => "wget https://mysql-master-ha.googlecode.com/files/mha4mysql-manager_0.55-0_all.deb -qO /tmp/mha4mysql_manager.deb && dpkg -i /tmp/mha4mysql_manager.deb && rm /tmp/mha4mysql_manager.deb",
					cwd => "/tmp",
					path => "/usr/bin:/bin",
					unless => "/usr/bin/dpkg -l mha4mysql-manager";
			}
		}
	}
	
	if( $master_ip_failover_script == undef ) {
		$master_ip_failover_script = "/usr/local/bin/master_ip_failover"
	}
	
	if( $master_ip_online_change_script == undef ) {
		$master_ip_online_change_script = "/usr/local/bin/master_ip_online_change_script"
	}
	
	file {
		"/etc/mha.cnf":
			ensure => 'present',
			content => template("mha/mha.cnf.erb");
		"/usr/local/bin/master_ip_failover":
			ensure => 'present',
			source => 'puppet:///modules/mha/master_ip_failover';
		"/usr/local/bin/master_ip_online_change_script":
			ensure => 'present',
			source => 'puppet:///modules/mha/master_ip_online_change';
	}
}