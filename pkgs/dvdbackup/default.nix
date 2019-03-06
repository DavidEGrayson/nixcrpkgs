{ crossenv }:

crossenv.make_derivation rec {
  name = "dvdbackup-${version}";

  version = "0.4.2";

  src = crossenv.nixpkgs.fetchurl {
    url = "http://downloads.sourceforge.net/dvdbackup/dvdbackup-${version}.tar.xz";
    sha256 = "1rl3h7waqja8blmbpmwy01q9fgr5r0c32b8dy3pbf59bp3xmd37g";
  };

  builder = ./builder.sh;
}
