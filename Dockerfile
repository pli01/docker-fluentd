FROM fluent/fluentd:v1.1.3-debian
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-rdoc", "--no-ri", "--version", "2.8.5"]
