FROM debian:buster

LABEL maintainer "Yuki Kikuchi <bclswl0827@yahoo.co.jp>"

RUN mkdir -p /etc/goestools /etc/caddy \
  && sed -i "s/deb.debian.org/mirrors.bfsu.edu.cn/g" /etc/apt/sources.list \
  && sed -i "s/security.debian.org/mirrors.bfsu.edu.cn/g" /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y wget build-essential cmake zlib1g-dev libopencv-dev git python3 python3-pip libairspy-dev librtlsdr-dev gpg \
  && wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
  && echo "deb [arch=$(dpkg --print-architecture)] http://packages.microsoft.com/repos/microsoft-debian-buster-prod/ buster main" > /etc/apt/sources.list.d/dotnetdev.list

RUN git clone --recursive https://github.com/sam210723/goestools /goestools \
  && cd /goestools \
  && mkdir /goestools/build \
  && cd /goestools/build \
  && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
  && make -j4 \
  && make install

RUN rm -rf /goestools \
  && git clone https://github.com.cnpmjs.org/sam210723/xrit-rx /xrit-rx \
  && pip3 install --no-cache-dir -r  /xrit-rx/requirements.txt \
  && wget -P /xrit-rx/src --no-check-certificate https://cdn-static.ibcl.us/GK2A-Decode_20190811/EncryptionKeyMessage_001F2904C905.bin \
  && python3 /xrit-rx/src/tools/keymsg-decrypt.py /xrit-rx/src/EncryptionKeyMessage_001F2904C905.bin 001F2904C905 \
  && chmod +x /xrit-rx/src/xrit-rx.py

RUN if [ "$(dpkg --print-architecture)" = "i386" ]; then ARCH="386"; elif [ "$(dpkg --print-architecture)" = "armhf" ]; then ARCH="arm7"; else ARCH=$(dpkg --print-architecture); fi \
  && mkdir /tmp/caddy \
  && wget -O /tmp/caddy/caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_${ARCH}.tar.gz \
  && tar -xvf /tmp/caddy/caddy.tar.gz -C /tmp/caddy \
  && mv /tmp/caddy/caddy /usr/local/bin/caddy

RUN apt-get update \
  && apt-get install -y dotnet-sdk-3.1 \
  && git clone https://github.com.cnpmjs.org/nullpainter/sanchez /sanchez \
  && cd /sanchez/Sanchez \
  && dotnet restore \
  && dotnet build --configuration Release --no-restore \
  && dotnet test --no-restore --verbosity normal \
  && mv /sanchez/Sanchez/bin/Release/netcoreapp3.1 /usr/local/bin/sanchez

RUN rm -rf /tmp/caddy /sanchez \
  && apt-get remove --purge wget build-essential cmake gpg git dotnet-sdk-3.1 -y \
  && apt-get install -y dotnet-runtime-3.1 cron \
  && apt-get autoremove -y \
  && apt-get clean \
  && echo '0 * * * * /usr/local/bin/sanchez/Sanchez -s "/xrit-rx/src/received/LRIT/**/FD/*.jpg" -m /usr/local/bin/sanchez/Resources/Mask.jpg -u /usr/local/bin/sanchez/Resources/GK-2A/Underlay.jpg -o /xrit-rx/src/received/LRIT/COLOURED -t "#0070ba"' | crontab -

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
