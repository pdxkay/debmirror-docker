#!/bin/bash
lockfile=/tmp/mirror.lock

if [[ -e "$lockfile" ]]; then
    echo "[mirror.sh] Already running! (or something bad happened?)" > /dev/stderr
fi

touch $lockfile

echo "[mirror.sh] Let's do this thing"

echo "[mirror.sh] * Loading configuration"
# created by entry.sh
source /app/conf.sh

truthy="y Y yes YES T t True true TRUE"
nosource="--nosource"

for t in $truthy; do
    if [[ "$DEBMIRROR_SOURCE" == "$t" ]]; then
        nosource="--source"
    fi
done

echo "[mirror.sh] * Configuration:"
echo "[mirror.sh] arch=    $DEBMIRROR_ARCH"
echo "[mirror.sh] section= $DEBMIRROR_SECTION"
echo "[mirror.sh] host=    $DEBMIRROR_SERVER"
echo "[mirror.sh] dist=    $DEBMIRROR_RELEASE"
echo "[mirror.sh] root=    $DEBMIRROR_PATH"
echo "[mirror.sh] method=  $DEBMIRROR_PROTO"
echo "[mirror.sh] source=  $nosource"
echo "[mirror.sh] path=    $APT_PATH/$DEBMIRROR_DIR"

echo "[mirror.sh] * Running debmirror"
# run debmirror
debmirror --arch=$DEBMIRROR_ARCH \
          --section=$DEBMIRROR_SECTION \
          --host=$DEBMIRROR_SERVER \
          --dist=$DEBMIRROR_RELEASE \
          --root=$DEBMIRROR_PATH \
          --method=$DEBMIRROR_PROTO \
          $nosource \
          --progress \
          --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
          $APT_PATH/$DEBMIRROR_DIR

echo "[mirror.sh] * debmirror donezo"

rm $lockfile
