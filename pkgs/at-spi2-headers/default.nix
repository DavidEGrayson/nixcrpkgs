{ crossenv }:

let
  lib = crossenv.native.make_derivation {
    name = "at-spi2-headers";

    src = crossenv.nixpkgs.fetchgit {
      url = "https://gitlab.gnome.org/GNOME/at-spi2-core.git";
      rev = "e1d5412b33463fd2f45dea400c45b107d0c78f42";
      sha256 = "022k9yl65a5ak02283zhd8c73vnx8yc3siqj96qifwvdgd71ihb6";
    };

    builder = ./builder.sh;
  };

  license_fragment = crossenv.native.make_derivation {
    name = "at-spi2-headers-license-fragment";
    src = lib.src;
    builder = ./license_builder.sh;
  };
  license_set = { "${lib.name}" = license_fragment; };

in
  lib // { inherit license_set; }
