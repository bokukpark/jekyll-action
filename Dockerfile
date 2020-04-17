FROM ruby:2.7.1-slim

LABEL version="2.0.0"
LABEL repository="https://github.com/helaili/jekyll-action"
LABEL homepage="https://github.com/helaili/jekyll-action"
LABEL maintainer="Alain Hélaïli <helaili@github.com>"

COPY LICENSE README.md /

# ENV BUNDLER_VERSION 1.17.3
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
    && bundle config --global silence_root_warning 1

COPY entrypoint.sh /

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk8u242-b08

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='a2314de7f0120c9bdc69aec2198428a2deeb9ad977fc6801f89d0ec8382d65a5'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_aarch64_linux_hotspot_jdk8u242-b08.tar.gz'; \
         ;; \
       armhf|armv7l) \
         ESUM='ea5f784e70f7c07713dd06214e3c993763857bd31f6de3904971e3032d77388e'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_arm_linux_hotspot_8u242b08.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='72f42c2014cb29a2fcd71b1a678af3ed148358a8f9b7d741a5da88cb178d9c53'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_ppc64le_linux_hotspot_8u242b08.tar.gz'; \
         ;; \
       s390x) \
         ESUM='98f7217dc4acc6bc8b474a2009922b51767d84c045f95a16ee0b9216467ba2de'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_s390x_linux_hotspot_8u242b08.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='f39b523c724d0e0047d238eb2bb17a9565a60574cf651206c867ee5fc000ab43'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u242b08.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

ENTRYPOINT ["/entrypoint.sh"]
