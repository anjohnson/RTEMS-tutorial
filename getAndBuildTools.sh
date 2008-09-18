#!/bin/sh

#
# Get, build and install the latest cross-development tools and libraries
#

#
# Specify the architectures for which the tools are to be built
# To build for single target: ARCHS="m68k"
#
ARCHS="${ARCHS:-m68k i386 powerpc}"

#
# Specify the versions
#
GCC=4.3.2
BINUTILS=2.18
NEWLIB=1.16.0
GDB=6.8
BINUTILSDIFF=binutils-2.18-rtems4.9-20080211.diff
GCCDIFF=gcc-core-4.3.2-rtems4.9-20080828.diff
NEWLIBDIFF=newlib-1.16.0-rtems4.9-20080827.diff
GDBDIFF=gdb-6.8-rtems4.9-20080917.diff
RTEMS_VERSION=4.9

#
# Where to install
#
PREFIX="${PREFIX:-/usr/local/rtems/rtems-${RTEMS_VERSION}}"

#
# Where to get the GNU tools
#
RTEMS_SOURCES_URL=ftp://www.rtems.com/pub/rtems/SOURCES/${RTEMS_VERSION}
RTEMS_BINUTILS_URL=${RTEMS_SOURCES_URL}/binutils-${BINUTILS}.tar.bz2
RTEMS_GCC_CORE_URL=${RTEMS_SOURCES_URL}/gcc-core-${GCC}.tar.bz2
RTEMS_GCC_GPP_URL=${RTEMS_SOURCES_URL}/gcc-g++-${GCC}.tar.bz2
RTEMS_NEWLIB_URL=${RTEMS_SOURCES_URL}/newlib-${NEWLIB}.tar.gz
RTEMS_GDB_URL=${RTEMS_SOURCES_URL}/gdb-${GDB}.tar.bz2
RTEMS_BINUTILS_DIFF_URL=${RTEMS_SOURCES_URL}/${BINUTILSDIFF}
RTEMS_GCC_DIFF_URL=${RTEMS_SOURCES_URL}/${GCCDIFF}
RTEMS_NEWLIB_DIFF_URL=${RTEMS_SOURCES_URL}/${NEWLIBDIFF}
RTEMS_GDB_DIFF_URL=${RTEMS_SOURCES_URL}/${GDBDIFF}

#
# Uncomment one of the following depending upon which your system provides
#
GET_COMMAND="curl --remote-name"
#GET_COMMAND="wget --passive-ftp --no-directories --retr-symlinks "
#GET_COMMAND="wget --no-directories --retr-symlinks "

#
# Solaris likely needs gmake and /bin/bash here.
#
MAKE="${MAKE:-make}"
export MAKE
SHELL=/bin/sh
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
    ${GET_COMMAND} "${RTEMS_GCC_CORE_URL}"
    ${GET_COMMAND} "${RTEMS_GCC_GPP_URL}"
    if [ -n "$GCCDIFF" ]
    then
        ${GET_COMMAND} "${RTEMS_GCC_DIFF_URL}"
    fi
     ${GET_COMMAND} "${RTEMS_NEWLIB_URL}"
    if [ -n "$NEWLIBDIFF" ]
    then
        ${GET_COMMAND} "${RTEMS_NEWLIB_DIFF_URL}"
    fi
     ${GET_COMMAND} "${RTEMS_GDB_URL}"
    if [ -n "$GDBDIFF" ]
    then
        ${GET_COMMAND} "${RTEMS_GDB_DIFF_URL}"
    fi
}

#
# Unpack the source
#
unpackSource() {
    rm -rf "binutils-${BINUTILS}"
    bzcat "binutils-${BINUTILS}.tar.bz2" | tar xf -
    for d in "binutils-${BINUTILS}"*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "binutils-${BINUTILS}" ; patch -p1)
        fi
    done

    rm -rf "gcc-${GCC}"
    bzcat "gcc-core-${GCC}.tar.bz2" | tar xf -
    bzcat "gcc-g++-${GCC}.tar.bz2" | tar xf -
    for d in gcc*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "gcc-${GCC}" ; patch -p1)
        fi
    done

    rm -rf "newlib-${NEWLIB}"
    zcat <"newlib-${NEWLIB}.tar.gz" | tar xf -
    for d in "newlib-${NEWLIB}"*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "newlib-${NEWLIB}" ; patch -p1)
        fi
    done
    (cd "gcc-${GCC}" ; ln -s "../newlib-${NEWLIB}/newlib" newlib)

    rm -rf "gdb-${GDB}"
    bzcat <"gdb-${GDB}.tar.bz2" | tar xf -
    for d in "gdb-${GDB}"*.diff
    do
        if [ -r "$d" ]
        then
            cat "$d" | (cd "gdb-${GDB}" ; patch -p1)
        fi
    done
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
        "${SHELL}" "../binutils-${BINUTILS}/configure" \
            "--target=${arch}-rtems${RTEMS_VERSION}" "--prefix=${PREFIX}" \
            --verbose --disable-nls \
            --without-included-gettext \
            --disable-win32-registry \
            --disable-werror 
        ${MAKE} -w all install
        cd ..

        rm -rf build
        mkdir build
        cd build
       "${SHELL}" "../gcc-${GCC}/configure" \
            "--target=${arch}-rtems${RTEMS_VERSION}" "--prefix=${PREFIX}" \
            --disable-libstdcxx-pch \
            --with-gnu-as --with-gnu-ld --verbose \
            --with-newlib \
            --with-system-zlib \
            --disable-nls --without-included-gettext \
            --disable-win32-registry \
            --enable-version-specific-runtime-libs \
            --enable-threads \
            --enable-newlib-io-c99-formats \
            --enable-languages="c,c++" \
            --with-gmp="${PREFIX}" --with-mpfr="${PREFIX}"
        ${MAKE} -w all
        ${MAKE} -w install
        cd ..

        rm -rf build
        mkdir build
        cd build
       "${SHELL}" "../gdb-${GDB}/configure" \
            "--target=${arch}-rtems${RTEMS_VERSION}" "--prefix=${PREFIX}" \
            --verbose --disable-nls --without-included-gettext \
            --disable-win32-registry \
            --enable-version-specific-runtime-libs \
            --disable-win32-registry \
            --disable-werror \
            --enable-sim \
            --with-expat
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
export LD_LIBRARY_PATH="${PREFIX}/lib"
build
