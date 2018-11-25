
; ==============================================================================

    ; *$F2AA7-$F2AF3 JUMP LOCATION
    Sprite_StalfosKnight:
    {
        LDA $0D80, X : BNE .visible
        
        JSL Sprite_PrepOamCoordLong
        
        BRA .not_visible
    
    .visible
    
        JSR StalfosKnight_Draw
    
    .not_visible
    
        JSR Sprite3_CheckIfActive
        
        LDA $0EF0, X : AND.b #$7F : CMP.b #$01 : BNE BRANCH_GAMMA
        
        STZ $0EF0, X
        
        LDA.b #$06 : STA $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        STZ $0D50, X
        STZ $0D40, X
        
        LDA.b #$02 : STA $7F6918
    
    BRANCH_GAMMA:
    
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw StalfosKnight_WaitingForPlayer
        dw StalfosKnight_Falling
        dw $AB5C ; = $F2B5C*
        dw $ABA6 ; = $F2BA6*
        dw $ABD6 ; = $F2BD6*
        dw $ABF6 ; = $F2BF6*
        dw $AC77 ; = $F2C77*
        dw $ACD8 ; = $F2CD8*
    }

; ==============================================================================

    ; *$F2AF4-$F2B26 JUMP LOCATION
    StalfosKnight_WaitingForPlayer:
    {
        LDA.b #$09 : STA $0F60, X : STA $0BA0, X
        
        ; Temporarily make the sprite harmless since it's not technically
        ; on screen yet.
        LDA $0E40, X : PHA
        ORA.b #$80   : STA $0E40, X
        
        JSR Sprite3_CheckDamageToPlayer
        
        PLA : STA $0E40, X : BCC .didnt_touch
        
        ; As soon as Link gets close enough, the Stalfos knight reveals itself
        ; by falling from the ceiling.
        LDA.b #$90 : STA $0F70, X
        
        INC $0D80, X
        
        LDA.b #$02 : STA $0EB0, X
        
        LDA.b #$02 : STA $0DC0, X
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
    
    .didnt_touch
    
        RTS
    }

; ==============================================================================

    ; *$F2B27-$F2B59 JUMP LOCATION
    StalfosKnight_Falling:
    {
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F80, X : CMP.b #$C0 : BMI .at_terminal_falling_speed
        
        SUB.b #$03 : STA $0F80, X
    
    .at_terminal_falling_speed
    
        PLA : EOR $0F70, X : BPL .not_sign_change
        
        LDA $0F70, X : BPL .in_air
    
    ; *$F2B46 ALTERNATE ENTRY POINT
    
        LDA.b #$02 : STA $0D80, X
        
        STZ $0BA0, X
        
        STZ $0F70, X
        
        STZ $0F80, X
        
        LDA.b #$3F : STA $0DF0, X
    
    .in_air
    .no_sign_change
    
        RTS
    }

; ==============================================================================

    ; $F2B5A-$F2B5B DATA
    {
    
    .animation_states
        db 0, 1
    }

; ==============================================================================

    ; *$F2B5C-$F2B95 JUMP LOCATION
    {
        LDA.b #$00 : STA $7F6918
        
        JSR Sprite3_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$03 : STA $0D80, X
        
        JSL GetRandomInt : AND.b #$3F : STA $0DA0, X
        
        LDA.b #$7F : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #5 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA .animation_states, Y : STA $0DB0, X
        
        LDA.b #$02 : STA $0EB0, X
        
        RTS
    }

; ==============================================================================

    ; $F2B96-$F2BA5 DATA
    {
    
        ; \task Label this data.
        db  0,  0,  0,  2,  1,  1,  1,  2
        db  0,  0,  0,  2,  1,  1,  1,  2
    }

; ==============================================================================

    ; *$F2BA6-$F2BD5 JUMP LOCATION
    {
        JSR Sprite3_CheckDamage
        
        LDA $0DF0, X : CMP $0DA0, X : BNE BRANCH_ALPHA
        
        JSR Sprite3_IsToRightOfPlayer
        
        TYA : STA $0EB0, X
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LSR #3 : TAY
        
        LDA $AB96, Y : STA $0EB0, X
        
        LDA.b #$00 : STA $0DB0, X
        
        LDA.b #$00 : STA $0DC0, X
        
        RTS
    }

    ; *$F2BD6-$F2BF5 JUMP LOCATION
    {
        JSR Sprite3_CheckDamage
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        LDA.b #$20 : STA $0E00, X
    
    ; *$F2BEB ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDA.b #$01 : STA $0DB0, X
        LDA.b #$01 : STA $0DC0, X
        
        RTS
    }

    ; *$F2BF6-$F2C56 JUMP LOCATION
    {
        JSR Sprite3_CheckDamage
        
        LDA $0E00, X : BEQ BRANCH_ALPHA
        DEC A        : BNE BRANCH_BETA
        
        LDA.b #$30 : STA $0F80, X
        
        LDA.b #$10
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        JSR Sprite3_IsToRightOfPlayer
        
        TYA : STA $0EB0, X
        
        LDA.b #$13 : JSL Sound_SetSfx3PanLong
    
    BRANCH_BETA:
    
        BRA BRANCH_$F2BEB
    
    BRANCH_ALPHA:
    
        JSR Sprite3_MoveXyz
        JSR Sprite3_CheckTileCollision
        
        LDA $0F80, X : CMP.b #$C0 : BMI BRANCH_GAMMA
        
        SUB.b #$02 : STA $0F80, X
    
    BRANCH_GAMMA:
    
        LDA $0F70, X : DEC A : BPL BRANCH_DELTA
        
        STZ $0F70, X
        STZ $0F80, X
        
        LDA $0DF0, X : BNE BRANCH_EPSILON
        
        JMP $AB46 ; $F2B46 IN ROM
    
    BRANCH_EPSILON:
    
        LDA.b #$10 : STA $0E00, X
    
    BRANCH_DELTA:
    
        LDY.b #$02
        
        LDA $0F80, X : CMP.b #$18 : BMI BRANCH_ZETA
        
        LDY.b #$00
    
    BRANCH_ZETA:
    
        TYA : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F2C57-$F2C76 DATA
    {
    
        ; \task Label this data
        db  0,  4,  8, 12, 14, 14, 14, 14
        db 14, 14, 14, 14, 14, 14, 14, 14
        db 14, 14, 14, 14, 14, 14, 14, 14
        db 14, 14, 15, 14, 12,  8,  4,  0
    }

; ==============================================================================

    ; *$F2C77-$F2CD5 JUMP LOCATION
    {
        JSR Sprite3_MoveXyz
        JSR Sprite3_CheckTileCollision
        
        LDA $0F80, X : CMP.b #$C0 : BMI BRANCH_ALPHA
        
        SUB.b #$02 : STA $0F80, X
    
    BRANCH_ALPHA:
    
        LDA $0F70, X : DEC A : BPL BRANCH_BETA
        
        STZ $0F70, X
        STZ $0F80, X
    
    BRANCH_BETA:
    
        LDA $0DF0, X : BNE BRANCH_GAMMA
        
        JSL GetRandomInt : AND.b #$01 : BNE BRANCH_DELTA
        
        LDA.b #$07 : STA $0D80, X
        LDA.b #$50 : STA $0DF0, X
        
        RTS
    
    BRANCH_DELTA:
    
        JMP $AB46 ; $F2B46 IN ROM
    
    BRANCH_GAMMA:
    
        CMP.b #$E0 : BCC BRANCH_EPSILON
        
        PHA : AND.b #$03 : BNE BRANCH_ZETA
        
        LDA.b #$14 : JSL Sound_SetSfx3PanLong
    
    BRANCH_ZETA:
    
        PLA
    
    BRANCH_EPSILON:
    
        LSR #3 : TAY
        
        LDA $AC57, Y : STA $0DB0, X
        
        LDA.b #$03 : STA $0DC0, X
        
        LDA.b #$02 : STA $0EB0, X
        
        RTS
    }

; ==============================================================================

    ; $F2CD6-$F2CD7 DATA
    {
    
    ; \task Name this routine / pool.
    .animation_states
        db 1, 4
    }

; ==============================================================================

    ; *$F2CD8-$F2CEB JUMP LOCATION
    {
        LDA $0DF0, X : BNE .delay
        
        JMP $AB46 ; $F2B46 IN ROM
    
    .delay
    
        LSR #2 : AND.b #$01 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F2CEC-$F2E03 DATA
    pool StalfosKnight_Draw:
    {
    
    .oam_groups
        dw -4, -8 : db $64, $00, $00, $00
        dw -4,  0 : db $61, $00, $00, $02
        dw  4,  0 : db $62, $00, $00, $02
        dw -3, 16 : db $74, $00, $00, $00
        dw 11, 16 : db $74, $40, $00, $00
        
        dw -4, -7 : db $64, $00, $00, $00
        dw -4,  1 : db $61, $00, $00, $02
        dw  4,  1 : db $62, $00, $00, $02
        dw -3, 16 : db $65, $00, $00, $00
        dw 11, 16 : db $65, $40, $00, $00
        
        dw -4, -8 : db $48, $00, $00, $02
        dw  4, -8 : db $49, $00, $00, $02
        dw -4,  8 : db $4B, $00, $00, $02
        dw  4,  8 : db $4C, $00, $00, $02
        dw  4,  8 : db $4C, $00, $00, $02
        
        dw -4,  8 : db $68, $00, $00, $02
        dw  4,  8 : db $69, $00, $00, $02
        dw  4,  8 : db $69, $00, $00, $02
        dw  4,  8 : db $69, $00, $00, $02
        dw  4,  8 : db $69, $00, $00, $02
        
        dw 12, -7 : db $64, $40, $00, $00
        dw -4,  1 : db $62, $40, $00, $02
        dw  4,  1 : db $61, $40, $00, $02
        dw -3, 16 : db $65, $00, $00, $00
        dw 11, 16 : db $65, $40, $00, $00
        
        dw 12, -8 : db $64, $40, $00, $00
        dw -4,  0 : db $62, $40, $00, $02
        dw  4,  0 : db $61, $40, $00, $02
        dw -3, 16 : db $74, $00, $00, $00
        dw 11, 16 : db $74, $40, $00, $00
        
        dw -4, -8 : db $49, $40, $00, $02
        dw  4, -8 : db $48, $40, $00, $02
        dw -4,  8 : db $4C, $40, $00, $02
        dw  4,  8 : db $4B, $40, $00, $02
        dw  4,  8 : db $4B, $40, $00, $02
    }

; ==============================================================================

    ; *$F2E04-$F2E45 LOCAL
    StalfosKnight_Draw:
    {
        JSR Sprite3_PrepOamCoord
        JSR $AE4E ; $F2E4E IN ROM
        
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #3 : STA $00 : ASL #2 : ADC $00
        
        ADC.w #.oam_groups : STA $08
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        LDA.b #$05 : JSR Sprite3_DrawMultiple
        
        REP #$20
        
        LDA $90 : SUB.w #$0004 : STA $90
        
        DEC $92
        
        SEP #$20
        
        LDA.b #$12 : JSL Sprite_DrawShadowLong.variable
        
        RTS
    }

; ==============================================================================

    ; $F2E46-$F2E4D DATA
    {
    
    ; \task Name this pool / routine. Hint: Perhaps it's for the Stalfos knight
    ; head?
    .chr
        db $66, $66, $46, $46
    
    .properties
        db $40, $00, $00, $00
    }

; ==============================================================================

    ; *$F2E4E-$F2EA3 LOCAL
    {
        LDA $0DC0, X : CMP.b #$02 : BEQ .dont_draw
        
        LDA $0DB0, X : STA $06
                       STZ $07
        
        LDY.b #$00
        
        PHX
        
        LDA $0EB0, X : TAX
        
        REP #$20
        
        LDA $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $06 : SUB.w #$000C : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_y
    
        SEP #$20
        
        LDA .chr, X        : INY           : STA ($90), Y
        LDA .properties, X : INY : ORA $05 : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLX
    
    .dont_draw:
    
        RTS
    }

; ==============================================================================
