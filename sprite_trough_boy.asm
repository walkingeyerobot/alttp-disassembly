
; ==============================================================================

    ; *$2FF5E-$2FF65 LONG
    Sprite_TroughBoyLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_TroughBoy
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2FF66-$2FF9E LOCAL
    Sprite_TroughBoy:
    {
        JSR TroughBoy_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSL Sprite_MakeBodyTrackHeadDirection
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDA $7EF3C7 : CMP.b #$03 : BCS .player_met_sahasralah
        
        ; "Hi [Name]! Elder?  Are you talking about the grandpa?"
        LDA.b #$47
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_converse
        
        LDA.b #$02 : STA $7EF3C7
    
    .didnt_converse
    
        RTS
    
    .player_met_sahasralah
    
        ; "Did you meet the grandpa? If all the bad people go away..."
        LDA.b #$48
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; $2FF9F-$2FFDE LOCAL
    pool TroughBoy_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $82, $08, $00, $02
        dw 0,  0 : db $AA, $0A, $00, $02
        
        dw 0, -8 : db $82, $08, $00, $02
        dw 0,  0 : db $AA, $0A, $00, $02
        
        dw 0, -8 : db $80, $48, $00, $02
        dw 0,  0 : db $AA, $0A, $00, $02
        
        dw 0, -8 : db $80, $08, $00, $02
        dw 0,  0 : db $AA, $0A, $00, $02
    }

; ==============================================================================

    ; *$2FFDF-$2FFFE LOCAL
    TroughBoy_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

    ; $2FFFF-$2FFFF NULL
    {
        fillbyte $FF
        
        fill 1
    }

; ==============================================================================
