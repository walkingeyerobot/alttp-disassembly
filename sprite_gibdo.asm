
; ==============================================================================

    ; *$F39A9-$F39BF JUMP LOCATION
    Sprite_Gibdo:
    {
        JSR Gibdo_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Gibdo_ApproachTargetDirection
        dw Gibdo_CanMove
    }

; ==============================================================================

    ; $F39C0-$F39CB DATA
    pool Gibdo_ApproachTargetDirection:
    {
    
    .target_direction length 8
        db $02, $06, $04, $00
    
    .animation_states
        db $04, $08, $0B, $0A, $00, $06, $03, $07
    }

; ==============================================================================

    ; *$F39CC-$F39FF JUMP LOCATION
    Gibdo_ApproachTargetDirection:
    {
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $1A : AND.b #$07 : BNE .delay
        
        LDY $0D90, X
        
        LDA $0DE0, X : CMP .target_direction, Y
        
        BEQ .reset_timer
        BPL .rotate_towards_target_direction
        
        INC $0DE0, X
        
        BRA .return
    
    .rotate_towards_target_direction
    
        DEC $0DE0, X
    
    .delay
    .return
    
        RTS
    
    .reset_timer
    
        JSL GetRandomInt : AND.b #$1F : ADC.b #$30 : STA $0DF0, X
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $F3A00-$F3A11 DATA
    pool Gibdo_CanMove:
    {
    
    .y_speeds length 8
        db -16,   0
    
    .x_speeds
        db   0,   0,  16,   0,   0,   0, -16,   0
    
    .animation_states
        db 9, 2, 0, 4, 11, 3, 1, 5
    }

; ==============================================================================

    ; *$F3A12-$F3A5F JUMP LOCATION
    Gibdo_CanMove:
    {
        LDY $0DE0, X
        
        ; Note that half of these states will have a speed of zero, or that the
        ; sprite is standing still. Gibdos are kind of weird in that regard.
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite3_Move
        JSR Sprite3_CheckTileCollision
        
        LDA $0DF0, X : BEQ .timer_expired_so_face_player
        
        LDA $0E70, X : BEQ .no_tile_collision
    
    .timer_expired_so_face_player
    
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : CMP $0D90, X : BEQ .already_facing_player
        
        ; Need to go back to the seeking state to rotate to the direction
        ; that is towards the player.
        STA $0D90, X
        
        STZ $0D80, X
        
        RTS
    
    .no_tile_collision
    .already_facing_player
    
        DEC $0DA0, X : BPL .dont_tick_animation_timer
        
        LDA.b #$0E : STA $0DA0, X
        
        INC $0E80, X
    
    .dont_tick_animation_timer
    
        LDA $0E80, X : ASL #2 : AND.b #$04 : ORA $0D90, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F3A60-$F3B1F DATA
    pool Gibdo_Draw:
    {
    
    .oam_groups
        dw 0, -9 : db $80, $00, $00, $02
        dw 0,  0 : db $8A, $00, $00, $02
        
        dw 0, -8 : db $80, $00, $00, $02
        dw 0,  1 : db $8A, $40, $00, $02
        
        dw 0, -9 : db $82, $00, $00, $02
        dw 0,  0 : db $8C, $00, $00, $02
        
        dw 0, -8 : db $82, $00, $00, $02
        dw 0,  0 : db $8E, $00, $00, $02
        
        dw 0, -9 : db $84, $00, $00, $02
        dw 0,  0 : db $A0, $00, $00, $02
        
        dw 0, -8 : db $84, $00, $00, $02
        dw 0,  1 : db $A0, $40, $00, $02
        
        dw 0, -9 : db $86, $00, $00, $02
        dw 0,  0 : db $A2, $00, $00, $02
        
        dw 0, -9 : db $88, $00, $00, $02
        dw 0,  0 : db $A4, $00, $00, $02
        
        dw 0, -9 : db $88, $40, $00, $02
        dw 0,  0 : db $A4, $40, $00, $02
        
        dw 0, -9 : db $82, $40, $00, $02
        dw 0,  0 : db $8C, $40, $00, $02
        
        dw 0, -9 : db $86, $40, $00, $02
        dw 0,  0 : db $A2, $40, $00, $02
        
        dw 0, -8 : db $82, $40, $00, $02
        dw 0,  1 : db $8E, $40, $00, $02
    }
; ==============================================================================

    ; *$F3B20-$F3B41 LOCAL
    Gibdo_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w .oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite3_DrawMultiple
        
        LDA $0F00, X : BNE .no_shadow
        
        JSL Sprite_DrawShadowLong
    
    .no_shadow
    
        RTS
    }

; ==============================================================================
