.PHONY: all clean build serve

all: public

public:
	if [ "$$CF_PAGES_BRANCH" = "master" ]; then zola build; else zola build -u "https://$$CF_PAGES_BRANCH.rutar.pages.dev" --drafts; fi

clean:
	rm -rf public

build:
	python runner.py build
	zola build

serve: build
	zola serve
