.PHONY: all clean build_cmd serve

all: public

public: build_cmd static/alex_rutar_cv.pdf
	if [ "$$CF_PAGES_BRANCH" = "master" ]; then zola build; else zola build -u "https://$$CF_PAGES_BRANCH.rutar.pages.dev" --drafts; fi


build:
	python build_cv.py
	mbib generate build/alex_rutar_cv.tex --out build/alex_rutar_cv.bib
	latexmk -pdf -interaction=nonstopmode -silent -Werror -file-line-error -cd build/alex_rutar_cv.tex

clean:
	rm -rf public
	rm -rf build
	rm -rf static/alex_rutar_cv.pdf
	rm -rf static/papers
	rm -rf static/notes

static/alex_rutar_cv.pdf: build
	mv build/alex_rutar_cv.pdf static/

build_cmd: build
	python runner.py build
	zola build

serve: build_cmd
	zola serve
