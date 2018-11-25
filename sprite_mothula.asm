
    !spike_activation_timer = $0EB0
    !beam_timer             = $0ED0

; ==============================================================================

    ; *$F3E7E-$F3E87 JUMP LOCATION
    Sprite_Mothula:
    {
        JSR Mothula_Main
        JSR Sprite3_CheckIfActive
        JSR Mothula_ActivateMovingSpikeBlock
        
        RTS
    }

; ==============================================================================

    ; *$F3E88-$F3ED7 LOCAL
    Mothula_Main:
    {
        JSL Mothula_DrawLong
        
        LDA $0DD0, X : CMP.b #$0B : BNE .not_stunned
        
        ; \tcrf(confirmed) I can't get this to ever execute. If you do
        ; force Mothula to a stunned state, it will drop to the floor (like
        ; you'd expect). Also have to set the stun timer for the sprite for
        ; that to work. After Mothula recovers, it sometimes is invisible and
        ; probably invulnerable. It's not clear why, but it suggests that
        ; the sprite originally would have been stunned in this fashion by
        ; use of the fire rod or another special weapon. This is just
        ; speculation, though. It also suggests that they couldn't get it to
        ; work properly.
        STZ $0D80, X
    
    .not_stunned
    
        JSR Sprite3_CheckIfActive
        
        STZ $0E60, X
        
        LDA $0EE0, X : BEQ .vulnerable
        
        ; Make sprite impervious (while the above timer ticks down).
        LDA.b #$40 : STA $0E60, X
    
    .vulnerable
    
        LDA $0EA0, X            : BEQ .not_recoiling
        AND.b #$7F : CMP.b #$06 : BNE .early_recover_delay
        
        ; Mothula apparently recovers slightly earlier from recoil than typical
        ; sprites.
        STZ $0EA0, X
        
        ; Make sprite impervious for about a half second.
        LDA.b #$20 : STA $0EE0, X
        
        ; And use this AI pointer.
        LDA.b #$02 : STA $0D80, X
        
        STZ $0DF0, X
        
        LDA.b #$40 : STA !beam_timer, X
    
    .early_recover_delay
    .not_recoiling
    
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Mothula_Delay
        dw Mothula_Ascend
        dw Mothula_FlyAbout
        dw Mothula_FireBeams
    }

; ==============================================================================

    ; *$F3ED8-$F3EE0 JUMP LOCATION
    Mothula_Delay:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$F3EE1-$F3F06 JUMP LOCATION
    Mothula_Ascend:
    {
        LDA.b #$08 : STA $0F80, X
        
        JSR Sprite3_MoveAltitude
        
        STZ $0F80, X
        
        LDA $0F70, X : CMP.b #$18 : BCC .below_target_altitude
        
        LDA.b #$80 : STA !beam_timer, X
        
        INC $0D80, X
        
        ; Make vulnerable to projectiles again (like the fire rod shot).
        STZ $0BA0, X
        
        LDA.b #$40 : STA $0DF0, X
    
    .below_target_altitude
    
        JSR Mothula_FlapWings
        
        RTS
    }

; ==============================================================================

    ; $F3F07-$F3F12 DATA
    pool Mothula_FlyAbout:
    {
    
    .z_accelerations
        db 1, -1
    
    .y_speeds length 8
        db -16, -12
    
    .x_speeds 
        db 0, 12, 16, 12, 0, -12, -16, -12
    }

; ==============================================================================

    ; *$F3F13-$F3F9A JUMP LOCATION
    Mothula_FlyAbout:
    {
        LDA !beam_timer, X : BNE .delay_beam_firing_mode
        
        LDA.b #$3F : STA $0DF0, X
        
        INC $0D80, X
        
        RTS
    
    .delay_beam_firing_mode
    
        DEC !beam_timer, X
        
        JSR Mothula_FlapWings
        
        LDA $0D90, X : AND.b #$01 : TAY
        
        LDA $0F80, X : ADD .z_accelerations, Y : STA $0F80, X
        
        CMP Sprite3_Shake.x_speeds, Y : BNE .anotoggle_z_acceleration_polarity
        
        INC $0D90, X
    
    .anotoggle_z_acceleration_polarity
    
        LDA $0DF0, X : BNE .delay_xy_speed_adjustment
        
        INC $0DB0, X : LDA $0DB0, X : CMP.b #$07 : BNE .use_random_xy_speeds
        
        STZ $0DB0, X
        
        BRA .go_towards_player
    
    .use_random_xy_speeds
    
        JSL GetRandomInt : AND.b #$07 : TAY
        
        ; speeds are randomly selected.
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$40 : STA $0DF0, X
        
        BRA .tile_collision_logic
    
    .go_towards_player
    
        LDA.b #$20 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA.b #$80 : STA $0DF0, X
    
    .delay_xy_speed_adjustment
    .tile_collision_logic
    
        LDA $0E70, X : BNE .move_if_no_tile_collision
        
        JSR Sprite3_Move
    
    .move_if_no_tile_collision
    
        JSR Sprite3_MoveAltitude
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        ; Immediately do a speed adjustment next frame if we hit a solid tile.
        STZ $0DF0, X
    
    .no_tile_collision
    
        JSR Sprite3_CheckDamage
        
        INC $0E80, X : INC $0E80, X
        
        RTS
    }

; ==============================================================================

    ; $F3F9B-$F3F9E DATA
    pool Mothula_FlapWings:
    {
    
    .animation_states
        db 0, 1, 2, 1
    }

; ==============================================================================

    ; *$F3F9F-$F3FB8 LOCAL
    Mothula_FlapWings:
    {
        INC $0E80, X
        
        LDA $0E80, X : LSR #2 : AND.b #$03 : TAY : BNE .sfx_delay
        
        LDA.b #$02 : JSL Sound_SetSfx3PanLong
    
    .sfx_delay
    
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F3FB9-$F3FD8 JUMP LOCATION
    Mothula_FireBeams:
    {
        JSR Sprite3_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        DEC $0D80, X
        
        JSL GetRandomInt : AND.b #$1F : ORA.b #$40 : STA !beam_timer, X
        
        RTS
    
    .delay
    
        CMP.b #$20 : BNE .dont_fire_beam
        
        JSR Mothula_SpawnBeams
    
    .dont_fire_beam
    
        BRA Mothula_FlapWings
    }

; ==============================================================================

    ; $F3FD9-$F3FDE DATA
    Mothula_SpawnBeams:
    {
    
    ; \note Yes, they are combined for this routine.
    .x_offsets
    .x_speeds
        db -16, 0, 16
    
    .y_speeds
        db 24, 32, 24
    }

; ==============================================================================

    ; *$F3FDF-$F402D BRANCH LOCATION
    Mothula_SpawnBeams:
    {
        LDA.b #$36 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$02 : STA $0FB5
    
    .spawn_next_beam
    
        LDA.b #$89
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $02 : SUB $04 : ADD.b #$03 : STA $0D00, Y
        
        LDA.b #$10 : STA $0DF0, Y
                     STA $0BA0, Y
        
        PHX
        
        LDX $0FB5
        
        LDA $00 : ADD .x_offsets, X : STA $0D10, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA.b #$00 : STA $0F70, Y
        
        PLX
    
    .spawn_failed
    
        DEC $0FB5 : BPL .spawn_next_beam
        
        RTS
    }

; ==============================================================================

    ; $F402E-$F4087 DATA
    pool Mothula_ActivateMovingSpikeBlock:
    {
    
    .x_coords_low
        db $38, $48, $58, $68, $88, $98, $A8, $B8
        db $C8, $C8, $C8, $C8, $C8, $C8, $C8, $B8
        db $A8, $98, $78, $68, $58, $48, $38, $28
        db $28, $28, $28, $28, $28, $28
    
    .y_coords_low
        db $38, $38, $38, $38, $38, $38, $38, $38
        db $48, $58, $68, $78, $98, $A8, $B8, $C8
        db $C8, $C8, $C8, $C8, $C8, $C8, $C8, $B8
        db $A8, $98, $78, $68, $58, $48
    
    .directions
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $01, $01, $01, $03
        db $03, $03, $03, $03, $03, $03, $03, $00
        db $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$F4088-$F4102 LOCAL
    Mothula_ActivateMovingSpikeBlock:
    {
        DEC !spike_activation_timer, X : BNE .activation_delay
        
        ; Set the delay for 64 more frames.
        LDA.b #$40 : STA !spike_activation_timer, X
        
        LDA.b #$8A : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        JSL GetRandomInt : AND.b #$1F : CMP #$1E : BCC .already_in_range
        
        SBC.b #$1E
    
    .already_in_range
    
        TAX
        
        LDA .x_coords_low, X : STA $0D10, Y
                               STA $0D90, Y
        
        LDA .y_coords_low, X : DEC A : STA $0D00, Y
                                       STA $0DA0, Y
        
        LDA .directions, X : STA $0DE0, Y
        
        ; \note Differentiates it from a standard spike block as it will
        ; melt back into the scenery when it collides with tiles.
        LDA.b #$01 : STA $0E90, Y
        
                     ADD $0FB0 : STA $0D30, Y
        LDA.b #$01 : ADD $0FB1 : STA $0D20, Y
        
        TYX
        
        ; \note The collision is being detected from the sprite's spawned
        ; position, which is potentially in the upper left of a bg based
        ; spike block. So it's checking for collision with a spike block
        ; "underneath" it, so to speak.
        LDA.b #$01 : STA $0D50, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        JSR Sprite3_CheckTileCollision
        
        STZ $0D50, X
        
        LDA $0D90, X : STA $0D10, X
        
        LDA $0DA0, X : STA $0D00, X
        
        LDA $0E70, X : BNE .spawning_atop_spike_block
        
        ; Essentially this code is to prevent the transient spike block from
        ; materializing from thin air / from the floor, however you want to
        ; look at it.
        STZ $0DD0, X
        
        PLX
        
        LDA.b #$01 : STA !spike_activation_timer, X
        
        RTS
    
    .spawning_atop_spike_block
    
        PLX
    
    .spawn_failed
    .activation_delay
    
        RTS
    }

; ==============================================================================
