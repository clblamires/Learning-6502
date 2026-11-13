;;; ADDITION
LDA #5      ; loads the number 5 into the accumulator
CLC         ; clears the carry flag before we add anything
ADC #3      ; adds the number 3 to the accumulator  

; Note that there is no ADC without carry, so we have to 
; explicitly clear the carry flag before adding.

; the result is 8, which is stored in the accumulator


;;; SUBTRACTION
LDA #9      ; loads the number 9 into the accumulator
SEC         ; sets the carry flag before we subtract anything
SBC #4      ; subtracts the number 4 from the accumulator

; Note that there is no SBC without carry, so we have to
; explicitly set the carry flag before subtracting.

; the result is 5, which is stored in the accumulator


;;; Storing results using STA
LDA #8      ; loads the number 8 into the accumulator
STA $00     ; stores the value in the accumulator at memory address $00
; the $ denotes memory address in hexadecimal notation :)