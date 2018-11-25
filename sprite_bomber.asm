
; ==============================================================================

    ; *$F0DD2-$F0DE6 JUMP LOCATION
    Sprite_Bomber:
    {
        LDA.b #$30 : STA $0B89, X
        
        LDA $0D90, X : BEQ Bomber_Main
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw BomberPellet_Falling
        dw BomberPellet_Exploding
    }

; ==============================================================================

    ; *$F0DE7-$F0E13 JUMP LOCATION
    BomberPellet_Falling:
    {
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_Move
        JSR Sprite3_MoveAltitude
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .aloft
        
        STZ $0F70, X
        
        INC $0D80, X
        
        LDA.b #$13 : STA $0DF0, X
        
        INC $0E40, X
        
        LDA.b #$0C : JSL Sound_SetSfx2PanLong
    
    .aloft
    
        RTS
    }

; ==============================================================================

    ; *$F0E14-$F0E28 JUMP LOCATION
    BomberPellet_Exploding:
    {
        JSL BomberPellet_DrawExplosion
        JSR Sprite3_CheckIfActive
        
        LDA $1A : AND.b #$03 : BNE .dont_rewind_timer
        
        INC $0DF0, X
    
    .dont_rewind_timer
    
        JSL Sprite_CheckDamageToPlayerLong
        
        RTS
    }

; ==============================================================================

    ; $F0E29-$F0E30 DATA
    pool Bomber_Main:
    {
    
    .z_speed_step
        db $01, $FF
    
    .z_speed_limit
        db $08, $F8
    
    .animation_states
        db $09, $0A, $08, $07
    }

; ==============================================================================

    ; $F0E31-$F0ED1 BRANCH LOCATION
    Bomber_Main:
    {
        LDA $0E00, X : BEQ .direction_lock_inactive
        
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
    
    .direction_lock_inactive
    
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSL Bomber_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0E00, X : CMP.b #$08 : BNE .direction_lock_active
        
        JSR Bomber_SpawnPellet
    
    .direction_lock_active
    
        JSR Sprite3_CheckDamage
        
        LDA $1A : AND.b #$01 : BNE .delay
        
        LDA $0ED0, X : AND.b #$01 : TAY
        
        LDA $0F80, X : ADD .z_speed_step, Y : STA $0F80, X
        
        CMP .z_speed_limit, Y : BNE .not_at_speed_limit
        
        ; invert polarity of motion in the z axis. (gives an undulation effect.)
        INC $0ED0, X
    
    .not_at_speed_limit
    .delay
    
        JSR Sprite3_MoveAltitude
        JSR Sprite3_DirectionToFacePlayer
        
        LDA $0E : ADD.b #$28 : CMP.b #$50 : BCS .player_not_close
        
        LDA $0F : ADD.b #$28 : CMP.b #$50 : BCS .player_not_close
        
        LDA $44 : CMP.b #$80 : BEQ .player_not_attacking
        
        LDA $0372 : BNE .dodge_player_attack
        
        LDA $3C : CMP.b #$09 : BPL .player_not_attacking
    
    .dodge_player_attack
    
        LDA.b #$30 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $01 : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $00 : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA.b #$08 : STA $0DF0, X
        
        LDA.b #$02 : STA $0D80, X
    
    .player_not_attacking
    .player_not_close
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Bomber_Hovering
        dw Bomber_Moving
        dw Bomber_Dodge
    }

; ==============================================================================

    ; $F0ED2-$F0EE3 JUMP LOCATION
    Bomber_Dodge:
    {
        LDA $0DF0, X : BNE .delay
        
        STZ $0D80, X
    
    .delay
    
        INC $0E80, X : INC $0E80, X
        
        JSR Bomber_MoveAndAnimate
        
        RTS
    }

; ==============================================================================

    ; $F0EE4-$F0EF7 DATA
    pool Bomber_Hovering:
    {
    
    .x_speeds
        db $10, $0C
        db $00, $F4
        db $F0, $F4
        db $00, $0C
    
    .y_speeds
        db $00, $0C
        db $10, $0C
        db $00, $F4
        db $F0, $F4
    
    .approach_indices
        db $00, $04, $02, $06
    }

; ==============================================================================

    ; $F0EF8-$F0F70 JUMP LOCATION
    Bomber_Hovering:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        INC $0DA0, X : LDA $0DA0, X : CMP.b #$03 : BNE .choose_random_direction
        
        STZ $0DA0, X
        
        LDA.b #$30 : STA $0DF0, X
        
        JSR Sprite3_DirectionToFacePlayer
        
        ; \task Decide whether this is really approaching the player or just
        ; flanking... confusing the player?
        LDA .approach_indices, Y
        
        BRA .approach_player
    
    .choose_random_direction
    
        JSL GetRandomInt : AND.b #$1F : ORA.b #$20 : STA $0DF0, X : AND.b #$07
    
    .approach_player
    
        TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
    
    .delay
    
        BRA .just_face_and_animate
    
    ; $F0F36 ALTERNATE ENTRY POINT
    shared Bomber_Moving:
    
        LDA $0DF0, X : BNE .delay_2
        
        STZ $0D80, X
        
        LDA.b #$0A : STA $0DF0, X
        
        LDY $0E20, X : CPY.b #$A8 : BNE .cant_spawn_pellet
        
        ; Only the green bombers can do that, apparently.
        LDA.b #$10 : STA $0E00, X
    
    .cant_spawn_pellet
    
        RTS
    
    .delay_2
    
    ; $F0F50 ALTERNATE ENTRY POINT
    shared Bomber_MoveAndAnimate:
    
        JSR Sprite3_Move
    
    .just_face_and_animate
    
        JSR Sprite3_DirectionToFacePlayer : TYA : STA $0DE0, X
        
        INC $0E80, X : LDA $0E80, X : LSR #3 : AND.b #$01 : STA $00
        
        LDA $0DE0, X : ASL A : ORA $00 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F0F71-$F0F80 DATA
    pool Bomber_SpawnPellet:
    {
    
    .x_offsets_low
        db $0E, $FA, $04, $04
    
    .x_offsets_high
        db $00, $FF, $00, $00
    
    .y_offsets_low
        db $07, $07, $0C, $FC
    
    .y_offsets_high
        db $00, $00, $00, $FF
    }

; ==============================================================================

    ; $F0F81-$F0FDE LOCAL
    Bomber_SpawnPellet:
    {
        LDA.b #$A8 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        LDA $04 : STA $0F70, Y
        
        PHX
        
        LDX $0DE0, Y
        
        LDA $00 : ADD .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X  : STA $0D00, Y
        LDA $03 : ADC .y_offsets_hiwh, X : STA $0D20, Y
        
        LDA Sprite3_Shake.x_speeds, X : STA $0D50, Y
        
        LDA Sprite3_Shake.y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA.b #$01 : STA $0D90, Y : STA $0BA0, Y
        
        LDA.b #$09 : STA $0F60, Y
        
        LDA.b #$33 : STA $0E60, Y
        
        AND.b #$0F : STA $0F50, Y

    .spawn-failed

        RTS
    }

; ==============================================================================

