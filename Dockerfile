ARG DISTRO=alpine:3
FROM $DISTRO

RUN apk add --no-cache openssh shadow bash

COPY root/ /

VOLUME ["/etc/ssh", "/log", "/home"]
EXPOSE 22/tcp

CMD ["/run.sh"]

