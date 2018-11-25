; ==============================================================================

    ; $46EDE-$46F99 DATA
    pool Ancilla_SkullWoodsFire:
    {
    
    .flame_y_offsets_low
        db 0, 0, 0, -3
    
    .flame_y_offsets_high
        db 0, 0, 0, -1
    
    .flame_chr
        db $8E, $A0, $A2, $A4
    
    .flame_properties
        db $02, $02, $02, $00
    
    .blast_chr
        db $86, $86, $86, $FF, $FF, $FF
        db $86, $86, $86, $86, $86, $86
        db $8A, $8A, $8A, $8A, $8A, $8A
        db $9B, $9B, $9B, $9B, $9B, $9B
    
    .blast_properties
        db $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00
        db $80, $40, $40, $80, $40, $00
    
    .blast_oam_sizes
        db $02, $02, $02, $02, $01, $01
        db $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02
        db $00, $00, $00, $00, $00, $00
    
    .blast_y_offsets
        dw -31, -24, -22,  -1,  -1,  -1
        dw -37, -32, -32, -23, -16, -14
        dw -37, -32, -32, -23, -16, -14
        dw -35, -29, -28, -20, -13, -11
    
    .blast_x_offsets
        dw -13, -21, -10,  -1,  -1,  -1
        dw -16, -27,  -4, -16,  -6, -25
        dw -16, -27,  -4, -16,  -6, -25
        dw -13,  -5, -27, -11, -22,  -3
    
    .blast_data_offsets
        db 0, 6, 12, 18
    }

; ==============================================================================

    ; *$46F9A-$47168 JUMP LOCATION
    Ancilla_SkullWoodsFire:
    {
        LDA $7F0010 : BEQ .blast_inactive
        
        LDA $0C5E, X : CMP.b #$04 : BEQ .blast_inactive
        
        DEC $03B1, X : BPL .blast_state_delay
        
        LDA.b #$05 : STA $03B1, X
        
        INC $0C5E, X
    
    .blast_state_delay
    .blast_inactive
    
        LDX.b #$03
        LDY.b #$00
    
    .execute_next_flame
    
        LDA $7F0008, X : DEC A : STA $7F0008, X
        
        BMI .reset_flame_animation_index
    
    .flame_permanently_inactive
    .dont_reset_flame_control_index
    
        BRL .draw_flames_logic
    
    .reset_flame_animation_index
    
        LDA.b #$05 : STA $7F0008, X
        
        LDA $7F0000, X : CMP.b #$80 : BEQ .flame_permanently_inactive
        
        INC A : STA $7F0000, X : BEQ .flame_control_state_reset
        
        CMP.b #$04 : BNE .dont_reset_flame_control_index
        
        LDA.b #$00 : STA $7F0000, X
    
    .flame_control_state_reset
    
        REP #$20
        
        LDA $7F0018 : SUB.w #$0008 : STA $7F0018
        
        CMP.w #$00C8 : BCS .dont_play_thud_sfx
        
        LDA.w #$0098 : SUB $E2 : STA $00
        
        SEP #$20
        
        LDA $7F0010 : CMP.b #$01 : BEQ .dont_play_thud_sfx
        
        ; Activate the blast component of this object.
        LDA.b #$01 : STA $7F0010
        
        LDA $00 : JSR Ancilla_SetSfxPan_NearEntity : ORA.b #$0C : STA $012E
    
    .dont_play_thud_sfx
    
        REP #$20
        
        LDA $7F0018 : CMP.w #$00A8 : BCS .dont_permadeativate_flame
        
        LDA $7F0000, X : AND.w #$FF00 : ORA.w #$0080 : STA $7F0000, X
    
    .dont_permadeativate_flame
    
        PHX : TXA : ASL A : TAX
        
        LDA $7F001A : STA $7F0030, X
        LDA $7F0018 : STA $7F0020, X
        
        PLX
        
        SEP #$20
        
        LDA $012E : BNE .sfx2_already_set
        
        LDA $7F001A : SUB $E2
        
        JSR Ancilla_SetSfxPan_NearEntity : ORA.b #$2A : STA $012E
    
    .sfx2_already_set
    .draw_flames_logic
    
        SEP #$20
        
        PHX
        
        LDA $7F0000, X : BPL .active_flame
        
        BRL .inactive_flame
    
    .active_flame
    
        PHY
        
        TAY
        
        LDA .flame_y_offsets_low,  Y : STA $04
        LDA .flame_y_offsets_high, Y : STA $05
        LDA .flame_chr, Y            : STA $06
        LDA .flame_properties, Y     : STA $07
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $7F0020, X : SUB $E8 : ADD $04 : STA $00
        
        LDA $7F0030, X : SUB $E2 : STA $02
        
        ADD.w #$0008 : STA $08
        
        SEP #$20
        
        PLY
        
        JSR Ancilla_SetOam_XY
        
        LDA $06    : STA ($90), Y : INY
        LDA.b #$32 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA $07 : STA ($92), Y
        
        PLY
        
        CMP.b #$02 : BEQ .large_oam_entry
        
        REP #$20
        
        LDA $08 : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA $06 : INC A : STA ($90), Y
        
        INY
        
        LDA.b #$32 : STA ($90), Y
        
        INY : PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA $07 : STA ($92), Y
        
        PLY
    
    .large_oam_entry
    .inactive_flame
    
        PLX : DEX : BMI .done_executing_flames
        
        BRL .execute_next_flame
    
    .done_executing_flames
    
        LDX.b #$03
    
    .find_active_flame_loop
    
        LDA $7F0000, X : BPL .flames_not_all_inactive
        
        DEX : BPL .find_active_flame_loop
        
        LDX $0FA0
        
        STZ $0C4A, X
        
        RTS
    
    .flames_not_all_inactive
    
        LDX $0FA0
        
        LDA $7F0010 : BEQ .blast_logic_inactive
        
        LDA $0C5E, X : CMP.b #$04 : BEQ .blast_logic_inactive
        
        TAX
        
        LDA .blast_data_offsets, X : TAX
        
        STZ $08
    
    .next_blast_oam_entry
    
        LDA .blast_chr, X : CMP.b #$FF : BEQ .skip_blast_oam_entry
        
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA.w #$00C8 : SUB $E8 : ADD .blast_y_offsets, X : STA $00
        LDA.w #$00A8 : SUB $E2 : ADD .blast_x_offsets, X : STA $02
        
        SEP #$20
        
        PLX
        
        JSR Ancilla_SetOam_XY
        
        LDA .blast_chr, X : STA ($90), Y : INY
        
        LDA .blast_properties, X : ORA.b #$30 : ORA.b #$02 : STA ($90), Y
        
        INY : PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA .blast_oam_sizes, X : STA ($92), Y
        
        PLY
    
    .skip_blast_oam_entry
    
        INX
        
        INC $08
        
        LDA $08 : CMP.b #$06 : BNE .next_blast_oam_entry
    
    .blast_logic_inactive
    
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================
