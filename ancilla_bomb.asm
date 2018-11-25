
; ==============================================================================

    ; $41543-$41559 DATA
    pool Ancilla_Bomb:
    {
    
    .interstate_intervals
        db 160, 6, 4, 4, 4, 4, 4, 6, 6, 6, 6
        
    .chr_groups
        db 0, 1, 2, 3, 2, 3, 4, 5, 6, 7, 8, 9
    }

; ==============================================================================

    ; *$4155A-$417B5 JUMP LOCATION
    Ancilla_Bomb:
    {
        ; Code for implementing the Bomb Special Effect (0x07)
        LDA $11    : BEQ .full_execute
        CMP.b #$08 : BEQ .walking_on_staircase
        CMP.b #$10 : BNE .not_in_room_staircase_submode
    
    .walking_on_staircase
    
        JSR Ancilla_LiftableObjectLogic
        
        BRA .just_draw
    
    .not_in_room_staircase_submode
    
        ; Is Link close to the bomb? If not, branch
        TXA : INC A : CMP $02EC : BNE .just_draw
        
        ; Is Link carrying the bomb?
        LDA $0380, X : BEQ .just_draw
        CMP.b #$03   : BEQ .player_fully_holding
        
        ; Coerce the bomb into the held state immediately.
        LDY.b #$03
        
        JSR Ancilla_PegCoordsToPlayer
        JSR Ancilla_PegAltitudeAbovePlayer
        
        LDA.b #$03 : STA $0380, X
    
    .player_fully_holding
    
        JSR Ancilla_SetPlayerHeldPosition
    
    .just_draw
    
        BRL .draw
    
    .full_execute
    
        JSR Ancilla_LiftableObjectLogic
        JSR Ancilla_Adjust_Y_CoordByAltitude
        
        LDA $0C72, X : STA $74
        
        LDA $0280, X : STA $75
        
        STZ $0280, X
        
        JSR Ancilla_CheckTileCollision_Class2
        
        ; Save the collision flag status.
        PHP
        
        ; Outdoors doesn't use multiple interactive bgs.
        LDA $1B : BEQ .dont_coerce_to_bg1
        
        ; Check to see if the bomb is airborn.
        LDA $0385, X : BEQ .dont_coerce_to_bg1
        
        ; If it hit the top of a 'water staircase', coerce.
        LDA $03E4, X : CMP.b #$1C : BNE .dont_coerce_to_bg1
        
        ; if it's tile type 0x1C (whatever that is), set the transition flag (to go to BG0)
        LDA.b #$01 : STA $03D5, X
    
    .dont_coerce_to_bg1
    
        PLP : BCC .no_tile_collision

    .check_tile_collision

        ; collision detected with wall
        BIT $0308 : BPL .player_not_holding_anything_yet
        
        LDA $0309 : BEQ .no_tile_collision

    .player_not_holding_anything_yet

        ; collision detected with wall and link is not holding the bomb in his hands
        ; therefore, collisions matter and we have to handle them.
        LDA $75 : BNE .ignore_tile_collision_results
        
        ; Seemingly flags a collision has been handled and does not need to be  
        ; handled again this frame.
        LDA $0BF0, X : BNE .ignore_tile_collision_results
        
        ; If we reach this point we need to handle a collision
        LDA.b #$01 : STA $0BF0, X
        
        LDA.b #$04 : STA $0E
        
        LDY.b #-4
        
        LDA $0C72, X : CMP.b #$01 : BNE .not_oriented_down
        
        LDA.b #16 : STA $0E
        
        LDY.b #-16

    .not_oriented_down

        ; Get current y speed
        LDA $0C22, X : BEQ .at_rest_y
                       BPL .moving_down
        
        LDY $0E
    
    .moving_down
    
        ; This is where reversal of y velocity occurs (bounces off of a wall).
        TYA : STA $0C22, X
    
    .at_rest_y
    
        ; moving left at a rate of 4
        LDY.b #-4
        
        LDA $0C2C, X : BEQ .at_rest_x
                       BPL .moving_right
        
        LDY.b #4
    
    .moving_right
    
        ; This is where reversal of X velocity occurs (bounces off of a wall).
        TYA : STA $0C2C, X
    
    .at_rest_x
    
        ; \wtf I don't know what else to call this label, what the fuck are we
        ; doing here? I realize that the perspective of this game is
        ; messed up, but what makes the downward physics handling so
        ; special that it needs all this adjustment?
        LDA $0C72, X : CMP.b #$01 : BNE .dont_fudge_y_velocity
        
        LDA $029E, X : BEQ .dont_fudge_y_velocity
        
        LDA.b #-4 : STA $0C22, X
        
        LDA.b #$02 : STA $0385, X
    
    .dont_fudge_y_velocity
    .ignore_tile_collision_results
    .dont_process_ground_touch_logic
    
        BRL .state_logic
    
    .no_tile_collision
    
        ; This branch is taken if collision with a wall was not detected
        
        TXA : INC A : CMP $02EC : BNE .player_not_touching_object
        
        BIT $0308 : BMI .ignore
    
    .player_not_touching_object
    
        ; bomb's elevation in pixels
        LDA $029E, X : BEQ .touching_ground
        CMP.b #$FF   : BNE .dont_process_ground_touch_logic
    
    .touching_ground
    
        ; Essentially this designates that the bomb has no orientation at the
        ; moment.
        LDA.b #$10 : STA $0C72, X
        
        ; Not really sure what purpose saving $0280, X serves...
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
        
        ; Checking for any other cane of somaria types
        AND.b #$F0 : CMP.b #$B0 : BEQ .pit_tiles
    
    .transit_tiles
    
        STZ $0C68, X
        
        ; Check if flying through air
        LDA $0385, X : BNE .dont_process_ground_touch_logic
        
        LDA.b #$02 : STA $0C68, X
    
    .delay_reckoning
    
        BRL .state_logic
    
    .conveyor_belt_tiles
    
        BRL .apply_conveyor_movement_to_object
    
    .in_floor_staircase_boundary
    
        BRL .check_tile_collision
    
    .niche_collision_tiles
    
        ; Top of water staircase and moving floor tiles end up here.
        BRL .niche_collision_logic
    
    .deep_water_tile
    
        ; Kills the bomb b/c it fell in water; then it makes a splash
        
        TXA : INC A : CMP $02EC : BNE .water_tile_reset_player_proximity
        
        ; Don't get the game's hopes up that you can pick up this bomb,
        ; it's set for termination soon!
        STZ $02EC
    
    .water_tile_reset_player_proximity
    
        LDA $0C68, X : BNE .delay_reckoning
        
        LDA $0BFA, X : ADD.b #-24                : STA $0BFA, X
                       LDA.b #-1  : ADC $0C0E, X : STA $0C0E, X
        
        BRL Ancilla_TransmuteToObjectSplash
    
    .pit_tiles
    
        ; executed when the bomb falls into a hole
        LDA $0308 : BMI .state_logic
        
        STX $04
        
        LDA $02EC : DEC A : CMP $04 : BNE .pit_tile_reset_player_proximity
        
        ; Same as with water tiles, reset this state if necessary.
        STZ $02EC
    
    .pit_tile_reset_player_proximity
    
        LDA $0C68, X : BNE .delay_reckoning
        
        BRL Ancilla_SelfTerminate
    
    .niche_collision_logic
    
        LDA $046C : CMP.b #$03 : BEQ .moving_floor_collision
        
        LDA $0C7C, X : BNE .state_logic
        
        ; check elevation
        LDA $029E, X : BEQ .state_logic ; if zero, branch
        CMP.b #$FF   : BEQ .state_logic ; if it bounced, branch
        
        ; Move the object to BG1.
        LDA.b #$01 : STA $0C7C, X
        
        BRA .state_logic
    
    .moving_floor_collision
    
        LDA $0310 : ADD $0BFA, X : STA $72
        LDA $0311 : ADC $0C0E, X : STA $73
        
        LDA $0312 : ADD $0C04, X : STA $0C04, X
        LDA $0313 : ADC $0C18, X : STA $0C18, X
        
        BRA .state_logic
    
    .apply_conveyor_movement_to_object
    
        JSR Ancilla_ConveyorBeltVelocityOverride
    
    .state_logic
    
        JSR Ancilla_Set_Y_Coord
        
        LDA $74 : STA $0C72, X
        
        LDA $75 : ORA $0280, X : STA $0280, X
        
        JSR Bomb_CheckSpriteAndPlayerDamage
        
        ; Decrement the timer for the bomb.
        DEC $039F, X : LDA $039F, X : BNE .state_change_delay
        
        ; Begin the bomb's explosion
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$01 : BNE .not_just_exploded
        
        ; Play the bomb exploding sound
        LDA.b #$0C : JSR Ancilla_DoSfx2
        
        ; Did Link come in contact with the explosion?
        TXA : INC A : CMP $02EC : BNE .dont_reset_player_lift_state
        
        STZ $02EC ; Link has been hit by this bomb
        
        ; See if he's carrying anything.
        BIT $0308 : BPL .dont_reset_player_lift_state
        
        ; Make him drop anything he carries
        STZ $0308
        
        ; Unset any flags stopping Link from changing direction
        STZ $50
    
    .not_just_exploded
    .dont_reset_player_lift_state
    
        ; Check the bomb explosion state index (0x01 to 0x0B)
        ; branch if it's not at 0x0B
        LDA $0C5E, X : CMP.b #$0B : BNE .not_fully_exploded
        
        ; Trigger no special effect... if there's no wall to blow up
        LDY.b #$00
        
        LDA $0C54, X : BEQ .dont_transmute_to_door_debris
        
        ; Transmute to the door debris special effect
        LDY.b #$08
    
    .dont_transmute_to_door_debris
    
        TYA : STA $0C4A, X
        
        RTS
    
    .not_fully_exploded
    
        ; explosion states < 0x0B
        
        TAY ; Y = the explosion state
        
        ; Set a new timer based on which explosion state it is
        LDA .interstate_intervals, Y : STA $039F, X
    
    .state_change_delay
    
        LDA $0C5E, X : CMP.b #$07 : BNE .draw
        
        LDA $039F, X : CMP.b #$02 : BNE .draw
        
        PHX
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        STX $0E
        
        TXA : ASL A : TAX
        
        STZ $03B6, X
        STZ $03B7, X
        
        JSL Bomb_CheckForVulnerableTileObjects
        
        PLX : TXY : TXA : ASL A : TAX
        
        LDA $03B6, X : ORA $03B7, X : BEQ .didnt_blow_open_door
        
        TYX
        
        ; Set a flag indicating that we need to transmute to the door debris
        ; object when finished exploding.
        LDA.b #$01 : STA $0C54, X
    
    .didnt_blow_open_door
    
        TYX
    
    .draw
    
        JSR Bomb_Draw
    
    ; 417B5 ALTERNATE ENTRY POINT
    .return
    
        RTS
    }

; ==============================================================================

    ; $417B6-$417BD DATA
    pool Ancilla_ConveyorBeltVelocityOverride:
    {
    
    .y_speeds
        db -8,  8,  0,  0
    
    .x_speeds
        db  0,  0, -8,  8
    }

; ==============================================================================

    ; *$417BE-$417E1 LOCAL
    Ancilla_ConveyorBeltVelocityOverride:
    {
        ; This routine is triggered if a bomb is on a conveyor belt or
        ; otherwise moving surface
        
        LDA $03E4, X : SUB.b #$68 : TAY
        
        LDA .y_speeds, Y : STA $0C22, X
        LDA .x_speeds, Y : STA $0C2C, X
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        LDA $0BFA, X : STA $72
        LDA $0C0E, X : STA $73
        
        RTS
    }

; ==============================================================================

    ; $417E2-$41814 DATA
    pool Bomb_CheckSpriteAndPlayerDamage:
    {
    
    .recoil_magnitudes
        db 32, 32, 32, 32, 32, 32, 28, 28
        db 28, 28, 28, 28, 24, 24, 24, 24
    
    .resistances
        db 16, 16, 16, 16, 16, 16, 12, 12
        db 12, 12,  8   8,  8,  8,  8,  8
    
    .damage_timers
        db 32, 32, 32, 32, 32, 32, 24, 24
        db 24, 24, 24, 24, 16, 16, 16, 16
    
    .damage_quantities
        db 8, 4, 2
    }

; ==============================================================================

    ; *$41815-$41912 LOCAL
    Bomb_CheckSpriteAndPlayerDamage:
    {
        ; If the bomb is in state 9 it can do damage
        LDA $0C5E, X : BEQ .dont_damage_anything
        CMP.b #$09   : BCS .dont_damage_anything
        
        JSR Bomb_CheckSpriteDamage
        
        LDA $037B : BEQ .player_not_using_invincibility_item
        
        TXA : INC A : CMP $02EC : BNE Ancilla_Bomb.return
        
        ; If the player is holding the bomb that is exploding, take the player
        ; out of the "holding something over head" state.
        LDA $0308 : AND.b #$80 : BEQ Ancilla_Bomb.return
        
        LDA $0308 : AND.b #$7F : STA $0308
        
        STZ $50
    
    .dont_damage_anything
    
        BRL Ancilla_Bomb.return
    
    .player_not_using_invincibility_item
    
        LDA $4D : BNE .dont_damage_anything
        
        LDA $46 : BNE .dont_damage_anything
        
        LDA $0C7C, X : CMP $EE : BNE .dont_damage_anything
        
        LDA $22 : STA $00
        LDA $23 : STA $08
        LDA $20 : STA $01
        LDA $21 : STA $09
        
        LDA.b #$10 : STA $02
        LDA.b #$18 : STA $03
        
        LDA $0C04, X : STA $04
        LDA $0C18, X : STA $05
        
        LDA $0BFA, X : STA $06
        LDA $0C0E, X : STA $07
        
        REP #$20
        
        LDA $04 : ADD.w #-16 : STA $04
        LDA $06 : ADD.w #-16 : STA $06
        
        SEP #$20
        
        LDA $05 : STA $0A
        LDA $06 : STA $05
        LDA $07 : STA $0B
        
        LDA.b #$20 : STA $06
                     STA $07
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .dont_damage_player
        
        LDA $0C04, X : ADD.b #$-8 : STA $00
        LDA $0C18, X : ADC.b #$-1 : STA $01
        
        LDA $0BFA, X : ADD.b #$-12 : STA $02
        LDA $0C0E, X : ADC.b #$-1  : STA $03
        
        PHX
        
        JSR Bomb_GetGrossPlayerDistance
        
        LDA .recoil_magnitudes, Y : TAY
        
        JSL Bomb_ProjectSpeedTowardsPlayer
        
        PLX
        
        ; If Link is already flashing he's invulnerable
        LDA $031F : BNE .dont_damage_player
        
        ; Check for the menu being unable to be activated
        LDA $0FFC : CMP.b #$02 : BEQ .dont_damage_player
        
        LDA $00 : STA $27
        LDA $01 : STA $28
        
        JSR Bomb_GetGrossPlayerDistance
        
        LDA .resistances, Y : STA $29 : STA $02C7
        
        LDA .damage_timers, Y : STA $46
        
        ; Put Link in recoil mode
        LDA.b #$01 : STA $4D
        
        ; Make Link's sprite blink
        LDA.b #$3A : STA $031F
        
        ; If the boss is beaten Link is invincible!
        LDA $0403 : AND.b #$80 : BNE .dont_damage_player
        
        ; Check his armor status
        LDA $7EF35B : TAY
        
        ; Damage Link by this amount
        LDA .damage_quantities, Y : STA $0373
    
    .dont_damage_player
    
        RTS
    }

; ==============================================================================

    ; $41913-$41975 DATA
    pool Ancilla_LiftableObjectLogic:
    {
    
    .player_relative_y_offsets
        dw 16, 8, 4, 4
        dw 8, 2, -1, -1
        dw 2, 2, -1, -1
        
    .player_relative_x_offsets
        dw 8, 8, -4, 20
        dw 8, 8, 8, 8
        dw 8, 8, 8, 8
    
    .lift_timers
        db 16, 8, 9
    
    .z_offset_player_moving
        dw -2, -1, 0, -2, -1, 0
    
    .throw_y_speeds
        db -32,  32,   0,   0
    
    .throw_x_speeds
        db   0,   0, -32,  32
    
    ; $4195A to $41961
    ; \unused Presumably for testing throws and bounces
    .unused_throw_y_speeds
        db   8,   8,   0,   0
        db   4,   4,   0,   0
    
    ; $41962 to $41969
    ; \unused Presumably for testing throws and bounces
    .unused_throw_x_speeds
        db   0,   0,   8,   8
        db   0,   0,   4,   4
    
    .postbounce_z_speeds
        db 16, 16
    
    ; $4196c to $41971
    ; \unused Presumably for testing throws and bounces
    .unused_postbounce_z_speeds
        db 16, 16, 8,  8,  8,  8
        
    .compatible_lift_directions
        db 0, 2, 4, 6
    }

; ==============================================================================

    ; *$41976-$41C7E LOCAL
    Ancilla_LiftableObjectLogic:
    {
        ; Setting this flag causes player to not be able to pick it up
        LDA $03EA, X : BNE .not_currently_liftable
        
        ; Is it in motion?
        LDA $0385, X : BEQ .not_airborn
        
        BRL .airborn_logic
    
    .not_airborn
    
        STX $00
        
        ; This is set to the special effect index + 1 of a detected collision
        LDA $02EC : BEQ .player_not_near_to_any_object
        
        ; this branch fails if some other sprite triggered $02EC
        DEC A : CMP $00 : BEQ .closest_liftable_object_to_player
        
        RTS
    
    .closest_liftable_object_to_player
    
        ; Collision detected and it matches this special effect
        LDY $037B : BNE .player_invulnerable
        
        LDA $46 : BNE .not_liftable_per_player_damage_timer
    
    .player_invulnerable
    
        LDA $03FD : BNE .travel_bird_in_play
        
        LDA $4D : CMP.b #$01 : BNE .player_not_in_recoil
    
    .travel_bird_in_play
    .not_liftable_per_player_damage_timer
    
        LDA.b #$01 : STA $03EA, X
        
        STZ $0294, X
        
        ; Set it so there's no possibility of lifting anything this frame.
        STZ $02EC
        
        STZ $0BF0, X
        
        BRA .not_currently_liftable
    
    .player_not_in_recoil
    
        ; This code is hit when Link is within range of the bomb
        LDA $0308 : BPL .player_not_carrying_anything
        
        BRL .player_already_carrying_something
    
    .not_currently_liftable
    
        BRL .altitude_physics
    
    .player_not_holding_anything_yet
    .player_not_near_to_any_object
    
        ; Set collision detection to "false"
        STZ $02EC
        
        ; Check explosion status (0 = not exploded yet)
        LDA $0C5E, X : BNE .not_liftable_2
        
        ; See if Link is lifting or lifted anything
        LDA $0308 : BNE .not_liftable_2
        
        LDY.b #$00
        
        JSR Ancilla_CheckPlayerCollision : BCC .not_liftable_2
        
        LDA $0C7C, X : CMP $EE : BNE .not_liftable_2
        
        LDA $08 : CMP.b #$10 : BCS .vertical_distance_large
        
        LDA $0A : CMP.b #$0C : BCC .begin_lifting
    
    .vertical_distance_large
    
        LDA $08 : CMP $0A : BCC .vertical_distance_less
        
        LDY.b #$00
        
        LDA $04 : BPL .is_player_direction_suitable_for_lift
        
        INY
        
        BRA .is_player_direction_suitable_for_lift
    
    .vertical_distance_less
    
        LDY.b #$02
        
        LDA $06 : BPL .is_player_direction_suitable_for_lift
        
        INY
    
    .is_player_direction_suitable_for_lift
    
        ; Check if player facing a proper direction for lifting the object
        LDA .compatible_lift_directions, Y : CMP $2F : BNE .not_liftable_2
    
    .begin_lifting
    
        ; Collision detected?
        TXA : INC A : STA $02EC
        
        STZ $0380, X
        
        LDA .lift_timers : STA $03B1, X
        
        STZ $0385, X
        STZ $029E, X
    
    .not_liftable_2
    
        RTS
    
    .player_already_carrying_something
    
        ; Check if Link is already picking up something or throwing it.
        LDA $0309 : CMP.b #$02 : BEQ .throw_logic
        
        LDA $02EC : BEQ .throw_logic
        
        LDY $0380, X : CPY.b #$03 : BEQ .throw_logic
        
        CPY.b #$00 : BNE dont_play_lift_sfx
        
        LDA $03B1, X : CMP.b #$10 : BNE .dont_play_lift_sfx
        
        LDA.b #$1D : JSR Ancilla_DoSfx2
    
    .dont_play_lift_sfx
    
        DEC $03B1, X : BPL Ancilla_PegCoordsToPlayer
    
        ; Make Link pick up the bomb (1 all the way to 3)
        INY : TYA : STA $0380, X
        
        LDA .lift_timers, Y : STA $03B1, X
        
        CPY.b #$03 : BNE Ancilla_PegCoordsToPlayer
    
    ; *$41A4F ALTERNATE ENTRY POINT
    shared Ancilla_PegAltitudeAbovePlayer:
    
        ; This subsection makes the elevation 0x11, but also pushes the y
        ; coordinate down 0x11 pixels.
        ; Altitude += 0x11;
        LDA.b #$11 : STA $029E, X
        
        ; y_coord += 0x11;
        LDA $0BFA, X : ADD.b #$11 : STA $0BFA, X
        LDA $0C0E, X : ADC.b #$00 : STA $0C0E, X
        
        STZ $0280, X
        
        BRA .cant_throw
    
    ; *$41A6A ALTERNATE ENTRY POINT
    shared Ancilla_PegCoordsToPlayer:
    
        TYA : ASL #3 : ADD $2F : TAY
        
        LDA $20 : ADD .player_relative_y_offsets+0, Y : STA $0BFA, X
        LDA $21 : ADC .player_relative_y_offsets+1, Y : STA $0C0E, X
        
        LDA $22 : ADD .player_relative_x_offsets+0, Y : STA $0C04, X
        LDA $23 : ADC .player_relative_x_offsets+1, Y : STA $0C18, X
    
    .cant_throw
    
        RTS
    
    .throw_logic
    
        LDA $0380, X : CMP.b #$03 : BNE .cant_throw
        
        LDA $0309 : CMP.b #$02 : BEQ .throwing_object
        
        LDA $11 : BNE .ignore_throw_logic
        
        ; Lets you throw the bomb with either the A or B button
        LDA $F6 : ORA $F4 : AND.b #$80 : BNE .throw_object
    
    .ignore_throw_logic
    
        BRL .player_fall_logic
    
    .throw_object
    
        LDA $2F : LSR A : STA $0C72, X : TAY
        
        ; Gives the object 0x18 points of lift.
        LDA.b #$18 : STA $0294, X
        
        ; Set the Y and X velocity for the bomb
        LDA .throw_y_speeds, Y : STA $0C22, X
        LDA .throw_x_speeds, Y : STA $0C2C, X
        
        ; Make it look like Link is throwing the object
        LDA.b #$02 : STA $0309
        
        ; Indicate that the object is in motion
        DEC A : STA $0385, X
        
        ; Player is not colliding with the object
        STZ $02EC
        
        STZ $0BF0, X ; ???
        STZ $0380, X ; Set carrying state to zero (not holding it)
        STZ $0280, X
        
        LDA.b #$13 : JSR Ancilla_DoSfx3
    
    .airborn_logic
    
        LDA $0C5E, X : BEQ .airborn_in_ground_state
        
        ; If the object has exploded or otherwise changed from ground state,
        ; it stops moving, even in the air.
        RTS
    
    .airborn_in_ground_state
    
        ; Simulate gravity.
        LDA $0294, X : SUB.b #$02 : STA $0294, X
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        LDA $029E, X : STA $00
        
        JSR Ancilla_MoveAltitude
        
        ; Ugh, what a clusterfuck!
        LDA $0BF0, X : BEQ .dont_add_altitude_back_to_y_coord
        
        LDA $0C72, X : CMP.b #$01 : BNE .dont_add_altitude_back_to_y_coord
        
        LDA $0BFA, X : STA $0C
        LDA $0C0E, X : STA $0D
        
        LDA $029E, X : BMI .dont_add_altitude_back_to_y_coord
        
        SUB $00 : STA $0E
        
        REP #$20
        
        LDA $0E : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_y_coord
        
        ORA.w #$FF00
    
    .sign_ext_y_coord
    
        ADD $0C : STA $0C
        
        SEP #$20
        
        LDA $0C : STA $0BFA, X
        LDA $0D : STA $0C0E, X
    
    .dont_add_altitude_back_to_y_coord
    
        LDA $029E, X : CMP.b #$80 : BCS .negative_altitude
    
    .didnt_just_hit_ground
    
        RTS
    
    .negative_altitude
    
        CMP.b #$FF : BCS .didnt_just_hit_ground
        
        STZ $029E, X
        
        ; Play the "bomb hitting the ground" sound
        LDA.b #$21 : JSR Ancilla_DoSfx2
        
        INC $0385, X : LDA $0385, X : CMP.b #$03 : BEQ .bounces_maxed_out
        
        SUB.b #$02 : ASL #2 : ADD $0C72, X : TAY
        
        LDY.b #$00
        
        LDA $0C22, X : BPL .halve_y_speed_due_to_ground_hit
        
        LDY.b #$01
        
        EOR.b #$FF : INC A
    
    .halve_y_speed_due_to_ground_hit
    
        LSR A
        
        CPY.b #$01 : BNE .restore_y_speed_sign
        
        EOR.b #$FF : INC A
    
    .restore_y_speed_sign
    
        STA $0C22, X
        
        LDY.b #$00
        
        LDA $0C2C, X : BPL .halve_x_speed_due_to_ground_hit
        
        LDY.b #$01
        
        EOR.b #$FF : INC A
    
    .halve_x_speed_due_to_ground_hit
    
        LSR A
        
        CPY.b #$01 : BNE .restore_x_speed_sign
        
        EOR.b #$FF : INC A
    
    .restore_x_speed_sign
    
        STA $0C2C, X
        
        LDA .postbounce_z_speeds, Y : STA $0294, X
        
        LDA $0BF0, X : BEQ .dont_transition_bg
        
        ; Reset collision already detected flag.
        STZ $0BF0, X
        
        RTS
    
    .bounces_maxed_out
    
        STZ $029E, X
        STZ $0385, X
        STZ $0BF0, X
        STZ $5E
        STZ $0C22, X
        STZ $0C2C, X
        STZ $0294, X
        
        LDA $03D5, X : BEQ .dont_transition_bg
        
        STA $0C7C, X ; Performs a transition from BG2 to BG1 for the bomb
        
        STZ $03D5, X
    
    .dont_transition_bg
    
        RTS
    
    .player_fall_logic

        LDA $0C5E, X : BNE .ignore_player_fall_logic
        
        LDA $5B : CMP.b #$02 : BCC .player_not_falling
        
        STZ $5E
        
        TXA : INC A : CMP $02EC : BNE .player_not_falling_with_this_object
        
        STZ $02EC
        
        ; Just terminate the held ancilla if the player is falling into a pit.
        STZ $0C4A, X
    
    .player_not_falling_with_this_object
    
        RTS
    
    .player_not_falling
    
        ; Are we in water or using the bunny graphics set?
        LDA $0345 : ORA $02E0 : BEQ Ancilla_SetPlayerHeldPosition
        
        STZ $0308
        
        BRL .throwing_object
    
    ; *$41BEF ALTERNATE ENTRY POINT
    shared Ancilla_SetPlayerHeldPosition:
    
        ; Link's animation status
        LDA $2E : ASL A : TAY
        
        ; Slow player down b/c they're carrying something
        LDA.b #$0C : STA $5E
        
        ; Make the floor the player is on the floor that the bomb is on.
        LDA $EE : STA $0C7C, X
        
        ; Same, but for pseudo-bg
        LDA $0476 : STA $03CA, X
        
        REP #$20
        
        LDA $24 : CMP.w #$-1 : BNE .player_didnt_just_hit_ground
        
        LDA.w #$0000
    
    .player_didnt_just_hit_ground
    
        EOR.w #$FFFF : INC A
        
        ADD $20 : ADD .z_offset_player_moving, Y : ADD.w #$0012 : STA $00
        LDA $22                                  : ADD.w #$0008 : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
    
    .ignore_player_fall_logic
    .ignore_altitude_physics
    
        RTS
    
    .altitude_physics
    
        LDA $0C5E, X : BNE .ignore_altitude_physics
        
        LDA $0380, X : CMP.b #$03 : BNE .restore_liftability
        
        ; Simulate gravity.
        LDA $0294, X : SUB.b #$02 : STA $0294, X
        
        JSR Ancilla_MoveAltitude
        
        LDA $029E, X : BEQ .on_ground
        CMP.b #$FC   : BCC .return
    
    .on_ground
    
        STZ $029E, X
        
        INC $03EA, X : LDA $03EA, X : CMP.b #$03 : BEQ .bounces_maxed
        
        LDA.b #$18 : STA $0294, X
        
        BRA .return
    
    .bounces_maxed
    
        STZ $029E, X
        STZ $0380, X
    
    .restore_liftability
    
        ; Make object liftable again
        STZ $03EA, X
        
        STZ $5E
    
    .return
    
        RTS
    }

; ==============================================================================

    ; \wtf Wait, so the bombs and somarian blocks simulate gravity by adjusting
    ; the Y coordinate? What?
    
    ; *$41C7F-$41CC2 LOCAL
    Ancilla_Adjust_Y_CoordByAltitude:
    {
        ; Special effects routine for adjusting objects for height
        
        LDA $0BFA, X : STA $72
        LDA $0C0E, X : STA $73
        
        STZ $0D
        STZ $0C
        
        ; 'down' here means in the y axis, akin to 'southern direction'
        LDA $0C72, X : ASL A : TAY : CMP.b #$02 : BNE .not_oriented_down
        
        LDA $029E, X : STA $0C : BPL .positive_altitude
        
        LDA.b #$FF : STA $0D
    
    .not_oriented_down
    .positive_altitude
    
        REP #$20
        
        LDA $0C : CMP.w #$FFFF : BNE .not_hitting_ground
        
        LDA.w #$0000
    
    .not_hitting_ground
    
        EOR.w #$FFFF : INC A : ADD $72 : STA $0E
        
        SEP #$20
        
        LDA $0E : STA $0BFA, X
        LDA $0F : STA $0C0E, X
        
        RTS
    }

; ==============================================================================

    ; $41CC3-$41CCD LOCAL
    Ancilla_Set_Y_Coord:
    {
        LDA $73 : STA $0C0E, X
        LDA $72 : STA $0BFA, X
        
        RTS
    }

; ==============================================================================

    ; \note I'd call this an absolute distance or a euclidean distance, but that
    ; would be totally wrong. This gets the sum of the difference of delta x 
    ; and delta y of the player and bomb coordinates.
    
    ; *$41CCE-$41D0F LOCAL
    Bomb_GetGrossPlayerDistance:
    {
        LDA $0C04, X : STA $06
        LDA $0C18, X : STA $07
        
        LDA $0BFA, X : STA $04
        LDA $0C0E, X : STA $05
        
        REP #$20
        
        ; A = Link's X pos. + 8 - effect's X pos.
        LDA $22 : ADD.w #$0008 : SUB $06 : BPL .abs_delta_x
        
        ; A = abs(A) [absolute value]
        EOR.w #$FFFF : INC A
    
    .abs_delta_x
    
        STA $0A
        
        LDA $20 : ADD.w #$000C : SUB $04 : BPL .abs_delta_y
        
        ; A = abs(Link's Y pos. + 0x0C - effect's Y pos.)
        EOR.w #$FFFF : INC A
    
    .abs_delta_y
    
        ; add the X and Y absolute distances together, and snap to a 
        ; 4 by 4 pixel grid
        ADD $0A : AND.w #$00FC : LSR #2 : TAY
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $41D10-$41E9D DATA
    pool Bomb_Draw:
    parallel pool Bomb_DrawExplosion:
    {
    
    .chr_and_properties
    .chr
        
        db $6E
    
    .properties
        db $26
        
        db $FF, $FF
        db $FF, $FF
        db $FF, $FF
        db $FF, $FF
        
        db $FF, $FF
        db $8C, $22
        db $8C, $62
        db $8C, $A2
        
        db $8C, $E2
        db $FF, $FF
        db $FF, $FF
        db $84, $22
        
        db $84, $62
        db $84, $A2
        db $84, $E2
        db $FF, $FF
        
        db $FF, $FF
        db $88, $22
        db $88, $62
        db $88, $A2
        
        db $88, $E2
        db $FF, $FF
        db $FF, $FF
        db $86, $22
        db $88, $22
        
        db $88, $62
        db $88, $A2
        db $88, $E2
        db $FF, $FF
        
        db $86, $22
        db $86, $62
        db $86, $E2
        db $86, $E2
        db $FF, $FF
        db $FF, $FF
        
        db $86, $E2
        db $86, $22
        db $86, $22
        db $86, $62
        db $86, $A2
        db $86, $A2
        
        db $8A, $A2
        db $8A, $62
        db $8A, $22
        db $8A, $62
        db $8A, $62
        db $8A, $E2
        
        db $9B, $22
        db $9B, $A2
        db $9B, $62
        db $9B, $E2
        db $9B, $A2
        db $9B, $22
        
    .xy_offsets
    .y_offsets
        dw  -8
    
    .x_offsets
        dw  -8
        
        ; 4x0
        dw   0,   0
        dw   0,   0
        dw   0,   0
        dw   0,   0
        
        ; 4x1
        dw   0,   0
        dw  -8,  -8
        dw  -8,   0
        dw   0,  -8
        
        ; 4x2
        dw   0,   0
        dw   0,   0
        dw   0,   0
        dw -16, -16
        
        ; 4x3
        dw -16,   0
        dw   0, -16
        dw   0,   0
        dw   0,   0
        
        ; 4x4
        dw   0,   0
        dw -16, -16
        dw -16,   0
        dw   0, -16
        
        ; 5x1
        dw   0,   0
        dw   0,   0
        dw   0,   0
        dw  -8,  -8
        dw -21, -22
        
        ; 4x1
        dw -21,   8
        dw   9, -22
        dw   9,   8
        dw   0,   0
        
        ; 6x0
        dw  -6, -15
        dw   0,  -1
        dw -16,  -2
        dw  -8,  -7
        dw   0,   0
        dw   0,   0
        
        ; 6x1
        dw  -9,  -4
        dw -21,  -5
        dw -12, -18
        dw -11,   7
        dw   0, -15
        dw   4,  -2
        
        ; 6x2
        dw  -9,  -4
        dw -22,  -5
        dw -13, -20
        dw -11,   8
        dw   1, -16
        dw   5,  -2
        
        ; \note For future reference, this is used, somehow.
        dw -20,   4
        dw -12, -19
        dw  -9,  16
        dw  -5,  -2
        dw   2,  -9
        dw  10,   6
    
    .oam_sizes
    
        ; \note The entries that are '1' are designed to push the sprite
        ; off screen, as in disable it from being viewed.
        db 2, 1, 1, 1, 1, 1
        db 0, 0, 0, 0, 1, 1
        db 2, 2, 2, 2, 1, 1
        db 2, 2, 2, 2, 1, 1
        db 2, 2, 2, 2, 2, 1
        db 2, 2, 2, 2, 1, 1
        db 2, 2, 2, 2, 2, 2
        db 2, 2, 2, 2, 2, 2
        db 0, 0, 0, 0, 0, 0        
    
    .chr_start_offset
        db 0, 6, 12, 18, 24, 30, 36, 42, 48
    
    .num_oam_entries
        db 1, 4, 4, 4, 4, 4, 5, 4, 6, 6, 6
    
    }

; ==============================================================================

    ; *$41E9E-$41FB5 LOCAL
    Bomb_Draw:
    {
        JSR Ancilla_PrepAdjustedOamCoord
        
        REP #$20
        
        ; Elevation of the special effect
        LDA $029E, X : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_z_coord
        
        ORA.w #$FF00
    
    .sign_ext_z_coord
    
        STA $04 : BEQ .not_max_oam_priority
        
        CMP.w #$FFFF : BEQ .not_max_oam_priority
        
        LDA $0380, X : AND.w #$00FF : CMP.w #$0003 : BEQ .not_max_oam_priority
        
        LDA $0280, X : AND.w #$00FF : BEQ .not_max_oam_priority
        
        LDA.w #$3000 : STA $64
    
    .not_max_oam_priority
    
        LDA.w #$0000 : ADD $04 : EOR.w #$FFFF : INC A : ADD $00 : STA $00
        
        SEP #$20
        
        ; Y = bomb state
        LDY $0C5E, X
        
        LDA Ancilla_Bomb.chr_groups, Y : TAY
        
        LDA Bomb_Draw.chr_start_offset, Y : ASL A : TAY
        
        ASL A : STA $04 : STZ $05
        
        STZ $0A
        
        ; Use palette 1.
        LDA.b #$02 : STA $0B
        
        LDA $0C5E, X : BNE .dont_palette_cycle
        
        ; Use palette 2.
        LDA.b #$04 : STA $0B
        
        ; Check the timer
        ; if timer is >= 0x20 branch...
        LDA $039F, X : CMP.b #$20 : BCS .dont_palette_cycle
        
        ; Cycle the palette as it's nearing explosion.
        AND.b #$0E : STA $0B
    
    .dont_palette_cycle
    
        ; X is either the first or second bomb (0 or 1)
        PHX : PHY
        
        ; exploding state? branch!
        LDA $0C5E, X : STA $08 : BNE .determine_underside_sprite
        
        ; bomb in flight? branch!
        LDA $0385, X : BNE .not_player_deference
        
        LDA $0E20 : CMP.b #$92 : BEQ .helmasaur_king_present
        
        TXY : INY : CPY $02EC : BNE .not_player_deference
    
    .helmasaur_king_present
    
        LDA $0308 : AND.b #$80 : BEQ .defer_for_uncarrying_player
        
        LDA $0380, X : CMP.b #$03 : BEQ .not_player_deference
        
        LDA $2F : BNE .not_player_deference
    
    .defer_for_uncarrying_player
    
        ; this only seems to get called if Link is near the bomb.
        LDA.b #$0C : JSR Ancilla_AllocateOam_B_or_E
        
        BRA .determine_underside_sprite
    
    .not_player_deference
    
        LDA $0FB3 : BEQ .determine_underside_sprite
        
        LDA $0C7C, X : BEQ .determine_underside_sprite
        
        LDA $0385, X : BNE .use_specific_oam_region
        
        TXY : INY : CPY $02EC : BNE .determine_underside_sprite
        
        LDA $0308 : BPL .determine_underside_sprite
    
    .use_specific_oam_region
    
        REP #$20
        
        ; \optimize Use constant folding to reduce by two instructions.
        LDA.w #$00D0 : ADD.w #$0800 : STA $90
        LDA.w #$0034 : ADD.w #$0A20 : STA $92
        
        SEP #$20
    
    .determine_underside_sprite
    
        ; Load the current state of the bomb.
        LDY $08
        
        LDA .num_oam_entries, Y : STA $08
        
        CPY.b #$00 : BNE .no_underside_sprite
        
        ; Is the type of tile it's standing on a 0x09 type?
        LDA $03E4, X : CMP #$09 : BEQ .in_deep_water
                       CMP #$40 : BNE .no_underside_sprite
    
    .in_deep_water
    
        LDY.b #$08
        
        BRA .setup_underside_sprite_coords
    
    .no_underside_sprite
    
        LDY.b #$00
    
    .setup_underside_sprite_coords
    
        LDA $00 : STA $0C
        LDA $01 : STA $0D
        
        LDA $02 : STA $0E
        LDA $03 : STA $0F
        
        STZ $06
        
        PLX ; X = the old Y, which is some value like 0, 6, 18, 24, ??? etc.
        
        JSR Bomb_DrawExplosion
        
        PLX ; X = the old index for the bomb (either 0 or 1)
        
        JSL Bomb_CheckUndersideSpriteStatus : BCS .dont_draw_shadow
        
        ; (set in the previous routine)
        LDX $0A : JSR Ancilla_DrawShadow
        
        LDX $0FA0
    
    .dont_draw_shadow
    
        RTS
    }

; ==============================================================================

