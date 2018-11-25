
; ==============================================================================

    ; *$EDD7B-$EDD82 LONG
    Sprite_RavenLong:
    {
        PHB : PHK : PLB
        
        JSR SpritePrep_Raven
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EDD83-$EDD84 DATA
    pool Sprite_SetHflip:
    {
    
    .h_flip
        db $00, $40
    }

; ==============================================================================

    ; *$EDD85-$EDDAB LOCAL
    Sprite_Raven:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckIfRecoiling
        JSR Sprite4_CheckDamage
        JSR Sprite4_Move
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Raven_InWait
        dw Raven_Ascend
        dw Raven_Attack
        dw Raven_FleePlayer
    }

; ==============================================================================

    ; $EDDAC-$EDDAD DATA
    pool Raven_Ascend:
    {
    
    ; \task Name this routine / pool.
    .timers
        db $10, $F8
    }

; ==============================================================================

    ; *$EDDAE-$EDDE4 JUMP LOCATION
    Raven_InWait:
    {
        JSR Sprite4_IsToRightOfPlayer
        JSR Raven_SetHflip
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADC.w #$0050 : CMP.w #$00A0 : BCS .player_too_far
        
        LDA $20 : SUB $0FDA : ADC.w #$0058 : CMP.w #$00A0 : BCS .player_too_far
        
        SEP #$20
        
        INC $0D80, X
        
        LDA.b #$18 : STA $0DF0, X
        
        LDA.b #$1E : JSL Sound_SetSfx3PanLong
    
    .player_too_far
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$EDDE5-$EDE08 JUMP LOCATION
    Raven_Ascend:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDY $0D90, X
        
        LDA .timers, Y : STA $0DF0, X
        
        LDA.b #$20
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
    
    .delay
    
        INC $0F70, X
        
        LDA $1A : LSR A : AND.b #$01 : INC A : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EDE09-$EDE65 JUMP LOCATION
    Raven_Attack:
    {
        LDA $0DF0, X : BNE .delay_fleeing
        
        LDA $0FFF : BEQ .always_flee_in_light_world
        
        ; Afaik, all Dark World 'ravens' are fearless. They look like mini-
        ; pterodactyls.
        LDA $0D90, X : BNE .is_fearless
    
    .always_flee_in_light_world
    
        INC $0D80, X
    
    .is_fearless
    .delay_fleeing
    
        TXA : EOR $1A : LSR A : BCS .delay_speed_analysis
        
        LDA #$20 : JSL Sprite_ProjectSpeedTowardsPlayerLong
    
    ; *$EDE27 ALTERNATE ENTRY POINT
    Raven_AccelerateToTargetSpeed:
    
        LDA $0D40, X : CMP $00 : BEQ .y_speed_at_target
                                 BPL .y_speed_above_target
        
        INC $0D40, X
        
        BRA .check_x_speed
    
    .y_speed_above_target
    
        DEC $0D40, X
    
    .y_speed_at_target
    .check_x_speed
    
        LDA $0D50, X : CMP $01 : BEQ .x_speed_at_target
                                 BPL .x_speed_above_target
        
        INC $0D50, X
        
        BRA .animate
    
    .x_speed_above_target
    
        DEC $0D50, X
    
    .x_speed_at_target
    .delay_speed_analysis
    .animate
    
    ; *$EDE49 ALTERNATE ENTRY POINT
    shared Raven_Animate:
    
        LDA $1A : LSR A : AND.b #$01 : INC A : STA $0DC0, X
        
        LDA $0D50, X : ASL A : ROL A : AND.b #$01 : TAY
    
    ; *$EDE5A ALTERNATE ENTRY POINT
    shared Raven_SetHflip:
    
        LDA $0F50, X : AND.b #$BF : ORA $DD83, Y : STA $0F50, X
        
        RTS
    }

; ==============================================================================

    ; *$EDE66-$EDE81 JUMP LOCATION
    Raven_FleePlayer:
    {
        TXA : EOR $1A : LSR A : BCS Raven_Animate
        
        LDA.b #$30 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : EOR.b #$FF : INC A : STA $00
        
        LDA $01 : EOR.b #$FF : INC A : STA $01
        
        BRA Raven_AccelerateToTargetSpeed
    }

; ==============================================================================
