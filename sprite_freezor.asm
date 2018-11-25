
; ==============================================================================

    ; *$F181D-$F1858 JUMP LOCATION
    Sprite_Freezor:
    {
        JSL Freezor_Draw
        
        ; Essentially this is to find out if it was hit with a fire
        ; attack and make it melt instantly in that event.
        LDA $0DD0, X : CMP.b #$09 : BEQ .in_basic_active_state
        
        LDA.b #$03 : STA $0D80, X
        
        LDA.b #$1F : STA $0DF0, X : STA $0BA0, X
        
        LDA.b #$09 : STA $0DD0, X
        
        STZ $0EF0, X
    
    .in_basic_active_state
    
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X : CMP.b #$03 : BEQ .ignore_recoil_if_melting
        
        JSR Sprite3_CheckIfRecoiling
    
    .ignore_recoil_if_melting
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Freezor_Stasis
        dw Freezor_Awakening
        dw Freezor_Moving
        dw Freezor_Melting
    }

; ==============================================================================

    ; *$F1859-$F1870 JUMP LOCATION
    Freezor_Stasis:
    {
        INC $0BA0, X
        
        JSR Sprite3_IsToRightOfPlayer
        
        LDA $0F : ADD.b #$10 : CMP.b #$20 : BCS .player_not_in_horiz_range
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
    
    .player_not_in_horiz_range
    
        RTS
    }

; ==============================================================================

    ; *$F1871-$F18B7 JUMP LOCATION
    Freezor_Awakening:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .shaking
        
        INC $0D80, X
        
        LDA $0D10, X : SUB.b #$05 : STA $00
        LDA $0D30, X : SUB.b #$00 : STA $01
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        LDY.b #$08 : JSL Dungeon_SpriteInducedTilemapUpdate
        
        LDA.b #$60 : STA $0E00, X
        
        LDA.b #$02 : STA $0DE0, X
        
        LDA.b #$50 : STA $0DF0, X
        
        RTS
    
    .shaking
    
        AND.b #$01 : TAY
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        JSR Sprite3_MoveHoriz
        
        RTS
    }

; ==============================================================================

    ; $F18B8-$F18D1 DATA
    pool Freezor_Moving:
    {
    
    .x_speeds length 4
        db $08, $F8
    
    .y_speeds
        db $00, $00, $12, $EE
    
    .animation_states
        db $01, $02, $01, $03
    
    .sparkle_x_offsets_low
        db $FC, $FE, $00, $02, $04, $06, $08, $0A
    
    .sparkle_x_offsets_high
        db $FF, $FF, $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$F18D2-$F193D JUMP LOCATION
    Freezor_Moving:
    {
        JSR Sprite3_CheckDamageToPlayer
        
        ; $372AA IN ROM
        JSL Sprite_CheckDamageFromPlayerLong : BCC .no_damage_contact
        
        STZ $0EF0, X
    
    .no_damage_contact
    
        LDA $0E00, X : BEQ .dont_spawn_sparkle
        
        TXA : EOR $1A : AND.b #$07 : BNE .dont_spawn_sparkle
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA .sparkle_x_offsets_low, Y  : STA $00
        LDA .sparkle_x_offsets_high, Y : STA $01
        
        LDA.b #$FC : STA $02
        LDA.b #$FF : STA $03
        
        JSL Sprite_SpawnSimpleSparkleGarnish
    
    .dont_spawn_sparkle
    
        LDA $0DF0, X : BNE .dont_track_player_yet
        
        JSR Sprite3_DirectionToFacePlayer : TYA : STA $0DE0, X
    
    .dont_track_player_yet
    
        LDY $0DE0, X
        
        ; \note The Y speeds are faster than the X speeds.
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA $0E70, X : AND.b #$0F : BNE .tile_collision_occurred
        
        JSR Sprite3_Move
    
    .tile_collision_occurred
    
        JSR Sprite3_CheckTileCollision
        
        TXA : EOR $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F193E-$F1941 DATA
    pool Freezor_Melting:
    {
    
    .animation_states
        db $06, $05, $04, $07
    }

; ==============================================================================

    ; *$F1942-$F195A JUMP LOCATION
    Freezor_Melting:
    {
        LDA $0DF0, X : BNE .not_dead_yet
        
        PHA
        
        JSL Dungeon_ManuallySetSpriteDeathFlag
        
        STZ $0DD0, X
        
        PLA
    
    .not_dead_yet
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================
