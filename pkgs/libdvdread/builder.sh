source $setup

tar -xf $src
mv libdvdread-* libdvdread
cd libdvdread
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
mv msvc xxx
mv xxx/msvc .
rmdir xxx
cd ..

mkdir build
cd build

CFLAGS="-D__USE_MINGW_ANSI_STDIO=1 -Wno-unused-variable -Wno-unused-parameter" \
../libdvdread/configure --host=$host --prefix=$out \
  --disable-shared --enable-static

make

make install
