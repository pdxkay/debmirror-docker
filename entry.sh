#!/bin/bash

echo "[entry.sh] Let's get this party started.."

echo "[entry.sh] * Setting up configuration and permissions..."
aptdir=/srv/apt
crfile=/etc/cron.d/debmirror-cron
nginxconf=/etc/nginx/nginx.conf
mirrorsh=/app/mirror.sh
mirrorlog=/app/mirror.log
confsh=/app/conf.sh

echo DEBMIRROR_ARCH="$DEBMIRROR_ARCH" > $confsh
echo DEBMIRROR_SECTION="$DEBMIRROR_SECTION" >> $confsh
echo DEBMIRROR_RELEASE="$DEBMIRROR_RELEASE" >> $confsh
echo DEBMIRROR_SERVER="$DEBMIRROR_SERVER" >> $confsh
echo DEBMIRROR_PROTO="$DEBMIRROR_PROTO" >> $confsh
echo DEBMIRROR_PATH="$DEBMIRROR_PATH" >> $confsh
echo DEBMIRROR_SOURCE="$DEBMIRROR_SOURCE" >> $confsh
echo DEBMIRROR_DIR="$DEBMIRROR_DIR" >> $confsh
echo APT_PATH="$aptdir" >> $confsh

mkdir -p $aptdir
chmod 755 $mirrorsh
echo "" > $mirrorlog

echo "[entry.sh] * Setting timezone"
if [[ -e "/usr/share/zoneinfo/$TIMEZONE" ]]; then
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

echo "[entry.sh] * Setting up nginx"
# set nginx conf
rm $nginxconf
ln -sf /app/nginx.conf $nginxconf
mkdir /app/nginx

echo "[entry.sh] * Setting setting up cron"
# set cron job
echo "$CRON_FREQ root $mirrorsh >> $mirrorlog 2>&1" > $crfile
echo "" >> $crfile
chmod 0644 $crfile

echo "[entry.sh] Services"
# start cron & nginx
echo "[entry.sh] * Starting cron"
cron

echo "[entry.sh] * Starting nginx"
nginx

if [[ $(/bin/ls -A $aptdir) == "" ]]; then
    echo "[entry.sh] Seems like we're missing mirror files, so running mirror now"
    $mirrorsh >> $mirrorlog 2>&1 &
fi

echo "[entry.sh] Now we go to sleep"
# now just wait. I could do `cron -n` but eh
trap : TERM INT; tail -f $mirrorlog & wait

echo "[entry.sh] Stopping services"
echo "[entry.sh] * Killing cron"
killall cron 2>/dev/null

echo "[entry.sh] * Killing debmirror (if in-progress)"
killall debmirror 2>/dev/null

echo "[entry.sh] * Killing tail"
killall tail 2>/dev/null

echo "[entry.sh] * Stopping nginx"
nginx -s stop

echo "[entry.sh] All done here, have a nice day :)"
