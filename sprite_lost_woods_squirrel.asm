
; ==============================================================================

    ; *$29468-$294AE JUMP LOCATION
    Sprite_LostWoodsSquirrel:
    {
        LDA $0E00, X : BNE .delay
        
        LDA $0F50, X : AND.b #$BF
        
        LDY $0D50, X : BMI .moving_left
        
        ORA.b #$40
    
    .moving_left
    
        STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        JSR Sprite2_Move
        JSR Sprite2_MoveAltitude
        
        LDA $0F80, X : DEC #2 : STA $0F80, X
        
        LDA $0F70, X : BPL .nonnegative_altitude
        
        ; If the sprite's altitude goes negative, force it back to 0.
        STZ $0F70, X
        
        ; And make the squirrel pop up a bit too.
        LDA.b #$10 : STA $0F80, X
        LDA.b #$0C : STA $0DF0, X
    
    .nonnegative_altitude
    
        LDA.b #$00
        
        LDY $0DF0, X : BEQ .falling_graphic
        
        ; Or the jumping up sprite state.
        INC A
    
    .falling_graphic
    
        STA $0DC0, X
    
    .delay
    
        RTS
    }

; ==============================================================================
