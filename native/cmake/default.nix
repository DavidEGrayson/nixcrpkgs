{ native }:

native.make_derivation rec {
  name = "cmake";
  version = "3.10.0-rc3";
  src = native.nixpkgs.fetchurl {
    url = "https://cmake.org/files/v3.10/cmake-${version}.tar.gz";
    sha256 = "050bv1bina3rb5p5gj2lfnikq1m2r4ipr385akrd50d38nk32m0m";
  };
  builder = ./builder.sh;
}
