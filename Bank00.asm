	; <-- This tab is being kept prisoner in case I need to search for other
    ; tabs.
    ; Zelda III Source Code
    ; Courtesy of MathOnNapkins

    lorom
    
; ==============================================================================

    ; $000000-$000060
    Vector_Reset:
    {
        SEI ; Set interrupt disable bits
        
        STZ $4200   ; Disables the NMI and various other things
        STZ $420C   ; HDMA and DMA is disabled
        STZ $420B   
        STZ $2140   ; Clear SPC locations
        STZ $2141
        STZ $2142
        STZ $2143
        
        ; Set brightness to zero and enable force blank (forced V-Blank all the time)
        LDA.b #$80 : STA $2100
        
        ; Switch to native mode
        CLC : XCE
        
        ; Reset M and D flags
        REP #$28
        
        ; Direct page is at $0000
        LDA.w #$0000 : TCD
        
        ; Stack is located at $01FF
        LDA.w #$01FF : TCS
        
        SEP #$30 ; M and X are 8 bit
        
        JSR Sound_LoadIntroSongBank
        JSR Startup_InitializeMemory
        
        ; Bit 7 enables NMI interrupt.
        ; This register tracks whether NMI is enabled.
        LDA.b #$81 : STA $4200
    
    .nmi_wait_loop
    
        ; This loop doesn't normally exit unless NMI is enabled!
        LDA $12 : BEQ .nmi_wait_loop
        
        CLI ; Clear the interrupt disable bit.
        
        BRA .do_frame
    
    ; Inaccessible code, used for debug if assembled in.
    ; NOP out the above BRA to activate this code
    .frameStepDebugCode
    
        LDA $F6 : AND.b #$20 : BEQ .L_ButtonDown ; If the L button is down, then...
        
        INC $0FD7
    
    .L_ButtonDown
    
        ; If the R button is down, then...
        LDA $F6 : AND.b #$10 : BNE .R_ButtonDown
        
        LDA $0FD7 : AND.b #$01 : BNE .skip_frame
    
    .R_ButtonDown
    .do_frame
    
        INC $1A ; frame counter. See ZeldaRAM.rtf for more variable listings.
        
        JSR ClearOamBuffer
        JSL Module_MainRouting
    
    .skip_frame
    
        JSR Main_PrepSpritesForNmi
        
        ; Start the NMI Wait loop again
        STZ $12
        
        BRA .nmi_wait_loop
    }

; ==============================================================================

    ; $0061-$00B4 JUMP TABLE FOR SR$0085
    pool Module_MainRouting: 
    {
        ; \task Figure out how to express this interleavededly... gah.
        interleave
        {
            ; Note: there are 28 distinct modes here (0x1C)
            ; This jump table is interlaced, sadly enough
            
        .modules
            dl Module_Intro          ; 0x00 - Triforce / Zelda startup screens
            dl Module_SelectFile     ; 0x01 - File Select screen
            dl Module_CopyFile       ; 0x02 - Copy Player Mode
            dl Module_EraseFile      ; 0x03 - Erase Player Mode
            dl Module_NamePlayer     ; 0x04 - Name Player Mode
            dl Module_LoadFile       ; 0x05 - Loading Game Mode
            dl Module_PreDungeon     ; 0x06 - Pre Dungeon Mode
            dl Module_Dungeon        ; 0x07 - Dungeon Mode
            dl Module_PreOverworld   ; 0x08 - Pre Overworld Mode
            dl Module_Overworld      ; 0x09 - Overworld Mode
            dl Module_PreOverworld   ; 0x0A - Pre Overworld Mode (special overworld)
            dl Module_Overworld      ; 0x0B - Overworld Mode (special overworld)
            dl Module_Unknown0       ; 0x0C - ???? I think we can declare this one unused, almost with complete certainty.
            dl Module_Unknown1       ; 0x0D - Blank Screen
            dl Module_Messaging      ; 0x0E - Text Mode/Item Screen/Map
            dl Module_CloseSpotlight ; 0x0F - Closing Spotlight
            dl Module_OpenSpotlight  ; 0x10 - Opening Spotlight
            dl Module_HoleToDungeon  ; 0x11 - Happens when you fall into a hole from the OW.
            dl Module_Death          ; 0x12 - Death Mode
            dl Module_GanonVictory   ; 0x13 - Boss Victory Mode (refills stats)
            dl Module_Attract        ; 0x14 - Attract Mode
            dl Module_Mirror         ; 0x15 - Module for Magic Mirror
            dl Module_Victory        ; 0x16 - Module for refilling stats after boss.
            dl Module_Quit           ; 0x17 - Quitting mode (save and quit)
            dl Module_GanonEmerges   ; 0x18 - Ganon exits from Agahnim's body. Chase Mode.
            dl Module_TriforceRoom   ; 0x19 - Triforce Room scene
            dl Module_EndSequence    ; 0x1A - End sequence
            dl Module_LocationMenu   ; 0x1B - Screen to select where to start from (House, sanctuary, etc.)
            
            { modules long i } => { lowers  byte i       },
                                  { middles byte i >> 8  },
                                  { banks   byte i >> 16 }
        }
    }

; ==============================================================================

    ; *$00B5-$00C8 LONG
    Module_MainRouting:
    {
        ; This variable determines which module we're in.
        LDY $10
        
        LDA .lowers, Y  : STA $03
        LDA .middles, Y : STA $04
        LDA .banks, Y   : STA $05
        
        ; Jump to a main module depending on addr $7E0010 in ram
        JMP [$0003]
    }

; ==============================================================================

    ; *$0000C9-$00022C NMI Interrupt Subroutine (NMI Vector)
    Vector_NMI:
    {
        ; Ensures this interrupt isn't interrupted by an IRQ
        SEI
        
        ; Resets M and X flags
        REP #$30
        
        ; Pushes 16 bit registers to the stack
        PHA : PHX : PHY : PHD : PHB
        
        ; Sets DP to $0000
        LDA.w #$0000 : TCD
        
        ; Equate Program and Data banks
        PHK : PLB
        
        SEP #$30
        
        ; This register needs to be read each time NMI is called.
        ; It apparently resets a latch so that the next NMI can trigger?
        LDA $4210
        
        ; Used to select a musical track.
        LDA $012C : BNE .nonzeroMusicInput
        
        LDA $2140 : CMP $0133 : BNE .handleAmbientSfxInput
        
        ; If they were the same, put 0 in $2140
        STZ $2140
        
        BRA .handleAmbientSfxInput
    
    .nonzeroMusicInput
    
        CMP $0133 : BEQ .handleAmbientSfxInput
        
        ; The song has changed...
        STA $2140 : STA $0133 : CMP.b #$F2 : BCS .volumeOrTransferCommand
        
        STA $0130
    
    .volumeOrTransferCommand
    
        STZ $012C
    
    .handleAmbientSfxInput
    
        LDA $012D : BNE .nonzeroAmbientSfxInput
        
        ; Compare the values
        LDA $2141 : CMP $0131 : BNE .writeSfx
        
        STZ $2141 ; If equal, zero out $2141
        
        BRA .writeSfx
    
    .nonzeroAmbientSfxInput
    
        STA $0131 : STA $2141
        
        STZ $012D
    
    .writeSfx
    
        ; Addresses will hold SPC memory locations
        LDA $012E : STA $2142
        LDA $012F : STA $2143
        
        STZ $012E
        STZ $012F
        
        ; Bring the screen into forceblank (forced vblank)
        LDA.b #$80 : STA $2100
        
        ; Disable all DMA transfers
        STZ $420C
        
        ; Checks to see if we're still in the infinite loop in the main routine
        ; If $12 is not 0, it shows that the infinite loop isn't running.
        LDA $12 : BNE .normalFrameNotFinished
        
        ; This would happen if NMI had been called from the wait loop.
        INC $12
        
        JSR NMI_DoUpdates
        JSR NMI_ReadJoypads
    
    .normalFrameNotFinished
    
        LDA $012A : BEQ .helperThreadInactive
        
        JMP NMI_SwitchThread
    
    .helperThreadInactive
    
        ; Sets background clipping... 
        LDA $96 : STA $2123
        LDA $97 : STA $2124
        LDA $98 : STA $2125
        
        ; Sets color / sprite windowing registers
        LDA $99 : STA $2130
        LDA $9A : STA $2131
        
        ; Possibly a register that must be written 3 times (internal pointer)
        LDA $9C : STA $2132
        LDA $9D : STA $2132
        LDA $9E : STA $2132
        
        ; Main / Subscreen designation registers
        LDA $1C : STA $212C
        LDA $1D : STA $212D
        
        ; Window designations...
        LDA $1E : STA $212E
        LDA $1F : STA $212F
        
        ; Are these word addresses?
        LDA $0120 : STA $210D
        LDA $0121 : STA $210D
        
        LDA $0124 : STA $210E
        LDA $0125 : STA $210E
        
        LDA $011E : STA $210F
        LDA $011F : STA $210F
        
        LDA $0122 : STA $2110
        LDA $0123 : STA $2110
        
        LDA $E4 : STA $2111
        LDA $E5 : STA $2111
        
        ; All BG registers
        LDA $EA : STA $2112
        LDA $EB : STA $2112
        
        ; MOSAIC and BGMODE register mirrors
        LDA $95 : STA $2106
        LDA $94 : STA $2105
        
        ; Check to see if we're in mode 7
        AND.b #$07 : CMP.b #$07 : BNE .notInMode7
        
        STZ $211C : STZ $211C
        STZ $211D : STZ $211D
        
        LDA $0638 : STA $211F
        LDA $0639 : STA $211F
        LDA $063A : STA $2120
        LDA $063B : STA $2120
    
    .notInMode7
    
        LDA $0128 : BEQ .irqInactive
        
        ; Clear the IRQ line if one is pending? (reset latch)
        LDA $4211
        
        ; Set vertical irq trigger position to 128, which is a tad
        ; bit past the middle of the screen, vertically
        LDA.b #$80 : STA $4209 : STZ $420A
        
        ; Set horizontal irq trigger position to 0.
        ; (Will not be used anyways)
        STZ $4207 : STZ $4208
        
        ; Will enable NMI, and Joypad, and vertical IRQ trigger
        LDA.b #$A1 : STA $4200 ; #$A1 = #%10100001
    
    .irqInactive
    
        ; $13 holds the screen state
        LDA $13 : STA $2100
        LDA $9B : STA $420C
        
        REP #$30
        
        PLB : PLD : PLY : PLX : PLA
    
    .return
    
        RTI
    }

; ==============================================================================

    ; $22D-$2D7 JUMP LOCATION
    NMI_SwitchThread:
    {
        JSR NMI_UpdateIrqGfx
        
        LDA $FF : STA $4209 : STZ $420A
        
        ; A = #%10100001, which means activate NMI, V-IRQ, and Joypad
        LDA.b #$A1 : STA $4200
        
        LDA $96 : STA $2123
        LDA $97 : STA $2124
        LDA $98 : STA $2125
        
        LDA $99 : STA $2130
        LDA $9A : STA $2131
        LDA $9C : STA $2132
        LDA $9D : STA $2132
        LDA $9E : STA $2132
        
        LDA $1C : STA $212C
        LDA $1D : STA $212D
        LDA $1E : STA $212E
        LDA $1F : STA $212F
        
        LDA $0120 : STA $210D
        LDA $0121 : STA $210D
        
        LDA $0124 : STA $210E
        LDA $0125 : STA $210E
        
        LDA $011E : STA $210F
        LDA $011F : STA $210F
        
        LDA $0122 : STA $2110
        LDA $0123 : STA $2110
        
        LDA $E4 : STA $2111
        LDA $E5 : STA $2111
        LDA $EA : STA $2112
        LDA $EB : STA $2112
        LDA $13 : STA $2100
        LDA $9B : STA $420C
        
        REP #$30
        
        ; This is very tricksy.
        ; X = S; (apparently they did't know about the TSX instruction)
        TSC : TAX
        
        ; S = $1F0A
        ; $1F0A = X
        LDA $1F0A : TCS : STX $1F0A
        
        ; Expect to end up at $09F81D after the RTI ;)
        
        PLB : PLD : PLY : PLX : PLA
        
        RTI
    }

    ; *$2D8-$332 IRQ INTERRUPT
    Vector_IRQ:
    {    
        SEI
        
        REP #$30
        
        PHA : PHX : PHY : PHD
        
        PHB : PHK : PLB
        
        SEP #$30
        
        LDA $012A : BNE BRANCH_3
        
        ; Only d7 is significant in this register. If set, h/v counter has latched.
        LDA $4211 : BPL BRANCH_2 ; So in other words, branch if the timer has NOT counted down.
        
        ; Not sure what this does...
        LDA $0128 : BEQ BRANCH_2
    
    BRANCH_1:
    
        BIT $4212 : BVC BRANCH_1 ; Wait for hBlank
        
        LDA $0630 : STA $2111
        LDA $0631 : STA $2111
        
        STZ $2112 : STZ $2112
        
        LDA $0128 : BPL BRANCH_2
        
        STZ $0128
        
        LDA.b #$81 : STA $4200
    
    BRANCH_2:
    
        ; h/v timer didn't count down yet, so we do NOTHING :).
        
        REP #$30
        
        PLB : PLD : PLY : PLX : PLA
        
        RTI
    
    BRANCH_3:
    
        LDA $4211
        
        REP #$30
        
        ; X = S
        TSC : TAX
        
        ; Transfer A -> S
        LDA $1F0A : TCS : STX $1F0A
        
        PLB : PLD : PLY : PLX : PLA
        
        RTI
    }
    
    ; $0333-$3D0 LONG
    Vram_EraseTilemaps:
    {
        ; this routine might be optimizable
    
    .triforce ; for use with the title screen and the credits sequence
    
        !fillBg_1_2 = $00
        !fillBg_3   = $02
        
        REP #$20
        
        LDA.w #$00A9 : STA !fillBg_3
        
        LDA.w #$007F
        
        BRA .fillTilemaps
    
    ; $033F ALTERNATE ENTRY POINT
    .palaceMap
    
        REP #$20
        
        LDA.w #$007F : STA !fillBg_3
        
        LDA.w #$0003
        
        BRA .fillTilemaps
    
    ; $034B ALTERNATE ENTRY POINT
    .normal
    
        ; Performs a tilemap blanking (filling with transparent tiles) for BG1, BG2, and BG3
        
        REP #$20
        
        ; $01EC indicates "blank" tiles
        LDA.w #$007F : STA !fillBg_3
        
        LDA.w #$01EC
    
    .fillTilemaps
    
        ; Could be any number of values.
        STA !fillBg_1_2
        
        ; vram target address updates on writes to $2118
        STZ $2115
        
        ; The vram target address is $0000 (word address)
        STZ $2116
        
        ; target register is $2118, write one register once mode, with fixed source address
        LDA.w #$1808 : STA $4310
        
        ; dma source address is $000000    
        STZ $4314
        LDA.w #$0000 : STA $4312
        
        ; will write 0x2000 bytes. since we're only writing to the low byte of each vram word address,
        ; we will technically cover 0x4000 bytes worth of address space, but in terms of vram addresses it's 
        ; still only vram address $0000 to $1FFF
        LDA.w #$2000 : STA $4315
        
        ; transfer the data on channel 1
        LDY.b #$02 : STY $420B
        
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ; increment vram address when $2119 is written
        LDX.b #$80 : STX $2115
        
        ; Reinitialize vram target address to $0000 (word)
        STZ $2116
        
        ; Again write 0x2000 bytes
        STA $4315
        
        ; dma target register is $2119, write one register once mode, with fixed address
        LDA.w #$1908 : STA $4310
        
        ; The DMA source address will now be $000001
        LDA.w #$0001 : STA $4312
        
        ; transfer data on channel 1
        STY $420B
        
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ; This value was saved earliest in the routine.
        LDA !fillBg_3 : STA !fillBg_1_2
        
        ; increment on writes to $2118 again
        STZ $2115
        
        ; write to vram address $6000 (word)
        LDA.w #$6000 : STA $2116
        
        ; Write to $2118, Non incrementally
        LDA.w #$1808 : STA $4310
        
        ; $DMA source address is $000000
        LDA.w #$0000 : STA $4312
        
        ; Write $00 #$800 times to Vram.
        LDA.w #$0800 : STA $4315
        
        ; transfer data on channel 1
        STY $420B
        
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ; increment on writes to $2119 again
        STX $2115
        
        ; Reset the byte amount to 0x800 bytes    
        STA $4315
        
        ; Reset vram target address to $6000 (word)
        LDA.w #$6000 : STA $2116
        
        ; write to $2119, write one register once mode, fixed source address
        LDA.w #$1908 : STA $4310
        
        ; DMA source address is $000001
        LDA.w #$0001 : STA $4312
        
        ; transfer data on channel 1
        STY $420B
        
        SEP #$20
        
        RTL
    }

    ; *$3D1 - $41D LOCAL
    NMI_ReadJoypads:
    {
        !disableJoypad2 = "RTS"
        !enableJoypad2  = "NOP"
        !joypad2_action = !disableJoypad2
        
        ; Probably indicates that we're not using the old style joypad reading.
        STZ $4016 
        
        ; Storing the state of Joypad 1 to $00-$01
        LDA $4218 : STA $00
        LDA $4219 : STA $01
        
        ; $F2 has the pure joypad data
        LDA $00 : STA $F2 : TAY 
        
        ; $FA at this point contains the joypad data from the last frame.
        ; This is intended to avoid flooding in processing commands.
        ; Send this "button masked" reading here.
        ; Hence $F2 and $FA contain pure joypad readings from this frame now.
        EOR $FA : AND $F2 : STA $F6 : STY $FA
        
        ; Essentially the same procedure as above, but for the other half of JP1.
        LDA $01 : STA $F0 : TAY
        EOR $F8 : AND $F0 : STA $F4 : STY $F8
        
        !joypad2_action
        
        ; If it wasn't obvious, please note that the original game, coded this way,
        ; never reaches this section. Yes folks, there is no love for Joypad2 in
        ; Zelda 3.
        
        LDA $421A : STA $00
        LDA $421B : STA $01
        
        LDA $00 : STA $F3 : TAY
        EOR $FB : AND $F3 : STA $F7 : STY $FB
        
        LDA $01 : STA $F1 : TAY
        EOR $F9 : AND $F1 : STA $F5 : STY $F9
        
        RTS
    }

; ==============================================================================

    ; *$41E-$489 LOCAL
    ClearOamBuffer:
    {
        ; Gets rid of old sprites by moving them off screen, basically.
        ; E.g., when you kill a soldier, his sprite has to disappear, right?
        ; Any sprites that are still in the game engine will be moved back on screen 
        ; before VRAM
        ; is written to again.    
        
        LDX.b #$60
    
    .loop
    
        LDA.b #$F0
        
        STA $0801, X : STA $0805, X : STA $0809, X : STA $080D, X
        STA $0811, X : STA $0815, X : STA $0819, X : STA $081D, X
        
        STA $0881, X : STA $0885, X : STA $0889, X : STA $088D, X
        STA $0891, X : STA $0895, X : STA $0899, X : STA $089D, X
        
        STA $0901, X : STA $0905, X : STA $0909, X : STA $090D, X
        STA $0911, X : STA $0915, X : STA $0919, X : STA $091D, X
        
        STA $0981, X : STA $0985, X : STA $0989, X : STA $098D, X
        STA $0991, X : STA $0995, X : STA $0999, X : STA $099D, X
        
        ; X -= 0x20
        TXA : SUB.b #$20 : TAX : BPL .loop
        
        RTS
    }

    ; $48A-$5FB DATA
    {
        dw $0000, $0000
        dw $0500, $0A00
        dw $0F00 
    
    ; $494
        dw $A480
        dw $A4C0, $A500
        dw $A540
    
    ; $49C
        dw $9000, $9020, $9060, $91E0, $90A0, $90C0, $9100, $9140
    
    ; $4AC
        dw $9300, $9340, $9380, $9480, $94C0, $94E0, $95C0, $9500
        
        dw $9520
        dw $9540, $9480
        dw $9640, $9680
        dw $96A0, $9780
        dw $96C0, $96E0
        dw $9700, $9480
        dw $9800, $9840
        dw $98A0, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9AC0, $9B00
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9BC0, $9C00
        dw $9C40, $9C80
        dw $9CC0, $9D00
        dw $9D40, $9480
        dw $9F40, $9F80
        dw $9FC0, $9FE0
        dw $A000, $9480
        dw $9480, $9480
        dw $A100, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $98C0, $9900
        dw $99C0, $99E0
        dw $9A00, $9A20
        dw $9A40, $9A60
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9A80, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
        dw $9480, $9480
    }

; ==============================================================================

    ; *$05FC-$0780 LOCAL
    Main_PrepSpritesForNmi:
    {
        ; Writes some extra data for the OAM memory
        ; The data is written to $0A00 to $0A1F,
        ; And the data that is written is formed from
        ; The addresses $0A20 through $0A9F
        
        LDY.b #$1C
    
    .buildHighOamTable
    
        ; Y = 0x1C, X = 0x70
        TYA : ASL #2 : TAX
        
        ; Start at $0A93?
        LDA $0A23, X : ASL #2
        ORA $0A22, X : ASL #2
        ORA $0A21, X : ASL #2
        ORA $0A20, X : STA $0A00, Y
        
        LDA $0A27, X : ASL #2
        ORA $0A26, X : ASL #2
        ORA $0A25, X : ASL #2
        ORA $0A24, X : STA $0A01, Y
        
        LDA $0A2B, X : ASL #2
        ORA $0A2A, X : ASL #2
        ORA $0A29, X : ASL #2
        ORA $0A28, X : STA $0A02, Y
        
        LDA $0A2F, X : ASL #2
        ORA $0A2E, X : ASL #2
        ORA $0A2D, X : ASL #2
        ORA $0A2C, X : STA $0A03, Y
        
        DEY #4 : BPL .buildHighOamTable
        
        REP #$31
        
        LDX $0100
        
        LDA $9396, X : STA $0ACC : ADC.w #$0200 : STA $0ACE
        LDA $95F4, X : STA $0AD0 : ADD.w #$0200 : STA $0AD2
        
        LDX $0102 : LDA $9852, X : STA $0AD4
        
        LDX $0104 : LDA $9852, X : STA $0AD6
        
        SEP #$10
        
        LDX $0107 : LDA $849C, X : STA $0AC0 : ADD.w #$0180 : STA $0AC2
        LDX $0108 : LDA $84AC, X : STA $0AC4 : ADD.w #$00C0 : STA $0AC6
        
        LDA $0109 : AND.w #$00F8 : LSR #2 : TAY
        
        LDA $0109 : ASL A : TAX
        
        LDA $84B2, X : STA $0AC8
        
        CLC : TYX : ADC $85B2, X : STA $0ACA
        
        LDA $02C3 : AND.w #$0003 : ASL A : TAX
        
        LDA $8494, X : STA $0AD8 : ADD.w #$0100 : STA $0ADA
        
        LDA $7EC00D : DEC A : STA $7EC00D : BNE .ignoreTileAnimation
        
        ; Reset the counter for tile animation
        LDA.w #$0009
        
        LDX $8C : CPX.b #$B5 : BEQ BRANCH_1A
        
        CPX.b #$BC : BNE BRANCH_1B
    
    BRANCH_1A:
    
        LDA.w #$0017
    
    BRANCH_1B:
    
        STA $7EC00D
        
        LDA $7EC00F : ADD.w #$0400 : CMP.w #$0C00 : BNE BRANCH_1C
        
        LDA.w #$0000
    
    BRANCH_1C:
    
        STA $7EC00F : ADD.w #$A680 : STA $0ADC
    
    .ignoreTileAnimation
    
        LDA $7EC013 : DEC A : STA $7EC013 : BNE .ignoreSpriteAnimation
        
        LDA $7EC015 : TAX
        
        INX #2 : CPX.b #$0C : BNE .spriteAnimationLoopIncomplete
        
        LDX.b #$00
    
    .spriteAnimationLoopIncomplete
    
        TXA : STA $7EC015
        
        LDA $85D2, X : STA $7EC013
        
        LDA.w #$B280  : ADD $85DE, X : STA $0AE0
        ADD.w #$0060                 : STA $0AE2
    
    .ignoreSpriteAnimation
    
        ; setup tagalong sprite for dma transfer
        LDA $0AE8    : ASL A
        ADC.w #$B940 : STA $0AEC
        ADC.w #$0200 : STA $0AEE
        
        ; setup tagalong sprite's other component for dma transfer?
        LDA $0AEA    : ASL A
        ADC.w #$B940 : STA $0AF0
        ADC.w #$0200 : STA $0AF2
        
        ; setup dma transfer for bird's sprite slot
        LDA $0AF4    : ASL A
        ADC.w #$B540 : STA $0AF6
        ADC.w #$0200 : STA $0AF8
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$000781-$00079B LONG
    UseImplicitRegIndexedLocalJumpTable:
    {
        ; Parameters: Stack, A
        
        ; save current Y
        STY $03
        
        ; Pull return PCL to Y
        PLY : STY $00
        
        REP #$30
        
        ; Ensures offset is a Multiple of two
        AND.w #$00FF : ASL A : TAY
        
        ; Pull the rest of the return address onto A
        ; Since this is a 16 bit value this ensures that the jump address is 
        ; in the same bank as the return address
        PLA : STA $01
        
        INY
        
        LDA [$00], Y : STA $00
        
        SEP #$30
        
        ; restore Y
        LDY $03
        
        JML [$0000]
    }

; ==============================================================================

    ; *$79C-$7BF LONG( A, STACK)
    UseImplicitRegIndexedLongJumpTable:
    {
        STY $05
        
        ; load Y with lower return PC from the stack
        PLY : STY $02
        
        REP #$30
        
        AND.w #$00FF : STA $03
        
        ; shift bits left = multiply by two, since bit 15 will NOT be set.
        ; Add the original number. Essentially, this is 2N + N = 3N
        ; // In other words, Y is indexed as 3 times the value that A had.
        ASL A : ADC $03 : TAY
        
        ; Pull the upper return PC and return PB from the Stack.
        PLA : STA $03
        
        INY ; Pushes Y past the edge of the original PC
        
        ; Look up a new address in a table
        LDA [$02], Y : STA $00 : INY
        
        ; Note that the first STA overlapped this one.
        LDA [$02], Y : STA $01
        
        ; The idea was to retrieve a 3-byte address from a jump table
        
        SEP #$30
        
        LDY $05 ; Restore Y's earlier value.
        
        JML [$0000]
    }

; ==============================================================================

    ; *$07C0-$082D LOCAL
    Startup_InitializeMemory:
    {
        ; Zeroes out $7e0000-$7e1FFF, and checks some values in SRAM
        
        REP #$30
        
        ; Save the return location of this subroutine
        ; But why do this, why not something like "TSX : TXY"?
        LDY.w $01FE
        
        ; Counter for the loop.
        LDX.w #$03FE
        
        ; The value to write.
        LDA.w #$0000
    
    .erase
    
        ; Zero out $0000-$1FFF
        
        STA $0000, X : STA $0400, X : STA $0800, X : STA $0C00, X
        STA $1000, X : STA $1400, X : STA $1800, X : STA $1C00, X
        
        DEX #2 : BNE .erase
        
        STA $7EC500 : STA $701FFE ; Sets it so we have no memory of opening a save file.
        
        ; Checks the checksum for the first save file.
        LDA $7003E5 : CMP.w #$55AA : BEQ .validSlot1Sram
        
        ; Effectively sends the program the message to delete this file.
        LDA.w #$0000 : STA $7003E5
    
    .validSlot1Sram
    
        ; repeat this for slots 2 and 3
        LDA $7008E5 : CMP.w #$55AA : BEQ .validSlot2Sram
        
        LDA.w #$0000 : STA $7008E5
    
    .validSlot2Sram
    
        LDA $700DE5 : CMP.w #$55AA : BEQ .validSlot3Sram
        
        LDA.w #$0000 : STA $700DE5
    
    .validSlot3Sram
    
        ; Restore the return location for this function to the stack
        ; As above, I think "TYX : TXS" would have worked >___>
        STY $01FE
        
        ; Window mask activation
        STZ $212E
        
        SEP #$30
        
        ; bring the screen into force blank after NMI
        LDA.b #$80 : STA $13
        
        ; update cgram this frame
        INC $15
        
        RTS
    }

; ==============================================================================

    ; *$82E-$887 LONG
    Overworld_GetTileAttrAtLocation:
    {
        ; inputs:
        ; $00 - full 16-bit Y coordinate of an object.
        ; $02 - full 16-bit X coordinate of an object
        ; $
        
        REP #$30
        
        LDA $00 : SUB $0708 : AND $070A : ASL #3  : STA $06
        LDA $02 : SUB $070C : AND $070E : ORA $06 : TAX
        
        LDA $7E2000, X : ASL #2 : STA $06
        LDA $00 : AND.w #$0008 : LSR #2 : TSB $06
        LDA $02 : AND.w #$0001 : ORA $06 : ASL A : TAX
        
        ; $78000, X THAT IS
        LDA $0F8000, X : STA $06 : AND.w #$01FF : TAX
        
        ; $71459, X THAT IS
        LDA Overworld_TileAttr, X
        
        SEP #$30
        
        CMP.b #$10 : BCC BRANCH_1
        CMP.b #$1C : BCS BRANCH_1
        
        STA $06
        
        LDA $07 : AND.b #$40 : ASL A : ROL #2 : ORA $06
    
    BRANCH_1:
    
        RTL
    }

; ==============================================================================

    ; *$888-$900 LOCAL
    Sound_LoadSongBank:
    {
        ; Loads SPC with data
        
        PHP
        
        REP #$30
        
        LDY.w #$0000
        LDA.w #$AABB
    
    BRANCH_INIT_WAIT:
    
        ; // Wait for the SPC to initialize to #$AABB
        CMP $2140 : BNE BRANCH_INIT_WAIT
        
        SEP #$20
        
        LDA.b #$CC
        
        BRA BRANCH_SETUP_TRANSFER
    
    BRANCH_BEGIN_TRANSFER:
    
        LDA [$00], Y
        
        INY
        
        XBA
        
        LDA.b #$00
        
        BRA BRANCH_WRITE_ZERO_BYTE
    
    BRANCH_CONTINUE_TRANSFER:
    
        XBA
        
        LDA [$00], Y ; Load the data byte to transmit.
        
        INY
        
        ; Are we at the end of a bank?
        CPY.w #$8000 : BNE BRANCH_NOT_BANK_END ; If not, then branch forward.
        
        LDY.w #$0000 ; Otherwise, increment the bank of the address at [$00]
        
        INC $02
    
    BRANCH_NOT_BANK_END:
    
        XBA
    
    BRANCH_WAIT_FOR_ZERO:
    
        ; Wait for $2140 to be #$00 (we're in 8bit mode)
        CMP $2140 : BNE BRANCH_WAIT_FOR_ZERO
        
        INC A ; Increment the byte count
    
    BRANCH_WRITE_ZERO_BYTE:
    
        REP #$20
        
        ; Ends up storing the byte count to $2140 and the
        STA $2140
        
        SEP #$20 ; data byte to $2141. (Data byte represented as **)
        
        DEX : BNE BRANCH_CONTINUE_TRANSFER
    
    BRANCH_SYNCHRONIZE: ; We ran out of bytes to transfer.
    
        ; But we still need to synchronize.
        CMP $2140 : BNE BRANCH_SYNCHRONIZE
    
    BRANCH_NO_ZERO: ; At this point $2140 = #$01
    
        ; Add four to the byte count
        ADC.b #$03 : BEQ BRANCH_NO_ZERO ; (But Don't let A be zero!)
    
    BRANCH_SETUP_TRANSFER:
    
        PHA
        
        REP #$20
        
        LDA [$00], Y : INY #2 : TAX ; Number of bytes to transmit to the SPC.
        
        LDA [$00], Y : INY #2 : STA $2142 ; Location in memory to map the data to.
        
        SEP #$20
        
        CPX.w #$0001 ; If the number of bytes left to transfer > 0...
        
        ; Then the carry bit will be set
        ; And rotated into the accumulator (A = #$01)
        ; NOTE ANTITRACK'S DOC IS WRONG ABOUT THIS!!!
        ; He mistook #$0001 to be #$0100.
        LDA.b #$00 : ROL A : STA $2141 : ADC.b #$7F
        
        ; Hopefully no one was confused.
        PLA : STA $2140
    
    BRANCH_TRANSFER_INIT_WAIT:
    
        ; Initially, a 0xCC byte will be sent to initialize
        ; The transfer.
        ; If A was #$01 earlier...
        CMP $2140 : BNE BRANCH_TRANSFER_INIT_WAIT : BVS BRANCH_BEGIN_TRANSFER
        
        STZ $2140 : STZ $2141 : STZ $2142 : STZ $2143
        
        PLP
        
        RTS
    }

; ==============================================================================

    ; *$901-$912 LOCAL
    Sound_LoadIntroSongBank:
    {
        ; $00[3] = $198000, which is $C8000 in Rom
        LDA.b #$00 : STA $00
        LDA.b #$80 : STA $01
        LDA.b #$19 : STA $02
        
        SEI
        
        JSR Sound_LoadSongBank
        
        CLI
        
        RTS
    }

; ==============================================================================

    ; *$0913-$0924 LONG
    Sound_LoadLightWorldSongBank:
    {
        ; $00[3] = $1A9EF5, which is $D1EF5 in Rom
        LDA.b #$F5 : STA $00
        LDA.b #$9E : STA $01
        LDA.b #$1A
    
    .do_load
    
        STA $02
        
        SEI
        
        JSR Sound_LoadSongBank
        
        CLI
        
        RTL
    
    ; *$0925-$0930 ALTERNATE ENTRY POINT
    shared Sound_LoadIndoorSongBank:
    
        ; $00[3] = $1B8000, which is $D8000 in rom
        LDA.b #$00 : STA $00
        LDA.b #$80 : STA $01
        LDA.b #$1B
        
        BRA .do_load
    
    ; *$0931-$093C ALTERNATE ENTRY POINT
    shared Sound_LoadEndingSongBank:
    
        ; $00[3] = $1AD380, which is $D5380 in rom
        LDA.b #$80 : STA $00
        LDA.b #$D3 : STA $01
        LDA.b #$1A
        
        BRA .do_load
    }

; ==============================================================================

    ; *$093D-$0949 LONG
    EnableForceBlank:
    {
        ; Bring the screen into forceblank
        ; Screen state is mirrored at $13
        LDA.b #$80 : STA $2100 : STA $13
        
        ; Disable hdma transfers on all channels. 
        STZ $420C : STZ $9B
        
        RTL
    }

; ==============================================================================
    
    ; $094A-$09C1 LONG
    Main_SaveGameFile:
    {
        ; Loads Ram into SRAM, calculates an inverse checksum
        
        ; Data bank = 0x70, which is the bank that SRAM has been mapped it
        PHB : LDA.b #$70 : PHA : PLB
        
        REP #$30
        
        ; $701FFE, an offset of 0, 2, 4, 6,...
        ; Will give Y a value of 0, 0x0500, 0x0A00, or 0x0F00
        LDX $1FFE : LDA $00848A, X : TAY : PHY
        
        LDX.w #$0000
    
    .writeSlot
    
        ; loads memory from WRAM and writes it into SRAM
        ; Notice the difference of 0xF00 in the mirrored SRAM locations
        LDA $7EF000, X : STA $0000, Y : STA $0F00, Y
        LDA $7EF100, X : STA $0100, Y : STA $1000, Y
        LDA $7EF200, X : STA $0200, Y : STA $1100, Y
        LDA $7EF300, X : STA $0300, Y : STA $1200, Y
        LDA $7EF400, X : STA $0400, Y : STA $1300, Y
        
        INY #2
        
        INX #2 : CPX.w #$0100 : BNE .writeSlot
        
        LDX.w #$0000
        
        TXA
    
    .calcChecksum
    
        ; The checksum is a sum of 16-bit words of the first 0x4FE words of the save file
        ADD $7EF000, X
        
        INX #2 : CPX.w #$04FE : BNE .calcChecksum
        
        ; Store the calculated checksum to dp address $00 for temporary keeping
        STA $00
        
        ; restore the index (0x0000, 0x0500, 0x0A00, ... )
        PLY
        
        ; Subtract the checksum from 0x5A5A, and store the result at a corresponding location in RAM
        ; Because the result is subtracted from 0x5A5A, I'm inclined to call it an "inverse" checksum
        LDA.w #$5A5A : SUB $00 : STA $7EF4FE
        
        TYX
        
        ; Store the checksum at offset 0x4FE into the SRAM save game slot. (the last two bytes of the slot)
        STA $7004FE, X : STA $7013FE, X
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================
    
    ; $09C2-$09DF NULL
    {
        
    }

; ==============================================================================
    
    ; *$9E0-$D12 LOCAL
    NMI_DoUpdates:
    {
        REP #$10
        
        ; update target vram address after writes to $2119
        LDA.b #$80 : STA $2115
        
        ; flag used to indicate that special screen updates need to happen.
        LDA $0710 : BEQ .doCoreAnimatedSpriteUpdates
        
        JMP .skipCoreAnimatedSpriteUpdates
    
    .doCoreAnimatedSpriteUpdates
    
        ; In this section Link's sprite, his sword, his shield, blocks, sparkles, rupees, tagalongs,
        ; and optionally the bird's sprite gets updated (copied to vram).
        
        ; base dma register is $2118, write two registers once mode ($2118/$2119), with autoincrementing source addr.
        ; Why isn't $4320 set????
        LDX.w #$1801 : STX $4300 : STX $4310 : STX $4320 : STX $4330 : STX $4340
        
        ; Sets the bank for the DMA source bank to $10
        ; Use channels 0 - 2
        LDA.b #$10 : STA $4304 : STA $4314 : STA $4324
        
        ; The vram target address is $4100 (word)
        LDY.w #$4100 : STY $2116
        
        ; Sets a source address for dma channel 0
        LDY $0ACE : STY $4302
        
        ; going to write 0x40 bytes on channel 0 
        LDX.w #$0040 : STX $4305
        
        ; set source address for channel 1
        LDY $0AD2 : STY $4312
        
        ; Also send 0x40 bytes on channel 1
        STX $4315
        
        ; Set source for channel 1
        LDY $0AD6 : STY $4322
        
        ; Send 32 bytes on channel 2
        LDY.w #$0020 : STY $4325
        
        ; VOLLEY 1 *****
        ; activates DMA transfers on channels 0 - 2
        LDA.b #$07 : STA $420B
        
        STY $4325 ; Reset for another 32 bytes?
        
        ; Set VRAM target to $4000 word addr. = $8000 byte addr. 
        LDY.w #$4000 : STY $2116
        
        LDY $0ACC ; 0 on first round
        STY $4302 ; Uses Channel 1
        STX $4305 ; Send 0x40 bytes
        
        LDY $0AD0 ; 0 on first round
        STY $4312 ; Uses channel 2
        STX $4315 ; Send 0x40 bytes
        
        LDY $0AD4 ; 0 on first round
        STY $4322 ; Note $4325 is still #$20. This was done above to save cycles.
        STA $420B ; Activate transfer ( A = #$7 ) End of Volley 2 *****
        
        ; Set the bank for the source to $7E
        LDA.b #$7E : STA $4304
        
        STA $4314
        STA $4324
        STA $4334
        STA $4344 ; Doing five transfers on channels 1 through 5
        
        LDY $0AC0 ; 0 on first round
        STY $4302 ;    
        STX $4305 ; X is still 0x40
        
        LDY $0AC4
        STY $4312 ;
        STX $4315
        
        LDY $0AC8
        STY $4322 ;
        STX $4325
        
        LDY $0AE0 : STY $4332
        
        ; Store 0x20 bytes
        LDY.w #$0020 : STY $4335
        
        ; Use as a Rom local source address (channel 5)
        LDY $0AD8 : STY $4342
        
        STX $4345 ; Store 64 bytes
        
        ; 0x1F = 0b00011111
        LDA.b #$1F : STA $420B ; Activate DMA channels 0 - 4 ; End of Volley 3 *****
        
        ; Target $8300 in VRAM
        LDY.w #$4150 : STY $2116
        
        ; Again X = 0x40
        LDY $0AC2 : STY $4302
        STX $4305
        
        LDY $0AC6 : STY $4312
        STX $4315
        
        LDY $0ACA : STY $4322
        STX $4325
        
        LDY $0AE2 : STY $4332
        
        ; Transfer 32 bytes
        LDY.w #$0020 : STY $4335
        
        LDY $0ADA : STY $4342
        STX $4345
        
        ; Activate lines 0 - 4; End of Volley 4
        STA $420B
        
        ; Target #$8400
        LDY.w #$4200 : STY $2116
        
        LDY $0AEC : STY $4302
        STX $4305
        
        LDY $0AF0 : STY $4312
        STX $4315
        
        LDY.w #$BD40 : STY $4322
        STX $4325
        
        ; Transfer 64 bytes on all lines.
        ; Use lines 0 - 2 ; End of Volley 5 *****
        LDA.b #$07 : STA $420B
        
        ; Target $8600 in VRAM
        LDY.w #$4300 : STY $2116
        
        LDY $0AEE : STY $4302
        STX $4305
        
        LDY $0AF2 : STY $4312
        STX $4315
        
        LDY.w #$BD80 : STY $4322
        STX $4325 ; X = 64 still
        
        STA $420B ; Use lines 0 - 2 ; End of Volley 6 *****
        
        LDA $0AF4 : BEQ .noBirdSpriteUpdate
        
        ; Otherwise, Target $81C0
        LDY.w #$40E0 : STY $2116
        
        ; X = 64 = #$40
        LDY $0AF6 : STY $4302
        STX $4305
        
        ; Use line 0
        LDA.b #$01 : STA $420B
        
        ; Target $83C0
        LDY.w #$41E0 : STY $2116
        
        LDY $0AF8 : STY $4302
        STX $4305
        
        STA $420B ; Activate line 0
    
    .noBirdSpriteUpdate
    
        LDX $0ADC : STX $4302
        
        ; Set the target vram address
        LDX $0134 : STX $2116
        
        ; Transfer #$400 = 4 * 256 = 1024 bytes = 1 Kbyte
        LDX.w #$0400 : STX $4305
        
        ; Activate line 0.
        LDA.b #$01 : STA $420B
    
    .skipCoreAnimatedTilesUpdate
    
        LDA $16 : BEQ .noBg3Update
        
        ; target vram address is determined by $0219, but I'd expect this to be somewhat... fixed in practice.
        LDX $0219 : STX $2116
        
        ; $7EC700 is the WRAM buffer for this data
        LDX.w #$C700 : STX $4302
        LDA.b #$7E   : STA $4304
        
        ; number of bytes to transfer is 330
        LDX.w #$014A : STX $4305
        
        ; refresh BG3 tilemap data with this transfer on channel 0
        LDA.b #$01 : STA $420B
    
    .noBg3Update
    
        LDA $15 : BEQ .noCgramUpdate
        
        ; If $15 is set, we'll update CGRAM (palette update)
        
        ; Initialize the cgram pointer to color 0 (the start of cgram)
        STZ $2121
        
        ; We're going to be loading up CGRAM with palette data.
        ; Sets up data to be read in mode 0, to address $2222 (CGRAM DATA IN)
        LDY.w #$2200 : STY $4310
        
        ; Sets source address to $7EC500
        LDY.w #$C500 : STY $4312
        LDA.b #$7E   : STA $4314
        
        ; number of bytes to transfer is 0x200, which is also the size of cgram
        LDY.w #$0200 : STY $4315
        
        ; transfer data on channel 1
        LDA.b #$02 : STA $420B
    
    .noCgramUpdate
    
        ; Zero out the necesary flags and get ready to update OAM data.
        
        REP #$20 : SEP #$10
        
        ; Clear out $15-$16 and an OAM register
        STZ $15 : STZ $2102
        
        ; Will send data to $2104, write one register once mode, autoincrementing source address
        LDA.w #$0400 : STA $4300
        
        ; Source address will be $7E0800
        LDA.w #$0800 : STA $4302
        STZ $4304
        
        ; Fetch #$220 = 512 + 32 = 544 bytes
        LDA.w #$0220 : STA $4305
        
        ; transfer data on channel 1
        LDY.b #$01 : STY $420B
        
        SEP #$30
        
        ; Another graphics flag... not sure what it does
        LDY $14 : BEQ BRANCH_6
       
        ; $137A, Y in Rom        
        LDA $937A, Y : STA $00
        LDA $9383, Y : STA $01
        LDA $938C, Y : STA $02
        
        JSR $92A1 ; $12A1 in Rom
        
        LDA $14 : CMP.b #$01 : BNE BRANCH_5
        
        STZ $1000 : STZ $1001
    
    BRANCH_5:
    
        STZ $14
    
    BRANCH_6:
    
        ; What does $19 do?
        LDA $19 : BEQ BRANCH_7
        
        ; apparently part of its function is to determine the upper byte of the target vram address
        ; this already looks fiendish :/
        STA $2117
        
        REP #$10
        
        ; update vram target address after writes to $2119
        LDY.w #$0080 : STY $2115
        
        ; dma target address is $2118, write two registers once, autoincrement source address
        LDX.w #$1801 : STX $4300
        
        ; source address is ($7F0000 + $0118).
        LDX $0118  : STX $4302
        LDA.b #$7F : STA $4304
        
        ; number of bytes to transfer is 0x0200
        LDX.w #$0200 : STX $4305
        
        ; transfer data on channel 0
        LDA.b #$01 : STA $420B
        
        STZ $19
        
        SEP #$10
        
    BRANCH_7:
    
        ; Yet another graphics flag
        LDX $18 : BEQ BRANCH_9
        
        ; Write from Bank $00.
        STZ $4314
        
        REP #$20
        
        ; Writing to $2118 / $2119 alternating, with autoincrementing addressing
        LDA.w #$1801 : STA $4310
        
        REP #$10
        
        LDX.w #$0000 : LDA $1100, X
    
    BRANCH_8:
    
        ; Extract the target VRAM Address
        STA $2116
        
        TXA : ADD.w #$1104 : STA $4312
        
        ; Tells us how many bytes to transfer.
        LDA $1103, X : AND.w #$00FF : STA $4315
        
        ADD.w #$0004 : STA $00
        
        SEP #$20
        
        ; video port settings are determined in the packed data
        LDA $1102, X : STA $2115
        
        ; transfer data on channel 1
        LDA.b #$02 : STA $420B
        
        REP #$21
        
        TXA : ADC $00 : TAX
        
        LDA $1100, X : CMP.w #$FFFF : BNE BRANCH_8
        
        SEP #$30
        
        STZ $18 : STZ $0710
    
    BRANCH_9:
    
        ; This graphics variable is not a flag but an index for which specialized graphics routine to run this frame.
        LDA $17 : ASL A : TAX
        
        ; disable the variable (meaning it will have to be reenabled next frame)
        STZ $17
        
        JMP ($8C7E, X)
    }

; ==============================================================================

    ; $C7E-$CAF Jump Table
    {
        dw NMI_UploadTilemap_doNothing            ; (0x00)
        dw NMI_UploadTilemap                      ; (0x01)
        dw NMI_UploadBg3Text                      ; (0x02)
        dw NMI_UpdateScrollingOwMap               ; (0x03)
        dw NMI_UploadSubscreenOverlay             ; (0x04)
        dw NMI_UploadBg3Unknown                   ; (0x05) this also appears to be unused... strange...
        dw NMI_UploadBg3Unknown_doNothing         ; (0x06) also unused by extension
        dw NMI_LightWorldMode7Tilemap             ; (0x07) Transfers mode 7 tilemap
        
        dw NMI_UpdateLeftBg2Tilemaps              ; (0x08) Transfers 0x1000 bytes from $7F0000 to vram $0000
        dw NMI_UpdateBgChrSlots_3_to_4            ; (0x09) Transfers 0x1000 bytes from $7F0000 to vram $2C00
        dw NMI_UpdateBgChrSlots_5_to_6            ; (0x0A) Transfers 0x1000 bytes from $7F1000 to vram $3400 
        dw NMI_UpdateChrHalfSlot                  ; (0x0B) Transfers 0x400 bytes from $7F1000 to a vram address set by $0116 (sets the high byte)
        dw NMI_UploadSubscreenOverlay.secondHalf  ; (0x0C)
        dw NMI_UploadSubscreenOverlay.firstHalf   ; (0x0D)
        dw NMI_UpdateChr_Bg0                      ; (0x0E)
        dw NMI_UpdateChr_Bg1                      ; (0x0F)
        
        dw NMI_UpdateChr_Bg2                      ; (0x10)
        dw NMI_UpdateChr_Bg3                      ; (0x11)
        dw NMI_UpdateChr_Spr0                     ; (0x12)
        dw NMI_UpdateChr_Spr2                     ; (0x13)
        dw NMI_UpdateChr_Spr3                     ; (0x14)
        dw NMI_DarkWorldMode7Tilemap              ; (0x15)
        dw NMI_UpdateBg3ChrForDeathMode           ; (0x16)
        dw NMI_UpdateBarrierTileChr               ; (0x17)
        
        dw NMI_UpdateStarTiles                    ; (0x18)
    }

; ==============================================================================

    ; *$CB0-$CE3 JUMP LOCATION
    NMI_UploadTilemap:
    {    
        ; General purpose dma transfer for updating tilemaps, though
        ; I suppose you could use it to update graphics too.
        
        ; $1888, X that is
        ; Sets the high byte of the Target VRAM address.
        LDX $0116 : LDA $9888, X : STA $2117
        
        ; bank of the source address is 0x00
        STZ $4304
        
        REP #$20
        
        ; vram target address will auto update after writes to $2119. (lower byte of vram addr is also 0x00 now)
        LDA.w #$0080 : STA $2115
        
        ; dma target register is $2118, write two registers once mode ($2118/$2119), autoincrement source address.
        LDA.w #$1801 : STA $4300
        
        ; Designates the source addr as $001000
        LDA.w #$1000 : STA $4302
        
        ; The number of bytes to transfer is $800
        LDA.w #$0800 : STA $4305
        
        ; Fire DMA channel 1. 
        LDY.b #$01 : STY $420B
        
        ; Do a little clean up.
        STZ $1000
        
        SEP #$20
        
        STZ $0710
    
    ; *$CE3 ALTERNATE ENTRY POINT
    .doNothing
    
        RTS
    }

; ==============================================================================
    
    ; *$CE4-$D12 JUMP LOCATION
    NMI_UploadBg3Text:
    {
        ; Copies $7F0000[0x7E0] to $7C00 in VRAM ($F800 in byte addressing)
        
        REP #$10
        
        ; update target vram address after writes to $2119
        LDA.b #$80 : STA $2115
        
        ; dma target address = $2118, write two registers once mode ($2118/$2119), autoincrement source address        
        LDX.w #$1801 : STX $4300
        
        ; target vram address is $7C00 (word)
        LDY.w #$7C00 : STY $2116
        
        ; source address is $7F0000
        LDY.w #$0000 : STY $4302
        LDA.b #$7F   : STA $4304
        
        ; Copy 0x07E0 bytes
        LDX.w #$07E0 : STX $4305
        
        ; transfer data on channel 0
        LDA.b #$01 : STA $420B
        
        SEP #$10
        
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; *$D13-$D61 JUMP LOCATION
    NMI_UpdateScrollingOwMap:
    {
        ; This updates the tilemap on the overworld every time you reach a map16 boundary
        ; From a graphical standpoint, that means every time you cross a boundary on an imaginary grid of
        ; 16x16 pixel tiles. 
        
        REP #$10
        
        ; dma will alternate writing between $2118 and $2119
        LDX.w #$1801 : STX $4300
        
        ; source bank is determined to be 0x00
        STZ $4304
        
        ; Value is either 0x81 or 0x80
        ; This means, increment on writing to $2119 and optionally write to VRAM horizontally (0x80)
        ; or vertically (0x81). It depends on how the data in the $1100 area was set up
        LDA $1101 : AND.b #$80 : ASL A : ROL A : ORA.b #$80 : STA $2115
        
        REP #$20
        
        ; X = $1100 & 0x3FFF, $02 = X + 2
        LDA $1100 : AND.w #$3FFF : TAX : INC #2 : STA $02
        
        LDY.w #$0000
    
    .nextTransfer
    
        REP #$21
        
        ; the next word in the array determines the target vram address (word)
        LDA $1102, Y : STA $2116
        
        TYA : ADC.w #$1104 : STA $4302
        
        ; brings us to the header of the next transfer block
        TYA : ADC $02 : TAY
        
        ; Set number of bytes to transfer
        STX $4305
        
        SEP #$20
        
        ; transfer data on channel 0
        LDA.b #$01 : STA $420B
        
        ; while somewhat nonsensical, the signal to stop transferring is a negative byte
        ; ( what if you wanted the next transfer to do between 0x80 and 0xFF bytes?)
        ; well apparently it wasn't designed for that.
        LDA $1103, Y : BPL .nextTransfer
        
        SEP #$30
        
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; *$D62-$E08 JUMP LOCATION
    NMI_UploadSubscreenOverlay:
    {

        ; write 0x2000 bytes to vram
        
        ; source bank is 0x7F
        LDA.b #$7F : STA $4304
        
        ; update target vram address after writes to $2119
        LDA.b #$80 : STA $2115
        
        REP #$31
        
        ; source address is $7F2000
        LDA.w #$2000 : STA $4302
        
        ; Going to loop many many times to fill the whole screen    
        LDX.w #$0000
        LDA.w #$0080
        
        BRA .startTransfers
    
    ; *$D7C ALTERNATE ENTRY POINT
    .firstHalf
    
        ; write 0x1000 bytes to vram (half of a tilemap)
        
        ; source bank is 0x7F
        LDA.b #$7F : STA $4304
        
        ; update target vram address after writes to $2119
        LDA.b #$80 : STA $2115
        
        REP #$31
        
        ; source address is $7F2000
        LDA.w #$2000 : STA $4302
        
        LDX.w #$0000
        LDA.w #$0040
        
        BRA .startTransfers
    
    ; *$D96 ALTERNATE ENTRY POINT
    .secondHalf
    
        ; write the second 0x1000 bytes to vram (half of a tilemap)
        
        ; source bank is 0x7F
        LDA.b #$7F : STA $4304
        
        ; update target vram address after writes to $2119
        LDA.b #$80 : STA $2115
        
        REP #$31
        
        ; source address is $7F3000
        LDA.w #$3000 : STA $4302
        
        LDX.w #$0040
        LDA.w #$0080
    
    .startTransfers
    
        ; This part does several DMA transfers that build a tilemap
        STA $02
        
        ; alternate writing to $2118 and $2119, autoincrement source address
        LDA.w #$1801 : STA $4300
        
        LDA.w #$0001 : STA $00
        
        ; We gonna write 0x80 bytes tonight... doo wop wop
        LDY.w #$0080
        
    .nextRound
    
        ; Each iteration of this loop writes four packets of 0x80 bytes each (0x200 bytes).
        ; Since the number of packets [ times two ] is specified by (A - X) in the various entry points to the function,
        ; this results in either 0x1000 or 0x2000 bytes being written to vram.
    
        ; target vram address (word) is determined by $7F4000
        LDA $7F4000, X : STA $2116
    
        ; store the number of bytes to use to the proper register
        STY $4305
    
        ; transfer data on channel 0
        LDA $00 : STA $420B
        
        ; updating the target vram address with a new value
        LDA $7F4002, X : STA $2116
    
        ; reset the number of bytes to 0x80
        STY $4305
        
        ; perform another 0x80 byte transfer
        LDA $00 : STA $420B
        
        ; updating target vram address (again, yeesh)
        LDA $7F4004, X : STA $2116
        
        ; 0x80 bytes (again, double yeesh)
        STY $4305
        
        ; I think you can tell where this is headed
        LDA $00 : STA $420B
        
        LDA $7F4006, X : STA $2116
        
        STY $4305
        
        LDA $00 : STA $420B
        
        ; Note there was a REP #$31 earlier that reset the carry. Tricky bastards, eh?
        ; Tells the next iteration to handle the next 4 packets specified in the $7F4000, X array
        TXA : ADC.w #$0008 : TAX : CMP $02 : BNE .nextRound
        
        SEP #$30
        
        STZ $0710
        
        RTS
    }

; ==============================================================================
    
    ; *$E09-$E4B JUMP LOCATION
    NMI_UploadBg3Unknown:
    {
        REP #$20
        
        ; target dma address is $2118, write two registers once mode, auto increment source address
        LDA.w #$1801 : STA $4300
        
        ; vram target address (word) = $0116
        LDA $0116 : STA $2116
        
        ; update vram address after writes to $2119
        LDX.b #$81 : STX $2115
        
        ; source address = $7EC880
        LDX.b #$7E   : STX $4304
        LDA.w #$C880 : STA $4302
        
        ; write 0x40 bytes
        LDA.w #$0040 : STA $4305
        
        ; transfer data on channel 0
        LDY.b #$01 : STY $420B
        
        ; write 0x40 bytes again
        STA $4305
        
        ; increment vram target address by 0x800 words
        LDA $0116 : ADD.w #$0800 : STA $2116
        
        ; source address = $7EC8C0
        LDA.w #$C8C0 : STA $4302
        
        ; transfer data on channel 0
        STY $420B
        
        REP #$20
        
        RTS
    
    ; *$E4B ALTERNATE ENTRY POINT
    .doNothing
    
        RTS
    }

; ==============================================================================

    ; $E4C-$E53 DATA
    {
        dw $0000, $0020, $1000, $1020
    }

; ==============================================================================
    
    ; *$E54-$EA8 JUMP LOCATION
    NMI_LightWorldMode7Tilemap:
    {
        STZ $2115
        
        ; Source address is in bank 0x0A
        LDA.b #$0A : STA $4304
        
        REP #$20
        
        ; Writing to $2118, incrementing of source address enabled
        ; (write once)
        LDA.w #$1800 : STA $4300
        
        STZ $04 : STZ $02
        
        LDY.b #$01
        LDX.b #$00
    
    .alpha
    
        LDA.w #$0020 : STA $06
        
        LDA $8E4C, X : STA $00
    
    .beta
    
        LDA $00 : STA $2116
        
        ; but is adjusted for each iteration of the loop by 0x80 words (0x100 bytes)
        ADD.w #$0080 : STA $00
        
        ; Mode 7 tilemap data is based at $0AC727 ($054727 in rom)    
        ; This data fills in the tilemap data that isn't "blank"
        LDA $02 : ADD.w #$C727 : STA $4302
        
        ; Number of bytes to transfer is 0x0020
        LDA.w #$0020 : STA $4305
        
        STY $420B
        
        ADD $02 : STA $02
        
        DEC $06 : BNE .beta
        
        INC $04 : INC $04
        
        LDX $04 : CPX.b #$08 : BNE .alpha
        
        SEP #$20
        
        RTS
    }

; ==============================================================================
    
    ; *$EA9-$EE6 JUMP LOCATION
    NMI_UpdateLeftBg2Tilemaps:
    {
        ; Copies $7F0000[0x1000] to VRAM address $0000
        
        ; vram address increments after writing to $2119
        LDA.b #$80 : STA $2115
        
        REP #$10
        
        ; Target address in vram is (word) 0x0000
        LDY.w #$0000 : STY $2116
        
        ; Target $2118, two registers write once ($2118 / $2119 alternating)
        LDY.w #$1801 : STY $4310
        
        ; Source address is $7F0000
        LDY.w #$0000 : STY $4312
        LDA.b #$7F : STA $4314
        
        ; transfer 0x0800 bytes
        LDY.w #$0800 : STY $4315
        
        ; Use channel 2 to transfer the data.
        LDA.b #$02 : STA $420B
        
        STY $4315
        
        ; Target address in vram is (word) 0x0800    
        LDY.w #$0800 : STY $2116
        
        ; Source address is $7F0800
        LDY.w #$0800 : STY $4312
        
        ; Use channel 1 to transfer the data.
        STA $420B
        
        SEP #$10
        
        RTS
    }

; ==============================================================================

    ; *$EE7-$F15 JUMP LOCATION
    NMI_UpdateBgChrSlots_3_to_4:
    {
        ; Transfers 0x1000 bytes from $7F0000 to VRAM $2C00 (word)
        
        REP #$20
        
        ; vram target is $2C00 (word)
        LDA.w #$2C00 : STA $2116
        
        ; Increment vram address on writes to $2119
        LDY.b #$80 : STY $2115
        
        ; target bbus address is $2118, write two registers once ($2118 / $2119)
        LDA.w #$1801 : STA $4300
        
        ; source address is $7F0000
        LDA.w #$0000 : STA $4302
        LDY.b #$7F : STY $4304
        
        ; write 0x1000 bytes
        LDA.w #$1000 : STA $4305
        
        ; transfer data on channel 0
        LDY #$01 : STY $420B
        
        SEP #$20
        
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; *$F16-$F44 JUMP LOCATION
    NMI_UpdateBgChrSlots_5_to_6:
    {
        ; Transfers 0x1000 bytes from $7F0000 to vram $3400 (word)
        
        REP #$20
        
        ; vram target address is $3400 (word)
        LDA.w #$3400 : STA $2116
        
        ; increment on writes to $2119
        LDY.b #$80 : STY $2115
        
        ; target $2118, write twice ($2118 / $2119)
        LDA.w #$1801 : STA $4300
        
        ; source address is $7F1000    
        LDA.w #$1000 : STA $4302
        LDY.b #$7F   : STY $4304
        
        ; write 0x1000 bytes
        LDA.w #$1000 : STA $4305
        
        ; transfer data on channel 1
        LDY.b #$01 : STY $420B
        
        SEP #$20
        
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; *$F45-$F71 JUMP LOCATION
    NMI_UpdateChrHalfSlot:
    {
        ; set vram target address as variable ($0116)
        LDA $0116 : STA $2117
        
        REP #$10
        
        ; increment on writes to $2119
        LDX.w #$0080 : STX $2115
        
        ; target is $2118, write twice ($2118 / $2119)    
        LDX.w #$1801 : STX $4300
        
        ; source address is $7F1000
        LDX.w #$1000 : STX $4302
        LDA.b #$7F   : STA $4304
        
        ; write 0x400 bytes
        LDX.w #$0400 : STX $4305
        
        ; transfer data on channel 1
        LDA.b #$01 : STA $420B
        
        SEP #$10
        
        RTS
    }

; ==============================================================================

    ; *$F72-$FF2 JUMP LOCATION
    NMI_UpdateChr_Bg0:
    {
        REP #$20
        
        ; set vram target to $2000 (word)
        LDA.w #$2000
        
        BRA NMI_UpdateChr_doUpdate
    }

; ==============================================================================

    ; *$F79 ALTERNATE ENTRY POINT
    NMI_UpdateChr_Bg1:
    {
        REP #$20
        
        ; set vram target to $2800 (word)
        LDA.w #$2800
        
        BRA NMI_UpdateChr_doUpdate
    }

; ==============================================================================

    ; *$F80 ALTERNATE ENTRY POINT
    NMI_UpdateChr_Bg2:
    {
        REP #$20
        
        ; set vram target to $3000 (word)
        LDA.w #$3000
        
        BRA NMI_UpdateChr_doUpdate
    }

; ==============================================================================

    ; *$F87 ALTERNATE ENTRY POINT
    NMI_UpdateChr_Bg3:
    {
        REP #$20
        
        ; set vram target to $3800 (word)
        LDA.w #$3800
        
        BRA NMI_UpdateChr_doUpdate
    }

; ==============================================================================

    ; *$F8E ALTERNATE ENTRY POINT
    NMI_UpdateChr_Spr0:
    {
        REP #$20
        
        ; vram target addr is $4400 (word)
        LDA.w #$4400 : STA $2116
        
        LDA.w #$0000 : STA $4302
        
        ; increment vram address on writes to $2119
        LDY.b #$80 : STY $2115
        
        ; target is $2118, write two registers once ($2118 / $2119)
        LDA.w #$1801 : STA $4300
        
        ; source address is $7F0000    
        LDY.b #$7F : STY $4304
        
        ; write 0x0800 bytes
        LDA.w #$0800 : STA $4305
        
        ; transfer data on channel 1
        LDY #$01 : STY $420B
        
        SEP #$20
        
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; *$FBD ALTERNATE ENTRY POINT
    NMI_UpdateChr_Spr2:
    {
        REP #$20
        
        ; set vram target to $5000 (word)
        LDA.w #$5000
        
        BRA NMI_UpdateChr_doUpdate
    }

; ==============================================================================

    ; *$FC4 ALTERNATE ENTRY POINT
    NMI_UpdateChr:
    {
    
    .Spr3
    
        REP #$20
        
        ; set vram target to $5800 (word)
        LDA.w #$5800
    
    .doUpdate
    
        STA $2116
        
        LDA.w #$0000 : STA $4302
        
        ; increment on writes to $2119
        LDY.b #$80 : STY $2115
        
        ; target is $2118, write two registers once ($2118 / $2119)    
        LDA.w #$1801 : STA $4300
        
        ; source address is $7F0000    
        LDY.b #$7F : STY $4304
        
        ; write 0x1000 bytes
        LDA.w #$1000 : STA $4305
        
        ; transfer data on channel 1
        LDY.b #$01 : STY $420B
        
        SEP #$20
        
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; *$FF3-$1037 JUMP LOCATION
    NMI_DarkWorldMode7Tilemap:
    {
        ; increment vram address on writes to $2118
        STZ $2115
        
        ; source bank is 0x00
        STZ $4304
        
        REP #$20
        
        ; set dma target register to $2118
        LDA.w #$1800 : STA $4300
        
        STZ $02
        
        LDA.w #$0020 : STA $06
        LDA.w #$0810 : STA $00
        
        ; going to transfer on channel 0
        LDY.b #$01
    
    .writeLoop
    
        LDA $00 : STA $2116
        ADD.w #$0080 : STA $00
        
        LDA $02 : ADD.w #$1000 : STA $4302
        
        ; transfering 0x20 bytes
        LDA.w #$0020 : STA $4305
        
        ; perform dma transfer
        STY $420B
        
        ; increment source address by 0x20 bytes each iteration
        ADD $02 : STA $02
        
        ; loop 0x20 times
        DEC $06 : BNE .writeLoop
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$1038-$108A JUMP LOCATION
    NMI_UpdateBg3ChrForDeathMode:
    {
        ; Transfers 0x800 bytes from $7E2000 to vram $7800 (word)
        
        REP #$20
        
        ; target vram addr is $7800 (word)
        LDA.w #$7800 : STA $2116
        
        LDA.w #$2000 : STA $4302
        
        ; increment vram addr on writes to $2119
        LDY.b #$80 : STY $2115
        
        ; target is $2118, write two registers once ($2118 / $2119)
        LDA.w #$1801 : STA $4300
        
        ; source address is $7E2000
        LDY.b #$7E : STY $4304
        
        ; write 0x0800 bytes
        LDA.b #$0800 : STA $4305
        
        ; transfer data on channel 1    
        LDY.b #$01 : STY $420B
        
        ; target vram addr is $7D00
        LDA.w #$7D00 : STA $2116
        
        LDA.w #$3400 : STA $4302
        
        ; don't know why this was written again. The value hasn't changed.
        ; I suspect some macro tomfoolery
        LDY.b #$80 : STY $2115
        
        ; again, this setting hasn't changed
        LDA.w #$1801 : STA $4300
        
        ; source address is $7E3400
        LDY.b #$7E : STY $4304
        
        ; transfer 0x0600 bytes
        LDA.w #$0600 : STA $4305
        
        ; transfer data on channel 1
        LDY.b #$01 : STY $420B
        
        SEP #$20
        
        RTS
    }

    ; *$108B-$10B6 JUMP LOCATION
    NMI_UpdateBarrierTileChr:
    {
        ; transfers 0x100 bytes from $7F0000 to vram $3D00 (word)
        
        REP #$10
        
        ; vram target address is $3D00 (word)
        LDX.w #$3D00 : STX $2116
        
        ; increment target addr on writes to $2119
        LDA.b #$80 : STA $2115
        
        ; base register is $2118, write two registers once ($2118 / $2119)
        LDX.w #$1801 : STX $4300
        
        ; source address is $7F0000
        LDX.w #$0000 : STX $4302
        LDA.b #$7F : STA $4304
        
        ; write 0x100 bytes
        LDX.w #$0100 : STX $4305
        
        ; transfer data on channel 1
        LDA.b #$01 : STA $420B
        
        SEP #$10
        
        RTS
    }

; ==============================================================================

    ; *$10B7-$10E2 JUMP LOCATION
    NMI_UpdateStarTiles:
    {
        ; ( transfers 0x40 bytes from $7F0000 to vram $3ED0 (word)
        
        REP #$10
        
        ; vram target address is $3ED0 (word)
        LDX.w #$3ED0 : STX $2116
        
        ; increment vram address on writes to $2119
        LDA.b #$80 : STA $2115
        
        ; base register is $2118, two registers write once ($2118 / $2119)
        LDX.w #$1801 : STX $4300
        
        ; source address is $7F0000
        LDX.w #$0000 : STX $4302
        LDA.b #$7F   : STA $4304
        
        ; write 0x40 bytes
        LDX.w #$0040 : STX $4305
        
        ; transfer data on channel 1
        LDA.b #$01 : STA $420B
        
        REP #$10
        
        RTS
    }

; ==============================================================================

    ; *$10E3-$10E6 LONG
    {
        JSR NMI_UploadTilemap
        
        RTL
    }

; ==============================================================================

    ; *$10E7-$10EA LONG
    {
        ; Unused???
        
        JSR $8D13 ; $D13 IN ROM    
        
        RTL
    }

; ==============================================================================

    ; $10EB-$110E LONG
    {
        ; UNUSED???
        
        STA $14 : TAY
        
        LDA $937A, Y : STA $00
        LDA $9383, Y : STA $01
        LDA $938C, Y : STA $02
        
        JSR $92A1 ; $12A1 in Rom
        
        LDA $14 : CMP.b #$01 : BNE .alpha
        
        STZ $1000 : STZ $1001
    
    .alpha
    
        STZ $14
        
        RTL
    }

; =============================================
    
    ; $110F-$112E DATA
    ; $112F-$113E DATA

; =============================================
    
    ; *$113F-$11C3 LONG
    {
        REP #$31
        
        LDA $0418 : AND.w #$000F : ADC $045C : PHA : ASL A : TAY
        
        LDX $910F, Y
        
        LDY.w #$0000
    
    .copyTilemap
    
        ; Every iteration writes 0x100 bytes.
        LDA $7E2000, X : STA $1000, Y
        LDA $7E2002, X : STA $1002, Y
        LDA $7E2080, X : STA $1040, Y
        LDA $7E2082, X : STA $1042, Y
        LDA $7E2100, X : STA $1080, Y
        LDA $7E2102, X : STA $1082, Y
        LDA $7E2180, X : STA $10C0, Y
        LDA $7E2182, X : STA $10C2, Y
        
        INX #4
        
        ; Loop until Y has increased by $40
        ; (what's wrong with a CPY.w #$0040 : BCC ...?
        INY #4 : TYA : AND.w #$003F : BNE .copyTilemap
        
        ; Y's net increase: $100
        TYA : ADD.w #$00C0 : TAY
        
        ; X's net increase: $200
        TXA : ADD.w #$01C0 : TAX
        
        ; Loop until Y reaches $800
        CPY.w #$0800 : BNE .copyTilemap
        
        PLX
        
        SEP #$20
        
        LDA $045C : ADD.b #$04 : STA $045C
        
        LDA $912F, X : STA $0116
        
        LDA.b #$01 : STA $17 : STA $0710
        
        RTL
    }

; ==============================================================================

    ; *$11C4-$12A0 LONG
    {
        ; Seems to be used to update the tiles of an room (indoors)
        ; One known use is for the watergate
        
        ; Not a water enabled room?
        LDA $AE : CMP.b #$19 : BNE .noWater
        
        LDA $0405 : AND $0098C1 : BEQ .skipAllThis
    
    ; *$11D3 ALTERNATE ENTRY POINT
    .noWater
    
        REP #$31
        
        ; It's worth noting that both $418 and $45C
        ; Start off at zero.
        LDA $0418 : AND.w #$000F : ADC $045C : PHA : ASL A : TAY
        
        LDX $910F, Y
        
        LDY.w #$0000
    
    .loadBlitBuffer
        
        ; Every iteration will write 0x100 bytes
        LDA $7E4000, X : STA $1000, Y
        LDA $7E4002, X : STA $1002, Y
        LDA $7E4080, X : STA $1040, Y
        LDA $7E4082, X : STA $1042, Y
        LDA $7E4100, X : STA $1080, Y
        LDA $7E4102, X : STA $1082, Y
        LDA $7E4180, X : STA $10C0, Y
        LDA $7E4182, X : STA $10C2, Y
        
        INX #4
        
        INY #4 : TYA : AND.w #$003F : BNE .loadBlitBuffer
        
        ; Net Y increase, $100
        TYA : ADD.w #$00C0 : TAY
        
        ; Net X increase, $200
        TXA : ADD.w #$01C0 : TAX
        
        ; Stop when we've written $800 bytes.
        CPY.w #$0800 : BNE .loadBlitBuffer
        
        PLX ; X = previously masked value ( ($418 & #$000F) + 0x045C)
        
        SEP #$30
        
        LDA $912F, X : ADD.b #$10 : STA $0116
        
        LDA.b #$01 : STA $17 : STA $0710
        
        RTL
    
    .skipAllThis
    
        REP #$31
        
        LDX.w #$00F0
        LDY.w #$0000
    
    .waterLoop
    
        LDA $9B52, X
        
        STA $1000, Y : STA $1002, Y : STA $1040, Y : STA $1042, Y
        STA $1080, Y : STA $1082, Y : STA $10C0, Y : STA $10C2, Y
        
        INY #4 : TYA : AND.w #$003F : BNE .waterLoop
        
        TYA : ADD.w #$00C0 : TAY : CPY.w #$0800 : BNE .waterLoop
        
        LDA $0418 : AND.w #$000F : ADD $045C : TAX
        
        SEP #$30
        
        LDA $912F, X : ADD.b #$10 : STA $0116
        
        RTL
    }

; ==============================================================================

    ; *$12A1-$1346 LOCAL
    {
        REP #$10
        
        ; Designates a source bank for a transfer to VRAM
        STA $4314
        
        ; You may have noticed this function is passed parameters through memory
        STZ $06
        
        LDY.w #$0000
        
        ; Typically tells us whether to look at $1000 or $1002
        LDA [$00], Y : BPL .validTransfer
        
        SEP #$30
        
        RTS
    
    .validTransfer
    
        ; determines the vram target address.
                             STA $04
        INY : LDA [$00], Y : STA $03 
        
        ; If this number is negative, A will end up as 0x01, otherwise 0x00
        ; This determines whether the transfer will write to the tilemap in a horizontal or vertical fashion.
        INY : LDA [$00], Y : AND.b #$80 : ASL A : ROL A : STA $07
        
        ; Check whether the source address will be fixed or incrmenting during the transfer.
        LDA [$00], Y : AND.b #$40 : STA $05
        
        ; This adds the "two registers, write once" setting
        LSR #3 : ORA.b #$01 : STA $4310
        
        ; Write to $2118 in DMA transfers
        LDA.b #$18 : STA $4311
        
        REP #$20
        
        ; write to the vram target address register.
        LDA $03 : STA $2116
        
        ; Set the number of bytes to transfer
        ; (the amount stored in the buffer is the number of bytes minus one)
        LDA [$00], Y : XBA : AND.w #$3FFF : TAX : INX : STX $4315
        
        ; Set the source address (which will be somewhere in the $1000[0x800] buffer
        INY #2 : TYA : ADD $00 : STA $4312
        
        ; A = #$40 or #$00
        ; If DMAing in incremental mode, branch
        LDA $05 : BEQ .incrementSourceAddress
        
        INX
        
        TXA : LSR A : TAX : STX $4315
        
        SEP #$20
        
        LDA $05 : LSR #3 : STA $4310
        
        ; A = 0x00 or 0x01
        ; Hence we'll either increment VRAM addresses by 2 or 64 bytes    
        LDA $07 : STA $2115
        
        LDA.b #$02 : STA $420B ; Fire DMA channel 2.
        
        ; Now data is written to $2119 (upper byte only gets written)
        LDA.b #$19 : STA $4311
        
        REP #$21
        
        ; Y is still the offset after reading the encoding information earlier.    
        TYA
        
        ; Add the original absolute address to this offset.
        ; It becomes the source address for DMA
        ADC $00 : INC A : STA $4312
        
        ; $03 contains the VRAM target address
        LDA $03 : STA $2116
        
        ; X contains the number of bytes to transfer
        STX $4315
        
        LDX.w #$0002
    
    .incrementSourceAddress
    
        ; Not sure what the point of this is.... seems useless.
        STX $03
        
        ; Again, the offset past the encoding info.
        ; A procedure to position ourselves just past the encoding information
        TYA : ADD $03 : TAY
        
        SEP #$20
        
        ; A = 0x01 or 0x00
        ; We're incrementing when $2118 is accessed.
        LDA $07 : ORA.b #$80 : STA $2115
        
        ; fire DMA channel 1
        LDA.b #$02 : STA $420B
        
        LDA [$00], Y : BMI .endOfTransfers
        
        JMP .validTransfer
    
    .endOfTransfers
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$1347-$137A LOCAL
    NMI_UpdateIrqGfx:
    {
        LDA $1F0C : BEQ .noTransfer
       
        ; Increment vram address when $2119 is written.
        LDA.b #$80 : STA.w !VMAINC
        
        REP #$20
        
        ; VRAM target is $5800
        LDA.w #$5800 : STA.w !VMADDR
        
        ; DMA will write to $2118, write two registers once mode ($2118/$2119)
        LDA.w #$1801 : STA.w !DMAP0
        
        ; source address is $7EE800
        LDA.w #$e800 : STA.w !A1T0
        LDX.b #$7e   : STX.w !A1B0
        
        ; We're going to write 0x800 bytes.
        LDA.w #$0800 : STA.w !DAS0
        
        SEP #$20
        
        ; transfer data on channel 0
        LDA.b #$01 : STA.w !MDMAEN
        
        STZ $1F0C
    
    .noTransfer
    
        RTS
    }

; ==============================================================================

    ; $137B-$1395 0DATA TABLE
    {
        db $02, $00, $6D, $1B, $BF, $A8, $3C, $56, $9C
        db $10, $10, $DD, $02, $E7, $E2, $E6, $E4, $DA
        db $00, $00, $0C, $00, $0C, $0C, $0C, $0C, $0E
    }

    ; $1396-$4FF2 DATA
    
    ; $1888- DATA
    {
        db $00, $00, $04, $08, $0C, $08, $0C, $00
        db $04, $00, $08, $04, $0C, $04, $0C, $00
        db $08, $10, $14, $18, $1C, $18, $1C, $10
        db $14, $10, $18, $14, $1C, $14, $1C, $10
        db $18, $60, $68
    }
    
    ; $18C1-$18C1 DATA (bit masks) Unmapped data for now
    {
    
    }
    
    ; $1B02-$1B09 DATA
    Dungeon_QuadrantOffsets:
    {
        dw $0000, $0040, $1000, $1040
    }
    
    ; $18C0-$18FF DATA ($98C0 CPU)
    {
    
    .set_masks
        dw $8000, $4000, $2000, $1000, $0800, $0400, $0200, $0100
        dw $0080, $0040, $0020, $0010, $0008, $0004, $0002, $0001
    
    .unset_masks
        dw $7FFF, $BFFF, $DFFF, $EFFF, $F7FF, $FBFF, $FDFF, $FEFF
        dw $FF7F, $FFBF, $FFDF, $FFEF, $FFF7, $FFFB, $FFFD, $FFFE    
    }
    
    ; $1B0A-$1B11 DATA
    {
        dw 5, 7, 11, 15
    }
    
    ; $1B12-$1B19
    {
        dw 8, 16, 24, 32
    }

    ; $4FF3-$5230
    {
        ; One set of locations for compressed 2bpp graphics.
        
        ; $4FF3 DATA LENGTH #$DF
        ; $50D2 DATA LENGTH #$DF
        ; $51B1 DATA LENGTH #$DF
    }

; ==============================================================================

    ; *$5231 - $52BD JUMP LOCATION LONG
    {  
        PHB : PHK : PLB
        
        REP #$20
        
        STZ $0A : STZ $0C 
        
        LDA.w #$0480 : STA $06
        
        SEP #$20
        
        ; Load ice rod tiles?
        LDA.b #$07
        
        JSR $D537 ; $5537 IN ROM
        
        ; Load fire rod tiles?
        LDA.b #$07
        
        JSR $D537 ; $5537 in Rom.
        
        ; Load hammer tiles?
        LDA.b #$03
        
        JSR $D537 ; $5537 in Rom.
        
        LDY.b #$5F
        LDA.b #$04
        
        JSR $D54E ; $554E IN ROM
        
        LDA.b #$03
        
        JSR $D553 ; $5553 IN ROM
        
        LDA.b #$01
        
        JSR $D553 ; $5553 in Rom.
        
        LDA.b #$04
        
        JSR $D537 ; $5537 in Rom.
        
        LDY.b #$60
        LDA.b #$0E
        
        JSR $D54E ; $554E in Rom.
        
        LDA.b #$07
        
        JSR $D553 ; $5553 in Rom.
        
        LDY.b #$5F
        LDA.b #$02
        
        JSR $D54E ; $554E in Rom.
        
        LDY.b #$54
        
        JSR Decomp_spr_low
        
        REP #$30
        
        LDA $00
        
        ; Skip ahead to write the push block sprite tiles
        LDX.w #$1480
        
        PHA
        
        LDY.w #$0008
        
        JSR Do3To4HighAnimated_variable
        
        PLA : ADD.w #$0180
        
        LDY.w #$0008
        
        JSR Do3To4HighAnimated_variable
        
        SEP #$30
        
        LDY #$60
        
        JSL Decomp_spr_low
        
        REP #$30
        
        ; target offset is $7EB280, convert 3 tiles (upper halves of animated rupee tiles)
        LDA $00
        LDX.w #$2280
        LDY.w #$0003
        
        PHA
        
        JSR Do3To4HighAnimated_variable
        
        PLA : ADD.w #$0180
        
        ; convert 3 tiles again (lower halves of animated rupee tiles)
        LDY.w #$0003
        
        JSR Do3To4HighAnimated_variable
        
        SEP #$30
        
        JSR $D3C6 ; $53C6
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $52BE-$52C7 DATA

; ==============================================================================

    ; *$52C8-$52FF LONG
    DecompSwordGfx:
    {
        PHB : PHK : PLB
        
        LDY.b #$5F
        
        JSR Decomp_spr_high
        
        LDY.b #$5E
        
        JSR Decomp_spr_low
        
        REP #$21
        
        ; Load Link's sword value.
        LDA $7EF359 : AND.w #$00FF : ASL A : TAY
        
        LDA $00 : ADC $D2BE, Y
        
        REP #$10
        
        LDX.w #$0000
        LDY.w #$000C
        PHA
        
        JSR Do3To4HighAnimated_variable
        
        PLA : ADD.w : #$0180
        
        LDY.w #$000C
        
        JSR Do3To4HighAnimated_variable
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $5300-$5307 DATA
    {
        dw $0660, $0660, $06F0, $0900
    }

; ==============================================================================

    ; *$5308-$5336 LONG
    DecompShieldGfx:
    {
        PHB : PHK : PLB
        
        LDY.b #$5F
        
        JSR Decomp_spr_high
        
        LDY.b #$5E
        
        JSR Decomp_spr_low
        
        REP #$21
        
        ; Load Link's shield value
        LDA $7EF35A : ASL A : TAY
        
        ; Load the index into $7E9000 to store the graphics to
        LDA $00 : ADC $D300, Y

        REP #$10
        
        LDX.w #$0300
        
        PHA
        
        JSR Do3To4HighAnimated
        
        PLA : ADD.w #$0180
        
        JSR Do3To4HighAnimated
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$5337-$5393 LONG
    DecompDungAnimatedTiles:
    {
        ; Decompress Animated Tiles for Dungeons
        
        PHB : PHK : PLB
        
        JSR Decomp_bg_low
        
        REP #$30
        
        ; Sets up animated tiles for the dungeons
        LDA $00
        LDY.w #$0030
        LDX.w #$1680
        
        JSR Do3To4LowAnimated_variable
        
        SEP #$30
        
        LDY.b #$5C
        
        JSR Decomp_bg_low
        
        REP #$30
        
        ; Sets up the second half of the animated tiles for the dungeons.
        LDA $00
        LDY.w #$0030
        LDX.w #$1C80
        
        JSR Do3To4LowAnimated_variable
        
        LDX.w #$0000
    
    .loop
    
        LDA $7EA880, X : PHA
        
        LDA $7EAC80, X : STA $7EA880, X
        LDA $7EAE80, X : STA $7EAC80, X
        LDA $7EAA80, X : STA $7EAE80, X
        
        PLA : STA $7EAA80, X
        
        INX #2 : CPX.w #$0200 : BNE .loop
        
        ; This is the base address in vram for animated tiles.
        LDA.w #$3B00 : STA $0134
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$5394-$53C5 LONG
    DecompOwAnimatedTiles:
    {
        ; Decompress Animated Tiles for Overworld
        ; Parameters: Y
        
        PHB : PHK : PLB
        
        PHY
        
        JSR Decomp_bg_low
        
        REP #$30
        
        LDA $00
        LDY.w #$0040
        LDX.w #$1680
        
        JSR Do3To4LowAnimated_variable
        
        SEP #$30
        
        ; Decompress the next consecutive bg graphics pack (e.g. 0x44 -> 0x45)
        PLY : INY
        
        JSR Decomp_bg_low
        
        REP #$30
        
        LDA $00
        LDY.w #$0020
        LDX.w #$1E80
        
        JSR Do3To4LowAnimated_variable
        
        ; Set offset of animated tiles in vram to $3C00 (word)
        LDA.w #$3C00 : STA $0134
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================
    
    ; *$53C6-$5406 LOCAL
    {
        ; Loads blue / orange block, bird / thief's chest, and star
        ; animated tiles (in that order)
        LDY.b #$0F
        
        JSR Decomp_bg_low
        
        REP #$30
        
        LDA $00
        LDY.w #$0010
        LDX.w #$2340
        
        JSR Do3To4LowAnimated_variable
        
        SEP #$30
        
        LDY.b #$58
        
        JSR Decomp_spr_low
        
        REP #$30
        
        LDA $00
        LDY.w #$0020
        LDX.w #$2540
        
        JSR Do3To4LowAnimated_variable
        
        SEP #$30
        
        LDY.b #$05
        
        JSR Decomp_bg_low
        
        REP #$30
        
        LDA $00 : ADD.w #$0480
        
        LDY.w #$0002
        LDX.w #$2DC0
        
        JSR Do3To4LowAnimated_variable
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $5407-$5422 DATA
    {
        db $00, $00, $00, $06, $00, $03, $00, $03
        db $00, $03, $00, $00, $00, $00, $00, $09
        db $00, $06, $00, $06, $00, $09, $00, $09
        db $00, $06, $00, $09
    }

; ==============================================================================

    ; *$5423-$5468 LONG
    Tagalong_LoadGfx:
    {
        ; Something of a tagalong graphics decompressor
        
        PHB : PHK : PLB
        
        LDY.b #$64
        
        ;  If your tagalong is princess zelda...
        LDA $7EF3CC : CMP.b #$01 : BEQ .doDecomp
        
        LDY.b #$66
        
        ; #$09 = Creepy middle aged guy
        ; If less than the middle aged guy
        LDA $7EF3CC : CMP.b #$09 : BCC .doDecomp
        
        LDY.b #$59
        
        ; Otherwise if less then #$0C
        CMP.b #$0C : BCC .doDecomp
        
        LDY.b #$58
    
    .doDecomp
    
        ; Zelda and anything else less than 0x0C
        
        JSR Decomp_spr_high
        
        LDY.b #$65 ; Loads up graphics for the old man and maiden gfx
        
        JSR Decomp_spr_low
        
        REP #$30
        
        LDA $7EF3CC : AND.w #$00FF : ASL A : TAX
        
        LDA $00 : ADD $00D407, X
        
        LDY.w #$0020
        LDX.w #$2940
        
        JSR Do3To4LowAnimated_variable
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $5469-$54DA DATA
    pool GetAnimatedSpriteTile:
    {
        dw $09C0, $0030, $0060, $0090, $00C0, $0300, $0318, $0330
        dw $0348, $0360, $0378, $0390, $0930, $03F0, $0420, $0450
        dw $0468, $0600, $0630, $0660, $0690, $06C0, $06F0, $0270
        dw $0750, $0768, $0900, $0930, $0960, $0990, $09F0, $0000
        dw $00F0, $0A20, $0A50, $0660, $0600, $0618, $0630, $0648
        dw $0678, $06D8, $06A8, $0708, $0738, $0768, $0960, $0900
        dw $03C0, $0990, $09A8, $09C0, $09D8, $0A08, $0A38, $0600
    }

; ==============================================================================
    
    ; *$54DB-$5536 LONG
    GetAnimatedSpriteTile:
    {
        ; Inputs:
        ; A - indexes into a table of offsets into $7E9000, X
        ; this tells the game where in the animated tiles buffer ($7E9000)
        ; to place the decompressed tiles. More explicitly, the parameter
        ; passed to A tells us to grab a specific graphic, and this routine
        ; uses a table to know where to put it in the animated tiles buffer.
        
        PHB : PHK : PLB
        
        PHA
        
        ; $00[3] = $7F4000
        STZ $00
        LDA.b #$40 : STA $01
        LDA.b #$7F : STA $02 : STA $05
        
        BRA .copyToBuffer
    
    ; *$54ED ALTERNATE ENTRY POINT
    .variable
    
        ; Input for this is the same as the main entry point
        
        PHB : PHK : PLB
        
        PHA
        
        LDY.b #$5D
        
        CMP.b #$23 : BEQ .firstSet
        CMP.b #$37 : BCS .firstSet
        
        LDY.b #$5C
        
        CMP.b #$0C : BEQ .secondSet
        CMP.b #$24 : BCS .secondSet
        
        ; this is the third possible graphics pack that could be loaded.
        LDY.b #$5B
    
    .firstSet
    .secondSet
    
        JSR Decomp_spr_high
        
        ; always decompress spr graphics pack 0x5A into the low part of $7E4000
        LDY.b #$5A
        
        JSR Decomp_spr_low
    
    .copyToBuffer
    
        ; copy the decompressed tiles to the animated tiles buffer in wram
        
        PLA
        
        REP #$21
        
        AND.w #$00FF : ASL A : TAX
        
        ; time to determine where in the decompressed buffer the graphics will
        ; be copied from
        LDA $00 : ADC $D469, X
        
        REP #$10
        
        ; target address is $7EBD40, convert 2 tiles
        LDX.w #$2D40
        LDY.w #$0002
        PHA
        
        JSR Do3To4HighAnimated_variable
        
        ; go to the next line
        PLA : ADD.w #$0180
        
        ; convert 2 tiles again
        LDY.w #$0002
        
        JSR Do3To4HighAnimated_variable
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $5537-$5584 LOCAL
    {
        ; Parameters: A
        
        STA $0A
        
        ; Will always load a pointer to sprite graphics pack 0
        LDY.b #$00
        
        LDA $CFF3, Y : STA $02 : STA $05
        LDA $D0D2, Y : STA $01
        LDA $D1B1, Y : STA $00
        
        BRA .expandTo4bpp
    
    ; *$554E Alternate Entry Point
    
        PHA
        
        JSR Decomp_spr_low
        
        PLA
    
    ; *$5553 Alternate Entry Point
    
        STA $0A
        
        ; $00[3] = $7F4000
        STZ $00
        LDA.b #$40 : STA $01
        LDA.b #$7F : STA $02 : STA $05
    
    .expandTo4bpp
    
        REP #$31
        
        LDY $0C
        
        LDA $00 : ADC $D21D, Y
        
        LDX $06
        LDY $0A
        
        PHA
        
        JSR Do3To4HighAnimated_variable
        
        PLA : ADD.w #$0180
        
        LDY $0A
        
        JSR Do3To4HighAnimated_variable
        
        INC $0C : INC $0C
        
        STX $06
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $5585-$55CA LOCAL
    ; This "unpacks" animated tiles
    {
        LDY.w #$0008 : STY $0E
    
    .nextTile
    
        STA $00 : ADD.w #$0010 : STA $03
        
        LDY.w #$0007
    
    .writeTile
    
        LDA [$00] : STA $7E9000, X : INC $00 : INC $00
        
        LDA [$03] : AND.w #$00FF : STA $7E9010, X : INC $03 : INX #2
        
        DEY : BPL .writeTile
        
        TXA : ADD.w #$0010 : TAX
        
        ; not sure what the point of this is.
        LDA $03 : AND.w #$0078 : BNE .mystery
        
        LDA $03 : ADD.w #$0180 : STA $03
    
    .mystery
    
        LDA $03
        
        DEC $0E : BNE .nextTile
        
        RTS
    }

; ==============================================================================

    ; *$55CB-$5618 LOCAL
    ; Isn't this just another 3bpp to 4bpp converter?
    ; Swear to God, they have like 8 different routines for this
    ; (update: they have at least 3)
    ; The main difference among them is the target address base
    ; ($7E9000 instead of $7F0000, for example)
    Do3To4LowAnimated:
    {
        LDY.w #$0008
        
    ; *$55CE ALTERNATE ENTRY POINT
    .variable
        ; "variable" because the number of tiles it processes is variable.
        
        STY $0E
    
    .nextTile
    
        STA $00 : ADD.w #$0010 : STA $03
        
        LDY.w #$0003
    
    .writeTile
        
        LDA [$00] : STA $7E9000, X : INC $00 : INC $00
        LDA [$03] : AND.w #$00FF : STA $7E9010, X : INC $03 : INX #2
        
        LDA [$00] : STA $7E9000, X : INC $00 : INC $00
        LDA [$03] : AND.w #$00FF : STA $7E9010, X : INC $03 : INX #2
        
        DEY : BPL .writeTile
        
        TXA : ADD.w #$0010 : TAX
        
        LDA $03
        
        DEC $0E : BNE .nextTile
        
        RTS
    }

; ==============================================================================

    ; *$5619-$566D LOCAL
    Do3To4HighAnimated:
    {
        ; Inputs:
        ; A - local portion of the pointer to the data to be converted
        ; X - offset into the animated tile buffer of WRAM (0x7E9000)
        ; Y - Number of tiles to convert
        
        LDY.w #$0006
    
    ; *$561C Alternate Entry Point
    .variable
    
        STY $0E
    
    .nextTile
    
        STA $00
        
        ; Addresses will be #$10 apart
        ADD.w #$0010 : STA $03
        
        LDY.w #$0007
    
    .writeTile
    
        LDA [$00] : STA $7E9000, X : XBA : ORA [$00] : AND.w #$00FF : STA $08 
        INC $00 : INC $00
        
        LDA [$03] : AND.w #$00FF : STA $BD : ORA $08 : XBA : ORA $BD : STA $7E9010, X
        INC $03 : INX #2 
        
        DEY : BPL .writeTile
        
        TXA : ADD.w #$0010 : TAX
        
        LDA $03 : AND.w #$0078 : BNE .noAdjust
        
        ; Since we're most likely working with sprite gfx we have to adjust
        ; by 0x10 tiles to get to the next line
        LDA $03 : ADD.w #$0180 : STA $03
    
    .noAdjust
    
        LDA $03
        
        DEC $0E : BNE .nextTile
        
        RTS
    }

; ==============================================================================
    
    ; $566E-$5787 LONG
    LoadTransAuxGfx:
    {
        PHB : PHK : PLB
        
        ; $00[3] = $7E6000
        STZ $00
        LDA.b #$60 : STA $01
        LDA.b #$7E : STA $02
        
        REP #$30
        
        ; $0E = $0AA2 * 4
        LDA $0AA2 : AND.w #$00FF : ASL #2 : STA $0E
        
        SEP #$20
        
        LDX $0E
        
        LDA $DD97, X : BEQ .noBgGfxChange0
        
        STA $7EC2F8
        
        SEP #$10
        
        TAY
        
        JSR Decomp_bg_variable
    
    .noBgGfxChange0
    
        SEP #$10
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        REP #$10
        
        LDX $0E
        
        LDA $DD98, X : BEQ .noBgGfxChange1
        
        STA $7EC2F9
        
        SEP #$10
        
        TAY
        
        JSR Decomp_bg_variable
    
    .noBgGfxChange1
    
        SEP #$10
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        REP #$10
        
        LDX $0E
        
        LDA $DD99, X : BEQ .noBgGfxChange2
        
        STA $7EC2FA
        
        SEP #$10
        
        TAY
        
        JSR Decomp_bg_variable
    
    .noBgGfxChange2
    
        SEP #$10
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        REP #$10
        
        LDX $0E
        
        LDA $DD9A, X : BEQ .noBgGfxChange3
        
        STA $7EC2FB
        
        SEP #$10
        
        TAY
        
        JSR Decomp_bg_variable
    
    .noBgGfxChange3
    
        SEP #$10
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        BRA .continue
    
    ; *$56F9 ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
        
        STZ $00
        LDA.b #$78 : STA $01
        LDA.b #$7E : STA $02
    
    .continue
    
        REP #$30
        
        ; $0E = $0AA3 * 4
        LDA $0AA3 : AND.b #$00FF : ASL #2 : STA $0E
        
        SEP #$20
        
        LDX $0E
        
        LDA $DB57, X : BEQ .noSprGfxChange0
        
        STA $7EC2FC
    
    .noSprGfxChange0
    
        SEP #$10
        
        LDA $7EC2FC : TAY
        
        JSR Decomp_spr_variable
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        REP #$10
        
        LDX $0E
        
        LDA $DB58, X : BEQ .noSprGfxChange1
        
        STA $7EC2FD
    
    .noSprGfxChange1
    
        SEP #$10
        
        LDA $7EC2FD : TAY
        
        JSR Decomp_spr_variable
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        REP #$10
        
        LDX $0E
        
        LDA $DB59, X : BEQ .noSprGfxChange2
        
        STA $7EC2FE
    
    .noSprGfxChange2
    
        SEP #$10
        
        LDA $7EC2FE : TAY
        
        JSR Decomp_spr_variable
        
        ; Increment buffer address by 0x0600.
        LDA $01 : ADD.b #$06 : STA $01
        
        REP #$10
        
        LDX $0E
        
        LDA $DB5A, X : BEQ .noSprGfxChange3
        
        STA $7EC2FF
    
    .noSprGfxChange3
    
        SEP #$10
        
        LDA $7EC2FF : TAY
        
        JSR Decomp_spr_variable
        
        STZ $0412
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$5788-$580D LONG
    {
        PHB : PHK : PLB
        
        ; target decompression address = $7E6000
        ; Y = graphics pack to decompress
        STZ   $00
        LDA.b #$60 : STA $01
        LDA.b #$7E : STA $02
        LDA   $7EC2F8 : TAY
        
        JSR $E78F ; $678F in Rom.
        
        ; target decompression address = $7E6600
        LDA $01 : ADD.b #$06 : STA $01
        LDA $7EC2F9 : TAY
        
        JSR $E78F ; $678F in Rom.
        
        ; target decompression address = $7E6C00
        LDA $01 : ADD.b #$06 : STA $01
        LDA $7EC2FA : TAY
        
        JSR $E78F ; $678F in Rom.
        
        ; target decompression address = $7E7200
        LDA $01 : ADD.b #$06 : STA $01
        LDA $7EC2FB : TAY
        
        JSR $E78F ; $678F in Rom.
        
        ; target decompression address = $7E7800
        STZ $00
        LDA.b #$78 : STA $01
        LDA.b #$7E : STA $02
        LDA $7EC2FC : TAY
        
        JSR Decomp_spr_variable
        
        ; target decompression address = $7E7E00
        LDA $01 : ADD.b #$06 : STA $01
        LDA $7EC2FD : TAY
        
        JSR Decomp_spr_variable
        
        ; target decompression address = $7E8400
        LDA $01 : ADD.b #$06 : STA $01
        LDA $7EC2FE : TAY
        
        JSR Decomp_spr_variable
        
        ; target decompression address = $7E8A00
        LDA $01 : ADD.b #$06 : STA $01
        LDA $7EC2FF : TAY
        
        JSR Decomp_spr_variable
        
        STZ $0412
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$580E-$5836 LON
    Attract_DecompressStoryGfx:
    {
        ; This routine decompresses graphics packs 0x67 and 0x68
        ; Now the funny thing is that these are picture graphics for the intro
        ; (module 0x14)
        ; I at first thought they were the game's text.
        ; graphics pack 0x68 is EMPTY, by the way.
        
        PHB : PHK : PLB
        
        STZ $00
        
        LDA.b #$40 : STA $01
        
        ; $00[3] = 0x7F4000
        LDA.b #$7F : STA $02 : STA $05
        
        LDA.b #$67 : STA $0E
        
        ; This loop decompresses sprite graphics packs 0x67 and 0x68
    
    .loop
    
        LDY $0E
        
        JSR Decomp_spr_variable
        
        ; $00[3] = 0x7F4800; set up the next transfer
        LDA $01 : ADD.b #$08 : STA $01
        
        INC $0E
        
        LDA $0E : CMP.b #$69 : BNE .loop
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $5837-$5854 Jump Table
    {
        ; \task interleaved!
    
    meta .states
        dw $D892 ; = $5892*
        dw $D8FE ; = $58FE* ; gets ready to decompress typical graphics...
        dw $D9B9 ; = $59B9* ; more decompression...
        dw $D9F8 ; = $59F8* ; ""
        dw $DA2C ; = $5A2C* ; ""
        dw $D8A5 ; = $58A5* ; load overlays and ... silence music? what?
        dw $D8C7 ; = $58C7*
        dw $D8B3 ; = $58B3*
        dw $D8BB ; = $58BB*
        dw $D8C7 ; = $58C7*
        dw $D8D5 ; = $58D5*
        dw $DA63 ; = $5A63* 
        dw $DABB ; = $5ABB*
        dw $DB1B ; = $5B1B*
        dw $D8CF ; = $58CF*
        
        interleave
        {
            {states word i} => {lowers byte i},
                                uppers byte i >> 8}
        }
    }

    ; $5855-$5863 DATA
    {
        db $00, $0E, $0F, $10, $11, $00, $00, $00
        db $00, $00, $00, $12, $13, $14, $00
    }

    ; *$5864-$5891 LONG
    {
        ; Sets up the two low bytes of the decompression target address (0x4000)
        ; The bank is determined in the subroutine that's called below
                     STZ $00
        LDA.b #$40 : STA $01
        
        LDX $0200
        
        LDA $00D855, X : STA $17 : STA $0710
        
        ; Determine which subroutine in the jump table to call.
        LDA $00D837, X : STA $0E
        LDA $00D846, X : STA $0F
        
        LDX.b #$00
        
        LDA $8A : AND.b #$40 : BEQ .lightWorld
        
        LDX.b #$08
    
    .lightWorld
    
        INC $0200
        
        JMP ($000E) ; Use jump table at $5837
    }

; ==============================================================================

    ; *$5892-$58A4 JUMP LOCATION (LONG)
    {
        INC $06BA : LDA $06BA : CMP.b #$20 : BEQ .ready
        
        STZ $0200
        
        RTL
    
    .ready
    
        ; Loads overworld exit data and animated tiles. Initialization, mostly.
        JSL $029E5F ; $11E5F IN ROM
        
        RTL
    }

; ==============================================================================

    ; *$58A5-$58B2 JUMP LOCATION (LONG)
    {
        JSL $02B2D4 ; $132D4 IN ROM
        
        DEC $11
        
        LDA.b #$0C : STA $17 : STA $0710
        
        RTL
    }

; ==============================================================================

    ; *$58B3-$58BA JUMP LOCATION (LONG)
    {
        JSL $02B2E6 ; $132E6 IN ROM
        
        INC $0710
        
        RTL
    }

; ==============================================================================

    ; *$58BB-$58C6 JUMP LOCATION (LONG)
    {
        JSL $02B334 ; $13334 IN ROM
        
        LDA.b #$0C : STA $17 : STA $0710
        
        RTL
    }

; ==============================================================================

    ; *$58C7-$58CE JUMP LOCATION (LONG)
    {
        LDA.b #$0D : STA $17 : STA $0710
        
        RTL
    }

; ==============================================================================

    ; *$58CF-$58D4 JUMP LOCATION (LONG)
    {
        LDA.b #$0E : STA $0200
        
        RTL
    }

; ==============================================================================

    ; $58D5-$58ED JUMP LOCATION (LONG)
    {
        LDY.b #$58
        
        ; Death mountain here denotes either the light world or the dark world version
        ; bitwise AND with 0xBF masks out the 0x40 bit.
        LDA $8A : AND.b #$BF
        
        CMP.b #$03 : BEQ .deathMountain
        CMP.b #$05 : BEQ .deathMountain
        CMP.b #$07 : BEQ .deathMountain
        
        LDY.b #$5A
    
    .deathMountain
    
        JSL $00D394 ; $5394 IN ROM
        
        RTL
    }

; ==============================================================================
    
    ; $58EE-$58FD DATA

; ==============================================================================

    ; $58FE-$59B8 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        PHX
        
        REP #$30
        
        LDA $0AA1 : AND.w #$00FF : ASL #3 : TAX
        LDA $0AA2 : AND.w #$00FF : ASL #2 : TAY
        
        SEP #$20
        
        LDA $DD97, Y : BNE .override1
        
        LDA $E076, X
    
    .override1
    
        STA $7EC2F8
        
        LDA $DD98, Y : BNE .override2
        
        LDA $E077, X
    
    .override2
    
        STA $7EC2F9
        
        LDA $DD99, Y : BNE .override3
        
        LDA $E078, X
    
    .override3
    
        STA $7EC2FA
        
        LDA $DD9A, Y : BNE .override4
        
        LDA $E079, X
    
    .override4
    
        STA $7EC2FB
        
        REP #$20
        
        LDA $0AA3 : AND.w #$00FF : ASL #2 : TAY
        
        SEP #$20
        
        LDA $DB57, Y : BEQ .noChange1
        
        STA $7EC2FC
    
    .noChange1
    
        LDA $DB58, Y : BEQ .noChange2
        
        STA $7EC2FD
    
    .noChange2
    
        LDA $DB59, Y : BEQ .noChange3
        
        STA $7EC2FE
    
    .noChange3
    
        LDA $DB5A, Y : BEQ .noChange4
        
        STA $7EC2FF
    
    .noChange4
    
        SEP #$10
        
        PLX
        
        LDA $00D8EF, X : STA $08
        LDA $00D8EE, X : TAY
        
        ; apparently the low 16 bits of the source address are found elsewhere...
        LDA.b #$7F
        
        JSR Decomp_bg_variable_bank
        
        LDA $01 : ADD.b #$06 : STA $01
        
        LDY $08
        
        JSR Decomp_bg_variable
        
        PLB
        
        LDA.b #$7F : STA $02 : STA $05
        
        REP #$31
        
        ; Source address is $7F4000, number of tiles is 0x0040, base target address is $7F0000
        LDX.w #$0000
        LDY.w #$0040
        LDA.w #$4000
        
        JSR Do3To4High16Bit
        
        LDY.w #$0040
        LDA $03
        
        JSR Do3To4Low16Bit
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; $59B9-$59F7 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        LDA $00D8F1, X : STA $08
        LDA $00D8F0, X : TAY
        
        LDA.b #$7F
        
        JSR Decomp_bg_variable_bank
        
        LDA $01 : ADD.b #$06 : STA $01
        LDY $08
        
        JSR Decomp_bg_variable
        
        PLB
        
        LDA.b #$7F : STA $02 : STA $05
        
        REP #$31
        
        ; Source address is $7F4000, number of tiles is 0x0040, base target address is $7F0000
        LDX.w #$0000
        LDY.w #$0040
        LDA.w #$4000
        
        JSR Do3To4Low16Bit
        
        LDY.w #$0040
        
        LDA $03
        
        JSR Do3To4High16Bit
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; $59F8-$5A2B JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        LDA $7EC2F9 : TAY
        
        LDA.b #$7F
        
        JSR Decomp_bg_variable_bank
        
        LDA $01 : ADD.b #$06 : STA $01
        
        LDA $7EC2FA : TAY
        
        JSR Decomp_bg_variable
        
        PLB
        
        LDA.b #$7F : STA $02 : STA $05
        
        REP #$31
        
        ; Source address is $7F4000, number of tiles is 0x0080, base target address is $7F0000
        LDX.w #$0000
        LDY.w #$0080
        LDA.w #$4000
        
        JSR Do3To4High16Bit
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; $5A2C-$5A62 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        LDA $00D8F3, X : STA $08
        LDA $00D8F2, X : TAY
        
        LDA.b #$7F
        
        JSR Decomp_bg_variable_bank
        
        LDA $01 : ADD.b #$06 : STA $01
        LDY $08
        
        JSR Decomp_bg_variable
        
        PLB
        
        LDA.b #$7F : STA $02 : STA $05
        
        REP #$31
        
        ; Source address is $7F4000, number of tiles is 0x0080, base target address is $7F0000
        LDX.w #$0000
        LDY.w #$0080
        LDA.w #$4000
        
        JSR Do3To4Low16Bit
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; $5A63-$5ABA JUMP LOCATION (LONG)
    ; no name for this yet
    {
        STZ $1D
        
        LDA $8A    : BEQ .subscreen
        CMP.b #$70 : BEQ .subscreen
        CMP.b #$40 : BEQ .subscreen
        CMP.b #$5B : BEQ .subscreen
        CMP.b #$03 : BEQ .subscreen
        CMP.b #$05 : BEQ .subscreen
        CMP.b #$07 : BEQ .subscreen
        CMP.b #$43 : BEQ .subscreen
        CMP.b #$45 : BEQ .subscreen
        CMP.b #$47 : BNE .normal
    
    .subscreen
    
        LDA.b #$01 : STA $1D
    
    .normal
    
        PHB : PHK : PLB
        
        LDA $00D8F4, X : TAY
        
        LDA $D1B1, Y : STA $00
        LDA $D0D2, Y : STA $01
        LDA $CFF3, Y : STA $02
        STA $05
        
        PLB
        
        REP #$31
        
        ; source address is determined above, number of tiles is 0x0040, base target address is $7F0000
        LDX.w #$0000
        LDY.w #$0040
        
        LDA $00
        
        JSR Do3To4High16Bit
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$5ABB-$5B1A JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        LDA $7EC2FC : TAY
        
        LDA.b #$7F : STA $02 : STA $05
        
        JSR Decomp_spr_variable
        
        LDA $01 : ADD.b #$06 : STA $01
        
        LDA $7EC2FD : TAY
        
        JSR Decomp_spr_variable
        
        PLB
        
        LDA.b #$7F : STA $02 : STA $05
        
        REP #$31
        
        LDX.w #$0000
        LDY.w #$0040
        
        LDA $7EC2FC
        
        CMP.w #$0052 : BEQ .high
        CMP.w #$0053 : BEQ .high
        CMP.w #$005A : BEQ .high
        CMP.w #$005B : BNE .low
    
    .high
    
        LDA.w #$4000
        
        JSR Do3To4High16Bit
        
        BRA .lastGfxPack
    
    .low
    
        LDA.w #$4000
        
        JSR Do3To4Low16Bit
    
    .lastGfxPack
    
        LDY.w #$0040
        
        LDA $03
        
        JSR Do3To4Low16Bit
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; $5B1B-$5B56 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        LDA $7EC2FE : TAY
        
        LDA.b #$7F : STA $02 : STA $05
        
        JSR Decomp_spr_variable
        
        LDA $01 : ADD.b #$06 : STA $01
        
        LDA $7EC2FF : TAY
        
        JSR Decomp_spr_variable
        
        PLB
        
        LDA.b #$7F : STA $02 : STA $05
        
        REP #$31
        
        LDX.w #$0000
        LDY.w #$0080
        LDA.w #$4000
        
        JSR Do3To4Low16Bit
        
        SEP #$30
        
        JSL $07AAA2 ; $3AAA2 IN ROM
        
        RTL
    }

; =============================================

    ; $5B57
    ; This table is indexed by $0AA3 * 4 (0x90 entries)
    db $00, $49, $00, $00
    db $46, $49, $0C, $1D
    db $48, $49, $13, $1D
    db $46, $49, $13, $0E
    db $48, $49, $0C, $11
    db $48, $49, $0C, $10
    db $4F, $49, $4A, $50
    db $0E, $49, $4A, $11
    db $46, $49, $12, $00
    db $00, $49, $00, $50
    db $00, $49, $00, $11
    db $48, $49, $0C, $00
    db $00, $00, $37, $36
    db $48, $49, $4C, $11
    db $5D, $2C, $0C, $44
    db $00, $00, $4E, $00
    db $0F, $00, $12, $10
    db $00, $00, $00, $4C
    db $00, $0D, $17, $00
    
    ; .....
    
    ; $5D97
    ; This table is indexed by $0AA2 * 4 - (0x52 entries)
    db $06, $00, $1F, $18
    db $08, $00, $22, $1B
    db $06, $00, $1F, $18
    db $07, $00, $23, $1C
    
    db $07, $00, $21, $18
    db $09, $00, $20, $19
    db $0B, $00, $21, $1A
    db $0C, $00, $24, $19
    
    db $08, $00, $22, $1B
    db $0C, $00, $25, $1B
    db $0C, $00, $26, $1B
    db $0A, $00, $27, $1D
    
    db $0A, $00, $28, $1E
    db $0B, $00, $29, $16
    db $0D, $00, $2A, $18
    
    ; ......
    
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    db $00, $00, $00, $00
    
    db $72, $71, $72, $71
    db $17, $40, $41, $39
    
    ; $5EDF-$5EFE DATA
    pool Graphics_IncrementalVramUpload:
    {
    
    ; $5EDF
        db $50, $51, $52, $53, $54, $55, $56, $57
        db $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
        
    ; $5EEF
        db $00, $02, $04, $06, $08, $0A, $0C, $0E
        db $10, $12, $14, $16, $18, $1A, $1C, $1E
    }
    
; ==============================================================================

    ; $5EFF-$5F19 LONG
    Graphics_IncrementalVramUpload:
    {
        LDX $0412 : CPX.b #$10 : BEQ .finished
        
        LDA $00DEDF, X : STA $19
        
        STZ $0118
        
        LDA $00DEEF, X : STA $0119
        
        INC $0412
    
    .finished
    
        RTL
    }

; ==============================================================================

    ; $5F1A-$5F4E LONG
    PrepTransAuxGfx:
    {
        ; Prepares the transition graphics to be transferred to VRAM during NMI
        ; This could occur either during this frame or any subsequent frame
        
        ; Set bank for source address
        LDA.b #$7E : STA $02 : STA $05
        
        REP #$31
        
        ; source address is $7E6000, number of tiles is 0x40,
        ; base address is $7F0000.
        LDX.w #$0000
        LDY.w #$0040
        LDA.w #$6000
        
        ; The first graphics pack always uses the higher 8 palette values
        JSR Do3To4High16Bit
        
        ; Number of tiles for next set is 0xC0
        LDY #$00C0
        
        ; If this branch is taken, all 3 graphics packs will use the lower 8
        ; palette values.
        LDA $0AA2 : AND.w #$00FF : CMP.w #$0020 : BCC .low
        
        ; $0AA2 >= 0x20, the first two graphics packs expand as high 8 palette
        ; values.
        LDY.w #$0080
        
        LDA $03
        
        JSR Do3To4High16Bit
        
        ; The last set will use the lower 8 palette values in this case.
        LDY #$0040
    
    .low
    
        LDA $03
        
        JSR Do3To4Low16Bit
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *5F4F-$5FB7 LOCAL
    Do3To4High16Bit:
    {
        ; Looks similar to Do3To4High, exept that it accepts more parameters
        ; Inputs:
        ; A - Used to set the low 2 bytes of $00[3] - source address for
        ;     already decompressed data.
        ; Y - number of 3bpp tiles to convert to 4bpp (using only the higher 8
        ;     colors of the palette)
        ; X - a starting offset into $7F0000
        
        STY $0C
    
    .nextTile
    
        STA $00 : ADD.w #$0010 : STA $03
        
        LDY.w #$0003
    
    .writeTile
    
        LDA [$00] : STA $7F0000, X : XBA : ORA [$00] : AND.w #$00FF : STA $08
        INC $00 : INC $00
        
        LDA [$03] : AND.w #$00FF : STA $0A : ORA $08 : XBA : ORA $0A : STA $7F0010, X
        INC $03 : INX #2
        
        LDA [$00] : STA $7F0000, X : XBA : ORA [$00] : AND.w #$00FF : STA $08
        INC $00 : INC $00
        
        LDA [$03] : AND.w #$00FF : STA $0A : ORA $08 : XBA : ORA $0A : STA $7F0010, X
        INC $03 : INX #2
        
        DEY : BPL .writeTile
        
        TXA : ADD.w #$0010 : TAX
        
        LDA $03
        
        DEC $0C : BNE .nextTile
        
        RTS
    }

; =============================================

    ; *$5FB8-$6030 LOCAL
    Do3To4Low16Bit:
    {
        ; Very similar to Do3To4Low, except that the routine is completely standalone, and remains in 16-bit
        ; until after the routine is finished as well. (There are other differences)
        ; Inputs:
        ; A - Used to set the low 2 bytes of $00[3] - source address for already decompressed data.
        ; Y - number of 3bpp tiles to convert to 4bpp (using only the lower 8 colors of the palette)
        ; X - a starting offset into $7F0000
        
        STY $0C
    
    .nextTile
    
        STA $00 : ADD.w #$0010 : STA $03
        
        LDY.w #$0001
    
    .nextHalf
    
        ; each 12 bytes corresponds to half of the 24-byte 3bpp tile
        ; The tile is being expanded from 3bpp to 4bpp, where it will use only the lower 8 colors of the palette
        
        LDA [$00] : STA $7F0000, X : INC $00 : INC $00
        LDA [$03] : AND.w #$00FF : STA $7F0010, X : INC $03 : INX #2
        
        LDA [$00] : STA $7F0000, X : INC $00 : INC $00
        LDA [$03] : AND.w #$00FF : STA $7F0010, X : INC $03 : INX #2
        
        LDA [$00] : STA $7F0000, X : INC $00 : INC $00
        LDA [$03] : AND.w #$00FF : STA $7F0010, X : INC $03 : INX #2
        
        LDA [$00] : STA $7F0000, X : INC $00 : INC $00
        LDA [$03] : AND.w #$00FF : STA $7F0010, X : INC $03 : INX #2
        
        DEY : BPL .nextHalf
        
        TXA : ADD.w #$0010 : TAX
        
        LDA $03
        
        DEC $0C : BNE .nextTile
        
        RTS
    }

; ==============================================================================
    
    ; *$6031-$6072 LONG
    {
        LDA.b #$7E : STA $02 : STA $05
        
        REP #$31
        
        ; Source address is $7E7800, base target address is $7F0000,
        ; number of tiles is 0xC0
        LDX.w #$0000
        LDA.w #$7800
        LDY.w #$00C0
        
        JSR Do3To4Low16Bit
        
        LDY.w #$0040
        
        ; Depending on which graphics pack it was, we decode from 3bpp to 4bpp
        ; using either the lowest 8 colors or the highest 8 colors in
        ; the palette.
        LDA $7EC2FF : AND.w #$00FF 
        
        CMP.w #$0052 : BEQ .high
        CMP.w #$0053 : BEQ .high
        CMP.w #$005A : BEQ .high
        CMP.w #$005B : BNE .low
    
    .high
    
        LDA $03
        
        JSR Do3To4High16Bit
        
        SEP #$30
        
        RTL
    
    .low
    
        LDA $03
        
        JSR Do3To4Low16Bit
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; $6073-$619A primary and default BG tilesets
    ; contains 0x25 8-byte entries
    ; indexed by $0AA1 * 8

; ==============================================================================

    ; *$619B-$62CF LONG
    InitTilesets:
    {
        ; Summary of this routine:
        ; Uses $0AA4 to load the sprite graphics for misc. items.
        ; Uses $0AA3 to load sprite graphics.
        
        PHB : PHK : PLB
        
        ; increment target vram address after each write to $2119
        LDA.b #$80 : STA $2115
        
        ; Target address in vram is $4400 (word)
        STZ $2116
        LDA.b #$44 : STA $2117
        
        JSR LoadCommonSprGfx ; $66B7 in rom.
        
        REP #$30
        
        LDA $0AA3 : AND.w #$00FF : ASL #2 : TAY
        
        SEP #$20
        
        LDA $DB57,Y : BEQ .skipSprSlot1
        
        STA $7EC2FC
    
    .skipSprSlot1
    
        LDA $7EC2FC : STA $09
        
        LDA $DB58,Y : BEQ .skipSprSlot2
        
        STA $7EC2FD
    
    .skipSprSlot2
    
        LDA $7EC2FD : STA $08
        
        LDA $DB59,Y : BEQ .skipSprSlot3
        
        STA $7EC2FE
    
    .skipSprSlot3
    
        LDA $7EC2FE : STA $07
        
        LDA $DB5A,Y : BEQ .skipSprSlot4
        
        STA $7EC2FF
    
    .skipSprSlot4
    
        LDA $7EC2FF : STA $06
        
        SEP #$10
        
        LDY $09
        
        ; this next section decompresses graphics to $7E7800, $7E7E00, $7E8400, and $7E8A00, successively.
        ; Note that these are all 0x600 bytes apart, the size of the typical 3bpp graphics pack.
        LDA.b #$7E : STA $02
        
        LDX.b #$78
        
        JSR LoadSprGfx
       
        LDY $08 : LDX.b #$7E
        
        JSR LoadSprGfx
        
        LDY $07 : LDX.b #$84
        
        JSR LoadSprGfx
        
        LDY $06 : LDX.b #$8A
        
        JSR LoadSprGfx
        
        REP #$30
        
        ; This is the address for BG0 and BG1's graphics
        ; (Not tilemap, actual graphics)
        LDA.w #$2000 : STA $2116
        
        LDA $0AA1 : AND.w #$00FF : ASL #3 : TAY
        LDA $0AA2 : AND.w #$00FF : ASL #2 : TAX
        
        SEP #$20
        
        LDA $E073, Y : STA $0D
        LDA $E074, Y : STA $0C
        LDA $E075, Y : STA $0B
        
        LDA $DD97, X : BNE .overrideDefaultBgSlot1
        
        LDA $E076, Y
    
    .overrideDefaultBgSlot1
    
        STA $7EC2F8 : STA $0A
        
        LDA $DD98, X : BNE .overrideDefaultBgSlot2
        
        LDA $E077, Y
    
    .overrideDefaultBgSlot2
    
        STA $7EC2F9 : STA $09
        
        LDA $DD99, X : BNE .overrideDefaultBgSlot3
        
        LDA $E078, Y
    
    .overrideDefaultBgSlot3
    
        STA $7EC2FA : STA $08
        
        LDA $DD9A, X : BNE .overrideDefaultBgSlot4
        
        LDA $E079, Y
    
    .overrideDefaultBgSlot4
    
        STA $7EC2FB : STA $07
        
        LDA $E07A, Y : STA $06
        
        SEP #$10
        
        LDA.b #$07 : STA $0F
        
        LDY $0D
        
        JSR LoadBgGfx
        
        DEC $0F
        
        LDY $0C
        
        JSR LoadBgGfx
        
        DEC $0F
        
        LDY $0B
        
        JSR LoadBgGfx
        
        DEC $0F
        
        LDY $0A : LDA.b #$7E : LDX.b #$60
        
        JSR LoadBgGfx_variable
        
        DEC $0F
        
        LDY $09 : LDA.b #$7E : LDX.b #$66
        
        JSR LoadBgGfx_variable
        
        DEC $0F
        
        LDY $08 : LDA.b #$7E : LDX.b #$6C
        
        JSR LoadBgGfx_variable
        
        DEC $0F
        
        LDY $07 : LDA.b #$7E : LDX.b #$72
        
        JSR LoadBgGfx_variable
        
        DEC $0F
        
        LDY $06
        
        JSR LoadBgGfx
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$62D0-$633A LONG
    LoadDefaultGfx:
    {    
        ; The subroutine loads some default sprite graphics into VRAM
        ; miscellaneous stuff really like blobs, signs, keys, etc
        ; probably just a holdover for the programmers to dick around with
        ; though it also does load the default graphics for the HUD, which is far more useful.
        PHB : PHK : PLB
        
        ; increment vram target address when data is written to $2119
        LDA.b #$80 : STA $2115
        
        ; The long address at $00[3] is $10F000 = $87000 in rom.
        LDA $CFF3 : STA $02
        LDA $D0D2 : STA $01
        LDA $D1B1 : STA $00
        
        REP #$20

        ; Initial target vram address is $4000 (word)
        LDA.w #$4000 : STA $2116
        
        ; all in all, this loop writes 0x1000 bytes in total, or 0x800 words
        LDY.b #$40
    
    .nextTile
    
        LDX.b #$0E
    
    .writeLowBitplanes
    
        ; Tiles are converted from 3bpp to 4bpp using only the latter 8 palette entries (See Do3To4High)
        
        ; The values will be written in reverse order from how they are in memory.
        LDA [$00] : STA $2118 : XBA : ORA [$00] : AND.w #$00FF : STA $BF, X
        
        INC $00 : INC $00
        
        DEX #2 : BPL .writeLowBitplanes
        
        LDX.b #$0E
    
    .writeHighBitplanes
    
        LDA [$00] : AND.w #$00FF : STA $BD : ORA $BF, X : XBA : ORA $BD : STA $2118
        INC $00
        
        DEX #2 : BPL .writeHighBitplanes
        
        DEY : BNE .nextTile

        ; Now that Link's graphics are in VRAM
        ; We'll next load the tiles for the HUD
        
        LDA.w #$7000 : STA $2116
        
        SEP #$20
        
        ; Load three 0x800 byte CHR sets for the HUD
        ; The final slot will be occupied by textbox tiles
        LDY.b #$6A

        JSR DecompAndDirectCopy ; $633B IN ROM

        LDY.b #$6B

        JSR DecompAndDirectCopy ; $633B IN ROM
        
        LDY.b #$69

        JSR DecompAndDirectCopy ; $633B IN ROM
        
        PLB

        RTL
    }

; ==============================================================================

    ; $633B-$636C LOCAL
    DecompAndDirectCopy:
    {
        ; inputs:
        ; Y - graphics pack to decompress
        ; target vram address is determined by calling functions,
        ; Decompresses a sprite gfx pack and directly copies it to vram
        
        JSR Decomp_spr_low
        
        REP #$30
        
        LDX.w #$00FF
        
        ; Iterating $100 times multiplied by 4 word writes
        ; total bytes written = $800    
    .copyToVram
    
        ; write the graphics we just decompressed into vram
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        
        DEX : BPL .copyToVram
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $636D-$6383 LONG
    {
        PHB : PHK : PLB
        
        ; increment vram target address on writes to $2119
        LDA.b #$80 : STA $2115
        
        ; vram target address is $7800 (word)
                     STZ $2116
        LDA.b #$78 : STA $2117
        
        LDY.b #$67
        
        JSR DecompAndDirectCopy
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $6384-$6398 LONG
    Graphics_LoadCommonSprLong:
    {
        PHB : PHK : PLB
        
        ; writes to $2119 increment the VRAM target address
        LDA.b #$80 : STA $2115
        
        ; Set initial vram target address to 0x4400 (word)
        STZ $2116 : LDA.b #$44 : STA $2117
        
        JSR LoadCommonSprGfx ; $66B7 in rom
        
        PLB
        
        RTL
    }

; =============================================

    ; $6399-$63D1 LONG
    CopyMode7Chr: ; decent name?
    {
        ; appears to write the mode 7 chr data to vram
        ; however, it would be much faster to do this via DMA
        ; in fact, in another place this operation is performed with dma, if I'm not mistaken.
        
        ; set source address bank to 0x18
        LDA.b #$18 : STA $02
        
        ; update vram address after writes to $2119
        LDA.b #$80 : STA $2115
        
        ; vram target address = $0000 (word)
        STZ $2116 : STZ $2117
        
        REP #$10
        
        ; source address ($00[3]) is $18C000
        LDY.w #$C000 : STY $00
        
        LDY.w #$0000
    
    ; This loop only updates the upper bytes of the vram addresses that are being written to.
    .writeChr
        
        LDA [$00], Y : STA $2119 : INY
        LDA [$00], Y : STA $2119 : INY
        LDA [$00], Y : STA $2119 : INY
        LDA [$00], Y : STA $2119 : INY
        
        CPY.w #$4000 : BNE .writeChr
        
        SEP #$10
    
    ; *$63D1 ALTERNATE ENTRY POINT
    .easyOut
    
        RTL
    }

; =============================================

    ; $63D2-$63E5 DATA
    {
        ; sprite packs to use, $01 indicates that $0aa4 will be used
        ; instead, btw.
        db $01, $01, $08, $08, $09, $09, $02, $02
        db $02, $02, $03, $03, $04, $04, $05, $05
        db $08, $08, $08, $08
    }

    ; need to name this data table
    ; $63E6-$63F9 DATA TABLE
    {
        db 10, -1,  3, -1, 0, -1, -1, -1
        db  0, -1,  2, -1, 0, -1, -1, -1
        db -1, -1, -1, -1
    }

; ==============================================================================

    ; okay, so months later I'm back, and this seems to upload 0x20
    ; tiles to one of two locations in the sprite region of VRAM - 
    ; 0x4400 or 0x4600. Generally I guess you could say that it's designed
    ; to load "half slots" or half graphics packs.
    
    ; \task Verify the naming of this, but pretty confident that it's good
    ; these days.
    
    ; *$63FA-$64E8 LONG
    Graphics_LoadChrHalfSlot:
    {
        ; $AAA is 0, return
        LDX $0AAA : BEQ CopyMode7Chr_easyOut
        
        PHB : PHK : PLB
        
        LDA $E3E5, X : BMI .negative
        
        STA $0AB1 ; $0AB1 can be derived from $0AAA
        
        CPX.b #$01 : BNE .notSlot1
        
        ; As far as I can tell, this line is totally redundant. It should
        ; already be set to 0x0a (10 decimal).
        LDA.b #$0A : STA $0AB1
        
        LDA.b #$02 : STA $0AA9
        
        JSL Palette_MiscSprite ; $DED6E IN ROM
        
        ; signal to update CGRAM this frame
        INC $15
        
        BRA .loadGraphics
    
    .notSlot1
    
        LDA.b #$02 : STA $0AA9
        
        JSL Palette_MiscSpr.justSP6
        
        ; signal to update CGRAM this frame
        INC $15
    
    .negative
    .loadGraphics
    
        LDX $0AAA
        
        LDY.b #$44
        
        STZ $08 : STZ $09
        
        ; Toggle Even-Odd state of $0AAA
        INC $0AAA
        
        ; branch if the new value of $0AAA is even
        LDA $0AAA : LSR A : BCC .even
        
        STZ $0AAA
        
        ; Check the previous value of $0AAA, before all the shenanigans
        CPX.b #$12 : BEQ .specificValues
        
        LDA.b #$03 : STA $09
        
        LDY.b #$46
        
        CPX.b #$02 : BNE .specificValues
        
        ; Unknown usage
        STZ $0112
    
    .even
    .specificValues
    
        STY $0116
        
        ; Graphics flag.
        LDA.b #$0B : STA $17
        
        ; $63D1, X THAT IS
        LDY $E3D1, X : CPY.b #$01 : BNE .dontUseDefault
        
        ; Just load the typical misc sprite graphics in this case
        LDY $0AA4
    
    .dontUseDefault
    
        ; Y = sprite graphics pack to load. Note that decompression will not be occuring,
        ; just conversion to 4bpp from 3bpp
        
        LDA $CFF3, Y : STA $02 : STA $05
        LDA $D0D2, Y : STA $01
        LDA $D1B1, Y : STA $00
        
        REP #$31
        
        LDY.w #$0020 : STY $0C ; $0C serves as a counter here
        
        LDX.w #$0000
        
        LDA $00 : ADC $08
    
    .nextTile
    
        STA $00
        
        ADD.w #$0010 : BNE .notAtBankEdge
        
        LDA.w #$8000
        
        INC $05
    
    .notAtBankEdge
    
        STA $03
        
        LDY.w #$0007 ; In this case it seems obvious only 8 loops occur
    
    .nextBitplane
    
        LDA [$00] : STA $7F1000, X : XBA : ORA [$00] : AND.w #$00FF : STA $08 
        
        INC $00 : INC $00 : BNE .notAtBankEdge2
        
        LDA $03 : INC A : STA $00
        
        INC $02
        
        LDA $02 : STA $05
    
    .notAtBankEdge2
    
        LDA [$03] : AND.w #$00FF : STA $0A : ORA $08 : XBA : ORA $0A : STA $7F1010, X
        
        INC $03 : BNE .notAtBankEdge3
        
        LDA.w #$8000 : STA $00
        LDA.w #$8010 : STA $03
        
        INC $02 : INC $05
    
    .notAtBankEdge2
    
        INX #2 : DEY : BPL .nextBitplane
            
        TXA : ADD.w #$0010 : TAX
        
        LDA $03
        
        ; This memory location holds a counter.
        DEC $0C : BNE .nextTile
        
        SEP #$30
        
        PLB
        
        RTL
    }

; =============================================

    ; *$64E9-$6555 LONG
    LoadSelectScreenGfx:
    {
        ; The base address for OAM data will be (2 << 14) = $8000 (byte) in vram
        ; ^ unsure of this, anomie's document seems to contradict itself
        LDA.b #$02 : STA $2101
        
        ; The address in vram increments when $2119 is written.
        LDA.b #$80 : STA $2115
        
        ; The intitial target address in vram is $5000 (word)
        STZ $2116
        LDA.b #$50 : STA $2117
        
        PHB : PHK : PLB     
        
        ; decompress sprite gfx pack 0x5E, which contains 0x40 tiles, and convert from 3bpp to 4bpp (high)
        LDY.b #$5E
        
        JSR Decomp_spr_low
        
        REP #$20
        
        LDY.b #$3F
        
        JSR Do3To4High
        
        ; decompress sprite gfx pack 0x5F, which contains 0x40 tiles, and convert from 3bpp to 4bpp (high)
        LDY.b #$5F
        
        JSR Decomp_spr_low
        
        REP #$20
        
        LDY.b #$3F
        
        JSR Do3To4High
        
        ; restore data bank
        PLB
        
        ; ----------------------------------
        
        ; Set source data address bank to 0x0E
        LDA.b #$0E : STA $02
        
        REP #$30
        
        ; target vram address is $7000 (word)
        LDA.w #$7000 : STA $2116
        
        ; Set source data address to $0E8000
        LDA.w #$8000 : STA $00
        
        LDX.w #$07FF
    
    ; writes 0x800 words to vram (0x1000 bytes)
    .copyFont
    
        LDA [$00] : STA $2118
        
        INC $00 : INC $00
        
        DEX : BPL .copyFont
        
        SEP #$30
        
        ; ----------------------------------
        
        PHB : PHK : PLB
        
        ; Decompress spr graphics pack 0x6B and manually write it to vram address 0x7800 (word)
        LDY.b #$6B
        
        JSR Decomp_spr_low
        
        REP #$30
        
        LDX.w #$02FF
        
    ; writes 0x300 words to vram (0x600 bytes)
    .copyOther2bpp
    
        LDA [$00] : STA $2118
        
        INC $00 : INC $00
        
        DEX : BPL .copyOther2bpp
        
        SEP #$30
        
        PLB
        
        RTL
    }

; =============================================

    ;*$6556-$6582 LONG
    CopyFontToVram:
    {
        ; copies font graphics to VRAM (for BG3)
        
        ; set name base table to vram $4000 (word)
        LDA.b #$02 : STA $2101
        
        ; increment on writes to $2119
        LDA.b #$80 : STA $2115
        
        ; set bank of the source address (see below)
        LDA.b #$0E : STA $02
        
        REP #$30
        
        ; vram target address is $7000 (word)
        LDA.w #$7000 : STA $2116
        
        ; $00[3] = $0E8000 (offset for the font data)
        LDA.w #$8000 : STA $00
        
        ; going to write 0x1000 bytes (0x800 words)
        LDX.w #$07FF
        
    .nextWord
    
        ; read a word from the font data
        LDA [$00] : STA $2118
        
        ; increment source address by 2
        INC $00 : INC $00
        
        DEX : BPL .nextWord
        
        SEP #$30
        
        RTL
    }

; =============================================

    ;*$6583-$6608 LOCAL / EXTERN_BRANCH
    LoadSprGfx:
    {
        ; this function takes as its parameters:
        ; $01[1] - the high byte of the decompression target address
        ; Y - the sprite graphics pack to decrompress
        
        STZ $00
        STX $01
        
        PHY
        
        JSR Decomp_spr_variable 
        
        REP #$20
        
        ; The graphics pack is assumed to contain 0x40 tiles (0x600 bytes)
        LDY.b #$3F
        
        ; depending on which graphics pack we decompressed,
        ; convert from 3bpp to 4bpp using either the first 8 colors of the palette, or the second 8 colors.
        PLX
        
        CPX.b #$52 : BEQ Do3To4High
        CPX.b #$53 : BEQ Do3To4High
        CPX.b #$5A : BEQ Do3To4High
        CPX.b #$5B : BEQ Do3To4High
        CPX.b #$5C : BEQ Do3To4High
        CPX.b #$5E : BEQ Do3To4High
        CPX.b #$5F : BEQ Do3To4High

        ; Write the graphics to vram using the 3bpp to 4bpp low technique (first 8 entries of the palette)
        JMP Do3To4Low
    }

; =============================================

    ; $65AF ALTERNATE ENTRY POINT
    ; Write graphics to VRAM using the 3bpp to 4bpp high technique (latter 8 entries of the palette)
    Do3To4High:
    {
    
    .nextTile
    
        LDX.b #$0E
    
    .writeLowBitplans
    
        LDA [$00] : STA $2118 : XBA : ORA [$00] : AND.w #$00FF : STA $BF, X
        INC $00   : INC $00   : DEX #2
        
        LDA [$00] : STA $2118 : XBA : ORA [$00] : AND.w #$00FF : STA $BF, X
        INC $00   : INC $00
        
        DEX #2 : BPL .writeLowBitplanes
        
        LDX.b #$0E
    
    .writeHighBitplanes
        
        LDA [$00] : AND.w #$00FF : STA $BD : ORA $BF, X : XBA : ORA $BD : STA $2118
        INC $00   : DEX #2
        
        LDA [$00] : AND.w #$00FF : STA $BD : ORA $BF, X : XBA : ORA $BD : STA $2118
        INC $00
        
        DEX #2 : BPL .writeHighBitplanes
        
        DEY : BPL .nextTile
        
        SEP #$20
        
        RTS
    }

; ==============================================================================
    
    ; *$6609-$66B6 LOCAL
    LoadBgGfx:
    {
        ; Inputs:
        ; $0F index of the graphics pack slot we're currently working on
        
        ; Target decompression address is $7F4000
        LDA.b #$7F
        LDX.b #$40
    
    .variable
    ; uses a variable source data address rather than the fixed one above
    ; *$660D ALTERNATE ENTRY POINT
    
        ; Going to decompress data to the address pointed at by [$00]
        STZ $00
        STX $01
        STA $02
        
        JSR Decomp_bg_variable
        
        REP #$20
        
        LDY.b #$3F
        
        LDX $0AA1 : CPX.b #$20 : BCC .typicalGfxPack
        
        LDX $0F
        
        CPX.b #$07 : BEQ Do3To4High
        CPX.b #$02 : BEQ Do3To4High
        CPX.b #$04 : BEQ Do3To4High
        CPX.b #$03 : BNE Do3To4Low
    
    .high
    
        JMP Do3To4High ; $E5AF
    
    .typicalGfxPack
    
        LDX $0F : CPX.b #$04 : BCS .high
        
        ; there should be a JMP to Do3To4Low here...
    }
      
; =============================================
      
    ; *$663C ALTERNATE ENTRY POINT
    Do3To4Low:
    {
        ; Takes as input:
        ; Y - number of tiles to convert from 3bpp to 4bpp
        ; $00[3] - source address of the already decompressed graphics
    
    .nextTile
    
        ; This whole routine writes $1000 or $800 bytes to VRAM
        ; Do3To4Low( )
        
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        LDA [$00] : STA $2118 : INC $00 : INC $00
        
        LDX.b #$01
    
    .writeHighBitplanes
    
        LDA [$00] : AND.w #$00FF : STA $2118 : INC $00
        LDA [$00] : AND.w #$00FF : STA $2118 : INC $00
        LDA [$00] : AND.w #$00FF : STA $2118 : INC $00
        LDA [$00] : AND.w #$00FF : STA $2118 : INC $00
        
        DEX : BPL .writeHighBitplanes
        
        ; Loops variable number of times, usually $80 or $40
        DEY : BPL .nextTile
        
        SEP #$20
        
        RTS 
    }

; =============================================
    
    ; *$66B7-$675B LOCAL
    LoadCommonSprGfx:
    {
        ; Loads basic sprite graphics using $0AA4
        ; Loads more sprite graphics using index #$06
        LDY $0AA4
        
        LDA $CFF3, Y : STA $02    
        LDA $D0D2, Y : STA $01
        LDA $D1B1, Y : STA $00
        
        REP #$20
        
        LDY.b #$40
    
    .nextTile
    
        LDX.b #$0E
    
    .writeLowBitplanes
    
        LDA [$00] : STA $2118 : XBA : ORA [$00] : AND.w #$00FF : STA $BF, X
        INC $00 : INC $00 : DEX #2
        
        LDA [$00] : STA $2118 : XBA : ORA [$00] : AND.w #$00FF : STA $BF, X
        INC $00 : INC $00
        
        DEX #2 : BPL .writeLowBitplanes
        
        LDX.b #$0E
    
    .writeHighBitplanes
    
        LDA [$00] : AND.w #$00FF : STA $BD : ORA $BF, X : XBA : ORA $BD : STA $2118
        INC $00 : DEX #2
        
        LDA [$00] : AND.w #$00FF : STA $BD : ORA $BF, X : XBA : ORA $BD : STA $2118
        INC $00
        
        DEX #2 : BPL .writeHighBitplanes
        
        DEY : BNE .nextTile
        
        SEP #$20
        
        ; Are we in the trifoce opening mode?        
        LDA $10 : CMP.b #$01 : BEQ .triforceMode
        
        
        ; 0x06 is a hardcoded sprite graphics pack for us to decompress.
        ; I forget what it contains for the moment...
        LDY.b #$06
        
        ; Determine the address of the data to directly convert from 3bpp to 4bpp
        LDA $CFF3, Y : STA $02
        LDA $D0D2, Y : STA $01
        LDA $D1B1, Y : STA $00
        
        REP #$20
        
        ; indicates that it contains 0x80 tiles
        LDY.b #$7F
        
        ; $663C in rom.
        JMP Do3To4Low
    
    .triforceMode
    
        STZ $0F
        
        ; I don't quite understand the significant of writing to $06...
        LDY.b #$5E : STY $06
        LDA.b #$7F : STA $02
        LDX.b #$40
        
        JSR LoadSprGfx ; $6583 in rom
        
        ; I don't quite understand the significant of writing to $06...
        LDY.b #$5F : STY $06
        
        LDX.b #$40
            
        JSR LoadSprGfx ; $6583 in rom
    }

; =============================================

    ; $675C-$6851 LOCAL
    Decomp:
    {
        ; The infamous graphics decompression routine
    
    .spr_high
    
        ; Sprite (type 1) decompression routine
        ; Target address will be $7F4600
        STZ $00
        LDA.b #$46 : STA $01
        LDA.b #$7F
        
        BRA .spr_set_bank
    
    .spr_low
    
        ; Target address will be $7F4000
        STZ $00
        LDA.b #$40 : STA $01
        LDA.b #$7F
    
    .spr_set_bank
    
        STA $02 : STA $05
    
    ; the caller sets the target address for the decompressed data with this version
    .spr_variable
    
        ; Set $C8[3], the indirect long source address
        LDA $CFF3, Y : STA $CA
        LDA $D0D2, Y : STA $C9
        LDA $D1B1, Y : STA $C8
        
        BRA .begin
    
    .bg_low
    
        ; Background (type 2) graphics decompression
        
        ; $00[3] = $7F4000
        STZ $00
        LDA.b #$40 : STA $01
        LDA.b #$7F
    
    .bg_variable_bank
    
        STA $02 : STA $05
    
    .bg_variable
    
        ; type 2 graphics pointers (tiles)
        ; GetSrcTypeTwo( )
        
        ; Set $C8[3], the indirect long source address
        LDA $CF80, Y : STA $CA
        LDA $D05F, Y : STA $C9
        LDA $D13E, Y : STA $C8
    
    .begin
    
        REP #$10
        
        LDY.w #$0000
    
    .next_code
    
        JSR .get_next_byte
        
        ; #$FF signals to terminate the decompression.
        CMP.b #$FF : BNE .continue
        
        ; this is the termination point of the routine
        SEP #$10
        
        RTS
    
    .continue
    
        STA $CD
        
        ; If all the upper 3 bits are set...
        ; [111]
        AND.b #$E0 : CMP.b #$E0 : BEQ .expanded
        
        PHA ; If not... then,
        
        ; Let's examine the byte again.
        LDA $CD
        
        REP #$20
        
        ; A is now between 0 and 31
        AND.w #$001F
        
        BRA .normal
    
    .expanded
    
        ; Extracts bits 2-4 from $CD and push it to the stack
        LDA $CD : ASL #3 : AND.b #$E0 : PHA
        
        ; Examine the byte again.
        ; Get the lower two bits.
        ; Shift this value to the upper byte of the Acc.    
        LDA $CD : AND.b #$03 : XBA
        
        JSR .get_next_byte
        
        REP #$20
    
    .normal
    
        INC A ; A is between 1 and 32
        STA $CB ; $CB = R, the number of bytes to write.
        
        SEP #$20
        
        PLA : BEQ .nonrepeating ; CODE [000]
        
        ; CODES [101], [110], [100], and [111]
        BMI .copy
        
        ; CODE [001]
        ASL A : BPL .repeating
        
        ; CODE [010]
        ASL A : BPL .repeating_word
        
        ; This counts as CODE [003]
        JSR .get_next_byte
        
        LDX $CB
    
    .increment_write
    
        STA [$00], Y
        
        INC A
        
        INY
        
        DEX : BNE .increment_write
        
        BRA .next_code
    
    ; CODE [000]
    .nonrepeating
    
        JSR .get_next_byte
        
        STA [$00], Y
        
        INY
        
        LDX $CB : DEX : STX $CB : BNE .nonrepeating
        
        BRA .next_code
    
    ; CODE [001]
    .repeating
    
        JSR .get_next_byte
        
        LDX $CB
    
    .loop_back
    
        STA [$00], Y
        
        INY
        
        DEX : BNE .loop_back
        
        BRA .next_code
    
    .repeating_word
    
        JSR .get_next_byte
        
        XBA
        
        JSR .get_next_byte
        
        LDX $CB
    
    .more_bytes
    
        XBA : STA [$00], Y
        
        INY
        
        DEX : BEQ .out_of_bytes
        
        XBA : STA [$00], Y
        
        INY
        
        DEX : BNE .more_bytes
    
    .out_of_bytes
    
        JMP .next_code
    
    ; CODES [101], [110], [100]
    .copy
    
        JSR .get_next_byte
        
        XBA
        
        JSR .get_next_byte
        
        XBA : TAX
    
    .loop_back2:
    
        PHY : TXY
        
        LDA [$00], Y ; Load from the target array
        TYX ; A value to copy later into the target array.
        PLY
        
        STA [$00], Y
        
        INY : INX
        
        REP #$20
        
        DEC $CB : SEP #$20 : BNE .loop_back2
        
        JMP .next_code
    
    .get_next_byte
   
        ; loads a value from a long address stored at $C8
        LDA [$C8]
        
        LDX $C8 : INX : BNE .no_bank_wrap
        
        LDX.w #$8000 ; LoROM banks range from 0x8000 to 0xFFFF
        
        INC $CA    ; Roll the bank number b/c we've gone past the end of the last bank.
        
    .no_bank_wrap
        
        STX $C8
        
        RTS
    }

; =============================================

    ; $6852-$690B DATA
    
    
    ; $6880
        dw $FFFF, $0001
    
    
        dw $FFE0, $0020
    
    
        dw $FC00, $0400
    
    ; $688C
        dw $FFFF, $FFFF
        dw $FFFE, $FFFF
        dw $7FFF, $7FFF
        dw $7FDF, $FBFF
        dw $7F7F, $7F7F
        dw $7DF7, $EFBF
        dw $7BDF, $7BDF
        dw $77BB, $DDEF
        dw $7777, $7777
        dw $6EDD, $BB77
        dw $6DB7, $6DB7
        dw $5B6D, $B6DB
        dw $5B5B, $5B5B
        dw $56B6, $AD6B
        dw $5555, $AD6B
        dw $5555, $AAAB
        dw $5555, $5555
        dw $2A55, $5555
        dw $2A55, $2A55
        dw $294A, $5295
        dw $2525, $2525
        dw $2492, $4925
        dw $1249, $1249
        dw $1122, $4489
        dw $1111, $1111
        dw $0844, $2211
        dw $0421, $0421
        dw $0208, $1041
        dw $0101, $0101
        dw $0020, $0401
        dw $0001, $0001
        dw $0000, $0001
    }

; =============================================
    
    ; *$690C-$69E3 LONG
    PaletteFilter:
    {
        ; color filtering routine
        
        !color      = $04
        !bitFilter  = $0C
        
        ; ---------------------------
        
        SEP #$20
        
        ; perform the filtering it $1A (frame counter) is even, but don't if it's odd
        LDA $1A : LSR A : BCC .doFiltering
        
        RTL
    
    ; *$6914 ALTERNATE ENTRY POINT
    .doFiltering
    
        REP #$30
        
        LDX.w #$E88C
        
        LDA $7EC007 : CMP.w #$0010 : BCC .alpha
        
        ; X = 0xE88E in this case. (darkening process)
        INX #2
    
    .alpha
    
        STX $B7
        
        AND.w #$000F : ASL A : TAX
        
        ; To avoid confusion, in this routine this does in fact load from bank $00
        ; $0C will contain a 2-byte value that consists of a single bit
        LDA $98C0, X : STA !bitFilter
        
        PHB : PHK : PLB
        
        ; this variable determines whether we're darkening or lightening the screen
        LDA $7EC009 : TAX
        
        LDA $E880, X : STA $06
        LDA $E884, X : STA $08
        LDA $E888, X : STA $0A
        
        LDX.w #$0040
        
        ; perform filtering on BP2-BP7, SP0-SP4, and SP6
        JSR FilterColors
        
        ; At this point filter the background color the same way the subroutine does
        LDA $7EC500 : STA !color
        
        ; obtain the red bits of the color
        LDA $7EC300 : AND.w #$001F : ASL #2 : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noRedFilter
        
        LDA !color : ADC $06 : STA !color
    
    .noRedFilter
        
        LDA $7EC300 : AND.w #$03E0 : LSR #3 : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noGreenFilter
        
        LDA !color : ADC $08 : STA !color
    
    .noGreenFilter
    
        LDA $7EC301 : AND.w #$007C : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noBlueFilter
    
        LDA !color : ADD $0A : STA !color
    
    .noBlueFilter
    
        LDA !color : STA $7EC500
        
        PLB
        
        LDA $7EC009 : BNE .lightening
        
        LDA $7EC007 : INC A : STA $7EC007 : CMP $7EC00B : BNE .stillFiltering
    
    .switchDirection
    
        ; we're going to switch the direction of the lightening / darkening process
        ; if we were lightening we will now be darkening, or vice versa
        
        LDA $7EC009 : EOR.w #$0002 : STA $7EC009
        
        LDA.w #$0000 : STA $7EC007
        
        SEP #$20
    
        INC $B0
    
    .stillFiltering
        
        SEP #$30
        
        ; tells NMI to update the CGRAM from WRAM
        INC $15
        
        RTL
    
    .lightening
    
        ; screen is being ligthened rather than darkened.
        
        LDA $7EC007 : CMP $7EC00B : BEQ .switchDirection
        
        LDA $7EC007 : DEC A : STA $7EC007
        
        SEP #$30
        
        ; tells NMI to update the CGRAM from WRAM
        INC $15
        
        RTL
    }

; =============================================
    
    ; *$69E4-$6A48 LOCAL
    FilterColors:
    {
        ; performs color filtering on the palette data given a starting color, and counts up to color 0x1B0,
        ; skips sprite palette 5, then filters sprite palette 6, and skips sprite palette 7.
        ; inputs:
        ; X - the starting index of the color to work with
        
        ; --------------------------------
    
    .nextColor
    
        LDA $7EC500, X : STA !color
        
        LDA $7EC300, X : BEQ .color_is_pure_black
        
        ; examine the red channel
        AND.w #$001F : ASL #2 : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noRedFilter
        
        LDA !color : ADC $06 : STA !color
    
    .noRedFilter
    
        ; examine the green channel
        LDA $7EC300, X : AND.w #$03E0 : LSR #3 : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noGreenFilter
    
        LDA !color : ADC $08 : STA !color
    
    .noGreenFilter
    
        ; examine the blue channel
        LDA $7EC301, X : AND.w #$007C : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noBlueFilter
        
        LDA !color : ADD $0A : STA !color
    
    .noBlueFilter
    
        ; write the adjusted color to the main palette memory
        LDA !color : STA $7EC500, X
    
    .color_is_pure_black
    
        ; skip sprite palette 5 (second half) for some strange reason?
        INX #2 : CPX.w #$01B0 : BCC .nextColor : BNE .dontSkipPalette
        
        TXA : ADD.w #$0010 : TAX
    
    .dontSkipPalette
    
        ; stop at sprite palette 7 (SP-7)
        CPX.w #$01E0 : BNE .nextColor
        
        RTS
    }

; =============================================
    
    ; *$6A49-$6AB5 LONG
    PaletteFilterUnused:
    {
        ; This routine and its companion routine below don't seem to be used in the game at all
        ; But they could potentially be used, they are finished products, it seems
        ; The key difference is that this routine doesn't skip SP5 and SP7, like the ones above do.
        ; This could be a "first draft" of what the final routine was originally designed to do.
        
        REP #$30
        
        LDX.w #$E88C
        
        LDA $7EC007 : CMP.w #$0010 : BCC .firstHalf
        
        INX #2 
    
    .firstHalf
        
        STX $B7
        
        AND.w #$000F : ASL A : TAX
        
        LDA $98C0, X : STA $0C
        
        PHB : PHK : PLB
        
        LDA $7EC009 : TAX
        
        LDA $E880, X : STA $06
        LDA $E884, X : STA $08
        LDA $E888, X : STA $0A
        
        LDX.w #$0040
        LDA.w #$0200
        
        JSR FilterColorsEndpoint
        
        PLB
        
        LDA $7EC009 : BNE .lightening
        
        LDA $7EC007 : INC A : STA $7EC007 : CMP $7EC00B : BNE .stillFiltering
    
    .switchDirection
    
        LDA $7EC009 : EOR.w #$0002 : STA $7EC009
        
        LDA.w #$0000 : STA $7EC007
        
        SEP #$20
        
        INC $B0
    
    .stillFiltering
    
        SEP #$30
        
        INC $15
        
        RTL
    
    .lightening
    
        LDA $7EC007 : CMP $7EC00B : BEQ $BRANCH_6A9B
        
        LDA $7EC007 : DEC A : STA $7EC007
        
        SEP #$30
        
        INC $15
        
        RTL
    }

; =============================================

    ; *$6ACE-$6B28 LOCAL
    FilterColorsEndpoint:
    {
        ; similar to FilterColors, but it has a variable last color. Also doesn't skip SP5 or SP7
        
        !lastColor = $0E
        
        ; -----------------------
        
        STA !lastColor
    
    .nextColor
    
        LDA $7EC500, X : STA !color
        
        LDA $7EC300, X : BEQ .color_is_pure_black
        
        ; \note Makes it a multiple of 4... hrm...
        AND.w #$001F : ASL #2 : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noRedFilter
        
        ; adjust red content by +/- 1
        LDA !color : ADD $06 : STA !color
    
    .noRedFilter
    
        ; \note Also a multiple of 4
        LDA $7EC300, X : AND.w #$03E0 : LSR #3 : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noGreenFilter
        
        ; adjust green content by +/- 1
        LDA !color : ADD $08 : STA !color
    
    .noGreenFilter
    
        ; \
        LDA $7EC301, X : AND.w #$007C : TAY
        
        LDA ($B7), Y : AND !bitFilter : BNE .noBlueFilter
        
        ; adjust blue content by +/- 1
        LDA !color : ADD $0A : STA !color
        
    .noBlueFilter
    
        LDA !color : STA $7EC500, X
        
    .color_is_pure_black
    
        INX #2 : CPX !lastColor : BNE .nextColor
        
        RTS
    }

; ==============================================================================

    ; *$6B29-$6B5D LONG
    Attract_ResetHudPalettes_4_and_5:
    {
        ; Zeroes out BP1 (first half) in the cgram buffer and sets $15 high
        ; So the NMI routine will update cgram.
        
        REP #$20
        
        LDA.w #$0000
        
        STA $7EC520 : STA $7EC522 : STA $7EC524 : STA $7EC526
        STA $7EC528 : STA $7EC52A : STA $7EC52C : STA $7EC52E 
        
        ; Set the mosaic level to zero
        STA $7EC007
        
        ; Going to be lightening the screen
        LDA.w #$0002 : STA $7EC009
        
        SEP #$20
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; *$6B5E-$6BC4 LONG
    PaletteFilterHistory:
    {
        REP #$30
        
        LDX.w #$E88C
        
        LDA $7EC007 : CMP.w #$0010 : BCC .firstHalf
        
        INX #2
    
    .firstHalf
    
        STX $B7
        
        AND.w #$000F : ASL A : TAX
        
        ; Note that this access is a long address mode, unlike the others
        LDA $0098C0, X : STA $0C
        
        ; equate banks
        PHB : PHK : PLB
        
        LDA $7EC009 : TAX
        
        LDA $E880, X : STA $06
        LDA $E884, X : STA $08
        LDA $E888, X : STA $0A
        
        ; going to just modify BP2
        LDX.w #$0020
        LDA.w #$0030
    
    ; *$6B98 ALTERNATE ENTRY POINT
    .doFiltering
    
        JSR FilterColorsEndpoint
        
        PLB
        
        LDA $7EC007 : INC A : STA $7EC007 : CMP.w #$001F : BNE .stillFiltering
        
        ; At this point the     
        LDA.w #$0000 : STA $7EC007
        
        LDA $7EC009 : EOR.w #$0002 : STA $7EC009 : BEQ .stillFiltering
        
        ; Tell attract mode to move on to the next 2bpp graphic.
        INC $27
    
    .stillFiltering
    
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; \task This probably needs a better name.
    ; *$6BC5-$6BF1 LONG
    PaletteFilter_WishPonds:
    {
        ; Put BG2 on the subscreen? What?
        LDA.b #$02 : STA $1D
        
        ; Turn on color math on obj and backdrop.
        LDA.b #$30 : STA $9A
        
        BRA .continue
    
    ; *$6BCF ALTERNATE ENTRY POINT
    shared PaletteFilter_Crystal:
    
        LDA.b #$01 : STA $1D
    
    .continue
    
    ; \task Best guess, rename if turns out incorrect.
    ; *$6BD3 ALTERNATE ENTRY POINT
    shared PaletteFilter_InitTheEndSprite:
    
        REP #$20
        
        LDX.b #$0E
        LDA.w #$0000
    
    .zero_out_sp5
    
        ; zeroes out sprite palette 5 for use with the pond of wishing (seems like)
        
        STA $7EC6A0, X : DEX #2 : BPL .zero_out_sp5
        
        STA $7EC007
        
        LDA.w #$0002 : STA $7EC009
        
        SEP #$20
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; *$6BF2-$6C0C LONG
    Palette_Restore_SP5F:
    {
        REP #$20
        
        LDX.b #$0E
    
    .copy_colors
    
        ; copy colors from the auxiliary palette buffer's SP5F to the main
        ; palette buffer's SP5F
        
        LDA $7EC4A0, X : STA $7EC6A0, X
        
        DEX #2 : BPL .copy_colors
        
        SEP #$20
        
        STZ $1D
        
        ; only the background participates in color addition
        LDA.b #$20 : STA $9A
        
        INC $15
        
    ; *$6C0C ALTERNATE ENTRY POINT
    .return

        RTL
    }

; ==============================================================================

    ; *$6C0D-$6C53 LONG
    Palette_Filter_SP5F:
    {
        JSR .filter
        
        ; Now filter again!
        LDA $7EC007 : BEQ BRANCH_$6C0C
    
    .filter
    
        REP #$30
        
        LDX.w #$E88C
        
        LDA $7EC007 : CMP.w #$0010 : BCC .first_half
        
        DEX #2
    
    .first_half
    
        STX $B7
        
        AND.w #$000F : ASL A : TAX
        
        LDA $0098C0, X : STA !bitFilter
        
        PHB : PHK : PLB
        
        LDA $7EC009 : TAX
        
        LDA $E880, X : STA $06
        LDA $E884, X : STA $08
        LDA $E888, X : STA $0A
        
        LDX.w #$01A0
        LDA.w #$01B0
        
        JMP PaletteFilterHistory.doFiltering
    }

; ==============================================================================

    ; *$6C54-$6C78 BRANCH LOCATION
    pool KholdstareShell_PaletteFiltering:
    {
    
    .initialize
    
        REP #$20
        
        ; This loop copies auxiliary BP4_L to normal BP4_L
        ; \note Although, to work properly, it ought to be copying BP5_L to
        ; BP5_L axuiliary.
        LDX.b #$0E
    
    .next_color
    
        LDA $7EC380, X : STA $7EC580, X
        
        DEX #2 : BPL .next_color
        
        LDA.w #$0000 : STA $7EC007 : STA $7EC009
        
        SEP #$20
        
        INC $15
        
        INC $B0
        
        RTL
    
    .disable_subscreen
    
        STZ $1D

        RTL
    }

; ==============================================================================

    ; *$6C79-$6CC3 LONG
    KholdstareShell_PaletteFiltering:
    {
        LDA $B0 : BEQ .initialize
        
        JSL .do_filtering
        
        LDA $7EC007 : BEQ .disable_subscreen
    
    .do_filtering
    
        REP #$30
        
        LDX.w #$E88C
        
        LDA $7EC007 : CMP.w #$0010 : BCC .firstHalf
        
        INX #2
    
    .firstHalf
    
        STX $B7
        
        AND.w #$000F : ASL A : TAX
        
        ; Get 1 << (15 - i)
        LDA $0098C0, X : STA !bitFilter
        
        PHB : PHK : PLB
        
        LDA $7EC009 : TAX
        
        LDA $E880, X : STA $06
        LDA $E884, X : STA $08
        LDA $E888, X : STA $0A
        
        LDX.w #$0080
        LDA.w #$0090
        
        JMP PaletteFilterHistory.doFiltering
    }

; ==============================================================================

    ; $6CC4-$6CC9 DATA
    pool PaletteFilter_Agahnim:
    {
    
    .palette_offsets
        dw $0160, $0180, $01A0
    }

; ==============================================================================
    
    ; *$6CCA-$6D18 LONG
    PaletteFilter_Agahnim:
    {
        ; \parameters:
        ; X - index of the sprite to perform filtering for. How this works...
        ; I don't even...
        ; 
        
        ; does palette filtering for Agahnim sprite and sprites when there's 2
        ; or three of him.
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $7EC019, X : STA $7EC007
        LDA $7EC01F, X : STA $7EC009
        
        LDA.l .palette_offsets, X : STA $00
        
        ; Set upper limit of filtering? (non inclusive I assume).
        ADD.w #$0010 : STA $02
        
        REP #$10
        
        JSR $ED19 ; $6D19 IN ROM
        
        LDA $7EC007 : BEQ .done_filtering
        
        JSR $ED19 ; $6D19 IN ROM
    
    .done_filtering
    
        SEP #$30
        
        PLX
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $7EC007 : STA $7EC019, X
        LDA $7EC009 : STA $7EC01F, X
        
        SEP #$20
        
        PLX
        
        ; update the palette ram this frame
        INC $15
        
        RTL
    }

; ==============================================================================
    
    ; *$6D19-$6D7B LOCAL
    {
        LDY.w #$E88C
        
        LDA $7EC007 : CMP.w #$0010 : BCC .firstHalf
        
        INY #2

    .firstHalf

        STY $B7
        
        AND.w #$000F : ASL A : TAX
        
        LDA $0098C0, X : STA !bitFilter
        
        PHB : PHK : PLB
        
        LDA $7EC009 : TAX
        
        LDA $E880, X : STA $06
        LDA $E884, X : STA $08
        LDA $E888, X : STA $0A
        
        LDX $00 : PHX
        
        LDA $02 : PHA
        
        JSR FilterColorsEndpoint
        
        PLA : STA $02
        
        PLX : STX $00
        
        PLB
        
        LDA $7EC007 : INC A : STA $7EC007 : CMP.w #$001F : BNE .notDoneFiltering
        
        LDA.w #$0000 : STA $7EC007
        
        ; change the direction of the filtering (lightening vs. darkening)
        LDA $7EC009 : EOR.w #$0002 : STA $7EC009

    .notDoneFiltering
    
        RTS
    }

; =============================================
    
    ; *$6D7C-$6DB0 LONG
    {
        REP #$30
        
        LDX.w #$0100
        LDA.w #$01A0
        
        JSR RestorePaletteAdditive
        
        LDX.w #$00C0
        LDA.w #$0100
        
        BRA BRANCH_1
    
    ; *$6D8F ALTERNATE ENTRY POINT
    
        REP #$30
        
        LDX.w #$0040
        LDA.w #$00C0
        
        JSR RestorePaletteAdditive
        
        LDX.w #$0040
        LDA.w #$00C0
    
    BRANCH_1:
    
        JSR RestorePaletteAdditive
        
        SEP #$30
        
        LDA $7EC007 : DEC A : STA $7EC007
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; $6DB1-$6DC9 LONG
    {
        REP #$30
        
        LDX.w #$00B0
        LDA.w #$00C0
        
        JSR RestorePaletteAdditive
        
        LDX.w #$00D0
        LDA.w #$00E0
        
        JSR RestorePaletteSubtractive
        
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==============================================================================
    
    ; *$6DCA-$6E20 LOCAL
    RestorePaletteAdditive:
    {
        ; Gradually changes the colors in the main buffer so that they match those in the
        ; auxiliary buffer by *increasing* the color values.
        
        STA $0E
    
    .nextColor
    
        LDA $7EC500, X : TAY 
        
        AND.w #$001F       : STA $08
        TYA : AND.w #$03E0 : STA $0A
        TYA : AND.w #$7C00 : STA $0C
        
        LDA $7EC300, X : AND.w #$001F : CMP $08 : BEQ .redMatch
        
        TYA : ADD.w #$0001 : TAY
    
    .redMatch
        
        LDA $7EC300, X : AND.w #$03E0 : CMP $0A : BEQ .greenMatch
        
        TYA : ADD.w #$0020 : TAY
    
    .greenMatch
    
        LDA $7EC300, X : AND.w #$7C00 : CMP $05 : BEQ .blueMatch

        TYA : ADD.w #$0400 : TAY
        
    .blueMatch

        TYA : STA $7EC500, X
        
        INX #2 : CPX $0E : BNE .nextColor
        
        RTS
    }

; =============================================

    ; *$6E21-$6E77 JUMP LOCATION
    RestorePaletteSubtractive:
    {
        ; Gradually changes the colors in the main buffer so that they match those in the
        ; auxiliary buffer by *decreasing* the color values.
    
        STA $0E
    
    .nextColor
    
        LDA $7EC500, X : TAY
        
        AND.w #$001F       : STA $08
        TYA : AND.w #$03E0 : STA $0A
        TYA : AND.w #$7C00 : STA $0C
        
        LDA $7EC300, X : AND.w #$001F : CMP $08 : BEQ .redMatch
        
        TYA : SUB.w #$0001 : TAY
    
    .redMatch
    
        LDA $7EC300, X : AND.w #$03E0 : CMP $0A : BEQ .greenMatch
        
        TYA : SUB.w #$0020 : TAY
    
    .greenMatch
    
        LDA $7EC300, X : AND.w #$7C00 : CMP $0C : BEQ .blueMatch
    
        TYA : SUB.w #$0400 : TAY
    
    .blueMatch
    
        TYA : STA $7EC500, X
        
        INX #2 : CPX $0E : BNE .nextColor
        
        RTS
    }

; =============================================

    ; *$6E78-$6EDF JUMP LOCATION
    Palette_InitWhiteFilter:
    {
        REP #$20
        
        LDX.b #$00
        
        LDA.w #$7FFF
    
    .whiteFill
    
        STA $7EC300, X : STA $7EC340, X : STA $7EC380, X : STA $7EC3C0, X
        STA $7EC400, X : STA $7EC440, X : STA $7EC480, X : STA $7EC4C0, X
        
        INX #2 : CPX.b #$40 : BNE .whiteFill
        
        LDA $7EC500 : STA $7EC540
        
        ; start the filtering process, we're going to be lightening the screen too
        LDA.w #$0000 : STA $7EC007
        LDA.w #$0002 : STA $7EC009
        
        LDA $8A : CMP.w #$001B : BNE .notHyruleCastle
        
        LDA.w #$0000 : STA $7EC300 : STA $7EC340 : STA $7EC500 : STA $7EC540
    
    .notHyruleCastle
    
        SEP #$20
        
        LDA.b #$08 : STA $06BB
        
        STZ $06BA
        
        RTL
    }

; ==============================================================================

    ; *$6EE0-$6EE6 BRANCH LOCATION (LONG)
    {
        ; Seems to be used exclusively during the mirror sequence to gradually
        ; decompress graphics.
        
        JSL $00D864 ; $5864 IN ROM
    
    ; *$6EE4 ALTERNATE ENTRY POINT
    
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$6EE7-$6F89 LONG
    {
        DEC $06BB : BNE BRANCH_6EE0
        
        LDA.b #$02 : STA $06BB
    
    ; *$6EF1 ALTERNATE ENTRY POINT
    
        REP #$30
        
        LDA $7EC009
        
        CMP.w #$00FF : BEQ BRANCH_6EE4
        CMP.w #$0002 : BNE .alpha
        
        LDX.w #$0040 : LDA.w #$01B0
        
        JSR RestorePaletteAdditive
        
        LDX.w #$01C0
        LDA.w #$01E0
        
        JSR RestorePaletteAdditive
        
        BRA .beta
    
    .alpha
    
        LDX.w #$0040
        LDA.w #$01B0
        
        JSR RestorePaletteSubtractive
        
        LDX.w #$01C0
        LDA.w #$01E0
        
        JSR RestorePaletteSubtractive
    
    ; *$6F27 ALTERNATE ENTRY POINT
    .beta
    
        LDA $7EC540 : STA $7EC500
        
        LDA $7EC009 : BNE .gamma
        
        LDA $7EC007 : INC A : STA $7EC007 : CMP.w #$0042 : BNE .delta
        
        LDA.w #$00FF : STA $7EC009
        
        SEP #$20
        
        LDA.b #$20 : STA $06BB
    
    .delta
    
        SEP #$30
        
        INC $15
        
        RTL
    
    .gamma
    
        LDA $7EC007 : INC A : STA $7EC007 : CMP.w #$001F : BNE .delta
        
        LDA $7EC009 : EOR.w #$0002 : STA $7EC009
        
        SEP #$30
        
        LDA $10 : CMP.b #$15 : BNE .epsilon
        
        STZ $420C : STZ $9B
        
        REP #$20
        
        LDX.b #$3E : LDA.w #$0778
        
        JSL $00FE3E ; $7E3E IN ROM
        
        INC $15
    
    .epsilon
    
        RTL
    }

; =============================================
    
    ; *$6F8A-$6F96 LONG
    {
        REP #$30
        
        LDX.w #$0040
        LDA.w #$0200
        
        JSR RestorePaletteAdditive
        
        BRA BRANCH_$6F27
    }

; =============================================
    
    ; *$6F97-$700B LONG
    WhirlpoolSaturateBlue:
    {
        ; Causes all the colors in the palette to saturate their blue component (saturated = 0x1F)
        ; This occurs first when you slip into a whirlpool. The routine below eliminates the nonblue components.
        
        LDA $1A : LSR A : BCC .skipFrame
        
        REP #$30
        
        PHB : PHK : PLB
        
        LDX.w #$0040
    
    .nextColor
    
        LDA $7EC500, X : TAY
        
        AND.w #$7C00 : CMP.w #$7C00 : BEQ .fullBlue
        
        TYA : ADD.w #$0400 : TAY
    
    .fullBlue
    
        TYA : STA $7EC500, X
        
        INX #2 : CPX.w #$0200 : BNE .nextColor
        
        LDA $7EC540 : STA $7EC500
        
        PLB
        
        SEP #$20
        
        LDA $7EC007 : LSR A : BCS .noMosaicIncrease
        
        LDA $7EC011 : ADD.b #$10 : STA $7EC011
    
    ; *$6FE0 ALTERNATE ENTRY POINT
    .noMosaicincrease
    
        LDA $7EC007 : INC A : STA $7EC007 : CMP.b #$1F : BNE .notDone
        
        LDA.b #$00 : STA $7EC007
        
        INC $B0
        
        ; Set mosaic to full
        LDA.b #$F0 : STA $7EC011
    
    .skipFrame
    .notDone
    
        SEP #$30
        
        LDA.b #$09 : STA $94
        
        LDA $7EC011 : ORA.b #$03 : STA $95
        
        INC $15
        
        RTL
    }

; =============================================
    
    ; *$700C-$7049 LONG
    WhirlpoolIsolateBlue:
    {
        ; Cycles through all colors in the palette and decrements the red and green components of
        ; each color by one each frame.
        
        REP #$30
        
        PHB : PHK : PLB
        
        LDX.w #$0040
    
    .nextColor
    
        LDA $7EC500, X : TAY : AND.w #$03E0 : BEQ .noGreen
        
        TYA : SUB.w #$0020 : TAY
    
    .noGreen
    
        TYA : AND.w #$001F : BEQ .noRed
        
        TYA : SUB.w #$0001 : TAY
    
    .noRed
    
        TYA : STA $7EC500, X
        
        INX #2 : CPX.w #$0200 : BNE .nextColor
        
        LDA $7EC540 : STA $7EC500
        
        PLB
        
        SEP #$20
        
        JMP WhirlpoolSaturateBlue_noMosaicIncrease
    }

; =============================================
    
    ; *$704A-$70C6 LONG
    WhirlpoolRestoreBlue:
    {
        ; Restores the blue components in the palette colors to their original states
        
        LDA $1A : LSR A : BCC .skipFrame
        
        REP #$30
        
        PHB : PHK : PLB
        
        LDX.w #$0040
    
    .nextColor
    
        LDA $7EC300, X : AND.w #$7C00 : STA $00
        
        LDA $7EC500, X : TAY : AND.w #$7C00 : CMP $00 : EQ .blueMatch
        
        TYA : SUB.w #$0400 : TAY
    
    .blueMatch
    
        TYA : STA $7EC500, X
        
        INX #2 : CPX.w #$0200 : BNE .nextColor
        
        LDA $7EC540 : STA $7EC500
        
        PLB
        
        SEP #$20
        
        LDA $7EC007 : LSR A : BCS .noMosaicDecrease
        
        LDA $7EC011 : BEQ .noMosaicDecrease
        
        SUB.b #$10 : STA $7EC011
    
    .noMosaicDecrease
    
        LDA $7EC007 : INC A : STA $7EC007 : CMP.b #$1F : BNE .notDone
        
        LDA.b #$00 : STA $7EC007 : STA $7EC011
        
        INC $B0
    
    .notDone
    .skipFrame
    
        SEP #$30
        
        LDA.b #$09 : STA $94
        
        LDA $7EC011 : ORA.b #$03 : STA $95
        
        INC $15
        
        RTL
    }

; =============================================
    
    ; *$70C7-$7131 LONG
    WhirlpoolRestoreRedGreen:
    {
        ; restores the red and green component levels of the palette's colors
        ; to their original levels from before we entered the whirlpool.
        
        REP #$30
        
        PHB : PHK : PLB
        
        LDX.w #$0040
    
    .nextColor
    
        LDA $7EC300, X : AND.w #$03E0 : STA $00
        LDA $7EC300, X : AND.w #$001F : STA $02
        
        LDA $7EC500, X : TAY
        
        AND.w #$03E0 : CMP $00 : BEQ .greenMatch
        
        TYA : ADD.w #$0020 : TAY
    
    .greenMatch
    
        TYA : AND.w #$001F : CMP $02 : BEQ .redMatch
        
        TYA : ADD.w #$0001 : TAY
    
    .redMatch
    
        TYA : STA $7EC500, X
        
        INX #2 : CPX.w #$0200 : BNE .nextColor
        
        LDA $7EC540 : STA $7EC500
        
        PLB
        
        SEP #$20
        
        LDA $7EC007 : INC A : STA $7EC007 : CMP.b #$1F : BNE .notDone
        
        LDA.b #$00 : STA $7EC007
        
        INC $B0
    
    .notDone
    
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; $7132-$7168 BRANCH LOCATION
    pool PaletteFilter_Restore_Strictly_Bg_Subtractive:
    {
    
    .easy_out
    
        SEP #$30

        RTL
    
    ; *$7135 ENTRY POINT LONG
    PaletteFilter_Restore_Strictly_Bg_Subtractive:
    
        REP #$30
        
        LDA $7EC009 : CMP.w #$00FF : BEQ .easy_out
        
        PHB : PHK : PLB
        
        LDX.w #$0040
        LDA.w #$0100
        
        JSR RestorePaletteSubtractive
        
        PLB
        
        LDA $7EC007 : INC A : STA $7EC007
        
        CMP.w #$0020 : BNE .not_finished
        
        LDA.w #$00FF : STA $7EC009
        
        STZ $1D
    
    ; *$7164 ALTERNATE ENTRY POINT
    .not_finished
    
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==============================================================================
    
    ; *$7169-$7182 LONG
    PaletteFilter_Restore_Strictly_Bg_Additive:
    {
        REP #$30
        
        PHB : PHK : PLB
        
        LDX.w #$0040
        LDA.w #$0100
        
        JSR RestorePaletteAdditive
        
        PLB
        
        LDA $7EC007 : INC A : STA $7EC007
        
        BRA PaletteFilter_Restore_Strictly_Bg_Subtractive.not_finished
    }

; ==============================================================================
    
    ; *$7183-$71CE LONG
    PaletteFilter_IncreaseTrinexxRed:
    {
        ; increases the red component in the sprite palette of Trinexx, or one of his parts
    
        LDA $04BE : BNE .countdown
        
        REP #$20
        
        LDX.b #$00
    
    .nextColor
    
        LDA $7EC582, X : AND.w #$001F : CMP.w #$001F : BEQ .redMatch
        
        ADD.w #$0001
    
    .redMatch
    
        STA $00
        
        LDA $7EC582, X : AND.w #$FFE0 : ORA $00 : STA $7EC582, X
        
        INX #2 : CPX.b #$0E : BNE .nextColor
    
    ; *$71B1 ALTERNATE ENTRY POINT
    
        SEP #$20
        
        INC $15
        INC $04C0
        
        LDA $04C0 : CMP.b #$0C : BCS .finished
        
        LDA.b #$03 : STA $04BE
    
    ; *$71C4 ALTERNATE ENTRY POINT
    .countdown
    
        DEC $04BE
        
        RTL
    
    .finished
    
        STZ $04BE
        STZ $04C0
        
        RTL
    }

; ==============================================================================
    
    ; *$71CF-$7206 LONG
    PaletteFilter_RestoreTrinexxRed:
    {
        LDA $04BE : BNE IncreaseTrinexxRed_countdown
        
        REP #$20
        
        LDX.b #$00
    
    .nextColor
    
        LDA $7EC382, X : AND.w #$001F : STA $0C
        
        LDA $7EC582, X : AND.w #$001F : CMP $0C : BEQ .redMatch
        
        SUB.w #$0001
    
    .redMatch
    
        STA $00
        
        LDA $7EC582, X : AND.w #$FFE0 : ORA $00 : STA $7EC582, X
        
        INX #2 : CPX.b #$0E : BNE .nextColor
        
        BRA IncreaseTrinexxRed_finished
    }
    
; ==============================================================================

    ; *$7207-$7252 LONG
    PaletteFilter_IncreaseTrinexxBlue:
    {
        ; increases the blue component of trinexx or one of his parts by one
        ; each time the routine is called.
        
        LDA $04BF : BNE .countdown
        
        REP #$20
        
        LDX.b #$00
    
    .nextColor
    
        LDA $7EC582, X : AND.w #$7C00 : CMP.w #$7C00 : BEQ .blueMatch
        
        ADD.w #$0400
    
    .blueMatch
    
        STA $00
        
        LDA $7EC582, X : AND.w #$83FF : ORA $00 : STA $7EC582, X
        
        INX #2 : CPX.b #$0E : BNE .nextColor
    
    ; *$7235 ALTERNATE ENTRY POINT
    
        SEP #$20
        
        INC $15
        INC $04C1
        
        LDA $04C1 : CMP.b #$0C : BCS .finished
        
        LDA.b #$03 : STA $04BF
    
    ; *$7248 ALTERNATE ENTRY POINT
    .countdown
    
        DEC $04BF
        
        RTL
    
    .finished
    
        STZ $04BF
        STZ $04C1
        
        RTL
    }

; ==============================================================================

    ;*$7253-$728A LONG
    PaletteFilter_RestoreTrinexxBlue:
    {
        LDA $04BF : BNE IncreaseTrinexxBlue_countdown
        
        REP #$20
        
        LDX.b #$00
    
    .nextColor
    
        LDA $7EC382, X : AND.w #$7C00 : STA $0C
        
        LDA $7EC582, X : AND.w #$7C00 : CMP $0C : BEQ .blueMatch
        
        SUB.w #$0400
    
    .blueMatch
    
        STA $00
        
        LDA $7EC582, X : AND.w #$83FF : ORA $00 : STA $7EC582, X
        
        INX #2 : CPX.b #$0E : BNE .nextColor
        
        BRA IncreaseTrinexxBlue_finished
    }

; ==============================================================================
    
    ; *$728B-$7301 JUMP LOCATION
    Spotlight:
    {
    
    .close
    
        REP #$10
        
        LDY.w #$0000 : LDX.w #$007E
        
        BRA .setValues
    
    ; *$7295 ALTERNATE ENTRY POINT
    .open
    
        REP #$10
        
        LDY.w #$0002 : LDX.w #$0000
    
    .setValues
    
        STY $067E 
        STX $067C
        
        STZ $420C
        
        ; target dma register is $2126 (WH0), Window 1 Left Position. $2127 (WH1) will also be written b/c of the mode.
        ; Indirect HDMA is being used as well. transfer mode is write two registers once, ($2126 / $2127).
        LDX.w #$2641 : STX $4360 : STX $4370
        
        ; The source address of the indirect hdma table
        LDX.w #.hdma_table : STX $4362
                             STX $4372
        
        ; source bank is bank $00
        LDA.b #$00 : STA $4364 : STA $4374
        LDA.b #$00 : STA $4367 : STA $4377
        
        ; configure window mask settings
        LDA.b #$33 : STA $96
        LDA.b #$03 : STA $97
        LDA.b #$33 : STA $98
        
        ; cache screen designation information into temp variables
        LDA $1C : STA $1E
        LDA $1D : STA $1F
        
        LDA $1B : BNE .indoors
        
        ; set up fixed color add / sub value
        LDA.b #$20 : STA $9C
        LDA.b #$40 : STA $9D
        LDA.b #$80 : STA $9E
    
    .indoors
    
        SEP #$10
        
        JSL ConfigureSpotlightTable
        
        ; enable HDMA on channel 7 during the NMI of the next frame
        LDA.b #$80 : STA $9B
        
        ; set screen brightness to full
        LDA.b #$0F : STA $13
        
        RTL
    
    .hdma_table
        dw $F8    ; line count with repeat flag set
        dw $1B00  ; address of the data for the first 120 scanlines
        db $F8    ; line count with repeat flag set
        dw $1BF0  ; address of the data for the second 120 scanlines
        db $00    ; termination byte
    }
        
; ==============================================================================

    ; $7302-$7311 DATA
    pool ConfigureSpotlightTable:
    {
    
    ; granularity of how much the spotlight expands or dilates each frame
    .delta_size
        dw -7,   7,   7,   7
    
    .goal
        dw  0, 126,  35, 126
    }
    
; ==============================================================================

    ; *$7312-$7426 LONG
    ConfigureSpotlightTable:
    {
        PHB : PHK : PLB
        
        REP #$30
        
        ; $0E = (Link's Y coordinate - BG2VOFS mirror + 0x0C)
        ; $0674 = $0E - $067C
        LDA $20 : SUB $E8 : ADD.w #$000C : STA $0E : SUB $067C : STA $0674
        
        LDA $0E : ADD $067C : STA $0676
        
        ; $0670 = (Link's X coordinate - BG2HOFS mirror + 0x08)
        LDA $22 : SUB $E2 : ADD.w #$0008 : STA $0670
        
        ; temporary caching of this value?
        LDA $067C : STA $067A
        
        ; $06 = $0E << 1, check if >= 0xE0
        LDA $0E : ASL A : STA $06 : CMP.w #$00E0 : BCS .largeEnough
        
        ; the length of the table must span at least 224 scanlines (0xE0)
        LDA.w #$00E0 : STA $06
    
    .largeEnough
    
        ; $0A = $06 - $0E, $04 = $0E - $0A = ( (2 * $0E) - $06 )
        LDA $06 : SUB $0E : STA $0A
        LDA $0E : SUB $0A : STA $04
    
    ; *$7361 ALTERNATE ENTRY POINT
    
        LDA.w #$00FF : STA $08
        
        LDA $06 : CMP $0676 : BCS BRANCH_BETA
        
        LDA $067A : BEQ BRANCH_GAMMA
        
        DEC $067A
    
    BRANCH_GAMMA:
    
        JSR $F4CC ; $74CC IN ROM
    
    BRANCH_BETA:
    
        LDA $04 : ASL A : CMP.w #$01C0 : BCS BRANCH_DELTA
        
        TAX
        
        LDA $08 : STA $7F7000, X
    
    BRANCH_DELTA:
    
        LDA $06 : ASL A : CMP.w #$01C0 : BCS BRANCH_EPSILON
        
        TAX
        
        LDA $08 : STA $7F7000, X
    
    BRANCH_EPSILON:
    
        LDA $0E : CMP $04 : BEQ BRANCH_ZETA
        
        INC $04
        DEC $06
        
        JMP $F361 ; $7361 IN ROM
    
    BRANCH_ZETA:
    
        LDA $2137 
        LDA $213F
        
        LDA $213D : AND.w #$00FF : CMP.w #$00C0 : BCC BRANCH_ZETA
        
        LDX.w #$0000
    
    .copyTable
    
        LDA $7F7000, X : STA $1B00, X
        
        INX #2 : CPX.w #$01C0 : BCC .copyTable
        
        LDX $067E
        
        ; $067C = (+/-) 0x07, compare with either 0 or 0x7E
        LDA $067C : ADD .delta_size, X : STA $067C
        
        CMP .goal, X : BNE .return
        
        SEP #$20
        
        LDA $067E : BNE .resetTable
        
        ; Enable forceblank
        LDA.b #$80 : STA $13 : STA $2100
        
        BRA BRANCH_LAMBDA
    
    .resetTable
    
        JSL ResetSpotLightTable
    
    BRANCH_LAMBDA:
    
        SEP #$30
        
        STZ $B0 : STZ $11
        
        LDA $10
        
        CMP.b #$07 : BEQ BRANCH_MU
        CMP.b #$10 : BNE BRANCH_NU
    
    BRANCH_MU:
    
        LDA $1B : BNE BRANCH_XI
        
        LDX $8A
        
        LDA $7F5B00, X : LSR #4 : STA $012D
    
    BRANCH_XI:
    
        LDA $0132 : CMP.b #$FF : BEQ BRANCH_NU
        
        STA $012C
    
    BRANCH_NU:
    
        ; restore the current module
        LDA $010C : STA $10 : CMP.b #$06 : BNE .notPreDungeon
        
        JSL Sprite_ResetAll ; $4C44E IN ROM
    
    .return
    .notPreDungeon
    
        SEP #$30
        
        PLB
        
        RTL
    }

; =============================================
    
    ; *$7427-$744A LONG
    ResetSpotlightTable:
    {
        REP #$30
        
        LDX.w #$003E
        LDA.w #$FF00
    
    .loop
    
        STA $1B00, X : STA $1B40, X
        STA $1B80, X : STA $1BC0, X
        STA $1C00, X : STA $1C40, X
        
        STZ $1C80, X
        
        DEX #2 : BPL .loop
        
        SEP #$30
        
        RTL
    }

; =============================================
    
    ; *$74CC-$753D LOCAL
    {
        SEP #$30
        
        ; set up an 8-bit dividend
        STA $4205
        STZ $4204
        
        ; set the divisor
        LDA $067C : STA $4206
        
        NOP #6
        
        REP #$20
        
        ; obtain the quotient of the division, and divide by two
        LDA $4214 : LSR A
        
        SEP #$20
        
        TAX
        
        LDY $F44B, X : STY $0A : STY $4202
        
        LDA $067C : STA $4203
        
        NOP #2
        
        STZ $01 : STZ $0B
        
        LDA $4217 : STA $00
        
        REP #$30
        
        ASL $00
        
        LDA $0A : BEQ BRANCH_ALPHA
        
        LDA $00 : ADD $0670 : STA $02
        
        LDA $0670 : SUB $00 : STZ $00 : BMI BRANCH_BETA
        
        BIT.w #$FF00 : BEQ BRANCH_GAMMA
        
        LDA.w #$00FF
    
    BRANCH_GAMMA:
    
        STA $00
    
    BRANCH_BETA:
    
        LDA $02 : BIT.w #$FF00 : BEQ BRANCH_DELTA
        
        LDA.w #$00FF
    
    BRANCH_DELTA:
    
        XBA : ORA $00 : CMP.w #$FFFF : BNE BRANCH_EPSILON
        
        LDA.w #$00FF
    
    BRANCH_EPSILON:
    
        STA $08
    
    BRANCH_ALPHA:
    
        RTS
    }

; =============================================

    OrientLampData:
    {
        ; data for the following routine

    .horitzonal
        dw   0, 256,   0, 256
        
    .vertical
        dw   0,   0, 256, 256

    .adjustment
        dw  52,  -2,  56,   6

    .margin
        dw  64,  64, 82, -176

    .maxima
        dw 128, 384, 160, 160
   
    .easyOut

        RTL
    }
    
    ; *$7567-$7648 LONG
    OrientLampBg:
    {
        ; If necessary, this function orients BG1 (which would have lamp graphics on it) 
        ; to match Link's direction and movement.
        
        ; This variable is nonzero if Link has the lantern and the room is dark.
        LDA $0458 : BEQ OrientLampData_easyOut
        
        LDA $11 : CMP.b #$14 : BEQ OrientLampData_easyOut
        
        REP #$30
        
        ; $00 = X = direction Link is facing
        LDA $2F : AND.w #$00FF : STA $00 : TAX
        
        LDA $6C : AND.w #$00FF : BEQ .notInDoorway
        
        AND.w #$00FE : ASL A : TAX : BEQ .verticalDoorway
        
        LDA $00 : CMP.w #$0004 : BCS .facingLeftOrRight
        
        LDA $22 : ADD.w #$0008 : AND.w #$00FF
        
        BRA BRANCH_DELTA
    
    .facingLeftOrRight
    
        TAX
        
        BRA .notInDoorway
    
    .verticalDoorway
    
        LDA $00 : CMP.w #$0004 : BCC .facingLeftOrRight
        
        LDA $20 : AND.w #$00FF
    
    BRANCH_DELTA:
    
        CMP.w #$0080 : BCC .notInDoorway
        
        INX #2
    
    .notInDoorway
    
        CPX.w #$0004 : BCS .facingLeftOrRight2
        
        LDA $22 : SUB.w #$0077 : STA $00
        
        ; BG1HOFS mirror = BG2HOFS mirror - Link's X coordinate + 0x77 + $00F43E, X
        LDA $E2 : SUB $00 : ADD.l OrientLampData_horizontal, X : STA $E0
        
        LDA $20 : SUB.w #$0058 : STA $00
        
        ; A = BG2VOFS mirror - Link's Y coordinate + 0x58 + bunch of stuff
        LDA $E8 : SUB $00                  : ADD.l OrientLampData_vertical, X 
        ADD.l OrientLampData_adjustment, X : ADD.l OrientLampData_margin, X
        
        BPL .positive
        
        ; don't allow the vertical offset to be negative
        LDA.w #$0000
    
    .positive
    
        CMP.l OrientLampData_maxima, X : BCC .inBounds
        
        LDA.l OrientLampData_maxima, X
    
    .inBounds
    
        ; BG1VOFS mirror = the bounds-checked result of the eaarlier operations
        SUB.l OrientLampData_margin, X : STA $E6
        
        SEP #$30
        
        RTL
    
    .facingLeftOrRight2
    
        LDA $20 : SUB.w #$0072 : STA $00
        
        ; BG1VOFS mirror = BG2VOFS mirror - Link's Y coordinate + 0x72 + $00F546, X
        LDA $E8 : SUB $00 : ADD.l OrientLampData_vertical, X : STA $E6
        
        LDA $22 : SUB.w #$0058 : STA $00
        
        ; A = BG2HOFS mirror - Link's X coordinate + 0x58 + bunch of stuff...
        LDA $E2 : SUB $00                  : ADD.l OrientLampData_horizontal, X 
        ADD.l OrientLampData_adjustment, X : ADD.l OrientLampData_margin, X
        
        BPL .positive2
        
        LDA.w #$0000
    
    .positive2
    
        CMP.l OrientLampData_maxima, X : BCC .inBounds2
        
        LDA.l OrientLampData_maxima, X
    
    .inBounds2
    
        SUB OrientLampData_margin, X : STA $E0
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$7649-$7733 LONG
    Hdma_ConfigureWaterTable:
    {
        REP #$30
        
        ; $0A = $0682 - $E8
        ; $0674 = $0A - $0684
        LDA $0682 : SUB $E8 : STA $0A : SUB $0684 : STA $0674
        
        LDA $0A : ADD $0684
    
    ; *$7660 ALTERNATE ENTRY POINT
    
        ; $0676 = $0A + $0684
        STA $0676
        
        ; Subtract off the current BG2 scroll position.
        LDA $0680 : SUB $E2 : STA $0670
        
        LDA $0686 : BEQ .alpha
        
        DEC A
    
    .alpha
    
        ; $02 = ($0686 ? $0686 : 1) + $0670
        STA $0C : ADD $0670 : STA $02
        
        ; $00 = $0670 - $0C
        LDA $0670 : SUB $0C : STA $00
        
        ; this appears to be a compile time thing, given that it loads a
        ; constant value then immediately tests for negativity
        LDY.w #$0000 : BMI .beta
        
        TAY : AND.w #$FF00 : BEQ .beta
        
        LDY.w #$00FF
    
    .beta
    
        TYA : AND.w #$00FF : STA $00
        
        LDA $02 : TAY : AND.w #$FF00 : BEQ .gamma
        
        LDY #$00FF
    
    .gamma
    
        TYA : AND.w #$00FF : XBA : ORA $00 : STA $0C
        
        LDA $0A : ASL A : STA $06 : CMP.w #$00E0 : BCS .delta
        
        LDA.w #$00E0 : STA $06
    
    .delta
    
        LDA $06 : SUB $0A : STA $08
        LDA $0A : SUB $08 : STA $04
        
        BRA .epsilon
    
    .rho
    
        INC $04
        DEC $06
    
    .epsilon
    
        LDA $04 : BMI .zeta
        
        LDA $0674 : BMI .theta
        
        LDA $04 : CMP $0674 : BCS .theta
        
        ASL A : TAX
        
        LDA.w #$00FF
        
        BRA .iota
    
    .theta
    
        LDA $04 : ASL A : TAX
        
        LDA $0C
    
    .iota
    
        CPX.w #$01C0 : BCS .zeta
        
        CMP.w #$FFFF : BNE .kappa
        
        LDA.w #$00FF
    
    .kappa
    
        STA $1B00, X
    
    .zeta
    
        LDA $06 : CMP $0676 : BCS .mu
        
        ASL A : TAX
        
        LDA.w #$00FF
        
        BRA .nu
    
    .mu
    
        CMP.w #$00E1 : BCS .xi
        
        LDA $0678 : BEQ .xi
        
        DEC $0678
    
    .xi
    
        LDA $06 : ASL A : TAX
        
        LDA $0C
    
    .nu
    
        CPX.w #$01C0 : BCS .omicron
        
        CMP.w #$FFFF : BNE .pi
        
        LDA.w #$00FF
    
    .pi
    
        STA $1B00, X
    
    .omicron
    
        LDA $0A : CMP $04 : BNE .rho
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$7734-$77DF LONG
    {
        !leftFinal  = $00
        !scanline   = $04
        !lineBounds = $0C
        
        !leftBase   = $0670
        !startLine  = $0676
        !lineOffset = $0686
        
        ; ------------------------------
        
        REP #$30
        
        STZ !scanline
        
        ; $0674 = $0682 - BG2VOFS mirror
        ; $0670 = $0680 - BG2HOFS mirror
        LDA $0682 : SUB $E8 : STA $0674
        LDA $0680 : SUB $E2 : STA !leftBase
        
        ; $0E = $0686 ^ 0x0001
        LDA !lineOffset : EOR.w #$0001 : STA $0E
        
        ; $02 = $0E + $0670
        ADD !leftBase : STA $02
        
        LDA !leftBase : SUB $0E : AND.w #$00FF : STA !leftFinal
        
        LDA $02 : AND.w #$00FF : XBA : ORA !leftFinal : STA !lineBounds
    
    .disableLoop
    
        LDA !scanline : ASL A : TAX
        
        LDA.w #$FF00 : STA $1B00, X
        
        ; $0676 was determined when the watergate barrier was placed
        INC !scanline : LDA !scanline : CMP !startLine : BNE .disableLoop
        
        LDA $0E : SUB.w #$0007 : ADD.w #$0008 : STA !lineBounds
        
        ADD !leftBase : STA $02
        
        LDA !leftBase : SUB !lineBounds : AND.w #$00FF : STA !leftFinal
        
        LDA $02 : AND.w #$00FF : XBA : ORA !leftFinal : STA !lineBounds
        
        LDA !startLine : ADD $0684 : EOR.w #$0001 : STA $0A
    
    .nextScanline
    
        LDA !scanline : CMP $0A : BCC .beta
        
        ASL A : TAX
        
        LDA.w #$00FF
        
        BRA .gamma
    
    .beta
    
        ASL A : TAX : CPX.w #$01C0 : BCS .beta
        
        LDA $0C
    
    .gamma
    
        CMP.w #$FFFF : BNE .delta
        
        LDA.w #$00FF
    
    .delta
    
        STA $1B00, X
        
        INC !scanline : LDA !scanline : CMP.w #$00E1 : BCC .nextScanline
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$7800-$7875 JUMP LOCATION
    Module_Messaging:
    {
        ; Beginning of Module 0x0E - Messaging mode
        
        LDA $1B : BEQ .outdoors
        
        LDA $11 : CMP.b #$03 : BNE .notDungeonMapMode
        
        LDA $0200  : BEQ .processCoreTasks
        CMP.b #$07 : BEQ .processCoreTasks
        
        BRA .ignoreCoreTasks
    
    .notDungeonMapMode
    
        ; handles moving blocks and other stuff we're trying to finish up
        ; before pausing the action on screen.
        JSL PushBlock_Handler
        
        BRA .processCoreTasks
    
    .outdoors
    
        LDA $11 : CMP.b #$07 : BEQ .mode7MapMode
        
        CMP.b #$0A : BNE .processCoreTasks
    
    .mode7MapMode
    
        LDA $0200 : BNE .ignoreCoreTasks
    
    .processCoreTasks
    
        JSL Sprite_Main
        JSL PlayerOam_Main
        
        LDA $1B : BNE .indoors
        
        JSL $02A4CD ; $124CD IN ROM
    
    .indoors
    
        JSL HUD.RefillLogicLong
        
        LDA $11 : CMP.b #$02 : BEQ .dialogueMode
        
        JSL OrientLampBg
    
    .dialogueMode
    .ignoreCoreTasks
    
        SEP #$30
        
        JSL Messaging_Main
        
        REP #$21
        
        LDA $E2 : ADC $011A : STA $011E
        LDA $E8 : ADD $011C : STA $0122
        LDA $E0 : ADD $011A : STA $0120
        LDA $E6 : ADD $011C : STA $0124
        
        SEP #$20
    
    ; *$7875 ALTERNATE ENTRY POINT
    .doNothing
    
        RTL
    }

; ==============================================================================

    ; $7876-$7899 JUMP TABLE
    Messaging_MainJumpTable:
    {
        ; \task figure out interleaving syntax for tables like this.
        ; Parameterized by X:
        
        dl $00F875 ; = $7875*  ; X=0: ; RTL (do nothing)
        dl $0DDD2A ; = $6DD2A* ; X=1: ; Link's item submenu (press start)
        dl $0EC440 ; = $74440* ; X=2: ; Dialogue Mode
        dl $0AE0B0 ; = $560B0* ; X=3: ; Dungeon Map Mode
        dl $00F8FB ; = $78FB*  ; X=4: ; Fills life (red potion)
        dl Messaging_PrayingPlayer ; X=5: ; Link praying in front of desert palace before it opens.
        dl $00F8E9 ; = $78E9*  ; X=6: ; unused? Agahnim 2 related code?
        dl $0AB98B ; = $5398B* ; X=7: ; Overworld Map Mode
        dl $00F911 ; = $7911*  ; X=8: ; Fill up all magic (green potion)
        dl $00F918 ; = $7918*  ; X=9: ; Fill up magic and life (blue potion)
        dl $0AB730 ; = $53730* ; X=A: ; The bird (duck?) that flies you around.
        dl $00F9FA ; = $79FA*  ; X=B: ; Continue/Save & Quit Mode
    }

; ==============================================================================

    ; *$789A-$78B0 LONG
    Messaging_Main:
    {
        LDX $11
        
        LDA $00F876, X : STA $00
        LDA $00F882, X : STA $01
        LDA $00F88E, X : STA $02
        
        JMP [$0000] ; SEE JUMP TABLE $7876
    }

; ==============================================================================

    ; *$78B1-$78C5 JUMP LOCATION LONG
    Messaging_PrayingPlayer:
    {
        ; for using messaging functions without being in module 0x0E
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLongJumpTable
        
        dl $02A2A5                      ; = $122A5* (initialize overworld color filtering settings)
        dl PaletteFilter.doFiltering    ; Fade out before we set up the actual scene.
        dl PrayingPlayer_InitScene
        dl PrayingPlayer_FadeInScene
        dl PrayingPlayer_AwaitButtonInput
    }

; ==============================================================================

    ; *$78C6-$78DF JUMP LOCATION LONG
    PrayingPlayer_InitScene:
    {
        JSL Player_InitPrayingScene_HDMA
        
        ; Reverse filtering direction?
        LDA $7EC00B : DEC A : STA $7EC007
        
        LDA.b #$00 : STA $7EC00B
        LDA.b #$02 : STA $7EC009
        
        RTL
    }

; =============================================

    ; *$78E0-$78E8 JUMP LOCATION LONG
    PrayingPlayer_FadeInScene:
    {
        ; Lightens scene until fully illuminated.
        JSL PaletteFilter.doFiltering
    
    ; *$78E4 ALTERNATE ENTRY POINT
    shared PrayingPlayer_AwaitButtonInput:
    
        JSL $07EA27 ; $3EA27 IN ROM
        
        RTL
    }
    
; =============================================
    
    ; *$78E9-$78FA JUMP LOCATION LONG
    {
        LDA $B0
        
        JSL UseImplicitRegIndexedLongJumpTable
        
        dl $02A2A5  ; $122A5 initialize a bunch of overworld crap
        dl PaletteFilter.doFiltering
        dl $02A2A9 ; swap some palettes in memory?
        dl $02A2AD ; $122AD
    }

; =============================================
    
    ; *$78FB-$7910 JUMP LOCATION LONG
    {
        JSL HUD.RefillHealth : BCC BRANCH_ALPHA
    
    ; *$7901 ALTERNATE ENTRY POINT
    
        LDA $3A : AND.b #$BF : STA $3A
        
        INC $16
        
        STZ $11
        
        LDA $010C : STA $10
    
    BRANCH_ALPHA:
    
        RTL
    }

; =============================================
    
    ; *$7911-$7917 JUMP LOCATION LONG
    {
        JSL HUD.RefillMagicPower : BCS BRANCH_$7901
        
        RTL
    }

; ==============================================================================

    ; *$7918-$792C JUMP LOCATION LONG
    {
        JSL HUD.RefillHealth : BCC .alpha
        
        LDA.b #$08 : STA $11
    
    .alpha
    
        JSL HUD.RefillMagicPower : BCC .beta
        
        LDA.b #$04 : STA $11
    
    .beta
    
        RTL
    }

; ==============================================================================

    ; *$7945-$79DC LONG
    PrepDungeonExit:
    {
        JSL SavePalaceDeaths
        JSL Dungeon_SaveRoomData_justKeys ; $121C7 IN ROM ; Save current dungeon keys to proper slots.
        
        ; Indicate a boss has been killed in this room.
        LDA $0403 : ORA.b #$80 : STA $0403
        
        JSL $02B929 ; $13929 IN ROM ; Save the room data as we exit.
        
        LDX.b #$0C
        
        LDA $A0
    
    .next_room
    
        ; Cycle through all the registered boss rooms.
        ; If it's not the room we're in, branch
        DEX : CMP $00F92D, X : BNE .next_room
        
        ; Set the room to the entrance room of the palace (I'm guessing this is so we can use an exit object?)
        ; Are we in Agahnim's room?
        LDA $00F939, X : STA $A0 : CMP.b #$20 : BNE .not_agahnim
        
        ; After beating Agahnim the world state gets set to 3 ("second part")
        LDA.b #$03 : STA $7EF3C5
        
        ; Set up the lumber jack's pit tree overlay so that the tree looks different
        LDA $7EF282 : ORA.b #$20 : STA $7EF282
        
        ; Put us in the Dark World.
        LDA $7EF3CA : EOR.b #$40 : STA $7EF3CA
        
        JSL Sprite_LoadGfxProperties.justLightWorld 
        JSL Ancilla_TerminateSelectInteractives
        
        STZ $037B : STZ $3C : STZ $3A : STZ $03EF
        
        ; Link can't move
        LDA.b #$01 : STA $02E4
        
        ; The module to return to is #$08 (preoverworld)
        LDA.b #$08 : STA $010C
        
        ; Do the magic mirror sequence.
        ; (After all, we just beat Agahnim.)
        LDA.b #$15 : STA $10
        
        STZ $11 : STZ $B0
        
        RTL
    
    .not_agahnim
    
        ; Are we in Agahnim's second room in Ganon's tower?
        CMP.b #$0D : BNE .not_agahnim_2
        
        ; If in Agahnim's second room, do the "Ganon pops out to say hi" sequence.
        LDA.b #$18 : STA $10
        
        STZ $11 : STZ $0200
        
        ; disable that red flashing?
        LDA.b #$20 : STA $9A
        
        RTL
    
    .not_agahnim_2
    
        ; Ganon and normal Boss victory modes
        ; If room index < Chris Houlihan room
        CPX.b #$03 : BCC .ganon
        
        ; In this case room index >= Chris Houlihan room
        ; Do a volume fade out.
        LDA.b #$F1 : STA $012C : STA $0130
        
        ; Do the normal boss victory mode.
        LDA.b #$16
        
        BRA .normal
    
    .ganon
    
        ; Probably Ganon's boss victory mode.
        LDA.b #$13
    
    .normal
    
        ; Put us in either boss victory mode or boss refill mode.
        STA $10
        
        ; After we're done with doing... whatever go to preoverworld module.
        LDA.b #$08 : STA $010C
        
        STZ $11 : STZ $B0
        
        RTL
    }

; =============================================
    
    ; *$79DD-$79F9 LONG
    SavePalaceDeaths:
    {
        PHX
        
        REP #$20
        
        ; Load the dungeon index.
        LDX $040C
        
        ; Store the running count of deaths and store it as the count for the dungeon we just completed.
        ; If it's Hyrule Castle 2, then branch.
        LDA $7EF403 : STA $7EF3E7, X : CPX.b #$08 : BEQ .hyruleCastle
        
        ; Otherwise zero out the number of deaths.
        LDA.w #$0000 : STA $7EF403
    
    .hyruleCastle
    
        SEP #$20
        
        PLX
        
        RTL
    }

; =============================================
    
    ; *$79FA-$7A40 JUMP LOCATION
    {
        LDA $1B : BNE .indoors
        
        JSL Overworld_DwDeathMountainPaletteAnimation
    
    .indoors
    
        JSL Messaging_Text
        
        STZ $16 : STZ $0710
        
        LDA $B0 : CMP.b #$03 : BCS BRANCH_BETA
        
        INC $B0
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        STZ $14
    
    BRANCH_GAMMA:
    
        LDA $11 : BNE .notBaseSubmodule
        
        STZ $B0
        
        LDA.b #$01 : STA $14
        
        ; if zero, the player choose "continue", if not "save and quit"
        LDA $1CE8 : BEQ .continue
        
        ; Save and quit
        
        ; play the save and quit sound effect
        LDA.b #$0F : STA $012D
        
        ; go in to the save and quit main module
        LDA.b #$17 : STA $10
        
        ; use the 0x01 submodule (???)
        LDA.b #$01 : STA $11
        
        STZ $05FC : STZ $05FD
        
        RTL
    
    .continue
    
        ; Restore $1CE8's value and carry on
        LDA $1CF4 : STA $1CE8
    
    .notBaseSubmodule
    
        RTL
    }
    
; =============================================

    ; $7A41
    Sprite_GfxIndices:
    {
        ; phase 0 / 1 (light world)
        db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02, $00, $00, $00
        db $00, $00, $00, $02, $02, $00, $00, $00, $00, $00, $00, $02, $02, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        
        ; phase 2 (light world)
        db $07, $07, $07, $10, $10, $10, $10, $10, $07, $07, $07, $10, $10, $10, $10, $04
        db $06, $06, $00, $03, $03, $00, $0D, $0A, $06, $06, $01, $01, $01, $04, $05, $05
        db $06, $06, $06, $01, $01, $04, $05, $05, $06, $09, $0F, $00, $00, $0B, $0B, $05
        db $08, $08, $0A, $04, $04, $04, $04, $04, $08, $08, $0A, $04, $04, $04, $04, $04
        
        ; phase 3 (light world)
        db $07, $07, $1A, $10, $10, $10, $10, $10, $07, $07, $1A, $10, $10, $10, $10, $04
        db $06, $06, $00, $03, $03, $00, $0D, $0A, $06, $06, $1C, $1C, $1C, $02, $05, $05
        db $06, $06, $06, $1C, $1C, $00, $05, $05, $06, $00, $0F, $00, $00, $23, $23, $05
        db $1F, $1F, $0A, $20, $20, $20, $20, $20, $1F, $1F, $0A, $20, $20, $20, $20, $20
        
        ; all phases (dark world)
        db $13, $13, $17, $14, $14, $14, $14, $14, $13, $13, $17, $14, $14, $14, $14, $16
        db $15, $15, $12, $13, $13, $18, $16, $16, $15, $15, $13, $26, $26, $13, $17, $17
        db $15, $15, $15, $26, $26, $13, $17, $17, $1B, $1D, $11, $13, $13, $18, $18, $17
        db $16, $16, $13, $13, $13, $19, $19, $19, $16, $16, $18, $13, $18, $19, $19, $19
    }
    
; =============================================

    ; $7B41
    Sprite_PaletteIndices:
    {
        ; phase 0 / 1 (light world)
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
        
        ; phase 2 (light world)
        db $05, $05, $06, $09, $09, $09, $09, $09, $05, $05, $06, $09, $09, $09, $09, $03
        db $01, $01, $00, $02, $02, $00, $06, $03, $01, $01, $01, $03, $03, $03, $07, $07
        db $01, $01, $01, $03, $03, $03, $07, $07, $01, $00, $01, $00, $00, $03, $03, $07
        db $04, $04, $00, $03, $03, $03, $03, $03, $04, $04, $00, $03, $03, $03, $03, $03
        
        ; phase 3 (light world)
        db $05, $05, $06, $09, $09, $09, $09, $09, $05, $05, $06, $09, $09, $09, $09, $03
        db $01, $01, $00, $02, $02, $00, $06, $03, $01, $01, $01, $01, $01, $03, $07, $07
        db $01, $01, $01, $01, $01, $03, $07, $07, $01, $00, $01, $00, $00, $03, $03, $07
        db $04, $04, $00, $03, $03, $03, $03, $03, $04, $04, $00, $03, $03, $03, $03, $03
        
        ; all phases (dark world)
        db $0E, $0E, $10, $0C, $0C, $0C, $0C, $0C, $0E, $0E, $10, $0C, $0C, $0C, $0C, $0A
        db $10, $10, $00, $0E, $0E, $00, $0D, $0A, $10, $10, $10, $0E, $0E, $0E, $0D, $0D
        db $10, $10, $10, $0E, $0E, $0E, $0D, $0D, $12, $00, $0B, $0E, $0E, $0E, $0E, $0D
        db $0F, $0F, $00, $0E, $0E, $0E, $0E, $0E, $0F, $0F, $00, $0E, $0E, $0E, $0E, $0E
    }

; =============================================

    ; *$7C41-$7C9B LONG
    Sprite_LoadGfxProperties:
    {
        PHB : PHK : PLB
        
        REP #$30
        
        LDY.w #$00FE
        LDX.w #$003E
    
    .darkWorldLoop
    
        LDA Sprite_GfxIndices, Y     : STA $7EFD00, X
        LDA Sprite_PaletteIndices, Y : STA $7EFD80, X
        
        DEY #2
        
        DEX #2 : BPL .darkWorldLoop
        
        BRA .doLightWorld
    
    ; *$7C62 ALTERNATE ENTRY POINT
    .justLightWorld
    
        PHB : PHK : PLB
        
        REP #$30
    
    .doLightWorld
    
        ; If game stage == 0 or 1
        LDY.w #$003E
        
        ; Which game stage are we in?
        LDA $7EF3C5 : AND.w #$00FF : CMP.w #$0002 : BCC .beforeSavingZelda
        
        LDY.w #$007E
        
        CMP.w #$0003 : BNE .beforeKillingAgahnim
        
        LDY.w #$00BE
    
    .beforeSavingZelda
    .beforeKillingAgahnim
    
        LDX.w #$003E
    
    .lightWorldLoop
    
        ; This array will be used to load values for $0AA3 and $0AB1 at a later time
        LDA Sprite_GfxIndices, Y     : STA $7EFCC0, X
        LDA Sprite_PaletteIndices, Y : STA $7EFD40, X
        
        DEY #2 : DEX #2 : BPL .lightWorldLoop
        
        SEP #$30
        
        PLB
        
        RTL
    }
    
; =============================================

    ; $7C9C-$7D1B DATA - auxiliary graphics index for overworld areas (0x80 entries)
    {
        db $21, $21, $21, $22, $22, $22, $22, $22
        
        ; ....
        
        db $42, $42, $30, $40, $40, $42, $42, $40
        db $42, $42, $30, $40, $40, $42, $42, $30
    }

; =============================================

    ; *$7DA4-$7DED LONG
    Dungeon_InitStarTileChr:
    {
        ; Swaps star tiles, bitches!
        STZ $04BC
    
    ; *$7DA7 ALTERNATE ENTRY POINT
    Dungeon_RestoreStarTileChr:
    
        ; This entry point is used when we want to toggle the chr state of the
        ; star tiles, or if we need to restore it after coming back from 
        ; some other submode like the dungeon map. 
        REP #$10
        
        LDX.w #$0000
        LDY.w #$0020
        
        LDA $04BC : BEQ .notToggled
        
        ; swap X and Y
        TYX : LDY #$0000
    
    .notToggled
    
        STY $0E
        
        ; set data bank to 0x7F
        PHB : LDA.b #$7F : PHA : PLB
        
        REP #$20
        
        LDY.w #$0000
    
    ; these two loops are for swapping the star tiles in VRAM
    ; tricky shit, took me a while to figure out what the offset
    ; $7EBDC0 was for!
    .swapTile1
    
        LDA $7EBDC0, X : STA $0000, Y
        
        INX #2
        
        INY #2 : CPY.w #$0020 : BNE .swapTile1
        
        LDX $0E
    
    .swapTile2
    
        LDA $7EBDC0, X : STA $0000, Y
        
        INX #2
        
        INY #2 : CPY.w #$0040 : BNE .swapTile2
        
        SEP #$30
        
        PLB
        
        ; Tell NMI to update the star tiles in vram.
        LDA.b #$18 : STA $17
        
        RTL
    }

; ==============================================================================
    
    ; *$7DEE-$7E5D LONG
    Mirror_InitHdmaSettings:
    {
        STZ $9B
        
        REP #$20
        
        STZ $06A0 : STZ $06AC : STZ $06AA : STZ $06AE : STZ $06B0
        
        LDA.w #$0008 : STA $06B4
                       STA $06B6
        
        LDA.w #$0015 : STA $06B2
        LDA.w #$FFC0 : STA $06A6
        LDA.w #$0040 : STA $06A8
        LDA.w #$FE00 : STA $06A2
        LDA.w #$0200 : STA $06A4
        
        STZ $06AC : STZ $06AE
        
        LDA.w #$0F42 : STA $4370
        LDA.w #$0D42 : STA $4360
        
        LDX.b #$3E
        
        LDA $E2
    
    ; *$7E3E ALTERNATE ENTRY POINT
    .init_hdma_table
    
        STA $1B00, X : STA $1B40, X : STA $1B80, X : STA $1BC0, X
        STA $1C00, X : STA $1C40, X : STA $1C80, X
        
        DEX #2 : BPL .init_hdma_table
        
        SEP #$20
        
        ; Enable hdma channels 6 and 7.
        LDA.b #$C0 : STA $9B
        
    .easy_out
        
        RTL
    }

; ==============================================================================
    
    ; *$7E5E-$7F2E LONG
    {
        INC $B0
        
        ; Enable hdma (though I thought it already would be at this point).
        LDA.b #$C0 : STA $9B
    
    ; *$7E64 ALTERNATE ENTRY POINT
    
        JSL $00EEE7 ; $6EE7 IN ROM
        
        ; Only do something every other frame.
        LDA $1A : LSR A : BCS Mirror_InitHdmaSettings.easy_out
        
        REP #$30
        
        LDX.w #$01A0
        LDY.w #$01B0
        
        LDA.w #$0002 : STA $00
        
        LDA.w #$0003 : STA $02
    
    .gamma
    
        LDA $1B00, X
        
        STA $1B00, Y : STA $1B04, Y
        STA $1B08, Y : STA $1B0C, Y
        
        TXA : SUB.w #$0010 : TAX
        
        DEC $00 : BNE .alpha
        
        LDA.w #$0008 : STA $00
    
    .alpha
    
        TYA : SUB.w #$0010 : TAY
        
        DEC $02 : BNE .beta
        
        LDA.w #$0008 : STA $02
    
    .beta
    
        CPY.w #$0000 : BNE .gamma
        
        LDX $06A0
        
        ; Is it just me, or is this a really weird set of formulas?
        LDA $06AC : ADD $06A6, X : PHA : SUB $06A2, X : EOR $06A2, X : BMI .delta
        
        STZ $06AA
        STZ $06AE
        
        ; Toggle this variable's state.
        LDA $06A0 : EOR.w #$0002 : STA $06A0
        
        ; Replace the value on the stack with this.
        PLA : LDA $06A2, X : PHA

    .delta

        PLA : STA $06AC
        
        ADD $06AE : PHA : AND.w #$00FF : STA $06AE
        
        PLA : BPL .epsilon
        
        ORA.w #$00FF
        
        BRA .zeta
    
    .epsilon
    
        AND.w #$FF00
    
    .zeta
    
        XBA : ADD $06AA : STA $06AA : TAX
        
        LDA $7EC007 : CMP.w #$0030 : BCC BRANCH_THETA
        
        TXA : AND.w #$FFF8 : BNE BRANCH_THETA
        
        LDA.w #$FF00 : STA $06A2
        
        LDA.w #$0100 : STA $06A4
        
        LDX.w #$0000
        
        INC $B0
    
    BRANCH_THETA:
    
        TXA : ADD $E2 : STA $1B00 : STA $1B04 : STA $1B08 : STA $1B0C
        
        SEP #$30
    
    .return
    
        RTL
    }

    ; *$7F2F-$7FB6 JUMP LOCATION (LONG)
    {
        JSL $00EEE7 ; $6EE7 IN ROM
        
        LDA $1A : LSR A : BCS BRANCH_$7E5E_return
        
        REP #$30
        
        LDX.w #$01A0
        LDY.w #$01B0
        
        LDA.w #$0002 : STA $00
        LDA.w #$0003 : STA $02
    
    BRANCH_GAMMA:
    
        LDA $1B00, X : STA $1B00, Y : STA $1B04, Y : STA $1B08, Y : STA $1B0C, Y
        
        TXA : SUB.w #$0010 : TAX
        
        DEC $00 : BNE BRANCH_ALPHA
        
        LDA.w #$0008 : STA $00
    
    BRANCH_ALPHA:
    
        TYA : SUB.w #$0010 : TAY
        
        DEC $02 : BNE BRANCH_BETA
        
        LDA.w #$0008 : STA $02
    
    BRANCH_BETA:
    
        CPY.w #$0000 : BNE BRANCH_GAMMA
        
        LDA $1C80 : ORA $1C90 : ORA $1CA0 : ORA $1CB0 : CMP $E2 : BNE BRANCH_DELTA
        
        SEP #$20
        
        STZ $9B
        
        INC $B0
        
        JSL $0BFE70 ; $5FE70 IN ROM
        
        ; check if area is the Hyrule Castle screen or pyramid of power screen
        LDA $8A : AND.b #$3F : CMP.b #$1B : BEQ .dont_align_bgs
        
        REP #$20
        
        LDA $E2 : STA $E0 : STA $0120 : STA $011E
        LDA $E8 : STA $E6 : STA $0122 : STA $0124
    
    .dont_align_bgs
    BRANCH_DELTA:
    
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; $7FB7-$7FBF Null
    {
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    }
    
; ==============================================================================

    ; $7FC0-$7FFF Internal Rom Header
    Internal_Rom_Header:
    {
        db "THE LEGEND OF ZELDA  "
        
        db $20   ; rom layout
        db $02   ; cartridge type
        db $0A   ; rom size
        db $03   ; ram size (sram size)
        db $01   ; country code (NTSC here)
        db $01   ; licensee (Nintendo here)
        db $00   ; game version
        dw $50F2 ; game image checksum
        dw $AF0D ; game image inverse checksum
        
        dw $FFFF, $FFFF, Vector_NMI_return, $FFFF,             Vector_NMI_return, Vector_NMI, Vector_Reset, Vector_IRQ
        dw $FFFF, $FFFF, Vector_NMI_return, Vector_NMI_return, Vector_NMI_return, Vector_NMI_return, Vector_Reset, Vector_IRQ
    }

; ==============================================================================

