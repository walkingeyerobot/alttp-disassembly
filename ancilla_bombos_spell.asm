
; ==============================================================================

    ; $42F56-$42F65 DATA
    pool AddBombosSpell:
    {
    
    .y_offsets
        dw   16,   24, -128,  -16
    
    .x_offsets
        dw  -16, -128,    0,  128
    }

; ==============================================================================

    ; Adds the bombos effect in response to getting it for the first time.
    ; The ether medallion doesn't use this approach so I wonder why the diff?
    ; *$42F66-$430CD LONG
    AddBombosSpell:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_Spawn : BCC .spawn_succeeded
        
        BRL .spawn_failed
    
    .spawn_succeeded
    
        LDA.b #$03
        
        STA $7F5800 : STA $7F5801 : STA $7F5802 : STA $7F5803
        STA $7F5804 : STA $7F5805 : STA $7F5806 : STA $7F5807
        STA $7F5808 : STA $7F5809
        
        STA $7F5945 : STA $7F5946 : STA $7F5947 : STA $7F5948
        STA $7F5949 : STA $7F594A : STA $7F594B : STA $7F594C
        
        LDA.b #$00
        
        STA $7F5810 : STA $7F5811 : STA $7F5812 : STA $7F5813
        STA $7F5814 : STA $7F5815 : STA $7F5816 : STA $7F5817
        STA $7F5818 : STA $7F5819
        
        STA $7F5935 : STA $7F5936 : STA $7F5937 : STA $7F5938
        STA $7F5939 : STA $7F593A : STA $7F593B : STA $7F593C
        STA $7F5934
        
        STA $7F5A56
        
        ; Set an overall timer for the effect? \warning Set this below 0x40,
        ; and the game will go into an infinite loop due to particularities
        ; of this ancillary object's code.
        LDA.b #$80 : STA $7F5A55
        LDA.b #$10 : STA $7F5820
        
        LDA.b #$0B : STA $0AAA
        
        LDA.b #$01 : STA $0112
        
        STZ $0C54, X
        STZ $0C5E, X
        
        LDA.b #$2A : JSR Ancilla_DoSfx2_NearPlayer
        
        PHX
        
        LDY $1A
        
        LDA $21 : STA $7F5956
        LDA $23 : STA $7F59D6
        
        ; \wtf this points to a nonexistent data table. Is this on purpose?
        ; (It points to the beginning of the boomerang ancilla code.
        ; \bug Could be considered a bug, hard to say.
        LDA $90FC, Y : CMP.b #$E0 : BCC .wtf
        
        AND.b #$7F
    
    .wtf
    
        STA $7F5955 : STA $7F59D5
        
        LDX.b #$00 : STX $72
    
    .never
    
        REP #$20
        
        LDA $20 : ADD .y_offsets, X : STA $7F5924, X
        LDA $22 : ADD .x_offsets, X : STA $7F592C, X
        
        SEP #$20
        
        PHX
        
        TXA : LSR A : TAX
        
        LDA.b #$10 : STA $08 : STA $7F5A57
        
        LDA $7F5820, X
        
        PLX
        
        JSR Ancilla_GetRadialProjection
        
        REP #$20
        
        LDA $00
        
        LDY $02 : BEQ .positive_x_projection
        
        EOR.w #$FFFF : INC A
    
    .positive_x_projection
    
        ADD $7F5924, X : STA $00
        
        LDA $04
        
        LDY $06 : BEQ .positive_y_projection
        
        EOR.w #$FFFF : INC A
    
    .positive_y_projection
    
        ADD $7F592C, X : STA $04
        
        SEP #$20
        
        PHX
        
        LDX $72
        
        LDA $00 : STA $7F5824, X
        LDA $01 : STA $7F5864, X
        
        LDA $04 : STA $7F58A4, X
        LDA $05 : STA $7F58E4, X
        
        PLX
        
        LDA $72 : SUB.b #$10 : STA $72
        
        DEX #2 : BPL .never
        
        PLX
    
    .spawn_failed
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $430CE-$43109 JUMP LOCATION
    Ancilla_BombosSpell:
    {
        LDA $7F5934 : BNE .not_spawning_new_columns
        
        LDA $11 : BNE .just_draw_flame_columns
        
        JMP Bombos_ExecuteFlameColumns
    
    .just_draw_flame_columns
    
        LDY.b #$00
        LDX.b #$09
    
    .next_fire_column
    
        JSR BombosSpell_DrawFireColumn
        
        DEX : BPL .next_fire_column
        
        RTS
    
    .not_spawning_new_columns
    
        LDA $7F5934 : CMP.b #$02 : BEQ .in_blast_stage
        
        LDA $11 : BNE .just_draw_flame_columns
        
        JSR BombosSpell_WrapUpFlameColumns
        
        RTS
    
    .in_blast_stage
    
        LDA $11 : BEQ .dont_just_draw_blasts
        
        PHX
        
        LDA $0C54, X : TAX
    
    .draw_next_blast
    
        JSR BombosSpell_DrawBlast
        
        DEX : BPL .draw_next_blast
        
        PLX
        
        RTS
    
    .dont_just_draw_blasts
    
        JMP BombosSpell_ExecuteBlasts
    }

; ==============================================================================

    ; *$4310A-$43235 JUMP LOCATION
    Bombos_ExecuteFlameColumns:
    {
        PHX
        
        LDA $0C5E, X : STA $73
        
        LDA $0C54, X : STA $72 : TAX
        
        LDY.b #$00
    
    .next_column
    
        LDA $7F5810, X : CMP.b #$0D : BNE .active_column
    
    .inactive_column
    .done_activating_columns
    
        BRL .advance_to_next_column
    
    .active_column
    
        LDA $7F5800, X : DEC A : STA $7F5800, X : BMI .timer_expired
    
    .dont_activate_another_column
    
        BRL .just_draw_column
    
    .timer_expired
    
        LDA.b #$03 : STA $7F5800, X
        
        LDA $7F5810, X : INC A : STA $7F5810, X
        
        CMP.b #$0D : BEQ .inactive_column
        CMP.b #$02 : BNE .dont_activate_another_column
        
        ; \wtf I don't think this branch is ever taken.
        LDA $73 : BNE .done_activating_columns
        
        PHX
        
        LDA $72 : CMP.b #$09 : BNE .increment_column_count
        
        LDX.b #$09
    
    .find_inactive_column_loop
    
        LDA $7F5810, X : CMP.b #$0D : BNE .column_not_ready_for_reset
        
        LDA.b #$00 : STA $7F5810, X
        
        BRA .set_radial_distance_and_angle
    
    .column_not_ready_for_reset
    
        DEX : BPL .find_inactive_column_loop
    
    .increment_column_count
    
        LDX $72 : INX : CPX.b #$0A : BNE .columns_not_maxed_out
        
        LDX.b #$09
    
    .columns_not_maxed_out
    
        STX $72
    
    .set_radial_distance_and_angle
    
        TXA : ADD.b #$00 : STA $74
    
    .never
    
        LDA $74 : LSR #4 : TAX
        
        ; (proj = projection)
        LDA $7F5A57 : ADD.b #$03 : CMP.b #$D0 : BCC .proj_distance_not_maxed
        
        LDA.b #$CF
    
    .proj_distance_not_maxed
    
        STA $7F5A57 : STA $08
        
        LDA $7F5820, X : ADD.b #$06 : STA $7F5820, X : AND.b #$3F
        
        JSR Ancilla_GetRadialProjection
        
        TXA : ASL A : TAX
        
        REP #$20
        
        PHY
        
        LDA $00
        
        LDY $02 : BEQ .positive_y_projection
        
        EOR.w #$FFFF : INC A
    
    .positive_y_projection
    
        ADD $7F5924, X : STA $00
        
        LDA $04
        
        LDY $06 : BEQ .positive_x_projection
        
        EOR.w #$FFFF : INC A
    
    .positive_x_projection
    
        ADD $7F592C, X : STA $04
        
        PLY
        
        SEP #$20
        
        LDX $74
        
        LDA $00 : STA $7F5824, X
        LDA $01 : STA $7F5864, X
        
        LDA $04 : STA $7F58A4, X
        LDA $05 : STA $7F58E4, X
        
        ; \wtf Okay.... seriously I think that either the Bombos person was
        ; smoking crack rock or there was some earlier version of this
        ; spell that employed more sprites. Or it was differently implemented
        ; maybe. With a limit of 10 blasts, we're certainly never going to
        ; branch here.
        LDA $74 : SUB.b #$10 : STA $74 : BPL .never
        
        REP #$20
        
        LDA $04 : SUB $E2 : ADD.w #$0008 : STA $04
        
        SEP #$20
        
        LDA $05 : BNE .not_flame_sfx
        
        LDA $04 : LSR #5 : TAX
        
        LDA $09968A, X : ORA.b #$2A : STA $012E
    
    .no_flame_sfx
    
        PLX
    
    .just_draw_column
    
        JSR BombosSpell_DrawFireColumn
    
    .advance_to_next_column
    
        DEX : BMI .handled_all_active_columns
        
        BRL .next_column
    
    .handled_all_active_columns
    
        PLX
        
        ; Checks if the first column slot's angle ever exceeds or meets 0x80.
        ; If so, move on to the next state that will phase out the flame
        ; columns.
        LDA $7F5820 : CMP.b #$80 : BCS .initiate_flame_column_wrap_up
        
        BRA .update_active_column_count
    
    .initiate_flame_column_wrap_up
    
        LDA.b #$01 : STA $7F5934
    
    .update_active_column_count
    
        LDA $72 : STA $0C54, X
        
        RTS
    }

; ==============================================================================

    ; *$43236-$43288 LOCAL
    BombosSpell_WrapUpFlameColumns:
    {
        PHX
        
        LDA $0C54, X : TAX
        
        LDY.b #$00
    
    .next_fire_column
    
        LDA $7F5800, X : DEC A : STA $7F5800, X : BPL .delay
        
        LDA.b #$03 : STA $7F5800, X
        
        LDA $7F5810, X : INC A : STA $7F5810, X : CMP.b #$0D : BCC .not_inactive
        
        ; Keep the flame column inactive if it has already reached that state.
        LDA.b #$0D : STA $7F5810, X
    
    .delay
    .not_inactive
    
        JSR BombosSpell_DrawFireColumn
        
        DEX : BPL .next_fire_column
        
        LDX.b #$09
    
    .find_active_column_loop
    
        LDA $7F5810, X : CMP.b #$0D : BNE .not_all_inactive
        
        DEX : BPL .find_active_column_loop
        
        STZ $72
        
        ; Increment the overall effect state to begin displaying blasts.
        LDA.b #$02 : STA $7F5934
        
        PLX : PHX
        
        JSL Medallion_CheckSpriteDamage
        
        PLX
        
        STZ $0C54, X
        
        RTS
    
    .not_all_inactive
    
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$43289-$43372 DATA
    pool BombosSpell_DrawFireColumn:
    {
        
    }

; ==============================================================================

    ; *$43373-$4340C LOCAL
    BombosSpell_DrawFireColumn:
    {
        ; \note Why add 0? Seems like some testing code here wasn't completely
        ; weeded out. See note near the end of this subroutine.
        TXA : ADD.b #$00 : STA $75
        
        LDA.b #$10 : JSR Ancilla_AllocateOam
        
        LDY.b #$00
    
    .never
    
        PHX
        
        LDA $7F5810, X : CMP.b #$0D : BEQ .inactive_flame_column
        
        ASL A : ADD $7F5810, X : ADD.b #$02 : TAX
        
        STZ $08
    
    .next_oam_entry
    
        LDA $B289, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        PHX
        
        LDX $75
        
        LDA $7F5824, X : STA $00
        LDA $7F5864, X : STA $01
        
        LDA $7F58A4, X : STA $02
        LDA $7F58E4, X : STA $03
        
        PLX : PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $B2D7, X : SUB $E8 : STA $00
        LDA $02 : ADD $B325, X : SUB $E2 : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        PLX
        
        LDA $B289, X : STA ($90), Y : INY
        LDA $B2B0, X : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        JSR Ancilla_CustomAllocateOam
        
        DEX
        
        INC $08 : LDA $08 : CMP.b #$03 : BNE .next_oam_entry
    
    .inactive_flame_column
    
        PLX
        
        ; \wtf When would this ever evalute to >= 0?
        ; Debugger testing points to the game always branching here, thus
        ; backing me up on this.
        LDA $75 : SUB.b #$10 : STA $75 : BMI .always
        
        BRL .never
    
    .always
    
        RTS
    }

; ==============================================================================

    ; *$4340D-$43520 LOCAL
    BombosSpell_ExecuteBlasts:
    {
        PHX
        
        LDY.b #$00
        
        ; Essentially operates as the number of active blasts in play at
        ; the moment.
        LDA $0C54, X : STA $72 : TAX
    
    .next_blast
    
        LDA $7F5935, X : CMP.b #$08 : BEQ .inactive_blast
        
        LDA $7F5945, X : DEC A : STA $7F5945, X : BMI .expired_delay_timer
    
    .inactive_blast
    .dont_activate_new_blast
    
        BRL .just_draw_blast
    
    .expired_delay_timer
    
        LDA.b #$03 : STA $7F5945, X
        
        LDA $7F5935, X : INC A : STA $7F5935, X
        
        CMP.b #$01 : BNE .dont_activate_new_blast
        
        ; This flag indicates that the effect should absolutely not convert
        ; any more blasts to an active state.
        LDA $7F5A56 : BNE .dont_activate_new_blast
        
        PHX
        
        LDA $72 : CMP.b #$0F : BEQ .maxed_blast_count
        
        LDA $72 : INC A : CMP.b #$10 : BNE .not_maxed_blast_count
        
        LDA.b #$0F
    
    .not_maxed_blast_count
    
        STA $72 : TAX
        
        BRA .activate_another_blast
    
    .maxed_blast_count
    
        LDX.b #$0F
    
    .find_inactive_blast_loop
    
        LDA $7F5935, X : CMP.b #$08 : BEQ .activate_another_blast
        
        DEX : BPL .find_inactive_blast_loop
    
    .activate_another_blast
    
        LDA.b #$00 : STA $7F5935, X
        LDA.b #$03 : STA $7F5945, X
        
        PHY
        
        TXA : ASL A : TAY
        
        ; Determine the x and y coordinates of the blast (was wondering where
        ; that was done at. This is essentially an even simpler RNG than the
        ; game normally uses.)
        LDA $1A : AND.b #$3F : TAX
        
        LDA .y_offsets, X : STA $00 : STZ $01
        LDA .x_offsets, X : STA $02 : STZ $03
        
        TYX
        
        REP #$20
        
        LDA $00 : ADD $E8 : STA $7F5955, X
        LDA $02 : ADD $E2 : STA $7F59D5, X
        
        SEP #$20
        
        LDA $7F59D5, X : LSR #5 : TAX
        
        LDA $09968A, X : ORA.b #$0C : STA $012E
        
        PLY : PLX
    
    .just_draw_blast
    
        JSR BombosSpell_DrawBlast
        
        DEX : BMI .handled_all_active_blasts
        
        BRL .next_blast
    
    .handled_all_active_blasts
    
        LDX.b #$0F
    
    .find_active_blast_loop
    
        LDA $7F5935, X : CMP.b #$08 : BNE .not_all_inactive
        
        DEX : BPL .find_active_blast_loop
        
        ; The bombos spell has run its course, time to self terminate and
        ; clear some of the related player state data.
        
        PLX
        
        STZ $0C4A, X
        
        LDA.b #$01 : STA $0AAA
        
        STZ $0324
        STZ $031C
        STZ $031D
        STZ $50
        STZ $0FC1
        
        LDA $5D : CMP.b #$1A : BEQ .player_in_bombos_mode
        
        ; If the player for some silly reason is not in bombos mode,
        ; put them back to ground state and reset things like
        ; the button inputs.
        LDA.b #$00 : STA $5D
        
        STZ $3D
        
        LDY.b #$00
        
        LDA $3C : BEQ .spin_attack_inactive
        
        ; This is to restore the player back to a held charge for spin attack
        ; if they were in that state prior to initiating the Bombos Spell.
        LDA $F0 : AND.b #$80 : TAY
    
    .spin_attack_inactive
    
        STY $3A
    
    .player_in_bombos_mode
    
        STZ $5E
        STZ $0325
        
        BRA .tick_blast_timer
    
    .not_all_inactive
    
        PLX
        
        LDA $72 : STA $0C54, X
    
    .tick_blast_timer
    
        LDA $7F5A55 : DEC A : STA $7F5A55 : BNE .not_expired
        
        LDA.b #$01 : STA $7F5A56
                     STA $7F5A55
    
    .not_expired
        
        RTS
    }

; ==============================================================================

    ; $43521-$435E0 DATA
    pool BombosSpell_DrawBlast:
    {
    
    .chr
        db $60, $FF, $FF, $FF
        db $62, $62, $62, $62
        db $64, $64, $64, $64
        db $66, $66, $66, $66
        db $68, $68, $68, $68
        db $68, $68, $68, $68
        db $6A, $6A, $6A, $6A
        db $4E, $4E, $4E, $4E
    
    .properties
        db $3C, $FF, $FF, $FF
        db $3C, $7C, $BC, $FC
        db $3C, $7C, $BC, $FC
        db $3C, $7C, $BC, $FC
        db $3C, $7C, $BC, $FC
        db $3C, $7C, $BC, $FC
        db $3C, $7C, $BC, $FC
        db $3C, $7C, $BC, $FC
    
    .y_offsets
        dw  -8,  -1,  -1,  -1
        dw -12, -12,  -4,  -4
        dw -16, -16,   0,   0
        dw -16, -16,   0,   0
        dw -17, -17,   1,   1
        dw -19, -19,   3,   3
        dw -19, -19,   3,   3
        dw -19, -19,   3,   3
    
    .x_offsets
        dw  -8,  -1,  -1,  -1
        dw -12,  -4, -12,  -4
        dw -16,   0, -16,   0
        dw -16,   0, -16,   0
        dw -17,   1, -17,   1
        dw -19,   3, -19,   3
        dw -19,   3, -19,   3
        dw -19,   3, -19,   3
    }

; ==============================================================================

    ; *$435E1-$43669 LOCAL
    BombosSpell_DrawBlast:
    {
        PHX
        
        LDA.b #$03 : STA $0C
        
        PHX : TXA : ASL A : TAX
        
        LDA $7F5955, X : STA $08
        LDA $7F5956, X : STA $09
        
        LDA $7F59D5, X : STA $0A
        LDA $7F59D6, X : STA $0B
        
        PLX
        
        LDA $7F5935, X : CMP.b #$08 : BEQ .inactive_blast
        
        LDA.b #$10 : JSR Ancilla_AllocateOam
        
        LDY.b #$00
        
        LDA $7F5935, X : ASL #2 : ADD.b #$03 : STA $73 : TAX
    
    .next_oam_entry
    
        LDA $B521, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        PHX : TXA : ASL A : TAX
        
        REP #$20
        
        LDA .y_offsets, X : ADD $08 : SUB $E8 : STA $00
        LDA .x_offsets, X : ADD $0A : SUB $E2 : STA $02
        
        SEP #$20
        
        PLX
        
        JSR Ancilla_SetOam_XY
        
        LDA $B521, X : STA ($90), Y : INY
        LDA $B541, X : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        JSR Ancilla_CustomAllocateOam
        
        DEX
        
        DEC $0C : BPL .next_oam_entry
    
    .inactive_blast
    
        PLX
        
        RTS
    }

; ==============================================================================
