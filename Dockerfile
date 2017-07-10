FROM alpine:3.6
MAINTAINER Matthew Davis <matthew@appsoa.io>

LABEL Name="MySQL Server on Alpine"
LABEL Version="1.0"
LABEL build="Image-Version:- ${IMAGE_VERSION} Image-Build-Date: ${IMAGE_BUILD_DATE}"

ARG IMAGE_BUILD_DATE
ARG IMAGE_VERSION

COPY data /data
WORKDIR /data
VOLUME /data

RUN apk add --update mysql mysql-client && rm -f /var/cache/apk/*
COPY my.cnf /etc/mysql/my.cnf

EXPOSE 3306

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
