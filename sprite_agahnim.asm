
; ==============================================================================

    ; $F5310-$F532F DATA
    {
    
        ; \task Split up and name labels later.
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $05, $05, $00, $01, $01, $04
        db $04, $00, $02, $02, $04, $04, $03, $02
        db $02, $02, $0A, $08, $00, $04, $06, $FA    
        
    }

; ==============================================================================

    ; *$F5330-$F536E JUMP LOCATION
    Sprite_Agahnim:
    {
        JSR $D978 ; $F5978 IN ROM
        
        LDA $0F00, X : BEQ BRANCH_ALPHA
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA.b #$00 : STA $0DC0, X
        
        LDA.b #$03 : STA $0DE0, X
    
    BRANCH_ALPHA:
    
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $D4EC ; = $F54EC*
        dw $D4F6 ; = $F54F6*
        dw $D524 ; = $F5524*
        dw $D566 ; = $F5566*
        dw $D630 ; = $F5630*
        dw $D708 ; = $F5708*
        dw $D45E ; = $F545E*
        dw $D47C ; = $F547C*
        dw $D3DA ; = $F53DA*
        dw $D408 ; = $F5408*
        dw $D376 ; = $F5376*
    }

; ==============================================================================

    ; $F536F-$F5375 DATA
    {
    
    ; \task Name this routine / pool.
    .animation_states
        db 0, 8, 10, 2, 2, 6, 4
    }

; ==============================================================================

    ; *$F5376-$F53D9 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA ; Is the timer still going?
        
        ; Time is done. Kill Agahnim.
        PHX
        
        STZ $0DD0, X
        
        JSL PrepDungeonExit
        
        PLX
    
    BRANCH_ALPHA:
    
        ; If Timer > #$10, branch
        LDA $0DF0, X : CMP.b #$10 : BCS BRANCH_BETA
        
        LDA.b #$7F : STA $9A
        
        LDA.b #$06 : STA $1C
        LDA.b #$10 : STA $1D
        
        PHX
        
        JSL Palette_Filter_SP5F
        
        PLX
    
    BRANCH_BETA:
    
        LDA $0DF0, X : AND.b #$00 : BNE BRANCH_GAMMA
        
        LDA $0F80, X : CMP.b #$FF : BEQ BRANCH_GAMMA
        
        ADD.b #$01 : STA $0F80, X
    
    BRANCH_GAMMA:
    
        LDA $0F90, X : ADD $0F80, X : STA $0F90, X : BCC BRANCH_DELTA
        
        INC $0E80, X : LDA $0E80, X : CMP.b #$07 : BNE BRANCH_DELTA
        
        STZ $0E80, X
        
        LDA.b #$04 : JSL Sound_SetSfx2PanLong
    
    BRANCH_DELTA:
    
        LDY $0E80, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F53DA-$F5407 JUMP LOCATION
    {
        LDA.b #$02 : STA $0FFC
        
        STZ $0EB0, X
        
        LDA $0DF0, X : CMP.b #$40 : BCC BRANCH_ALPHA
        
        LDA $0EF0, X : ORA.b #$E0 : STA $0EF0, X
        
        RTS
    
    BRANCH_ALPHA:
    
        CMP.b #$01 : BNE BRANCH_BETA
        
        JSL Sprite_SpawnPhantomGanon
        
        LDA.b #$1D : STA $012C
    
    BRANCH_BETA:
    
        STZ $0EF0, X
        
        LDA.b #$11 : STA $0DC0, X
        
        RTS
    }

    ; *$F5408-$F545D JUMP LOCATION
    {
        STZ $0EB0, X
        
        LDA $0D10 : STA $04
        LDA $0D30 : STA $05
        
        LDA $0D00 : STA $06
        LDA $0D20 : STA $07
        
        REP #$20
        
        LDA $0FD8 : SUB $04 : ADD.w #$0004 : CMP.w #$0008 : BCS BRANCH_ALPHA
        
        LDA $0FDA : SUB $06 : ADD.w #$0004 : CMP.w #$0008 : BCS BRANCH_ALPHA
        
        SEP #$20
        
        STZ $0DD0, X
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        LDA.b #$20
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        JSR Sprite3_Move
        JSL Sprite_SpawnAgahnimAfterImage
        
        RTS
    }

; ==============================================================================

    ; *$F545E-$F5479 JUMP LOCATION
    {
        LDA $0DF0, X : BNE .delay
        
        ; "I'm very happy to see you again... but you better believe we will"
        ; "will not have a third meeting! ..."
        LDA.b #$41 : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        INC $0D80, X
        
        LDA.b #$50 : STA $0DF0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F547A-$F547B DATA
    {
    
    .x_speeds
        db 32, -32
    }

; ==============================================================================

    ; *$F547C-$F54A6 JUMP LOCATION
    {
        LDA $0EC0, X : BEQ BRANCH_$F54A9
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        JMP $D509 ; $F5509 IN ROM
    
    BRANCH_ALPHA:
    
        ; Each of the clones has its own x speed at the start... I guess
        ; that's what is going on here.
        LDA $D479, X : STA $0D50, X
        
        ; And speed up the y velocity.
        LDA $0D40, X : ADD.b #$02 : STA $0D40, X
        
        JSR Sprite3_Move
        
        JSL Sprite_SpawnAgahnimAfterImage : BMI BRANCH_BETA
        
        LDA.b #$04 : STA $0F50, Y
    
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; $F54A7-$F54A8 DATA
    {
    
    ; \task Name this routine / pool.
    .special_properties
        db $09, $0B
    }

; ==============================================================================

    ; *$F54A9-$F54E9 BRANCH LOCATION
    {
        LDA $0DF0, X : BNE .ai_transition_delay
        
        JMP $D509 ; $F5509 IN ROM
    
    .ai_transition_delay
    
        CMP.b #$40 : BNE .cloning_delay
        
        LDA.b #$28 : STA $012F
        
        LDA.b #$01 : STA $0FB5
    
    .clone_spawn_loop
    
        LDA.b #$7A
        LDY.b #$02
        
        JSL Sprite_SpawnDynamically.arbitrary
        JSL Sprite_SetSpawnedCoords
        
        LDA .special_properties, Y : STA $0E60, Y
        
        AND.b #$0F : STA $0F50, Y : STA $0EC0, Y
        
        LDA $0D80, X : STA $0D80, Y
        
        LDA.b #$20 : STA $0DF0, Y
        
        DEC $0FB5 : BPL .clone_spawn_loop
    
    .cloning_delay
    
        RTS
    }

; ==============================================================================

    ; $F54EA-$F54EB DATA
    {
    
    .ai_states
        db 1, 6
    }

; ==============================================================================

    ; *$F54EC-$F54F5 JUMP LOCATION
    {
        LDY $0FFF
        
        LDA .ai_states, Y : STA $0D80, X
        
        RTS
    }

    ; *$F54F6-$F5513 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_F551E ; (RTS)
        
        LDA.b #$3F : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
    
    ; *$F5509 ALTERNATE ENTRY POINT
    
        LDA.b #$03 : STA $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS
    }

    ; *$F5514-$F551E LOCAL
    {
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$27 : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; $F551F-$F5523 DATA
    {
    
    ; \task Name this pool / routine.
    .animation_states
        db 12, 13, 14, 15, 16, 
    }

; ==============================================================================

    ; *$F5524-$F553F JUMP LOCATION
    {
        STZ $0FF8
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F5540-$F5565 DATA
    {
    
    ; \task Name this pool / routine.
    ; $F5540
        db 0, 0, 0, 0, 0, 0, 0, 1
        db 1, 1, 1, 1, 1, 1, 0, 0
    
    ; $F5550
        db 0, 0, 0, 0, 0, 0, 0, 6
        db 5, 4, 3, 2, 1, 0, 0, 0
    
    ; $F5560
        db $1E, $18, $0C, $00, $06, $12
    }

; ==============================================================================

    ; *$F5566-$F560A JUMP LOCATION
    {
        LDA $0DF0, X : CMP.b #$C0 : BNE BRANCH_ALPHA
        
        PHA
        
        LDA.b #$27 : JSL Sound_SetSfx3PanLong
        
        PLA
    
    BRANCH_ALPHA:
    
        CMP.b #$EF : BCS BRANCH_BETA
        CMP.b #$10 : BCS BRANCH_GAMMA
    
    BRANCH_BETA:
    
        PHX
        
        LDA.b $0FFF : BNE .inDarkWorld
        
        ; apparently Agahnim is only in sprite slot 0x01 (of 0x10) in the 
        ; light world
        LDX.b #$02
    
    .inDarkWorld
    
        JSL PaletteFilter_Agahnim
        
        PLX
        
        BRA BRANCH_EPSILON
    
    BRANCH_GAMMA:
    
        TXA : BNE BRANCH_EPSILON
        
        JSR Sprite3_CheckDamage
        
        STZ $0BA0, X
    
    BRANCH_EPSILON:
    
        LDA $0DF0, X : BNE BRANCH_ZETA
        
        INC $0D80, X
        
        LDA.b #$27 : STA $0DF0, X
        
        RTS
    
    BRANCH_ZETA:
    
        CMP.b #$80 : BCC BRANCH_THETA
        
        PHA
        
        LDA.b #$02
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDY $01
        
        LDA $00 : ADD.b #$02 : STA $02
        
        ASL #2 : ADC $02 : ADC.b #$02 : ADD $01 : TAY
        
        LDA $D310, Y : STA $0DE0, X
        
        LDA.b #$20 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA $0E30, X : CMP.b #$04 : BNE BRANCH_IOTA
        
        LDA.b #$03 : STA $0DE0, X
    
    BRANCH_IOTA:
    
        PLA
    
    BRANCH_THETA:
    
        CMP.b #$70 : BNE BRANCH_KAPPA
        
        PHA
        
        JSR $D67A ; $F567A IN ROM
        
        PLA
    
    BRANCH_KAPPA:
    
        LSR #4 : TAY
        
        LDA $D540, Y : STA $0D90, X
        
        LDA $D550, Y : BEQ BRANCH_LAMBDA
        
        CLC
        
        LDY $0DE0, X
        
        ADC $D560, Y
    
    BRANCH_LAMBDA:
    
        STA $0EB0, X
        
        LDY $0DE0, X
        
        LDA $D329, Y : ADD $0D90, X : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F560B-$F562F DATA
    {
    
    ; \task Name this routine / pool.
    .animation_states
        db 16, 15, 14, 13, 12
    
    .unknown_0
        db $38, $38, $38, $58, $78, $98, $B8, $B8
        db $B8, $98, $58, $58, $60, $90, $98, $78
    
    .unknown_1
        db $B8, $78, $58, $48, $48, $48, $58, $78
        db $B8, $B8, $B8, $90, $70, $70, $90, $A0
    }

; ==============================================================================

    ; *$F5630-$F5667 JUMP LOCATION
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        INC $0D80, X
        
        LDY.b #$04
        
        LDA $0E30, X : CMP.b #$04 : BEQ BRANCH_BETA
        
        JSL GetRandomInt : AND.b #$0F : TAY
    
    BRANCH_BETA:
    
        LDA $D610, Y : STA $0DB0, X
        LDA $D620, Y : STA $0E90, X
        
        LDA.b #$08 : STA $0ED0, X
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA $D60B, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F5668-$F5679 DATA
    {
    
    ; \task Name this routine / pool.
    .x_offsets_low
        db  0, 10,  8,  0, -10, -10
    
    .x_offsets_high
        db  0,  0,  0,  0,  -1,  -1
    
    .y_offsets_low
        db -9, -2, -2, -9,  -2,  -2
    }

; ==============================================================================

    ; *$F567A-$F5707 LOCAL
    {
        CPX.b #$00 : BNE BRANCH_ALPHA
        
        INC $0E30, X
        
        LDA $0FFF : BEQ BRANCH_ALPHA
        
        LDA $0E30, X : AND.b #$03 : STA $0E30, X
    
    BRANCH_ALPHA:
    
        LDA $0E30, X : CMP.b #$05 : BNE BRANCH_BETA
        
        STZ $0E30, X
        
        LDA.b #$26 : JSL Sound_SetSfx3PanLong
        
        JSR $D6A1 ; $F56A1 IN ROM
    
    ; *$F56A1 ALTERNATE ENTRY POINT
    
        JSL Sprite_SpawnLightning
        JSL Sprite_SpawnLightning
        
        RTS
    
    BRANCH_BETA:
    
        LDA.b #$7B
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$29 : JSL Sound_SetSfx3PanLong
        
        PHX
        
        LDA $0DE0, X : TAX
        
        LDA $00 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X : STA $0D00, Y
        LDA $03 : ADC.b #$FF   : STA $0D20, Y
                                 STA $0BA0, Y
        
        PLX
        
        LDA $0D50, X : STA $0D50, Y
        LDA $0D40, X : STA $0D40, Y
        
        LDA $0E30, X : CMP.b #$02 : BCC BRANCH_GAMMA
        
        JSL GetRandomInt : AND.b #$01 : BNE BRANCH_GAMMA
        
        LDA.b #$01 : STA $0DA0, Y
        LDA.b #$20 : STA $0DF0, Y
    
    BRANCH_GAMMA:
    .spawn_failed
    
        RTS
    }

    ; *$F5708-$F577E JUMP LOCATION
    {
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
                       STA $05
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
                       STA $07
        
        LDA $0DB0, X : STA $04
        LDA $0E90, X : STA $06
        
        REP #$20
        
        LDA $00 : SUB $04 : ADD.w #$0007 : CMP.w #$000E : BCS BRANCH_ALPHA
        LDA $02 : SUB $06 : ADD.w #$0007 : CMP.w #$000E : BCS BRANCH_ALPHA
        
        SEP #$20
        
        LDA $0DB0, X : STA $0D10, X
        LDA $0E90, X : STA $0D00, X
        
        JMP $D514 ; $F5514 IN ROM
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        LDA $0ED0, X
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        LDA $0ED0, X : CMP.b #$40 : BCS BRANCH_BETA
        
        INC $0ED0, X
    
    BRANCH_BETA:
    
        JSR Sprite3_Move
        
        RTS
    }

; ==============================================================================

    ; $F577F-$f5977 DATA
    {
    
        ; \task Fill in data later.
    }

; ==============================================================================

    ; *$F5978-$F5A41 LOCAL
    {
        JSR Sprite3_PrepOamCoord
        
        LDA $0DC0, X : ASL #2 : STA $06
        
        PHX
        
        LDX.b #$03
    
    BRANCH_BETA:
    
        PHX
        
        TXA : ADD $06 : TAX
        
        LDA $00      : ADD $D77F, X       : STA ($90), Y
        LDA $02      : ADD $D7C7, X : INY : STA ($90), Y
        LDA $D80F, X                : INY : STA ($90), Y
        LDA $D857, X : ORA $05      : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02
        
        CPX.b #$44 : BCS BRANCH_ALPHA
        CPX.b #$40 : BCC BRANCH_ALPHA
        
        LDA.b #$00
    
    BRANCH_ALPHA:
    
        STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL BRANCH_BETA
        
        PLX
        
        LDA $0DC0, X : CMP.b #$0C : BCS BRANCH_GAMMA
        
        LDA.b #$12
        
        JSL Sprite_DrawShadowLong.variable
    
    BRANCH_GAMMA:
    
        LDA $11 : BEQ BRANCH_DELTA
        
        LDY.b #$FF
        LDA.b #$03
        
        JSL Sprite_CorrectOamEntriesLong
    
    BRANCH_DELTA:
    
        JSR Sprite3_PrepOamCoord
        
        LDA.b #$08
        
        LDY $0DE0, X : BEQ BRANCH_EPSILON
        
        JSL OAM_AllocateFromRegionC
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        JSL OAM_AllocateFromRegionB
    
    BRANCH_ZETA:
    
        LDY.b #$00
        
        LDA $0EB0, X : BEQ BRANCH_THETA
        
        DEC A : STA $0C
        
        ASL A : STA $06
        
        LDA $1A : LSR A : AND.b #$02 : INC #2 : ORA.b #$31 : STA $0D
        
        PHX
        
        LDX.b #$01
    
    BRANCH_IOTA:
    
        PHX
        
        TXA : ADD $06 : TAX
        
        LDA $00 : ADD $D89F, X       : STA ($90), Y
        LDA $02 : ADD $D8E7, X : INY : STA ($90), Y
        
        LDX $0C
        
        LDA $D92F, X : INY : STA ($90), Y
        
        INY
        
        LDA $0D : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $D953, X : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL BRANCH_IOTA
        
        PLX
    
    BRANCH_THETA:
    
        RTS
    }

; ==============================================================================
