
; ==============================================================================

    ; *$3394C-$33961 JUMP LOCATION
    Sprite_BugNetKid:
    {
        JSL BugNetKid_Draw
        JSR Sprite_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw BugNetKid_Resting
        dw BugNetKid_PerkUp
        dw BugNetKid_GrantBugNet
        dw BugNetKid_BackToResting
    }

; ==============================================================================

    ; *$33962-$33990 JUMP LOCATION
    BugNetKid_Resting:
    {
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .dont_awaken
        
        JSR Sprite_CheckDamageToPlayer_same_layer : BCC .dont_awaken
        
        LDA $7EF35C : ORA $7EF35D : ORA $7EF35E : ORA $7EF35F
        
        CMP.b #$02 : BCC .gotsNoBottles
        
        INC $0D80, X
        
        INC $02E4
    
    .dont_awaken
    
        RTS
    
    .gotsNoBottles
    
        ; "... Do you have a bottle to keep a bug in? ... I see. You don't..."
        LDA.b #$04
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; $33991-$3399F DATA
    pool BugNetKid_PerkUp:
    {
    
    .animation_states
        db 0,  1,  0,  1, 0, 1, 2, 255
    
    .delay_timers
        db 8, 12, 8, 12, 8, 96, 16
    }

; ==============================================================================

    ; *$339A0-$339C5 JUMP LOCATION
    BugNetKid_PerkUp:
    {
        LDA $0DF0, X : BNE .delay
        
        LDY $0D90, X
        
        LDA .animation_states, Y : BMI .invalid_animation_state
        
        STA $0DC0, X
        
        LDA .delay_timers, Y : STA $0DF0, X
        
        INC $0D90, X
    
    .delay
    
        RTS
    
    .invalid_animation_state
    
        ; "I can't go out 'cause I'm sick. ... This is my bug catching net..."
        LDA.b #$05
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$339C6-$339D7 JUMP LOCATION
    BugNetKid_GrantBugNet:
    {
        ; Give Link the Bug catching net
        LDY.b #$21
        
        STZ $02E9
        
        PHX
        
        JSL Link_ReceiveItem
        
        PLX
        
        INC $0D80, X
        
        STZ $02E4
        
        RTS
    }

; ==============================================================================

    ; *$339D8-$339E5 JUMP LOCATION
    BugNetKid_BackToResting:
    {
        LDA.b #$01 : STA $0DC0, X
        
        ; "Sniffle... I hope I get well soon. Cough cough."
        LDA.b #$06
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================
