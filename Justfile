branch := `git rev-parse --abbrev-ref HEAD`

public: releases cv data
    if [ "{{branch}}" = "master" ]; then zola build; else zola build -u "https://{{branch}}.rutar.pages.dev" --drafts; fi

check: public
    uvx ruff check scripts
    uvx ruff format scripts --check
    uvx html5validator --root public/ --also-check-css --show-warnings --format gnu -ll

releases:
    ./scripts/releases.py

cv: data
    ./scripts/cv.py
    latexmk -pdf -interaction=nonstopmode -silent -Werror -file-line-error -cd build/alex_rutar_cv.tex
    mv build/alex_rutar_cv.pdf static/

data: releases
    mkdir --parent data/generated
    ./scripts/pdf_data.py
    ./scripts/past_travel.py

serve: releases cv data
    zola serve

clean:
	rm -rf public
	rm -rf build
	rm -rf data/generated/*.pdf

clean_all: clean
	rm -rf static/alex_rutar_cv.pdf
	rm -rf static/papers
	rm -rf static/notes
