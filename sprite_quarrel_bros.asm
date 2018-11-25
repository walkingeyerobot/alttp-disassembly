
; ==============================================================================

    ; *$2E00B-$2E012 LONG
    Sprite_QuarrelBrosLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_QuarrelBros
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E013-$2E051 LOCAL
    Sprite_QuarrelBros:
    {
        JSR QuarrelBros_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_MakeBodyTrackHeadDirection
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDA $A0 : AND.b #$01 : BNE .is_right_hand_brother
        
        ; Hey [Name], did you come from my older brother's room?..."
        LDA.b #$31
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .moving_on
    
    .is_right_hand_brother
    
        LDA $0401 : BNE .door_bombed_open
        
        ; Yeah [Name], now I'm quarreling with my younger brother. I sealed..."
        LDA.b #$2F
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        BRA .moving_on
    
    .door_bombed_open
    
        ; "So the doorway is open again... maybe I should make up with my..."
        LDA.b #$30
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
    
    .moving_on
    
        JSL Sprite_PlayerCantPassThrough
        
        RTS
    }

; ==============================================================================

    ; $2E052-$2E062 UNUSED
    Sprite_Oprhan1:
    {
        JSR Sprite2_Move
        
        JSR Sprite2_CheckTileCollision
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Orphan1_State1
        dw Orphan1_State2
    }

; ==============================================================================

    ; $2E063-$2E06A UNUSED DATA
    pool Oprhan1_State1:
    {
    
    .x_speeds
        db $00, $00, $F4, $0B
    
    .y_speeds
        db $F4, $0B, $00, $00
    }

; ==============================================================================

    ; $2E06B-$2E0B5 UNUSED JUMP LOCATION
    Orphan1_State1:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$1F : ADD.b #$40 : STA $0DF0, X
        
        ; Picks a sort of new random direction that will be different from
        ; the previous direction.
        LDA $1A : AND.b #$01 : ORA.b #$02 : EOR $0DE0, X : STA $0DE0, X
        
    .delay
    
        LDA $0E70, X : AND.b #$0F : BEQ .no_wall_collision
        
        INC $0D80, X
        
        LDA.b #$60 : STA $0DF0, X
    
    .no_wall_collision
    
        TXA : EOR $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        TYA : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $2E0B6-$2E0FE UNUSED JUMP LOCATION
    Orphan1_State2:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$1F : ADD.b #$60 : STA $0DF0, X
        
        STZ $0D80, X
        
        ; Picks a sort of new random direction that will be different from
        ; the previous direction.
        LDA $1A : AND.b #$01 : ORA.b #$02 : EOR $0DE0, X : STA $0DE0, X
    
    .delay
    
        STZ $0D50, X
        
        STZ $0D40, X
        
        TXA : EOR $1A : LSR #5 : AND.b #03 : STA $00
        
        AND.b #$01 : BNE .skip
        
        LDA $00 : LSR A : ORA.b #$02 : EOR $0DE0, X : STA $0DE0, X
        
        RTS
    
    .skip
    
        LDA $0DE0, X : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $2E0FF-$2E17E DATA
    pool QuarrelBros_Draw:
    {
    
    .animation_states
        dw 0, -12 : db $04, $00, $00, $02
        db 0,   0 : db $0A, $00, $00, $02
        db 0, -11 : db $04, $00, $00, $02
        db 0,   1 : db $0A, $40, $00, $02
        db 0, -12 : db $04, $00, $00, $02
        db 0,   0 : db $0A, $00, $00, $02
        db 0, -11 : db $04, $00, $00, $02
        db 0,   1 : db $0A, $40, $00, $02
        db 0, -12 : db $08, $00, $00, $02
        db 0,   0 : db $0A, $00, $00, $02
        db 0, -11 : db $08, $00, $00, $02
        db 0,   1 : db $0A, $40, $00, $02
        db 0, -12 : db $08, $40, $00, $02
        db 0,   0 : db $0A, $00, $00, $02
        db 0, -11 : db $08, $40, $00, $02
        db 0,   1 : db $0A, $40, $00, $02
    }

; ==============================================================================

    ; *$2E17F-$2E1A2 LOCAL
    QuarrelBros_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        ; This is using the table at $E0FF / $2E0FF, just in case I get
        ; distracted and have to come back to this.
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL #4 : ADC.b #$FF : STA $08
        LDA.b #$E0                                   : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
