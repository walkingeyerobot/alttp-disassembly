
; ==============================================================================

    ; $F1A6B-$F1A6C DATA
    pool FluteBoyAnimal:
    {
    
    .vh_flip
        db $40, $00
    }

; ==============================================================================

    ; *$F1A6D-$F1A89 JUMP LOCATION
    Sprite_FluteBoyRabbit:
    {
        LDY $0DE0, X
        
        LDA $0F50, X : AND.b #$BF : ORA FluteBoyAnimal.vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteBoyRabbit_Chillin
        dw FluteBoyRabbit_RunAway
    }

; ==============================================================================

    ; *$F1A8A-$F1AAB JUMP LOCATION
    FluteBoyRabbit_Chillin:
    {
        LDA.b #$03 : STA $0DC0, X
        
        LDA $0FDD : BEQ .dont_run_away
        
        INC $0D80, X
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X : TAY
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        LDA.b #$F8 : STA $0D40, X
    
    .dont_run_away
    
        RTS
    }

; ==============================================================================

    ; $F1AAC-$F1AAE DATA
    pool FluteBoyRabbit_RunAway:
    {
    
    .animation_states
        db 0, 1, 2
    }

; ==============================================================================

    ; *$F1AAF-$F1AEB JUMP LOCATION
    FluteBoyRabbit_RunAway:
    {
        JSR Sprite3_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .aloft
        
        ; Hop again!
        LDA.b #$18 : STA $0F80, X
        
        STZ $0F70, X
        
        STZ $0E80, X
        
        STZ $0D90, X
    
    .aloft
    
        INC $0E80, X : LDA $0E80, X : AND.b #$03 : BNE .delay_animation_tick
        
        LDA $0D90, X : CMP.b #$02 : BEQ .animation_counter_maxed
        
        INC $0D90, X
    
    .animation_counter_maxed
    .delay_animation_tick
    
        LDY $0D90, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

