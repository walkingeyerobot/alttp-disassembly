
; ==============================================================================

    ; $4F270-$4F28F Jump Table
    pool Module_Death:
    {
    
    .states
        dw $F2A2 ; = $4F2A2*              ; 0x00 -
        dw $F2A4 ; = $4F2A4*              ; 0x01 - 
        dw $F33B ; = $4F33B*              ; 0x02 - ????
        dw $F350 ; = $4F350*              ; 0x03 - screen spotlight starts caving in
        dw $F47E ; = $4F47E*              ; 0x04 - screen turns red, link spins around and falls down
        dw $F3DE ; = $4F3DE*              ; 0x05-  screen fades from red to black                    
        dw $F458 ; = $4F458*              ; 0x06 - 
        dw $F483 ; = $4F483*              ; 0x07 -
        dw Death_ShowSaveOptionsMenu      ; 0x08 -
        dw $F4C1 ; = $4F4C1*              ; 0x09 -
        dw $F6A4 ; = $4F6A4*              ; 0x0A - 
        dw $F6B4 ; = $4F6B4*              ; 0x0B - Faerie revival?
        dw $F6B9 ; = $4F6B9*              ; 0x0C - Faerie revival part 2?
        dw $F71D ; = $4F71D*              ; 0x0D
        dw $F735 ; = $4F735*              ; 0x0E
        dw Death_RestoreScreenPostRevival ; 0x0F
    }

; ==============================================================================

    ; *$4F290-$4F2A1 JUMP LOCATION LONG
    Module_Death:
    {
        ; Beginning of Module 0x12, Death Mode
        
        LDA $11 : ASL A : TAX
        
        JSR (.states, X)
        
        LDA $11 : CMP.b #$09 : BEQ .dont_show_player
        
        JSL PlayerOam_Main
    
    .dont_show_player
    
        RTL
    }

; ==============================================================================

    ; *$4F2A2-$4F33A LOCAL
    {
        INC $11
    
    ; *$4F2A4 ALTERNATE ENTRY POINT
    
        ; ????
        LDA $0130 : STA $7EC227
        LDA $0131 : STA $7EC228
        
        ; Fade volume to nothing
        LDA.b #$F1 : STA $012C
        
        ; turn off ambient sound effect (rumbling, etc)
        LDA.b #$05 : STA $012D
        
        ; not sure of the interpretation of this, though
        STA $0200
        
        ; turn off cape ($55), and two other things that I don't understand
        STZ $03F3 : STZ $0322 : STZ $55
        
        REP #$20
        
        ; cache mosaic level settings in temporary variables
        LDA $7EC007 : STA $7EC221
        LDA $7EC009 : STA $7EC223
        
        LDX.b #$00
    
    ; sets all entries in the auxiliary palette to black. This is presumably used later for the fade from
    ; red to black after Link falls down
    .blackenAuxiliary
    
        LDA $7EC300, X : STA $7FDD80, X
        LDA $7EC340, X : STA $7FDDC0, X
        LDA $7EC380, X : STA $7FDE00, X
        LDA $7EC3C0, X : STA $7FDE40, X
        
        LDA.w #$0000 : STA $7EC340, X : STA $7EC380, X : STA $7EC3C0, X
        
        INX #2 : CPX.b #$40 : BNE .blackenAuxiliary
        
        STA $7EC007 : STA $7EC009
        
        STZ $011A : STZ $011C
        
        LDA $99 : STA $7EC225
        
        SEP #$20
        
        ; Set a timer for 32 frames
        LDA.b #$20 : STA $C8
        
        STZ $04A0
        
        ; Setting $04A0 to 0 turns off the display of the floor level indicator on bg3
        JSL $0AFD0C ; $57D0C
        
        INC $16
        
        ; silences the sound effect on first channel    
        LDA #$05 : STA $012D
        
        INC $11
        
        RTS
    } 


    ; *$4F33B-$4F34F LOCAL
    {
        DEC $C8 : BNE .alpha
        
        ; Initializes "death ancillae" for death mode.
        JSL Death_InitializeGameOverLetters
        JSL Spotlight.close
        
        LDA.b #$30 : STA $98
                     STZ $97
        
        INC $11
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$4F350-$4F3DD LOCAL
    {
        JSL PaletteFilter_Restore_Strictly_Bg_Subtractive
        
        LDA $7EC540 : STA $7EC500
        LDA $7EC541 : STA $7EC501
        
        LDA $10 : PHA
        
        JSL ConfigureSpotlightTable
        
        PLA : STA $10
        
        ; \wtf Shouldn't $11 always be nonzero here? Or does that subroutine
        ; call set it to zero?
        LDA $11 : BNE .return
        
        REP #$20
        
        LDA.w #$0018
        LDX.b #$00
    
    .fill_main_bg_palettes_with_red
    
        STA $7EC540, X : STA $7EC560, X : STA $7EC580, X
        STA $7EC5A0, X : STA $7EC5C0, X : STA $7EC5E0, X
        
        INX #2 : CPX.b #$20 : BNE .fill_main_bg_palettes_with_red
        
        STA $7EC500 : STA $7EC540
        
        SEP #$20
        
        JSL ResetSpotlightTable
        
        LDA.b #$20 : STA $9C
        LDA.b #$40 : STA $9D
        LDA.b #$80 : STA $9E
        
        STZ $96
        STZ $97
        STZ $98
        
        LDA.b #$04 : STA $11
        
        INC $15
        
        LDA.b #$0F : STA $13
        
        LDA.b #$14 : STA $1C
        
        STZ $1D
        
        LDA.b #$20 : STA $9A
        LDA.b #$40 : STA $C8
        
        LDA.b #$00 : STA $7EC007 : STA $7EC009
        
        JSL Death_PrepFaint
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$4F3DE-$4F457 LOCAL
    {
        LDA $C8 : BNE .delay
        
        JSL PaletteFilter_Restore_Strictly_Bg_Subtractive
        
        LDA $7EC540 : STA $7EC500
        LDA $7EC541 : STA $7EC501
        
        LDA $7EC009 : CMP.b #$FF : BNE BRANCH_BETA
        
        LDA.b #$00 : STA $7EC011
                     STA $0647
        
        LDA.b #$03 : STA $95
        
        LDX.b #$00
        
        LDA.b #$06 : CMP $7EF35C : BEQ .hasBottledFairy
        
        INX
        
        CMP $7EF35D : BEQ .hasBottledFairy
        
        INX
        
        CMP $7EF35E : BEQ .hasBottledFairy
        
        INX
        
        CMP $7EF35F : BEQ .hasBottledFairy
        
        STZ $05FC : STZ $05FD
        
        LDA.b #$16 : STA $17 : STA $0710
        
        INC $11
    
    BRANCH_BETA:
    
        RTS
    
    .delay
    
        DEC $C8
        
        RTS
    
    .hasBottledFairy
    
        ; Empty that bottle.
        LDA.b #$02 : STA $7EF35C, X
        
        ; Switch to a different fricken submode of this module?
        LDA.b #$0C : STA $C8
        
        LDA.b #$0F : STA $0AAA
        
        ; Grab a half pack of graphics and expand to 4bpp.
        JSL Graphics_LoadChrHalfSlot
        
        STZ $0AAA
        
        LDA.b #$0A : STA $11
        
        RTS
    }

    ; *$4F458-$4F482 LOCAL
    {
        LDA.b #$0C : STA $C8
        LDA.b #$0F : STA $0AAA
        
        JSL Graphics_LoadChrHalfSlot
        
        STZ $0AAA
        
        LDA.b #$05 : STA $0AB1
        LDA.b #$02 : STA $0AA9
        
        JSL Palette_MiscSpr.justSP6
        JSL Palette_MainSpr
        
        INC $15 : INC $11
    
    ; *$4F47E ALTERNATE ENTRY POINT
    
        JSL Death_PlayerSwoon
        
        RTS
    }

    ; *$4F483-$4F487 LOCAL
    {
        JSL Ancilla_GameOverTextLong
        
        RTS
    }

    ; *$4F488-$4F4AB LOCAL
    Death_ShowSaveOptionsMenu:
    {
        JSL Ancilla_GameOverTextLong
        
        LDA $10 : PHA
        LDA $11 : PHA
        
        LDA.b #$02 : STA $1CD8
        
        JSL Messaging_Text
        
        PLA : INC A : STA $11
        
        PLA : STA $10
        
        LDA.b #$02 : STA $C8
        
        ; Play the fountain music?
        LDA.b #$0B : STA $012C
        
        RTS
    }

; ==============================================================================

    ; $4F4AC-$4F4C0 DATA
    {
    
    ; \task Name this pool / routine.
        db $18, $18, $18, $18, $18, $20, $20, $28
        db $28, $30, $30, $38, $38, $38, $40, $40
        db $40, $48, $48, $48, $50
    }

; ==============================================================================

    ; *$4F4C1-$4F674 LOCAL
    {
        JSR $F67A ; $4F67A IN ROM
        
        LDA $0C4A : BEQ .alpha
        
        JSL Ancilla_GameOverTextLong
    
    .alpha
    
        LDA $F4 : AND.b #$20 : BNE .selectButtonPressed
        
        DEC $C8 : BNE BRANCH_GAMMA
        
        INC $C8
        
        LDA $F0
        
        AND.b #$0C : BEQ BRANCH_GAMMA
        AND.b #$04 : BEQ BRANCH_DELTA
    
    .selectButtonPressed
    
        INC $B0 : LDA $B0 : CMP.b #$03 : BMI BRANCH_EPSILON
        
        STZ $B0
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        DEC $B0 : BPL BRANCH_EPSILON
        
        LDA.b #$02 : STA $B0
    
    BRANCH_EPSILON:
    
        LDA.b #$0C : STA $C8
        
        LDA.b #$20 : STA $012F
    
    BRANCH_GAMMA:
    
        LDA $F6 : AND.b #$C0 : ORA $F4 : AND.b #$D0 : BEQ BRANCH_$4F4AB ; (RTS)
        
        LDA.b #$2C : STA $012E
    
    ; *$4F50F ALTERNATE ENTRY POINT
    
        LDA.b #$F1 : STA $012C
        
        LDA $1B : BEQ BRANCH_ZETA
        
        JSL Dungeon_SaveRoomQuadrantData
    
    BRANCH_ZETA:
    
        JSL $02856A ; $1056A IN ROM
        
        LDA $7EF3C5 : CMP.b #$03 : BCS BRANCH_THETA
        
        LDA.b #$00 : STA $7EF3CA
        
        LDA $7EF357 : BNE BRANCH_THETA
        
        JSL $028570 ; $10570 IN ROM
    
    BRANCH_THETA:
    
        LDA $A0 : ORA $A1 : BNE BRANCH_IOTA
        
        STZ $1B
    
    BRANCH_IOTA:
    
        JSL $0BFFBF ; $5FFBF IN ROM
        
        LDA $7EF3CC
        
        CMP.b #$06 : BEQ BRANCH_KAPPA
        CMP.b #$0D : BEQ BRANCH_KAPPA
        CMP.b #$0A : BEQ BRANCH_KAPPA
        CMP.b #$09 : BNE BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        LDA.b #$00 : STA $7EF3CC
    
    BRANCH_LAMBDA:
    
        LDA $7EF36C : LSR #3 : TAX
        
        LDA $09F4AC, X : STA $7EF36D : STA $04AA
        
        LDA $040C
        
        CMP.b #$FF : BEQ BRANCH_MU
        CMP.b #$02 : BNE BRANCH_NU
        
        LDA.b #$00
    
    BRANCH_NU:
    
        LSR A : TAX
        
        LDA $7EF36F : STA $7EF37C, X
    
    BRANCH_MU:
    
        JSL Sprite_ResetAll
        
        REP #$20
        
        LDA $7EF405 : CMP.w #$FFFF : BNE .playerHasDeaths
        
        LDA $7EF403 : INC A : STA $7EF403
    
    .playerHasDeaths
    
        SEP #$20
        
        INC $010A
        
        LDA $B0 : CMP.b #$01 : BEQ .handleSram
        
        LDA $1B : BEQ BRANCH_PI
        
        LDA $7EF3CC : CMP.b #$01 : BEQ BRANCH_RHO
        
        LDA $040C : CMP.b #$FF : BEQ BRANCH_SIGMA
        
        STZ $04AA
        
        BRA BRANCH_RHO
    
    BRANCH_SIGMA:
    
        STZ $0132
        STZ $1B
    
    BRANCH_PI:
    
        ; Are we in the Dark World?
        LDA $7EF3CA : BEQ BRANCH_RHO
        
        ; Otherwise, make it so the dungeon room we were last in was Agahnim's first room.
        LDA.b #$20 : STA $A0 : STZ $A1
    
    BRANCH_RHO:
    
        LDA $7EF3C5 : BEQ BRANCH_TAU
        
        LDA $B0 : BNE BRANCH_UPSILON
        
        JSL Main_SaveGameFile
    
    BRANCH_UPSILON:
    
        LDA #$05 : STA $10
        
        STZ $11 : STZ $14
        
        RTS
    
    BRANCH_TAU:
    
        REP #$20
        
        LDA $701FFE : TAX : DEX #2
        
        LDA $00848C, X : STA $00
        
        SEP #$20
        
        STZ $010A
        
        JSL $0CCFBB ; $64FBB IN ROM
        
        RTS
    
    .handleSram
    
        LDA $7EF3C5 : BEQ .dontSave
        
        JSL Main_SaveGameFile
    
    .dontSave
    
        LDA.b #$10 : STA $1C
        
        STZ $1B
        
        JSL $0CF0E2 ; $670E2 IN ROM
        
        STZ $04AA : STZ $010A : STZ $0132
        
        SEI
        
        STZ $4200 : STZ $420C
        
        REP #$30
        
        STZ $E0 : STZ $E2 : STZ $E4 : STZ $E6 : STZ $E8 : STZ $EA
        
        STZ $0120 : STZ $011E : STZ $0124 : STZ $0122
        
        LDX.w #$0000 : TXA
    
    .eraseSramBuffer
    
        STA $7EF000, X
        STA $7EF100, X
        STA $7EF200, X
        STA $7EF300, X
        STA $7EF400, X
        
        INX #2 : CPX.w #$0100 : BNE .eraseSramBuffer
        
        SEP #$30
        
        STZ $0136
        
        LDA.b #$FF : STA $2140
        
        JSL Sound_LoadLightWorldSongBank
        
        LDA #$81 : STA $4200
        
        RTS
    }

; ==============================================================================

    ; $4F675-$4F679 DATA
    {
        db -22, -20
        
        db $7F, $8F, $9F
    }

; ==============================================================================

    ; *$4F67A-$4F6A3 LOCAL
    {
        PHB : PHK : PLB
        
        LDX $B0
        
        LDA.b #$34 : STA $0850
        
        LDA $F677, X : STA $0851
        
        LDA $1A : AND.b #$08 : LSR #3 : TAX
        
        LDA $F675, X : STA $0852
        
        LDA.b #$78 : STA $0853
        LDA.b #$02 : STA $0A34
        
        PLB
        
        RTS
    }

    ; *$4F6A4-$4F6B3 LOCAL
    {
        ; Configure some ancillary objects for reviving the player, such
        ; as a faerie and... other stuff?
        JSL Ancilla_ConfigureRevivalObjects
        
        ; Restore the player's health by 7 hearts.
        LDA.b #$38 : STA $7EF372
        
        INC $11
        
        STZ $0200
        
        RTS
    }

    ; *$4F6B4-$4F6B8 LOCAL
    {
        JSL Ancilla_RevivalFaerie
        
        RTS
    }

    ; *$4F6B9-$4F71C LOCAL
    {
        LDA $7EF372 : BNE .refillHearts
        
        REP #$20
        
        LDX.b #$00
    
    .restore_cached_palettes_loop
        
        ; mess with the palette
        LDA $7FDD80, X : STA $7EC300, X
        LDA $7FDDC0, X : STA $7EC340, X
        LDA $7FDE00, X : STA $7EC380, X
        LDA $7FDE40, X : STA $7EC3C0, X
        
        LDA.w #$0000 : STA $7EC540, X : STA $7EC580, X : STA $7EC5C0, X
        
        INX #2 : CPX.b #$40 : BNE .restore_cached_palettes_loop
        
        STA $7EC500
        
        LDA.w #$0000 : STA $7EC007
        LDA.w #$0002 : STA $7EC009
        
        LDA $7EC225 : STA $99
        
        SEP #$20
    
    ; *$4F712 ALTERNATE ENTRY POINT
    
        INC $11
    
    ; *$4F714 ALTERNATE ENTRY POINT
    
    .refillHearts
    
        JSL Ancilla_RevivalFaerie
        JSL HUD.RefillLogicLong
        
        RTS
    }

    ; *$4F71D-$4F734 LOCAL
    {
        LDA $020A : BNE BRANCH_$4F714
        
        LDA #$01 : STA $0AAA
        
        JSL Graphics_LoadChrHalfSlot
        
        LDA $7EC017
        
        JSL Dungeon_ApproachFixedColor.variable ; $FEC1 IN ROM
        
        BRA BRANCH_$4F712
    }

    ; *$4F735-$4F741 LOCAL
    {
        JSL Graphics_LoadChrHalfSlot
        
        LDA $7EC212 : STA $1D
        
        INC $11
        
        RTS
    }

; ==============================================================================

    ; *$4F742-$4F79A LOCAL
    Death_RestoreScreenPostRevival:
    {
        JSL PaletteFilter_Restore_Strictly_Bg_Additive
        
        LDA $7EC540 : STA $7EC500
        LDA $7EC541 : STA $7EC501
        
        LDA $7EC007 : CMP.b #$20 : BNE .not_done
        
        LDA $1B : BNE .indoors
        
        JSL $0BFE70 ; $5FE70 IN ROM
    
    .indoors
    
        LDA $7EC212 : STA $1D
        
        LDA $010C : STA $10
        
        STZ $11
        
        LDA.b #$90 : STA $031F
        
        LDA $7EC227 : STA $012C
        LDA $7EC228 : STA $012D
        
        REP #$20
        
        LDA $7EC221 : STA $7EC007
        LDA $7EC223 : STA $7EC009
        
        SEP #$20
    
    ; $4F742 ALTERNATE ENTRY POINT
    .return
    .not_done
    
        RTS
    }

; ==============================================================================

