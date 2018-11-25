
; ==============================================================================

    ; *$EF063-$EF06A LONG
    Sprite_EvilBarrierLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_EvilBarrier
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EF06B-$EF0E0 LOCAL
    Sprite_EvilBarrier:
    {
        JSR EvilBarrier_Draw
        
        LDA $0DC0, X : CMP.b #$04 : BEQ .zap_attempt_inhibit
        
        LDA $1A : LSR A : AND.b #$03 : STA $0DC0, X
        
        JSR Sprite4_CheckIfActive
        
        JSL Sprite_CheckDamageFromPlayerLong : BCC .anozap_from_player_attack
        
        ; got master sword?
        LDA $7EF359 : CMP.b #$02 : BCS .anozap_from_player_attack
        
        ; no? yo' ass be gettin electrocuted, son
        STZ $0EF0, X
        
        JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
        
        LDA $031F : BNE .anozap_from_player_attack
        
        LDA.b #$40 : STA $0360
    
    .anozap_from_player_attack
    
        REP #$20
        
        LDA $20 : SUB $0FDA : ADD.w #$0008
        
        CMP.w #$0018 : BCS .anozap_from_player_contact
        
        LDA $22 : SUB $0FD8 : ADD.w #$0020
        
        CMP.w #$0040 : BCS .anozap_from_player_contact
        
        SEP #$20
        
        LDA $27 : DEC A : BPL .anozap_from_player_contact
        
        LDA.b #$40 : STA $0360
        
        LDA.b #$0C : STA $46
        
        LDA.b #$01 : STA $4D
        
        LDA.b #$02 : STA $0373
        
        STZ $28
        
        LDA.b #$30 : STA $27
    
    .anozap_from_player_contact
    .zap_attempt_inhibit
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $EF0E1-$EF248 DATA
    pool EvilBarrier_Draw:
    {
    
    .oam_groups
        dw   0,  0 : db $E8, $00, $00, $02
        dw -29,  3 : db $CA, $00, $00, $00
        dw -29, 11 : db $DA, $00, $00, $00
        dw  37,  3 : db $CA, $40, $00, $00
        dw  37, 11 : db $DA, $40, $00, $00
        dw -24, -2 : db $E6, $00, $00, $02
        dw  -8, -2 : db $E6, $00, $00, $02
        dw   8, -2 : db $E6, $40, $00, $02
        dw  24, -2 : db $E6, $40, $00, $02
        
        dw   0,  0 : db $CC, $00, $00, $02
        dw -29,  3 : db $CB, $00, $00, $00
        dw -29, 11 : db $DB, $00, $00, $00
        dw  37,  3 : db $CB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw   0,  0 : db $CC, $00, $00, $02
        dw   0,  0 : db $CC, $00, $00, $02
        dw   0,  0 : db $CC, $00, $00, $02
        dw   0,  0 : db $CC, $00, $00, $02
        
        dw   0,  0 : db $CC, $00, $00, $02
        dw -29,  3 : db $CB, $00, $00, $00
        dw -29, 11 : db $DB, $00, $00, $00
        dw  37,  3 : db $CB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw -24, -2 : db $E6, $80, $00, $02
        dw  -8, -2 : db $E6, $80, $00, $02
        dw   8, -2 : db $E6, $C0, $00, $02
        dw  24, -2 : db $E6, $C0, $00, $02
        
        dw   0,  0 : db $E8, $00, $00, $02
        dw -29,  3 : db $CA, $00, $00, $00
        dw -29, 11 : db $DA, $00, $00, $00
        dw  37,  3 : db $CA, $40, $00, $00
        dw  37, 11 : db $DA, $40, $00, $00
        dw   0,  0 : db $E8, $00, $00, $02
        dw   0,  0 : db $E8, $00, $00, $02
        dw   0,  0 : db $E8, $00, $00, $02
        dw   0,  0 : db $E8, $00, $00, $02
        
        dw -29,  3 : db $CB, $00, $00, $00
        dw -29, 11 : db $DB, $00, $00, $00
        dw  37,  3 : db $CB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00
        dw  37, 11 : db $DB, $40, $00, $00     
    }

; ==============================================================================

    ; *$EF249-$EF276 LOCAL
    EvilBarrier_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #3 : STA $00
        
        ASL #3 : ADD $00 : ADC.w #.oam_groups : STA $08
        
        LDA $0FDA : ADD.w #$0008 : STA $0FDA
        
        SEP #$20
        
        LDA.b #$09 : JSR Sprite4_DrawMultiple
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        RTS
    }

; ==============================================================================
