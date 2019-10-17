#!/bin/bash -x

# the function with the data to the file must be formatted in this way, otherwise it returns an error
create_style_file () {
cat > /home/dexk/letsencrypt/site/style.css << ENDOFFILE
style
ENDOFFILE
}

# the function with the data to the file must be formatted in this way, otherwise it returns an error
create_index_file () {
cat > /home/dexk/letsencrypt/site/index.html << ENDOFFILE
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>
    Document
  </title>
</head>
<body>
  <div>
    <h4>
      let's encrypt ssl certificate
    </h4>
  </div>
</body>
</html>
ENDOFFILE
}

# the function with the data to the file must be formatted in this way, otherwise it returns an error
create_docker_compose_file () {
cat > /home/dexk/letsencrypt/docker-compose.yml << ENDOFFILE
version: '3.1'

services:

  letsencrypt-nginx-container:
    container_name: 'letsencrypt-nginx-container'
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./site:/usr/share/nginx/html
    networks:
      - docker-network

networks:
  docker-network:
    driver: bridge
ENDOFFILE
}

# the function with the data to the file must be formatted in this way, otherwise it returns an error
create_nginx_config_file () {
cat > /home/dexk/letsencrypt/nginx.conf << ENDOFFILE
server {
    listen 80;
    listen [::]:80;
    server_name jakubgania.io www.jakubgania.io;

    location ~ /.well-known/acme-challenge {
        allow all;
        root /usr/share/nginx/html;
    }

    root /usr/share/nginx/html;
    index index.html;
}
ENDOFFILE
}

run_staging_command_for_new_certificate () {
docker run -it --rm \
-v /docker-volumes/etc/letsencrypt:/etc/letsencrypt \
-v /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt \
-v /home/dexk/letsencrypt/site:/data/letsencrypt \
-v "/docker-volumes/var/log/letsencrypt:/var/log/letsencrypt" \
certbot/certbot \
certonly --webroot \
--register-unsafely-without-email --agree-tos \
--webroot-path=/data/letsencrypt \
--staging \
-d jakubgania.io -d www.jakubgania.io
}

get_additional_information_about_certificates () {
sudo docker run --rm -it --name certbot \
-v /docker-volumes/etc/letsencrypt:/etc/letsencrypt \
-v /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt \
-v /home/dexk/letsencrypt/site:/data/letsencrypt \
certbot/certbot \
--staging \
certificates
}

CURRENT_DIRECTORY=$(pwd)
FOLDER_NAME="letsencrypt"
EXMP="${CURRENT_DIRECTORY}/${FOLDER_NAME}"

echo "${EXMP}"

echo 'start script - docker-letsencrypt.sh'

echo 'start command - docker-compose down'
# docker compose down
echo 'end command - dcoker-compose down'

echo 'check directory exists - /docker-volumes'
# rmove docker-volumes

if [ -d "/docker-volumes"  ]; then
    echo "exsits"

    echo 'remove directory - /docker-columes'
    rm -rf /docker-volumes
else
    echo "not exists"
fi

if [ -d "/home/dexk/letsencrypt" ]; then
    echo "directory exists"

    echo 'remove directory - /home/dexk/letsencrypt'
    rm -rf /home/dexk/letsencrypt
else
    echo "directory not exists"

    echo "create directory - /home/dexk/letsencrypt"
    mkdir /home/dexk/letsencrypt

    echo "create directory - /home/dexk/letsencrypt/site"
    mkdir /home/dexk/letsencrypt/site

    #touch /home/dexk/letsencrypt/site

    #cd /home/dexk/letsencrypt/site

    echo 'create file style.css'
    create_style_file

    echo 'create file index.html'
    create_index_file

    echo 'create file docker-compose.yml'
    create_docker_compose_file

    echo 'create file nginx.conf'
    create_nginx_config_file

    echo 'running containers'
    docker ps

    echo 'stop all running containers'
    cd /home/dexk/letsencrypt && docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

    echo 'start nginx container'
    cd /home/dexk/letsencrypt && docker-compose up -d && docker ps

    echo 'run staging command for new certificate'
    run_staging_command_for_new_certificate

    echo 'get some additional information about certificates'
    get_additional_information_about_certificates

    echo 'clean up staging artifacts'
    echo 'request a production certificate'
    echo 'stop all running containers'
    # create function

fi

