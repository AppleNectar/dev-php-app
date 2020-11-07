#!/bin/sh

: "MariaDB container entrypoint" && set -eu && {
    if [ ! -d "${MYSQL_DATA_PATH}/mysql" ]; then
        # Initialize
        mysql_install_db --user=mysql --datadir=${MYSQL_DATA_PATH}
        # Start mariadb
        rc-service mariadb start
        # Generate and execute SQL to change root password and create users, delete default user and test database
        TEMP_SQL=/tmp/maria_init.sql
        mysqladmin -u root password "${MYSQL_ROOT_PASSWORD}"
        echo "CREATE DATABASE IF NOT EXISTS ${MYSQL_DEFAULT_DB} DEFAULT CHARACTER SET utf8mb4;"  >> ${TEMP_SQL}
        echo "GRANT ALL PRIVILEGES ON ${MYSQL_DEFAULT_DB}.* TO ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;" >> ${TEMP_SQL}
        echo "DELETE FROM mysql.user WHERE User='';" >> ${TEMP_SQL}
        echo "DROP DATABASE test;" >> ${TEMP_SQL}
        echo "FLUSH PRIVILEGES;" >> ${TEMP_SQL}
        cat ${TEMP_SQL} | mysql -u root --password="${MYSQL_ROOT_PASSWORD}"
        rm ${TEMP_SQL}
        unset TEMP_SQL
        rc-service mariadb stop
    else
        # If don't start it with service once, it won't create a socket file, so start and stop it (you can create it manually, but...)
        rc-service mariadb start
        rc-service mariadb stop
    fi

    mysqld --user=mysql --datadir=${MYSQL_DATA_PATH}
}