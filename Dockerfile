FROM debian:10-slim

WORKDIR /build

COPY . .

# Add the key for the crystal debian repo
ADD https://keybase.io/crystal/pgp_keys.asc /tmp/crystal.gpg

# See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199 for why mkdir is needed
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install  --yes --no-install-recommends \
	# Install gnupg for the apt-key operation
	gnupg=2.2.12-1+deb10u1 \
	# libssl for faster TLS in Crystal
	libssl-dev=1.1.1d-0+deb10u2 \
	# pdftk as a dependency for muse-dl
	pdftk=2.02-5 \
	# ca-certificates for talking to crystal-lang.org
	ca-certificates=20190110 \
	# git to let shards install happen
	git=1:2.20.1-2+deb10u1 \
	# build --release
	zlib1g-dev=1:1.2.11.dfsg-1 && \
	# See https://crystal-lang.org/install/
	apt-key add /tmp/crystal.gpg && \
	echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list && \
	apt-get update && \
	apt-get install --no-install-recommends --yes crystal=0.33.0-1 && \
	# Cleanup
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN shards install && shards build --release && \
	ln /build/bin/muse-dl /usr/bin/muse-dl

RUN apt-get --yes remove git gnupg

WORKDIR /data
VOLUME /data

ENTRYPOINT ["/usr/bin/muse-dl"]