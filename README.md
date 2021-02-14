# GK2A-Docker
Docker for GK2A decoding, using xrit-rx.

# Quick Start

Install docker-ce, example given on Fedora Linux.

```
[tony@localhost ~]$ sudo dnf install curl
[tony@localhost ~]$ curl -fsSL get.docker.com -o get-docker.sh
[tony@localhost ~]$ sudo sh get-docker.sh
[tony@localhost ~]$ sudo groupadd docker
[tony@localhost ~]$ sudo usermod -aG docker $USER
[tony@localhost ~]$ sudo systemctl enable docker && sudo systemctl start docker
```

Run GK2A-Docker.

```
[tony@localhost]$ docker volume create xrit-rx
[tony@localhost]$ docker run -d -i -t \
 --restart always \
 --name=goesrecv \
 --device /dev/bus/usb \
 -e DEVICE=airspy \
 -e GAIN=50 \
 -p 1692:1692 \
 -p 5001:5001 \
 -p 5002:5002 \
 -p 5004:5004 \
 -p 5005:5005 \
 -p 6001:6001 \
 -p 6002:6002 \
 -p 8888:8888 \
 -v xrit-rx:/usr/local/bin/xrit-rx/src/received/LRIT \
 bclswl0827/gk2a-docker:latest
```

**Replace the string `airspy` with `rtlsdr` in case of using RTL-SDR dongle instead of Airspy when deploying docker.**

## Get Pictures

### Local Disk

```
[tony@localhost]$ cd /var/lib/docker/volumes/xrit-rx/_data/src/received
```

### Via HTTP

```
http://[Your IP]:5005
```
