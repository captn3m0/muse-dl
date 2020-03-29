# muse-dl

Download PDFs from Project MUSE and stitch them together into a single-file using [`pdftk`](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/).

# Installation

```
git clone https://github.com/captn3m0/muse-dl.git
cd muse-dl
shards install
shards build
./bin/muse-dl --help
```

## Requirements

Please ensure you have `pdftk` installed, and run the `muse-dl` binary. To build the binary, please run the steps in Installation.

## Usage

```
Usage: muse-dl [--flags] [URL|INPUT_FILE]

URL: A link to a book on the Project MUSE website, eg https://muse.jhu.edu/book/875
INPUT_FILE: Path to a file containing a list of links

    --no-cleanup                     Don't cleanup temporary files
    --tmp-dir PATH                   Temporary Directory to use
    --output FILE                    Output Filename
    --no-bookmarks                   Don't add bookmarks in the PDF
    --input-pdf INPUT                Input Stitched PDF. Will not download anything
    --clobber                        Overwrite the output file, if it already exists. Not compatible with input-pdf
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