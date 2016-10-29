# Copyright 2009, 2013, 2016 Michael L Gran

# This file is part of guile-aspell.

# guile-aspell is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# guile-aspell is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with guile-aspell.  If not, see <http://www.gnu.org/licenses/>.


## Process this file with automake to produce Makefile.in
ACLOCAL_AMFLAGS = -I m4

### FLAGS ###

### MAIN TARGETS ###

dist_guilesite_DATA = \
	aspell/aspell.scm

### SOURCES ###

### LINKER ###

### OTHER RULES ###

# Gnulib
distclean-local: clean-GNUmakefile
clean-GNUmakefile:
	test '$(srcdir)' = . || rm -f $(top_builddir)/GNUmakefile

### CHECK ###

# TESTLIB = \
#	test/lib.scm \
#	test/lib2.scm

# TESTS_ENVIRONMENT = GUILE_AUTO_COMPILE=0 \
#	guile -L $(abs_top_srcdir) -s

# TESTS = \
#	test/aspell_test.test

### DOCUMENTATION ###

# Cygwin's texi2dvi can try to call etex, resulting in this error:
#   "texinfo.tex appears to be broken, quitting"
# The problem lies in Cygwin's etex.fmt file
# Forcing TEX to tex works around this problem
# This should not harm other platforms

#if FORCE_TEX_TO_TEX
#TEX=tex
#TEXI2DVI= TEX=${TEX} texi2dvi
#endif

info_TEXINFOS = \
	doc/guile-aspell.texi

SUBDIRS = lib

### DISTRIBUTION ###

EXTRA_DIST = \
	AUTHORS \
	INSTALL \
	NEWS \
	README \
	COPYING \
	ChangeLog \
	m4/gnulib-cache.m4 \
	doc/fdl-1.3.texi \
	build-aux/texinfo.tex \
	cfg.mk

### INSTALLATION ###
