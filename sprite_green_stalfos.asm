
; ==============================================================================

    ; $F528D-$F5298 DATA
    pool Sprite_GreenStalfos:
    {
    
    ,facing_direction
        db $04, $06, $00, $02
    
    .vh_flip
        db $40, $00, $00, $00
    
    .animation_states
        db $00, $00, $01, $02
    }

; ==============================================================================

    ; *$F5299-$F530F JUMP LOCATION
    Sprite_GreenStalfos:
    {
        LDY $0DE0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .vh_flip, Y : STA $0F50, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        
        STZ $0D90, X
        
        JSR Sprite3_DirectionToFacePlayer
        
        LDA .facing_direction, Y : CMP $002F : BEQ .player_is_facing
        
        TXA : EOR $1A : AND.b #$07 : BNE .delay_for_speedup
        
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0DE0, X
        
        LDA $0DA0, X : CMP.b #$04 : BEQ .finished_accelerating
        
        INC $0DA0, X
    
    .finished_accelerating
    
        JSL Sprite_ApplySpeedTowardsPlayerLong
        JSR Sprite3_IsToRightOfPlayer
        
        TYA : STA $0DE0, X
    
    .delay_for_speedup
    
        JSR Sprite3_Move
        
        RTS
    
    .player_is_facing
    
        INC $0D90, X
        
        TXA : EOR $1A : AND.b #$0F : BNE .delay_for_slowdown
        
        LDA $0DA0, X : BEQ .finished_decelerating
        
        DEC $0DA0, X
    
    .finished_decelerating
    
        JSL Sprite_ApplySpeedTowardsPlayerLong
        JSR Sprite3_IsToRightOfPlayer
        
        TYA : STA $0DE0, X
    
    .delay_for_slowdown
    
        JSR Sprite3_Move
        
        RTS
    }

; ==============================================================================

