
; ==============================================================================

    ; $4F79B-$4F79E Jump Table
    pool Module_Quit:
    {
    
    .submodules
        dw Quit_IndicateHaltedState
        dw Quit_FadeOut
    }

; ==============================================================================

    ; *$4F79F-$4F7AE JUMP LOCATION LONG
    Module_Quit:
    {
        ; Beginning of Module 0x17, Restart Mode
        
        LDA $11 : ASL A : TAX
        
        JSR (.submodules, X)
        
        JSL Sprite_Main
        JSL PlayerOam_Main
        
        RTL
    }

; ==============================================================================

    ; *$4F7AF-$4F7BF LOCAL
    Quit_IndicateHaltedState:
    {
        INC $11
    
    ; *$4F7B1 ALTERNATE ENTRY POINT
    shared Quit_FadeOut:
    
        DEC $13 : BNE Death_RestoreScreenPostRevival.return
        
        ; Once the screen fades out it's time to save game state and restart,
        ; essentially.
        LDA.b #$0F : STA $95
        
        LDA.b #$01 : STA $B0
        
        JMP $F50F ; $4F50F IN ROM
    }

; ==============================================================================
