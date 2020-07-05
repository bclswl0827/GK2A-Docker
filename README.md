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
[tony@localhost]$ sudo chmod -R 777 /var/lib/docker/volumes/xrit-rx
[tony@localhost]$ docker run -d -i -t \
	--restart always \
	--name=GK2A \
	--device /dev/bus/usb \
	-e DEVICE=airspy \
	-e GAIN=50 \
	-p 0.0.0.0:5001:5001 \
	-p 0.0.0.0:5002:5002 \
	-p 0.0.0.0:5004:5004 \
	-p 0.0.0.0:6001:6001 \
	-p 0.0.0.0:6002:6002 \
	-v xrit-rx:/xrit-rx \
	bclswl0827/gk2a-docker:latest
```

**Replace the string `airspy` with `rtlsdr` in case of using RTL-SDR dongle instead of Airspy when deploying docker.**

## Get Pictures

```
[tony@localhost]$ cd /var/lib/docker/volumes/xrit-rx/_data/src/received
```
