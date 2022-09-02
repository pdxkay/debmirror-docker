FROM debian:stable

RUN apt-get update
RUN apt-get install -y cron debmirror debian-keyring nginx

ENV DEBMIRROR_ARCH=amd64
ENV DEBMIRROR_SECTION=main,contrib,non-free,main/debian-installer
ENV DEBMIRROR_RELEASE=buster,buster-updates,buster-backports
ENV DEBMIRROR_SERVER=debian.gtisc.gatech.edu
ENV DEBMIRROR_PROTO=rsync
ENV DEBMIRROR_PATH=debian/
ENV DEBMIRROR_DIR=debian
ENV DEBMIRROR_SOURCE=N
ENV CRON_FREQ="0 0 * * 5"
ENV TIMEZONE="America/Los_Angeles"

WORKDIR /app

COPY . /app

CMD ["bash", "/app/entry.sh"]
