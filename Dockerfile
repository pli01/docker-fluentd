FROM fluent/fluentd:v1.1.3-debian
ARG RUBY_URL
ARG MIRROR_DEBIAN
COPY Gemfile /Gemfile
RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" && \
    echo "$http_proxy $no_proxy" && set -x && [ -z "$MIRROR_DEBIAN" ] || \
     sed -i.orig -e "s|http://deb.debian.org/debian|$MIRROR_DEBIAN/debian9|g ; s|http://security.debian.org/debian-security|$MIRROR_DEBIAN/debian9-security|g" /etc/apt/sources.list ; cat /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && ( set -ex ; echo 'gem: --no-document' >> /etc/gemrc && \
    [ -z "$http_proxy" ] || gem_args=" $gem_args -r -p $http_proxy " ; \
    [ -z "$RUBY_URL" ] || sudo -E gem source -r https://rubygems.org/ ; \
    [ -z "$RUBY_URL" ] || sudo -E gem source -a $RUBY_URL ; \
    [ -z "$RUBY_URL" ] || sudo -E gem source -c ; \
    sudo -E gem sources ; \
    sudo -E gem install -V --file /Gemfile --no-rdoc --no-ri $gem_args ) \
 && sudo -E gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem
