FROM ubuntu:xenial

RUN apt-get update && \ 
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
	apt-get install -y --no-install-recommends build-essential cmake g++-7 gcc-7 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 60 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60

WORKDIR /home/

ENV DOCKER=1

CMD /bin/bash
