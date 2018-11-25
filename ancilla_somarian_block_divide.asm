
; ==============================================================================

    ; *$46B3E-$46BE2 JUMP LOCATION
    Ancilla_SomarianBlockDivide:
    {
        DEC $03B1, X : BPL .full_divide_delay
        
        LDA.b #$03 : STA $03B1, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X : CMP.b #$02 : BNE .full_divide_delay
        
        STZ $0C4A, X
        
        PHX
        
        JSR SomarianBlast_SpawnCentrifugalQuad
        
        PLX
        
        RTS
    
    .full_divide_delay
    
        JSR Ancilla_PrepAdjustedOamCoord
        
        LDY.b #$00
        
        ; \wtf Where is this variable actually initialized or  set for this
        ; object?
        LDA $0380, X : CMP.b #$03 : BNE .unsigned_player_altitude
        
        LDA $24 : CMP.b #$FF : BNE .positive_player_altitude
    
    .unsigned_player_altitude
    
        LDA.b #$00
    
    .positive_player_altitude
    
        ADD $029E, X : STA $04 : BPL .positive_object_altitude
        
        LDY.b #$FF
    
    .positive_object_altitude
    
        STY $05
        
        REP #$20
        
        LDA $04 : EOR.w #$FFFF : INC A : ADD $00 : STA $04
        
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDA $0C5E, X : ASL #3 : TAX
        
        LDY.b #$00 : STY $08
    
    .next_oam_entry
    
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
        
        PLY : INX
        
        INC $08 : LDA $08 : CMP.b #$08 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
