.segment "CODE"

main: 
    LDA #42
    JSR doSomething
    ; A is still 42 here
    JMP finished

doSomething:
    PHA         ; push A onto the stack
    LDA #100    ; load 100 into A
    ; do some operations with A
    PLA         ; pulls A from the stack (restoring it to 42)
    RTS

finished:
    