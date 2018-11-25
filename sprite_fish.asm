
; ==============================================================================

    ; *$E8235-$E826B JUMP LOCATION
    Sprite_Fish:
    {
        ; Check if if the right graphics are loaded to be able to draw.
        LDA $0FC6 : CMP.b #$03 : BCS .improper_gfx_pack_loaded
        
        JSR Fish_Draw
    
    .improper_gfx_pack_loaded
    
        LDA $0DD0, X : CMP.b #$0A : BNE .not_held_by_player
        
        ; Can only wriggle while being held.
        LDA.b #$04 : STA $0D80, X
        
        LDA $1A : LSR #3 : AND.b #$02 : LSR A : ADC.b #$03 : STA $0DC0, X
    
    .not_held_by_player
    
        JSR Sprite4_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Fish_PreliminaryDeepWaterCheck
        dw Fish_FlopAround
        dw Fish_PauseBeforeLeap
        dw Fish_Leaping
        dw Fish_Wriggle
    }

; ==============================================================================

    ; $E826C-$E827D JUMP LOCATION
    Fish_Wriggle:
    {
        LDA $0F70, X : BNE .aloft
        
        ; Go back to flopping when you hit the ground.
        LDA.b #$01 : STA $0D80, X
    
    .aloft
    
        JSR Sprite4_Move
        
        ; \note It's what allows the fish to become grateful, as this is 
        ; the only way the player can become thanked. If the fish just flops
        ; itself into deep water, it won't thank you at all. And naturally you
        ; didn't really do as much as you could in that scenario anyway, now
        ; did you?
        JSL ThrownSprite_TileAndPeerInteractionLong
        
        RTS
    }

; ==============================================================================

    ; *$E827E-$E828F JUMP LOCATION
    Fish_PauseBeforeLeap:
    {
        LDA $0DF0, X : BNE .delay
        
        ; Transition to leaping state.
        INC $0D80, X
        
        ; Determine the Z speed of the leap.
        LDA.b #$30 : STA $0F80, X
    
    ; *$E828B ALTERNATE ENTRY POINT
    shared Fish_SpawnSmallWaterSplash:
    
        JSL Sprite_SpawnSmallWaterSplash
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $E8290-$E82A0 DATA
    pool Fish_Leaping:
    {
    
    .animation_states
        db 5, 5, 6, 6, 5, 5, 4, 4
        db 3, 7, 7, 8, 8, 7, 7, 8
        db 8
    }

; ==============================================================================

    ; *$E82A1-$E830E JUMP LOCATION
    Fish_Leaping:
    {
        JSR Sprite4_MoveAltitude
        
        DEC $0F80, X : DEC $0F80, X : BNE .still_ascending
        
        ; Recall that leaping fish are only grateful if they were on land
        ; and helped into water by a helpful little elf man or woman throwing
        ; them back in.
        LDY $0D90, X : BEQ .ungrateful
        
        LDA.b #$76 : STA $1CF0
        LDA.b #$01 : JSR Sprite4_ShowMessageMinimal
    
    .ungrateful
    .still_ascending
    
        LDA $0F70, X : BPL .aloft
        
        STZ $0F70, X
        
        JSR Fish_SpawnSmallWaterSplash
        
        LDA $0D90, X : BEQ .no_rupees_for_you
        
        LDA.b #$DB : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $00 : ADD.b #$04 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA.b #$FF : STA $0B58, Y
        
        LDA.b #$30 : STA $0F80, Y : STA $0EE0, Y
        
        PHX
        
        TYX
        
        LDA.b #$10 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        PLX
    
    .spawn_failed
    .no_rupees_for_you
    
        STZ $0DD0, X
    
    .aloft
    
        INC $0E80, X : LDA $0E80, X : LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$E830F-$E8320 JUMP LOCATION
    Fish_PreliminaryDeepWaterCheck:
    {
        JSR Sprite4_CheckTileCollision
        
        LDA $0FA5 : CMP.b #$08 : BNE .not_deep_water
        
        ; Fell into deep water, time to skidaddle.
        STZ $0DD0, X
        
        RTS
    
    .not_deep_water
    
        ; Move on, otherwise.
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $E8321-$E8335 DATA
    Fish_FlopAround:
    {
    
    .x_speeds
        db   0,  12,  16,  12,   0, -12, -16, -12
    
    .y_speeds
        db -16, -12,   0,  12,  16,  12,   0, -12
    
    .boundary_limits
        db 2, 0
    
    .animation_state_bases
        db 5, 1, 3
    }

; ==============================================================================

    ; *$E8336-$E83B5 JUMP LOCATION
    Fish_FlopAround:
    {
        JSL Sprite_CheckIfLiftedPermissiveLong
        JSR Sprite4_BounceFromTileCollision
        JSR Sprite4_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .aloft
        
        STZ $0F70, X
        
        LDA $0FA5 : CMP.b #$09 : BEQ .touched_shallow_water
                    CMP.b #$08 : BNE .didnt_touch_deep_water
        
        ; Time to swim with the fishes. (I.e. your brothers).
        STZ $0DD0, X
    
    .touched_shallow_water
    
        JSR Fish_SpawnSmallWaterSplash
    
    .didnt_touch_deep_water
    
        JSL GetRandomInt : AND.b #$0F : ADC.b #$10 : STA $0F80, X
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        INC $0DE0, X
        
        LDA.b #$03 : STA $0E80, X
    
    .aloft
    
        INC $0E80, X
        
        ; \note The way they simulate a flopping fish is quite impressive.
        ; Just kind of... awed by it. It could be more detailed but it's
        ; pretty damn good the way it is.
        LDA $0E80, X : AND.b #$07 : BNE .delay_animation_base_adjustment
        
        LDA $0DE0, X : AND.b #$01 : TAY
        
        ; \note The index for the animation fluctates between 0 and 2 inclusive.
        LDA $0D90, X : CMP .boundary_limits, Y : BEQ .at_boundary_already
        
        ADD Sprite_ApplyConveyorAdjustment.x_shake_values, Y : STA $0D90, X
    
    .at_boundary_already
    .delay_animation_base_adjustment
    
        LDA $1A : LSR #3 : AND.b #$01 : LDY $0D90, X
        
        ADD .animation_state_bases, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $E83B6-$E8482 POOL
    pool Fish_Draw:
    {
    
    .oam_groups
        dw -4,  8 : db $5E, $04, $00, $00
        dw  4,  8 : db $5F, $04, $00, $00
        
        dw -4,  8 : db $5E, $84, $00, $00
        dw  4,  8 : db $5F, $84, $00, $00
        
        dw -4,  8 : db $5F, $44, $00, $00
        dw  4,  8 : db $5E, $44, $00, $00
        
        dw -4,  8 : db $5F, $C4, $00, $00
        dw  4,  8 : db $5E, $C4, $00, $00
        
        dw  0,  0 : db $61, $04, $00, $00
        dw  0,  8 : db $71, $04, $00, $00
        
        dw  0,  0 : db $61, $44, $00, $00
        dw  0,  8 : db $71, $44, $00, $00
        
        dw  0,  0 : db $71, $84, $00, $00
        dw  0,  8 : db $61, $84, $00, $00
        
        dw  0,  0 : db $71, $C4, $00, $00
        dw  0,  8 : db $61, $C4, $00, $00
    
    .shadow_oam_groups
        dw -2, 11 : db $38, $04, $00, $00
        dw  0, 11 : db $38, $04, $00, $00
        dw  2, 11 : db $38, $04, $00, $00
        
        dw -1, 11 : db $38, $04, $00, $00
        dw  0, 11 : db $38, $04, $00, $00
        dw  1, 11 : db $38, $04, $00, $00
        
        dw  0, 11 : db $38, $04, $00, $00
        dw  0, 11 : db $38, $04, $00, $00
        dw  0, 11 : db $38, $04, $00, $00
    
    .dont_draw
    
        JSL Sprite_PrepOamCoordLong
        
        RTS
    }

; ==============================================================================

    ; *$E8483-$E84F0 LOCAL
    Fish_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : BEQ .dont_draw
        
        DEC A
        
        REP #$20
        
        ASL #4 : ADC.w #(.oam_groups) : STA $08
        
        LDA $0FD8 : ADD.w #$0004 : STA $0FD8
        
        SEP #$20
        
        LDA.b #$02 : JSL Sprite_DrawMultiple
        
        LDA $0FDA : ADD $0F70, X : STA $0FDA
        LDA $0FDB : ADC.b #$00   : STA $0FDB
        
        LDA.b #$00 : XBA
        
        LDA $0F70, X : LSR #2 : CMP.b #$02 : BCC .shadow_oam_groups
        
        ; Use the smallest shadow oam group if the sprite is way up.
        LDA.b #$02
    
    .shadow_oam_groups
    
        REP #$20 : ASL #3 : STA $00 : ASL A : ADC $00
        
        ADC.w #(.unknown) : STA $08
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        LDA.b #$03 : JSL Sprite_DrawMultiple
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        RTS
    }

; ==============================================================================
