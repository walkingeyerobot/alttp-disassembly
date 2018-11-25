
    ; Doesn't use $0DC0, so it's oddball in that regard.
    !animation_index   = $0E80
    
    ; \note Rotarity is a term I've created for direction of spin, like
    ; clockwise vs. counterclockwise. It's a general term that doesn't indicate
    ; either of these, but rather it as a property.
    !rotarity          = $0EB0
    
    ; Most of the time the sprite picks a random rotarity and timer, but
    ; every 7th time it will enter a state where it targets the player and
    ; tries to move toward them.
    !seek_delay_counter = $0ED0
    

; ==============================================================================

    ; $317D8-$31807 DATA
    pool Sprite_Moldorm:
    {
    
    .x_speeds
        db  24,  22,  17,   9,   0,  -9, -17, -22
        db -24, -22, -17,  -9,   0,   9,  17,  22
    
    .y_speeds
        db   0,   9,  17,  22,  24,  22,  17,   9
        db   0,  -9, -17, -22, -24, -22, -17,  -9
    
    .next_directions
        db  8,  9, 10, 11, 12, 13, 14, 15
        db  0,  1,  2,  3,  4,  5,  6,  7
    }

; ==============================================================================

    ; *$31808-$3185F JUMP LOCATION
    Sprite_Moldorm:
    {
        JSL Moldorm_Draw
        JSR Sprite_CheckIfActive
        
        LDA $0EA0, X : BEQ .not_recoiling
        
        JSR SpritePrep_Moldorm
    
    .not_recoiling
    
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        INC !animation_index, X
        
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        JSL GetRandomInt : LSR A : BCC .anotoggle_rotarity
        
        LDA !rotarity, X : EOR.b #$FF : INC A : STA !rotarity, X
    
    .anotoggle_rotarity
    
        LDY $0DE0, X
        
        LDA .next_directions, Y : STA $0DE0, X
    
    .no_tile_collision
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Moldorm_ConfigureNextState
        dw Moldorm_Meander
        dw Moldorm_SeekPlayer
    }

; ==============================================================================

    ; *$31860-$3188C JUMP LOCATION
    Moldorm_ConfigureNextState:
    {
        LDA $0DF0, X : BNE .delay
        
        INC A
        
        INC !seek_delay_counter, X
        
        LDY !seek_delay_counter, X : CPY.b #$06 : BNE .anoseek_player
        
        STZ !seek_delay_counter, X
        
        INC A
    
    .anoseek_player
    
        STA $0D80, X
        
        JSL GetRandomInt : AND.b #$02 : DEC A : STA !rotarity, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$20 : STA $0DF0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$3188D-$318B1 JUMP LOCATION
    Moldorm_Meander:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$0F : ADC.b #$08 : STA $0DF0, X
        
        STZ $0D80, X
        
        RTS
    
    .delay
    
        AND.b #$03 : BNE .anostep_angle
        
        LDA $0DE0, X : ADD !rotarity, X : AND.b #$0F : STA $0DE0, X
    
    .anostep_angle
    
        RTS
    }

; ==============================================================================

    ; *$318B2-$318DF JUMP LOCATION
    Moldorm_SeekPlayer:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .delay
        
        LDA.b #$1F : JSR Sprite_ApplySpeedTowardsPlayer
        
        JSL Sprite_ConvertVelocityToAngle
        
        CMP $0DE0, X : BNE .not_at_target_angle
        
        ; Revert back to the base ai state to select another rotarity and timer.
        STZ $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
        
        RTS
    
    .not_at_target_angle
    
        PHP : LDA $0DE0, X : PLP : BMI .target_angle_lesser
        
        INC #2
    
    .target_angle_lesser
    
        DEC A : AND.b #$0F : STA $0DE0, X
    
    .delay
    
        RTS
    }

; ==============================================================================
