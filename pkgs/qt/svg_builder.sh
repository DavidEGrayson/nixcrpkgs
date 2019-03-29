source $setup

tar -xf $src
mv qtsvg-* qtsvg

mkdir build
cd build

qmake ../qtsvg/qtsvg.pro QT_INSTALL_EXAMPLES=/foobar
make
make install INSTALL_ROOT=$PWD/root
ls root
mkdir $out
mv root$qtbase_raw/* $out
