FROM rails:4.2.3

RUN mkdir -p /var/www/nusmods-cloud
ADD . /var/www/nusmods-cloud

RUN mkdir -p /shared/gems && \
      cd /var/www/nusmods-cloud &&\
      bundle install --deployment --without test:development --path=/shared/gems

WORKDIR /var/www/nusmods-cloud
