.PHONY: all clean clean_remote serve

all: public

public: static/papers static/notes static/alex_rutar_cv.pdf data/pdf_data.json
	if [ $$(git rev-parse --abbrev-ref HEAD) = "master" ]; then zola build; else zola build -u "https://$$(git rev-parse --abbrev-ref HEAD).rutar.pages.dev" --drafts; fi

static/papers static/notes: venv
	venv/bin/python scripts/releases.py

venv:
	python3 -m venv venv
	venv/bin/pip install -r requirements.txt

static/alex_rutar_cv.pdf: build/alex_rutar_cv.pdf
	mv build/alex_rutar_cv.pdf static/

build/alex_rutar_cv.pdf: build/alex_rutar_cv.tex
	latexmk -pdf -interaction=nonstopmode -silent -Werror -file-line-error -cd build/alex_rutar_cv.tex

build/alex_rutar_cv.tex:
	venv/bin/python scripts/cv.py

data/pdf_data.json: venv static/papers static/notes
	venv/bin/python scripts/pdf_data.py

serve: public
	zola serve

clean_remote: clean
	rm -rf static/papers
	rm -rf static/notes

clean:
	rm -rf public
	rm -rf build
	rm -rf static/alex_rutar_cv.pdf
	rm -rf data/pdf_data.json
