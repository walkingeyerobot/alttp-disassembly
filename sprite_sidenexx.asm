
; ==============================================================================

    ; *$EB897-$EB92A JUMP LOCATION
    {
        ; One of the two side heads?
        
        LDA $0E90, X : BEQ BRANCH_ALPHA
        
        JMP $BDC6 ; $EBDC6 IN ROM
    
    ; *$EB89F ALTERNATE ENTRY POINT
    
        ; One of the two side heads?
        
        LDA $0E90, X : BEQ BRANCH_ALPHA
        
        JMP $BD28 ; $EBD28 IN ROM
    
    BRANCH_ALPHA:
    
        LDA $0E20, X : SUB.b #$CC : TAY
        
        LDA $0D90 : ADD $B88A, Y : STA $0D90, X
        LDA $0DA0 : ADC $B88C, Y : STA $0DA0, X
        
        LDA $0DB0 : SUB.b #$20 : STA $0DB0, X
        LDA $0ED0 : SBC.b #$00 : STA $0ED0, X
        
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR $BB70 ; $EBB70 IN ROM
        JSR Sprite4_CheckIfActive
        
        LDA $0D80, X : BPL BRANCH_BETA
        
        STA $0BA0, X
        
        JMP $BB3F ; $EBB3F IN ROM
    
    BRANCH_BETA:
    
        LDA $0EF0, X : BEQ BRANCH_GAMMA
        
        LDA $0D80, X : CMP.b #$04 : BEQ BRANCH_GAMMA
        
        STZ $0EF0, X
        
        LDA.b #$80 : STA $0DF0, X
        LDA.b #$04 : STA $0D80, X
        
        LDA $0F50, X : STA $0F80, X
        
        LDA.b #$03 : STA $0F50, X
    
    BRANCH_GAMMA:
    
        JSR Sprite4_CheckDamage
        
        LDA $0CAA, X : ORA.b #$04 : STA $0CAA, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $B986 ; = $EB986*
        dw $B9A6 ; = $EB9A6*
        dw $B9F2 ; = $EB9F2*
        dw $BA70 ; = $EBA70*
        dw $B92B ; = $EB92B*
    }

    ; *$EB92B-$EB985 JUMP LOCATION
    {
        LDA $0CAA, X : AND.b #$FB : STA $0CAA, X
        
        STZ $0E30, X
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        PHA
        
        LDA.b #$01 : STA $0D80, X
        LDA.b #$20 : STA $0DF0, X
        
        LDA $0F80, X : STA $0F50, X
        
        STZ $0EF0, X
        
        PLA

    BRANCH_ALPHA:

        CMP.b #$0F : BCC BRANCH_BETA
        CMP.b #$4E : BCS BRANCH_GAMMA
        CMP.b #$3F : BCC BRANCH_GAMMA
        
        LDA $0E20, X : CMP.b #$CD : BNE BRANCH_DELTA
        
        PHX
        
        JSL PaletteFilter_IncreaseTrinexxBlue
        
        PLX
        
        RTS

    BRANCH_DELTA:

        PHX
        
        JSL PaletteFilter_IncreaseTrinexxRed
        
        PLX

    BRANCH_GAMMA:

        RTS

    BRANCH_BETA:

        LDA $0E20, X : CMP.b #$CD : BNE BRANCH_EPSILON
        
        PHX
        
        JSL PaletteFilter_RestoreTrinexxBlue
        
        PLX
        
        RTS

    BRANCH_EPSILON:

        PHX
        
        JSL PaletteFilter_RestoreTrinexxRed
        
        PLX
        
        RTS
    }

    ; *$EB986-$EB9A5 JUMP LOCATION
    {
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA.b #$02 : STA $0D80, X
        LDA.b #$09 : STA $0E80, X
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$EB9A6-$EB9F1 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA $0DE0, X : STA $00
        
        JSL GetRandomInt : AND.b #$07 : INC A : CMP.b #$05 : BCS BRANCH_ALPHA
        
        CMP $0DE0, X : BEQ BRANCH_ALPHA
        
        STA $0DE0, X
        
        INC $0D80, X
        
        LDA $00 : CMP.b #$01 : BNE BRANCH_ALPHA
        
        JSL GetRandomInt : LSR A : BCS BRANCH_ALPHA
        
        LDA $0D80 : CMP.b #$02 : BCS BRANCH_ALPHA
        
        INC $0DC0, X : LDA $0DC0, X : CMP.b #$06
        
        NOP #2
        
        STZ $0DC0, X
        
        LDA.b #$03 : STA $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$EB9F2-$EBA66 JUMP LOCATION
    {
        STZ $01
        
        LDA $0DE0, X : ASL #3 : ADC $0DE0, X : TAY
        
        LDA $BB6D, X : PHX : TAX
        
        LDA.b #$08 : STA $00
    
    BRANCH_IOTA:
    
        LDA $1D10, X : CMP $B830, Y : BEQ BRANCH_ALPHA : BPL BRANCH_BETA
        
        INC $1D10, X
        
        INC $01
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        DEC $1D10, X
        
        INC $01
    
    BRANCH_ALPHA:
    
        LDA $1D10, X : CMP $B830, Y : BEQ BRANCH_GAMMA : BPL BRANCH_DELTA
        
        INC $1D10, X
        
        INC $01
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        DEC $1D10, X
        
        INC $01
    
    BRANCH_GAMMA:
    
        LDA $1A : AND.b #$00 : BNE BRANCH_EPSILON
        
        LDA $1D50, X : CMP $B85D, Y : BEQ BRANCH_ZETA : BPL BRANCH_THETA
        
        INC $1D50, X
        
        INC $01
        
        BRA BRANCH_ZETA
    
    BRANCH_THETA:
    
        DEC $1D50, X
    
    BRANCH_EPSILON:
    
        INC $01
    
    BRANCH_ZETA:
    
        INX
        
        INY
        
        DEC $00 : BPL BRANCH_IOTA
        
        PLX
        
        LDA $01 : BNE BRANCH_KAPPA
        
        DEC $0D80, X
        
        JSL GetRandomInt : AND.b #$0F : STA $0DF0, X
    
    BRANCH_KAPPA:
    
        RTS
    }

    ; *$EBA70-$EBAE5 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        STZ $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS
    
    BRANCH_ALPHA:
    
        CMP.b #$40 : BNE BRANCH_BETA
        
        PHA
        
        JSR $BAE8   ; $EBAE8 IN ROM
        
        PLA
    
    BRANCH_BETA:
    
        CMP.b #$08              : BCC BRANCH_GAMMA
        CMP.b #$79 : LDA.b #$08 : BCC BRANCH_GAMMA
        
        LDA $0DF0, X : ADD.b #$80 : EOR.b #$FF
    
    BRANCH_GAMMA:
    
        STA $0E30, X
        
        LDA $0DF0, X : CMP.b #$40 : BCC BRANCH_DELTA
        
        SUB.b #$40 : LSR #3 : TAY
        
        LDA $1A : AND $BA68, Y : BNE BRANCH_DELTA
        
        JSL GetRandomInt : AND.b #$0F : LDY.b #$00 : SUB.b #$03
                                                      STA $00 : BPL BRANCH_EPSILON
        
        DEY
    
    BRANCH_EPSILON:
    
        STY $01
        
        JSL GetRandomInt : AND.b #$0F : ADD.b #$0C : STA $02 : STZ $03
        
        JSL Sprite_SpawnSimpleSparkleGarnish
        
        LDA $0E20, X : CMP.b #$CC : BNE BRANCH_DELTA
        
        PHX
        
        LDX $0F
        
        LDA.b #$0E : STA $7FF800, X
        
        PLX
    
    BRANCH_DELTA:
    
        RTS
    }

; ==============================================================================

    ; $EBAE6-$EBAE7 DATA
    {
    
    ; \task Name this routine / pool
    .x_accelerations
        db -2, 1
    }

; ==============================================================================

    ; *$EBAE8-$EBB3E LOCAL
    {
        LDA $0E20, X : CMP.b #$CD : BNE BRANCH_ALPHA
        
        STZ $0FB6
        
        JSR $BAFA   ; $EBAFA IN ROM
        
        INC $0FB6
        
        LDA.b #$CD
    
    ; *$EBAFA ALTERNATE ENTRY POINT
    
        JSL Sprite_SpawnDynamically : BMI BRANCH_BETA
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        LDX $0FB6
        
        LDA .x_accelerations, X : STA $0DB0, Y
        
        PLX
        
        LDA.b #$19 : JSL Sound_SetSfx3PanLong
        
        BRA BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        JSL Sprite_SpawnDynamically : BMI BRANCH_BETA
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$2A : JSL Sound_SetSfx2PanLong
    
    BRANCH_GAMMA:
    
        LDA.b #$01 : STA $0E90, Y
                     STA $0BA0, Y
        
        LDA.b #$18 : STA $0D40, Y
        
        LDA.b #$00 : STA $0E40, Y
        
        LDA.b #$40 : STA $0E60, Y
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$EBB3F-$EBB6C LOCAL
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA.b #$0C : STA $0DF0, X
        
        LDA $0E80, X : CMP.b #$01 : BNE BRANCH_BETA
        
        STZ $0DD0, X
    
    BRANCH_BETA:
    
        DEC $0E80, X
        
        LDA $0FD8 : ADD $E2 : STA $0FD8
        
        LDA $0FDA : ADD $E8 : STA $0FDA
        
        JSL Sprite_MakeBossDeathExplosion
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $EBB6D-$EBB6F DATA
    {
    
    ; \task Apply labels to this pool / routine.
        db 0, 9, 18
    }

; ==============================================================================

    ; *$EBB70-$EBC8B LOCAL
    {
        LDA $0D90, X : STA $0D10, X
        
        LDA $0DA0, X : STA $0D30, X
        
        LDA $0DB0, X : STA $0D00, X
        
        LDA $0ED0, X : STA $0D20, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        JSR Sprite4_PrepOamCoord
        
        STZ $0FB5
        STZ $0FB6
    
    ; *$EBB95 ALTERNATE ENTRY POINT
    
        LDY $0FB5
        
        TYA : ADD $BB6D, X : TAY
        
        CPX.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $1D10, Y : EOR.b #$FF : INC A : STA $06
        LDA.b #$01                        : STA $07
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $1D10, Y : STA $06 : STZ $07
    
    BRANCH_BETA:
    
        LDA $1D50, Y : STA $0F
        
        PHX
        
        REP #$30
        
        LDA $06 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $0A
        
        LDA $06 : ADD.w #$0080 : STA $08
        
        AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $0C
        
        SEP #$30
        
        PLX
        
        LDA $0A : STA $4202
        
        LDA $0F
        
        LDY $0B : BNE BRANCH_GAMMA
        
        STA $4203
        
        NOP #8
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_GAMMA:
    
        LSR $07 : BCC BRANCH_DELTA
        
        EOR.b #$FF : INC A
    
    BRANCH_DELTA:
    
        STA $0FA8
        
        LDA $0C : STA $4202
        
        LDA $0F
        
        LDY $0D : BNE BRANCH_EPSILON
        
        STA $4203
        
        NOP #8
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_EPSILON:
    
        LSR $09 : BCC BRANCH_ZETA
        
        EOR.b #$FF : INC A
    
    BRANCH_ZETA:
    
        STA $0FA9
        
        LDA $0FB5 : BNE BRANCH_THETA
        
        JSR $BCA0   ; $EBCA0 IN ROM
        
        BRA BRANCH_IOTA
    
    BRANCH_THETA:
    
        LDA $00 : ADD $0FA8 : LDY $0FB6       : STA ($90), Y : STA $0FD8
        LDA $0FA9 : ADD $02 : LDY $0FB6 : INY : STA ($90), Y : STA $0FDA
        LDA.b #$08                      : INY : STA ($90), Y
        LDA $05                         : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY : STY $0FB6
    
    BRANCH_IOTA:
    
        INC $0FB5 : LDA $0FB5 : CMP $0E80, X : BEQ BRANCH_KAPPA
        
        JMP $BB95   ; $EBB95 IN ROM
    
    BRANCH_KAPPA:
    
        LDA $11 : BEQ BRANCH_LAMBDA
        
        LDY.b #$02
        LDA.b #$04
        
        JSL Sprite_CorrectOamEntriesLong
    
    BRANCH_LAMBDA:
    
        RTS
    }

    ; *$EBCA0-$EBD25 LOCAL
    {
        LDA $0E30, X : STA $08
        
        PHX
        
        LDX.b #$00
        
        LDY $0FB6
    
    BRANCH_BETA:
    
        LDA $0FA8 : ADD $00 : STA $0FD8
        
        ADD $BC8C, X : STA ($90), Y
        
        LDA $0FA9 : ADD $02 : STA $0FDA
        
        ADD $BC91, X
        
        CPX.b #$04 : BNE BRANCH_ALPHA
        
        ADD $08
    
    BRANCH_ALPHA:
    
                                      INY : STA ($90), Y
        LDA $BC96, X                : INY : STA ($90), Y
        LDA $05      : ORA $BC9B, X : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        INX : CPX.b #$05 : BNE BRANCH_BETA
        
        PLX
        
        LDA $0FB6 : ADD.b #$14 : STA $0FB6
        
        LDY.b #$00
        
        LDA $0FA8 : BPL BRANCH_GAMMA
        
        DEY
    
    BRANCH_GAMMA:
    
              ADD $0D90, X : STA $0D10, X
        TYA : ADC $0DA0, X : STA $0D30, X
        
        LDY.b #$00
        
        LDA $0FA9 : BPL BRANCH_DELTA
        
        DEY
    
    BRANCH_DELTA:
    
              ADD $0DB0, X : STA $0D00, X
        TYA : ADC $0ED0, X : STA $0D20, X
        
        RTS
    }

; ==============================================================================

    ; $EBD26-$EBD27 DATA
    {
    
    ; \task Name this routine / pool.
    .x_speed_targets
        db 16, -16
    }

; ==============================================================================

    ; *$EBD28-$EBD64 LOCAL
    {
        JSL Sprite_PrepOamCoordLong
        JSR Sprite4_CheckIfActive
        
        LDA $0D50, X : PHA : ADD $0DB0, X : STA $0D50, X
        
        JSR Sprite4_Move
        
        PLA : STA $0D50, X
        
        JSR $BD65 ; $EBD65 IN ROM
    
    ; *$EBD44 ALTERNATE ENTRY POINT
    
        LDA $1A : AND.b #$03 : BNE BRANCH_ALPHA
        
        JSR Sprite4_IsToRightOfPlayer
        
        LDA $0D50, X : CMP .x_speed_targets, Y : BEQ BRANCH_ALPHA
        
        ADD $8000, Y : STA $0D50, X
    
    BRANCH_ALPHA:
    
        JSR Sprite4_CheckTileCollision : BEQ BRANCH_BETA
        
        STZ $0DD0, X
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$EBD65-$EBDC5 LOCAL
    {
        INC $0E80, X
        
        LDA $0E80, X : AND.b #$07 : BNE BRANCH_ALPHA
        
        LDA.b #$14 : JSL Sound_SetSfx3PanLong
        
        PHX : TXY
        
        LDX.b #$1D
    
    BRANCH_GAMMA:
    
        LDA $7FF800, X : BEQ BRANCH_BETA
        
        DEX : BPL BRANCH_GAMMA
        
        DEC $0FF8 : BPL BRANCH_DELTA
        
        LDA.b #$1D : STA $0FF8
    
    BRANCH_DELTA:
    
        LDX $0FF8
    
    BRANCH_BETA:
    
        LDA.b #$0C : STA $7FF800, X : STA $0FB4
        
        TYA : STA $7FF92C, X
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$7F : STA $7FF90E, X
        
        PLX
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$EBDC6-$EBE3B JUMP LOCATION
    {
        JSL Sprite_PrepOamCoordLong
        JSR Sprite4_CheckIfActive
        JSR Sprite4_Move
        JSR $BDD6   ; $EBDD6 IN ROM
        JMP $BD44   ; $EBD44 IN ROM
    
    ; *$EBDD6 ALTERNATE ENTRY POINT
    
        INC $0E80, X : LDA $0E80, X : AND.b #$07 : BNE BRANCH_ALPHA
        
        LDA.b #$2A : JSL Sound_SetSfx2PanLong
        
        LDA.b #$1D
    
    ; *$EBDE8 ALTERNATE ENTRY POINT
    
        PHX : TXY
        
        TAX : STA $00
    
    BRANCH_GAMMA:
    
        LDA $7FF800, X : BEQ BRANCH_BETA
        
        DEX : BPL BRANCH_GAMMA
        
        DEC $0FF8 : BPL BRANCH_DELTA
        
        LDA $00 : STA $0FF8
    
    BRANCH_DELTA:
    
        LDX $0FF8
    
    BRANCH_BETA:
    
        LDA.b #$10 : STA $7FF800, X : STA $0FB4
        
        TYA : STA $7FF92C, X
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$7F : STA $7FF90E, X
        
        STX $00
        
        PLX
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================
