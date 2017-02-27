# reset 57 password, requires validate-password=OFF in config

class percona::server-password {
    if $percona_server_version == "57" or $percona_server_version == "-57" {
        exec {"remove57randompassword":
            command => 'mysql -u root -p`grep "A temporary password is generated for root@localhost" /var/log/mysqld.log | tail -n 1 | awk "{print \\$(NF)}"` --connect-expired-password -e "set password=\"\""',
            path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
            unless  => "/usr/bin/mysqladmin ext",
            require => Service["mysql"]
        }
    }   
}
