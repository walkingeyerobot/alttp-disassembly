
; ==============================================================================

    ; *$F1BC8-$F1C6A JUMP LOCATION
    Sprite_Zoro:
    shared Sprite_Babusu:
    {
        LDA $0E90, X : BNE .is_zoro
        
        JMP Babusu_Main
    
    .is_zoro
    
        LDA $0DB0, X : BNE .initialized
        
        INC $0DB0, X
        
        JSR Sprite3_IsBelowPlayer
        
        ; 0 - sprite is above or level with player
        ; 1 - sprite is below player
        CPY.b #$00 : BEQ .dont_self_terminate
        
        ; is sprite is below player during the initialization phase, we just
        ; self terminate. This would be after the player enters the door
        ; and enters a different quadrant.
        STZ $0DD0, X
        
        RTS
    
    .dont_self_terminate
    .initialized
    
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckDamage
        
        INC $0E80, X : LDA $0E80, X : LSR A : AND.b #$01 : STA $0DC0, X
        
        LDA $0E80, X : LSR #2 : AND.b #$01 : TAY
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        JSR Sprite3_Move
        
        LDA $0DF0, X : BNE .dont_self_terminate
        
        JSR Sprite3_CheckTileCollision : BEQ .dont_self_terminate
        
        STZ $0DD0, X
    
    .dont_self_terminate
    
        LDA $0E80, X : AND.b #$03 : BNE .spawn_delay
        
        PHX : TXY
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .spawn_zoro_garnish
        
        DEX : BPL .next_slot
        
        PLX
    
    .spawn_delay
    
        RTS
    
    .spawn_zoro_garnish
    
        LDA.b #$06 : STA $7FF800, X : STA $0FB4
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$0A : STA $7FF90E, X
        
        TYA : STA $7FF92C, X
        
        LDA $0F20, Y : STA $7FF968, X
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$F1C6B-$F1C80 ALTERNATE ENTRY POINT
    Babusu_Main:
    {
        JSL Babusu_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Babusu_Reset
        dw Babusu_Hiding
        dw Babusu_TerrorSprinkles
        dw Babusu_ScurryAcross
    }

; ==============================================================================

    ; *$F1C81-$F1C8E JUMP LOCATION
    Babusu_Reset:
    {
        INC $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
        
        LDA.b #$FF : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F1C8F-$F1C9C JUMP LOCATION
    Babusu_Hiding:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$37 : STA $0DF0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F1C9D-$F1CAC DATA
    pool Babusu_TerrorSprinkles:
    {
    
    .animation_states
        db $05, $04, $03, $02, $01, $00
    
    .animation_adjustments
        db $06, $06, $00, $00
    
    .x_speeds length 4
        db $20, $E0
    
    .y_speeds
        db $00, $00, $20, $E0
    }


; ==============================================================================

    ; *$F1CAD-$F1CE7 JUMP LOCATION
    Babusu_TerrorSprinkles:
    {
        LDA $0DF0, X : BNE .delay
        
        PHA
        
        INC $0D80, X
        
        ; \task investigate whether these things can move left or right, and
        ; whether they have any understanding
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA.b #$20 : STA $0DF0, X
        
        PLA
    
    .delay
    
        CMP.b #$20 : BCC .still_hidden
        
        SBC.b #$20 : LSR #2 : TAY
        
                       LDA .animation_states, Y      
        LDY $0DE0, X : ADD .animation_adjustments, Y : STA $0DC0, X
        
        RTS
    
    .still_hidden
    
        LDA.b #$FF : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F1CE8-$F1CEB DATA
    pool Babusu_ScurryAcross:
    {
    
    .animation_states
        db $12, $0E, $0C, $10
    }

; ==============================================================================

    ; *$F1CEC-$F1D16 JUMP LOCATION
    Babusu_ScurryAcross:
    {
        JSR Sprite3_CheckDamage
        JSR Sprite3_Move
        
        LDA $1A : LSR A : AND.b #$01
        
        LDY $0DE0, X
        
        ADD .animation_states, Y : STA $0DC0, X
        
        LDA $0DF0, X : BNE .cant_collide
        
        JSR Sprite3_CheckTileCollision : BEQ .didnt_collide
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        STZ $0D80, X

    .didnt_collide
    .cant_collide

        RTS
    }

; ==============================================================================

