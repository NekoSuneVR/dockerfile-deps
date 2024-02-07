FROM debian:stretch-slim

RUN groupadd -r zenzo && useradd -r -m -g zenzo zenzo

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV ZENZO_VERSION 2.1.0
ENV ZENZO_URL https://github.com/ZENZO-Ecosystem/ZENZO-Core/releases/download/v2.1.0/zenzo-2.1.0-x86_64-linux-gnu.tar.gz
ENV ZENZO_SHA256 1f3a85d2344bd92255b438a15ed4fd04398b5a78e0ee42133798ff49a554e72d 

# install Zenzo binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO zenzo.tar.gz "$ZENZO_URL" \
	&& echo "$ZENZO_SHA256 zenzo.tar.gz" | sha256sum -c - \
	&& tar -xzvf zenzo.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV ZENZO_DATA /data
RUN mkdir "$ZENZO_DATA" \
	&& chown -R zenzo:zenzo "$ZENZO_DATA" \
	&& ln -sfn "$ZENZO_DATA" /home/zenzo/.zenzo \
	&& chown -h zenzo:zenzo /home/zenzo/.zenzo
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 26211 26210
CMD ["zenzod"]
