FROM ubuntu:16.10
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    APTLIST="ca-certificates openssl sudo wget" \
    REFRESHED_AT='2017-01-03'

ADD ./files/plexupdate.sh /root/plexupdate.sh

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy $APTLIST && \

    # Install Plex
    bash /root/plexupdate.sh -p -a -d && \

    # Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

VOLUME [ "/config" , "/media" ]

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod u+x  /entrypoint.sh

ENV RUN_AS_ROOT="false" \
    CHANGE_DIR_RIGHTS="false" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config"

EXPOSE 32400

ENTRYPOINT ["/entrypoint.sh"]