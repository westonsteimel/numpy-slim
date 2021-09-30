FROM ghcr.io/westonsteimel/python:3.9-slim-bookworm

ARG TARGETPLATFORM
ENV TARGETPLATFORM="${TARGETPLATFORM}"

RUN apt update \
    && apt install -y \
    zip \
    pcregrep \
    binutils \
    bash

WORKDIR /build

COPY slimify.sh /build/
COPY test.py /build/

CMD ["/build/slimify.sh"]
