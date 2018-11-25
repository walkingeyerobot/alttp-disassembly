
; ==============================================================================

    ; $458F6-$458FC DATA
    pool Ancilla_SpinSpark:
    {
    
    .spark_chr
        db $D7, $B7, $80, $83
    
    .extra_spark_chr
        db $B7, $80, $83
    }

; ==============================================================================

    ; *$458FD-$45A16 JUMP LOCATION
    Ancilla_SpinSpark:
    {
        LDA $0385, X : BEQ .multi_spark_in_progress
        
        BRL SpinSpark_ExecuteClosingSpark
    
    .multi_spark_in_progress
    
        PHX
        
        ; Normally use palette 1 for the sparks.
        LDA.b #$02 : STA $73
        
        LDA $11 : BNE .skip_state_logic
        
        ; By default, only draw the lead spark.
        LDY.b #$00
        
        LDA $0C5E, X : SUB.b #$03 : STA $0C5E, X
        
        CMP.b #$0D : BCS .dont_transition_to_closing_spark
        
        PLX
        
        LDA.b #$01 : STA $03B1, X
                     STA $0385, X
        
        STZ $0C5E, X
        
        BRL SpinSpark_ExecuteClosingSpark
    
    .dont_transition_to_closing_spark
    
        CMP.b #$42 : BCS .dont_draw_four_sparks
        
        ; Display 4 spark components.
        LDY.b #$03
        
        BRA .set_spark_draw_count
    
    .dont_draw_four_sparks
    
        CMP.b #$46 : BNE .dont_draw_two_sparks
        
        ; Display two spark components.
        LDY.b #$01
    
    .dont_draw_two_sparks
    
        CMP.b #$43 : BNE .dont_draw_three_sparks
        
        LDY.b #$02
    
    .dont_draw_three_sparks
    .set_spark_draw_count
    
        TYA : STA $0C54, X
        
        DEC $03B1, X : BPL .not_alternate_palette
        
        ; Use palette 2 for the sparks on this frame.
        LDA.b #$04 : STA $73
        
        LDA.b #$02 : STA $03B1, X
    
    .skip_state_logic
    .not_alternate_palette
    
        LDY.b #$00
        
        LDA $0C54, X : TAX
    
    .next_spark
    
        STX $72
        
        LDA $11 : BNE .dont_advance_spark_rotation
        
        LDA $7F5800, X : ADD.b #$04 : AND.b #$3F : STA $7F5800, X
    
    .dont_advance_spark_rotation
    
        PHX : PHY
        
        LDA $7F5808 : STA $08
        
        LDA $7F5800, X
        
        JSR Ancilla_GetRadialProjection
        JSL Sparkle_PrepOamCoordsFromRadialProjection
        
        PLY
        
        JSR Ancilla_SetOam_XY
        
        LDX $72
        
        LDA .spark_chr, X           : STA ($90), Y : INY
        LDA $73           : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
        
        PLX : DEX : BPL .next_spark
        
        PLX : PHX
        
        LDA $11 : BNE .skip_extra_spark_logic
        
        DEC $039F, X : BPL .extra_spark_delay
        
        LDA.b #$00 : STA $039F, X
        
        LDA $03A4, X : INC A : AND.b #$03 : STA $03A4, X
        
        CMP.b #$03 : BNE .extra_spark_rotation_delay
        
        LDA $7F5804 : ADD.b #$09 : AND.b #$3F : STA $7F5804
    
    .skip_extra_spark_logic
    .extra_spark_rotation_delay
    
        LDA $03A4, X : STA $72 : CMP.b #$03 : BEQ .anodraw_extra_spark
        
        PHY
        
        LDA $7F5808 : STA $08
        
        LDA $7F5804
        
        JSR Ancilla_GetRadialProjection
        JSL Sparkle_PrepOamCoordsFromRadialProjection
        
        PLY
        
        JSR Ancilla_SetOam_XY
        
        LDX $72
        
        LDA .extra_spark_chr, X           : STA ($90), Y : INY
        LDA.b #$04              : ORA $65 : STA ($90), Y : INY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
    
    .extra_spark_delay
    .anodraw_extra_spark
    
        PLX : PHX
        
        LDA $0C5E, X : TAX : CPX.b #$07 : BNE .never
        
        ; \wtf(confirmed that this never seems to execute)
        ; Possibly debug code or a dev dicking around that was never taken
        ; out.
        LDY.b #$03 : LDA.b #$01 : STA ($92), Y
    
    .never
    
        PLX
        
        RTS
    }

; ==============================================================================

    ; \note Takes the calculated radial projection and converts the values
    ; to screen relative coordinates (oam coordinates)
    ; *$45A17-$45A4B LONG
    Sparkle_PrepOamCoordsFromRadialProjection:
    {
        REP #$20
        
        LDA $00
        
        LDY $02 : BEQ .positive_y_projection
        
        EOR.w #$FFFF : INC A
    
    .positive_y_projection
    
        ADD $7F5810 : ADD.w #$FFFC : SUB $E8 : STA $00
        
        LDA $04
        
        LDY $06 : BEQ .positive_x_projection
        
        EOR.w #$FFFF : INC A
    
    .positive_x_projection
    
        ADD $7F580E : ADD.w #$FFFC : SUB $E2 : STA $02
        
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; *$45A4C-$45A83 LONG BRANCH LOCATION
    SpinSpark_ExecuteClosingSpark:
    {
        DEC $03B1, X : BPL .animation_delay
        
        LDA.b #$01 : STA $03B1, X
        
        LDA $0C5E, X : INC A : STA $0C5E, X
        
        CMP.b #$03 : BNE .termination_delay
        
        STZ $0C4A, X
    
    .animation_delay
    .termination_delay
    
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $06
        LDA $02 : STA $08
        
        SEP #$20
        
        PHX
        
        LDY.b #$00 : STY $04
        
        LDA $0C5E, X : ADD.b #$04 : ASL #2 : TAX
        
        BRL Ancilla_InitialSpinSpark.oam_commit_loop
    }

; ==============================================================================
