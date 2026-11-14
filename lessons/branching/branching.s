.segment "CODE"

; check whether A equals 10

LDA #10
CMP #10
BEQ equal

; this runs if A is not equal to 10
LDA #0
JMP finished

equal:
    ; this runs if A is equal to 10
    LDA #1
    JMP finished ; this isn't super necessary but it makes me feel better

finished:
    STA $00