# GK2A-Docker
Docker for GK2A decoding

```
docker volume create xrit-rx
docker run -d -i -t \
	--name=GK2A \
  --device /dev/bus/usb \
  -p 0.0.0.0:5004:5004 \
  -v xrit-rx:/xrit-rx \
  gk2a:latest
```
