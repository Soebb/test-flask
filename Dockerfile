FROM    ubuntu:22.04 AS base

## Install libraries by package
ENV     DEBIAN_FRONTEND=noninteractive
RUN     apt-get update && apt-get install -y tzdata sudo curl

FROM    base AS build

WORKDIR /tmp

ARG     OME_VERSION=master
ARG 	STRIP=TRUE

ENV     PREFIX=/opt/ovenmediaengine
ENV     TEMP_DIR=/tmp/ome

## Download OvenMediaEngine
RUN \
        mkdir -p ${TEMP_DIR} && \
        cd ${TEMP_DIR} && \
        curl -sLf https://github.com/AirenSoft/OvenMediaEngine/archive/${OME_VERSION}.tar.gz | tar -xz --strip-components=1

## Install dependencies
RUN \
        ${TEMP_DIR}/misc/prerequisites.sh 

## Build OvenMediaEngine
RUN \
        cd ${TEMP_DIR}/src && \
        make release -j$(nproc)

RUN \
        if [ "$STRIP" = "TRUE" ] ; then strip ${TEMP_DIR}/src/bin/RELEASE/OvenMediaEngine ; fi

## Make running environment
RUN \
        cd ${TEMP_DIR}/src && \
        mkdir -p ${PREFIX}/bin/origin_conf && \
        mkdir -p ${PREFIX}/bin/edge_conf && \
        cp ./bin/RELEASE/OvenMediaEngine ${PREFIX}/bin/ && \
        cp ../misc/conf_examples/Origin.xml ${PREFIX}/bin/origin_conf/Server.xml && \
        cp ../misc/conf_examples/Logger.xml ${PREFIX}/bin/origin_conf/Logger.xml && \
        cp ../misc/conf_examples/Edge.xml ${PREFIX}/bin/edge_conf/Server.xml && \
        cp ../misc/conf_examples/Logger.xml ${PREFIX}/bin/edge_conf/Logger.xml && \
        cp ../misc/install_nvidia_driver.sh ${PREFIX}/bin/install_nvidia_driver.sh && \
        rm -rf ${TEMP_DIR}

FROM	base AS release

WORKDIR         /opt/ovenmediaengine/bin
EXPOSE          80/tcp 8080/tcp 8090/tcp 1935/tcp 3333/tcp 3334/tcp 4000-4005/udp 10000-10010/udp 9000/tcp
COPY            --from=build /opt/ovenmediaengine /opt/ovenmediaengine

# Send SIGKILL to OvenMediaEngine instead of SIGTERM
STOPSIGNAL      SIGKILL

ENV OME_ORIGIN_PORT 9000
ENV OME_RTMP_PROV_PORT 1935
ENV OME_SRT_PROV_PORT 9999
ENV OME_MPEGTS_PROV_PORT 4000-4005/udp
ENV OME_HLS_STREAM_PORT 8080
ENV OME_DASH_STREAM_PORT 8080
ENV OME_SIGNALLING_PORT 3333
ENV OME_TCP_RELAY_ADDRESS *:3478
ENV OME_ICE_CANDIDATES *:10006-10010/udp

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y ffmpeg python3 python3-pip wget
RUN wget -c https://github.com/nicolas-van/multirun/releases/download/1.1.3/multirun-x86_64-linux-gnu-1.1.3.tar.gz -O - | tar -xz && mv multirun /bin

WORKDIR /app

COPY . ./

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

CMD multirun "/opt/ovenmediaengine/bin/OvenMediaEngine -c origin_conf" "gunicorn --workers=3 -b 0.0.0.0:5000 --reload --access-logfile - --error-logfile - app:app"
