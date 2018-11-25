
; ==============================================================================

    ; $35DAF-$35DB6 DATA
    pool Sprite_StalfosHead:
    {
    
    .h_flip
        db $00, $00, $00, $40
    
    .animation_states
        db 0, 1, 2, 1
    }

; ==============================================================================

    ; *$35DB7-$35E4C JUMP LOCATION
    Sprite_StalfosHead:
    {
        ; Force the sprite's layer to be that of the player's.
        ; \note This is somewhat unusual.
        LDA $EE : STA $0F20, X
        
        LDA $0E00, X : BEQ .use_typical_oam_region
        
        LDA.b #$08 : JSL OAM_AllocateFromRegionC
    
    .use_typical_oam_region
    
        LDA $0E80, X : LSR #3 : AND.b #$03 : TAY
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA.b #$30 : STA $0B89, X
        
        JSR Sprite_PrepAndDrawSingleLarge
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        LDA $0EA0, X : BEQ .not_recoiling
        
        ; This sprite can't be recoiled by hitting it. That's part of why
        ; they're annoying.
        JSR Sprite_Zero_XY_Velocity
    
    .not_recoiling
    
        JSR Sprite_Move
        
        INC $0E80, X
        
        LDA $0DF0, X : BEQ .flee_from_player
        AND.b #$01   : BNE  .return
        
        LDA.b #$10 : JSR Sprite_ProjectSpeedTowardsPlayer
    
    .approach_target_speed
    
        LDA $0D40, X : CMP $00 : BEQ .at_target_x_speed
                                 BPL .above_target_x_speed
        
        INC $0D40, X
        
        BRA .check_y_speed
    
    .above_target_x_speed
    
        DEC $0D40, X
    
    .at_target_x_speed
    .check_y_speed
    
        LDA $0D50, X : CMP $01 : BEQ  .return
                                 BPL .above_target_y_speed
        
        INC $0D50, X
        
        BRA  .return
    
    .above_target_y_speed
    
        DEC $0D50, X
    
     .return
    
        RTS
    
    .flee_from_player
    
        TXA : EOR $1A : AND.b #$03 : BNE .return
        
        LDA.b #$10
        
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : EOR.b #$FF : INC A : STA $00
        LDA $01 : EOR.b #$FF : INC A : STA $01
        
        BRA .approach_target_speed
    }

; ==============================================================================
