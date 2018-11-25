
; ==============================================================================

    ; $2A377-$2A379 DATA
    pool Lanmola_FinishInitialization:
    {
        ; Seems hard coded for 3 Lanmolas... here at least.
    .starting_delay
        db $80, $CF, $FF
    }

; ==============================================================================

    ; *$2A37A-$2A39F LONG
    Lanmola_FinishInitialization:
    {
        LDA.l .starting_delay, X : STA $0DF0, X
        
        LDA.b #$FF : STA $0F70, X
        
        PHX
        
        LDY.b #$3F
        
        LDA .sprite_regions, X : TAX
        
        LDA.b #$FF
    
    .reset_extended_sprites
    
        STA $7FFE00, X
        
        INX
        
        DEY : BPL .reset_extended_sprites
        
        PLX
        
        LDA.b #$07 : STA $7FF81E, X
        
        RTL
    }

; ==============================================================================

    ; $2A3A0-$2A3A1 DATA (UNUSED)
    pool Sprite_Lanmola:
    {
    
    .unused
        db 24, -24
    }

; ==============================================================================

    ; *$2A3A2-$2A3BE JUMP LOCATION
    Sprite_Lanmola:
    {
        JSL Sprite_PrepOamCoordLong
        JSR Lanmola_Draw
        JSR Sprite2_CheckIfActive.permissive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        ; \task Name these ai states.
        dw $A3BF ; = $2A3BF*
        dw $A3E6 ; = $2A3E6*
        dw $A431 ; = $2A431*
        dw $A4CB ; = $2A4CB*
        dw $A4F2 ; = $2A4F2*
        dw $A529 ; = $2A529*
    }

; ==============================================================================

    ; *$2A3BF-$2A3D5 JUMP LOCATION
    {
        LDA $0DF0, X : ORA $0F00, X : BNE .alpha
        
        LDA.b #$7F : STA $0DF0, X
        
        INC $0D80, X
        
        LDA.b #$35 : JSL Sound_SetSfx2PanLong
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $2A3D6-$2A3E5 DATA
    {
        db $58, $50, $60, $70, $80, $90, $A0, $98
        
        db $68, $60, $70, $80, $90, $A0, $A8, $B0
    }

; ==============================================================================

    ; *$2A3E6-$2A42E JUMP LOCATION
    {
        LDA $0DF0, X : BNE .alpha
        
        JSL Lanmola_SpawnShrapnel
        
        LDA.b #$13 : STA $012D
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $A3D6, Y : STA $0DA0, X
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $A3DE, Y : STA $0DB0, X
        
        INC $0D80, X
        
        LDA.b #$18 : STA $0F80, X
        
        STZ $0EC0, X
        STZ $0ED0, X
    
    ; *$2A41C ALTERNATE ENTRY POINT
    shared Lanmola_SetScatterSandPosition:
    
        LDA $0D10, X : STA $0DE0, X
        LDA $0D00, X : STA $0E70, X
        
        LDA.b #$4A : STA $0E00, X
        
        RTS
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $2A42F-$2A430 DATA
    {
        db 2, -2
    }

; ==============================================================================

    ; *$2A431-$2A4CA JUMP LOCATION
    {
        JSR Sprite2_CheckDamage
        JSR Sprite2_MoveAltitude
        
        LDA $0EC0, X : BNE .alpha
        
        LDA $0F80, X : SUB.b #$01 : STA $0F80, X : BNE .beta
        
        INC $0EC0, X
    
    .beta
    
        BRA .gamma
    
    .alpha
    
        LDA $1A : AND.b #$01 : BNE .gamma
        
        LDA $0ED0, X : AND.b #$01 : TAY
        
        LDA $0F80, X : ADD $A42F, Y : STA $0F80, X : CMP $95FC, Y : BNE .gamma
        
        INC $0ED0, X
    
    .gamma
    
        LDA $0DA0, X : STA $04
        LDA $0D30, X : STA $05
        LDA $0DB0, X : STA $06
        LDA $0D20, X : STA $07
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        REP #$20
        
        LDA $00 : SUB $04 : ADD.w #$0002 : CMP.w #$0004            : BCS .delta
        LDA $02 : SUB $06 : ADD.w #$0002 : CMP.w #$0004 : SEP #$20 : BCS .delta
        
        INC $0D80, X
    
    .delta
    
        SEP #$20
        
        LDA.b #$0A
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        LDA $01 : STA $0D50, X
        
        JSR Sprite2_Move
        
        RTS
    }

    ; *$2A4CB-$2A4F1 JUMP LOCATION
    {
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        JSR Sprite2_MoveAltitude
        
        LDA $0F80, X : CMP.b #$EC : BMI .alpha
        
        SUB.b #$01 : STA $0F80, X
    
    .alpha
    
        LDA $0F70, X : BPL .beta
        
        INC $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
        
        JSR Lanmola_SetScatterSandPosition
    
    .beta
    
        RTS
    }

    ; *$2A4F2-$2A514 JUMP LOCATION
    {
        LDA $0DF0, X : BNE .alpha
        
        STZ $0D80, X
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $A3D6, Y : STA $0D10, X
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $A3DE, Y : STA $0D00, X
    
    .alpha
    
    parallel pool Lanmola_Death:
    
    .easy_out
    
        RTS
    }

; ==============================================================================

    ; $2A515-$2A51C DATA
    {
    
    ; \task Name this routine / pool.
        db 0,  8, 16, 24, 32, 40, 48, 56
    }

; ==============================================================================

    ; *$2A51D-$2A528 LONG
    Sprite_SpawnFallingItem:
    {
        ; Triggers falling item special object apparently?
        
        PHX
        
        TAX
        
        LDY.b #$04 ; Try to load the effect into slot 4.
        LDA.b #$29 ; Trigger a falling item effect.
        
        JSL AddPendantOrCrystal
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$2A529-$2A5D9 JUMP LOCATION
    {
        LDY $0DF0, X : BNE .alpha
        
        STZ $0DD0, X
        
        JSL Sprite_VerifyAllOnScreenDefeated : BCC .alpha
        
        ; Lanmolas are dead, spawn heart container
        LDA.b #$EA : JSL Sprite_SpawnDynamically
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$20 : STA $0F80, Y
        LDA.b #$03 : STA $0D90, Y
    
    .alpha
    
        LDA $0DF0, X : CMP.b #$20 : BCC .easy_out
                       CMP.b #$A0 : BCS .easy_out
                       AND.b #$0F : BNE .easy_out
        
        LDA $7FF81E, X : TAY
        
        LDA $0E80, X : SUB $A515, Y : AND.b #$3F : ADD $A5DA, X : PHX : TAX
        
        LDA $7FFC00, X : SUB $E2                  : STA $0A
        LDA $7FFD00, X : SUB $7FFE00, X : SUB $E8 : STA $0B
        
        PLX
        
        ; Spawn a sprite that instantly dies as a boss explosion?
        LDA.b #$00 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$0B : STA $0AAA
        
        LDA.b #$04 : STA $0DD0, Y
        
        LDA.b #$1F : STA $0DF0, Y : STA $0D90, Y
        
        LDA $0A : ADD $E2    : STA $0D10, Y
        LDA $E3 : ADC.b #$00 : STA $0D30, Y
        LDA $0B : ADD $E8    : STA $0D00, Y
        LDA $E9 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$03 : STA $0E40, Y
        
        LDA.b #$0C : STA $0F50, Y
        
        LDA.b #$0C : JSL Sound_SetSfx2PanLong
        
        LDA $7FF81E, X : BMI .beta
        
        DEC A : STA $7FF81E, X
    
    .spawn_failed
    .beta
    
        RTS
    }

; ==============================================================================

    ; $2A5DA-$2A649 DATA
    shared pool Lanmola_FinishInitialization:
    {
    
    .sprite_regions
        db $00, $40, $80, $C0
        
    ; $2A5DE
        db $00, $1C
    
    ; $2A5E0
        db $01, $F9
    }

; ==============================================================================

    ; *$2A64A-$2A87F LOCAL
    Lanmola_Draw:
    {
        TXA : ASL A : TAY
        
        REP #$20
        
        LDA $A63A, Y : STA $90
        LDA $A642, Y : STA $92
        
        SEP #$20
        
        LDA $0D40, X : SUB $0F80, X : STA $00
        LDA $0D50, X                : STA $01
        
        JSL Sprite_ConvertVelocityToAngle : STA $0DC0, X
        
        LDA $A5DA, X : STA $04
        
        PHX
        
        LDA $0D10, X : PHA
        LDA $0D00, X : PHA
        LDA $0F70, X : PHA
        LDA $0DC0, X : PHA
        
        LDA $0E80, X : STA $02 : STA $05
        
        ADD $04 : TAX
        
        PLA : STA $7FFF00, X
        PLA : STA $7FFE00, X
        PLA : STA $7FFD00, X
        PLA : STA $7FFC00, X
        
        PLX
        
        LDA $0DD0, X : CMP.b #$09 : BNE .alpha
        
        LDA $11 : ORA $0FC1 : BNE .alpha
        
        LDA $0E80, X : INC A : AND.b #$3F : STA $0E80, X
    
    .alpha
    
        LDA $0F50, X : ORA $0B89, X : STA $03
        
        LDA $7FF81E, X : BPL .beta
        
        RTS
    
    .beta
    
        PHX
        
        PHA : STA $0E
        
        LDA $0D40, X : ASL A : ROL A : AND.b #$01 : TAX
        
        LDA $A5E0, X : STA $0C
        
        LDY $A5DE, X
        
        PLX
        
        STX $0B
    
    .theta
    
        PHX : STX $0D
        
        LDA $02 : ADD $04 : TAX
        
        LDA $02 : SUB.b #$08 : AND.b #$3F : STA $02
        
        LDA $7FFC00, X : SUB $E2 : STA ($90), Y : INY
        
        LDA $7FFE00, X : BMI .gamma
        
        LDA $7FFD00, X : SUB $7FFE00, X : SUB $E8 : STA ($90), Y
    
    .gamma
    
        PHY
        
        LDA $7FFF00, X : TAX
        
        LDY $0D
        
        LDA $0B : CMP.b #$07 : BNE .delta
        
        CPY.b #$00 : BEQ .epsilon
    
    .delta
    
        LDA.b #$C6
        
        CPY $0B : BNE .zeta
        
        LDA $A5E2, X
        
        BRA .zeta
    
    .epsilon
    
        LDA $A5F2, X
    
    .zeta
    
        PLY                    : INY : STA ($90), Y
        LDA $A602, X : ORA $03 : INY : STA ($90), Y
        
        TYA : PHY : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLA : ADD $0C : TAY
        
        PLX : DEX : BPL .theta
        
        LDX $0E
        
        LDY.b #$20
    
    .kappa
    
        PHX
        
        LDA $05 : ADD $04 : TAX
        
        LDA $05 : SUB.b #$08 : AND.b #$3F : STA $05
        
        LDA $7FFC00, X : SUB $E2 : STA ($90), Y
        
        INY
        
        LDA $7FFE00, X : BMI .iota
        
        LDA $7FFD00, X : ADD.b #$0A : SUB $E8 : STA ($90), Y
    
    .iota
    
        LDA.b #$6C : INY : STA ($90), Y
        LDA.b #$34 : INY : STA ($90), Y
        
        TYA : PHY : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .kappa
        
        PLX
        
        LDA $0D80, X : CMP.b #$01 : BNE .lambda
        
        JMP Lanmola_DrawMound
    
    .lambda
    
        CMP.b #$05 : BEQ .mu
        
        LDA $0E00, X : BEQ .mu
        
        PHA
        
        LDA $0D40, X : ASL A : ROL A : ASL A : EOR $0D80, X : AND.b #$02 : BEQ .nu
        
        LDA.b #$08 : JSL OAM_AllocateFromRegionB
        
        BRA .xi
    
    .nu
    
        LDA.b #$08 : JSL OAM_AllocateFromRegionC
    
    .xi
    
        LDY.b #$00
        
        PLA : LSR #2 : AND.b #$03 : EOR.b #$03 : ASL A : STA $06
        
        LDA $0DE0, X : SUB $E2 : STA $00
        LDA $0E70, X : SUB $E8 : STA $02
        
        PHX
        
        LDX.b #$01
    
    .omicron
    
        PHX
        
        TXA : ADD $06 : TAX
        
        LDA $00 : ADD $A612, X          : STA ($90), Y
        LDA $02 : ADD $A61A, X    : INY : STA ($90), Y
        LDA $A622, X              : INY : STA ($90), Y
        LDA $A62A, X : ORA.b #$31 : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $A632, X : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .omicron
        
        PLX
    
    .mu
    
        RTS
    
    ; *$2A820 ALTERNATE ENTRY POINT
    Lanmola_DrawMound:
    
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
        
        LDA $0D10, X : SUB $E2 : STA $00
        LDA $0D00, X : SUB $E8 : STA $02
        
        LDA $0DF0, X : LSR #3 : TAY
        
        PHX
        
        LDX $A870, Y
        
        LDY.b #$00
        
        LDA $00                         : STA ($90), Y
        LDA $02                   : INY : STA ($90), Y
        LDA $A864, X              : INY : STA ($90), Y
        LDA $A86A, X : ORA.b #$31 : INY : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLX
        
        RTS
    
    .
        db $EE, $EE, $EC, $EC, $CE, $CE
    
    .
        db $00, $40, $00, $40, $00, $40
    
    . 
        db $04, $05, $04, $05, $04, $05, $04, $05
        db $04, $03, $02, $01, $01, $01, $00, $00
    }
