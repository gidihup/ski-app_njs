#!/bin/bash

######This script bootstrap the server OS (Unbuntu 18.04 TLS)
######It installs and starts Docker, build the application into a container and start same

###preparing the docker engine and app folder###

##Update the repository and install Docker community edition and unzip 
sudo apt-get update
#Install packages to allow apt to use a repository over HTTPS:
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
#Adding Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -    

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
#Update the apt package index
sudo apt-get update
#Install docker-ce version 18.06.0
sudo apt-get install -y docker-ce=18.06.0~ce~3-0~ubuntu containerd.io
#Install unzip
sudo apt-get install -y unzip

##download docker compose and set it as executable
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

##Start and enable the Docker engine
sudo systemctl start docker && sudo systemctl enable docker

##create the app folder, copy code to same and unzip
sudo mkdir ./nodejs-app
sudo mv ceros-ski.zip nodejs-app/
cd ./nodejs-app
sudo unzip ceros-ski.zip
sudo chown $USER ceros-ski-master/
cd ceros-ski-master/


###building and installing the containerized nodejs app###

##create the Dockerfile

sudo cat <<EOF >>appfile
FROM node:8-alpine
MAINTAINER app-dev@ceros.com

# Create app directory
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied

COPY package*.json /app/

RUN npm install

# Bundle app source
COPY . /app

# Expose the port the app is listening on
EXPOSE 5000

#Start the app
CMD [ "npm", "start" ]
EOF

##create the nginx load balancer config file
sudo cat <<EOF >>nginx_lb.conf
events {
  worker_connections  1000;  ## Default: 1024
}

http {
    upstream ceros_app {
        server nj-app1:5000;
        server nj-app2:5000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://ceros_app;
        }
    }
}
EOF

##create the dockerignore file
sudo cat <<EOF >>.dockerignore
node_modules
npm-debug.log
nginx_lb.conf
EOF

##build and the app image
sudo docker build -t ceros/nj-app:v1 -f appfile .

##create the docker-compose.yaml file
sudo cat <<EOF >>docker-compose.yaml
version: '3'
services:
  #the nginx container to loadbalance the app
  nginx: 
    image: nginx:1.15-alpine
    volumes:
      - ./nginx_lb.conf:/etc/nginx/nginx.conf  #copy lb config into nginx container
    ports:
      - 80:80
      - 443:443
    networks:
      - ski_app_net
    restart: unless-stopped

# node js app defined to run in multiple containers
  nj-app1:
    image: ceros/nj-app:v1
    container_name: nj-web-app1
    ports:
      - 5151:5000
    networks:
      - ski_app_net
    restart: unless-stopped

  nj-app2:
    image: ceros/nj-app:v1
    container_name: nj-web-app2
    ports:
      - 5252:5000
    networks:
      - ski_app_net
    restart: unless-stopped

# Networks to be created to facilitate communication between containers
networks:
  ski_app_net:
EOF

##start containers 
sudo docker-compose up -d