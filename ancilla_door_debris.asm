
; ==============================================================================

    ; *$41FB6-$41FD0 JUMP LOCATION
    Ancilla_DoorDebris:
    {
        ; Special Effect 0x08 - Debris from bombing a cave / wall open.
        
        JSR DoorDebris_Draw
        
        DEC $03C0, X : BPL .delay
        
        LDA.b #$07 : STA $03C0, X
        
        INC $03C2, X
        
        LDA $03C2, X : CMP.b #$04 : BNE .delay
        
        ; Self-terminate at this point.
        STZ $0C4A, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $41FD1-$42090 DATA
    pool DoorDebris_Draw:
    {
    
    .xy_offsets
        dw  4,  7,  3, 17,  8,  8,  7, 17
        dw 11,  7, 10, 16, 16,  7, 17, 17
        dw 20,  7, 21, 17, 16,  8, 17, 17
        dw 13,  7, 14, 16,  8,  7,  7, 17
        dw  7,  4, 17,  3,  8,  8, 17,  7
        dw  7, 11, 16, 10,  7, 16, 17, 17
        dw  7, 20, 17, 21,  8, 16, 17, 17
        dw  7, 13, 16, 14,  7,  8, 17,  7
    
    .chr_and_properties
        db $5E, $20, $5E, $E0, $5E, $A0, $5E, $60
        db $4F, $20, $4F, $20, $4F, $20, $4F, $20
        db $5E, $60, $5E, $60, $5E, $20, $5E, $E0
        db $4F, $60, $4F, $60, $4F, $60, $4F, $60
        db $5E, $20, $5E, $E0, $5E, $A0, $5E, $60
        db $4F, $20, $4F, $E0, $4F, $20, $4F, $20
        db $5E, $60, $5E, $60, $5E, $20, $5E, $E0
        db $4F, $60, $4F, $60, $4F, $60, $4F, $60
    }

; ==============================================================================

    ; *$42091-$42120 LOCAL
    DoorDebris_Draw:
    {
        JSR Ancilla_PrepAdjustedOamCoord
        
        TXA : ASL A : TAY
        
        REP #$20
        
        LDA $03BA, Y : SUB $E8 : STA $0C
        LDA $03B6, Y : SUB $E2 : STA $0E
        
        SEP #$20
        
        PHX
        
        STZ $06
        
        LDA $03C2, X : ASL #2 : STA $04 : STA $08
        
        LDA $03BE, X : ASL #4 : STA $0A
        
        ADD $04 : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        PHX
        
        LDA $0A : ASL A : STA $04
        
        LDA $08 : ASL A : ADD $04 : STA $04
        
        LDA $06 : ASL #2 : ADD $04 : TAX
        
        REP #$20
        
        ; The first entry in each interleaved pair is the y offset and the
        ; second is the x offset.
        LDA .xy_offsets + 0, X : ADD $0C : STA $00
        LDA .xy_offsets + 2, X : ADD $0E : STA $02
        
        SEP #$20
        
        PLX
        
        JSR Ancilla_SetOam_XY
        
        ; The second entry in each interleaved set is a property, and the first
        ; is a chr value.
        LDA .chr_and_properties + 0, X                        : STA ($90), Y : INY
        LDA .chr_and_properties + 2, X : AND.b #$C0 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : JSR Ancilla_CustomAllocateOam
        
        INX #2
        
        LDA $06 : INC A : STA $06 : CMP.b #$02 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================

