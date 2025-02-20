# Makefile for Sphinx documentation
#
# The included file 'gh-project.mk' should define the following:
# GH_SOURCE_DIR = top-level directory of all the ReST source files
include gh-project.mk

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = ./gh-build
CYCLUS_GIT_BRANCH    = main
CYCLUS_GIT_FORK      = cyclus
CYCAMORE_GIT_BRANCH	 = main
CYCAMORE_GIT_FORK	 = cyclus


# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) $(GH_SOURCE_DIR)
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) $(GH_SOURCE_DIR)

.PHONY: help clean html dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub latex \
	 latexpdf text man changes linkcheck doctest gettext

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  gh-preview        to build HTML in directory $BUILDDIR for testing"
	@echo "  gh-revert         to cleanup HTML build in directory $BUILDDIR after testing"
	@echo "  docker-html       to use docker to build HTML in directory $BUILDDIR for testing"
	@echo "  serve             build+serve html files using Python's SimpleHTTPServer"
	@echo "  serve-only        serve pre-built html files using Python's SimpleHTTPServer"
	@echo "  dirhtml           to make HTML files named index.html in directories"
	@echo "  singlehtml        to make a single large HTML file"
	@echo "  pickle            to make pickle files"
	@echo "  json              to make JSON files"
	@echo "  htmlhelp          to make HTML files and a HTML help project"
	@echo "  qthelp            to make HTML files and a qthelp project"
	@echo "  devhelp           to make HTML files and a Devhelp project"
	@echo "  epub              to make an epub"
	@echo "  latex             to make LaTeX files, you can set PAPER=a4 or PAPER=letter"
	@echo "  latexpdf          to make LaTeX files and run them through pdflatex"
	@echo "  text              to make text files"
	@echo "  man               to make manual pages"
	@echo "  texinfo           to make Texinfo files"
	@echo "  info              to make Texinfo files and run them through makeinfo"
	@echo "  gettext           to make PO message catalogs"
	@echo "  changes           to make an overview of all changed/added/deprecated items"
	@echo "  linkcheck         to check all external links for integrity"
	@echo "  doctest           to run all doctests embedded in the documentation (if enabled)"

gh-clean gh-revert clean:
	-rm -rf $(BUILDDIR)

gh-preview html:
	wget -nv https://raw.githubusercontent.com/${CYCLUS_GIT_FORK}/cyclus/${CYCLUS_GIT_BRANCH}/INSTALL.rst -O source/user/CYCLUS_INSTALL.rst || \
		curl https://raw.githubusercontent.com/${CYCLUS_GIT_FORK}/cyclus/${CYCLUS_GIT_BRANCH}/INSTALL.rst -L -o source/user/CYCLUS_INSTALL.rst
	wget -nv https://raw.githubusercontent.com/${CYCLUS_GIT_FORK}/cyclus/${CYCLUS_GIT_BRANCH}/DEPENDENCIES.rst -O source/user/DEPENDENCIES.rst || \
		curl https://raw.githubusercontent.com/${CYCLUS_GIT_FORK}/cyclus/${CYCLUS_GIT_BRANCH}/DEPENDENCIES.rst -L -o source/user/DEPENDENCIES.rst
	wget -nv https://raw.githubusercontent.com/${CYCAMORE_GIT_FORK}/cycamore/${CYCAMORE_GIT_BRANCH}/INSTALL.rst -O source/user/CYCAMORE_INSTALL.rst || \
		curl https://raw.githubusercontent.com/${CYCAMORE_GIT_FORK}/cycamore/${CYCAMORE_GIT_BRANCH}/INSTALL.rst -L -o source/user/CYCAMORE_INSTALL.rst
	wget -nv https://raw.githubusercontent.com/${CYCAMORE_GIT_FORK}/cycamore/${CYCAMORE_GIT_BRANCH}/DEPENDENCIES.rst -O source/user/CYCAMORE_DEPS.rst || \
		curl https://raw.githubusercontent.com/${CYCAMORE_GIT_FORK}/cycamore/${CYCAMORE_GIT_BRANCH}/DEPENDENCIES.rst -L -o source/user/CYCAMORE_DEPS.rst

	python3 source/releases.py
	PYTHONDONTWRITEBYTECODE="TRUE" $(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)
	sed -i.bak 's/function top_offset([$$]node){ return [$$]node\[0\].getBoundingClientRect().top; }/function top_offset($$node){ return (typeof $$node[0] === "undefined") ? 0 : $$node[0].getBoundingClientRect().top; }/' ./gh-build/_static/cloud.js
	sed -i.bak 's/  if (state == "collapsed"){/  if (typeof state === "undefined") {\n	var state = "uncollapsed";\n  };\n  if (state == "collapsed"){/' ./gh-build/_static/cloud.js
	rm ./gh-build/_static/*.bak
	cp $(BUILDDIR)/cep/cep0.html $(BUILDDIR)/cep/index.html
	cp `cyclus --install-path`/share/cyclus/dbtypes.json $(BUILDDIR)/arche/
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)."

docker-gh-preview docker-html:
	docker build --platform linux/amd64 -f docker/Dockerfile -t site-image --build-arg BUILDDIR=$(BUILDDIR) --progress plain .
	docker create --platform linux/amd64 --name site-container site-image sleep
	docker cp site-container:/$(BUILDDIR) $(BUILDDIR)
	docker rm site-container

serve: html
	cd $(BUILDDIR) && python -m http.server

serve-only:
	cd $(BUILDDIR) && python -m http.server

htmlclean cleanhtml: clean html

dirhtml:
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) $(BUILDDIR)/dirhtml
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/dirhtml."

singlehtml:
	$(SPHINXBUILD) -b singlehtml $(ALLSPHINXOPTS) $(BUILDDIR)/singlehtml
	@echo
	@echo "Build finished. The HTML page is in $(BUILDDIR)/singlehtml."

pickle:
	$(SPHINXBUILD) -b pickle $(ALLSPHINXOPTS) $(BUILDDIR)/pickle
	@echo
	@echo "Build finished; now you can process the pickle files."

json:
	$(SPHINXBUILD) -b json $(ALLSPHINXOPTS) $(BUILDDIR)/json
	@echo
	@echo "Build finished; now you can process the JSON files."

htmlhelp:
	$(SPHINXBUILD) -b htmlhelp $(ALLSPHINXOPTS) $(BUILDDIR)/htmlhelp
	@echo
	@echo "Build finished; now you can run HTML Help Workshop with the" \
	      ".hhp project file in $(BUILDDIR)/htmlhelp."

qthelp:
	$(SPHINXBUILD) -b qthelp $(ALLSPHINXOPTS) $(BUILDDIR)/qthelp
	@echo
	@echo "Build finished; now you can run "qcollectiongenerator" with the" \
	      ".qhcp project file in $(BUILDDIR)/qthelp, like this:"
	@echo "# qcollectiongenerator $(BUILDDIR)/qthelp/UW-MadisonComputationalNuclearEngineeringResearchGroupCNERG.qhcp"
	@echo "To view the help file:"
	@echo "# assistant -collectionFile $(BUILDDIR)/qthelp/UW-MadisonComputationalNuclearEngineeringResearchGroupCNERG.qhc"

devhelp:
	$(SPHINXBUILD) -b devhelp $(ALLSPHINXOPTS) $(BUILDDIR)/devhelp
	@echo
	@echo "Build finished."
	@echo "To view the help file:"
	@echo "# mkdir -p $$HOME/.local/share/devhelp/UW-MadisonComputationalNuclearEngineeringResearchGroupCNERG"
	@echo "# ln -s $(BUILDDIR)/devhelp $$HOME/.local/share/devhelp/UW-MadisonComputationalNuclearEngineeringResearchGroupCNERG"
	@echo "# devhelp"

epub:
	$(SPHINXBUILD) -b epub $(ALLSPHINXOPTS) $(BUILDDIR)/epub
	@echo
	@echo "Build finished. The epub file is in $(BUILDDIR)/epub."

latex:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo
	@echo "Build finished; the LaTeX files are in $(BUILDDIR)/latex."
	@echo "Run \`make' in that directory to run these through (pdf)latex" \
	      "(use \`make latexpdf' here to do that automatically)."

latexpdf:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex."

text:
	$(SPHINXBUILD) -b text $(ALLSPHINXOPTS) $(BUILDDIR)/text
	@echo
	@echo "Build finished. The text files are in $(BUILDDIR)/text."

man:
	$(SPHINXBUILD) -b man $(ALLSPHINXOPTS) $(BUILDDIR)/man
	@echo
	@echo "Build finished. The manual pages are in $(BUILDDIR)/man."

texinfo:
	$(SPHINXBUILD) -b texinfo $(ALLSPHINXOPTS) $(BUILDDIR)/texinfo
	@echo
	@echo "Build finished. The Texinfo files are in $(BUILDDIR)/texinfo."
	@echo "Run \`make' in that directory to run these through makeinfo" \
	      "(use \`make info' here to do that automatically)."

info:
	$(SPHINXBUILD) -b texinfo $(ALLSPHINXOPTS) $(BUILDDIR)/texinfo
	@echo "Running Texinfo files through makeinfo..."
	make -C $(BUILDDIR)/texinfo info
	@echo "makeinfo finished; the Info files are in $(BUILDDIR)/texinfo."

gettext:
	$(SPHINXBUILD) -b gettext $(I18NSPHINXOPTS) $(BUILDDIR)/locale
	@echo
	@echo "Build finished. The message catalogs are in $(BUILDDIR)/locale."

changes:
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) $(BUILDDIR)/changes
	@echo
	@echo "The overview file is in $(BUILDDIR)/changes."

linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) $(BUILDDIR)/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in $(BUILDDIR)/linkcheck/output.txt."

doctest:
	$(SPHINXBUILD) -b doctest $(ALLSPHINXOPTS) $(BUILDDIR)/doctest
	@echo "Testing of doctests in the sources finished, look at the " \
	      "results in $(BUILDDIR)/doctest/output.txt."
install:
	rsync -a $(BUILDDIR)build/html/* .
	rm -rf $(BUILDDIR)build/html/*
