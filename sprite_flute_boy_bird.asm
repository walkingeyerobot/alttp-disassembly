
; ==============================================================================

    ; *$F1AEC-$F1B2B JUMP LOCATION
    Sprite_FluteBoyBird:
    {
        LDA $0DC0, X : CMP.b #$03 : BNE .not_blinking
        
        JSR FluteBoyBird_DrawBlink
    
    .not_blinking
    
        LDY $0DE0, X
        
        LDA $0F50, X : AND.b #$BF : ORA FluteBoyAnimal.vh_flip, Y : STA $0F50, X
        
        REP #$20
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        DEC $0E40, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        INC $0E40, X
        
        JSR Sprite3_MoveXyz
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteBoyBird_Chillin
        dw FluteBoyBird_Rising
        dw FluteBoyBird_Falling
    }

; ==============================================================================

    ; *$F1B2C-$F1B60 JUMP LOCATION
    FluteBoyBird_Chillin:
    {
        LDY.b #$00
        
        LDA $1A : AND.b #$18 : BNE .other_animation_state
        
        LDY.b #$03
    
    .other_animation_state
    
        TYA : STA $0DC0, X
        
        LDA $0FDD : BEQ .dont_run_away
        
        INC $0D80, X
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X : TAY
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA.b #$10 : STA $0F80, X
        
        LDA.b #$F8 : STA $0D40, X
    
    .dont_run_away
    
        RTS
    }

; ==============================================================================

    ; *$F1B61-$F1B83 JUMP LOCATION
    FluteBoyBird_Rising:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA $0F80, X : ADD.b #$02 : STA $0F80, X
        
        CMP.b #$10 : BMI .below_rise_speed_limit
        
        INC $0D80, X
    
    .below_rise_speed_limit
    .delay
    
        INC $0E80, X : LDA $0E80, X : LSR A : AND.b #$01 : INC A : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F1B84-$F1B99 JUMP LOCATION
    FluteBoyBird_Falling:
    {
        LDA.b #$01 : STA $0DC0, X
        
        LDA $0F80, X : SUB.b #$01 : STA $0F80, X
        
        CMP.b #$F1 : BPL .above_fall_speed_limit
        
        DEC $0D80, X
    
    .above_fall_speed_limit
    
        RTS
    }

; ==============================================================================

    ; $F1B9A-$F1B9B DATA
    pool FluteBoyBird_DrawBlink:
    {
    
    .x_offsets
        $08, $00
    }

; ==============================================================================

    ; *$F1B9C-$F1BC7 LOCAL
    FluteBoyBird_DrawBlink:
    {
        JSR Sprite3_PrepOamCoord
        
        PHX
        
        LDA $0DE0, X : TAX
        
        LDA $00 : ADD .x_offsets, X                    : STA ($90), Y
        LDA $02                                  : INY : STA ($90), Y
        LDA.b #$AE                               : INY : STA ($90), Y
        LDA $05 : ORA FluteBoyAnimal.vh_flip, X  : INY : STA ($90), Y
        
        PLX
        
        LDY.b #$00
        LDA.b #$00
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    }

; ==============================================================================

