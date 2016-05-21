FROM alpine:3.3

RUN \
    apk update && \
    apk add -u nginx curl bash && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

ENV CONSUL_TEMPLATE_VERSION 0.14.0
ENV CONSUL_HOST 172.17.0.1

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS /tmp/
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp/
RUN cd /tmp && \ 
    sha256sum -c consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS 2>&1 | grep OK && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \ 
    mv consul-template /bin/consul-template && \
    rm -rf /tmp

ENV ENTRYKIT_VERSION 0.4.0

ADD https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz /tmp/
RUN cd /tmp && \
  tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz && \
  rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz && \
  mv entrykit /bin/entrykit && \
  chmod +x /bin/entrykit && \
  entrykit --symlink

ADD nginx.conf /etc/nginx/nginx.conf
ADD templates /etc/nginx/templates

ADD reloader /usr/sbin/reloader
RUN chmod +x /usr/sbin/reloader

EXPOSE 80

ENTRYPOINT [ \
  "codep", \
    "/usr/sbin/reloader", \
    "/usr/sbin/nginx" \
]
