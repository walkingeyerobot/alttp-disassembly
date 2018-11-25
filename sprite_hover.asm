
; ==============================================================================

    ; *$F4C02-$F4C42 JUMP LOCATION
    Sprite_Hover:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        LDA $0EA0, X : BEQ .not_in_recoil
        
        STZ $0D80, X
    
    .not_in_recoil
    
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        
        LDA $0E70, X : BNE .collided_with_tile
        
        JSR Sprite3_Move
    
    .collided_with_tile
    
        JSR Sprite3_CheckTileCollision
        
        INC $0E80, X : LDA $0E80, X : LSR #3 : AND.b #$02 : STA $0DC0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Hover_Stopped
        dw Hover_Moving
    }

; ==============================================================================

    ; $F4C43-$F4C46 DATA
    pool Hover_Stopped:
    {
    
    .vh_flip
        db $40, $00, $40, $00
    }

; ==============================================================================

    ; *$F4C47-$F4C78 JUMP LOCATION
    Hover_Stopped:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        ; \note $0DE0, X is used atypically here as a bitfield rather than
        ; a discrete direction. This allows it to move in both directions at
        ; once, but also restricts it to diagonal movement.
        JSR Sprite3_IsToRightOfPlayer
        
        STY $0C
        
        JSR Sprite3_IsBelowPlayer
        
        TYA : ASL A : ORA $0C : STA $0DE0, X : TAY
        
        LDA $0F50, X : AND.b #$BF : ORA .vh_flip, Y : STA $0F50, X
        
        JSL GetRandomInt : AND.b #$0F : ADC.b #$0C : STA $0DF0, X
        
        JSR Sprite3_Zero_XY_Velocity
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F4C79-$F4C88 DATA
    pool Hover_Moving:
    {
    
    .x_acceleration_step
        db $01, $FF, $01, $FF
    
    .y_acceleration_step
        db $01, $01, $FF, $FF
    
    .x_deceleration_step
        db $FF, $01, $FF, $01
    
    .y_deceleration_step
        db $FF, $FF, $01, $01        
    }

; ==============================================================================

    ; *$F4C89-$F4CD2 JUMP LOCATION
    Hover_Moving:
    {
        LDA $0DF0, X : BEQ .timer_elapsed
        
        LDY $0DE0, X
        
        ; Accelerate until timer elapses.
        LDA $0D50, X : ADD $CC79, Y : STA $0D50, X
        
        LDA $0D40, X : ADD $CC7D, Y : STA $0D40, X
        
        LDA $0E80, X : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    
    .timer_elapsed
    
        LDY $0DE0, X
        
        ; Decelerate until stopped.
        LDA $0D50, X : ADD $CC81, Y : STA $0D50, X
        
        LDA $0D40, X : ADD $CC85, Y : STA $0D40, X : BNE .still_decelerating
        
        STZ $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
    
    .still_declerating
    
        RTS
    }

; ==============================================================================
