source $setup

  # -isystem /usr/lib/gcc/x86_64-linux-gnu/6/include \

$host-gcc \
  -nostdinc \
  -I/usr/src/linux-headers-4.9.0-8-common/arch/x86/include \
  -I./arch/x86/include/generated/uapi \
  -I./arch/x86/include/generated \
  -I/usr/src/linux-headers-4.9.0-8-common/include \
  -I./include \
  -I/usr/src/linux-headers-4.9.0-8-common/arch/x86/include/uapi \
  -I/usr/src/linux-headers-4.9.0-8-common/include/uapi \
  -I./include/generated/uapi \
  -include /usr/src/linux-headers-4.9.0-8-common/include/linux/kconfig.h \
  -I/home/david/hello_ko \
  -D__KERNEL__ \
  -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing \
  -fno-common -Werror-implicit-function-declaration -Wno-format-security \
  -std=gnu89 -fno-PIE -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 \
  -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 \
  -mpreferred-stack-boundary=3 -mskip-rax-setup -mtune=generic -mno-red-zone \
  -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args \
  -DCONFIG_X86_X32_ABI -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 \
  -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1 \
  -DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 \
  -DCONFIG_AS_AVX512=1 -DCONFIG_AS_SHA1_NI=1 -DCONFIG_AS_SHA256_NI=1 \
  -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables \
  -mindirect-branch=thunk-extern -mindirect-branch-register \
  -DRETPOLINE -fno-delete-null-pointer-checks -Wno-frame-address \
  -O2 --param=allow-store-data-races=0 -DCC_HAVE_ASM_GOTO \
  -Wframe-larger-than=2048 -fstack-protector-strong \
  -Wno-unused-but-set-variable -Wno-unused-const-variable \
  -fno-var-tracking-assignments -g -pg -mfentry -DCC_USING_FENTRY \
  -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow \
  -fno-merge-all-constants -fmerge-constants -fno-stack-check \
  -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes \
  -Werror=date-time -Werror=incompatible-pointer-types \
  -DMODULE -DKBUILD_BASENAME='"hello_ko"' -DKBUILD_MODNAME='"hello_ko"' \
  -c -o hello_ko.o \
  $src
