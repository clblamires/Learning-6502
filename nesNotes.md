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


