class misc::vividcortex(
	$api_key
) {
    exec {
    		"get_vividcortex_installer":
    			command => "wget -O vividcortex_installer https://download.vividcortex.com/install",
    			cwd => "/tmp",
    			creates => "/tmp/vividcortex_installer",
    			path => ['/bin','/usr/bin','/usr/local/bin'],
    			require => Package['wget'];
    		"install_vividcortex":
    			command => "sh /tmp/vividcortex_installer -t $api_key --autostart -s --no-proxy",
    			cwd => "/tmp",
    			creates => "/usr/local/bin/vc-agent-007",
    			path => ['/bin','/usr/bin','/usr/local/bin'],
    			require => Exec['get_vividcortex_installer'];
    }
}
