{ nixpkgs, macos_sdk }:

rec {
  inherit nixpkgs;

  # Some native build tools and libraries.
  native = import ./native { inherit nixpkgs; };

  # Cross-compiling environments for each target system.
  crossenvs = {
    i686-w64-mingw32 = import ./mingw-w64 { inherit native; arch = "i686"; };
    x86_64-w64-mingw32 = import ./mingw-w64 { inherit native; arch = "x86_64"; };
    i686-linux-musl = import ./linux { inherit native; arch = "i686"; };
    x86_64-linux-musl = import ./linux { inherit native; arch = "x86_64"; };
    armv6-linux-musl = import ./linux {
      inherit native;
      arch = "armv6";
      gcc_options = "--with-fpu=vfp --with-float=hard ";
    };
    aarch64-linux-musl = import ./linux { inherit native; arch = "aarch64"; };
    x86_64-macos = import ./macos { inherit native macos_sdk; arch = "x86_64"; };
    aarch64-macos = import ./macos { inherit native macos_sdk; arch = "aarch64"; };
  };

  pkgFun = crossenv: import ./pkgs.nix { inherit crossenv; } // crossenv;

  # Sets of packages for each target system.
  i686-w64-mingw32 = pkgFun crossenvs.i686-w64-mingw32;
  x86_64-w64-mingw32 = pkgFun crossenvs.x86_64-w64-mingw32;
  i686-linux-musl = pkgFun crossenvs.i686-linux-musl;
  x86_64-linux-musl = pkgFun crossenvs.x86_64-linux-musl;
  armv6-linux-musl = pkgFun crossenvs.armv6-linux-musl;
  aarch64-linux-musl = pkgFun crossenvs.aarch64-linux-musl;
  x86_64-macos = pkgFun crossenvs.x86_64-macos;
  aarch64-macos = pkgFun crossenvs.aarch64-macos;

  envs = [
    i686-w64-mingw32
    x86_64-w64-mingw32
    i686-linux-musl
    x86_64-linux-musl
    armv6-linux-musl
    aarch64-linux-musl
    x86_64-macos
    aarch64-macos
  ];

  # omni is convenient name for packages that are used for cross-compiling but
  # are actually the same on all platforms.  You can just refer to it by
  # 'omni.package_name' instead of 'some_platform.package_name'.
  omni = pkgFun { inherit native nixpkgs; };

  # Handy aliases.
  win32 = i686-w64-mingw32;
  win64 = x86_64-w64-mingw32;
  linux32 = i686-linux-musl;
  linux-x86 = i686-linux-musl;
  linux-i686 = i686-linux-musl;
  linux64 = x86_64-linux-musl;
  linux-x86_64 = x86_64-linux-musl;
  linux-rpi = armv6-linux-musl;
  linux-rpi32 = armv6-linux-musl;
  linux-rpi64 = aarch64-linux-musl;
  rpi = armv6-linux-musl;
  rpi32 = armv6-linux-musl;
  rpi64 = aarch64-linux-musl;
  macos = x86_64-macos;
  mac = x86_64-macos;
  macos-arm = aarch64-macos;
  mac-arm = aarch64-macos;

  # filter is a function that can be applied to a local directory to filter out
  # files that are likely to change frequently without affecting the build,
  # causing unneeded rebuilds.
  filter_func = name: type: let bn = baseNameOf (toString name); in !(
    (type == "directory" && bn == ".git") ||
    (type == "symlink" && nixpkgs.lib.hasPrefix "result" bn) ||
    (type == "directory" && bn == "nix") ||
    (type == "directory" && bn == "build") ||
    nixpkgs.lib.hasSuffix ".nix" bn ||
    nixpkgs.lib.hasSuffix "~" bn
  );
  filter = builtins.filterSource filter_func;

  # bundle is a function that takes a set of derivations and makes a
  # derivation for a bundle that has symbolic links in it to each of
  # the input derivations.
  bundle = drvs: native.make_derivation rec {
    name = "bundle";
    builder = ./bundle_builder.sh;
    names = builtins.attrNames drvs;
    dirs = builtins.attrValues drvs;
  };

  # gcroots is a derivation that builds a list of the items that we usually do
  # not want to garbage collect.
  gcroots_func = env: env.default_native_inputs ++ [env.qt];
  gcroots = native.make_derivation rec {
    name = "gcroots.txt";
    builder = ./file_builder.sh;
    contents = builtins.concatStringsSep "\n" (
      builtins.foldl' (a: b: a ++ b) [] (
        builtins.map gcroots_func envs
      )
    );
  };
}
