
; ==============================================================================

    ; *$E8B49-$E8B51 JUMP LOCATION
    Sprite_FlameTrailBat:
    {
        JSR FireBat_Draw
        JSR Sprite4_CheckIfActive
        JMP $8B90   ; $E8B90 IN ROM
    }

; ==============================================================================

