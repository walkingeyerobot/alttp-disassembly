
; ==============================================================================

    ; *$ED6D1-$ED6F5 LONG
    Sprite_InitializedSegmented:
    {
        PHX : TXY
        
        LDX.b #$7F
    
    .init_segment_loop
    
        LDA $0D10, Y : STA $7FFC00, X
        LDA $0D30, Y : STA $7FFC80, X
        
        LDA $0D00, Y : STA $7FFD00, X
        LDA $0D20, Y : STA $7FFD80, X
        
        DEX : BPL .init_segment_loop
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$ED6F6-$ED6FD LONG
    Sprite_GiantMoldormLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_GiantMoldorm
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $ED6FE-$ED74D DATA
    pool Sprite_GiantMoldorm:
    {
    
    .x_speeds
        db  24,  22,  17,   9,   0,   -9, -17, -22
        db -24, -22, -17,  -9,   0,    9,  17,  22
        db  36,  33,  25,  13,   0,  -13, -25, -33
        db -36, -33, -25, -13,   0,   13,  25,  33
    
    .y_speeds
        db   0,   9,  17,  22,  24,  22,  17,   9
        db   0,  -9, -17, -22, -24, -22, -17,  -9
        db   0,  13,  25,  33,  36,  33,  25,  13
        db   0, -13, -25, -33, -36, -33, -25, -13
    
    .direction
        db  8,  9, 10, 11, 12, 13, 14, 15
        db  0,  1,  2,  3,  4,  5,  6,  7
    }

; ==============================================================================

    ; *$ED74E-$ED7FD LOCAL
    Sprite_GiantMoldorm:
    {
        JSR GiantMoldorm_Draw
        JSR Sprite4_CheckIfActive
        
        LDA $0D80, X : CMP.b #$03 : BNE .not_scheduled_for_death
        
        JMP GiantMoldorm_AwaitDeath
    
    .not_scheduled_for_death
    
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA.b #$07
        
        LDY $0E50, X : CPY.b #$03 : BCS .not_desperate_yet
        
        INC $0E80, X
        
        LDA.b #$03
    
    .not_desperate_yet
    
        INC $0E80, X
        
        AND $1A : BNE .skip_sound_effect_this_frame
        
        LDA.b #$31 : JSL Sound_SetSfx3PanLong
    
    .skip_sound_effect_this_frame
    
        LDA $0EA0, X : BEQ .not_stunned_from_damage
        
        LDA.b #$40 : STA !timer_2, X
        
        LDA $1A : AND.b #$03 : BNE .stun_timer_delay
        
        DEC $0EA0, X
    
    .stun_timer_delay
    
        RTS
    
    .not_stunned_from_damage
    
        LDA $46 : BNE .dont_repulse_player
        
        JSL Sprite_CheckDamageToPlayerLong : BCC .dont_repulse_player
        
        JSL Player_HaltDashAttackLong
        
        LDA.b #$28 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : STA $27
        
        LDA $01 : STA $28
        
        LDA.b #$18 : STA $46
        
        LDA.b #$30 : STA !timer_1, X
        
        ; Wait... how does this work? This value gets overriden by the call...
        ; I think this may be a certified \bug
        LDA.b #$32 : JSL Sound_SetSfxPan : STA $012F
    
    .dont_repulse_player
    
        LDY $0DE0, X
        
        LDA $0E50, X : CMP.b #$03 : BCS .not_desperate_2
        
        TYA : ADD.b #$10 : TAY
    
    .not_desperate_2
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite4_Move
        
        JSR Sprite4_CheckTileCollision : BEQ .no_tile_collision
        
        LDY $0DE0, X
        
        LDA .directions, Y : STA $0DE0, X
        
        ; I guess... this is where the ticking sound comes from?
        LDA.b #$21 : JSL Sound_SetSfx2PanLong
    
    .no_tile_collision
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw GiantMoldorm_StraightPath
        dw GiantMoldorm_SpinningMeander
        dw GiantMoldorm_LungeAtPlayer
    }

; ==============================================================================

    ; *$ED7FE-$ED82C JUMP LOCATION
    GiantMoldorm_StraightPath:
    {
        LDA !timer_0, X : BNE .wait
        
        LDA.b #$01
        
        INC $0ED0, X : LDY $0ED0, X : CPY.b #$03 : BNE .beta
        
        STZ $0ED0, X
        
        LDA.b #$02
    
    .beta
    
        STA $0D80, X
        
        ; \note Resultant value is either 1 or -1.
        JSL GetRandomInt : AND.b #$02 : DEC A : STA $0EB0, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$20 : STA !timer_0, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; *$ED82D-$ED851 JUMP LOCATION
    GiantMoldorm_SpinningMeander:
    {
        LDA !timer_0, X : BNE .wait
        
        JSL GetRandomInt : AND.b #$0F : ADC.b #$08 : STA !timer_0, X
        
        STZ $0D80, X
        
        RTS
    
    .wait
    
        AND.b #$03 : BNE .dont_adjust_direction
        
        LDA $0DE0, X : ADD $0EB0, X : AND.b #$0F : STA $0DE0, X
    
    .dont_adjust_direction
    
        RTS
    }

; ==============================================================================

    ; *$ED852-$ED880 JUMP LOCATION
    GiantMoldorm_LungeAtPlayer:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .frame_delay
        
        LDA.b #$1F : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        JSL Sprite_ConvertVelocityToAngle
        
        CMP $0DE0, X : BNE .current_direction_doesnt_match
        
        STZ $0D80, X
        
        LDA.b #$30 : STA !timer_0, X
        
        RTS
    
    .current_direction_doesnt_match
    
        PHP : LDA $0DE0, X : PLP : BMI .rotate_one_way
        
        ; rotate the other way... don't know if it's clockwise or counter
        ; clockwise.
        INC #2
    
    .rotate_one_way
    
        DEC A : AND.b #$0F : STA $0DE0, X
    
    .frame_delay
    
        RTS
    }

; ==============================================================================

    ; *$ED881-$ED8F1 LOCAL
    GiantMoldorm_Draw:
    {
        JSR Sprite4_PrepOamCoord
        
        LDA.b #$0B : STA $0F50, X
        
        JSR GiantMoldorm_DrawEyeballs
        
        REP #$20
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        PHX : TXY
        
        LDA $0E80, X : AND.b #$7F : TAX
        
        LDA $0D10, Y : STA $7FFC00, X
        LDA $0D00, Y : STA $7FFD00, X
        
        LDA $0D30, Y : STA $7FFC80, X
        LDA $0D20, Y : STA $7FFD80, X
        
        PLX
        
        JSR GiantMoldorm_DrawHead
        
        LDA $0DA0, X : CMP.b #$04 : BCS .dont_draw_segment
        
        JSR GiantMoldorm_DrawSegment_A
        
        LDA $0DA0, X : CMP.b #$03 : BCS .dont_draw_segment
        
        JSR GiantMoldorm_DrawSegment_B
        
        LDA $0DA0, X : CMP.b #$02 : BCS .dont_draw_segment
        
        JSR GiantMoldorm_DrawSegment_C
        
        LDA $0DA0, X : BNE .dont_draw_segment
        
        JSR GiantMoldorm_Tail
    
    .dont_draw_segment
    
        JSR GiantMoldorm_IncrementalSegmentExplosion
        JSL Sprite_Get_16_bit_CoordsLong
        
        RTS
    }

; ==============================================================================

    ; *$ED8F2-$ED912 LOCAL
    GiantMoldorm_IncrementalSegmentExplosion:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .alive_and_well
        
        LDA !timer_4, X : BEQ .delay_explosion
        CMP.b #$50      : BCS .delay_explosion
        
        AND.b #$0F : ORA $11 : ORA $0FC1 : BNE .delay_explosion
        
        ; Move on to the next segment.
        INC $0DA0, X
        
        JSL Sprite_MakeBossDeathExplosion
    
    .delay_explosion
    .alive_and_well
    
        RTS
    }

; ==============================================================================

    ; $ED913-$ED992 DATA
    pool GiantMoldorm_DrawHead:
    {
    
    .oam_groups
        dw -8, -8 : db $80, $00, $00, $02
        dw  8, -8 : db $82, $00, $00, $02
        dw -8,  8 : db $A0, $00, $00, $02
        dw  8,  8 : db $A2, $00, $00, $02
        
        dw -8, -8 : db $82, $40, $00, $02
        dw  8, -8 : db $80, $40, $00, $02
        dw -8,  8 : db $A2, $40, $00, $02
        dw  8,  8 : db $A0, $40, $00, $02
        
        dw -6, -6 : db $80, $00, $00, $02
        dw  6, -6 : db $82, $00, $00, $02
        dw -6,  6 : db $A0, $00, $00, $02
        dw  6,  6 : db $A2, $00, $00, $02
        
        dw -6, -6 : db $82, $40, $00, $02
        dw  6, -6 : db $80, $40, $00, $02
        dw -6,  6 : db $A2, $40, $00, $02
        dw  6,  6 : db $A0, $40, $00, $02
    }

; ==============================================================================

    ; *$ED993-$ED9B7 LOCAL
    GiantMoldorm_DrawHead:
    {
        LDA.b #$00 : XBA
        
        LDA !timer_1, X : AND.b #$02 : STA $00
        
        LDA $0E80, X : LSR A : AND.b #$01 : ORA $00
        
        REP #$20
        
        ASL #5 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JMP Sprite4_DrawMultiple
    }

; ==============================================================================

    ; $ED9B8-$ED9F7 DATA
    pool GiantMoldorm_DrawSegment_A:
    {
    
    .oam_groups
        dw -8, -8 : db $84, $00, $00, $02
        dw  8, -8 : db $86, $00, $00, $02
        dw -8,  8 : db $A4, $00, $00, $02
        dw  8,  8 : db $A6, $00, $00, $02
        
        dw -8, -8 : db $86, $40, $00, $02
        dw  8, -8 : db $84, $40, $00, $02
        dw -8,  8 : db $A6, $40, $00, $02
        dw  8,  8 : db $A4, $40, $00, $02
    }

; ==============================================================================

    ; \note The segment nearest the head.
    ; *$ED9F8-$EDA4F LOCAL
    GiantMoldorm_DrawSegment_A:
    {
        TXY
        
        PHX
        
        LDA $0E80, X : SUB.b #$10
    
    ; *$EDA00 ALTERNATE ENTRY POINT
    shared GiantMoldorm_DrawLargeSegment:
    
        AND.b #$7F : TAX
        
        LDA $7FFC00, X : STA $0FD8
        LDA $7FFC80, X : STA $0FD9
        
        LDA $7FFD00, X : STA $0FDA
        LDA $7FFD80, X : STA $0FDB
        
        PLX
        
        LDA.b #$00 : XBA
        
        LDA $0E80, X : LSR A : AND.b #$01
        
        REP #$20
        
        ASL #5 : ADC.w #.oam_groups : STA $08
        
        REP #$20
        
        LDA $90 : ADD.w #$0010 : STA $90
        
        LDA $92 : ADD.w #$0004 : STA $92
        
        SEP #$20
        
        SEP #$20
        
        LDA.b #$04
        
        JMP Sprite4_DrawMultiple
    }

; ==============================================================================

    ; *$EDA50-$EDA5A LOCAL
    GiantMoldorm_DrawSegment_B:
    {
        TXY
        
        PHX
        
        LDA $0E80, X : SUB.b #$1C
        
        JMP GiantMoldorm_DrawLargeSegment
    }

; ==============================================================================

    ; $EDA5B-$EDA5E DATA
    pool GiantMoldorm_DrawSegment_C:
    {
    
    .vh_flip
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; *$EDA5F-$EDAB9 LOCAL
    GiantMoldorm_DrawSegment_C:
    {
        STZ $0DC0, X
        
        REP #$20
        
        LDA $90 : ADD.w #$0010 : STA $90
        
        LDA $92 : ADD.w #$0004 : STA $92
        
        SEP #$20
        
        TXY
        
        PHX
        
        LDA $0E80, X : SUB.b #$28
    
    ; *$EDA7E ALTERNATE ENTRY POINT
    shared GiantMoldorm_PrepAndDrawSingleLargeLong:
    
        AND.b #$7F : TAX
        
        LDA $7FFC00, X : STA $0FD8
        LDA $7FFC80, X : STA $0FD9
        
        LDA $7FFD00, X : STA $0FDA
        LDA $7FFD80, X : STA $0FDB
        
        PLX
        
        LDA $0E80, X : LSR A : AND.b #$03 : TAY
        
        LDA $0F50, X : PHA
        
        AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        PLA : STA $0F50, X
        
        RTS
    }

; ==============================================================================

    ; *$EDABA-$EDB16 LOCAL
    GiantMoldorm_Tail:
    {
        JSR GiantMoldorm_DrawTail
        
        LDA !timer_2, X : BNE .temporarily_invulnerable
        
        LDA.b #$01 : STA $0D90, X
        
        STZ $0F60, X
        STZ $0CAA, X
        
        LDA $0D10, X : PHA
        LDA $0D30, X : PHA
        
        LDA $0D00, X : PHA
        LDA $0D20, X : PHA
        
        LDA $0FD8 : STA $0D10, X
        LDA $0FD9 : STA $0D30, X
        
        LDA $0FDA : STA $0D00, X
        LDA $0FDB : STA $0D20, X
        
        JSL Sprite_CheckDamageFromPlayerLong
        
        STZ $0D90, X
        
        LDA.b #$09 : STA $0F60, X
        LDA.b #$04 : STA $0CAA, X
        
        PLA : STA $0D20, X
        PLA : STA $0D00, X
        
        PLA : STA $0D30, X
        PLA : STA $0D10, X
    
    .temporarily_invulnerable
    
        RTS
    }

; ==============================================================================

    ; *$EDB17-$EDB3D LOCAL
    GiantMoldorm_DrawTail:
    {
        REP #$20
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        LDA $92 : ADD.w #$0001 : STA $92
        
        SEP #$20
        
        INC $0DC0, X
        
        LDA.b #$0D : STA $0F50, X
        
        TXY
        PHX
        
        LDA $0E80, X : SUB.b #$30
        
        JMP GiantMoldorm_PrepAndDrawSingleLargeLong
    }

; ==============================================================================

    ; $EDB3E-$EDB9D DATA
    pool GiantMoldorm_DrawEyeballs:
    {
    
    .x_offsets
        dw  16,  15,  12,   6,   0,  -6, -12, -13
        dw -16, -13, -12,  -6,   0,   6,  12,  15
    
    .y_offsets
        dw   0,   6,  12,  15,  16,  15,  12,   6
        dw   0,  -6, -12, -13, -16, -13, -12,  -6
    
    .chr
        db $AA, $AA, $A8, $A8, $8A, $8A, $A8, $A8
        db $AA, $AA, $A8, $A8, $8A, $8A, $A8, $A8
    
    .vh_flip
        db $00, $00, $00, $00, $80, $80, $40, $40
        db $40, $40, $C0, $C0, $00, $00, $80, $80
    }

; ==============================================================================

    ; *$EDB9E-$EDC10 LOCAL
    GiantMoldorm_DrawEyeballs:
    {
        STZ $07
        
        LDA $0EA0, X : BEQ .dont_accelerate_eyerolling
        
        LDA $1A : STA $07
    
    .dont_accelerate_eyerolling
    
        LDA $0DE0, X : ADD.b #$FF : STA $06
        
        PHX
        
        LDX.b #$01
    
    .draw_eyes_loop
    
        LDA $06 : AND.b #$0F : ASL A : PHX : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADC.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        LDA $06 : ADD $07 : AND.b #$0F : TAX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA .vh_flip, X : ORA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : ORA.b #$02 : STA ($92), Y
        
        LDA $06 : ADD.b #$02 : STA $06
        
        PLY : INY
        
        PLX : DEX : BPL .draw_eyes_loop
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$EDC11-$EDC29 JUMP LOCATION
    GiantMoldorm_AwaitDeath:
    {
        LDA !timer_4, X : BNE .delay
    
    ; *$EDC16 ALTERNATE ENTRY POINT
    Sprite_ScheduleBossForDeath:
    
        LDA.b #$04 : STA $0DD0, X
        
        STZ $0D90, X
        
        LDA.b #$E0 : STA !timer_0, X
        
        RTS
    
    .delay
    
        ORA.b #$E0 : STA $0EF0, X
        
        RTS
    }

; ==============================================================================

    ; *$EDC2A-$EDC71 LONG
    Sprite_MakeBossDeathExplosion:
    {
        LDA.b #$0C : JSL Sound_SetSfx2PanLong
    
    ; *$EDC30 ALTERNATE ENTRY POINT
    .silent
    
        ; Spawn a.... raven? What? Oh it's just a dummy sprite that will be
        ; transmuted to an explosion.
        LDA.b #$00 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$0B : STA $0AAA
        
        LDA.b #$04 : STA $0DD0, Y
        LDA.b #$03 : STA $0E40, Y
        LDA.b #$0C : STA $0F50, Y
        
        LDA $0FD8 : STA $0D10, Y
        LDA $0FD9 : STA $0D30, Y
        
        LDA $0FDA : STA $0D00, Y
        LDA $0FDB : STA $0D20, Y
        
        LDA.b #$1F : STA !timer_0, Y
                     STA $0D90, Y
        
        LDA.b #$02 : STA $0F20, Y
    
    .spawn_failed
    
        RTL
    }

; ==============================================================================
