.PHONY: all clean
all: public

public: static/alex_rutar_cv.pdf
	if [ "$$CF_PAGES_BRANCH" = "master" ]; then zola build; else zola build -u "https://$$CF_PAGES_BRANCH.rutar.pages.dev" --drafts; fi

static/alex_rutar_cv.pdf:
	tpr -C cv validate --pdf static/alex_rutar_cv.pdf

clean:
	rm -r public
