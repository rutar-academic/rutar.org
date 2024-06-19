branch := `git rev-parse --abbrev-ref HEAD`

public: releases cv data build

fast: cv data build

releases:
    venv/bin/python scripts/releases.py

cv:
    venv/bin/python scripts/cv.py
    latexmk -pdf -interaction=nonstopmode -silent -Werror -file-line-error -cd build/alex_rutar_cv.tex
    mv build/alex_rutar_cv.pdf static/

data:
    venv/bin/python scripts/pdf_data.py

init:
    python3 -m venv venv
    venv/bin/pip install -r requirements.txt

build:
    if [ "{{branch}}" = "master" ]; then zola build; else zola build -u "https://{{branch}}.rutar.pages.dev" --drafts; fi

serve: releases cv data
    zola serve

clean:
	rm -rf public
	rm -rf build
	rm -rf static/alex_rutar_cv.pdf
	rm -rf data/pdf_data.json
	rm -rf static/papers
	rm -rf static/notes
