    .text
    .align  2
    .thumb
    .thumb_func
    .globl  patch_start
patch_start:
    push    {r2-r7,lr}
    bl      patch_main
    ldr     r0, .Lsum_game_off
    ldrh    r1, [r0] @ sum game
    pop     {r2-r7,pc}
.Lsum_game_off:
    .word 0x04000130
