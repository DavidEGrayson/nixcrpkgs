{ crossenv }:
let
  nixpkgs = crossenv.nixpkgs;
  target = "riscv64-none-elf";
in
crossenv.make_derivation rec {
  name = "${target}-binutils-${version}";

  version = "2.41";

  src = nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-rppXieI0WeWWBuZxRyPy0//DHAMXQZHvDQFb3wYAdFA=";
  };

  patches = [
    ./deterministic.patch
  ];

  native_inputs = [ nixpkgs.texinfo nixpkgs.bison nixpkgs.m4 ];

  configure_flags =
    "--host=${crossenv.host} " +
    "--target=${target} " +
    "--disable-shared " +   # NOTE: This is bad, the executables are each 6 to 9MB
    "--enable-deterministic-archives " +
    "--disable-werror ";

  builder = ./builder.sh;
}

