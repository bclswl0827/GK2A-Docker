FROM debian:buster

LABEL maintainer "Yuki Kikuchi <bclswl0827@yahoo.co.jp>"

ENV DOTNET_ROOT=/usr/local/bin/dotnet \
    PATH=$PATH:/usr/local/bin/dotnet

RUN mkdir -p /etc/goestools /etc/caddy \
  && sed -i "s/deb.debian.org/mirrors.bfsu.edu.cn/g" /etc/apt/sources.list \
  && sed -i "s/security.debian.org/mirrors.bfsu.edu.cn/g" /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y cron wget build-essential cmake zlib1g-dev libopencv-dev git python3 python3-pip libairspy-dev librtlsdr-dev

RUN git clone --recursive https://github.com/sam210723/goestools /goestools \
  && cd /goestools \
  && mkdir /goestools/build \
  && cd /goestools/build \
  && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
  && make -j4 \
  && make install \
  && rm -rf /goestools

RUN git clone https://github.com/sam210723/xrit-rx /xrit-rx \
  && pip3 install --no-cache-dir -r  /xrit-rx/requirements.txt \
  && wget -P /xrit-rx/src --no-check-certificate https://cdn-static.ibcl.us/GK2A-Decode_20190811/EncryptionKeyMessage_001F2904C905.bin \
  && python3 /xrit-rx/src/tools/keymsg-decrypt.py /xrit-rx/src/EncryptionKeyMessage_001F2904C905.bin 001F2904C905 \
  && chmod +x /xrit-rx/src/xrit-rx.py

RUN if [ "$(dpkg --print-architecture)" = "armhf" ]; then ARCH="arm7"; else ARCH=$(dpkg --print-architecture); fi \
  && mkdir /tmp/caddy \
  && wget -O /tmp/caddy/caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_${ARCH}.tar.gz \
  && tar -zxf /tmp/caddy/caddy.tar.gz -C /tmp/caddy \
  && mv /tmp/caddy/caddy /usr/local/bin/caddy \
  && rm -rf /tmp/caddy

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then ARCH="x64"; elif [ "$(dpkg --print-architecture)" = "armhf" ]; then ARCH="arm"; else ARCH=$(dpkg --print-architecture); fi \
  && mkdir /tmp/dotnet-sdk \
  && wget -O /tmp/dotnet-sdk.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/3.1.302/dotnet-sdk-3.1.302-linux-${ARCH}.tar.gz \
  && tar -zxf /tmp/dotnet-sdk.tar.gz -C /tmp/dotnet-sdk \
  && rm -rf /tmp/dotnet-sdk.tar.gz

RUN export DOTNET_ROOT=/tmp/dotnet-sdk \
  && export PATH=$PATH:/tmp/dotnet-sdk \
  && git clone https://github.com/nullpainter/sanchez /sanchez \
  && cd /sanchez/Sanchez \
  && dotnet restore --disable-parallel \
  && dotnet build --configuration Release --no-restore \
  && dotnet test --no-restore --verbosity normal \
  && mv /sanchez/Sanchez/bin/Release/netcoreapp3.1 /usr/local/bin/sanchez \
  && rm -rf /tmp/dotnet-sdk /sanchez

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then ARCH="x64"; elif [ "$(dpkg --print-architecture)" = "armhf" ]; then ARCH="arm"; else ARCH=$(dpkg --print-architecture); fi \
  && mkdir /usr/local/bin/dotnet \
  && wget -O /tmp/dotnet-runtime.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/3.1.6/dotnet-runtime-3.1.6-linux-${ARCH}.tar.gz \
  && tar -zxf /tmp/dotnet-runtime.tar.gz -C /usr/local/bin/dotnet \
  && rm -rf /tmp/dotnet-sdk.tar.gz \
  && echo '0,10,20,30,40,50 * * * * /usr/local/bin/sanchez/Sanchez -s "/xrit-rx/src/received/LRIT/**/FD/*.jpg" -m /usr/local/bin/sanchez/Resources/Mask.jpg -u /usr/local/bin/sanchez/Resources/GK-2A/Underlay.jpg -o /xrit-rx/src/received/LRIT/COLOURED -t "#0070ba"' | crontab -

RUN apt-get remove --purge wget build-essential cmake git -y \
  && apt-get autoremove -y \
  && apt-get clean

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
