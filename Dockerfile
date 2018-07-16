FROM fluent/fluentd:v1.1.3-debian
ARG RUBY_URL
COPY Gemfile /Gemfile
RUN set -ex ; echo 'gem: --no-document' >> /etc/gemrc && \
    [ -z "$http_proxy" ] || gem_args=" $gem_args -r -p $http_proxy " ; \
    [ -z "$RUBY_URL" ] || gem source -r https://rubygems.org/ ; \
    [ -z "$RUBY_URL" ] || gem source -a $RUBY_URL ; \
    [ -z "$RUBY_URL" ] || gem source -c ; \
    gem sources ; \
    gem install -V --file /Gemfile --no-rdoc --no-ri $gem_args
