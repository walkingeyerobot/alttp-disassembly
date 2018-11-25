
; ==============================================================================

    ; $4698E-$469B1 DATA
    pool Ancilla_SomarianBlockFizzle:
    {
    
    .y_offsets
        dw -4, -1, -4, -4, -4, -4
    
    .x_offsets
        dw -4, -1, -8,  0, -6, -2
    
    .chr
        db $92, $FF, $F9, $F9, $F9, $F9
    
    .properties
        db $06, $FF, $86, $C6, $86, $C6
    }

; ==============================================================================

    ; *$469B2-$46A7E LONG BRANCH LOCATION
    Ancilla_TransmuteToSomarianBlockFizzle:
    {
        LDA $5E : CMP.b #$12 : BNE .player_not_slowed_down
        
        STZ $48
        STZ $5E
    
    .player_not_slowed_down
    
        STZ $0646
        
        LDA.b #$2D : STA $0C4A, X
        
        STZ $03B1, X
        STZ $0C54, X
        STZ $0C5E, X
        STZ $039F, X
        STZ $03A4, X
        STZ $03EA, X
        
        TXA : INC A : CMP $02EC : BNE .player_wasnt_carrying_block
        
        STZ $02EC
        
        LDA $0308 : AND.b #$80 : STA $0308
    
    .player_wasnt_carrying_block
    
    ; *$469E8 ALTERNATE ENTRY POINT
    shared Ancilla_SomarianBlockFizzle:
    
        DEC $03B1, X : BPL .animation_delay
        
        LDA.b #$03 : STA $03B1, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X : CMP.b #$03 : BNE .animation_delay
        
        STZ $0C4A, X
        
        RTS
    
    .animation_delay
    
        JSR Ancilla_PrepAdjustedOamCoord
        
        LDY.b #$00
        
        LDA $029E, X : CMP.b #$FF : BNE .coerce_above_ground
        
        LDA.b #$00
    
    .coerce_above_ground
    
        STA $04 : BPL .sign_ext_z_coord
        
        LDY.b #$FF
    
    .sign_ext_z_coord
    
        STY $05
        
        REP #$20
        
        LDA $04 : EOR.w #$FFFF : INC A : ADD $00 : STA $04
        
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDA $0C5E, X : ASL A : TAX
        
        LDY.b #$00 : STY $08
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        REP #$20
        
        PHX : TXA : ASL A : TAX
        
        LDA $04 : ADD .y_offsets, X : STA $00
        LDA $06 : ADD .x_offsets, X : STA $02
        
        PLX
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                               : STA ($90), Y : INY
        LDA .properties, X : AND.b #$CF : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX
        
        INC $08 : LDA $08 : CMP.b #$02 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
