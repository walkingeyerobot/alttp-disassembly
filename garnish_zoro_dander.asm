
; ==============================================================================

    ; \note Called simple sparkle because it has no animation frames. It's
    ; either on the screen or it isn't - nothing more to it.
    ; $4B4FB-$4B51B JUMP LOCATION
    Garnish_ZoroDander:
    {
        ; Special animation 0x05
        
        JSR Garnish_PrepOamCoord
        
        LDA $00          : STA ($90), Y
        LDA $02    : INY : STA ($90), Y
        LDA.w #$75 : INY : STA ($90), Y
        
        PHY
        
        LDA $7FF92C, X : TAY
        
        ; Copy palette and other oam properties from the parent sprite object.
        LDA $0F50, Y : ORA $0B89, Y
        
        PLY
        
        JMP Garnish_SetOamPropsAndSmallSize
    }

; ==============================================================================
