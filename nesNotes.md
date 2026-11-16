# NES Notes

The CPU communicates with the PPU via memory-mapped registers.

- CPU: Executes the code
- PPU: Creates the graphics
- Cartridge: Stores game code and data

## The CPU

The 6502 processor is an 8-bit processor with a 16-bit address bus, meaning it can access `2^16 = 65536` addresses. This is 64 KB of address space. Addresses run from `$0000` to `$FFFF`.

Different sections of that address space are assigned to different hardware. This arrangement is the *memory map*.

## The NES memory map

| Address Range | Device | Details |
| ------------- | ------ | ------- |
| $FFFF | Cartridge ROM | Game code and data |
| $6000 - $7FFF | Cartridge RAM | Optional, depends on cart |
| $4020 - $5FFF | Expansion / cart space | Additional hardware |
| $4000 - $401F | APU and I/O | Audio and controller hardware |
| $2000 - $3FFF | PPU registers | Graphics hardware (mirrored) |
| $0800 - $1FFF | Internal RAM mirrors | Repeats the first 2 KB |
| $0000 - $07FF | Internal RAM | 2 KB of actual RAM |

## Internal RAM
The first 2 KB of memory are RAM, where our variables live. The addresses are `$0000` to `$07FF`. 

```
; Example: Store 25 in $00, and store 10 in $01
LDA #25     ; loads 25 into A
STA $00     ; stores A into $00, the first address in the internal RAM
LDA #10
STA $01

; Retrieve value from ram, add them together
LDA $00     ; retrieves $00, which was 25
CLC         ; clear the carry
ADC $01     ; add $01 to A, A is now 25 + 10 = 35
```

The first 256 bytes ($00 to $FF) are Zero-Page and is quickly accessible by the CPU. This is where game variables will live.

## PPU registers
The PPU is the Picture Processing Unit, and it is in charge of displaying graphics on the screen. The PPU registers are from `$2000` to `$3FFF`.

```STA $2000 ; This would store data on the PPU registers, controlling the PPU```

The PPU has eight registers, mirrored throughout the memory map:

| Address | Register | Purpose |
| $2000 | PPUCTRL | Controls important PPU settings |
| $2001 | PPUMASK | Controls rendering options |
| $2002 | PPUSTATUS | Reports PPU status |
| $2003 | OAMADDR | Selects sprite memory position |
| $2004 | OAMDATA | Reads/writes sprite data |
| $2005 | PPUSCROLL | Sets background scrolling |
| $2006 | PPUADDR | Sets a PPU memory address |
| $2007 | PPUDATA | Reads/writes PPU memory |

For example:
```
LDA #$00    ; the hex number for 0
STA $2001   ; writes to PPUMASK, changes PPU's rendering configuration
; we haven't drawn anything yet, but this just shows communication with the graphics hardware.
```

## NES Input/Output

How does the CPU know when you press a button on the controller? Memory-mapped I/O! The addresses for controller 1 and controller 2 are `$4016` and `$4017` respectively. Each is a single byte (8 bits), which corresponds to each of the 8 inputs a controller can perform. Button order is:

1. A
2. B
3. Select
4. Start
5. Up
6. Down
7. Left
8. Right

## The Cartridge
The cartride stores the game on ROM chips. When the NES starts up, the CPU accesses portions of cartridge memory through its address space.

- $8000 - $BFFF: Program ROM
- $C000 - $FFFF: Program ROM

## How the NES draws pictures

Everything is a tile, 8x8 pixels wide (64 pixels total). Each NES tile uses two bitplanes to represent pixel color. Each bitplane is 8 bytes, one byte per row.

| BP1 | BP2 | Result  |
| --- | --- | ------- |
| 0   | 0   | Color 0 |
| 1   | 0   | Color 1 |
| 0   | 1   | Color 2 |
| 1   | 1   | Color 3 |

```
; example
Bitplane 1: 00111100
Bitplane 2: 01100110

; results
Pixel: 0 1 2 3 4 5 6 7
Color: 0 2 3 1 1 3 2 0
```

This gets the first 8 pixels of the tile. Do this for all 8 rows. Each pixel is described using 16 bytes. 

Now, this doesn't specify the actual *color* of the pixel. That comes from the NES's palette.

## CHR-ROM, CHR-RAM, and Pattern Tables
NES graphics are made up of 8x8 tiles, each of which occupies 16 bytes of data. These data live on CHR-ROM, or Character data. NES cartridges contail two kinds of ROM data: PRG-ROM for program instructions executed by the CPU, and CHR-ROM for graphical tile patterns executed by the PPU.

Some NES cartridges contain CHR-RAM instead to allow for writing RAM for graphics. That would be if a character changes appearance or generates graphics while running.

## Pattern tables
The PPU has its own address space, separate from the CPU's 64 KB address space. Within the PPU, the first $2000 bytes are for tile patterns (8 KB total). This is divided into two sections, called Pattern Tables. Each pattern table holds 256 8x8 tiles, amounting to 4096 bytes total.

- Pattern Table 0: $0000 - $0FFF
- Pattern Table 1: $1000 - $1FFF

The NES can be configured to use one pattern table for backgrounds, and one patern table for sprites. 

## Graphics and nametables
- Pattern table: What each tile looks like
- Nametable: Where the tile goes

A nametable is 32 tiles wide and 30 tiles tall, which is approximately the entire TV. This comes out to 256x240 pixels. There are 960 tiles in a nametable.

Nametables are stored in the PPU's memory, in `$2000-$2FFF`. This is 4 KB of memory, though the NES console only has 2 KB of video RAM (VRAM) for nametables. The address space can be arraned to mirror memory. This is called nametable mirroring and has configurations like horizontal mirroring, vertical mirroring, and four-screen mirroring.

**Attribute tables** are arrays at the end of each nametable that controls the palettes assigned to each part of the background.

## Sprites

Backgrounds are stationary. Sprites move independently. Sprites are stored on OAM, or Object Attribute Memory. OAM stores information about the sprites that the PPU should display.

Each sprite gets four bytes
- Byte 0: Y position
- Byte 1: Tile number
- Byte 2: Attributes (palette, flipping, priority)
- Byte 3: X position

The NES has room for 64 hardware sprites in OAM. With 64 sprites and 4 bytes per sprite, that's 256 bytes total.

When we draw characters, we have to consider the character's X and Y coordinates. Example assumes the sprite is 16x16 pixes (made of 4 tiles)

| Sprite | X Position | Y Position |
|-|-|-|
| Top-left | charX | charY |
| Top-right | charX + 8 | charY |
| Bottom-left | charX | charY + 8 |
| Bottom-right | charX + 8 | charY + 8 |

### Sprite Palettes
Each sprite palette has four entries. Color 0 is transparent. Colors 1-3 are actual sprite colors from the NES palette. There are four palettes at a time, based on the attribute bits

| Bits 1-0 | Palette |
| - | - |
| `00` | Palette 0 |
| `01` | Palette 1 |
| `10` | Palette 2 |
| `11` | Palette 3 |

Bits 6 and 7 are used for flipping sprites. Bit 6 is a horizontal flip. Bit 7 is the vertical flip.

Bit 5 determines sprite priority. Bit 0 is in front of the background. Bit 1 is behind it.

## OAM DMA - Getting Sprites onto the Screen

OAM is Object Attribute Memory, a special 256 byte area inside the PPU that stores information about all 64 hardware sprites. Each sprite gets those four bytes (see above).

The 6502 processor can't use STA to write to OAM addresses like it can to RAM. Instead, we have to use DMA - Direct Memory Access. We prepare all 256 bytes of data into the CPU RAM, then tell the NES to copy that into OAM. 

The NES has a memory-mapped register at `$4014` that triggers OAM DMA. Suppose we've prepared our sprite data at CPU RAM address $0200. We can transfer the page with two instructions:

```
LDA #$02    ; loads page $02 into the accumulator
STA $4014   ; stores A into PPU's OAM.
```

An important note about pages. A page is 256 bytes. The high byte of the address identifies the page.

| Value written to `$4014` | Source Address |
| - | - |
| $00 | $0000 - $00FF |
| $01 | $0100 - $01FF |
| $02 | $0200 - $02FF |
| $03 | $0300 - $03FF |

Example with a character:
```
.segment "ZEROPAGE"
fleeX: .res 1
fleeY: .res 1

.segment "OAM"
spriteData: .res 256
; this reserves a page of RAM for our shadow OAM
```

## VBlank - drawing on the screen
The PPU is responsible for drawing the picture onto the screen but it doesn't draw the entire screen all at once. It works through the display one scanline at a time. 

A standard NTSC NES frame has:
- 240 visible scanlines
- 1 post-render scanline
- 20 VBlank scanlines
- 1 pre-render scanline
- Total: 262 scanlines

VBlank stands for Vertical Blanking Interval. It's the short period of time after the PPU finishes drawing teh visible picture and before it starts drawing the next frame. During this time, the PPU isn't drawing visible pixels. This is important because we want to change sprite data during VBlank. 

We can know when VBlank starts by checking the PPUSTATUS register. This is located at `$2002`. One of its bits is VBlank flag (bit 7). When VBlank begins, that bit becomes 1. When the next frame begins, it gets cleared.

```
waitForVblank:
    BIT $2002           ; reads PPUSTATUS and updates processor flags
    BPL waitForVBlanks  ; Branch if plus (Negative flag = 0)
    ; the VBlank flag is bit 7, which is also the N flag
    ; if its 0, keep waiting
    ; if its 1, we continue
```

## Palettes and Colors

The pixels of each tile uses two bits, giving it one of four possible color options. The palette tells the PPU what those color options are. There are two kinds of palettes, one for backgrounds and one for sprites. The sprite palette's first entry is transparent, allowing the background to show through. 

- Background color index 0 is a "universal background" shared by all four background palettes. 
- Sprite color index 0 is transparent.

The PPU's palette memory stores the selection of palettes. Its main address range `is $3F00-$3F1F`.

## Bitplanes and turning pixels into binary
Every pixel is represented by two bits. The NES doesn't store these bits next to each other. They are instead stored in bitplanes.
- Bitplane 0 stores the first (least significant) bit
- Bitplane 1 stores the second (most significant) bit

Example:

```
Imagine we have the following 8-pixel row with these color indices:
0  1  2  3  1  0  2  3

They are stored as:
00 01 10 11 01 00 10 11

Bitplates
Bitplane 0: %01011001
Bitplane 1: %00110011
```