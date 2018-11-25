
; ==============================================================================

    ; $4B58D-$4B590 DATA
    pool Garnish_BlindLaserTrail:
    {
    
    .chr
        db $61, $71, $70, $60
    }

; ==============================================================================

    ; $4B591-$4B5B8
    Garnish_BlindLaserTrail:
    {
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        PHY
        
        ; Get the chr index.
        LDA $7FF9FE, X : TAY
        
        ; I guess that this assumes that the chr *index*
        ; is at least 0x07?
        LDA .chr-7, Y : PLY : INY : STA ($90), Y
        
        PHY
        
        LDA $7FF92C, X : TAY
        
        ; Copy palette and other oam properties from the parent sprite object.
        LDA $0F50, Y : ORA $0B89, Y
        
        PLY
        
        BRA Garnish_SetOamPropsAndSmallSize
    }

; ==============================================================================

