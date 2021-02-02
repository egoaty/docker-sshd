ARG DISTRO=alpine:3
FROM $DISTRO

RUN apk add --no-cache openssh shadow bash

COPY root/ /

EXPOSE 22/tcp

CMD ["/run.sh"]

