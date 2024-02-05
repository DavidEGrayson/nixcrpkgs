{ crossenv, libusb }:

let
  version = "2022-09-08";

  name = "openocd-${version}";

  nixpkgs = crossenv.nixpkgs;

  src = nixpkgs.fetchgit {
    url = "git://repo.or.cz/openocd";  # official mirror
    rev = "de99836cf639b63dc357a34c13825669af841f17";
    sha256 = "sha256-+51wBfDc086Z+GauDeehsrSiYGNHrI8mmyIONR47WYo=";
    fetchSubmodules = true;
  };

  drv = crossenv.make_derivation {
    inherit version name src;
    builder = ./builder.sh;

    native_inputs = [
      nixpkgs.autoconf
      nixpkgs.automake
      nixpkgs.libtool
      nixpkgs.m4
    ];

    ACLOCAL_PATH =
      "${nixpkgs.libtool}/share/aclocal:" +
      "${nixpkgs.pkg-config}/share/aclocal";

    # Avoid a name conflict: get_home_dir is also defined in libudev.
    CFLAGS = "-Dget_home_dir=openocd_get_home_dir";

    patches = [
      # Make sure the linker arguments needed by our static build of libusb
      # get used when compiling the openocd executable.
      ./ldflags.patch
    ];

    cross_inputs = [ libusb ];
  };

in
  drv
