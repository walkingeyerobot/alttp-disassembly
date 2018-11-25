
; ==============================================================================

    ; *$2B80A-$2B891 JUMP LOCATION
    Sprite_Bot:
    shared Sprite_Popo:
    {
        JSR Bot_Draw
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        
        INC $0E80, X
        
        LDA $0E80, X : LSR #4 : AND.b #$03 : STA $0D90, X
        
        JSR Sprite2_CheckDamage
        
        LDA $0D80, X : CMP.b #$02 : BEQ .alpha
        
        CMP.b #$01 : BEQ .beta
        
        LDA $0DF0, X : BNE .gamma
        
        INC $0D80, X
        
        LDA.b #$69 : STA $0DF0, X
    
    .gamma
    
        RTS
    
    .beta
    
        INC $0E80, X
        
        LDA $0DF0, X : BNE .delta
        
        JSL GetRandomInt : AND.b #$3F : ADC.b #$80 : STA $0DF0, X
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$0F : TAY
        
        LDA $AAE4, Y : ASL #2 : STA $0D50, X
        LDA $AAF4, Y : ASL #2 : STA $0D40, X
    
    .delta
    
        RTS
    
    .alpha
    
        INC $0E80, X
        
        LDA $0DF0, X : BNE .epsilon
    
    .theta
    
        STZ $0D80, X
        
        LDA.b #$50 : STA $0DF0, X
        
        RTS
    
    .epsilon
    
        TXA : EOR $1A : AND $0DA0, X : BNE .zeta
        
        JSR Sprite2_Move
        
        LDA $0E70, X : BNE .theta
    
    ; *$2B88D ALTERNATE ENTRY POINT
    .zeta
    shared Sprite2_CheckTileCollision:
    
        JSL Sprite_CheckTileCollisionLong
        
        RTS
    }

; ==============================================================================

    ; $2B892-$2B899 DATA
    pool Bot_Draw
    {
    
    .animation_states
        db $00, $01, $00, $01
    
    .vh_flip
        db $00, $00, $40, $40
    }

; ==============================================================================

    ; *$2B89A-$2B8B2 LOCAL
    Bot_Draw:
    {
        LDY $0D90, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        RTS
    }

; ==============================================================================
