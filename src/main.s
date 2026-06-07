; 6502 Assembly code to switch the C64 character ROM using Piers Finlayson's 
; ROM Bus Control Protocol (RBCP) library.
; https://github.com/piersfinlayson/rom-bus-control-protocol

; Copyright (C) 2026 Philippe Lacoude

; CC65 Linker Compatibility Placeholders
; ---------------------------------------------------------
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

; Pull in RBCP constants (e.g., rbcp_zp_5) without inlining RBCP code.
.include "./piers/defs.s"

.import rbcp_reset
.import rbcp_cmd_enter_cmd_resp
.import rbcp_cmd_get_ram_slot_info_all
.import rbcp_cmd_load_slot
.import rbcp_cmd_switch_and_exit

; Hardware Registers
PROCESSOR_PORT = $01
VIC_MEMORY_REG = $D018
MEMORY_BANK = $DD00
KEYBOARD_CTRL = $DC0E

; Target configuration constants
; Source Char ROM location (when mapped in)
ROM_CHAR_SRC   = $D000
; We will copy the first 16 bytes of the character ROM here 
; to check it's enabled
ROM_CHAR_CHECK = _error+2  
; Safe RAM destination inside VIC Bank 0 ($3000-$3FFF)
RAM_CHAR_DEST  = $3000      
; Original screen RAM is at $0400-$07FF
SCREEN_RAM_SRC = $0400
; New screen location
SCREEN_RAM_DEST = $5C00

.segment "CODE"

start:
    ; Disable interrupts - This is important for reliable RBCP operation, as
    ; interrupts will cause reads from the ROM that the RBCP device will
    ; interpret as commands.
    sei

	; Set error flag to 1, ZP 5 to 0
	lda #1
	sta _error
	lda #0
	sta _error+1

	; While we are at it, turn off keyboard interrupts, which will cause the 
	; keyboard to stop responding until we reset the device.  This is not 
	; strictly necessary, but if we were in BASIC, we would execute
	; POKE 56334, PEEK(56334) AND 254 to achieve the same effect.
	; Turns bit 0 off : AND 11111110 (FE, 254)
	lda KEYBOARD_CTRL
	sta _old_kb
	and #$FE
	sta KEYBOARD_CTRL

	; Set error flag to 2
	lda #2
	sta _error

	; Make sure the character ROM is enabled, in case we were called from BASIC 
	; with it disabled. This is equivalent to POKE 1, PEEK(1) AND 251 in BASIC.
	; Turns bit 2 back off : AND 11111011 (FB, 251)
	lda PROCESSOR_PORT
	sta _old_01
	and #$FB ; → char ROM visible at $D000
	sta PROCESSOR_PORT

	; Set error flag to 3
	lda #3
	sta _error

	; Now, we will move the character ROM image to RAM, and switch to it, 
	; which will cause the VIC-II to read the character data from RAM instead 
	; of ROM, preventing the VIC-II from interfering with our attempts to 
	; communicate with One ROM via the ROM bus (RBCP)
    ldx #16             ; 16 pages = 4096 bytes
    ldy #0
copyCharROM:
    lda ROM_CHAR_SRC, y
    sta RAM_CHAR_DEST,y
    iny
    bne copyCharROM
    inc copyCharROM+2   ; self-modify source high byte
    inc copyCharROM+5   ; self-modify dest high byte
    dex
    bne copyCharROM

    ; Disable the character ROM so we can see the I/O area
    lda _old_01
	; restore memory map
    sta PROCESSOR_PORT

    ; Copy current screen RAM to $5C00 so display doesn't 
	; turn to garbage
    ldx #4
    ldy #0
copyScreen:
    lda SCREEN_RAM_SRC,y
    sta SCREEN_RAM_DEST,y
    iny
    bne copyScreen
    inc copyScreen+2
    inc copyScreen+5
    dex
    bne copyScreen

    ; --- Switch VIC-II to bank 1 + set pointers ---
    ;   Final Address = VIC Bank Starting Address (set by MEMORY_BANK $DD00) 
	;                 + Offset (Set by VIC_MEMORY_REG $D018)

    ; Bank 1 ($4000-$7FFF)
    lda MEMORY_BANK
	sta _old_bank
    and #%11111100
    ora #%00000010          ; bits 0-1 = %10
    sta MEMORY_BANK

    ; Point VIC-II to look at RAM ($3000) instead of ROM ($D000)
    ; VIC_MEMORY_REG ($D018) = $14 (0001 010 0) : Screen at $0400, Chars at $D000 (ROM)
    ; VIC_MEMORY_REG ($D018) = $7C (0111 110 0) : Screen at $5C00, Chars at $3000 (RAM)
	;
	; Bits 7–4 (VM3–VM0): Selects the starting address of the Screen Matrix (in 
	;                       increments of 1,042 bytes / 1KB)
	; Bits 3–1 (CM3–CM1): Selects the starting address of the Character Generator (in
	;                       increments of 4KB). 010 is default uppercase ROM
	;                                           011 is default lowercase ROM
	;                                           110 is the first 4KB of RAM ($3000-$37FF)
	; Bit 0:              Unused by the VIC-II (it always reads back as a 1)
	;
	; To point the VIC-II to the character data we copied to RAM, we need to set
	;     bits 3-1 to % 110 (6 in decimal) to select $3000-$37FF
	;     bits 7-4 to %0111 (7 in decimal) to select $5C00-$5FFF
	lda VIC_MEMORY_REG
	sta _old_d018
	and #%11110001          ; Clear character base selection bits (bits 1-3)
    ora #%00001100          ; Set bits 2 and 3 (%110 -> 12) to select RAM at $3000
	sta VIC_MEMORY_REG

	; At this point, the character ROM is disabled, and the VIC-II is switched to bank 1 
	; and pointed to the RAM we copied the character data to, so we can now safely access 
	; the ROM bus without the VIC-II interfering, which will allow us to use RBCP to 
	; switch the character ROM set.

	; We need to re-activiate the character ROM (without re-enabling it for the VIC-II) so 
	; we can use RBCP to switch the character ROM set.
	lda PROCESSOR_PORT
	and #$FB ; → char ROM visible at $D000
	sta PROCESSOR_PORT

	; check the character ROM is enabled by reading the first 16 bytes (@ and A)
	; of the character ROM, and copying them to an array after the error codes
	ldx #$00             ; Initialize index to 0
checkCharROM:
	lda $D000,x          ; Read from character ROM (@ and A start at $D000)
	sta ROM_CHAR_CHECK,x ; Store at _error+2
	inx                  ; Increment index
	cpx #$10             ; Compare with 16
	bne checkCharROM     ; Branch if not equal
	
resetOneROM:
    ; Reset the device's RBCP implemenation, to ensure it's in a known state
    ; before attempting to communicate.
    jsr rbcp_reset

	; Set error flag to 4
	lda #4
	sta _error

areWeIn:
    ; Put the device into command-respond mode.  Uses configuration from
    ; rbcp_config.s
    jsr rbcp_cmd_enter_cmd_resp

	; Set error flag to 5
	lda #5     ; Note: this does not clear the carry flag
	sta _error ; Note: this does not clear the carry flag

	; This branch relies on an implicit calling convention that 
	; rbcp_cmd_enter_cmd_resp indicates success/failure via the CPU 
	; carry flag (C clear => success).
    bcc loadToRAMslot1

	; Set error flag to 6
	lda #6
	sta _error

	; failed to enter RBCP cmd-resp mode, exit with error rbcp_zp_5, 
	; which contains the error code from the failed command, which we 
	; can return to the caller.
	lda rbcp_zp_5
	sta _error+1
    jmp exit

loadToRAMslot1:
    ; find free RAM slot to load the new ROM image to.
    jsr rbcp_cmd_get_ram_slot_info_all
	lda #7     ; Note: this does not clear the carry flag
	sta _error ; Note: this does not clear the carry flag
	bcs exit

    ; If the active RAM slot is zero, use RAM slot 1,
	; and vice versa
	lda RBCP_DATA_ADDR + 1 ; Field 'active_slot'
	eor #$01
	sta _active_slot

    ; Load another ROM image from flash to an unused RAM slot
    ldx _set_nb_c   ; Flash slot
    jsr rbcp_cmd_load_slot
    bcc loadedNowSwitch

	; Set error flag to 8
	lda #8
	sta _error

	; Failed to load the RAM slot, exit with error
	jmp exit

loadedNowSwitch:
    ; Switch to the new RAM slot and exit command-respond mode, which will
    ; cause the device to start executing from the new RAM slot.
    lda _active_slot ; RAM slot to switch to
    jsr rbcp_cmd_switch_and_exit

	; We've reached this point, so the command was successfully sent to the 
	; device.
	lda #0 ; Success
	sta _error

exit:
	; Exit the program i.e. return to BASIC
	; _error will be 0 if we succeeded, or 1, 2, 3,... if we failed to switch
	; the character ROM set

    ; Error codes:
	;   0 = Success
	;   1 = Interrupts were not disabled
	;   2 = Character ROM was not enabled
	;   3 = Failed to rbcp_reset
	;   4 = Failed to enter command-response mode
	;   5 = Failed to rbcp_cmd_load_slot
	;   6 = Failed to rbcp_cmd_enter_cmd_resp (carry is set, check ZP 5)
	;   7 = Failed to find active RAM slot (carry is set)
	;   8 = Failed to rbcp_cmd_load_slot (carry is set)

    ; rbcp_cmd_enter_cmd_resp error codes returned to BASIC via _error+1 :
	;   0 = Success
    ;   1 = Token poll timeout (command not received / silently discarded)
    ;   2 = Progress poll timeout (received but never completed)
    ;   3 = Response = FAILED

    ; Restore character ROM to disabled state, in case we return to BASIC
	; or some other code that expects it to be disabled. Restore I/O.
	; This is equivalent to POKE 1, PEEK(1) OR 4 in BASIC.
	; Turns bit 2 back on : OR 00000100
	lda PROCESSOR_PORT
	ora #$04
	sta PROCESSOR_PORT

    ; The $D000-$D3FF range now points to the I/O area, reserved for the 
	; VIC-II, so we can now safely switch the VIC-II back to VIC bank 0.

	; Restore the VIC bank to the default of bank 0, which is where the
	; character ROM is mapped.

    ; Restore pointer first (while still in temp bank)
    lda _old_d018
    sta VIC_MEMORY_REG

    ; Switch back to VIC bank 0
    lda _old_bank
    sta MEMORY_BANK

	; We are now pointing the VIC-II back to the character ROM, and the 
	; screen RAM is back to the original location. We did not copy the
	; screen RAM back, because we never wrote anything to it.

    ; Restore keyboard interrupts
	; This is equivalent to POKE 56334, PEEK(56334) OR 1 in BASIC.
	; Turns bit 0 back on : OR 00000001
	lda _old_kb
	sta KEYBOARD_CTRL

    ; Re-enable interrupts before exiting, in case we return to BASIC or some
	; other code that expects them to be enabled.
	cli

	rts

; Reserve:
; rts+1  - one byte in writable RAM for the error code to return
;          to BASIC. 0 = success, nonzero = failure.
; rts+2  - one byte in writable RAM to return the error code from
;          rbcp_cmd_enter_cmd_resp if it fails, which may be useful 
;          for debugging.
; rts+3  - first 16 bytes of the character ROM to make sure it's enabled
; rts+19 - one byte to save the old VIC bank
; rts+20 - one byte to save the old $D018 value
; rts+21 - one byte to pass the char ROM set number to the machine 
;          language code, which will be used by the RBCP device to 
;          determine which char ROM set to switch to.
; rts+22 - one byte to save the old value of $01, which controls 
;          the char ROM visibility
.segment "BSS"
_error:       .res 18
_old_bank:    .res 1
_old_d018:    .res 1
_set_nb_c:    .res 1
_old_01:      .res 1
_old_kb:      .res 1
_active_slot: .res 1