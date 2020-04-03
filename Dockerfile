FROM ubuntu:19.04

WORKDIR /build

COPY . .

# Add the key for the crystal debian repo
ADD https://keybase.io/crystal/pgp_keys.asc /tmp/crystal.gpg

# Install gnupg for the apt-key operation and openssl for our TLS stuff
RUN apt-get update && \
	apt-get install  --yes --no-install-recommends gnupg=2.2.12-1ubuntu3 libssl-dev=1.1.1b-1ubuntu2.4 && \
	# See https://crystal-lang.org/install/
	apt-key add /tmp/crystal.gpg && \
	echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list && \
	apt-get update && \
	apt-get install --no-install-recommends --yes crystal=0.33.0-1 pdftk=2.02-5 && \
	# Cleanup
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN shards install && shards build --release

VOLUME /output

ENTRYPOINT ["/build/bin/muse-dl"]