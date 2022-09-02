# debmirror-docker

## Overview

This docker container is a host for the debmirror script and accompanying software. It is designed to be left running as it serves the repository with Nginx.

All configuration is handled through environment variables, here is a list with description and default:

For detailed information on what debmirror supports, check out it's man page.

To see more information about available debian mirrors, see: https://www.debian.org/mirror/list-full - Note: This script will also work perfectly fine for mirroring Ubuntu.

## Configuration

* DEBMIRROR_ARCH=amd64
  * Debmirror arch string. May contain multiple deliminated by commas.
* DEBMIRROR_RELEASE=buster,buster-updates,buster-backports
  * Releases to mirror
* DEBMIRROR_SECTION=main,contrib,non-free,main/debian-installer
  * Sections to mirror
* DEBMIRROR_SERVER=debian.gtisc.gatech.edu
  * Server to mirror from
* DEBMIRROR_PROTO=rsync
  * Mirror protocol (I recommend rsync, but the mirror must support the protocol)
* DEBMIRROR_PATH=debian/
  * The path on the mirror, depends on the mirror itself
* DEBMIRROR_DIR=debian
  * Path to place the mirror in container's /srv/apt - this is useful as it will be what your mirror's base path is. Nginx serves /srv/apt - so debian would mean the files are placed in /srv/apt/debian
* DEBMIRROR_SOURCE=N
  * Mirror source files as well (needed if you use deb-src) - takes up a bit more space but it's up to you.
* CRON_FREQ="0 0 * * 5"
  * When the mirror script will run.
* TIMEZONE="America/Los_Angeles"
  * Your timezone so that the mirror script runs when you expect it to :)

## How to use

### Docker
    docker run -p 80:80 \
        -v /path/to/disk:/srv/apt \
        -e TIMEZONE=America/New_York \
        -e CRON_REQ='0 0 * * 1' \
        -e DEBMIRROR_SOURCE=Y \
        debmirror

### Docker-compose
    version: "3"

    services:
      debmirror:
        image: debmirror-docker:latest
        restart: unless-stopped
        ports:
          - 80:80
        volumes:
          - /path/to/disk:/srv/apt
        environment:
          TIMEZONE: "America/New_York"
          CRON_REQ: "0 0 * * 1"
          DEBMIRROR_SOURCE: "Y"

### How to manually trigger mirror update

Something like... curl http://debmirror/run-mirror
