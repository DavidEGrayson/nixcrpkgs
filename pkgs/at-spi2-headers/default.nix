{ crossenv, glib }:

let
  lib = crossenv.make_derivation {
    name = "at-spi2-headers";

    src = crossenv.nixpkgs.fetchgit {
      url = "https://gitlab.gnome.org/GNOME/at-spi2-core.git";
      rev = "69201560832c1ed8b2cbadb142b6a14506b6bc50";
      hash = "sha256-+OfE+ZbLNJrTfX7G/MQhKO1toM4E7xgDRiRjdsBEF0Y=";
    };

    inherit glib;

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
