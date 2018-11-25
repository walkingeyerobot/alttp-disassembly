
; ==============================================================================

    ; *$34BA2-$34BD7 JUMP LOCATION
    Sprite_Leever:
    {
        LDA $0D80, X : BEQ .dont_draw
        
        JSR Leever_Draw
        
        BRA .respawn_logic
    
    .dont_draw
    
        JSR Sprite_PrepOamCoordSafeWrapper
    
    .respawn_logic
    
        LDA $0F00, X : BEQ .dont_respawn
        
        ; \task Find out if this ever executes. Would be interesting to know.
        LDA.b #$08 : STA $0DD0, X
    
    .dont_respawn
    
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        
        LDA $0D80, X : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        LDA .handlers, Y : PHA
        
        SEP #$30
        
        RTS
    
    ; \task Note that these are all the pointers minus one. Make sure
    ; to note that by adding "-1" to these. Maybe come up with a macro that
    ; expresses this? Probably would need to add more functionality to xkas for
    ; that.
    .handlers
        dw Leever_UnderSand-1
        dw Leever_Emerge-1
        dw Leever_AttackPlayer-1
        dw Leever_Submerge-1
    }

; ==============================================================================

    ; $34BD8-$34BF4 JUMP LOCATION
    Leever_UnderSand:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
        
        RTS
    
    .delay
    
        LDA.b #$10 : JSR Sprite_ApplySpeedTowardsPlayer
        
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        RTS
    }

; ==============================================================================

    ; \unused Almost certainly unused. Probably was for an earlier design
    ; where the Leever didn't go towards the player while it was submerged.
    ; I say this due to the large simlarity with the previous routine
    ; (Leever_UnderSand).
    ; $34BF5-$34C02 LOCAL
    {
        LDA $0DF0, X : BNE .delay
    
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
    
    .delay
    
        RTS
    }    

; ==============================================================================

    ; $34C03-$34C12 DATA
    pool Leever_Emerge:
    {
    
    .animation_states
        db 10,  9,  8,  7,  6,  5,  4,  3
        db  2,  1,  2,  1,  2,  1,  0,  0
    }

; ==============================================================================

    ; $34C13-$34C36 JUMP LOCATION
    Leever_Emerge:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$3F : ADC.b #$A0 : STA $0DF0, X
        
        JMP Sprite_Zero_XY_Velocity
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }    

; ==============================================================================

    ; $34C37-$34C3B DATA
    pool Leever_AttackPlayer:
    {
    
    .animation_states length 4
        db 9, 10, 11
    
    .speeds
        db 12, 8
    }

; ==============================================================================

    ; $34C3C-$34C79 JUMP LOCATION
    Leever_AttackPlayer:
    {
        JSR Sprite_CheckDamage
        
        LDA $0DF0, X : BNE .submersion_delay
    
    .tile_collision
    
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
        
        RTS
    
    .submersion_delay
    
        LDA $0E80, X : AND.b #$07 : BNE .tracking_delay
        
        LDY $0D90, X
        
        LDA .speeds, Y : JSR Sprite_ApplySpeedTowardsPlayer
    
    .tracking_delay
    
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BNE .tile_collision
        
        INC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$03 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $34C7A-$34C89 DATA
    pool Leever_Submerge:
    {
    
    .animation_states
        db 10,  9,  8,  7,  6,  5,  4,  3
        db  2,  1,  2,  1,  2,  1,  0,  0
    }

; ==============================================================================

    ; $34C8A-$34CAE JUMP LOCATION
    Leever_Submerge:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        STZ $0D80, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$40 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #3 : EOR.b #$0F : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    
    .unused
    
        RTS
    }

; ==============================================================================

    ; $34CAF-$34E44 DATA
    pool Leever_Draw:
    {
        ; \task fill in later.
        db  2,  0,  6,  0,  6,  0,  6,  0
        db  0,  0,  8,  0,  8,  0,  8,  0
        db  0,  0,  8,  0,  8,  0,  8,  0
        db  0,  0,  8,  0,  0,  0,  8,  0
        db  0,  0,  8,  0,  0,  0,  8,  0
        db  0,  0,  0,  0,  0,  0,  8,  0
        db  0,  0,  0,  0,  0,  0,  8,  0
        db  0,  0,  0,  0,  0,  0,  8,  0
        db  0,  0,  0,  0,  0,  0,  8,  0
        db  0,  0,  0,  0,  0,  0,  0,  0
        db  0,  0,  0,  0,  0,  0,  0,  0
        db  0,  0,  0,  0,  0,  0,  0,  0
        db  0,  0,  0,  0,  0,  0,  0,  0
        db  0,  0,  0,  0,  0,  0,  0,  0
        
        db  8,  0,  8,  0,  8,  0,  8,  0
        db  8,  0,  8,  0,  8,  0,  8,  0
        db  8,  0,  8,  0,  8,  0,  8,  0
        db  5,  0,  5,  0,  8,  0,  8,  0
        db  5,  0,  5,  0,  8,  0,  8,  0
        db  2,  0,  2,  0,  8,  0,  8,  0
        db  1,  0,  1,  0,  8,  0,  8,  0
        db  0,  0,  0,  0,  8,  0,  8,  0
        db -1, -1, -1, -1,  8,  0,  8,  0
        db  8,  0, -2, -1, -2, -1,  0,  0
        db  8,  0, -2, -1, -2, -1,  0,  0
        db  8,  0, -2, -1, -2, -1,  0,  0
        db  8,  0, -2, -1, -2, -1,  0,  0
        db  8,  0, -2, -1, -2, -1,  0,  0
    
    .chr
        db $28, $28, $28, $28, $28, $28, $28, $28
        db $38, $38, $38, $38, $08, $09, $28, $28
        db $08, $09, $D9, $D9, $08, $08, $D8, $D8
        db $08, $08, $DA, $DA, $06, $06, $D9, $D9
        db $26, $26, $D8, $D8, $6C, $06, $06, $00
        db $6C, $26, $26, $00, $6C, $06, $06, $00
        db $6C, $26, $26, $00, $6C, $08, $08, $00
    
    .properties
        db $01, $41, $41, $41, $01, $41, $41, $41
        db $01, $41, $41, $41, $01, $01, $01, $41
        db $01, $01, $00, $40, $01, $01, $00, $40
        db $01, $01, $00, $40, $01, $01, $00, $40
        db $00, $01, $00, $40, $06, $41, $41, $00
        db $06, $41, $41, $00, $06, $01, $01, $00
        db $06, $01, $01, $00, $06, $01, $01, $00
    
    .oam_sizes
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $02, $02, $00, $00
        db $02, $02, $00, $00, $02, $02, $00, $00
        db $02, $02, $00, $00, $02, $02, $02, $00
        db $02, $02, $02, $00, $02, $02, $02, $00
        db $02, $02, $02, $00, $02, $02, $02, $00
    
    .num_oam_entries
        db 1, 1, 1, 3, 3, 3, 3, 3
        db 3, 1, 1, 1, 1, 1
    }

; ==============================================================================

    ; *$34E45-$34EBF LOCAL
    Leever_Draw:
    {
        JSR Sprite_PrepOamCoord
        
        LDA $0DC0, X : TAY : ASL #2 : STA $06
        
        PHX
        
        LDX .num_oam_entries, Y
        
        LDY.b #$00
    
    .next_oam_entry
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA $05 : PHA
        
        LDA .chr, X : INY : STA ($90), Y
        
        CMP.b #$60 : BCS .mask_off_palette_and_nametable_bits
        CMP.b #$28 : BEQ .mask_off_palette_and_nametable_bits
        CMP.b #$38 : BNE .dont_do_that
    
    .mask_off_palette_and_nametable_bit
    
        ; \task (and \wtf) What purpose does this serve exactly?
        LDA $05 : AND.b #$F0 : STA $05
    
    .dont_do_that
    
        LDA .properties, X : ORA $05 : INY : STA ($90), Y
        
        PLA : STA $05
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA .oam_sizes, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
