
; ==============================================================================

    ; *$F68B6-$F68F0 JUMP LOCATION
    Sprite_BlindMaiden:
    {
        JSL CrystalMaiden_Draw
        JSR Sprite3_CheckIfActive
        JSL Sprite_MakeBodyTrackHeadDirection
        
        JSR Sprite3_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDA $0D80, X : BNE .switch_to_tagalong
        
        LDA.b #$22
        LDY.b #$01
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    
    .switch_to_tagalong
    
        STZ $0DD0, X
        
        ; Set "Blind the Thief (maiden)" as the tagalong
        LDA.b #$06 : STA $7EF3CC
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        JSL Tagalong_SpawnFromSprite
        
        RTS
    }

; ==============================================================================
