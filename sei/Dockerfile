FROM ubuntu:latest as builder

WORKDIR /sei

RUN apt update && apt-get install -y git make golang-go

RUN git clone https://github.com/sei-protocol/sei-chain .

RUN git checkout origin/1.0.1beta-upgrade

RUN export GOPROXY=proxy.golang.org

RUN make install

CMD sleep 6000