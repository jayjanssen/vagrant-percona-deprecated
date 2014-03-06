include percona::repository
include percona::toolkit
include percona::cluster::packages
include percona::cluster::config

include misc
include misc::mysql_datadir
include misc::sysbench

Class['misc'] -> Class['percona::repository']

Class['misc::mysql_datadir'] -> Class['percona::cluster::packages']

Class['percona::repository'] -> Class['percona::cluster::packages']
Class['percona::repository'] -> Class['percona::toolkit']


Class['percona::cluster::packages'] -> Class['percona::cluster::config']

class {'pacemaker': pcmk_ip => $ipaddress_eth1 }
include pacemaker::pxc_resource_agent

Class['pacemaker::pxc_resource_agent'] -> Class['pacemaker']
