class pacemaker::service {
	service {
        	"corosync":
        		enable     => true,
        		ensure     => "running",
        		hasrestart => true,
        		hasstatus  => true,
        		require => [ File["/etc/corosync/corosync.conf"], Package["pacemaker"] ],
    	}

	service {
        	"pacemaker":
        		enable     => true,
        		ensure     => "running",
        		hasrestart => true,
        		hasstatus  => true,
        		require => Service['corosync'],
    	}

}
