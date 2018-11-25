
; ==============================================================================

    ; $E84F1-$E8530 DATA
    pool ChimneySmoke_Draw:
    {
    
    .oam_groups
        dw 0, 0 : db $86, $00, $00, $00
        dw 8, 0 : db $87, $00, $00, $00
        dw 0, 8 : db $96, $00, $00, $00
        dw 8, 8 : db $97, $00, $00, $00
        
        dw 1, 1 : db $86, $00, $00, $00
        dw 7, 1 : db $87, $00, $00, $00
        dw 1, 7 : db $96, $00, $00, $00
        dw 7, 7 : db $97, $00, $00, $00
    }

; ==============================================================================

    ; *$E8531-$E854D LOCAL
    ChimneySmoke_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : AND.b #$01 : REP #$20 : ASL #5
        
        ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04
    
    ; *$E8549 ALTERNATE ENTRY POINT
    shared Sprite4_DrawMultiple:
    
        JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================

    ; $E854E-$E854F DATA
    pool Sprite_ChimneySmoke:
    parallel pool Sprite_Chimney:
    {
    
    ; \task Name this routine / pool.
    .x_speed_targets
        db 4, -4
    }

; ==============================================================================

    ; *$E8550-$E858A BRANCH LOCATION
    Sprite_ChimneySmoke:
    {
        LDA.b #$30 : STA $0B89, X
        
        JSR ChimneySmoke_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_Move
        
        INC $0E80, X : LDA $0E80, X : AND.b #$07 : BNE .speed_adjust_delay
        
        LDA $0DE0, X : AND.b #$01 : TAY
        
        LDA $0D50, X
        
        ADD Sprite_ApplyConveyorAdjustment.x_shake_values, Y : STA $0D50, X
        
        CMP .x_speed_targets, Y : BNE .anoswitch_direction
        
        INC $0DE0, X
    
    .anoswitch_direction
    .speed_adjust_delay
    
        LDA $0E80, X : AND.b #$1F : BNE .anoincrement_animation_state
        
        INC $0DC0, X
    
    .anoincrement_animation_state
    
        RTS
    }

; ==============================================================================

    ; *$E858B-$E85DF JUMP LOCATION
    Sprite_ChimneyAndRabbitBeam:
    shared Sprite_Chimney: ; \note This is only put here to indicate an alias.
    {
        LDA $1B : BNE Sprite_RabbitBeam
        
        LDA.b #$40 : STA $0E60, X : STA $0BA0, X
        
        LDA $0D80, X : BNE Sprite_ChimneySmoke
        
        JSR Sprite4_CheckIfActive
        
        LDA $0DF0, X : BNE .spawn_delay
        
        LDA.b #$43 : STA $0DF0, X
        
        LDA.b #$D1 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $00 : ADD.b #$08 : STA $0D10, Y
        
        LDA $02 : ADC.b #$04 : STA $0D00, Y
        
        LDA.b #$04 : STA $0F50, Y : STA $0D80, Y
        
        LDA.b #$43 : STA $0E40, Y : STA $0E60, Y
        
        LDA .x_speed_targets+1 : STA $0D50, Y
        
        LDA.b #-6 : STA $0D40, Y
    
    .spawn_delay
    .spawn_failed
    
        RTS
    }
    
; ==============================================================================

    ; $E85E0-$E85F9 BRANCH LOCATION
    Sprite_RabbitBeam:
    {
    
        LDA $0D80, X : BNE RabbitBeam_Active
        
        JSL Sprite_PrepOamCoordLong
        JSR Sprite4_CheckIfActive
        
        JSR Sprite4_CheckTileCollision : BNE .no_tile_collision
        
        INC $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
    
    .no_tile_collision
    
        RTS
    }

; ==============================================================================

    ; $E85FA-$E85FF DATA
    pool RabbitBeam_Active:
    {
    
    .chr
        db $D7, $D7, $D7, $91, $91, $91
    }

; ==============================================================================

    ; *$E8600-$E8669 BRANCH LOCATION
    RabbitBeam_Active:
    {
        JSL Sprite_DrawFourAroundOne
        
        LDA $0F00, X : BNE .sprite_is_paused
        
        LDY $0DC0, X
        
        LDA .chr, Y : STA $00
        
        LDY.b #$00
    
    .next_oam_entry
    
        ; Force the chr to a certain value, and the palette of each entry
        ; to palette 1 (name table is also forced to 0 here).
        INY #2 : LDA $00                                : STA ($90), Y
        INY    : LDA ($90), Y : AND.b #$F0 : ORA.b #$02 : STA ($90), Y
        
        INY : CPY.b #$14 : BCC .next_oam_entry
    
    .sprite_is_paused
    
        JSR Sprite4_CheckIfActive
        
        LDA $0DF0, X : BNE .cant_move_yet
        
        LDA.b #$30 : STA $0CD2, X
        
        ; The hunter is alive, but didn't get link yet.
        JSL Sprite_CheckDamageToPlayerLong : BCC .no_player_collision
        
        ; The hunter is dead, and it got Link to turn into a bunny.
        STZ $0DD0, X
        
        ; This useless load probably indicates a commented out store to the 
        ; countdown timer that would use 0x180 frames instead of 0x100.
        LDA.b #$80
        
        ; Set the tempbunny countdown timer to 0x100 frames.
                     STZ $03F5
        LDA.b #$01 : STA $03F6
    
    .no_player_collision
    
        ; Only adjust trajectory if player is on the same layer.
        LDA $EE : CMP $0F20, X : BNE .cant_track_player
        
        LDA.b #$10
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
    
    .cant_track_player
    
        JSR Sprite4_Move
        
        JSR Sprite4_CheckTileCollision : BEQ .no_tile_collision
        
        ; The transformer ran into a wall and died.
        STZ $0DD0, X
        
        JSL Sprite_SpawnPoofGarnish
        
        ; Selects a sound to play.
        LDA.b #$15 : JSL Sound_SetSfx2PanLong
    
    .cant_move_yet
    .no_tile_collision
    
        RTS
    }

; ==============================================================================
