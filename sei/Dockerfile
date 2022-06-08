FROM archlinux:latest as builder

WORKDIR /sei

RUN yes | pacman -Syy go git make gcc

RUN git clone https://github.com/sei-protocol/sei-chain .

RUN git checkout origin/1.0.1beta-upgrade

RUN export GOPROXY=proxy.golang.org

RUN make install

CMD sleep 6000