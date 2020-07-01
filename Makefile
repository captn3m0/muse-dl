mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

release:
	# Build a static binary and save it in muse-dl-static
	docker build --tag muse-dl-static --file static.Dockerfile .
	# Then extract the image | extract the layer.tar file (we only have one layer) | extract the muse-dl-static file
	docker image save muse-dl-static | tar xf - --wildcards "*/layer.tar" -O | tar xf - "muse-dl-static"
	# And move it to the bin/ directory
	mv -f muse-dl-static bin/

test:
	crystal spec
