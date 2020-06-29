# GK2A-Docker
Docker for GK2A decoding, using xrit-rx.

# Quick Start

Install docker-ce, example given on Fedora Linux.

```
[tony@localhost ~]$ dnf install curl
[tony@localhost ~]$ curl -fsSL get.docker.com -o get-docker.sh
[tony@localhost ~]$ sudo sh get-docker.sh --mirror Aliyun
[tony@localhost ~]$ sudo groupadd docker
[tony@localhost ~]$ sudo usermod -aG docker $USER
[tony@localhost ~]$ systemctl enable docker && systemctl start docker
```



```
[tony@localhost]$ docker volume create xrit-rx
[tony@localhost]$ sudo chmod -R 777 var/lib/docker/volumes/xrit-rx
[tony@localhost]$ docker run -d -i -t \
	--restart always \
	--name=GK2A \
	--device /dev/bus/usb \
	-p 0.0.0.0:5001:5001 \
	-p 0.0.0.0:5002:5002 \
	-p 0.0.0.0:5004:5004 \
	-p 0.0.0.0:6001:6001 \
	-p 0.0.0.0:6002:6002 \
	-v xrit-rx:/xrit-rx \
	bclswl0827/gk2a-docker:latest
```
