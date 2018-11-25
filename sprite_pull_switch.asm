
; ==============================================================================

    ; *$2D6BC-$2D6D3 LONG
    Sprite_PullSwitch:
    {
        ; Switch / Lever (0x04, 0x05, 0x06, 0x07) That can be pulled in puzzles.
        PHB : PHK : PLB
        
        LDA $0E20, X
        
        CMP.b #$07 : BEQ .bad_switches
        CMP.b #$05 : BNE .good_switch
    
    .bad_switches
    
        JSR Sprite_BadPullSwitch
        
        PLB
        
        RTL
    
    .good_switch
    
        JSR Sprite_GoodPullSwitch
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2D6D4-$2D72E LOCAL
    Sprite_BadPullSwitch:
    {
        JSR $D743 ; $2D743 IN ROM
        
        LDY $0DC0, X : BEQ .alpha
        CPY.b #$0B   : BEQ .alpha
        
        LDA $D738, Y : STA $0377
        
        LDA $0D00, X : SUB.b #$13 : STA $20
        LDA $0D20, X : SBC.b #$00 : STA $21
        
        LDA $0D10, X : STA $22
        LDA $0D30, X : STA $23
        
        LDA $0DF0, X : BNE .alpha
        
        INC $0DC0, X : LDY $0DC0, X : CPY.b #$0B : BNE .beta
        
        LDA.b #$1B : STA $012F
        
        LDA.b #$01 : STA $0642
    
    .beta
    
        LDA $D72D, Y : STA $0DF0, X
        
        BRA .alpha
    
    .alpha
    
        LDA $0E20, X : CMP.b #$07 : BEQ .up_facing_switch
        
        JSR BadPullDownSwitch_Draw
        
        RTS
    
    .up_facing_switch
    
        JSR BadPullUpSwitch_Draw
        
        RTS
    }

; ==============================================================================

    ; $2D72F-$2D742 DATA
    {
    
    
        db 8, 24, 
    }

; ==============================================================================

    ; *$2D743-$2D7C9 LOCAL
    {
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .alpha
        
        STZ $27
        STZ $28
        
        JSL Sprite_RepelDashAttackLong
        
        STZ $48
        
        LDA $0020 : SUB $0D00, X : CMP.b #$02 : BPL .beta
        
        CMP.b #$F4 : BMI .gamma
        
        LDA $0022 : CMP $0D10, X : BPL .delta
        
        LDA $0D10, X : SUB.b #$10 : STA $22
        LDA $0D30, X : SBC.b #$00 : STA $23

        RTS
    
    .delta
    
        LDA $0D10, X : ADD.b #$0E : STA $22
        LDA $0D30, X : ADC.b #$00 : STA $23
    
    .alpha
    
        RTS
    
    .gamma
    
        INC $0379
        
        LDA $F2 : BPL .epsilon
        
        LDA $F0 : AND.b #$03 : BNE .epsilon
        
        LDA $0DC0, X : BNE .epsilon
        
        INC $0DC0, X
        
        LDA.b #$08 : STA $0DF0, X
        
        LDA.b #$22 : JSL Sound_SetSfx2PanLong
    
    .epsilon
    
        LDA $0D00, X : SUB.b #$15 : STA $20
        LDA $0D20, X : SBC.b #$00 : STA $21
        
        RTS
    
    .beta
    
        LDA $0D00, X : ADD.b #$09 : STA $20
        LDA $0D20, X : ADC.b #$00 : STA $21
        
        RTS
    } 

; ==============================================================================

    ; \wtf This sprite is an over optimized mess in terms of table space
    ; usage.
    ; $2D7CA-$2D7F8 DATA
    {
    
    .x_offsets
        db -4, 12,  0, -4,  4,  4
    
    .y_offsets
        db -3,  3,  0,  5,  5,  5
    
    .chr
        db $D2, $D2, $C4, $E4, $E4, $E4
    
    .h_flip length 6
        db $40, $00, $00, $40
    
    .properties
        db $00, $00, $02, $02, $02, $02
    
    ; Both draw routines need this data.
    parallel pool BadPullUpSwitch_Draw:
    
    .additional_handle_y_offsets
        db 0, 1, 2, 3, 4, 5, 5
    
    ; $2D7ED
    .additional_handle_y_indices
        db 0, 0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 5
    }

; ==============================================================================

    ; *$2D7F9-$2D855 LOCAL
    BadPullDownSwitch_Draw:
    {
        JSR Sprite2_PrepOamCoord
        JSL OAM_AllocateDeferToPlayerLong
        
        LDY $0DC0, X
        
        LDA .additional_handle_y_indices, Y : TAY
        
        LDA .additional_handle_y_offsets, Y : STA $06
        
        PHX
        
        LDX.b #$04
        LDY.b #$00
    
    .next_oam_entry
    
        LDA $00 : ADD $D7CA, X          : STA ($90), Y
        LDA $02 : ADD $D7D0, X    : INY : STA ($90), Y
        LDA .chr, X                 : INY : STA ($90), Y
        LDA .h_flip, X : ORA.b #$21 : INY : STA ($90), Y
        
        PHY
        
        CPX.b #$02 : BNE .alpha
        
        DEY #2
        
        LDA ($90), Y : SUB $06 : STA ($90), Y
    
    .alpha
    
        TYA : LSR #2 : TAY
        
        LDA .properties, X : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_oam_entry
        
        PLX
        
        LDY.b #$FF
        LDA.b #$04
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    }

; ==============================================================================

    ; $2D856-$2D857 DATA
    pool BadPullUpSwitch_Draw:
    {
    
    .chr
        db $A2, $A4
    }

; ==============================================================================

    ; *$2D858-$2D8B4 LOCAL
    BadPullUpSwitch_Draw:
    {
        JSR Sprite2_PrepOamCoord
        JSL OAM_AllocateDeferToPlayerLong
        
        LDY $0DC0, X
        
        LDA .additional_handle_y_indices, Y : TAY
        
        LDA .additional_handle_y_offsets, Y : STA $06
                                              STZ $07
        
        PHX
        
        LDX.b #$01
        LDY.b #$00
    
    .gamma
    
        REP #$20
        
        LDA $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02
        
        CPX.b #$00 : BNE .alpha
        
        SUB $06
    
    .alpha
    
        INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        LDA .chr, X : INY : STA ($90), Y
        LDA $05      : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .gamma
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$2D8B5-$2D944 LOCAL
    Sprite_GoodPullSwitch:
    {
        JSR $D999 ; $2D999 IN ROM
        
        LDY $0DC0, X : BEQ .alpha
        CPY.b #$0D   : BEQ .alpha
        
        LDA .player_pull_poses-1, Y : STA $0377
        
        LDA $0D00, X : ADD .player_y_offsets-1, Y : STA $20
        LDA $0D20, X : ADC.b #$00                 : STA $21
        
        LDA $0D10, X : STA $22
        LDA $0D30, X : STA $23
        
        LDA $0DF0, X : BNE .alpha
        
        INC $0DC0, X : LDY $0DC0, X : CPY.b #$0D : BNE .set_delay_timer
        
        LDA $0E20, X : CMP.b #$06 : BNE .not_trap_switch
        
        ; tell bomb / snake traps in the room to trigger 
        LDA.b #$01 : STA $0CF4
        
        ; play error noise
        LDA.b #$3C : STA $012E
        
        BRA .set_delay_timer
    
    .not_trap_switch
    
        ; indicates the correct switch was pulled
        LDA.b #$01 : STA $0642
        
        ; play puzzle solved noise
        LDA.b #$1B : STA $012F
    
    .set_delay_timer
    
        LDA .timers-1, Y : STA $0DF0, X
        
        BRA .alpha
    
    .alpha
    
        JSR GoodPUllSwitch_Draw
        
        LDA $0F00, X : BEQ .delta
        
        STZ $0DC0, X
    
    .delta
    
    ; \wtf Using the RTS as a timer element? Fucking shit...
    .timers length 13
    
        RTS
    
        db  5,  5,  5,  5,  5,  5,  5,  5
        db  5,  5,  5,  5
    
    .player_pull_poses
        db  1,  1,  2,  2,  3,  3,  1,  1
        db  4,  4,  5,  5
    
    .player_y_offsets
        db  9,  9, 10, 10, 11, 11, 12, 12
        db 13, 13, 14, 14
    }

; ==============================================================================

    ; $2D945-$2D952 DATA
    pool GoodPullSwitch_Draw:
    {
    
    .y_offsets
        db 1, 1, 2, 3, 2, 3, 4, 5
        db 6, 7, 6, 7, 7, 7
    }

; ==============================================================================

    ; *$2D953-$2D998 LOCAL
    GoodPUllSwitch_Draw:
    {
        JSR Sprite2_PrepOamCoord
        JSL OAM_AllocateDeferToPlayerLong
        
        LDY $0DC0, X
        
        LDA .y_offsets, Y : STA $06
        
        LDY.b #$04
        
        LDA $00                      : STA ($90), Y
                          LDY.b #$00 : STA ($90), Y
        LDA $02 : DEC A : LDY.b #$01 : STA ($90), Y
        ADD $06         : LDY.b #$05 : STA ($90), Y
        LDA.b #$CE      : LDY.b #$06 : STA ($90), Y
        LDA.b #$EE      : LDY.b #$02 : STA ($90), Y
        LDA $05         : LDY.b #$03 : STA ($90), Y
                          LDY.b #$07 : STA ($90), Y
        
        LDY.b #$02
        LDA.b #$01
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    }

; ==============================================================================

    ; *$2D999-$2DA28 LOCAL
    {
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_collision
        
        STZ $27
        STZ $28
        
        JSL Sprite_RepelDashAttackLong
        
        STZ $48
        
        LDA $0020 : SUB $0D00, X : CMP.b #$02 : BPL .beta
        
        CMP.b #$F4 : BMI .A_button_held
        
        LDA $0022 : CMP $0D10, X : BPL .delta
        
        LDA $0D10, X : SUB.b #$10 : STA $22
        LDA $0D30, X : SBC.b #$00 : STA $23
    
    .no_player_collision
    
        RTS
    
    .delta
    
        LDA $0D10, X : ADD.b #$0E : STA $22
        LDA $0D30, X : ADC.b #$00 : STA $23
        
        RTS
    
    .A_button_held
    
        LDA $0D00, X : SUB.b #$15 : STA $20
        LDA $0D20, X : SBC.b #$00 : STA $21
        
        RTS
    
    .beta
    
        INC $0379
        
        LDA $F2 : BPL .epsilon
        
        LDA $F0 : AND.b #$03 : BNE .epsilon
        
        INC $0377
        
        LDA $F0 : AND.b #$04 : BEQ .epsilon
        
        LDA $0DC0, X : BNE .epsilon
        
        INC $0DC0, X
        
        LDA.b #$0C : STA $0DF0, X
        
        LDA.b #$22 : JSL Sound_SetSfx2PanLong
    
    .epsilon
    
        LDA $0D00, X : ADD.b #$09 : STA $20
        LDA $0D20, X : ADC.b #$00 : STA $21
        
        RTS
    }

; ==============================================================================

