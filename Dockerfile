FROM ubuntu

# Need to install GCC-MULTILIB to be able to run amxxpc
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget git vim curl ca-certificates gcc-multilib hashalot

RUN useradd -m amxx && mkdir -p /var/build && chown -R amxx:amxx /var/build

USER amxx
WORKDIR /home/amxx
RUN wget -q -O amxx.tgz "https://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz" && \
    wget -q -O amxx_ns.tgz "https://www.amxmodx.org/release/amxmodx-1.8.2-ns-linux.tar.gz" && \
    wget -q -O amxx_ns.tgz "https://www.amxmodx.org/release/amxmodx-1.8.2-ns-linux.tar.gz" && \
    wget -q -O amxx_ns.tgz "https://www.amxmodx.org/release/amxmodx-1.8.2-ns-linux.tar.gz" && \

COPY files/amxmodx.sha /home/amxx
RUN sha256sum -c amxmodx.sha

RUN tar -zxf amxx.tgz && tar -zxf amxx_ns.tgz

WORKDIR /home/amxx/addons/amxmodx/scripting

COPY src/*.* /home/amxx/addons/amxmodx/scripting/
COPY src/include/*  /home/amxx/addons/amxmodx/scripting/include

# RUN ./amxxpc ENSL.sma && cp ENSL.sma /var/build

USER root
ENTRYPOINT ["/home/amxx/addons/amxmodx/scripting/compile.sh", "ENSL.sma"]
