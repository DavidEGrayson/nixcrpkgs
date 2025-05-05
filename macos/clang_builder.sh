source $setup

tar -xf $llvm_third_party_src
mv third-party* third-party

tar -xf $llvm_cmake_src
mv cmake-* cmake

tar -xf $llvm_src
mv llvm-* llvm

tar -xf $clang_src
mv clang-* clang
cd clang
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..
mv clang llvm/projects/

mkdir build
cd build

cmake ../llvm -GNinja -DDEFAULT_SYSROOT=$out -DCMAKE_INSTALL_PREFIX=$out $cmake_flags

# We use -j options below so we can avoid running out of RAM on
# systems with several cores and little RAM.

ninja -j2

ninja -j1 install
