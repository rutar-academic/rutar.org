.PHONY: all clean
all: public

public:
	if [ "$$CF_PAGES_BRANCH" = "master" ]; then zola build; else zola build -u "https://$$CF_PAGES_BRANCH.rutar.pages.dev" --drafts; fi

clean:
	rm -r public
