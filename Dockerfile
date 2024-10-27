FROM rust:1.81 as pyspybuilder

COPY py-spy /app
WORKDIR /app
RUN ls -lah
# Built artifact will be at /app/release/py-spy0
RUN cargo build --release --target-dir=/app 

FROM golang:1.23 as delvebuilder

COPY delve /app
WORKDIR /app
RUN ls -lah
RUN make build

FROM debian:bookworm
SHELL ["/bin/bash", "-c"]

COPY --from=pyspybuilder /app/release/py-spy /usr/bin/py-spy
COPY --from=delvebuilder /app/dlv /usr/bin/dlv

RUN chmod +x /usr/bin/{dlv,py-spy}

CMD ["bash"]

