{ crossenv }:

if crossenv.os != "linux" then "linux only" else

crossenv.make_derivation {
  name = "hello_ko";
  builder = ./builder.sh;
  src = ./hello_ko.c;
}
