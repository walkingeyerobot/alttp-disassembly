
; ==============================================================================

    ; *$2940E-$29467 JUMP LOCATION
    Sprite_LostWoodsBird:
    {
        LDA $0E00, X : BNE .delay
        
        LDA $0F50, X : AND.b #$BF
        
        LDY $0D50, X : BMI .moving_left
        
        ; set the hflip bit
        ORA.b #$40
    
    .moving_left
    
        STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        JSR Sprite2_Move
        JSR Sprite2_MoveAltitude
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw .dropping
        dw .still_rising
    
    .dropping
    
        STZ $0DC0, X
        
        LDA $0F80, X : DEC A : STA $0F80, X : CMP.b #$F1 : BPL .still_dropping
        
        INC $0D80, X
    
    .still_dropping
    .delay
    
        RTS
     
     .rising
     
        LDA $0F80, X : INC #2 : STA $0F80, X : CMP.b #$10 : BMI .still_rising
        
        STZ $0D80, X
    
    .still_rising
    
        INC $0E80, X : LDA $0E80, X : LSR A : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================
