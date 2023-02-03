FROM ubuntu:latest as builder

WORKDIR /sei

RUN apt update && apt-get install -y git make golang-go curl

RUN git clone https://github.com/sei-protocol/sei-chain .

RUN git checkout 1.0.2beta

RUN export GOPROXY=proxy.golang.org

RUN make install

RUN cp /root/go/bin/seid /usr/bin/

RUN chmod 777 /usr/bin/seid

ENTRYPOINT /entrypoint.sh