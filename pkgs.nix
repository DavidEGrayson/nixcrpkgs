{ crossenv }:
let pkgs =
rec {
  recurseForDerivations = true;
  inherit (crossenv) binutils gcc;

  hello = import ./pkgs/hello {
    inherit crossenv;
  };

  hello_cpp = import ./pkgs/hello_cpp {
    inherit crossenv;
  };

  usbview = import ./pkgs/usbview {
    inherit crossenv;
  };

  devcon = import ./pkgs/devcon {
    inherit crossenv;
  };

  pdcurses = import ./pkgs/pdcurses {
    inherit crossenv;
  };

  readline = import ./pkgs/readline {
    inherit crossenv;
    curses = pdcurses;
  };

  expat = import ./pkgs/expat {
    inherit crossenv;
  };

  zlib = import ./pkgs/zlib {
    inherit crossenv;
  };

  gmp = import ./pkgs/gmp {
    env = crossenv;
  };

  mpfr = import ./pkgs/mpfr {
    env = crossenv;
    inherit gmp;
  };

  libmpc = import ./pkgs/libmpc {
    env = crossenv;
    inherit gmp mpfr;
  };

  libudev = import ./pkgs/libudev {
    inherit crossenv;
  };

  libusb = import ./pkgs/libusb {
    inherit crossenv libudev;
  };

  libusbp = import ./pkgs/libusbp {
    inherit crossenv libudev;
  };

  p-load = import ./pkgs/p-load {
    inherit crossenv libusbp;
  };

  avrdude = import ./pkgs/avrdude {
    inherit crossenv;
  };

  openocd = import ./pkgs/openocd {
    inherit crossenv libusb;
  };

  xcb-proto = import ./pkgs/xcb-proto {
    inherit crossenv;
  };

  xorg-macros = import ./pkgs/xorg-macros {
    inherit crossenv;
  };

  xorgproto = import ./pkgs/xorgproto {
    inherit crossenv xorg-macros;
  };

  libxau = import ./pkgs/libxau {
    inherit crossenv xorg-macros xorgproto;
  };

  libxcb = import ./pkgs/libxcb {
    inherit crossenv xcb-proto libxau;
  };

  xcb-util = import ./pkgs/xcb-util {
    inherit crossenv libxcb;
  };

  xcb-util-image = import ./pkgs/xcb-util-image {
    inherit crossenv libxcb xcb-util;
  };

  xcb-util-keysyms = import ./pkgs/xcb-util-keysyms {
    inherit crossenv libxcb;
  };

  xcb-util-renderutil = import ./pkgs/xcb-util-renderutil {
    inherit crossenv libxcb;
  };

  xcb-util-wm = import ./pkgs/xcb-util-wm {
    inherit crossenv libxcb;
  };

  xtrans = import ./pkgs/xtrans {
    inherit crossenv;
  };

  libx11 = import ./pkgs/libx11 {
    inherit crossenv xorg-macros xorgproto xtrans libxcb;
  };

  libxext = import ./pkgs/libxext {
    inherit crossenv xorgproto libx11;
  };

  libxfixes = import ./pkgs/libxfixes {
    inherit crossenv xorgproto libx11;
  };

  libxi = import ./pkgs/libxi {
    inherit crossenv xorgproto libx11 libxext libxfixes;
  };

  libxkbcommon = import ./pkgs/libxkbcommon {
     inherit crossenv libxcb;
  };

  libxall = import ./pkgs/libxall {
    inherit crossenv;
    libs = [
      xcb-proto xorg-macros xorgproto libxau libxcb
      xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm
      xtrans libx11 libxext libxfixes libxi libxkbcommon
    ];
  };

  at-spi2-headers = import ./pkgs/at-spi2-headers {
    inherit crossenv;
  };

  dejavu-fonts = import ./pkgs/dejavu-fonts {
    inherit crossenv;
  };

  qt = import ./pkgs/qt {
    inherit crossenv libudev libxall at-spi2-headers dejavu-fonts;
  };

  qt6 = import ./pkgs/qt6 {
    inherit crossenv libudev at-spi2-headers dejavu-fonts;
    xlibs = [
      libxcb xcb-util xcb-util-wm xcb-util-image
      xcb-util-keysyms xcb-util-renderutil
      libx11 libxkbcommon
    ];
  };

  pavr2 = import ./pkgs/pavr2 {
    inherit crossenv libusbp qt;
  };

  tic = import ./pkgs/tic {
    inherit crossenv libusbp qt;
  };

  jrkg2 = import ./pkgs/jrkg2 {
    inherit crossenv libusbp qt;
  };
};
in pkgs
