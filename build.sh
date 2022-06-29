#!/bin/bash
# based on the instructions from edk2-platform
set -e
export PACKAGES_PATH=$PWD/../edk2:$PWD/../edk2-platforms:$PWD
export WORKSPACE=$PWD/workspace
. ../edk2/edksetup.sh
# not actually GCC5; it's GCC7 on Ubuntu 18.04.
GCC5_ARM_PREFIX=arm-linux-gnueabi- build -s -n 0 -a ARM -t GCC5 -p MSM8909Pkg/MSM8909Pkg.dsc
gzip -c < workspace/Build/MSM8909/DEBUG_GCC5/FV/MSM8909_UEFI.fd >MSM8909_UEFI.fd.gz
skales-mkbootimg --kernel MSM8909_UEFI.fd.gz --dt huawei-y560.dtb --ramdisk workspace/empty --base 0x80000000 --pagesize 2048 --cmdline "androidboot.hardware=qcom msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive" --output uefi.img