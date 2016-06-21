FROM alpine

ADD ./src /www

WORKDIR /www
ENTRYPOINT ["/www/startup.sh"]