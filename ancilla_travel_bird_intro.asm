
; ==============================================================================

    ; $451D4-$451D7 DATA
    pool Ancilla_TravelBirdIntro:
    {
    
    .hflip_settings
        db $40, $00
    
    ; \note These are sensitively calibrated values that can look funky or
    ; keep the bird on screen indefinitely if set to other values.
    .swirl_speeds
        db $1c, $3C
    }

; ==============================================================================

    ; *$451D8-$45379 JUMP LOCATION
    Ancilla_TravelBirdIntro:
    {
        ; Check the frame index.
        LDA $1A : AND.b #$1F : BNE .no_flutter_sfx
        
        LDA.b #$1E : JSR Ancilla_DoSfx3
    
    .no_flutter_sfx
    
        DEC $039F, X : BPL .flap_delay
        
        LDA.b #$03 : STA $039F, X
        
        ; Controls the flapping of the wings. (The two sprite graphic states.)
        ; Toggle it, basically.
        LDA $0380, X : EOR.b #$01 : STA $0380, X
    
    .flap_delay
    
        DEC $03B1, X : LDA $03B1, X : BEQ .movement_logic
        
        BRL .update_position_draw
    
    .movement_logic
    
        LDA.b #$01 : STA $03B1, X
        
        LDA $0385, X : BNE .swirling_logic
        
        DEC $0C5E, X : BMI .init_swirling_logic
        
        LDY.b #$FF
        
        LDA $0C54, X : BEQ .accelerate_descent
        
        ; (In this case, accelerate ascent)
        LDY.b #$01
    
    .accelerate_descent
    
        TYA : ADD $0294, X : STA $0294, X : BPL .abs_z_speed
        
        ; Get abs(z speed) so we can check whether to reverse the float
        ; polarity.
        EOR.b #$FF : INC A
    
    .abs_z_speed
    
        CMP.b #$0C : BCC .dont_flip_float_polarity
        
        LDA $0C54, X : EOR.b #$01 : STA $0C54, X
    
    .dont_flip_float_polarity
    
        BRL .update_position_and_draw
    
    .init_swirling_logic
    
        STZ $0C5E, X
        
        STZ $0C54, X
        
        ; Move to the right
        LDA .swirl_speeds : STA $0C2C, X
        
        ; Begin falling.
        LDA.b #$F0 : STA $0294, X
        
        ; Indicate that swirling logic has begun.
        INC $0385, X
        
        LDA.b #$03 : STA $0C54, X
    
    .swirling_logic
    
        LDY.b #$FF
        
        LDA $0C54, X : AND.b #$01 : BNE .accelerate_left
        
        ; (Or accelerate right in this case)
        LDY.b #$01
    
    .accelerate_left
    
        TYA : ADD $0C2C, X : STA $0C2C, X : BPL .abs_x_speed
        
        EOR.b #$FF : INC A
    
    .abs_x_speed
    
        CMP.b #$00 : BNE .not_x_speed_inflection
        
        INC $0385, X : LDY $0385, X : CPY.b #$07 : BNE .swirl_cycles_not_maxed
        
        PHA
        
        LDA.b #$01 : STA $03A9, X
        
        PLA
    
    .not_x_speed_inflection
    .swirl_cycles_not_maxed
    
        LDY $03A9, X
        
        CMP .swirl_speeds, Y : BCC .x_speed_not_maxed
        
        ; \wtf(confirmed) Um, you know you could just fucking xor with 0x03
        ; directly, then store it back and you'd do it in 3 instructions instead
        ; of 8?
        ; \optimize See above. (lda addr : eor.b #constant : sta addr)
        LDA $0C54, X : AND.b #$03 : EOR.b #$03 : STA $00
        
        LDA $0C54, X : AND.b #$FC : ORA $00 : STA $0C54, X
    
    .x_speed_not_maxed
    
        LDY.b #$03
        
        LDA $0C2C, X : BPL .abs_x_speed_2
        
        EOR.b #$FF : INC A
        
        LDY.b #$02
    
    .abs_x_speed_2
    
        STA $00
        
        ; Set the direction the bird is facing.
        TYA : STA $0C72, X
        
        LDY $03A9, X
        
        ; \note Seems that the actual z speed determined is actually affected
        ; by the current x speed. Perhaps that's where this ellipsoid behavior
        ; originates from.
        LDA .swirl_speeds, Y : SUB $00 : LSR A : STA $00
        
        LDA $0C54, X : AND.b #$02 : BEQ .lowering
        
        ; (Or rising, in this case.)
        LDA $00 : EOR.b #$FF : INC A : STA $00
    
    .lowering
    
        LDA $00 : STA $0294, X
    
    .update_position_and_draw
    
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveAltitude
        
        LDY $0380, X
        
        ; Indicate which chr to transfer to vram for the travel bird. There are
        ; only two states, but this is updated every frame.
        LDA $DDE5, Y : STA $0AF4
        
        JSR Ancilla_PrepOamCoord
        
        LDA $0C72, X : AND.b #$01 : TAY
        
        LDA .hflip_settings, Y : STA $08
        
        REP #$20
        
        LDA $029E, X : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_z_coord
        
        ORA.w #$FF00
    
    .sign_ext_z_coord
    
        EOR.w #$FFFF : INC A : STA $04
        
        LDA $00 : STA $0A
        SUB $04 : STA $04
        
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDY.b #$00
        
        REP #$20
        
        ; Check up on this to work on the bird (Paul)
        LDA $DDDE : AND.w #$00FF : ADD $04 : STA $00
        LDA $DDE1 : AND.w #$00FF : ADD $06 : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA $DDD8                        : STA ($90), Y : INY
        LDA $DDDB : ORA.b #$30 : ORA $08 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY
        
        REP #$20
        
        LDA $0A : ADD.w #$0030 : STA $00
        
        LDA $06 : STA $02
        
        SEP #$20
        
        LDA.b #$30 : STA $04
        
        LDX.b #$01 : JSR Ancilla_DrawShadow
        
        PLX
        
        REP #$20
        
        LDA $06      : BMI .bird_on_screen_x
        CMP.w #$00F8 : BCC .bird_on_screen_x
        
        SEP #$20
        
        ; self terminate.
        STZ $0C4A, X
        
        ; Return to normal mode.
        STZ $11
        
        ; Give player the Flute 3 item.
        LDA.b #$03 : STA $7EF34C
    
    .bird_on_screen_x
    
        SEP #$20
        
        RTS
    }

; ==============================================================================
