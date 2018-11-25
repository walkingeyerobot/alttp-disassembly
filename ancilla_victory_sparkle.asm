
; ==============================================================================

    ; $44107-$44166 DATA
    pool Ancilla_VictorySparkle:
    {
    
    .y_offsets
        dw -7,  0,  0,  0, -11, -11, -3, -3
        dw -7, -7,  0,  0,  -7,   0,  0,  0
    
    .x_offsets
        dw 16,  0,  0,  0,  8, 16,  8, 16
        dw  9, 15,  0,  0, 12,  0,  0,  0
    
    .chr
        db $92, $FF, $FF, $FF, $93, $93, $93, $93
        db $F9, $F9, $FF, $FF, $80, $FF, $FF, $FF
    
    .properties
        db $00, $FF, $FF, $FF, $00, $40, $80, $C0
        db $00, $40, $FF, $FF, $00, $FF, $FF, $FF
    }

; ==============================================================================

    ; *$44167-$441E3 JUMP LOCATION
    Ancilla_VictorySparkle:
    {
        ; Special object 0x3B (Victory Sparkle)
        
        !numSprites = $06
        
        LDA $03B1, X : BNE .delay
        
        DEC $039F, X : BPL .active
        
        LDA.b #$01 : STA $039F, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$04 : BNE .active
        
        STZ $0C4A, X
    
    .delay
    
        DEC $03B1, X
        
        RTS
    
    .active
    
        PHX
        
        JSR Ancilla_PrepOamCoord
        
        LDA.b #$03 : STA !numSprites
        
        LDA $0C5E, X : ASL #2 : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDA $C147, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        REP #$20
        
        PHX : TXA : ASL A : TAX
        
        LDA $20 : ADD .y_offsets, X : SUB $E8 : STA $00
        LDA $22 : ADD .x_offsets, X : SUB $E2 : STA $02
        
        PLX
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                               : STA ($90), Y : INY
        LDA .properties, X : ORA.b #$04 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX
        
        DEC !numSprites : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
