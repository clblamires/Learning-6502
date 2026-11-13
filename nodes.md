# Notes
not sure why but I wanted to teach myself this stuff suddenly lol


## Registers
- A - The Accumulator
- X - X register
- Y - Y register

Each register stores a byte, a number between 0 and 255

## Opcodes

ADC - Add with carry

CLC - Clear the carry

INX - Increment X (adds 1 to X register's value)

LDA - Load Accumulator

LDX - Load X register

LDY - Load Y register

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


