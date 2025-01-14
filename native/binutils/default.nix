{ env, host }:
let
  nixpkgs = env.nixpkgs;
in
env.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.43";
  src = env.nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-tTYG9EOsjwHR1fycOUl/KvMi2Z4UzqXAtLEk1jA3k2U=";
  };

  patches = [
    ./deterministic.patch

    # The Raspberry Pi 5 kernel uses 16 KiB pages.  Without this patch, 32-bit
    # executables fail at startup time on RPi5 with a segmentation fault.
    ./arm_page_size.patch
  ];

  native_inputs = [ nixpkgs.bison nixpkgs.flex nixpkgs.m4 nixpkgs.texinfo ];

  configure_flags =
    "--target=${host} " +
    "--enable-shared " +
    "--enable-deterministic-archives " +
    "--disable-werror ";

  builder = ./builder.sh;
}
