
; ==============================================================================

    ; $4B5B9-$4B5BA DATA
    pool Garnish_LaserBeamTrail:
    {
    
    .chr
        ; \note One is horizontal, the other is vertical.
        db $D2, $F3
    }

; ==============================================================================

    ; $4B5BB-$4B5DD JUMP LOCATION
    Garnish_LaserBeamTrail:
    {
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        PHY
        
        LDA $7FF9FE, X : TAY
        
        LDA .chr, Y : PLY : INY : STA ($90), Y
        
        LDA.b #$25
    
    ; $4B5D6 ALTERNATE ENTRY POINT
    shared Garnish_SetOamPropsAndSmallSize:
    
        INY : STA ($90), Y
        
        LDA.b #$00 : STA ($92)
        
        RTS
    }

; ==============================================================================

