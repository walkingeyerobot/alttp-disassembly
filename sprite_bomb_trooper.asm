
; ==============================================================================

    ; *$2BE0A-$2BE48 JUMP LOCATION
    Sprite_BombTrooper:
    {
        LDA $0DB0, X : BNE .is_bomb
        
        JMP BombTrooper_Main
    
    .is_bomb
    
        CMP.b #$02 : BCS .flashing_or_exploding
        
        JMP EnemyBomb_ExplosionImminent
    
    .flashing_or_exploding
    
        BNE .exploding
        
        LDY.b #$0F
    
    .next_sprite
    
        CPY $0FA0                                 : BEQ .dont_damage
        LDA $0DD0, Y : CMP.b #$09                 : BCC .dont_damage
        TYA : EOR $1A : AND.b #$07 : ORA $0EF0, Y : BNE .dont_damage
        
        JSR EnemyBomb_CheckDamageToSprite
    
    .delta
    
        DEY : BPL .next_sprite
        
        JSL Sprite_CheckDamageToPlayerLong
    
    .exploding
    
        JSR EnemyBomb_DrawExplosion
        
        LDA $0E00, X : BNE .dont_self_terminate
        
        STZ $0DD0, X
    
    .dont_self_terminate
    
        RTS
    }
    
; ==============================================================================

    ; *$2BE49-$2BED2 LOCAL
    EnemyBomb_CheckDamageToSprite:
    {
        LDA $0D10, X : SUB.b #$10 : STA $00
        LDA $0D30, X : SBC.b #$00 : STA $08
        
        LDA.b #$30 : STA $02 : STA $03
        
        LDA $0D00, X : SUB.b #$10 : STA $01
        LDA $0D20, X : SBC.b #$00 : STA $09
        
        PHX
        
        TYX
        
        JSL Sprite_SetupHitBoxLong
        
        PLX
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .dont_damage
        
        LDA $0E20, Y : CMP.b #$11 : BEQ .dont_damage
        
        PHX
        
        TYX : PHY
        
        LDA.b #$08 : JSL Ancilla_CheckSpriteDamage.preset_class
        
        PLY : PLX
        
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        
        LDA $0D00, X : SUB $0F70, X : STA $02
        LDA $0D20, X : SBC.b #$00 : STA $03
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : SUB $0F70, Y : STA $06
        LDA $0D20, Y : SBC.b #$00 : STA $07
        
        PHY
        
        LDA.b #$20 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        PLY
        
        LDA $00 : STA $0F30, Y
        LDA $01 : STA $0F40, Y
        
    .dont_damage
    
        RTS
    }
    
; ==============================================================================

    ; *$2BED3-2BF50 LOCAL
    EnemyBomb_ExplosionImminent:
    {
        LDA $0E90, X : BEQ .iota
        
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
    
    .iota
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        LDA $0EF0, X : BNE .kappa
        
        LDA $0E00, X : CMP.b #$40 : BCS .lambda
        
        CMP.b #$01 : BNE .mu

    .kappa

        STZ $0EF0, X
        
        LDA $0DD0, X : CMP.b #$0A : BNE .nu
        
        STZ $0309
        STZ $0308

    .nu

        LDA.b #$0C : JSL Sound_SetSfx2PanLong
        
        INC $0DB0, X
        
        LDA.b #$09 : STA $0F60, X
        LDA.b #$02 : STA $0F50, X
        LDA.b #$1F : STA $0E00, X
        LDA.b #$06 : STA $0DD0, X
        LDA.b #$03 : STA $0E40, X
        
        RTS
    
    .mu
    
        LSR A : AND.b #$0E : STA $00
        
        LDA $0F50, X : AND.b #$F1 : ORA $00 : STA $0F50, X
    
    .lambda
    
        JSR Sprite2_CheckIfActive
        
        LDA $0EE0, X : BNE .xi
        
        JSL Sprite_CheckDamageFromPlayerLong
    
    .xi
    
        JSR Sprite2_Move
        
        LDA $1B : BEQ .omicron
        
        JSR Sprite2_CheckTileCollision
    
    .omicron
    
        JSL ThrownSprite_TileAndPeerInteractionLong
        
        RTS
    }

; ==============================================================================

    ; $2BF51-$2BFB0 LOCAL
    BombTrooper_Main:
    {
        JSR BombTrooper_Draw
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckDamage
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0DE0, X : STA $0EB0, X
        
        LDA $0D80, X : BNE .pi
        
        LDA $0DF0, X : BNE .rho
        
        INC $0D80, X
        
        LDA.b #$70 : STA $0DF0, X

    .rho

        RTS

    .pi

        LDA $0DF0, X : BNE .sigma
        
        STZ $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS

    .sigma

        STZ $0E80, X
        
        CMP.b #$50 : BCC .tau
        
        INC $0E80, X

    .tau

        CMP.b #$20 : BNE .upsilon
        
        PHA
        
        JSR BombTrooper_SpawnAndThrowBomb
        
        PLA

    .upsilon

        LSR #4 : STA $00
        
        LDA $0DE0, X : ASL #3 : ORA $00 : ADD.b #$20 : TAY
        
        LDA $D001, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2BFB1-$2BFC0 DATA
    pool 
    {
    
    .x_offsets_low
        db $00, $01, $09, $F8
    
    .x_offsets_high
        db $00, $00, $00, $FF
    
    .y_offsets_low
        db $F4, $F4, $F1, $F3
    
    .y_offsets_high
        db $FF, $FF, $FF, $FF
    }

; ==============================================================================

    ; *$2BFC1-$2C04A LOCAL
    BombTrooper_SpawnAndThrowBomb:
    {
        LDA.b #$4A
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        LDA $0DE0, X : TAX
        
        LDA $00 : ADD .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X  : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        TYX
        
        LDA.b #$10 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA.b #$01 : STA $0DB0, X
        
        JSR Sprite2_DirectionToFacePlayer
        
        LDA $0F : BPL .positive_dx
        
        EOR.b #$FF : INC A
    
    .positive_dx
    
        STA $0F
        
        LDA $0E : BPL .positive_dy
        
        EOR.b #$FF : INC A
    
    .positive_dy
    
        ORA $0F : LSR #4 : TAY
        
        LDA .initial_z_velocities, Y : STA $0F80, X
        
        LDA $0E60, X : AND.b #$EE : ORA.b #$18 : STA $0E60, X
        
        LDA.b #$08 : STA $0F50, X
        
        LDA.b #$FF : STA $0E00, X
        
        STZ $0E50, X
        
        LDA.b #$13 : JSL Sound_SetSfx3PanLong
        
        PLX
    
    .spawn_failed
    
        RTS
    
    .initial_z_velocities
        db $20, $28, $30, $38, $40, $40, $40, $40
        db $40, $40, $40, $40, $40, $40, $40, $40
    }

; ==============================================================================

    ; *$2C04B-$2C068 LOCAL
    BombTrooper_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDY.b #$08
        
        JSR $B160 ; $2B160 IN ROM
        
        LDY.b #$04
        
        JSR $B3CD ; $2B3CD IN ROM
        
        LDA $0DC0, X : CMP.b #$14 : BCS .alpha
        
        JSR BombTrooper_DrawArm
    
    .alpha
    
        LDA.b #$0A
        
        JSL Sprite_DrawShadowLong.variable
        
        RTS
    }

; ==============================================================================

    ; *$2C089-$2C0D2 LOCAL
    ; \note This name is tentative, and based purely on educated guessing.
    ; \task Determine what this routine *really* does.
    BombTrooper_DrawArm:
    {
        
        PHX
        
        LDA $0DE0, X : ASL A : ORA $0E80, X : ASL A : TAX
        
        REP #$20
        
        LDA $00      : ADD $C069, X : LDY.b #$00 : STA ($90), Y
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $C079, X      : INY        : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_y
    
        SEP #$20
        
        LDA.b #$6E : INY                     : STA ($90), Y : INY
        LDA $05    : AND.b #$30 : ORA.b #$08 : STA ($90), Y
        
        LDA.b #$02 : ORA $0F : STA ($92)
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $2C0D3-$2C112 DATA
    pool EnemyBomb_DrawExplosion:
    {
    
    .x_offsets
        db -12, 12, -12, 12
        db -8,   8,  -8,  8
        db -8,   8,  -8,  8
        db  0,   0,   0,  0
    
    .y_offsets
        db -12, -12, 12, 12
        db  -8,  -8,  8,  8
        db  -8,  -8,  8,  8
        db   0,   0,  0,  0
    
    .chr
        db $88, $88, $88, $88, $8A, $8A, $8A, $8A
        db $84, $84, $84, $84, $86, $86, $86, $86
    
    .vh_flip
        db $00, $40, $80, $C0, $00, $40, $80, $C0
        db $00, $40, $80, $C0, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$2C113-$2C154 LOCAL
    EnemyBomb_DrawExplosion:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0E00, X : LSR A : AND.b #$0C : STA $06
        
        PHX
        
        LDX.b #$03
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : TAX
    
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        LDA .chr, X                 : INY : STA ($90), Y
        LDA .vh_flip, X : ORA $05   : INY : STA ($90), Y
        
        INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
        
        LDY.b #$02
        LDA.b #$03
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    }

; ==============================================================================

