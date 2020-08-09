#!/bin/bash

# ENV
DATE=$(date +%Y%m%d)
SRC_DIR=/xrit-rx/src/received/LRIT/COLOURED/${DATE}
DEST_DIR=${SRC_DIR}/Merged

# Convert
mkdir -p ${DEST_DIR}
convert -delay 25 -loop 0 ${SRC_DIR}/*.jpg ${DEST_DIR}/0000-2400_${DATE}.gif
