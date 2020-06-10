{ crossenv }:

crossenv.make_derivation rec {
  name = "libdvdread-${version}";

  version = "6.0.2";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://download.videolan.org/pub/videolan/libdvdread/${version}/libdvdread-${version}.tar.bz2";
    sha256 = "1c7yqqn67m3y3n7nfrgrnzz034zjaw5caijbwbfrq89v46ph257r";
  };

  builder = ./builder.sh;
}
