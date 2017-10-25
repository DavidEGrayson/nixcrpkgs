source $setup

header_dirs="
architecture
i386
libkern
mach
machine
mach-o
mach_debug
"

headers="
libunwind.h
Availability.h
AvailabilityMacros.h
AvailabilityInternal.h
sys/_types.h
sys/_pthread/_pthread_types.h
sys/_types/_mach_port_t.h
sys/_types/_os_inline.h
sys/appleapiopts.h
"

for dir in $header_dirs; do
  d=$out/usr/include/$(dirname $dir)/
  mkdir -p $d
  cp -r --no-preserve=mode $sdk/usr/include/$dir $d
done

for header in $headers; do
  mkdir -p $out/usr/include/$(dirname $header)
  cp $sdk/usr/include/$header $out/usr/include/$header
done

cat > $out/usr/include/i386/_types.h <<EOF
// Don't redefine things like __int64_t, causing a conflicting definition.
// Just include the appropriate glibc header.
#include <bits/types.h>
#include <sys/cdefs.h>
typedef long __darwin_intptr_t;
typedef unsigned int __darwin_natural_t;
EOF

cat > $out/usr/include/string.h <<EOF
// MacOS programs expect string.h to define strlcpy.

#include_next <string.h>

#ifndef _NIXCRPKGS_MACOS_SDK_STRING_H
#define _NIXCRPKGS_MACOS_SDK_STRING_H

static inline size_t
strlcpy(char * __restrict__ dst, const char * __restrict__ src, size_t dstsize)
{
  size_t len = strlen(src);
  if (!dstsize) { return len; }
  if (len >= dstsize) { len = dstsize - 1; }
  memcpy(dst, src, len);
  dst[len] = 0;
  return len;
}

#endif
EOF

# The MacOS SDK expects sys/cdefs.h to define __unused as an attribute.  But we
# can't have that definition here because glibc's linux/sysctl.h uses __unused as a
# variable name.  Instead, we just fix the SDK to not use __unused.
sed -i -r 's/\b__unused\b//g' $out/usr/include/mach/mig_errors.h