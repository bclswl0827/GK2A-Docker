FROM alpine AS builder

ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm32v5/debian:buster-slim

COPY --from=builder qemu-arm-static /usr/bin

LABEL maintainer "Yuki Kikuchi <bclswl0827@yahoo.co.jp>"

RUN mkdir /etc/goestools \
  #&& sed -i "s/deb.debian.org/mirror.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
  #&& sed -i "s/security.debian.org/mirror.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y wget build-essential cmake zlib1g-dev libopencv-dev git python3 python3-pip libairspy-dev librtlsdr-dev

RUN git clone --recursive https://github.com/sam210723/goestools /goestools \
  && cd /goestools \
  && mkdir /goestools/build \
  && cd /goestools/build \
  && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
  && make -j4 \
  && make install

RUN rm -rf /goestools \
  && git clone https://github.com/sam210723/xrit-rx /xrit-rx \
  && pip3 install -r /xrit-rx/requirements.txt \
  && wget -P /xrit-rx/src --no-check-certificate https://cdn-static.ibcl.us/GK2A-Decode_20190811/EncryptionKeyMessage_001F2904C905.bin \
  && python3 /xrit-rx/src/tools/keymsg-decrypt.py /xrit-rx/src/EncryptionKeyMessage_001F2904C905.bin 001F2904C905 \
  && chmod +x /xrit-rx/src/xrit-rx.py

RUN apt-get remove --purge wget build-essential cmake git -y \
  && apt-get autoremove -y \
  && apt-get clean

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
