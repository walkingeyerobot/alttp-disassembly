
; ==============================================================================

    ; $42121-$42130 DATA
    pool Ancilla_Arrow:
    {
    
    .y_offsets
        dw -4,  2,  0,  0
    
    .x_offsets
        dw  0,  0, -4,  4
    }

; ==============================================================================

    ; *$42131-$4224D JUMP LOCATION
    Ancilla_Arrow:
    {
        LDA $11 : BEQ .normal_submode
        
        BRL .just_draw
    
    .normal_submode
    
        DEC $0C5E, X : LDA $0C5E, X : BMI .timer_elapsed
                       CMP.b #$04   : BCC .begin_moving
        
        ; The object doesn't even start being drawn until this timer counts
        ; down.
        BRL .do_nothing
    
    .timer_elapsed
    
        LDA.b #$FF : STA $0C5E, X
    
    .begin_moving
    
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        LDA $7EF340 : AND.b #$04 : BEQ .dont_spawn_sparkle
        
        LDA $1A : AND.b #$01 : BNE .dont_spawn_sparkle
        
        PHX
        
        JSL AddSilverArrowSparkle
        
        PLX
    
    .dont_spawn_sparkle
    
        LDA.b #$FF : STA $03A9, X
        
        JSR Ancilla_CheckSpriteCollision : BCS .sprite_collision
        
        JSR Ancilla_CheckTileCollision : BCS .tile_collision
        
        BRL .draw
    
    .tile_collision
    
        TYA : STA $03C5, X
        
        LDA $0C72, X : AND.b #$03 : ASL A : TAY
        
        LDA .y_offsets+0, Y : ADD $0BFA, X : STA $0BFA, X
        LDA .y_offsets+1, Y : ADC $0C0E, X : STA $0C0E, X
        
        LDA .x_offsets+0, Y : ADD $0C04, X : STA $0C04, X
        LDA .x_offsets+1, Y : ADC $0C18, X : STA $0C18, X
        
        STZ $0B88
        
        BRA .transmute_to_halted_arrow
    
    .sprite_collision
    
        LDA $0C04, X : SUB $0D10, Y : STA $0C2C, X
        
        LDA $0BFA, X : SUB $0D00, Y : ADD $0F70, Y : STA $0C22, X
        
        TYA : STA $03A9, X
        
        LDA $0E20, Y : CMP.b #$65 : BNE .not_archery_game_sprite
        
        LDA $0D90, Y : CMP.b #$01 : BNE .not_archery_target_mop
        
        LDA.b #$2D : STA $012F
        
        ; Set a delay for the archery game proprietor and set a timer for the 
        ; target that was hit (indicating it was hit)
        LDA.b #$80 : STA $0E10, Y : STA $0F10
        
        ; \tcrf In conjunction with the ArcheryGameGuy sprite code, this is
        ; another lead the suggested that there were 9 game prize values
        ; instead of just the normal 5.
        LDA $0B88 : CMP.b #$09 : BCS .prize_index_maxed_out
        
        INC $0B88
    
    .prize_index_maxed_out
    
        LDA $0B88 : STA $0DA0, Y
        
        LDA $0ED0, Y : INC A : STA $0ED0, Y
        
        BRA .transmute_to_halted_arrow
    
    .not_archery_target_mop
    
        LDA.b #$04 : STA $0EE0, Y
    
    .not_archery_game_sprite
    
        STZ $0B88
    
    .transmute_to_halted_arrow
    
        LDA $0E20, Y : CMP.b #$1B : BEQ .hit_enemy_arrow_no_sfx
        
        LDA.b #$08 : JSR Ancilla_DoSfx2
    
    .hit_enemy_arrow_no_sfx
    
        STZ $0C5E, X
        
        LDA.b #$0A : STA $0C4A, X
        LDA.b #$01 : STA $03B1, X
        
        LDA $03C5, X : BEQ .draw
        
        REP #$20
        
        LDA $E0 : SUB $E2 : ADD $0C04, X : STA $00
        LDA $E6 : SUB $E8 : ADD $0BFA, X : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0C04, X
        LDA $02 : STA $0BFA, X
        
        BRA .draw
    
    .do_nothing
    
        RTS
    
    .draw
    
        BRL Arrow_Draw
    }

; ==============================================================================

    ; $4224E-$4236D DATA
    pool Arrow_Draw:
    {
    
    .chr_and_properties
        db $2B, $A4
        db $2A, $A4
        db $2A, $24
        db $2B, $24
        db $3D, $64
        db $3A, $64
        db $3A, $24
        db $3D, $24
        db $2B, $A4
        db $FF, $FF
        db $2B, $24
        db $FF, $FF
        db $3D, $64
        db $FF, $FF
        db $3D, $24
        db $FF, $FF
        db $3C, $A4
        db $2C, $A4
        db $3C, $A4
        db $2A, $A4
        db $3C, $A4
        db $2C, $E4
        db $3C, $A4
        db $2A, $A4
        db $2C, $24
        db $3C, $24
        db $2A, $24
        db $3C, $24
        db $2C, $64
        db $3C, $24
        db $2A, $24
        db $3C, $24
        db $3B, $64
        db $2D, $64
        db $3B, $64
        db $3A, $E4
        db $3B, $64
        db $2D, $E4
        db $3B, $64
        db $3A, $E4
        db $2D, $24
        db $3B, $24
        db $3A, $24
        db $3B, $A4
        db $2D, $A4
        db $3B, $24
        db $3A, $24
        db $3B, $A4
    
    .xy_offsets
        dw  0,  0
        dw  8,  0
        dw  0,  0
        dw  8,  0
        dw  0,  0
        dw  0,  8
        dw  0,  0
        dw  0,  8
        dw  0,  0
        dw  0,  0
        dw  0,  0
        dw  0,  0
        dw  0,  0
        dw  0,  0
        dw  0,  0
        dw  0,  0
        dw  0,  1
        dw  8,  1
        dw  0,  0
        dw  8,  0
        dw  0, -1
        dw  8, -2
        dw  0,  0
        dw  8,  0
        dw  0,  1
        dw  8,  1
        dw  0,  0
        dw  8,  0
        dw  0, -2
        dw  8, -1
        dw  0,  0
        dw  8,  0
        dw -1,  0
        dw -1,  8
        dw  0,  0
        dw  0,  8
        dw  0,  0
        dw  1,  8
        dw  0,  0
        dw  0,  8
        dw -1,  0
        dw -1,  8
        dw  0,  0
        dw  0,  8
        dw  1,  0
        dw  0,  8
        dw  0,  0
        dw  0,  8
    }

; ==============================================================================

    ; *$4236E-$4245A LONG BRANCH LOCATION
    Arrow_Draw:
    {
        JSR Ancilla_PrepAdjustedOamCoord
        
        LDA $0280, X : BEQ .normal_priority
        
        LDA.b #$30 : STA $65
    
    .normal_priority
    
        REP #$20
        
        LDA $00 : STA $0C
        LDA $02 : STA $0E : STA $04
        
        LDA $03C5, X : AND.w #$00FF : BEQ .basic_collision
        
        ; Seems like this does special handling for more complex collision
        ; modes.
        LDA $E8 : SUB $E6 : ADD $0C : STA $0C
        LDA $E2 : SUB $E0 : ADD $0E : STA $0E : STA $04
    
    .basic_collision
    
        SEP #$20
        
        LDA $0C5E, X : STA $07
        
        LDA $0C72, X : AND.b #$FB : TAY
        
        LDA $0C4A, X : CMP.b #$0A : BNE .not_halted_arrow
        
        LDA $0C5E, X : AND.b #$08 : BEQ .use_wiggling_frames
        
        ; During this frame draw as a straight arrow
        LDA.b #$01
        
        BRA .chr_index_determined
    
    .use_wiggling_frames
    
        LDA $0C5E, X : AND.b #$03
    
    .chr_index_determined
    
        STA $0A
        
        TYA : ASL #2 : ADD.b #$08 : ADD $0A : TAY
        
        BRA .determine_palette
    
    .not_halted_arrow
    
        LDA $0C5E, X : BMI .determine_palette
        
        TYA : ORA.b #$04 : TAY
    
    .determine_palette
    
        PHX
        
        TYA : ASL #2 : TAX
        
        LDY.b #$02
        
        ; Use different palette for silver arrow.
        LDA $7EF340 : AND.b #$04 : BNE .use_silver_palette
        
        LDY.b #$04
    
    .use_silver_palette
    
        STY $74
        
        LDY.b #$00
        
        STZ $06
    
    .next_oam_entry
    
        LDA .chr_and_properties, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        STA $72
        
        PHX : TXA : ASL A : TAX
        
        REP #$20
        
        ; First of each interleaved pair is the y offset, and the second
        ; is the x offset.
        LDA .xy_offsets+0, X : ADD $0C : STA $00
        LDA .xy_offsets+2, X : ADD $0E : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        PLX
        
        LDA $72 : STA ($90), Y : INY
        
        LDA .chr_and_properties+1, X : AND.b #$C1
        
        ORA $74 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX #2
        
        INC $06 : LDA $06 : CMP.b #$02 : BEQ .finished_drawing
        
        BRL .next_oam_entry
    
    .finished_drawing
    
        PLX
        
        LDY.b #$01 : LDA ($90), Y : CMP.b #$F0 : BNE .on_screen
        
        LDY.b #$05 : LDA ($90), Y : CMP.b #$F0 : BNE .on_screen
        
        BRL Ancilla_HaltedArrow.self_terminate
    
    .on_screen
    
        RTS
    }

; ==============================================================================
