
; ==============================================================================

    ; *$F0A8E-$F0A95 LONG
    Sprite_MadBatterBoltLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_MadBatterBolt
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$F0A96-$F0ABA LOCAL
    Sprite_MadBatterBolt:
    {
        LDA $0E80, X : AND.b #$10 : BEQ .in_front_of_player
        
        ; \note Seems we have some confirmation that this oam region is for
        ; putting sprites behind the player...
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
    
    .in_front_of_player
    
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X : BNE MadBatterBold_Active:
        
        JSR Sprite3_Move
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
    
    .delay:
    
        RTS
    }

; ==============================================================================

    ; $F0ABB-$F0ACA DATA
    pool MadBatterBolt_Active:
    {
    
    .x_offsets
        db 0, 4, 8, 12, 12, 4, 8, 0
    
    .y_offsets
        db 0, 4, 8, 12, 12, 4, 8, 0
    }
    
; ==============================================================================

    ; *$F0ACB-$F0B10 BRANCH LOCATION
    MadBatterBolt_Active:
    {
        INC $0D80, X : BNE .dont_self_terminate
        
        STZ $0DD0, X
    
    .dont_self_terminate
    
        INC $0E80, X : LDA $0E80, X : PHA : AND.b #$07 : BNE .dont_play_sfx
        
        LDA.b #$30 : STA $012F
    
    .dont_play_sfx
    
        PLA : LSR #2 : PHA : AND.b #$07 : TAY
        
        LDA $22 : ADD .x_offsets, Y : STA $0D10, X
        LDA $23 : ADC.b #$00        : STA $0D30, X
        
        PLA : LSR #2 : AND.b #$07 : TAY
        
        LDA $20 : ADD .y_offsets, Y : STA $0D00, X
        LDA $21 : ADC.b #$00        : STA $0D20, X
        
        RTS
    }

; ==============================================================================

