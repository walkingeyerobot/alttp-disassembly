
; ==============================================================================

    ; $2A880-$2A8AF DATA
    pool Sprite_Rat:
    {
    
    .animation_states
        db $00, $00, $03, $03, $01, $02, $04, $04
        db $01, $02, $04, $05, $00, $00, $03, $03
    
    .vh_flip
        db $00, $40, $00, $40, $00, $00, $00, $00
        db $40, $40, $40, $40, $80, $C0, $80, $C0
    
    .stationary_states
        db $0A, $0B, $06, $07, $02, $03, $0E, $0F
    
    .moving_states
        db $08, $09, $04, $05, $00, $01, $0C, $0D
    }

; ==============================================================================

    ; *$2A8B0-$2A90A JUMP LOCATION
    Sprite_Rat:
    {
        LDY $0D90, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        JSR Sprite2_CheckTileCollision
        
        LDA $0D80, X : BNE Rat_Moving
        
        JSR Sprite2_ZeroVelocity
        
        LDA $0DF0, X : BNE .no_new_direction
        
        ; Select a new direction and change to the moving state.
        
        JSL GetRandomInt : PHA : AND.b #$03 : STA $0DE0, X
        
        INC $0D80, X
        
        PLA : AND.b #$7F : ADC.b #$40 : STA $0DF0, X
    
    .no_new_direction
    
        LDA $1A : LSR #4 : LDA $0DE0, X : ROL A : TAY
        
        LDA .stationary_states, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $2A90B-$2A916 DATA
    pool Rat_Moving:
    {
    
    .x_speeds
        db  24, -24,   0,   0
        
    .y_speeds
        db   0,   0,  24, -24
        
    .next_direction
        db 2, 3, 0, 1
    }

; ==============================================================================

    ; *$2A917-$2A95A BRANCH LOCATION
    Rat_Moving:
    {
        LDA $0DF0, X : BNE .sound_wait
        
        LDA $0FFF : BNE .in_dark_world
        
        LDA.b #$17 : JSL Sound_SetSfx3PanLong
    
    .in_dark_world
    
        STZ $0D80, X
        
        LDA.b #$50 : STA $0DF0, X
    
    .sound_wait
    
        LDY $0DE0, X
        
        LDA $0E70, X : BEQ .no_wall_collision
        
        LDA .next_direction, Y : STA $0DE0, X : TAY
    
    .no_wall_collision
    
        LDA .x_speeds, Y : STA $0D50, X
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA $1A : LSR #3 : LDA $0DE0, X : ROL A : TAY
        
        LDA Sprite_Rat.moving_states, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================
