
; ==============================================================================

    ; $44091-$44093 DATA
    pool Ancilla_SleepIcon:
    {
    
    .tileset
        db $44, $43, $42
    }

; ==============================================================================

    ; *$44094-$44106 JUMP LOCATION
    Ancilla_SleepIcon:
    {
        ; Special object 0x21 (Link's Zs while he's sleeping)
        
        DEC $03B1, X : BPL .delay
        
        ; Don't increment the object's state beyond the value 2.
        LDA $0C5E, X : INC A : CMP.b #$03 : BEQ .at_last_state
        
        STA $0C5E, X
    
    .at_last_state
    
        LDA.b #$07 : STA $03B1, X
    
    .delay
    
        LDA $0C2C, X : ADD $0C54, X : STA $0C2C, X : BPL .positive_x_speed
        
        EOR.b #$FF : INC A
    
    .positive_x_speed
    
        CMP.b #$08 : BCC .dont_reverse_x_acceleration
        
        LDA $0C54, X : EOR.b #$FF : INC A : STA $0C54, X
    
    .dont_reverse_x_acceleration:
    
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        REP #$20
        
        LDA $20 : SUB.w #$0018 : CMP $00 : BCC .still_close_enough_to_player
        
        SEP #$20
        
        ; Self terminate if the Z gets too far away from the player.
        STZ $0C4A, X
    
    .still_close_enough_to_player
    
        SEP #$20
        
        LDY $0C5E, X
        
        ; This variable is used every NMI to update a small portion of the
        ; tiles available in vram. This essentially causes the 'Z's to
        ; cycle through different animation states.
        LDA .tileset, Y : STA $0109
        
        JSR Ancilla_PrepOamCoord
        
        LDY.b #$00
        
        JSR Ancilla_SetOam_XY
        
        LDA.b #$09 : STA ($90), Y : INY
        LDA.b #$24 : STA ($90), Y
        
        LDA.b #$00 : STA ($92)
        
        RTS
    }
