; ==============================================================================

    ; *$2E28C-$2E293 LONG
    Sprite_GargoyleGrateLong:
    {
        ; Gargoyle's Domain Entrance (0x14)
        
        PHB : PHK : PLB
        
        JSR Sprite_GargoyleGrate
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E294-$2E2E9 LOCAL
    Sprite_GargoyleGrate:
    {
        JSL Sprite_PrepOamCoordLong
        JSR Sprite2_CheckIfActive
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .dont_open
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_not_near
        
        LDA.b #$01 : STA $03F8 : STA $0D90, X
        
        RTS
    
    .player_not_near
    
        LDA $0D90, X : BEQ .dont_open
        
        STZ $03F8
        
        LDA $0308 : AND.b #$01 : BEQ .dont_open
        
        LDA.b #$1F : JSL Sound_SetSfx2PanLong
        
        PHX
        
        JSL Overworld_AlterGargoyleEntrance
        
        PLX
        
        JSR MedallionTablet_SpawnDustCloud
        
        LDA $0D10, X : STA $0D10, Y
        LDA $0D30, X : STA $0D30, Y
        
        LDA $0D00, X : STA $0D00, Y
        LDA $0D20, X : STA $0D20, Y
        
        STZ $0DD0, X
    
    .dont_open
    
        RTS
    }

; ==============================================================================
