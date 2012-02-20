# configure.in for CilTutorial           -*- sh -*-
AC_INIT(src/main.ml)
AC_PREREQ(2.50)

AC_PROG_CC
AC_PROG_INSTALL

AC_CANONICAL_SYSTEM

CILTUTHOME=`pwd`
DEFAULT_CIL_MODE=GNUCC
CILTUT_VERSION=1.0

OCAMLINC=/usr/lib/ocaml

# make sure I haven't forgotten to run autoconf
if test configure -ot configure.ac; then
  AC_MSG_ERROR(configure is older than configure.ac; you forgot to run autoconf)
fi

ECC=$CC
AC_SUBST(ECC)

case "$target" in
  # Linux
  *86*linux*|*86*openbsd*)
    AC_MSG_RESULT(configuring for $target)
    ARCHOS=x86_LINUX
    ;;

  # FreeBSD
  *i386*freebsd*|*amd64*freebsd*)
    if test x"${ARCH}" = x""; then
       ARCH=`uname -p`
    fi

    AC_MSG_RESULT(configuring for $target)
    ARCHOS=${ARCH}_FREEBSD
    ;;

  # Mac OS X
  *86*darwin*)
    AC_MSG_RESULT(configuring for $target)
    ARCHOS=x86_DARWIN
    ;;

  # Cygwin
  *86*cygwin*)
    AC_MSG_RESULT(configuring for $target)
    ARCHOS=x86_WIN32

    # override CILTUTHOME; even on cygwin we want forward slashes
    # sm: I folded this into what I hope will be the only
    # case-analysis of machine type
    # CILTUTHOME=`cygpath -wa "$CILTUTHOME"  | sed -e "s/\\\\\/\\//g"`
    # Try to use the Unix paths even on cygwin. The newest versions of make
    #  do not like colons in file names
    CILTUTHOME=`cygpath -u "$CILTUTHOME"`
    CC=`which $CC`
    CC=`cygpath -wa "$CC"  | sed -e "s/\\\\\/\\//g"`
    ;;

  *)
    AC_MSG_ERROR([
      Unsupported platform $target -- sorry.
      ./configure supports these platforms:
         on x86:     Linux, Cygwin, FreeBSD, OpenBSD, Darwin
    ])
    ;;
esac

AC_PROG_OCAML
if test "$OCAMLC" = "no"; then
  AC_MSG_ERROR([You must install the OCaml compiler])
fi

AC_PROG_FINDLIB
if test "$OCAMLFIND" = "no"; then
  AC_MSG_ERROR([You must install OCaml findlib (the ocamlfind command)])
fi

AC_CHECK_OCAML_PKG([cil])
if test "$OCAML_PKG_cil" = "no"; then
  AC_MSG_ERROR([Please install OCaml findlib module 'cil'.])
fi

AC_CHECK_OCAML_PKG([ocamlgraph])
if test "$OCAML_PKG_ocamlgraph" = "no"; then
  AC_MSG_ERROR([Please install OCaml findlib module 'ocamlgraph'.])
fi

AC_CHECK_FILE(obj/$ARCHOS,, AC_MSG_RESULT(creating obj/$ARCHOS);
                            mkdir -p obj/$ARCHOS)


# Check for Why3 to see if we should build tut11
#
#
BUILD_TUT11="false"
AC_ARG_ENABLE([tut11],
              AS_HELP_STRING([--disable-tut11], [Do not build tut11]),
              [ac_build_tut11=$enableval], [ac_build_tut11=yes])

if test "x$ac_build_tut11" = "xno"; then
  HAVE_WHY3=false
else
  AC_CHECK_PROG(HAVE_WHY3, why3, true, false)

  if test "x$HAVE_WHY3" = "xfalse" -a "x$ac_build_tut11" = "xyes"; then
    AC_MSG_ERROR([*** Couldn't find Why3 installation. Use --disable-tut11, or install Why3])
  fi

  BUILD_TUT11="true"
fi
if test $BUILD_TUT11 = "false"; then
  AC_MSG_WARN([Why3 not found. Tut11 won't be built])
fi

AC_SUBST(ARCHOS)
AC_SUBST(CILTUTHOME)
AC_SUBST(DEFAULT_CIL_MODE)
AC_SUBST(CILTUT_VERSION)
AC_SUBST(OCAMLINC)
AC_SUBST(BUILD_TUT11)

# finish the configure script and generate various files; ./configure
# will apply variable substitutions to <filename>.in to generate <filename>;
# I find it useful to mark generated files as read-only so I don't
# accidentally edit them (and them lose my changes when ./configure
# runs again); I had originally done the chmod after AC_OUTPUT, but
# the problem is then the chmod doesn't run inside ./config.status

# MY_AC_CONFIG_FILES(filename)
# do AC_CONFIG_FILES(filename, chmod a-w filename)
define([MY_AC_CONFIG_FILES],
[{
  if test -f [$1].in; then
    AC_CONFIG_FILES([$1], chmod a-w [$1])
  else
    true
    #echo "skipping [$1] because it's not in this distribution"
  fi
}])
define([MY_AC_CONFIG_EXE_FILES],
[{
  if test -f [$1].in; then
    AC_CONFIG_FILES([$1], [chmod a-w,a+x $1])
  else
    true
    #echo "skipping [$1] because it's not in this distribution"
  fi
}])

MY_AC_CONFIG_FILES(Makefile)
MY_AC_CONFIG_FILES(ciltut-lib/Makefile.dummy)

AC_OUTPUT()

cat <<EOF

Ciltut configuration:
  System:                        $ARCHOS
  Ciltut home:                   $CILTUTHOME
  Ciltut version:                $CILTUT_VERSION
  Build Tutorial 11              $BUILD_TUT11
EOF
