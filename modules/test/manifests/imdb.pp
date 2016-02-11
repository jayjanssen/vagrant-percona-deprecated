class test::imdb ($type = 'ibd'){
    



    # DB Stuff
    file {
        "/tmp/my.grants.sql":
			source => "puppet:///modules/test/imdb/my.grants.sql";
        "/tmp/my.indexes.sql":
			source => "puppet:///modules/test/imdb/my.indexes.sql";
    }

    if ( $type == 'sql' ) {
        file {
            "/tmp/imdb.sql.bz2":
                require => Exec["mysql-download-imdb"];
        }

        exec {
            "mysql-download-imdb":
                command => "/usr/bin/wget -O /tmp/imdb.sql.bz2 https://s3.amazonaws.com/percona-training/imdb.sql.bz2 && touch /tmp/imdb.sql.bz2.downloaded",
                timeout => 0,
                creates => "/tmp/imdb.sql.bz2.downloaded";
            "mysql-indexes-add":
                command => "/usr/bin/mysql -u root imdb < /tmp/my.indexes.sql && touch /tmp/my.indexes.sql.done",
                creates => "/tmp/my.indexes.sql.done",
                timeout => 0,
                require => [ File["/tmp/my.indexes.sql"], Exec["mysql-imdb-import"] ];
            "mysql-imdb-import":
                command => "/usr/bin/bzcat /tmp/imdb.sql.bz2 | mysql -u root imdb && touch /tmp/imdb.sql.bz2.imported",
                creates => "/tmp/imdb.sql.bz2.imported",
                timeout => 0,
                require => [ Exec['mysql-create-schema'], File["/tmp/imdb.sql.bz2"] ];
        }
    } elsif ( $type == 'ibd' ) {
        file {
            "/tmp/imdb-innodb-ibd.tar.gz.downloaded":
                require => Exec["mysql-download-imdb-tablespaces"];
            "/var/lib/mysql/imdb_import":
                ensure  => directory;
            "/tmp/imdb-innodb-ibd.import.sh":
                content => '#!/bin/bash -e
for file in `ls /var/lib/mysql/imdb_import/*.cfg`; do
    table=`basename $file .cfg`
    mysql -e "ALTER TABLE $table DISCARD TABLESPACE;" imdb
    mv /var/lib/mysql/imdb_import/$table.{cfg,ibd} /var/lib/mysql/imdb/ 
    mysql -e "ALTER TABLE $table IMPORT TABLESPACE;" imdb
    mysql -e "ANALYZE TABLE $table;" imdb
    rm /var/lib/mysql/imdb/$table.cfg
done
touch /tmp/imdb-innodb-ibd.import.sh.done
rm -rf /var/lib/mysql/imdb_import
',
                mode    => 755;

        }

        exec {
            "mysql-download-imdb-tablespaces":
                command => "/usr/bin/wget -O /tmp/imdb-innodb-ibd.tar.gz https://s3.amazonaws.com/percona-training/imdb-innodb-ibd.tar.gz && touch /tmp/imdb-innodb-ibd.tar.gz.downloaded",
                timeout => 0,
                creates => "/tmp/imdb-innodb-ibd.tar.gz.downloaded";
            "mysql-extract-imdb-tablespaces":
                command => "/usr/bin/tar -xzvf /tmp/imdb-innodb-ibd.tar.gz && touch /tmp/imdb-innodb-ibd.tar.gz.extracted",
                cwd     => "/var/lib/mysql/imdb_import",
                creates => "/tmp/imdb-innodb-ibd.tar.gz.extracted",
                require => [ Exec["mysql-download-imdb-tablespaces"], File["/var/lib/mysql/imdb_import"] ];
            "mysql-imdb-create-tables-tablespace":
                command => "/usr/bin/cat /var/lib/mysql/imdb_import/schema.sql | mysql -u root imdb",
                creates => "/var/lib/mysql/imdb/cast_info.frm",
                require => [ Exec["mysql-extract-imdb-tablespaces"], Exec["mysql-create-schema"] ];
            "mysql-import-tablespaces":
                command => "/tmp/imdb-innodb-ibd.import.sh",
                timeout => 0,
                creates => "/tmp/imdb-innodb-ibd.import.sh.done",
                require => [ File["/tmp/imdb-innodb-ibd.import.sh"] , Exec["mysql-imdb-create-tables-tablespace"] ];
        }

    }

    exec {
        "mysql-grants-apply":
            command => "/usr/bin/mysql -u root < /tmp/my.grants.sql && touch /tmp/my.grants.sql.done",
            creates => "/tmp/my.grants.sql.done",
            require => [ File["/tmp/my.grants.sql"] ];
        "my-movies-get-branch":
            command => "/usr/bin/bzr branch lp:my-movies && touch /tmp/my-movies.downloaded",
            cwd => "/tmp",
            creates => "/tmp/my-movies.downloaded",
            require => [ Package["bzr"]];
        "mysql-create-schema":
            command => "/usr/bin/mysqladmin -u root create imdb",
            creates => "/var/lib/mysql/imdb";       
    }

    
    # App stuff
    package {
        "httpd":
            ensure  => latest;
        "php":
            ensure  => latest;
        "php-mysql":
            ensure  => latest;
        "bzr":
            ensure  => latest;
    }

    service {
        "httpd":
            ensure  => running,
            require => [ Package["httpd"], Package["php"], Package["php-mysql"] ];
    }

    exec {
        "install-my-movies":
            command => "/usr/bin/bzr branch lp:my-movies && touch /var/www/html/my-movies.ok",
            cwd => "/var/www/html",
            creates => "/var/www/html/my-movies.ok",
            require => [ Package["httpd"], Package["bzr"] ];
    }

    file {
        "/var/www/html/my-movies/lib/config.inc.php":
            source  => "puppet:///modules/test/my-movies.config.inc.php",
            require => Exec["install-my-movies"];
    }


}
