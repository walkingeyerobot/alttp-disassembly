
; ==============================================================================

    ; $4B559-$4B55C DATA
    pool Garnish_TrinexxLavaBubble:
    {
    
    .chr
        db $83, $C7, $80, $9D
    }

; ==============================================================================

    ; $4B55D-$4B58C JUMP LOCATION
    Garnish_TrinexxLavaBubble:
    {
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        LDA $7FF90E, X : LSR #3 : PHX : TAX
        
        LDA .chr, X : PLX : INY : STA ($90), Y
        
        PHY
        
        LDA $7FF92C, X : TAY
        
        ; Copy palette and other oam properties from the parent sprite object.
        LDA $0F50, Y : ORA $0B89, Y : AND.b #$F0 : ORA.b #$0E
        
        PLY
        
        JMP Garnish_SetOamPropsAndSmallSize
    }

; ==============================================================================

