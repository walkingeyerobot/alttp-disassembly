
; ==============================================================================

    ; $4422F-$4425E DATA
    pool Ancilla_SwordCeremony:
    {
    
    .y_offsets
        dw 1, 1, 9, 9
        dw 1, 1, 9, 9
    
    .x_offsets
        dw -1,  8, -1,  8
        dw  0,  7,  0,  7
    
    .chr
        db $86, $86, $96, $96
        db $87, $87, $97, $97
    
    .properties
        db $01, $41, $01, $41
        db $01, $41, $01, $41
    }

; ==============================================================================

    ; *$4425F-$442DC JUMP LOCATION
    Ancilla_SwordCeremony:
    {
        ; Special object 0x35 - Master Sword Ceremony
        
        LDA $0C68, X : BNE .delay
        
        STZ $0C4A, X
        
        RTS
    
    .delay
    
        DEC $03B1, X : BPL .dont_advance_animation_index
        
        LDA $0C5E, X : INC A : CMP.b #$03 : BNE .dont_reset_animation_index
        
        LDA.b #$00
    
    .dont_reset_animation_index
    
        STA $0C5E, X
    
    .dont_advance_animation_index
    
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $04
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        STZ $08
        
        LDA $0C5E, X : BEQ .nothing_to_draw
        
        DEC A : ASL #2 : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        PHX : TXA : ASL A : TAX
        
        REP #$20
        
        LDA $04 : ADD .y_offsets, X : STA $00
        LDA $06 : ADD .x_offsets, X : STA $02
        
        SEP #$20
        
        PLX
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X : STA ($90), Y : INY
        
        LDA .properties, X : AND.b #$CF
        
        ORA.b #$04 : ORA $65 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
        
        INX
        
        INC $08 : LDA $08 : CMP.b #$04 : BNE .next_oam_entry
    
    .nothing_to_draw
    
        PLX
        
        RTS
    }

; ==============================================================================
