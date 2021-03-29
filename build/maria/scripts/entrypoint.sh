#!/bin/sh

: "MariaDB container entrypoint" && set -eux && {
    # Create socket dir
    if [ ! -d "/run/mysqld" ]; then
        mkdir /run/mysqld
        chown mysql:mysql /run/mysqld
    else
        chown mysql:mysql /run/mysqld
    fi

    # Create data dir
    if [ ! -d "/var/lib/mysql" ]; then
        mkdir /var/lib/mysql
        chown mysql:mysql /var/lib/mysql
    else
        chown mysql:mysql /var/lib/mysql
    fi

    if [ -z "$(ls /var/lib/mysql)" ]; then
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
        # Generate and execute SQL to change root password and create users, delete default user and test database
        INIT_SQL=/tmp/maria_init.sql
        cat << EOF > ${INIT_SQL}
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'%' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'127.0.0.1' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DEFAULT_DB} DEFAULT CHARACTER SET utf8mb4;
GRANT ALL PRIVILEGES ON ${MYSQL_DEFAULT_DB}.* TO ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
EOF
        /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < ${INIT_SQL}
        rm -f ${INIT_SQL}
    fi

    exec /usr/bin/mysqld --user=mysql --port=3306 --character-set-server=utf8mb4 --skip-name-resolve --skip-bind-address --skip-networking=0 $@
}
