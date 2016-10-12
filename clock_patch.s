    .text
    .align  2
    .thumb
    .thumb_func
    .globl  patch_caller
patch_caller:
    push    {lr}
    push    {r0-r7}
    ldr     r0, .PLAYER_DATA
    ldr     r0, [r0]
    add     r0, r0, #0x11 @ & playing time seconds
    str     r0, [sp]
    ldr     r4, .PLAYER_DATA
    ldr     r4, [r4]
    add     r4, r4, #0x9a @ & clock hours
    add     r3, r4, #0x1 @ & clock minutes
    ldr     r7, .SUM_BUFF @ & sum buff
    ldrb    r5, [r7] @ sum buff
    ldrb    r0, [r0] @ playing time seconds
    add     r2, r7, #0x1 @ & sum buff + 1
    cmp     r5, r0 @ if sum buff == playing time seconds => return
    beq     Game_Code_and_Return
    strb    r0, [r7] @ sum buff := playing time seconds
    ldrb    r0, [r2] @ next sum buff = (& sum buff)[1]
    add     r6, r0, #0x1 @ next sum buff + 1
    lsl     r0, r6, #24 @ (next sum buff + 1) << 24
    lsr     r0, r0, #24 @ (next sum buff + 1) << 24 >> 24
    strb    r0, [r2] @ (& sum buff)[1] := (next sum buff + 1) << 24 >> 24
    cmp     r0, #59 @ if (next sum buff + 1) << 24 >> 24 <= 59 => return
    ble     Game_Code_and_Return
    mov     r6, #0
    strb    r6, [r2] @ (& sum buff)[1] := 0
    ldrb    r6, [r3] @ clock minutes
    sub     r6, #1 @ clock minutes - 1
    lsl     r1, r6, #24 @ (clock minutes - 1) << 24
    lsr     r1, r1, #24 @ (clock minutes - 1) << 24 >> 24
    cmp     r1, #0xff @ if (clock minutes - 1) << 24 >> 24 != -1 => L3
    bne     SOMETHING3
    mov     r6, #59
    strb    r6, [r3] @ clock minutes := 59
    ldrb    r6, [r4] @ clock hours
    sub     r6, #0x1 @ clock hours - 1
    and     r1, r6 @ 0xff & (clock hours - 1)
    cmp     r1, #0xff @ 0xff & (clock hours - 1) != -1 => L2
    bne     SOMETHING2
    mov     r1, #23
    bl      SOMETHING4 @ => L4

SOMETHING2:
    strb    r1, [r4] @ clock hours := 0xff & (clock hours - 1)
    b       Game_Code_and_Return

SOMETHING3:
    strb    r1, [r3] @ clock minutes := (clock minutes - 1) << 24 >> 24

Game_Code_and_Return:
    pop     {r0-r7}
    ldr     r0, .SUM_GAME_OFF @ & sum game
    ldrh    r1, [r0] @ sum game
    ldr     r2, .SUM_VAL @ sum val
    mov     r0, r2 @ sum val
    @mov    r3, r0 @ sum val
    @eor    r3, r1 @ sum val ^ sum game
    pop     {pc} @ return

SOMETHING4:
    push    {r0-r2}
    ldr     r0, .PLAYER_DATA
    ldr     r0, [r0]
    add     r0, r0, #0x98 @ & date
    ldrh    r1, [r0] @ date
    sub     r1, #1 @ date - 1
    ldr     r2, =.SUM_VAL2 @ sum val 2
    cmp     r1, r2 @ if date - 1 < sum val 2 => L1
    blt     SOMETHING1
    ldr     r1, .SUM_VAL3 @ sum val 3

SOMETHING1:
    strh    r1, [r0] @ date := date - 1 < sum val 2 ? date - 1 : sum val 3
    pop     {r0-r2}
    mov     pc, lr @ return

    .align 2
.PLAYER_DATA:
    .word 0x03005d90
.SUM_BUFF:
    @ Offset 0200F024 may not be safe in emerald but this can be changed to anything desired.
    @ This code seems to work but is not fully tested. Use at your own risk.
    @.word 0x0200f024
    @.word 0x0203fea0
    .word 0x0201f000
.SUM_GAME_OFF:
    .word 0x04000130
.SUM_VAL:
    .hword 0x03ff
    .hword 0x0000
.SUM_VAL2:
    .hword 0x8000
    .hword 0x0000
.SUM_VAL3:
    .hword 0xffff
    .hword 0x0000
