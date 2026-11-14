.segment "CODE"

.org $8000

reset: 
    LDA #$42
    STA $00
    RTS