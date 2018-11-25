
; ==============================================================================

    ; $4B6C0-$4B6E0 JUMP LOCATION
    Garnish_WinderTrail:
    {
        ; special animation 0x01
        
        JSR Garnish_PrepOamCoord
        
        LDA $00                    : STA ($90), Y
        LDA $02 : INY              : STA ($90), Y
                  INY : LDA.b #$28 : STA ($90), Y
        
        PHY
        
        LDA $7FF92C, X : TAY
        
        ; Copy palette and other property info from the parent sprite object.
        LDA $0F50, Y : ORA $0B89, Y
        
        PLY
        
        JMP Garnish_SetOamPropsAndLargeSize
    }

; ==============================================================================

