# GK2A-Docker
Docker for GK2A decoding

```
docker volume create xrit-rx
docker run --device /dev/bus/usb -v xrit-rx:/xrit-rx gk2a:latest
```
