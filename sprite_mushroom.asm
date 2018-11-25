
; ==============================================================================

    ; *$2EE4B-$2EE52 LONG
    SpritePrep_MushroomLong:
    {
        PHB : PHK : PLB
        
        JSR SpritePrep_Mushroom
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2EE53-$2EE6F LOCAL
    SpritePrep_Mushroom:
    {
        ; \item(Magic powder)
        LDA $7EF344 : CMP.b #$02 : BCC .player_lacks_magic_powder
        
        STZ $0DD0, X
        
        RTS
    
    .player_lacks_magic_powder
    
        LDA.b #$00 : STA $0DC0, X
        
        LDA.b #$08 : ORA $0F50, X : STA $0F50, X
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; *$2EE70-$2EE77 LONG
    Sprite_MushroomLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_Mushroom
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2EE78-$2EEA5 LOCAL
    Sprite_Mushroom:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .player_cant_obtain
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_collision
        
        STZ $0DD0, X
        
        PHX
        
        ; \item(Mushroom)
        LDY.b #$29
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        PLX
        
        RTS
    
    .no_player_collision
    
        LDA $1A : AND.b #$1F : BNE .dont_toggle_h_flip
        
        LDA $0F50, X : EOR.b #$40 : STA $0F50, X
    
    .dont_toggle_h_flip
    .player_cant_obtain
    
        RTS
    }

; ==============================================================================

