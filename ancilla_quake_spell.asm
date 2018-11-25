
; ==============================================================================

    ; *$4366A-$436F6 JUMP LOCATION
    Ancilla_QuakeSpell:
    {
        LDA $11 : BNE .just_draw
        
        LDA $0C54, X : CMP.b #$02 : BEQ .wrap_up_state
        
        JSR QuakeSpell_ShakeScreen
        JSR QuakeSpell_ExecuteBolts
        
        BRL QuakeSpell_SpreadGroundBolts
    
    .wrap_up_state
    
        BRA .apply_effect_and_self_terminate
    
    .just_draw
    
        PHX
        
        LDX.b #$04
        
        ; \bug Maybe? Note the short branch a few lines down.
        LDA $7F5805, X : CMP $B713, X : BEQ .inactive_piece
        
        JSR QuakeSpell_DrawFirstGroundBolts
    
    .possible_bug
    .inactive_piece
    
        DEX : BPL .possible_bug
        
        PLX
        
        RTS
    
    .apply_effect_and_self_terminate
    
        PHX
        
        JSL Medallion_CheckSpriteDamage
        JSL Player_ApplyRumbleToSprites
        
        PLX
        
        STZ $0C4A, X
        
        LDA.b #$00 : STA $5D
        
        LDA.b #$01 : STA $0AAA
        
        STZ $0324
        STZ $031C
        STZ $031D
        STZ $50
        STZ $3D
        
        STZ $0FC1
        STZ $011A
        STZ $011B
        STZ $011C
        STZ $011D
        
        LDA $8A : CMP.b #$47 : BNE .not_turtle_rock_trigger
        
        ; Check event overlay flag for Turtle Rock (overworld)
        LDA $7EF2C7 : AND.b #$20 : BNE .not_turtle_rock_trigger
        
        LDY.b #$03 : JSR Ancilla_CheckIfEntranceTriggered
        
        BCC .not_turtle_rock_trigger
        
        LDA.b #$04 : STA $04C6
        
        STZ $B0
        STZ $C8
    
    .not_turtle_rock_trigger
    
        LDY.b #$00
        
        LDA $3C : BEQ .spin_charge_not_previously_active
        
        LDA $F0 : AND.b #$80 : TAY
    
    .spin_charge_not_previously_active
    
        STY $3A
        
        STZ $5E
        STZ $0325
        
        RTS
    }

; ==============================================================================

    ; *$436F7-$43712 LOCAL
    QuakeSpell_ShakeScreen:
    {
        REP #$20
        
        LDA $7F581E : STA $011C
        
        ; Toggle rumble screen offset.
        EOR.w #$FFFF : INC A : STA $7F581E
        
        SEP #$20
        
        ; Make this move the player too, slightly?
        LDA $30 : ADD $011C : STA $30
        
        RTS
    }

; ==============================================================================

    ; $43713-$43717 DATA
    pool QuakeSpell_ExecuteBolts:
    {
    
    .limits
        db 23, 22, 23, 22, 16
    }

; ==============================================================================

    ; \task A bit iffy on the labels in this routine too.
    ; *$43718-$4378D LOCAL
    QuakeSpell_ExecuteBolts:
    {
        PHX
        
        ; Cache overall state variable here for now. It will be possibly
        ; modified but certainly written back by the end of the routine
        LDA $0C54, X : STA $7F580F
        
        LDA $7F580A : TAX
    
    .next_component
    
        LDA $7F5805, X : CMP .limits, X : BEQ .component_inactive
        
        LDA $7F5800, X : DEC A : STA $7F5800, X : BPL .draw_bolt
        
        LDA.b #$01 : STA $7F5800, X
        
        LDA $7F5805, X : INC A : STA $7F5805, X
        
        CMP .limits, X : BEQ .component_inactive
        
        TXY : BNE .not_in_first_state
        
        CMP.b #$02 : BNE .dont_activate_second_state
        
        ; Play loud thud sound.
        LDA.b #$0C : JSR Ancilla_DoSfx2_NearPlayer
        
        ; Add an extra... something.
        LDA.b #$01 : STA $7F580A
        
        BRA .draw_bolt
    
    .not_in_first_state
    .dont_activate_second_state
    
        CPX.b #$01 : BNE .not_second_state
        
        CMP.b #$02 : BNE .dont_activate_third_state
        
        ; Switch to 5 somethings instead of 1?
        LDA.b #$04 : STA $7F580A
        
        BRA .draw_bolt
    
    .not_second_state
    .dont_activate_third_state
    
        CPX.b #$04 : BNE .draw_bolt
        
        CMP.b #$07 : BNE .draw_bolt
        
        LDA.b #$01 : STA $7F580F
    
    .draw_bolt
    
        JSR QuakeSpell_DrawFirstGroundBolts
    
    .component_inactive
    
        DEX : BPL .next_component
        
        PLX
        
        LDA $7F580F : STA $0C54, X
        
        RTS
    }

; ==============================================================================

    ; $4378E-$43792 DATA
    pool QuakeSpell_DrawFirstGroundBolts:
    {
    
    .pointer_offsets
        db $00, $18, $00, $18, $2F
    }

; ==============================================================================

    ; \task Get deeper into the logic of this ancilla to get a better name
    ; for this, as we're still somewhat confused on how this spell progresses.
    ; *$43793-$4384E LOCAL
    pool QuakeSpell_DrawFirstGroundBolts:
    {
        PHX
        
        LDA $7F5805, X : ADD .pointer_offsets, X : ASL A : TAY
        
        ; Start pointer.
        LDA .pointers+0, Y : STA $72
        LDA .pointers+1, Y : STA $73
        
        ; End pointer
        LDA .pointers+2, Y : STA $74
        LDA .pointers+3, Y : STA $75
        
        REP #$20
        
        LDA $74 : SUB $72 : STA $74
        
        SEP #$20
        
        LDX.b #$00
    
    .next_bolt
    
        TXY
        
        REP #$20
        
        LDA ($72), Y : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_x_offset
        
        ORA.w #$FF00
    
    .sign_ext_x_offset
    
        STA $02
        
        LDA $7F580D : ADD $02 : SUB $E2 : STA $02
        
        INX : TXY
        
        LDA ($72), Y : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_y_offset

        ORA #$FF00
    
    .sign_ext_y_offset
    
        STA $00
        
        LDA $7F580B : ADD $00 : SUB $E8 : STA $00
        
        INX
        
        SEP #$20
        
        PHX
        
        LDX.b #$F0
        
        LDA $01 : BNE .off_screen
        LDA $03 : BNE .off_screen
        
        LDY.b #$00
        
        ; Store x coordinate.
        LDA $02 : STA ($90), Y
        
        LDA $00 : CMP.b #$F0 : BCS .off_screen
        
        ; If on screen, load the actual y coordinate.
        TAX
    
    .off_screen
    
        INC $90
        
        ; Store y coordinate.
        LDY.b #$00 : TXA : STA ($90), Y : INC $90
        
        PLX : PHX : TXY
        
        LDA ($72), Y : AND.b #$0F : TAX
        
        LDA QuakeSpell_DrawGroundBolts.chr, X
        
        ; Store chr.
        LDY.b #$00 : STA ($90), Y : INC $90
        
        PLX : TXY
        
        LDA ($72), Y : AND.b #$C0 : ORA #$3C
        
        ; Store properties
        LDY.b #$00 : STA ($90), Y : INC $90
        
        ; Store oam size.
        LDY.b #$00 : LDA.b #$02 : STA ($92), Y : INC $92
        
        INX : CPX $74 : BEQ .done_drawing
        
        BRL .next_bolt
    
    .done_drawing
    
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$4384F-$43872 LONG BRANCH LOCATION
    QuakeSpell_SpreadGroundBolts:
    {
        LDA $0C54, X : CMP.b #$01 : BNE .not_second_state
        
        LDA $0C68, X : BNE .second_state_still_progressing
        
        LDA.b #$02 : STA $0C68, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X
        
        CMP.b #$37 : BNE .second_state_still_progressing
        
        LDA.b #$02 : STA $0C54, X
    
    .not_second_state
    
        RTS
    
    .second_state_still_progressing
    
        BRA QuakeSpell_DrawGroundBolts
    }

; ==============================================================================

    ; $43873-$43881 DATA
    pool QuakeSpell_DrawGroundBolts:
    {
    
    .chr
        db $40, $42, $44, $46, $48, $4A, $4C, $4E
        db $60, $62, $64, $66, $68, $6A, $63
    }

; ==============================================================================

    ; *$43882-$438F3 BRANCH LOCATION
    QuakeSpell_DrawGroundBolts:
    {
        PHX
        
        LDA $0C5E, X : ASL A : TAY
        
        ; \bug(unconfirmed)
        ; Wouldn't this be a buffer overrun? There's only enough data there
        ; for 0x1c entries.
        ; \task Check into this.
        
        ; Start pointer
        LDA .pointers+0, Y : STA $72
        LDA .pointers+1, Y : STA $73
        
        ; End pointer
        LDA .pointers+2, Y : STA $74
        LDA .pointers+3, Y : STA $75
        
        REP #$20
        
        ; Calculates the number of oam entries to commit.
        LDA $74 : SUB $72 : STA $74
        
        SEP #$20
        
        LDX.b #$00
    
    .next_oam_entry
    
        TXY
        
        ; Store X coord.
        LDA ($72), Y : LDY.b #$00 : STA ($90), Y : INC $90
        
        INX : TXY
        
        ; Store Y coord.
        LDA ($72), Y : LDY.b #$00 : STA ($90), Y : INC $90
        
        INX : PHX : TXY
        
        LDA ($72), Y : AND.b #$0F : TAX
        
        ; Store chr.
        LDA .chr, X
        
        LDY.b #$00 : STA ($90), Y : INC $90
        
        PLX : TXY
        
        ; Store properties
        LDA ($72), Y : AND.b #$C0 : ORA.b #$3C
        
        LDY.b #$00 : STA ($90), Y : INC $90
        
        TXY
        
        ; Store oam size.
        LDA ($72), Y : AND.b #$30 : LSR #4
        
        LDY.b #$00 : STA ($92), Y : INC $92
        
        JSR Ancilla_CustomAllocateOam
        
        INX : CPX $74 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
