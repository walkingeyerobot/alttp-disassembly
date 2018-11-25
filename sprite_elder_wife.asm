
; ==============================================================================

    ; *$2F469-$2F470 LONG
    Sprite_ElderWifeLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_ElderWife
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2F471-$2F489 LOCAL
    Sprite_ElderWife:
    {
        ; Namely, I think it seems implied that this is Sahasralah's wife.
        
        JSR ElderWife_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ElderWife_Initial
        dw ElderWife_TellLegend
        dw ElderWife_LoopUntilPlayerNotDumb
        dw ElderWife_GoAwayFindTheOldMan
    }

; ==============================================================================

    ; *$2F48A-$2F4B4 JUMP LOCATION
    ElderWife_Initial:
    {
        LDA $7EF359 : CMP.b #$02 : BCS .player_has_master_sword
        
        ; "... Oh, it's you, [Name]!What can I do for you, young man?"
        LDA.b #$2B
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .animate
        
        INC $0D80, X
    
    .animate
    
    ; *$2F49F ALTERNATE ENTRY POINT
    shared ElderWife_UpdateAnimationState:
    
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        RTS
    
    .player_has_master_sword
    
        ; ...You've changed! You look marvelous... Please save us..."
        LDA.b #$2E
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .animate
    }

; ==============================================================================

    ; *$2F4B5-$2F4C0 JUMP LOCATION
    ElderWife_TellLegend:
    {
        ; Long ago, a prosperous people known as the Hylia inhabited this..."
        LDA.b #$2C
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2F4C1-$2F4DA JUMP LOCATION
    ElderWife_LoopUntilPlayerNotDumb:
    {
        LDA $1CE8 : BNE .player_requested_repeat
        
        INC $0D80, X
        
        ; Anyway, look for the elder. There must be someone in the village..."
        LDA.b #$2D
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    
    .player_requested_repeat
    
        ; Long ago, a prosperous people known as the Hylia inhabited this..."
        ; (Repeat of the previous message ad nauseum).
        LDA.b #$2C
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    }

; ==============================================================================

    ; *$2F4DB-$2F4E4 JUMP LOCATION
    ElderWife_GoAwayFindTheOldMan:
    {
        ; Anyway, look for the elder. There must be someone in the village..."
        LDA.b #$2D
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA ElderWife_UpdateAnimationState
    }

; ==============================================================================

    ; $2F4E5-$2F504 DATA
    pool ElderWife_Draw:
    {
    
    .oam_groups
        dw 0, -5 : db $8E, $00, $00, $02
        dw 0,  5 : db $28, $00, $00, $02
        
        dw 0, -4 : db $8E, $00, $00, $02
        dw 0,  5 : db $28, $40, $00, $02
    }
    
; ==============================================================================

    ; *$2F505-$2F520 LOCAL
    ElderWife_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DC0, X : ASL #4
        
        ADC.b ( (.oam_groups >> 0 & $FF) )              : STA $08
        LDA.b ( (.oam_groups >> 8 & $FF) ) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        
        RTS
    }

; ==============================================================================
