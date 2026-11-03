# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java (Zulu OpenJDK 25)
# ----------------------------------

FROM        azul/zulu-openjdk-alpine:25-latest

LABEL       author="krcnpeter" maintainer="mail@krcnpeter.org"
LABEL       org.opencontainers.image.source="https://github.com/AXZNS-Network/pierdoldactyl-images"
LABEL       org.opencontainers.image.licenses="MIT"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apk update \
            && apk upgrade --no-cache \
            && apk add --no-cache \
               wget \
               curl \
               ffmpeg \
               iproute2 \
               git \
               sqlite \
               python3 \
               tzdata \
               ca-certificates \
               bind-tools \
               fontconfig \
               freetype \
               libstdc++ \
               lsof \
               build-base \
               musl-locales \
               musl-locales-lang \
               openssl \
               bash \
            \
            && wget -O /usr/local/share/ca-certificates/KRCN.NETWORK_CA.crt http://10.0.200.2:8042/KRCN.NETWORK_CA.crt \
            && update-ca-certificates \
            \
            && keytool -importcert \
               -trustcacerts \
               -cacerts \
               -storepass changeit \
               -alias krcn-vpn \
               -file /usr/local/share/ca-certificates/KRCN.NETWORK_CA.crt \
               -noprompt \
            \
            && adduser -D -h /home/container container

ENV         LC_ALL=en_US.UTF-8
ENV         LANG=en_US.UTF-8
ENV         LANGUAGE=en_US.UTF-8

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
