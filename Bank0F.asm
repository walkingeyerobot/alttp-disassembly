; ==============================================================================

    ; *$7F540-$7F576 LONG
    Sprite_NullifyHookshotDrag:
    {
        PHB : PHK : PLB
        
        PHX
        
        LDX.b #$04
    
    .next_objext
    
        ; Check if the hookshot is being used
        LDA $0C4A, X : CMP.b #$1F : BNE .not_hookshot
        
        ; Is the hookshot dragging Link somewhere?
        LDA $037E : BEQ .hookshot_not_dragging_player
        
        ; If the hookshot will drag Link through this sprite, stop him
        STZ $037E : BRA .moving_on
    
    .not_hookshot
    .hookshot_not_dragging_player
    
        DEX : BPL .next_object
    
    .moving_on
    
        ; Buffer Link's coordinates
        
        LDA $23 : STA $41
        LDA $21 : STA $40
        
        REP #$20
        
        LDA $0FC2 : STA $22
        LDA $0FC4 : STA $20
        
        SEP #$20
        
        ; This is what stops Link dead in his tracks when he collides with a
        ; sprite :/
        JSL $07F42F ; $3F42F IN ROM; Does some stuff only relevant to indoors
        
        PLX
        
        PLB
        
        RTL
    }

; ==============================================================================
    
    ; *$7F577-$7F5C2 LONG
    Ancilla_CheckForAvailableSlot:
    {
        ; sees if the effect in question is already in play
        ; and if not, gives the okay to add it to the field.
        
        STY $0F : INY : STY $0E
        
        LDY.b #$00
        LDX.b #$04
    
    .nextSlot
    
        ; Compare the effect with the first 5 effects.
        CMP $0C4A, X : BNE .noMatch
        
        ; Y is the number of times that (A == $0C4A, X) is true
        INY
    
    .noMatch
    
        DEX : BPL .nextSlot
        
        CPY $0E : BEQ .alreadyFull
        
        LDY.b #$01 
        
        ; check if it's a bomb
        CMP.b #$07 : BEQ .onlyTwoSlots
        
        ; check if it's the rock fall from a bomb blowing open a door
        CMP.b #$08 : BEQ .onlyTwoSlots
        
        ; Otherwise, search 5 slots for an open one
        LDY.b #$04
    
    .onlyTwoSlots
    .findOpenSlot
    
        ; If any entry is zero, up to Y, end the routine (RTL)
        LDA $0C4A, Y : BEQ .openSlot
        
        DEY : BPL .findOpenSlot
    
    ; Here, none of the entries were 0, up until Y.
    .nextSlot2
    
        ; We go until this value is 0.
        ; As long as $03C4 is positive, skip this next part.
        DEC $03C4 : BPL .anoreset_slot_search_index
        
        ; The original Y parameter passed long ago.
        LDA $0F : STA $03C4
    
    .anoreset_slot_search_index
    
        LDY $03C4
        
        ; certain kinds of effects can be overridden, apparently
        LDA $0C4A, Y
        
        CMP.b #$3C : BEQ .openSlot
        CMP.b #$13 : BEQ .openSlot
        CMP.b #$0A : BEQ .openSlot
        
        ; Here none of the values matched. If we exhaust Y ( = $03C4), end the routine 
        DEY : BPL .nextSlot2
    
    .openSlot
    
        RTL
    
    .alreadyFull
    
        ; occurs when there are already too many of the same kind of effect in play
        TXY
        
        RTL
    }

; ==============================================================================

    ; $7F5C3-$7F5E2 DATA
    Death_PlayerSwoon:
    {
    
    .player_oam_states
        db 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 4, 5, 5
    
    .timers
        db 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 3, 3, 98
    
    .properties
        db $20, $10
    }

; ==============================================================================

    ; *$7F5E3-$7F64E LONG
    Death_PlayerSwoon:
    {
        PHB : PHK : PLB
        
        DEC $030B : BPL .delay
        
        ; \wtf Um, if this actually ends up as 0x0F, how do we advance in
        ; death mode?
        LDX $030D : INX : CPX.b #$0F : BEQ .return
                          CPX.b #$0E : BNE .swoon_in_progress
    
        INC $11
    
    .swoon_in_progress
    
        STX $030D
    
        LDA .player_oam_states, X : STA $030A
        
        LDA .timers, X : STA $030B
    
    .delay
    
        LDA $030D : CMP.b #$0D : BNE .return
        
        LDA $4B : CMP.b #$0C : BEQ .player_not_visible
        
        REP #$20
        
        LDA $20 : ADD.w #$0010 : SUB $E8 : STA $00
        LDA $22 : ADD.w #$0007 : SUB $E2 : STA $02
        
        SEP #$20
        
        LDY $EE
        
        LDA $02                         : STA $09D0
        LDA $00                         : STA $09D1
        LDA.b #$AA                      : STA $09D2
        LDA .properties, Y : ORA.b #$02 : STA $09D3
        
        LDA.b #$02 : STA $0A94
    
    .player_not_visible
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $7F64F-$7F67A DATA
    pool AddSwordBeam:
    {
    
    .initial_angles
        db $21, $1D, $19, $15
        db $03, $3E, $3A, $36
        db $12, $0E, $0A, $06
        db $31, $2D, $29, $25
    
    .y_speeds
        db $C0, $40, $00, $00
    
    .x_speeds
        db $00, $00, $C0, $40
    
    .rotation_speeds
        db $F8, $F8, $F8, $08
    
    .y_offsets_low
        db $E8, $08, $FA, $FA
    
    .y_offsets_high
        db $FF, $00, $FF, $FF
    
    .x_offsets_low
        db $F8, $F6, $EA, $04
    
    .x_offsets_high
        db $FF, $FF, $FF, $00
    }

; ==============================================================================

    ; *$7F67B-$7F74C LONG
    AddSwordBeam:
    {
        ; \note SHOOT TEH BEAMZ
        
        PHB : PHK : PLB
        
        ; Master sword's bolts of lightning
        LDA.b #$0C : JSL AddAncillaLong : BCS Death_PlayerSwoon.return
        
        LDA $2F : ASL A : TAY
        
        LDA .initial_angles+0, Y : STA $7F5800
        LDA .initial_angles+1, Y : STA $7F5801
        LDA .initial_angles+2, Y : STA $7F5802
        LDA .initial_angles+3, Y : STA $7F5803 : STA $7F5804
        
        LDA.b #$02 : STA $03B1, X
        LDA.b #$4C : STA $0C5E, X
        LDA.b #$08 : STA $039F, X
        
        STZ $0C54, X : STZ $0385, X : STZ $0394, X
        
        LDA.b #$00 : STA $03A4, X
        
        LDA.b #$0E : STA $7F5808
        
        LDA $2F : LSR A : STA $0C72, X : TAY
        
        LDA .y_speeds, Y        : STA $0C22, X
        LDA .x_speeds, Y        : STA $0C2C, X
        LDA .rotation_speeds, Y : STA $03A9, X
        
        REP #$20
        
        LDA $20 : ADD.w #$000C : STA $7F5810
        LDA $22 : ADD.w #$0008 : STA $7F580E
        
        SEP #$20
        
        JSL Ancilla_CheckInitialTileCollision_Class_1 : BCS .start_as_beam_hit
        
        PLB
        
        RTL
    
    .start_as_beam_hit
    
        LDY $0C72, X
        
        LDA $7F5810 : ADD .y_offsets_low,  Y : STA $0BFA, X
        LDA $7F5811 : ADC .y_offsets_high, Y : STA $0C0E, X
        
        LDA $7F580E : ADD .x_offsets_low,  Y : STA $0C04, X
        LDA $7F580F : ADC .x_offsets_high, Y : STA $0C18, X
        
        JSL Sound_SfxPanObjectCoords : ORA.b #$01 : STA $012F
        
        LDA.b #$04 : STA $0C4A, X
        LDA.b #$07 : STA $0C68, X
        
        LDA.b #$10 : STA $0C90, X
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $7F74D-$7F763 DATA
    pool SwordBeam:
    {
    
    .chr
        db $D7, $B7, $80, $83
    
    .extra_spark_chr
        db $B7, $80, $83
    
    .y_offsets_low
        db  0,  0, -6, -6
    
    .y_offsets_high
        db  0,  0, -1, -1
    
    .x_offsets_low
        db -8, -10, 0,  0
    
    .x_offsets_high
        db -1, -1,  0,  0
    }

; ==============================================================================

    ; *$7F764-$7F8EA LONG
    SwordBeam:
    {
        PHB : PHK : PLB
        
        PHX
        
        LDA.b #$02 : STA $73
        
        LDA $11 : BEQ .execute
        
        BRL .draw_logic
    
    .execute
    
        LDA $7F5810 : STA $0BFA, X
        LDA $7F5811 : STA $0C0E, X
        
        LDA $7F580E : STA $0C04, X
        LDA $7F580F : STA $0C18, X
        
        JSR SwordBeam_MoveVert
        JSR SwordBeam_MoveHoriz
        
        LDA $0BFA, X : STA $7F5810
        LDA $0C0E, X : STA $7F5811
        
        LDA $0C04, X : STA $7F580E
        LDA $0C18, X : STA $7F580F
        
        LDA $0394, X : AND.b #$0F : BNE .sfx_delay
        
        JSL Sound_SfxPanObjectCoords : ORA.b #$01 : STA $012F
    
    .sfx_delay
    
        INC $0394, X
        
        JSL Ancilla_CheckSpriteCollisionLong : BCS .hit_sprite
        
        JSL Ancilla_CheckTileCollisionLong : BCC .anohit_sprite_or_tile
    
    .hit_sprite
    
        LDY $0C72, X
        
        LDA $0BFA, X : ADD .y_offsets_low,  Y : STA $0BFA, X
        LDA $0C0E, X : ADC .y_offsets_high, Y : STA $0C0E, X
        
        LDA $0C04, X : ADD .x_offsets_low,  Y : STA $0C04, X
        LDA $0C18, X : ADC .x_offsets_high, Y : STA $0C18, X
        
        ; Transmute into a beam hit object.
        LDA.b #$04 : STA $0C4A, X
        
        ; Set timer and oam allocation for this tranmuted little guy.
        LDA.b #$07 : STA $0C68, X
        LDA.b #$10 : STA $0C90, X
        
        BRL .return
    
    .anohit_sprite_or_tile
    
        DEC $03B1, X : BPL .draw_logic
        
        LDA.b #$04 : STA $73
        
        LDA.b #$02 : STA $03B1, X
    
    .draw_logic
    
        LDA $03A9, X : STA $76
        
        LDY.b #$00
        LDX.b #$03
    
    .next_oam_entry
    
        STX $72
        
        LDA $11 : BNE .dont_rotate_component
        
        LDA $7F5800, X : ADD $76 : AND.b #$3F : STA $7F5800, X
    
    .dont_rotate_component
    
        PHX
        PHY
        
        LDA $7F5808 : STA $08
        
        LDA $7F5800, X
        
        JSL Ancilla_GetRadialProjectionLong
        JSL Sparkle_PrepOamCoordsFromRadialProjection
        
        PLY
        
        JSL Ancilla_SetOam_XY_Long
        
        LDX $72
        
        LDA .chr, X       : STA ($90), Y : INY
        LDA $73 : ORA $65 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX : PHX
        
        LDA $11 : BNE .dont_rotate_extra_spark
        
        DEC $039F, X : BPL .skip_extra_spark_draw_logic
        
        LDA.b #$00 : STA $039F, X
        
        LDA $03A4, X : INC A : AND.b #$03 : STA $03A4, X : CMP.b #$03 : BNE .dont_rotate_extra_spark
        
        LDA $7F5804 : ADD $76 : AND.b #$3F : STA $7F5804
    
    .dont_rotate_extra_spark
    
        LDA $03A4, X : STA $72 : CMP.b #$03 : BEQ .skip_extra_spark_draw_logic
        
        PHY
        
        LDA $7F5808 : STA $08
        
        LDA $7F5804
        
        JSL Ancilla_GetRadialProjectionLong
        JSL Sparkle_PrepOamCoordsFromRadialProjection
        
        PLY
        
        JSL Ancilla_SetOam_XY_Long
        
        LDX $72
        
        LDA .extra_spark_chr, X : STA ($90), Y : INY
        LDA.b #$04 : ORA $65    : STA ($90), Y : INY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
    
    .skip_extra_spark_draw_logic
    
        PLX
        PHX
        
        LDY.b #$01
    
    .find_active_component
    
        LDA ($90), Y : CMP.b #$F0 : BNE .at_least_one_component_active
        
        INY #4 : CPY.b #$11 : BNE .find_active_component
        
        STZ $0C4A, X
    
    .at_least_one_component_active
    .return
    
        PLX
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $7F8EB-$7F8FE
    pool SwordFullChargeSpark:
    {
    
    .y_offsets_low
        db -8,  27,  12,  12
    
    .y_offsets_high
        db -1,   0,   0,   0
    
    .x_offsets_low
        db  4,   4, -13, 20
    
    .x_offsets_high
        db  0,   0,  -1,  0
    
    .properties
        db $20, $10, $30, $20
    }

; ==============================================================================

    ; *$7F8FF-$7F960 LONG
    SwordFullChargeSpark:
    {
        PHB : PHK : PLB
        
        LDA $0C68, X : BNE .delay_termination
        
        STZ $0C4A, X
        
        BRA .return
    
    .delay_termination
    
        LDA $2F : LSR A : TAY
        
        LDA $20 : ADD .y_offsets_low,  Y : STA $00
        LDA $21 : ADC .y_offsets_high, Y : STA $01
        
        LDA $22 : ADD .x_offsets_low,  Y : STA $02
        LDA $23 : ADC .x_offsets_high, Y : STA $03
        
        REP #$20
        
        LDA $00 : SUB $E8 : STA $00
        LDA $02 : SUB $E2 : STA $02
        
        SEP #$20
        
        LDY $0C7C, X
        
        LDA .properties, Y : STA $65
                             STZ $64
        
        LDY.b #$00
        
        JSL Ancilla_SetOam_XY_Long
        
        LDA.b #$D7           : STA ($90), Y : INY
        LDA.b #$02 : ORA $65 : STA ($90), Y
        
        LDA.b #$00 : STA ($92)
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $7F961-$7F978 DATA
    pool AncillaSpawn_SwordChargeSparkle:
    {
    
    .y_offsets
        dw  5, 12,  8,  8
    
    .x_offsets
        dw  0,  3,  4,  5
    
    .y_position_masks
        db $00, $00, $07, $07
    
    .x_position_masks
        db $70, $70, $00, $00
    }

; ==============================================================================

    ; *$7F979-$7FA36 LONG
    AncillaSpawn_SwordChargeSparkle:
    {
        PHB : PHK : PLB
        
        LDX.b #$09
    
    .next_slot
    
        LDA $0C4A, X : BEQ .empty_ancillary_slot
        
        DEX : BPL .next_slot
        
        BRL .return
    
    .empty_ancillary_slot
    
        ; Spawn a sword charge sparkle.
        LDA.b #$3C : STA $0C4A, X
        
        STZ $0C5E, X
        
        LDA.b #$04 : STA $0C68, X
        
        LDA $EE : STA $0C7C, X
        
        STZ $74
        STZ $75
        
        LDA $2F : LSR A : TAY
        
        LDA .y_position_masks, Y : BNE .off_axis_y
        
        LDA $0079 : LSR #2
        
        CPY.b #$00 : BNE .sign_correct_for_y_direction
        
        EOR.b #$FF : INC A
    
    .sign_correct_for_y_direction
    
        STA $74
        
        LDA.b #$00
    
    .off_axis_y
    
        STA $72
        
        LDA .x_position_masks, Y : BNE .off_axis_x
        
        LDA $0079 : LSR #2
        
        CPY.b #$02 : BNE .sign_correct_for_x_direction
        
        EOR.b #$FF : INC A
    
    .sign_correct_for_x_direction
    
        STA $75
        
        LDA.b #$00
    
    .off_axis_x
    
        STA $73
        
        JSL GetRandomInt : STA $08 : AND $72 : STA $04
                                               STZ $05
        
        LDA $08 : AND $73 : LSR #4 : STA $06
                                     STZ $07
        
        LDY $2F
        
        REP #$20
        
        LDA $74 : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_y_offset
        
        ORA.w #$FF00
    
    .sign_ext_y_offset
    
        ADD $20 : ADD .y_offsets, Y : ADD $04 : STA $00
        
        LDA $75 : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_x_offset
        
        ORA.w #$FF00
    
    .sign_ext_x_offset
    
        ADD $22 : ADD .x_offsets, Y : ADD $06 : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$7FA37-$7FA42 LOCAL
    SwordBeam_MoveHoriz:
    {
    	TXA : ADD.b #$0A : TAX

    	JSR SwordBeam_MoveVert

    	LDX $0FA0
    	
        RTS
    }

; ==============================================================================

    ; *$7FA43-$7FA6E LOCAL
    SwordBeam_MoveVert:
    {
        LDA $0C22, X : ASL #4 : ADD $0C36, X : STA $0C36, X
        
        LDY.b #$00
        
        ; upper 4 bits are pixels per frame. lower 4 bits are 1/16ths of a pixel per frame.
        ; store the carry result of adding to $0C36, X
        ; check if the y pixel change per frame is negative
        LDA $0C22, X : PHP : LSR #4 : PLP : BPL .moving_down
        
        ; sign extend from 4-bits to 8-bits
        ORA.b #$F0
        
        DEY
    
    .moving_down
    
        ; modifies the y coordinates of the special object
              ADC $0BFA, X : STA $0BFA, X
        TYA : ADC $0C0E, X : STA $0C0E, X
        
        RTS
    }

; ==============================================================================

    ; *$7FA6F-$7FAE9 LONG
    Death_PrepFaint:
    {
        ; Something related to death mode and the spot light closing in...
        
        PHB : PHK : PLB
        
        LDA.b #$02 : STA $2F
        
        LDA.b #$01 : STA $036B
        
        STZ $030D : STZ $030A
        
        LDA.b #$05 : STA $030B
        
        ; Leave no chance of regeneration and zero out health.
        LDA.b #$00 : STA $7EF372
                     STA $7EF36D
        
        JSL $07F1FA ; $3F1FA IN ROM
        
        STZ $02F5 : STZ $0351 : STZ $02E0 : STZ $48
        STZ $02EC : STZ $4D   : STZ $46   : STZ $0373
        STZ $02E1 : STZ $5E   : STZ $03F7
        
        ; \item
        LDA $7EF357 : BEQ .no_moon_pearl
        
        STZ $56
    
    .no_moon_pearl
    
        STZ $03F5 : STZ $03F6
        
        ; Play passing out noise.
        JSL Sound_SetSfxPanWithPlayerCoords : ORA.b #$27 : STA $012E
        
        ; \item
        LDA.b #$06 : CMP $7EF35C : BEQ .noBottledFairy
                     CMP $7EF35D : BEQ .noBottledFairy
                     CMP $7EF35E : BEQ .noBottledFairy
                     CMP $7EF35F : BEQ .noBottledFairy
        
        STZ $05FC : STZ $05FD
    
    .noBottledFairy
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$7FAEA-$7FAFD LONG
    ShopKeeper_RapidTerminateReceiveItem:
    {
        ; Causes receive item ancilla to hurry up and finish executing.
        
        PHX
        
        LDX.b #$04
    
    .next_slot
    
        LDA $0C4A, X : CMP.b #$22 : BNE .not_receive_item
        
        LDA.b #$01 : STA $03B1, X
    
    .not_receive_item
    
        DEX : BPL .next_slot
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$7FAFE-$7FB79 LONG
    DashTremor_TwiddleOffset:
    {
    	LDY $0C72, X

    	LDA $0BFA, X : STA $00
    	LDA $0C0E, X : STA $01

    	REP #$20

        ; $00 *= -1
    	LDA $00 : EOR.w #$FFFF : INC A : STA $00

    	SEP #$20

    	LDA $00 : STA $0BFA, X
    	LDA $01 : STA $0C0E, X
        
    	LDA $1B : BNE .indoors
        
    	CPY.b #$02 : BNE .horizontal_shake
        
    	REP #$20
        
        ; \note It appears that these are screen boundaries of some sort.
    	LDA $0600 : ADD.w #$0001 : STA $02
    	LDA $0602 : ADD.w #$FFFF : STA $04
        
    	LDA $00 : ADD $E8 : CMP $02 : BEQ .zero_shake_vert
                                      BCC .zero_shake_vert
                            CMP $04 : BEQ .zero_shake_vert
                                      BCC .return
    
    .zero_shake_vert
    
    	BRA .zero_shake_offset_this_frame
    
    .horizontal_shake
    
    	REP #$20
        
        ; \note It appears that these are screen boundaries of some sort.
    	LDA $0604 : ADD.w #$0001 : STA $02
    	LDA $0606 : ADD.w #$FFFF : STA $04
        
    	LDA $00 : ADD $E2 : CMP $02 : BEQ .zero_shake_horiz
                                      BCC .zero_shake_horiz
                            CMP $04 : BEQ .zero_shake_horiz
                                      BCC .return
    
    .zero_shake_horiz
    .zero_shake_offset_this_frame
    
    	STZ $00
    
    .indoors
    .return
    
    	SEP #$20
        
    	RTL
    }

; ==============================================================================

    ; $7FB7A-$7FBC1 DATA
    pool BombosSpell_ExecuteBlasts:
    {
    
    .y_offsets length 64
        db $B6, $5D, $A1
    
    .x_offsets length 64
        db $30, $69, $B5, $A3, $24
        db $96, $AC, $73, $5F, $92, $48, $52, $81
        db $39, $95, $7F, $20, $88, $5D, $34, $98
        db $BC, $D2, $51, $77, $A2, $47, $94, $B2
        db $34, $DA, $30, $62, $9F, $76, $51, $46
        db $98, $5C, $9B, $61, $58, $95, $4C, $BA
        db $7E, $CB, $12, $D0, $70, $A6, $46, $BF
        db $40, $50, $7E, $8C, $2D, $61, $AC, $88
    
    ; \wtf Is this used for anything?
    .unknown
        db $20, $6A, $72, $5F, $D2, $28, $52, $80        
    }

; ==============================================================================

    ; $7FBC2-$7FCC1 DATA
    pool Ancilla_GetRadialProjection:
    {
        ; 0x100 bytes worth of data used to project a distance circularly or
        ; some shit. (Hey, I'm tired, will document later)
        
        ; These first two arrays are simplified sin() and cos() tables, but
        ; it's hard for me to tell yet which is which? It also requires further
        ; exploration to figure out whether the angle argument starts at 0
        ; degrees or radians or whatever, or whether it starts at a different
        ; on the unit circle. \task Figure this out.
        ; To quote a contemporary:
        ; "Trigonometry in assembler is a fucking bitch." -Kejardon
        
        db $00, $19, $31, $4A, $61, $78, $8E, $A2
        db $B5, $C5, $D4, $E1, $EC, $F4, $FB, $FE
        db $FF, $FE, $FB, $F4, $EC, $E1, $D4, $C5
        db $B5, $A2, $8E, $78, $61, $4A, $31, $19
        db $00, $19, $31, $4A, $61, $78, $8E, $A2
        db $B5, $C5, $D4, $E1, $EC, $F4, $FB, $FE
        db $FF, $FE, $FB, $F4, $EC, $E1, $D4, $C5
        db $B5, $A2, $8E, $78, $61, $4A, $31, $19
    
    
        db $FF, $FE, $FB, $F4, $EC, $E1, $D4, $C5
        db $B5, $A2, $8E, $78, $61, $4A, $31, $19
        db $00, $19, $31, $4A, $61, $78, $8E, $A2
        db $B5, $C5, $D4, $E1, $EC, $F4, $FB, $FE
        db $FF, $FE, $FB, $F4, $EC, $E1, $D4, $C5
        db $B5, $A2, $8E, $78, $61, $4A, $31, $19
        db $00, $19, $31, $4A, $61, $78, $8E, $A2
        db $B5, $C5, $D4, $E1, $EC, $F4, $FB, $FE
    
    
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
    
    
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01        
    }

; ==============================================================================

    ; $7FCC2-$7FD21 DATA
    pool Ancilla_SomarianBlockDivide:
    {
    
    .y_offsets
        dw -10, -10,   2,   2,  -8,   0,  -8,   0
        dw -12, -12,   4,   4,  -8,   0,  -8,   0
    
    .x_offsets
        dw  -8,   0,  -8,   0, -10, -10,   2,   2
        dw  -8,   0,  -8,   0, -12, -12,   4,   4
    
    .chr
        db $C6, $C6, $C6, $C6, $C4, $C4, $C4, $C4
        db $D2, $D2, $D2, $D2, $C5, $C5, $C5, $C5
    
    .properties
        db $C6, $86, $46, $06, $46, $C6, $06, $86
        db $C6, $86, $46, $06, $46, $C6, $06, $86
    }

; ==============================================================================

    ; *$7FD22-$7FD3B LONG
    Link_CheckBunnyStatus:
    {
        LDA $5D : CMP.b #$02 : BNE .linkNotRecoiling
        
        LDY.b #$00
        
        LDA $02E0 : BEQ .linkNotBunny
        
        LDY.b #$17 
        
        LDA $7EF357 : BEQ .noMoonPearl
        
        LDY.b #$1C
    
    .noMoonPearl
    
        STY $5D
    
    .linkNotBunny
    .linkNotRecoiling
    
        RTL
    }

; ==============================================================================

    ; *$7FD3C-$7FD51 LONG
    Ancilla_TerminateWaterfallSplashes:
    {
        ; \hardcoded
        LDA $8A : CMP.b #$0F : BNE .not_area_below_zora_falls
        
        LDX.b #$04
    
    .next_slot
    
        LDA $0C4A, X : CMP.b #$41 : BNE not_waterfall_splash
        
        ; Terminate the ancilla if it's a waterfall splash.
        STZ $0C4A, X
    
    .not_waterfall_splash
    
        DEX : BPL .next_slot
    
    .not_area_below_zora_falls
    
        RTL
    }

; ==============================================================================

    ; \note I think this routine is redundant, there are probably routines
    ; in bank 0x08 that can already handle this.
    ; *$7FD52-$7FD85 LONG
    Ancilla_TerminateIfOffscreen:
    {
        LDA $0BFA, Y : STA $0C
        LDA $0C0E, Y : STA $0D
        
        LDA $0C04, Y : STA $0E
        LDA $0C18, Y : STA $0F
        
        REP #$20
        
        LDA $0C : SUB $E8 : CMP.w #$00F0 : BCS .self_terminate
        
        LDA $0E : SUB $E2 : CMP.w #$00F4 : BCC .on_screen
    
    .self_terminate
    
        SEP #$20
        
        LDA.b #$00 : STA $0C4A, Y
    
    .on_screen
    
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; *$7FD86-$7FDA9 LONG
    Sprite_InitializeSecondaryItemMinigame:
    {
        PHX
        
        ; Signal that a Y button override is in effect (Shovel and Bow are the
        ; two known instances of this).
        STA $03FC
        
        JSL $07F1FA ; $3F1FA IN ROM
        
        LDX.b #$04
    
    .next_object
    
        LDA $0C4A, X
        
        CMP.b #$30 : BEQ .terminate_object
        CMP.b #$31 : BEQ .terminate_object
        CMP.b #$05 : BNE .no_match
        
        STZ $035F
    
    .terminate_object
    
        STZ $0C4A, X
    
    .no_match
    
        DEX : BPL .next_object
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$7FDAA-$7FDC3 LONG
    Main_ShowTextMessage:
    {
        ; Are we in text mode? If so then end the routine.
    	LDA $10 : CMP.b #$0E : BEQ .already_in_text_mode

    	STZ $0223   ; Otherwise set it so we are in text mode.
    	STZ $1CD8   ; Initialize the step in the submodule
    	
        ; Go to text display mode (as opposed to maps, etc)
    	LDA.b #$02 : STA $11
    	
        ; Store the current module in the temporary location.
    	LDA $10 : STA $010C
    	
        ; Switch the main module ($10) to text mode.
    	LDA.b #$0E : STA $10
    	
    .already_in_text_mode

    	RTL
    }

; ==============================================================================

    ; *$7FDC4-$7FDCE LONG
    Sprite_SpawnSparkleAncilla:
    {
    	PHB : PHK : PLB

    	PHX

    	JSL AddSwordChargeSpark

    	PLX

    	PLB

    	RTL
    }

; ==============================================================================

    ; \note Determines whether to use a shadow, a water ripple, or grass
    ; sprite under the bomb. It also detects situations where none of these
    ; are necessary or appropriate, and returns a carry flag state of clear
    ; to indicate that no 'underside' sprite should be drawn.
    
    ; *$7FDCF-$7FE71 LONG
    Bomb_CheckUndersideSpriteStatus:
    {
        ; this routine is a bomb exclusive
        
        LDA $0C5E, X : BEQ .not_exploding
                       BRL .no_underside_sprite
    
    .not_exploding
    
        STZ $0A ; Set it to a large shadow by default
        
        ; This checks for a water tile type
        ; (water tile type of course)
        LDA $03E4, X : CMP.b #$09 : BNE .not_shallow_water
        
        DEC $03E1, X : BPL .ripple_animation_delay
        
        LDA.b #$03 : STA $03E1, X
        
        INC $03D2, X
        
        LDA $03D2, X : CMP.b #$03 : BNE .anoreset_ripple_animation_index
        
        LDA.b #$00 : STA $03D2, X
    
    .ripple_animation_delay
    .anoreset_ripple_animation_index
    
        ; Puts a water ripple around the bomb
        LDA $03D2, X : ADD.b #$04 : STA $0A
        
        LDA $012E : AND.b #$3F
        
        CMP.b #$0B : BEQ .sfx_can_be_overriden
        CMP.b #$21 : BNE .shadow_size_logic
    
    .sfx_can_be_overriden
    
        STZ $012E
        
        JSL Sound_SfxPanObjectCoords : ORA.b #$28 : STA $012E
        
        BRA .shadow_size_logic
    
    .not_shallow_water
    
        ; grass tile type
        CMP.b #$40 : BNE .shadow_size_logic
        
        ; Put grass around the bomb
        LDA.b #$03 : STA $0A
    
    .shadow_size_logic
    
        ; Check the bomb's height off the ground
        ; If less than two, shadow stays large
        LDA $029E, X : CMP.b #$02 : BCC .use_large_shadow
        
        ; If >= 252, shadow stays large
        CMP.b #$FC : BCS .use_large_shadow
        
        ; if(height >= 2 && height < 252) draw a small shadow
        LDA.b #$02 : STA $0A
    
    .use_large_shadow
    
        ; Branch if Link is touching the bomb
        TXA : INC A : CMP $02EC : BNE .not_nearest_to_player
        
        ; Branch if Link is holding the bomb (or something else?)
        LDA $0308 : AND.b #$80 : BNE .no_underside_sprite
    
    .not_nearest_to_player
    
        ; \wtf What's the point of this?
        CPY.b #$04 : BEQ .oam_slot_is_four_yeah_ok_whatever
        
        LDY.b #$00
    
    .oam_slot_is_four_yeah_ok_whatever
    
        REP #$20
        
        LDA $029E, X : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_z_coord
        
        ; sign extends to 16-bits
        ORA.w #$FF00
    
    .sign_ext_z_coord
    
        ADD $0C : ADD.w #$0002 : STA $00
        
        LDA $0E : ADD.w #$FFF8 : STA $02
        
        SEP #$20
        
        LDA $65 : STA $04
        
        CLC
        
        RTL
    
    .no_underside_sprite
    
        SEC
        
        RTL
    }

; ==============================================================================
