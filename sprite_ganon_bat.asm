; ==============================================================================

    ; $E8906-$E890D DATA
    pool Sprite_GanonBat:
    {
    
    .animation_states
        db 0, 1, 2, 1
    
    .x_speed_limits
        db 32, -32
    
    .y_speed_limits
        db 16, -16
    }

; ==============================================================================

    ; *$E890E-$E89BA LOCAL
    Sprite_GanonBat:
    {
        JSR GanonBat_Draw
        
        LDA $0F00, X : BEQ BRANCH_ALPHA
        
        STZ $0DD0, X
        
        LDA $0403 : ORA.b #$80 : STA $0403
    
    BRANCH_ALPHA:
    
        JSR Sprite4_CheckIfActive
        
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0DF0, X : BEQ BRANCH_BETA
        CMP #$D0     : BCS BRANCH_GAMMA
        
        LDA $0EB0, X : AND.b #$01 : TAY
        
        ; Is this the kind of ganon bat that spirals out?
        LDA $0D40, X : ADD $8000, Y : STA $0D40, X
        
        CMP .y_speed_limits, Y : BNE BRANCH_DELTA
        
        INC $0EB0, X
    
    BRANCH_DELTA:
    
        LDA $0DE0, X : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD $8000, Y : STA $0D50, X : BNE BRANCH_EPSILON
        
        PHA
        
        LDA.b #$1E : JSL Sound_SetSfx3PanLong
        
        PLA
    
    BRANCH_EPSILON:
    
        CMP .x_speed_limits, Y : BNE BRANCH_GAMMA
        
        INC $0DE0, X
    
    BRANCH_GAMMA:
    
        LDA.b #$78 : STA $04
        
        LDA.b #$50 : STA $06
        
        LDA $23 : STA $05
        
        LDA $21 : STA $07
        
        LDA.b #$05 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $0D50, X : PHA : ADD $01 : STA $0D50, X
        
        LDA $0D40, X : PHA : ADD $00 : STA $0D40, X
        
        JSR Sprite4_Move
        
        PLA : STA $0D40, X
        PLA : STA $0D50, X
        
        RTS
    
    BRANCH_BETA:
    
        JSR Sprite4_Move
        
        LDA $0D50, X : CMP.b #$40 : BEQ BRANCH_ZETA
        
        INC $0D50, X
        
        DEC $0D40, X
    
    BRANCH_ZETA:
    
        RTS
    }

; ==============================================================================

    ; $E89BB-$E89EA DATA
    pool GanonBat_Draw:
    {
    
    .oam_groups
    {
        dw -8, 0 : db $60, $05, $00, $02
        dw  8, 0 : db $60, $45, $00, $02
        
        dw -8, 0 : db $62, $05, $00, $02
        dw  8, 0 : db $62, $45, $00, $02
        
        dw -8, 0 : db $44, $05, $00, $02
        dw  8, 0 : db $44, $45, $00, $02
    }

; ==============================================================================

    ; *$E89EB-$E8A03 LOCAL
    GanonBat_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #4 : ADD.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite4_DrawMultiple
    }

; ==============================================================================

