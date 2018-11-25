
; ==============================================================================

    ; *$F3002-$F3054 JUMP LOCATION
    Sprite_Zol:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .skip_initial_collision_check
        
        LDA $0E90, X : BEQ .skip_initial_collision_check
        
        STZ $0E90, X
        
        LDA.b #$01 : STA $0D50, X
        
        JSR Sprite3_CheckTileCollision
        
        STZ $0D50, X
        
        BEQ .anoself_terminate
        
        STZ $0DD0, X
        
        RTS
    
    .anoself_terminate
    
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
    
    .skip_initial_collision_check
    
        LDA $0DB0, X : BEQ .use_oam_normal_priority_scheme
        
        LDA.b #$30 : STA $0B89, X
    
    .use_oam_normal_priority_scheme
    
        JSR Zol_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X : CMP.b #$02 : BCC .cant_damage_player
        
        JSL Sprite_CheckDamageFromPlayerLong
    
    .cant_damage_player
    
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Zol_HidingUnseen
        dw Zol_PoppingOut
        dw Zol_Falling
        dw Zol_Active
    }

; ==============================================================================

    ; *$F3055-$F309E JUMP LOCATION
    Zol_HidingUnseen:
    {
        LDA $0F60, X : PHA : ORA.b #$09 : STA $0F60, X
        
        LDA $0E40, X : ORA.b #$80 : STA $0E40, X
        
        JSR Sprite3_CheckDamageToPlayer
        
        PLA : STA $0F60, X : BCC .didnt_touch_player
        
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
        
        ; Clear untouchable bit.
        ASL $0E40, X : LSR $0E40, X
        
        LDA $22 : STA $0D10, X
        LDA $23 : STA $0D30, X
        
        LDA $20 : ADD.b #$08 : STA $0D00, X
        LDA $21 : ADC.b #$00 : STA $0D20, X
        
        LDA.b #$30 : STA $0F10, X
        
        STZ $0BA0, X
    
    .didnt_touch_player
    
        RTS
    }

; ==============================================================================

    ; $F309F-$F30AE DATA
    pool Zol_PoppingOut:
    {
    
    .animation_states
        db $00, $01, $07, $07, $06, $06, $05, $05
        db $06, $06, $05, $05, $04, $04, $04, $04
    }

; ==============================================================================

    ; *$F30AF-$F30D3 JUMP LOCATION
    Zol_PoppingOut:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        ; Make the Zol jump up.
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$10 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        ; Play popping out of ground sfx.
        LDA.b #$30 : JSL Sound_SetSfx3PanLong
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F30D4-$F30D5 DATA
    pool Zol_Falling:
    {
    
    .animation_states
        db $00, $01
    }

; ==============================================================================

    ; *$F30D6-$F3143 JUMP LOCATION
    Zol_Falling:
    {
        LDA $0DF0, X : BEQ .falling_from_above
        DEC A        : BNE .hobble_around
        
        LDA.b #$20 : STA $0DF0, X
        
        INC $0D80, X
        
        STZ $0DC0, X
        
        RTS
    
    ; \task Is this label correctly named?
    .hobble_around
    
        LSR #4 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $1A : LSR A : AND.b #$01 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        JSR Sprite3_MoveHoriz
        
        RTS
    
    .falling_from_above
    
        JSL Sprite_CheckDamageFromPlayerLong
        JSR Sprite3_Move
        JSR Sprite3_CheckTileCollision
        
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F80, X : CMP.b #$C0 : BMI .fall_speed_maxed_out
        
        SUB.b #$02 : STA $0F80, X
    
    .fall_speed_maxed_out
    
        PLA : EOR $0F70, X : BPL .didnt_hit_ground
        
        LDA $0F70, X : BPL .didnt_hit_ground
        
        STZ $0F80, X
        
        STZ $0F70, X
        
        STZ $0DB0, X
        
        LDA.b #$1F : STA $0DF0, X
        
        LDA.b #$08 : STA $0EB0, X
    
    .didnt_hit_ground
    
        RTS
    
    .x_speeds
        db -8,  8
    }

; =============================================================================

    ; *$F3144-$F31C0 JUMP LOCATION
    Zol_Active:
    {
        JSR Sprite3_CheckDamageToPlayer
        
        LDA $0E00, X : BNE .delay_retargeting_player
        
        LDA.b #$30 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        JSL GetRandomInt : AND.b #$3F : ORA.b #$60 : STA $0E00, X
        
        ; Set h flip based on msb of x speed.
        ASL $0F50, X : ASL $0F50, X
        
        LDA $0D50, X : ASL A : ROR $0F50, X : LSR $0F50, X
    
    .delay_retargeting_player
    
        ; \task Figure out if this label is correctly named. Zols do get
        ; agitated though...
        LDA $0E10, X : BNE .not_agitated
        
        INC $0E80, X : LDA $0E80, X : AND.b #$0E
                                      ORA $0E70, X : BNE .deagitation_delay
        
        JSR Sprite3_Move
        
        INC $0ED0, X : LDA $0ED0, X : CMP $0EB0, X : BNE .deagitation_delay
        
        STZ $0ED0, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$40 : STA $0E10, X
        
        JSL GetRandomInt : AND.b #$1F : ORA.b #$10 : STA $0EB0, X
    
    .deagitation_delay
    
        JSR Sprite3_CheckTileCollision
        
        LDA $0E80, X : AND.b #$08 : LSR #3 : STA $0DC0, X
        
        RTS
    
    .not_agitated
    
        LDY.b #$00
        
        AND.b #$10 : BEQ .use_base_animation_state
        
        INY
    
    .use_base_animation_state
    
        TYA : STA $0DC0, X
        
        RTS
    }

; =============================================================================

    ; $F31C1-$F31C4 DATA
    pool Zol_Draw:
    {
    
    .hflip_states
        db $00, $00, $40, $40
    }

; =============================================================================

    ; *$F31C5-$F3213 LOCAL
    Zol_Draw:
    {
        LDA $0F50, X : LSR A : BCS .skip_unknown_check
        
        ; \task What the hell are this and the branch instruction above for?
        LDA $0FC6 : CMP.b #$03 : BCS .return
    
    .skip_unknown_check
    
        LDA $0F10, X : BEQ .draw_in_front_of_player
        
        ; Draw behind player.
        LDA.b #$08 : JSL OAM_AllocateFromRegionB
    
    .draw_in_front_of_player
    
        LDA $0D80, X : BEQ .not_visible
        
        LDA $0DC0, X : CMP.b #$04 : BCS Zol_DrawMultiple
        
        PHA : TAY
        
        LDA $0F50, X : PHA
        
        EOR .hflip_states, Y : STA $0F50, X
        
        ; \wtf With all the use of $0F50, X?
        AND.b #$01 : EOR.b #$01 : ASL #2 : ADD $0DC0, X : STA $0DC0, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        PLA : STA $0F50, X
        PLA : STA $0DC0, X
        
        RTS
    
    .not_visible
    
        ; \wtf Am I to understand that this is doing anything useful?
        JSL Sprite_PrepOamCoordLong
    
    .return
    
        RTS
    }

; =============================================================================

    ; $F3214-$F3253 DATA
    pool Zol_DrawMultiple:
    {
    
    .oam_groups
        dw 0, 8 : db $6C, $03, $00, $00
        dw 8, 8 : db $6D, $03, $00, $00
        dw 0, 8 : db $60, $00, $00, $00
        dw 8, 8 : db $70, $00, $00, $00
        dw 0, 8 : db $70, $40, $00, $00
        dw 8, 8 : db $60, $40, $00, $00
        dw 0, 0 : db $40, $00, $00, $02
        dw 0, 0 : db $40, $00, $00, $02
    }

; =============================================================================

    ; *$F3254-$F326E LOCAL
    Zol_DrawMultiple:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : SUB.b #$04 : REP #$20 : ASL #4
        
        ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite3_DrawMultiple
    }

; =============================================================================
