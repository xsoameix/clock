#!/bin/bash
set_vma() {
    arm-linux-gnueabi-objcopy --change-section-vma ".text=$1" $2 2> /dev/null
}
get_sym() {
    echo "0x$(arm-linux-gnueabi-readelf -s $2 | grep $1 | awk '{print $2}')"
}
add_sym() {
    arm-linux-gnueabi-objcopy --add-symbol \
        "$1=.text:$(($2-$3)),function,global" $4
}
# english version
jump_base=0x000005e8
# english:  0x00380000
# japanese: 0x002aa000
patch_base=0x000aa000
# english:  0x0002fb06
# japanese: 0x0002f7c0
nop_base=0x0002f7c0 # To disable the error code text write C046C046 (nop x 2)
tjump_base=0x0002f294
arm-linux-gnueabi-gcc -S -o cpatch.s cpatch.c
arm-linux-gnueabi-as -o cpatch.o cpatch.s
arm-linux-gnueabi-as -o patch_caller.o patch_caller.s
arm-linux-gnueabi-as -o jump.o jump.s
arm-linux-gnueabi-as --defsym jump_base=$jump_base -o patch.o patch.s
arm-linux-gnueabi-as -o nop.o nop.s
arm-linux-gnueabi-as -o tjump.o tjump.s
arm-linux-gnueabi-ld -e 0 -o patch_caller patch_caller.o cpatch.o
set_vma $patch_base patch_caller
add_sym patch_start $(get_sym patch_start patch_caller) $jump_base jump.o
add_sym timer_start $(get_sym patch_main patch_caller) $tjump_base tjump.o
arm-linux-gnueabi-ld -e 0 -o jump jump.o
arm-linux-gnueabi-ld -e 0 -o patch -R jump.o patch.o
arm-linux-gnueabi-ld -e 0 -o tjump tjump.o
set_vma $jump_base jump # optional
set_vma $tjump_base tjump # optional
arm-linux-gnueabi-objcopy -O binary patch_caller patch_caller.text
arm-linux-gnueabi-objcopy -O binary jump jump.text
arm-linux-gnueabi-objcopy -O binary patch patch.text
arm-linux-gnueabi-objcopy -O binary nop.o nop.text
arm-linux-gnueabi-objcopy -O binary tjump.o tjump.text
#dir="$HOME/VirtualBox VMs/shared/Pokemon/english"
dir="$HOME/VirtualBox VMs/shared/Pokemon/japanese"
#bin="$dir/Pokemon Emerald-patched.gba"
#cp "$dir/Pokemon Emerald.gba" "$bin"
bin="$dir/ポケットモンスター エメラルド-patched.gba"
cp "$dir/ポケットモンスター エメラルド.gba" "$bin"
./main "$bin" jump.text $jump_base
./main "$bin" patch_caller.text $patch_base
#./main "$bin" patch.text $patch_base
./main "$bin" nop.text $nop_base
