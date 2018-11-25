
; ==============================================================================

    ; *$6C4A5-$6C4AC LONG
    Sprite_SweepingLadyLong:
    {
        ; Sweeping lady
        
        PHB : PHK : PLB
        
        JSR Sprite_SweepingLady
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$6C4AD-$6C4CA LOCAL
    Sprite_SweepingLady:
    {
        JSR SweepingLady_Draw
        JSR Sprite5_CheckIfActive
        
        ; "... rumors say you kidnapped the Princess, but I still trust you."
        LDA.b #$A5
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        JSL Sprite_PlayerCantPassThrough
        
        ; Next section of code simply changes her graphic index
        
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $6C4CB-$6C4EA DATA
    pool SweepingLady_Draw:
    {
    
    .oam_groups
        dw 0, -7 : db $8E, $00, $00, $02
        dw 0,  5 : db $8A, $00, $00, $02
        
        dw 0, -8 : db $8E, $00, $00, $02
        dw 0,  4 : db $8C, $00, $00, $02
    }

; ==============================================================================

    ; *$6C4EB-$6C50A LOCAL
    SweepingLady_Draw:
    {
        ; Handles appearance of sprite
        
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
