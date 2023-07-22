.PHONY: all clean build serve

all: public

public: build
	if [ "$$CF_PAGES_BRANCH" = "master" ]; then zola build; else zola build -u "https://$$CF_PAGES_BRANCH.rutar.pages.dev" --drafts; fi


cv_build:
	python build_cv.py
	mbib generate cv_build/alex_rutar_cv.tex --out cv_build/main.bib

clean:
	rm -rf public
	rm -rf cv_build

build: cv_build
	python runner.py build
	zola build

serve: build
	zola serve
