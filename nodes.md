# Notes
not sure why but I wanted to teach myself this stuff suddenly lol


## Registers
- A - The Accumulator
- X - X register
- Y - Y register

Each register stores a byte, a number between 0 and 255

## Opcodes

ADC - Add with carry (adds to accumulator)

BEQ - Branch Equal, or "Branch if Equal"

CLC - Clear the carry

CMP - Compare accumulator against a value

CPX - Compare X against a value

CPY - Compare Y against a value

DEX - Decrement X (subtracts 1 from X register's value)

DEY - Decrement X (subtracts 1 from Y register's value)

INX - Increment X (adds 1 to X register's value)

INY - Increment Y (adds 1 to Y register's value)

JMP - Jump to a label

JSR - Jump to Subroutine

LDA - Load Accumulator

LDX - Load X register

LDY - Load Y register

PHA - Push Accumulator (stack operations)

PLA - Pull Accumulator (stack operations)

RTS - Return from Subroutine

SBC - Subtract with carry

SEC - Set carry

STA - Store accumulator (save results of math somewhere)

TAX - Transfer accumulator to X

## Operators and loading
The # operator is for numbers

#x is for decimal, like:
```
LDA #13 ; loads 13 into A
```

#%xx is for hexadecimal, like:

```
LDA #$0D ; loads 13 into A
```

#% is for binary, like:

```
LDA #%00001101 ; loads 13 into A
```

$x means memory location, like where to store numbers:
```
LDA #25 ; the number 25
STA $10 ; stores the number 25 into memory address $10
```

Likewise, we can load data from memory into registers:
```
LDA $10 ; loads the value at $10 into A
```

## Addressing modes

- Immediate
- Zero Page
- Absolute
- Indexed
- Indirect

| Address | Value |
| ------- | ----- |
| $0000   | 12    |
| $0001   | 42    |
| $0002   | 99    |
| $0003   | 17    |
| $0004   | 255   |

### Immediate addressing
```LDA #42 ; Loads the value 42 into A, simple enough```

### Zero Page addressing
```LDA $02 ; Loads the value at memory address $02, which is 99```

Zero page addressing gives us 256 addresses to work with, in the range of $0000 to $00FF.

This is called "zero page" addressing because the address is in the "zero" range between $0000 and $00FF. Zero page addressing are accessed with shorter instructions, making them run faster. On an NES, we reserve zero page memory for things like player X or Y positions, current health, enemy counters, or temporary calculations.

### Absolute addressing
```LDA $1234 ; loads the value at address $1234 into A```

The 6502 processor can address 65536 addresses, $0000 to $FFFF. This is important because some addresses access system RAM, others communicate with graphics, and others interact with controllers and sound hardware.

### Indexed addressing
Assume another table of addresses:

| Address | Value |
| ------- | ----- |
| $1000   | 10    |
| $1001   | 20    |
| $1002   | 30    |
| $1003   | 40    |
| $1004   | 50    |

What if we want to access different elements of this list without writing a different isntruction for every single address? 

```
LDX #2          ; load 2 into X register
LDA $1000,X     ; Adds X (2) to the base address $1000, which is $1002. Loads its value (30) into register A
```

This is conceptually the same as:
```
let numbers = [10,20,30,40,50];
let value = numbers[2]; // 30
```

Likewise, we can use register Y
```
LDY #3
LDA $1000,Y ; adds 3 to the address $1000, which becomes address $1003. The value 40 is stored there and is loaded into A
```

### Indirect addressing
This has to do with pointers. A pointer is a memory location that contains *another* memory address.

| Address | Value |
| ------- | ----- |
| $0010   | $34   |
| $0011   | $12   |
| $1234   | 99    |

Looking at this, the first two addresses in the table can describe address $1234. We need two bytes to store $1234 because it is too long. Indirect addressing lets us access this. Low-bit goes first. The ( ) parentheses denote a pointer.

```
LDA ($10),X ; reads $10 ($32) which is the low bit of the pointer. The next address is $11 ($12). Since the low bit goes first, the address is $1234. Loads the value stored at $1234, or 99, into register A.
```

#### Practice with indirect indexing
```
; assume $20 contains $00, and $21 contains $30
LDY #4 ; loads 4 into Y
LDA ($20), Y ;address $20 has $00. Since this is a pointer and pointers are two bytes long, it goes to $21, which is $30. Low bit goes first, so the pointed address is $3000. The ,Y gets from the Y register (4) and adds it to the address. The final address is $3004.
```

```
LDX #3 ; loads 3 into X register
LDA ($10,3) ; Offsets address $10 by X (3), which makes it $13. Since this is a pointer and is two bytes long, it becomes $13 and $14 for the pointer's location.
```

## Flags, comparisons, and branching

This is when the 6502 processor starts making decisions. These are the equivalents to `if`, `else`, and `while` loops.

The **process status register** is a special register, called P. Unlike registers A, X, and Y, the P register stores flags. A flag is a *single bit* that tells us something about the processor's current state. Here are the important flags:

- C: Carry, meaning to carry or borrow information
- Z: Zero, tells us whether a result is zero 
- I: Interrupt Disable, whether maskable interrupts are disabled (??)
- D: Decimal, decimal arithmetic mode
- B: Break, software interrupt status representation
- V: Overflow, signed arithmetic overflow
- N: Negative, wehtehr a result's highest bit is set

### The Zero Flag (Z)
The processor updates Z to indicate whether a result was zero or not. For example:

```LDA #0 ; sets the zero flag to 1 (true)```

```LDA $5 ; sets the zero flag to 0 (false)```

This matters because we can store the player's health in memory. If the health is zero, we can trigger a game over sequence.

### The Carry Flag (C)
The carry flag is for when arithmetic exceeds the capacity of a byte. For example, if A contains the value 255 and we execute:

```
LDA #255 ; Loads 255 into A
CLC        ; Clear the carry
ADC #1     ; Add with carry, adds 1 to A, which becomes 00 (rolls over)
; this sets the carry flag to 1
```

### The Negative Flag (N)
The negative flag is based on the highest bit of an 8-bit result. If it is 1, then the negative flag is set.
```
LDA #%00000101 ; loads 5, N is 0
LDA #%10000101 ; loads 133, N is 1 because the highest bit is 1.
```
This is because the 6502 processor interprets bytes as signed numbers (positive and negative) between -128 and +127.

The N flag doesn't literally mean the number is negative in all cases. It just means the highest bit is a 1.

### Comparing values with the CMP operator

CMP means "Compare Accumulator", meaning it compares a value with what is in the accumulator and updates the processor flags based on the result. Notably, it does NOT change the value in A.

The processor effectively performs a subtraction to determine the relationship beween the two values, putting the result in the Zero flag.

```
;;; CMP should return the equivalent of "true", which sets the Zero flag to 1
LDA #5
CMP #5
; result is 0, which sets the Zero flag to 1

;;; example with a return equivalent of "false", which sets the Zero flag to 0 (meaning "not zero")
LDA #5
CMP #4
; result is 1, which is not zero, so it sets to Zero flag to 0
```
Likewise this will set the Negative flag if it does subtraction for a negative number:
```
LDA #5
CMP #6
; sets zero flag to 0
; also sets Negative flag to 1 because 5 - 6 = -1
```

CPX and CPY are for comparing X or Y registers against a value

### Branching

BEQ - Branch equal, or "Branch if Equal"

Branches based on the Zero flag's value (branches if zero bit is a 1)

```
LDA #5
CMP #5
BEQ equal
    ; code skipped if the branch happens

equal: 
    ; code runs if equal!
```

Other branching instructions
- BEQ - Branch if equal (condition Z = 1) ***
- BNE - Branch if NOT equal (Z = 0) ***
- BCS - Branch if Carry is set (C = 1)
- BCC - Branch if Carry is clear (C = 0)
- BMI - Branch if minus, meaning result is negative (N = 1)
- BPL - Branch if plus, meaning result is positive (N = 0)
- BVS - Branch if oVerflow set (V = 1)
- BVC - Branch if oVerflow is clear (V = 0)

```
;;; Example: if the player has 3 health
LDA $00
CMP #0
BEQ gameOver
    ; continue playing

gameOver:
    ; game over screen!
```

### JMP - Jump to a label

```
LDA $00
CMP #0
BEQ gameOver;

; Player still has health
JMP continuePlaying

gameOver:
    ; Game over code goes here
    JMP finished

continuePlaying:
    ; Normal gameplay in here

finished:
    ; end of the game
```

## Loops

6502 doesn't have a built in `for` loop so we have to make one ourselves. We do this by using a register to keep track of our count, doing whatever instruction, and using a branch instruction to jump back up and repeat

Opcodes used here are INX, INY, DEX, DEY (increment and decrement X or Y registers)

```
LDX #5  ; sets x to 5
INX     ; increases x to 6

; likewise
LDX #5  ; sets x to 5
DEX     ; decreases x to 4
```

These opcodes update the Zero and Negative flags. We use that to control the loop

```
; Our first loop!
LDX #5
loop:
    DEX         ; decreases x by 1
    BNE loop    ; Branch if not equal, go to loop
; This loops 5 times
; code here runs after the loop is finished! :)
```

```
; Loop to keep adding 1 to A
LDA #0
LDX #5 ; loop 5 times
loop:
    CLC
    ADC #1 ; add 1 to A
    DEX    ; decrement X
    BNE loop
STA $00 ; stores value of A into memory
```

When looping down from a number to zero, BNE (branch if not equal) is perfectly fine. But when counting *up* from zero to another number, remember that BNE looks at the Zero flag. This code will fail:

```
LDX #0
loop:
    INX         ; increment x by 1
    BNE loop    ; branch if not equal (Zero) back to loop
; the zero flag is 0, which causes the branch to loop immediately. This loop will never end
```

```
; A CORRECT loop counting up from zero to five 
LDX #0
loop:
    ; do stuff
    INX         ; x = x + 1
    CPX #5      ; compare X with #5
    BNE loop
```

## Subroutines and the Stack

Subroutines are reusable chunks of code, like functions. We'll use these things for this:

- JSR - Jump to subroutine
- RTS - Return from subroutine
- The Stack - temporary storage
- PHA and PLA - push and pull from the stack (accumulator)

Example:

```
LDA #5
JSR doubleNumber ; jumps to doubleNumber

STA $00
; other program instructions...

doubleNumber:
    ASL A ; arithmetic shift left (doubles the number)
    RTS   ; return from subroutine

; the results of this stores the number 10 in $00
```

But how does RTS know where to go? The Stack!

The 6502 processor has a built-in stack located in memory addresses `$0100` to `$01FF` (256 bytes of stack space). There is a special register called Stack Pointer (S) that keeps track of where the top of the stack currently is. 

Two opcodes can put things onto the stack or pull from the stack. Those are PHA and PLA (push A and pull A)

```
LDA #10     ; save 10 to accumulator
PHA         ; Push A to stack (10)
LDA #25     ; save 25 to accumulator
PLA         ; Pull from stack, retrieves the saved 10
```

### Nested subroutines and the stack

```
LDA #5
JMP main

main:
    JSR calculate
    ; continue here afterwards

calculate:
    JSR doubleNumber
    RTS

doubleNumber:
    ASL A
    RTS
```

This is an example of a nested subroutine, or a sub that calls another sub. The 6502 processor will remember what is on the top of the stack.

The top of the stack is $01FF. The bottom of the stack is $0100. The stack points downward in memory. When the stack is empty, the stack pointer is $FF.

### Saving and restoring processor flags

- PHP: Push processor status onto the stack
- PLP: Pull processor status from the stack

These are the processor flags like Carry, Zero, Negative, Overflow, etc.

```
LDA #$FF    ; load $FF (255) into A
CLC         ; clear carry

PHP         ; Push processor status to the stack

SEC         ; Set carry
LDA #10     ; Load 10 into Accumulator
ADC #5      ; Add 5 to the accumulator

PLP         ; Pull processor status from the stack
```

A good rule of thumb is that every PHA needs a matching PLA, and every PHP needs a matching PLP. Don't leave things on the stack.

Something else to consider: JSR and RTS manage their own addresses. Don't pull them off the stack!