#!/bin/sh

bundle install --deployment --without development:test --jobs=4 --path=/tmp
docker build -t nusmodifications/nusmods-cloud .
docker-compose run web rake db:create
docker-compose run web rake db:migrate
docker-compose up -d
