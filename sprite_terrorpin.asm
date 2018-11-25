
; =============================================================================

    ; *$F326F-$F3296 JUMP LOCATION
    Sprite_Terrorpin:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckTileCollision
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0E10, X : BNE .invulnerable
        
        JSL Sprite_CheckDamageFromPlayerLong
    
    .invulnerable
    
        JSR Terrorpin_CheckHammerHitNearby
        JSR Sprite3_MoveXyz
        
        LDA $0DA0, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Terrorpin_Upright
        dw Terrorpin_Overturned
    
    .unused
    
        RTS
    }

; =============================================================================

    ; $F3297-$F32A6 DATA
    pool Terrorpin_Upright:
    {
    
    .x_speeds
        db $08, $F8, $00, $00
        db $0C, $F4, $00, $00
    
    .y_speeds
        db $00, $00, $08, $F8
        db $00, $00, $0C, $F4
    }

; =============================================================================

    ; *$F32A7-$F330D JUMP LOCATION
    Terrorpin_Upright:
    {
        LDA $0F10, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$20 : STA $0F10, X
        
        AND.b #$03 : STA $0DE0, X
        
        ; \note Label so named because it clearly can never happen if there
        ; was a logical and with 0x03 immediately preceding this.
        AND.b #$30 : BNE .never_branch
        
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0DE0, X
    
    .never_branch
    .delay
    
        LDA $0DE0, X : ADD $0ED0, X : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA $0F80, X : DEC #2 : STA $0F80, X
        
        LDA $0F70, X : BPL .in_air
        
        STZ $0F70, X
        STZ $0F80, X
    
    .in_air
    
        LDA $1A
        
        LDY $0ED0, X : BNE .moving_faster
        
        LSR A
    
    .moving_faster
    
        LSR #2 : AND.b #$01 : STA $0DC0, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDA.b #$04 : STA $0CAA, X
        
        JSR Sprite3_CheckDamageToPlayer
        
        RTS
    }

; =============================================================================

    ; *$F330E-$F33A2 JUMP LOCATION
    Terrorpin_Overturned:
    {
        ; Remove invulnerability.
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        ; Don't make little hit effect when hit by hammer and sword.
        STZ $0CAA, X
        
        LDA $0F10, X : BNE .delay
        
        STZ $0DA0, X
        
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$40 : STA $0F10, X
        
        RTS
    
    .delay
    
        LDA $0F80, X : DEC #2 : STA $0F80, X
        
        LDA $0F70, X : BPL .in_air
        
        STZ $0F70, X
        
        LDA $0F80, X : EOR.b #$FF : INC A : LSR A
        
        CMP.b #$09 : BCS .bounced
        
        LDA.b #$00
    
    .bounced
    
        STA $0F80, X
        
        ; This operation arithmetically shifts right to reduce the x velocity.
        LDA $0D50, X : ASL A : ROR $0D50, X
        
        LDA $0D50, X : CMP.b #$FF : BNE .dont_zero_x_speed
        
        STZ $0D50, X
    
    .dont_zero_x_speed
    
        ; This operation arithmetically shifts right to reduce the y velocity.
        LDA $0D40, X : ASL A : ROR $0D40, X
        
        LDA $0D40, X : CMP.b #$FF : BNE .dont_zero_y_speed
        
        STZ $0D40, X
    
    .dont_zero_x_speed
    .in_air
    
        LDA $0F10, X : CMP.b #$40 : BCS .not_struggling_hard_yet
        
        LSR A : AND.b #$01 : TAY
        
        LDA .shake_x_speeds, Y : STA $0D50, X
        
        INC $0E80, X
    
    .not_struggling_hard_yet
    
        INC $0E80, X : LDA $0E80, X : LSR #3 : AND.b #$01 : TAY
        
        LDA.b #$02 : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
        
        RTS
    
    .h_flip
        db $00, $40
    
    .shake_x_speeds
        db $08, $F8
    }

; =============================================================================

    ; *$F33A3-$F3404 LOCAL
    Terrorpin_CheckHammerHitNearby:
    {
        LDA $0F70, X : ORA $0E10, X : BNE .cant_overturn
        
        LDA $EE : CMP $0F20, X : BNE .cant_overturn
        
        LDA $0044 : CMP.b #$80 : BEQ .cant_overturn
        LDA $0301 : AND.b #$0A : BEQ .cant_overturn
        
        JSL Player_SetupActionHitBoxLong
        JSR Terrorpin_FormHammerHitBox
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .didnt_hit_within_box
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA.b #$20 : STA $0E10, X
        
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$04 : STA $0ED0, X
        
        LDA $0DA0, X : EOR.b #$01 : STA $0DA0, X
        
        CMP.b #$01 : LDA.b #$FF : BCS .to_overturned_state
        
        LDA.b #$40
    
    .to_overturned_state
    
        STA $0F10, X
    
    .didnt_hit_within_box
    .cant_overturn
    
        STZ $0EB0, X
        
        RTS
    }

; =============================================================================

    ; *$F3405-$F3429 LOCAL
    Terrorpin_FormHammerHitBox:
    {
        LDA $0D10, X : SUB.b #$10 : STA $04
        LDA $0D30, X : SBC.b #$00 : STA $0A
        
        LDA $0D00, X : SUB.b #$10 : STA $05
        LDA $0D20, X : SBC.b #$00 : STA $0B
        
        LDA.b #$30 : STA $06
                     STA $07
        
        RTS
    }

; ==============================================================================
