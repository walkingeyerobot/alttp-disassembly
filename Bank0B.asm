

    ; *$5FE70-$5FFA7 LONG
    {
        ; Turn the subscreen off for the moment.
        STZ $1D
        
        REP #$30
        
        LDX.w #$19C6
        
        LDA $8A : CMP.w #$0080 : BNE .notMasterSwordArea
        
        LDA $A0 : CMP.w #$0181 : BNE .setBgColor
        
        INC $1D
        
        BRA .useDefaultGreen
    
    .notMasterSwordArea
    
        ; If area == 0x81 branch
        CMP.w #$0081 : BEQ .setBgColor
        
        LDX.w #$0000
        
        CMP.w #$005B                : BEQ .setBgColor
        AND.w #$00BF : CMP.w #$0003 : BEQ .setBgColor
        CMP.w #$0005                : BEQ .setBgColor
        CMP.w #$0007                : BEQ .setBgColor
    
    .useDefaultGreen
    
        LDX.w #$2669
        
        LDA $8A : AND.w #$0040 : BEQ .setBgColor
        
        ; Default tan color for the dark world
        LDX.w #$2A32
    
    .setBgColor
    
        TXA : STA $7EC500 : STA $7EC300 : STA $7EC540 : STA $7EC340
        
        ; set fixed color to neutral
        LDA.w #$4020 : STA $9C
        LDA.w #$8040 : STA $9D
        
        LDA $8A      : BEQ .noCustomFixedColor
        CMP.w #$0070 : BNE .notSwampOfEvil
        
        JMP .subscreenOnAndReturn
    
    .notSwampOfEvil
    
        CMP.w #$0040 : BEQ .noCustomFixedColor
        CMP.w #$005B : BEQ .noCustomFixedColor
        
        LDX.w #$4C26
        LDY.w #$8C4C
        
        CMP.w #$0003 : BEQ .setCustomFixedColor
        CMP.w #$0005 : BEQ .setCustomFixedColor
        CMP.w #$0007 : BEQ .setCustomFixedColor
        
        LDX.w #$4A26
        LDY.w #$874A
        
        CMP.w #$0043 : BEQ .setCustomFixedColor
        CMP.w #$0045 : BEQ .setCustomFixedColor
        
        SEP #$30
        
        ; Update CGRAM this frame
        INC $15
        
        RTL
    
    .setCustomFixedColor
    
        STX $9C
        STY $9D ; Set the fixed color addition color values
    
    .noCustomFixedColor
    
        LDA $11 : AND.w #$00FF : CMP.w #$0004 : BEQ BRANCH_11
        
        ; Make sure BG2 and BG1 Y scroll values are synchronized. Same for X scroll
        LDA $E8 : STA $E6
        LDA $E2 : STA $E0
        
        LDA $8A : AND.w #$003F
        
        ; Are we at Hyrule Castle or Pyramid of Power?
        CMP.w #$001B : BNE .subscreenOnAndReturn
        
        LDA $E2 : SUB.w #$0778 : LSR A : TAY : AND.w #$4000 : BEQ BRANCH_7
        
        TYA : ORA.w #$8000 : TAY
    
    BRANCH_7:
    
        STY $00
        
        LDA $E2 : SUB $00 : STA $E0
        
        LDA $E6 : CMP.w #$06C0 : BCC BRANCH_9
        
        SUB.w #$0600 : AND.w #$03FF : CMP.w #$0180 : BCS BRANCH_8
        
        LSR A : ORA.w #$0600
        
        BRA BRANCH_10
    
    BRANCH_8:
    
        LDA.w #$06C0
        
        BRA BRANCH_10
    
    BRANCH_9:
    
        LDA $E6 : AND.w #$00FF : LSR A : ORA.w #$0600
    
    BRANCH_10:
    
        ; Set BG1 vertical scroll
        STA $E6
        
        BRA .subscreenOnAndReturn
    
    BRANCH_11:
    
        LDA $8A : AND.w #$003F : CMP.w #$001B : BNE .subscreenOnAndReturn
        
        ; Synchronize Y scrolls on BG0 and BG1. Same for X scrolls
        LDA $E8 : STA $E6
        LDA $E2 : STA $E0
        
        LDA $0410 : AND.w #$00FF : CMP.w #$0008 : BEQ BRANCH_12
        
        ; Handles scroll for special areas maybe?
        LDA.w #$0838 : STA $E0
    
    BRANCH_12:
    
        LDA $06C0 : STA $E6
    
    .subscreenOnAndReturn
    
        SEP #$20
        
        ; Put BG0 on the subscreen
        LDA.b #$01 : STA $1D
        
        SEP #$30
        
        ; Update palette
        INC $15
        
        RTL
    }

; ==============================================================================

    ; *$5FFA8-$5FFF5 LONG
    WallMaster_SendPlayerToLastEntrance:
    {
        JSL Dungeon_SaveRoomData.justKeys
        JSL Dungeon_SaveRoomQuadrantData
        JSL Sprite_ResetAll
        
        ; Don't use a starting point entrance.
        STZ $04AA
        
        ; Falling into an overworld hole mode.
        LDA.b #$11 : STA $10
        
        STZ $11
        STZ $14
    
    ; *$5FFBF ALTERNATE ENTRY POINT
    
        STZ $0345
        
        ; \wtf 0x11? Written here? I thought these were all even.
        STA $005E
        
        STZ $03F3
        STZ $0322
        STZ $02E4
        STZ $0ABD
        STZ $036B
        STZ $0373
        
        STZ $27
        STZ $28
        
        STZ $29
        
        STZ $24
        
        STZ $0351
        STZ $0316
        STZ $031F
        
        LDA.b #$00 : STA $5D
        
        STZ $4B
    
    ; *$5FFEE ALTERNATE ENTRY POINT
    
        JSL Ancilla_TerminateSelectInteractives
        JML Player_ResetState
    }

; ==============================================================================
