source $setup

mkdir -p $out/bin

cp -r $src $out/src

cat <<END > $out/bin/pkgbuild
export PATH="$dep_path:\$PATH"
exec $out/src/pkgbuild.rb "\$@"
END

cat <<END > $out/bin/productbuild
export PATH="$dep_path:\$PATH"
exec $out/src/pkgbuild.rb "\$@"
END

chmod a+x $out/bin/*
