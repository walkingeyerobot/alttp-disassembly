
; ==============================================================================

    ; $323F9-$32408 DATA
    Sprite_Helmasaur:
    {
    
    .animation_states
        db 3, 4, 3, 4, 2, 2, 5, 5
    
    .h_flip
        db $40, $40, $00, $00, $00, $40, $40, $00
    }

; ==============================================================================

    ; *$32409-$324D1 JUMP LOCATION
    Sprite_Helmasaur:
    {
        LDA $0DE0, X : ASL A : STA $00
        
        LDA $0E80, X : LSR #2 : AND.b #$01 : ORA $00 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
        
        TXA : EOR $1A : AND.b #$0F : BNE .delay_direction_selection_logic
        
        LDA $0D50, X : BPL .abs_x_speed
        
        EOR.b #$FF : INC A

    .abs_x_speed

        STA $00
        
        LDA $0D40, X : BPL .abs_y_speed
        
        EOR.b #$FF : INC A

    .abs_y_speed

        STA $01
        
        LDA $00 : CMP $01
        
        LDA.b #$00
        
        LDY $0D50, X
        
        BCS .x_speed_magnitude_greater_or_equal
        
        LDA.b #$02
        
        LDY $0D40, X
    
    .x_speed_magnitude_greater_or_equal
    
        BPL .winning_speed_is_not_negative
        
        INC A
    
    .winning_speed_is_not_negative
    
        STA $0DE0, X
    
    .delay_direction_selection_logic
    
        JSR Sprite_PrepAndDrawSingleLarge
        
        BRA .done_drawing
    
    ; *$32460 ALTERNATE ENTRY POINT
    shared Sprite_HardHatBeetle:
    
        LDA $0E80, X : LSR #2 : AND.b #$01 : STA $0DC0, X
        
        JSR HardHatBeetle_Draw

    .done_drawing

        JSR Sprite_CheckIfActive
        
        INC $0E80, X
        
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        LDA $0E70, X : AND.b #$0F : BEQ .no_tile_collision
        
        AND.b #$03 : BEQ .no_horizontal_tile_collision
        
        STZ $0D50, X
    
    .no_horizontal_tile_collision
    
        ; \wtf Seems like not really a bug, but a quirk. If it hit tiles it
        ; always zeroes its y velocity, but conditionally zeroes the x velocity.
        STZ $0D40, X
        
        BRA .dont_move
    
    .no_tile_collision
    
        JSR Sprite_Move
    
    .dont_move
    
        JSR Sprite_CheckTileCollision
        
        TXA : EOR $1A : AND.b #$1F : BNE .project_speed_delay
        
        LDA $0D90, X
        
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : STA $0DA0, X
        
        LDA $01 : STA $0DB0, X
    
    .project_speed_delay
    
        TXA : EOR $1A : AND $0D80, X : BNE .acceleration_delay
        
        LDA $0D40, X : CMP $0DA0, X : BPL .y_speed_maxed
        
        INC $0D40, X
        
        BRA .check_x_speed
    
    .y_speed_maxed
    
        DEC $0D40, X
    
    .check_x_speed
    
        LDA $0D50, X : CMP $0DB0, X : BPL .x_speed_maxed
        
        INC $0D50, X
        
        BRA .return
    
    .x_speed_maxed
    
        DEC $0D50, X
    
    .return
    .acceleration_delay
    
        RTS
    }

; ==============================================================================

    ; $324D2-$324F1 DATA
    {
    
    .oam_groups
        dw 0, -4 : db $40, $01, $00, $02
        dw 0,  2 : db $42, $01, $00, $02
        
        dw 0, -5 : db $40, $01, $00, $02
        dw 0,  2 : db $44, $01, $00, $02
    }

; ==============================================================================

    ; *$324F2-$3250B LOCAL
    HardHatBeetle_Draw:
    {
        LDA $0DC0, X : ASL #4
        
        ADC.b #.oam_groups                 : STA $08
        LDA.b #.oam_groups>>8 : ADC.b #$00 : STA $09
        
        LDA.b #$02 : JSL Sprite_DrawMultiple
        
        JMP Sprite_DrawShadowRedundant
    }

; ==============================================================================
