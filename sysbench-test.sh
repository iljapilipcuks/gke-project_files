#!/bin/bash

# Packages installed for testing:
# sudo apt-get update
# sudo apt-get install -y default-mysql-client
# curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
# sudo apt -y install sysbench

# $1-ip address of tested application database
DBADD=$1

sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$DBADD --mysql-port=3306 --mysql-user=root --mysql-password='mysql_password' --mysql-db=mysql --db-driver=mysql --tables=10 --table-size=2500 prepare

sysbench oltp_read_only --tables=10 --table_size=2500 --mysql-host=$DBADD --mysql-port=3306 --mysql-user=root --mysql-password='mysql_password' --mysql-db=mysql --time=300 --threads=4 --report-interval=15 run >> oltp_read_only.txt

sysbench oltp_write_only --tables=10 --table_size=2500 --mysql-host=$DBADD --mysql-port=3306 --mysql-user=root --mysql-password='mysql_password' --mysql-db=mysql --time=300 --threads=4 --report-interval=15 run >> oltp_write_only.txt

sysbench oltp_read_write --tables=10 --table_size=2500 --mysql-host=$DBADD --mysql-port=3306 --mysql-user=root --mysql-password='mysql_password' --mysql-db=mysql --time=300 --threads=4 --report-interval=15 run >> oltp_read_write.txt

sysbench oltp_delete --tables=10 --table_size=2500 --mysql-host=$DBADD --mysql-port=3306 --mysql-user=root --mysql-password='mysql_password' --mysql-db=mysql --time=300 --threads=4 --report-interval=15 run >> oltp_delete.txt

