#!/bin/sh

#TODO: env vars and path should be more general

#LINUXVERSION=3.18.18
LINUXVERSION=3.10.49

KLIB_BUILD="$OPENWRT_PATH/../kernel/linux-3.10.49-wndr3700"

make KLIB_BUILD=$KLIB_BUILD clean
make KLIB_BUILD=$KLIB_BUILD oldconfig

#cp .config-2015-07-12 .config

export CC=mips-openwrt-linux-gcc
export LD=mips-openwrt-linux-ld
export AR=mips-openwrt-linux-ar
export NM=mips-openwrt-linux-nm
export STRIP=mips-openwrt-linux-strip
export ARCH=mips
export BOARD=ath79
export CROSS_COMPILE="mips-openwrt-linux-"
export KLIB_BUILD=$KLIB_BUILD
export KLIB="$STAGING_DIR/target-mipsel_mips32_uClibc-0.9.33.2"

set -a
CROSS_COMPILE="mips-openwrt-linux-"
ARCH=mips
KLIB_BUILD=$KLIB_BUILD
KLIB="$STAGING_DIR/target-mipsel_mips32_uClibc-0.9.33.2/"
set +a

make
