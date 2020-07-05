# bomutils: A utility that helps us make the "bill of materials" files found
# inside macOS packages.

{ env }:

env.make_derivation rec {
  name = "bomutils-${version}";

  version = "2014-05-20";

  src = env.nixpkgs.fetchFromGitHub {
    owner = "hogliux";
    repo = "bomutils";
    rev = "3f7dc2dbbc36ca1c957ec629970026f45594a52c";
    sha256 = "1i7nhbq1fcbrjwfg64znz8p4l7662f7qz2l6xcvwd5z93dnmgmdr";
  };

  builder = ./builder.sh;
}
