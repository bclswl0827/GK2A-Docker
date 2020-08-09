#!/bin/bash

# ENV
DATE=$(date +%Y%m%d)
SRC_DIR=/xrit-rx/src/received/LRIT/COLOURED/${DATE}
DEST_DIR=${SRC_DIR}/Merged

# Compress
mkdir -p /tmp/resize_${DATE}
cd ${SRC_DIR}
for IMG in $(ls *.jpg);
 do
  convert -resize "800x800" -strip -quality 75% ${IMG} /tmp/resize_${DATE}/${IMG};
 done

# Convert
mkdir -p ${DEST_DIR}
convert -delay 24 -loop 0 /tmp/resize_${DATE}/*.jpg ${DEST_DIR}/0000-2400_${DATE}.gif
rm -rf /tmp/resize_${DATE}
