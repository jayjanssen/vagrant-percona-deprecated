class misc::myq_tools {
    exec {
    		"myq_tools":
    			command => "wget `curl -s https://api.github.com/repos/jayjanssen/myq-tools/releases | grep browser_download_url | head -n 1 | cut -d '\"' -f 4` && tar xvzf myq_tools.tgz -C /usr/local/bin --strip-components=1 && ln -sf /usr/local/bin/myq_status.linux-amd64 /usr/local/bin/myq_status",
    			cwd => "/tmp",
    			creates => "/usr/local/bin/myq_status.linux-amd64",
    			path => ['/bin','/usr/bin','/usr/local/bin'],
    			require => Package['wget'];
    }
}