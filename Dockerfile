FROM rails:4.2.3

ENV APP_HOME=/var/www/nusmods-cloud/

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME
RUN bundle install --deployment --without development:test --jobs=4 --path=/tmp
