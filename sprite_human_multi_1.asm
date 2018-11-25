
; ==============================================================================

    ; *$6C2D1-$6C2D8 LONG
    Sprite_HumanMulti_1_Long:
    {
        PHB : PHK : PLB
        
        JSR Sprite_HumanMulti_1
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$6C2D9-$6C2E5 LOCAL
    Sprite_HumanMulti_1:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_FluteBoyFather
        dw Sprite_ThiefHideoutGuy
        dw Sprite_BlindHideoutGuy
    }

; ==============================================================================

    ; $6C2E6-$6C307 JUMP LOCATION
    Sprite_BlindHideoutGuy:
    {
        JSR BlindHideoutGuy_Draw
        JSR Sprite5_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSL Sprite_MakeBodyTrackHeadDirection
        
        STZ $0EB0, X
        
        ; "Yo [Name]! This house used to be a hideout for a gang of thieves..."
        LDA.b #$72
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        STA $0DE0, X
        STA $0EB0, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$6C308-$6C342 JUMP LOCATION
    Sprite_ThiefHideoutGuy:
    {
        LDA $1A : AND.b #$03 : BNE .delay_head_direction_change
        
        LDA.b #$02 : STA $0DC0, X
        
        JSL Sprite_DirectionToFacePlayerLong : CPY.b #$03 : BNE .not_up
        
        LDY.b #$02
    
    .not_up
    
        TYA : STA $0EB0, X
    
    .delay_head_direction_change
    
        LDA.b #$0F : STA $0F50, X
        
        JSL OAM_AllocateDeferToPlayerLong
        JSL Thief_Draw
        JSR Sprite5_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        ; "Hey kid, this is a secret hide-out for a gang of thieves! ..."
        LDA.b #$71
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        LDA.b #$02 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$6C343-$6C3B0 JUMP LOCATION
    Sprite_FluteBoyFather:
    {
        JSR FluteBoyFather_Draw
        JSR Sprite5_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $1A : CMP.b #$30 : BCS .dozing
        
        LDA.b #$02
        
        BRA .not_dozing
    
    .dozing
    
        ASL A : ROL A : AND.b #$01
    
    .not_dozing
    
        STA $0DC0, X
        
        LDA $0D80, X : BNE .knows_what_happened_to_son
        
        LDA $7EF34C : CMP.b #$02 : BCS .player_has_flute
        
        ; "... My son really liked to play the flute, ..."
        LDA.b #$A1
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
    
    .didnt_speak
    
        RTS
    
    .player_has_flute
    
        ; "Zzzzzzz  Zzzzzzzz ...  ...  ... Snore  Zzzzzz  Zzzzzz"
        LDA.b #$A4
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak_2
        
        RTS
    
    .didnt_speak_2
    
        LDA $0202 : CMP.b #$0D : BNE .flute_usage_undetected
        
        BIT $F0 : BVC .flute_usage_not_detected
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong
        
        BCC .flute_usage_not_detected
        
        ; "... Oh? This is my son's flute...! Did you meet my son? ..."
        LDA.b #$A2
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA.b #$02 : STA $0DC0, X
    
    .flute_usage_not_detected
    
        RTS
    
    .knows_what_happened_to_son
    
        ; "... And will you play its sweet melody for the bird in the (...)?"
        LDA.b #$A3
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        LDA.b #$02 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $6C3B1-$6C3E0 DATA
    pool FluteBoyFather_Draw:
    {
    
    .oam_groups
        dw 0, -7 : db $86, $00, $00, $02
        dw 0,  0 : db $88, $00, $00, $02
        
        dw 0, -6 : db $86, $00, $00, $02
        dw 0,  0 : db $88, $00, $00, $02
        
        dw 0, -8 : db $84, $00, $00, $02
        dw 0,  0 : db $88, $00, $00, $02
    }

; ==============================================================================

    ; *$6C3E1-$6C400 LOCAL
    FluteBoyFather_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DC0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

    ; $6C401-$6C480 DATA
    pool BlindHideoutGuy_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $0C, $00, $00, $02
        dw 0,  0 : db $CA, $00, $00, $02
        
        dw 0, -8 : db $0C, $00, $00, $02
        dw 0,  0 : db $CA, $40, $00, $02
        
        dw 0, -8 : db $0C, $00, $00, $02
        dw 0,  0 : db $CA, $00, $00, $02
        
        dw 0, -8 : db $0C, $00, $00, $02
        dw 0,  0 : db $CA, $40, $00, $02
        
        dw 0, -8 : db $0E, $00, $00, $02
        dw 0,  0 : db $CA, $00, $00, $02
        
        dw 0, -8 : db $0E, $00, $00, $02
        dw 0,  0 : db $CA, $40, $00, $02
        
        dw 0, -8 : db $0E, $00, $00, $02
        dw 0,  0 : db $CA, $00, $00, $02
        
        dw 0, -8 : db $0E, $00, $00, $02
        dw 0,  0 : db $CA, $40, $00, $02
    }

; ==============================================================================

    ; *$6C481-$6C4A4 LOCAL
    BlindHideoutGuy_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

