
; ==============================================================================

    ; *$4549A-$454B8 JUMP LOCATION
    Ancilla_DwarfPoof:
    {
        DEC $03B1, X : BPL .draw
        
        LDA.b #$07 : STA $03B1, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X : CMP.b #$03 : BNE .draw
        
        STZ $0C4A, X
        STZ $02F9
        
        RTS
    
    .draw
    
        BRL MorphPoof_Draw
    }

; ==============================================================================
