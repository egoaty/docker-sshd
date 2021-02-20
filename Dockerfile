ARG DISTRO=alpine:3
FROM $DISTRO

COPY files/ /tmp/files

RUN \
  apk add -U --no-cache tzdata openssh shadow bash iputils && \
  cat /tmp/files/sshd_config_append >> /etc/ssh/sshd_config && \
  cat /tmp/files/ssh_config_append >> /etc/ssh/ssh_config && \
  rm -rf /tmp/files/ && \
  rm -rf /var/cache/apk/*

COPY root/ /

VOLUME ["/local/etc/ssh"]

EXPOSE 22/tcp

CMD ["/run.sh"]

