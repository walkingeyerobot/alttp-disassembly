; ==============================================================================

    ; *$2F0CD-$2F0D4 LONG
    Sprite_ElderLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_Elder
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2F0D5-$2F0E9 LOCAL
    Sprite_Elder:
    {
        JSR Elder_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_Sahasrahla
        dw Sprite_Aginah
    }

; ==============================================================================

    ; *$2F0EA-$2F14C JUMP LOCATION
    Sprite_Aginah:
    {
        ; Guarantees that this is the first thing he says
        LDA $7EF3C6 : AND.b #$20 : BEQ .alpha
        
        ; If you don't have the master sword (or better)
        LDA $7EF359 : CMP.b #$02 : BCC .beta
        
        LDA.b #$28
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .gamma
    
    .beta
    
        LDA $7EF374 : AND.b #$07 : CMP.b #$07 : BNE .delta
        
        LDA.b #$26
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .gamma
    
    .delta
    
        AND.b #$02 : CMP.b #$02 : BNE .epsilon
        
        LDA.b #$29
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .gamma
    
    .epsilon
    
        LDA $7EF34E : BEQ .alpha
        
        LDA.b #$27
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .gamma
    
    .alpha
    
        LDA.b #$25
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        LDA $7EF3C6 : ORA.b #$20 : STA $7EF3C6
    
    .gamma
    
        JMP Elder_AdvanceAnimationState
    }

; ==============================================================================

    ; *$2F14D-$2F15B JUMP LOCATION
    Sprite_Sahasrahla:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sahasrahla_Dialogue
        dw Sahasrahla_MarkMap
        dw Sahasrahla_GrantBoots
        dw Sahasrahla_ShamelesslyPromoteIceRod
    }

; ==============================================================================

    ; $2F15C-$2F15F DATA
    pool Sahasrahla_Dialogue:
    {
        ; "You are correct, young man! I am Sahasrahla, the village elder..."
        ; "Oh!? You got the Pendant Of Courage! Now I will tell you more..."
    .messages_low
        db $39, $38
    
    .messages_high
        db $00, $00
    }

; ==============================================================================

    ; *$2F160-$2F1E8 JUMP LOCATION
    Sahasrahla_Dialogue:
    {
        LDA $7EF374 : AND.b #$04 : BNE .has_third_pendant
        
        ; I am, indeed, Sahasrahla, the village elder and a descendent of..."
        LDA.b #$32
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .dont_show
        
        INC $0D80, X
    
    .dont_show
    
        BRA .advance_animation_state
    
    .has_third_pendant
    
        LDA $7EF355 : BNE .has_boots
        
        LDA $7EF3C7 : CMP.b #$03 : ROL A : AND.b #$01 : TAY
        
        LDA .messages_low, Y  : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .dont_show_2
        
        INC $0D80, X : INC $0D80, X
    
    .dont_show_2
    
        BRA .advance_animation_state
    
    .has_boots
    
        LDA $7EF346 : BNE .has_ice_rod
        
        ; "A helpful item is hidden in the cave on the east side (...) Get it!"
        LDA.b #$37
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .advance_animation_state
    
    .has_ice_rod
    
        LDA $7EF374 : AND.b #$07 : CMP.b #$07 : BEQ .has_all_pendants
        
        ; ...relatives of the wise men are hiding (...) should find them."
        LDA.b #$34
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .advance_animation_state
    
    .has_all_pendants
    
        LDA $7EF359 : CMP.b #$02 : BCS .has_master_sword
        
        ; Incredible! ... Now, you should go to the Lost Woods..."
        LDA.b #$30
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .advance_animation_state
    
    .has_master_sword
    
        ; "I am too old to fight. I can only rely on you."
        LDA.b #$31
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
    
    ; *$2F1DC ALTERNATE ENTRY POINT
    shared Elder_AdvanceAnimationState:
    
    .advance_animation_state
    
        LDA $1A : LSR #5 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$2F1E9-$2F1FA JUMP LOCATION
    Sahasrahla_MarkMap:
    {
        ; "Good. As a test, can you retrieve the Pendant Of Courage (...) ?"
        LDA.b #$33
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        LDA.b #$03 : STA $7EF3C7
        
        RTS
    }

; ==============================================================================

    ; *$2F1FB-$2F20D JUMP LOCATION
    Sahasrahla_GrantBoots:
    {
        LDY.b #$4B
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        INC $0D80, X
        
        LDA.b #$03 : STA $7EF3C7
        
        RTS
    }

; ==============================================================================

    ; *$2F20E-$2F219 JUMP LOCATION
    Sahasrahla_ShamelesslyPromoteIceRod:
    {
        ; "A helpful item is hidden in the cave on the east side (...) Get it!"
        LDA.b #$37
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $2F21A-$2F239 DATA
    pool Elder_Draw
    {
    
    .animation_states
        dw 0, -9 : db $A0, $00, $00, $02
        dw 0,  0 : db $A2, $00, $00, $02
        
        dw 0, -8 : db $A0, $00, $00, $02
        dw 0,  0 : db $A4, $40, $00, $02        
    }

; ==============================================================================

    ; *$2F23A-$2F259 LOCAL
    Elder_Draw:
    {
        ; Sahasralah / Aginah graphics selector
        
        LDA.b #$02 : STA $06 : STZ $07
        
        LDA $0DC0, X : ASL #4
        
        ; $2F21A
        ADC.b #$1A              : STA $08
        LDA.b #$F2 : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

