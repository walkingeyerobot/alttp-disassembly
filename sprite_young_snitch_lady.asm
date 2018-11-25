
; ==============================================================================

    ; *$2E2EA-$2E2F1 LONG
    Sprite_YoungSnitchLadyLong:
    {
        ; Scared Girl 2 (HM Name) (0x34)
        PHB : PHK : PLB
        
        JSR SpriteYoungSnitchLady
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E2F2-$2E2FE LOCAL
    Sprite_YoungSnitchLady:
    {
        LDA $0D80, X : CMP.b #$02 : BCS .not_visible
        
        JSR YoungSnitchLady_Draw
    
    .not_visible
    
        JMP Sprite_Snitch
    }

; ==============================================================================

    ; $2E2FF-$2E37E DATA
    pool YoungSnitchLady_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $26, $00, $00, $02
        dw 0,  0 : db $E8, $00, $00, $02
        dw 0, -7 : db $26, $00, $00, $02
        dw 0,  1 : db $E8, $40, $00, $02
        dw 0, -8 : db $24, $00, $00, $02
        dw 0,  0 : db $C2, $00, $00, $02
        dw 0, -7 : db $24, $00, $00, $02
        dw 0,  1 : db $C2, $40, $00, $02
        dw 0, -8 : db $28, $00, $00, $02
        dw 0,  0 : db $E4, $00, $00, $02
        dw 0, -7 : db $28, $00, $00, $02
        dw 0,  1 : db $E6, $00, $00, $02
        dw 0, -8 : db $28, $40, $00, $02
        dw 0,  0 : db $E4, $40, $00, $02
        dw 0, -7 : db $28, $40, $00, $02
        dw 0,  1 : db $E6, $40, $00, $02
    }

; ==============================================================================

    ; *$2E37F-$2E3A2 LOCAL
    YoungSnitchLady_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam-groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
