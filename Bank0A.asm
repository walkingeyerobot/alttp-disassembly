
; ==============================================================================

    ; *$53730-$5374A JUMP LOCATION LONG
    Messaging_BirdTravel:
    {
        LDA $0200
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw OverworldMap_Backup
        dw BirdTravel_InitGfx
        dw OverworldMap_LoadSprGfx
        dw OverworldMap_BrightenScreen
        dw BirdTravel_InitCounter
        dw BirdTravel_Main
        dw OverworldMap_PrepExit
        dw BirdTravel_LoadTargetArea
        dw BirdTravel_LoadAmbientOverlay
        dw BirdTravel_Finish
    }

; ==============================================================================

    ; *$5374B-$53752 JUMP LOCATION LONG
    BirdTravel_InitGfx:
    {
        STZ $1AF0
        
        JSL OverworldMap_InitGfx
        
        RTL
    }

; ==============================================================================

    ; *$53753-$5375A JUMP LOCATION LONG
    BirdTravel_InitCounter:
    {
        LDA.b #$10 : STA $C8
        
        INC $0200
        
        RTL
    }

; ==============================================================================

    ; $5375B-$5378A DATA
    pool BirdTravel_Main:
    {
    
        ; \task Apply labels to these locations
        db $7F, $79, $6C, $6D, $6E, $6F, $7C, $7D
    
        db $80, $CF, $10, $B8, $30, $70, $70, $F0
    
        db $06, $0C, $02, $08, $0F, $00, $07, $0E
    
        db $5B, $98, $C0, $20, $50, $B0, $30, $80
    
        db $03, $05, $07, $0B, $0B, $0F, $0F, $0F
    
        db $80, $40, $20, $10, $08, $04, $02, $01
    }

; ==============================================================================

    ; *$5378B-$538C4 JUMP LOCATION LONG
    BirdTravel_Main:
    {
        LDA $C8 : BNE .waitForCounter
        
        ; Check A, X, B, and Y buttons (BYSTudlr and AXLR----)
        LDA $F2 : ORA $F0 : AND.b #$C0 : BEQ .noButtonInput
        
        ; These buttons cause us to exit bird travel and end up at the
        ; selected destination
        INC $0200
        
        RTL
    
    .waitForCounter
    
        DEC $C8
    
    .noButtonInput
    
        LDY.b #$07
        
        LDX $1AF0
    
    BRANCH_LAMBDA:
    
        BRA BRANCH_GAMMA
    
    ; *$537A4 ALTERNATE ENTRY POINT
    
        TXA : INC A : AND.b #$07 : TAX
        
        DEY : BPL BRANCH_LAMBDA
    
    BRANCH_GAMMA:
    
        STX $1AF0
        
        LDA $F4 : AND.b #$0A : BEQ BRANCH_DELTA
        
        DEC $1AF0
        
        LDA.b #$20 : STA $012F
    
    BRANCH_DELTA:
    
        LDA $F4 : AND.b #$05 : BEQ BRANCH_EPSILON
        
        INC $1AF0
        
        LDA.b #$20 : STA $012F
    
    BRANCH_EPSILON:
    
        LDA $1AF0 : AND.b #$07 : STA $1AF0
        
        LDA $1A : AND.b #$10 : BEQ BRANCH_ZETA
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_ZETA
        
        LDA $0E : SUB.b #$04 : STA $0E
        LDA $0F : SUB.b #$04 : STA $0F
        
        LDA.b #$00 : STA $0D
        LDA.b #$3E : STA $0C
        LDA.b #$02 : STA $0B
        
        LDX.b #$10
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_ZETA:
    
        LDA $7EC108 : PHA
        LDA $7EC109 : PHA
        LDA $7EC10A : PHA
        LDA $7EC10B : PHA
        
        LDX.b #$07
    
    ; *$53813 ALTERNATE ENTRY POINT
    
        CPX $1AF0 : BNE BRANCH_THETA
        
        LDA $0AB763, X : STA $1AB0, X : STA $7EC10A
        LDA $0AB76B, X : STA $1AC0, X : STA $7EC10B
        LDA $0AB773, X : STA $1AD0, X : STA $7EC108
        LDA $0AB77B, X : STA $1AE0, X : STA $7EC109
        
        PHX
        
        JSR $C39F ; $5439F IN ROM
        
        PLX
        
        BCC BRANCH_IOTA
        
        LDA $0AB75B, X : STA $0D
        
        LDA $1A : AND.b #$06 : ORA.b #$30 : STA $0C
        
        LDA.b #$00 : STA $0B
        
        PHX
        
        JSR $C51C ; $5451C IN ROM
        
        PLX
        
        BRA BRANCH_IOTA
    
    BRANCH_THETA:
    
        LDA $0AB763, X : STA $1AB0, X : STA $7EC10A
        LDA $0AB76B, X : STA $1AC0, X : STA $7EC10B
        LDA $0AB773, X : STA $1AD0, X : STA $7EC108
        LDA $0AB77B, X : STA $1AE0, X : STA $7EC109
        
        PHX
        
        JSR $C39F ; $5439F IN ROM
        
        PLX
        
        BCC BRANCH_IOTA
        
        LDA $0AB75B, X : STA $0D
        
        LDA.b #$32 : STA $0C
        LDA.b #$00 : STA $0B
        
        PHX
        
        JSR $C51C ; $5451C IN ROM
        
        PLX
    
    BRANCH_IOTA:
    
        DEX : BMI BRANCH_KAPPA
        
        JMP $B813 ; $53813 IN ROM
    
    BRANCH_KAPPA:
    
        PLA : STA $7EC10B
        PLA : STA $7EC10A
        PLA : STA $7EC109
        PLA : STA $7EC108
        
        RTL
    }

; ==============================================================================

    ; *$538C5-$53947 JUMP LOCATION LONG
    BirdTravel_LoadTargetArea:
    {
        ; reset the overlay flags for the swamp palace and its light world
        ; counterpart.
        LDA $7EF2BB : AND.b #$DF : STA $7EF2BB
        LDA $7EF2FB : AND.b #$DF : STA $7EF2FB
        
        ; reset the indoor flags for the swamp palace and the watergate as well.
        LDA $7EF216 : AND.b #$7F : STA $7EF216
        LDA $7EF051 : AND.b #$FE : STA $7EF051
        
        JSL BirdTravel_LoadTargetAreaData
        JSL BirdTravel_LOadTargetAreaPalettes
        
        LDY.b #$58
        
        LDA $8A : AND.b #$BF
        
        CMP.b #$03 : BEQ .death_mountain
        CMP.b #$05 : BEQ .death_mountain
        CMP.b #$07 : BEQ .death_mountain
        
        LDY.b #$5A
    
    .death_mountain
    
        JSL $00D394 ; $5394 IN ROM
        JSL $0BFE70 ; $5FE70 IN ROM
        
        STZ $0AA9
        STZ $0AB2
        
        JSL InitTilesets
        
        INC $0200
        
        STZ $B2
        
        JSL $02B1F4 ; $131F4 IN ROM
        
        ; Play sound effect indicating we're coming out of map mode
        LDA.b #$10 : STA $012F
        
        ; reset the ambient sound effect to what it was
        LDX $8A : LDA $7F5B00, X : LSR #4 : STA $012D
        
        ; if it's a different music track than was playing where we came from,
        ; simply change to it (as opposed to setting volume back to full)
        LDA $7F5B00, X : AND.b #$0F : TAX : CPX $0130 : BNE .different_music
        
        ; otherwise, just set the volume back to full.
        LDX.b #$F3
    
    .different_music
    
        STX $012C
        
        RTL
    }

; ==============================================================================

    ; *$53948-$53963 LONG
    BirdTravel_LoadAmbientOverlay:
    {
        REP #$20
        
        LDA $10 : PHA
        
        LDA $0200 : PHA
        
        SEP #$20
        
        ; Loads overworld map32 data (and subsequently map16, etc etc)
        JSL $02B1F0 ; $131F0 IN ROM
        
        REP #$20
        
        PLA : INC A : STA $0200
        
        PLA : STA $10
        
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; *$53964-$5398A JUMP LOCATION LONG
    BirdTravel_Finish:
    {
        INC $13
        
        LDA $13 : CMP.b #$0F : BNE .keep_brightening
    
    ; *$5396C ALTERNATE ENTRY POINT
    .restore_prev_module
    
        STZ $0200
        
        STZ $B0
        
        LDA $010C : STA $10
        
        STZ $11
        
        LDA $7EC229 : STA $9B
        
        LDY.b #$04
        LDA.b #$27
        
        JSL AddTravelBird.drop_off
    
    .keep_brightening
    
        JSL Sprite_Main
        
        RTL
    }

; ==============================================================================

    ; *$5398B-$539A1 JUMP LOCATION LONG
    Messaging_OverworldMap:
    {
        LDA $0200
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw OverworldMap_Backup
        dw OverworldMap_InitGfx
        dw OverworldMap_DarkWorldTilemap
        dw OverworldMap_LoadSprGfx
        dw OverworldMap_BrightenScreen
        dw OverworldMap_Main
        dw OverworldMap_PrepExit
        dw OverworldMap_RestoreGfx
    }

; ==============================================================================

    ; *$539A2-$539A2 BRANCH LOCATION
    OverworldMap_KeepDarkening:
    {
        RTS
    }

; ==============================================================================

    ; *$539A3-$53A2F JUMP LOCATION LONG
    OverworldMap_Backup:
    {
        ; Darken the screen until it's fully black.
        DEC $13 : BNE OverworldMap_KeepDarkening
        
        ; Cache hdma settings
        LDA $9B : STA $7EC229
        
        JSL EnableForceBlank ; $93D IN ROM
        
        ; Set mosaic to disabled on BG1 and BG2
        LDA.b #$03 : STA $95
        
        ; Move to next step of submodule
        INC $0200
        
        REP #$20
        
        ; cache main screen designation
        LDA $1C : STA $7EC211
        
        ; Cache BG offset register mirros
        LDA $E0 : STA $7EC200
        LDA $E2 : STA $7EC202
        LDA $E6 : STA $7EC204
        LDA $E8 : STA $7EC206
        
        ; Zero out BG offset register mirrors
        STZ $E0 : STZ $E2
        STZ $E4 : STZ $E6
        STZ $E8 : STZ $EA
        
        ; cache CGWSEL register mirror
        LDA $99 : STA $7EC225
        
        LDA.w #$01FC : STA $0100
        
        LDX $8A : CPX.b #$80 : BCS .specialArea
        
        ; Cache Link's coordinates
        LDA $20 : STA $7EC108
        LDA $22 : STA $7EC10A
    
    .specialArea
    
        SEP #$20
        
        LDA $7EF3C5 : CMP.b #$02 : BCS .savedZeldaOnce
        
        ; Clip to black before color math inside color window only
        LDA.b #$80 : STA $99
        
        ; apply color math to BG1 and background, with half addition
        LDA.b #$61 : STA $9A
    
    .savedZeldaOne
    
        ; Play sound effect indicating we're entering overworld map mode
        LDA.b #$10 : STA $012F
        
        ; Play another sound effect in conjunction (to produce a nuanced sound)
        LDA.b #$05 : STA $012D
        
        ; Set volume to half
        LDA.b #$F2 : STA $012C
        
        ; Set screen mode to mode 7 (because the overworld map is done in mode 7, obviously)
        LDA.b #$07 : STA $2105 : STA $94
        
        ; Set so that the playing field is filled with transparency wherever there aren't tiles.
        LDA.b #$80 : STA $211A
        
        RTL
    }

; =============================================

    ; *$53A30-$53A79 JUMP LOCATION LONG
    OverworldMap_InitGfx:
    {
        JSR ClearMode7Tilemap
        
        ; Put BG1 and OBJ on main screen, and nothing on the subscreen
        LDA.b #$11 : STA $1C
                     STZ $1D
        
        JSL WriteMode7Chr       ; $6399 IN ROM
        JSR $BC96               ; $53C96 IN ROM (configures hdma for map mode)
        
        ; Set data bank to 0x0A
        PHB : LDA.b #$0A : PHA : PLB
        
        REP #$30
        
        LDX.w #$00FE
        LDY.w #$00FE
        
        LDA $8A : AND.w #$0040 : BEQ .lightWorld
        
        LDY.w #$01FE
    
    .lightWorld
    .copyFullCgramBuffer
    
        LDA $DB27, Y : STA $7EC500, X
        
        DEY #2
        
        DEX #2 : BPL .copyFullCgramBuffer
        
        SEP #$30
        
        PLB
        
        JSL LoadActualGearPalettes ; $756C0 IN ROM
        
        ; Tell NMI to update CGRAM this frame.
        INC $15
        
        LDA.b #$07 : STA $17
        
        STZ $13
        
        INC $0710
        
        INC $0200
        
        RTL
    }

; =============================================

    ; *$53A7A-$53A99 JUMP LOCATION LONG
    OverworldMap_DarkWorldTilemap:
    {
        ; Performs teh necessary mods to the light world tilemap to produce
        ; the dark world tilemap.
        
        LDA $8A : AND.b #$40 : BEQ .lightWorld
        
        REP #$30
        
        LDX.w #$03FE
    
    .copyLoop
    
        LDA $0AD727, X : STA $1000, X
        
        DEX #2 : BPL .copyLoop
        
        SEP #$30
        
        LDA.b #$15 : STA $17
    
    .lightWorld
    
        INC $0200
        
        RTL
    }

; =============================================

    ; *$53A9A-$53AA9 JUMP LOCATION LOCAL
    OverworldMap_LoadSprGfx:
    {
        LDA.b #$10 : STA $0AAA
        
        JSL Graphics_LoadChrHalfSlot
        
        STZ $0AAA
        
        ; Move on to next substep
        INC $0200
        
        RTL
    }

; ==============================================================================

    ; *$53AAA-$53AB5 JUMP LOCATION LONG
    OverworldMap_BrightenScreen:
    {
        INC $13
        
        LDA $13 : CMP.b #$0F : BNE .notDoneBrightening
        
        ; Move to next step
        INC $0200
    
    .notDoneBrightening
    
        RTL
    }

; ==============================================================================

    ; $53AB6-$53AE5 DATA
    pool OverworldMap_Main:
    {
    
        ; \task Assign labels to these locations.
        db $1E, $00, $1E, $02, $FE, $02, $00, $80
        db $02, $80, $00, $01, $FF, $01, $21, $0C
        db $00, $00, $00, $00, $01, $00, $02, $00
        db $FF, $FF, $FE, $FF, $01, $00, $02, $00
        db $00, $00, $00, $00, $E0, $00, $E0, $01
        db $B8, $FF, $20, $FF, $CF, $BD, $D6, $BD
    }

; ==============================================================================

    ; *$53AE6-$53BD5 JUMP LOCATION LONG
    OverworldMap_Main:
    {
        LDA $0636 : ASL A : BCC .dontToggleZoomLevel
        
        TAX
        
        ; we got rid of bit 7 of $0636
        LSR A : STA $0636
        
        ; Change the matrix multiplication done via hdma
        ; (changes from closeup to full view)
        LDA $0ABAE2, X : STA $4362 : STA $4372
    
    .dontToggleZoomLevel
    
        LDA $0636 : BNE .dontExitMap
        
        ; Check for presses of the X button this frame.
        LDA $F6 : AND.b #$40 : BEQ .dontExitMap
        
        ; The signal to come out of map mode
        INC $0200
        
        RTL
    
    .dontExitMap
    
        LDA $B2 : BEQ .zoomTransitionFinished
        
        DEC $B2
        
        JMP .noButtonInput
    
    .zoomTransitionFinished
    
        ; checking -XLR---- (AXLR----)
        LDA $F6 : AND.b #$70 : BEQ .noButtonInput
        
        ; Play the "change map screen" sound effect.
        LDA.b #$24 : STA $012F
        
        LDA.b #$08 : STA $B2
        
        ; Toggle bit 0 of $0636 and OR in bit 7.
        LDA $0636 : EOR.b #$01 : TAX
        
        ORA.b #$80 : STA $0636
        
        LDA $0ABAC4, X : STA $0637 : CMP.b #$0C : BNE .fartherZoomedOut
        
        REP #$20
        
        LDA $7EC108 : LSR #4 : SUB.w #$0048 : AND.w #$FFFE : STA $E6
        
        ADD.w #$0100 : STA $063A
        
        LDA $7EC10A : LSR #4 : SUB.w #$0080 : STA $02 : BPL BRANCH_ZETA
        
        EOR.w #$FFFF : INC A

    BRANCH_ZETA:

        STA $00
        
        ; A = ($00 * 5) / 2
        ASL #2 : ADD $00 : LSR A
        
        LDX $03 : BPL BRANCH_THETA
        
        EOR.w #$FFFF : INC A
    
    BRANCH_THETA:
    
        ADD.w #$0080
        
        BRA BRANCH_IOTA
    
    .fartherZoomedOut
    
        REP #$21
        
        LDA.w #$00C8 : STA $E6
        ADC.w #$0100 : STA $063A
        
        LDA.w #$0080
    
    BRANCH_IOTA:
    
        AND.w #$FFFE : STA $E0
    
    .noButtonInput
    
        SEP #$20
        
        LDA $0636 : BEQ BRANCH_KAPPA
        
        ; BYSTudlr -> ----ud--
        LDA $F0 : AND.b #$0C : TAX
        
        REP #$20
        
        LDA $E6 : CMP $0ABAD6, X : BEQ BRANCH_LAMBDA
        
        ADD $0ABAC6, X : STA $E6
        ADD.w #$0100 : STA $063A
    
    BRANCH_LAMBDA:
    
        SEP #$20
        
        ; BYSTudlr -> ----lr10 -> X
        ; .... who knows what they're doing... Anyways, keep reading.
        LDA $F0 : AND.b #$03 : ASL A : INC A : ASL A : TAX
        
        REP #$20
        
        LDA $E0 : CMP $0ABAD6, X : BEQ BRANCH_MU
        
        ADD $0ABAC6, X : STA $E0
    
    BRANCH_MU:
    
        SEP #$20
    
    BRANCH_KAPPA:
    
        JSR $BF66 ; $53F66 IN ROM
    
    .easyOut
    
        RTL
    }

; =============================================

    ; *$53BD6-$53C53 JUMP LOCATION
    OverworldMap_PrepExit:
    {
        ; 0x0E.0x07.0x06 (coming out of overworld map)
        
        ; darken screen gradually until fully dark
        DEC $13 : BNE OverworldMap_Main_easyOut ; (RTL)
        
        JSL EnableForceBlank ; $93D IN ROM
        
        INC $0200
        
        REP #$20
        
        LDX.b #$00
    
    .restore_palette
    
        ; This restores the palette to the original state before the map
        ; was brought up
        LDA $7EC300, X : STA $7EC500, X
        LDA $7EC380, X : STA $7EC580, X
        LDA $7EC400, X : STA $7EC600, X
        LDA $7EC480, X : STA $7EC680, X
        
        INX #2 : CPX.b #$80 : BNE .restore_palette
        
        ; Next we restore other screen settings (needs some research)
        
        LDA $7EC225 : STA $99
        
        STZ $E4 : STZ $EA
        
        LDA $7EC200 : STA $E0
        LDA $7EC202 : STA $E2
        LDA $7EC204 : STA $E6
        LDA $7EC206 : STA $E8
        LDA $7EC211 : STA $1C
    
    .restoreHdmaSettings
    
        ; restore HDMA settings on channel 7
        
        LDA.w #$BDDD : STA $4372
        
        LDX.b #$0A : STX $4374
        LDX.b #$00 : STX $4377
        
        SEP #$30
        
        ; Enable hdma only on channel 7 (for spotlight effect)
        LDA.b #$80 : STA $9B
        
        ; Return to screen mode 1 (with priority bit enabled)
        LDA.b #$09 : STA $2105
        
        STA $94
        
        STZ $0710
        
        RTL
    }

; ==============================================================================

    ; *$53C54-$53C95 JUMP LOCATION LONG
    OverworldMap_RestoreGfx:
    {
        ; 0x0E.0x07.0x07 (restoring graphics?)
        
        ; Indicate that special palette values are no longer in use
        STZ $0AA9
        STZ $0AB2
        
        ; $619B IN ROM. Decompression routine
        JSL InitTilesets
        
        ; Update CGRAM this frame
        INC $15
        
        ; Set things back to the way they were, submodule-wise
        STZ $B2
        STZ $0200
        STZ $B0
        
        ; Restore module we came from
        LDA $010C : STA $10
        
        ; Put us in submodule 0x20
        LDA.b #$20 : STA $11
        
        ; Indicate there's no special tile or tilemap transfers this frame
        STZ $1000 : STZ $1001
        
        ; Restore CGADSUB
        LDA $7EC229 : STA $9B
        
        SEP #$20
        
        ; restore ambient sound effect (rain, etc)
        LDX $8A : LDA $7F5B00, X : LSR #4 : STA $012D
        
        ; Play sound effect indicating we're coming out of map mode
        LDA.b #$10 : STA $012F
        
        ; Signal music to go back to full volume
        LDA.b #$F3 : STA $012C
        
        RTL
    }

; ==============================================================================

    ; *$53C96-$53DA4 LOCAL
    {
        REP #$20
        
        LDA.w #$0080 : STA $E0
        LDA.w #$00C8 : STA $E6
        ADC.w #$0100 : STA $063A
        
        LDA.w #$0100 : STA $0638
        
        LDA.w #$1B42 : STA $4360
        LDA.w #$1E42 : STA $4370
        
        SEP #$20
        
        STZ $96 : STZ $97 : STZ $98
        
        STZ $1E : STZ $1F
        
        STZ $211C : STZ $211C
        STZ $211D : STZ $211D
        
        STZ $211F : LDA.b #$01 : STA $211F
        STZ $2120 : STA $2120 
        
        LDA $10 : CMP.b #$14 : BEQ .attractMode
        
        LDA $11 : CMP.b #$0A : BNE .beta
        
        JMP $BD76 ; $53D76 IN ROM
    
    .beta
    
        LDA.b #$04 : STA $0635
        LDA.b #$0C : STA $0637
        LDA.b #$01 : STA $0636
        
        REP #$21
        
        LDA $7EC108 : LSR #4 : SUB.w #$0048 : AND.w #$FFFE : ADD $0ABAC6 : STA $E6
        ADD.w #$0100 : STA $063A
        
        LDA $7EC10A : LSR #4 : SUB.w #$0080 : STA $02 : BPL BRANCH_GAMMA
        
        EOR.w #$FFFF : INC A
    
    BRANCH_GAMMA:
    
        STA $00
        ASL #2 : ADD $00 : LSR A
        
        LDX $03 : BPL BRANCH_DELTA
        
        EOR.w #$FFFF : INC A
    
    BRANCH_DELTA:
    
        ADD.w #$0080 : AND.w #$FFFE : STA $E0
        
        LDA.w #$BDD6 : STA $4362 : STA $4372
        LDX.b #$0A   : STX $4364 : STX $4374
        
        LDX.b #$0A
        
        BRA BRANCH_EPSILON
    
    .attractMode
    
        REP #$21
        
        LDA.w #$BDDD : STA $4362 : STA $4372
        LDX.b #$0A   : STX $4364 : STX $4374
        
        LDX.b #$00
        
        BRA BRANCH_EPSILON
    
    ; *$53D76 ALTERNATE ENTRY POINT
    
        LDA.b #$04 : STA $0635
        LDA.b #$21 : STA $0637
                   : STZ $0636
        
        REP #$21
        
        LDA.w #$BDCF : STA $4362 : STA $4372
        LDX.b #$0A   : STX $4364 : STX $4374
        
        LDX.b #$0A
    
    BRANCH_EPSILON:
    
        STX $4367 : STX $4377
        
        SEP #$20
        
        ; enable hdma transfers on channels 6 and 7.
        LDA.b #$C0 : STA $9B
        
        RTS
    }

; ==============================================================================

    ; *$53DA5-$53DCE LOCAL
    ClearMode7Tilemap:
    {
        ; clears out the low bytes of the first 0x4000 words of VRAM
        
        REP #$20
        
        LDA.w #$00EF : STA $00
        
        ; Sets VRAM address to 0x0000 and configures the video port.
        STZ $2115 : STZ $2116
        
        ; destination register is $2118 and DMA address will not be adjusted.
        LDA.w #$1808 : STA $4310
        
        ; use bank $00 for DMA address.
        STZ $4314
        
        ; use address $000000 ($7E:0000) for DMA address
        LDA.w #$0000 : STA $4312
        
        ; write 0x4000 bytes
        LDA.w #$4000 : STA $4315
        
        ; do transfer on DMA channel 0.
        LDY.b #$02 : STY $420B
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

; $53DCF-$53F65 DATA?

; ==============================================================================

    ; *$53F66-$5439E LOCAL
    {
        LDA $1A : AND.b #$10 : BEQ BRANCH_ALPHA
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_ALPHA
        
        LDA $0E : SUB.b #$04 : STA $0E
        LDA $0F : SUB.b #$04 : STA $0F
        
        LDA #$00 : STA $0D
        LDA #$3E : STA $0C
        LDA #$02 : STA $0B
        
        LDX.b #$00
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_ALPHA:
    
        LDA $7EC108 : PHA
        LDA $7EC109 : PHA
        LDA $7EC10A : PHA
        LDA $7EC10B : PHA
        
        LDA $008A : CMP.b #$40 : BCS BRANCH_BETA
        
        LDX.b #$0F
        
        LDA $1AB0, X : ORA $1AC0, X : ORA $1AD0, X : ORA $1AE0, X : BEQ BRANCH_BETA
        
        LDA $1A : BNE BRANCH_GAMMA
        
        LDA $1AF0, X : INC A : STA $1AF0, X

    BRANCH_GAMMA:

        LDA $1AB0, X : STA $7EC10A
        LDA $1AC0, X : STA $7EC10B
        LDA $1AD0, X : STA $7EC108
        LDA $1AE0, X : STA $7EC109
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_BETA
        
        LDA.b #$6A : STA $0D
        
        LDA $1A : LSR A : AND.b #$03 : TAX
        
        LDA $0ABF62, X : STA $0C
        
        LDA.b #$02 : STA $0B
        
        LDX.b #$0F
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_BETA:
    
        LDA $7EF2DB : AND.b #$20 : BNE BRANCH_DELTA
        
        ; Load map icon indicator variable
        LDA $7EF3C7 : CMP.b #$06 : ROL A : EOR $0FFF : AND.b #$01 : BEQ .lightWorldSprites
    
    BRANCH_DELTA:
    
        JMP $C38A ; $5438A IN ROM
    
    .lightWorldSprites
    
        ; checking pendant 0 (courage)
        LDX.b #$00
        
        ; $545A9 IN ROM
        JSR OverworldMap_CheckPendant : BCS BRANCH_ZETA
        
        ; $545C6 IN ROM
        JSR OverworldMap_CheckCrystal : BCS BRANCH_ZETA
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABDE5, X : BMI BRANCH_ZETA
        
        STA $7EC10B
        
        LDA $0ABDE4, X : STA $7EC10A
        LDA $0ABDF7, X : STA $7EC109
        LDA $0ABDF6, X : STA $7EC108
        
        LDA $0ABEE1, X : BEQ BRANCH_THETA
        CMP.b #$64     : BEQ BRANCH_IOTA
        
        LDA $1A : AND.b #$10 : BNE BRANCH_ZETA
    
    BRANCH_IOTA:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_THETA:
    
        LDX.b #$0E
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_ZETA
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABEE1, X : BEQ BRANCH_KAPPA
        
        STA $0D
        
        LDA $0ABEE0, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        LDA.b #$32     : STA $0C
        LDA.b #$00
    
    BRANCH_LAMBDA:
    
        STA $0B
        
        LDX.b #$0E
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_ZETA:
    
        LDX.b #$01
        
        ; $545A9 IN ROM
        JSR $C5A9 : BCS BRANCH_MU
        
        ; $545C6 IN ROM
        JSR $C5C6 : BCS BRANCH_MU
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABE09, X : BMI BRANCH_MU
        
        STA $7EC10B
        
        LDA $0ABE08, X : STA $7EC10A
        LDA $0ABE1B, X : STA $7EC109
        LDA $0ABE1A, X : STA $7EC108
        
        LDA $0ABEF3, X : BEQ BRANCH_NU
        CMP.b #$64     : BEQ BRANCH_XI
        
        ; every 16 frames...
        LDA $1A : AND.b #$10 : BNE BRANCH_MU
    
    BRANCH_XI:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_NU:
    
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_MU
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABEF3, X : BEQ BRANCH_OMICRON
        
        STA $0D
        
        LDA $0ABEF2, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_PI
    
    BRANCH_OMICRON:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        LDA.b #$32     : STA $0C
        LDA.b #$00
    
    BRANCH_PI:
    
        STA $0B
        
        LDX.b #$0D
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_MU:
    
        LDX.b #$02
        
        ; $545A9 IN ROM
        JSR $C5A9 : BCS BRANCH_RHO
        
        ; $545C6 IN ROM
        JSR $C5C6 : BCS BRANCH_RHO
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABE2D, X : BMI BRANCH_RHO
        
        STA $7EC10B
        
        LDA $0ABE2C, X : STA $7EC10A
        LDA $0ABE3F, X : STA $7EC109
        LDA $0ABE3E, X : STA $7EC108
        
        LDA $0ABF05, X : BEQ BRANCH_SIGMA
        CMP.b #$64     : BEQ BRANCH_TAU
        
        LDA $1A : AND.b #$10 : BNE BRANCH_RHO
    
    BRANCH_TAU:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_SIGMA:
    
        LDX.b #$0C
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_RHO
        
        ; X = (map sprites indictaor << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABF05, X : BEQ BRANCH_UPSILON
        
        STA $0D
        
        LDA $0ABF04, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_PHI
    
    BRANCH_UPSILON:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        
        LDA.b #$32 : STA $0C
        
        LDA.b #$00
    
    BRANCH_PHI:
    
        STA $0B
        
        LDX.b #$0C
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_RHO:
    
        LDX.b #$03
        
        ; $545C6 IN ROM
        JSR $C5C6 : BCS BRANCH_CHI
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABE51, X : BMI BRANCH_CHI
        
        STA $7EC10B
        
        LDA $0ABE50, X : STA $7EC10A
        LDA $0ABE63, X : STA $7EC109
        LDA $0ABE62, X : STA $7EC108
        
        LDA $0ABF17, X : BEQ BRANCH_PSI
        CMP.b #$64     : BEQ BRANCH_OMEGA
        
        LDA $1A : AND.b #$10 : BNE BRANCH_CHI
    
    BRANCH_OMEGA:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_PSI:
    
        LDX.b #$0B
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_CHI
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABF17, X : BEQ BRANCH_ALTIMA
        
        STA $0D
        
        LDA $0ABF16, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_ULTIMA
    
    BRANCH_ALTIMA:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        LDA.b #$32     : STA $0C
        LDA.b #$00
    
    BRANCH_ULTIMA:
    
        STA $0B
        
        LDX.b #$0B
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_CHI:
    
        LDX.b #$04
        
        ; $545C6 IN ROM
        JSR $C5C6 : BCS BRANCH_OPTIMUS
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABE75, X : BMI BRANCH_OPTIMUS
        
        STA $7EC10B
        
        LDA $0ABE74, X : STA $7EC10A
        LDA $0ABE87, X : STA $7EC109
        LDA $0ABE86, X : STA $7EC108
        
        LDA $0ABF29, X : BEQ BRANCH_ALIF
        CMP.b #$64     : BEQ BRANCH_BET
        
        LDA $1A : AND.b #$10 : BNE BRANCH_OPTIMUS
    
    BRANCH_BET:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_ALIF:
    
        LDX.b #$0A
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_OPTIMUS
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABF29, X : BEQ BRANCH_DEL
        
        STA $0D
        
        LDA $0ABF28, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_THEL
    
    BRANCH_DEL:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        LDA.b #$32     : STA $0C
        
        LDA.b #$00
    
    BRANCH_THEL:
    
        STA $0B
        
        LDX.b #$0A
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_OPTIMUS:
    
        LDX.b #$05
        
        ; $545C6 IN ROM
        JSR $C5C6 : BCS BRANCH_SIN
        
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABE99, X : BMI BRANCH_SIN
        
        STA $7EC10B
        
        LDA $0ABE98, X : STA $7EC10A
        LDA $0ABEAB, X : STA $7EC109
        LDA $0ABEAA, X : STA $7EC108
        
        LDA $0ABF3B, X : BEQ BRANCH_SHIN
        
        CMP.b #$64 : BEQ BRANCH_SOD
        
        LDA $1A : AND.b #$10 : BNE BRANCH_SIN
    
    BRANCH_SOD:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_SHIN:
    
        LDX.b #$09
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_SIN
        
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABF3B, X : BEQ BRANCH_DOD
        
        STA $0D
        
        LDA $0ABF3A, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_TOD
    
    BRANCH_DOD:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        LDA.b #$32     : STA $0C
        
        LDA.b #$00
    
    BRANCH_TOD:
    
        STA $0B
        
        LDX.b #$09
        
        JSR $C51C ; $5451C IN ROM
    
    BRANCH_SIN:
    
        LDX.b #$06
        
        ; $545C6 IN ROM
        JSR $C5C6 : BCS BRANCH_ZOD
        
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABEBD, X : BMI BRANCH_ZOD
        
        STA $7EC10B
        
        LDA $0ABEBC, X : STA $7EC10A
        LDA $0ABECF, X : STA $7EC109
        LDA $0ABECE, X : STA $7EC108
        
        LDA $0ABF4D, X : BEQ BRANCH_FATHA
        CMP.b #$64     : BEQ BRANCH_KESRA
        
        LDA $1A : AND.b #$10 : BNE BRANCH_ZOD
    
    BRANCH_KESRA:
    
        JSR $C589 ; $54589 IN ROM
    
    BRANCH_FATHA:
    
        LDX.b #$08
        
        ; $5439F IN ROM
        JSR $C39F : BCC BRANCH_ZOD
        
        ; X = (map sprites indicator << 1)
        LDA $7EF3C7 : ASL A : TAX
        
        LDA $0ABF4D, X : BEQ BRANCH_DUMMA
        
        STA $0D
        
        LDA $0ABF4C, X : STA $0C
        
        LDA.b #$02
        
        BRA BRANCH_EIN
    
    BRANCH_DUMMA:
    
        LDA $1A : LSR #3 : AND.b #$03 : TAX
        
        LDA $0ABF5E, X : STA $0D
        LDA.b #$32     : STA $0C
        
        LDA.b #$00
    
    BRANCH_EIN:
    
        STA $0B
        
        LDX.b #$08
        
        JSR $C51C ; $5451C IN ROM
    
    ; *$5438A ALTERNATE ENTRY POINT
    BRANCH_ZOD:
    
        PLA : STA $7EC10B
        PLA : STA $7EC10A
        PLA : STA $7EC109
        PLA : STA $7EC108
        
        RTS
    }

; ==============================================================================

; *$5439F-$54514 LOCAL
{
    LDA $0636 : BNE BRANCH_ALPHA
    
    REP #$30
    
    LDA $7EC108 : LSR #4 : EOR.w #$FFFF : INC A : ADC $063A : SUB.w #$00C0 : TAX
    
    SEP #$20
    
    LDA $0AC5DA, X : STA $0F
    
    SEP #$30
    
    XBA
    
    LDA.b #$0D
    
    JSR $C56D ; $5456D IN ROM
    JSR $C580 ; $54580 IN ROM
    
    STA $0F
    
    REP #$30
    
    LDA $7EC10A : LSR #4
    
    SEP #$30
    
    SUB.b #$80
    
    PHP : BPL BRANCH_BETA
    
    EOR.b #$FF

BRANCH_BETA:

    PHA
    
    LDA $0F : CMP.b #$E0 : BCC BRANCH_GAMMA
    
    LDA.b #$00

BRANCH_GAMMA:

    XBA
    
    LDA.b #$54
    
    JSR $C56D ; $5456D
    
    XBA : ADD.b #$B2 : XBA
    
    PLA
    
    JSR $C56D ; $5456D IN ROM
    
    XBA
    
    PLP : BCS BRANCH_DELTA
    
    STA $00
    
    LDA #$80 : SUB.b $00
    
    BRA BRANCH_EPSILON

BRANCH_DELTA:

    ADD.b #$80

BRANCH_EPSILON:

    SUB $E0 : STA $0E
    
    LDA $0E : ADD.b #$80 : STA $0E
    LDA $0F : ADD.b #$0C : STA $0F
    
    JMP $C50D ; $5450D IN ROM

BRANCH_ALPHA:

    REP #$30
    
    LDA $7EC108 : LSR #4 : EOR.w #$FFFF : INC A : ADD $063A : SUB.w #$0080 : CMP.w #$0100 : BCC BRANCH_ZETA
    
    JMP $C511 ; $54511 IN ROM

BRANCH_ZETA:

    SEP #$30
    
    XBA
    
    LDA.b #$25
    
    JSR $C56D ; $5456D IN ROM
    JSR $C580 ; $54580 IN ROM
    
    REP #$10
    
    TAX : CPX.w #$014D : BCC BRANCH_THETA
    
    JMP $C511 ; $54511 IN ROM

BRANCH_THETA:

    LDA $0AC5DA, X : STA $0F
    
    REP #$20
    
    LDA $7EC10A : SUB.w #$07F8
    
    ; supposed to be PLP? (check rom)
    PHP

    BPL BRANCH_IOTA
    
    EOR.w #$FFFF : INC A
    
BRANCH_IOTA:

    PHA
    
    SEP #$20
    
    LDA $0F : CMP.b #$E2 : BCC BRANCH_KAPPA
    
    LDA.b #$00

BRANCH_KAPPA:

    XBA
    
    LDA.b #$54
    
    JSR $C56D ; $5456D IN ROM
    
    XBA : ADD.b #$B2 : STA $00 : XBA
    
    PLA
    
    JSR $C56D ; $5456D IN ROM
    
    XBA : STA $01
    
    PLA : XBA
    
    LDA $00
    
    JSR $C56D ; $5456D IN ROM
    
    ADD $01 : XBA : ADC.b #$00 : XBA
    
    PLP : BCS BRANCH_LAMBDA
    
    STA $00

    LDA #$0800 : SUB $00

    BRA BRANCH_MU

BRANCH_LAMBDA:

    ADD.w #$0800

BRANCH_MU:

    SUB.w #$0800 : BCS BRANCH_NU

    EOR #$FFFF : INC A

BRANCH_NU:

    SEP #$20

    PHP

    XBA : PHA

    LDA.b #$2D

    JSR $C56D ; $5456D IN ROM

    XBA : STA $00

    PLA : XBA

    LDA.b #$2D

    JSR $C56D ; $5456D IN ROM

    ADD $00 : XBA : ADC.b #$00 : XBA

    PLP

    BCS BRANCH_XI

    STA $00

    LDA.b #$80 : SUB $00 : XBA : STA $00
    LDA.b #$00 : SBC $00 : XBA
    
    BRA BRANCH_OMICRON

BRANCH_XI:

    ADD.b #$80 : XBA : ADC.b #$00 : XBA

BRANCH_OMICRON:

    PHA : SUB $E0 : STA $0E
    
    PLA
    
    REP #$30
    
    SUB.w #$FF80 : SUB $E0
    
    SEP #$30
    
    XBA : BNE BRANCH_PI
    
    LDA $0E : ADD.b #$81 : STA $0E
    LDA $0F : ADD.b #$10 : STA $0F

; *$5450D ALTERNATE ENTRY POINT

    SEP #$30
    
    SEC
    
    RTS

; *$54511 ALTERNATE ENTRY POINT
BRANCH_PI:

    SEP #$30
    
    CLC
    
    RTS
}

; ==============================================================================

    ; $54515-$5451B DATA?

    ; *$5451C-$5456C LOCAL
    {
        ; alternates on and off every 16 frames
        LDA $1A : LSR #4 : AND.b #$01 : BNE BRANCH_ALPHA
        
        LDA $0D : CMP.b #$64 : BNE BRANCH_ALPHA
        
        ; Since the base of this array starts in code, we deduce that
        ; X must range from 0x08 and 0x0E
        LDA $0AC50D, X : STA $0D
        LDA.b #$32     : STA $0C
        
        STZ $0A20, X
        
        TXA : ASL #2 : TAX
        
        ; Set coordinates of the sprite
        LDA $0E : STA $0800, X
        LDA $0F : STA $0801, X
        
        BRA .finishedWithCoords
    
    BRANCH_ALPHA:
    
        LDA $0B : STA $0A20, X
        
        TXA : ASL #2 : TAX
        
        ; Offset the coordinates of the sprite by -4, vertically and horizontally
        LDA $0E : SUB.b #$04 : STA $0800, X
        LDA $0F : SUB.b #$04 : STA $0801, X
    
    .finishedWithCoords
    
        ; Set CHR, palette, and priority of the sprite
        LDA $0D : STA $0802, X
        LDA $0C : STA $0803, X
        
        RTS
    }

; =============================================
    
    ; *$5456D-$5457F LOCAL
    {
        STA $4202
        
        XBA : STA $4203
        
        NOP #4
        
        LDA $4217 : XBA
        
        LDA $4216
        
        RTS
    }

; =============================================

    ; *$54580-$54588 LOCAL
    {
        REP #$30
        
        LSR #4
        
        SEP #$30
        
        RTS
    }

    ; *$54589-$545A5 LOCAL
    {
        REP #$20
        
        LDA $7EC10A : SUB.w #$0004 : STA $7EC10A
        LDA $7EC108 : SUB.w #$0004 : STA $7EC108
        
        SEP #$20
        
        RTS
    }

    ; $545A6-$545A8 DATA
    db $04, $02, $01

; =============================================

    ; *$545A9-$545BE LOCAL
    Overworldmap_CheckPendant:
    {
        ; X is an input variable to this function
        
        ; check if the sprites indicator tells us to show the three pendants
        LDA $7EF3C7 : CMP.b #$03 : BNE .fail
        
        ; check if we have that pendant
        LDA $7EF374 : AND $0AC5A6, X : BEQ .fail
        
        SEC
        
        RTS
    
    ; *$545BD ALTERNATE ENTRY POINT
    .fail
    
        CLC
        
        RTS
    }

; ==============================================================================
    
    ; $545BF-$545C5 DATA?
    {
        db $02, $40, $08, $20, $01, $04, $10
    }

; ==============================================================================

    ; *$545C6-$545D9 LOCAL
    OverworldMap_CheckCrystal:
    {
        ; Check if the sprite indicator tells us to show all 7 crystals (ones we've yet to obtain)
        LDA $7EF3C7 : CMP.b #$07 : BNE OverworldMap_CheckPendant_fail
        
        ; Check if we have that crystal
        LDA $7EF37A : AND $0AC5BF, X : BEQ OverworldMap_CheckPendant_fail
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; $545DA-$560AF DATA
    {
        ; \task Figure out what this data is and split it up. There's a lot
        ; though! A quick perusal doesn't seem to turn up any code, btw.
    }

; ==============================================================================

    ; *$560B0-$560D1 JUMP LOCATION (LONG)
    Messaging_PalaceMap:
    {
        LDA $0200 ; An index into what type of display to use.
        
        JSL UseImplicitRegIndexedLongJumpTable
        
        dl PalaceMap_Backup         ; Fade to full darkness (amidst other things)
        dl PalaceMap_Init           ; Loading Dungeon Map
        dl PalaceMap_LightenUpMap   ; Fade to full brightness
        dl PalaceMap_3              ; Dungeon map Mode
        dl PalaceMap_4              ;  
        dl PalaceMap_FadeMapToBlack
        dl PalaceMap_RestoreGraphics
        dl PalaceMap_RestoreStarTileState
        dl PalaceMap_LightenUpDungeon
    }

; =============================================

    ; $560D2-$560DB Jump Table
    PalaceMap_InitJumpTable:
    {
        dw PalaceMap_SetupGraphics
        dw PalaceMap_OptionalGraphic
        dw $E1F3 ; = $561F3*
        dw $E384 ; = $56384*
        dw $E823 ; = $56823*
    }

    ; *$560DC-$560E3 JUMP LOCATION (LONG)
    PalaceMap_Init:
    {
        LDA $020D : ASL A : TAX
        
        JMP (PalaceMap_InitJumpTable, X)  ; $560D2 IN ROM
    }

; =============================================

    ; *$560E4-$56159 JUMP LOCATION (LONG)
    PalaceMap_SetupGraphics:
    {
        ; Cache HDMA settings elsewhere and turn off HDMA for the time being.
        LDA $9B : PHA : STZ $420C : STZ $9B
        
        ; Cache graphics settings to temp variables
        LDA $0AA1 : STA $7EC20E
        LDA $0AA3 : STA $7EC20F
        LDA $0AA2 : STA $7EC210
        
        ; Cache bg screen settings to temp variables
        LDA $1C : STA $7EC211
        LDA $1D : STA $7EC212
        
        ; Set a fixed main graphics index
        LDA.b #$20 : STA $0AA1
        
        ; Use the current palace we're in to determine the sprite tileset
        LDA $040C : LSR A : ORA.b #$80 : STA $0AA3
        
        ; Set the auxiliary bg graphics tileset
        LDA.b #$40 : STA $0AA2
        
        ; BG1 on subscreen; BG2, BG3, and OAM on main screen.
        LDA.b #$16 : STA $1C
        LDA.b #$01 : STA $1D
        
        ; Writes blanks to $0000-$1FFF (byte addr) in vram. Clears BG2 tilemap
        JSL Vram_EraseTilemaps_palace ; $33F IN ROM
        
        ; Perform the standard graphics decompression routine
        JSL InitTilesets    ; $619B IN ROM
        
        ; Set special palette index
        LDA.b #$02 : STA $0AA9
        
        ; Load palettes
        JSL Palette_PalaceMapBg     ; $DEE3A IN ROM
        JSL Palette_PalaceMapSpr    ; $DEDDD IN ROM
        
        ; Set another palette index
        LDA.b #$01 : STA $0AB2
        
        ; Load palettes for BG3 (2bpp) graphics
        JSL Palette_Hud ; $DEE52 IN ROM
        
        ; $756C0 IN ROM
        JSL LoadActualGearPalettes
        
        INC $15
        
        INC $020D
        
        PLA : STA $9B
        
        LDA.b #$09 : STA $14
        
        STA $0710
        
        RTL
    }
    
; =============================================

    ; $5615A-$561A3 DATA

; =============================================

    ; *$561A4-$561E0 JUMP LOCATION (LONG)
    PalaceMap_OptionalGraphic:
    {
        PHB : PHK : PLB
        
        ; Load palace index
        LDA $040C : LSR A : TAX
        
        ; guessing this means that there's no special graphic
        ; for this palace.
        LDY $E196, X : BMI .return
        
        LDA.b #$FF : STA $1022
        
        LDX.b #$0E
        
        REP #$20
        
        LDA $E176, Y : STA $1002, X
        LDA $E186, Y : STA $1012, X
        
        SEP #$20
        
        DEX
    
    .copyTiles
    
        LDA $E15A, X : STA $1002, X
        LDA $E168, X : STA $1012, X
        
        DEX : BPL .copyTiles
        
        LDA.b #$01 : STA $14
    
    .return
    
        ; move to next step of submodule
        INC $020D
        
        PLB
        
        RTL
    }

; =============================================

    ; $561E1-$561F2 DATA
    dw $1223, $1263, $12A3, $12E3, $1323, $11E3, $11A3, $1163
    dw $1123

; =============================================

    ; *$561F3-$562E4 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        REP #$30
        
        STZ $1000
        
        LDX $040C : PHX
        
        LDA $F5D9, X
        
        AND.w #$0300 : BEQ .skipTileCopy
        AND.w #$0100 : BEQ .skipTileCopy
        
        LDX.w #$002A : PHX
    
    .copyTiles
    
        LDA $EFDD, X : STA $1000, X
        
        DEX #2 : BNE .copyTiles
        
        PLX
        
        LDA.w #$1123 : STA $00
        
        LDY.w #$0010
    
    .copyTiles2
    
        LDA $00 : XBA : STA $1002, X
        XBA : ADD.w #$0020 : STA $00
        
        LDA.w #$0E40 : STA $1004, X
        LDA.w #$1B2E : STA $1006, X
        
        INX #6
        
        DEY : BNE .copyTiles2
        
        STX $1000
    
    .skipTileCopy
    
        STZ $00
        STZ $02
        
        LDX $040C : LDA $F5D9, X : AND.w #$00FF : CMP.w #$0050 : BCC .notTower
        
        ; Seems to be looking for tower style levels (tower of hera, hyrule castl 2, ganon's tower)
        LSR #4 : SUB.w #$0004 : ASL A : STA $00
        
        BRA .setupVramTarget
    
    .notTower
    
        AND.w #$000F : CMP.w #$0005 : BCC .setupVramTarget
        
        ASL A : STA $00
    
    .setupVramTarget
    
        LDX $00
        
        LDY $1000
        
        LDA $E1E1, X : STA $00 : STA $0E
    
    .limitNotReached
    
        ; store big endian vram target address????
        LDA $00 : XBA : STA $1002, Y
        
        INY #2
        
        ; .... have to look up NMI workings to know what this does.
        LDA.w #$0E40 : STA $1002, Y
        
        INY #2
        
        LDX $02
        
        LDA $EFD1, X : STA $04
        
        ; check bit 13 in palace properties word
        LDX $040C : LDA $F5D9, X : AND.w #$0200 : BEQ .noOffset
        
        LDA $04 : ADD.w #$0400 : STA $04
    
    .noOffset
    
        LDA $04 : STA $1002, Y
        
        INY #2
        
        ; apparently stop incrementing once $02 reaches 0x000C
        LDA $02 : CMP.w #$000C : BEQ .stopIncrementing
        
        INC $02 : INC $02
    
    .stopIncrementing
    
        LDA $00 : ADD.w #$0020 : STA $00 : CMP.w #$1360 : BCC .limitNotReached
        
        ; Tell NMI how large the buffer is as of now
        STY $1000
        
        SEP #$20
        
        PLX
        
        JSR $E2F5 ; $562F5 IN ROM
        
        REP #$10
        
        LDY $1000
        
        LDA.b #$FF : STA $1002, Y
        
        SEP #$10
        
        ; Move to next step of submodule
        INC $020D
        
        LDA.b #$01 : STA $14
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $562E5-$562F4 DATA

; ==============================================================================

    ; *$562F5-$56383 LOCAL
    {
        REP #$20
        
        LDA $F5D9, X : AND.w #$00FF : STA $02
        AND.w #$000F : STA $00
        
        LDA $02 : LSR #4 : ADD $00 : STA $02
        
        LDA $A4 : ADD $00 : AND.w #$00FF : STA $0C
        
        STZ $0A
        
        LDA $0E : SUB.w #$0040 : ADD.w #$0002 : STA $0E
        
        LDX $00 : BEQ BRANCH_ALPHA
        
        LDA $0E
    
    BRANCH_BETA:
    
        ADD.w #$0040
        
        DEX : BNE BRANCH_BETA
        
        STA $0E
    
    BRANCH_ALPHA:
    
        REP #$10
        
        LDY $1000
    
    BRANCH_ZETA:
    
        LDX.w #$0000
        
        LDA $0E
    
    BRANCH_THETA:
    
        XBA : STA $1002, Y
        
        INY #2
        
        LDA.w #$0700 : STA $1002, Y
        
        INY #2
    
    BRANCH_GAMMA:
    
        LDA $E2E5, X : STA $1002, Y
        
        INY #2
        
        INX #2 : CPX.w #$0008 : BCC BRANCH_GAMMA : BEQ BRANCH_DELTA
        
        CPX.w #$0010 : BNE BRANCH_GAMMA
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LDA $0E : ADD.w #$0020
        
        BRA BRANCH_THETA
    
    BRANCH_EPSILON:
    
        LDA $0E : SUB.w #$0040 : STA $0E
        
        INC $0A : LDA $0A : CMP $02 : BMI BRANCH_ZETA
        
        STY $1000
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$56384-$56428 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        STZ $0210
        
        REP #$30
        
        STZ $00 : STZ $02 : STZ $04 : STZ $06
        STZ $08 : STZ $0A : STZ $0C
        
        STZ $0211
        
        LDX $040C
        
        LDA $F5D9, X : AND.w #$000F : EOR.w #$00FF : INC A : AND.w #$00FF : CMP $A4 : BEQ BRANCH_ALPHA
        
        LDA $A4 : AND.w #$00FF : STA $020E
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $A4 : INC A : STA $020E
        
        INC $0211 : INC $0211
    
    BRANCH_BETA:
    
        LDA $020E : AND.w #$0050 : BNE BRANCH_GAMMA
        
        LDA.w #$EFFF : STA $08
        
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA.w #$EFFF : STA $08
    
    BRANCH_DELTA:
    
        JSR $E4F9 ; $564F9 IN ROM
        JSR $E449 ; $56449 IN ROM
        JSR $E579 ; $56579 IN ROM
        
        DEC $020E
        
        REP #$30
        
        LDA.w #$0300 : STA $06
        
        LDA $0211 : BNE BRANCH_EPSILON
        
        BRA BRANCH_EPSILON
    
    BRANCH_EPSILON:
    
        LDA $020E : AND.w #$0050 : BNE BRANCH_ZETA
        
        LDA.w #$EFFF : STA $08
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDA.w #$EFFF : STA $08
    
    BRANCH_THETA:
    
        JSR $E4F9 ; $564F9 IN ROM
        JSR $E449 ; $56449 IN ROM
        JSR $E579 ; $56579 IN ROM
        
        REP #$30
        
        INC $020E
        
        STZ $06
        
        SEP #$30
        
        LDA.b #$08 : STA $17
        
        LDA.b #$22 : STA $0116
        
        INC $020D
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $56429-$56448 DATA
    {
        dw $1F19, $5F19, $9F19, $DF19
        
        dw $00E2, $00F8, $03A2, $03B8
        
        dw $1F1A, $9F1A, $
    }

; ==============================================================================
    
    ; *$56449-$564E8 LOCAL
    {
        REP #$30
        
        STZ $02
    
    BRANCH_ALPHA:
    
        LDY $02 : LDA $E431, Y : ADD $06 : AND.w #$0FFF : TAX
        
        LDA.w #$0F00 : STA $7F0000, X
        
        LDA $E429, Y : AND $08 : STA $7F0000, X
        
        INC $02 : INC $02
        
        LDA $02 : CMP.w #$0008 : BNE BRANCH_ALPHA
        
        LDY.w #$0000
    
    BRANCH_GAMMA:
    
        STZ $02
        
        LDA $E43D, Y : ADD $06 : STA $04
    
    BRANCH_BETA:
    
        LDA $04 : ADD $02 : AND.w #$0FFF : TAX
        
        LDA.w #$0F00 : STA $7F0000, X
        
        LDA $E439, Y : AND $08 : STA $7F0000, X
        
        INC $02 : INC $02 : LDA $02 : CMP.w #$0014 : BNE BRANCH_BETA
        
        INY #2 : CPY.w #$0004 : BNE BRANCH_GAMMA
        
        LDY.w #$0000
    
    BRANCH_EPSILON:
    
        STZ $02
        
        LDA $E445, Y : ADD $06 : STA $04
    
    BRANCH_DELTA:
    
        LDA $04 : ADD $02 : AND.w #$0FFF : TAX
        
        LDA.w #$0F00 : STA $7F0000, X
        
        LDA $E441, Y : AND $08 : STA $7F0000, X
        
        LDA $02 : ADD.w #$0040 : STA $02 : CMP.w #$0280 : BNE BRANCH_DELTA
        
        INY #2 : CPY.w #$0004 : BNE BRANCH_EPSILON
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $564E9-$564F8 DATA

    ; *$564F9-$5656E LOCAL
    {
        REP #$30
        
        LDA.w #$00DE : STA $00
    
    BRANCH_ALPHA:
    
        LDA $00 : ADD $06 : AND.w #$0FFF : TAX
        
        LDA.w #$0F00 : STA $7F0000, X : STA $7F0002, X
        
        LDA $00 : ADD.w #$0040 : STA $00 : CMP.w #$039E : BNE BRANCH_ALPHA
        
        LDA $020E : AND.w #$0080 : BEQ BRANCH_BETA
        
        LDA.w #$1F1C
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        LDA $020E : AND.w #$000F : ASL A : TAY
        
        LDA $E4E9, Y
    
    BRANCH_GAMMA:
    
        PHA
        
        LDA.w #$035E : ADD $06 : AND.w #$0FFF : TAX
        
        PLA : AND $08 : STA $7F0000, X
        
        LDA $020E : AND.w #$0080 : BEQ BRANCH_DELTA
        
        LDA $020E : AND.w #$00FF : EOR.w #$00FF : ASL A : TAY
        
        LDA $E4E9, Y
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LDA.w #$1F1D
    
    BRANCH_EPSILON:
    
        AND $08 : STA $7F0002, X
        
        SEP #$30
        
        RTS
    }

    ; $5656F-$56578 DATA
    {
        dw $0124, $01A4, $0224, $02A4, $0324
    }

    ; *$56579-$56599 LOCAL
    {
        ; Draws a 5x5 floor grid for the map?
        
        REP #$30
        
        STZ $00
    
    .nextRow
    
        LDA $00 : ASL A : TAX
        
        LDA $E56F, X : ADD $06 : AND.w #$0FFF : TAX
        
        JSR $E5BC ; $565BC IN ROM
        
        INC $00
        
        LDA $00 : CMP.w #$0005 : BNE .nextRow
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $5659A-$565BB DATA
    {
        dw $0000, $0005, $000A, $000F, $0014
        
        ; unused?
        dw $0000, $0032, $0064, $0096, $00C8, $00FA, $012C, $015E
        dw $0190, $0300
        
        dw $0B00, $0F00
    }

; ==============================================================================

    ; *$565BC-$567F2 LOCAL
    {
        REP #$30
        
        STZ $02
    
    .nextColumn
    
        STZ $0E
        
        PHX
        
        LDA $00 : ASL A : TAX
        
        ; $04 = column * 5;
        LDA $02 : ADC $E59A, X : STA $04
        
        SEP #$20
        
        LDX $040C
        
        ; I think this is trying to figure out the current floor against
        ; the deepest depth of the current palace.
        LDA $F5D9, X : AND.b #$0F : ADD $020E : ASL A : STA $0E : TAY
        
        REP #$20
        
        ; 
        LDA $F605, X : STA $0C
        
        ; Y = (???? * 0x19) + $04;
        LDA $F5F5, Y : ADD $04 : TAY
        
        SEP #$20
        
        ; 0x0F incdiates a blank room in the map, or so it would seem.
        LDA ($0C), Y : CMP.b #$0F : BNE BRANCH_ALPHA
        
        REP #$20
        
        LDA.w #$0051
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        REP #$20
        
        AND.w #$00FF : STA $CA
        
        ASL A : PHA
        
        LDA $CA : ASL A : TAX
        
        ; $0E = the quadrants Link has visited
        LDA $7EF000, X : AND.w #$000F : STA $0E
        
        PLA
        
        BRA BRANCH_ULTIMA
    
    BRANCH_BETA:
    
        ASL #3 : TAY
        
        BRA BRANCH_GAMMA
    
    BRANCH_ULTIMA:
    
        STZ $C8
        
        LDY.w #$0000
        
        LDX $040C : LDA $F605, X : STA $0C
    
    BRANCH_ALIF:
    
        SEP #$20
        
        LDA ($0C), Y : CMP.b #$0F : BNE BRANCH_OPTIMUS
        
        INY
        
        BRA BRANCH_ALIF
    
    BRANCH_OPTIMUS:
    
        CMP $CA : BEQ BRANCH_BET
        
        INC $C8
        
        INY
        
        BRA BRANCH_ALIF

    BRANCH_BET:

        REP #$20
        
        LDA $FBE4, X : STA $0C
        
        LDA $C8 : TAY
        
        SEP #$20
        
        LDA ($0C), Y
        
        REP #$20
        
        ASL #3 : TAY
    
    BRANCH_GAMMA:
    
        PLX
        
        LDA $F009, Y : STA $0C : PHA : CMP.w #$0B00 : BEQ BRANCH_DELTA
        
        ; Check if top left quadrant has been seen
        LDA $0E : AND.w #$0008 : BNE BRANCH_DELTA
        
        LDA $0C : AND.w #$1000 : BNE BRANCH_EPSILON
        
        LDA.w #$0400 : STA $0C
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        PHX
        
        LDX $040C
        
        ; Check if Link has the map
        LDA $7EF368 : AND $0098C0, X : BEQ BRANCH_DEL
        
        PLX : PLA
        
        LDA $0C : AND.w #$E3FF : ORA.w #$0C00
        
        BRA BRANCH_THEL
    
    BRANCH_DEL:
    
        PLX
    
    BRANCH_DELTA:
    
        STZ $0C
    
    BRANCH_ZETA:
    
        PLA : ADD $0C : PHX : STA $0C
        
        LDX $040C
        
        ; Check if Link has the map
        LDA $7EF368 : AND $0098C0, X : BNE BRANCH_THETA
        
        LDA $0E : AND.w #$0008 : BNE BRANCH_THETA
        
        LDA.w #$0B00
        
        BRA BRANCH_IOTA
    
    BRANCH_THETA:
    
        LDA $0C
    
    BRANCH_IOTA:
    
        PLX
    
    BRANCH_THEL:
    
        STA $7F0000, X
        
        LDA $F00B, Y : STA $0C : PHA : CMP.w #$0B00 : BEQ BRANCH_KAPPA
        
        ; Check if top right quadrant has been seen
        LDA $0E : AND.w #$0004 : BNE BRANCH_KAPPA
        
        LDA $0C : AND.w #$1000 : BNE BRANCH_LAMBDA
        
        LDA.w #$0400 : STA $0C
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA:
    
        PHX
    
        LDX $040C
        
        ; Check if Link has the map
        LDA $7EF368 : AND $0098C0, X : BEQ BRANCH_SIN
        
        PLX : PLA
        
        LDA $0C : AND.w #$E3FF : ORA.w #$0C00
        
        BRA BRANCH_SHIN
    
    BRANCH_SIN:
    
        PLX
    
    BRANCH_KAPPA:
    
        STZ $0C
    
    BRANCH_MU:
    
        ; damn PHX in the middle... whatever. But it's an eyesore.
        PLA : ADD $0C : PHX : STA $0C
        
        LDX $040C
        
        ; check if we have the map for this dungeon
        LDA $7EF368 : AND $0098C0, X : BNE BRANCH_NU
        
        LDA $0E : AND.w #$0004 : BNE BRANCH_NU
        
        LDA.w #$0B00
        
        BRA BRANCH_XI
    
    BRANCH_NU:
    
        LDA $0C
    
    BRANCH_XI:
    
        PLX
    
    BRANCH_SHIN:
    
        STA $7F0002, X
        
        LDA $F00D, Y : STA $0C : PHA : CMP.w #$0B00 : BEQ BRANCH_OMICRON
        
        LDA $0E : AND.w #$0002 : BNE BRANCH_OMICRON
        
        LDA $0C : AND.w #$1000 : BNE BRANCH_PI
        
        LDA.w #$0400 : STA $0C
        
        BRA BRANCH_RHO
    
    BRANCH_PI:
    
        PHX
        
        LDX $040C
        
        ; Check if we have the map... again
        LDA $7EF368 : AND $0098C0, X : BEQ BRANCH_SOD
        
        PLX : PLA
        
        LDA $0C : AND.w #$E3FF : ORA.w #$0C00
        
        BRA BRANCH_DOD
    
    BRANCH_SOD:
    
        PLX
    
    BRANCH_OMICRON:
    
        STZ $0C
    
    BRANCH_RHO:
    
        PLA : ADD $0C : PHX : STA $0C
        
        LDX $040C
        
        LDA $7EF368 : AND $0098C0, X : BNE BRANCH_SIGMA
        
        LDA $0E : AND.w #$0002 : BNE BRANCH_SIGMA
        
        LDA.w #$0B00
        
        BRA BRANCH_TAU
    
    BRANCH_SIGMA:
    
        LDA $0C
    
    BRANCH_TAU:
    
        PLX
    
    BRANCH_DOD:
    
        STA $7F0040, X
        
        LDA $F00F, Y : STA $0C : PHA : CMP.w #$0B00 : BEQ BRANCH_UPSILON
        
        LDA $0E : AND.w #$0001 : BNE BRANCH_UPSILON
        
        LDA $0C : AND.w #$1000 : BNE BRANCH_PHI
        
        LDA #$0400 : STA $0C
        
        BRA BRANCH_CHI
    
    BRANCH_PHI:
    
        PHX
        
        LDX $040C
        
        ; Check if Link has the map
        LDA $7EF368 : AND $0098C0, X : BEQ BRANCH_TOD
        
        PLX : PLA
        
        LDA $0C : AND.w #$E3FF : ORA.w #$0C00
        
        BRA BRANCH_ZOD
    
    BRANCH_TOD:
    
        PLX
    
    BRANCH_UPSILON:
    
        STZ $0C
    
    BRANCH_CHI:
    
        PLA : ADD $0C : PHX : STA $0C
    
        LDX $040C
        
        ; Check if Link has the map
        LDA $7EF368 : AND $0098C0, X : BNE BRANCH_PSI
        
        LDA $0E : AND.w #$0001 : BNE BRANCH_PSI
        
        LDA.w #$0B00
        
        BRA BRANCH_OMEGA
    
    BRANCH_PSI:
    
        LDA $0C
    
    BRANCH_OMEGA:
    
        PLX
    
    BRANCH_ZOD:
    
        STA $7F0042, X
        
        INX #4
        
        INC $02
        
        LDA $02 : CMP.w #$0005 : BEQ BRANCH_ALTIMA
        
        JMP .nextColumn
    
    BRANCH_ALTIMA:
    
        RTS
    }

; ==============================================================================

    ; $567F3-$56822 DATA

    ; *$56823-$56953 JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        REP #$10
        
        LDA.b #$00 : XBA
        
        LDX $040C : LDA $F5D9, X : AND.b #$0F : ADD $A4 : ASL A : TAY : STY $0C
        
        REP #$20
        
        STZ $00 : STZ $02
        
        PHY
        
        LDY $E805
        
        ; This loop is searching for rooms that you can fall into that are out
        ; of the way (secret locations you can get to by falling through
        ; pots in the Tower of Hera or Eastern Palace.
        LDA $A0
    
    .secretRoomLoop
    
        CMP $E7F9, Y : BEQ .isSecretRoom
        
        DEY #2 : BPL .secretRoomLoop
        
        BRA .notSecretRoom
    
    .isSecretRoom
    
        ; Substitute a different room to use in the case that we're in a secret
        ; room.
        LDA $E7FF, Y
    
    .notSecretRoom
    
        STA $0E
        
        PLY
        
        LDA $F605, X : STA $04
        
        LDA $F5F5, Y : TAY
        
        SEP #$20
    
    ; This loop tries to locate the current (or substituted) room in the
    ; palace's map data.
    BRANCH_ZETA:
    
        LDA ($04), Y : INY : CMP $0E : BEQ BRANCH_DELTA
        
        LDA $00 : CMP.b #$40 : BCC BRANCH_EPSILON
        
        STZ $00
        
        LDA $02 : ADD.b #$10 : STA $02
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        ADD.b #$10 : STA $00
        
        BRA BRANCH_ZETA
    
    BRANCH_DELTA:
    
        REP #$20
        
        LDA $00 : ADD $E7F7 : STA $0215
        
        LDA $22 : AND.w #$01E0 : ASL #3 : XBA : ADD $0215 : STA $0215
        
        LDY $0211
        
        LDA $02       : STA $0CF5
        ADD $E7F3, Y : STA $0217
        
        LDA $20 : AND.w #$01E0 : ASL #3 : XBA : ADD $0217 : STA $0217
        
        SEP #$20
        
        LDA.b #$00 : XBA
        
        LDA $F5D9, X : AND.b #$0F : ADD $EE79, X
        
        REP #$20
        
        ASL A : TAY
        
        LDA $F605, X : ADD $F5F5, Y : STA $0E
        
        SEP #$20
        
        LDA.b #$40 : STA $0FA8 : STZ $0FA9
                     STA $0FAA : STZ $0FAB
        
        LDY.w #$0018
    
    BRANCH_LAMBDA:
    
        LDA ($0E), Y : CMP.b #$0F : BEQ BRANCH_THETA
        
        CMP $E807, X : BEQ BRANCH_IOTA
    
    BRANCH_THETA:
    
        LDA $0FA8 : SUB.b #$10 : STA $0FA8 : BPL BRANCH_KAPPA
        
        LDA.b #$40 : STA $0FA8
        
        LDA $0FAA : SUB.b #$10 : STA $0FAA
    
    BRANCH_KAPPA:
    
        DEY : BPL BRANCH_LAMBDA
    
    BRANCH_IOTA:
    
        STZ $02
        STZ $0F
        
        LDA $020E : SUB $EE79, X : STA $0E : BPL BRANCH_MU
        
        EOR.b #$FF : INC A : STA $0E
        
        INC $02 : INC $02
    
    BRANCH_MU:
    
        SEP #$10
        
        LDY $02
        
        REP #$20
    
    BRANCH_XI:
    
        DEC $0E : BMI BRANCH_NU
        
        LDA $0FAA : ADD $E975, Y : STA $0FAA
        
        BRA BRANCH_XI
    
    BRANCH_NU:
    
        LDA $0FAA : ADD $E7F3 : STA $0FAA
        
        SEP #$20
        
        INC $0200
        
        STZ $13
        STZ $020D
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$56954-$5695A JUMP LOCATION
    PalaceMap_3:
    {
        JSL $0AE95B ; $5695B IN ROM
        JMP $EAB2   ; $56AB2 IN ROM
    }

; ==============================================================================

    ; *$5695B-$56974 LONG
    {
        PHB : PHK : PLB
        
        ; Unless the depressed button is X, continue.
        LDA $F6 : AND.b #$40 : BNE .exitPalaceMapMode
        
        JSL $0AE979 ; $56979 IN ROM
        
        PLB
        
        RTL
    
    .exitPalaceMapMode
    
    ; in this case, we need come out of map mode
    
        INC $0200 : INC $0200
        
        STZ $020D
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $56975-$56978 DATA
    {
        dw $0060, $FFA0
    }

    ; *$56979-$56985 LONG
    {
        JSL $0AE986 ; $56986 IN ROM
        
        LDA $0210 : BEQ .notScrolling
        
        JMP PalaceMap_Scroll
    
    .notScrolling
    
        RTL
    }

; ==============================================================================

    ; *$56986-$56A76 LONG
    {
        REP #$30
        
        LDX $040C : LDA $F5D9, X : AND.w #$00F0 : LSR #4 : STA $00
        
        LDA $F5D9, X : AND.w #$000F : ADD $00 : CMP.w #$0003 : BMI BRANCH_ALPHA
        
        SEP #$30
        
        LDA $0210 : BNE BRANCH_ALPHA
        
        ; BYSTudlr -> ----ud--
        LDA $F0 : AND.b #$0C : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        JMP $EA75 ; $56A75 IN ROM
    
    BRANCH_BETA:
    
        STA $0A
        
        STZ $020F
        
        AND.b #$08 : BEQ BRANCH_GAMMA
        
        REP #$30
        
        LDX $040C : LDA $F5D9, X : AND.w #$00F0 : LSR #4 : DEC A : CMP $020E : BNE BRANCH_DELTA
        
        JMP $EA75 ; $56A75 IN ROM
    
    BRANCH_DELTA:
    
        INC $020E
        
        LDA $06 : SUB.w #$0300 : AND.w #$0FFF : STA $06
        
        BRA BRANCH_EPSILON
    
    BRANCH_GAMMA:
    
        REP #$30
        
        LDX $040C : LDA $F5D9, X : AND.w #$000F : EOR.w #$00FF : INC #2 : AND.w #$00FF : CMP $020E : BEQ BRANCH_MU
        
        DEC $020E : DEC $020E
        
        LDA $06 : ADD.w #$0600 : AND.w #$0FFF : STA $06
    
    BRANCH_EPSILON:
    
        SEP #$20
        
        LDA $020E : CMP $A4 : BNE BRANCH_ZETA
        
        REP #$20
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        BMI BRANCH_NU
        
        REP #$20
        
        BRA BRANCH_THETA
    
    BRANCH_NU:
    
        REP #$20
    
    BRANCH_THETA:
    
        LDA $020E : AND.w #$0080 : BNE BRANCH_IOTA
        
        LDA.w #$EFFF : STA $08
        
        BRA BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        LDA.w #$EFFF : STA $08
    
    BRANCH_KAPPA:
    
        SEP #$20
        
        JSR $E4F9 ; $564F9 IN ROM
        JSR $E449 ; $56449 IN ROM
        JSR $E579 ; $56579 IN ROM
        
        SEP #$20
        
        INC $0210
        
        LDA $0A : AND.b #$08 : LSR #2 : TAX
        
        REP #$30
        
        LDA $E8 : ADD $E975, X : STA $0213
        
        LDA $0A : AND.w #$0008 : BNE BRANCH_LAMBDA
        
        LDA $06 : SUB.w #$0300 : AND.w #$0FFF : STA $06
        
        INC $020E
    
    BRANCH_LAMBDA:
    
        SEP #$20
        
        LDA.b #$08 : STA $17
    
    ; *$56A75 ALTERNATE ENTRY POINT
    BRANCH_MU:
    
        BRA BRANCH_$56AAF
    }

; ==============================================================================

    ; $56A77-$56A7E DATA
    {
        dw 4, -4
        
    ; $56A7B
        
        dw -4, 4
    }

; ==============================================================================

    ; *$56A7F-$56AB1 JUMP LOCATION (LONG)
    PalaceMap_Scroll:
    {
        REP #$30
        
        ; $0A is direction?
        LDA $0A : AND.w #$0008 : LSR #2 : TAX
        
        LDA $0217 : ADD $EA7B, X : STA $0217
        LDA $0FAA : ADD $EA7B, X : STA $0FAA
        
        LDA $E8 : ADD $EA77, X : STA $E8 : CMP $0213 : BNE .notDoneScrolling
        
        SEP #$20
        
        STZ $0210
    
    ; *$56AAF ALTERNATE ENTRY POINT
    .notDoneScrolling
    .easyOut
    
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$56AB2-$56AED JUMP LOCATION (LONG)
    {
        PHB : PHK : PLB
        
        REP #$10
        
        LDX $040C : LDA $F5D9, X : AND.b #$0F : STA $02
        
        ADD $A4 : STA $01 : STA $03
        
        SEP #$10
        
        STZ $00
        STZ $0E
        
        JSR PalaceMap_DrawPlayerFloorIndicator
        
        INC $00
    
    BRANCH_ALPHA:
    
        JSR $EBA8 ; $56BA8 IN ROM
        
        INC $0E
        
        LDA $00 : CMP.b #$09 : BNE BRANCH_ALPHA
        
        JSR $EB50 ; $56B50 IN ROM
        
        INC $00
        
        JSR $EDE4 ; $56DE4 IN ROM
        JSR $EC0A ; $56C0A IN ROM
        JSR $ECCF ; $56CCF IN ROM
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $56AEE-$56AEE DATA
    pool PalaceMap_DrawPlayerFloorIndicator:
    {
    
    .x_offset
        db $19
    }
    
; ==============================================================================

    ; $56AEF-$56AEF DATA
    pool PalaceMap_DrawBossFloorIndicator:
    {
    
    .x_offset
        db $4C
    }
    
; ==============================================================================

    ; *$56AF0-$56B3F LOCAL
    PalaceMap_DrawPlayerFloorIndicator:
    {
        REP #$10
        
        LDA.b #$04 : SUB $02 : BMI BRANCH_ALPHA
        
        ADD $03 : STA $03
        
        LDA $F5D9, X : LSR #4 : SUB.b #$04 : BMI BRANCH_ALPHA
        
        SUB $03 : EOR.b #$FF : INC A : STA $03
    
    BRANCH_ALPHA:
    
        SEP #$10
        
        LDX $00
        
        LDA #$02 : STA $0A20, X
        
        TXA : ASL #2 : TAX
        
        LDA .x_offset : STA $0800, X
        
        LDY $03
        
        LDA $ECBE, Y : SUB.b #$04 : STA $0801, X
        STZ $0802, X
        
        LDA.b #$3E
        
        LDY $0ABD : BEQ .playerPaletteSwapped
        
        LDA.b #$30
    
    .playerPaletteSwapped
    
        STA $0803, X
        
        RTS
    }

; ==============================================================================

    ; $56B40-$56B4F DATA
    {
    
        ; \task Fill in data and apply labels.
    }

; ==============================================================================

    ; *$56B50-$56B89 LOCAL
    {
        LDX $00
        
        LDA.b #$00 : STA $0A20, X
        
        TXA : ASL #2 : TAX
        
        LDA $0215 : SUB.b #$03 : STA $0800, X
        
        LDA $0218 : BEQ BRANCH_ALPHA
        
        LDA.b #$F0 : BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $0217
    
    BRANCH_BETA:
    
        SUB.b #$03 : STA $0801, X
        
        LDA $1A : AND.b #$0C : LSR #2 : TAY
        
        LDA $EB40    : STA $0802, X
        LDA $EB48, Y : STA $0803, X
        
        RTS
    }

; $56B8A-$56BA7 DATA

    ; *$56BA8-$56C09 LOCAL
    {
        LDY.b #$03
    
    BRANCH_BETA:
    
        LDA $00 : TAX
        
        LDA.b #$02 : STA $0A20, X
        
        TXA : ASL #2 : TAX
        
        LDA $0215 : AND.b #$F0 : ADD $EB8A, Y : STA $0800, X
        
        PHY
        
        LDA $0E : ASL A : TAY
        
        LDA $0CF5 : ADD $E7F3, Y : STA $0F
        
        PLY
        
        ADD $EB8E, Y : STA $0801, X
        
        STZ $0802, X
        
        LDA $EB92, Y : STA $0C 
        
        PHY
        
        LDA $1A : LSR #2 : AND.b #$01 : TAY
        
        INC $0F
        
        LDA $0217 : INC A : AND.b #$F0 : CMP $0F : BNE BRANCH_ALPHA
        
        LDA $0218 : BNE BRANCH_ALPHA
        
        INY #2
    
    BRANCH_ALPHA:
    
        LDA $0C : ORA $EB96, Y : STA $0803, X
        
        PLY
        
        INC $00
        
        DEY : BPL BRANCH_BETA
        
        RTS
    }

    ; *$56C0A-$56CBD LOCAL
    {
        REP #$10
        
        LDX $040C : LDA $F5D9, X : PHA : LSR #4 : STA $02
        
        PLA : AND.b #$0F : STA $03
        
        SEP #$10
        
        LDY.b #$07
        
        LDA $02 : ADD $03 : CMP.b #$08 : BEQ BRANCH_ALPHA
        
        LDA $02 : CMP.b #$04 : BPL BRANCH_ALPHA
        
        DEY
        
        LDX.b #$03 : STX $04
    
    BRANCH_GAMMA:
    
        CMP $04 : BEQ BRANCH_BETA
        
        DEY
        
        DEC $04 : BNE BRANCH_GAMMA
    
    BRANCH_BETA:
    
        LDA $03 : CMP.b #$05 : BMI BRANCH_ALPHA
        
        LDX.b #$05 : STX $04
    
    BRANCH_DELTA:
    
        CMP $04 : BEQ BRANCH_ALPHA
        
        INY
        
        INC $04
        
        CMP.b #$08 : BNE BRANCH_DELTA
    
    BRANCH_ALPHA:
    
        LDA $ECBE, Y : INC A : STA $04
        
        DEC $02
        
        LDA $03 : EOR.b #$FF : INC A : STA $03
    
    BRANCH_THETA:
    
        LDX $00
        
        LDA.b #$00 : STA $0A20, X : STA $0A21, X
        
        TXA : ASL #2 : TAX
        
        LDA.b #$30 : STA $0800, X
        LDA.b #$38 : STA $0804, X
        
        LDA $04 : STA $0801, X : STA $0805, X
        
        ADD.b #$10 : STA $04
        
        LDA.b #$3D : STA $0803, X : STA $0807, X
        LDA.b #$1C : STA $0802, X
        LDA.b #$1D : STA $0806, X
        
        LDY $02 : BMI BRANCH_EPSILON
        
        LDA $ECC6, Y : STA $0802, X
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        TYA : EOR.b #$FF : TAY
        
        LDA $ECC6, Y : STA $0806, X
    
    BRANCH_ZETA:
    
        INC $00 : INC $00
        
        DEC $02
        
        LDA $02 : INC A : CMP $03 : BNE BRANCH_THETA
        
        RTS
    }

; $56CBE-$56CCE DATA

    ; *$56CCF-$56D4D LOCAL
    {
        LDA $00 : STA $05
        
        LDA $020E : STA $03
        
        LDY.b #$00
        
        REP #$10
        
        LDX $040C : LDA $F5D9, X : LSR #4 : STA $02
        
        LDA $F5D9, X : AND.b #$0F
        
        SEP #$10
        
        ADD $02 : CMP.b #$01 : BEQ BRANCH_ALPHA
        
        INC $05 : INC $05
        DEC $03
        
        LDY.b #$01

    BRANCH_ALPHA:

        STY $02

    BRANCH_DELTA:

        LDX $02 : LDA $ECCE : STA $0E, X
        
        REP #$10
        
        LDX $040C : LDA $F5D9, X : AND.b #$0F : STA $01
        ADD $03 : STA $00
        
        LDA.b #$04 : SUB $01 : BMI BRANCH_BETA
        
        ADD $00 : STA $00
        
        LDA $F5D9, X : LSR #4 : SUB.b #$04 : BMI BRANCH_BETA
        
        SUB $00 : EOR.b #$FF : INC A : STA $00

    BRANCH_BETA:

        SEP #$10
        
        DEC $05 : DEC $05
        
        INC $03
        
        DEC $02 : BMI BRANCH_GAMMA
        
        BRL BRANCH_DELTA

    BRANCH_GAMMA:

        LDA $1A : AND.b #$10 : BNE BRANCH_$56D54
        
        RTS
    }

    ; $56D4E-$56D53 DATA

    ; *$56D54-$56DE3 BRANCH LOCATION
    {
        LDY $00 : LDA $ECBE, Y : SUB.b #$04 : STA $02
        ADD.b #$10 : STA $03
        
        LDY.b #$00
        
        REP #$10
        
        LDX $040C : LDA $F5D9, X : LSR #4 : STA $0D
        
        LDA $F5D9, X : AND.b #$0F 
        
        SEP #$10
        
        ADD $0D : CMP.b #$01 : BEQ BRANCH_ALPHA
        
        LDY.b #$01
    
    BRANCH_ALPHA:
    
        STY $0D
    
    BRANCH_DELTA:
    
        LDA.b #$28 : STA $01
        LDA.b #$03 : STA $0C
        
        LDX $0D : LDA $ED4E, X : TAY
    
    BRANCH_GAMMA:
    
        LDA.b #$00 : STA $0A60, Y : STA $0A64, Y
        
        PHY
        
        TYA : ASL #2 : TAY
        
        LDA $01 : STA $0900, Y : STA $0910, Y
        LDA $02, X : STA $0901, Y : ADD.b #$08 : STA $0911, Y
        
        PHX
        
        LDX $0C : LDA $ED50, X : STA $0902, Y : STA $0912, Y
        
        PLX : PHY
        
        LDA $0E, X
        
        LDY $0C : BNE BRANCH_BETA
        
        ORA.b #$40
    
    BRANCH_BETA:
    
        PLY
        
        STA $0903, Y
        
        ORA.b #$80 : STA $0913, Y
        
        PLY : INY
        
        LDA $01 : ADD.b #$08 : STA $01
        
        DEC $0C : BPL BRANCH_GAMMA
        
        DEC $0D : BPL BRANCH_DELTA
        
        RTS
    }

    ; *$56DE4-$56E5A LOCAL
    {
        REP #$10
        
        ; Load palace index
        LDX $040C
        
        REP #$20
        
        PHX
        
        ; X = boss room of the palace
        LDA $E807, X : ASL A : TAX
        
        SEP #$20
        
        ; Check if the boss of the palace has been beaten
        LDA $7EF001, X : PLX : AND.b #$08 : BNE .dontShowBossIcon
        
        REP #$20
        
        ; Check if we have the compass for this palace
        LDA $7EF364 : AND $0098C0, X : SEP #$20 : BEQ .dontShowBossIcon
        
        LDA $EE7A, X : BPL .palaceHasBoss
    
    .dontShowBossIcon
    
        SEP #$10
        
        RTS
    
    .palaceHasBoss
    
        PHX
        
        JSR PalaceMap_DrawBossFloorIndicator
        
        PLX
        
        SEP #$10
        
        LDA $1A : AND.b #$0F : CMP.b #$0A : BCS BRANCH_GAMMA
        
        LDY $00
        
        LDA.b #$00 : STA $0A20, Y
        
        TYA : ASL #2 : TAY
        
        LDA $EE5E, X : ADD $0FA8 : ADD.b #$90 : STA $0800, Y
        
        LDA $0FAB : BEQ BRANCH_DELTA
        
        LDA.b #$F0
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LDA $EE5D, X : ADD $0FAA
    
    BRANCH_EPSILON:
    
                    STA $0801, Y
        LDA $EE5B : STA $0802, Y
        LDA $EE5C : STA $0803, Y
        
        INC $00
    
    BRANCH_GAMMA:
    
        RTS
    }

; ==============================================================================

    ; $56E5B-$56E94 DATA
    {
        db $31
        
    ; $56E5C
        
        db $33
        
    ; $56E5D
    
        db $FF, $FF
        db $FF, $FF
        db $08, $08
        db $00, $08
        db $00, $00
        db $00, $08
        db $08, $08
        db $00, $08
        
        db $08, $08
        db $08, $00
        db $04, $04
        db $08, $08
        db $00, $08
        db $00, $08
    
    ; $56E79
    
        db $FF, $FF
        db $FF, $FF
        db $01, $00
        db $01, $00
        db $06, $00
        db $FF, $00
        db $FF, $00
        db $FF, $00
        
        db $FE, $00
        db $F9, $00
        db $05, $00
        db $FF, $00
        db $FD, $00
        db $06, $00
    }

; ==============================================================================

    ; *$56E95-$56EF5 LOCAL
    PalaceMap_DrawBossFloorIndicator:
    {
        LDA $F5D9, X : AND.b #$0F : STA $02 : ADD $EE79, X : STA $03
        
        LDA.b #$04 : SUB $02 : BMI BRANCH_ALPHA
        
        ADD $03 : STA $03
        
        LDA $F5D9, X : LSR #4 : SUB.b #$04 : BMI BRANCH_ALPHA
        
        SUB $03 : EOR.b #$FF : INC A : STA $03
    
    BRANCH_ALPHA:
    
        SEP #$10
        
        LDA $1A : AND.b #$0F : CMP.b #$0A : BCS BRANCH_BETA
        
        LDX $00 : LDA.b #$00 : STA $0A20, X
        
        TXA : ASL #2 : TAX
        
        LDA .x_offset : STA $0800, X
        
        LDY $03
        
        LDA $ECBE, Y : STA $0801, X
        
        LDA $EE5B : STA $0802, X
        LDA $EE5C : STA $0803, X
        
        INC $00
    
    BRANCH_BETA:
    
        REP #$10
        
        RTS
    }

; =======================================================

    ; *$56EF6-$56F18 JUMP LOCATION (LONG)
    PalaceMap_4:
    {
        ; Is this ever used?
        
        REP #$30
        
        LDA $0213 : ADD $E8 : STA $E8
        
        LDA $0213 : EOR.w #$FFFF : INC A : ADD $0217 : STA $0217
        
        SEP #$30
        
        DEC $0205 : BNE .alpha
        
        ; Go back to previous mode.
        DEC $0200
    
    .alpha
    
        RTL
    }

; =======================================================

    ; *$56F19-$56FC8 JUMP LOCATION (LONG)
    PalaceMap_RestoreGraphics:
    {
        LDA $9B : PHA
        
        STZ $420C
        STZ $9B
        
        JSL Vram_EraseTilemaps.normal
        
        ; Restore main screen designation
        LDA $7EC211 : STA $1C
        
        ; assembler problem much?
        ; (compiled as long address when only a direct page access was necessary)
        LDA $7EC212 : STA $00001D
        
        ; Restore graphics tileset indices
        LDA $7EC20E : STA $0AA1
        LDA $7EC20F : STA $0AA3
        LDA $7EC210 : STA $0AA2
        
        ; Restore graphic from the mode we came from
        JSL InitTilesets ; $619B IN ROM
        
        ; Begin ignoring any special palette loads
        STZ $0AA9
        STZ $0AB2
        
        JSL HUD.RebuildLong2
        
        STZ $0418
        STZ $045C
    
    .drawQuadrants
    
        JSL $0091C4 ; $11C4 IN ROM
        JSL $0090E3 ; $10E3 IN ROM
        JSL $00913F ; $113F IN ROM
        JSL $0090E3 ; $10E3 IN ROM
        
        LDA $045C : CMP.b #$10 : BNE .drawQuadrants
        
        STZ $17
        STZ $B0
        
        PLA : STA $9B
        
        REP #$20
        
        LDX.b #$00
    
    .restorePaletteBuffer
    
        LDA $7FDD80, X : STA $7EC500, X
        LDA $7FDE00, X : STA $7EC580, X
        LDA $7FDE80, X : STA $7EC600, X
        LDA $7FDF00, X : STA $7EC680, X
        
        INX #2 : CPX.b #$80 : BNE .restorePaletteBuffer
        
        SEP #$20
        
        LDA $7EC017 : TSB $9C : TSB $9D : TSB $9E
        
        ; Play sound effect indicating we're coming out of map mode.
        LDA.b #$10 : STA $012F
        
        ; Bring volume back to full
        LDA #$F3 : STA $012C
        
        JSL $0297B2 ; $117B2 IN ROM
        
        ; Refresh cgram this frame.
        INC $15
        
        ; Move to next step of the submodule
        INC $0200
        
        STZ $13
        STZ $0710
        
        RTL
    }

; =============================================

    ; *$56FC9-$56FD0 JUMP LOCATION (LONG)
    PalaceMap_RestoreStarTileState:
    {
        JSL Dungeon_RestoreStarTileChr
        
        INC $0200
        
        RTL
    } 

; ==============================================================================
    
    ; $56FD1-$57D0B DATA

; ==============================================================================

    ; $575D9 DATA
    {
        dw $0021, $0023, $0020, $0021, $0070, $0012, $0011, $0212
        dw $0002, $0217, $0160, $0012, $0113, $0171
        
    ; $575F5
        
        dw $0000, $0019, $0032, $004B, $0064, $007D, $0096, $00AF
        
    ; $57605
        
        ; Quick note, all of these pointers seem to be a multiple of 25 bytes
        ; apart...
        db $F621, $F66C, $F6E9, $F71B, $F766, $F815, $F860, $F892
        db $F8DD, $F90F, $F9D7, $FA6D, $FAB8, $FB1C
    
    ; $57621
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $11, $0F, $0F
        db $0F, $0F, $21, $22, $0F
        db $0F, $0F, $0F, $32, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $02, $0F, $0F
        db $0F, $0F, $12, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $42, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $41, $0F
    
    ; $5766C
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $80, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F

        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $70, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $71, $72, $0F, $0F
        db $0F, $81, $82, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $50, $01, $52, $0F
        db $0F, $60, $61, $62, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $51, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $576E9
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $99, $0F, $0F
        db $0F, $A8, $A9, $AA, $0F
        db $0F, $B8, $B9, $BA, $0F
        db $0F, $0F, $C9, $0F, $0F
        
        db $C8, $0F, $0F, $0F, $0F
        db $D8, $D9, $DA, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $5771B
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $73, $74, $75, $0F
        db $0F, $83, $84, $85, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $63, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $33, $0F, $0F
        db $0F, $0F, $43, $0F, $0F
        db $0F, $0F, $53, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $57766
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $E0, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $D0, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $C0, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $B0, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $40, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $20, $0F, $0F
        db $0F, $0F, $30, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $57815
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $66, $0F, $0F
        db $0F, $0F, $76, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $06, $0F, $0F
        db $0F, $0F, $16, $0F, $0F
        db $0F, $0F, $26, $0F, $0F
        db $34, $35, $36, $37, $38
        db $0F, $0F, $46, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $54, $0F, $0F, $0F, $28
        db $0F, $0F, $0F, $0F, $0F
        
    ; $57860
        
        db $0F, $0F, $5A, $0F, $0F
        db $0F, $0F, $6A, $0B, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0A, $3B, $0F
        db $0F, $0F, $09, $4B, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $19, $1A, $1B, $0F
        db $0F, $0F, $2A, $2B, $0F
        db $0F, $0F, $3A, $0F, $0F
        db $0F, $0F, $4A, $0F, $0F
        
    ; $57892
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $91, $92, $93, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $90, $0F, $0F, $0F
        db $0F, $A0, $A1, $A2, $A3
        db $0F, $0F, $B1, $B2, $B3
        db $0F, $0F, $C1, $C2, $C3
        db $0F, $0F, $D1, $D2, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $97, $98, $0F
        
    ; $578DD
        
        db $29, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $39, $0F, $0F, $0F, $0F
        db $49, $0F, $0F, $0F, $0F
        db $59, $0F, $0F, $0F, $0F
        db $0F, $56, $57, $58, $0F
        db $0F, $0F, $67, $68, $0F
        
    ; $5790F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $DE, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $BE, $BF, $0F
        db $0F, $0F, $CE, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $9E, $9F, $0F
        db $0F, $0F, $AE, $AF, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $7E, $7F, $0F
        db $0F, $0F, $8E, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $5E, $5F, $0F
        db $0F, $0F, $6E, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $3E, $3F, $0F
        db $0F, $0F, $4E, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $1E, $1F, $0F
        db $0F, $0F, $2E, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0E, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $579D7
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $87, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $77, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $31, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $27, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $17, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $07, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $57A6D
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $44, $45, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $AB, $AC, $0F, $0F
        db $0F, $BB, $BC, $0F, $0F
        db $0F, $CB, $CC, $0F, $0F
        db $0F, $DB, $DC, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $64, $65, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
    ; $57AB8
        
        db $0F, $A4, $0F, $0F, $0F
        db $0F, $B4, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $B5, $0F, $0F
        db $0F, $C4, $C5, $0F, $0F
        db $0F, $0F, $D5, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $04, $0F, $0F
        db $0F, $13, $14, $15, $0F
        db $0F, $23, $24, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $B6, $B7
        db $0F, $0F, $0F, $C6, $C7
        db $0F, $0F, $0F, $D6, $0F
        
    ; $57B1C
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $1C, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $7B, $7C, $7D, $0F
        db $0F, $8B, $8C, $8D, $0F
        db $0F, $9B, $9C, $9D, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0C, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $5B, $5C, $0F
        db $0F, $0F, $6B, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $5D, $0F
        db $0F, $0F, $6C, $6D, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $95, $96, $0F
        db $0F, $0F, $A5, $A6, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $3D, $0F
        db $0F, $0F, $4C, $4D, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0D, $0F, $0F
        db $0F, $0F, $1D, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
        db $0F, $0F, $0F, $0F, $0F
    }

    ; I'm tentatively assuming this is chest data for the maps
    ; (i.e. a listing of references to chest numbers),
    ; but so far it's inconclusive.
    ; $57BE4
    {
        dw $FC00, $FC08, $FC15, $FC21, $FC2B, $FC32, $FC3F, $FC4D
        dw $FC5F, $FC68, $FC7D, $FC83, $FC8F, $FCA0
        
    ; $57C00
    {
        db $00, $01, $02, $03, $04, $05, $06, $07
        
    ; $57C08
        
        db $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
        db $10, $11, $12, $13, $14
        
    ; $57C15
        
        db $15, $16, $17, $18, $19, $1A, $1B, $1C
        db $1D, $1E, $1F, $20
        
    ; $57C21
        
        db $22, $23, $24, $25, $26, $27, $21, $28
        db $29, $2A
        
    ; $57C2B
        
        db $2B, $2C, $2C, $2D, $2E, $2F, $30
        
    ; $57C32
        
        db $31, $32, $33, $34, $35, $36, $37, $38
        db $39, $3A, $3B, $3C, $3D
        
    ; $57C3F
        
        db $3E, $3F, $40, $41, $42, $43, $44, $45
        db $46, $47, $48, $49, $4A, $4B
        
    ; $57C4D
        
        db $4E, $4F, $50, $52, $53, $54, $55, $56
        db $57, $58, $59, $5A, $5B, $5C, $5D, $5E
        db $5F, $60
        
    ; $57C5F
        
        db $61, $62, $63, $64, $65, $66, $67, $68
        db $69, $6A, $6B
        
    ; $57C68
        
        db $6C, $6D, $6E, $6F, $70, $71, $72, $73
        db $74, $75, $76, $77, $78, $79, $7A, $7B
        db $7C, $7D, $7E, $7F, $80
        
    ; $57C7D
        
        db $81, $82, $83, $84, $85, $86
        
    ; $57C83
        
        db $87, $88, $89, $8A, $8B, $8C, $8D, $8E
        db $8F, $90, $91, $92
        
    ; $57C8F
        
        db $93, $94, $95, $4C, $96, $97, $98, $99
        db $4D, $9A, $9B, $9C, $9D, $9E, $9F, $A0
        db $A1
        
    ; $57CA0
        
        db $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9
        db $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1
        db $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9
    }
    
    ; $57CBA NULL
    {
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF        
    }
    
    ; $57CE0 DATA
    HUD.FloorIndicatorNumberHigh:
    {
        dw $2508, $2509, $2509, $250A, $250B, $250C, $250D, $251D
        dw $E51C, $250E, $007F
    }
    
    ; $57CF6 DATA
    HUD.FloorIndicatorNumberLow:
    {
        dw $2518, $2519, $A509, $251A, $251B, $251C, $2518, $A51D
        dw $E50C, $A50E, $007F
    }

; ==============================================================================

    ; *$57D0C-$57DA7 JUMP LOCATION (LONG)
    FloorIndicator:
    {
        ; Handles display of the Floor indicator on BG3 (1F, B1, etc)
        
        REP #$30
        
        LDA $04A0 : AND.w #$00FF : BEQ .hideIndicator
        
        INC A : CMP.w #$00C0 : BNE .dontDisable
        
        ; if the count up timer reaches 0x00BF frames, disable the floor indicator during the next frame.
        LDA.w #$0000
    
    .dontDisable
    
        STA $04A0
        
        PHB : PHK : PLB
        
        LDA.w #$251E : STA $7EC7F2
        INC A        : STA $7EC834
        INC A        : STA $7EC832
        
        LDA.w #$250F : STA $7EC7F4
        
        LDX.w #$0000
        
        ; this confused me at first, but it's actually looking at whether $A4[1]
        ; has a negative value $A3 has nothing to do with $A4
        LDA $A3 : BMI .basementFloor
        
        ; check which floor Link is on.
        LDA $A4 : BNE .notFloor1F
        
        LDA $A0 : CMP.w #$0002 : BEQ .sanctuaryRatRoom
        
        SEP #$20
        
        ; Check the world state
        LDA $7EF3C5 : CMP.b #$02 : BCS .noRainSound
        
        ; cause the ambient rain sound to occur (indoor version)
        LDA.b #$03 : STA $012D
    
    .noRainSound
    
        REP #$20
    
    .notFloor1F
    .sanctuaryRatRoom
    
        LDA $A4 : AND.w #$00FF
        
        BRA .setFloorIndicatorNumber
    
    .basementFloor
    
        SEP #$20
        
        ; turn off any ambient sound effects
        LDA.b #$05 : STA $012D
        
        REP #$20
        
        INX #2
        
        LDA $A4 : ORA.w #$FF00 : EOR.w #$FFFF
    
    .setFloorIndicatorNumber
    
        ASL A : TAY
        
        LDA FloorIndicatorNumberHigh, Y : STA $7EC7F2, X
        LDA FloorIndicatorNumberLow, Y  : STA $7EC832, X
        
        SEP #$30
        
        PLB
        
        ; send a signal indicating that bg3 needs updating
        INC $16
        
        RTL
    
    ; *$57D90 ALTERNATE ENTRY POINT
    .hideIndicator
    
        REP #$20
        
        ; disable the display of the floor indicator.
        LDA.w #$007F : STA $7EC7F2 : STA $7EC832 : STA $7EC7F4 : STA $7EC834
        
        SEP #$30
        
        RTL
    }

; =======================================================

    HUD.SuperBombIndicator:
    ; *$57DA8-$57E17 LONG
    {
        LDA $04B5 : BNE BRANCH_ALPHA
        
        LDA $04B4 : BMI BRANCH_BETA
        
        DEC $04B4
        
        LDA.b #$3E : STA $04B5
    
    BRANCH_ALPHA:
    
        DEC $04B5
        
        LDA $04B4 : BPL BRANCH_GAMMA
    
    BRANCH_BETA:
    
        LDA.b #$FF : STA $04B4
        
        REP #$30
        
        BRA FloorIndicator_hideIndicator
    
    BRANCH_GAMMA:
    
        LDA $04B4 : STA $4204
                    STZ $4205
        
        LDA.b #$0A : STA $4206
        
        NOP #8
        
        LDA $4214 : ASL A : STA $00
        
        LDA $4216 : ASL A : STA $02
        
        PHB : PHK : PLB
        
        REP #$20
        
        LDX.b #$02
    
    BRANCH_EPSILON:
    
        LDY $00, X : DEY #2 : BPL BRANCH_DELTA
        
        LDY.b #$12
        
        CPX.b #$00 : BNE BRANCH_DELTA
        
        LDY.b #$14
    
    BRANCH_DELTA:
    
        LDA $FCE0, Y : STA $7EC7F2, X
        LDA $FCF6, Y : STA $7EC832, X
        
        DEX #2 : BPL BRANCH_EPSILON
        
        SEP #$20
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $57E18-$57E1F EMPTY
    pool Empty:
    {
        fillbyte $FF
        
        fill $08
    }

; ==============================================================================

    ; *$57E20-$57E64 LONG
    Death_InitializeGameOverLetters:
    {
        PHB : PHK : PLB
        
        STZ $035F
        
        ; Sets X coordinates for the first 8 special effects to 0x00B0
        LDA.b #$B0 : STA $0C04
                     STA $0C05
                     STA $0C06
                     STA $0C07
                     STA $0C08
                     STA $0C09
                     STA $0C0A
                     STA $0C0B
        
        LDA.b #$00 : STA $0C18
                     STA $0C19
                     STA $0C1A
                     STA $0C1B
                     STA $0C1C
                     STA $0C1D
                     STA $0C1E
                     STA $0C1F
        
        INC A : STA $0C4A
        
        LDA.b #$06 : STA $039D
        
        PLB
        
        RTL
    } 

; ==============================================================================

    ; $57E65-$57E6F NULL
    {
        fillbyte $FF
        
        fill $0B
    }

; ==============================================================================

    ; $57E70-$57E7F DATA
    pool Effect_Handler:
    {
    
    .handlers
        dw Effect_DoNothing
        dw Effect_DoNothing
        dw Effect_MovingFloor
        dw Effect_MovingWater
        dw Effect_MovingFloor2      ; Not sure if this is used anywhere
        dw Effect_RedFlashes        ; (Agahnim's room in Ganon's tower)
        dw Effect_TorchHiddenTiles
        dw Effect_TorchGanonRoom
    }
    
; ==============================================================================

    ; $57E80-$57E86 LONG
    Effect_Handler:
    {
        LDA $AD : ASL A : TAX
        
        JMP (.handlers, X)
    }

; ==============================================================================

    ; $57E87-$57E87 JUMP LOCATION
    Effect_DoNothing:
    {
        RTL
    }

; ==============================================================================
    
    ; $57E88-$57EED JUMP LOCATION
    Effect_MovingFloor:
    {
        ; If the boss has been beaten in this room don't move the floor anymore.
        LDA $0403 : AND.b #$80 : BEQ .bossNotDead
        
        STZ $AD
        
        RTL
    
    .bossNotDead
    
        REP #$30
        
        ; Set moving floor speeds to zero, both X and Y velocities.    
        STZ $0312 : STZ $0310
        
        ; Test the low bit of $041A[2]
        ; The low bit of that variable disables floor movement
        LDA $041A : LSR A : BCS .return
        
        ; X = the bit 1 of $041A[2]
        ASL A : AND.w #$0002 : TAX
        
        ; $041C[2] += 0x8000
        LDA $041C : ADD.w #$8000 : STA $041C
        
        ; if $041C[2] was negative before the addition, then A = 1, otherwise A = 0
        ROL A : AND.w #$0001
        
        CPX.w #$0002 : BNE .notInverted
        
        ; Invert the accumulator. Thus A =   
        EOR.w #$FFFF : INC A
    
    .notInverted
    
        LDX $041A : CPX.w #$0004 : BCS .vertical
        
        ; Set the horizontal floor movement speed
        STA $0312
        
        LDA $0422 : SUB $0312 : STA $0422
        
        ADD $E2 : STA $E0
        
        SEP #$30
        
        RTL

    .vertical

        ; Tells the floor to move in a Y direction instead. 
        ; Set the vertical floor movement speed.
        STA $0310
        
        LDA $0424 : SUB $0310 : STA $0424
        
        ADD $E8 : STA $E6
    
    .return
    
        SEP #$30
        
        RTL
    }

; ==============================================================================
   
    ; $57EEE-$57F0C JUMP LOCATION
    Effect_MovingFloor2:
    {
        REP #$20
        
        ; Causes the background to move by the amounts specified by the variables below
        LDA $0422 : ADD $0312 : STA $0422
        LDA $0424 : ADD $0310 : STA $0424
        
        ; Sets the velocities of the background to zero, meaning they must be set again for the bg to continue moving.
        STZ $0312 : STZ $0310
        
        SEP #$20
        
        RTL
    }

; ==============================================================================
    
    ; $57F0D-$57F5C JUMP LOCATION
    Effect_RedFlashes:
    {
        LDA $1A : AND.b #$7F
        
        CMP.b #$03 : BEQ .redFlash
        CMP.b #$05 : BEQ .restoreColors
        CMP.b #$24 : BEQ .redFlash
        CMP.b #$26 : BNE .noChange
    
    .restoreColors
    
        REP #$20
        
        LDA $7EC3DA : STA $7EC5DA
        LDA $7EC3DC : STA $7EC5DC
        
        LDA $7EC3DE
    
    .finishUp
    
        STA $7EC5DE : STA $7EC5EE
        
        SEP #$20
        
        INC $15
    
    .noChange
    
        ; Put bg2 on the subscreen
        LDA.b #$02 : STA $1D
        
        RTL
    
    .redFlash
    
        REP #$20
        
        LDA.w #$1D59 : STA $7EC5DA
        LDA.w #$25FF : STA $7EC5DC
        
        ; Change the sky to a very red color.
        LDA.w #$001A
        
        BRA .finishUp
    }

; ==============================================================================

    ; $57F5D-$57FA3 JUMP LOCATION
    Effect_TorchHiddenTiles:
    {
        ; Light torch to see floor?
        
        REP #$30
        
        LDX.w #$0000 : STX $00
    
    .countLitTorches
    
        ; special object tile position...
        LDA $0540, X : ASL A : BCC .notLit
    
        INC $00
    
    .notLit
    
        INX #2 : CPX.w #$0020 : BNE .countLitTorches
        
        ; Cause the tiles to be seen by setting them two bluish colors.
        LDX.w #$2940
        LDY.w #$4E60
        
        ; Check how many torches are lit        ; at least one is lit
        LDA $00 : BNE .atLeastOne
        
        ; hides the tiles by setting critical colors in the tiles' palette to black.
        LDX.w #$0000
        LDY.w #$0000
    
    .atLeastOne
    
        TXA : CMP $7EC3F6 : BEQ .matchesAuxiliary
        
        STA $7EC3F6 : STA $7EC5F6 ; Changing a palette value
        
        TYA : STA $7EC3F8 : STA $7EC5F8
        
        ; tell NMI to reupload CGRAM data
        INC $15
    
    .matchesAuxiliary
    
        SEP #$30
        
        ; Enable bg2 on the subscreen 
        LDA.b #$02 : STA $1D
        
        RTL
    }

; ==============================================================================

    ; $57FA4-$57FDD JUMP LOCATION
    Effect_TorchGanonRoom:
    {
        ; initialize number of lit torches to zero
        STZ $04C5
        
        REP #$30
        
        LDX.w #$0000
    
    .nextTorch
    
        LDA $0540, X : ASL A : BCC .notLit
        
        INC $04C5
    
    .notLit
    
        ; only check the first 3 torches in memory. (this probably causes bugs
        ; in some hacks) Cycle through all the torche
        INX #2 : CPX.w #$0006 : BNE .nextTorch
        
        SEP #$30
        
        LDA $04C5 : BNE .oneLit
        
        ; effectively this darkens the room so you can't see Ganon
        ; diable all layers on the subscreen
        STZ $1D
        
        ; $9A = !CGSUB | !CGBG0 | !CGBG1 | !CGOBJ | !CGBGD ;    
        LDA.b #$B3 : STA $9A
        
        RTL
    
    .oneLit
    
        ; only one torch is lit in Ganon's room.
        CMP.b #$01 : BNE .fullyLit
        
        ; Put BG1 on the subscreen    
        LDA.b #$02 : STA $1D
        
        ; $9A = !CGADDHALF | !CGOBJ | !CGBGD
        LDA.b #$70 : STA $9A
        
        RTL
    
    .fullyLit
    
        ; since BG1 does not participate in color math anymore, it appears normal (fully lit)
        STZ $1D ; Take BG1 off of the subscreen
        
        ; $9A = !CGADDHALF | !CGOBJ | !CGBGD
        LDA.b #$70 : STA $9A
        
        RTL
    }

; ==============================================================================

    ; $57FDE-$57FFA JUMP LOCATION
    Effect_MovingWater:
    {
        REP #$21
        
        ; $041C alternates between being negative and non negative
        LDA.w #$8000 : ADC $041C : STA $041C
        
        ; Effectively this means that $00 alternates between being 0 and 1 each
        ; frame
        ROL A : AND.w #$0001 : STA $00
        
        ; Adjust the horizontal position of the water background by either 0 or
        ; -1
        LDA.w #$0000 : SUB $00 : STA $0312
        
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; $57FFB-$57FFF NULL
    {
        db $FF, $FF, $FF, $FF, $FF
    }

; ==============================================================================

warnpc $0B8000