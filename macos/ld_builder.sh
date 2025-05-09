source $setup

tar -xf $src
mv cctools-port-* cctools-port

cd cctools-port

for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done

# Similar to but not the same as the other _structs.h.
rm cctools/include/foreign/mach/i386/_structs.h

cd ..

mv cctools-port/cctools/ld64 ld64
mv cctools-port/cctools/include include
rm -r cctools-port
rm -r ld64/src/other

mkdir build
cd build

CFLAGS="-Wno-format -Wno-deprecated -Wno-deprecated-declarations -Wno-unused-result"
CFLAGS+=" -Wfatal-errors -O2 -g -fblocks"
CFLAGS+=" -I../include -I../include/foreign"
CFLAGS+=" -I../ld64/src/{,ld,ld/parsers,abstraction,3rd,3rd/include,mach_o}"
CFLAGS+=" $(pkg-config --cflags libtapi libdispatch) -DTAPI_SUPPORT"
CFLAGS+=" -DPROGRAM_PREFIX=\\\"$host-\\\""
CFLAGS+=" -DHAVE_BCMP -DHAVE_BZERO -DHAVE_BCOPY -DHAVE_INDEX -DHAVE_RINDEX -D__LITTLE_ENDIAN__"

CXXFLAGS="-std=gnu++20 $CFLAGS"

LDFLAGS="$(pkg-config --libs libtapi libdispatch) -ldl -lpthread"

for f in ../ld64/src/ld/*.c ../ld64/src/3rd/*.c ; do
  echo "compiling $f"
  eval "clang -c $CFLAGS $f -o $(basename $f).o"
done

for f in $(find ../ld64/src -name \*.cpp); do
  echo "compiling $f"
  eval "clang++ -c $CXXFLAGS $f -o $(basename $f).o"
done

clang++ *.o $LDFLAGS -o $host-ld

mkdir -p $out/bin
cp $host-ld $out/bin
