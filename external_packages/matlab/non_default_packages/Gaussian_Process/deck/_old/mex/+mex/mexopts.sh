#
# mexopts.sh	Shell script for configuring MEX-file creation script,
#               mex.  These options were tested with the specified compiler.
#
# usage:        Do not call this file directly; it is sourced by the
#               mex shell script.  Modify only if you don't like the
#               defaults after running mex.  No spaces are allowed
#               around the '=' in the variable assignment.
#
# Note: For the version of system compiler supported with this release,
#       refer to the Supported and Compatible Compiler List at:
#       http://www.mathworks.com/support/compilers/current_release/
#
#
# SELECTION_TAGs occur in template option files and are used by MATLAB
# tools, such as mex and mbuild, to determine the purpose of the contents
# of an option file. These tags are only interpreted when preceded by '#'
# and followed by ':'.
#
#SELECTION_TAG_MEX_OPT: Template Options file for building MEX-files
#
# Copyright 1984-2011 The MathWorks, Inc.
# $Revision: 1.78.4.18 $  $Date: 2012/11/15 06:22:54 $
#----------------------------------------------------------------------------
#
TMW_ROOT="$MATLAB"
if [ "$ENTRYPOINT" = "mexLibrary" ]; then
    MLIBS="-L$TMW_ROOT/bin/$Arch -lmx -lmex -lmat -lmwservices -lut"
else
    MLIBS="-L$TMW_ROOT/bin/$Arch -lmx -lmex -lmat"
fi
case "$Arch" in
    Undetermined)
#----------------------------------------------------------------------------
# Change this line if you need to specify the location of the MATLAB
# root directory.  The script needs to know where to find utility
# routines so that it can determine the architecture; therefore, this
# assignment needs to be done while the architecture is still
# undetermined.
#----------------------------------------------------------------------------
        MATLAB="$MATLAB"
        ;;
    mac|maci|glnx86|sol64)
#----------------------------------------------------------------------------
        echo "Error: missing config for platform '$Arch'."; exit 1
#----------------------------------------------------------------------------
        ;;
    glnxa64_gcc|glnxa64)
#----------------------------------------------------------------------------
        RPATH="-Wl,-rpath-link,$TMW_ROOT/bin/$Arch"
        POSTLINK_CMDS=':'
#
        CC='gcc'
        CFLAGS='-ansi -D_GNU_SOURCE'
        CFLAGS="$CFLAGS -fexceptions -fPIC -fno-omit-frame-pointer -pthread"
        CLIBS="$RPATH $MLIBS -lm"
        COPTIMFLAGS='-O3 -DNDEBUG'
        CDEBUGFLAGS='-g'
#
        CXX='g++'
        CXXFLAGS='-ansi -D_GNU_SOURCE'
        CXXFLAGS="$CXXFLAGS -std=c++0x -fexceptions -fPIC -fno-omit-frame-pointer -pthread"
        CXXLIBS="$RPATH $MLIBS -lm"
        CXXOPTIMFLAGS='-O3 -DNDEBUG'
        CXXDEBUGFLAGS='-g'
#
        FC='gfortran'
        FFLAGS='-fexceptions -fbackslash -fPIC -fno-omit-frame-pointer'
        FLIBS="$RPATH $MLIBS -lm"
        FOPTIMFLAGS='-O'
        FDEBUGFLAGS='-g'
#
        LD="$COMPILER"
        LDEXTENSION='.mexa64'
        LDFLAGS="-pthread -shared -Wl,--version-script,$TMW_ROOT/extern/lib/$Arch/$MAPFILE -Wl,--no-undefined"
        LDOPTIMFLAGS='-O'
        LDDEBUGFLAGS='-g'
#----------------------------------------------------------------------------
        ;;
    glnxa64_clang)
#----------------------------------------------------------------------------
        RPATH="-Wl,-rpath-link,$TMW_ROOT/bin/$Arch"
        POSTLINK_CMDS=':'
#
        CC='clang'
        CFLAGS='-fno-common -fexceptions -fPIC -fno-omit-frame-pointer -pthread'
        CLIBS="$MLIBS -lstdc++"
        COPTIMFLAGS='-O3 -DNDEBUG'
        CDEBUGFLAGS='-g'
#
        CXX='clang++'
        CXXFLAGS='-std=c++0x -fno-common -fexceptions -fPIC -fno-omit-frame-pointer -pthread'
        CXXLIBS="$RPATH $MLIBS -lstdc++"
        CXXOPTIMFLAGS='-O3 -DNDEBUG'
        CXXDEBUGFLAGS='-g'
#
        FC='gfortran'
        FFLAGS='-fexceptions -fbackslash -fPIC -fno-omit-frame-pointer'
        FLIBS="$RPATH $MLIBS -lm"
        FOPTIMFLAGS='-O'
        FDEBUGFLAGS='-g'
#
        LD="$COMPILER"
        LDEXTENSION='.mexa64'
        LDFLAGS="-pthread -shared -Wl,--version-script,$TMW_ROOT/extern/lib/$Arch/$MAPFILE -Wl,--no-undefined"
        LDOPTIMFLAGS='-O'
        LDDEBUGFLAGS='-g'
#----------------------------------------------------------------------------
        ;;
    maci64_clang|maci64)
#----------------------------------------------------------------------------
        TARGET_OSX_VERSION='10.10'
        TARGET_ARCH='x86_64'
        POSTLINK_CMDS=':'
        MAC_FLAGS="-arch $TARGET_ARCH -mmacosx-version-min=$TARGET_OSX_VERSION"
#
        CC='clang'
        CFLAGS="-fno-common -fexceptions $MAC_FLAGS"
        CLIBS="$MLIBS -lstdc++"
        COPTIMFLAGS='-O3 -DNDEBUG'
        CDEBUGFLAGS='-g'
#
        CXX='clang++'
        CXXFLAGS="-std=c++0x -fno-common -fexceptions $MAC_FLAGS"
        CXXLIBS="$MLIBS -lstdc++"
        CXXOPTIMFLAGS='-O3 -DNDEBUG'
        CXXDEBUGFLAGS='-g'
#
        FC='gfortran'
        FFLAGS='-fexceptions -m64 -fbackslash'
        FC_LIBDIR1=`$FC -print-file-name=libgfortran.dylib 2>&1 | sed -n '1s/\/*libgfortran\.dylib//p'`
        FC_LIBDIR2=`$FC -print-file-name=libgfortranbegin.a 2>&1 | sed -n '1s/\/*libgfortranbegin\.a//p'`
        FLIBS="$MLIBS -L$FC_LIBDIR1 -lgfortran -L$FC_LIBDIR2 -lgfortranbegin"
        FOPTIMFLAGS='-O'
        FDEBUGFLAGS='-g'
#
        LD="$CC"
        LDEXTENSION='.mexmaci64'
        LDFLAGS="-Wl $MAC_FLAGS"
        LDFLAGS="$LDFLAGS -bundle -Wl,-exported_symbols_list,$TMW_ROOT/extern/lib/$Arch/$MAPFILE"
        LDOPTIMFLAGS='-O'
        LDDEBUGFLAGS='-g'
#----------------------------------------------------------------------------
        ;;
#     maci64_gcc) # doesn't work
# #----------------------------------------------------------------------------
#         TARGET_OSX_VERSION='10.10'
#         TARGET_ARCH='x86_64'
#         POSTLINK_CMDS=':'
#         MAC_FLAGS="-arch $TARGET_ARCH -mmacosx-version-min=$TARGET_OSX_VERSION -m64"
#         RPATH="-Wl,$TMW_ROOT/bin/$Arch"
# #
#         CC='gcc'
#         CFLAGS="-ansi -fexceptions $MAC_FLAGS"
#         CFLAGS="$CFLAGS -fPIC -fno-omit-frame-pointer -pthread"
#         CLIBS="$RPATH $MLIBS -lm"
#         COPTIMFLAGS='-O3 -DNDEBUG'
#         CDEBUGFLAGS='-g'
# #
#         CXX='g++'
#         CXXFLAGS="-ansi -fexceptions -std=c++0x $MAC_FLAGS"
#         CXXFLAGS="$CXXFLAGS -fPIC -fno-omit-frame-pointer -pthread"
#         CXXLIBS="$RPATH $MLIBS -lm"
#         CXXOPTIMFLAGS='-O3 -DNDEBUG'
#         CXXDEBUGFLAGS='-g'
# #
#         FC='gfortran'
#         FFLAGS='-fexceptions -fbackslash'
#         FFLAGS="$FFLAGS -fPIC -fno-omit-frame-pointer"
#         FLIBS="$RPATH $MLIBS -lm"
#         FOPTIMFLAGS='-O'
#         FDEBUGFLAGS='-g'
# #
#         LD="$CC"
#         LDEXTENSION='.mexmaci64'
#         LDFLAGS="$MAC_FLAGS -bundle -Wl,-syslibroot,$TMW_ROOT/extern/lib/$Arch/$MAPFILE"
#         LDOPTIMFLAGS='-O'
#         LDDEBUGFLAGS='-g'
# #----------------------------------------------------------------------------
#         ;;
esac
