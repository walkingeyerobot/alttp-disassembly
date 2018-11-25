
; ==============================================================================

    ; *$F38B4-$F38BB LONG
    {
        PHB : PHK : PLB
        
        JSR $B6E9 ; $F36E9 IN ROM
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $F38BC-$F38C3 DATA
    pool Sprite_Arrgi:
    {
    
    .animation_states
        db 0, 1, 2, 2, 2, 2, 2, 1
    }

; ==============================================================================

    ; *$F38C4-$F39A8 JUMP LOCATION
    Sprite_Arrgi:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        INC $0E80, X
        
        LDA $0E80, X : LSR #3 : AND.b #$07 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0DA0, X : BEQ BRANCH_ALPHA
        
        TAY : DEY
        
        LDA $0C4A, Y : BEQ BRANCH_BETA
        
        LDA $0C04, Y : STA $0D10, X
        LDA $0C18, Y : STA $0D30, X
        LDA $0BFA, Y : STA $0D00, X
        LDA $0C0E, Y : STA $0D20, X
        
        LDA.b #$05 : STA $0F50, X
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        RTS
    
    BRANCH_BETA:
    
        LDA.b #$01 : STA $0D80, X
        
        STZ $0DA0, X
        
        LDA.b #$20 : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        LDA $0DF0, X : BNE BRANCH_GAMMA
        
        JSR Sprite3_CheckDamageToPlayer
    
    BRANCH_GAMMA:
    
        LDA $0D80, X : BNE BRANCH_DELTA
        
        LDA $0B0F, X : STA $0D10, X
        LDA $0B1F, X : STA $0D30, X
        
        LDA $0B2F, X : STA $0D00, X
        LDA $0B3F, X : STA $0D20, X
        
        RTS
    
    BRANCH_DELTA:
    
        JSL Sprite_CheckDamageFromPlayerLong
        
        TXA : EOR $1A : AND.b #$03 : BNE BRANCH_EPSILON
        
        LDA $0B0F, X : STA $04
        LDA $0B1F, X : STA $05
        LDA $0B2F, X : STA $06
        LDA $0B3F, X : STA $07
        
        LDA.b #$04
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        LDA $0D10, X : SUB $0B0F, X : ADD.b #$08 : CMP.b #$10 : BCS BRANCH_EPSILON
        
        LDA $0D00, X : SUB $0B2F, X : ADD.b #$08 : CMP.b #$10 : BCS BRANCH_EPSILON
        
        STZ $0D80, X
        
        LDA.b #$0D : STA $0F50, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
    
    BRANCH_EPSILON:
    
        JSR Sprite3_Move
        
        RTS
    }

; ==============================================================================
