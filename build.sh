#!/bin/bash
gcc() {
    arm-linux-gnueabi-gcc -nostdlib -T <(m4 -D_start=$1 link.ld) -o "${@:2}"
    arm-linux-gnueabi-objcopy -O binary -j '.text' $2 "${2}.text"
}
gen() {
    gcc $1 $2 -Xlinker -R -Xlinker $3 -x assembler <(m4 -D_start=$4 patch.s)
}
clock_patch=0x000005e8
# free space >= 10000 bytes
# english:  0x00380000
# japanese: 0x002aa000
clock_start=0x002aa000
# english:  0x0002fb06
# japanese: 0x0002f7c0
clock_nop=0x0002f7c0 # To disable the error code text write C046C046 (nop x 2)
timer_patch=0x0002f294
gcc $clock_start build/clock       clock_start.s clock.c
gcc $clock_nop   build/clock_nop   clock_nop.s
gen $clock_patch build/clock_patch build/clock clock_start
gen $timer_patch build/timer_patch build/clock clock_main

#dir="$HOME/VirtualBox VMs/shared/Pokemon/english"
dir="$HOME/VirtualBox VMs/shared/Pokemon/japanese"
#bin="$dir/Pokemon Emerald-patched.gba"
#cp "$dir/Pokemon Emerald.gba" "$bin"
bin="$dir/ポケットモンスター エメラルド-patched.gba"
cp "$dir/ポケットモンスター エメラルド.gba" "$bin"
./main "$bin" $clock_start build/clock.text
./main "$bin" $clock_nop   build/clock_nop.text
./main "$bin" $clock_patch build/clock_patch.text
