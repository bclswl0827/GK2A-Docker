FROM debian:latest

LABEL maintainer "Yuki Kikuchi <bclswl0827@yahoo.co.jp>"

RUN mkdir /etc/goestools /src \
  && apt-get update \
  && apt-get install -y wget build-essential cmake zlib1g-dev git python3 python3-pip unzip libusb-1.0-0-dev pkg-config libairspy-dev rtl-sdr librtlsdr-dev libopencv-dev

RUN git clone https://github.com/airspy/airspyone_host /src/airspyone_host \
  && cd /src/airspyone_host \
  && mkdir /src/airspyone_host/build \
  && cd /src/airspyone_host/build \
  && cmake .. -DINSTALL_UDEV_RULES=ON \
  && make -j4 \
  && make install \
  && ldconfig

RUN git clone https://github.com/osmocom/rtl-sdr.git /src/rtl-sdr \
  && cd /src/rtl-sdr \
  && mkdir /src/rtl-sdr/build \
  && cd /src/rtl-sdr/build \
  && cmake .. -DINSTALL_UDEV_RULES=ON \
  && make -j4 \
  && make install \
  && ldconfig

RUN git clone --recursive https://github.com/sam210723/goestools /src/goestools \
  && cd /src/goestools \
  && mkdir /src/goestools/build \
  && cd /src/goestools/build \
  && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
  && make -j4 \
  && make install \
  && cp /src/goestools/etc /etc/goestools

RUN rm -rf /src \
  && git clone https://github.com/sam210723/xrit-rx /xrit-rx \
  && pip3 install -r /xrit-rx/requirements.txt \
  && wget -P /xrit-rx/src/EncryptionKeyMessage_001F2904C905.bin --no-check-certificate https://cdn-static.ibcl.us/GK2A-Decode_20190811/EncryptionKeyMessage_001F2904C905.bin \
  && python3 /xrit-rx/src/tools/keymsg-decrypt.py /xrit-rx/src/EncryptionKeyMessage_001F2904C905.bin 001F2904C905
  && chmod +x /xrit-rx/src/xrit-rx.py

RUN apt-get remove --purge wget build-essential cmake git unzip \
  && apt-get autoremove \
  && apt-get clean

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
