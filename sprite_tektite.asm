
; ==============================================================================

    ; $EC26D-$EC274 DATA
    pool Tektite_Stationary:
    {
    
    .x_speeds
        db  16, -16,  16, -16
    
    .y_speeds
        db  16,  16, -16, -16
    }

; ==============================================================================

    ; *$EC275-$EC292 JUMP LOCATION LOCAL
    Sprite_GanonHelpers:
    {
        ; Tektite / Ganon's firebats and pitchfork code
        
        LDA $0EC0, X : BEQ Sprite_Tektite
        
        STA $0BA0, X : PHA
        
        LDA.b #$30 : STA $0B89, X
        
        PLA : DEC A
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_PhantomGanon  ; Ganon bat atop Ganon's Tower
        dw Sprite_Trident       ; Trident
        dw Sprite_SpiralFireBat ; special spiraling firebat
        dw Sprite_FireBat       ; normal firebat
        dw Sprite_FlameTrailBat ; Special flametrail firebat
    }

; ==============================================================================

    ; *$EC293-$EC2CD BRANCH LOCATION
    Sprite_Tektite:
    {
        ; Code for Tektites
        
        LDA $0E00, X : BEQ .anoforce_default_animation_state
        
        STZ $0DC0, X
    
    .anoforce_default_animation_state
    
        JSR Tektite_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckIfRecoiling
        JSR Sprite4_CheckDamage
        JSR Sprite4_MoveXyz
        JSR Sprite4_BounceFromTileCollision
        
        ; Simulates gravity for the sprite.
        LDA $0F80, X : SUB.b #$01 : STA $0F80, X
        
        LDA $0F70, X : BPL .aloft
        
        STZ $0F70, X
        STZ $0F80, X
    
    .aloft
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Tektite_Stationary
        dw Tektite_Aloft
        dw Tektite_RepeatingHop
    }

; ==============================================================================

    ; $EC2CE-$EC2D1 DATA
    pool Tektite_Stationary:
    {
    
    .comparison_directions
        db 3, 2, 1, 0
    }

; ==============================================================================

    ; *$EC2D2-$EC387 JUMP LOCATION LOCAL
    Tektite_Stationary:
    {
        JSR Sprite4_DirectionToFacePlayer
        
        LDA $0E : ADD.b #$28 : CMP.b #$50 : BCS .dont_dodge
        
        LDA $0F : ADD.b #$28 : CMP.b #$50 : BCS .dont_dodge
        
        ; Is this checking for a sword attack? Maybe.
        LDA $44 : CMP.b #$80 : BEQ .dont_dodge
        
        LDA $0F70, X : ORA $0F00, X : BNE .dont_dodge
        
        LDA $EE : CMP $0F20, X : BNE .dont_dodge
        
        STY $00
        
        LDA $2F : LSR A : TAY
        
        ; \wtf Weird directions to check against? Either a bug or intentionally
        ; quirky logic.
        LDA $00 : CMP .comparison_directions, Y : BEQ .dont_dodge
        
        LDA.b #$20 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $01 : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $00 : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA.b #$10 : STA $0F80, X
        
        INC $0D80, X
        
        RTS
    
    .dont_dodge
    
        LDA $0DF0, X : BNE .just_animate
        
        INC $0D80, X
        
        INC $0DA0, X
        
        LDA $0DA0, X : CMP.b #$04 : BNE .select_random_direction
        
        ; Otherwise select a direction towards the player.
        STZ $0DA0, X
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$3F : ADC.b #$30 : STA $0DF0, X
        
        LDA.b #$0C : STA $0F80, X
        
        JSR Sprite4_IsBelowPlayer
        
        TYA : ASL A : STA $00
        
        JSR Sprite4_IsToRightOfPlayer
        
        TYA : ORA $00
        
        BRA .set_xy_speeds
    
    .select_random_direction
    
        JSL GetRandomInt : AND.b #$07 : ADC.b #$18 : STA $0F80, X
        
        JSL GetRandomInt : AND.b #$03
    
    .set_xy_speeds
    
        TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        RTS
    
    .just_animate
    
        LSR #4 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EC388-$EC3A7 JUMP LOCATION
    Tektite_Aloft:
    {
        LDA $0F70, X : BNE .aloft
    
    ; *$EC38D ALTERNATE ENTRY POINT
    shared Tektite_RevertToStationary:
    
        STZ $0D80, X
        
        JSL GetRandomInt : AND.b #$3F : ADC.b #$48 : STA $0DF0, X
    
    ; *$EC39B ALTERNATE ENTRY POINT
    shared Sprite4_Zero_XY_Velocity:
    
        STZ $0D40, X
        STZ $0D50, X
        
        RTS
    
    .aloft
    
        LDA.b #$02 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EC3A8-$EC3C4 JUMP LOCATION
    Tektite_RepeatingHop:
    {
        LDA $0DF0, X : BEQ Tektite_RevertToStationary
        
        LDA $0F70, X : BNE .aloft
        
        LDA.b #$0C : STA $0F80, X
        
        INC $0F70, X
        
        LDA.b #$08 : STA $0E00, X
    
    .aloft
    
        LDA.b #$02 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $EC3C5-$EC3F4 DATA
    pool Tektite_Draw:
    {
    
    .oam_groups
        dw -8,  0 : db $C8, $00, $00, $02
        dw  8,  0 : db $C8, $40, $00, $02
        
        dw -8,  0 : db $CA, $00, $00, $02
        dw  8,  0 : db $CA, $40, $00, $02
    }

; ==============================================================================

    ; *$EC3F5-$EC411 LOCAL
    Tektite_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite4_DrawMultiple
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
