class pacemaker ( $ringnumber = '0',
		  $bindnetaddr = '0.0.0.0',
		  $mcastaddr = '226.94.1.1',
		  $mcastport = '5405', 
		  $pcmk_ip = "0.0.0.0") {

	include pacemaker::packages
	include pacemaker::service

	file {
		"/etc/corosync/authkey":
			ensure  => present,
        		mode    => 0400,
        		owner   => "root",
        		group   => "root",
        		source  => "puppet:///modules/pacemaker/authkey",
        		require => Package["pacemaker"];
	}

    	file {
        	"/etc/corosync/corosync.conf":
        		ensure  => present,
        		content => template("pacemaker/corosync.conf.erb"),
        		require => [ File["/etc/corosync/authkey"], Package["pacemaker"] ],
    	}


       	exec { "restart-cluster":
		refreshonly	=> true,
		command		=> "/sbin/service pacemaker stop; /sbin/service corosync restart; /sbin/service pacemaker start",
		require 	=> File["/etc/corosync/corosync.conf"],
		subscribe 	=> File["/etc/corosync/corosync.conf"],
	}

}
