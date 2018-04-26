FROM ubuntu

# Need to install GCC-MULTILIB to be able to run amxxpc
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget git vim curl ca-certificates gcc-multilib hashalot unzip zip

RUN useradd -m amxx && mkdir -p /var/build/pkg && chown -R amxx:amxx /var/build

USER amxx
WORKDIR /home/amxx
RUN wget -q -O amxx.tgz "https://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz" && \
    wget -q -O amxx_ns.tgz "https://www.amxmodx.org/release/amxmodx-1.8.2-ns-linux.tar.gz" && \
    wget -q -O amxx.zip "https://www.amxmodx.org/release/amxmodx-1.8.2-base-windows.zip" && \
    wget -q -O amxx_ns.zip "http://www.amxmodx.org/release/amxmodx-1.8.2-ns-windows.zip"

COPY files/amxmodx.sha /home/amxx
RUN sha256sum -c amxmodx.sha

RUN tar -zxf amxx.tgz && tar -zxf amxx_ns.tgz

WORKDIR /home/amxx/addons/amxmodx/scripting

#COPY --chown=amxx src/ensl.sh /home/amxx/
#COPY --chown=amxx src/*.sma /home/amxx/addons/amxmodx/scripting/
#COPY --chown=amxx src/include/*  /home/amxx/addons/amxmodx/scripting/include
#COPY --chown=amxx pkg /var/pkg
COPY src/ensl.sh /home/amxx/
COPY src/*.sma /home/amxx/addons/amxmodx/scripting/
COPY src/include/*  /home/amxx/addons/amxmodx/scripting/include
COPY pkg /var/pkg
RUN chown -R /home/amxx


# RUN ./amxxpc ENSL.sma && cp ENSL.sma /var/build

USER root
ENTRYPOINT ["/home/amxx/ensl.sh", "ENSL.sma"]
