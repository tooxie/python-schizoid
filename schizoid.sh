#!/bin/bash

# Schizoid. Creates an isolated python environment.
#
# Copyright (C) 2010 Alvaro Mouriño <alvaro@mourino.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# virtualenv
export VENV=~/venv # Virtual environment directory
export PYV='2.7' # Python version
export STV='0.6c11' # Setuptools version
export PIPV='0.8.2' # PIP version
export GTV='0.18.1.1' # Gettext version
export PROF="`dirname $0`/profile.txt" # Profiling file

# functions
# http://wuhrr.wordpress.com/2010/01/13/adding-confirmation-to-bash/
function confirm() {
    echo "$@"
    echo -n "[y/N] "
    read -e answer
    for response in y Y yes YES Yes
    do
        if [ "_$answer" == "_$response" ]; then
            return 0
        fi
    done

    # Any answer other than the list above is considerred a "no" answer
    return 1
}

function assert() {
    $@
    ERR=$?
    if [ $ERR -ne 0 ]; then
        echo "Assertion error, quitting."
        exit $ERR
    fi
    return 0
}

# main
if [ -a $VENV ]; then
    confirm "$VENV exists. Do you want to remove it?"
    if [ $? -eq 0 ]; then
        confirm " *** Are you really sure? ***"
        if [ $? -eq 0 ]; then
            echo -n "** Removing... "
            assert rm -Rf "$VENV"
            echo "[ OK ]"
            echo -n "** Creating $VENV... "
            assert mkdir -p "$VENV"
            echo "[ OK ]"
        else
            echo "** Aborting..."
            exit 1
        fi
    else
        echo "** Aborting..."
        exit 1
    fi
else
    echo -n "** Creating $VENV... "
    assert mkdir -p "$VENV"
    echo "[ OK ]"
fi
echo ""

echo  "--- START ---" >> $PROF
echo `date` >> $PROF

echo "** Creating virtual environment..."
assert virtualenv --no-site-packages $VENV
assert mkdir -p $VENV/src
echo ""

echo -n "** Activating environment... "
source $VENV/bin/activate
echo "[ OK ]"

# dependencies
echo "** Installing dependencies..."
BIN=`which yum 2>/dev/null`
if [ $? -eq 0 ]; then
    yum -y --skip-broken install \
        autoconf automake automake14 automake15 automake16 automake17 binutils \
        bison bluez-libs-devel byacc bzip2-devel crash cscope ctags cvs db4-devel \
        dev86 diffstat dogtail doxygen elfutils flex gcc gcc-c++ gcc-gfortran gdb \
        gdbm-devel gettext graphviz-devel imake indent libjpeg-devel libtool \
        ltrace make mysql-devel ncurses-devel nss_db openssl-devel oprofile \
        patchutils pkgconfig pstack python-ldap rcs readline-devel \
        redhat-rpm-config rpm-build splint sqlite-devel strace subversion swig \
        systemtap texinfo tk-devel valgrind zlib-devel
else
    BIN=`which apt-get 2>/dev/null`
    #TODO: Install dependencies for debian systems.
fi
echo ""

# python
cd $VENV/src
if [ ! -f "$VENV/src/Python-$PYV.tgz" ]; then
    echo "** Downloading python..."
    assert wget "http://www.python.org/ftp/python/$PYV/Python-$PYV.tgz"
    echo ""
fi
if [ -f "$VENV/src/Python-$PYV" ]; then
    assert rm -Rf "$VENV/src/Python-$PYV"
fi
assert tar xzf "Python-$PYV.tgz"
cd "$VENV/src/Python-$PYV"
make clean
echo "** Configuring python..."
assert ./configure --prefix=$VENV --oldincludedir=$VENV/include \
    --datarootdir=$VENV/share --disable-ipv6 --enable-unicode
echo ""
echo "** Compiling python..."
assert make
echo ""
echo "** Installing python..."
assert make install
echo ""

# setuptools
cd $VENV/src
if [ ! -f "$VENV/src/setuptools-$STV.tar.gz" ]; then
    echo "** Downloading setuptools..."
    assert wget "http://pypi.python.org/packages/source/s/setuptools/setuptools-$STV.tar.gz"
    echo ""
fi
if [ -f "$VENV/src/setuptools-$STV" ]; then
    assert rm -Rf "$VENV/src/setuptools-$STV"
fi
assert tar xzf "$VENV/src/setuptools-$STV.tar.gz"
cd $VENV/src/setuptools-$STV
echo "** Compiling setuptools..."
assert $VENV/bin/python$PYV $VENV/src/setuptools-$STV/setup.py build
echo ""
echo "** Installing setuptools..."
$VENV/bin/python$PYV $VENV/src/setuptools-$STV/setup.py install
echo ""

# pip
cd $VENV/src
if [ ! -f "$VENV/src/pip-$PIPV.tar.gz" ]; then
    echo "** Downloading pip..."
    assert wget "http://pypi.python.org/packages/source/p/pip/pip-$PIPV.tar.gz"
    echo ""
fi
if [ -f "$VENV/src/pip-$STV" ]; then
    assert rm -Rf "$VENV/src/pip-$STV"
fi
assert tar xzf "pip-$PIPV.tar.gz"
cd "$VENV/src/pip-$PIPV"
echo "** Compiling pip..."
assert $VENV/bin/python$PYV setup.py build
echo ""
echo "** Installing pip..."
assert $VENV/bin/python$PYV setup.py install
echo ""

# gettext
cd $VENV/src
if [ ! -f "$VENV/src/gettext-$GTV.tar.gz" ]; then
    echo "** Downloading GNU gettext..."
    assert wget "http://ftp.gnu.org/pub/gnu/gettext/gettext-$GTV.tar.gz"
    echo ""
fi
if [ -f "$VENV/src/gettext-$GTV" ]; then
    assert rm -Rf "$VENV/src/gettext-$GTV"
fi
assert tar xzf "gettext-$GTV.tar.gz"
cd "$VENV/src/gettext-$GTV"
make clean
echo "** Configuring GNU gettext..."
assert ./configure --prefix=$VENV --oldincludedir=$VENV/include --datarootdir=$VENV/share
echo ""
echo "** Compiling GNU gettext..."
assert make
echo ""
echo "** Installing GNU gettext..."
assert make install
echo ""

# PIP Installs Packages

echo "** Installing pep8..."
assert $VENV/bin/pip install pep8
echo ""

echo "** Installing ipdb and ipython..."
assert $VENV/bin/pip install ipdb
echo ""

echo "** Installing mysql python driver..."
assert $VENV/bin/pip install mysql-python
echo ""

echo "** Installing pygraphviz..."
assert $VENV/bin/pip install pygraphviz
echo ""

echo "** Installing django..."
if [ -a $VENV/src/django-trunk ]; then
    rm -Rf $VENV/src/django-trunk
fi
cd $VENV/src
# assert svn checkout http://code.djangoproject.com/svn/django/branches/releases/1.3.X/django
assert svn checkout http://code.djangoproject.com/svn/django/trunk/django
# assert svn export django $VENV/lib/python$PYV/site-packages/django
assert ln -s ../../../src/django $VENV/lib/python$PYV/site-packages/django
assert ln -s ../lib/python$PYV/site-packages/django/bin/django-admin.py $VENV/bin/django-admin.py
echo ""

echo -n "** Cleaning up a little... "
cd $VENV
assert rm -Rf "$VENV/src/Python-$PYV"
assert rm -Rf "$VENV/src/setuptools-$STV"
assert rm -Rf "$VENV/src/pip-$PIPV"
assert rm -Rf "$VENV/src/gettext-$GTV"
echo "[ OK ]"

echo `date` >> $PROF
echo "--- END ---" >> $PROF

echo "Done! =)"
# :wq
