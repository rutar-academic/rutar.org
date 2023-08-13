.PHONY: all clean clean_remote serve

all: public

public: static/papers static/notes static/alex_rutar_cv.pdf data/pdf_data.json
	if [ $$(git rev-parse --abbrev-ref HEAD) = "master" ]; then zola build; else zola build -u "https://$$(git rev-parse --abbrev-ref HEAD).rutar.pages.dev" --drafts; fi


build:
	python build_cv.py
	latexmk -pdf -interaction=nonstopmode -silent -Werror -file-line-error -cd build/alex_rutar_cv.tex

clean_remote: clean
	rm -rf static/papers
	rm -rf static/notes

clean:
	rm -rf public
	rm -rf build
	rm -rf static/alex_rutar_cv.pdf
	rm -rf data/pdf_data.json

static/alex_rutar_cv.pdf: build
	mv build/alex_rutar_cv.pdf static/

static/papers:
	python runner.py papers

static/notes:
	python runner.py notes

data/pdf_data.json: static/papers static/notes
	python pdf_data.py

serve: public
	zola serve
