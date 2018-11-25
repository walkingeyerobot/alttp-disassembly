
; ==============================================================================

    ; $46BE3-$46C12 DATA
    pool Ancilla_LampFlame:
    {
    
    .chr
        db $9C, $9C, $FF, $FF
        db $A4, $A5, $B2, $B3
        db $E3, $F3, $FF, $FF
    
    .y_offsets_low
        db -3,  0,  0,  0
        db  0,  0,  8,  8
        db  0,  8,  0,  0
    
    .y_offsets_high
        db -1,  0,  0,  0
        db  0,  0,  0,  0
        db  0,  0,  0,  0
    
    .x_offsets_low
        db 4, 10, 0, 0
        db 1, 9, 2, 7
        db 4, 4, 0, 0    
    }

; ==============================================================================

    ; *$46C13-$46C76 JUMP LOCATION
    Ancilla_LampFlame:
    {
        JSR Ancilla_PrepAdjustedOamCoord
        
        LDA $00 : STA $06
        LDA $01 : STA $07
        
        LDY.b #$00
        
        LDA $0C68, X : BNE .termination_delay
        
        STZ $0C4A, X
        
        RTS
    
    .termination_delay
    
        AND.b #$F8 : LSR A : TAX
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        LDA .y_offsets_low, X : ADD $06                : STA $00
        LDA $07               : ADC .y_offsets_high, X : STA $01
        
        LDA .x_offsets_low, X : ADD $04    : STA $02
        LDA $05               : ADC.b #$00 : STA $03
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X          : STA ($90), Y : INY
        LDA.b #$02 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX : TXA : AND.b #$03 : BNE .next_oam_entry
        
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================
