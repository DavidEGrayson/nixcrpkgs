source $setup

tar -xf $src

mv dvdbackup-* dvdbackup

cd dvdbackup
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..


mkdir build
cd build

export CFLAGS="$(pkg-config-cross --cflags dvdread) -Wno-unused-value -Wno-unused-parameter"
export LDFLAGS="$(pkg-config-cross --libs dvdread)"
../dvdbackup/configure --host=$host --prefix=$out

make

make install
