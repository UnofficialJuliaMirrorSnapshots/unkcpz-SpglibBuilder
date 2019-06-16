# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "SpglibBuilder"
version = v"1.12.2"

# Collection of sources required to build SpglibBuilder
sources = [
    "https://github.com/atztogo/spglib/archive/v1.12.2.tar.gz" =>
    "d92f5e4fa0f54cc0abd0209b81c4d5c647dae9d25b774c2296f44b8558b17976",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd spglib-1.12.2/
if [[ ${target} == *-mingw32 ]]; then
    sed -i -e 's/LIBRARY/RUNTIME/' CMakeLists.txt
fi
mkdir _build
cd _build/
cmake -DCMAKE_INSTALL_PREFIX=$prefix \
      -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain \
      ../
make
make install VERBOSE=1
"""


# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Windows(:i686),
    Windows(:x86_64),
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libsymspg", :libsymspg)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
