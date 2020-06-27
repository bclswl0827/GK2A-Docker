#!/bin/bash
goesrecv -i 1 -c /etc/goestools/goesrecv.conf &
ls /src/xrit-rx
cd /src/xrit-rx/src
python3 xrit-rx.py
