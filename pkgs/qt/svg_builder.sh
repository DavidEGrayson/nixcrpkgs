source $setup

tar -xf $src
mv qtsvg-* qtsvg

mkdir build
cd build

qmake ../qtsvg/qtsvg.pro
make
make install INSTALL_ROOT=$PWD/root
ls root
mkdir $out
mv root$qtbase_raw/* $out
