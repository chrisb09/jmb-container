FROM alpine:3

LABEL maintainer="chrisb09 <mail@christian-f-brinkmann.de>"

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="chrisb09/jmusicbot"
LABEL org.label-schema.description="Java based Discord music bot"
LABEL org.label-schema.url="https://github.com/chrisb09/MusicBot"
LABEL org.label-schema.vcs-url="https://github.com/chrisb09/jmb-container"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.docker.cmd="docker run -v ./config:/jmb/config -d chrisb09/jmusicbot"

# Install necessary packages including Maven and JDK
RUN apk add --update --no-cache \
    openjdk11-jre-headless \
    openjdk11 \
    maven \
    su-exec \
    git \
    tini && \
    mkdir -p /jmb/config

# Clone the repository and build the project
RUN git clone https://github.com/chrisb09/MusicBot.git /jmb/MusicBot && \
    cd /jmb/MusicBot && \
    mvn clean package && cp target/JMusicBot-Snapshot-All.jar /jmb/JMusicBot.jar

RUN chmod -R 755 /jmb/config && chown -R 10000:10001 /jmb/config

RUN mkdir /jmb/reference

RUN cp /jmb/MusicBot/src/main/resources/reference.conf /jmb/reference/config.txt

RUN chmod -R 755 /jmb/reference && chown -R 10000:10001 /jmb/reference

RUN cd / && rm -rf /jmb/MusicBot  # Cleanup after building

COPY --chmod=755 ./docker-entrypoint.sh /jmb

VOLUME /jmb/config

RUN addgroup -S appgroup -g 10001 && \
    adduser -S appuser -G appgroup -u 10000

# Required to ensure the entry point script has the necessary permissions
USER 0

WORKDIR /jmb/config

ENTRYPOINT ["/sbin/tini", "--", "/jmb/docker-entrypoint.sh"]
