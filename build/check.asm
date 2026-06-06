; da65 V2.19 - Git cc3c40c
; Created:    2026-06-06 17:54:04
; Input file: D:\Google Drive\My Code\6502\CC65\SwitchCharROM/build/main.bin
; Page:       1


        .setcpu "6502"

        sei
        lda     #$01
        sta     $C31E
        lda     #$00
        sta     $C31F
        lda     $DC0E
        sta     $C334
        and     #$FE
        sta     $DC0E
        lda     #$02
        sta     $C31E
        lda     $01
        sta     $C333
        and     #$FB
        sta     $01
        lda     #$03
        sta     $C31E
        ldx     #$10
        ldy     #$00
LC02D:  .byte   $B9
        brk
LC02F:  bne     *-101
        brk
LC032:  bmi     *-54
        bne     LC02D
        inc     LC02F
        inc     LC032
        dex
        bne     LC02D
        lda     $C333
        sta     $01
        ldx     #$04
        ldy     #$00
LC048:  .byte   $B9
        brk
LC04A:  .byte   $04
        .byte   $99
        brk
LC04D:  .byte   $5C
        iny
        bne     LC048
        inc     LC04A
        inc     LC04D
        dex
        bne     LC048
        lda     $DD00
        sta     $C330
        and     #$FC
        ora     #$02
        sta     $DD00
        lda     $D018
        sta     $C331
        and     #$F1
        ora     #$0C
        sta     $D018
        lda     $01
        and     #$FB
        sta     $01
        ldx     #$00
LC07C:  lda     $D000,x
        sta     $C320,x
        inx
        cpx     #$10
        bne     LC07C
        jsr     LC1B0
        lda     #$04
        sta     $C31E
        jsr     LC1E4
        lda     #$05
        sta     $C31E
        bcc     LC0A6
        lda     #$06
        sta     $C31E
        .byte   $A5
LC09F:  sbc     $8D,x
        .byte   $1F
        .byte   $C3
        jmp     LC0C2

LC0A6:  .byte   $A9
LC0A7:  ora     ($AE,x)
        .byte   $32
        .byte   $C3
        jsr     LC262
        bcc     LC0B8
        lda     #$07
        sta     $C31E
        jmp     LC0C2

LC0B8:  lda     #$01
        jsr     LC273
        lda     #$00
        sta     $C31E
LC0C2:  lda     $01
        ora     #$04
        sta     $01
        lda     $C331
        sta     $D018
        lda     $C330
        sta     $DD00
        lda     $C334
        sta     $DC0E
LC0DA:  cli
        rts

LC0DC:  lda     $D021
        lda     $D052
        lda     $D042
        lda     $D043
        lda     $D050
        lda     $D021
        rts

LC0EF:  sta     $F4
        lda     $F0
        sta     LC0F7
        .byte   $AD
LC0F7:  brk
        bne     LC09F
        sbc     ($8D),y
        .byte   $FF
        cpy     #$AD
        brk
        bne     LC0A7
        .byte   $F4
        beq     LC115
        tax
        ldy     #$00
LC108:  lda     $F7,y
        sta     LC10F
        .byte   $AD
LC10F:  brk
        bne     LC0DA
        dex
        bne     LC108
LC115:  rts

LC116:  lda     $D102
        sta     $F2
        rts

LC11C:  ldx     #$FF
LC11E:  lda     $D102
        cmp     $F2
        bne     LC12A
        dex
        bne     LC11E
        sec
        rts

LC12A:  clc
        rts

LC12C:  ldx     #$FF
LC12E:  lda     $D104
        cmp     #$BB
        beq     LC13D
        jsr     LC2ED
        dex
        bne     LC12E
        sec
        rts

LC13D:  clc
        rts

LC13F:  ldx     #$FF
        ldy     #$FF
LC143:  lda     $D104
        cmp     #$BB
        beq     LC152
        dex
        bne     LC143
        dey
        bne     LC143
        sec
        rts

LC152:  clc
        rts

LC154:  lda     $D105
        cmp     #$CC
        beq     LC15D
        sec
        rts

LC15D:  clc
        rts

LC15F:  tax
        lda     #$01
        sta     $F3
        txa
        jmp     LC16E

LC168:  tax
        lda     #$00
        sta     $F3
        txa
LC16E:  sta     $F4
        lda     #$FF
        sta     $F5
        lda     #$03
        sta     $F6
LC178:  jsr     LC116
        lda     $F4
        jsr     LC0EF
        jsr     LC11C
        bcc     LC18E
        dec     $F6
        bpl     LC178
        lda     #$01
        jmp     LC1AA

LC18E:  lda     $F3
        beq     LC199
        jsr     LC13F
        bcs     LC19E
        bcc     LC1A3
LC199:  jsr     LC12C
        bcc     LC1A3
LC19E:  lda     #$02
        jmp     LC1AA

LC1A3:  jsr     LC154
        bcc     LC1AE
        lda     #$03
LC1AA:  sta     $F5
        sec
        rts

LC1AE:  clc
        rts

LC1B0:  jsr     LC1D0
        jsr     LC2ED
        jsr     LC1D9
        jsr     LC2ED
        jsr     LC1DD
        jsr     LC2ED
        rts

LC1C3:  lda     #$AA
        sta     $F0
        lda     #$AA
        sta     $F1
        lda     #$00
        jmp     LC0EF

LC1D0:  ldy     #$05
LC1D2:  jsr     LC1C3
        dey
        bne     LC1D2
        rts

LC1D9:  jsr     LC1C3
        rts

LC1DD:  jsr     LC0DC
        jsr     LC1C3
        rts

LC1E4:  lda     #$FF
        sta     $F5
        lda     #$00
        sta     $F0
        lda     #$01
        sta     $F1
        lda     #$00
        sta     $F7
        lda     #$00
        sta     $F8
        lda     #$00
        sta     $F9
        lda     #$01
        sta     $FA
        lda     #$00
        sta     $FB
        lda     #$00
        sta     $FC
        lda     #$02
        sta     $FD
        lda     #$BB
        sta     $FE
        lda     #$CC
        sta     $FF
        lda     #$03
        sta     $F6
LC218:  jsr     LC116
        jsr     LC0DC
        lda     #$09
        jsr     LC0EF
        jsr     LC11C
        bcc     LC231
        dec     $F6
        bpl     LC218
        lda     #$01
        jmp     LC242

LC231:  jsr     LC12C
        bcc     LC23B
        lda     #$02
        jmp     LC242

LC23B:  jsr     LC154
        bcc     LC246
        lda     #$03
LC242:  sta     $F5
        sec
        rts

LC246:  clc
        rts

        lda     #$01
        sta     $F0
        lda     #$03
        sta     $F1
        lda     #$00
        jmp     LC168

        lda     #$01
        sta     $F0
        lda     #$02
        sta     $F1
        lda     #$00
        jmp     LC168

LC262:  sta     $F7
        stx     $F8
        lda     #$02
        sta     $F0
        lda     #$02
        sta     $F1
        lda     #$02
        jmp     LC168

LC273:  sta     $F7
        lda     #$00
        sta     $F0
        lda     #$04
        sta     $F1
        lda     #$01
        jsr     LC0EF
        jsr     LC2ED
        rts

        lda     #$01
        sta     $F0
        lda     #$04
        sta     $F1
        lda     #$00
        jmp     LC168

        lda     #$01
        sta     $F0
        lda     #$05
        sta     $F1
        lda     #$00
        jmp     LC168

LC2A0:  lda     #$01
        sta     $F0
        lda     #$06
        sta     $F1
        lda     #$00
        jmp     LC168

        lda     #$00
        sta     $F7
        lda     #$01
        sta     $F8
        lda     #$00
        sta     $F9
        jsr     LC2A0
        bcs     LC2EB
        lda     $D108
        cmp     $F7
        bne     LC2EB
        lda     $F7
        bne     LC2D9
        lda     $D109
        cmp     $F8
        bne     LC2EB
        lda     $D10A
        cmp     $F9
        bcc     LC2EB
        clc
        rts

LC2D9:  lda     $D109
        cmp     $F8
        bcc     LC2EB
        bne     LC2E9
        lda     $D10A
        cmp     $F9
        bcc     LC2EB
LC2E9:  clc
        rts

LC2EB:  sec
        rts

LC2ED:  stx     $F3
        ldx     #$0A
LC2F1:  dex
        bne     LC2F1
        ldx     $F3
        rts

        lda     #$03
        sta     $F0
        lda     #$00
        sta     $F1
        lda     #$00
        jmp     LC168

        lda     #$03
        sta     $F0
        lda     #$01
        sta     $F1
        lda     #$03
        jmp     LC168

        lda     #$03
        sta     $F0
        lda     #$06
        sta     $F1
        lda     #$04
        jmp     LC15F

