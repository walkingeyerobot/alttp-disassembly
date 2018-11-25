
; ==============================================================================

    ; $40CD9-$40D18 DATA
    pool Ancilla_BeamHit:
    {
    
    .x_offsets
        db -12,  20, -12,  20
        db  -8,  16,  -8,  16
        db  -4,  12,  -4,  12
        db   0,   8,   0,   8
     
    .y_offsets
        db -12,  -12, 20,  20
        db  -8,  -8,  16,  16
        db  -4,  -4,  12,  12
        db   0,   0,   8,   8
    
    .chr
        db $53, $53, $53, $53
        db $53, $53, $53, $53
        db $53, $53, $53, $53
        db $54, $54, $54, $54
    
    .properties
        db $40, $00, $C0, $80
        db $40, $00, $C0, $80
        db $40, $00, $C0, $80
        db $00, $40, $80, $C0
    }

; ==============================================================================

    ; *$40D19-$40D67 JUMP LOCATION
    Ancilla_BeamHit:
    {
        JSR Ancilla_BoundsCheck
        
        LDA $0C68, X : BNE .delay
        
        BRL Ancilla_SelfTerminate
    
    .delay
    
        LSR A : STA $02
        
        ; Draw four sprites moving in away from another in a square pattern.
        LDX.b #$03
        LDY.b #$00
    
    .next_oam_entry
    
        STX $03
        
        LDA $02 : ASL #2 : ADC $03 : TAX
        
        LDA $00     : ADD .x_offsets, X                 : STA ($90), Y
        LDA $01     : ADD .y_offsets, X           : INY : STA ($90), Y
        LDA .chr, X : ADD.b #$82                  : INY : STA ($90), Y
        LDA .properties, X : ORA.b #$02 : ORA $04 : INY : STA ($90), Y
        
        INY
        
        LDX $03 : DEX : BPL .next_oam_entry
        
        LDX $0FA0
        
        LDY.b #$00
        LDA.b #$03
        
        BRL BeamHit_Unknown
    }

; ==============================================================================
