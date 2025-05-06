{ crossenv, libudev }:

let
  version = "0e1c4f2";  # 1.3.1, plus some build system changes

  name = "libusbp-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/libusbp/archive/${version}.tar.gz";
    hash = "sha256-hOy/3VEdZ/cEGLUv0ZFDwcO0nxClF9+MhIw2FFx/YxY=";
  };

  lib = crossenv.make_derivation {
    inherit version name src;
    builder = ./builder.sh;

    cross_inputs =
      if crossenv.os == "linux" then
        [ libudev ]
      else
        [];

    libudev = if crossenv.os == "linux" then libudev else null;
  };

  examples = crossenv.make_derivation {
    name = "${name}-examples";
    inherit src version;
    builder = ./examples_builder.sh;
    cross_inputs = [ lib ];
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    (if crossenv.os == "linux" then libudev.license_set else {}) //
    { "${name}" = license; };
in
  lib // { inherit examples license_set; }
