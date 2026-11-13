.segment "CODE" ; start of the code segment

; immediate indexing
LDA #42 ; life, the universe, and everything, stored in A
STA $00 ; stores the value in A into memory $00

; zero page
LDA $00 ; loads the value from memory $00 into A
STA $01 ; stores the value in A into memory $01

; absolute
LDA $1234 ; loads the value from memory $1234 into A, whatever is stored there
STA $02 ; stores the value in A into memory $02

; indexed
LDX #3 ; loads the value 3 into X
LDA $1000,X ; loads the value from memory $1003 into A
STA $03 ; stores the value in A into memory $03

; indirect indexed
LDY #2 ; loads the value 2 into Y
LDA ($10),Y ; loads the value from the address stored in $10,Y into A
STA $04 ; stores the value in A into memory $04