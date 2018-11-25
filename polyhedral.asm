
; ==============================================================================

    ; *$4F7DE-$4F81C LONG
    Polyhedral_InitThread:
    {
        PHP : PHB
        
        REP #$30
        
        PHA : PHX : PHY
        
        LDA.w #$0000 : STA $001F00
        LDX.w #$1F00
        LDY.w #$1F02
        
        ; Initialization.
        LDA.w #$00FD
        
        MVN $00,$00
        
        LDA.w #$1F31 : STA $1F0A
        
        LDA.w #$000C
        LDX.w #.thread_init_state
        LDY.w #$1F32
        
        MVN $09,$00
        
        PLY : PLX : PLA 
        
        PLB : PLP
        
        RTL
    
    .thread_init_state
        db $09          ; For B register
        dw $1F00        ; For D register
        dw $0000        ; For Y register
        dw $0000        ; For X register
        dw $0000        ; For A register
        db $30          ; Status register at return addres location.
        dl $09F81D      ; Return address in helper thread
    }
    
; ==============================================================================

    ; $4F81D-$4F83C
    {
        ; Polyhedral thread entry point
    
    .wait
    
        LDA $00 : BEQ .wait
        LDA $0C : BNE .wait
        
        JSL $09FD04 ; $4FD04 in ROM
        
        JSR $F83D ; $4F83D in Rom.
        JSR $F864 ; $4F864 in Rom.
        JSR $F8FB ; $4F8FB in Rom.
        JSR $FA4F ; $4FA4F in Rom.
        
        STZ $00
        
        LDA.b #$FF : STA $0C
        
        BRA .wait
    }

    ; $4F83D-$4F863 LOCAL
    {
        REP #$30
        
        LDA $02 : AND.w #$00FF : ASL A : ADC.w #$0080 : STA $08
        
        LDA $1F03 : AND.w #$00FF : ASL A : STA $B0
        
        ; X = ( 0xFF8C + ($1F03 * 6) ).
        ; Note that $1F03 seems to always be 0 or 1
        ASL A : ADC $B0 : ADC.w #$FF8C : TAX
        
        LDY.w #$1F3F
        LDA.w #$0005
        
        MVN $09,$09
        
        RTS
    }

    ; $4F864-$4F8FA LOCAL
    {
        SEP #$30
        
        LDY $04
        
        LDA $FB6D, Y : STA $50
        
        CMP.b #$80 : SBC $50 : EOR.b #$FF : STA $51
        
        LDA $FBAD, Y : STA $52
        
        CMP.b #$80 : SBC $52 : EOR.b #$FF : STA $53
        
        LDY $05
        
        LDA $FB6D, Y : STA $54
        
        CMP.b #$80 : SBC $54 : EOR.b #$FF : STA $55
        
        LDA $FBAD, Y : STA $56
        
        CMP.b #$80 : SBC $56 : EOR.b #$FF : STA $57
        
        REP #$20
        
        SEI
        
        LDX $54 : STX $211B
        LDX $55 : STX $211B
        LDX $50 : STX $211C
        
        LDA $2135 : ASL #2 : STA $58
        
        LDX $56 : STX $211B
        LDX $57 : STX $211B
        LDX $52 : STX $211C
        
        LDA $2135 : ASL #2 : STA $5E
        
        LDX $56 : STX $211B
        LDX $57 : STX $211B
        LDX $50 : STX $211C
        
        LDA $2135 : ASL #2 : STA $5A
        
        LDX $54 : STX $211B
        LDX $55 : STX $211B
        LDX $52 : STX $211C
        
        LDA $2135 : ASL #2 : STA $5C
        
        CLI
        
        RTS
    }

    ; $4F8FB-$4F930
    {
        SEP #$30
        
        LDA $3F : TAX
        
        ; Y = 3 * $3F
        ASL A : ADC $3F : TAY
    
    .alpha
    
        DEX
        
        DEY
        
        LDA ($41), Y : STA $47
        
        DEY
        
        LDA ($41), Y : STA $46
        
        DEY
        
        LDA ($41), Y : STA $45
        
        PHY
        
        REP #$20
        
        JSR $F931 ; $4F931 in rom.
        JSR $F9D6 ; $4F9D6 in Rom.
        
        SEP #$20
        
        CLC : LDA $06 : ADC $48 : STA $60, X
        SEC : LDA $07 : SBC $4A : STA $88, X
        
        PLY : BNE .alpha
        
        RTS
    }
    
    ; $4F931-$4F9D5
    {
        LDY $56
        
        SEI
        
                  STY $211B
        LDY $57 : STY $211B
        LDY $45 : STY $211C
        
        LDA $2134
        
        LDY $54 : STY $211B
        LDY $55 : STY $211B
        LDY $47 : STY $211C
        
        SUB $2134
        
        CLI
        
        STA $48
        
        LDY $58
        
        SEI
        
                  STY $211B
        LDY $59 : STY $211B
        LDY $45 : STY $211C
        
        LDA $2134
        
        LDY $52 : STY $211B
        LDY $53 : STY $211B
        LDY $46 : STY $211C
        
        ADD $2134
        
        LDY $5A : STY $211B
        LDY $5B : STY $211B
        LDY $47 : STY $211C
        
        ADD $2134
        
        CLI
        
        STA $4A
        
        LDY $5C
        
        SEI
        
                  STY $211B
        LDY $5D : STY $211B
        LDY $45 : STY $211C
        
        LDA $2135
        
        LDY $50 : STY $211B
        LDY $51 : STY $211B
        LDY $46 : STY $211C
        
        SUB $2135
        
        LDY $5E : STY $211B
        LDY $5F : STY $211B
        LDY $47 : STY $211C
        
        ADD $2135
        
        ; Note that this combines a CLC with a CLI
        REP #$05
        
        ADC $08 : STA $4C
        
        RTS
    }

    ; $4F9D6-$4FA4E
    {
        LDA $48 : BPL .alpha
        
        EOR.w #$FFFF : INC A
    
    .alpha
    
        STA $B2
        
        LDA $4C : STA $B0
        
        XBA : AND.w #$00FF : BEQ .gamma
    
    .beta
    
        LSR $B2
        LSR $B0
        
        LSR A : BNE .beta
    
    .gamma
    
        SEI
        
        LDA $B2 : STA $4204
        LDY $B0 : STY $4206
        
        NOP #2
        
        LDA.w #$0000
        
        LDY $49
        
        SEC
        
        BMI .delta
        
        NOP
        
        LDA $4214
        
        BRA .epsilon
    
    .delta
    
        SBC $4214
    
    .epsilon
    
        CLI
        
        STA $48
        
        ; $4FA12
        
        LDA $4A : BPL .zeta
        
        EOR.w #$FFFF : INC A
    
    .zeta
    
        STA $B2
        
        LDA $4C : STA $B0
        
        XBA : AND.w #$00FF : BEQ .iota
    
    .theta
    
        LSR $B2
        LSR $B0
        
        LSR A : BNE .theta
    
    .iota
    
        SEI
        
        LDA $B2 : STA $4204
        LDY $B0 : STY $4206
        
        NOP #2
        
        LDA.w #$0000
        
        LDY $4B
        
        SEC
        
        BMI .kappa
        
        NOP
        
        LDA $4214
        
        BRA .lamba
    
    .kappa
    
        SBC $4214
    
    .lambda
    
        CLI
        
        STA $4A
        
        RTS
    }

    ; $4FA4F-$4FAC9
    {
        SEP #$30
        
        LDY.b #$00
    
    .delta
    
        LDA ($43), Y : STA $4E
        
        AND.b #$7F : STA $B0
        
        ASL A : STA $C0
        
        INY
        
        LDX.b #$01
    
    .alpha
    
        PHY
        
        LDA ($43), Y : TAY
        
        LDA $1F60, Y : STA $C0, X
        
        INX
        
        LDA $1F88, Y : STA $C0, X
        
        INX
        
        PLY : INY
        
        DEC $B0 : BNE .alpha
        
        LDA ($43), Y
        
        INY
        
        STA $4F
        
        PHY
        
        LDA $C0 : CMP.b #$06 : BCC .beta
        
        JSR $FB24 : BMI .gamma : BEQ .beta
        
        JSR $FACA   ; $4FACA in Rom.
        JSL $09FD1E ; $4FD1E in Rom.
    
    .beta
    
        PLY
        
        DEC $40 : BNE .delta
        
        RTS
    
    .gamma
    
        LDA $4E : BPL .beta
        
        REP #$20
        
        LDA $C0 : AND.w #$00FF : TAY
        
        DEY
        
        LDX.b #$01
        
        LSR #2 : STA $B0
    
    .epsilon
    
        LDA $C0, X : PHA
        
        LDA $1FC0, Y : STA $C0, X
        
        PLA
        
        STA $1FC0, Y
        
        INX #2
        
        DEY #2
        
        DEC $B0 : BNE .epsilon
        
        SEP #$20
        
        JSR $FAD7   ; $4FAD7 in rom.
        JSL $09FD1E ; $4FD1E in Rom.
        
        JMP .beta
    }

    ; $4FACA-$4FAD6 LOCAL
    {
        LDA $01 : BNE BRANCH_4FAD7_external_1
        
        LDA $4F : AND.b #$07
        
        JSL $09FCAE ; $4FCAE in ROM.
        
        RTS
    }

    ; $4FAD7-$4FB23
    {
        LDA $01 : BNE .alpha
        
        LDA $4F : LSR #4 : AND.b #$07
        
        JSL $09FCAE ; $4FCAE in ROM.
        
        RTS
    
    .alpha
    
        REP #$20
        
        LDA $B0 : EOR.w #$FFFF : INC A
        
        BRA .beta
    
    .external_1
    
        REP #$20
        
        LDA $B0
    
    .beta
    
        PHA
        
        LDA $1F03 : AND.w #$00FF : BEQ .gamma
        
        LDA $1F02 : AND.w #$00FF : LSR #5
    
    .gamma
    
        TAX
        
        PLA
    
    .shift
    
        ASL A
        
        DEX : BPL .shift
        
        SEP #$20
        
        XBA : BNE .delta
        
        LDA.b #$01
        
        BRA .epsilon
    
    .delta
    
        CMP.b #$08 : BCC .epsilon
        
        LDA.b #$07
    
    .epsilon
    
        JSL $09FCAE ; $4FCAE in ROM.
        
        RTS
    }

    ; $4FB24-$4FB6C
    {
        ; (set I and C flags)
        SEP #$05
        
        LDA $C3 : SBC $C1 : STA $211B
        
        LDA.b #$00 : SBC.b #$00 : STA $211B
        
        SEC : LDA $C6 : SBC $C4 : STA $211C
        
        ; apparently it's super important to keep the I flag low
        ; for as little time as possible.
        LDA $2134       : STA $B0
        LDA $2135 : CLI : STA $B1
        
        SEP #$05
        
        LDA $C5    : SBC $C3    : STA $211B
        LDA.b #$00 : SBC.b #$00 : STA $211B
        
        SEC : LDA $C4 : SBC $C2 : STA $211C
        
        REP #$20
        
        SEC : LDA $B0 : SBC $2134 : STA $B0
        
        SEP #$20
        CLI
        
        RTS
    }

    ; $4FB6D-$4FCAD DATA
    {
    
    ; $4FBAD
    }

    ; $4FCAE-$4FCC3 LONG
    {
        PHP
        
        SEP #$30
        
        ASL #2 : TAX
        
        REP #$20
        
        LDA $09FCC4, X : STA $B5
        LDA $09FCC6, X : STA $B7
        
        PLP
        
        RTL
    }

    ; $4FCC4-$4FD03 DATA
    {
        ; Masks for different bitplanes (0 - 3)?
        dd $00000000
        dd $000000FF
        dd $0000FF00
        dd $0000FFFF
        dd $00FF0000
        dd $00FF00FF
        dd $00FFFF00
        dd $00FFFFFF
        dd $FF000000
        dd $FF0000FF
        dd $FF00FF00
        dd $FF00FFFF
        dd $FFFF0000
        dd $FFFF00FF
        dd $FFFFFF00
        dd $FFFFFFFF
    }

    ; $4FD04-$4FD1D LONG
    {
        PHP : PHB
        
        REP #$30
        
        LDA.w #$0000 : STA $7EE800
        
        LDX.w #$E800
        LDY.w #$E802
        LDA.w #$07FD
        
        MVN $7E7E
        
        PLB : PLP
        
        RTL
    }

    ; $4FD1E-$4FDCE LONG
    {
        PHP : PHB
        
        SEP #$30
        
        LDA.b #$7E : PHA : PLB
        
        LDY $C0 : TYX
        
        LDA $C0, X
    
    .alpha
    
        DEX #2 : BEQ .beta
        
        ; (<= comparison)
        CMP $C0, X : BCC .alpha : BEQ .alpha
        
        TXY
        
        LDA $C0, X
        
        BRA .alpha
    
    .beta
    
        AND.b #$07 : ASL A : STA $B9
        
        LDA $1FC0, Y : AND.b #$38 : BIT.b #$20 : BEQ .gamma
        
        EOR.b #$24
    
    .gamma
    
        LSR #2 : ADC.b #$E8 : STA $BA
        
        STY $E9 : STY $F2
        
        LDA $C0 : LSR A : STA $E0
        
        LDA $1FC0, Y : STA $E2 : STA $EB
        LDA $1FBF, Y : STA $E1 : STA $EA
        
        JSR $FEB4 : BCS .delta
        JSR $FF1E : BCC .epsilon
    
    .delta
    
        PLB : PLP
        
        RTL
    
    .epsilon
    
        JSR $FDCF ; $4FDCF in Rom.
        
        LDA $B9 : INC #2 : CMP.b #$10 : BEQ .zeta
        
        STA $B9
        
        BRA .iota
    
    .zeta
    
        LDA $BA : INC #2 : BIT.b #$08 : BNE .theta
        
        EOR.b #$19
    
    .theta
    
        STA $BA : STZ $B9
    
    .iota
    
        LDX $E2 : CPX $E4 : BNE .kappa
        
        LDX $E3 : STX $E1
        
        JSR $FEB4 : BCS .delta
        
        LDX $E2
    
    .kappa
    
        INX : STX $E2
        
        LDX $EB : CPX $ED : BNE .lambda
        
        LDX $EC : STX $EA
        
        JSR $FF1E : BCS .delta
        
        LDX $EB
    
    .lambda
    
        INX : STX $EB
        
        REP #$21
        
              LDA $E5 : ADC $E7 : STA $E5
        CLC : LDA $EE : ADC $F0 : STA $EE
        
        SEP #$20
        
        BRA .epsilon
    
    .unused_code
    
        PLB : PLP
        
        RTL
    }

    ; $4FDCF-$4FE93 LOCAL
    {
        LDA $E6 : AND.b #$07 : ASL A : TAY
        
        LDA $EF : AND.b #$07 : ASL A : TAX
        
        LDA $E6 : AND.b #$38 : STA $BC
        
        LDA $EF : AND.b #$38 : SUB $BC : BNE .alpha
        
        REP #$30
        
        LDA $09FEA4, X : TYX : AND $09FE94, X : STA $B2
        
        LDA $EF : AND.w #$0038 : ASL #2 : ORA $B9 : TAY
        
        LDA $B5 : EOR $0000, Y : AND $B2 : EOR $0000, Y : STA $0000, Y
        LDA $B7 : EOR $0010, Y : AND $B2 : EOR $0010, Y : STA $0010, Y
    
    .return
    
        SEP #$30
        
        RTS
    
    .alpha
    
        BCC .return
        
        LSR #3 : STA $FA : STZ $FB
        
        REP #$30
        
        LDA $09FEA4, X : STA $B2
        
        TYX
        
        LDA $EF : AND.w #$0038 : ASL #2 : ORA $B9 : TAY
        
        LDA $B5 : EOR $0000, Y : AND $B2 : EOR $0000, Y : STA $0000, Y
        LDA $B7 : EOR $0010, Y : AND $B2 : EOR $0010, Y : STA $0010, Y
        
        SEC : TYA : SBC.w #$0020 : TAY
        
        DEC $FA : BEQ .beta
    
    .gamma
    
        LDA $B5 : STA $0000, Y
        LDA $B7 : STA $0010, Y
        
        TYA : SBC.w #$0020 : TAY
        
        DEC $FA : BNE .gamma
    
    .beta
    
        LDA $09FE94, X : STA $B2
        
        LDA $B5 : EOR $0000, Y : AND $B2 : EOR $0000, Y : STA $0000, Y
        LDA $B7 : EOR $0010, Y : AND $B2 : EOR $0010, Y : STA $0010, Y
        
        SEP #$30
        
        RTS
    }

    ; $4FE94-$4FEB3 DATA
    {
        dw $FFFF, $7F7F, $3F3F, $1F1F, $0F0F, $0707, $0303, $0101
        
    ; $4FEA4
        
        dw $8080, $C0C0, $E0E0, $F0F0, $F8F8, $FCFC, $FEFE, $FFFF
    }

    ; $4FEB4-$4FF1D LOCAL
    {
    
    .loop
    
        DEC $E0 : BPL .alpha
    
    .gamma
    
        SEC
        
        RTS
        
    .alpha
    
        LDX $E9 : DEX #2 : BNE .beta
        
        LDX $C0
        
    .beta
    
        STA $C0, X : CMP $E2 : BCC .gamma : BNE .delta
        
        LDA $BF, X : STA $E1
        
        STX $E9
        
        BRA .loop
    
    .delta
    
        STA $E4
        
        LDA $BF, X : STA $E3
        
        STX $E9
        
        LDX.b #$00
        
        SBC $E1 : BCS .epsilon
        
        DEX
        
        EOR.b #$FF : INC A
    
    .epsilon
    
        SEI
        
                     STA $004205
        LDA.b #$00 : STA $004204
        
        SEC : LDA $E4 : SBC $E2 : STA $004206
        
        REP #$20
        
        LDA $E0 : AND.w #$FF00 : ORA.w #$0080 : STA $E5
        
        LDA.w #$0000
        
        CPX.b #$00 : BNE .zeta
        
        LDA $004214
        
        BRA .theta
    
    .zeta
    
        SUB $004214
    
    .theta
    
        CLI
        
        STA $E7
        
        SEP #$20
        
        CLC
        
        RTS
    }

    ; $4FF1E-$4FF8B LOCAL
    {
    
    .loop
    
        DEC $E0 : BPL .alpha
    
    .delta
    
        SEC
        
        RTS
    
    .alpha
    
        LDX $F2 : CPX $C0 : BNE .beta
        
        LDX.b #$02
        
        BRA .gamma
    
    .beta
    
        INX #2
    
    .gamma
    
        LDA $C0, X : CMP $EB : BCC .delta : BNE .epsilon
        
        LDA $BF, X : STA $EA
        
        STX $F2
        
        BRA .loop
    
    .epsilon
    
        STA $ED
        
        LDA $BF, X : STA $EC
        
        STX $F2
        
        LDX.b #$00
        
        SUB $EA : BCS .zeta
        
        DEX
        
        EOR.b #$FF : INC A
    
    .zeta
    
        SEI
        
                     STA $004205
        LDA.b #$00 : STA $004204
        
        SEC : LDA $ED : SBC $EB : STA $004206
        
        REP #$20
        
        LDA $E9 : AND.w #$FF00 : ORA #$0080 : STA $EE
        
        LDA.w #$0000
        
        CPX.b #$00 : BNE .theta
        
        LDA $004214
        
        BRA .iota
    
    .theta
    
        SUB $004214
    
    .iota
    
        CLI
        
        STA $F0
        
        SEP #$20
        
        CLC
        
        RTS
    }

    ; $4FF8C-$4FF97 DATA (rest is not mapped)
    {
        ; \task Figure out where this array really ends. Does it cross
        ; bank boundaries?
        db $06, $08
        dw $FF98
        dw $FFAA
        
        db $06, $05
        dw $FFD2
        dw $FFE4
    }

