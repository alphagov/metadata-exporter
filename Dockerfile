ARG base_image=ruby:2.5.3
FROM ${base_image}

EXPOSE 9199

RUN gem install --no-document bundler
RUN mkdir /app
WORKDIR   /app

COPY $PWD/metadata-checker.gemspec        /app/metadata-checker.gemspec
COPY $PWD/lib/metadata/checker/version.rb /app/lib/metadata/checker/version.rb
COPY $PWD/Gemfile                         /app/Gemfile
COPY $PWD/Gemfile.lock                    /app/Gemfile.lock

RUN bundle install

COPY $PWD/ /app/

ENTRYPOINT ["bundle", "exec", "bin/prometheus-metadata-exporter"]
