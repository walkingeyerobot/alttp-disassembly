
; ==============================================================================

    ; $4B496-$4B49D DATA
    pool Garnish_BabusuFlash:
    {
    
    .chr
        db $A8, $8A, $86, $86
    
    .properties
        db $2D, $2C, $2C, $2C
    }

; ==============================================================================

    ; $4B49E-$4B4BF
    Garnish_BabusuFlash:
    {
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        LDA $7FF90E, X : LSR #3
        
        PHX
        
        TAX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA .properties, X
        
        PLX
        
        JMP Garnish_SetOamPropsAndLargeSize
    }

; ==============================================================================
