
; ==============================================================================

    ; $F7D12-$F7D13 DATA
    pool Faerie_HandleMovement:
    {
    
    .z_speeds
        db 1, -1
    }

; ==============================================================================

    ; *$F7D14-$F7D1B LONG
    Faerie_HandleMovementLong:
    {
        ; Some subroutine of a Faerie...
        
        PHB : PHK : PLB
        
        JSR Faerie_HandleMovement
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$F7D1C-$F7E32 LOCAL
    Faerie_HandleMovement:
    {
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        ; Interesting... the outdoor faeries have no regard for walls.
        LDA $1B : BEQ .no_wall_bounce_detection
        
        LDA $0E00, X : BNE .dont_invert_speeds
        
        JSR Sprite3_CheckTileCollision
        
        AND.b #$03 : BEQ .dont_invert_x_speed
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $0DE0, X : EOR.b #$FF : INC A : STA $0DE0, X
        
        LDA.b #$20 : STA $0E00, X
    
    .dont_invert_x_speed
    
        LDA $0E70, X : AND.b #$0C : BEQ .dont_invert_y_speed
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA $0D90, X : EOR.b #$FF : INC A : STA $0D90, X
        
        LDA.b #$20 : STA $0E00, X
    
    .dont_invert_y_speed
    .no_wall_bounce_detection
    
        LDA $0D50, X : BEQ .x_speed_at_zero
                       BPL .positive_x_speed
        
        LDA $0F50, X : AND.b #$BF
        
        BRA .set_hflip
    
    .positive_x_speed
    
        LDA $0F50, X : ORA.b #$40
    
    .set_hflip
    
        STA $0F50, X
    
    .x_speed_at_zero
    
        JSR Sprite3_Move
        
        LDA $1A : AND.b #$3F : BNE .direction_change_delay
        
        JSL GetRandomInt : STA $04
        LDA $23          : STA $05
        
        JSL GetRandomInt : STA $06
        LDA $21          : STA $07
        
        LDA.b #$10
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D90, X
        LDA $01 : STA $0DE0, X
    
    .direction_change_delay
    
        LDA $1A : AND.b #$0F : BNE .delay_speed_averaging
        
        LDA.b #$FF : STA $01
                     STA $03
        
        LDA $0D90, X : STA $00 : BMI .negative_y_target_speed
        
        STZ $01
    
    .negative_y_target_speed
    
        LDA $0D40, X : STA $02 : BMI .negative_y_speed
        
        STZ $03
    
    .negative_y_speed
    
        REP #$21
        
        ; average the two speeds?
        LDA $00 : ADC $02 : LSR A : SEP #$30 : STA $0D40, X
        
        LDA.b #$FF : STA $01
                     STA $03
        
        LDA $0DE0, X : STA $00 : BMI .negative_x_target_speed
        
        STZ $01
    
    .negative_x_target_speed
    
        LDA $0D50, X : STA $02 : BMI .negative_x_speed
        
        STZ $03
    
    .negative_x_speed
    
        REP #$21
        
        LDA $00 : ADC $02 : LSR A : SEP #$30 : STA $0D50, X
    
    .delay_speed_averaging
    
        JSR Sprite3_MoveAltitude
        
        JSL GetRandomInt : AND.b #$01 : TAY
        
        LDA .z_speeds, Y : ADD $0F80, X : STA $0F80, X
        
        LDA $0F70, X
        
        LDY.b #$08
        
        CMP.b #$08 : BCC .too_close_to_ground
        
        LDY.b #$18
        
        CMP.b #$18 : BCC .not_too_elevated
        
        TYA : STA $0F70, X
        
        LDA.b #$FB : STA $0F80, X
    
    .not_too_elevated
    
        RTS
    
    .too_close_to_ground
    
        TYA : STA $0F70, X
        
        LDA.b #$05 : STA $0F80, X
        
        RTS
    }

; ==============================================================================

    ; *$F7E33-$F7E68 LONG
    PlayerItem_SpawnFaerie:
    {
        LDA.b #$E3 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $EE : STA $0F20, Y
        
        LDA $22 : ADD.b #$08 : STA $0D10, Y
        LDA $23 : ADC.b #$00 : STA $0D30, Y
        
        LDA $20 : ADD.b #$10 : STA $0D00, Y
        LDA $21 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$00 : STA $0DE0, Y
        LDA.b #$60 : STA $0F10, Y
    
    .spawn_failed
    
        RTL
    }

; ==============================================================================
