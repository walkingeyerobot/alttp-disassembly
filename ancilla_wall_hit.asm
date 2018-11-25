
; ==============================================================================

    ; *$413E8-$4141E JUMP LOCATION
    Ancilla_WallHit:
    {
        DEC $039F, X : BPL .delay
        
        LDA $0C5E, X : INC A : CMP.b #$05 : BEQ .self_terminate
        
        STA $0C5E, X
        
        ; Reset the countdown tiemr to 1.
        LDA.b #$01 : STA $039F, X
        
        BRA .delay
    
    ; *$413FF ALTERNATE ENTRY POINT
    shared Ancilla_SwordWallHit:
    
        JSR Ancilla_AlertSprites
        
        DEC $03B1, X : BPL .delay
        
        LDA $0C5E, X : INC A : CMP.b #$08 : BEQ .self_terminate
        
        STA $0C5E, X
        
        ; Reset the countdown timer to 1.
        LDA.b #$01 : STA $03B1, X
        
        BRA .delay
    
    .self_terminate
    
        BRL Ancilla_SelfTerminate
    
    .delay
    
        BRL WallHit_Draw
    }

; ==============================================================================

    ; $4141F-$414DE DATA
    pool WallHit_Draw:
    {
    
    .chr
        db $80, $00, $00, $00, $92, $00, $00, $00
        db $81, $81, $81, $81, $82, $82, $82, $82
        db $93, $93, $93, $93, $92, $00, $00, $00
        db $B9, $00, $00, $00, $90, $90, $00, $00
    
    .properties
        db $32, $00, $00, $00, $32, $00, $00, $00
        db $32, $72, $B2, $F2, $32, $72, $B2, $F2
        db $32, $72, $B2, $F2, $32, $00, $00, $00
        db $72, $00, $00, $00, $32, $F2, $00, $00
    
    .y_offsets
        dw -4,  0,  0,  0, -4,  0,  0,  0
        dw -8, -8,  0,  0, -8, -8,  0,  0
        dw -8, -8,  0,  0, -4,  0,  0,  0
        dw -4,  0,  0,  0, -8,  0,  0,  0
    
    .x_offsets
        dw -4,  0,  0,  0, -4,  0,  0,  0
        dw -8,  0, -8,  0, -8,  0, -8,  0
        dw -8,  0, -8,  0, -4,  0,  0,  0
        dw -4,  0,  0,  0, -8,  0,  0,  0
    }

; ==============================================================================

    ; *$414DF-$41542 LONG BRANCH LOCATION
    WallHit_Draw:
    {
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $04
        LDA $02 : STA $06
        
        SEP #$20
        
        LDA.b #$03 : STA $08
        
        PHX
        
        LDA $0C5E, X : ASL #2 : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDA .chr, X : BEQ .skip_entry
        
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA .y_offsets, X : ADD $04 : STA $00
        LDA .x_offsets, X : ADD $06 : STA $02
        
        SEP #$20
        
        PLX
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X : STA ($90), Y
        INY
        
        LDA .properties, X : AND.b #$CF : ORA $65 : STA ($90), Y
        INY : PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_entry
    
        JSR Ancilla_CustomAllocateOam
        
        INX
        
        DEC $08 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
