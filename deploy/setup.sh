#!/bin/sh

docker pull xinan/nusmods-cloud
docker-compose run web rake db:setup
docker-compose up -d
