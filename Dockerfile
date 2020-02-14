FROM alpine:3.10.2

RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
RUN apk update && \
    apk add py-pip python-dev libffi-dev openssl-dev gcc libc-dev make

RUN pip install docker-compose

ENTRYPOINT ["docker-compose"]