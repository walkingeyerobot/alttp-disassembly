
; ==============================================================================

    ; $E9C7A-$E9C7F DATA
    pool Swamola_InitSegments:
    {
    
    .ram_offsets
        db $00, $20, $40, $60, $80, $A0
    }

; ==============================================================================

    ; *$E9C80-$E9CAC LONG
    Swamola_InitSegments:
    {
        PHX : TXY
        
        ; \bug(confirmed) This loads from the wrong bank when this function
        ; is called.
        LDA .ram_offsets, X : TAX
        
        LDA.b #$1F : STA $00
    
    .next_segment
    
        LDA $0D10, Y : STA $7FFA5C, X
        LDA $0D30, Y : STA $7FFB1C, X
        
        LDA $0D00, Y : STA $7FFBDC, X
        LDA $0D20, Y : STA $7FFC9C, X
        
        INX
        
        DEC $00 : BPL .next_segment
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; \unused This pool seems to be completely unused.
    ; $E9CAD-$E9CAF DATA
    pool Sprite_Swamola:
    {
        db $00, $10, $F0
    }

; ==============================================================================

    ; *$E9CB0-$E9CEC JUMP LOCATION
    Sprite_Swamola:
    {
        LDA $0D80, X : BEQ .dont_draw
                       BPL .not_ripples
        
        JMP Sprite_SwamolaRipples
    
    .not_ripples
    
        JSR Swamola_Draw
    
    .dont_draw
    
        JSL Sprite_Get_16_bit_CoordsLong
        JSR Sprite4_CheckIfActive
        
        INC $0E80, X
        
        JSR Sprite4_CheckDamage
        
        LDA $0D40, X : PHA : ADD $0F80, X : STA $0D40, X
        
        JSR Sprite4_Move
        
        PLA : STA $0D40, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Swamola_Emerge
        dw Swamola_Ascending
        dw Swamola_WiggleTowardsTarget
        dw Swamola_Descending
        dw Swamola_Submerge
    }

; ==============================================================================

    ; $E9CED-$E9D18 DATA
    pool Swamola_Submerged:
    {
    
    .x_offsets_low
        db   0,   0,  32,  32,  32,   0, -32, -32
        db -32
    
    .x_offsets_high
        db   0,   0,   0,   0,   0,   0,  -1,  -1
        db  -1
    
    .x_offsets_low
        db   0, -32, -32,   0,  32,  32,  32,   0
        db -32
    
    .y_offsets_high
        db   0,  -1,  -1,   0,   0,   0,   0,   0
        db  -1
    
    .directions
        db 1, 2, 3, 4, 5, 6, 7, 8
    }

; ==============================================================================

    ; *$E9D19-$E9D66 JUMP LOCATION
    Swamola_Emerge:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        ; Seems like a staggering mechanism.
        LDA .directions, Y : CMP $0DE0, X : BEQ .direction_mismatch
        
        TAY
        
        LDA $0D90, X : ADD .x_offsets_low,  Y : STA $7FFD5C, X
        LDA $0DA0, X : ADC .x_offsets_high, Y : STA $7FFD62, X
        
        LDA $0DB0, X : ADD .y_offsets_low,  Y : STA $7FFD68, X
        LDA $0EB0, X : ADC .y_offsets_high, Y : STA $7FFD6E, X
        
        INC $0D80, X
        
        JSR Sprite4_Zero_XY_Velocity
        
        LDA.b #$F1 : STA $0F80, X
        
        JSR Swamola_SpawnRipples
    
    .direction_mismatch
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$E9D67-$E9DA2 JUMP LOCATION
    Swamola_Ascending:
    {
        LDA $0E80, X : AND.b #$03 : BNE .delay_upward_acceleration
        
        INC $0F80, X : BNE .delay_state_transition
        
        INC $0D80, X
    
    .delay_state_transition
    .delay_upward_acceleration
    
        LDA $0E80, X : AND.b #$03 : BNE .delay_speed_checks
        
        JSR Swamola_PursueTargetCoord
    
    ; *$E9D80 ALTERNATE ENTRY POINT
    shared Swamola_ApproachPursuitSpeed:
    
        LDA $0D40, X : CMP $00 : BEQ .at_target_y_speed
                                 BPL .above_target_y_speed
        
        INC $0D40, X
        
        BRA .check_x_speed
    
    .above_target_y_speed
    
        DEC $0D40, X
    
    .at_target_y_speed
    .check_x_speed
    
        LDA $0D50, X : CMP $01 : BEQ .at_target_x_speed
                                 BPL .above_target_x_speed
        
        INC $0D50, X
        
        BRA .return
    
    .above_target_x_speed
    
        DEC $0D50, X
    
    .return
    .at_target_x_speed
    .delay_speed_checks
    
        RTS
    }

; ==============================================================================

    ; $E9DA3-$E9DA6 DATA
    pool Swamola_WiggleTowardsTarget:
    {
    
    .z_offsets
        db  2,  -2
    
    .z_offset_limits
        db 12, -12
    }

; ==============================================================================

    ; *$E9DA7-$E9E12 JUMP LOCATION
    Swamola_WiggleTowardsTarget:
    {
        ; \unused The branch can never be taken (though we will end up there
        ; eventually).
        LDA $0E80, X : AND.b #$00 : BNE .never
        
        LDA $0ED0, X : AND.b #$01 : TAY
        
        LDA $0F80, X : ADD .z_offsets, Y : STA $0F80, X
        
        CMP .z_offset_limits, Y : BNE .anotoggle_wiggle_direction
        
        INC $0ED0, X
    
    .anotoggle_wiggle_direction
    .never
    
        LDA $7FFD5C, X : STA $04
        LDA $7FFD62, X : STA $05
        
        LDA $7FFD68, X : STA $06
        LDA $7FFD6E, X : STA $07
        
        REP #$20
        
        LDA $0FD8 : SUB $04 : ADD.w #$0008 : CMP.w #$0010 : BCS .not_at_target
        
        LDA $0FDA : SUB $06 : ADD.w #$0008 : CMP.w #$0010 : BCS .not_at_target
        
        SEP #$20
        
        INC $0D80, X
    
    .not_at_target
    
        SEP #$20
        
        JSR Swamola_PursueTargetCoord
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        RTS
    }

; ==============================================================================

    ; *$E9E13-$E9E31 LOCAL
    Swamola_PursueTargetCoord:
    {
        LDA $7FFD5C, X : STA $04
        LDA $7FFD62, X : STA $05
        
        LDA $7FFD68, X : STA $06
        LDA $7FFD6E, X : STA $07
        
        LDA.b #$0F : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        RTS
    }

; ==============================================================================

    ; *$E9E32-$E9E61 JUMP LOCATION
    Swamola_Descending:
    {
        LDA $0E80, X : AND.b #$03 : BNE .delay_altitude_check
        
        INC $0F80, X : LDA $0F80, X : CMP.b #$10 : BNE .continue_descent
        
        INC $0D80, X
        
        JSR Swamola_SpawnRipples
        
        ; Puts the sprite out of harm's way and can't damage the player.
        LDA.b #$80 : STA $0D20, X
        
        LDA.b #$50 : STA $0DF0, X
    
    .continue_descent
    .delay_altitude_check
    
        LDA $0E80, X : AND.b #$03 : BNE .delay_speed_adjustment
        
        STZ $00
        STZ $01
        
        JSR Swamola_ApproachPursuitSpeed
    
    .delay_speed_adjustment
    
        RTS
    }

; ==============================================================================

    ; *$E9E62-$E9EA9 JUMP LOCATION
    Swamola_Submerge:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA Swamola_Emerge.directions, Y : STA $0DE0, X : TAY
        
        LDA $0D90, X : ADD Swamola_Emerge.x_offsets_low,  Y : STA $0D10, X
        LDA $0DA0, X : ADC Swamola_Emerge.x_offsets_high, Y : STA $0D30, X
        
        LDA $0DB0, X : ADD Swamola_Emerge.y_offsets_low,  Y : STA $0D00, X
        LDA $0EB0, X : ADC Swamola_Emerge.y_offsets_high, Y : STA $0D20, X
        
        STZ $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
        
        JSR Sprite4_Zero_XY_Velocity
        
        STZ $0F80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$E9EAA-$E9ECD LOCAL
    Swamola_SpawnRipples:
    {
        LDA.b #$CF : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$80 : STA $0D80, Y
        
        LDA.b #$20 : STA $0DF0, Y
        
        LDA.b #$04 : STA $0F50, Y
                     STA $0BA0, Y
        
        LDA.b #$00 : STA $0E40, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$E9ECE-$E9EDC LOCAL
    Sprite_SwamolaRipples:
    {
        JSR SwamolaRipples_Draw
        JSR Sprite4_CheckIfActive
        
        LDA $0DF0, X : BNE .delay
        
        STZ $0DD0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $E9EDD-$E9F1C DATA
    pool SwamolaRipples_Draw:
    {
    
    .oam_groups
        dw 0, 4 : db $D8, $00, $00, $00
        dw 8, 4 : db $D8, $40, $00, $00
        
        dw 0, 4 : db $D9, $00, $00, $00
        dw 8, 4 : db $D9, $40, $00, $00
        
        dw 0, 4 : db $DA, $00, $00, $00
        dw 8, 4 : db $DA, $40, $00, $00
        
        dw 0, 4 : db $D9, $00, $00, $00
        dw 8, 4 : db $D9, $40, $00, $00
    }

; ==============================================================================

    ; *$E9F1D-$E9F3B LOCAL
    SwamolaRipples_Draw:
    {
        LDA.b #$08 : JSL OAM_AllocateFromRegionB
        
        LDA.b #$00   : XBA
        LDA $0DF0, X : AND.b #$0C : REP #$20 : ASL #2
        
        ADD.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite4_DrawMultiple
    }

; ==============================================================================

    ; $E9F3C-$E9F63 DATA
    pool Swamola_Draw:
    {
    
    .unknown_0
        db $08, $10, $16, $1A
    
    .head_animation_states
        db 7, 6, 5, 4, 3, 4, 5, 6
        db 7, 6, 5, 4, 3, 4, 5, 6
    
    .head_vh_flip
        ; \bug Is that a bug in the last 4 bytes? How irregular.
        db $C0, $C0, $C0, $C0, $80, $80, $80, $80
        db $00, $00, $00, $00, $00, $40, $40, $40
    
    .segment_animation_states
        db 0, 0, 1, 2
    }

; ==============================================================================

    ; *$E9F64-$EA03B LOCAL
    Swamola_Draw:
    {
        LDA $0D50, X : STA $01
        
        LDA $0D40, X : ADD $0F80, X : STA $00
        
        JSL Sprite_ConvertVelocityToAngle : TAY
        
        LDA .head_animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$3F : ORA .head_vh_flip, Y : STA $0F50, X
        
        ; Draw the head portion.
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        PHX : TXY
        
        LDA $0E80, X : AND.b #$1F : ADD $9C7A, X : TAX
        
        LDA $0D10, Y : STA $7FFA5C, X
        LDA $0D30, Y : STA $7FFB1C, X
        
        LDA $0D00, Y : STA $7FFBDC, X
        LDA $0D20, Y : STA $7FFC9C, X
        
        PLX
        
        REP #$20
        
        LDA.w #$0000
        
        LDY $0D40, X : BPL .moving_downward
        
        LDA.w #$0014
    
    .moving_downward
    
        PHA : ADD $90 : STA $90
        
        PLA : LSR #2 : ADD $92 : STA $92
        
        SEP #$20
        
        LDA.b #$00 : STA $0FB6
    
    .segment_draw_loop
    
        LDY $0FB6
        
        LDA .segment_animation_states, Y : STA $0DC0, X
        
        PHX
        
        LDA $0E80, X : SUB .unknown_0, Y : AND.b #$1F : ADD $9C7A, X : TAX
        
        LDA $7FFA5C, X : STA $0FD8
        LDA $7FFB1C, X : STA $0FD9
        
        LDA $7FFBDC, X : STA $0FDA
        LDA $7FFC9C, X : STA $0FDB
        
        PLX
        
        LDA $0D40, X : BPL .moving_downward_2
        
        REP #$20
        
        ; \task Subtraction? What the hell is going on here?
        LDA $90 : SUB.w #$0004 : STA $90
        
        DEC $92
        
        BRA .draw_segment
    
    .moving_downward_2
    
        REP #$20
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
    
    .draw_segment
    
        SEP #$20
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        INC $0FB6 : LDA $0FB6 : CMP.b #$04 : BNE .segment_draw_loop
        
        RTS
    }

; ==============================================================================
