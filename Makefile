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
	cd plotnine/docs && make clean

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

## Install build dependencies
deps:
	cd plotnine/docs && make deps
	# Copy all generated files except index.qmd
	rsync -av plotnine/docs/reference/ ./reference

## Build qmd files for plotnine API docs
api-docs:
	cd plotnine/docs && make docstrings

## Build website
site:
	quarto render

## Build website and serve
preview:
	quarto preview
