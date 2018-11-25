
; ==============================================================================

    ; $43BF4-$43C91 DATA
    pool Ancilla_DashDust:
    {
    
    .y_offsets
        dw -2,  0, -1
        dw -3, -2,  0
        dw -3,  0, -1
        dw -3, -1, -1
        dw -2, -1, -1
        dw -2,  0, -1
        dw -3, -2,  0
        dw -3,  0, -1
        dw -3, -1, -1
        dw -2, -1, -1
    
    .x_offsets
        dw 10,  5, -1
        dw  0, 10,  5
        dw  0,  5, -1
        dw  0, -1, -1
        dw  9, -1, -1
        dw 10,  5, -1
        dw  0, 10,  5
        dw  0,  5, -1
        dw  0, -1, -1
        dw  9, -1, -1
    
    .chr
        db $CF, $A9, $FF
        db $A9, $DF, $CF
        db $CF, $DF, $FF
        db $DF, $FF, $FF
        db $A9, $FF, $FF
        db $CF, $CF, $FF
        db $CF, $DF, $CF
        db $CF, $DF, $FF
        db $DF, $FF, $FF
        db $CF, $FF, $FF
    
    .player_relative_offset
        dw 0, 0, 4, -4
    }

; ==============================================================================

    ; *$43C92-$43D4B JUMP LOCATION
    Ancilla_DashDust:
    {
        LDA $0C54, X : BEQ .stationary_dust
        
        JSL Ancilla_MotiveDashDust
        
        BRA .return
    
    .stationary_dust
    
        LDA $0C68, X : BNE .delay
        
        LDA.b #$03 : STA $0C68, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X : CMP.b #$05 : BEQ .return
                                              CMP.b #$06 : BNE .delay
        
        STZ $0C4A, X
    
    .return
    
        RTS
    
    .delay
    
        LDA $0C5E, X : CMP.b #$05 : BEQ .return
        
        JSR Ancilla_PrepOamCoord
        
        PHX
        
        LDA $00 : STA $06
        LDA $01 : STA $07
        
        LDA $02 : STA $08
        LDA $03 : STA $09
        
        LDY $2F
        
        LDA .player_relative_offset+0, Y : STA $0C
        LDA .player_relative_offset+1, Y : STA $0D
        
        LDY.b #$00
        
        LDA $0351 : CMP.b #$01 : BNE .not_standing_in_water
        
        LDY.b #$05
    
    .not_standing_in_water
    
        STY $04
        
        LDA $0C5E, X : ADD $04 : STA $04
        
        ASL A : ADD $04 : STA $04
        
        LDA.b #$02 : STA $72
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDX $04
        
        LDA $BC6C, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $06 : ADD .y_offsets, X           : STA $00
        LDA $08 : ADD .x_offsets, X : ADD $0C : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDX $04
        
        LDA .chr, X          : STA ($90), Y : INY
        LDA.b #$04 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INC $04
        
        DEC $72 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
