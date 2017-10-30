source $setup

export PATH=/home/david/cmake_destdir/bin:$PATH
echo -n using cmake:
which cmake

tar -xf $src
mv p-load-* p-load

ls $cml
mv $cml p-load/CMakeLists.txt

mkdir build
cd build

cmake-cross ../p-load \
  -DCMAKE_INSTALL_PREFIX=$out

make VERBOSE=Y

make install
