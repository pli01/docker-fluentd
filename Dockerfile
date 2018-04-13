FROM fluent/fluentd:v1.1.3-debian
COPY Gemfile /Gemfile
RUN echo 'gem: --no-document' >> /etc/gemrc && \
    gem install --file /Gemfile --no-rdoc --no-ri
