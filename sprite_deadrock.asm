
; ==============================================================================

    ; $31478-$31489 DATA
    pool Sprite_DeadRock:
    {
    
    .animation_states
        db 0, 1, 0, 1, 2, 2, 3, 3
        db 4
    
    .h_flip
        db $40, $40, $00, $00, $00, $40, $00, $40
        db $00
    }

; ==============================================================================

    ; *$3148A-$314FF JUMP LOCATION
    Sprite_DeadRock:
    {
        ; Deadrock code (Sprite 0x27)
        
        LDA $0E10, X : BEQ .petrification_inactive
        AND.b #$04   : BNE .use_normal_animation_state
    
    .use_petrified_animation_state
    
        LDY.b #$08
        
        BRA .write_animation_state
    
    .petrification_inactive
    
        LDA $0D80, X : CMP.b #$02 : BEQ .use_petrified_animation_state
    
    .use_normal_animation_state
    
        LDY $0D90, X
    
    .write_animation_state
    
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
        
        JSR Sprite_PrepAndDrawSingleLarge
        JSR Sprite_CheckIfActive
        
        LDA $0EA0, X : BNE .anoplay_sfx
        
        JSR Sprite_CheckDamageFromPlayer : BCC .anoplay_sfx
        
        LDA $012E : BNE .anoplay_sfx
        
        LDA.b #$0B : JSL Sound_SetSfx2PanLong
    
    .anoplay_sfx
    
        JSR Sprite_CheckDamageToPlayer.same_layer : BCC .no_player_collision
        
        JSL Sprite_NullifyHookshotDrag
        JSL Sprite_RepelDashAttackLong
    
    .no_player_collision
    
        LDA $0EA0, X : CMP.b #$0E : BNE .dont_activate_petrification
        
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$FF : STA $0E00, X
        
        LDA.b #$40 : STA $0E10, X
    
    .dont_activate_petrification
    
        JSR Sprite_CheckIfRecoiling
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw DeadRock_PickDirection
        dw DeadRock_Walk
        dw DeadRock_Petrified:
    }

; ==============================================================================

    ; $31500-$31505 DATA
    {
        db $20, $E0, $00, $00, $20, $E0
    }

; ==============================================================================

    ; *$31506-$31558 JUMP LOCATION
    DeadRock_PickDirection:
    {
        LDA $0DF0, X : BNE .wait
        
        ASL $0E40, X : LSR $0E40, X
        
        LDA $0CAA, X : AND.b #$FB : STA $0CAA, X
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$20 : STA $0DF0, X
        
        INC $0DA0, X : LDA $0DA0, X : CMP.b #$04 : BNE .use_random_direction
        
        STZ $0DA0, X
        
        JSR Sprite_DirectionToFacePlayer
        
        TYA
        
        BRA .set_velocity
    
    .use_random_direction
    
        JSL GetRandomInt : AND.b #$03
    
    .set_velocity
    
    ; *$31548 ALTERNATE ENTRY POINT
    shared DeadRock_SetDirectionAndSpeed:
    
        STA $0DE0, X : TAY
        
        LDA $9500, Y : STA $0D50, X
        LDA $9502, Y : STA $0D40, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; *$31559-$3158E JUMP LOCATION
    DeadRock_Walk:
    {
        LDA $0DF0, X : BNE .try_to_move
        
        STZ $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS
    
    .try_to_move
    
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .no_wall_collision
        
        LDA $0DE0, X : EOR.b #$01
        
        BRA DeadRock_SetDirectionAndSpeed
    
    .no_wall_collision
    
        INC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$01 : STA $00
        
        LDA $0DE0, X : ASL A : ORA $00 : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; *$3158F-$315C8 JUMP LOCATION
    DeadRock_Petrified:
    {
        LDA $0E40, X : ORA.b #$80 : STA $0E40, X
        
        LDA $0CAA, X : ORA.b #$04 : STA $0CAA, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDA $1A : AND.b #$01 : BNE .skip
        
        LDA $0E00, X : BNE .dont_revert
        
        STZ $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
        
        RTS
    
    .dont_revert
    
        CMP.b #$20 : BNE .gamma
        
        LDA.b #$40 : STA $0E10, X
    
    .gamma
    
        RTS
    
    .skip
    
        INC $0E00, X
        
        RTS
    }

; ==============================================================================

