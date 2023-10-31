FROM debian:10-slim

WORKDIR /build

COPY . .

# Add the key for the crystal debian repo
ADD https://download.opensuse.org/repositories/devel:/languages:/crystal/Debian_10/Release.key /tmp/crystal.key

# See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199 for why mkdir is needed
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install  --yes --no-install-recommends \
	# Install gnupg for the apt-key operation
	gnupg \
	# libssl for faster TLS in Crystal
	libssl-dev \
	# pdftk as a dependency for muse-dl
	pdftk=2.02-5 \
	# ca-certificates for talking to crystal-lang.org
	ca-certificates \
	# git to let shards install happen
	git \
	# needed by myhtml crystal shard
	make \
	# build --release
	zlib1g-dev && \
	# See https://crystal-lang.org/install/
	echo "deb http://download.opensuse.org/repositories/devel:/languages:/crystal/Debian_10/ /" | tee /etc/apt/sources.list.d/crystal.list && \
	gpg --dearmor /tmp/crystal.key && \
	mv /tmp/crystal.key.gpg /etc/apt/trusted.gpg.d/crystal.gpg && \
	rm /tmp/crystal.key && \
	apt-get update && \
	apt-get install --no-install-recommends --yes crystal && \
	# Cleanup
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN shards install && shards build --release && \
	ln /build/bin/muse-dl /usr/bin/muse-dl

RUN apt-get --yes remove git gnupg

WORKDIR /data
VOLUME /data

ENTRYPOINT ["/usr/bin/muse-dl"]
