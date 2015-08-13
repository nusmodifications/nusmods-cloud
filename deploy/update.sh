#!/bin/sh

git pull --rebase origin production
docker build -t nusmodifications/nusmods-cloud .
docker-compose stop web
docker-compose rm -f web
docker-compose up -d --no-recreate
