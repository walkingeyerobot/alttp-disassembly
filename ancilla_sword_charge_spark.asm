
; ==============================================================================

    ; $441E4-$441E9 DATA
    pool Ancilla_SwordChargeSpark:
    {
    
    .chr
        db $B7, $80, $83
    
    .properties
        db $04, $04, $84
    }

; ==============================================================================

    ; *$441EA-$4422E JUMP LOCATION
    Ancilla_SwordChargeSpark:
    {
        LDA $11 : BNE .draw
        
        LDA $0C68, X : BNE .draw
        
        LDA.b #$04 : STA $0C68, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$03 : BNE .dont_self_terminate
        
        STZ $0C4A, X
        
        RTS
    
    .draw
    .dont_self_terminate
    
        PHX
        
        LDA.b #$04
        
        JSR Ancilla_AllocateOam
        
        TYA : STA $0C86, X
        
        JSR Ancilla_PrepOamCoord
        
        LDA $0C5E, X : TAX
        
        LDY.b #$00
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                  : STA ($90), Y : INY
        LDA .properties, X : ORA $65 : STA ($90), Y
        
        LDA.b #$00 : STA ($92)
        
        PLX
        
        RTS
    }

; ==============================================================================
