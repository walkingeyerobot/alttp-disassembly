
; ==============================================================================

    ; $F2192-$F2195 DATA
    pool Sprite_Pengator:
    {
    
    .animation_states
        db $05, $00, $0A, $0F
    }

; ==============================================================================

    ; *$F2196-$F21E9 JUMP LOCATION
    Sprite_Pengator:
    {
        LDY $0DE0, X
        
        LDA $0D90, X : ADD .animation_states, Y : STA $0DC0, X
        
        JSR Pengator_Draw
        
        LDA $0EA0, X : BNE .recoiling
        
        LDA $0E70, X : AND.b #$0F : BEQ .no_tile_collision
    
    .recoiling
    
        STZ $0D80, X
        
        STZ $0D50, X
        
        STZ $0D40, X
    
    .no_tile_collision
    
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        JSR Sprite3_MoveXyz
        
        ; Apply gravity
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .hasnt_landed
        
        STZ $0F80, X
        
        STZ $0F70, X
    
    .hasnt_landed
    
        JSR Sprite3_CheckTileCollision
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Pengator_FacePlayer
        dw Pengator_SpeedUp
        dw Pengator_Jump
        dw Pengator_SlideAndSparkle
    }

; ==============================================================================

    ; *$F21EA-$F21F4 JUMP LOCATION
    Pengator_FacePlayer:
    {
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0DE0, X
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $F21F5-$F21FA DATA
    pool Pengator_SpeedUp:
    {
    
    .x_speeds length 4
        db 1, -1
        
        db 0,  0, 1, -1
    }

; ==============================================================================

    ; *$F21FB-$F223F JUMP LOCATION
    Pengator_SpeedUp:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .delay
        
        STZ $00
        
        LDY $0DE0, X
        
        LDA $0D50, X : CMP Sprite3_Shake.x_speeds, Y : BEQ .x_speed_at_target
        
        ADD .x_speeds, Y : STA $0D50, X
        
        INC $00
    
    .x_speed_at_target
    
        LDA $0D40, X : CMP Sprite3_Shake.y_speeds, Y : BEQ .y_speed_at_target
        
        ADD .y_speeds, Y : STA $0D40, X
        
        INC $00
    
    .y_speed_at_target
    
        LDA $00 : BNE .added_speed_this_frame
        
        LDA.b #$0F : STA $0DF0, X
        
        INC $0D80, X
    
    .added_speed_this_frame
    .delay
    
        LDA $1A : AND.b #$04 : LSR #2 : TAY : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $F2240-$F2243 DATA
    pool Pengator_Jump:
    {
    
    .animation_states
        db 4, 4, 3, 2
    }

; ==============================================================================

    ; *$F2244-$F2260 JUMP LOCATION
    Pengator_Jump:
    {
        LDA $0DF0, X : BNE .state_transition_delay
        
        INC $0D80, X
    
    .state_transition_delay
    
        CMP.b #$05 : BNE .anojump
        
        PHA
        
        LDA.b #$18 : STA $0F80, X
        
        PLA
    
    .anojump
    
        LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $F2261-$F2270 DATA
    pool Pengator_SlideAndSparkle:
    {
    
    .random_x_offsets
        db  8, 10, 12, 14
        db 12, 12, 12, 12
    
    .random_y_offsets
        db  4,  4,  4,  4
        db  0,  4,  8, 12
    }

; ==============================================================================

    ; *$F2271-$F22B4 JUMP LOCATION
    Pengator_SlideAndSparkle:
    {
        TXA : EOR $1A : AND.b #$07 : ORA $0F70, X : BNE .still_falling
        
        LDA $0DE0, X : STA $06
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $06 : CMP.b #$02 : BCC .vertical_orientation
        
        INY #4
    
    .vertical_orientation
    
        LDA .random_y_offsets, Y : STA $00
                                   STZ $01
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $06 : CMP.b #$02 : BCC .vertical_orientation_2
        
        INY #4
    
    .vertical_orientation_2
    
        LDA .random_y_offsets, Y : STA $02
                                   STZ $03
        
        JSL Sprite_SpawnSimpleSparkleGarnish_SlotRestricted
    
    .still_falling
    
        RTS
    }

; ==============================================================================

    ; $F22B5-$F2414 DATA
    pool Pengator_Draw:
    {
    
    .oam_groups
        dw -1, -8 : db $82, $00, $00, $02
        dw  0,  0 : db $88, $00, $00, $02
        dw -1, -7 : db $82, $00, $00, $02
        dw  0,  0 : db $8A, $00, $00, $02
        dw -3, -6 : db $82, $00, $00, $02
        dw  0,  0 : db $88, $00, $00, $02
        dw -6, -4 : db $82, $00, $00, $02
        dw  0,  0 : db $8A, $00, $00, $02
        dw -4,  0 : db $A2, $00, $00, $02
        dw  4,  0 : db $A3, $00, $00, $02
        dw  1, -8 : db $82, $40, $00, $02
        dw  0,  0 : db $88, $40, $00, $02
        dw  1, -7 : db $82, $40, $00, $02
        dw  0,  0 : db $8A, $40, $00, $02
        dw  3, -6 : db $82, $40, $00, $02
        dw  0,  0 : db $88, $40, $00, $02
        dw  6, -4 : db $82, $40, $00, $02
        dw  0,  0 : db $8A, $40, $00, $02
        dw  4,  0 : db $A2, $40, $00, $02
        dw -4,  0 : db $A3, $40, $00, $02
        dw  0, -7 : db $80, $00, $00, $02
        dw  0,  0 : db $86, $00, $00, $02
        dw  0, -7 : db $80, $40, $00, $02
        dw  0,  0 : db $86, $40, $00, $02
        dw  0, -4 : db $80, $00, $00, $02
        dw  0,  0 : db $86, $00, $00, $02
        dw  0, -1 : db $80, $00, $00, $02
        dw  0,  0 : db $86, $00, $00, $02
        dw -8,  0 : db $8E, $00, $00, $02
        dw  8,  0 : db $8E, $40, $00, $02
        dw  0, -8 : db $84, $00, $00, $02
        dw  0,  0 : db $8C, $00, $00, $02
        dw  0, -8 : db $84, $40, $00, $02
        dw  0,  0 : db $8C, $40, $00, $02
        dw  0, -7 : db $84, $00, $00, $02
        dw  0,  0 : db $8C, $00, $00, $02
        dw  0,  0 : db $8C, $40, $00, $02
        dw  0, -6 : db $84, $40, $00, $02
        dw -8,  0 : db $A0, $00, $00, $02
        dw  8,  0 : db $A0, $40, $00, $02
    
    .oam_groups_2
        dw  0, 16 : db $B5, $00, $00, $00
        dw  8, 16 : db $B5, $40, $00, $00
        dw  0, -8 : db $A5, $00, $00, $00
        dw  8, -8 : db $A5, $40, $00, $00
    }

; ==============================================================================

    ; *$F2415-$F2461 LOCAL
    Pengator_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite3_DrawMultiple
        
        LDY.b #$00
        
        LDA.b #$00   : XBA
        LDA $0DC0, X : CMP.b #$0E : BEQ .draw_more_sprites
        
        INY
        
        CMP.b #$13 : BNE .draw_shadow
    
    ; \task Find out exactly what these other sprites are.
    .draw_more_sprites
    
        TYA
        
        REP #$20
        
        ASL #4 : ADC.w #.oam_groups_2 : STA $08
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite3_DrawMultiple
    
    .draw_shadow
    
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
