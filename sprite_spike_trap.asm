
; ==============================================================================

    ; *$F4F47-$F4F99 JUMP LOCATION
    Sprite_SpikeTrap:
    {
        JSR SpikeTrap_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckDamage
        
        LDA $0D80, X : BNE SpikeTrap_InMotion
        
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0DE0, X
        
        LDA $0F : ADD.b #$10 : CMP.b #$20 : BCS .not_close_enough
        
        BRA .move_towards_player
    
    .not_close_enough:
    
        LDA $0E : ADD.b #$10 : CMP.b #$20 : BCS .not_close_enough
    
    .move_towards_player
    
        LDA .timers, Y : STA $0DF0, X
        
        INC $0D80, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
    
    .not_close_enough
    
        RTS
    
    parallel pool SpikeTrap_InMotion:
    
    .x_speeds
        db  32, -32,   0,   0
    
    .retract_x_speeds
        db -16,  16,   0,   0
    
    .y_speeds
        db   0,   0,  32, -32
    
    .retract_y_speeds
        db   0,   0, -16,  16
    
    .timers
        db $40, $40, $38, $38
    }
    
; ==============================================================================

    ; $F4F9A-$F4FDE BRANCH LOCATION
    SpikeTrap_InMotion:
    {
        CMP.b #$01 : BNE .retracting
        
        JSR Sprite3_CheckTileCollision : BNE .collided_with_tile
        
        LDA $0DF0, X : BNE .moving_on
    
    .collided_with_tile
    
        INC $0D80, X
        
        LDA.b #$60 : STA $0DF0, X
    
    .moving_on
    
        JSR Sprite3_Move
        
        RTS
    
    .retracting
    
        LDA $0DF0, X : BNE .delay
        
        LDY $0DE0, X
        
        LDA .retract_x_speeds, Y : STA $0D50, X
        
        LDA .retract_y_speeds, Y : STA $0D40, X
        
        JSR Sprite3_Move
        
        LDA $0D10, X : CMP $0D90, X : BNE .delay
        
        LDA $0D00, X : CMP $0DB0, X : BNE .delay
        
        STZ $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F4FDF-$F4FFE DATA
    pool SpikeTrap_Draw:
    {
    
    .oam_groups
        dw -8, -8 : db $C4, $00, $00, $02
        dw  8, -8 : db $C4, $40, $00, $02
        dw -8,  8 : db $C4, $80, $00, $02
        dw  8,  8 : db $C4, $C0, $00, $02
    }

; ==============================================================================

    ; *$F4FFF-$F5011 LOCAL
    SpikeTrap_Draw:
    {
        REP #$20
        
        LDA.w #(.oam_groups) : STA $08
        
        LDA.w #$0004 : STA $06
        
        SEP #$30
        
        JSL Sprite_DrawMultiple.quantity_preset
        
        RTS
    }

; ==============================================================================
