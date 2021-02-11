FROM debian:buster-slim

LABEL maintainer "Yuki Kikuchi <bclswl0827@yahoo.co.jp>"

ENV DOTNET_ROOT=/usr/local/bin/dotnet \
    PATH=$PATH:/usr/local/bin/dotnet

ADD colour.sh /opt/colour.sh
ADD convert.sh /opt/convert.sh
ADD entrypoint.sh /opt/entrypoint.sh

RUN export DIR_TMP="$(mktemp -d)" \
  && sed -i "s/deb.debian.org/mirrors.bfsu.edu.cn/g" /etc/apt/sources.list \
  && sed -i "s/security.debian.org/mirrors.bfsu.edu.cn/g" /etc/apt/sources.list \
  && apt-get update \
  && apt-get install --no-install-recommends -y cron \
                                                build-essential \
                                                ca-certificates \
                                                curl \
                                                cmake \
                                                zlib1g-dev \
                                                make \
                                                libopencv-dev \
                                                git \
                                                python3 \
                                                python3-pip \
                                                libairspy-dev \
                                                librtlsdr-dev \
                                                graphicsmagick-imagemagick-compat \
  && mkdir -p /etc/goestools /etc/caddy\
  && git clone --recursive https://github.com/sam210723/goestools ${DIR_TMP}/goestools \
  && cd ${DIR_TMP}/goestools \
  && mkdir -p  ${DIR_TMP}/goestools/build \
  && cd ${DIR_TMP}/goestools/build \
  && cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local \
  && make -j${nproc} \
  && make install \
  && git clone https://github.com/sam210723/xrit-rx /usr/local/bin/xrit-rx \
  && mkdir -p /usr/local/bin/xrit-rx/src/received \
  && pip3 install --no-cache-dir -r /usr/local/bin/xrit-rx/requirements.txt \
  && curl -L -o ${DIR_TMP}/EncryptionKeyMessage_001F2904C905.bin https://c.ibcl.us/GK2A-Decode_20190811/EncryptionKeyMessage_001F2904C905.bin \
  && python3 /usr/local/bin/xrit-rx/src/tools/keymsg-decrypt.py ${DIR_TMP}/EncryptionKeyMessage_001F2904C905.bin 001F2904C905 \
  && if [ "$(dpkg --print-architecture)" = "armhf" ]; then \
        ARCH="arm7"; \
     else \
        ARCH=$(dpkg --print-architecture); \
     fi \
  && mkdir -p ${DIR_TMP}/caddy \
  && curl -L -o ${DIR_TMP}/caddy/caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_${ARCH}.tar.gz \
  && tar -zxf ${DIR_TMP}/caddy/caddy.tar.gz -C ${DIR_TMP}/caddy \
  && mv ${DIR_TMP}/caddy/caddy /usr/local/bin/caddy \
  && curl -fsSL https://filebrowser.org/get.sh | bash \
  && if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        ARCH="x64"; \
     elif [ "$(dpkg --print-architecture)" = "armhf" ]; then \
        ARCH="arm"; \
     else \
        ARCH=$(dpkg --print-architecture); \
     fi \
  && mkdir -p ${DIR_TMP}/dotnet-sdk \
  && curl -L -o ${DIR_TMP}/dotnet-sdk.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/3.1.302/dotnet-sdk-3.1.302-linux-${ARCH}.tar.gz \
  && tar -zxf ${DIR_TMP}/dotnet-sdk.tar.gz -C ${DIR_TMP}/dotnet-sdk \
  && rm -rf ${DIR_TMP}/dotnet-sdk.tar.gz \
  && git clone https://github.com/nullpainter/sanchez ${DIR_TMP}/sanchez \
  && cd ${DIR_TMP}/sanchez \
  && git checkout 852f124ae703961d932acd48bebe3036448ce76a \
  && cd ${DIR_TMP}/sanchez/Sanchez \  
  && export DOTNET_ROOT=${DIR_TMP}/dotnet-sdk \
            PATH=$PATH:${DIR_TMP}/dotnet-sdk \
  && dotnet restore --disable-parallel \
  && dotnet build --configuration Release --no-restore \
  && dotnet test --no-restore --verbosity normal \
  && mv ${DIR_TMP}/sanchez/Sanchez/bin/Release/netcoreapp3.1 /usr/local/bin/sanchez \
  && if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        ARCH="x64"; \
     elif [ "$(dpkg --print-architecture)" = "armhf" ]; then \
        ARCH="arm"; \
     else \
        ARCH=$(dpkg --print-architecture); \
     fi \
  && mkdir /usr/local/bin/dotnet \
  && curl -o ${DIR_TMP}/dotnet-runtime.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/3.1.6/dotnet-runtime-3.1.6-linux-${ARCH}.tar.gz \
  && tar -zxf ${DIR_TMP}/dotnet-runtime.tar.gz -C /usr/local/bin/dotnet \
  && chmod +x /opt/* /usr/local/bin/xrit-rx/src/xrit-rx.py \
  && echo "*/10 * * * * /colour.sh" > ${DIR_TMP}/crontab \
  && echo "55 23 * * * /convert.sh" >> ${DIR_TMP}/crontab \
  && crontab ${DIR_TMP}/crontab \
  && rm -f ${DIR_TMP} \
  && apt-get autoremove --purge curl ca-certificates make build-essential cmake git -y

ENTRYPOINT ["sh", "-c", "/opt/entrypoint.sh"]
