# Copyright 2009, 2013, 2016, 2021 Michael L Gran

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

### SOURCES ###

SOURCES = \
	aspell.scm

GOBJECTS = $(SOURCES:%.scm=%.go)

guilesite_DATA = $(SOURCES)
guilecache_DATA = $(GOBJECTS)
CLEANFILES = $(GOBJECTS)
GUILE_WARNINGS =                                          \
  -Wunbound-variable -Warity-mismatch -Wshadowed-toplevel \
  -Wmacro-use-before-definition                           \
  -Wunused-variable                                       \
  -Wduplicate-case-datum -Wbad-case-datum                 \
  -Wformat

SUFFIXES = .scm .go
.scm.go:
	$(top_builddir)/pre-inst-env $(GUILE_TOOLS) compile $(GUILE_TARGET) $(GUILE_WARNINGS) -o "$@" "$<"


### LINKER ###

### OTHER RULES ###

### CHECK ###

TESTS = \
	tests/spell.scm

TEST_EXTENSIONS = .scm

SCM_LOG_DRIVER = \
  $(top_builddir)/pre-inst-env \
  $(GUILE) --no-auto-compile \
      $(top_srcdir)/build-aux/test-driver.scm

# AM_SCM_LOG_FLAGS = --no-auto-compile -L "$(top_srcdir)"

test: check

### DOCUMENTATION ###

info_TEXINFOS = \
	doc/guile-aspell.texi

### DISTRIBUTION ###

EXTRA_DIST = \
	AUTHORS \
	INSTALL \
	NEWS \
	README \
	COPYING \
	ChangeLog \
	pre-inst-env.in \
	$(SOURCES) \
	doc/fdl-1.3.texi \
	build-aux/texinfo.tex \
	build-aux/config.guess \
	build-aux/config.sub \
	build-aux/test-driver.scm \
	$(TESTS)

### INSTALLATION ###
