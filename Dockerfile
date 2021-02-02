ARG DISTRO=alpine:3
FROM $DISTRO

COPY files/ /tmp/files

RUN \
  apk add --no-cache openssh shadow bash && \
  cat /tmp/files/sshd_config_append >> /etc/ssh/sshd_config && \
  cat /tmp/files/ssh_config_append >> /etc/ssh/ssh_config && \
  rm -rf /tmp/files/

COPY root/ /

VOLUME ["/local/etc/ssh"]

EXPOSE 22/tcp

CMD ["/run.sh"]

