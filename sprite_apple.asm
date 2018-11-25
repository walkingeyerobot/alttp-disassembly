
; ==============================================================================

    ; *$F7515-$F7534 JUMP LOCATION
    Sprite_DashApple:
    {
        ; This is the apple sprite embedded in trees. Afaik, it starts off
        ; invisible, but will split into a random number of other apples when the 
        ; player bashes into a tree containing one of these.
        LDA $0D80, X : BNE Sprite_Apple
        
        ; \note: The code that would set this variable low is not part of
        ; the sprite logic itself. Rather, it is done by the player code when
        ; the player actually hits something and bounces back.
        LDA $0E90, X : BNE .not_dashed_into_yet
        
        STZ $0DD0, X
        
        ; Spawn 2 to 5 apples.
        JSL GetRandomInt : AND.b #$03 : ADD.b #$02 : TAY
    
    .next_spawn_attempt
    
        PHY
        
        JSR Apple_SpawnTangibleApple
        
        PLY : DEY : BPL .next_spawn_attempt
    
    .not_dashed_into_yet
    
        RTS
    }

; ==============================================================================

    ; *$F7535-$F7579 LOCAL
    Apple_SpawnTangibleApple:
    {
        LDA.b #$AC : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$01 : STA $0D80, Y
        
        LDA.b #$FF : STA $0D90, Y
        
        LDA.b #$08 : STA $0F70, Y
        
        LDA.b #$16 : STA $0F80, Y
        
        JSL GetRandomInt : STA $04
        LDA $01          : STA $05
        
        JSL GetRandomInt : STA $06
        LDA $03          : STA $07
        
        LDA.b #$0A : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, Y
        LDA $01 : STA $0D50, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $F757A-$F757B DATA
    pool Sprite_Apple:
    {
    
    .speeds
        db $FF, $01
    }

; ==============================================================================

    ; *$F757C-$F7602 BRANCH LOCATION
    Sprite_Apple:
    {
        LDA $0D90, X : CMP.b #$10 : BCS .dont_blink
        
        LDA $1A : AND.b #$02 : BEQ .blink
    
    .dont_blink
    
        JSL Sprite_PrepAndDrawSingleLargeLong
    
    .blink
    
        JSR Sprite3_CheckIfActive
        
        LDA $0D90, X : BEQ .expired_so_self_terminate
        
        JSR Sprite3_MoveXyz
        
        JSR Sprite3_CheckDamageToPlayer : BCC .no_player_collision
        
        LDA.b #$0B
        
        JSL Sound_SetSfx3PanLong
        
        ; Fill in the player's life meter by 8 points (1 heart)
        LDA $7EF372 : ADD.b #$08 : STA $7EF372
    
    .expired_so_self_terminate
    
        STZ $0DD0, X
        
        RTS
    
    .no_player_collision
    
        LDA $1A : AND.b #$01 : BNE .delay_expiration_timer_tick
        
        DEC $0D90, X
    
    .delay_expiration_timer_tick
    
        LDA $0F70, X : DEC A : BPL .aloft
        
        STZ $0F70, X
        
        LDA $0F80, X : BMI .hit_ground_this_frame
        
        LDA.b #$00
    
    .hit_ground_this_frame
    
        EOR.b #$FF : INC A : LSR A : STA $0F80, X
        
        LDA $0D50, X : BEQ .x_speed_at_rest
        
        PHA
        
        ASL A : LDA.b #$00 : ROL A : TAY
        
        PLA : ADD .speeds, Y : STA $0D50, X
    
    .x_speed_at_rest
    
        LDA $0D40, X : BEQ .y_speed_at_rest
        
        PHA
        
        ASL A : LDA.b #$00 : ROL A : TAY
        
        PLA : ADD .speeds, Y : STA $0D40, X
    
    .y_speed_at_rest
    
        RTS
    
    .aloft
    
        LDA $0F80, X : SUB.b #$01 : STA $0F80, X
        
        RTS
    }

; ==============================================================================
