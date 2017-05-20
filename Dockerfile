FROM showtimeanalytics/alpine-java:8u131b11_server-jre

MAINTAINER Alberto Gregoris <alberto@showtimeanalytics.com>

LABEL vendor=Sonatype \
      com.sonatype.license="Apache License, Version 2.0" \
      com.sonatype.name="Nexus Repository Manager base image" \
      com.sonatype.nexus.version="3.3.1" \
      description="Nexus is a repository manager. It allows you to proxy, collect, and manage your dependencies so that you are not constantly juggling a collection of JARs" \
      maintainer="Alberto Gregoris <alberto@showtimeanalytics.com>" \
      com.sonatype.nexus.full.version="3.3.1-01"

ARG NEXUS_VERSION=3.3.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work \
    USER=nexus \
    GROUP=nexus \
    UID=10018 \
    GID=10018

RUN set -ex \
 && apk --update add curl bash tar \
 && mkdir -p ${NEXUS_HOME} \
 && curl -fsSL ${NEXUS_DOWNLOAD_URL} -o /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz \
 && tar --strip-components=1 -xvzf /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz -C ${NEXUS_HOME} \
 && chown -R root:root ${NEXUS_HOME} \
 && sed -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' -i ${NEXUS_HOME}/etc/nexus-default.properties \
 && sed -e '/^-Xms/d' -e '/^-Xmx/d' -i ${NEXUS_HOME}/bin/nexus.vmoptions \
 && addgroup -g ${GID} ${GROUP} \
 && adduser -g "${USER} user" -D -h ${NEXUS_DATA} -G ${GROUP} -s /sbin/nologin -u ${UID} ${USER} \
 && mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} \
 && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 \
 && chown -R nexus:nexus ${NEXUS_DATA} \
 && rm -rf /tmp/* \
           /var/cache/apk/*

VOLUME ${NEXUS_DATA}

EXPOSE 8081

USER ${USER}

WORKDIR ${NEXUS_HOME}

ENV INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m"

CMD ["bin/nexus", "run"]
