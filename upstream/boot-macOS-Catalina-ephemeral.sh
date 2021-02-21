#!/usr/bin/env bash

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

MY_OPTIONS="+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

# OVMF=./firmware
OVMF="./"

# This causes high cpu usage on the *host* side
# qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,hypervisor=off,vmx=on,kvm=off,$MY_OPTIONS\

cat $OVMF_VARS > my_ovmf

# !!! Necessary when the default $TMPDIR isn't big enough (otherwise, the VM may deadlock when installing Nix / nix-darwin)
TMPDIR=$(mktemp -p . -d --suffix=-ephemeral)

finish() {
    rmdir $TMPDIR
}
trap finish EXIT

qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$MY_OPTIONS\
	  -machine q35 \
	  -smp 4,cores=2 \
	  -usb -device usb-kbd -device usb-tablet \
	  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	  -drive if=pflash,format=raw,readonly,file=$OVMF_CODE \
	  -drive if=pflash,format=raw,readonly,file=my_ovmf \
	  -smbios type=2 \
		-snapshot \
	  -device ide-cd,bus=ide.0,drive=config \
	  -drive id=config,if=none,snapshot=on,media=cdrom,file=./config.iso \
	  -device ich9-intel-hda -device hda-duplex \
	  -device ich9-ahci,id=sata \
	  -device ide-hd,bus=sata.2,drive=Clover \
	  -drive id=Clover,if=none,snapshot=on,format=qcow2,file=$CLOVER_QCOW \
	  -device ide-hd,bus=sata.4,drive=MacHDD \
	  -drive id=MacHDD,if=none,file=./mac_hdd_ng.img,format=qcow2 \
	  -netdev user,id=net0,hostfwd=tcp::2200-:22 -device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
	  -monitor stdio \
	  -vnc 127.0.0.1:0
