FROM rust:1.81 as pyspybuilder

COPY py-spy /app
WORKDIR /app

RUN apt-get update && \
  apt-get install -y libunwind-dev && \
  rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-gnu
# Built artifact will be at /app/release/py-spy0
RUN cargo build --release --target-dir=/app --target=x86_64-unknown-linux-gnu 
RUN ls -lah /app/x86_64-unknown-linux-gnu/release
FROM golang:1.23 as delvebuilder

COPY delve /app
WORKDIR /app
RUN ls -lah
RUN make build

FROM debian:bookworm
SHELL ["/bin/bash", "-c"]

COPY --from=pyspybuilder /app/x86_64-unknown-linux-gnu/release/py-spy /usr/bin/py-spy
COPY --from=delvebuilder /app/dlv /usr/bin/dlv

RUN chmod +x /usr/bin/{dlv,py-spy}

RUN apt-get update && apt-get install -y \
  curl \
  linix-perf \
  procps \
  gdb && \
  apt-get clean 

CMD ["bash"]

