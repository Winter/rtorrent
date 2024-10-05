FROM alpine:3.20 AS build-libtorrent
WORKDIR /tmp/libtorrent

RUN echo "**** install packages ****" && \
    apk add --no-cache \
        autoconf \
        automake \
        build-base \
        git \
        libtool \
        linux-headers \
        openssl-dev \
        pkgconf \
        zlib-dev 

RUN git clone https://github.com/rakshasa/libtorrent.git /tmp/libtorrent

RUN echo "**** build libtorrent ****" && \
    autoreconf -i && \
    ./configure --prefix=/tmp/build && \
    make -j && \
    make install

FROM alpine:3.20 AS build-rtorrent
WORKDIR /tmp/rtorrent

COPY --from=build-libtorrent /tmp/build /usr

RUN echo "**** install packages ****" && \
    apk add --no-cache \
        autoconf \
        autoconf-archive \
        automake \
        build-base \
        curl-dev \
        git \
        libtool \
        libxml2-dev \
        linux-headers \
        ncurses-dev \
        openssl-dev \
        pkgconf \
        xmlrpc-c-dev \
        zlib-dev 

COPY . .

RUN echo "**** converting CRLF to LF ****" && \
    find . -type f -exec sed -i 's/\r$//' {} \; && \
    echo "**** build rtorrent ****" && \
    autoreconf -i && \
    ./configure --prefix=/tmp/build --with-xmlrpc-c && \
    make -j && \
    make install

FROM alpine:3.20

COPY --from=build-libtorrent /tmp/build /usr
COPY --from=build-rtorrent /tmp/build /usr

RUN echo "**** install packages ****" && \
    apk add --no-cache \
        curl \
        libcurl \
        libgcc \
        libstdc++ \
        libxml2 \
        ncurses \
        openssl \
        xmlrpc-c \
        zlib

COPY doc/rtorrent.rc-docker /etc/rtorrent/rtorrent.rc
COPY entrypoint.sh /entrypoint.sh

CMD ["./entrypoint.sh"]