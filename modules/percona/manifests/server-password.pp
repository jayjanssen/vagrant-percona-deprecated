# reset 57 password, requires validate-password=OFF in config

class percona::server-password {
    if $percona_server_version == 57 {
        exec {"remove57randompassword":
            command => 'mysql -u root -p`cat /var/lib/mysql/error.log | grep "A temporary password is generated for root@localhost" | tail -n 1 | awk "{print \\$(NF)}"` --connect-expired-password -e "set password=\"\"" && touch /root/mysqlpassword.ok',
            path    => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
            creates => "/root/mysqlpassword.ok",
            require => Service["mysql"]
        }
    }   
}
