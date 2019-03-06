{ crossenv }:

crossenv.make_derivation rec {
  name = "libdvdread-${version}";

  version = "6.0.1";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://download.videolan.org/pub/videolan/libdvdread/${version}/libdvdread-${version}.tar.bz2";
    sha256 = "1gfmh8ii3s2fw1c8vn57piwxc0smd3va4h7xgp9s8g48cc04zki8";
  };

  patches = [ ./paren-warning.patch ];

  builder = ./builder.sh;
}
