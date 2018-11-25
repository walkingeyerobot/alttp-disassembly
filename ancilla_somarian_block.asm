
    ;   $0394[0x05]
    ;       When the block is spawned, this timer is set and prevents any
    ;       interaction with the object until it counts down.
    ;   
    ;   
    ;
    ;
    ;
    ;
    ;
    ;
    ;
    ;

; ==============================================================================

    ; $462F9-$46364 DATA
    pool Ancilla_SomarianBlock:
    {
    
    .properties
        db $00, $40, $00, $C0
        
        ; \task check if these are ever used.
        db $00, $40, $00, $C0
        db $00, $40, $00, $C0
    
    .y_offsets
        dw -8, -8,  0,  0
        dw  0,  0,  0,  0
        dw  0,  0,  0,  0
    
    .x_offsets
        dw -8,  0, -8,  0
        dw  0,  0,  0,  0
        dw  0,  0,  0,  0
    
    .node_check_y_offsets
        dw -8,  8,  0,  0
        dw  0,  0,  0,  0
        dw -8,  8, -8,  8
    
    .node_check_x_offsets
        dw  0,  0, -8,  8
        dw  0,  0,  0,  0
        dw  8, -8, -8,  8
    }

; ==============================================================================

    ; *$46365-$4674B JUMP LOCATION
    Ancilla_SomarianBlock:
    {
        DEC $0394, X : BPL Ancilla_SetupBasicHitBox.return
        
        STZ $0394, X
        
        LDA $03C5, X : BNE .bouncing
        
        LDA $11    : BEQ .full_execute
        CMP.b #$08 : BEQ .full_execute
        CMP.b #$10 : BNE .partial_execute
    
    .full_execute
    
        JSR Ancilla_LiftableObjectLogic
        
        BRA .held_logic
    
    .partial_execute
    
        TXA : INC A : CMP $02EC : BNE .pretrigger_logic
        
        LDA $0380, X : BEQ .pretrigger_logic
        CMP.b #$03   : BEQ .assert_fully_held_position
    
        LDY.b #$03
        
        JSR Ancilla_PegCoordsToPlayer
        JSR Ancilla_PegAltitudeAbovePlayer
        
        LDA.b #$03 : STA $0380, X
    
    .assert_fully_held_position
    
        JSR Ancilla_SetPlayerHeldPosition
    
    .pretrigger_logic
    
        LDA $1B : BEQ .outdoors
        
        LDA $0380, X : BNE .unset_trigger_if_player_holding
        
        BIT $0308 : BMI .unset_trigger_if_player_holding
        
        LDA $029E, X : BEQ .trigger_logic
        
        CMP.b #$FF : BEQ .trigger_logic
    
    .bouncing
    .unset_trigger_if_player_holding
    
        TXA : INC A : CMP $02EC : BNE .anounset_trigger_tile
        
        STZ $0646
    
    .outdoors
    .anounset_trigger_tile
    
        BRL .tile_collision_logic
    
    .trigger_logic
    
        ; \wtf What this indicates to me is that using a somarian block
        ; as a platform generator and as a tile trigger cover is mutually
        ; exclusive in a given room.
        LDA $03F4 : BEQ .no_tranit_tiles_available
        
        LDA $1A : AND.b #$03 : ASL A : TAY
    
    .find_transit_node_nearby
    
        LDA $0BFA, X : ADD .node_check_y_offsets+0, Y : STA $00 : STA $72
        LDA $0C0E, X : ADC .node_check_y_offsets+1, Y : STA $01 : STA $73
        
        LDA $0C04, X : ADD .node_check_x_offsets+0, Y : STA $02 : STA $74
        LDA $0C18, X : ADC .node_check_x_offsets+1, Y : STA $03 : STA $75
        
        PHY
        
        LDA $0280, X : PHA
        
        JSR Ancilla_CheckTargetedTileCollision
        
        PLA : STA $0280, X
        
        PLY
        
        ; These are the '?' transit tile nodes.
        LDA $03E4, X : CMP.b #$B6 : BEQ .attempt_platform_spawn
                       CMP.b #$BC : BEQ .attempt_platform_spawn
        
        TYA : ADD.b #$08 : TAY : CPY.b #$18 : BCS .tile_collision_logic
        
        BRA .find_transit_node_nearby
    
    .attempt_platform_spawn
    
        LDA $72 : STA $0BFA, X
        LDA $73 : STA $0C0E, X
        
        LDA $74 : STA $0C04, X
        LDA $75 : STA $0C18, X
        
        JSL AddSomarianPlatformPoof
        
        TXA : INC A : CMP $02EC : BNE .reset_nearest_flag_near_platform
        
        STZ $02EC
    
    .reset_nearest_flag_near_platform
    
        RTS
    
    .no_tranit_tiles_available
    
        ; \wtf Does this routine check against star tiles? Could I use this
        ; to trigger doors in dungeon by putting a block on a star tile?
        ; (or whatever 0x3b is?)
        JSR SomarianBlock_CheckCoveredTileTrigger : BCS .tile_collision_logic
        
        LDA $029E, X : BEQ .set_tile_trigger_flag
        CMP.b #$FF   : BNE .tile_collision_logic
    
    .set_tile_trigger_flag
    
        INC $0646
    
    .tile_collision_logic
    
        JSR Ancilla_Adjust_Y_CoordByAltitude
        
        LDA $0C72, X : STA $74
        LDA $0280, X : STA $75
        
        STZ $0280, X
        
        JSR Ancilla_CheckTileCollision_Class2
        
        PHP
        
        LDA $1B : BEQ .dont_transition_to_bg1
        
        LDA $0385, X : BEQ .dont_transition_to_bg1
        
        LDA $03E4, X : CMP.b #$1C : BNE .dont_transition_to_bg1
        
        LDA.b #$01 : STA $03D5, X
    
    .dont_transition_to_bg1
    
        PLP : BCC .no_tile_collision
    
    .wall_bounce_logic
    
        ; If we reach this point the somarian block is touching a wall tile and
        ; requires collision handling
        BIT $0308 : BPL .not_being_held_so_can_bounce
        
        LDA $0309 : BEQ .no_tile_collision
    
    .not_being_held_so_can_bounce
    
        ; super priority means ignore all collision.
        LDA $75 : BNE .end_tile_collision_logic
        
        LDA $0BF0, X : BNE .end_tile_collision_logic
        
        LDA $029E, X : BEQ .end_tile_collision_logic
        
        LDA.b #$01 : STA $0BF0, X
        
        LDA.b #$04 : STA $0E
        
        ; What is the obsession with the down direction? It uses less of
        ; a wall bounce magnitude.
        LDA $0C72, X : CMP.b #$01 : BNE .use_small_bounce_magnitude
        
        LDA.b #$10 : STA $0E
        
        LDY.b #$F0
        
        BRA .check_vertical_speed
    
    .use_small_bounce_magnitude
    
        LDY.b #$FC
    
    .check_vertical_speed
    
        LDA $0C22, X : BEQ .at_rest_y
                       BPL .bounce_upward
        
        LDY $0E
    
    .bounce_upward
    
        TYA : STA $0C22, X
    
    .at_rest_y
    
        LDY.b #$FC
        
        LDA $0C2C, X : BEQ .at_rest_x
                       BPL .bounce_leftward
        
        LDY.b #$04
    
    .bounce_leftward
    
        TYA : STA $0C2C, X
    
    .at_rest_x
    
        LDA $0C72, X : CMP.b #$01 : BNE .end_tile_collision_logic
        
        INC A : STA $0385, X
        
        LDA.b #$FC : STA $0C22, X
    
    .end_tile_collision_logic
    .dont_process_ground_touch_logic
    
        BRL .damage_logic
    
    .no_tile_collision
    
        BIT $0308 : BMI .end_tile_collision_logic
        
        LDA $029E, X : BEQ .touching_ground
        CMP.b #$FF   : BNE .dont_process_ground_touch_logic
    
    .transit_tiles
    
        LDA.b #$10 : STA $0C72, X
        
        LDA $0280, X : PHA
        
        JSR Ancilla_CheckTileCollision
        
        PLA : STA $0280, X
        
        LDA $03E4, X
        
        CMP.b #$26 : BEQ .in_floor_staircase_boundary
        CMP.b #$0C : BEQ .niche_collision_tiles
        CMP.b #$1C : BEQ .niche_collision_tiles
        CMP.b #$20 : BEQ .pit_tiles
        CMP.b #$08 : BEQ .deep_water_tile
        CMP.b #$68 : BEQ .conveyor_belt_tiles
        CMP.b #$69 : BEQ .conveyor_belt_tiles
        CMP.b #$6A : BEQ .conveyor_belt_tiles
        CMP.b #$6B : BEQ .conveyor_belt_tiles
        CMP.b #$B6 : BEQ .transit_tiles
        CMP.b #$BC : BEQ .transit_tiles
        
        ; \wtf... is this accurate disassembly?
        AND.b #$F0 : CMP.b #$B0 : BNE .transit_tiles
    
    .pit_tiles
    
        BRL .pit_tile_logic
    
    .in_floor_staircase_boundary
    
        BRL .wall_bounce_logic
    
    .conveyor_belt_tiles
    
        BRL .apply_conveyor_movement_to_object
    
    .transit_tiles
    
        STZ $0C68, X
        
        LDA $0385, X : ORA $03C5, X : BNE .bouncing_and_or_airborn
        
        LDA.b #$02 : STA $0C68, X
    
    .delay_reckoning
    .bouncing_and_or_airborn
    
        BRL .damage_logic
    
    .deep_water_tile
    
        ; If a bomb falls into deep water it disappears and makes a splash
        TXA : INC A : CMP $02EC : BNE .water_tile_reset_player_proximity
        
        STZ $02EC
    
    .water_tile_reset_player_proximity
    
        LDA $0C68, X : BNE .delay_reckoning
        
        LDA $0BFA, X : ADD.b #$E8 : STA $0BFA, X
        LDA $0C0E, X : ADC.b #$FF : STA $0C0E, X
        
        BRL Ancilla_TransmuteToObjectSplash
    
    .niche_collision_tiles
    
        LDA $046C : CMP.b #$03 : BEQ .moving_floor_collision
        
        LDA $0C7C, X : BNE .damage_logic
        
        LDA $029E, X : BEQ .damage_logic
        CMP.b #$FF   : BEQ .damage_logic
        
        LDA.b #$01 : STA $0C7C, X
        
        BRL .damage_logic
    
    .moving_floor_collision
    
        ; Handle bomb on a moving floor
        LDA $0BFA, X : ADD $0310 : STA $72
        LDA $0C0E, X : ADC $0311 : STA $73
        
        LDA $0C04, X : ADD $0312 : STA $0C04, X
        LDA $0C18, X : ADC $0313 : STA $0C18, X
        
        BRA .damage_logic
    
    .apply_conveyor_movement_to_object
    
        JSR Ancilla_ConveyorBeltVelocityOverride
        
        BRA .damage_logic
    
    .pit_tile_logic
    
        LDA $0308 : BMI .damage_logic
        
        TXA : INC A : CMP $02EC : BNE .pit_tile_reset_player_proximity
        
        STZ $02EC
    
    .pit_tile_reset_player_proximity
    
        LDA $0C68, X : BNE .damage_logic
        
        LDA $5E : CMP.b #$12 : BNE Ancilla_SelfTerminate
        
        STZ $5E
        STZ $48
    
    ; *$465D8 ALTERNATE ENTRY POINT
    shared Ancilla_SelfTerminate:
    
        STZ $0C4A, X
        
        RTS
    
    .damage_logic
    
        LDA $75 : ORA $0280, X : STA $75
        
        LDA $0308 : BMI .dont_fizzle
        
        DEC $03A9, X : LDA $03A9, X : BNE .dont_fizzle
        
        INC $03A9, X
        
        STZ $0280, X
        
        JSR Ancilla_CheckBasicSpriteCollision : BCC .dont_fizzle
        
        LDA.b #$07 : STA $03A9, X
        
        LDA $0C54, X : INC A : STA $0C54, X : CMP.b #$05 : BNE .dont_fizzle
        
        BRL Ancilla_TransmuteToSomarianBlockFizzle
    
    .dont_fizzle
    
        LDA $74 : STA $0C72, X
        LDA $75 : STA $0280, X
        
        JSR Ancilla_Set_Y_Coord
    
    ; *$4661B ALTERNATE ENTRY POINT
    shared SomarianBlock_Draw:
    
        TXY : INY : CPY $02EC : BNE .no_special_oam_allocation
        
        LDA $0308 : BPL .no_special_oam_allocation
        
        LDA $0380, X : CMP.b #$03 : BEQ .no_special_oam_allocation
        
        LDA $2F : BNE .no_special_oam_allocation
        
        LDA $0C90, X : JSR Ancilla_AllocateOam_B_or_E
        
        BRA .prep_coords
    
    .no_special_oam_allocation
    
        LDA $0FB3 : BEQ .prep_coords
        
        LDA $0C7C, X : BEQ .prep_coords
        
        LDA $0385, X : BNE .other_special_allocation_if_airborn
        
        TXY : INY : CPY $02EC : BNE .prep_coords
        
        LDA $0308 : BPL .prep_coords
    
    .other_special_allocation_if_airborn
    
        REP #$20
        
        LDA.w #$00D0 : ADD.w #$0800 : STA $90
        LDA.w #$0034 : ADD.w #$0A20 : STA $92
        
        SEP #$20
    
    .prep_coords
    
        JSR Ancilla_PrepAdjustedOamCoord
        
        REP #$20
        
        LDA $029E, X : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_z_coord
        
        ORA.w #$FF00
    
    .sign_ext_z_coord
    
        STA $04 : BEQ .anoset_max_priority
        
        CMP.w #$FFFF : BEQ .anoset_max_priority
        
        ; \optimize Use bit instruction instead?
        LDA $0380, X : AND.w #$00FF : CMP.w #$0003 : BEQ .anoset_max_priority
        
        ; \optimize Use bit instruction instead?
        LDA $0280, X : AND.w #$00FF : BEQ .anoset_max_priority
        
        LDA.w #$3000 : STA $64
    
    .anoset_max_priority
    
        LDA.w #$0000 : ADD $04 : EOR.w #$FFFF : INC A : ADD $00 : STA $04
        
        LDA $02 : STA $06
        
        SEP #$20
        
        STZ $08
        
        PHX
        
        LDA.b #$02 : STA $72
        
        LDA $03A4, X : ASL #2 : TAX
        
        LDY.b #$00
    
    .next_oam_entry
    
        REP #$20
        
        STZ $74
        
        PHX : TXA : ASL A : TAX
        
        LDA $04 : ADD .y_offsets, X : STA $00
        LDA $06 : ADD .x_offsets, X : STA $02
        
        PLX
        
        SEP #$20
        
        JSR Ancilla_SetSafeOam_XY
        
        ; \note Really? This is made out of 4 little sprites and not 1 big one?
        ; I doesn't computer this amdfpaiosdfjadsofja. (Maybe it was a space
        ; limitation, but still...)
        LDA.b #$E9                                          : STA ($90), Y : INY
        LDA .properties, X : AND.b #$CF : ORA $72 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        ; \wtf(unconfirmed) .... compile time constant?
        LDA.b #$00 : ORA $75 : STA ($92), Y
        
        PLY
        
        INX
        
        INC $08 : LDA $08 : AND.b #$03 : BNE .next_oam_entry
        
        PLX
        
        ; Don't self terminate if in the player's hands.
        LDA $0380, X : CMP.b #$03 : BEQ .return
        
        LDY.b #$01
    
    .find_on_screen_y_oam_entry
    
        LDA ($90), Y : CMP.b #$F0 : BNE .oam_entry_not_off_screen_y
        
        INY #4 : CPY.b #$11 : BNE .find_on_screen_y_oam_entry
        
        BRA .terminate_per_off_screen
    
    .oam_entry_not_off_screen_y
    
        LDY.b #$00
    
    .find_on_screen_x_oam_entry
    
        LDA ($92), Y : AND.b #$01 : BEQ .return
        
        INY : CPY.b #$04 : BNE .find_on_screen_x_oam_entry
    
    .terminate_per_off_screen
    
        STZ $0646
        
        ; The block self terminates and unsets the 'switch set' status variable.
        STZ $0C4A, X
        
        TXA : INC A : CMP $02EC : BNE .return
        
        STZ $02EC
        
        LDA $0308 : AND.b #$80 : BEQ .return
        
        ; Reset player carrying status.
        STZ $0308
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $4674C-$4675B DATA
    pool SomarianBlock_CheckCoveredTileTrigger
    {
    
    .y_offsets
        dw -4,  4,  0,  0
    
    .x_offsets
        dw  0,  0, -4,  4
    }

; ==============================================================================

    ; *$4675C-$467BF LOCAL
    SomarianBlock_CheckCoveredTileTrigger:
    {
        STZ $0646
        
        STZ $03DB, X
        
        LDY.b #$06
    
    .next_offset
    
        LDA $0BFA, X : ADD .y_offsets+0, Y : STA $00 : STA $72
        LDA $0C0E, X : ADC .y_offsets+1, Y : STA $01 : STA $73
        
        LDA $0C04, X : ADD .x_offsets+0, Y : STA $02 : STA $74
        LDA $0C18, X : ADC .x_offsets+1, Y : STA $03 : STA $75
        
        PHY
        
        LDA $0280, X : PHA
        
        JSR Ancilla_CheckTargetedTileCollision
        
        PLA : STA $0280, X
        
        PLY
        
        LDA $03E4, X
        
        CMP.b #$23 : BEQ .recognized_tile_attr
        CMP.b #$24 : BEQ .recognized_tile_attr
        CMP.b #$25 : BEQ .recognized_tile_attr
        CMP.b #$3B : BNE .ignored_tile_attr
    
    .recognized_tile_attr
    
        INC $03DB, X
    
    .ignored_tile_attr
    
        DEY #2 : BPL .next_offset
        
        LDA $03DB, X : CMP.b #$04 : BNE .not_full_covering
        
        CLC
        
        RTS
    
    .not_full_covering
    
        SEC
        
        RTS
    }

; ==============================================================================

    ; $467C0-$467E5 DATA
    pool SomarianBlock_PlayerInteraction:
    parallel pool SomarianBlock_InitDashBounce:
    {
    
    .positive_push_speed
        db 16
    
    .negative_push_speed
        db -16
    
    .launch_y_speeds
        db -40,  40,   0,   0
    
    ; $467c6 to $467d1 \unused
    .unused_y_speeds
        db -32,  32,   0,   0
        db -16,  16,   0,   0
        db  -8,   8,   0,   0
    
    .launch_x_speeds
        db  0,   0, -40,  40
    
    ; $467d6 to $467e1 \unused
    .unused_y_speeds
        db  0,   0, -32,  32
        db  0,   0, -16,  16
        db  0,   0,  -8,   8
    
    .bounce_rebound_z_speeds
        db 30,  18,  10,   8
    }

; ==============================================================================

    ; *$467E6-$468F2 LONG
    SomarianBlock_PlayerInteraction:
    {
        PHB : PHK : PLB
        
        ; Index into the SFX arrays
        STX $0FA0
        
        LDA $0394, X : BNE .end_push_logic
        
        LDA $03C5, X : BEQ .not_dash_airborn
        
        BRL SomarianBlock_ContinueDashBounce
    
    .not_dash_airborn
    
        LDA $4D : BNE .end_push_logic
        
        LDA $0308 : AND.b #$01 : BNE .end_push_logic
        
        LDA $029E, X : BEQ .ground_touch
        
        CMP.b #$FF : BNE .end_push_logic
    
    .ground_touch
    
        LDA $0380, X : BNE .end_push_logic
        
        LDA $0385, X : BNE .end_push_logic
        
        LDA $F0 : AND.b #$0F : BNE .dpad_pressed
        
        ; Setting these to zero has the affect of not making the player look
        ; like they're pushing anything.
        STA $039F, X
        STA $48
        
        LDA.b #$FF : STA $038A, X
        
        LDA $0372 : BNE .check_player_collision
        
        STZ $5E
    
    .end_push_logic
    
        BRL .return
    
    .dpad_pressed
    
        CMP $039F, X : BNE .different_directions_from_prev_frame
        
        LDA $5E : CMP.b #$12 : BNE .check_player_collision
        
        LDA.b #$81 : TSB $48
        
        BRA .check_player_collision
    
    .different_directions_from_prev_frame
    
        ; Refresh button directional input?
        STA $039F, X
        
        STZ $5E
    
    .check_player_collision
    
        LDY.b #$04
        
        JSR Ancilla_CheckPlayerCollision : BCC .end_push_logic
        
        LDA $0C7C, X : CMP $EE : BNE .end_push_logic
        
        LDA $0372 : BEQ .not_dash_bounce
        
        LDA $02F1 : CMP.b #$40 : BEQ .not_dash_bounce
        
        TXA : INC A : CMP $02EC : BNE .disable_nearby_status
        
        STZ $02EC
    
    .disable_nearby_status
    
        JSL Player_HaltDashAttackLong
        
        LDA.b #$32 : JSR Ancilla_DoSfx3
        
        BRL SomarianBlock_InitDashBounce
    
    .not_dash_bounce
    
        STZ $0C2C, X
        STZ $0C22, X
        
        LDA $F0 : AND.b #$0F : STA $039F, X
        
        AND.b #$03 : BEQ .vertical_push
        
        LDY .positive_push_speed
        
        AND.b #$01 : BNE .left_push
        
        LDY .negative_push_speed
    
    .left_push
    
        TYA : STA $0C2C, X
        
        LDY.b #$02
        
        CMP .positive_push_speed : BNE .set_direction_indicator
        
        INY
        
        BRA .set_direction_indicator
    
    .vertical_push
    
        LDY .positive_push_speed
        
        LDA $F0 : AND.b #$08 : BEQ .upward_push
        
        LDY .negative_push_speed
    
    .upward_push
    
        TYA : STA $0C22, X
        
        LDY.b #$00
        
        CMP .positive_push_speed : BNE .set_direction_indicator
        
        INY
    
    .set_direction_indicator
    
        TYA : STA $0C72, X
        
        ; \task Or does this mean movement in general?
        LDA $27 : BEQ .no_player_recoil
        
        LDA $28 : BNE .player_recoiling
    
    .no_player_recoil
    
        JSR Ancilla_CheckTileCollision_Class2 : BCS .no_tile_collision
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        ; \task Does this like.... mean if you walk up to a somarian block
        ; while you're holding something else it makes no noise?
        ; \task Also, investigate why throwing a block and then dashing before
        ; it stops bouncing slows down the player's dash speed to that of
        ; holding a block and walking.)
        LDA $0308 : AND.b #$80 : BNE .no_push_sfx
        
        INC $038A, X : STA $038A, X : AND.b #$07 : BNE .no_push_sfx
        
        LDA $22 : JSR Ancilla_DoSfx2
    
    .no_push_sfx
    .no_tile_collision
    
        LDA.b #$81 : STA $48
        LDA.b #$12 : STA $5E
    
    .player_recoiling
    
        JSL Sprite_NullifyHookshotDrag
    
    .return
    
        PLB
        
        RTL
    }
    
; ==============================================================================

    ; $468F3-$4698D BRANCH LOCATION
    SomarianBlock_InitDashBounce:
    {
    
        ; \note Send the Somarian block flying from the impact of the dash
        ; attack.
        
        LDA $2F : LSR A : STA $0C72, X : TAY
        
        LDA .launch_y_speeds, Y : STA $0C22, X
        
        LDA .launch_x_speeds, Y : STA $0C2C, X
        
        ; Not indexed, used the maximum rise available in the array.
        LDA .bounce_rebound_z_speeds : STA $0294, X
        
        LDA.b #$01 : STA $03C5, X
        
        STZ $029E, X
    
    shared SomarianBlock_ContinueDashBounce:
    .bounce_logic
    
        ; Simulate gravity.
        LDA $0294, X : SUB.b #$02 : STA $0294, X
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveAltitude
        
        LDA $029E, X : BEQ .hit_ground
        CMP.b #$FC   : BCC .return
    
    .hit_ground
    
        ; Play plopping on the ground noise when it hits the ground.
        LDA.b #$21 : JSR Ancilla_DoSfx2
        
        ; Force altitude to zero.
        STZ $029E, X
        
        LDA $03C5, X : INC A : STA $03C5, X
        
        CMP.b #$04 : BNE .bounces_maxed_out
        
        STZ $0BF0, X
        STZ $03C5, X
        
        BRA .return
    
    .bounces_maxed_out
    
        TAY
        
        DEX
        
        ; Get different resultant altitude speeds for each bounce.
        LDA .bounce_rebound_z_speeds, Y : STA $0294, X
        
        LDA $2F : LSR A : STA $00
        
        TYA : ASL #2 : ADD $00 : TAY
        
        LDY.b #$00
        
        LDA $0C22, X : BPL .abs_y_speed
        
        LDY.b #$01
        
        EOR.b #$FF : INC A
    
    .abs_y_speed
    
        ; Halve the absolute value of the y speed.
        LSR A
        
        CPY.b #$01 : BNE .restore_y_speed_sign
        
        EOR.b #$FF : INC A
    
    .restore_y_speed_sign
    
        STA $0C22, X
        
        LDY.b #$00
        
        LDA $0C2C, X : BPL .abs_x_speed
        
        LDY.b #$01
        
        EOR.b #$FF : INC A
    
    .abs_x_speed
    
        ; Halve the absolute value of the x speed.
        LSR A
        
        CPY.b #$01 : BNE .restore_x_speed_sign
        
        EOR.b #$FF : INC A
    
    .restore_x_speed_sign
    
        STA $0C2C, X
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================
