
; ==============================================================================

    ; $4B3E8-$4B3ED DATA
    pool Garnish_CannonPoof:
    {
    
    .chr
        db $8A, $86
        
        db $20, $10, $30, $30
    }

; ==============================================================================

    ; $4B3EE-$4B418 JUMP LOCATION
    Garnish_CannonPoof:
    {
        ; special animation 0x0A
        
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        LDA $7FF90E, X : LSR #3 : PHX : TAX
        
        LDA .chr, X : INY : STA ($90), Y
        
        PLX 
        
        PHX
        
        LDA $7FF92C, X : TAX
        
        LDA .properties, X : ORA.b #$04 : PLX
        
        JMP Garnish_SetOamPropsAndLargeSize
    }

; ==============================================================================

