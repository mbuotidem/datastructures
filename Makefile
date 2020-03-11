SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = docsource
BUILDDIR      = docsource/build
MD:= $(wildcard prose/*.md)
GENERATEDTEX:= $(MD:prose/%.md=tex/generated/%.tex)
TEX = tex/main.tex tex/generated/pygments_macros.tex tex/titlepage.tex
# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile github test docs pdf clean weave

github:
	@make docs
	@cp -a docsource/build/html/. docs/

test:
	nosetests --with-coverage

docs:	Makefile
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

html: docs

tex/generated/pygments_macros.tex :
	prosecode styledefs --outfile tex/generated/pygments_macros.tex

tex/generated/%.tex: prose/%.md
	prosecode tangle $< --srcdir ds2/
	prosecode weave $< --outfile $@ --execute True

clean:
	$(foreach mdfile, $(MD), prosecode cleanup $(mdfile) --srcdir ds2/;)
	rm tex/generated/*
	rm tex/fullbook.*

weave: $(GENERATEDTEX)

pdf: $(GENERATEDTEX) $(TEX)
	cd tex; pdflatex -jobname=fullbook main.tex
