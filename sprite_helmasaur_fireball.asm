
; ==============================================================================

    ; *$EEDD6-$EEDDD LONG
    Sprite_HelmasaurFireballLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_HelmasaurFireball
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EEDDE-$EEDE2 DATA
    pool Sprite_HelmasaurFireball:
    {
    
    .chr
        db $CC, $CC, $CA
    
    .properties
        db $33, $73
    }

; ==============================================================================

    ; *$EEDE3-$EEE9B LOCAL
    Sprite_HelmasaurFireball:
    {
        INC $0E80, X
        
        LDA $0E80, X : LSR #2 : AND.b #$01 : TAY
        
        LDA .properties, Y : STA $05
        
        LDY.b #$00
        
        LDA $0D10, X : SUB $E2 : STA ($90), Y
        
        ; \note These two branches check if the fireball is with in 32 pixels
        ; of the edge of the screen horizontally, and 16 pixels of the top of
        ; the screen. Because the screen is only 224 pixels tall in Zelda 3
        ; (though the snes can be configured for 240 called overscan mode), this
        ; has no impact on fireballs traveling towards the bottom edge of the
        ; screen.
        ADD.b #$20 : CMP.b #$40 : BCC .too_close_to_screen_edge
        
        LDA $0D00, X : SUB $E8 : INY : STA ($90), Y
        
        ADD.b #$10 : CMP.b #$20 : BCS .in_range
    
    .too_close_to_screen_edge
    
        STZ $0DD0, X
        
        RTS
    
    .in_range
    
        PHX
        
        LDA $0DC0, X : TAX
        
        LDA .chr, X
        
        PLX
                  INY : STA ($90), Y
        LDA $05 : INY : STA ($90), Y
        
        LDA.b #$02 : STA ($92)
        
        JSR Sprite4_CheckIfActive
        
        TXA : EOR $1A : AND.b #$03 : BNE .anodamage_player
        
        REP #$20
        
        LDA $22 : SUB $0FD8
                  ADD.w #$0008 : CMP.w #$0010 : BCS .anodamage_player
        
        LDA $20 : SUB $0FDA
                  ADD.w #$0010 : CMP.w #$0010 : BCS .anodamage_player
        
        SEP #$20
        
        JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
    
    .anodamage_player
    
        SEP #$20
        
        LDA $0D80, X
        
        ; \optimize Zero distance jump instruction. is a dumb. Just remove it.
        ; In fact, this whole section might be faster overall as a jump table.
        ; \note The ordering of this decision tree is as follows: 4, 1, 2, 3, 0
        ; These are the values of $0D80 that are being checked successively.
        ; Note that if the value were goreater than 4 it would resolve down to
        ; the final jump. This odd ordering in and of itself is blech.
        CMP.b #$04 : BEQ HelamsaurFireball_Move
        DEC A      : BEQ HelmasaurFireball_MigrateDown
        DEC A      : BEQ HelmasaurFireball_DelayThenTriSplit
        DEC A      : BEQ HelmasaurFireball_DelayThenQuadSplit
        
        JMP HelmasaurFireball_PreMigrateDown
    }
    
; ==============================================================================

    ; $EEE72-$EEE84 JUMP LOCATION
    HelmasaurFireball_PreMigrateDown:
    {
        LDA !timer_0, X : BNE .delay_ai_state_transition
        
        LDA.b #$12 : STA !timer_0, X
        
        INC $0D80, X
        
        LDA.b #$24 : STA $0D40, X
    
    .delay_ai_state_transition
    
        RTS
    }
    
; ==============================================================================

    ; $EEE85-$EEE9B BRANCH LOCATION
    HelmasaurFireball_MigrateDown:
    {
        LDA !timer_0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$1F : STA !timer_0, X
    
    .delay
    
        ; Slow down a bit each frame.
        DEC $0D40, X : DEC $0D40, X
        
        JSR Sprite4_MoveVert
        
        RTS
    }

; ==============================================================================

    ; $EEE9C-$EEE9F DATA
    HelmasaurFireball_DelayThenTriSplit:
    {
    
    .animation_states
        db 2, 2, 1, 0
    }

; ==============================================================================

    ; *$EEEA0-$EEEB2 BRANCH LOCATION
    HelmasaurFireball_DelayThenTriSplit:
    {
        LDA !timer_0, X : BNE .delay
        
        JMP HelmasaurFireball_TriSplit
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EEEB3-$EEEC8 BRANCH LOCATION
    HelmasaurFireball_DelayThenQuadSplit:
    {
        LDA !timer_0, X : BNE .delay
        
        JMP HelmasaurFireball_QuadSplit
    
    .delay
    
        LDA $0EB0, X : CMP.b #$14 : BCS .delay_movement
        
        INC $0EB0, X
        
        JSR Sprite4_Move
    
    .delay_movement
    
        RTS
    }

; ==============================================================================

    ; *$EEEC9-$EEECC BRANCH LOCATION
    HelamsaurFireball_Move:
    {
        ; Just moves until it hits the edge of the screen. (See notes at the
        ; root procedure).
        JSR Sprite4_Move
        
        RTS
    }

; ==============================================================================

    ; $EEECD-$EEED2 DATA
    pool HelmasaurFireball_TriSplit:
    {
    
    .x_speeds
        db   0,  28, -28
    
    .y_speeds
        db -32,  24,  24
    }

; ==============================================================================

    ; *$EEED3-$EEF34 LOCAL
    HelmasaurFireball_TriSplit:
    {
        LDA.b #$36 : JSL Sound_SetSfx3PanLong
        
        STZ $0DD0, X
        
        LDA.b #$02       : STA $0FB5
        JSL GetRandomInt : STA $0FB6
    
    .spawn_next
    
        LDA.b #$70
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        LDX $0FB5
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA.b #$03 : STA $0D80, Y
                     STA $0BA0, Y
        
        LDA $0FB6 : AND.b #$03 : ADD $0FB5 : TAX
        
        LDA .timers, X : STA !timer_0, Y
        
        LDA.b #$00 : STA $0EB0, Y
        
        LDA.b #$01 : STA $0DC0, Y
        
        PLX
    
    .spawn_failed
    
        DEC $0FB5 : BPL .spawn_next
        
        RTS
    
    .timers
        db  32,  80, 128,  32,  80, 128,  32,  80
    }

; ==============================================================================

    ; $EEF35-$EEF3C DATA
    HelmasaurFireball_QuadSplit:
    {
    
    .x_speeds
        db  32,  32, -32, -32
    
    .y_speeds
        db -32,  32, -32,  32
    }

; ==============================================================================

    ; *$EEF3D-$EEF75 LOCAL
    HelmasaurFireball_QuadSplit:
    {
        LDA.b #$36 : JSL Sound_SetSfx3PanLong
        
        STZ $0DD0, X
        
        LDA.b #$03 : STA $0FB5
    
    .spawn_next
    
        LDA.b #$70
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        LDX $0FB5
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA.b #$04 : STA $0D80, Y
                     STA $0BA0, Y
    
    .spawn_failed
    
        DEC $0FB5 : BPL .spawn_next
        
        RTS
    }

; ==============================================================================
