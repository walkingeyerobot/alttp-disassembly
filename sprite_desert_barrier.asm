
; ==============================================================================

    ; *$2956D-$295FB JUMP LOCATION
    Sprite_DesertBarrier:
    {
        JSR DesertBarrier_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_CheckDamageToPlayerSameLayerLong : PHP : BCC .no_collision
        
        JSL Sprite_NullifyHookshotDrag
        JSL Sprite_RepelDashAttackLong
    
    .no_collision
    
        PLP
        
        LDA $0DF0, X : BNE .delay
        
        LDA $0D80, X : BMI .deactivated : BNE .moving
        
        LDA $02F0 : BNE .activate
    
    .delay
    .deactivated
    
        RTS
    
    .activate
    
        STA $0D80, X
        
        ; Initiate a delay for the next frame.
        LDA.b #$80 : STA $0DF0, X
        
        LDA.b #$07 : STA $012D
    
    .moving
    
        BCC .no_collision_2
        
        LDA $46 : BNE .no_collision_2
        
        LDA.b #$10 : STA $46
        
        LDA.b #$20
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA $01 : STA $28
        
        LDA $00 : STA $27
    
    .no_collision_2
    
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite2_Move
        
        JSR Sprite2_CheckTileCollision : BEQ .no_collision
        
        LDY $0DE0, X
        
        ; Effects a counterclockwise adhesion to walls.
        LDA .next_direction, Y : STA $0DE0, X
    
    .no_collision
    
        LDA.b #$01 : STA $02E4
        
        INC $0E80, X : LDA $0E80, X : AND.b #$01 : BNE .skip_frame
        
        INC $0ED0, X : LDA $0ED0, X : CMP.b #$82 : BNE .dont_deactivate
        
        ; The barrier (and its cousins) have moved enough, time to deactivate.
        ; Love the hard codedness? I don't!
        LDA.b #$80 : STA $0D80, X
        
        STZ $02E4
    
    .dont_deactivate
    .skip_frame
    
        RTS
    }

; ==============================================================================

    ; $295FC-$29605 DATA
    pool Sprite_DesertBarrier:
    shared Sprite_ArmosKnight:
    shared Sprite_Lanmolas:
    {
    
    ; Note the overlap - they optimized it for space reasons. It's correct.
    .x_speeds length 4
        db $10, $F0
     
    .y_speeds
        db $00, $00, $10, $F0
    
    .next_direction
        db  3,  2,  0,  1
    }

; ==============================================================================

    ; $29606-$29625 DATA
    pool DesertBarrier_Draw:
    {
    
    .subsprites
        dw -8, -8
        db $8E, $00, $00, $02
        
        dw  8, -8
        db $8E, $40, $00, $02
        
        dw -8,  8
        db $AE, $00, $00, $02
        
        dw  8,  8
        db $AE, $40, $00, $02
    }

; ==============================================================================

    ; *$29626-$29669 LOCAL
    DesertBarrier_Draw:
    {
        LDA $0DF0, X : CMP.b #$01 : BNE .no_sound_effect
        
        ; Play puzzle solved sound.
        LDY.b #$1B : STY $012F
        
        LDY.b #$05 : STY $012D
    
    .no_sound_effect
    
        LSR A : AND.b #$01 : ADD $0FD8 : STA $0FD8
        
        JSR Sprite2_DirectionToFacePlayer
        
        LDA $0F : ADD.b #$20 : CMP.b #$40 : BCS .beta
        
        LDA $0E : ADD.b #$20 : CMP.b #$40 : BCS .beta
        
        LDA.b #$10 : JSL OAM_AllocateFromRegionB
    
    .beta
    
        REP #$20
        
        LDA.w #.subsprites : STA $08
        
        SEP #$20
        
        LDA.b #$04
        
        JMP Sprite_DrawMultipleRedundantCall
    }

; ==============================================================================
