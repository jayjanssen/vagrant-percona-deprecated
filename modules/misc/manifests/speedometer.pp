class misc::speedometer {
	
	case $operatingsystem {
		centos: {
			package {
				'python-urwid': ensure => 'present';
			}

			file {
				'/root/bin/speedometer':
					ensure	=> present,
					mode 	=> 0755,
					source  => "puppet:///modules/misc/speedometer.py"
			}
		}
		ubuntu: {
			package {
				"speedometer":
					ensure	=> installed;
			}
		}
	}
}