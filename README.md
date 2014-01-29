# Application deployment process
## Requirements
  - You need a build box which I will describe later
  - The following steps are done on this build box

## Getting a postgresql database running
    docker pull zumbrunnen/postgresql
    docker run -d -name dde-db-server-1 zumbrunnen/postgresql
    # Test with:
    CONTAINER_IP=$(docker inspect dde-db-server-1 | grep IPAddress | awk '{ print $2 }' | tr -d ',"')
    psql -h $CONTAINER_IP -p 5432 -d docker -U docker -W
    # Password is docker

## Building the nginx and passenger image
    cd /source_code/docker-deployment-example
    docker build -t 'dde-app-server:latest' .
    #docker run -d -name dde-app-server-1 -link dde-db-server-1:db dde-app-server:latest
    docker run -d -name dde-app-server-1 -link dde-db-server-1:db dde-app-server:latest sh /opt/start_passenger
    # Test with
    APP_SERVER_IP=$(docker inspect dde-app-server-1 | grep IPAddress | awk '{ print $2 }' | tr -d ',"')
    curl $APP_SERVER_ID/home/index.json
