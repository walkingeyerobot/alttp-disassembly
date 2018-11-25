
; ==============================================================================

    ; *$4B6E1-$4B713 JUMP LOCATION
    Garnish_MothulaBeamTrail:
    {
        LDY.b #$00
        
        LDA $7FF83C, X : SUB $E2                    : STA ($90), Y
        LDA $7FF81E, X : SUB $E8 : INY              : STA ($90), Y
                                   INY : LDA.b #$AA : STA ($90), Y
        
        LDA $7FF92C, X
        
        PHY
        
        LDA $7FF92C, X : TAY
        
        ; Copy palette and other property info from the parent sprite object.
        LDA $0F50, Y : ORA $0B89, Y
        
        PLY
    
    ; *$4B70C ALTERNATE ENTRY POINT
    shared Garnish_SetOamPropsAndLargeSize:
    
        INY : STA ($90), Y
        
        LDA.b #$02 : STA ($92)
        
        RTS
    }

; ==============================================================================
