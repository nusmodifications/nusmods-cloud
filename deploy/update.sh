#!/bin/sh

docker pull xinan/nusmods-cloud
docker-compose stop web
docker-compose rm -f web
docker-compose run web rake db:migrate
docker-compose up -d --no-recreate
