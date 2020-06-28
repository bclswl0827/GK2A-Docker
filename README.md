# GK2A-Docker
Docker for GK2A decoding

```
docker volume create xrit-rx
docker run -d -i -t \
	--restart always \
	--name=GK2A \
	--device /dev/bus/usb \
	-p 0.0.0.0:5001:5001 \
	-p 0.0.0.0:5002:5002 \
	-p 0.0.0.0:5004:5004 \
	-p 0.0.0.0:6001:6001 \
	-p 0.0.0.0:6002:6002 \
	-v xrit-rx:/xrit-rx \
	gk2a:latest
```
