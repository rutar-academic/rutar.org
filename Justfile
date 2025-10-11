branch := `git rev-parse --abbrev-ref HEAD`

public: check releases cv data build

fast: cv data build

check:
    uvx ruff check scripts
    uvx ruff format scripts --check

releases:
    uv run --python 3.12 --with-requirements requirements.txt scripts/releases.py

cv: data
    uv run --python 3.12 --with-requirements requirements.txt scripts/cv.py
    latexmk -pdf -interaction=nonstopmode -silent -Werror -file-line-error -cd build/alex_rutar_cv.tex
    mv build/alex_rutar_cv.pdf static/

data:
    uv run --python 3.12 --with-requirements requirements.txt scripts/pdf_data.py
    uv run --python 3.12 scripts/past_travel.py

build: data
    if [ "{{branch}}" = "master" ]; then zola build; else zola build -u "https://{{branch}}.rutar.pages.dev" --drafts; fi

serve: releases cv data
    zola serve

clean:
	rm -rf public
	rm -rf build
	rm -rf data/generated/*.pdf

clean_all:
	rm -rf static/alex_rutar_cv.pdf
	rm -rf static/papers
	rm -rf static/notes
