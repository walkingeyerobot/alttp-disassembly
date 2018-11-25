
; ==============================================================================
 
    ; $2A95B-$2A972 DATA
    pool Sprite_Rope:
    {
    
    .animation_states
        db $00, $00, $02, $03
        db $02, $03, $01, $01
    
    .vh_flip
        db $00, $40, $00, $00
        db $40, $40, $00, $40
    
    .animation_control
        db $04, $05, $02, $03
        db $00, $01, $06, $07
    }

; ==============================================================================

    ; *$2A973-$2AA2F JUMP LOCATION
    Sprite_Rope:
    {
        LDY $0D90, X
        
        ; Determine which graphic to use
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        
        LDA $0E90, X : BEQ .on_ground
        
        LDY.b #$03
        
        ; Modify character index
        LDA ($90), Y : ORA.b #$30 : STA ($90), Y
        
        LDA $0F70, X : PHA
        
        JSR Sprite2_MoveAltitude
        
        LDA $0F80, X : CMP.b #$C0 : BMI .at_terminal_falling_speed
        
        ; terminal altitude velocity?
        SUB.b #$02 : STA $0F80, X
    
    .at_terminal_falling_speed
    
        PLA : EOR $0F70, X : BPL .in_air
        
        LDA $0F70, X : BPL .in_air
        
        STZ $0F70, X
        STZ $0F80, X
        STZ $0E90, X
        
        LDA $0E60, X : AND.b #$EF : STA $0E60, X
    
    .in_air
    
        RTS
    
    .on_ground
    
        STZ $0E40, X
        
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        JSR Sprite2_CheckTileCollision
        
        LDA $0D80, X : BNE Rope_Moving
        
        JSR Sprite2_ZeroVelocity
        
        LDA $0DF0, X : BNE .delay
        
        STZ $0ED0, X
        
        JSL GetRandomInt : PHA : AND.b #$03 : STA $0DE0, X
        
        INC $0D80, X
        
        PLA : AND.b #$7F : ADC.b #$40 : STA $0DF0, X
        
        JSR Sprite2_DirectionToFacePlayer
        
        LDA $0E : ADD.b #$10 : CMP.b #$20 : BCC .player_on_sightline
        
        LDA $0F : ADD.b #$18 : CMP.b #$20 : BCS .player_not_on_sightline
    
    .player_on_sightline
    
        LDA.b #$04 : STA $0ED0, X
        
        TYA : STA $0DE0, X
    
    .player_not_on_sightline
    .delay
    
        LDA $1A : LSR #4 : LDA $0DE0, X : ROL A : TAY
        
        LDA .animation_control, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $2AA30-$2AA43 DATA
    pool Rope_Moving:
    {
    
    .x_speeds
        db $08, $F8, $00, $00
        db $10, $F0, $00, $00
    
    .y_speeds
        db $00, $00, $08, $F8
        db $00, $00, $10, $F0
    
    .reaction_direction
        db $02, $03, $01, $00
    }

; ==============================================================================

    ; *$2AA44-$2AA86 BRANCH LOCATION
    Rope_Moving:
    {
        LDA $0DF0, X : BNE delay
        
        STZ $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
    
    .delay
    
        LDY $0DE0, X
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        LDA $AA40, Y : STA $0DE0, X : TAY
    
    .no_tile_collision
    
        TYA : ADD $0ED0, X : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA $1A
        
        CPY.b #$04 : BCS .moving_fast
        
        LSR A
    
    .moving_fast
    
        LSR #2 : LDA $0DE0, X : ROL A : TAY
        
        LDA .animation_control, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================
