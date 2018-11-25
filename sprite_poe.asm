
; ==============================================================================

    ; $31686-$31687 DATA
    pool Sprite_Poe:
    {
    
    .h_flip
        db $40, $00
    }

; ==============================================================================

    ; *$31688-$3171E JUMP LOCATION
    Sprite_Poe:
    {
        ; Derive orientation (for h_flip) from the sign of the x velocity.
        LDA $0D50, X : ASL A : ROL A : AND.b #$01 : STA $0DE0, X : TAY
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
        
        ; If this branch is taken, it means that the Poe is rising from a
        ; grave in the light world.
        LDA $0E90, X : BNE .dont_use_super_priority
        
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
    
    .dont_use_super_priority
    
        JSR Poe_Draw
        
        REP #$20
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        DEC $0E40, X
        
        JSR Sprite_PrepAndDrawSingleLarge
        
        INC $0E40, X
        
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        
        LDA $0E90, X : BEQ .not_rising_from_grave
        
        ; The Poe can't do anything else while it is rising from a grave. It
        ; just gets drawn and rises until it reaches a height of 12 pixels.
        INC $0F70, X
        
        LDA $0F70, X : CMP.b #12 : BNE .not_at_target_altitude
        
        STZ $0E90, X
    
    .not_at_target_altitude
    
        RTS
    
    .not_rising_from_grave
    
        JSR Sprite_CheckDamage
        
        INC $0E80, X
        
        JSR Sprite_Move
        
        LDA $1A : LSR A : BCS .z_speed_adjustment_delay
        
        LDA $0ED0, X : AND.b #$01 : TAY
        
        LDA $0F80, X : ADD .acceleration, Y : STA $0F80, X
        
        CMP .z_speed_limits, Y : BNE .z_speed_not_at_max
        
        INC $0ED0, X
    
    .z_speed_not_at_max
    .z_speed_adjustment_delay
    
        JSR Sprite_MoveAltitude
        
        STZ $0D40, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Poe_SelectVerticalDirection
        dw Poe_Roaming

    parallel pool Poe_Roaming:
    
    .acceleration
        db 1, -1
        
        ; \note These accelerations are use only for the x velocity and only
        ; in the dark world, making the poes slightly different there.
        db 2, -2
        
    .x_speed_limits
        db 16, -16, 28, -28
    
    .z_speed_limits
        db 8, -8
    }

; ==============================================================================

    ; *$3171F-$3173E JUMP LOCATION
    Poe_SelectVerticalDirection:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        ; Generate one random int and check its bit content.
        JSL GetRandomInt : AND.b #$0C : BNE .flip_a_coin
        
        ; In this case the player's relative position is used to set the
        ; y direction.
        JSR Sprite_IsBelowPlayer : TYA
        
        BRA .set_y_direction
    
    .flip_a_coin
    
        ; And in this case it's just a fifty fifty chance of going one way
        ; or thw other, vertically.
        JSL GetRandomInt : AND.b #$01
    
    .set_y_direction
    
        STA $0EB0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $3173F-$31740 DATA
    pool Poe_Roaming:
    {
    
    .y_speeds
        db 8, -8
    }

; ==============================================================================

    ; *$31741-$3177D JUMP LOCATION
    Poe_Roaming:
    {
        LDA $001A : LSR A : BCS .adjust_speed_delay
        
        ; Why are we adding the light world / dark world distinctifier?
        LDA $0EC0, X : AND.b #$01 : ADD $0FFF : ADC $0FFF : TAY
        
        LDA $0D50, X : ADD .acceleration, Y : STA $0D50, X
        
        CMP .x_speed_limits, Y : BNE .x_speed_maxed_out
        
        ; Speed limit reached, time to switch direction.
        INC $0EC0, X
        
        STZ $0D80, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$10 : STA $0DF0, X
    
    .adjust_speed_delay
    .x_speed_maxed_out
    
        LDY $0EB0, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        RTS
    }

; ==============================================================================

    ; $3177E-$31785 DATA
    pool Poe_Draw:
    {
    
    .x_offsets
        db 9, 0, -1, -1
    
    .chr
        db $7C, $80, $B7, $80
    }

; ==============================================================================

    ; *$31786-$317D7 LOCAL
    Poe_Draw:
    {
        JSR Sprite_PrepOamCoord
        
        LDA $0E80, X : LSR #3 : AND.b #$03 : STA $06
        
        LDA $0DE0, X : ASL A : PHX : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        ADD.w #$0100 : STA $0E
        
        LDA $02 : ADD.w #$0009 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        LDX $06
        
        LDA .chr, X                       : INY : STA ($90), Y
        LDA $05 : AND.b #$F0 : ORA.b #$02 : INY : STA ($90), Y
        
        LDA $0F : STA ($92)
        
        PLX
        
        RTS
    }

; ==============================================================================
