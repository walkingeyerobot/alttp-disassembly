
; ==============================================================================

    ; *$F7603-$F7631 JUMP LOCATION
    Sprite_DrinkingGuy:
    {
        JSL DrinkingGuy_Draw
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSL GetRandomInt : BNE .dont_set_timer
        
        LDA.b #$20 : STA $0DF0, X
    
    .dont_set_timer
    
        STZ $0DC0, X
        
        LDA $0DF0, X : BEQ .not_other_animation_state
        
        INC $0DC0, X
    
    .not_other_animation_state
    
        ; 
        LDA.b #$75
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        STZ $0DC0, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================
