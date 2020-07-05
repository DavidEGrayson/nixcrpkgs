# pkgbuild and productbuild: Utilities for creating macOS .pkg files (installers).
{ env, bomutils }:
env.make_derivation rec {
  name = "macos_pkg_utils-${version}";

  version = "2014-05-20";

  src = ./src;

  builder = ./builder.sh;

  ruby = env.nixpkgs.ruby;
  xar = env.nixpkgs.xar;
  cpio = env.nixpkgs.cpio;
  inherit bomutils;

  dep_path = "${ruby}/bin:${xar}/bin:${cpio}/bin:${bomutils}/bin";
}
