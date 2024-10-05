#!/bin/sh
export CONFIG_DIR="/config/"
export DOWNLOAD_DIR="/downloads/"
export SESSION_DIR="/config/.session/"
export WATCH_DIR="/watch/"
export LOG_DIR="/config/logs/"

mkdir -p /config
cp -n /etc/rtorrent/rtorrent.rc /config/rtorrent.rc

exec /usr/bin/rtorrent -n -o import=/config/rtorrent.rc 