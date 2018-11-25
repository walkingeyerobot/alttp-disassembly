
; ==============================================================================

    ; *$4245B-$424DC JUMP LOCATION
    Ancilla_HaltedArrow:
    {
        ; Special object 0x0A (arrow stuck in something)
        
        ; Set to a sprite index if it collided with a sprite when it was in
        ; motion. Set to 0xFF otherwise.
        LDY $03A9, X : BMI .didnt_collide_with_sprite
        
        LDA $0DD0, Y : CMP.b #$09 : BCC .self_terminate
        
        LDA $0F70, Y : BMI .self_terminate
        
        LDA $0BA0, Y : BNE .self_terminate
        
        LDA $0CAA, Y : AND.b #$02 : BNE .self_terminate
        
        STZ $00
        
        LDA $0C2C, X : BPL .positive_x_speed
        
        DEC $00
    
    .positive_x_speed
    
                       ADD $0D10, Y : STA $0C04, X
        LDA $0D30, Y : ADC $00      : STA $0C18, X
        
        STZ $00
        
        LDA $0C22, X : BPL .positive_y_speed
        
        DEC $00
    
    .positive_y_speed
    
        ADD $0D00, Y : PHP : SUB $0F70, Y                 : STA $0BFA, X
        LDA $0D20, Y       : SBC.b #$00   : PLP : ADC $00 : STA $0C0E, X
    
    .didnt_collide_with_sprite
    
        LDA $11 : BEQ .normal_submode
        
        BRA .just_draw
    
    .normal_submode
    
        DEC $03B1, X : LDA $03B1, X : BNE .just_draw
        
        LDA.b #$02 : STA $03B1, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$09 : BEQ .self_terminate
                                      AND.b #$08 : BEQ .just_draw
        
        LDA.b #$80 : STA $03B1, X
    
    .just_draw
    
        JML Arrow_Draw
    
    ; *$424DA ALTERNATE ENTRY POINT
    .self_terminate
    
        BRL Ancilla_SelfTerminate
    }

; ==============================================================================

