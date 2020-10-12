FROM rust:1.46.0-slim-buster AS builder

ARG LINDERA_CLI_VERSION

WORKDIR /repo

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       cmake \
       jq \
       pkg-config \
       libssl-dev \
       curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cargo install lindera-cli --root=./ --vers=${LINDERA_CLI_VERSION}


FROM debian:buster-slim

WORKDIR /

RUN set -ex \
    && apt-get update \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /repo/bin /usr/local/bin

ENTRYPOINT [ "lindera" ]
