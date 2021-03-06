========
Schizoid
========

Creates an isolated python environment with (almost) no dependencies with the
outer world.


Dependencies
============

*Schizoid* does its best effort to avoid communicating with the outer world,
but at some extent it needs resources to operate properly. There are two types
of dependencies:


Life dependencies
-----------------

These are the unavoidable dependencies you need in your system to run
*schizoid.sh* and create a virtual environment. It can be summarized to one:

* virtualenv

This package has its own dependencies, in debian boxes they are:

* python
* python-central (>= 0.6.6) (only in lenny)
* python-support (>= 0.90.0) (from squeeze on)
* python-pkg-resources
* python-setuptools


Avoidable dependencies
----------------------

Every package is downloaded, compiled and installed inside the virtual
environment, except for one: the database. It would be not-smart to compile
and install a database engine, so we rely on the system to provide us with such
service.

*Schizoid* installs the MySQLdb driver, but you can install a different one or
no driver at all.


Structure
=========

Suppose you install the virtual environment in ~/venv, then the resulting
directories structure would look like::

 ~/venv
     bin/
     include/
     lib/
         pkgconfig/
     lib64@ -> ~/venv/lib  (only in 64bits systems)
     share/
         alocal/
         doc/
         gettext/
         info/
         locale/
         man/
     src/
         django-1.3.X/


Software
========

By default *schizoid.sh* downloads, compiles (when required) and installs the
following software:

* Python 2.7
* mod_wsgi
* setuptools 0.6c11
* pip 0.8.2
* GNU gettext 0.18.1.1
* memcached
* pep8
* ipdb
* ipython
* mysql-python
* python-dateutil
* python-memcached
* soaplib
* suds
* pygraphviz (to use with django_extensions)
* django-admin-tools
* docutils
* django 1.3.X


Post-install
------------

When *Schizoid* finishes installing everything it looks for a file named
*post_install.sh* to execute user-defined actions. Remember that it must be an
**executable** file.

By default it doesn't exists, you have to create it with the proper
permissions.


TO-DO list
==========

* Install dependencies in debian systems. (Currently works only on yum-based
  boxes.)
* Allow for easy customization.
* Recognize partially installed environments and continue from checkpoint.

Right now works good for me, so I don't think I'm going to add any of these
features. If you want to do it I will gladly merge your improvements.

Happy hacking!

:wq
