source $stdenv/setup

tar -xf $src
mv *libdispatch* src

mkdir build
cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=$out
make
make install

cd $out
mv lib64 lib
mkdir -p lib/pkgconfig
cat <<END > lib/pkgconfig/libdispatch.pc
prefix=$out
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libdispatch
Version: $version
Libs: -L\${libdir} -ldispatch -lBlocksRuntime
Cflags: -I\${includedir}
END
