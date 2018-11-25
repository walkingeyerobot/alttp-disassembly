
; ==============================================================================

    ; \note Each of these groupings corresponds to a different direction.
    ; Interestingly enough, I think the chr and properties are identical
    ; for all 3 directions. No surprise there, I guess.
    ; $45596-$45659 DATA
    pool Ancilla_SwordSwingSparkle:
    {
    
    .chr
        db $B7, $B7, $FF
        db $80, $80, $B7
        db $83, $83, $80
        db $83, $FF, $FF
        
        db $B7, $B7, $FF
        db $80, $80, $B7
        db $83, $83, $80
        db $83, $FF, $FF
        
        db $B7, $B7, $FF
        db $80, $80, $B7
        db $83, $83, $80
        db $83, $FF, $FF
        
        db $B7, $B7, $FF
        db $80, $80, $B7
        db $83, $83, $80
        db $83, $FF, $FF
    
    .properties
        db $00, $00, $FF
        db $00, $00, $00
        db $80, $80, $00
        db $80, $FF, $FF
        
        db $00, $00, $FF
        db $00, $00, $00
        db $80, $80, $00
        db $80, $FF, $FF
        
        db $00, $00, $FF
        db $00, $00, $00
        db $80, $80, $00
        db $80, $FF, $FF
        
        db $00, $00, $FF
        db $00, $00, $00
        db $80, $80, $00
        db $80, $FF, $FF
    
    .y_offsets
        db -22, -18,  -1
        db -22, -18, -17
        db -22, -18, -17
        db -17,  -1,  -1
        
        db  35,  40,  -1
        db  35,  40,  37
        db  35,  40,  37
        db  37,  -1,  -1
        
        db   2,   7,  -1
        db   2,   7,  19
        db   2,   7,  19
        db  19,  -1,  -1
        
        db   2,   7,  -1
        db   2,   7,  19
        db   2,   7,  19
        db  19,  -1,  -1
    
    .y_offsets
        db   5,  10,  -1
        db   5,  10,  -4
        db   5,  10,  -4
        db  -4,  -1,  -1
        
        db   0,   5,  -1
        db   0,   5,  14
        db   0,   5,  14
        db  14,  -1,  -1
        
        db -23, -27,  -1
        db -23, -27, -22
        db -23, -27, -22
        db -22,  -1,  -1
        
        db  32,  35,  -1
        db  32,  35,  30
        db  32,  35,  30
        db  30,  -1,  -1    
    
    .directed_oam_group
        db 0, 12, 24, 36
    }

; ==============================================================================

    ; *$4565A-$45703 JUMP LOCATION
    Ancilla_SwordSwingSparkle:
    {
        DEC $03B1, X : BPL .termination_delay
        
        LDA.b #$00 : STA $03B1, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$04 : BNE .termination_delay
        
        STZ $0C4A, X
        
        RTS
    
    .termination_delay
    
        PHX
        
        LDA $20 : STA $0BFA, X
        LDA $21 : STA $0C0E, X
        
        LDA $22 : STA $0C04, X
        LDA $23 : STA $0C18, X
        
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $04
        LDA $02 : STA $06
        
        SEP #$20
        
        ; Number of sprites to draw
        LDA.b #$02 : STA $08
        
        LDY $0C72, X
        
        LDA $0C5E, X : ASL A : ADD $0C5E, X : ADD .directed_oam_group, Y : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        REP #$20
        
        LDA .y_offsets, X : AND.w #$00FF : CMP.w #$0080 : BCC .positive_y_offset
        
        ORA.w #$FF00
    
    .positive_y_offset
    
        ADD $04 : STA $00
        
        LDA .x_offsets, X : AND.w #$00FF : CMP.w #$0080 : BCC .positive_x_offset
        
        ORA.w #$FF00
    
    .positive_x_offset
    
        ADD $06 : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                               : STA ($90), Y : INY
        LDA .properties, X : ORA.b #$04 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX
        
        DEC $08 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
