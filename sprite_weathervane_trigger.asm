
; ==============================================================================

    ; *$342E5-$34308 JUMP LOCATION
    Sprite_WeathervaneTrigger:
    {
        JSR Sprite_PrepOamCoordSafeWrapper
        JSR Sprite_CheckIfActive
        
        LDA $8A : CMP.b #$18 : BNE .outside_village
        
        ; \item
        LDA $7EF34C : CMP.b #$03 : BNE .player_lacks_bird_enabled_flute
        
        STZ $0DD0, X
    
    .player_lacks_bird_enabled_flute
    
        RTS
    
    .outside_village
    
        ; What to do in an area outside of the village
        
        ; \item
        LDA $7EF34C : AND.b #$02 : BEQ .player_lacks_flute_completely
        
        STZ $0DD0, X ; suicide if the flute value is less than 2 (no flute or just the shovel)
    
    .player_lacks_flute_completely
    
        RTS
    }

; ==============================================================================
