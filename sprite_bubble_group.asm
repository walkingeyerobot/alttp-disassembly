
; ==============================================================================

    ; $F4AF4-$F4B0B DATA
    pool SpritePrep_BubbleGroup:
    {
    
    .x_offets_low
        db $0A, $14, $0A
    
    .x_offsets_high
        db $00, $00, $00
    
    .y_offets_low
        db $F6, $00, $0A
    
    .y_offets_high
        db $FF, $00, $00
    
    .x_speeds
        db $12, $00, $EE
    
    .x_polarities
        db $01, $01, $00
    
    .y_speeds
        db $00, $12, $00
    
    .y_polarities
        db $00, $01, $01
    }

; ==============================================================================

    ; *$F4B0C-$F4B8A LONG
    SpritePrep_BubbleGroup:
    {
        LDA $0D10, X : SUB.b #$0A : STA $0D10, X
        LDA $0D30, X : SBC.b #$00 : STA $0D30, X
        
        LDA.b #$EE : STA $0D40, X
        
        LDA.b #$00 : STA $0D50, X
        
        LDA.b #$00 : STA $0D90, X
        
        LDA.b #$00 : STA $0DA0, X
        
        LDA.b #$02 : STA $0FB5
    
    .attempt_next_spawn
    
        LDA.b #$82
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        LDX $0FB5
        
        LDA $00 : ADD.l .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC.l .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD.l .y_offsets_low, X  : STA $0D00, Y
        LDA $03 : ADC.l .y_offsets_high, X : STA $0D20, Y
        
        LDA.l .x_speeds, X : STA $0D50, Y
        
        LDA.l .y_speeds, X : STA $0D40, Y
        
        LDA.l .x_polarities, X : STA $0D90, Y
        
        LDA.l .y_polarities, X : STA $0DA0, Y
        
        PLX
    
    .spawn_failed
    
        DEC $0FB5 : BPL .attempt_next_spawn
        
        RTL
    }

; ==============================================================================

    ; $F4B8B-$F4B96 DATA
    pool Sprite_BubbleGroup:
    {
    
    .unused
    
        ; not really sure what this would be fore. perhaps earlier draft
        ; data that was never removed for the direction control?
        db $00, $01, $00, $01
        
        ; possibly hflip data?
        db $00, $00, $40, $40
        
    .speed_step
        db $01, $FF
    
    .speed_limit
        db $12, $EF
    }

; ==============================================================================

    ; *$F4B97-$F4C01 JUMP LOCATION
    Sprite_BubbleGroup:
    {
        JSL Sprite_DrawFourAroundOne
        JSR Sprite3_CheckIfActive
        
        ; Seems to handle the... acceleration in x and y directions... curious.
        ; In other words, this is the logic that effects the circular motion
        ; the bubble group's members.
        LDA $0D90, X : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD .speed_step, Y : STA $0D50, X
        
        CMP .speed_limit, Y : BNE .dont_flip_x_speed_polarity
        
        INC $0D90, X
    
    .dont_flip_x_speed_polarity
    
        LDA $0DA0, X : AND.b #$01 : TAY
        
        LDA $0D40, X : ADD .speed_step, Y : STA $0D40, X
        
        CMP .speed_step, Y : BNE .dont_flip_y_speed_polarity
        
        INC $0DA0, X
    
    .dont_flip_y_speed_polarity
    
        JSR Sprite3_Move
        
        LDA $0D50, X : BEQ .dont_disperse_yet
        
        LDA $0D40, X : BEQ .dont_disperse_yet
        
        JSL Sprite_CheckIfAllDefeated : BCC .dont_disperse_yet
        
        ; Change type to a normal bubble
        LDA.b #$15 : STA $0E20, X
        
        ; Set their speeds as normal bubbles would be set.
        LDA.b #$10
        
        LDY $0D50, X : BPL .positive_x_speed
        
        LDA.b #$F0
    
    .positive_x_speed
    
        STA $0D50, X
        
        LDA.b #$10
        
        LDY $0D40, X : BPL .positive_y_speed
        
        LDA.b #$F0
    
    .positive_y_speed
    
        STA $0D40, X
    
    .dont_disperse_yet
    
        ; \note This explains why the bubbles in this state can't be harmed.
        JSR Sprite3_CheckDamageToPlayer
        
        RTS
    }

; ==============================================================================
