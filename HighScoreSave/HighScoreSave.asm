// Purpose: Zombies ate my Neighbors --- High Score Save
//            Detects presence of SRAM and will save if possible.
// Date: November 01, 2016
// Author: DackR

// Architecture directive for xkas-plus:
arch snes.cpu; lorom

// Variables...
define NewCodeAddr $82F980

//SNES Header: Indicate ROM + RAM + SRAM
org $ffd6
db $02

//SNES Header: 2kb SRAM
org $ffd8
db $01

//Entry Point: Hijack high score table initialization in wram...
org $82bb13
jml makescoretable
nop
nop
nop
nop
nop
nop
nop
nop
scoreReturn:

//Entry Point: Hijack high score save!
org $82bd2f
jml xferscore
nop
nop

org {NewCodeAddr}
makescoretable:
lda $700010 // this tells me if I've initialized the table before
cmp #$0666 // check to see if the table is already written
beq writewram // if it exists, copy the sram table to wram

ldx #$0000
ldy #$0001
lda #$07fe // the number of bytes to clear
mvn $70,$70 //clear sram

ldx #$bb2e
ldy #$0020 //#$2064
lda #$00BC //instead of just $95, transfer $BC
mvn $82,$70 //7e

lda #$0666  // this is the value I check for on game start
sta $700010 // table now exists (if there is SRAM)

//CHECK IF LOROM OR HIROM
lda $700010 // this is the LOROM SRAM location
cmp #$0666 // check to see if the table was successfully written
beq writewram // if it exists, copy the sram table to wram

//THE SRAM WRITE FAILED - TRY HIROM MAPPING
lda $206010 // this is the HIROM SRAM location for the first 8kb
cmp #$0666 // check to see if the table is already written
beq writehiwram // if it exists, copy the sram table to wram

ldx #$6000 //start source
ldy #$6001 //start destination
lda #$07fe // the number of bytes to clear
mvn $20,$20 //clear sram

ldx #$bb2e
ldy #$6020 //#$2064
lda #$00BC //instead of just $95, transfer $BC
mvn $82,$20 //7e

lda #$0666  // this is the value I check for on game start
sta $206010 // table now exists (if there is SRAM)

//CHECK TO SEE IF HIROM SRAM write was successful--!
lda $206010 // this is the HIROM SRAM location for the first 8kb
cmp #$0666 // check to see if the table is there
bne nosram // if it exists, copy the sram table to wram

//If this is running on a HiROM cart...
writehiwram:
ldx #$6020
ldy #$2064
lda #$00BC
mvn $20,$7e

jml scoreReturn //$82bb2b // back to the main init routine

//If this is running on a LoROM cart...
writewram:
ldx #$0020
ldy #$2064
lda #$00BC
mvn $70,$7e

jml scoreReturn //$82bb2b //$82bb1f // jump back to main init routine

nosram: //if there is no SRAM, copy the high score table from ROM to WRAM
ldx #$bb2e
ldy #$2064 //#$2064
lda #$00BC //instead of just $95, transfer $BC
mvn $82,$7e //7e

jml scoreReturn //$82bb2b //$82bb1f // jump back to main init routine

//COPY SCORE TO SRAM!
xferscore:
mvn $00,$7e //this is where I hijacked it

//save it to SRAM!
ldx #$2064
ldy #$0020
lda #$00BC
mvn $7e,$70

//same as old routine exit
plb
plb
rts