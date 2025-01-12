source $stdenv/setup

unset CC CXX CFLAGS LDFLAGS LD AR AS RANLIB SIZE STRINGS NM STRIP OBJCOPY

tar -xf $src
mv binutils-* src

cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done

# Clear the default library search path (noSysDirs)
echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt

# Make it possible to build from the binutils-gdb git repo, with tarball
# generated by:  git archive --format=tgz --prefix=binutils-/ > binutils.tar.gz
rm -rf contrib gdb* gnulib libbacktrace libdecnumber multilib.am readline sim gas/doc/.dirstamp

cd ..

mkdir build
cd build

../src/configure --prefix=$out $configure_flags
make
make install

