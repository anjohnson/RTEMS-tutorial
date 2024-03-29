WEB_BASE=phoebus:/net/epics/Public/epics/base/RTEMS
TEXFILES = tutorial.tex

all: pdf html

pdf: tutorial.pdf

tutorial.pdf: tutorial.tex versions.tex
	pdflatex tutorial.tex
	pdflatex tutorial.tex

html: tutorial/tutorial.html

tutorial/tutorial.html: tutorial.pdf
	sh makehtml.sh
	cp tutorial.pdf tutorial

install: html pdf
	tar cfj ~/tutorial.tar.bz2 tutorial
	echo "Please unpack $(HOME)/tutorial.tar.bz2 in $(WEB_BASE)   (web server)"

versions.tex:
	perl makeDoc.pl >versions.tex

clean:
	rm -f *.dvi *.log *.aux *.bbl *.blg *.lof *.lot *.toc *.out *.zip

realclean: clean
	rm -f tutorial.ps tutorial.pdf
	rm -rf tutorial

icms: all clean
	zip -r tutorial.zip .
