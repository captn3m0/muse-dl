FROM jrei/crystal-alpine:edge as builder

WORKDIR /build

COPY . .

RUN shards install && \
	shards build --release --static

FROM scratch

COPY --from=builder /build/bin/muse-dl /muse-dl