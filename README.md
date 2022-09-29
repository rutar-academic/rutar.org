# About
This is a repository for my [personal webpage](https://rutar.org).
The site is built using the [Zola](https://www.getzola.org/documentation/getting-started/installation/) static content generator.
If you want to build this locally, just `git clone`, change into the directory, and `zola serve`.
My site is hosted on [Cloudflare](https://pages.cloudflare.com/).

## License
The code for this site is licensed under the [MIT License](LICENSE).
The content for this site is [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Building and Verification
Running
```
zola build
```
from the root of the project generates the folder `public`, which is the static webpage.
This site is currently prepared for [Zola 13.0](https://github.com/getzola/zola/releases/tag/v0.13.0).

It is convenient to validate the output HTML for errors: here is a fish function using [HTTPie](https://httpie.io/) to do this.
```fish
function validate_html --argument path
    set -l response (string trim (https "https://validator.w3.org/nu/?out=gnu" @$path "Content-Type: text/html; charset=utf-8" --print 'b' --ignore-stdin))
    if test -n "$response"
        echo "$path: found errors or warnings"
        echo $response
        return 1
    else
        echo "$path: no errors or warnings"
        return 0
    end
end
```
Now, we can use this tool, along with [fd](https://github.com/sharkdp/fd), to validate all the HTML files in the build directory.
```sh
fd --base-directory public -e html --exec fish -c 'validate_html $argv' {}
```
This command is valid sh as well as fish, so you can incorporate it into your pre-commit hook to check that the site builds correctly on each commit.
You can find [pre-commit script](scripts/pre-commit.sh) and the [HTML validation script](scripts/validate_html.fish) in the [scripts](scripts) directory.
