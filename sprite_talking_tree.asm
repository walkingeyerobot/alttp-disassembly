
; ==============================================================================

    ; *$EF943-$EF94A LONG
    Sprite_TalkingTreeLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_TalkingTree
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EF94B-$EF955 LOCAL
    Sprite_TalkingTree:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F956 ; = $EF956*
        dw $FB0A ; = $EFB0A*
    }

; ==============================================================================

    ; *$EF956-$EF96D JUMP LOCATION
    {
        JSR $FADB ; $EFADB IN ROM
        JSR Sprite4_CheckIfActive
        
        STZ $0F60, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F96E ; = $EF96E*
        dw $F99C ; = $EF99C*
        dw $F9B4 ; = $EF9B4*
        dw $F9E2 ; = $EF9E2*
    }

; ==============================================================================

    ; *$EF96E-$EF99B JUMP LOCATION
    {
        STZ $0DC0, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC BRANCH_ALPHA
        
        JSL Player_HaltDashAttackLong
        
        LDA.b #$10 : STA $46
        
        LDA.b #$30
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : STA $27
        LDA $01 : STA $28
        
        LDA.b #$32 : JSL Sound_SetSfx3PanLong
        
        INC $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$EF99C-$EF9AF JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        LDA.b #$08 : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        LSR A : AND.b #$03 : STA $0DC0, X

        RTS
    }

; ==============================================================================

    ; $EF9B0-$EF9B3 DATA
    {
        ; \task Name this routine / pool
    
    .animation_states
        db 0, 2, 3, 1
    }

; ==============================================================================

    ; *$EF9B4-$EF9D1 JUMP LOCATION
    {
        LDA $0DF0, X : LSR A : TAY
        
        LDA .animation_states, X : STA $0DC0, X
        
        LDA $0DF0, X : CMP.b #$07 : BNE BRANCH_ALPHA
        
        JSR $FA4E ; $EFA4E IN ROM
    
    BRANCH_ALPHA:
    
        LDA $0DF0, X : BNE BRANCH_BETA
        
        INC $0D80, X
    
    BRANCH_BETA:
    
        RTS
    } 

; ==============================================================================

    ; $EF9D2-$EF9E1 DATA
    {
    
        ; \task Name this routine / pool
    
    .animation_states
        db  1,  2,  3,  1,  3,  1,  2,  3
    
    .timers
        db 13, 13, 13, 11, 11,  6, 16,  8
    }

; ==============================================================================

    ; *$EF9E2-$EFA00 JUMP LOCATION
    {
        JSR $FA03 ; $EFA03 IN ROM
        
        LDA $0DF0, X : BNE .countingDown
        
        LDA $0DA0, X : INC A : AND.b #$07 : STA $0DA0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA .timers, Y : STA $0DF0, X
    
    .countingDown
    
        RTS
    }

; ==============================================================================

    ; $EFA01-$EFA02 DATA
    {
    
    ; \task Name this routine / pool.
    .message_ids
        db $82, $7D
    }

; ==============================================================================

    ; *$EFA03-$EFA2A LOCAL
    {
        LDA.b #$07 : STA $0F60, X
        
        LDA $0D90, X : BNE BRANCH_EFA33
        
        LDA $0D10, X : LSR #4 : AND.b #$01 : EOR.b #$01 : STA $0D90, X : TAY
        
        LDA .message_ids, Y
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCS .didnt_solicit
        
        STZ $0D90, X
    
    .didnt_solicit
    
        RTS
    }

; ==============================================================================

    ; $EFA2B-$EFA32 DATA
    {
        ; \task Label routine / pool.
    
    .message_ids
        db $7E, $7F, $80, $81
    
    .areas
        db $58, $5D, $72, $6B
    }

; ==============================================================================

    ; *$EFA33-$EFA4D BRANCH LOCATION
    {
        LDY.b #$00
        
        LDA $8A
    
    BRANCH_BETA:
    
        CMP .areas, Y : BEQ BRANCH_ALPHA
        
        INY : BEQ BRANCH_ALPHA
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA .message_ids, Y
        
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D90, X
        
        RTS
    }

; ==============================================================================

    ; *$EFA4E-$EFA7A LOCAL
    {
        LDA.b #$4A : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_TransmuteToEnemyBomb
        JSL Sprite_SetSpawnedCoords
        
        LDA $02 : ADD.b #$28 : STA $08
        LDA $03 : ADC.b #$00 : STA $03
        
        LDA.b #$40 : STA $0E00, Y
        
        LDA.b #$18 : STA $0D40, Y
        
        LDA.b #$12 : STA $0F80, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$EFADB-$EFAFA LOCAL
    {
        LDA $0DC0, X : DEC A : BMI BRANCH_ALPHA
        
        ASL #5     : ADC.b #$7B : STA $08
        LDA.b #$FA : ADC.b #$00 : STA $09
        
        LDA.b #$04 : STA $06
                     STZ $07
        
        JSL Sprite_DrawMultiple.player_deferred
    
    BRANCH_ALPHA:
    
        RTS
    } 

; ==============================================================================

    ; $EFAFB-$EFB09 DATA
    {
    
        ; \task Add labels.
        db  9, -9
        db  0, -1
    
        db -2, -1,  0,  1,  2
        db -1, -1,  0,  0,  0
    }

; ==============================================================================

    ; *$EFB0A-$EFB85 JUMP LOCATION
    {
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite4_CheckIfActive
        
        LDY $0EB0, X
        
        LDA $0D90, X : ADD $FAFB, Y : STA $0D10, X
        LDA $0DA0, X : ADC $FAFD, Y : STA $0D30, X
        
        LDA $0DB0, X : STA $0D00, X
        LDA $0E90, X : STA $0D20, X
        
        LDA.b #$02
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : BMI BRANCH_ALPHA
        
        LDA $01 : ADD.b #$02 : STA $0DE0, X
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $0DE0, X : CMP.b #$02 : BEQ BRANCH_BETA
        
        ROL A : AND.b #$01 : TAY
        
        LDA $0DE0, X : ADD $8000, Y : STA $0DE0, X
    
    BRANCH_BETA:
    
        LDY $0DE0, X
        
        LDA $0D90, X : ADD $FAFF, Y : STA $0D10, X
        LDA $0DA0, X : ADC $FB04, Y : STA $0D30, X
        
        LDA $0DB0, X : ADD $FB05, Y : STA $0D00, X
        LDA $0E90, X : ADC $FB05, Y : STA $0D20, X
        
        RTS
    }

; ==============================================================================

    ; $EFB86-$EFB89 DATA
    pool TalkingTree_SpawnEyes:
    {
    
    .x_offsets_low
        db $FC, $0E
    
    .x_offsets_high
        db $FF, $00
    }

; ==============================================================================

    ; *$EFB8A-$EFBCB LONG
    TalkingTree_SpawnEyes:
    {
        PHX : PHA
        
        LDA.b #$25
        
        JSL Sprite_SpawnDynamically
        
        PLA : STA $0EB0, Y : TAX
        
        LDA $00 : ADD.l .x_offsets_low, X  : STA $0D10, Y : STA $0D90, Y
        LDA $01 : ADC.l .x_offsets_high, X : STA $0D30, Y : STA $0DA0, Y
        
        LDA $02 : ADD.b #$F5 : STA $0D00, Y : STA $0DB0, Y
        LDA $03 : ADC.b #$FF : STA $0D20, Y : STA $0E90, Y
        
        LDA.b #$01 : STA $0E80, Y
        
        PLX
        
        RTL
    }

