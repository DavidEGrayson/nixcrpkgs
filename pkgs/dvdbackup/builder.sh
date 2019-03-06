source $setup

tar -xf $src

mv dvdbackup-* dvdbackup

mkdir build
cd build
../dvdbackup/configure --host=$host  --prefix=$out

# TODO
