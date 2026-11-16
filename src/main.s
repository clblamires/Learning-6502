;-----------------------------------------------------------------------------;
.segment "HEADER"

; Creates the NES ROM header
.byte $4E, $45, $53, $1A    ; NES header
.byte $02                   ; PRG ROM size (2 * 16KB = 32KB)
.byte $01                   ; CHR ROM size (1 * 8KB = 8KB)
.byte $00                   ; Flags 6
.byte $00                   ; Flags 7
.res 8, $00                 ; Reserved



;-----------------------------------------------------------------------------;
; Program code
;-----------------------------------------------------------------------------;
.segment "CODE"

reset:
    SEI         ; set interrupt disable flag
    CLD         ; clear decimal mode flag
    ; strange because the NES's processor doesn't support decimal arithmetic, but the instruction is still present in the 6502 instruction set for compatibility with other 6502-based systems. Oh well ^_^

    ; disable APU frame interrupt
    LDX #$40
    STX $4017   ; $4017 is the APU's frame counter register, which controls the timing of the APU's audio channels and the generation of interrupts. Writing $40 to this register disables the APU's frame interrupt.
    
    ; stack initialization
    LDX #$FF    ; set stack pointer to $FF
    TXS         ; transfer X to stack pointer
    ; the stack lives at $0100-$01FF, so setting the stack pointer to $FF means that the stack will start at $01FF and grow downwards as values are pushed onto it.


    ; PPU initialization
    LDX #$00    ; loads a zero onto the X register
    STX $2000   ; $2000 is PPUCTRL1, which controls various aspects of the PPU's operation, such as the name table to use, the background and sprite pattern tables, and the PPU's master/slave mode.
    STX $2001   ; $2001 is PPUMASK, which controls the rendering of the background and sprites, as well as the color emphasis and grayscale modes.
    STX $4010   ; $4010 is the APU's DMC control register, which controls the operation of the DMC channel. Writing a zero to this register disables the DMC channel.


;-----------------------------------------------------------------------------;
; Wait for VBlank
;-----------------------------------------------------------------------------;
waitForVBlank:
    BIT $2002   ; $2002 is PPUSTATUS, which contains various status flags related to the PPU's operation, including the VBlank flag.
    ; this reads bit 7 of PPUSTATUS, which indicates if we're in VBlank (1) or not (0). 
    BPL waitForVBlank  ; is bit 7 set? If not, branch back to waitForVBlank.

waitForSecondVBlank:
    BIT $2002   ; read PPUSTATUS again
    BPL waitForSecondVBlank  ; wait for the next VBlank
; we do a second wait for VBlank because the first VBlank may have already started before we set up the PPU.

;-----------------------------------------------------------------------------;
; Load background color
;-----------------------------------------------------------------------------;
LDA $2002   ; reads PPUSTATUS, resets PPU address write toggle
LDA #$3F    ; high byte of the palette address
STA $2006   ; write high byte to PPU address register
LDA #$00    ; low byte of the palette address
STA $2006   ; write low byte to PPU address register

LDA #$23    ; this is purple-ish?
STA $2007   ; write the color to the PPU data register

; turn on background rendering
LDA #$0A
STA $2001


;-----------------------------------------------------------------------------;
; Main game loop
;-----------------------------------------------------------------------------;

mainLoop: 
    JMP mainLoop  ; infinite loop to keep the program running


;-----------------------------------------------------------------------------;
; Interrupts
;-----------------------------------------------------------------------------;
nmi:
    RTI         ; return from interrupt
irq:
    RTI         ; return from interrupt
    

    


;-----------------------------------------------------------------------------;
; Vectors
;-----------------------------------------------------------------------------;
.segment "VECTORS"
.word nmi     ; NMI vector
.word reset   ; Reset vector
.word irq     ; IRQ/BRK vector