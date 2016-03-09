
class percona::agent {

    exec {
        "download_percona_agent":
            command => "/usr/bin/curl -O https://www.percona.com/redir/downloads/TESTING/ppl/open-source/ppl-agent.tar.gz",
            creates => '/root/ppl-agent.tar.gz',
            cwd     => '/root/',
            path    => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin';
        "extract_percona_agent":
            command => 'tar -xzvf /root/ppl-agent.tar.gz && touch /root/ppl-agent',
            creates => '/root/ppl-agent',
            require => Exec['download_percona_agent'],
            cwd     => '/root',
            path    => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin';
        "install_percona_agent":
            command => "cd percona-agent-* ; ./install -interactive=false docker:9001",
            require => Exec['extract_percona_agent'],
            creates => '/usr/local/percona/agent/bin/percona-agent',
            cwd     => '/root/',
            path    => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin';
    }    

}
