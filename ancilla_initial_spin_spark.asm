
; ==============================================================================

    ; $45704-$457B1 DATA
    pool Ancilla_InitialSpinSpark:
    {
    
    .timers
        db 4, 2, 3, 3, 2, 1
    
    .chr
        db $92, $FF, $FF, $FF
        db $8C, $8C, $8C, $8C
        db $D6, $D6, $D6, $D6
        db $93, $93, $93, $93
        db $D6, $D6, $D6, $D6
        db $D7, $FF, $FF, $FF
        db $80, $FF, $FF, $FF
    
    .properties
        db $22, $FF, $FF, $FF
        db $22, $62, $A2, $E2
        db $24, $64, $A4, $E4
        db $22, $62, $A2, $E2
        db $22, $62, $A2, $E2
        db $22, $FF, $FF, $FF
        db $22, $FF, $FF, $FF

    
        dw -4,  0,  0,  0
        dw -8, -8,  0,  0
        dw -8, -8,  0,  0
        dw -8, -8,  0,  0
        dw -8, -8,  0,  0
        dw -4,  0,  0,  0
        dw -4,  0,  0,  0
        
        dw -4,  0,  0,  0
        dw -8,  0, -8,  0
        dw -8,  0, -8,  0
        dw -8,  0, -8,  0
        dw -8,  0, -8,  0
        dw -4,  0,  0,  0
        dw -4,  0,  0,  0
    }

; ==============================================================================

    ; *$457B2-$4584C JUMP LOCATION
    Ancilla_InitialSpinSpark:
    {
        LDA $11 : BNE .draw
        
        DEC $03B1, X : BPL .draw
        
        STZ $03B1, X
        
        LDA $0C68, X : BNE .draw
        
        LDA $0C5E, X : INC A : STA $0C5E, X : TAY
        
        LDA .timers, Y : STA $0C68, X
        
        CPY.b #$05 : BNE .draw
        
        ; \wtf When is this branch ever taken? Perhaps this was test code,
        ; as the sword beam graphics are similar if not identical a spin attack.
        LDA $0C54, X : BNE .spawn_sword_beam
        
        BRL InitialSpinSpark_TransmuteToNormalSpinSpark
    
    .spawn_sword_beam
    
        JSL AddSwordBeam
        
        RTS
    
    .draw
    
        LDA $0C5E, X : BEQ .first_state_invisible
        
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $06
        LDA $02 : STA $08
        
        SEP #$20
        
        PHX
        
        LDY.b #$00 : STY $04
        
        LDA $0C5E, X : DEC A : ASL #2 : TAX
    
    ; *$45802 ALTERNATE ENTRY POINT
    .oam_commit_loop
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        REP #$20
        
        PHX : TXA : ASL A : TAX
        
        LDA $06 : ADD $D742, X : STA $00
        LDA $08 : ADD $D77A, X : STA $02
        
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
        
        INC $04 : LDA $04 : AND.b #$03 : BNE .next_oam_entry
        
        PLX
    
    .first_state_invisible
    
        RTS
    }

; ==============================================================================

    ; $4584D-$4586C DATA
    {
    
    .initial_rotation_states
        db $21, $20, $1F, $1E
        db $03, $02, $01, $00
        db $12, $11, $10, $0F
        db $31, $30, $2F, $2E
    
    .player_relative_y_offsets
        dw 28, -2, 24,  6
    
    .player_relative_x_offsets
        dw -3, 21, 25, -8
    }

; ==============================================================================

    ; *$4586D-$458F5 LONG BRANCH LOCATION
    InitialSpinSpark_TransmuteToNormalSpinSpark:
    {
        LDA.b #$2B : STA $0C4A, X
        
        LDA $2F : ASL A : TAY
        
        LDA .initial_rotation_states, Y : STA $7F5800
        LDA .initial_rotation_states, Y : STA $7F5801
        LDA .initial_rotation_states, Y : STA $7F5802
        LDA .initial_rotation_states, Y : STA $7F5803
                                          STA $7F5804
        
        LDA.b #$02 : STA $03B1, X
        LDA.b #$4C : STA $0C5E, X
        LDA.b #$08 : STA $039F, X
        
        STZ $0C54, X
        STZ $0385, X
        
        LDA.b #$FF : STA $03A4, X
        
        LDA.b #$14 : STA $7F5808
        
        LDY $2F
        
        REP #$20
        
        LDA $20 : ADD.w #$000C : STA $7F5810
        LDA $22 : ADD.w #$0008 : STA $7F580E
        
        LDA $20 : ADD $D85D, Y : STA $00
        LDA $22 : ADD $D865, Y : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
        
        BRA Ancilla_SpinSpark
    }

; ==============================================================================
