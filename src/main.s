;-----------------------------------------------------------------------------;
; Casey's Foray into NES Programming
;-----------------------------------------------------------------------------;

;-----------------------------------------------------------------------------;
; iNES Header
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

    ; disable APU frame interrupt
    LDX #$40
    STX $4017   ; $4017 is the APU's frame counter register, which controls the timing of the APU's audio channels and the generation of interrupts. Writing $40 to this register disables the APU's frame interrupt.
    
    ; stack initialization
    LDX #$FF    ; set stack pointer to $FF
    TXS         ; transfer X to stack pointer
    ; the stack lives at $0100-$01FF, so setting the stack pointer to $FF means that the stack will start at $01FF and grow downwards as values are pushed onto it.


    ; PPU initialization
    LDX #$00    ; loads a zero onto the X register
    STX $2000   ; $2000 is PPUCTRL, which controls various aspects of the PPU's operation, such as the name table to use, the background and sprite pattern tables, and the PPU's master/slave mode.
    STX $2001   ; $2001 is PPUMASK, which controls the rendering of the background and sprites, as well as the color emphasis and grayscale modes.
    STX $4010   ; Disable DMC IRQ generation


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

; write the color into PPU palette memory
LDA #$11    ; universal ackground color
STA $2007

LDA #$16    ; Palette color 1
STA $2007



;-----------------------------------------------------------------------------;
; Draw the room
;-----------------------------------------------------------------------------;

; set PPU address to the beginning of the nametable
LDA $2002
LDA #$20
STA $2006
LDA #$00
STA $2006

LDX #$20 ; hex for 32, we're going to draw 32 tiles


wallLoop:
    LDA #$01
    STA $2007
    DEX
    BNE wallLoop

    ; Draw floor tiles in remaining positions
    LDA #$00    ; tile 00, which is floor
    LDY #$03


floorOuterLoop:
    LDX #$00

floorInnerLoop:
    STA $2007
    DEX
    BNE floorInnerLoop

    DEY
    BNE floorOuterLoop

    ; Write final 160 floor tiles
    LDX #$A0

floorFinalLoop:
    STA $2007
    DEX
    BNE floorFinalLoop

;-----------------------------------------------------------------------------;
; Reset background scrolling
;-----------------------------------------------------------------------------;
LDA $2002
LDA #$00
STA $2005 ; set horizontal scroll to 0
STA $2005 ; set verfical scroll to 0

;-----------------------------------------------------------------------------;
; Turn on background rendering
;-----------------------------------------------------------------------------;
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


;-----------------------------------------------------------------------------;
; Character graphics
;-----------------------------------------------------------------------------;
.segment "CHARS"
.incbin "graphics/chr/floor.chr"