
; ==============================================================================

    ; $438F4-$43AAF DATA
    pool Ancilla_MagicPowder:
    {
    
    .animation_groups
        db 13, 14, 15,  0,  1,  2,  3,  4,  5,  6
        db 10, 11, 12,  0,  1,  2,  3,  4,  5,  6
        db 16, 17, 18,  0,  1,  2,  3,  4,  5,  6
        db  7,  8,  9,  0,  1,  2,  3,  4,  5,  6
    
    .animation_group_offsets
        db 0, 10, 20, 30
    
    .y_offsets
        dw -20, -15, -13,  -7
        dw -18, -13, -13, -13
        dw -20, -13, -13,  -8
        dw -20, -13, -13,  -8
        dw -19, -12, -12,  -7
        dw -18, -11, -11,  -6
        dw -17, -10, -10,  -5
        dw -16, -14, -12,  -9
        dw -17, -14, -12,  -8
        dw -18, -14, -13,  -6
        dw -33, -31, -29, -26
        dw -28, -25, -23, -19
        dw -22, -18, -17, -10
        dw  -2,   0,   2,   5
        dw  -9,  -6,  -4,   0
        dw -16, -12, -11,  -4
        dw -16, -14, -12,  -9
        dw -17, -14, -12,  -8
        dw -18, -14, -13,  -6
    
    .x_offsets
        dw  -5, -12,   2,  -9
        dw  -7, -10,  -6,  -2
        dw  -6, -12,   1,  -6
        dw  -6, -12,   1,  -6
        dw  -6, -12,   1,  -6
        dw  -6, -12,   1,  -6
        dw  -6, -12,   1,  -6
        dw -17, -23, -14, -19
        dw -11, -18,  -9, -13
        dw  -4, -13,  -1,  -8
        dw  -3,  -9,   0,  -5
        dw  -3, -10,  -1,  -5
        dw  -4, -13,  -1,  -8
        dw  -3,  -9,   0,  -5
        dw  -3, -10,  -1,  -5
        dw  -3, -13,  -1,  -8
        dw   9,  15,   6,  11
        dw   3,  10,   1,   5
        dw  -4,   5,  -7,   0
    
    .chr
        db $09, $0A, $0A, $09
        db $09, $09, $09, $09
        db $09, $09, $09, $09
        db $09, $09, $09, $09
        db $09, $09, $09, $09
    
    .properties
        db $68, $24, $A2, $28
        db $68, $E2, $28, $A4
        db $68, $E2, $A4, $28
        db $22, $A4, $E8, $62
        db $24, $A8, $E2, $64
        db $28, $A2, $E4, $68
        db $22, $A4, $E8, $62
        db $E2, $A4, $E8, $64
        db $E8, $A8, $E4, $62
        db $E4, $A8, $E2, $68
        db $E2, $A4, $E8, $64
        db $E8, $A8, $E4, $62
        db $E4, $A8, $E2, $68
        db $E2, $A4, $E8, $64
        db $E8, $A8, $E4, $62
        db $E4, $A8, $E2, $68
        db $E2, $A4, $E8, $64
        db $E8, $A8, $E4, $62
        db $E4, $A8, $E2, $68
    }

; ==============================================================================

    ; *$43AB0-$43B57 JUMP LOCATION
    Ancilla_MagicPowder:
    {
        LDA $11 : BNE .just_draw
        
        JSR MagicPowder_ApplySpriteDamage
        
        DEC $03B1, X : BPL .just_draw
        
        LDA.b #$01 : STA $03B1, X
        
        LDY $0C72, X
        
        LDA .animation_group_offsets, Y : STA $00
        
        LDA $0C5E, X : INC A : CMP.b #$0A : BNE .dont_self_terminate
        
        STZ $0C4A, X
        
        STZ $0333
        
        RTS
    
    .dont_self_terminate
    
        STA $0C5E, X
        
        ADD $00 : TAY
        
        LDA .animation_groups, Y : STA $03C2, X
    
    .just_draw
    
        LDA $0C90, X : JSR Ancilla_AllocateOam_B_or_E
    
    ; *$43AEB ALTERNATE ENTRY POINT
    shared MagicPowder_Draw:
    
        JSR Ancilla_PrepOamCoord
        
        PHX
        
        LDA $00 : STA $06
        LDA $01 : STA $07
        
        LDA $02 : STA $08
        LDA $03 : STA $09
        
        LDA $03C2, X : STA $0C
        
        ASL #2 : STA $0A
        
        ASL A : STA $04
        
        ; Committing 4 sprite entries.
        ; \optimize use direct page instead.
        LDA.b #$03 : STA $0072
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDX $04
        
        REP #$20
        
        LDA $06 : ADD .y_offsets, X : STA $00
        LDA $08 : ADD .x_offsets, X : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDX $0C
        
        LDA .chr, X : STA ($90), Y : INY
        
        LDX $0A
        
        ; \bug(maybe) Is it possible that the game will read past the end of
        ; this array into the proceeding code?
        LDA .properties, X : AND.b #$CF : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
        
        INC $04 : INC $04
        
        INC $0A
        
        DEC $72 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$43B58-$43BBB LOCAL
    MagicPowder_ApplySpriteDamage:
    {
        LDY.b #$0F
    
    .next_sprite
    
        TYA : EOR $1A : AND.b #$03 : BNE .no_collision
        
        LDA $0DD0, Y : CMP.b #$09 : BNE .no_collision
        
        LDA $0CD2, Y : AND.b #$20 : BNE .no_collision
        
        JSR Ancilla_SetupBasicHitBox
        
        PHY : PHX
        
        TYX
        
        JSL Sprite_SetupHitBoxLong
        
        PLX : PLY
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .no_collision
        
        LDA $0E20, Y : CMP.b #$0B : BNE .not_transformable_chicken
        
        LDA $1B : BEQ .not_transformable_chicken
        
        LDA $048E : DEC A : BNE .not_transformable_chicken

        BRA .transformable_sprite
    
    .not_transformable_chicken
    
        CMP.b #$0D : BNE .not_buzzblob
        
        LDA $0EB0, Y : BNE .no_collision
    
    .transformable_sprite
    
        LDA.b #$01 : STA $0EB0, Y
        
        PHX : PHY
        
        TYX
        
        JSL Sprite_SpawnPoofGarnish
        
        PLY : PLX
        
        BRA .no_collision
    
    .not_buzzblob
    
        PHX : PHY
        
        TYX
        
        ; Check damage from magic powder to general sprites (not specifically
        ; transformable like chickens or buzzblobs).
        LDA.b #$0A : JSL Ancilla_CheckSpriteDamage.preset_class
        
        PLY : PLX
    
    .no_collision
    
        DEY : BPL .next_sprite
        
        RTS
    }

; ==============================================================================
