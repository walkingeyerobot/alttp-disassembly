
; ==============================================================================

    ; $34309-$34318 DATA
    pool Sprite_WishPond:
    {
    
    .x_offsets
        db 0,  4,  8, 12, 16, 20, 24, 00
    
    .y_offsets
        db 0,  8, 16, 24, 32, 40,  4, 36
    }

; ==============================================================================

    ; *$34319-$343AA JUMP LOCATION
    Sprite_WishPond:
    {
        ; Pond of Wishing AI
        
        LDA $0D90, X : BNE BRANCH_ALPHA
        
        LDA $0DA0, X : BNE BRANCH_BETA
        
        JSR Sprite_PrepOamCoordSafeWrapper
        JMP $C41D ; $3441D IN ROM
    
    BRANCH_BETA:
    
        JSR FaerieQueen_Draw
        
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        LDA $1A : AND.b #$0F : BNE BRANCH_GAMMA
        
        LDA.b #$72 : JSL Sprite_SpawnDynamically : BMI BRANCH_GAMMA
        
        PHX
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA $00 : ADD .x_offsets, X : STA $0D10, Y
        LDA $01 : ADC.b #$00        : STA $0D30, Y
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA $02 : ADD .y_offsets, X : STA $0D00, Y
        LDA $03 : ADC.b #$00        : STA $0D20, Y
        
        LDA.b #$1F : STA $0DB0, Y
                     STA $0D90, Y
        
        JSR Sprite_ZeroOamAllocation
        
        LDA.b #$48 : STA $0E60, Y
        
        AND.b #$0F : STA $0F50, Y
        
        LDA.b #$01 : STA $0DA0, Y
        
        PLX
    
    BRANCH_GAMMA:
    
        RTS
    
    BRANCH_ALPHA:
    
        DEC $0DB0, X : BNE BRANCH_DELTA
        
        STZ $0DD0, X
    
    BRANCH_DELTA:
    
        LDA $0DB0, X : LSR #3 : STA $0DC0, X
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionC
        
        JSR Sprite_PrepAndDrawSingleSmall
        
        RTS
    }

; ==============================================================================

    ; $343AB-$3441D DATA
    {
        ; \task Fill in data later
    
    ; $343DD
        
        dw $C3AA, $C3AE, $C3B0, $C3B1, $C3B2, $C3B4, $C3B5, $C3B6
        dw $C3B7, $C3B8, $C3B9, $C3BA, $C3BB, $C3BE, $C3BF, $C3C0
        dw $C3C0, $C3C1, $C3C2, $C3C3, $C3C6, $C3C8, $C3C9, $C3CA
        dw $C3CB, $C3CB, $C3CF, $C3D2, $C3D4, $C3D4, $C3D4, $C3D4        
    }


; ==============================================================================

    ; *$3441D-$3444B LOCAL
    {
        JSR $C4B5 ; $344B5 IN ROM
        JSR Sprite_CheckIfActive
        
        LDA $A0 : CMP.b #$15 : BEQ Sprite_HappinessPond
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $C7A1 ; = $347A1*
        dw $C7C6 ; = $347C6*
        dw $C7ED ; = $347ED*
        dw $C83C ; = $3483C*
        dw $C88B ; = $3488B*
        dw $C8B7 ; = $348B7*
        dw $C8C6 ; = $348C6*
        dw $C952 ; = $34952*
        dw $C97A ; = $3497A*
        dw $C9A1 ; = $349A1*
        dw $C9C8 ; = $349C8*
        dw $C9E5 ; = $349E5*
        dw $C9F1 ; = $349F1*
        dw $CA00 ; = $34A00*
    }

; ==============================================================================

    ; \note The happiness pond, 
    ; *$3444C-$34470 BRANCH LOCATION
    Sprite_HappinessPond:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $C4FD ; = $344FD*
        dw $C52B ; = $3452B*
        dw $C570 ; = $34570*
        dw $C59F ; = $3459F*
        dw $C603 ; = $34603*
        dw $C616 ; = $34616*
        dw $C665 ; = $34665*
        dw $C691 ; = $34691*
        dw $C6A0 ; = $346A0*
        dw $C6D2 ; = $346D2*
        dw $C6E7 ; = $346E7*
        dw $C70E ; = $3470E*
        dw $C721 ; = $34721*
        dw $C763 ; = $34763*
        dw HappinessPond_GrantLuckStatus
    }

; ==============================================================================

    ; $34471-$344B4 DATA
    {
    
    ; $C471
        dw 32, -64 : db $24, $00, $00, $00
        dw 32, -56 : db $34, $00, $00, $00
        dw 32, -64 : db $24, $00, $00, $00
        dw 32, -56 : db $34, $00, $00, $00
    
    ; $C491
        dw 32, -64 : db $24, $00, $00, $02
        dw 32, -64 : db $24, $00, $00, $02
        dw 32, -64 : db $24, $00, $00, $02
        dw 32, -64 : db $24, $00, $00, $02
    
    ; $C4B1
        dw $C471, $C491
    }

; ==============================================================================

    ; *$344B5-$344FC LOCAL
    {
        ; No items returned at happiness pond.
        LDA $A0 : CMP.b #$15 : BEQ .return
        
        LDA $0D80, X
        
        CMP.b #$05 : BEQ .show_returned_item
        CMP.b #$06 : BEQ .show_returned_item
        CMP.b #$0B : BEQ .show_returned_item
        CMP.b #$0C : BEQ .show_returned_item
        
        BRA .return
    
    .show_returned_item
    
        PHX : TXY
        
        LDA $0DC0, Y : TAX
        
        LDA AddReceiveItem.properties, X
        
        CMP.b #$FF : BNE .valid_upper_properties
        
        ; \hardcoded
        ; Force to use palette 5. This only applies to the master sword
        ; anyways.
        LDA.b #$05
    
    .valid_upper_properties
    
        AND.b #$07 : ASL A : STA $0F50, Y
        
        LDA AddReceiveItem.wide_item_flag, X : TAY
        
        LDA $C4B1, Y : STA $08
        LDA $C4B2, Y : STA $09
        
        LDA.b #$04
        
        PLX
        
        JSL Sprite_DrawMultiple
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$344FD-$34522 JUMP LOCATION
    {
        STZ $02E4
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS BRANCH_ALPHA
        
        LDA.b #$89
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC BRANCH_ALPHA
        
        INC $0D80, X
        
        JSL Player_ResetState
        JSL Ancilla_TerminateSparkleObjects
        
        STZ $2F

    BRANCH_ALPHA:

        RTS
    }

; ==============================================================================

    ; $34523-$3452A DATA
    {
    
    .prices
        db 5, 20, 25, 50
    
    ; (binary coded decimal used for display in dialogue system).
    .bcd_prices
        db $05, $20, $25, $50
    }

; ==============================================================================

    ; *$3452B-$3455C JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_3455F
        
        LDA $7EF370 : ORA $7EF371 : BEQ .no_bomb_or_arrow_upgrades_yet
        
        LDA.b #$02
    
    .no_bomb_or_arrow_upgrades_yet
    
        STA $0DC0, X : TAY
        
        LDA $C527, Y : STA $1CF2
        LDA $C528, Y : STA $1CF3
        
        LDA.b #$4E
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA.b #$01 : STA $02E4
        
        RTS
    }

; ==============================================================================

    ; *$3455D-$3456F BRANCH LOCATION
    {
        SEP #$30
    
    ; *$3455F ALTERNATE ENTRY POINT
    
        LDA.b #$4C
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

    ; *$34570-$3459E JUMP LOCATION
    {
        LDA $1CE8 : ADD $0DC0, X : TAY
        
        LDA $C527, Y : STA $1CF3
        
        REP #$20
        
        LDA $C523, Y : AND.w #$00FF : STA $00
        
        LDA $7EF360 : CMP $00 : BCC BRANCH_$3455D
        
        SEP #$30
        
        LDA $00 : STA $0DE0, X
        
        TYA : STA $0EB0, X
        
        INC $0D80, X
        
        RTS
    }

    ; *$3459F-$34602 JUMP LOCATION
    {
        LDA.b #$50 : STA $0DF0, X
        
        LDA $0DE0, X : STA $00 : STZ $01
        
        REP #$20
        
        LDA $7EF360 : SUB $00 : STA $7EF360
        
        SEP #$30
        
        LDA $7EF36A : ADD $00 : STA $7EF36A
        
        PHX
        
        LDA $0EB0, X
        
        JSL AddHappinessPondRupees
        
        PLX
        
        LDA $7EF36A : CMP.b #$64 : BCC BRANCH_ALPHA
        
        SBC.b #$64 : STA $7EF36A
        
        LDA.b #$05 : STA $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA $7EF36A
        
        STZ $02
    
    BRANCH_GAMMA:
    
        CMP.b #$0A : BCC BRANCH_BETA
        
        SBC.b #$0A
        
        INC $02
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        ASL $02 : ASL $02 : ASL $02 : ASL $02
        
        ORA $02 : STA $1CF2 : INC $0D80, X
        
        RTS
    }

    ; *$34603-$34615 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA.b #$94
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$0D : STA $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$34616-$34664 JUMP LOCATION
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$72
        
        JSL Sprite_SpawnDynamically
        
        LDA.b #$1B : STA $012C
        
        STZ $0133
        
        LDA $00 : SUB $C83A  : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : SUB $C83B  : STA $0D00, Y
        LDA $03 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$01 : STA $0DA0, Y
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        JSL PaletteFilter_WishPonds
        
        PLX
        
        TYA : STA $0E90, X
    
    .delay
    
        RTS
    }

    ; *$34665-$34690 JUMP LOCATION
    {
        LDA $1A : AND.b #$07 : BNE BRANCH_ALPHA
        
        PHX
        
        JSL Palette_Filter_SP5F
        
        PLX
        
        LDA $7EC007 : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        LDA.b #$95
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        PHX
        
        JSL Palette_RevertTranslucencySwap
        
        STZ $1D
        
        LDA,b #$20 : STA $9A
        
        INC $15
        
        PLX
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$34691-$3469F JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$0C : STA $0D80, X
        
        RTS
    }

    ; *$346A0-$346D1 JUMP LOCATION
    {
        INC $0D80, X
        
        LDA $7EF370 : CMP.b #$07 : BEQ BRANCH_ALPHA
        
        INC A : STA $7EF370
        
        PHX
        
        TAX
        
        LDA $0DDB40, X : STA $1CF2 : STA $7EF375
        
        PLX
        
        LDA.b #$96
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$98
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        JMP $C752   ; $34752 IN ROM
    }

    ; *$346D2-$346E6 JUMP LOCATION
    {
        INC $0D80, X
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        
        LDA.b #$02 : STA $1D
        
        LDA.b #$30 : STA $9A
        
        INC $0015
        
        PLX
        
        RTS
    }

    ; *$346E7-$3470D JUMP LOCATION
    {
        LDA $1A : AND.b #$07 : BNE BRANCH_ALPHA
        
        PHX
        
        JSL Palette_Filter_SP5F
        
        PLX
        
        LDA $7EC007 : CMP.b #$1E : BNE BRANCH_BETA
        
        LDA $0E90, X : TAY
        
        LDA.b #$00 : STA $0DD0, Y
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        CMP.b #$00 : BNE BRANCH_ALPHA
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$3470E-$34720 JUMP LOCATION
    {
        PHX
        
        JSL Palette_Restore_SP5F
        JSL Palette_RevertTranslucencySwap
        
        PLX
        
        STZ $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

    ; *$34721-$34762 JUMP LOCATION
    {
        LDA.b #$09 : STA $0D80, X
        
        LDA $7EF371 : CMP.b #$07 : BEQ BRANCH_ALPHA
        
        INC A : STA $7EF371
        
        PHX
        
        TAX
        
        LDA $0DDB50, X : STA $1CF2 : STA $7EF376
        
        PLX
        
        LDA.b #$97
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$98
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
    
    ; *$34752 ALTERNATE ENTRY POINT
    
        REP #$20
        
        LDA $7EF360 : ADD.w #$0064 : STA $7EF360
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$34763-$3476E JUMP LOCATION
    {
        LDA.b #$54
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $3476F-$3477A DATA
    pool HappinessPond_GrantLuckStatus:
    {
    
    .message_ids_lower
        db $50, $51, $52, $53
    
    .message_ids_upper
        db $01, $01, $01, $01
    
    .luck_statuses
        db 1, 0, 0, 2
    }

; ==============================================================================

    ; *$3477B-$347A0 JUMP LOCATION
    HappinessPond_GrantLuckStatus:
    {
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA .luck_statuses, Y : STA $0CF9
                                STZ $0CFA
        
        LDA .message_ids_lower, Y       : XBA
        LDA .message_ids_upper, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$347A1-$347C5 JUMP LOCATION
    {
        STZ $02E4
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS BRANCH_ALPHA
        
        LDA.b #$4A
        LDY.b #$01
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC BRANCH_ALPHA
        
        INC $0D80, X
        
        JSL Player_ResetState
        
        STZ $2F
        STZ $0EB0, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$347C6-$347EC JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        LDA.b #$8A
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA.b #$01 : STA $02E4
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$4B
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

    ; *$347ED-$34839 JUMP LOCATION
    {
        INC $0D80, X : PHX
        
        LDA $1CE8 : STA $0DB0, X : TAX
        ASL A : TAY
        
        LDA $C3DD, Y : STA $00
        LDA $C3DE, Y : STA $01
        
        LDA $7EF340, X : PHA
        
        CPX.b #$20 : BEQ BRANCH_ALPHA
        CPX.b #$03 : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA.b #$01
    
    BRANCH_BETA:
    
        TAY
        
        LDA.b #$00 : STA $7EF340, X
        
        LDA ($00), Y : PHA : TAX
        
        LDY.b #$04
        LDA.b #$28
        
        JSL AddWishPondItem
        JSL HUD.RefreshIconLong
        
        PLA : PLY : PLX
        
        STA $0DC0, X
        
        TYA : STA $0DE0, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; $3483A-$3483B DATA
    {
    
    ; \task Name the routines that use these locations.
    ; \wtf Why not just use immediates for this instead of a data pool? It's
    ; not indexed.
    .x_offset
        db 0
    
    .y_offset
        db 80
    }

; ==============================================================================

    ; *$3483C-$3488A JUMP LOCATION
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$72 : JSL Sprite_SpawnDynamically
        
        LDA.b #$1B : STA $012C
        
        STZ $0133
        
        LDA $00 : SUB $C83A  : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : SUB $C83B  : STA $0D00, Y
        LDA $03 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$01 : STA $0DA0, Y
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        JSL PaletteFilter_WishPonds
        
        PLX
        
        TYA : STA $0E90, X
    
    .delay
    
        RTS
    }

    ; *$3488B-$348B6 JUMP LOCATION
    {
        LDA $1A : AND.b #$07 : BNE BRANCH_ALPHA
        
        PHX
        
        JSL Palette_Filter_SP5F
        
        PLX
        
        LDA $7EC007 : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        LDA.b #$8B
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        PHX
        
        JSL Palette_RevertTranslucencySwap
        
        STZ $1D
        
        LDA.b #$20 : STA $9A
        
        INC $15
        
        PLX
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$348B7-$348C5 JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA #$0B : STA $0D80, X
        
        RTS
    }

    ; *$348C6-$34951 JUMP LOCATION
    {
        INC $0D80, X
        
        LDA $7EF3CA : BNE BRANCH_ALPHA
        
        LDA $0DC0, X : CMP.b #$0C : BNE BRANCH_BETA
        
        LDA.b #$2A : STA $0DC0, X
        
        LDA.b #$01 : STA $0EB0, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        CMP.b #$04 : BNE BRANCH_DELTA
        
        LDA.b #$05 : STA $0DC0, X
        LDA.b #$02 : STA $0EB0, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        CMP #$16 : BNE BRANCH_EPSILON
        
        LDA.b #$2C : STA $0DC0, X
        LDA.b #$03 : STA $0EB0, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_EPSILON:
    
        BRA BRANCH_ZETA
    
    BRANCH_ALPHA:
    
        LDA $0DC0, X : CMP.b #$3A : BNE BRANCH_THETA
        
        LDA.b #$3B : STA $0DC0, X
        LDA.b #$04 : STA $0EB0, X
        
        LDA.b #$4F
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    
    BRANCH_THETA:
    
        CMP.b #$02 : BNE BRANCH_IOTA
        
        LDA.b #$03 : STA $0DC0, X
        LDA.b #$05 : STA $0EB0, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_IOTA:
    
        CMP #$16 : BNE BRANCH_KAPPA
        
        LDA.b #$2C : STA $0DC0, X
        LDA.b #$03 : STA $0EB0, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_KAPPA:
    
        BRA BRANCH_ZETA
    
    BRANCH_GAMMA:
    
        LDA.b #$8C
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    
    BRANCH_ZETA:
    
        LDA.b #$4D
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    }

    ; *$34952-$34979 JUMP LOCATION
    {
        LDA $0DE0, X : TAY
        
        LDA $0DB0, X
        
        PHX
        
        TAX
        
        TYA
        
        CPX.b #$03
        
        BNE BRANCH_ALPHA
        
        STA $7EF340, X
    
    BRANCH_ALPHA:
    
        PLX
        
        INC $0D80, X
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        
        LDA.b #$02 : STA $1D
        
        LDA.b #$30 : STA $9A
        
        INC $0015
        
        PLX
        
        RTS
    }

    ; *$3497A-$349A0 JUMP LOCATION
    {
        LDA $1A : AND.b #$07 : BNE BRANCH_ALPHA
        
        PHX
        
        JSL Palette_Filter_SP5F
        
        PLX
        
        LDA $7EC007 : CMP.b #$1E : BNE BRANCH_BETA
        
        LDA $0E90, X : TAY
        
        LDA.b #$00 : STA $0DD0, Y
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        CMP.b #$00 : BNE BRANCH_ALPHA
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$349A1-$349BD JUMP LOCATION
    {
        INC $0D80, X
        
        PHX
        
        JSL Palette_Restore_SP5F
        JSL Palette_RevertTranslucencySwap
        
        PLX
        PHX
        
        LDA.b #$02 : STA $02E9
        
        LDA $0DC0, X : TAY
        
        JSL Link_ReceiveItem
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $349BE-$349C7 DATA
    {
    
    ; \task Name the routines that use these locations.
    .message_ids_low
        db $8F, $90, $92, $91, $93
    
    .message_ids_high
        db $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$349C8-$349E4 JUMP LOCATION
    {
        LDA $0EB0, X : BEQ BRANCH_ALPHA
        
        DEC A : TAY
        
        LDA .message_ids_low, Y        : XBA
        LDA .message_ids_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
    
    BRANCH_ALPHA:
    
        STZ $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$349E5-$349F0 JUMP LOCATION
    {
        INC $0D80, X
        
        LDA.b #$8D
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    }

; ==============================================================================

    ; *$349F1-$349FF JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$06 : STA $0D80, X
        
        RTS
    }

    ; *$34A00-$34A0D JUMP LOCATION
    {
        LDA.b #$8E
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$07 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $34A0E-$34B25 DATA
    pool FaerieQueen_Draw:
    {
    
    .x_offsets
        db  0, 16,  0,  8, 16, 24,  0,  8
        db 16, 24,  0, 16,  0, 16,  0,  8
        db 16, 24,  0,  8, 16, 24,  0, 16
    
    .y_offsets
        db  0,  0, 16, 16, 16, 16, 24, 24
        db 24, 24, 32, 32,  0,  0, 16, 16
        db 16, 16, 24, 24, 24, 24, 32, 32
    
    .chr
        db $C7, $C7, $CF, $CA, $CA, $CF, $DF, $DA
        db $DA, $DF, $CB, $CB, $CD, $CD, $C9, $CA
        db $CA, $C9, $D9, $DA, $DA, $D9, $CB, $CB
    
    .properties
        db $00, $40, $00, $00, $40, $40, $00, $00
        db $40, $40, $00, $40, $00, $40, $00, $00
        db $40, $40, $00, $00, $40, $40, $00, $40
    
    .oam_sizes
        db $02, $02, $00, $00, $00, $00, $00, $00
        db $00, $00, $02, $02, $02, $02, $00, $00
        db $00, $00, $00, $00, $00, $00, $02, $02
    
    .oam_groups
        dw  0,  0 : db $E9, $00, $00, $02
        dw 16,  0 : db $E9, $40, $00, $02
        dw  0,  0 : db $E9, $00, $00, $02
        dw 16,  0 : db $E9, $40, $00, $02
        dw  0,  0 : db $E9, $00, $00, $02
        dw 16,  0 : db $E9, $40, $00, $02
        dw  0, 16 : db $EB, $00, $00, $02
        dw 16, 16 : db $EB, $40, $00, $02
        dw  0, 32 : db $ED, $00, $00, $02
        dw 16, 32 : db $ED, $40, $00, $02
        
        dw  0,  0 : db $EF, $00, $00, $00
        dw 24,  0 : db $EF, $40, $00, $00
        dw  0,  8 : db $FF, $00, $00, $00
        dw 24,  8 : db $FF, $40, $00, $00
        dw  0,  0 : db $E9, $00, $00, $02
        dw 16,  0 : db $E9, $40, $00, $02
        dw  0, 16 : db $EB, $00, $00, $02
        dw 16, 16 : db $EB, $40, $00, $02
        dw  0, 32 : db $ED, $00, $00, $02
        dw 16, 32 : db $ED, $40, $00, $02
    }

; ==============================================================================

    ; *$34B26-$34BA1 LOCAL
    FaerieQueen_Draw:
    {
        LDA $7EF3CA : BNE .in_dark_world
        
        JSR Sprite_PrepOamCoord
        
        LDA $0DC0, X : ASL #2 : STA $0D
        
        LDA $0DC0, X : ASL #3 : ADC $0D : STA $06
        
        PHX
        
        LDX.b #$0B
    
    .next_oam_entry
    
        PHX
        
        TXA : ADD $06 : TAX
        
        LDA $00 : ADD $CA0E, X       : STA ($90), Y
        LDA $02 : ADD $CA26, X : INY : STA ($90), Y
        
        LDA $CA3E, X            : INY : STA ($90), Y
        LDA $CA56, X : ORA $05  : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $CA6E, X : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        LDY.b #$FF
        LDA.b #$0B
        
        JSR Sprite_CorrectOamEntries
        
        RTS
    
    .in_dark_world
    
        LDA.b #$0A : STA $06
                     STZ $07
        
        LDA $0DC0, X : ASL #2 : ADC $0DC0, X : ASL #4
        
        ; references $34A86
        ADC.b #.oam_groups                 : STA $08
        LDA.b #.oam_groups>>8 : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.quantity_preset
        
        RTS
    }

; ==============================================================================
