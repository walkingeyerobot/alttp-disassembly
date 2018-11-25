
; ==============================================================================

    ; *$E8AB6-$E8B06 JUMP LOCATION
    Sprite_Trident:
    {
        JSR Trident_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckDamage
        JSR Sprite_PeriodicWhirringSfx
        JSR Sprite4_Move
        
        DEC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$07 : TAY
        
        LDA $92F7, Y : STA $0ED0, X
        
        LDA $0DF0, X : BEQ Trident_AimForParentPosition
        LSR A        : BCS BRANCH_ALPHA
        
        LDA.b #$20
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
    
    ; *$E8AE4 ALTERNATE ENTRY POINT
    
        LDA $00 : CMP $0D40, X : BEQ BRANCH_BETA : BPL BRANCH_GAMMA
        
        DEC $0D40, X
        
        BRA BRANCH_BETA
    
    BRANCH_GAMMA:
    
        INC $0D40, X
    
    BRANCH_BETA:
    
        LDA $01 : CMP $0D50, X : BEQ BRANCH_ALPHA : BPL BRANCH_DELTA
        
        DEC $0D50, X
        
        BRA BRANCH_ALPHA
    
    BRANCH_DELTA:
    
        INC $0D50, X
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $E8B07-$E8B0A DATA
    {
        ; \task Name this routine / pool.
        db 24, -16
        db  0,  -1
    }

; ==============================================================================

    ; *$E8B0B-$E8B48 BRANCH LOCATION
    Trident_AimForParentPosition:
    {
        LDY $0DE0
        
        LDA $0D10 : ADD $8B07, Y : STA $04
        LDA $0D30 : ADC $8B09, Y : STA $05
        
        LDA $0D00 : ADD.b #$F0 : STA $06
        LDA $0D20 : ADC.b #$FF : STA $07
        
        JSR Ganon_CheckEntityProximity : BCS BRANCH_ALPHA
        
        STZ $0DD0, X
        
        LDA.b #$03 : STA $0D80
        
        LDA.b #$10 : STA $0DF0
    
    BRANCH_ALPHA:
    
        LDA.b #$20
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        JMP $8AE4   ; $E8AE4 IN ROM
    }

; ==============================================================================
