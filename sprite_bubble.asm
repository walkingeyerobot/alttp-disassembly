
; ==============================================================================

    ; *$3250C-$3253F JUMP LOCATION
    Sprite_Bubble:
    {
        JSL Sprite_DrawFourAroundOne
        JSR Sprite_CheckIfActive
        
        JSR Sprite_CheckDamageToPlayer : BCC .anodrain_player_mp
        
        LDA $0DF0, X : BNE .anodrain_player_mp
        
        LDA.b #$10 : STA $0DF0, X
        
        ; \item
        ; Subtract off 8 points of mp.
        LDA $7EF36E : SUB.b #$08 : BCS .player_has_at_least_eight_mp
        
        LDA.b #$00
        
        BRA .anoplay_drain_sfx
    
    .player_has_at_least_eight_mp
    
        ; Play the magic draining sound.
        LDY.b #$1D : STY $012F
    
    .anoplay_drain_sfx
    
        STA $7EF36E
    
    .anodrain_player_mp
    
        JSR Sprite_Move
        JSL Sprite_BounceFromTileCollisionLong
        
        RTS
    }

; ==============================================================================
