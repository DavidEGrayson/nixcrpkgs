source $setup

tar -xf $src
mv cmake-* cmake

mkdir build
cd build

../cmake/configure --prefix=$out

make

make install
