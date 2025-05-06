{ crossenv, qt, libusbp }:

crossenv.make_derivation rec {
  name = "tic-${version}";

  version = "1.8.3";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/pololu-tic-software/archive/${version}.tar.gz";
    hash = "sha256-b2DrZiOUCCpJSfvB+1uvVXCv36jEcs4BlCAMrMLfUBQ=";
  };

  builder = ./builder.sh;

  cross_inputs = [ libusbp qt ];
}
