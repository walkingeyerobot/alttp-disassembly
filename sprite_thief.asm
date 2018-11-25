
; ==============================================================================

    ; $EC8CC-$EC8D7 DATA
    pool Thief:
    {
    
    .standing_animation_states
        db $0B, $08, $02, $05
    
    .watching_animation_states
        db $09, $06, $00, $03, $0A, $07, $01, $04
    }

; ==============================================================================

    ; *$EC8D8-$EC90D JUMP LOCATION
    Sprite_Thief:
    {
        JSL Thief_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckIfRecoiling
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA $0D80, X : CMP.b #$03 : BEQ .dont_reface_player
        
        JSR Sprite4_DirectionToFacePlayer : TYA : STA $0EB0, X
        
        EOR $0DE0, X : CMP.b #$01 : BNE .dont_reface_player
        
        TYA : STA $0DE0, X
    
    .dont_reface_player
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Thief_Loitering
        dw Thief_WatchPlayer
        dw Thief_ChasePlayer
        dw Thief_StealShit
    }

; ==============================================================================

    ; *$EC90E-$EC94B JUMP LOCATION
    Thief_Loitering:
    {
        JSR Thief_CheckPlayerCollision
        
        LDA $0DF0, X : BNE .delay
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0050
        
        CMP.w #$00A0 : BCS .player_not_close
        
        LDA $20 : SUB $0FDA : ADD.w #$0050
        
        CMP.w #$00A0 : BCS .player_not_close
        
        SEP #$20
        
        INC $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
    
    .delay
    .player_not_close
    
        SEP #$20
        
        LDY $0DE0, X
        
        LDA Thief.standing_animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EC94C-$EC984 JUMP LOCATION
    Thief_WatchPlayer:
    {
        JSR Thief_CheckPlayerCollision
        
        JSR Sprite4_DirectionToFacePlayer : TYA : STA $0EB0, X
                                                  STA $0DE0, X
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
    
    .delay
    
    ; *$EC966 ALTERNATE ENTRY POINT
    shared Thief_BodyTracksHead:
    
        LDA $1A : AND.b #$1F : BNE .dont_adjust_body
        
        LDA $0EB0, X : STA $0DE0, X
    
    .dont_adjust_body
    
    ; *$EC972 ALTERNATE ENTRY POINT
    shared Thief_Animate:
    
        INC $0E80, X : LDA $0E80, X : AND.b #$04 : ORA $0DE0, X : TAY
        
        LDA Thief.watching_animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EC985-$EC9DE JUMP LOCATION
    Thief_ChasePlayer:
    {
        LDA.b #$12 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA $0E70, X : BNE .hit_tile
        
        JSR Sprite4_Move
    
    .hit_tile
    
        JSR Sprite4_CheckTileCollision
        
        LDA $0DF0, X : BNE .delay
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0050
        
        CMP.w #$00A0 : BCS .player_not_close
        
        LDA $20 : SUB $0FDA : ADD.w #$0050
        
        CMP.w #$00A0 : BCC .player_still_close
    
    .player_not_close
    
        SEP #$20
        
        STZ $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
    
    .player_still_close
    .delay
    
        SEP #$20
        
        JSL Sprite_CheckDamageToPlayerLong : BCC .didnt_touch_player
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        JSR Thief_DislodgePlayerItems
        JSR Thief_MakeStealingShitNoise
    
    .didnt_touch_player
    
        JSR Thief_BodyTracksHead
        
        RTS
    }

; ==============================================================================

    ; *$EC9DF-$ECA23 JUMP LOCATION
    Thief_StealShit:
    {
        JSR Thief_CheckPlayerCollision
        JSR Thief_ScanForBooty
        
        PHY
        
        LDA $0DF0, X : BNE .delay_pursuit_of_booty
        
        JSR Thief_Animate
        
        LDA $0E70, X : BNE .tile_collision
        
        JSR Sprite4_Move
    
    .tile_collision
    
        JSR Sprite4_CheckTileCollision
        
        LDA $0EB0, X : STA $0DE0, X
    
    .delay_pursuit_of_booty
    
        PLY
        
        TXA : EOR $1A : AND.b #$03 : BNE .delay_facing_towards_booty
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        JSL Sprite_DirectionToFaceEntity
        
        TYA : STA $0EB0, X
    
    .delay_facing_towards_booty
    
        RTS
    }

; ==============================================================================

    ; *$ECA24-$ECA4B LOCAL
    Thief_ScanForBooty:
    {
        LDY.b #$0F
    
    .next_sprite_slot
    
        LDA $0DD0, Y : BEQ .inactive_sprite_slot
        
        LDA $0E20, Y : CMP.b #$DC : BEQ .savory_booty
                       CMP.b #$E1 : BEQ .savory_booty
                       CMP.b #$D9 : BNE .unsavory_booty
    
    .savory_booty
    
        PHY
        
        JSR Thief_TrackDownBooty
        
        PLY
        
        RTS
    
    .unsavory_booty
    .inactive_sprite_slot
    
        DEY : BPL .next_sprite_slot
        
        ; Nothing to steal, go back to skulking.
        STZ $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$ECA4C-$ECA9D LOCAL
    Thief_TrackDownBooty:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .speed_adjustment_delay
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        LDA.b #$13 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        LDA $01 : STA $0D50, X
    
    .speed_adjustment_delay
    
        LDY.b #$0F
    
    .next_sprite_slot
    
        TYA : EOR $1A : AND.b #$03 : ORA $0F10, Y : BNE .delay_grab_attempt
        
        LDA $0DD0, Y : BEQ .inactive_sprite_slot
        
        LDA $0E20, Y
        
        CMP.b #$DC : BEQ .savory_booty
        CMP.b #$E1 : BEQ .savory_booty
        CMP.b #$D9 : BNE .unsavory_booty
    
    .savory_booty
    
        JSR Thief_AttemptBootyGrab
    
    .unsavory_booty
    .inactive_sprite_slot
    .delay_grab_attempt
    
        DEY : BPL .next_sprite_slot
        
        RTS
    }

; ==============================================================================

    ; *$ECA9E-$ECAF1 LOCAL
    Thief_AttemptBootyGrab:
    {
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        REP #$20
        
        LDA $04 : SUB $0FD8 : ADD.w #$0008 : CMP.w #$0010 : BCS .out_of_reach
        
        LDA $06 : SUB $0FDA : ADD.w #$000C : CMP.w #$0018 : BCS .out_of_reach
        
        SEP #$20
        
        LDA.b #$00 : STA $0DD0, Y
        
        PHX
        
        LDA $0E20, Y : SUB.b #$D8 : TAX
        
        LDA $06D12D, X : JSL Sound_SetSfx3PanLong
        
        PLX
        
        LDA.b #$0E : STA $0DF0, X
    
    .out_of_reach
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$ECAF2-$ECB1F LOCAL
    Thief_CheckPlayerCollision:
    {
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .didnt_bump_player
        
        LDA.b #$20 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00    : STA $27
        EOR.b #$FF : STA $0F30, X
        
        LDA $01    : STA $28
        EOR.b #$FF : STA $0F40, X
        
        ; \task Figure out if this has any bearing on the player using a cape
        ; when being bumped into.
        LDA.b #$04 : STA $46
        
        LDA.b #$0C : STA $0EA0, X
    
    ; $ECB19 ALTERNATE ENTRY POINT
    shared Thief_MakeStealingShitNoise:
    
        LDA.b #$0B : JSL Sound_SetSfx2PanLong
    
    .didnt_bump_player
    
        RTS
    }

; ==============================================================================

    ; $ECB20-$ECB2F DATA
    {
    
    .x_speeds
        db   0,  24,  24,   0, -24, -24
    
    .y_speeds
        db -32, -16,  16,  32,  16, -16
    
    .item_to_spawn
        db $D9, $E1, $DC, $D9        
    }

; ==============================================================================

    ; *$ECB30-$ECBD5 LOCAL
    Thief_DislodgePlayerItems:
    {
        LDA.b #$05 : STA $0FB5
    
    .dislodge_next_item
    
        JSL GetRandomInt : AND.b #$03 : STA $0FB6
        
        DEC A : BEQ .target_arrows
        DEC A : BEQ .target_bombs
        
        ; Otherwise target rupees
        REP #$20
        
        LDA $7EF360
        
        SEP #$20
        
        BRA .test_quantity
    
    .target_arrows
    
        LDA $7EF377
        
        BRA .test_quantity
    
    .target_bombs
    
        LDA $7EF343
    
    .test_quantity
    
        BEQ .return
        
        LDY $0FB6
        
        LDA .item_to_spawn, Y
        
        LDY #$07
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .return
        
        LDA $0FB6 : DEC A : BEQ .extract_arrow
                    DEC A : BEQ .extract_bomb
        
        REP #$20
        
        LDA $7EF360 : DEC A : STA $7EF360
        
        SEP #$20
        
        BRA .spawn_extracted_item
    
    .extract_arrow
    
        LDA $7EF377 : DEC A : STA $7EF377
        
        BRA .spawn_extracted_item
    
    .extract_bomb
    
        LDA $7EF343 : DEC A : STA $7EF343
    
    .spawn_extracted_item
    
        LDA $22 : STA $0D10, Y
        LDA $23 : STA $0D30, Y
        
        LDA $20 : STA $0D00, Y
        LDA $21 : STA $0D20, Y
        
        LDA.b #$18 : STA $0F80, Y
        
        PHX
        
        LDX $0FB5
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA.b #$20 : STA $0F10, Y
        
        LDA.b #$01 : STA $0EB0, Y
        
        LDA.b #$FF : STA $0B58, Y
        
        DEC $0FB5 : BMI .return
        
        JMP .dislodge_next_item
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $ECBD6-$ECC9D DATA
    pool Thief_Draw:
    {
    
    .oam_groups
        dw 0, -6 : db $00, $00, $00, $02
        dw 0,  0 : db $06, $00, $00, $02
        dw 0, -6 : db $00, $00, $00, $02
        dw 0,  0 : db $06, $40, $00, $02
        dw 0, -6 : db $00, $00, $00, $02
        dw 0,  0 : db $20, $00, $00, $02
        dw 0, -7 : db $04, $00, $00, $02
        dw 0,  0 : db $22, $00, $00, $02
        dw 0, -7 : db $04, $00, $00, $02
        dw 0,  0 : db $22, $40, $00, $02
        dw 0, -7 : db $04, $00, $00, $02
        dw 0,  0 : db $24, $00, $00, $02
        dw 0, -8 : db $02, $00, $00, $02
        dw 0,  0 : db $0A, $00, $00, $02
        dw 0, -7 : db $02, $00, $00, $02
        dw 0,  0 : db $0E, $00, $00, $02
        dw 0, -7 : db $02, $00, $00, $02
        dw 0,  0 : db $0A, $00, $00, $02
        dw 0, -8 : db $02, $40, $00, $02
        dw 0,  0 : db $0A, $40, $00, $02
        dw 0, -7 : db $02, $40, $00, $02
        dw 0,  0 : db $0E, $40, $00, $02
        dw 0, -7 : db $02, $40, $00, $02
        dw 0,  0 : db $0A, $40, $00, $02    
    
    .chr
        db $02, $02, $00, $00
    
    .h_flip
        db $40, $00, $00, $00
    }

; ==============================================================================

    ; *$ECC9E-$ECCDA LONG
    Thief_Draw:
    {
        PHB : PHK : PLB
        
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite4_DrawMultiple
        
        ; \task Figure out if the label name accurately reflects the mechanism
        ; (blinking).
        LDA $0F00, X : BNE .dont_blink
        
        PHX
        
        LDA $0EB0, X : TAX
        
        LDA .chr, X : LDY.b #$02 : STA ($90), Y
        
        INY
        
        LDA ($90), Y : AND.b #$BF : ORA .h_flip, X : STA ($90), Y
        
        PLX
        
        JSL Sprite_DrawShadowLong
    
    .dont_blink
    
        PLB
        
        RTL
    }

; ==============================================================================
