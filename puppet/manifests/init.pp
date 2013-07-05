# include percona::repository
# include percona::toolkit
# include percona::server
include misc

# Class['percona::repository'] -> Class['percona::server']  -> Exec['replication-user']
# Class['percona::repository'] -> Class['percona::toolkit']
