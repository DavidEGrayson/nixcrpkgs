{ nixpkgs }:

let
  native_base = {
    inherit nixpkgs;

    is_cross = false;

    default_native_inputs = [
      nixpkgs.bashInteractive
      nixpkgs.binutils
      (nixpkgs.binutils-unwrapped or nixpkgs.binutils)
      nixpkgs.bzip2
      nixpkgs.cmake
      nixpkgs.coreutils
      nixpkgs.diffutils
      nixpkgs.findutils
      nixpkgs.gcc
      nixpkgs.gawk
      nixpkgs.gnumake
      nixpkgs.gnugrep
      nixpkgs.gnused
      nixpkgs.gnutar
      nixpkgs.gzip
      nixpkgs.ninja
      nixpkgs.patch
      nixpkgs.which
      nixpkgs.xz
    ];

    make_derivation = import ../make_derivation.nix native_base;
  };

  pkgconf = import ./pkgconf { env = native_base; };

  bomutils = import ./bomutils { env = native_base; };

  macos_pkg_utils = import ./macos_pkg_utils {
    env = native_base;
    inherit bomutils;
  };

  native = native_base // {
    default_native_inputs = native_base.default_native_inputs ++ [
      pkgconf
    ];

    inherit pkgconf bomutils macos_pkg_utils;

    make_derivation = import ../make_derivation.nix native;
  };

in native
