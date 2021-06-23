FROM ghcr.io/westonsteimel/python:3.9-slim-bullseye

RUN apt update \
    && apt install -y \
    zip \
    pcregrep \
    binutils \
    bash

WORKDIR /build

COPY slimify.sh /build/

CMD ["/build/slimify.sh"]
