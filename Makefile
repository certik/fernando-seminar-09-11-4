# author  : Mateusz Paprocki

TEXSRC=certik-09-11-4
BIBSRC=euroscipy-slides-2009
OUTDIR=output

TEXOUT=$(OUTDIR)/$(TEXSRC)

DVILATEX=latex
PDFLATEX=pdflatex

DVIVIEW=kdvi
PDFVIEW=acroread

BIBTEX=bibtex
PYTHON=python

TEXFLAGS=-interaction=nonstopmode -file-line-error

all: pdf

dvi: $(TEXOUT).dvi
pdf: $(TEXOUT).pdf

$(TEXOUT).pdf: $(TEXSRC).tex $(BIBSRC).bib
	$(make-pdflatex)

define make-pdflatex
	@echo " LATEX : First pass, generating pdf output"
    @mkdir -p $(OUTDIR)
	@$(PDFLATEX) $(TEXFLAGS) -output-directory=$(OUTDIR) $< &> /dev/null; true;
	@if ( grep "^Error" $(TEXOUT).log &> /dev/null ); then \
		sed -n "/^Error/!d;N;p" $(TEXOUT).log;             \
		rm -f $(OUTDIR)/*.pdf;                             \
		exit 1;                                            \
	fi
	@if ( grep "^No file $(TEXSRC).bbl" $(TEXOUT).log &> /dev/null ); then          \
		echo " BIBTEX : Making bibliography for $(TEXSRC).tex";                     \
		$(BIBTEX) $(TEXOUT);                                                        \
		echo " LATEX : Re-running to update the bibliography";                      \
		$(PDFLATEX) $(TEXFLAGS) -output-directory=$(OUTDIR) $< &> /dev/null; true;  \
	fi
	@while ( grep "Rerun to get cross-references right" $(TEXOUT).log &> /dev/null ); do \
		echo " LATEX : Re-running LaTeX to fix cross-references";                        \
		$(PDFLATEX) $(TEXFLAGS) -output-directory=$(OUTDIR) $< &> /dev/null; true;       \
	done
	@sed -n "/LaTeX Error/p" $(TEXOUT).log
	@tail -1 $(TEXOUT).log
endef

.PHONY: shallow clean dviview pdfview view

shallow:
	rm -f $(OUTDIR)/{*.aux,*.bbl,*.blg,*.log,*.nav,*.out,*.snm,*.sympy,*.vrb,*.toc}

clean: shallow
	rm -f $(OUTDIR)/{*.dvi,*.pdf}

view: pdfview

dviview: $(TEXOUT).dvi
	$(DVIVIEW) $<

pdfview: $(TEXOUT).pdf
	$(PDFVIEW) $<

