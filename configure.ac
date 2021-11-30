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
AC_INIT([guile_aspell],[0.5.0],[spk121@yahoo.com])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([gnu -Wall])
AC_CONFIG_SRCDIR([aspell.scm])
AC_CONFIG_MACRO_DIR([m4])
AC_CANONICAL_HOST

##################
# Check for Programs

AC_PROG_INSTALL
AC_PROG_MKDIR_P

##################
# Check for libraries

GUILE_PKG([3.0 2.2 2.0])
GUILE_PROGS
GUILE_SITE_DIR

AC_ARG_WITH([guilesitedir],
  [use the specified installation path for Guile scheme modules],
  [case "x$withval" in
    xyes|xno) guilesitedir="";;
    *)        guilesitedir="$withval";;
   esac],
  [guilesitedir=""])

pkgdatadir="$datadir/guile/site/$GUILE_EFFECTIVE_VERSION"
if test "x$guilesitedir" = "x"; then
  guilesitedir="$pkgdatadir"
fi
AC_SUBST([guilesitedir])

AC_ARG_WITH([guilecachedir],
  [use the specified installation path for compiled Guile scheme modules],
  [case "x$withval" in
    xyes|xno) guilecachedir="";;
    *)        guilecachedir="$withval";;
   esac],
  [guilecachedir=""])

pkgcachedir="$libdir/guile/$GUILE_EFFECTIVE_VERSION/site-ccache"
if test "x$guilecachedir" = "x"; then
  guilecachedir="$pkgcachedir"
fi
AC_SUBST([guilecachedir])

AC_CHECK_LIB([aspell],
             [new_aspell_config], ,
             # if aspell is not ok
             [AC_MSG_ERROR([libaspell not found])])

##################
# Check for header files

##################
# Check for types, structures, compiler characteristics

if test "$cross_compiling" != no; then
   GUILE_TARGET="--target=$host_alias"
   AC_SUBST([GUILE_TARGET])
fi

##################
# Check for C library functions

##################
# Check for system services

##################
#  Output
AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([pre-inst-env], [chmod +x pre-inst-env])

AC_REQUIRE_AUX_FILE([test-driver.scm])

AC_OUTPUT
