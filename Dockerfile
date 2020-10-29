FROM ruby:2.5

ENV RAILS_ENV=production \
    HELPY_HOME=/helpy \
    HELPY_USER=helpyuser \
    HELPY_SLACK_INTEGRATION_ENABLED=true \
    BUNDLE_PATH=/opt/helpy-bundle \
    POSTGRES_HOST=helpy-demo.cxjhnbkiyvpw.eu-west-1.rds.amazonaws.com \
    POSTGRES_DB=helpy_production \
    POSTGRES_USER=helpy \
    POSTGRES_PASSWORD=password \
    SECRET_KEY_BASE=some_secret_key_base_change_in_production

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y nodejs postgresql-client imagemagick --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN useradd --no-create-home $HELPY_USER \
  && mkdir -p $HELPY_HOME $BUNDLE_PATH \
  && chown -R $HELPY_USER:$HELPY_USER $HELPY_HOME $BUNDLE_PATH

WORKDIR $HELPY_HOME

COPY Gemfile Gemfile.lock $HELPY_HOME/
COPY vendor $HELPY_HOME/vendor
RUN chown -R $HELPY_USER $HELPY_HOME

USER $HELPY_USER

RUN bundle install --without test development

# manually create the /helpy/public/assets and uploads folders and give the helpy user rights to them
# this ensures that helpy can write precompiled assets to it, and save uploaded files
RUN mkdir -p $HELPY_HOME/public/assets $HELPY_HOME/public/uploads \
    && chown $HELPY_USER $HELPY_HOME/public/assets $HELPY_HOME/public/uploads

VOLUME $HELPY_HOME/public

USER root
COPY . $HELPY_HOME/
RUN chown -R $HELPY_USER $HELPY_HOME
USER $HELPY_USER

COPY docker/database.yml $HELPY_HOME/config/database.yml

EXPOSE 8080
CMD ["/bin/bash", "/helpy/docker/run.sh"]
