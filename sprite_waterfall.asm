
; ==============================================================================

    ; *$D75A5-$D75AC LONG
    Sprite_WaterfallLong:
    {
        ; Waterfall sprite
        
        PHB : PHK : PLB
        
        JSR Sprite_Waterfall
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$D75AD-$D75B7 LOCAL
    Sprite_Waterfall:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Waterfall_Main
        dw Sprite_RetreatBat
    }

; ==============================================================================

    ; *$D75B8-$D75D4 JUMP LOCATION
    Waterfall_Main:
    {
        JSR Sprite6_CheckIfActive
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_collision
        
        LDA $8A : CMP.b #$43 : BEQ .ganons_tower_area
        
        PHX
        
        JSL AddBreakTowerSeal
        
        PLX
    
    .no_player_collision
    
        RTS
    
    .ganons_tower_area
    
        PHX
        
        JSL AddBreakTowerSeal
        
        PLX
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_retreat_bat.asm"

; ==============================================================================
