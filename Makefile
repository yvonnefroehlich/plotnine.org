.PHONY: help Makefile
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

prev_line_help = None
for line in sys.stdin:
	if prev_line_help is None:
		match = re.match(r"^## (.*)", line)
		if match:
			prev_line_help = match.groups()[0]
		else:
			prev_line_help = None
	else:
		match = re.match(r'^([a-zA-Z_-]+)', line)
		if match:
			target = match.groups()[0]
			print("%-22s %s" % (target, prev_line_help))

		target = None
		prev_line_help = None

endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

## Remove Quarto website build files
clean:
	rm -rf _site
	rm -rf images
	rm -f changelog.qmd
	rm -f objects.inv
	rm -f objects.txt
	rm -f _variables.yml
	rm -f qrenderer.scss
	rm -f plotnine.scss
	cd plotnine/doc && make clean

## Remove Quarto extensions
clean-exts:
	rm -rf _extensions

## Update git submodules to commits referenced in this repository
submodules:
	git submodule init
	git submodule update --depth=20

## Pull latest commits in git submodules
submodules-pull:
	git submodule update --recursive --remote

## Setup notebooks from plotnine-examples
plotnine-examples:
	python _plotnine_examples.py

# Create gallery and tutorials pages
pages: plotnine-examples
	python gallery/_create.py
	python tutorials/_create.py

## Install build dependencies
deps:
	cd plotnine/doc && make deps

## Build qmd files for plotnine API docs
api-docs: plotnine-examples pages
	cd plotnine/doc && make docstrings
	# Copy all relevant files
	rsync -av plotnine/doc/changelog.qmd .
	rsync -av plotnine/doc/objects.txt .
	rsync -av plotnine/doc/objects.inv .
	rsync -av plotnine/doc/_variables.yml .
	rsync -av plotnine/doc/images .
	rsync -av plotnine/doc/reference .
	rsync -av plotnine/doc/qrenderer.scss .
	rsync -av plotnine/doc/plotnine.scss .

## Download interlinks
interlinks:
	quartodoc interlinks

## Build website
site:
	quarto render

## Build
fresh-site: clean clean-exts api-docs interlinks site

## Build website and serve
preview:
	quarto preview
