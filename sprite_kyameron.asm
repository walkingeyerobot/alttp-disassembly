
; ==============================================================================

    ; *$F1E7B-$F1EA4 JUMP LOCATION
    Sprite_Kyameron:
    {
        LDA $0D80, X : BNE .visible
        
        JSL Sprite_PrepOamCoordLong
        
        BRA .not_visible
    
    .visible
    
        JSR Kyameron_Draw
    
    .not_visible
    
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Kyameron_Reset
        dw Kyameron_PuddleUp
        dw Kyameron_Coagulate
        dw Kyameron_Moving
        dw Kyameron_Disperse
    }

; ==============================================================================

    ; *$F1EA5-$F1EDA JUMP LOCATION
    Kyameron_Reset:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$3F : ADC.b #$60 : STA $0DF0, X
        
        LDA $0D90, X : STA $0D10, X
        LDA $0DA0, X : STA $0D30, X
        
        LDA $0DB0, X : STA $0D00, X
        LDA $0EB0, X : STA $0D20, X
        
        LDA.b #$05 : STA $0E80, X
        
        LDA.b #$08 : STA $0DC0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$F1EDB-$F1F00 JUMP LOCATION
    Kyameron_PuddleUp:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$1F : STA $0DF0, X
        
        INC $0D80, X
    
    .delay
    
        DEC $0E80, X : BPL .animation_delay
        
        LDA.b #$05 : STA $0E80, X
        
        INC $0DC0, X : LDA $0DC0, X : AND.b #$03 : ADD.b #$08 : STA $0DC0, X
    
    .animation_delay
    
        RTS
    }

; ==============================================================================

    ; $F1F01-$F1F10 DATA
    pool Kyameron_Coagulate:
    {
    
    .animation_states
        db $04, $07, $0E, $0D, $0C, $06, $06, $05
    
    .x_speeds
        db $20, $E0, $20, $E0
    
    .y_speeds
        db $20, $20, $E0, $E0
    }

; ==============================================================================

    ; *$F1F11-$F1F54 JUMP LOCATION
    Kyameron_Coagulate:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        JSR Sprite3_IsBelowPlayer
        
        TYA : ASL A : STA $00
        
        JSR Sprite3_IsToRightOfPlayer
        
        TYA : ORA $00 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        RTS
    
    .delay
    
        CMP.b #$07 : BNE .dont_move_up
        
        PHA
        
        LDA $0D00, X : SUB.b #$1D : STA $0D00, X
        LDA $0D20, X : SBC.b #$00 : STA $0D20, X
        
        PLA
    
    .dont_move_up
    
        LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F1F55-$F1F58 DATA
    pool Kyameron_Moving:
    {
    
    .animation_states
        db $03, $02, $01, $00
    }

; ==============================================================================

    ; *$F1F59-$F1FE2 JUMP LOCATION
    Kyameron_Moving:
    {
        STZ $0BA0, X
        
        JSR Sprite3_CheckDamage : BCS .took_damage
        
        JSR Sprite3_Move
        
        JSR Sprite3_CheckTileCollision : AND.b #$03 : BEQ .no_horiz_collision
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        ; After accumulating 3 
        INC $0EC0, X
        
        BRA .no_horiz_collision
    
    .no_horiz_collision
    
        LDA $0E70, X : AND.b #$0C : BEQ .no_vert_collision
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        INC $0EC0, X
    
    .no_vert_collision
    
        LDA $0EC0, X : CMP.b #$03 : BCC .not_enough_tile_collisions
    
    .took_damage
    
        LDA.b #$04 : STA $0D80, X
        
        LDA.b #$0F : STA $0DF0, X
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
    
    .not_enough_tile_collisions
    
        INC $0E80, X : LDA $0E80, X : LSR #3 : AND.b #$03 : TAY
        
        LDA $9F55, Y : STA $0DC0, X
        
        TXA : EOR $1A : AND.b #$07 : BNE .dont_spawn_shiny_garnish
        
        JSL GetRandomInt : REP #$20 : AND.w #$000F : SUB.w #$0004 : STA $00
        
        SEP #$20
        
        JSL GetRandomInt : REP #$20 : AND.w #$000F : SUB.w #$0004 : STA $02
        
        SEP #$20
        
        JSL Sprite_SpawnSimpleSparkleGarnish
    
    .dont_spawn_shiny_garnish
    
        RTS
    }

; ==============================================================================

    ; *$F1FE3-$F2000 JUMP LOCATION
    Kyameron_Disperse:
    {
        LDA $0DF0, X : BNE .delay
        
        STZ $0EC0, X
        
        ; Go back to the reset state.
        STZ $0D80, X
        
        STZ $0F70, X
        
        LDA.b #$40 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #2 : TAY
        
        ADD.b #$0F : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F2001-$F206B LONG
    Sprite_SpawnSimpleSparkleGarnish_SlotRestricted:
    {
        PHX
        
        TXY
        
        LDX.b #$0E
        
        BRA .search_for_slot
    
    ; *$F2007 ALTERNATE ENTRY POINT
    shared Sprite_SpawnSimpleSparkleGarnish:
    
        ; This routine makes sparklies! ^_^
        
        PHX
        
        TXY
        
        LDX.b #$1D
    
    .search_for_slot
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        STX $0F
        
        PLX
        
        RTL
    
    .empty_slot
    
        STX $0F
        
        LDA.b #$05 : STA $7FF800, X : STA $0FB4
        
        LDA $0D10, Y : ADD $00 : STA $7FF83C, X
        LDA $0D30, Y : ADC $01 : STA $7FF878, X
        
        ; WTF is this math here? Will take some sorting out with the PHP / PLPs...
        LDA $0D00, Y : SUB $0F70, Y : PHP : ADD.b #$10 : PHP : ADD $02    : STA $7FF81E, X
        LDA $0D20, Y : ADC $03      : PLP : ADC.b #$00 : PLP : SBC.b #$00 : STA $7FF85A, X
        
        LDA.b #$1F : STA $7FF90E, X
        
        TYA : STA $7FF92C, X
        
        LDA $0F20, Y : STA $7FF968, X
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; $F206C-$F2157 DATA
    pool Kyameron_Draw:
    {
    
    .oam_groups
        dw  1,   8 : db $B4, $00, $00, $00
        dw  7,   8 : db $B5, $00, $00, $00
        dw  4,  -3 : db $86, $00, $00, $00
        dw  0, -13 : db $A2, $80, $00, $02
        
        dw  2,   8 : db $B4, $00, $00, $00
        dw  6,   8 : db $B5, $00, $00, $00
        dw  4,  -6 : db $96, $00, $00, $00
        dw  0, -20 : db $A2, $00, $00, $02
        
        dw  4,  -1 : db $96, $00, $00, $00
        dw  0, -27 : db $A2, $00, $00, $02
        dw  0, -27 : db $A2, $00, $00, $02
        dw  0, -27 : db $A2, $00, $00, $02
        
        dw -6,  -6 : db $DF, $01, $00, $00
        dw 14,  -6 : db $DF, $41, $00, $00
        dw -6,  14 : db $DF, $81, $00, $00
        dw 14,  14 : db $DF, $C1, $00, $00
        
        dw -6,  -6 : db $96, $00, $00, $00
        dw 14,  -6 : db $96, $40, $00, $00
        dw -6,  14 : db $96, $80, $00, $00
        dw 14,  14 : db $96, $C0, $00, $00
        
        dw -4,  -4 : db $8D, $01, $00, $00
        dw 12,  -4 : db $8D, $41, $00, $00
        dw -4,  12 : db $8D, $81, $00, $00
        dw 12,  12 : db $8D, $C1, $00, $00
        
        dw  0,   0 : db $8D, $01, $00, $00
        dw  8,   0 : db $8D, $41, $00, $00
        dw  0,   8 : db $8D, $81, $00, $00
        dw  8,   8 : db $8D, $C1, $00, $00      
    
    .vh_flip
        db $40, $00, $00, $00, $00, $00, $00, $00
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; *$F2158-$F2191 LOCAL
    Kyameron_Draw:
    {
        LDA $0DC0, X : CMP.b #$0C : BCS .dispersing
        
        LDY $0DC0, X
        
        LDA $0F50, X : PHA
        
        AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        PLA : STA $0F50, X
        
        RTS
    
    .dispersing
    
        SUB.b #$0C : TAY
        
        LDA.b #$00 : XBA
        
        TYA : REP #$20 : ASL #5 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JMP Sprite3_DrawMultiple
    }

; ==============================================================================
