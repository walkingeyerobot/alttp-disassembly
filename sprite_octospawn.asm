
; ==============================================================================

    ; *$35853-$35891 JUMP LOCATION
    Sprite_Octospawn:
    {
        LDA $0E80, X : BNE .still_alive
        
        STZ $0DD0, X
    
    .still_alive
    
        CMP.b #$40 : BCS .not_blinking
        AND.b #$01 : BNE .dont_draw_this_frame
    
    .not_blinking
    
        JSR Sprite_PrepAndDrawSingleSmall
    
    .dont_draw_this_frame
    
        JSR Sprite_CheckIfActive
        
        DEC $0E80, X
        
        JSR Sprite_CheckIfRecoiling
        
        DEC $0F80, X
        
        JSR Sprite_MoveAltitude
        
        LDA $0F70, X : BPL .not_grounded
        
        STZ $0F70, X
        
        LDA.b #$10 : STA $0F80, X
    
    .not_grounded
    
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        JSR Sprite_WallInducedSpeedInversion
    
    ; *$3588B ALTERNATE ENTRY POINT
    shared Sprite_CheckDamage:
    
        JSR Sprite_CheckDamageFromPlayer
        JSR Sprite_CheckDamageToPlayer
        
        RTS
    }

; ==============================================================================
