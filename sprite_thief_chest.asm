
; ==============================================================================

    ; *$F60DD-$F6110 JUMP LOCATION
    Sprite_ThiefChest:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X : BNE .transition_to_tagalong
        
        ; "... the key is locked inside this chest, you can never open it...."
        LDA.b #$16
        LDY.b #$01
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_touch
        
        ; \note This bit of logic is interesting in that the message above
        ; will always trigger from contact with the player but if for whatever
        ; reason they already have a tagalong, you can't get the chest
        ; following you. This gives the impression that the requirement
        ; that the smithy partner be saved first was to avoid that scenario
        ; entirely, rather than being a prerequisite by design. After all, they
        ; don't really have much to do with one another, do they? In other
        ; words, there is no causal relationship there.
        LDA $7EF3CC : BNE .already_have_tagalong
        
        INC $0D80, X
    
    .already_have_tagalong
    .didnt_touch
    
        RTS
    
    .transition_to_tagalong
    
        STZ $0DD0, X
        
        ; Thief's chest (at smithy house in DW) Set that as the tagalong sprite
        LDA.b #$0C : STA $7EF3CC
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        JSL Tagalong_SpawnFromSprite
        
        RTS
    }

; ==============================================================================
