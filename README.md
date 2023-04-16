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
make build
```
from the root of the project generates the folder `public`, which is the static webpage.
This site is currently prepared for [Zola 17.2](https://github.com/getzola/zola/releases/tag/v0.17.2).

It is convenient to validate the output HTML for errors: to do this, I use this [HTML5 validator tool](https://github.com/svenkreiss/html5validator) which I run with the command
```fish
html5validator --root public/ --also-check-css --show-warnings --format gnu -ll
```
