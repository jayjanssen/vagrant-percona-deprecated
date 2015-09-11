#!/bin/bash

engine=innodb
schema=sbtest
mysql_port=3306
mysql_host=127.0.0.1
tables=1
rows=100000
threads=1
tx_rate=0
max_requests=0
max_time=0

while getopts ":e:s:h:p:t:r:c:b:x:a:d" opt; do
  case $opt in
    e)
      echo "Engine: $OPTARG" >&2
      engine=$OPTARG
      ;;
    s)
      echo "Schema: $OPTARG" >&2
      schema=$OPTARG
      ;;
    h)
      echo "MySQL Host: $OPTARG" >&2
      mysql_host=$OPTARG
      ;;
    p)
      echo "MySQL Port: $OPTARG" >&2
      mysql_port=$OPTARG
      ;;
    t)
      echo "Tables: $OPTARG" >&2
      tables=$OPTARG
      ;;
    r)
      echo "Rows: $OPTARG" >&2
      rows=$OPTARG
      ;;
    c)
      echo "Threads: $OPTARG" >&2
      threads=$OPTARG
      ;;
    b)
      echo "TX Rate: $OPTARG" >&2
      tx_rate=$OPTARG
      ;;
    x)
	  echo "Task: $OPTARG" >&2
	  task=$OPTARG
	  ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
	a)
	  echo "Amount of Requests: $OPTARG" >&2
	  max_requests=$OPTARG
	  ;;
  	d)
	  echo "Duration: $OPTARG" >&2
	  max_time=$OPTARG
	  ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done



function prepare {
	
	sysbench \
		--db-driver=mysql \
		--test=/usr/share/doc/sysbench/tests/db/oltp.lua  \
		--mysql-table-engine=$engine \
		--mysql-user=test \
		--mysql-password=test \
		--mysql-db=$schema \
		--mysql-host=$mysql_host \
		--mysql-port=$mysql_port \
		--oltp-tables-count=$tables \
		cleanup

	sysbench \
		--test=/usr/share/doc/sysbench/tests/db/parallel_prepare.lua \
		--db-driver=mysql \
		--mysql-user=test \
		--mysql-password=test \
		--mysql-db=$schema  \
		--mysql-host=$mysql_host \
		--mysql-port=$mysql_port  \
		--oltp-tables-count=$tables \
		--oltp-table-size=$rows \
		--oltp-auto-inc=off \
		--num-threads=$threads \
		run

}



function oltp {

	sysbench \
		--db-driver=mysql \
		--test=/usr/share/doc/sysbench/tests/db/oltp.lua  \
		--mysql-table-engine=$engine \
		--mysql-user=test \
		--mysql-password=test \
		--mysql-db=$schema \
		--mysql-host=$mysql_host \
		--mysql-port=$mysql_port \
		--oltp-tables-count=$tables \
		--report-interval=1 \
		--num-threads=$threads \
		--max-requests=$max_requests \
		--max-time=$max_time \
		--tx-rate=$tx_rate \
		run | grep -v "queue length"
}



case $task in
	prepare)
		prepare
		;;
	oltp)
		oltp
		;;
	*)
		echo "ERROR: no or unknown task (-x) given: $task"
		exit 1
		;;
esac

