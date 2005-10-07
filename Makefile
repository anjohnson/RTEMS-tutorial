WEB_BASE=/net/epics/Public/epics/base/RTEMS/tutorial
TEXFILES = tutorial.tex

all: pdf html

pdf: tutorial.pdf

tutorial.pdf: tutorial.tex getAndBuildTools.sh
	perl makeDoc.pl >versions.tex
	pdflatex tutorial.tex
	pdflatex tutorial.tex

html: tutorial/tutorial.html

tutorial/tutorial.html: tutorial.pdf
	sh makehtml.sh
	cp tutorial.pdf getAndBuildTools.sh tutorial

install: html pdf
	cd tutorial ; scp -r * $(WEB_BASE)

clean:
	rm -f *.dvi *.log *.aux *.bbl *.blg *.lof *.lot *.toc *.out
	rm -f tutorial.ps tutorial.pdf
	rm -rf tutorial
