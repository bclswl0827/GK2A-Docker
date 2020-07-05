#!/bin/bash
sed -i "s/NULL/$DEVICE/g" /etc/goestools/goesrecv.conf
goesrecv -i 1 -c /etc/goestools/goesrecv.conf &
cd /xrit-rx/src
python3 xrit-rx.py
