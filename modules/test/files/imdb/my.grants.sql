GRANT ALL ON imdb.* to 'app'@'%' IDENTIFIED BY 'pass';
GRANT ALL ON *.* to 'approot'@'%' IDENTIFIED BY 'pass';
GRANT FILE ON *.* to 'approot'@'%' IDENTIFIED BY 'pass';
GRANT FILE ON *.* to 'approot'@'%' IDENTIFIED BY 'pass';
GRANT ALL on *.* to cactiuser@"%" identified by "cactiuser";
GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* to 'repl'@'%' IDENTIFIED BY 'pass';
