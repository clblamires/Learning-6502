# Build Commands

Cuz I'm gonna forget how to do this pretty much every time...

```
Assembly compiler:
ca65 src/main.s -o build/main.o

Linker:
ld65 -C cfg/nes.cfg build/main.o -o build/game.nes
```