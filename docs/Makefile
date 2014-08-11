#!/usr/bin/make -k

pdfs = $(shell ls *.tex | sh -x ../bin/rsed "s/tex$$/pdf/")
#SHARED = daybo.sty
SHARED=
IDENT=.ident
VERSION=.version
CONFIGURE_AC=../configure.ac

.PHONY: all
all: ident version $(pdfs)
	@echo Done.

# nb. multiple calls to pdflatex required, this is not a mistake.
%.pdf: %.tex $(SHARED)
	@echo Building $@
	# Need to set the environment variable TEXINPUTS to contain the shared folder.
	(TEXINPUTS=.:$$TEXINPUTS && export TEXINPUTS && \
		pdflatex $<  && \
		pdflatex $<)
	rm -f $(basename $<).toc $(basename $<).aux $(basename $<).log  $(basename $<).out

.PHONY: version
version: $(CONFIGURE_AC) ../bin/version
	../bin/version -c $(CONFIGURE_AC) > $(VERSION)

.PHONY: ident
ident: ../bin/hgident
	../bin/hgident > $(IDENT)

.PHONY: clean
clean:
	rm -f *.pdf *.toc *.aux *.log *.out $(IDENT) $(VERSION)

.PHONY: check
check:
	@echo 'Dummy rule'

.PHONY: reallyinstall install
install:
	@echo 'Dummy rule'

reallyinstall:
	mkdir -p $(DESTDIR)/usr/share/doc/dlpodget
	for pdf in $(pdfs); do \
		install -m 444 $$pdf $(DESTDIR)/usr/share/doc/dlpodget/
	done
