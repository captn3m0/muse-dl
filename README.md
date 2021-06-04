# muse-dl ![Travis (.org)](https://img.shields.io/travis/captn3m0/muse-dl) ![GitHub issues](https://img.shields.io/github/issues/captn3m0/muse-dl) ![GitHub issues by-label](https://img.shields.io/github/issues/captn3m0/muse-dl/bug?color=red&label=open%20bugs) ![GitHub](https://img.shields.io/github/license/captn3m0/muse-dl) ![GitHub top language](https://img.shields.io/github/languages/top/captn3m0/muse-dl) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com) ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/captn3m0/muse-dl) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/captn3m0/muse-dl) ![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/captn3m0/muse-dl)

Download PDFs from Project MUSE and stitch them together into a single-file using [`pdftk`](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/).

# :warning: WARNING :warning:

Any downloads you perform with this tool are for your own usage. I personally hate reading PDFs on a browser, this lets me read them much more easily offline. This is just for personal use.

# Installation

## Linux / Build

```
git clone https://github.com/captn3m0/muse-dl.git
cd muse-dl
shards install
shards build
./bin/muse-dl --help
```

## Linux / Download

A linux x86_64 static build is available in the latest release: <https://github.com/captn3m0/muse-dl/releases/latest>. Save the file as `muse-dl` and remember to mark it as executable (`chmod +x`).

## Docker

A docker image is available at `captn3m0/muse-dl` on Docker Hub. The working directory for the image is set as `/data`, so you'll need to mount your output-directory as `/data` for it to work. Sample invocations;

```
# Download the book, and put it in your Downloads directory
docker run -it /home/nemo/Downloads:/data captn3m0/muse-dl:edge https://muse.jhu.edu/book/875

# If you have a list.txt file in your Downloads directory, then you can run
docker run -it /home/nemo/Downloads:/data captn3m0/muse-dl:edge /data/list.txt

# If you want to keep the temporary files with your host, and not delete them
docker run -it /home/nemo/Downloads:/data /tmp:/musetmp captn3m0/muse-dl:edge --tmp-dir /musetmp --no-cleanup https://muse.jhu.edu/book/875
```

Replace edge with the latest version number if you'd like to run a tagged release.

### Docker Images

The following images are available:

- `edge`: Run `muse-dl` against latest master.
- `edge-static`: Get the pre-built static-binary against latest master.
- `v1.3.1`: Run `muse-dl` against the specific release.
- `v1.3.1-static`: Get the pre-built static binary against the specific release.

## Requirements

Please ensure you have `pdftk` installed, unless you're running via docker.

## Usage

```
Usage: muse-dl [--flags] [URL|INPUT_FILE]

URL: A link to a book on the Project MUSE website, eg https://muse.jhu.edu/book/875
INPUT_FILE: Path to a file containing a list of links

    --no-cleanup                     Don't cleanup temporary files
    --tmp-dir PATH                   Temporary Directory to use
    --output FILE                    Output Filename
    --no-bookmarks                   Don't add bookmarks in the PDF
    --clobber                        Overwrite the output file, if it already exists.
    --dont-strip-first-page          Disables first page from being stripped. Use carefully
    --cookie COOKIE                  Cookie-header
    -h, --help                       Show this help
```

## Sample Run

```
muse-dl https://muse.jhu.edu/book/875
Saved final output to Accommodating Revolutions- Virginia's Northern Neck in an Era of Transformations, 1760-1810.pdf
```

Alternatively, if you pass a `input-file.txt` ([sample](https://paste.ubuntu.com/p/myBkNn6DSP/)), you can pass it as the sole parameter.

`muse-dl input.txt`

And it will download all the links in that file.

## License

Licensed under the [MIT License](https://nemo.mit-license.org/). See LICENSE file for details.
