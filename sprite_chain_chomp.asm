
; ==============================================================================

    ; $EBE3C-$EBE43 DATA
    pool SpritePrep_ChainChomp:
    {
    
    .extended_subsprite_offsets
        db $00, $10, $20, $30, $40, $50, $60, $70
    }


; ==============================================================================

    ; *$EBE44-$EBE7C LONG
    SpritePrep_ChainChomp:
    {
        PHX
        
        LDY.b #$05
        
        LDA.l .extended_subsprite_offsets, X : TAX
        
        REP #$20
    
    .next_slot
    
        LDA $0FD8 : STA $7FFC00, X
        LDA $0FDA : STA $7FFD00, X
        
        INX #2
        
        DEY : BPL .next_slot
        
        SEP #$20
        
        PLX
        
        LDA $0D10, X : STA $0D90, X
        LDA $0D30, X : STA $0DA0, X
        
        LDA $0D00, X : STA $0DB0, X
        LDA $0D20, X : STA $0ED0, X
        
        RTL
    }

; ==============================================================================

    ; *$EBE7D-$EBF09 JUMP LOCATION
    Sprite_ChainChomp:
    {
        JSR $C192 ; $EC192 IN ROM
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckDamage
        JSR $C0F2 ; $EC0F2 IN ROM
        
        TXA : EOR $1A : AND.b #$03 : BNE BRANCH_ALPHA
        
        LDA $0D50, X : STA $01
        
        LDA $0D40, X : STA $00 : ORA $01 : BEQ BRANCH_ALPHA
        
        JSL Sprite_ConvertVelocityToAngle : AND.b #$0F : STA $0DE0, X
    
    BRANCH_ALPHA:
    
        JSR Sprite4_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .didnt_bounce
        
        STZ $0F70, X
        STZ $0F80, X
    
    .didnt_bounce
    
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA $0D90, X : STA $00
        LDA $0DA0, X : STA $01
        
        LDA $0DB0, X : STA $02
        LDA $0ED0, X : STA $03
        
        STZ $0EC0, X
        
        REP #$20
        
        LDA $0FD8 : SUB $00 : ADD.w #$0030
        
        CMP.w #$0060 : BCS .too_far_from_origin
        
        LDA $0FDA : SUB $02 : ADD.w #$0030
        
        CMP.w #$0060 : BCS .too_far_from_origin
        
        SEP #$20
        
        INC $0EC0, X
    
    .too_far_from_origin
    
        SEP #$20
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $BF2C ; = $EBF2C*
        dw $BF95 ; = $EBF95*
        dw $BFE5 ; = $EBFE5*
    }

; ==============================================================================

    ; *$EBF2C-$EBF94 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INC $0E80, X : LDA $0E80, X : CMP.b #$04 : BNE BRANCH_BETA
        
        STZ $0E80, X
        
        LDA.b #$02 : STA $0D80, X
        
        JSL GetRandomInt : AND.b #$0F : TAY
        
        LDA $BF0C, Y : ASL #2 : STA $0D50, X
        
        LDA $BF1C, Y : ASL #2 : STA $0D40, X
        
        JSL GetRandomInt : AND.b #$00 : BNE BRANCH_GAMMA
        
        LDA #$40
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA.b #$04 : JSL Sound_SetSfx3PanLong
    
    BRANCH_GAMMA:
    
        RTS
    
    BRANCH_BETA:
    
        JSL GetRandomInt : AND.b #$1F : ADC.b #$10 : STA $0DF0, X
        
        JSL GetRandomInt : AND.b #$0F : TAY
        
        LDA $BF0C, Y : STA $0D50, X
        
        LDA $BF1C, Y : STA $0D40, X
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        JSR Sprite4_Zero_XY_Velocity
        
        RTS
    }

    ; *$EBF95-$EBFE4 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA.b #$20 : STA $0DF0, X
        
        STZ $0D80, X
    
    BRANCH_ALPHA:
    
        AND.b #$0F : BNE BRANCH_BETA
        
        JSR $C02A   ; $EC02A IN ROM
    
    BRANCH_BETA:
    
        LDA $0F70, X : BNE BRANCH_GAMMA
        
        LDA.b #$10 : STA $0F80, X
    
    BRANCH_GAMMA:
    
        LDA $0EC0, X : BNE BRANCH_DELTA
        
        LDA $0D90, X : STA $04
        LDA $0DA0, X : STA $05
        LDA $0DB0, X : STA $06
        LDA $0ED0, X : STA $07
        
        LDA.b #$10
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        JSR Sprite4_Move
        
        LDA.b #$0C : STA $0DF0, X
    
    BRANCH_DELTA:
    
        RTS
    }

    ; *$EBFE5-$EC01F JUMP LOCATION
    {
        LDA $0EC0, X : BNE BRANCH_ALPHA
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        JSR Sprite4_Move
        JSR Sprite4_Zero_XY_Velocity
        
        INC $0D80, X
        
        LDA.b #$30 : STA $0E00, X
    
    BRANCH_ALPHA:
    
        BRA BRANCH_BETA
    
    ; *$EC00C ALTERNATE ENTRY POINT
    
        LDA $0E00, X : BNE BRANCH_BETA
        
        STZ $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
    
    BRANCH_BETA:
    
        JSR $C02A   ; $EC02A IN ROM
        JSR $C02A   ; $EC02A IN ROM
        
        RTS
    }

; ==============================================================================

    ; $EC020-$EC029 DATA
    {
    
    
        dw 205, 154, 102,  51,   8
    }

; ==============================================================================

    ; *$EC02A-$EC0F1 LOCAL
    {
        LDA $0D90, X : STA $00
        LDA $0DA0, X : STA $01
        
        LDA $0DB0, X : STA $02
        LDA $0ED0, X : STA $03
        
        PHX
        
        LDA.b #$05 : STA $0D
        
        LDA $BE3C, X : TAX
        
        LDA $7FFC00, X : SUB $00 : STA $04
        LDA $7FFD00, X : SUB $02 : STA $05
        
        INX #2

    ; *$EC05B ALTERNATE ENTRY POINT

        LDA $04
        
        ; .... okay...?
        PHP
        
        BPL BRANCH_ALPHA
        
        EOR.b #$FF : INC A

    BRANCH_ALPHA:

        STA $4202
        
        PHX : TXA : AND.b #$0F : TAX
        
        LDA $C01E, X : STA $4203
        
        PLX
        
        NOP #7
        
        LDA $4217
        
        LDY.b #$00
        
        PLP : BPL BRANCH_BETA
        
        EOR.b #$FF
        
        DEY

    BRANCH_BETA:

              ADD $00 : STA $08
        TYA : ADC $01 : STA $09
        
        LDA $05
        
        PHP
        
        BPL BRANCH_GAMMA
        
        EOR.b #$FF : INC A

    BRANCH_GAMMA:

        STA $4202
        
        PHX
        
        TXA : AND.b #$0F : TAX
        
        LDA $C01E, X : STA $4203
        
        PLX
        
        NOP #7
        
        LDA $4217
        
        LDY.b #$00
        
        PLP : BPL BRANCH_DELTA
        
        EOR.b #$FF
        
        DEY

    BRANCH_DELTA:

              ADD $02 : STA $0A
        TYA : ADC $03 : STA $0B
        
        REP #$20
        
        LDA $7FFC00, X : CMP $08 : BEQ BRANCH_EPSILON : BPL BRANCH_ZETA
        
        INC #2

    BRANCH_ZETA:

        DEC A : STA $7FFC00, X

    BRANCH_EPSILON:

        LDA $7FFD00, X : CMP $0A : BEQ BRANCH_THETA : BPL BRANCH_IOTA
        
        INC #2

    BRANCH_IOTA:

        DEC A : STA $7FFD00, X

    BRANCH_THETA:

        SEP #$20
        
        INX #2
        
        DEC $0D : BMI BRANCH_KAPPA
        
        JMP $C05B ; $EC05B IN ROM

    BRANCH_KAPPA:

        PLX
        
        RTS
    }

    ; *$EC0F2-$EC171 LOCAL
    {
        PHX
        
        LDA $BE3C, X : TAX
        
        REP #$20
        
        STZ $00
        
        LDA $0FD8 : STA $7FFC00, X
        LDA $0FDA : STA $7FFD00, X
    
    BRANCH_EPSILON:
    
        LDA $7FFC00, X : SUB $7FFC02, X
        
        CMP.w #$0008 : BPL BRANCH_ALPHA
        CMP.w #$FFF8 : BPL BRANCH_BETA
        
        LDA $7FFC00, X : ADD.w #$0008 : STA $7FFC02, X
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $7FFC00, X : SUB.w #$0008 : STA $7FFC02, X
    
    BRANCH_BETA:
    
        LDA $7FFD00, X : SUB $7FFD02, X
        
        CMP.w #$0008 : BPL BRANCH_GAMMA
        CMP.w #$FFF8 : BPL BRANCH_DELTA
        
        LDA $7FFD00, X : ADD.w #$0008 : STA $7FFD02, X
        
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA $7FFD00, X : SUB.w #$0008 : STA $7FFD02, X
    
    BRANCH_DELTA:
    
        INX #2
        
        INC $00 : LDA $00 : CMP.w #$0006 : BCC BRANCH_EPSILON
        
        PLX
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $EC172-$EC191 DATA
    {
    
    .animation_states
        db 0, 1, 2, 3, 3, 3, 2, 1
        db 0, 0, 0, 4, 4, 4, 0, 0
    
    .h_flip
        db $40, $40, $40, $40, $00, $00, $00, $00
        db $00, $00, $00, $00, $40, $40, $40, $40
    }

; ==============================================================================

    ; *$EC192-$EC210 LOCAL
    {
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$3F : ORA .h_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        LDA $0E00, X : AND.b #$01 : ADD.b #$04 : STA $08 : STZ $09
        
        LDA.b #$05 : STA $0D
        
        PHX
        
        LDA $BE3C, X : TAX
        
        LDY.b #$04
    
    BRANCH_BETA:
    
        REP #$20
        
        LDA $7FFC00, X : ADD $08 : SUB $E2 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $7FFD00, X : ADD $08 : SUB $E8 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC BRANCH_ALPHA
        
        LDA.b #$F0 : STA ($90), Y
    
    BRANCH_ALPHA:
    
        LDA.b #$8B : INY : STA ($90), Y
        
        LDA $05 : AND.b #$F0 : ORA.b #$0D : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        INX #2
        
        DEC $0D : BPL BRANCH_BETA
        
        PLX
        
        RTS
    }

; ==============================================================================
