# SwitchCharROM
Switch between C64 character ROM sets (fonts) using [One ROM](https://github.com/piersfinlayson/one-rom) and [RBCP](https://github.com/piersfinlayson/rom-bus-control-protocol).

[One ROM](https://github.com/piersfinlayson/one-rom) is a hardware device by Piers Finlayson that replaces a Commodore 64 ROM chip and can store multiple ROM images in flash memory, switching between them under software control.

[RBCP (ROM Bus Control Protocol)](https://github.com/piersfinlayson/rom-bus-control-protocol) is a communication protocol, also by Piers Finlayson, that lets the 6510 CPU send commands to One ROM over the ROM data bus by performing carefully sequenced reads from specific addresses.

## One ROM Configuration (`CharacterROMSetsOneROM.json`)

`OneROM/CharacterROMSetsOneROM.json` is the One ROM Studio configuration file that
defines what gets flashed to the One ROM device.  It must be loaded into
[One ROM Studio](https://studio.onerom.org) to program the device before running
`SWITCH.BAS`.

### Structure

The file follows the [One ROM config schema](https://images.onerom.org/configs/schema.json)
and declares eight `rom_sets` (flash slots 0–7):

| Slot | Type | Description |
|------|------|-------------|
| 0 | `system_plugin` | System – USB (required for USB / One ROM Studio connectivity) |
| 1 | `user_plugin` | User – Host Control |
| 2 | `2332` | Original C64 Character ROM (`characters.901225-01.bin`) |
| 3 | `2332` | Custom Apple \]\[ Character ROM |
| 4 | `2332` | Custom ZX Spectrum Character ROM |
| 5 | `2332` | Custom Minecraft Character ROM |
| 6 | `2332` | Custom Aniron Character ROM (Tolkien inspired) |
| 7 | `2332` | Custom Aurebesh Character ROM (Star Wars inspired) |

Slots 2–7 map to menu options 1–6 in `SWITCH.BAS`.  Each character ROM entry is
typed `2332` (the chip type of the original C64 character ROM socket) with
`cs1: active_low` and `cs2: active_high` to match the C64 hardware chip-select
wiring.  The ROM images are downloaded directly from their public URLs by One ROM
Studio at flash time, so no local ROM files are needed.

### How To Flash With One ROM Studio

1. Open [One ROM Studio](https://studio.onerom.org) in a Chromium-based browser
   (Web Serial is required).
2. Connect the One ROM device to your computer via USB.
3. Click **Load Config** and select `OneROM/CharacterROMSetsOneROM.json`.
4. One ROM Studio will fetch all ROM images from the URLs in the config and show
   you the slot layout.
5. Click **Flash** to program all slots onto the device.
6. Insert the programmed One ROM into the C64 character ROM socket. TRIPLE CHECK
the orientation and the location of the replacement ROM.
7. Run `SWITCH.BAS` on the C64. Voilà, you can swap fonts without opening the case and
playing with jumpers.

## What This Project Does
This project loads machine language at `$C000`, asks the user which font to use,
and sends RBCP commands to One ROM to switch to that character ROM set.

At runtime:
1. BASIC provides a small menu and gets the selected set number.
2. BASIC loads the machine language (6502/6510 code) to 49152
3. BASIC passes the selected set number to the machine language
4. BASIC runs machine code.
5. Machine code stops interrupts
6. Machine code disables keyboard interrupts
7. Machine code enables character ROM and hides I/O
8. Machine code copies the character ROM to RAM
9. Machine code copies the screen content to RAM
10. Machine code enables I/O and hides character ROM
11. Machine code temporarily remaps VIC-II to RAM.
     - This ensures the VIC-II will not access the character ROM
     - This avoids having to disable the screen (no flicker!)
12. Machine code enables character ROM and hides I/O
13. Machine code uses RBCP to load and switch to the selected slot.
14. Machine code restores interrupts, keyboard and VIC-II
15. Control returns to BASIC 
16. BASIC resets the screen
17. BASIC displays status/error bytes
18. BASIC displays the first 16 bytes (two-character map) of the
    character ROM before it was changes
19. BASIC offers to soft reset the Commodore 64
20. The USER lives in the bliss of a new cool font. Life is good.

## Runtime Flow (From `main.bas`)

### 1. Shrink BASIC RAM
`main.bas` first lowers top-of-memory (`POKE 55,0 : POKE 56,52 : CLR`) so RAM at
`$3000` is available for a copy of the character glyph data.

### 2. Optional Screen Clear
`SYS 58692` is called before and after the switch operation. This resets VIC-II
screen pointers.

### 3. Show ROM Menu
The program prints available font sets (`1..6`) and asks:
- `1..6` to switch
- `N` or `Q` to quit

### 4. Validate Selection
Input is converted with `VAL(a$)` and checked to ensure `1 <= c <= 6` as the 
image has only six character ROMs. The first one is the Commodore 64 standard
one.

### 5. Load Machine Code Into `$C000-$CFFF`
`DATA` bytes are copied into memory from address `49152` (`$C000`) upward.
The bytes come from the compiled assembly (via the build pipeline).

### 6. Pass Selected Font Set To Machine Code
`POKE i+20, c` stores the selected set number into the ML variable `_set_nb_c`
before execution. This is how I passed the font/slot number. The other option
would be to use POKE 781, X : SYS 49152 but it prooved harder to debug.

### 7. Run Machine Code
`SYS 49152` runs the assembly entry point. Classic $C000.

### 8. Print Status And Debug Values
After return, BASIC prints:
- `peek(i)` as primary error code (`_error`)
- `peek(i+1)` as RBCP detail code (`_error+1`)
- the first 16 bytes sampled from char ROM (stored after `_error`) for verification

If the One ROM device (Fire 24e RP2350) could not be reached, you'd likely get an
error 6 and a ZP 5 code of 1 (failed to enter RBCP mode). Also the 16 bytes would
read alternating 255 and 0 if the character ROM could not be enabled.

### 9. Exit Choice
At the end, user can soft-reset (`SYS 64738`) or end normally. If you end normally,
your Commodore 64 BASIC memory is still restricted to 11,263 bytes, an unused
copy of the screen lies at $5C00 (RAM), and an unused copy of the (old) character set
takes 4 kilobytes at $3000 (RAM).

## Runtime Flow (From `main.s`)

### 1. Enter Safe State
- Disable CPU interrupts (`SEI`) to avoid accidental ROM bus reads during RBCP.
- Disable keyboard CIA interrupts temporarily.
- Ensure character ROM is visible at `$D000` (clear bit 2 in `$01`).

### 2. Copy Character ROM To RAM
Copy `4 KB` from `$D000-$DFFF` to `$3000-$3FFF` (16 pages x 256 bytes).

### 3. Keep Screen Stable
Copy screen RAM from `$0400-$07FF` to `$5C00-$5FFF` so display remains readable
after VIC-II remap.

### 4. Repoint VIC-II To RAM Glyphs
- Save old VIC bank (`$DD00`) and old pointer register (`$D018`).
- Switch VIC bank to bank 1 (`$4000-$7FFF`).
- Update `$D018` so screen points to `$5C00` and charset points to `$3000`.

This stops VIC-II from fetching glyphs from the ROM bus while RBCP runs. THIS 
IS CRUCIAL. THIS DIFFERS FROM THE WAY PIERS FINLAYSON AND HOLGER GRYSKA's
BOOTLOADERS WORK! For the Kernal ROM, there is no need to worry about the VIC-II
activity. And, to the contrary of a bootloader, the present character ROM
switcher does not have to start a complicated gymnastic due to the fact it has
to run first and in the RAM...

### 5. Re-enable CPU View Of Char ROM
Set `$01` to make char ROM visible to CPU again (still safe for VIC-II because VIC
is now using RAM copy).

### 6. Verify ROM Visibility
Copy first 16 bytes at `$D000` into `_error+2...` for diagnostics.

### 7. Perform RBCP Sequence
Call imported RBCP routines:
1. `rbcp_reset`
2. `rbcp_cmd_enter_cmd_resp`
3. `rbcp_cmd_load_slot` (RAM slot `1`, flash slot from `_set_nb_c`)
4. `rbcp_cmd_switch_and_exit` (switch to RAM slot `1`)

Note _set_nb_c is equal to I+20 in the BASIC code.

Carry flag checks determine success/failure and update `_error`/`_error+1`.

### 8. Restore Hardware State And Return
Before `RTS`:
- restore CPU memory map (`$01`)
- restore VIC pointer (`$D018`) and bank (`$DD00`)
- restore keyboard interrupt control (`$DC0E`)
- re-enable interrupts (`CLI`)

## Error / Status Bytes Returned To BASIC
These bytes are stored in BSS and read by BASIC after `SYS 49152`:

- `_error` (`peek(i)`): primary status
- `_error+1` (`peek(i+1)`): RBCP detail from `rbcp_zp_5` when command-response mode fails
- `_error+2` onward: first 16 bytes sampled from `$D000` for verification

Current `_error` meanings in `main.s` comments:
- `0`: success
- `1..7`: intermediate failure states during setup/RBCP flow

## Build Pipeline Summary
The workspace tasks do the full pipeline:
1. compile assembly with `cl65`
2. run post-process script
3. convert BASIC text to PETSCII with `petcat`
4. optional disassembly check with `da65`
5. create `switch.d64` with `c1541`

Use the default task: **Build All (Compile + BASIC + PETSCII + DA65 Check + D64 floppy disk)**.

I use CC65 as a compiler, basic Python to turn the binary into BASIC DATA fields, and
VICE tools to make a new (virtual) floppy disk with the program SWITCH.BAS after each
compilation.

## Lawsuits
I am not responsible for the good or bad usage of this code. If you fall in love with One ROM (like me),
for its absolute genius design and flawless execution, it is not my fault if you neglect your friends and 
family in the pursuit of ever cooler applications... And find yourself typing these lines at 9:07 PM 
on a Saturday night!

If you fry your beloved Commodore 64 by pluging One ROM upside down, you will have to fix it
yourself by watching Robin at 8-Bit Show And Tell, or Adrian Blake, or The 8-Bit Guy, or Mark
at TheRetroChannel. It will cause you to spend hundreds of dollars and hours to do what you 
could have done on your Intel / AMD laptop with VICE for $0. This is the (small) price to pay
for being a Level V geek...