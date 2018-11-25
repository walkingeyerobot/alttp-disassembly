
; ==============================================================================

    ; *$F6AE7-$F6B02 JUMP LOCATION
    Sprite_DialogueTester:
    {
        ; Monologue Testing sprite (appears to be a debug artifact)
        
        ; Mess with graphics
        
        ; \tcrf (verified, submitted)
        ; The debug monologue sprite is intended to use the same sprite graphics
        ; as the priest, but has grey garb instead of blue, and he doesn't
        ; face the player. His direction is calculated from the current message
        ; he will say modulo 4. Contrary to what has been claimed, this sprite
        ; has no selection menu, that's just a misconception based on some of
        ; the first messages he says after being initialized.
        
        JSL Priest_Draw
        JSR Sprite3_CheckIfActive
        
        ; Next set up the graphics state for next frame?
        
        LDA $0D90, X : AND.b #$03 : STA $0DE0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw DialogueTester_Initialize
        dw DialogueTester_ShowMessage
        dw DialogueTester_IncrementMessageIndex
    }

; ==============================================================================

    ; *$F6B03-$F6B1B JUMP LOCATION
    DialogueTester_Initialize:
    {
        ; Set it to the 0th text message
        STZ $0D90, X
        STZ $0DA0, X
        
        INC $0D80, X
    
    ; *$F6B0C ALTERNATE ENTRY POINT
    shared DialogueTester_ShowMessage:
    
        LDA $0D90, X
        LDY $0DA0, X
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$F6B1C-$F6B32 JUMP LOCATION
    DialogueTester_IncrementMessageIndex:
    {
        ; Move to the next message
        LDA $0D90, X : ADD.b #$01 : STA $0D90, X
        
        LDA $0DA0, X : ADC.b #$00 : STA $0DA0, X
        
        LDA.b #$01 : STA $0D80, X
        
        RTS
    }

; ==============================================================================
