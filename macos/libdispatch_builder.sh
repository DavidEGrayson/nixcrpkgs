source $stdenv/setup

tar -xf $src
mv swift-corelibs-libdispatch* src

mkdir -p $out/include
cp -r src/os $out/include/
cp -r src/dispatch $out/include/
