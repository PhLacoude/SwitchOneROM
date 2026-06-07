; da65 V2.19 - Git cc3c40c
; Created:    2026-06-07 18:33:35
; Input file: D:\Google Drive\My Code\6502\CC65\SwitchCharROM/build/main.bin
; Page:       1


        .setcpu "6502"

        sei
        lda     #$01
        sta     $C32F
        lda     #$00
        sta     $C330
        lda     $DC0E
        sta     $C345
        and     #$FE
        sta     $DC0E
        lda     #$02
        sta     $C32F
        lda     $01
        sta     $C344
        and     #$FB
        sta     $01
        lda     #$03
        sta     $C32F
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
        lda     $C344
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
        sta     $C341
        and     #$FC
        ora     #$02
        sta     $DD00
        lda     $D018
        sta     $C342
        and     #$F1
        ora     #$0C
        sta     $D018
        lda     $01
        and     #$FB
        sta     $01
        ldx     #$00
LC07C:  lda     $D000,x
        sta     $C331,x
        inx
        cpx     #$10
        bne     LC07C
        jsr     LC1C1
        lda     #$04
        sta     $C32F
        jsr     LC1F5
        lda     #$05
        sta     $C32F
        bcc     LC0A6
        lda     #$06
        sta     $C32F
        lda     $F5
        sta     $C330
        jmp     LC0D3

LC0A6:  jsr     LC259
        lda     #$07
        sta     $C32F
        bcs     LC0D3
LC0B0:  lda     $D109
        eor     #$01
        sta     $C346
        ldx     $C343
        jsr     LC273
        bcc     LC0C8
        lda     #$08
        sta     $C32F
        jmp     LC0D3

LC0C8:  lda     $C346
        jsr     LC284
        lda     #$00
LC0D0:  sta     $C32F
LC0D3:  lda     $01
        ora     #$04
        sta     $01
        lda     $C342
        sta     $D018
        lda     $C341
        sta     $DD00
        lda     $C345
        sta     $DC0E
LC0EB:  cli
        rts

LC0ED:  lda     $D021
        lda     $D052
        lda     $D042
        lda     $D043
        lda     $D050
        lda     $D021
        rts

LC100:  sta     $F4
        lda     $F0
        sta     LC108
        .byte   $AD
LC108:  brk
        bne     LC0B0
        sbc     ($8D),y
        bpl     LC0D0
        lda     $D000
        lda     $F4
        beq     LC126
        tax
        ldy     #$00
LC119:  lda     $F7,y
        sta     LC120
        .byte   $AD
LC120:  brk
        bne     LC0EB
        dex
        bne     LC119
LC126:  rts

LC127:  lda     $D102
        sta     $F2
        rts

LC12D:  ldx     #$FF
LC12F:  lda     $D102
        cmp     $F2
        bne     LC13B
        dex
        bne     LC12F
        sec
        rts

LC13B:  clc
        rts

LC13D:  ldx     #$FF
LC13F:  lda     $D104
        cmp     #$BB
        beq     LC14E
        jsr     LC2FE
        dex
        bne     LC13F
        sec
        rts

LC14E:  clc
        rts

LC150:  ldx     #$FF
        ldy     #$FF
LC154:  lda     $D104
        cmp     #$BB
        beq     LC163
        dex
        bne     LC154
        dey
        bne     LC154
        sec
        rts

LC163:  clc
        rts

LC165:  lda     $D105
        cmp     #$CC
        beq     LC16E
        sec
        rts

LC16E:  clc
        rts

LC170:  tax
        lda     #$01
        sta     $F3
        txa
        jmp     LC17F

LC179:  tax
        lda     #$00
        sta     $F3
        txa
LC17F:  sta     $F4
        lda     #$FF
        sta     $F5
        lda     #$03
        sta     $F6
LC189:  jsr     LC127
        lda     $F4
        jsr     LC100
        jsr     LC12D
        bcc     LC19F
        dec     $F6
        bpl     LC189
        lda     #$01
        jmp     LC1BB

LC19F:  lda     $F3
        beq     LC1AA
        jsr     LC150
        bcs     LC1AF
        bcc     LC1B4
LC1AA:  jsr     LC13D
        bcc     LC1B4
LC1AF:  lda     #$02
        jmp     LC1BB

LC1B4:  jsr     LC165
        bcc     LC1BF
        lda     #$03
LC1BB:  sta     $F5
        sec
        rts

LC1BF:  clc
        rts

LC1C1:  jsr     LC1E1
        jsr     LC2FE
        jsr     LC1EA
        jsr     LC2FE
        jsr     LC1EE
        jsr     LC2FE
        rts

LC1D4:  lda     #$AA
        sta     $F0
        lda     #$AA
        sta     $F1
        lda     #$00
        jmp     LC100

LC1E1:  ldy     #$05
LC1E3:  jsr     LC1D4
        dey
        bne     LC1E3
        rts

LC1EA:  jsr     LC1D4
        rts

LC1EE:  jsr     LC0ED
        jsr     LC1D4
        rts

LC1F5:  lda     #$FF
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
LC229:  jsr     LC127
        jsr     LC0ED
        lda     #$09
        jsr     LC100
        jsr     LC12D
        bcc     LC242
        dec     $F6
        bpl     LC229
        lda     #$01
        jmp     LC253

LC242:  jsr     LC13D
        bcc     LC24C
        lda     #$02
        jmp     LC253

LC24C:  jsr     LC165
        bcc     LC257
        lda     #$03
LC253:  sta     $F5
        sec
        rts

LC257:  clc
        rts

LC259:  lda     #$01
        sta     $F0
        lda     #$03
        sta     $F1
        lda     #$00
        jmp     LC179

        lda     #$01
        sta     $F0
        lda     #$02
        sta     $F1
        lda     #$00
        jmp     LC179

LC273:  sta     $F7
        stx     $F8
        lda     #$02
        sta     $F0
        lda     #$02
        sta     $F1
        lda     #$02
        jmp     LC179

LC284:  sta     $F7
        lda     #$00
        sta     $F0
        lda     #$04
        sta     $F1
        lda     #$01
        jsr     LC100
        jsr     LC2FE
        rts

        lda     #$01
        sta     $F0
        lda     #$04
        sta     $F1
        lda     #$00
        jmp     LC179

        lda     #$01
        sta     $F0
        lda     #$05
        sta     $F1
        lda     #$00
        jmp     LC179

LC2B1:  lda     #$01
        sta     $F0
        lda     #$06
        sta     $F1
        lda     #$00
        jmp     LC179

        lda     #$00
        sta     $F7
        lda     #$01
        sta     $F8
        lda     #$00
        sta     $F9
        jsr     LC2B1
        bcs     LC2FC
        lda     $D108
        cmp     $F7
        bne     LC2FC
        lda     $F7
        bne     LC2EA
        lda     $D109
        cmp     $F8
        bne     LC2FC
        lda     $D10A
        cmp     $F9
        bcc     LC2FC
        clc
        rts

LC2EA:  lda     $D109
        cmp     $F8
        bcc     LC2FC
        bne     LC2FA
        lda     $D10A
        cmp     $F9
        bcc     LC2FC
LC2FA:  clc
        rts

LC2FC:  sec
        rts

LC2FE:  stx     $F3
        ldx     #$0A
LC302:  dex
        bne     LC302
        ldx     $F3
        rts

        lda     #$03
        sta     $F0
        lda     #$00
        sta     $F1
        lda     #$00
        jmp     LC179

        lda     #$03
        sta     $F0
        lda     #$01
        sta     $F1
        lda     #$03
        jmp     LC179

        lda     #$03
        sta     $F0
        lda     #$06
        sta     $F1
        lda     #$04
        jmp     LC170

