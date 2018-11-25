
; ==============================================================================

    ; $2B019-$2B01A DATA (UNUSED)
    pool Sprite_ChainBallTrooper:
    {
    
    .spin_speeds
        db $22, $10
    }

; ==============================================================================

    ; *$2B01B-$2B07C JUMP LOCATION
    Sprite_ChainBallTrooper:
    {
        JSR $B144 ; $2B144 IN ROM
        
        LDA $0D80, X : CMP.b #$02 : BCS .alpha
        
        LDA.b #$80 : STA $0FAB
    
    .alpha
    
        JSR Sprite2_CheckIfActive
        JSL $06EB5E ; $36B5E IN ROM
        
        LDY $0D80, X
        
        LDA .spin_speeds - 2, Y : ADD $0D90, X              : STA $0D90, X
        LDA $0DA0, X            : ADC.b #$00   : AND.b #$01 : STA $0DA0, X
        
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_CheckTileCollision
        JSR Sprite2_Move
        JSL Sprite_CheckDamageToPlayerLong
        
        TXA : EOR $1A : AND.b #$0F : BNE .no_head_direction_change
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0EB0, X
    
    .no_head_direction_change
    
        LDA $0D80, X : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        LDA .states, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .states
    
        db FlailTrooper_ApproachPlayer
        db FlailTrooper_ShortHalting
        db FlailTrooper_Attack
        db FlailTrooper_WindingDown
    }

; ==============================================================================

    ; $2B07D-$2B0C6 JUMP LOCATION
    FlailTrooper_ApproachPlayer:
    {
        TXA : EOR $1A : AND.b #$0F : BNE .delay
        
        ; Make body match head direction
        LDA $0EB0, X : STA $0DE0, X
        
        LDA $0E : ADD.b #$40 : CMP.b #$68 : BCS .player_not_close
        
        LDA $0F : ADD.b #$30 : CMP.b #$60 : BCS .player_not_close
        
        ; Start swinging the ball and chain.
        INC $0D80, X
        
        LDA.b #$18 : STA $0DF0, X
        
        RTS
    
    .beta
    
        LDA.b #$08 : JSL Sprite_ApplySpeedTowardsPlayerLong
    
    .delay
    
    shared FlailTrooper_Animate:
    
        LDA $0DE0, X : ASL #3 : STA $00
        
        INC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$07 : ORA $00 : TAY
        
        LDA.w .animation_states, Y : STA $0DC0, X
        
        RTS
    }
    
; ==============================================================================

    ; $2B0C7-$2B0E6 DATA
    pool FlailTrooper_Animate:
    parallel pool Sprite_PsychoTrooper:
    {
    
    .animation_states
    
        db $10, $11, $12, $13, $10, $11, $12, $13
        db $06, $07, $08, $09, $06, $07, $08, $09
        db $00, $01, $02, $03, $00, $01, $04, $05
        db $0A, $0B, $0C, $0D, $0A, $0B, $0E, $0F
    }

; ==============================================================================

    ; $2B0E7-$2B0F7 JUMP LOCATION
    FlailTrooper_ShortHalting:
    {
        JSR Sprite2_ZeroVelocity
        
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$30 : STA $0DF0, X
        
        INC $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2B0F8-$2B0FB DATA
    pool FlailTrooper_Attack:
    {
        db $03, $01, $02, $00
    }

; ==============================================================================

    ; $2B0FC-$2B12D JUMP LOCATION
    FlailTrooper_Attack:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA $0D90, X : ASL A : LDA $0DA0, X : ROL A : TAY
        
        ; Head doesn't match a direction...? what?
        LDA $B0F8, Y : CMP $0EB0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$1F : STA $0E10, X
    
    .delay
    
    shared FlailTrooper_DoubleAnimatePlusSound:
    
        INC $0E80, X
        
        JSR FlailTrooper_Animate
        
        TXA : EOR $1A : AND.b #$0F : BNE .return
        
        LDA.b #$06 : JSL Sound_SetSfx3PanLong
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $2B12E-$2B143 JUMP LOCATION
    FlailTrooper_WindingDown:
    {
        JSR Sprite2_ZeroVelocity
        
        LDA $0E10, X : BNE .delay
        
        STZ $0D80, X
    
    .delay
    
        CMP.b #$10 : BCS FlailTrooper_DoubleAnimatePlusSound
        
        INC $0E80, X
        
        JSR FlailTrooper_Animate
        
        RTS
    }

; ==============================================================================

    ; *$2B144-$2B155 LOCAL
    {
        JSR Sprite2_PrepOamCoord
        JSR ChainBallTrooper_DrawHead
        JSR FlailTrooper_DrawBody
        JSR $B468 ; $2B468 IN ROM
        JSR Sprite2_PrepOamCoord
        JMP $C68C ; $2C68C IN ROM
    } 

; ==============================================================================

    ; $2B156-$2B15D DATA
    pool ChainBallTrooper_DrawHead:
    {
    
    .chr
        db $02, $02, $00, $04
    
    .properties
        db $40, $00, $00, $00
    }

; ==============================================================================

    ; *$2B15E-$2B1A2 LOCAL
    ChainBallTrooper_DrawHead:
    {
        LDY.b #$18
    
    ; *$2B160 ALTERNATE ENTRY POINT
    
        PHX
        
        LDA $0EB0, X : TAX
        
        REP #$20
        
        LDA $00                       : STA ($90), Y
                                        AND.w #$0100 : STA $0E
        
        LDA $02 : SUB.w #$0009 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_y
    
        SEP #$20
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA .properties, X : INY : ORA $05 : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $2B1A3-$2B3CA DATA
    pool FlailTrooper_DrawBody:
    {
    
    .x_offsets

        dw -4,  4, 12
        dw -4,  4, 13
        dw -4,  4, 13
        dw -4,  4, 13
        dw -4,  4, 13
        dw -4,  4, 13
        dw  0,  0,  4
        dw  0,  0,  5
        dw  0,  0,  6
        dw  0,  0,  4
        dw -4,  4, -6
        dw -4,  4, -5
        dw -4,  4, -5
        dw -4,  4, -6
        dw -4,  4, -5
        dw -4,  4, -6
        dw  0,  0,  4
        dw  0,  0,  3
        dw  0,  0,  2
        dw  0,  0,  4
        dw  0,  0,  0
        dw  0,  0,  0
        dw -4,  4,  4
        dw -4,  4,  4
        
    .y_offsets
        dw  0,  0, -4
        dw  0,  0, -4
        dw  0,  0, -3
        dw  0,  0, -2
        dw  0,  0, -3
        dw  0,  0, -2
        dw  0,  0,  1
        dw  0,  0,  1
        dw  0,  0,  2
        dw  0,  0,  2
        dw  0,  0, -2
        dw  0,  0, -2
        dw  0,  0, -1
        dw  0,  0, -1
        dw  0,  0, -1
        dw  0,  0, -1
        dw  0,  0,  1
        dw  0,  0,  1
        dw  0,  0,  2
        dw  0,  0,  2
        dw  0,  0,  0
        dw  0,  0,  0
        dw  0,  0,  0
        dw  0,  0,  0
    
    .chr
        db $46, $06, $2F, $46, $06, $2F, $48, $0D
        db $2F, $48, $0D, $2F, $49, $0C, $2F, $49
        db $0C, $2F, $08, $08, $2F, $08, $08, $2F
        db $22, $22, $2F, $22, $22, $2F, $0A, $64
        db $2F, $0A, $64, $2F, $2C, $67, $2F, $2C
        db $67, $2F, $2D, $66, $2F, $2D, $66, $2F
        db $08, $08, $2F, $08, $08, $2F, $22, $22
        db $2F, $22, $22, $2F, $62, $62, $62, $62
        db $62, $62, $46, $4B, $4B, $69, $64, $64
    
    .vh_flip
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $40, $40, $00, $40
        db $40, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $40
        db $40, $00, $40, $40, $00, $00, $40, $00
        db $00, $40, $40, $40, $40, $40, $40, $40
        db $40, $40, $40, $40, $40, $40, $40, $40
        db $40, $40, $40, $40, $40, $40, $40, $00
        db $00, $00, $00, $40, $40, $00, $40, $40
    
    .sizes
        db $02, $02, $00, $02, $02, $00, $02, $02
        db $00, $02, $02, $00, $02, $02, $00, $02
        db $02, $00, $02, $02, $00, $02, $02, $00
        db $02, $02, $00, $02, $02, $00, $02, $02
        db $00, $02, $02, $00, $02, $02, $00, $02
        db $02, $00, $02, $02, $00, $02, $02, $00
        db $02, $02, $00, $02, $02, $00, $02, $02
        db $00, $02, $02, $00, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
    
    .num_subsprites
    ; I'm thinking that the last 4 entries are unfinished or unused...
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $01, $01, $01, $01
    
    .oam_offset_adjustment
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $08, $08, $08, $08
    }

; ==============================================================================

    ; *$2B3CB-$2B43F LOCAL
    FlailTrooper_DrawBody:
    {
        LDY.b #$14
        
        ; I am confuse, as this would certainly overwrite the head portion
        ; in most cases, right? bug?
    
    ; *$2B3CD ALTERNATE ENTRY POINT
    
        LDA $0DC0, X : ASL A : ADC $0DC0, X : STA $06
        
        PHX
        
        LDA $0DC0, X : TAX
        
        TYA : ADD .oam_offset_adjustment, X : TAY
        
        LDA .num_subsprites, X : TAX
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .alpha
        
        LDA.w #$00F0 : STA ($90), Y
    
    .alpha
    
        SEP #$20
        
        PLX
        
        LDA .chr, X               : INY : STA ($90), Y
        LDA .vh_flip, X : ORA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA .sizes, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : CPX.b #$02 : BNE .beta
        
        INY #4

    .beta

        DEX : BPL .next_subsprite
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $2B440-$2B467 DATA
    {
        db $10, $12, $14, $16, $18, $1A, $1C, $1E
        db $20, $22, $24, $26, $28, $2A, $2C, $2E
        db $30, $2E, $2C, $2A, $28, $26, $24, $22
        db $20, $1E, $1C, $1A, $18, $16, $14, $12
    
    ; $2B460
        db $04, $04, $0C, $FB
        
    ; $2B464
        db $FE, $FE, $FA, $FC
    }

; ==============================================================================

    ; *$2B468-$2B5BD LOCAL
    {
        LDA $00 : STA $0FA8
        LDA $02 : STA $0FA9
        
        LDA $0D90, X : STA $00
        LDA $0DA0, X : STA $01
        
        LDA.b #$00
        
        LDY $0D80, X : CPY.b #$02 : BCC .alpha
        
        LDA $0E10, X : TAY
        
        LDA $B440, Y
    
    .alpha
    
        STA $0F
        
        LDY $0DE0, X
        
        LDA $B460, Y : STA $0C
        LDA $B464, Y : STA $0D
        
        PHX
        
        REP #$30
        
        LDA $00 : AND.w #$01FF : LSR #6 : STA $0A
        
        LDA $00 : ADD.w #$0080 : AND.w #$01FF : STA $02
        
        LDA $00 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $04
        
        LDA $02 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $06
        
        SEP #$30
        
        PLX
        
        LDA $04 : STA $4202
        
        LDA $0F
        
        LDY $05 : BNE .beta
        
        STA $4203
        
        JSR $B5BE ; $2B5BE IN ROM
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    .beta
    
        STA $0E
        
        LSR $01 : BCC .gamma
        
        EOR.b #$FF : INC A
    
    .gamma
    
        STA $04
        
        LDA $06 : STA $4202
        
        LDA $0F
        
        LDY $07 : BNE .delta
        
        STA $4203
        
        JSR $B5BE ; $2B5BE IN ROM
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    .delta
    
        STA $0F
        
        LSR $03 : BCC .epsilon
        
        EOR.b #$FF : INC A
    
    .epsilon
    
        STA $06
        
        LDY.b #$00
        
        LDA $04 : SUB.b #$04 : ADD $0C : STA $0FAB
        
        ADD $0FA8 : STA ($90), Y
        
        LDA $06 : SUB.b #$04 : ADD $0D : STA $0FAA
        
        ADD $0FA9  : INY : STA ($90), Y
        LDA.b #$2A : INY : STA ($90), Y
        LDA.b #$2D : INY : STA ($90), Y
        
        LDA.b #$02 : STA ($92)
        
        LDY.b #$04
        
        PHX
        
        LDX.b #$03
    
    .iota
    
        LDA $0E      : STA $4202
        LDA $B5BA, X : STA $4203
        
        JSR $B5BE ; $2B5BE IN ROM
        
        LDA $04 : ASL A
        
        LDA $4217 : BCC .zeta
        
        EOR.b #$FF : INC A
    
    .zeta
    
        ADD $0FA8 : ADD $0C : STA ($90), Y
        
        LDA $0F : STA $4202
        
        LDA .multiplicands, X : STA $4203
        
        JSR $B5BE ; $2B5BE IN ROM
        
        LDA $06 : ASL A
        
        LDA $4217 : BCC .theta
        
        EOR.b #$FF : INC A
    
    .theta
    
        ADD $0FA9 : ADD $0D : INY : STA ($90), Y
        LDA.b #$3F          : INY : STA ($90), Y
        LDA.b #$2D          : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .iota
        
        PLX
        
        LDY.b #$FF
        LDA.b #$04
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    
    .multiplicands
        db $33, $66, $99, $CC
    }

; ==============================================================================

    ; *$2B5BE-$2B5C2 LOCAL
    {
        NOP #4
        
        RTS
    }

; ==============================================================================
