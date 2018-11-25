
; ==============================================================================

    ; *$4B714-$4B772 LOCAL
    Overlord_SpawnBoulder:
    {
        LDA $1B : BNE .indoors
        
        LDA $0FFD : BEQ .cant_spawn
        
        LDA $11 : ORA $0FC1 : BNE .cant_spawn
        
        INC $0FFE : LDA $0FFE : AND.b #$3F : BNE .cant_spawn
        
        LDA $E9 : SUB $0FBF : CMP.b #$02 : BMI .cant_spawn
        
        LDA.b #$C2
        LDY.b #$0D
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL GetRandomInt : AND.b #$7F : ADD.b #$40 : ADD $E2 : STA $0D10, Y
                           LDA $E3    : ADC.b #$00           : STA $0D30, Y
        
        LDA $E8 : SUB.b #$30 : STA $0D00, Y
        LDA $E9 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$00 : STA $0F20, Y : STA $0DE0, Y : STA $0F70, Y
    
    .spawn_failed
    .cant_spawn
    .indoors
    
        RTS
    }

; ==============================================================================

    ; *$4B773-$4B77D LONG
    Overlord_Main:
    {
        PHB : PHK : PLB
        
        JSR Overlord_ExecuteAll
        JSR Overlord_SpawnBoulder
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4B77E-$4B792 LOCAL
    Overlord_ExecuteAll:
    {
        LDA $11 : ORA $0FC1 : BNE .pause_execution
        
        LDX.b #$07
    
    .next_overlord
    
        LDA $0B00, X : BEQ .inactive_overlord
        
        JSR Overlord_ExecuteSingle
    
    .inactive_overlord
    
        DEX : BPL .next_overlord
    
    .pause_execution
    
        RTS
    }

; ==============================================================================

    ; *$4B793-$4B7DB LOCAL
    Overlord_ExecuteSingle:
    {
        ; OVERLORD HANDLER
        
        PHA
        
        JSR Overlord_CheckInRangeStatus
        
        PLA : DEC A : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        LDA .handlers, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .handlers
        dw Overlord_SpritePositionTarget         ; 0x01 - 
        dw Overlord_AllDirectionMetalBallFactory ; 0x02 - Generates metal balls in specific positions all around a quadrant of a room.
        dw Overlord_CascadeMetalBallFactory      ; 0x03 - Alternates generating metal balls at two positions and sometimes makes one large ball.
        dw Overlord_StalfosFactory               ; 0x04 - Probably unused in the original game, not positive.
        dw Overlord_StalfosTrap                  ; 0x05 - Stalfos trap (what's the other one do?)
        dw Overlord_SnakeTrap                    ; 0x06 - Snake trap
        dw Overlord_MovingFloor                  ; 0x07 - Moving floor
        dw Overlord_ZolFactory                   ; 0x08 - Zol factory
        dw Overlord_WallMasterFactory            ; 0x09 - Floormaster?
        dw Overlord_CrumbleTilePath              ; 0x0A - Falling tiles
        dw Overlord_CrumbleTilePath              ; 0x0B - Falling tiles 2
        dw Overlord_CrumbleTilePath              ; 0x0C - Falling tiles 3
        dw Overlord_CrumbleTilePath              ; 0x0D - Falling tiles 4
        dw Overlord_CrumbleTilePath              ; 0x0E - Falling tiles 5
        dw Overlord_CrumbleTilePath              ; 0x0F - Falling tiles 6
        dw Overlord_PirogusuFactory              ; 0x10 - Spawn pirogusu out of the walls in swamp palace.
        dw Overlord_PirogusuFactory              ; 0x11 - Spawn pirogusu out of the walls in swamp palace.
        dw Overlord_PirogusuFactory              ; 0x12 - Spawn pirogusu out of the walls in swamp palace.
        dw Overlord_PirogusuFactory              ; 0x13 - Spawn pirogusu out of the walls in swamp palace.
        dw Overlord_FlyingTileFactory            ; 0x14 - Spawns the flying tiles in annoying rooms in various dungeons.
        dw Overlord_WizzrobeFactory              ; 0x15 - 
        dw Overlord_ZoroFactory                  ; 0x16 - 
        dw Overlord_StalfosTrapTriggerWindow     ; 0x17 - 
        dw Overlord_RedStalfosTrap               ; 0x18 - 
        dw Overlord_ArmosCoordinator             ; 0x19 - 
        dw Overlord_BombTrap                     ; 0x1A - Bomb Trap
    }

; ==============================================================================

    ; *$4B7DC-$4B7E0 JUMP LOCATION
    Overlord_ArmosCoordinator:
    {
        JSL ArmosCoordinatorLong
        
        RTS
    }

; ==============================================================================

    ; $4B7E1-$4B7F4 DATA
    pool Overlord_RedStalfosTrap:
    {
    
    .x_offsets_low
        db   0,   0, -48,  48
    
    .x_offsets_high
        db   0,   0,  -1,   0
    
    .y_offsets_low
        db -40,  56,   8,   8
    
    .y_offsets_high
        db  -1,   0,   0,   0
    
    .stalfos_delay_timers
        db $30, $50, $70, $90
    }

; ==============================================================================

    ; \unused(unconfirmed) If used, I certainly can't remember where.
    ; *$4B7F5-$4B883 JUMP LOCATION
    Overlord_RedStalfosTrap:
    {
        LDA $0B08, X : STA $00
        LDA $0B10, X : STA $01
        
        LDA $0B18, X : STA $02
        LDA $0B20, X : STA $03
        
        REP #$20
        
        LDA $00 : SUB $22 : ADD.w #$0018 : CMP.w #$0030 : BCS .not_triggered
        LDA $02 : SUB $20 : ADD.w #$0018 : CMP.w #$0030 : BCS .not_triggered
        
        SEP #$20
        
        STZ $0B00, X
        
        LDA.b #$03 : STA $0FB5
    
    .next_spawn
    
        LDA.b #$A7
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        PHX
        
        LDX $0FB5
        
        LDA $22 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $23 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $20 : ADD .y_offsets_low , X : STA $0D00, Y
        LDA $21 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .stalfos_delay_timers, X : STA $0DF0, Y
        
        PLX
        
        LDA $0B40, X : STA $0F20, Y
        
        LDA.b #$01 : STA $0E90, Y
        
        LDA.b #$03 : STA $0E40, Y
        
        DEC A : STA $0DE0, Y
    
    .spawn_failed
    
        DEC $0FB5 : BPL .next_spawn
    
    .not_triggered
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$4B884-$4B8C0 JUMP LOCATION
    Overlord_StalfosTrapTriggerWindow:
    {
        LDA $0B08, X : STA $00
        LDA $0B10, X : STA $01
        
        LDA $0B18, X : STA $02
        LDA $0B20, X : STA $03
        
        REP #$20
        
        LDA $00 : SUB $22 : ADD.w #$0020 : CMP.w #$0040 : BCS .outOfRange
        LDA $02 : SUB $20 : ADD.w #$0020 : CMP.w #$0040 : BCS .outOfRange
        
        SEP #$20
        
        STZ $0B00, X
        
        INC $0B9E
    
    .outOfRange
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $4B8C1-$4B8D0 DATA
    pool Overlord_ZoroFactory:
    {
    
    .x_offsets_low
        db $FC, $FE, $00, $02, $04, $06, $08, $0C
    
    .x_offsets_high
        db $FF, $FF, $00, $00, $00, $00, $00, $00    
    }

; ==============================================================================

    ; *$4B8D1-$4B971 JUMP LOCATION
    Overlord_ZoroFactory:
    {
        DEC $0B30, X
        
        LDA $0B18, X : ADD.b #$08 : STA $00
        LDA $0B20, X : ADC.b #$00 : STA $01
        
        LDA $0B08, X : ADD.b #$08 : STA $02
        LDA $0B10, X : ADC.b #$00 : STA $03
        
        LDA $0B40, X
        
        JSL Entity_GetTileAttr : CMP.b #$82 : BNE .cant_spawn
        
        ; If timer hasn't counted down yet do nothing
        LDA $0B30, X : CMP.b #$18 : BCS .cant_spawn
        
        ; even when within the timer range, only spawn if (the timer % 4 == 0)
        AND.b #$03 : BNE .cant_spawn
        
        ; Try to spawn zoro (out of bombed out hole in wall)
        LDA.b #$9C
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        PHX
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        ; \task Just out of curiosity, figure out if this paradigm of PHP
        ; PLP is really required in these scenarios...
        LDA $05 : ADD .x_offsets_low, X  : PHP
                  ADD.b #$08             : STA $0D10, Y
        LDA $06 : ADC.b #$00             : PLP
                  ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $07 : ADD.b #$08 : STA $0D00, Y
        LDA $08              : STA $0D20, Y
        
        PLX
        
        LDA $0B40, X : STA $0F20, Y
        
        LDA.b #$01 : STA $0F60, Y
                     STA $0E90, Y
                     STA $0BA0, Y
        
        LDA.b #$10 : STA $0D40, Y
        LDA.b #$20 : STA $0E40, Y
        LDA.b #$0D : STA $0F50, Y
        
        JSL GetRandomInt : STA $0E80, Y
        
        LDA.b #$30 : STA $0DF0, Y
        LDA.b #$03 : STA $0CD2, Y
    
    .spawn_failed
    .cant_spawn
    
        RTS
    }

; ==============================================================================

    ; $4B972-$4B985 DATA
    pool Overlord_WizzrobeFactory:
    {
    
    .x_offsets_low
        db 48, -48,   0,   0
    
    .x_offsets_high
        db  0,  -1,   0,   0
    
    .y_offsets_low
        db 16,  16,  64, -64
    
    .y_offsets_high
        db 0,    0,   0,  -1
    
    .wizzrobe_delay_timers
        db 0,   10,  20,  30
    }

; ==============================================================================

    ; *$4B986-$4B9E7 JUMP LOCATION
    Overlord_WizzrobeFactory:
    {
        LDA $0B30, X : CMP.b #$80 : BEQ .spawn
        
        LDA $1A : LSR A : BCC .delay
        
        DEC $0B30, X
    
    .delay
    
        RTS
    
    .spawn
    
        LDA.b #$7F : STA $0B30, X
        
        LDA.b #$03 : STA $0FB5
    
    .next_spawn_attempt
    
        LDA.b #$9B 
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically_arbitrary : BMI .spawn_failed
        
        PHX
        
        LDX $0FB5
        
        LDA $22 : ADD $B972, X : STA $0D10, Y
        LDA $23 : ADC $B976, X : STA $0D30, Y
        
        LDA $20 : ADD $B97A, X : STA $0D00, Y
        LDA $21 : ADC $B97E, X : STA $0D20, Y
        
        ; \task Figure out what this really does and if there's a better
        ; name out there for this sublabel.
        LDA .wizzrobe_delay_timers, X : STA $0DF0, Y
        
        PLX
        
        LDA $0B40, X : STA $0F20, Y
        
        LDA.b #$01 : STA $0DA0, Y
    
    .spawn_failed
    
        DEC $0FB5 : BPL .next_spawn_attempt
        
        RTS
    }

; ==============================================================================

    ; *$4B9E8-$4BA29 JUMP LOCATION
    Overlord_FlyingTileFactory:
    {
    	LDA $0B08, X : CMP $E2
    	LDA $0B10, X : SBC $E3 : BNE .out_of_range

    	LDA $0B18, X : CMP $E8
    	LDA $0B20, X : SBC $E9 : BNE .out_of_range

    	DEC $0B30, X

    	LDA $0B30, X : CMP.b #$80 : BEQ .spawn_flying_tile

    	RTS

    .resetTimer

    	LDA.b #$81 : STA $0B30, X

    	RTS
    
    .spawn_flying_tile
    
    	JSR Overlord_SpawnFlyingTile : BMI .resetTimer
        
    	INC $0B28, X
        
    	LDA $0B28, X : CMP.b #$16 : BEQ .selfTerminate
        
    	LDA.b #$E0 : STA $0B30, X
        
    	RTS
    
    .selfTerminate
    
    	STZ $0B00, X
    
    .out_of_range
    
    	RTS
    }

; ==============================================================================

    ; $4BA2A-$4BA55 DATA
    pool Overlord_SpawnFlyingTile:
    {
    
    .x_coords_low
        db $70, $80, $60, $90, $90, $60, $70, $80
        db $80, $70, $50, $A0, $A0, $50, $50, $A0
        db $A0, $50, $70, $80, $80, $70
    
    .y_coords_low
        db $80, $80, $70, $90, $70, $90, $60, $A0
        db $60, $A0, $60, $B0, $60, $B0, $80, $90
        db $80, $90, $70, $90, $70, $90
    }

; ==============================================================================

    ; *$4BA56-$4BAAB LOCAL
    Overlord_SpawnFlyingTile:
    {
        LDA.b #$94 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$01 : STA $0E90, Y
        
        PHX : LDA $0B28, X : TAX
        
        ; \note The high portions are fed off of the high bytes of this
        ; overlord.
        LDA .x_coords_low, X : STA $0D10, Y
        
        LDA .y_coords_low, X : SUB.b #$08 : STA $0D00, Y
        
        PLX
        
        LDA $0B20, X : STA $0D20, Y
        LDA $0B10, X : STA $0D30, Y
        
        LDA $0B40, X : STA $0F20, Y
        
        LDA.b #$04 : STA $0E50, Y
        
        LDA.b #$00 : STA $0BE0, Y
                     STA $0E50, Y
        
        LDA.b #$08 : STA $0CAA, Y
        LDA.b #$04 : STA $0E40, Y
        LDA.b #$01 : STA $0F50, Y
        LDA.b #$04 : STA $0CD2, Y
    
    .spawnFailed
    
        RTS
    }

; ==============================================================================

    ; *$4BAAC-$4BABF JUMP LOCATION
    Overlord_PirogusuFactory:
    {
        LDA $0B00, X : SUB.b #$10 : STA $0FB5
        
        LDA $0B30, X : CMP.b #$80 : BEQ PirogusuFactory_Main
        
        ; Don't spawn until this timer expires.
        DEC $0B30, X
        
        RTS
    }

; ==============================================================================

    ; $4BAC0-$4BAC3 DATA
    pool PirogusuFactory_Main:
    {
    
    .dirctions
        db 2, 3, 0, 1
    }

; ==============================================================================

    ; *$4BAC4-$4BB23 BRANCH LOCATION
    PirogusuFactory_Main:
    {
        JSL GetRandomInt : AND.b #$1F
                           ADD.b #$60 : STA $0B30, X
        
        STZ $00
        
        LDY.b #$0F
    
    ; \wtf ... Why octospawn instead of pirogusu here? This makes no sense.
    ; Quite possibly \bug !
    .count_octospawn
    
        LDA $0DD0, Y : BEQ .skip_slot
        
        LDA $0E20, Y : CMP.b #$10 : BNE .not_octospawn
        
        INC $00
    
    .not_octospawn
    .skip_slot
    
        DEY : BPL .count_octospawn
        
        LDA $00 : CMP.b #$05 : BCS .octospawn_maxed_out
        
        LDY.b #$0C
        LDA.b #$94
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        LDA $05 : STA $0D10, Y
        LDA $06 : STA $0D30, Y
        
        LDA $07 : STA $0D00, Y
        LDA $08 : STA $0D20, Y
        
        LDA $0B40, X : STA $0F20, Y
        
        LDA.b #$20 : STA $0DF0, Y
        
        LDA $0FB5 : STA $0DE0, Y
        
        PHX
        
        TAX
        
        LDA .directions, X : STA $0D90, Y
        
        PLX
    
    .octospawn_maxed_out
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $4BB24-$4BBB1 DATA
    pool Overlord_CrumbleTilePath:
    {
        ; Defines to make it easier to tell what the path looks like.
        !right = 0
        !left  = 1
        !down  = 2
        !up    = 3
        
    ; $bb24
    .rectangle
        db  !down,  !down,  !down,  !down,  !down,  !down
        db  !left,  !left,  !left,  !left,  !left,  !left, !left
        db    !up,    !up,    !up,    !up,    !up,    !up
        db !right, !right, !right, !right, !right, !right
    
    .snake_upward
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right, !up, !left, !up
        db !right
    
    .line_rightward
        db !right, !right, !right, !right, !right, !right, !right, !right
        db !right, !right, !right
    
    .line_downward
        db !down, !down, !down, !down, !down, !down, !down, !down
        db !down, !down
    
    .line_leftward
        db !left, !left, !left, !left, !left, !left, !left, !left
        db !left, !left, !left
    
    .line_upward
        db !up, !up, !up, !up, !up, !up, !up, !up
        db !up, !up
    
    .x_adjustments_low
        db 16, -16,   0,   0
    
    .x_adjustments_high
        db  0,  -1,   0,   0
    
    .y_adjustments_low
        db  0,   0,  16, -16
    
    .y_adjustments_high
        db  0,   0,   0,  -1 
    
    .crumble_tile_limit
        db 26, 42, 12, 11, 12, 11
    
    ; \task perhaps express these pointers flat, then interlave them when we get
    ; the assembler features for it?
    .pointers_low
        db .rectangle,
        db .snake_upward,
        db .line_rightward,
        db .line_downward,
        db .line_leftward,
        db .line_upward
    
    .pointers_high
        db .rectangle      >> 8,
        db .snake_upward   >> 8,
        db .line_rightward >> 8,
        db .line_downward  >> 8,
        db .line_leftward  >> 8,
        db .line_upward    >> 8
    }

; ==============================================================================

    ; *$4BBB2-$4BC30 JUMP LOCATION
    Overlord_CrumbleTilePath:
    {
        LDA $0B30, X : BEQ .timer_expired
        
        LDA $0B38, X : BEQ .check_on_screen
        
        DEC $0B30, X
        
        RTS
    
    .check_on_screen
    
        LDA $0B08, X : CMP $E2
        LDA $0B10, X : SBC $E3 : BNE .off_screen
        
        LDA $0B18, X : CMP $E8
        LDA $0B20, X : SBC $E9 : BNE .off_screen
        
        ; If on screen even once in this logic, the overlord will continue
        ; crumbling tiles.
        INC $0B38, X
    
    .off_screen
    
        RTS
    
    .timer_expired
    
        LDA.b #$10 : STA $0B30, X
        
        JSR CrumbleTilePath_SpawnCrumbleTileGarnish
        
        INC $0B28, X
        
        LDA $0B00, X : SUB.b #$0A : TAY
        
        LDA .pointers_low, Y  : STA $00
        LDA .pointers_high, Y : STA $01
        
        LDA .crumble_tile_limit, Y : CMP $0B28, X : BNE .crumble_tiles_not_maxed
        
        STZ $0B00, X
    
    .crumble_tiles_not_maxed
    
        LDY $0B28, X : DEY
        
        LDA ($00), Y : TAY
        
        LDA $0B08, X : ADD .x_adjustments_low,  Y : STA $0B08, X
        LDA $0B10, X : ADC .x_adjustments_high, Y : STA $0B10, X
        
        LDA $0B18, X : ADD .y_adjustments_low,  Y : STA $0B18, X
        LDA $0B20, X : ADC .y_adjustments_high, Y : STA $0B20, X
        
        RTS
    }

; ==============================================================================

    ; *$4BC31-$4BC7A LOCAL
    CrumbleTilePath_SpawnCrumbleTileGarnish:
    {
        TXY
        
        PHX
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BNE .non_empty_slot
        
        LDA.b #$03 : STA $7FF800, X
        
        LDA $0B08, Y : STA $7FF83C, X
        
        JSL Sound_GetFineSfxPan : ORA.b #$1F : STA $012E
        
        LDA $0B10, Y : STA $7FF878, X
        
        LDA $0B18, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0B20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$1F : STA $7FF90E, X
                     STA $0FB4
        
        BRA .return
    
    .non_empty_slot
    
        DEX : BPL .next_slot
    
    .return
    
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$4BC7B-$4BCC2 JUMP LOCATION
    Overlord_WallMasterFactory:
    {
        LDA $0B30, X : CMP.b #$80 : BEQ .timer_expired
        
        LDA $1A : AND.b #$01 : BNE .anotick_timer
        
        DEC $0B30, X
    
    .anotick_timer
    
        RTS
    
    .timer_expired
    
        LDA.b #$7F : STA $0B30, X
        
        LDA.b #$90
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        LDA $22 : STA $0D10, Y
        LDA $23 : STA $0D30, Y
        
        LDA $20 : STA $0D00, Y
        LDA $21 : STA $0D20, Y
        
        LDA.b #$D0 : STA $0F70, Y
        
        PHX
        
        TYX
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        PLX
        
        LDA $EE : STA $0F20, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$4BCC3-$4BD3E JUMP LOCATION
    Overlord_ZolFactory:
    {
        LDA $0B30, X : BEQ .timer_expired
        
        DEC $0B30, X
        
        RTS
    
    .timer_expired
    
        ; And promptly reset it...
        LDA.b #$A0 : STA $0B30, X
        
        STZ $00
        
        LDY.b #$0F
    
    .count_current_zols
    
        LDA $0DD0, Y : BEQ .skip_slot
        
        LDA $0E20, Y : CMP.b #$8F : BNE .not_zol
        
        INC $00
    
    .skip_slot
    .not_zol
    
        DEY : BPL .count_current_zols
        
        LDA $00 : CMP.b #$05 : BCS .zols_currently_maxed_out
        
        LDA.b #$8F
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        PHX
        
        LDA $2F : LSR A : TAX
        
        LDA $22 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $23 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $20 : ADD .y_offsets_low,  X : STA $0D00, Y
        LDA $21 : ADC .y_offsets_high, X : STA $0D20, Y
        
        PLX
        
        LDA.b #$C0 : STA $0F70, Y
        
        LDA $EE : STA $0F20, Y
        
        LDA.b #$02 : STA $0D80, Y
                     STA $0E90, Y
                     STA $0DB0, Y
        
        JSL GetRandomInt : AND.b #$1F : ORA.b #$10 : STA $0EB0, Y
    
    .zols_currently_maxed_out
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$4BD3F-$4BD8C JUMP LOCATION
    Overlord_MovingFloor:
    {
        LDA $0DD0 : CMP.b #$04 : BNE .mothula_not_exploding
        
        STZ $0B00, X
        
        BRA .halt_floor
    
    .mothula_not_exploding
    
        LDA $0B28, X : BNE .locked_in_moving_state
        
        INC $0B30, X : LDA $0B30, X : CMP.b #$20 : BNE .halt_floor
        
        STZ $0B30, X
        
        JSL GetRandomInt : AND.b #$03
        
        ; So.... depending on the x coordinate we can either just flip
        ; back and forth between two directions, or move in all directions
        ; like in Mothula's room...
        LDY $0B08, X : BNE .all_direction_movement
        
        AND.b #$01
    
    .all_direction_movement
    
        ; invert floor movement direction?
        ASL A : STA $041A
        
        JSL GetRandomInt : AND.b #$7F : ADC.b #$80 : STA $0B30, X
        
        INC $0B28, X
        
        RTS
    
    .halt_floor
    
        ; disable horizontal and vertical floor from moving
        LDA.b #$01 : STA $041A
        
        RTS
    
    .locked_in_moving_state
    
        DEC $0B30, X : BNE .unlock_moving_state_delay
        
        STZ $0B28, X
    
    .unlock_moving_state_delay
    
        RTS
    
    .unused
    
        RTS
    }

; ==============================================================================

    ; $4BD8D-$4BD9C DATA
    pool Overlord_ZolFactory:
    parallel pool Overlord_StalfosFactory:
    {
    
    .x_offsets_low
        db   0,   0, -48,  48
    
    .y_offsets_low
        db -40,  40,   8,   8
    
    .x_offsets_high
        db   0,   0,  -1,   0
    
    .y_offsets_high
        db  -1,   0,   0,   0
    }

; ==============================================================================

    ; \unused(unconfirmed)
    ; \task Investigate this.
    ; \note Somewhat like endless shrimp at Red Lobster, but more affordable.
    
    ; *$4BD9D-$4BDFC JUMP LOCATION
    Overlord_StalfosFactory:
    {
        LDA $0B30, X : BEQ .spawn
        
        LDA $1A : AND.b #$01 : BNE .anodecrement_timer
        
        DEC $0B30, X
    
    .anodecrement_timer
    
        RTS
    
    .spawn
    
        LDA.b #$30
        
        INC $0B28, X : LDY $0B28, X : CPY.b #$04 : BNE .anoreset_spawn_count
        
        STZ $0B28, X
        
        LDA.b #$D0
    
    .anoreset_spawn_count
    
        STA $0B30, X
        
        LDA.b #$85
        LDY.b #$0C
        
        ; \wtf Why not just return in this routine? It's not like it's
        ; too far away.
        JSL Sprite_SpawnDynamically.arbitrary : BMI Overlord_PlayDropSfx.return
        
        PHX
        
        LDA $2F : LSR A : TAX
        
        LDA $22 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $23 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $20 : ADD .y_offsets_low,  X : STA $0D00, Y
        LDA $21 : ADC .y_offsets_high, X : STA $0D20, Y
        
        PLX
        
        LDA.b #$90 : STA $0F70, Y
        
        LDA $EE : STA $0F20, Y
        
        RTS
    }

; ==============================================================================

    ; *$4BDFD-$4BE06 LOCAL
    Overlord_PlayDropSfx:
    {
        PHX : TYX
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        PLX
    
    ; $4BE06 ALTERNATE ENTRY POINT
    .return
    
        RTS
    }

; ==============================================================================

    ; $4BE07-$4BE0E DATA
    pool Overlord_StalfosTrap:
    {
    
    .spawn_delays
        db $FF, $E0, $C0, $A0, $80, $60, $40, $20
    }

; ==============================================================================

    ; *$4BE0F-$4BE6C JUMP LOCATION
    Overlord_StalfosTrap:
    {
        LDA $0B08, X : CMP $E2
        LDA $0B10, X : SBC $E3 : BNE .out_of_range
        
        LDA $0B18, X : CMP $E8
        LDA $0B20, X : SBC $E9 : BNE .out_of_range
        
        LDA $0B28, X : BNE .spawning_active
        
        LDA $0B9E : BEQ .not_triggered
        
        INC $0B28, X
    
    .out_of_range
    .not_triggered
    
        RTS
    
    .spawning_active
    
        INC $0B28, X
        
        CMP .spawn_delays, X : BNE .delay_spawn
        
        STZ $0B00, X
        
        ; Try to spawn a yellow stalfos (the ones that chuck their head at
        ; you.)
        LDA.b #$85
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        LDA $05 : STA $0D10, Y
        LDA $06 : STA $0D30, Y
        
        LDA $07 : STA $0D00, Y
        LDA $08 : STA $0D20, Y
        
        LDA.b #$E0 : STA $0F70, Y
        
        LDA $0B40, X : STA $0F20, Y
        
        JSR Overlord_PlayDropSfx
    
    .delay_spawn
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $4BE6D-$4BE74 DATA
    pool Overlord_SnakeTrap:
    {
    
    .spawn_delays
        db $20, $30, $40, $50, $60, $70, $80, $90
    }

; ==============================================================================

    ; *$4BE75-$4BED8 JUMP LOCATION
    Overlord_SnakeTrap:
    shared Overlord_BombTrap:
    {
        LDA $0B28, X : BNE .been_activated
        
        LDA $0CF4 : BEQ .inactive
        
        INC $0B28, X
    
    .inactive
    
        RTS
    
    .been_activated
    
        INC $0B28, X
        
        ; The amount of time it takes to spawn the trap sprite varies depending
        ; on which slot the overlord is in. This is done to create a staggered
        ; feel when the trap trigger springs.
        CMP .spawn_delays, X : BNE .delay
        
        ; Spawn a snake
        LDA.b #$6E : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $05 : STA $0D10, Y
        LDA $06 : STA $0D30, Y
        
        LDA $07 : STA $0D00, Y
        LDA $08 : STA $0D20, Y
        
        LDA.b #$C0 : STA $0F70, Y
                     STA $0E90, Y
        
        LDA $0E60, Y : ORA.b #$10 : STA $0E60, Y
        
        LDA $0B40, X : STA $0F20, Y
        
        JSR Overlord_PlayFallingFromAboveSfx
        
        LDA $0B00, X : STZ $0B00, X : CMP.b #$1A : BNE .not_bomb_trap
        
        LDA.b #$4A : STA $0E20, Y
        
        JSL Sprite_TransmuteToEnemyBomb
        
        LDA.b #$70 : STA $0E00, Y
    
    .delay
    .spawn_failed
    .not_bomb_trap
    
        RTS
    }

; ==============================================================================

    ; $4BED9-$4BF08 DATA
    pool Overlord_AllDirectionMetalBallFactory:
    {
    
    .coord_indices
        db 2, 2, 2, 2, 1, 1, 1, 1
        db 3, 3, 3, 3, 0, 0, 0, 0
    
    .x_coords
        db $40, $60, $90, $B0, $F0, $F0, $F0, $F0
        db $B0, $90, $60, $40, $00, $00, $00, $00
    
    .y_coords
        db $10, $10, $10, $10, $40, $60, $A0, $C0
        db $F0, $F0, $F0, $F0, $C0, $A0, $60, $40
    }

; ==============================================================================

    ; *$4BF09-$4BF5A JUMP LOCATION
    Overlord_AllDirectionMetalBallFactory:
    {
        LDA $0B08, X : CMP $E2
        LDA $0B10, X : SBC $E3 : BNE .out_of_range
        
        LDA $0B18, X : CMP $E8
        LDA $0B20, X : SBC $E9 : BNE .out_of_range
        
        LDA $1A : AND.b #$0F : BNE .delay
        
        STZ $0E
        
        STZ $0FB6
        
        JSL GetRandomInt : AND.b #$0F : TAY
        
        LDA .coord_indices, Y : STA $0FB5
        
        ; \hardcoded The quadrant of the room where the balls generate.
        LDA .x_coords, Y             : STA $0B08, X
        LDA.b #$00       : ADD $0FB0 : STA $0B10, X
        
        LDA .y_coords, Y             : STA $0B18, X
        LDA.b #$01       : ADD $0FB1 : STA $0B20, X
        
        JSR Overlord_SpawnMetalBall
    
    .out_of_range
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$4BF5B-$4BFAE JUMP LOCATION
    Overlord_CascadeMetalBallFactory:
    {
        LDA $0B08, X : CMP $E2
        LDA $0B10, X : SBC $E3 : BNE .out_of_range
        
        LDA $1A : AND.b #$01 : BNE .delay
        
        LDA $0B30, X : BEQ .delay_timer_expired
        
        DEC $0B30, X
    
    .delay
    .delay_timer_expired
    
        ; Balls generated by this overlord always head downard
        ; (hence 'cascade').
        LDA.b #$02 : STA $0FB5
        
        ; By default generate a small ball.
        STZ $0FB6
        
        DEC $0B28, X : BPL .dont_spawn_anything
        
        LDA.b #$38 : STA $0B28, X
        
        LDA $0B30, X : BNE .spawn_small_ball
        
        ; Spawn a large ball instead and reset the timer that will dictate
        ; when next large ball can appear again.
        LDA.b #$A0 : STA $0B30, X
                     STA $0FB6
        
        LDA.b #$08 : STA $0E
        
        BRA .spawn_ball
    
    .spawn_small_ball
    
        JSL GetRandomInt : AND.b #$02 : ASL #3 : STA $0E
    
    .spawn_ball
    
        JSR Overlord_SpawnMetalBall
    
    .dont_spawn_anything
    
        RTS
    
    .out_of_range
    
        LDA.b #$FF : STA $0B30, X
        
        RTS
    }

; ==============================================================================

    ; *$4BFAF-$4C015 LOCAL
    Overlord_SpawnMetalBall:
    {
        ; Metal Balls (in Eastern Palace)
        LDA.b #$50 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        LDA $05 : ADD $0E    : STA $0D10, Y
        LDA $06 : ADC.b #$00 : STA $0D30, Y
        
        LDA $07 : SUB.b #$01 : STA $0D00, Y
        LDA $08 : SBC.b #$00 : STA $0D20, Y
        
        LDX $0FB5
        
        LDA .x_speeds, X : STA $0D50, Y
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA $0B40, X : STA $0F20, Y
        
        LDA $0FB6 : BEQ .spawn_small_ball
        
        STA $0D80, Y
        
        LDA $0D00, Y : ADD.b #$08 : STA $0D00, Y
        
        LDA.b #$03 : STA $0E40, Y
        LDA.b #$09 : STA $0F60, Y
    
    .spawn_small_ball
    
        LDA.b #$40 : STA $0E10, Y
        
        PHX : TYX
        
        LDA.b #$07 : JSL Sound_SetSfx3PanLong
        
        PLX
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $4C016-$4C01D DATA
    pool Overlord_SpawnMetalBall:
    {
    
    .x_speeds
        db  24, -24,   0,   0
    
    .y_speeds
        db   0,   0,  24, -24
    }

; ==============================================================================

    ; *$4C01E-$4C022 JUMP LOCATION
    Overlord_SpritePositionTarget:
    {
        TXA : STA $0FDE
        
        RTS
    }

; ==============================================================================
