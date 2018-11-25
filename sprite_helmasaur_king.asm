
; ==============================================================================

    ; \task These might need reinitialization, we should check up on what their
    ; specific function is.
    ; *$F0000-$F0038 LONG
    HelmasaurKing_Initialize:
    {
        LDA.b #$30 : STA $0B2F
        
        LDA.b #$80 : STA $0B2D
        
        STZ $0B2E
        STZ $0B30
        STZ $0B33
        STZ $0B31
        STZ $0B32

    ; *$F0019 ALTERNATE ENTRY POINT
    shared HelmasaurKing_Reinitialize:

        PHB : PHK : PLB : PHX
        
        LDA $0E80, X : STA $00
        
        LDY.b #$03
    
    .next_whatever
    
        LDA $00 : ADD $829C, Y : AND.b #$1F : TAX
        
        LDA $827C, X : STA $0B08, Y
        
        DEY : BPL .next_whatever
        
        PLX : PLB
        
        RTL
    }

; ==============================================================================

    ; *$F0039-$F0109 JUMP LOCATION
    Sprite_HelmasaurKing:
    {
        LDA $0DB0, X : BPL BRANCH_ALPHA
        
        LDA $0DF0, X : BEQ BRANCH_BETA
        DEC A        : BNE BRANCH_BETA
        
        STZ $0DD0, X
    
    BRANCH_BETA:
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        LDA $1A : AND.b #$07 : ORA $0E00, X : BNE BRANCH_GAMMA
        
        LDA $0F50, X : EOR.b #$40 : STA $0F50, X
    
    BRANCH_GAMMA:
    
        JSR Sprite3_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL BRANCH_DELTA
        
        STZ $0F70, X
        
        LDA.b #$0C : STA $0DF0, X
        LDA.b #$18 : STA $0F80, X
        LDA.b #$06 : STA $0DC0, X
    
    BRANCH_DELTA:
    
        RTS
    
    BRANCH_ALPHA:
    
        CMP.b #$03 : BCS BRANCH_EPSILON
        
        LDA $0B89, X : AND.b #$F1 : STA $0B89, X
        
        LDA.b #$0A : STA $0B6B, X
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        LDA.b #$1F : STA $0F60, X
        LDA.b #$02 : STA $0B6B, X
    
    BRANCH_ZETA:
    
        JSR $853B   ; $F053B IN ROM
        
        LDA $0DD0, X : CMP.b #$06 : BNE BRANCH_$F0117
        
        LDA $0DF0, X : BNE BRANCH_THETA
        
        LDA.b #$04 : STA $0DD0, X
        
        STZ $0D90, X
        
        LDA.b #$E0 : STA $0DF0, X
        
        RTS
    
    BRANCH_THETA:
    
        PHA
        
        ORA.b #$F0 : STA $0EF0, X
        
        PLA : CMP.b #$80 : BCS BRANCH_IOTA
        
        AND.b #$07 : BNE BRANCH_IOTA
        
        LDY $0B33 : CPY.b #$10 : BEQ BRANCH_IOTA
        
        INC $0B33
        
        STZ $00
        
        LDA $0B0D, Y : BPL BRANCH_KAPPA
        
        DEC $00
    
    BRANCH_KAPPA:
    
        ADD $0D10, X : STA $0FD8
        
        LDA $0D30, X : ADC $00 : STA $0FD9
        
        STZ $00
        
        LDA $0B1D, Y : BPL BRANCH_LAMBDA
        
        DEC $00
    
    BRANCH_LAMBDA:
    
        ADD $0D00, X : STA $0FDA
        
        LDA $0D20, X : ADC $00 : STA $0FDB
        
        JSL Sprite_MakeBossDeathExplosion
    
    BRANCH_IOTA:
    
        RTS
    }

; ==============================================================================

    ; $F010A-$F0116 DATA
    {
    
    .unknown
        db $03, $03, $03, $03, $03, $03, $03, $03
        db $02, $02, $01, $01, $00
    }

; ==============================================================================

    ; *$F0117-$F018B BRANCH LOCATION
    {
        JSR Sprite3_CheckIfActive
        
        LDA $0E50, X : LSR #2 : TAY
        
        LDA $810A, Y : STA $0DB0, X : CMP.b #$03 : BNE BRANCH_ALPHA
        
        CMP $0E90, X : BEQ BRANCH_BETA
        
        STZ $0EF0, X
        
        JSR $848C ; $F048C IN ROM
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        CMP $0E90, X : BEQ BRANCH_BETA
        
        JSR $847E ; $F047E IN ROM
    
    BRANCH_BETA:
    
        LDA $0DB0, X : STA $0E90, X
        
        JSL Sprite_CheckDamageFromPlayerLong
        JSR $82A0 ; $F02A0 IN ROM
        JSR $83EB ; $F03EB IN ROM
        JSR $8385 ; $F0385 IN ROM
        
        LDA $0E00, X : BEQ BRANCH_GAMMA
        CMP.b #$60   : BEQ BRANCH_DELTA
        
        RTS
    
    BRANCH_GAMMA:
    
        LDA $0E10, X : BEQ BRANCH_EPSILON
        CMP.b #$40   : BNE BRANCH_ZETA
        
        JSR $8517 ; $F0517 IN ROM
        
        LDA $0DB0, X : CMP.b #$03 : BCC BRANCH_ZETA
    
    BRANCH_DELTA:
    
        LDA $0EC0, X : BNE BRANCH_ZETA
        
        INC $0EC0, X
        
        LDA.b #$20 : STA $0EE0, X
    
    BRANCH_ZETA:
    
        RTS
    
    BRANCH_EPSILON:
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $819C ; = $F019C*
        dw $81D5 ; = $F01D5*
        dw $8210 ; = $F0210*
        dw $8242 ; = $F0242*
    }

    ; *$F019C-$F01D4 JUMP LOCATION
    {
        LDA $0EF0, X : BNE BRANCH_ALPHA
        
        LDA $0DF0, X : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        JSR $8253 ; $F0253 IN ROM
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $818C, Y : STA $0D50, X
        LDA $8194, Y : STA $0D40, X
        
        LDA.b #$40 : STA $0DF0, X
        
        LDA $0DB0, X : CMP.b #$03 : BCC BRANCH_GAMMA
        
        ASL $0D50, X
        ASL $0D40, X
        
        LSR $0DF0, X
    
    BRANCH_GAMMA:
    
        INC $0D80, X
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$F01D5-$F01E5 JUMP LOCATION
    {
        JSR $81E6 ; $F01E6 IN ROM
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA.b #$20 : STA $0DF0, X
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }


    ; *$F01E6-$F01FF LOCAL
    {
        JSR $8200 ; $F0200 IN ROM
        
        LDA $1A : AND.b #$03 : BNE BRANCH_ALPHA
        
        JSR $8200 ; $F0200 IN ROM
    
    BRANCH_ALPHA:
    
        LDA $0DB0, X : CMP.b #$03 : BCC BRANCH_BETA
        
        JSR $8200 ; $F0200 IN ROM
    
    BRANCH_BETA:
    
        JSR Sprite3_Move
        
        RTS
    }


    ; *$F0200-$F020F LOCAL
    {
        INC $0E80, X : LDA $0E80, X : AND.b #$0F : BNE BRANCH_ALPHA
        
        LDA.b #$21 : STA $012E
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F0210-$F0241 JUMP LOCATION
    {
        LDA $0EF0, X : BNE BRANCH_ALPHA
        
        LDA $0DF0, X : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        JSR $8253 ; $F0253 IN ROM
        
        LDA #$40 : STA $0DF0, X
        
        LDA $0E90, X : CMP.b #$03 : BCC BRANCH_GAMMA
        
        LSR $0DF0, X
    
    BRANCH_GAMMA:
    
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        INC $0D80, X
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$F0242-$F0252 JUMP LOCATION
    {
        JSR $81E6 ; $F01E6 IN ROM
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        STZ $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F0253-$F027B LOCAL
    {
        INC $0E30, X
        
        LDA $0E30, X : CMP.b #$04 : BNE BRANCH_ALPHA
        
        PLA : PLA
        
        STZ $0E30, X
        
        JSL GetRandomInt : AND.b #$01 : BEQ BRANCH_BETA
        
        LDA.b #$7F : STA $0E10, X
        
        LDA.b #$2A : JSL Sound_SetSfx3PanLong
        
        RTS
    
    BRANCH_BETA:
    
        LDA.b #$A0 : STA $0E00, X
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $F029C-$F029F DATA
    pool HelmasaurKing_Initialize:
    {
        db 0, 8, 16, 24
    }

; ==============================================================================

    ; *$F02A0-$F0326 LOCAL
    {
        INC $0B0C
        
        JSL HelmasaurKing_Reinitialize
        
        LDA.b #$01
        
        LDY $0EC0, X : BEQ BRANCH_ALPHA
        
        LDA.b #$00
    
    BRANCH_ALPHA:
    
        AND $1A : BNE BRANCH_BETA
        
        LDA $0DE0, X : AND.b #$01 : TAY
        
        LDA $0B30 : ADD $8383, Y : STA $0B30
        
        CMP Sprite3_Shake.x_speeds, Y : BNE BRANCH_GAMMA
        
        INC $0DE0, X
    
    BRANCH_GAMMA:
    
        LDY.b #$00
        
        LDA $0B30 : BPL BRANCH_DELTA
        
        DEY
    
    BRANCH_DELTA:
    
        ADD $0B2D : STA $0B2D
        
        TYA : ADC $0B2E : AND.b #$FF : STA $0B2E
    
    BRANCH_BETA:
    
        LDA $0EC0, X : BEQ BRANCH_EPSILON
        
        LDA $0B30 : BNE BRANCH_ZETA
        
        LDA.b #$06 : JSL Sound_SetSfx3PanLong
    
    BRANCH_ZETA:
    
        LDA $0EC0, X
        
        CMP.b #$02 : BEQ BRANCH_$F032D
        CMP.b #$03 : BEQ BRANCH_$F0357
        
        LDA $0B30 : ORA $0EE0, X : BNE BRANCH_$F0382 ; (RTS)
        
        LDA $0B2E : AND.b #$01 : STA $0EB0, X
        
        JSR Sprite3_IsToRightOfPlayer
        
        TYA : EOR.b #$01 : CMP $0EB0, X : BNE BRANCH_EPSILON
        
        INC $0EC0, X
        
        JSL Sound_SetSfxPan : ORA.b #$26 : STA $012F
    
    BRANCH_EPSILON:
    
        RTS
    }

    ; *$F032D-$F0356 BRANCH LOCATION
    {
        LDY $0EB0, X
        
        LDA $0B31 : ADD $8327, Y : STA $0B31 : PHA
        LDA $0B32 : ADC $8329, Y  : STA $0B32
        
        PLA : CMP $832B, Y : BNE BRANCH_ALPHA
        
        INC $0EC0, X
    
    BRANCH_ALPHA:
    
        LDA $0B2F : ADD.b #$03 : STA $0B2F
        
        RTS
    }

    ; *$F0357-$F0382 BRANCH LOCATION
    {
        LDA $0EB0, X : EOR.b #$01 : TAY
        
        LDA $0B31 : ADD $8327, Y : STA $0B31 : PHA
        LDA $0B32 : ADC $8329, Y : STA $0B32
        
        PLA : CMP.b #$00 : BNE BRANCH_ALPHA
        
        STZ $0EC0, X
    
    BRANCH_ALPHA:
    
        LDA $0B2F : SUB.b #$03 : STA $0B2F
        
        RTS
    }

; ==============================================================================

    ; $F0383-$F0384 DATA
    {
    
    ; \task Name this routine / pool
    .unknown_0
        db 1, -1
    }

; ==============================================================================

    ; *$F0385-$F03EA LOCAL
    {
        LDA $0DB0, X : CMP.b #$03 : BCS BRANCH_ALPHA
        
        LDA $0301 : AND.b #$0A : BEQ BRANCH_ALPHA
        
        LDA $44 : CMP.b #$80 : BEQ BRANCH_ALPHA
        
        JSL Player_SetupActionHitBoxLong
        
        LDA $0D00, X : PHA : ADD.b #$08 : STA $0D00, X
        
        JSL Sprite_SetupHitBoxLong
        
        PLA : STA $0D00, X
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC BRANCH_ALPHA
        
        DEC $0E50, X
        
        LDA.b #$21 : STA $012F
        
        LDA.b #$30
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : STA $27
        LDA $01 : STA $28
        
        LDA.b #$08 : STA $0046
        
        LDA $0FAC : BNE BRANCH_BETA
        
        LDA $00 : STA $0FAD
        LDA $01 : STA $0FAE
        
        LDA.b #$05 : STA $0FAC
    
    BRANCH_BETA:
    
        LDA.b #$05 : JSL Sound_SetSfx2PanLong
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F03EB-$F0419 LOCAL
    {
        LDA $1A : AND.b #$07 : BNE BRANCH_ALPHA
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0024 : CMP.w #$0048 : BCS BRANCH_ALPHA
        
        LDA $20 : SUB $0FDA : ADD.w #$0028 : CMP.w #$0040 : BCS BRANCH_ALPHA
        
        SEP #$20
        
        JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        RTS
    }

    ; *$F047E-$F04A9 LOCAL
    {
        LDA $0DB0, X : ADD.b #$07 : STA $0FB5
        
        JSR $84AA ; $F04AA IN ROM
        
        BRA BRANCH_ALPHA
    
    ; *$F048C ALTERNATE ENTRY POINT
    
        LDY.b #$0F
        LDA.b #$00
    
    BRANCH_BETA:
    
        STA $0DD0, Y
        
        DEY : BNE BRANCH_BETA
        
        LDA.b #$07 : STA $0FB5
    
    BRANCH_GAMMA:
    
        JSR $84AA ; $F04AA IN ROM
        
        DEC $0FB5 : BPL BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        LDA.b #$1F : JSL Sound_SetSfx2PanLong
        
        RTS
    }

    ; *$F04AA-$F0516 LOCAL
    {
        ; I think this can spawn all of parts of the Helmasaur King's mask
        ; flying off due to damage...
        LDA.b #$92 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        LDX $0FB5
        
        LDA $00 : ADD $842E, X : STA $0D10, Y
        LDA $01 : ADC $8438, X : STA $0D30, Y
        
        LDA $02 : ADD $841A, X : STA $0D00, Y
        LDA $03 : ADC $8424, X : STA $0D20, Y
        
        LDA $8442, X : STA $0F70, Y
        LDA $844C, X : STA $0D50, Y
        LDA $8456, X : STA $0D40, Y
        LDA $8460, X : STA $0F80, Y
        
        LDA $846A, X : ORA.b #$0D : STA $0F50, Y
        
        LDA $8474, X : STA $0DC0, Y
        
        LDA.b #$80 : STA $0DB0, Y
        ASL A      : STA $0E40, Y
        
        LDA.b #$0C : STA $0E00, Y : STA $0BA0, Y
        
        LDA $0FB5 : STA $0E30, Y
        
        PLX
    
    .spawn_failed
    
        RTS
    }

    ; *$F0517-$F053A LOCAL
    {
        ; Spawn helmasaur king fireball...
        LDA.b #$70 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $02 : ADD.b #$1C : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$20 : STA $0DF0, Y : STA $0BA0, Y
    
    .spawn_failed
    
        RTS
    }

    ; *$F053B-$F055E LOCAL
    {
        REP #$20
        
        LDA.w #$089C : STA $90
        LDA.w #$0A47 : STA $92
        
        SEP #$20
        
        JSR Sprite3_PrepOamCoord
        JSR $8920 ; $F0920 IN ROM
        JSR $856B ; $F056B IN ROM
        JSR $8686 ; $F0686 IN ROM
        JSR $87E5 ; $F07E5 IN ROM
        JSR $8805 ; $F0805 IN ROM
        JSR $88BC ; $F08BC IN ROM
        
        RTS
    }

; ==============================================================================

    ; $F055F-$F056A DATA
    {
    
    ; \task Name this routine / pool.
    .x_offsets
        db -3, 11
    
    .chr
        db $CE, $CF, $DE, $DE, $DE, $DE, $CF, $CE
    
    .properties
        db $3B, $7B
    }

; ==============================================================================

    ; *$F056B-$F05C5 LOCAL
    {
        REP #$20
        
        LDA $90 : ADD.w #$0040 : STA $90
        LDA $92 : ADD.w #$0010 : STA $92
        
        SEP #$20
        
        PHX
        
        LDY.b #$00
        LDX.b #$01
    
    BRANCH_ALPHA:
    
        PHX
        
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        LDA $02 : ADD.b #$14        : INY : STA ($90), Y
        
        LDA $0B0C : LSR #2 : AND.b #$07 : TAX
        
        LDA .chr, X : INY : STA ($90), Y
        
        PLX
        
        LDA .properties, X : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL BRANCH_ALPHA
        
        PLX
        
        LDA $11 : BEQ BRANCH_BETA
        
        LDY.b #$00
        LDA.b #$01
        
        JSL Sprite_CorrectOamEntriesLong
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$F0686-$F06E4 LOCAL
    {
        LDA.b #$00 : XBA
        
        LDA $0DB0, X
        
        REP #$20
        
        ASL #6 : ADC.w #$85C6 : STA $08
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        LDA $0DB0, X : CMP.b #$03 : BCS BRANCH_ALPHA
        
        LDA.b #$08
        
        JSR Sprite3_DrawMultiple
        
        REP #$20
        
        LDA $90 : ADD.w #$0020 : STA $90
        LDA $92 : ADD.w #$0008 : STA $92
        
        SEP #$20
        
        LDA $0F10, X : BEQ BRANCH_BETA
    
    BRANCH_ALPHA:
    
        RTS
    
    BRANCH_BETA:
    
        LDY.b #$01
    
    .nextSlot
    
        LDA $0C4A, Y : CMP.b #$07 : BNE .notBomb
        
        LDA $0C2C, Y : ORA $0C22, Y : BEQ BRANCH_GAMMA
        
        JSR $86E5   ; $F06E5 IN ROM
    
    .notBomb
    BRANCH_GAMMA:
    
        DEY : BPL .nextSlot
        
        RTS
    }

    ; *$F06E5-$F074C LOCAL
    {
        ; Helmasaur king checking for proximity between exploding bombs and its mask, probably
        
        JSL Sprite_SetupHitBoxLong
        
        LDA $0C04, Y : ADD.b #$06 : STA $00
        LDA $0C18, Y : ADC.b #$00 : STA $08
        
        LDA $0BFA, Y : SUB $029E, Y : STA $01
        LDA $0C0E, Y : SBC.b #$00   : STA $09
        
        LDA.b #$02 : STA $02
        LDA.b #$0F : STA $03
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC BRANCH_ALPHA
        
        LDA $0C2C, Y : EOR.b #$FF : INC A : STA $0C2C, Y
        LDA $0C22, Y : EOR.b #$FF : INC A : STA $00
        
        ASL $00 : ROR A : STA $0C22, Y
        
        LDA.b #$20 : STA $0F10, X
        
        LDA.b #$05 : STA $0FAC
        
        LDA $0C04, Y : STA $0FAD
        
        LDA $0BFA, Y : SUB $029E, Y : STA $0FAE
        
        ; Make "clink against wall" noise
        LDA.b #$05 : STA $012E
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F07E5-$F07F4 LOCAL
    {
        REP #$20
        
        LDA.w #$874D : STA $08
        
        SEP #$20
        
        LDA.b #$13
    
    ; *$F07F0 ALTERNATE ENTRY POINT
    shared Sprite3_DrawMultiple:
    
        JSL Sprite_DrawMultiple
        
        RTS
    }

    ; *$F0805-$F089B LOCAL
    {
        REP #$20
        
        LDA $90 : ADD.w #$004C : STA $90
        
        LDA $92 : ADD.w #$0013 : STA $92
        
        SEP #$20
        
        PHX
        
        LDY.b #$00
        
        LDA.b #$03 : STA $0FB5
    
    BRANCH_ALPHA:
    
        LDX $0FB5
        
        LDA $00 : ADD $87F5, X : STA ($90), Y
        
        LDA $02 : ADD $87F9, X : ADD $0B08, X : INY : STA ($90), Y
        LDA $87FD, X                          : INY : STA ($90), Y
        LDA $8801, X : EOR $05                : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        LDA $00 : ADD $87F5, X : STA ($90), Y
        
        LDA $02 : ADD $87F9, X : ADD.b #$10 : ADD $0B08, X : INY : STA ($90), Y
        LDA $87FD, X : ADD.b #$02                          : INY : STA ($90), Y
        LDA $8801, X : EOR $05                             : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        DEC $0FB5 : BPL BRANCH_ALPHA
        
        PLX
        
        LDA $11 : BEQ BRANCH_BETA
        
        LDY.b #$02
        LDA.b #$07
        
        JSL Sprite_CorrectOamEntriesLong
        JSR Sprite3_PrepOamCoord
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$F08BC-$F08EF LOCAL
    {
        LDA $0E10, X : BEQ BRANCH_ALPHA
        
        LSR #2 : TAY
        
        LDA $889C, Y : STA $06
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
        
        LDY.b #$00
        
        LDA $00                                 : STA ($90), Y
        LDA $02    : ADD.b #$13 : ADC $06 : INY : STA ($90), Y
        LDA.b #$AA                        : INY : STA ($90), Y
        LDA $05    : EOR.b #$0B           : INY : STA ($90), Y
        
        LDA.b #$02 : STA ($92)
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $F08F0-$F091F DATA
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$F0920-$F0A84 LOCAL
    {
        STZ $0FB5
    
    ; *$F0923 ALTERNATE ENTRY POINT
    
        LDY $0FB5 : PHY
        
        LDA $0EC0, X : BEQ BRANCH_ALPHA
        
        TYA : ADD.b #$10 : TAY
    
    BRANCH_ALPHA:
    
        REP #$20
        
        LDA $0B2D : ADD $0B31 : STA $0D
        
        SEP #$20
        
        LDA $0E : CMP.b #$01
        
        PHP
        
        PHP : LDA $0D : PLP : BPL BRANCH_BETA
        
        EOR.b #$FF : INC A
    
    BRANCH_BETA:
    
        STA $4202
        
        LDA $88F0, Y : STA $4203
        
        JSR Sprite3_DivisionDelay
        
        LDA $4217 : PLP : BPL BRANCH_GAMMA
        
        EOR.b #$FF
    
    BRANCH_GAMMA:
    
        STA $06
        
        LDA $0E : STA $07
        
        PLY
        
        LDA $0B2F    : STA $4202
        LDA $8910, Y : STA $4203
        
        JSR Sprite3_DivisionDelay
        
        LDA $4217 : STA $0F
        
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
        
        LDY $0B : BNE BRANCH_DELTA
        
        STA $4203
        
        JSR Sprite3_DivisionDelay
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_DELTA:
    
        LSR $07 : BCC BRANCH_EPSILON
        
        EOR.b #$FF : INC A
    
    BRANCH_EPSILON:
    
        LDY $0FB5
        
        STA $0B0D, Y
        
        LDA $0C : STA $4202
        
        LDA $0F
        
        LDY $0D : BNE BRANCH_ZETA
        
        STA $4203
        
        JSR Sprite3_DivisionDelay
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_ZETA:
    
        LSR $09 : BCC BRANCH_THETA
        
        EOR.b #$FF : INC A
    
    BRANCH_THETA:
    
        LDY $0FB5
        
        SUB.b #$28 : STA $0B1D, Y
        
        INC $0FB5 : LDA $0FB5 : CMP.b #$10 : BEQ BRANCH_IOTA
        
        JMP $8923 ; $F0923 IN ROM
    
    BRANCH_IOTA:
    
        LDA $0EC0, X : STA $0A
        
        STZ $0F
        
        PHX
        
        LDX $0B33 : CPX.b #$10 : BEQ BRANCH_KAPPA
        
        LDY.b #$00
    
    BRANCH_NU:
    
        LDA $00 : ADD $0B0D, X       : STA ($90), Y : STA $08
        LDA $02 : ADD $0B1D, X : INY : STA ($90), Y : STA $09
        
        LDA.b #$AC
        
        CPY.b #$01 : BNE BRANCH_LAMBDA
        
        LDA.b #$E4
    
    BRANCH_LAMBDA:
    
                               INY : STA ($90), Y
        LDA $05 : EOR.b #$1B : INY : STA ($90), Y
        
        INY
        
        TXA : EOR $1A : AND.b #$00 : ORA $031F : BNE BRANCH_MU
        
        LDA $0A : BEQ BRANCH_MU
        
        LDA $22 : SBC $E2 : SBC $08 : ADC.b #$0C : CMP.b #$18 : BCS BRANCH_MU
        
        LDA $20
        SBC $E8
        ADC #$08
        SBC $09
        ADC #$08
        CMP #$10 : BCS BRANCH_MU
        
        INC $0F
        
        STZ $28
        
        LDA.b #$38 : STA $27
    
    BRANCH_MU:
    
        INX : CPX.b #$10 : BNE BRANCH_NU
    
    BRANCH_KAPPA:
    
        PLX
        
        LDA $0F : BEQ BRANCH_XI
        
        LDA $0FFC : BNE BRANCH_XI
        
        JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
    
    BRANCH_XI:
    
        LDY.b #$02
        LDA.b #$0F
        
        JSL Sprite_CorrectOamEntriesLong
        JSR Sprite3_PrepOamCoord
        
        RTS
    }

; ==============================================================================
