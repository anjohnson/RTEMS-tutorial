#!/bin/sh

set -ex

address="<I>Eric Norum<BR>norume@aps.anl.gov<BR>`date`</I>"

latex2html -noinfo -local_icons -transparent -split 4 -t "Getting Started with EPICS on RTEMS" -address "$address" tutorial.tex
