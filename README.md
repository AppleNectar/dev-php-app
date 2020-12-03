# Web service development docker stack

Docker container stack for a web service development using PHP.  
The stack consists of Nginx / php-fpm / MariaDB / Redis, each container is based on Alpine Linux.

## Usage

1. Clone this repository.
2. Rename `.env.example` to `.env` and refer to the comment to set the value.
3. Create the `app` directory at the same level as the build directory.(`app` is mounted as `/home/<WEB_USER_NAME>/public_html`)  
  You will often want to change the DOCUMENT_ROOT. In that case, copy `/etc/nginx/conf.d/default.conf` from  
  your container to the host, modify the `root` directive and mount it on a container's original path.
4. Execute the `docker-compose up -d` command.

## Containers

### Nginx

- Use the official image of nginx
- The execution user has the same username and user id as PHP.
- SSL with self-certificate for localhost is valid (Automatic generation of certificate files by `mkcert`)
- Cooperation with php-fpm container is valid (Communicate with php-fpm on TCP port 9000)
- If you want to change nginx settings, mount any `default.conf` to `/etc/nginx/conf.d/default.conf`, `nginx.conf` to `/etc/nginx/nginx.conf`

### PHP

- Use the official image of php (Default version 8.0.0)
- The execution user has the same username and user id as Nginx.
- Listen on port 9000 of TCP
- Xdebug extension is valid (Listen on port 9003 / Default ide key `IDEKEY`)
- PHP's extension that Laravel depends on is installed
- Composer is installed system-wide
- php-cs-fixer is installed system wide
- Node.js is installed system-wide(Only when `PHP_NODE_ENABLE` is true in `.env` / Install to `/usr/loca/nodejs`)
- If you want to change php settings, mount any `php.ini` to `/usr/local/etc/php/php.ini`
- If you want to change php-fpm settings, mount any `zzz-www.conf` to `/usr/local/etc/php-fpm.d/zzz-www.conf`

### MariaDB

- Use the official image of alpine
- The root password, initial database name, default username, and user password are passed to the container as environment variables (The actual values are defined in the .env file)
- The data is persisted by the volume "mysql-data" by the local driver  
   (If you don't like it, specify the host directory as the volume to mount `/var/lib/mysql`)
- If you want to change mariadb settings, mount any `mariadb-server.cnf` to `/etc/my.cnf.d/mariadb-server.cnf`
- The time zone follows the time zone setting of the container (i.e. the environment variable "TZ").

### Redis

- Use the official image of redis
- This container does not persist data

## License

MIT
