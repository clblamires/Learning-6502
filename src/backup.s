;-----------------------------------------------------------------------------;
; Clear the nametable
;-----------------------------------------------------------------------------;
LDA $2002 ; read PPUSTATUS
LDA #$20
STA $2006
LDA #$00
STA $2006

; load zero into A
LDA #$00

; write three groups of 256 bytes
LDY #$03

nametableOuterLoop:
    LDX #$00

nametableInnerLoop:
    STA $2007
    DEX
    BNE nametableInnerLoop

    DEY
    BNE nametableOuterLoop

    ; 960 - 256 - 256 - 256 = 192 bytes remaining
    ; 192 in hex is $C0
    LDX #$C0

nametableFinalLoop:
    STA $2007
    DEX
    BNE nametableFinalLoop
