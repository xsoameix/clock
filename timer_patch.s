    @ from: http://tieba.baidu.com/p/3307774236
    .text
    .align  2
    .thumb
    .thumb_func
    .global timer_start
timer_start:
    push    {r0-r5, lr}
    ldr     r0, PLAYER_DATA
    ldr     r0, [r0]
    add     r0, r0, #0xe @ & hour
    ldrh    r2, [r0] @ hour
    mov     r1, #60
    mul     r2, r1 @ hour * 60
    add     r0, r0, #0x2 @ & minute
    ldrb    r0, [r0] @ minute
    add     r0, r0, r2 @ hour * 60 + minute
    mov     r1, #0xf @ 15
    lsl     r1, r1, #0x5 @ 15 * 32 = 30 * 16 = 60 * 8
    swi     #0x6 @ days = (hour * 60 + minute) / (60 * 8)
    mov     r2, #0 @ x
    mov     r3, #0 @ mon = 0
    mov     r4, #0 @ dsum = 0
    mov     r5, #0 @ year = 0
    add     r2, r0, #0x1 @ days++ (humanize)
loop:
    adr     r1, days_byte
    ldrb    r1, [r1, r3] @ days(mon)
    add     r4, r1, r4 @ dsum += days(mon)
    cmp     r2, r4 @ if days > dsum => not_this_month
    bgt     not_this_month

    get_year:
        adr     r0, hex_to_dec
        ldrb    r0, [r0, r5] @ dec(year)
        ldr     r1, ram_date
        strb    r0, [r1] @ ram_date[0] := dec(year)
    get_month:
        add     r3, #0x1 @ mon + 1
        adr     r0, hex_to_dec
        ldrb    r0, [r0, r3] @ human(mon) = dec(mon + 1)
        add     r1, #0x1
        strb    r0, [r1] @ ram_date[1] := human(mon)
    get_day:
        cmp     r2, #31 @ if days <= 31 => first_month
        ble     first_month
        sub     r2, r4, r2 @ days = dsum - days
    first_month:
        adr     r0, hex_to_dec
        ldrb    r0, [r0, r2] @ dec(days)
        add     r1, #0x1
        strb    r0, [r1] @ ram_date[2] := dec(days)
        pop     {r0}
        ldr     r0, ram_date
        pop     {r1-r5, pc} @ return

not_this_month:
    cmp     r3, #11 @ if mon == 11 => next_year
    beq     next_year
    add     r3, #1 @ mon++
    b       loop @ continue
next_year:
    ldr     r1, one_year @ 365
    sub     r2, r2, r1 @ days -= 365
    add     r5, #1 @ year++
    mov     r3, #0 @ mon = 0
    b       loop @ continue
    .align  2
PLAYER_DATA:    .word 0x03005d90
ram_date:       .word 0x0203f500
one_year:       .word 0x0000016d
days_byte:
    .byte 31 @ January
    .byte 28 @ February
    .byte 31 @ March
    .byte 30 @ April
    .byte 31 @ May
    .byte 30 @ June
    .byte 31 @ July
    .byte 31 @ August
    .byte 30 @ September
    .byte 31 @ October
    .byte 30 @ November
    .byte 31 @ December
    @ 1F 1C 1F 1E 1F 1E 1F 1F 1E 1F 1E 1F
    @ = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
hex_to_dec:
    .ascii "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09"
    .ascii "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19"
    .ascii "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29"
    .ascii "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39"
    .ascii "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49"
    .ascii "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59"
    .ascii "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69"
    .ascii "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79"
    .ascii "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89"
    .ascii "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99"
    .ascii "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    @ 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 00 00 00 00 00 00 00 00 00 00 00
