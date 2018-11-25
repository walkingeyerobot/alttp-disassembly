
; ==============================================================================

    ; *$F0FDF-$F0FFF LOCAL
    Sprite_StalfosBone:
    {
        JSR StalfosBone_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckDamageToPlayer
        
        INC $0E80, X
        
        JSR Sprite3_Move
        
        LDA !timer_0, X : BNE .dont_self_terminate
        
        JSR Sprite3_CheckTileCollision : BEQ .dont_self_terminate
        
        STZ $0DD0, X
        
        JSL Sprite_PlaceRupulseSpark
    
    .dont_self_terminate
    
        RTS
    }

; ==============================================================================

    ; $F1000-$F103F DATA
    pool StalfosBone_Draw:
    {
    
    .oam_groups
        dw -4, -2 : db $2F, $80, $00, $00
        dw  4,  2 : db $2F, $40, $00, $00
        
        dw -4,  2 : db $2F, $00, $00, $00
        dw  4, -2 : db $2F, $C0, $00, $00
        
        dw  2, -4 : db $3F, $40, $00, $00
        dw -2,  4 : db $3F, $80, $00, $00
        
        dw -2, -4 : db $3F, $00, $00, $00
        dw  2,  4 : db $3F, $C0, $00, $00
    }

; ==============================================================================

    ; *$F1040-$F105B LOCAL
    StalfosBone_Draw:
    {
        LDA.b #$00   : XBA
        
        LDA $0E80, X : LSR #2 : AND.b #$03 : REP #$20 : ASL #4
        
        ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite3_DrawMultiple
    }

; ==============================================================================

    ; $F105C-$F106B DATA
    pool Stalfos:
    {
    
    .timers
        db $10, $20, $40, $20
    
    .animation_states_1
        db $06, $04, $00, $02, $07, $05, $01, $03
    
    .animation_states_2
        db $08, $09, $0A, $0B
    }

; ==============================================================================

    ; *$F106C-$F10B0 JUMP LOCATION
    Sprite_Stalfos:
    {
        LDA $0D90, X : BEQ .not_bone
        
        JMP Sprite_StalfosBone
    
    .not_bone
    
        LDA $0E90, X : BEQ Stalfos_Visible
        
        LDA !timer_0, X : BNE .delay
        
        LDA.b #$01 : STA $0D50, X : STA $0D40, X
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        STZ $0DD0, X
        
        RTS
    
    .no_tile_collision
    
        STZ $0E90, X
        
        LDA.b #$15 : JSL Sound_SetSfx2PanLong
        
        JSL Sprite_SpawnPoofGarnish
        
        LDA.b #$08 : STA !timer_2, X
        
        LDA.b #$40 : STA !timer_0, X
        
        STZ $0D40, X
        
        STZ $0D50, X
    
    .delay
    
        JSL Sprite_PrepOamCoordLong
        
        RTS
    }

; ==============================================================================

    ; $F10B1-$F10B4 DATA
    pool Stalfos_Visible:
    {
        db $03, $02, $01, $00
    }

; ==============================================================================

    ; *$F10B5-$F122A BRANCH LOCATION
    Stalfos_Visible:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .dont_dodge
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0028 : CMP.w #$0050 : BCS .dont_dodge
        LDA $20 : SUB $0FDA : ADD.w #$0030 : CMP.w #$0050 : BCS .dont_dodge
        
        SEP #$20
        
        LDA $44 : CMP.b #$80 : BEQ .dont_dodge
        
        LDA $0F70, X : ORA $0F00, X : BNE .dont_dodge
        
        LDA $EE : CMP $0F20, X : BNE .dont_dodge
        
        JSR Sprite3_DirectionToFacePlayer
        
        STY $00
        
        LDA $0372 : BNE .dodge
        
        LDA $3C : CMP.b #$90 : BCS .face_player_then_dodge
        CMP.b #$09           : BPL .dont_dodge
    
    .dodge
    
        LDA $2F : LSR A : TAY
        
        LDA $00 : CMP $90B1, Y : BEQ .dont_dodge
    
    .face_player_then_dodge
    
        LDA $00 : STA $0DE0, X
        
        LDA.b #$20 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $01 : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $00 : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$13 : JSL Sound_SetSfx3PanLong
        
        INC $0F70, X
    
    .dont_dodge
    
        SEP #$20
        
        LDA $0F70, X : BEQ .not_dodging
        
        LDY $0DE0, X
        
        LDA Stalfos.animation_states_2, Y : STA $0DC0, X
        
        JSL Stalfos_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0EA0, X : BEQ .not_in_recoil
        
        STZ $0F80, X
    
    .not_in_recoil
    
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        JSR Sprite3_CheckTileCollision
        
        PHA
        
        AND.b #$03 : BEQ .no_horiz_tile_collision
        
        STZ $0D50, X
    
    .no_horiz_tile_collision
    
        PLA : AND.b #$0C : BEQ .no_vert_tile_collision
        
        STZ $0D40, X
    
    .no_horiz_tile_collision
    
        JSR Sprite3_MoveXyz
        
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        LDA $0F70, X : DEC A : BPL .in_air
        
        STZ $0F70, X
        
        JSR Sprite3_Zero_XY_Velocity
        
        LDA.b #$21 : JSL Sound_SetSfx2PanLong
        
        LDA $0E30, X : BEQ .not_red_stalfos
        
        ; Throw a bone at the player
        LDA.b #$10 : STA !timer_3, X
        
        STZ $0E80, X
    
    .not_red_stalfos
    .in_air
    
        RTS
    
    .not_dodging
    
    ; *$F119F ALTERNATE ENTRY POINT
    shared Sprite_Zazak:
    
        LDA $0DA0, X : BEQ .not_fire_phlegm
        
        JSR FirePhlegm_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $1A : LSR A : AND.b #$01 : STA $0DC0, X
        
        JSR Sprite3_CheckDamageToPlayer
        JSR Sprite3_Move
        
        JSR Sprite3_CheckTileCollision : BEQ .no_repulse_spark
        
        STZ $0DD0, X
        
        JSL Sprite_PlaceRupulseSpark.coerce
    
    .no_repulse_spark
    
        RTS
    
    .not_fire_phlegm
    
        ; \note Due to all this shared code, a Zazak could in theory be made
        ; to throw a bone, and a stalfos could be made to shoot fire phlegm.
        LDA !timer_3, X : BEQ .bone_throw_timer_inactive
        
        PHA
        
        STZ $0D80, X
        
        LDA.b #$20 : STA !timer_0, X
        
        JSR Sprite3_Zero_XY_Velocity
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0EB0, X
        
        PLA
    
    .bone_throw_timer_inactive
    
        CMP.b #$01 : BNE .dont_throw_bone
        
        JSR Stalfos_ThrowBoneAtPlayer
        
        LDA.b #$01 : STA $0E80, X
    
    .dont_throw_bone
    
        LDA $0E80, X : AND.b #$01 : ASL #2 : ADC $0DE0, X : TAY
        
        LDA Stalfos.animation_states_1, Y : STA $0DC0, X
        
        LDA $0E20, X : CMP.b #$A7 : BNE .not_stalfos
        
        JSL Stalfos_Draw
        JSR Sprite3_CheckIfActive
        
        BRA .moving_on
    
    .not_stalfos
    
        JSL Zazak_Draw
        JSR Sprite3_CheckIfActive
    
    .moving_on
    
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        JSR Sprite3_Move
        JSR Sprite3_CheckTileCollision
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Zazak_WalkThenTrackHead
        dw Zazak_HaltAndPickNextDirection
        dw Zazak_ShootFirePhlegm
    }

; ==============================================================================

    ; \note Walks in straight line, ignoring collision, and then uses the
    ; direction the head is facing as the next direction to walk in (in the
    ; next state).
    ; *$F122B-$F1253 JUMP LOCATION
    Zazak_WalkThenTrackHead:
    {
        LDA !timer_0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA Stalfos.timers, Y : STA !timer_0, X
        
        INC $0D80, X
        
        LDA $0EB0, X : STA $0DE0, X : TAY
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        LDA Sprite3_Shake.y_speeds, Y : STA $0D40, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F1254-$F125B DATA
    pool Zazak_HaltAndPickNextDirection:
    {
    
    .head_orientations
        db 2, 3, 2, 3, 0, 1, 0, 1
    }

; ==============================================================================

    ; *$F125C-$F12D1 JUMP LOCATION
    Zazak_HaltAndPickNextDirection:
    {
        LDA.b #$10
        
        LDY $0E70, X : BNE .select_new_direction
        
        LDA !timer_0, X : BNE .just_animate
        
        LDA $0E20, X : CMP.b #$A6 : BNE .not_red_zazak
        
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : CMP $0DE0, X : BNE .dont_shoot_player
        
        LDA $EE : CMP $0F20, X : BNE .dont_shoot_player
        
        INC $0D80, X
        
        LDA.b #$30 : STA !timer_0, X
                     STA !timer_1, X
        
        BRA .zero_xy_velocity
    
    .dont_shoot_player
    
        LDA.b #$20
    
    .not_red_zazak
    .select_new_direction
    
        STA !timer_0, X
        
        JSL GetRandomInt : LSR A : LDA $0DE0, X : ROL A : TAY
        
        LDA .head_orientations, Y : STA $0EB0, X
        
        STZ $0D80, X
        
        INC $0DB0, X : LDA $0DB0, X : CMP.b #$04 : BNE .zero_xy_velocity
        
        STZ $0DB0, X
        
        ; In this case, directly face the player and walk towards them.
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0EB0, X
        
        LDA.b #$18 : STA !timer_0, X
    
    .zero_xy_velocity
    
    ; *$F12BD ALTERNATE ENTRY POINT
    shared Sprite3_Zero_XY_Velocity:
    
        STZ $0D50, X
        STZ $0D40, X
        
        RTS
    
    .just_animate
    
        DEC $0ED0, X : BPL .animation_timer_not_expired
        
        LDA.b #$0B : STA $0ED0, X
        
        INC $0E80, X
    
    .animation_timer_not_expired
    
        RTS
    }

; ==============================================================================

    ; *$F12D2-$F12E3 JUMP LOCATION
    Zazak_ShootFirePhlegm:
    {
        LDA !timer_0, X : BNE .delay_ai_state_revert
        
        STZ $0D80, X
        
        RTS
    
    .delay_ai_state_revert
    
        CMP.b #$18 : BNE .delay_firing_phlegm
        
        JSL Sprite_SpawnFirePhlegm
    
    .delay_firing_phlegm
    
        RTS
    }

; ==============================================================================

    ; *$F12E4-$F1378 LONG
    Sprite_SpawnFirePhlegm:
    {
        PHB : PHK : PLB
        
        LDA.b #$A5 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$05 : JSL Sound_SetSfx3PanLong
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        LDA $0DE0, X : TAX
        
        LDA $00 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low,  X : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA $0E60, Y : ORA.b #$40 : STA $0E60, Y
        
        LDA.b #$40 : STA $0CAA, Y
        
        LDA.b #$21 : STA $0E40, Y
                     STA $0DA0, Y
        
        LDA.b #$02 : STA $0F50, Y
        
        LDA.b #$14 : STA $0F60, Y
                     STA $0BA0, Y
        
        LDA.b #$25 : STA $0CD2, Y
        
        ; Seems counterintuive as the blockable code I thought handles shield
        ; levels on its own, unless this is just to save time.
        LDA $7EF35A : CMP.b #$03 : BCC .unblockable
        
        LDA.b #$20 : STA $0BE0, Y
    
    .unblockable
    
        PLX
    
    .spawn_failed
    
        PLB
        
        RTL
    
    .x_speeds length 4
        db  48, -48
    
    .y_speeds
        db   0,   0,  48, -48
    
    .x_offsets_low
        db 16, -8,  4,  4
    
    .x_offsets_high
        db  0, -1,  0,  0
    
    .y_offsets_low
        db -2, -2,  8, -4
    
    .y_offsets_high
        db -1, -1,  0,  0
    }

; ==============================================================================

    ; *$F1379-$F13C2 LOCAL
    Stalfos_ThrowBoneAtPlayer:
    {
        LDA.b #$A7 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$01 : STA $0D90, Y
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        TYX
        
        LDA.b #$20 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA.b #$21 : STA $0E40, X : STA $0BA0, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDA.b #$48 : STA $0CAA, X
        
        LDA.b #$10 : STA !timer_0, X
        
        LDA.b #$14 : STA $0F60, X
        
        LDA.b #$07 : STA $0F50, X
        
        LDA.b #$20 : STA $0CD2, X
        
        PLX
        
        LDA.b #$02 : JSL Sound_SetSfx2PanLong
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $F13C3-$F1442 DATA
    pool FirePhlegm_Draw:
    {
    
    .oam_entries
        dw  0,  0 : db $C3, $00, $00, $00
        dw -8,  0 : db $C2, $00, $00, $00
        
        dw  0,  0 : db $C3, $80, $00, $00
        dw -8,  0 : db $C2, $80, $00, $00
        
        dw  0,  0 : db $C3, $40, $00, $00
        dw  8,  0 : db $C2, $40, $00, $00
        
        dw  0,  0 : db $C3, $C0, $00, $00
        dw  8,  0 : db $C2, $C0, $00, $00
        
        dw  0,  0 : db $D4, $00, $00, $00
        dw  0, -8 : db $D3, $00, $00, $00
        
        dw  0,  0 : db $D4, $40, $00, $00
        dw  0, -8 : db $D3, $40, $00, $00
        
        dw  0,  0 : db $D4, $80, $00, $00
        dw  0,  8 : db $D3, $80, $00, $00
        
        dw  0,  0 : db $D4, $C0, $00, $00
        dw  0,  8 : db $D3, $C0, $00, $00
    }

; ==============================================================================

    ; *$F1443-$F145F LOCAL
    FirePhlegm_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DE0, X : ASL A : ADD $0DC0, X : REP #$20 : ASL #4
        
        ADC.w #.oam_entries : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite3_DrawMultiple
    }

; ==============================================================================

