
; ==============================================================================

    ; $4B3B9-$4B3BB DATA
    pool Garnish_RunningManDashDust:
    {
    
    .chr.
        db $DF, $CF, $A9
    }

; ==============================================================================

    ; $4B3BC-$4B3E7 JUMP LOCATION
    Garnish_RunningManDashDust:
    {
        LDA $7FF90E, X
        
        BRA .set_chr_index
    
    ; $4B3C2 ALTERNATE ENTRY POINT
    shared Garnish_WaterTrail:
    
        LDA $7FF90E, X
        
        LSR A
    
    .set_chr_index
    
        LSR #2 : STA $0FB5
        
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        PHX
        
        LDX $0FB5
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA.b #$24
        
        PLX
        
        JMP Garnish_SetOamPropsAndSmallSize
    }

; ==============================================================================

