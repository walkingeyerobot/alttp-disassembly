    
; ==============================================================================

    ; Variables / aliases specific to Blind.
    
    ; \note Overrides typical usage.
    ; When set, prevents Blind from firing his laser for a while.
    !laser_inhibit = $0B58
    
    ; How many extra heads have been spawned.
    !extra_head_counter = $0B6A
    
    ; \note Overrides typical usage.
    ; Timer that, When set, will count down and fire a laser when nearly
    ; expired.
    !fire_laser = $0D80
    
    ; 0x00 - Blind
    ; 0x01 - BlindPoof
    ; 0x02 - BlindHead
    ; 0x80 - BlindLaser
    !blind_subtype = $0D90
    
    ; If even, accelerate downward, and accelerate upward if odd.
    !y_accel_polarity = $0DA0
    
    !blind_ai_state = $0DB0
    
    ; \note Overrides typical usage.
    ; 0x02 - Facing down
    ; 0x03 - Facing up
    ; Other values are invalid..
    !blind_direction = $0DE0
    
    ; \note Overrides conventional use of this variable
    !head_rotate_delay = $0E30
    
    ; For this sprite it acts as a 8-bit timer that ticks up every frame. When
    ; it overflows to zero it just keeps going without end. Some logic uses
    ; this as a mask to stagger certain behaviors between frames. There is also
    ; some code that bitwise ANDs this with 0x00 and then checks for a nonzero
    ; value, branching if so. This is considered to be debug code that never
    ; got taken out. Or rather, 0x00 was a symbolic constant that at one point
    ; might not have been 0x00.
    !forward_timer = $0E80
    
    ; For Blind, this actually is a timer for how long it takes to rotate the
    ; head. Its value is reset from !head_rotate_delay
    !head_rotate_timer = $0E90
    
    ; Controls the angle that the head is looking towards. Goes in 16ths of
    ; a full circle. It's not documented yet what each value (0x00 to 0x0f)
    ; corresponds to in terms of conventional angles.
    !head_angle = $0EB0
    
    ; If even, accelerate downward, and accelerate upward if odd.
    !head_y_accel_polarity = $0EC0
    
    ; If even, accelerate rightward, and accelerate leftward if odd.
    ; BlindHead also uses this, but its y acceleration variable is a different
    ; address.
    !x_accel_polarity      = $0ED0
    !head_x_accel_polarity = $0ED0

    ; \note Overrides typical usage.
    ; BlindHead uses this to delay fireballs that are actually aimed at the
    ; player.
    !fireball_aim_delay = $0F90
    
    ; \note Overrides typical usage.
    ; Counts how many times the current head has been hit. Once this reaches
    ; 3 it detaches and swirls around the room launching fireballs.
    !hit_counter = $0F90
    
; ==============================================================================

    ; *$EA03C-$EA080 LONG
    Blind_SpawnFromMaidenTagalong:
    {
        LDX.b #$00
        
        LDA.b #$09 : STA $0DD0, X
        
        LDA #$CE : STA $0E20, X
        
        LDA $00 : STA $0D10, X
        LDA $01 : STA $0D30, X
        
        LDA $02 : SUB.b #$10 : STA $0D00, X
        LDA $03              : STA $0D20, X
        
        JSL Sprite_LoadProperties
        
        LDA.b #$C0 : STA !timer_2, X
        
        LDA.b #$15 : STA $0DC0, X
        
        LDA.b #$02 : STA !blind_direction, X
                     STA $0BA0, X
        
        LDA $0403 : ORA.b #$20 : STA $0403
        
        STZ $0B69
        
        RTL
    }

; ==============================================================================

    ; *$EA081-$EA0B0 LONG
    Blind_Initialize:
    {
        LDA $7EF3CC : CMP.b #$06 : BEQ .self_terminate
        
        ; Check if the floor above this room has been bombed out.
        ; \hardcoded
        LDA $0403 : AND.b #$20 : BEQ .self_terminate
        
        LDA.b #$60 : STA !timer_2, X
        
        LDA.b #$01 : STA !blind_ai_state, X
        
        LDA.b #$02 : STA !blind_direction, X
        
        LDA.b #$04 : STA !head_angle, X
        
        LDA.b #$07 : STA $0DC0, X
        
        STZ $0B69
        
        RTL
    
    .self_terminate
    
        STZ $0DD0, X
        
        RTL
    }

; ==============================================================================

    ; *$EA0B1-$EA10F LOCAL
    BlindLaser_SpawnTrailGarnish:
    {
        ; \note Must have been some kind of development test code that never
        ; got edited out.
        LDA !forward_timer, X : AND.b #$00 : BNE .never
        
        PHX : TXY
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        DEC $0FF8 : BPL .no_garnish_slot_underflow
        
        LDA.b #$1D : STA $0FF8
    
    .no_garnish_slot_underflow
    
        LDX $0FF8
    
    .empty_slot
    
        ; \task Name this value with an enumeration when it becomes available.
        LDA.b #$0F : STA $7FF800, X : STA $0FB4
        
        LDA $0DC0, Y : STA $7FF9FE, X
        
        TYA : STA $7FF92C, X
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$0A : STA $7FF90E, X
        
        PLX
    
    .never
    
        RTS
    }

; ==============================================================================

    ; $EA110-$EA117 DATA
    pool Sprite_BlindHead:
    {
        ; \task Fill in data and label.
    
    .x_speed_limits
        db 32, -32
    
    .x_pos_limits
        db $98, $58
    
    .y_speeds_limits
        db 24, -24
    
    .y_pos_limits
        db $B0, $50
    }

; ==============================================================================

    ; *$EA118-$EA1EC LOCAL
    Sprite_BlindHead:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        PHX
        
        LDY.b #$02
        
        LDA !head_angle, X : TAX
        
        LDA $AC4C, X : STA ($90), Y : INY
        
        LDA ($90), Y : AND.b #$3F : ORA $AC5C, X : STA ($90), Y
        
        PLX
        
        JSR Sprite4_CheckIfActive
        
        LDA $0EA0, X : CMP.b #$0E : BNE .anospeed_up_recoil
        
        ; Slightly speed up the recoil process? Seems hacky. \hardcoded
        LDA.b #$08 : STA $0EA0, X
    
    .anospeed_up_recoil
    
        JSR Sprite4_CheckIfRecoiling
        
        DEC !head_rotate_delay, X : BPL .anorotate
        
        LDA.b #$02 : STA !head_rotate_delay, X
        
        LDA !head_angle, X : INC A : AND.b #$0F : STA !head_angle, X
    
    .anorotate
    
        ; When the free moving head is spawned, it is immovable at first and
        ; apparently can't cause damage either.
        LDA !timer_0, X : BEQ .fully_active
        
        JMP .return
    
    .fully_active
    
        JSR Sprite4_CheckDamage
        
        INC !forward_timer, X
        
        ; Spawn semi frequently (every 0x20 frames)
        LDA.b #$1F
        
        JSR Blind_SpawnFireball
        
        TYA : BMI .spawn_failed
        
        ; This means that every fifth fireball is directly aimed at the player.
        DEC !fireball_aim_delay, X : BPL .not_aimed_at_player
        
        LDA.b #$04 : STA !fireball_aim_delay, X
        
        PHY
        
        LDA.b #$20
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        PLY
        
        LDA $00 : STA $0D40, Y
        LDA $01 : STA $0D50, Y
    
    .not_aimed_at_player
    .spawn_failed
    
        ; \note Must be some debug setting that never got edited out.
        LDA !forward_timer, X : AND.b #$00 : BNE .never
        
        LDA !head_x_accel_polarity, X : AND.b #$01 : TAY
        
        LDA $0D50, X : CMP .x_speed_limits, Y : BEQ .anoalter_x_speed
        
        ADD $8000, Y : STA $0D50, X
    
    .anoalter_x_speed
    .never
    
        LDA $0D10, X : AND.b #$FE
        
        ; \hardcoded Using specific screen offsets seems kind of like cheating.
        CMP .x_pos_limits, Y : BNE .anoinvert_x_acceleration
        
        INC !head_x_accel_polarity, X
    
    .anoinvert_x_acceleration
    
        LDA !forward_timer, X : AND.b #$00 : BNE .never_2
        
        LDA !head_y_accel_polarity, X : AND.b #$01 : TAY
        
        LDA $0D40, X : CMP .y_speeds, Y : BEQ .anoalter_y_speed
        
        ADD $8000, Y : STA $0D40, X
    
    .anoalter_y_speed
    .never_2
    
        LDA $0D00, X : AND.b #$FE
        
        ; \hardcoded Same as above comment.
        CMP .y_pos_limits, Y : BNE .anoinvert_y_accleration
        
        INC !head_y_accel_polarity, X
    
    .anoinvert_y_accleration
    
        LDA $0EA0, X : BNE .dont_move
        
        JSR Sprite4_Move
    
    .dont_move
    .return
    
        RTS
    }

; ==============================================================================

    ; *$EA1ED-$EA23B LOCAL
    Blind_SpawnExtraHead:
    {
        ; Create a Blind Head sprite
        LDA.b #$CE : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$5B : STA $0E60, Y
        
        AND.b #$0F : STA $0F50, Y
        
        LDA.b #$04 : STA $0CAA, Y
        
        LDA.b #$02 : STA !blind_subtype, Y
        
        LDA.b #$01 : STA $0E40, Y
        
        DEC A : STA $0F60, Y : STA $0B6B, Y
        
        LDA.b #$17 : STA $0F70, Y
        
        ADD $02 : STA $0D00, Y
        
        LDA $00 : ASL A : ROL A : AND.b #$01 : STA !head_x_accel_polarity, Y
        LDA $02 : ASL A : ROL A : AND.b #$01 : STA !head_y_accel_polarity, Y
        
        LDA.b #$30 : STA !timer_0, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $EA23C-$EA25B DATA
    pool Sprite_BlindLaser:
    {
    
    .animation_states
        db  7,  7,  8,  9, 10,  9,  8,  7
        db  7,  7,  8,  9, 10,  9,  8,  7
    
    .vh_flip
        db $00, $00, $00, $00, $00, $40, $40, $40
        db $40, $40, $C0, $C0, $80, $80, $80, $80
    }
    
; ==============================================================================

    ; $EA25C-$EA262 DATA
    pool Sprite_Blind:
    {
    
    .animation_states
        db 20, 19, 18, 17, 16, 15, 15
    }

; ==============================================================================

    ; *$EA263-$EA2CA JUMP LOCATION
    Sprite_BlindEntities:
    {
        LDA !blind_subtype, X : BPL Sprite_Blind
    
    ; \note Not an actual branched to or jumped to location, but labeled for
    ; informational purposes.
    shared Sprite_BlindLaser:
    
        LDY !head_angle, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA .vh_flip, Y : ORA.b #$03 : STA $0F50, X
        
        JSL Sprite_PrepOamCoordLong
        JSR Sprite4_CheckIfActive
        
        LDA !timer_0, X : BEQ .termination_timer_not_set
        CMP.b #$01      : BNE .anoself_terminate
        
        STZ $0DD0, X
    
    .anoself_terminate
    
        RTS
    
    .termination_timer_not_set
    
        JSL Sprite_CheckDamageToPlayerSameLayerLong
        
        LDY.b #$00
        
        ; \note This usage of a speed deviates from most sprites in that it is
        ; expressed in pixels rather than 16ths of a pixel.
        LDA $0D50, X : BPL .sign_extend_x_speed
        
        DEY
    
    .sign_extend_x_speed
    
        ; Effectively this is Sprite_MoveHoriz but not in 16ths of a pixel.
              ADD $0D10, X : STA $0D10, X
        TYA : ADC $0D30, X : STA $0D30, X
        
        LDY.b #$00
        
        LDA $0D40, X : BPL .sign_extend_y_speed
        
        DEY
    
    .sign_extend_y_speed
    
        ; Same goes for the y speed (Sprite_MoveVert).
              ADD $0D00, X : STA $0D00, X
        TYA : ADC $0D20, X : STA $0D20, X
        
        JSR Sprite4_CheckTileCollision : BEQ .no_tile_collision
        
        LDA.b #$0C : STA !timer_0, X
    
    .no_tile_collision
    
        JSR BlindLaser_SpawnTrailGarnish
        
        RTS
    }

; ==============================================================================

    ; $EA2CB-$EA3D3 BRANCH LOCATION
    Sprite_Blind:
    {
        CMP.b #$02 : BNE .not_independent_head
        
        JMP Sprite_BlindHead
    
    .not_independent_head
    
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR Blind_Draw
        
        LDA.b #$01 : STA $0F50, X
        
        JSR Sprite4_CheckIfActive
        
        ; \note Blind wasn't designed so that his HP depletes normally. 
        LDA $0EA0, X : BEQ .not_counterattacking
        
        DEC $0EA0, X
        
        CMP.b #$0B : BNE .skip_damage_logic
        
        STZ $0EF0, X
        STZ $0E70, X
        
        LDA !timer_4, X : BNE .skip_damage_logic
        
        LDA.b #$80 : STA $0E50, X
        LDA.b #$30 : STA !timer_4, X
        
        LDA $0F50, X : AND.b #$01 : STA $0F50, X
        
        INC !hit_counter, X
        
        LDA !hit_counter, X : CMP.b #$03 : BCS .hit_counter_maxed
        
        LDA.b #$60 : STA $0E70, X
        
        LDA.b #$01 : STA !head_rotate_delay, X
        
        BRA .skip_damage_logic
    
    .time_to_die
    
        STZ !hit_counter, X
        
        INC !extra_head_counter
        
        LDA !extra_head_counter : CMP.b #$03 : BNE .spawn_extra_head
        
        ; \note Time for Blind and all his pals on screen to die.
        
        JSL Sprite_SchedulePeersForDeath
        
        ; Schedules Blind for death. Pretty sure.
        JSR Sprite_ScheduleBossForDeath
        
        LDA.b #$FF : STA !timer_0, X
                     STA $0EF0, X
        
        INC $0FFC
        
        LDA.b #$22 : JSL Sound_SetSfx3PanLong
        
        RTS
    
    .spawn_extra_head
    
        JSR Sprite4_Zero_XY_Velocity
        
        LDA.b #$06 : STA !blind_ai_state, X
        
        LDA.b #$FF : STA !timer_2, X
                     STA $0BA0, X
        
        JSR Blind_SpawnExtraHead
    
    .skip_damage_logic
    .not_counterattacking
    
        LDA !blind_subtype, X : BEQ .not_poof
        
        LDA !timer_0, X : BNE .delay_self_termination
        
        STZ $0DD0, X
    
    .delay_self_termination
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    
    .not_poof
    
        ; \optimize Slightly faster if we just load, xor with 0x01,
        ; store back, and then check flag. Same size in code.
        INC !forward_timer, X
        
        ; \note This extends timer 0 by about 50%. Since it's an 8-bit countdown
        ; timer, this means that it takes a maximum of 0x180 frames to expire
        ; for this sprite. This is not at all typical.
        LDA !forward_timer, X : AND.b #$01 : BNE .anopad_timer
        
        INC !timer_0, X
    
    .anopad_timer
    
        LDA !timer_1, X : BEQ .skip_damage_to_player_logic
        
        STZ !fire_laser, X
        
        CMP.b #$08 : BNE .anospawn_laser
        
        JSR Blind_SpawnLaser
    
    .anospawn_laser
    
        JMP Blind_CheckBumpDamage
    
    .skip_damage_to_player_logic
    
        ; \note Every time the laser can fire, this increments.
        INC $0B69
        
        LDA !laser_inhibit, X : BNE .cant_fire
        
        ; \note The probe sprite that Blind send out brings this flag high,
        ; but Blind has such lousy eyesight that it makes little difference.
        ; *Only* the Probe sprite can do this, by the way.
        LDA !fire_laser, X : BEQ .dont_fire
        
        ; Start a countdown during which Blind will fire a laser from its eyes.
        LDA.b #$10 : STA !timer_1, X
        
        LDA.b #$80 : STA !laser_inhibit, X
        
        BRA .unlatch_fire_laser_flag
    
    .cant_fire
    
        DEC !laser_inhibit, X
    
    .unlatch_fire_laser_flag
    
        STZ !fire_laser, X
    
    .dont_fire
    
        LDA $23 : STA $0D30, X
        LDA $21 : STA $0D20, X
        
        LDA !blind_ai_state, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Blind_BlindedByTheLight
        dw Blind_RetreatToBackWall
        dw Blind_OscillateAlongWall
        dw Blind_SwitchWalls
        dw Blind_WhirlAround
        dw Blind_FireballReprisal
        dw Blind_BehindTheCurtain
        dw Blind_Rerobe
    }

; ==============================================================================

    ; $EA3D4-$EA3D7 DATA
    pool Blind_BehindTheCurtain:
    {
    
    .animation_states
        db 14, 13, 12, 10
    }

; ==============================================================================

    ; *$EA3D8-$EA40A JUMP LOCATION
    Blind_BehindTheCurtain:
    {
        ; Prevent death from occurring since Blind can still spawn another
        ; head.
        STZ $0EF0, X
        
        LDA.b #$0C : STA !head_angle, X
        
        LDA !timer_2, X : BNE .delay_ai_state_transition
        
        INC !blind_ai_state, X
        
        LDA.b #$27 : STA !timer_2, X
        
        LDA.b #$13
        
        JSL Sound_SetSfx1PanLong
        
        RTS
    
    .delay_ai_state_transition
    
        CMP.b #$E0 : BCC .delay_desheeting
        
        SBC.b #$E0 : LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    
    .delay_desheeting
    
        LDA.b #$0E : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $EA40B-$EA40F DATA
    pool Blind_Rerobe:
    {
    
    .animation_states
        db 10, 11, 12, 13, 14
    }

; ==============================================================================

    ; *$EA410-$EA444 JUMP LOCATION
    Blind_Rerobe:
    {
        LDA !timer_2, X : BNE .delay_ai_state_transition
        
        LDA.b #$02 : STA !blind_ai_state, X
        
        LDA.b #$80 : STA !timer_0, X
        
        ; \hardcoded It depends upon Blind being in a 1 screen room in a corner.
        ; Set direction based on current Y position (sensible).
        LDA $0D00, X : ASL A
                       ROL A : AND.b #$01 : INC #2 : STA !blind_direction, X
        
        ; \hardcoded Also.
        ; Set head orientation based on current X position?
        LDA $0D10, X : ASL A : ROL A : STA !x_accel_polarity, X
        
        JSR Sprite4_Zero_XY_Velocity
        
        STZ $0BA0, X
        
        RTS
    
    .delay_ai_state_transition
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $EA445-$EA464 DATA
    pool Blind_FireballReprisal:
    {
    
    .x_speeds
        db -32, -28, -25, -16,   0,  16,  24,  28
        db  32,  28,  24,  16,   0, -16, -24, -28
    
    .y_speeds
        db   0,  16,  24,  28,  32,  28,  24,  16
        db   0, -16, -24, -28, -32, -28, -24, -16
    }

; ==============================================================================

    ; *$EA465-$EA4C5 JUMP LOCATION
    Blind_FireballReprisal:
    {
        DEC $0E70, X
        
        PHA
        
        AND.b #$07 : SEC : ROL A : STA $0F50, X
        
        ; \optimize Zero length branch. I wonder what was originally inside?
        PLA : BNE .zero_length_branch
    
    .zero_length_branch
    
        DEC !head_rotate_timer, X : BPL .anorotate_head
        
        LDA !head_rotate_delay, X : STA !head_rotate_timer, X
        
        LDA !head_angle, X : INC A : AND.b #$0F : STA !head_angle, X
    
    .anorotate_head
    
        LDA !forward_timer, X : AND.b #$1F : BNE .anoadjust_rotation_delay
        
        LDA !head_rotate_delay, X : CMP.b #$05 : BEQ .anoadjust_rotation_delay
        
        INC !head_rotate_delay, X
    
    .anoadjust_rotation_delay
    
        JSR Blind_AnimateBody
        
        ; Spawn very frequently (every 0x10 frames).
        LDA.b #$0F
    
    ; *$EA49D ALTERNATE ENTRY POINT
    shared Blind_SpawnFireball:
    
        LDY.b #$FF
        
        AND !forward_timer, X : BNE .delay_fireball_spawning
        
        JSL Sprite_SpawnFireball : BMI .spawn_failed
        
        LDA.b #$19 : JSL Sound_SetSfx3PanLong
        
        PHX
        
        LDA !head_angle, X : TAX
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        JSR Medusa_ConfigFireballProperties
        
        PLX
    
    .spawn_failed
    .delay_fireball_spawning
    
        RTS
    }

; ==============================================================================

    ; *$EA4C6-$EA4F8 JUMP LOCATION
    Blind_BlindedByTheLight:
    {
        ; Wrapped up like a douche and the somethin something something?
        
        LDA.b #$00 : STA $0AE8
        
        LDA.b #$A0 : STA $0AEA
        
        LDA !timer_2, X : BNE .anoadvance_ai_state
        
        INC !blind_ai_state, X
        
        LDA.b #$60 : STA !timer_2, X
    
    .anoadvance_ai_state
    
        CMP.b #$50 : BNE .anocomplain
        
        PHA
        
        ; "Gyaaa! Too bright!"
        LDA.b #$23 : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        PLA
    
    .anocomplain
    
        CMP.b #$18 : BNE .anopoo
        
        JSR Blind_SpawnPoof
    
    .anopoof
    
        RTS
    }

; ==============================================================================

    ; *$EA4F9-$EA539 LOCAL
    Blind_SpawnPoof:
    {
        LDA.b #$0C : STA $012E
        
        LDA.b #$CE : JSL Sprite_SpawnDynamically
        
        LDA $00 : ADD.b #$10 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$28 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$0F : STA $0DC0, Y
        
        LDA.b #$01 : STA !blind_subtype, Y
        
        LDA.b #$2F : STA !timer_0, Y
        
        LDA.b #$09 : STA $0E40, Y : STA $0BA0, Y
        
        RTS
    }

; ==============================================================================

    ; *$EA53A-$EA566 JUMP LOCATION
    Blind_RetreatToBackWall:
    {
        JSR Blind_CheckBumpDamage
        
        LDA.b #$09 : STA $0DC0, X
        
        LDA !timer_2, X : BNE .anoadvance_ai_state
        
        INC !blind_ai_state, X
        
        LDA.b #$FF : STA !timer_0, X
        
        STZ $0BA0, X
    
    .anoadvance_ai_state
    
        CMP.b #$40 : BCS .delay_upward_migration
        
        LDA.b #-8 : STA $0D40, X
        
        JSR Sprite4_MoveVert
    
    .delay_upward_migration
    
        JSR Blind_Animate
        
        LDA.b #$04 : STA !head_angle, X
        
        RTS
    }

; ==============================================================================

    ; $EA567-$EA56C DATA
    pool Blind_OscillateAlongWall:
    {
    
    .y_speed_limits
        db 18, -18
    
    .x_speed_limits
        db 24, -24
    
    .x_coord_limits
        db $A4, $76
    }

; ==============================================================================

    ; *$EA56D-$EA601 JUMP LOCATION
    Blind_OscillateAlongWall:
    {
        JSR Blind_CheckBumpDamage
        JSR Blind_Animate
        
        LDA !forward_timer, X : AND.b #$7F : BNE .ignore_player_position
        
        JSR Sprite4_IsBelowPlayer
        
        ; Results in Y being 2 or 3 (3 if sprite is below player).
        INY #2
        
        TYA : CMP !blind_direction, X : BNE .player_got_behind_us
    
    .ignore_player_position
    
        LDA !timer_0, X : BNE .delay_ai_state_transition
    
    .player_got_behind_us
    
        LDA $0D10, X : CMP.b #$78 : BCS .delay_ai_state_transition
        
        INC !blind_ai_state, X
        
        ; \wtf Why... do this exactly?
        LDA $0D40, X : AND.b #$FE : STA $0D40, X
        
        LDA $0D50, X : AND.b #$FE : STA $0D50, X
        
        LDA.b #$30 : STA !timer_2, X
        
        RTS
    
    .delay_ai_state_transition
    
        LDA !y_accel_polarity, X : AND.b #$01 : TAY
        
        LDA $0D40, X : ADD $8000, Y : STA $0D40, X
        
        CMP $A567, Y : BNE .anoinvert_y_acceleration
        
        INC !y_accel_polarity, X
    
    .anoinvert_y_acceleration
    
        LDA !x_accel_polarity, X : AND.b #$01 : TAY
        
        LDA $0D50, X : CMP .x_speed_limits, Y : BEQ .x_speed_maxed
        
        ADD $8000, Y : STA $0D50, X
    
    .x_speed_maxed
    
        ; Again... why snap to a grid?
        LDA $0D10, X : AND.b #$FE
        
        CMP .x_coord_limits, Y : BNE .anoinvert_x_acceleration
        
        INC !x_accel_polarity, X
    
    .anoinvert_x_acceleration
    
        JSR Sprite4_Move
        
        LDA $0E70, X : BEQ .no_tile_bump
        
        JMP Blind_FireballReprisal
    
    .no_tile_bump
    
        ; \optimize Learn the BIT instruction. Sheesh guys.
        LDA !forward_timer, X : AND.b #$07 : BNE .anospawn_probe
        
        LDA !head_angle, X : ASL #2 : STA $0F
        
        JSL Sprite_SpawnProbeAlwaysLong
    
    .anospawn_probe
    
        RTS
    }

; ==============================================================================

    ; $EA602-$EA607 DATA
    pool Blind_SwitchWalls:
    {
    
    .y_accellerations
        db 2, -2
    
    .y_speed_limits
        db 64, -64
    
    .y_pos_limits
        db $90, $50
    }

; ==============================================================================

    ; *$EA608-$EA662 JUMP LOCATION
    Blind_SwitchWalls:
    {
        ; This state has Blind migrate to the opposite wall from where he's
        ; currently at.
        
        JSR Blind_CheckBumpDamage
        
        LDA !timer_2, X : BEQ .stop_decelerating
        
        JSR Blind_Decelerate_X
        JSR Sprite4_MoveHoriz
        JMP Blind_Decelerate_Y
    
    .stop_decelerating
    
        LDA !blind_direction, X : DEC #2 : TAY
        
        LDA $0D40, X : CMP .y_speed_limits, Y : BEQ .y_speed_maxed
        
        ADD .y_accelerations, Y : STA $0D40, X
    
    .y_speed_maxed
    
        LDA $0D00, X : AND.b #$FC
        
        CMP .y_pos_limits, Y : BNE .delay_whirl_around
        
        INC !blind_ai_state, X
        
        LDA !blind_direction, X : SUB.b #$01 : STA !y_accel_polarity, X
    
    .delay_whirl_around
    
        JSR Sprite4_Move
    
    ; *$EA647 ALTERNATE ENTRY POINT
    shared Blind_Decelerate_X:
    
        LDA $0D50, X : BEQ .fully_decelerated_x
                       BPL .positive_speed_x
        
        ADD.b #$04
    
    .positive_speed_x
    
        SUB.b #$02 : STA $0D50, X
    
    .fully_decelerated_x
    
        JSR Blind_AnimateBody
        
        LDA $0E70, X : BEQ .inactive
        
        JMP Blind_FireballReprisal
    
    .inactive
    
        RTS
    }

; ==============================================================================

    ; $EA663-$EA666 DATA
    pool Blind_WhirlAround
    {
    
    .animation_step_directions
        db -1, 1
    
    .animation_limits
        db  0, 9
    }

; ==============================================================================

    ; *$EA667-$EA6BF JUMP LOCATION
    Blind_WhirlAround:
    {
        JSR Blind_CheckBumpDamage
        
        LDA !forward_timer, X : AND.b #$07 : BNE .delay_animation_adjustment
        
        LDA !blind_direction, X : DEC #2 : TAY
        
        LDA $0DC0, X : CMP .animation_limits, Y : BNE .not_yet_in_position
        
        LDA.b #$FE : STA !timer_0, X
        
        LDA.b #$02 : STA !blind_ai_state, X
        
        LDA !blind_direction, X : EOR.b #$01 : STA !blind_direction, X
        
        LDA $0D10, X : ASL A : ROL A : AND.b #$01 : STA !x_accel_polarity, X
        
        BRA .animation_logic_done
    
    .not_yet_in_position
    
        ADD .animation_step_directions, Y : STA $0DC0, X
    
    .animation_logic_done
    .delay_animation_adjustment
    
    ; *$EA6A4 ALTERNATE ENTRY POINT
    shared Blind_Decelerate_Y:
    
        LDA $0D40, X : BEQ .fully_decelerated_y
                       BPL .positive_y_speed
        
        ADD.b #$08
    
    .positive_y_speed
    
        SUB.b #$04 : STA $0D40, X
    
    .fully_decelerated_y
    
        JSR Sprite4_MoveVert
        
        LDA $0E70, X : BEQ .inactive
        
        JMP Blind_FireballReprisal
    
    .inactive
    
        RTS
    }

; ==============================================================================

    ; *$EA6C0-$EA6CE LOCAL
    Blind_CheckBumpDamage:
    {
        LDA !timer_4, X : ORA $0EA0, X : BNE .temporarily_intouchable
        
        JSR Sprite4_CheckDamage
    
    .temporarily_intouchable
    
        JSR Blind_BumpDamageFromBody
        
        RTS
    }

; ==============================================================================

    ; $EA6CF-$EA6EE DATA
    pool Blind_Animate:
    {
    
    .animation_states
        db 7, 8, 9, 8, 0, 1, 2, 1
    
        ; \task Name these sublabels.
        db 0,  1,  2,  3,  4,  3,  2,  1
        db 0, 15, 14, 13, 12, 13, 14, 15
    
    
        db 0, 1, 1, 2, 2, 3, 3, 4
    }

; ==============================================================================

    ; *$EA6EF-$EA744 LOCAL
    Blind_Animate:
    {
        ; \task What the hell is this routine doing? Targeting the laser on
        ; the player? Update: it seems to roughly try to track where the
        ; player is, but Blind has bad eyesight so he still kind of haphazardly
        ; looks for the player.
        LDA $0E70, X : BNE .counterattacking
        
        ; This logic animates the head loosely based on the player's
        ; X coordinate.
        LDA $22 : LSR #5 : TAY
        
        LDA $A6E7, Y
        
        LDY !blind_direction, X : CPY.b #$03 : BNE .facing_down
        
        EOR.b #$FF : INC A
    
    .facing_down
    
        STA $01
        
        ; Results in either 0 or 8.
        TYA : DEC #2 : ASL #3 : STA $00
        
        ; Pad in this .... value that comes from somewhere? A probe?
        LDA $0B69 : LSR #3 : AND.b #$07 : ADC $00 : TAY
        
        ; Now offset it by another small amount we calculated earlier and...
        ; fire the laser?
        LDA $A6D7, Y : ADD $01 : AND.b #$0F : STA !head_angle, X
    
    .counterattacking
    
    ; *$EA729 ALTERNATE ENTRY POINT
    ; \task Come back eventually and see if there were any other animate
    ; functions named.
    shared Blind_AnimateBody:
    
        LDA !blind_direction, X : DEC #2 : ASL #4 : STA $00
        
        LDA !forward_timer, X : LSR #3 : AND.b #$03 : ADD $00 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $EA745-$EA764 DATA
    pool Blind_SpawnLaser:
    {
    
    .x_speeds
        db -8, -8, -8, -4,  0,  4,  8,  8
        db  8,  8,  8,  4,  0, -4, -8, -8
    
    .y_speeds
        db  0,  0,  4,  8,  8,  8,  4,  0
        db  0,  0, -4, -8, -8, -8, -4,  0    
    }

; ==============================================================================

    ; *$EA765-$EA7A9 LOCAL
    Blind_SpawnLaser:
    {
        LDA.b #$CE : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sound_SetSfxPan : ORA.b #$26 : STA $012F
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $00 : ADD.b #$04 : STA $0D10, Y
        
        LDA !head_angle, X : STA !head_angle, Y
        
        PHX
        
        TAX
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA.b #$80 : STA !blind_subtype, Y
                     STA $0BA0, Y
        
        LDA.b #$40 : STA $0E40, Y
        
        LDA.b #$14 : STA $0F60, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $EA7AA-$EAC2E DATA
    BlindPoof_Draw:
    {
        ; \task Fill in data.
    
    ; $EA7AA
    .body_oam_groups
        
    
    ; $EABFC
    .oam_groups
        
    
    ; $EAC19
    .num_oam_entries
        
    }

; ==============================================================================

    ; *$EAC2F-$EAC41 BRANCH LOCATION
    BlindPoof_Draw:
    {
        PHA
        
        ASL A : TAY
        
        REP #$20
        
        LDA .oam_groups, Y : STA $08
        
        SEP #$20
        
        PLY
        
        LDA .num_oam_entries, Y : JMP Sprite4_DrawMultiple
    }

; ==============================================================================

    ; $EAC42-$EAC6D DATA
    pool Blind_Draw:
    {
    
    .chr_patch_offsets
        db $12, $12, $12, $16, $16, $02, $02, $02
        db $02, $02
    
    .chr
        db $86, $86, $84, $82, $80, $82, $84, $86
        db $86, $86, $88, $8A, $8C, $8A, $88, $86
    
    .vh_flip
        db $00, $00, $00, $00, $00, $40, $40, $40
        db $40, $40, $40, $40, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$EAC6C-$EACC7 LOCAL
    Blind_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : CMP.b #$0F : BCS BlindPoof_Draw
        
        REP #$20
        
        ASL #3 : STA $00
        
        ASL #3 : SUB $00 : ADD.w #BlindPoof_Draw.body_oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$07 : JSR Sprite4_DrawMultiple
        
        LDA $0E70, X : BNE .using_fireball_counterattack
        
        LDA !blind_ai_state, X : CMP.b #$06 : BEQ .sheet_is_down
                                 CMP.b #$04 : BEQ .dont_draw_head
    
    .using_fireball_counterattack
    
        LDY $0DC0, X : CPY.b #$0A : BCS .dont_draw_head
        
        ; These are for patching the head's chr as it 'rotates' as it moves
        ; left or right.
        LDA .chr_patch_offsets, Y : TAY
        
        PHX
        
        LDA !head_angle, X : TAX
        
        LDA .chr, X : STA ($90), Y : INY
        
        LDA ($90), Y : AND.b #$3F : ORA .vh_flip, X : STA ($90), Y
        
        PLX
    
    .dont_draw_head
    
        RTS
    
    .sheet_is_down
    
        ; \task Disables.... part of the sheet? or the head?
        LDY.b #$19
        
        LDA.b #$F0 : STA ($90), Y
        
        RTS
    }

; ==============================================================================

    ; \task A tentative name. Please make sure this is correct.
    ; *$EACC8-$EAD0D LOCAL
    Blind_BumpDamageFromBody:
    {
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$000E : CMP.w #$001C : BCS .dont_damage
        
        LDA $20 : SUB $0FDA : ADD.w #$0000 : CMP.w #$001C : BCS .dont_damage
        
        SEP #$20
        
        LDA $031F : ORA $037B : BNE .dont_damage
        
        LDA.b #$01 : STA $4D
        
        ; Damage player by one heart.
        ; \hardcoded Ignores armor value.
        LDA.b #$08 : STA $0373
        
        LDA.b #$10 : STA $46
        
        LDA $28 : EOR.b #$FF : STA $28
        LDA $27 : EOR.b #$FF : STA $27
    
    .dont_damage
    
        SEP #$20
        
        RTS
    }

; ==============================================================================
