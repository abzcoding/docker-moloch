FROM alpine:latest
RUN apk add --update wget curl openjdk8 python git && \
    rm -rf /var/cache/apk/*
