    .text
    .align  2
    .thumb
    .thumb_func
    .globl  clock_start
clock_start:
    push    {r3-r7, lr}
    bl      clock_main
    ldr     r0, .Lsum_val
    ldrh    r1, [r0]      @ sum val
    ldr     r2, .Lsum_xor @ sum xor
    pop     {r3-r7, pc}
    .align  2
.Lsum_val: .word 0x04000130
.Lsum_xor: .word 0x000003ff
