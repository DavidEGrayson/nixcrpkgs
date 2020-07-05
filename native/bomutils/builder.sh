source $setup

cp -r $src ./src
chmod u+rw -R ./src

cd src
make

make install DESTDIR=$out PREFIX=/
