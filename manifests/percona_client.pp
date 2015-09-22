include percona::repository
include percona::client

Class['percona::repository'] -> Class['percona::client']

if $mha_manager == 'true' {
  include mysql::group
  include mha::node
  include mha::manager
  include percona::toolkit

  Class['percona::client'] -> Class['mha::node'] -> Class['mha::manager']
  Class['mysql::group'] -> Class['mha::node']
}