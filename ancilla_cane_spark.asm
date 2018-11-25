
; ==============================================================================

    ; $45A84-$45B23 DATA
    pool Ancilla_InitialCaneSpark:
    {
    
    .chr
        db $92, $FF, $FF, $FF
        db $8C, $8C, $8C, $8C
        db $D6, $D6, $D6, $D6
        db $93, $93, $93, $93
    
    .properties
        db $22, $FF, $FF, $FF
        db $22, $62, $A2, $E2
        db $24, $64, $A4, $E4
        db $22, $62, $A2, $E2
    
    .y_offsets
    
        dw -4,  0,  0,  0
        dw -8, -8,  0,  0
        dw -8, -8,  0,  0
        dw -8, -8,  0,  0
    
    .x_offsets
        dw -4,  0,  0,  0
        dw -8,  0, -8,  0
        dw -8,  0, -8,  0
        dw -8,  0, -8,  0
    
    .player_relative_y_offsets
        dw  5,  0, -3, -6
        dw -8, -3, 12, 28
        dw  5,  0,  8, 16
        dw  5,  0,  8, 16
        
    .player_relative_x_offsets
        dw  3,   1,   0,   0
        dw 13,  16,  12,  12
        dw 24,   7,  -4, -10
        dw -8,   9,  22,  26
    }

; ==============================================================================

    ; *$45B24-$45C0D JUMP LOCATION
    Ancilla_InitialCaneSpark:
    {
        LDA $11 : BNE .transmute_delay
        
        DEC $03B1, X : BPL .transmute_delay
        
        LDA.b #$01 : STA $03B1, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X
        
        CMP.b #$11 : BNE .transmute_delay
        
        BRL CaneSpark_TransmuteInitialToNormal
    
    .transmute_delay
    
        ; Apparently, do nothing for the first state.
        LDA $0C5E, X : BNE .active
        
        BRL .return
    
    .active
    
        LDA $2F : ASL #2 : STA $00
        
        LDA $0300 : CMP.b #$02 : BNE .not_final_cast_pose
        
        TAY
        
        LDA $039F, X : DEC A : BPL .not_final_chr_group
        
        ; Reset the delay for using the final player relative position.
        ; Thus, all frames after this should use this position if $0300 stays
        ; at state 0x02.
        LDA.b #$00
        
        LDY.b #$03
    
    .not_final_chr_group
    
        STA $039F, X
        
        TYA
    
    .not_final_cast_pose
    
        ASL A : ADD $00 : TAY
        
        REP #$20
        
        LDA .player_relative_y_offsets, Y : ADD $20 : STA $00
        LDA .player_relative_x_offsets, Y : ADD $22 : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
        
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $06
        LDA $02 : STA $08
        
        SEP #$20
        
        PHX
        
        STZ $0A
        
        ; If we branch here, chr group is 0x00
        LDA $0C5E, X : DEC A : AND.b #$0F : BEQ .use_first_chr_group
        
        CMP.b #$0F : BEQ .use_last_chr_group
        
        ; chr group here is 0x01 or 0x02.
        AND.b #$01 : INC A : STA $0A
        
        BRA .start_oam_commit_loop
    
    .use_last_chr_group
    
        ; chr group here is 0x03.
        LDA.b #$03 : STA $0A
    
    .use_first_chr_group
    .start_oam_commit_loop
    
        LDA $0A : ASL #2 : TAX
        
        LDY.b #$00 : STY $04
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        REP #$20
        
        PHX
        
        TXA : ASL A : TAX
        
        LDA $06 : ADD .y_offsets, X : STA $00
        LDA $08 : ADD .x_offsets, X : STA $02
        
        PLX
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                               : STA ($90), Y : INY
        LDA .properties, X : AND.b #$CF : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        ; all oam entries are small for this guy.
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX
        
        INC $04 : LDA $04 : AND.b #$03 : BNE .next_oam_entry
        
        PLX
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $45C0E-$45C20 DATA
    pool CaneSpark_TransmuteInitialToNormal:
    {
    
    .initial_rotation_states
        db $34, $33, $32, $31
        db $16, $15, $14, $13
        db $2A, $29, $28, $27
        db $10, $0F, $0E, $0D
    
    .mp_costs
        db 4, 2, 1
    }

; ==============================================================================

    ; *$45C21-$45DC4 LONG BRANCH LOCATION
    CaneSpark_TransmuteInitialToNormal:
    {
        LDA.b #$31 : STA $0C4A, X
        
        LDA $2F : ASL A : TAY
        
        LDA .initial_rotation_states+0, Y : STA $7F5800
        LDA .initial_rotation_states+1, Y : STA $7F5801
        LDA .initial_rotation_states+2, Y : STA $7F5802
        LDA .initial_rotation_states+3, Y : STA $7F5803
        
        LDA.b #$17 : STA $03B1, X
        
        STZ $0394, X
        STZ $0C5E, X
        
        LDA.b #$08 : STA $039F, X
        
        STZ $0C54, X
        STZ $0385, X
        
        LDA.b #$02 : STA $03A4, X
        
        LDA.b #$15 : STA $0C68, X
        
        DEC A : STA $7F5808
        
        LDA.b #$30 : JSR Ancilla_DoSfx3_NearPlayer
    
    ; *$45C70 ALTERNATE ENTRY POINT
    shared Ancilla_CaneSpark:
    
        ; Cane of Byrna's spinning light.
        
        PHX
        
        ; Set palette property compoment.
        LDA.b #$02 : STA $73
        
        ; Make sure we're in the basic submodule.
        LDA $11 : BEQ .execute
        
        ; just draw, don't execute any state changes.
        BRL .draw
    
    .execute
    
        LDA $0303 : CMP.b #$0D : BNE .self_terminate
        
        ; Make player invincible.
        LDA.b #$01 : STA $037B
        
        ; Delay counter. (waits 0x18 frames to deplete magic)
        DEC $03B1, X : LDA $03B1, X : BNE .maintain_invulnerability
        
        ; If this... timer has counted down. Reset it to one.
        LDA.b #$01 : STA $03B1, X
        
        ; Does player have normal, 1/2, or 1/4 consumption?
        LDA $7EF37B : TAY
        
        ; Table of magic depletion values for the cane effects. 
        ; Depletions are every 0x18 frames.
        LDA .mp_costs, Y : STA $00
        
        ; Reduce magic by this amount
        LDA $7EF36E : BEQ .self_terminate
        
        ; Would consuming that much magic would leave us in the red?
        SUB $00 : CMP.b #$80 : BCS .self_terminate
        
        STA $00
        
        DEC $0394, X : BPL .magic_depletion_delay
        
        LDA.b #$17 : STA $0394, X
        
        LDA $00 : STA $7EF36E
    
    .magic_depletion_delay
    
        ; Check if Y button was pressed this frame. branch if it wasn't.
        BIT $F4 : BVC .maintain_invulnerability
    
    .self_terminate
    
        PLX
        
        ; Make player vulnerable again.
        STZ $037B
        
        ; Self terminate this object.
        STZ $0C4A, X
        
        STZ $0373 ; Make it so Link takes no damage I guess.
        
        RTS
    
    .maintain_invulnerability
    
        LDA $0C54, X : CMP.b #$03 : BEQ .all_sparkles_visible
        
        LDY.b #$00
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$04 : BCC .not_all_visible
        
        LDY.b #$03
        
        BRA .set_new_visible_quantity
    
    .not_all_visible
    
        CMP.b #$02 : BNE .not_two_visible
        
        LDY.b #$01
    
    .not_two_visible
    
        CMP.b #$03 : BNE .not_three_visible
        
        LDY.b #$02
    
    .set_new_visible_quantity
    .not_three_visible
    
        TYA : STA $0C54, X
    
    .all_sparkles_visible
    
        DEC $03A4, X : BPL .draw
        
        LDA.b #$02 : STA $03A4, X
        
        ; Override to a different palette in this situation (blue?)
        LDA.b #$04 : STA $73
    
    .draw
    
        REP #$20
        
        LDA $24 : AND.w #$00FF
        
        CMP.w #$0080 : BCC .no_player_altitude_sign_extend
        
        ORA.w #$FF00
    
    .no_player_altitude_sign_extend
    
        CMP.w #$FFFF : BNE .player_not_hitting_ground
        
        LDA.w #$0000
    
    .player_not_hitting_ground
    
        EOR.w #$FFFF : INC A
        
        ADD $20 : ADD.w #$000C : STA $7F5810
        LDA $22 : ADD.w #$0008 : STA $7F580E
        
        SEP #$20
        
        LDA $0C68, X : BNE .sfx_delay
        
        LDA.b #$15 : STA $0C68, X
        
        LDA.b #$30 : JSR Ancilla_DoSfx3_NearPlayer
    
    .sfx_delay
    
        STX $74
        
        LDY.b #$00
        
        LDA $0C54, X : TAX
    
    .next_oam_entry
    
        STX $72
        
        LDA $11 : BNE .dont_increment_sparkle_rotation
        
        LDA $7F5800, X : ADD.b #$03 : AND.b #$3F : STA $7F5800, X
    
    .dont_increment_sparkle_rotation
    
        PHX : PHY
        
        LDA $7F5808 : STA $08
        
        LDA $7F5800, X
        
        JSR Ancilla_GetRadialProjection
        JSL Sparkle_PrepOamCoordsFromRadialProjection
        
        PLY
        
        JSR Ancilla_SetOam_XY
        
        LDX $72
        
        LDA $D8F6, X      : STA ($90), Y : INY
        LDA $73 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        REP #$20
        
        LDA $00 : ADD $E8 : STA $04
        LDA $02 : ADD $E2 : STA $06
        
        SEP #$20
        
        LDX $74
        
        LDA $04 : STA $0BFA, X
        LDA $05 : STA $0C0E, X
        
        LDA $06 : STA $0C04, X
        LDA $07 : STA $0C18, X
        
        STZ $0C72, X
        
        JSR Ancilla_CheckSpriteCollision
        
        PLY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
