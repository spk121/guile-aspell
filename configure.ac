# Process this file with autoconf to produce a configure script

# Copyright 2009, 2013, 2016, 2017, 2021 Michael L Gran

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

##################
# Package info
AC_PREREQ([2.64])
AC_INIT([guile_aspell],[0.4],[spk121@yahoo.com])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([gnu std-options -Wall])
AC_CONFIG_SRCDIR([aspell.scm])
AC_CONFIG_MACRO_DIR([m4])

##################
# Check for Programs

gl_EARLY

AC_PROG_INSTALL

AC_PROG_MKDIR_P

#################
# Gnulib stuff
gl_INIT

# AC_CONFIG_COMMANDS_PRE([m4_ifdef([AH_HEADER],
#  [AC_SUBST([CONFIG_INCLUDE], m4_defn([AH_HEADER]))])])

##################
# Check for libraries

GUILE_PKG([2.2 2.0])
GUILE_PROGS
GUILE_SITE_DIR

AC_ARG_WITH([guilesitedir],
  [use the specified installation path for Guile scheme modules],
  [case "x$withval" in
    xyes|xno) guilesitedir="";;
    *)        guilesitedir="$withval";;
   esac],
  [guilesitedir=""])

pkgdatadir="$datadir/$PACKAGE_NAME"
if test "x$guilesitedir" = "x"; then
  guilesitedir="$pkgdatadir"
fi
AC_SUBST([guilesitedir])

# PKG_CHECK_MODULES(ASPELL, aspell)
# AC_SUBST(ASPELL_CFLAGS)
# AC_SUBST(ASPELL_LIBS)

# On success, this should append -laspell to LIBS and define
# HAVE_LIBASPELL.
AC_CHECK_LIB([aspell],
             [new_aspell_config], ,
             # if aspell is not ok
             [AC_MSG_ERROR([libaspell not found])])

##################
# Check for header files

##################
# Check for types, structures, compiler characteristics

##################
# Check for C library functions

##################
# Check for system services

##################
#  Output
AC_CONFIG_FILES([Makefile lib/Makefile])

AC_OUTPUT

if test "$guilesitedir" != "$GUILE_SITE"; then
   # Guile has a different prefix than this module
   AC_MSG_WARN([]
   [The Guile modules will be installed in ${guilesitedir}.]
   [You should consider re-running `configure' with]
   [`--with-guilesitedir=$GUILE_SITE']
   [Otherwise, you will have to adjust the `GUILE_LOAD_PATH' environment]
   [variable.])
fi
