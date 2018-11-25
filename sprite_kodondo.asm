
; ==============================================================================

    ; *$F4103-$F411F JUMP LOCATION
    Sprite_Kodondo:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        
        STZ $0B6B, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Kodondo_ChooseDirection
        dw Kodondo_Move
        dw Kodondo_BreatheFlame
    }

; ==============================================================================

    ; $F4120-$F4127 DATA
    pool Kodondo_ChooseDirection
    {
    
    .x_speeds
        db $01, $FF, $00, $00
    
    .y_speeds
        db $00, $00, $01, $FF
    }

; ==============================================================================

    ; *$F4128-$F4167 JUMP LOCATION
    Kodondo_ChooseDirection:
    {
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$03 : STA $0DE0, X
        
        LDA.b #$B0 : STA $0B6B, X
    
    .try_another_direction
    
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        LDA $0DE0, X : INC A : AND.b #$03 : STA $0DE0, X
        
        ; \bug I'm thinking this could potentially crash the game... (in the
        ; sense that it would be stuck in this loop, not go off the rails
        ; completely)
        BRA .try_another_direction
    
    .no_tile_collision
    
    ; *$F4158 ALTERNATE ENTRY POINT
    shared Kodondo_SetSpeed:
    
        LDY $0DE0, X
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        LDA Sprite3_Shake.y_speeds, Y : STA $0D40, X
        
        RTS
    }

; ==============================================================================

    ; $F4168-$F4177 DATA
    pool Kodondo_Move:
    {
    
    .animation_states
        db $02, $02, $00, $05, $03, $03, $00, $05
    
    .vh_flip_override
        db $40, $00, $00, $00, $40, $00, $40, $40
    }

; ==============================================================================

    ; *$F4178-$F41CD JUMP LOCATION
    Kodondo_Move:
    {
        JSR Sprite3_Move
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        JSR Kodondo_SetSpeed
    
    .no_tile_collision
    
        ; This logic sets up an invisible grid of points at which the Kodondo
        ; can potentially breath flames. It's still semi random as indicated
        ; below, though.
        
        LDA $0D10, X : AND.b #$1F : CMP.b #$04 : BNE .dont_breathe_flame
        
        LDA $0D00, X : AND.b #$1F : CMP.b #$1B : BNE .dont_breathe_flame
        
        JSL GetRandomInt : AND.b #$03 : BNE .dont_breathe_flame
        
        LDA.b #$6F : STA $0DF0, X
        
        INC $0D80, X
        
        STZ $0D90, X
    
    .dont_breathe_flame
    
        INC $0E80, X
        
        LDA $0E80, X : AND.b #$04 : ORA $0DE0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .vh_flip_override, Y : STA $0F50, X
        
        RTS
    }

; ==============================================================================

    ; $F41CE-$F41D5 DATA
    pool Kodondo_BreatheFlames:
    {
    
    .animation_states
        db $02, $02, $00, $05
        db $04, $04, $01, $06
    }

; ==============================================================================

    ; *$F41D6-$F4204 JUMP LOCATION
    Kodondo_BreatheFlame:
    {
        LDA $0DF0, X : BNE .dont_revert_yet
        
        STZ $0D80, X
    
    .dont_revert_yet
    
        LDY.b #$00
        
        SUB.b #$20 : CMP.b #$30 : BCS .cant_spawn
        
        LDY.b #$04
    
    .cant_spawn
    
        CPY.b #$04 : BNE .dont_spawn_flame
        
        LDA $0DF0, X : AND.b #$0F : BNE .dont_spawn_flame
        
        PHY
        
        JSR Kodondo_SpawnFlames
        
        PLY
    
    ,dont_spawn_flame
    
        TYA : ORA $0DE0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F4205-$F4222 DATA
    pool Kodondo_SpawnFlames:
    {
    
    .x_offsets_low
        db $08, $F8, $00, $00
    
    .x_offsets_high
        db $00, $FF, $00, $00
    
    .y_offsets_low
        db $00, $00, $08, $F8
    
    .y_offsets_high
        db $00, $00, $00, $FF
    
    .x_speeds
        db $18, $E8, $00, $00
    
    .y_speeds
        db $00, $00, $18, $E8
    
    ; \tcrf Not really major, but curious nonetheless
    .unused
        db $40, $38, $30, $28, $20, $18
    }

; ==============================================================================

    ; *$F4223-$F4266 LOCAL
    Kodondo_SpawnFlames:
    {
        LDA.b #$87
        LDY.b #$0D
        
        JSL Sprite_SpawnDynamically_arbitrary : BMI .spawn_failed
        
        PHX
        
        LDA $0DE0, X : TAX
        
        LDA $00 : ADD .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X  : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA.b #$01 : STA $0BA0, Y
        
        PLX
    
    .spawn_failed
    
        RTS
    } 

; ==============================================================================
