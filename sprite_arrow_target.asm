
; ==============================================================================

    ; *$2E62B-$2E632 LONG
    Sprite_ArrowTriggerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_ArrowTrigger
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E633-$2E655 LOCAL
    Sprite_ArrowTrigger:
    {
        LDA $0DA0, X : BNE .alpha
        
        JSL Sprite_PrepOamCoordLong
        JSR Sprite2_CheckIfActive
        
        JSR Sprite2_DirectionToFacePlayer : CPY.b #$02 : BNE .alpha
        
        LDA $0BB0, X : CMP.b #$09 : BNE .alpha
        
        INC $0642
        
        LDA.b #$01 : STA $0DA0, X
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $2E656-$2E656 LONG (UNUSED)
    ArrowTrigger_Unused:
    {
        RTL
    }

; ==============================================================================
