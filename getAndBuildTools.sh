#!/bin/sh

#
# Get, build and install the latest cross-development tools and libraries
#

#
# Specify the architectures for which the tools are to be built
# To build for multiple targets: ARCHS="m68k powerpc i386"
#
ARCHS="${ARCHS:-powerpc}"

#
# Where to install
#
PREFIX="${PREFIX:-/opt/rtems}"

#
# Specify the versions
#
GCC=gcc-3.3.3
BINUTILS=binutils-2.15
NEWLIB=newlib-1.11.0
BINUTILSDIFF=20040519
GCCDIFF=20040420
NEWLIBDIFF=20031113

#
# Where to get the GNU tools
#
RTEMS_SOURCES_URL=ftp://www.rtems.com/pub/rtems/SOURCES
RTEMS_BINUTILS_URL=${RTEMS_SOURCES_URL}/${BINUTILS}.tar.bz2
RTEMS_GCC_URL=${RTEMS_SOURCES_URL}/${GCC}.tar.bz2
RTEMS_NEWLIB_URL=${RTEMS_SOURCES_URL}/${NEWLIB}.tar.gz
RTEMS_BINUTILS_DIFF_URL=${RTEMS_SOURCES_URL}/${BINUTILS}-rtems-${BINUTILSDIFF}.diff
RTEMS_GCC_DIFF_URL=${RTEMS_SOURCES_URL}/${GCC}-rtems-${GCCDIFF}.diff
RTEMS_NEWLIB_DIFF_URL=${RTEMS_SOURCES_URL}/${NEWLIB}-rtems-${NEWLIBDIFF}.diff

#
# Uncomment one of the following depending upon which your system provides
#
#GET_COMMAND="curl --remote-name"
GET_COMMAND="wget --passive-ftp --no-directories --retr-symlinks "

#
# Allow environment to override some programs
#
MAKE="${MAKE:-make}"
export MAKE
SHELL="${SHELL:-/bin/sh}"
export SHELL

#
# Get the source
# If you don't have curl on your machine, try using
#     wget --passive-ftp --no-directories --retr-symlinks <<url>>
# If that doesn't work, try without the --passive-ftp option.
#
getSource() {
    ${GET_COMMAND} "${RTEMS_BINUTILS_URL}"
    if [ -n "$BINUTILSDIFF" ]
    then
        ${GET_COMMAND} "${RTEMS_BINUTILS_DIFF_URL}"
    fi
    ${GET_COMMAND}  "${RTEMS_GCC_URL}"
    if [ -n "$GCCDIFF" ]
    then
        ${GET_COMMAND} "${RTEMS_GCC_DIFF_URL}"
    fi
     ${GET_COMMAND} "${RTEMS_NEWLIB_URL}"
    if [ -n "$NEWLIBDIFF" ]
    then
        ${GET_COMMAND} "${RTEMS_NEWLIB_DIFF_URL}"
    fi
}

#
# Unpack the source
#
unpackSource() {
    rm -rf "{$BINUTILS}"
    bzcat "${BINUTILS}.tar.bz2" | tar xf -
    for d in "${BINUTILS}"*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "${BINUTILS}" ; patch -p1)
        fi
    done

    rm -rf "${GCC}"
    bzcat "${GCC}.tar.bz2" | tar xf -
    for d in "${GCC}"*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "${GCC}" ; patch -p1)
        fi
    done

    rm -rf "${NEWLIB}"
    zcat "${NEWLIB}.tar.gz" | tar xf -
    for d in "${NEWLIB}"*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "${NEWLIB}" ; patch -p1)
        fi
    done
    (cd "${GCC}" ; ln -s "../${NEWLIB}/newlib" newlib)
}

#
# Build
#
build() {
    PATH="${PREFIX}/bin:$PATH"
    for arch in $ARCHS
    do
        rm -rf build
        mkdir build
        cd build
        "${SHELL}" "../${BINUTILS}/configure" "--target=${arch}-rtems" "--prefix=${PREFIX}"
        ${MAKE} -w all install
        cd ..

        rm -rf build
        mkdir build
        cd build
       "${SHELL}" "../${GCC}/configure" "--target=${arch}-rtems" "--prefix=${PREFIX}" \
            --with-gnu-as --with-gnu-ld --with-newlib --verbose \
            --with-system-zlib --disable-nls \
            --enable-version-specific-runtime-libs \
            --enable-threads=rtems \
            --enable-languages=c,c++ 
        ${MAKE} -w all
        ${MAKE} -w install
        cd ..
    done
}

#
# Do everything
#
# Comment out any activities you wish to omit
#
set -ex
getSource
unpackSource
build
