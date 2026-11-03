# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java (Zulu OpenJDK 25)
# ----------------------------------

FROM        azul/zulu-openjdk-debian:25-latest

LABEL       author="krcnpeter" maintainer="mail@krcnpeter.org"
LABEL       org.opencontainers.image.source="https://github.com/AXZNS-Network/pierdoldactyl-images"
LABEL       org.opencontainers.image.licenses="MIT"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update \
            && apt-get -y install --no-install-recommends \
               wget \
               curl \
               ffmpeg \
               iproute2 \
               git \
               sqlite3 \
               python3 \
               tzdata \
               ca-certificates \
               dnsutils \
               fontconfig \
               libfreetype6 \
               libstdc++6 \
               lsof \
               build-essential \
               locales \
               openssl \
            && apt-get clean \
            && apt-get update \
            && apt full-upgrade -y \
            && apt autoremove -y \
            \
            && wget http://10.0.200.2:8042/KRCN.NETWORK_CA.crt \
            && mv KRCN.NETWORK_CA.crt /etc/ssl/certs/KRCN.NETWORK_CA.crt \
            && update-ca-certificates \
            \
            && keytool -importcert \
               -trustcacerts \
               -keystore /usr/lib/jvm/zulu25-ca-amd64/lib/security/cacerts \
               -storepass changeit \
               -alias krcn-vpn \
               -file /etc/ssl/certs/KRCN.NETWORK_CA.crt \
               -noprompt \
            \
            && rm -rf /var/lib/apt/lists/* \
            && useradd -m -d /home/container container \
            && locale-gen en_US.UTF-8

ENV         LC_ALL=en_US.UTF-8
ENV         LANG=en_US.UTF-8
ENV         LANGUAGE=en_US.UTF-8

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
