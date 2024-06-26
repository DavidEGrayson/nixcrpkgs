{ crossenv }:

if crossenv.os != "linux" then "linux only" else

let
  version = "255";

  name = "libudev-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/systemd/systemd/archive/v${version}.tar.gz";
    hash = "sha256-KIVP+yy1+eB/y9uvHgOoCzRioS7e74SJPKLzeyLkSR4=";
  };

  pointer_size = if crossenv.arch == "i686" || crossenv.arch == "armv6" then 4
    else 8;

  lib = crossenv.make_derivation rec {
    inherit version name src;
    builder = ./builder.sh;
    patches = [
      # Fix some compile-time errors caused by not using glibc.
      ./megapatch.patch

      # We can't figure out how to compile some compilation units, so we delete
      # them.  These patches clean up errors caused by that.
      ./filesystems.patch
      ./unit-name.patch
      ./capability.patch

      # af-list.c includes some header files we don't have.
      ./af-list.patch

      # We don't have errno-from-name.h or errno-to-name.h
      ./errno.patch
    ];
    fill = ./fill;

    size_flags =
        "-DGPERF_LEN_TYPE=size_t " +
        "-DSIZEOF_TIMEX_MEMBER=${toString pointer_size} " +
        "-D_FILE_OFFSET_BITS=64 " +  # not sure about this (TODO)
        "-DSIZEOF_PID_T=4 " +
        "-DSIZEOF_UID_T=4 " +
        "-DSIZEOF_GID_T=4 " +
        "-DSIZEOF_TIME_T=8 " +
        "-DSIZEOF_RLIM_T=8 " +
        "-DSIZEOF_INO_T=8 " +
        "-DSIZEOF_DEV_T=8";

    CFLAGS = "-ffunction-sections -Werror " +
      "-Dsocket_bind=libudev_socket_bind " +              # name conflict in OpenOCD
      "-Dsocket_set_option=libudev_socket_set_option " +  # name conflict in OpenOCD
      "-D__UAPI_DEF_ETHHDR=0 " +
      "-D_GNU_SOURCE " +
      "-DHAVE_REALLOCARRAY " +
      "-DHAVE_STRUCT_STATX " +
      "-DHAVE_NAME_TO_HANDLE_AT " +
      "-DBUILD_MODE_DEVELOPER=0 " +
      "-DHAVE_DECL_SETNS " +
      "-DHAVE_DECL_MEMFD_CREATE " +
      "-DHAVE_DECL_GETTID " +
      "-DHAVE_DECL_NAME_TO_HANDLE_AT " +
      "-DHAVE_DECL_COPY_FILE_RANGE " +
      size_flags;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set = { "${name}" = license; };

in
  lib // { inherit license_set; }
