
; ==============================================================================

    ; *$43BBC-$43BF3 JUMP LOCATION
    Ancilla_DashTremor:
    {
        LDA $11 : BNE .just_alert_sprites
        
        DEC $0C5E, X : BPL .delay
        
        STZ $011A
        STZ $011B
        STZ $011C
        STZ $011D
        
        STZ $0C4A, X
        
        RTS
    
    .delay
    
        JSL DashTremor_TwiddleOffset
        
        LDA $00 : STA $011A, Y
        LDA $01 : STA $011B, Y
        
        TYA : LSR A : EOR.b #$01 : TAY
        
        LDA $0030, Y : ADD $00 : STA $0030, Y
    
    .just_alert_sprites
    
        BRL Ancilla_AlertSprites
    }

; ==============================================================================
