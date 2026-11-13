.segment "CODE"

; we're going to do the following calculations
; first is 5+3
; second is 9 - 4


LDA #5
CLC
ADC #3
STA $00

LDA #9
SEC
SBC #4
STA $01

; omg :)

; Quiz:
; What are the values in A and X at the end of these instructions?
LDA #10
CLC
ADC #7
TAX
INX
STA $02
; A = 17, X = 18
; nailed it
