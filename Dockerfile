FROM rust:1.81 as pyspybuilder

RUN mkdir /app
RUN cd py-spy || exit 1
# Built artifact will be at /app/release/py-spy0
RUN cargo build --release --target-dir=/app 

FROM golang:1.23 as delvebuilder

RUN mkdir /app
RUN cd delve && make build
RUN cp dlv /app/dlv

FROM debian:bookworm
SHELL ["/bin/bash", "-c"]

COPY --from=pyspybuilder /app/release/py-spy /usr/bin/py-spy
COPY --from=delvebuilder /app/dlv /usr/bin/dlv

RUN chmod +x /usr/bin/{dlv,py-spy}

CMD ["bash"]

