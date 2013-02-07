# Process this file with autoconf to produce a configure script

# Copyright 2009, 2013 Michael L Gran

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
AC_PREREQ(2.61)
AC_INIT([guile_aspell],[0.1],[spk121@yahoo.com])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([gnu std-options -Wall])
AC_CONFIG_SRCDIR([config.h.in])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

##################
# Set some version constants
LIBGUILE_ASPELL_INTERFACE="1:0:0"
AC_SUBST(LIBGUILE_ASPELL_INTERFACE)

##################
# Check for Programs

AC_PROG_CC
gl_EARLY

AC_CANONICAL_HOST
AC_PROG_INSTALL

# AC_PROG_MKDIR_P is the current version of the macro
# AM_PROG_MKDIR_P is deprecated
AM_PROG_MKDIR_P

AM_PROG_CC_C_O

##################
# Check for Libtool

# New method for when Libtool 2.x is default
LT_INIT([dlopen disable-fast-install])

#################
# Gnulib stuff
gl_INIT
AC_CONFIG_COMMANDS_PRE([m4_ifdef([AH_HEADER],
  [AC_SUBST([CONFIG_INCLUDE], m4_defn([AH_HEADER]))])])

##################
# Initial guess of platform specific options
case $host in
*-*-cygwin)
        [force_tex_to_tex=yes] ;;
*)
        [force_tex_to_tex=no] ;;
esac

AM_CONDITIONAL([FORCE_TEX_TO_TEX], [test "$force_tex_to_tex" = yes])

##################
# Check for libraries

GUILE_FLAGS
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

AC_ARG_WITH([guileextensiondir],
  [use the specified installation path for Guile binary shared libraries],
  [case "x$withval" in
    xyes|xno) guileextensiondir="";;
    *)        guileextensiondir="$withval";;
   esac],
  [guileextensiondir=""])

if test "x$guileextensiondir" = "x"; then
  guileextensiondir="$libdir"
fi
AC_SUBST([guileextensiondir])

GUILE_EXTENSION_DIR=`pkg-config guile-2.0 --variable=extensiondir`
if test "x$GUILE_EXTENSION_DIR" = "x"; then
GUILE_EXTENSION_DIR=`guile-config info libdir`
fi
AC_SUBST([GUILE_EXTENSION_DIR])

AC_CHECK_LIB([aspell],
             [new_aspell_config], ,
             # if aspell is not ok
             [AC_MSG_ERROR([libaspell not found])])

AC_ARG_ENABLE([warnings],
              [AS_HELP_STRING([--enable-warnings],
                              [Build with most GCC warnings enabled])])
AM_CONDITIONAL([WARN], [test "$enable_warnings" = yes])

##################
# Check for header files
AC_CHECK_HEADERS([aspell.h])

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

if test "x$GUILE_EXTENSION_DIR" != "x"; then
if test "$guileextensiondir" != "$GUILE_EXTENSION_DIR"; then
   AC_MSG_WARN([]
   [The Guile extensions will be installed in ${guileextensiondir}.]
   [You should consider re-running `configure' with]
   [`--with-guileextensiondir=$GUILE_EXTENSION_DIR'])
fi
fi
