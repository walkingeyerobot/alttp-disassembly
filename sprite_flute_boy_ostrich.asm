
; ==============================================================================

    ; *$F195B-$F196B JUMP LOCATION
    Sprite_FluteBoyOstrich:
    {
        JSR FluteBoyOstrich_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteBoyOstrich_Chillin
        dw FluteBoyOstrich_RunAway
    }

; ==============================================================================

    ; *$F196C-$F198C JUMP LOCATION
    FluteBoyOstrich_Chillin:
    {
        LDY.b #$00
        
        LDA $1A : AND.b #$18 : BEQ .default_animation_state
        
        LDY.b #$03
    
    .default_animation_state
    
        TYA : STA $0DC0, X
        
        LDA $0FDD : BEQ .dont_run_away
        
        INC $0D80, X
        
        LDA.b #$F8 : STA $0D40, X
        
        LDA.b #$F0 : STA $0D50, X
    
    .dont_run_away
    
        RTS
    }

; ==============================================================================

    ; $F198D-$F1990 DATA
    pool FluteBoyOstrich_RunAway:
    {
    
    .animation_states
         db $00, $01, $00, $02
    }

; ==============================================================================

    ; *$F1991-$F19CA JUMP LOCATION
    FluteBoyOstrich_RunAway:
    {
        JSR Sprite3_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .dont_hop_yet
        
        LDA.b #$20 : STA $0F80, X
        
        STZ $0F70, X
        
        STZ $0E80, X
        
        STZ $0D90, X
    
    .dont_hop_yet
    
        INC $0E80, X : LDA $0E80, X : AND.b #$07 : BNE .delay_animation_tick
        
        LDA $0D90, X : CMP.b #$03 : BEQ .animation_counter_maxed
        
        INC $0D90, X
    
    .animation_counter_maxed
    .delay_animation_tick
    
        LDY $0D90, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F19CB-$F1A4A DATA
    pool FluteBoyOstrich_Draw:
    {
    
    .oam_groups
        dw -4, -8 : db $80, $00, $00, $02
        dw  4, -8 : db $81, $00, $00, $02
        dw -4,  8 : db $A3, $00, $00, $02
        dw  4,  8 : db $A4, $00, $00, $02
        
        dw -4, -8 : db $80, $00, $00, $02
        dw  4, -8 : db $81, $00, $00, $02
        dw -4,  8 : db $A0, $00, $00, $02
        dw  4,  8 : db $A1, $00, $00, $02
        
        dw -4, -8 : db $80, $00, $00, $02
        dw  4, -8 : db $81, $00, $00, $02
        dw -4,  8 : db $83, $00, $00, $02
        dw  4,  8 : db $84, $00, $00, $02
        
        dw -4, -7 : db $80, $00, $00, $02
        dw  4, -7 : db $81, $00, $00, $02
        dw -4,  9 : db $A3, $00, $00, $02
        dw  4,  9 : db $A4, $00, $00, $02
    }


; ==============================================================================

    ; *$F1A4B-$F1A6A LOCAL
    FluteBoyOstrich_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JSR Sprite3_DrawMultiple
        
        LDA.b #$12
        
        JSL Sprite_DrawShadowLong.variable
        
        RTS
    }

; ==============================================================================
