; ==============================================================================

    ; $28084-$2808F DATA
    pool Sprite_WallCannon:
    {
    
    .cannon_x_speeds
        db $00, $00
    
    .cannon_y_speeds
        db $F0, $10
    
    .cannon_animation_states
        db 0, 0, 2, 2
        
    .vh_flip
        db $40, $00, $00, $80
    }

; ==============================================================================

    ; *$28090-$28175 JUMP LOCATION
    Sprite_WallCannon:
    {
        ; Moving cannon ball shooters
        
        LDY $0DE0, X
        
        LDA $0E10, X : CMP.b #$01
        
        LDA .cannon_animation_states, Y : ADC.b #$00 : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        
        LDA $0DF0, X : BNE .direction_change_delay
        
        LDA.b #$80 : STA $0DF0, X
        
        LDA $0D90, X : EOR.b #$01 : STA $0D90, X
    
    .direction_change_delay
    
        LDY $0D90, X
        
        LDA .cannon_x_speeds, Y : STA $0D50, X
        
        LDA .cannon_y_speeds, Y : STA $0D40, X
        
        JSR Sprite2_Move
        
        TXA : ASL #2 : ADD $1A : AND.b #$1F : BNE .dont_reset_firing_delay
        
        LDA.b #$10 : STA $0E10, X
    
    .dont_reset_firing_delay
    
        LDA $0E10, X : CMP.b #$01 : BEQ .possible_to_fire
        
        RTS
    
    .possible_to_fire
    
        LDA $0F00, X : BNE .inactive_sprite
        
        ; Spawn cannon ball
        LDA.b #$6B
        LDY.b #$0D
        
        JSL Sprite_SpawnDynamically_arbitrary : BMI .spawn_failed
        
        LDA.b #$07 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$01 : STA $0DB0, Y : STA $0DC0, Y
        
        LDA $0DE0, X : PHX : TAX
        
        LDA $00 : ADD .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X  : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .cannonball_x_speeds, X : STA $0D50, Y
        
        LDA .cannonball_y_speeds, X : STA $0D40, Y
        
        LDA $0E40, Y : AND.b #$F0 : ORA.b #$01 : STA $0E40, Y
        
        LDA $0E60, Y : ORA.b #$47 : STA $0E60, Y
        LDA $0CAA, Y : ORA.b #$44 : STA $0CAA, Y
        
        LDA.b #$20 : STA $0DF0, Y
        
        PLX
    
    .spawn_failed
    .inactive_sprite
    
        RTS
    
    .x_offsets_low
        db 8, -8,  0,  0
    
    .x_offsets_high
        db 0, -1,  0,  0
    
    .y_offsets_low
        db 0,  0,  8, -8
    
    .y_offsets_high
        db 0,  0,  0, -1
    
    .cannonball_x_speeds
        db 24, -24,   0,   0
    
    .cannonball_y_speeds
        db  0,   0,  24, -24
    }

; ==============================================================================

