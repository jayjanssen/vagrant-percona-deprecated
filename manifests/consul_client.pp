include stdlib

$config_hash = delete_undef_values( {
	'datacenter' => $datacenter,
	'data_dir' => '/opt/consul',
	'log_level' => 'INFO',
	'node_name' => $node_name ? {
		undef => $vagrant_hostname,
		default => $node_name
	},
	'bind_addr' => $default_interface ? {
		undef => undef,
		default => getvar("ipaddress_${default_interface}")
	},
	'client_addr' => '0.0.0.0',
	'ui_dir' => '/opt/consul/ui',
	'server' => false,
	'retry_join' => split($retry_join, ',')
})

class { 'consul':
	version => '0.7.2',
	config_hash => $config_hash
}
