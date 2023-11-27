# About
This is a repository for my [personal webpage](https://rutar.org).
The site is built using the [Zola](https://www.getzola.org/documentation/getting-started/installation/) static content generator.
If you want to build this locally, just `git clone`, change into the directory, and `make serve`.
My site is hosted on [Cloudflare](https://pages.cloudflare.com/).

## License
The code for this site is licensed under the [MIT License](LICENSE).
The content for this site is [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Building and Verification
Running
```
make
```
from the root of the project generates the folder `public`, which is the static webpage.
This site is currently prepared for [Zola 17.2](https://github.com/getzola/zola/releases/tag/v0.17.2).
Note that running `make` yourself on this repository will likely fail since the release files for papers are in private repositories and require permission to access.

It is convenient to validate the output HTML for errors: to do this, I use this [HTML5 validator tool](https://github.com/svenkreiss/html5validator) which I run with the command
```fish
html5validator --root public/ --also-check-css --show-warnings
```
### Build steps
The build process is somewhat order dependent, so the entire process is summarized here.
The strict dependency structure can be found in the [`Makefile`](/Makefile).

1. Install dependencies from [`requirements.txt`](/requirements.txt).
2. Download all papers from the repositories specified in `data/papers.json` and `data/notes.json` by running `python scripts/releases.py papers` and `python scripts/releases.py notes`.
   The download location is hard-coded to `rutar-academic/<filename>` where `<filename>.pdf` is the name specified in the `.links.pdf` entry.
   The files are downloaded to `static/papers` and `static/notes`.
3. Generate PDF data using [pypdf](https://pypi.org/project/pypdf/) from the newly downloaded files in `static/papers` and `static/notes`.
   The generated PDF data is written to `data/pdf_data.json`.
4. Generate the CV `.tex` file using [jinja](https://jinja.palletsprojects.com/en/3.1.x/) from the template [`cv/alex_rutar_cv.tex`](/cv/alex_rutar_cv.tex) by using `python scripts/cv.py`.
   A lot of the CV data is taken from various files in the [`data`](/data) directory.
   The generated template is copied to the file `build/alex_rutar_cv.tex`.
5. Compile the LaTeX file `build/alex_rutar_cv.tex` and copy the compiled PDF to `static/alex_rutar_cv.pdf`.
6. Compile the HTML files using `zola build`.
   The compiled files are placed in the `public` directory.

You can clean-up all local build files using `make clean` and remote files as well with `make clean_remote`.
