FROM jrei/crystal-alpine as builder

WORKDIR /build

COPY . .

RUN shards install && shards build --release --static

FROM scratch

COPY --from=builder /build/bin/muse-dl /

ENTRYPOINT ["/muse-dl"]