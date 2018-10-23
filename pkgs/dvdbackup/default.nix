{ crossenv }:

let
  version = "0.4.2";

  name = "dvdbackup-#{version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "http://downloads.sourceforge.net/dvdbackup/dvdbackup-#{version}.tar.xz";
    sha256 = "1rl3h7waqja8blmbpmwy01q9fgr5r0c32b8dy3pbf59bp3xmd37g";
  };

  main = crossenv.make_derivation {
    inherit version name src;
    builder = ./builder.sh;
  };

in
  main
