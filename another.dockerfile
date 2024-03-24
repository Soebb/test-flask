FROM airensoft/ovenmediaengine:latest

EXPOSE 1935:1935/tcp
EXPOSE 3333:3333/tcp
EXPOSE 3478:3478/tcp
EXPOSE 8080:8080/tcp
EXPOSE 8081:8081/tcp
EXPOSE 9000:9000/tcp
EXPOSE 9999:9999/udp
EXPOSE 4000-4005:4000-4005/udp
EXPOSE 10006-10010:10006-10010/udp

ENV OME_ORIGIN_PORT 9000
ENV OME_RTMP_PROV_PORT 1935
ENV OME_SRT_PROV_PORT 9999
ENV OME_MPEGTS_PROV_PORT 4000-4005/udp
ENV OME_HLS_STREAM_PORT 8080
ENV OME_DASH_STREAM_PORT 8080
ENV OME_SIGNALLING_PORT 3333
ENV OME_TCP_RELAY_ADDRESS *:3478
ENV OME_ICE_CANDIDATES *:10006-10010/udp

CMD /opt/ovenmediaengine/bin/OvenMediaEngine -c origin_conf
