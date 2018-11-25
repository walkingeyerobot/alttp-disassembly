
; ==============================================================================

    ; $46C77-$46CAE DATA
    pool Ancilla_WaterfallSplash:
    {
    
    .chr
        db $C0, $FF, $AC, $AC, $AE, $AE, $BF, $BF
    
    .properties
        db $84, $FF, $84, $C4, $84, $C4, $84, $C4
    
    .oam_sizes
        db $02, $FF, $02, $02, $02, $02, $00, $00
    
    .y_offsets_low
        db -4,  0, -5, -5, -3, -3, 12, 12
    
    .y_offsets_high
        db -1,  0, -1, -1, -1, -1,  0,  0
    
    .x_offsets_low
        db  0,  0, -4,  4, -7,  7, -9, 17
    
    .x_offsets_high
        db  0,  0, -1,  0, -1,  0, -1,  0
    }

; ==============================================================================

    ; *$46CAF-$46D88 JUMP LOCATION
    Ancilla_WaterfallSplash:
    {
        ; Waterfall splash (special object 0x41)
        
        ; Waterfall in the swamp palace
        LDY.b #$00
        
        LDA $1B : BNE .indoors
        
        ; Waterfall of wishing entrance. There are no other doors / entrances
        ; under falling water in the game.
        LDY.b #$01
    
    .indoors
    
        JSR Ancilla_CheckIfEntranceTriggered : BCS .do_splash_sequence
        
        STZ $0C4A, X
        
        RTS
    
    .do_splash_sequence
    
        LDA $11 : BNE .no_sound_effect
        
        LDA $1A : AND.b #$07 : BNE .no_sound_effect
        
        LDA.b #$1C : JSR Ancilla_DoSfx2_NearPlayer
    
    .no_sound_effect
    
        LDA.b #$01 : STA $0351
        
        ; \wtf .... why would this be necessary?
        LDA $2E : SUB.b #$06 : BMI .dont_reset_player_animation
        
        STA $2E
    
    .dont_reset_player_animation
    
        LDA $0C68, X : BNE .animation_delay
        
        LDA.b #$02 : STA $0C68, X
        
        LDA $0C5E, X : INC A : AND.b #$03 : STA $0C5E, X
    
    .animation_delay
    
        LDA $1B : BEQ .set_y_coord
        
        LDA $20 : CMP.b #$38 : BCS .set_y_coord
        
        LDA.b #$38 : STA $0BFA, X
        LDA.b #$0D : STA $0C0E, X
        
        BRA .set_x_coord
    
    .set_y_coord
    
        LDA $20 : STA $0BFA, X
        LDA $21 : STA $0C0E, X
    
    .set_x_coord
    
        LDA $22 : STA $0C04, X
        LDA $23 : STA $0C18, X
        
        JSR Ancilla_PrepAdjustedOamCoord
        
        LDA $24 : BPL .positive_z_player_coord
        
        LDA.b #$00
    
    .positive_z_player_coord
    
        REP #$20
        
        AND.w #$00FF : EOR.w #$FFFF : INC A : ADD $00 : STA $00 : STA $06
        
        SEP #$20
        
        LDA $0C5E, X : ASL A : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        LDA .y_offsets_low,  X : ADD $06 : STA $00
        LDA .y_offsets_high, X : ADC $07 : STA $01
        
        LDA .x_offsets_low,  X : ADD $04 : STA $02
        LDA .x_offsets_high, X : ADC $05 : STA $03
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                     : STA ($90), Y : INY
        LDA .properties, X : ORA.b #$30 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA .oam_sizes, X : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX : TXA : AND.b #$01 : BNE .next_oam_entry
        
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================
