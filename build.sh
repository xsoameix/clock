#!/bin/bash
gcc() {
    # $1 = _start
    # $2 = output
    # ${@:2} = $2~last = output and other arguments
    arm-linux-gnueabi-gcc -nostdlib -T <(m4 -D_start=$1 link.ld) -o "${@:2}"
    arm-linux-gnueabi-objcopy -O binary -j '.text' $2 "${2}.text"
}
jmp() {
    # $1 = _start
    # $2 = output
    # $3 = ELF file with symbols needed
    # $4 = the name of entrance
    gcc $1 $2 -Xlinker -R -Xlinker $3 -x assembler <(m4 -D_start=$4 patch.s)
}
gba() {
    # $1 = the gba file
    # $2 = whether the game use GC
    # $3 = the player data
    # $4 = free space >= 10000 bytes
    # $5 = to disable the error code text write C046C046 (nop x 2)
    # $6 = where to do monkey patch
    #   fire red:
    #     japanese: 0x000005ec
    # $7 = timer_nop 0x0002f29c
    # $8 = timer_jmp 0x0002f298
    local def="-DGC=$2 -DPLAYER_DATA=$3"
    gcc $4 build/clock_start clock_start.s clock.c timer_patch.s $def
    gcc $5 build/clock_nop   clock_nop.s
    jmp $6 build/clock_jmp   build/clock_start clock_start
    #gcc $7 build/timer_nop   timer_nop.s
    #jmp $8 build/timer_jmp   build/clock_start timer_start
    local src="${1}"
    local dst="${1%.*}-clock.gba"
    cp "$src" "$dst"
    ./main "$dst" $4 build/clock_start.text
    ./main "$dst" $5 build/clock_nop.text
    ./main "$dst" $6 build/clock_jmp.text
    #./main "$dst" $7 build/timer_nop.text
    #./main "$dst" $8 build/timer_jmp.text
}
ver() {
    # Reference: https://github.com/roytam1/rtoss/blob/master/PokemonHackSourceCode/PokemonMemHack/PokemonMemHackCore.cpp
    # $1 = the gba file
    local name=$(dd if="$1" iflag=skip_bytes skip=$((0xa0)) ibs=16 count=1 \
        status=none 2>/dev/null)
    if [ "$name" == "POKEMON EMERBPEJ" ]; then      # japanese emerald
        gba "$1" 1 0x3005af0 0x2aa000 0x2f7c2 0x5e8
    elif [ "$name" == "POKEMON SAPPAXPJ" ] ||       # japanese sapphire
         [ "$name" == "POKEMON RUBYAXVJ" ]; then    # japanese ruby
        gba "$1" 0 0x2024c04 0x22d000 0x070b0 0x430
    elif [ "$name" == "POKEMON EMERBPEE" ]; then    # english emerald
        gba "$1" 1 0x3005d90 0x380000 0x2fb06 0x5e8
    elif [ "$name" == "POKEMON SAPPAXPE" ] ||       # english sapphire
         [ "$name" == "POKEMON RUBYAXVE" ]; then    # english ruby
        gba "$1" 0 0x2024ea4 0x255000 0x09aac 0x42c
    else
        echo "Unknown gba file: $1"
    fi
}
dir="$HOME/VirtualBox VMs/shared/Pokemon/gba"
ver "$dir/ポケットモンスター エメラルド.gba"
ver "$dir/ポケットモンスター サファイア.gba"
ver "$dir/ポケットモンスター ルビー.gba"
ver "$dir/Pokemon Emerald.gba"
ver "$dir/Pokemon Sapphire.gba"
ver "$dir/Pokemon Ruby.gba"
