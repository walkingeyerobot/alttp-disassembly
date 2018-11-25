
; ==============================================================================

    ; *$32D6F-$32D99 JUMP LOCATION
    Sprite_StoryTeller_1:
    {
        JSR StoryTeller_1_Draw
        JSR Sprite_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0DF0, X : BNE .countingDown
        
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
    
    .countingDown
    
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $AD9A ; = $32D9A*
        dw $ADE1 ; = $32DE1*
        dw $AE0A ; = $32E0A*
        dw $AE34 ; = $32E34*
        dw $AE5B ; = $32E5B*
    }

    ; $32D9A-$32DA6 JUMP LOCATION
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $ADA7 ; = $32DA7*
        dw $ADBF ; = $32DBF*
        dw $ADB5 ; = $32DB5*
    }

    ; *$32DA7-$32DB4 JUMP LOCATION
    {
        LDA.b #$FE
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC BRANCH_ALPHA
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$32DB5-$32DBE JUMP LOCATION
    {
        ; Refill all hearts
        LDA.b #$A0 : STA $7EF372
        
        STZ $0D80, X
        
        RTS
    }

    ; *$32DBF-$32DE0 JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        ; $32EAB IN ROM
        JSR $AEAB : BCC BRANCH_ALPHA
        
        LDA.b #$FF
        LDY.b #$00
    
    ; *$32DCD ALTERNATE ENTRY POINT
    
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$00
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; *$32DE1-$32DED JUMP LOCATION
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $ADA7 ; = $32DA7*
        dw $ADEE ; = $32DEE*
        dw $ADB5 ; = $32DB5*
    }

    ; *$32DEE-$32E09 JUMP TABLE
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        ; $32EAB IN ROM
        JSR $AEAB : BCC BRANCH_ALPHA
        
        LDA.b #$01
        LDY.b #$01
        
        BRA BRANCH_$32DCD
    
    BRANCH_ALPHA:
    
        LDA.b #$00
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; *$32E0A-$32E16 JUMP LOCATION
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $ADA7 ; = $32DA7*
        dw $AE17 ; = $32E17*
        dw $ADB5 ; = $32DB5*
    }

    ; *$32E17-$32E33 JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        ; $32EAB IN ROM
        JSR $AEAB : BCC BRANCH_ALPHA
        
        LDA.b #$02
        LDY.b #$01
        
        JMP $ADCD ; $32DCD IN ROM
    
    BRANCH_ALPHA:
    
        LDA.b #$00
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; *$32E34-$32E5A JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA $1A : AND.b #$3F : BNE BRANCH_BETA
        
        LDA $0F50, X : EOR.b #$40 : STA $0F50, X
    
    BRANCH_BETA:
    
        JSL GetRandomInt : BNE BRANCH_ALPHA
        
        LDA.b #$20 : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        LDA.b #$49
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

    ; *$32E5B-$32E8D JUMP LOCATION
    {
        LDA $1A : LSR A : AND.b #$01 : STA $0DC0, X
        
        JSR Sprite_MoveAltitude
        
        LDA $0F70, X : BPL BRANCH_ALPHA
        
        STZ $0F70, X
    
    BRANCH_ALPHA:
    
        LDA $0F70, X : CMP.b #$04 : ROL A : AND.b #$01 : TAY
        
        LDA $0F80, X : ADD $A213, Y : STA $0F80, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $ADA7 ; = $32DA7*
        dw $AE8E ; = $32E8E*
        dw $ADB5 ; = $32DB5*
    }

    ; *$32E8E-$32EAA JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        ; $32EAB IN ROM
        JSR $AEAB : BCC BRANCH_ALPHA
        
        LDA.b #$03
        LDY.b #$01
        
        JMP $ADCD   ; $32DCD IN ROM
    
    BRANCH_ALPHA:
    
        LDA.b #$00
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; *$32EAB-$32EC9 LOCAL
    {
        REP #$20
        
        LDA $7EF360 : CMP.w #$0014 : BCC .notEnoughRupees
        
        LDA $7EF360 : SUB.w #$0014 : STA $7EF360
        
        SEP #$30
        
        SEC
        
        RTS
    
    .notEnoughRupees
    
        SEP #$30
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; $32ECA-$32F19 DATA
    pool StoryTeller_1_Draw:
    {
        dw 0, 0 : db $4A, $0A, $00, $02
        dw 0, 0 : db $6E, $4A, $00, $02
        dw 0, 0 : db $24, $0A, $00, $02
        dw 0, 0 : db $24, $4A, $00, $02
        dw 0, 0 : db $04, $08, $00, $02
        dw 0, 0 : db $04, $48, $00, $02
        dw 0, 0 : db $6A, $0A, $00, $02
        dw 0, 0 : db $6C, $0A, $00, $02
        dw 0, 0 : db $0E, $0A, $00, $02
        dw 0, 0 : db $2E, $0A, $00, $02       
    }

; ==============================================================================

    ; *$32F1A-$32F3A LOCAL
    StoryTeller_1_Draw:
    {
        LDA $0E80, X : ASL A : ADC $0DC0, X : ASL #3
        
        ADC.b #.oam_groups                 : STA $08
        LDA.b #.oam_groups>>8 : ADC.b #$00 : STA $09
        
        LDA.b #$01 : STA $06
                     STZ $07
        
        JSL Sprite_DrawMultiple.player_deferred
        JMP Sprite_DrawShadow
    }

; ==============================================================================
