.segment "CODE"

LDA #13 ; loads the number 13 into A
STA $00 ; stores the value in A into memory $00

LDA #$20 ; loads hex number 20 (which is 32) into A
STA $01 ; stores the value in A into memory $01

LDA #%00001111 ; loads binary number 00001111 (which is 15) into A
STA $02 ; stores the value in A into memory $02

LDA #$FF ; loads hex number FF (which is 255) into A
STA $03 ; stores the value in A into memory $03