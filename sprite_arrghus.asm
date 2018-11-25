
    ; \note This sprite uses $0B08[0x05] as some extra scratch ram. This is
    ; probably ill-advised, but bosses always seem to want to break the rules.
    ;
    ; $0B08[0x02] - 
    ;   
    ;   Accumulator for angular offset of the Arrgi?
    ; 
    ; $0B0A[0x01] - 
    ;   
    ;   Radius of Arrgi during the swarm attack.
    ;
    ; $0B0B[0x01] - 
    ;   
    ;   Counter for number of times Arrghus has accelerated and then
    ;   decelerated. When it hits 4, it resets to 0, and a swarm attack with
    ;   the Arrgi occurs.
    ;
    ; $0B0C[0x01] - 
    ;   
    ;   Amount to increase the angular offset by each frame. Normally 1 unless
    ;   the swarm attack is in effect, in which it is set to 8 temporarily.

; =============================================================================

    ; $F342A-$F3432 DATA
    pool Sprite_Arrghus:
    {
    
    .animation_states
        db $01, $01, $01, $02, $02, $01, $01, $00
        db $00
    }

; ==============================================================================

    ; *$F3433-$F34C9 JUMP LOCATION
    Sprite_Arrghus:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR Arrghus_Draw
        
        LDA $0DD0, X : CMP.b #$09 : BNE .dying
        
        LDA $0F70, X : CMP.b #$60 : BCS .ignore_activity_check
    
    .dying
    
        JSR Sprite3_CheckIfActive
    
    .ignore_activity_check
    
        JSR $B6E9 ; $F36E9 IN ROM
        
        LDA.b #$01 : STA $0B0C
        
        LDA $0EF0, X : AND.b #$7F : CMP.b #$02 : BNE BRANCH_GAMMA
        
        JSR Arrghus_InitiateJumpWayUp
        
        ; Make it impervious temporarily...
        LDA.b #$40 : STA $0E60, X
    
    BRANCH_GAMMA:
    
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamageToPlayer
        
        LDA $0E80, X : INC $0E80, X : AND.b #$03 : BNE BRANCH_DELTA
        
        INC $0ED0, X : LDA $0ED0, X : CMP.b #$09 : BNE BRANCH_EPSILON
        
        STZ $0ED0, X
    
    BRANCH_EPSILON:
    
        LDY $0ED0, X
        
        LDA .animation_states, Y : STA $0DC0, X
    
    BRANCH_DELTA:
    
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        LDY $0D80, X : CPY.b #$05 : BNE .ignore_collision_result
        
        AND.b #$03 : BEQ .no_horiz_collision
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        BRA .run_subprogram
    
    .no_horiz_collision
    
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        BRA .run_subprogram
    
    .ignore_collision_result
    
        JSR Sprite3_Zero_XY_Velocity
    
    .run_subprogram
    .no_tile_collision
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Arrghus_ApproachTargetSpeed
        dw Arrghus_Decelerate
        dw $B63D ; = $F363D*
        dw Arrghus_JumpWayUp
        dw Arrghus_SmooshFromAbove
        dw Arrghus_SwimFrantically
    }

; ==============================================================================

    ; *$F34CA-$F34EE JUMP LOCATION
    Arrghus_JumpWayUp:
    {
        LDA.b #$78 : STA $0F80, X
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F70, X : CMP.b #$E0 : BCC .continue_rising
        
        LDA.b #$40 : STA $0DF0, X
        
        INC $0D80, X
        
        STZ $0F80, X
        
        ; Try to plop down on the player by matching their coordinates.
        LDA $22 : STA $0D10, X
        
        LDA $20 : STA $0D00, X
    
    .continue_rising
    
        RTS
    }

; ==============================================================================

    ; *$F34EF-$F3531 JUMP LOCATION
    Arrghus_SmooshFromAbove:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$90 : STA $0F80, X
        
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        PLA : EOR $0F70, X : BPL .didnt_touch_down
        
        LDA $0F70, X : BPL .didnt_touch_down
        
        STZ $0F70, X
        
        JSL Sprite_SpawnSplashRingLong
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA.b #$03 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$20 : STA $0D50, X : STA $0D40, X
    
    .didnt_touch_down
    .delay
    
        DEC A : BNE .dont_play_falling_sound
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
    
    .dont_play_falling_sound
    
        RTS
    }

; ==============================================================================

    ; *$F3532-$F3592 JUMP LOCATION
    Arrghus_SwimFrantically:
    {
        LDA $0DF0, X : BNE .delay
        
        ; Unset impervious status.
        STZ $0E60, X
        
        JSR Sprite3_Move
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA $1A : AND.b #$07  BNE .garnish_delay
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
        
        PHX : TXY
        
        LDX.b #$1D
        
        LDA $0D40, Y : BMI .use_full_range
        
        LDX.b #$0E
    
    .use_full_range
    .try_another_index
    
        LDA $7FF800, X : BNE .slot_in_use
        
        LDA.b #$15 : STA $7FF800, X : STA $0FB4
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$18 : STA $7FF81E, X
        LDA $0D20, Y              : STA $7FF85A, X
        
        LDA.b #$0F : STA $7FF90E, X
        
        PLX
        
        RTS
    
    .slot_in_use
    
        DEX : BPL .try_another_index
        
        PLX
    
    .garnish_delay
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$F3593-$F35C7 JUMP LOCATION
    Arrghus_ApproachTargetSpeed:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
    
    .delay
    
        JSR Sprite3_Move
        
        LDA $0D50, X : CMP $0EB0, X : BEQ .x_speed_matches_target
                                      BPL .decrease_x_speed
        
        INC $0D50, X
        
        BRA .check_y_speed
    
    .decrease_x_speed
    
        DEC $0D50, X
    
    .x_speed_matches_target
    .check_y_speed
    
        LDA $0D40, X : CMP $0DE0, X : BEQ .y_speed_matches_target
                                      BPL .decrease_y_speed
        
        INC $0D40, X
        
        BRA .return
    
    .decrease_y_speed
    
        DEC $0D40, X
    
    .return
    .y_speed_matches_target
    
        RTS
    }

; ==============================================================================

    ; *$F35C8-$F363C JUMP LOCATION
    Arrghus_Decelerate:
    {
        LDA $0DF0, X : BNE .decelerate
        
        STZ $0D80, X
        
        ; Checks to see if all his bebehs are ded.
        JSL Sprite_VerifyAllOnScreenDefeated : BCS .arrgi_all_dead
        
        ; \note What the hell Arrghus... why you dipping into Overlord memory
        ; regions?
        INC $0B0B : LDA $0B0B : CMP.b #$04 : BNE .arrgi_attack_delay
        
        STZ $0B0B
        
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$B0 : STA $0DF0, X
        
        RTS
    
    .arrgi_all_dead
    
    ; *$F35EE ALTERNATE ENTRY POINT
    shared Arrghus_InitiateJumpWayUp:
    
        LDA.b #$03 : STA $0D80, X
        
        LDA.b #$32 : JSL Sound_SetSfx3PanLong
        
        STZ $0E80, X
        
        RTS
    
    .arrgi_attack_delay
    
        JSL GetRandomInt : AND.b #$3F : ADC.b #$30 : STA $0DF0, X
        
        AND.b #$03 : ADC.b #$08 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : STA $0DE0, X
        LDA $01 : STA $0EB0, X
        
        RTS
    
    .decelerate
    
        JSR Sprite3_Move
        
        LDA $0D50, X : BEQ .x_speed_is_zero
                       BPL .decrease_x_speed
        
        INC $0D50, X
        
        BRA .decelerate_y_speed
    
    .decrease_x_speed
    
        DEC $0D50, X
    
    .declerate_y_speed
    .x_speed_is_zero
    
        LDA $0D40, X : BEQ .y_speed_is_zero
                       BPL .decrease_y_speed
        
        INC $0D40, X
        
        BRA .return
    
    .decrease_y_speed
    
        DEC $0D40, X
    
    .return
    .y_speed_is_zero
    
        RTS
    }

; ==============================================================================

    ; *$F363D-$F3673 JUMP LOCATION
    {
        LDA.b #$08 : STA $0B0C
        
        LDA $0DF0, X : CMP.b #$20 : BCC .decrease_radius
                       CMP.b #$60 : BCS .dont_adjust_radius
        
        INC $0B0A
        
        RTS
    
    .decrease_radius
    
        DEC $0B0A : BMI .finished_arrgi_attack
        
        RTS
    
    .dont_adjust_radius
    
        BNE BRANCH_DELTA
        
        ; \task Figure out if this code is ever reached, and if so, how???!!!
        LDA.b #$26 : BRA .play_sound_effect
    
    BRANCH_DELTA:
    
        AND.b #$0F : BNE .sound_effect_delay
        
        LDA.b #$06
    
    .play_sound_effect
    
        JSL Sound_SetSfx3PanLong
    
    .sound_effect_delay
    
        RTS
    
    .finished_arrgi_attack
    
        STZ $0B0A
        
        DEC $0D80, X
        
        LDA.b #$70 : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; $F3674-$F36E8 DATA
    {
        dw $0000, $0040, $0080, $00C0, $0100, $0140, $0180, $01C0
        dw $0000, $0066, $00CC, $0132, $0198
        
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $01FF, $01FF, $01FF, $01FF, $01FF
        
        db $14, $14, $14, $14, $14, $14, $14, $14
        db $0C, $0C, $0C, $0C, $0C
    
    ; $B6B5 \task fill in the rest of this data.
        db $00, $FF, $FE, $FD
    }

; ==============================================================================

    ; *$F36E9-$F3817 LOCAL
    {
        LDA $0B08 : ADD $0B0C  : STA $0B08
        LDA $0B09 : ADC.b #$00 : STA $0B09
        
        LDA $1A : AND.b #$03 : BNE .increment_delay
        
        INC $0D90, X : LDA $0D90, X : CMP.b #$0D : BNE .anoreset_counter
        
        STZ $0D90, X
    
    .increment_delay
    .anoreset_counter
    
        LDA $1A : AND.b #$07 : BNE .increment_delay_2
        
        INC $0DA0, X : LDA $0DA0, X : CMP.b #$0D : BNE .anoreset_counter_2
        
        STZ $0DA0, X
    
    .increment_delay_2
    .anoreset_counter_2
    
        STZ $0FB5
    
    .next_arrgi
    
        LDA $0FB5 : PHA : ASL A : TAY
        
        REP #$20
        
        LDA $0B08 : ADD $B674, Y : EOR $B68E, Y : STA $00
        
        SEP #$20
        
        PLY
        
        LDA $0B0A : ADD $B6A8, Y : STA $0E
                                   STA $0F
        
        LDA $0FB5 : STA $02
        
        LDA $0D90, X : ADD $02 : TAY
        
        LDA $0F : ADD $B6B5, Y : STA $0F
        
        LDA $0DA0, X : ADD $02 : TAY
        
        LDA $0E : ADD $B6B5, Y : STA $0E
        
        PHX
        
        REP #$30
        
        LDA $00 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $04
        
        LDA $00 : ADD.w #$0080 : STA $02 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $06
        
        SEP #$30
        
        PLX
        
        LDA $04 : STA $4202
        
        LDA $0F
        
        LDY $05 : BNE BRANCH_GAMMA
        
        STA $4203
        
        JSR Sprite3_DivisionDelay
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_GAMMA:
    
        LSR $01 : BCC BRANCH_DELTA
        
        EOR.b #$FF : INC A
    
    BRANCH_DELTA:
    
        STZ $0A
        
        CMP.b #$00 : BPL .x_adjustment_positive
        
        DEC $0A
    
    .x_adjustment_positive
    
        ADD $0D10, X : LDY $0FB5 : STA $0B10, Y
        LDA $0D30, X : ADC $0A   : STA $0B20, Y
        
        LDA $06 : STA $4202
        
        LDA $0E
        
        LDY $07 : BNE BRANCH_ZETA
        
        STA $4203
        
        JSR Sprite3_DivisionDelay
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_ZETA:
    
        LSR $03 : BCC BRANCH_THETA
        
        EOR.b #$FF : INC A
    
    BRANCH_THETA:
    
        STZ $0A
        
        CMP.b #$00 : BPL .y_adjustment_positive
        
        DEC $0A
    
    .y_adjustment_positive
    
        ADD $0D00, X : PHP : SUB.b #$10 : LDY $0FB5     : STA $0B30, Y
        LDA $0D20, X       : SBC.b #$00 : PLP : ADC $0A : STA $0B40, Y
        
        ; \task More of a note, but if our new assembler can handle meta branch
        ; instructions (that can dynamically resize at assembly time), we could
        ; replace this with "BNE .next_arrgi", and remove the JMP instruction.
        INC $0FB5 : LDA $0FB5 : CMP.b #$0D : BEQ .return
        
        JMP .next_arrgi
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $F3818-$F383F DATA
    pool Arrghus_Draw:
    {
    
    .oam_groups
        dw -8, -4 : db $80, $00, $00, $02
        dw  8, -4 : db $80, $40, $00, $02
        dw -8, 12 : db $A0, $00, $00, $02
        dw  8, 12 : db $A0, $40, $00, $02
        dw  0, 24 : db $A8, $00, $00, $02   
    }

; ==============================================================================

    ; *$F3840-$F38B3 LOCAL
    Arrghus_Draw:
    {
        REP #$20
        
        LDA.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$05 : JSR Sprite3_DrawMultiple
        
        LDA $0DC0, X : ASL A : STA $00
        
        LDY.b #$02
    
    .adjust_upper_chr
    
        LDA ($90), Y : ADD $00 : STA ($90), Y
        
        INY #4 : CPY.b #$12 : BCC .adjust_upper_chr
        
        LDA $0D80, X : CMP.b #$05 : BNE .dont_hide_some_portion
        
        LDY.b #$11 : LDA.b #$F0 : STA ($90), Y
    
    .dont_hide_some_portion
    
        LDA $0E80, X : AND.b #$08 : BEQ .dont_hflip_some_portion
        
        LDY.b #$13 : LDA ($90), Y : ORA.b #$40 : STA ($90), Y
    
    .dont_hflip_some_portion
    
        ; \task verify this assessment, as we're flying blind, somewhat.
        LDA $0D80, X : CMP.b #$05 : BEQ .draw_water_ripples
        
        REP #$20
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        ; \task Also verify this assessment that it controls shadow drawing.
        LDA $0F70, X : CMP.b #$A0 : BCS .dont_draw_shadow
        
        LDA $0F50, X : PHA : AND.b #$FE : STA $0F50, X
        
        JSL Sprite_DrawLargeShadow
        
        PLA : STA $0F50, X
    
    .dont_draw_shadow
    
        RTS
    
    .draw_water_ripples
    
        JSL Sprite_DrawLargeWaterTurbulence
        
        RTS
    }

; ==============================================================================
