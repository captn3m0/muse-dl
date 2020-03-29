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
Usage: muse-dl [--flags] URL
    --no-cleanup                     Don't cleanup temporary files
    --tmp-dir PATH                   Temporary Directory to use
    --output FILE                    Output Filename
    --no-bookmarks                   Don't add bookmarks in the PDF
    --clobber                        Overwrite the output file, if it already exists
    -h, --help                       Show this help
```

## Sample Run

```
muse-dl https://muse.jhu.edu/book/875
Saved final output to Accommodating Revolutions- Virginia's Northern Neck in an Era of Transformations, 1760-1810.pdf
```

## License

Licensed under the [MIT License](https://nemo.mit-license.org/). See LICENSE file for details.