
# LaTeX Makefile for dvi, ps, and pdf file creation.
#
# Adapted substantially by Rogan Creswick
# initially by Jeffrey Humpherys
# Written April 05, 2004
# Revised January 13, 2005-2012
# Thanks Bjorn and Boris
#

# urls is a list of uris that point to bib files: (space delimeted)
URLS = http://www.citeulike.org/bibtex/user/creswick
WGET = wget --output-document=dynamic.bib
INKSCAPE=`which inkscape`

BIBTEX=`which bibtex`
PDFLATEX=`which pdflatex`
PERL=`which perl`

#
# Useful for splitting out specific pages into separate pdfs:
#  (This makes a pdf out of everything but the first two pages)
# pdftk proposal.pdf cat 3-end output proposal-cddr.pdf
#
#

#################################################################
##
##  Set MAIN to the name of your primary tex file
##
MAIN       = cheatsheet
SOURCES	   = $(wildcard ./*.tex)

#
# The location of your figures:
#
FIGURE_DIR = figures
SVGFIGURES = $(patsubst %.svg,%.png,$(wildcard ./figures/*.svg))
EPSFIGURES = $(patsubst %.fig,%.eps,$(wildcard ./figures/*.fig))
PDFFIGURES = $(patsubst %.fig,%.pdf,$(wildcard ./figures/*.fig))

all: pdf

dynamic.bib:
	${WGET} ${URLS}

${MAIN}.bib: dynamic.bib base.bib
	cat base.bib dynamic.bib > ${MAIN}.bib

#
#  If you're using multi-bib, tweak the @if's so that you 
# have one @if line for each bibliography, and set the 
# names accordingly.  (this is out of date -- no if's needed now)
#
# dynamic.bib is created by sucking down bibtex info from 
# cite-u-like (or other on-line sources for bibtex files)
# base.bib will need to exist, so touch it if it doesn't.  
# It holds things that are document/project-specific.  
# (eg: stuff you don't want in cite-u-like)
#
bibliographies: ${MAIN}.bib all.aux
#	@for file in *.aux ; do ${BIBTEX} `basename $${file} .aux`; done;

%.aux:
	${PDFLATEX} ${MAIN}

pdf: ${MAIN}.pdf
	cp ${MAIN}.pdf ghc-mem-cheatsheet.pdf

${MAIN}.pdf : ${SOURCES} ${PDFFIGURES} ${SVGFIGURES} ${MAIN}.bib bibliographies
	pdflatex ${MAIN}
	pdflatex ${MAIN}
	@while ( grep "Rerun to get cross-references" 	\
		${MAIN}.log > /dev/null ); do		\
		echo '** Re-running LaTeX **';		\
		pdflatex ${MAIN};			\
	done

${MAIN}.ps : ${MAIN}.dvi
	dvips ${MAIN}.dvi -o ${MAIN}.ps

clean-bib: 
	rm -f ./dynamic.bib

clean:
#	rm -f ./${FIGURE_DIR}/*.tex
# 	rm -f ./${FIGURE_DIR}/*.eps
# 	rm -f ./${FIGURE_DIR}/*.pdf
	rm -f ./${FIGURE_DIR}/*.bak
	rm -f ./${MAIN}.bib
	rm -f ./${MAIN}.pdf
	rm -f ./${MAIN}.ps
	rm -f ./${MAIN}.dvi
#	rm -f ./dynamic.bib
	rm -f ./*.aux
	rm -f ./*.tex~
	rm -f ./*.bbl
	rm -f ./*.blg
	rm -f ./*.log

#
# (re)Make .eps is .fig if newer
#
%.eps : %.fig
	#Creates .eps file
	fig2dev -L pstex $*.fig > $*.eps
	#Creates .tex file
	fig2dev -L pstex_t -p $* $*.fig > $*.tex

#
# (re)Make .pdf if .esp is newer
#  Creates .pdf files from .esp files
%.png : %.svg
	${INKSCAPE} -T -z -f $*.svg  --export-png=$*.png --export-dpi=200

%.pdf: %.eps
	epstopdf $*.eps > $*.pdf