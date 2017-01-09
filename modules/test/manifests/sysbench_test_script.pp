class test::sysbench_test_script {
	if !$mysql_host { $mysql_host	= 'localhost' }
	if !$mysql_port { $mysql_port	= '3306' }
	if !$schema { $schema	= 'sbtest' }
	if !$tables { $tables	= 1 }
	if !$rows	{ $rows		= 100000 }
	if !$threads { $threads	= 1 }
	if !$tx_rate { $tx_rate	= 0 }
	if !$engine	 { $engine	= 'innodb' }

	file {
		'/usr/local/bin/run_sysbench_reload.sh':
			ensure => present,
			content => "sysbench --db-driver=mysql --test=/usr/share/doc/sysbench/tests/db/oltp.lua --mysql-table-engine=$engine --mysql-user=test --mysql-password=test --mysql-db=$schema --mysql-host=$mysql_host --mysql-port=$mysql_port --oltp-tables-count=$tables cleanup
sysbench --db-driver=mysql --test=/usr/share/doc/sysbench/tests/db/parallel_prepare.lua --mysql-table-engine=$engine --mysql-user=test --mysql-password=test --mysql-db=$schema	 --mysql-host=$mysql_host --mysql-port=$mysql_port --oltp-tables-count=$tables --oltp-table-size=$rows --oltp-auto-inc=off --max-requests=1 run",
			mode => 0755;
		}

	file {
		'/usr/local/bin/run_sysbench_oltp.sh':
			ensure => present,
			content => "sysbench --db-driver=mysql --test=/usr/share/doc/sysbench/tests/db/oltp.lua --mysql-user=test --mysql-password=test --mysql-db=$schema --mysql-host=$mysql_host --mysql-port=$mysql_port --mysql-ignore-errors=all --oltp-tables-count=$tables --oltp-table-size=$rows --oltp-auto-inc=off --num-threads=$threads --report-interval=1 --max-requests=0 --tx-rate=$tx_rate run | grep tps",
			mode => 0755;
	}
	
	file {
		'/usr/local/bin/run_sysbench_update_index.sh':
			ensure => present,
			content => "sysbench --db-driver=mysql --test=/usr/share/doc/sysbench/tests/db/update_index.lua --mysql-user=test --mysql-password=test --mysql-db=$schema --mysql-host=$mysql_host --mysql-port=$mysql_port --mysql-ignore-errors=all --oltp-tables-count=$tables --oltp-table-size=$rows --oltp-auto-inc=off --num-threads=$threads --report-interval=1 --max-requests=0 --tx-rate=$tx_rate run | grep tps",
			mode => 0755;
	}
	
	file {
		'/usr/local/bin/run_sysbench.sh':
			ensure	=> present,
			source	=> "puppet:///modules/test/run_sysbench.sh",
			mode	=> 0755;
		'/var/lib/mysql/sbtest':
			ensure	=> directory,
			owner	=> 'mysql',
			group	=> 'mysql',
			mode	=> '0755',
	}

	if $enable_consul == 'true' {
		# Watch for a test in consul and trigger it when the appropriate key/value is set
		consul::watch {
			'test': type => 'event', handler => 'wall test consul event';
			'sysbench_stop': type => 'event', handler => 'killall sysbench';
			'sysbench_oltp': type => 'event', handler => "pidof sysbench || /usr/local/bin/run_sysbench_oltp.sh";
			'sysbench_update_index': type => 'event', handler => "pidof sysbench || /usr/local/bin/run_sysbench_update_index.sh";
		}
		
		consul::service {
			'sysbench_running': checks => [{script => "killall -0 sysbench", interval => '10s'}];
			'sysbench_ready': checks => [{script => "which sysbench", interval => '1m'}];
		}
	}
}
