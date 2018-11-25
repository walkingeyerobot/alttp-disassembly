
; ==============================================================================

    ; $28000-$28007 DATA
    pool Sprite_SpawnSparkleGarnish:
    {
    
    .low_offset
        db $FC, $00, $04, $08
    
    .high_offset
        db $FF, $00, $00, $00
    }

; ==============================================================================

    ; *$28008-$2807E LONG
    Sprite_SpawnSparkleGarnish:
    {
        ; Check if the frame counter is a multiple of 4
        LDA $1A : AND.b #$03 : BNE .skip_frame
        
        PHX
        
        TXY
        
        JSL GetRandomInt : AND.b #$03 : TAX
        
        LDA.l .low_offset, X  : STA $00
        LDA.l .high_offset, X : STA $01
        
        JSL GetRandomInt : AND.b #$03 : TAX
        
        LDA.l .low_offset, X  : STA $02
        LDA.l .high_offset, X : STA $03
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        ; Even if we don't find an empty slot, we're still going to use slot 0
        ; anyway.
        INX
    
    .empty_slot
    
        ; sprite falling into a hole animation?
        ; (update: more likely to be setting up a sparkle animation, as this
        ; has so far only been linked to good bees and something that also seems
        ; to be a good bee).
        LDA.b #$12 : STA $7FF800, X
                     STA $0FB4
        
        LDA $0D10, Y : ADD $00 : STA $7FF83C, X
        LDA $0D30, Y : ADC $01 : STA $7FF878, X
        
        LDA $0D00, Y : ADD $02 : STA $7FF81E, X
        LDA $0D20, Y : ADC $03 : STA $7FF85A, X
        
        ; Set the associated sprite index for the garnish sprite?
        TYA : STA $7FF92C, X
        
        LDA.b #$0F : STA $7FF90E, X
        
        TXY
        
        PLX
    
    .skip_frame
    
        RTL
    }

; ==============================================================================

    ; *$2807F-$28083 JUMP LOCATION
    Sprite_HelmasaurFireballTrampoline:
    {
        JSL Sprite_HelmasaurFireballLong
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_wall_cannon.asm"
    incsrc "sprite_archery_game_guy.asm"
    incsrc "sprite_debirando_pit.asm"
    incsrc "sprite_beamos.asm"
    incsrc "sprite_debirando.asm"
    incsrc "sprite_master_sword.asm"
    incsrc "sprite_spike_roller.asm"
    incsrc "sprite_spark.asm"
    incsrc "sprite_lost_woods_bird.asm"
    incsrc "sprite_lost_woods_squirrel.asm"
    incsrc "sprite_crab.asm"
    incsrc "sprite_desert_barrier.asm"
    incsrc "sprite_zora_and_fireball.asm"
    incsrc "sprite_zora_king.asm"
    incsrc "sprite_walking_zora.asm"
    incsrc "sprite_armos_knight.asm"
    incsrc "sprite_lanmola.asm"
    incsrc "sprite_rat.asm"
    incsrc "sprite_rope.asm"
    incsrc "sprite_cannon_trooper.asm"
    incsrc "sprite_warp_vortex.asm"
    incsrc "sprite_flail_trooper.asm"

; ==============================================================================

    ; *$2B5C3-$2B5CA LONG
    SpriteActive2_MainLong:
    {
        PHB : PHK : PLB
        
        JSR SpriteActive2_Main
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $2B5CB-$2B5D2 DATA
    Soldier_DirectionLockSettings:
    {
    
    .directions
        db $03, $02, $00, $01
    
    .animation_states
        db $08, $00, $0C, $05
    }

; ==============================================================================

    ; *$2B5D3-$2B647 LOCAL
    SpriteActive2_Main:
    {
        ; This routine is meant to handle sprites with IDs 0x41 to 0x70.
        
        LDA $0E20, X : SUB.b #$41 : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        LDA .sprite_routines, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .sprite_routines
    
        ; Sprite routines 3*
        
        ; Please note that the numbers in the comments to the right are the actual sprite numbers
        ; and have nothing to do with the orientation of the table, though they ;are in order.
        
        dw Sprite_Soldier                     ; 0x41 - Green Soldier
        dw Sprite_Soldier                     ; 0x42 - Blue Soldier
        dw Sprite_Soldier                     ; 0x43 - Red Spear Soldier
        dw Sprite_PsychoTrooper               ; 0x44 - Crazy Blue Killer Soldiers
        dw Sprite_PsychoSpearSoldier          ; 0x45 - Crazed Spear Soldiers (Green or Red)
        dw Sprite_ArcherSoldier               ; 0x46 - Blue Archers
        dw Sprite_BushArcherSoldier           ; 0x47 - Green Archers (in bushes)
                                              
        dw Sprite_JavelinTrooper              ; 0x48 - Red Javelin Soldiers (in special armor)
        dw Sprite_BushJavelinSoldier          ; 0x49 - Red Javelin Soldiers (in bushes)
        dw Sprite_BombTrooper                 ; 0x4A - Bomb Trooper / Enemy Bombs
        dw Sprite_Recruit                     ; 0x4B - Recruit
        dw Sprite_GerudoMan                   ; 0x4C - Gerudo Man
        dw Sprite_Toppo                       ; 0x4D - Asshole bunnies (Toppo)
        dw Sprite_Popo                        ; 0x4E - Snakebasket (Popo?)
        dw Sprite_Bot                         ; 0x4F - Bot / Bit?
        
        dw Sprite_MetalBall                   ; 0x50 - Metal Balls in Eastern Palace
        dw Sprite_Armos                       ; 0x51 - Armos
        dw Sprite_ZoraKing                    ; 0x52 - Giant Zora
        dw Sprite_ArmosKnight                 ; 0x53 - Armos Knight Code
        dw Sprite_Lanmola                     ; 0x54 - Lanmola
        dw Sprite_ZoraAndFireball             ; 0x55 - Zora (or Agahnim) fireball code.
        dw Sprite_WalkingZora                 ; 0x56 - Walking Zora
        dw Sprite_DesertBarrier               ; 0x57 - Desert Palace Barrier
        
        dw Sprite_Crab                        ; 0x58 - Crab
        dw Sprite_LostWoodsBird               ; 0x59 - Birds (master sword grove)
        dw Sprite_LostWoodsSquirrel           ; 0x5A - Squirrel (master sword grove?)
        dw Sprite_Spark                       ; 0x5B - Spark (clockwise on convex, counterclockwise on concave)
        dw Sprite_Spark                       ; 0x5C - Spark (counterclockwise on convex, clockwise on concave)
        dw Sprite_SpikeRoller                 ; 0x5D - Roller (????)
        dw Sprite_SpikeRoller                 ; 0x5E - Roller (????)
        dw Sprite_SpikeRoller                 ; 0x5F - Roller (????)
        
        dw Sprite_SpikeRoller                 ; 0x60 - Roller (????)
        dw Sprite_Beamos                      ; 0x61 - Beamos (aka Statue Sentry)
        dw Sprite_MasterSword                 ; 0x62 - Master Sword (in the grove)
        dw Sprite_DebirandoPit                ; 0x63 - Sand lion pit
        dw Sprite_Debirando                   ; 0x64 - Sand lion
        dw Sprite_ArcheryGameGuy              ; 0x65 - Shooting gallery guy
        dw Sprite_WallCannon                  ; 0x66 - Moving cannon ball shooters
        dw Sprite_WallCannon                  ; 0x67 - Moving cannon ball shooters
        
        dw Sprite_WallCannon                  ; 0x68 - Moving cannon ball shooters
        dw Sprite_WallCannon                  ; 0x69 - Moving cannon ball shooters
        dw Sprite_ChainBallTrooper            ; 0x6A - Ball n' Chain Trooper
        dw Sprite_CannonTrooper               ; 0x6B - Cannon Ball Shooting Trooper (unused in game)
        dw Sprite_WarpVortex                  ; 0x6C - Warp Vortex (from Magic mirror in light world)
        dw Sprite_Rat                         ; 0x6D - Rat / Bazu
        dw Sprite_Rope                        ; 0x6E - Rope / Skullrope
        dw Sprite_Keese                       ; 0x6F - Keese
        
        dw Sprite_HelmasaurFireballTrampoline ; 0x70 - Helmasaur King fireballs
    }

; ==============================================================================

    incsrc "sprite_metal_ball.asm"
    incsrc "sprite_armos.asm"
    incsrc "sprite_bot.asm"
    incsrc "sprite_gerudo_man.asm"
    incsrc "sprite_toppo.asm"
    incsrc "sprite_recruit.asm"

; ==============================================================================

    ; *$2C155-$2C226 JUMP LOCATION LOCAL
    Sprite_Soldier:
    {
        LDA $0DB0, X : BNE .is_probe
        
        JMP Soldier_Main
    
    .is_probe
    
    ; \note Label here for informational purposes.
    shared Sprite_Probe:
    
        LDY.b #$00
        
        ; Is the sprite moving right? Yes, so skip the decrement of Y
        LDA $0D50, X : BPL .moving_right
        
        ; Sprite is moving left, so we have to make sure subtraction is done smoothly
        DEY
    
    .moving_right
    
        ; This code moves the soldier left or right, depending on $0D50, X
              ADD $0D10, X : STA $0D10, X
        TYA : ADC $0D30, X : STA $0D30, X
        
        LDY.b #$00
        
        ; Same as above but for Y coordinate of the soldier
        LDA $0D40, X : BPL .moving_down
        
        DEY
    
    .moving_down
    
              ADD $0D00, X : STA $0D00, X
        TYA : ADC $0D00, X : STA $0D20, X
        
        ; Usually 0. Otherwise the soldier’s invisible.
        LDY $0DB0, X
        
        ; Is this soldier (Link locator) belonging to Blind?
        LDA $0E1F, Y : CMP.b #$CE : BNE .parent_not_blind_the_thief
        
        REP #$20
        
        LDA $0FD8 : SUB $22 : ADD.w #$0010
        
        CMP.w #$0020 : SEP #$20 : BCS .player_not_close
        
        REP #$20
        
        LDA $20 : SUB $0FDA : ADD.w #$0018
        
        CMP.w #$0020 : SEP #$20 : BCS .player_not_close
        
        JMP $C1F6 ; $2C1F6 IN ROM
    
    .player_not_close
    
        JMP $C21A       ; $2C21A IN ROM
    
    .parent_not_blind_the_thief
    
        ; Check the tile attr that the sprite is interacting with
        JSL Probe_CheckTileSolidity : BCC .zeta
        
        LDA $0FA5 : CMP.b #$09 : BNE .theta
    
    .zeta
    
        ; Is Link invisible and invincible? (magic cape)
        LDA $0055 : BNE .theta
        
        REP #$20
        
        LDA $0FD8 : SUB $22 : CMP.w #$0010 : SEP #$20 : BCS .iota
        
        REP #$20
        
        LDA $0FDA : SUB $20 : CMP.w #$0010 : SEP #$20 : BCS .iota
        
        ; Are Link and the soldier on the same floor?
        LDA $0F20, X : CMP $EE : BNE .iota
    
    ; *$2C1F6 ALTERNATE ENTRY POINT
    
        LDA $0DB0, X : DEC A
        
        PHX
        
        TAX
        
        LDA $0D80, X : CMP.b #$03 : BEQ .kappa
        
        LDA.b #$03 : STA $0D80, X
        
        ; Is the sprite Blind the Thief?
        LDA $0E20, X : CMP.b #$CE : BEQ .kappa ; Yes...
        
        LDA.b #$10 : STA $0DF0, X
        
        STZ $0E80, X
    
    .kappa
    
        PLX
        
        BRA .theta
    
    ; *$2C21A ALTERNATE ENTRY POINT
    .iota
    
        JSR Sprite2_PrepOamCoord
        
        LDA $01 : ORA $03 : BEQ .return
    
    .theta
    
        STZ $0DD0, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$2C227-$2C2CF JUMP LOCATION
    Soldier_Main:
    {
        LDA $0DC0, X : PHA
        
        LDY $0DE0, X : PHY
        
        ; This is actually used.
        LDA $0E00, X : BEQ .direction_lock_inactive
        
        LDA Soldier_DirectionLockSettings.directions, Y : STA $0DE0, X
        
        LDA Soldier_DirectionLockSettings.animation_states, Y : STA $0DC0, X
    
    .direction_lock_inactive
    
        ; Looks like a "draw soldier" function...
        JSR $C680 ; $2C680 IN ROM
        
        PLA : STA $0DE0, X
        PLA : STA $0DC0, X
        
        LDA $0DD0, X : CMP.b #$05 : BNE .not_falling_in_hole
        
        LDA $11 : BNE Sprite_Soldier.return
        
        ; ticking animation clock and state...
        JSR $C535 ; $2C535 IN ROM
        JMP $C535 ; $2C535 IN ROM
    
    .not_falling_in_hole
    
        JSR Sprite2_CheckIfActive
        JSL $06EB5E ; $36B5E IN ROM ; push sprite back from sword hit?
        
        JSL Sprite_CheckDamageToPlayerLong : BCS .gamma
        
        LDA $0FDC : BEQ .delta
    
    .gamma
    
        LDA $0D80, X : CMP.b #$03 : BCS .delta
        
        LDA.b #$03 : STA $0D80, X
        
        LDA.b #$20
        
        BRA .epsilon
    
    .delta
    
        LDA $0EA0, X : BEQ .zeta
        
        CMP.b #$04 : BCC .zeta
        
        LDA.b #$04 : STA $0D80, X
        
        LDA.b #$80
    
    .epsilon
    
        JSR $C4D7 ; $2C4D7 IN ROM
    
    .zeta
    
        JSR Sprite2_CheckIfRecoiling
        
        LDA $0E30, X : AND.b #$07 : CMP.b #$05 : BCS .theta
        
        LDA $0E70, X : BNE .iota
        
        JSR $F9EB ; $2F9EB IN ROM
    
    .iota
    
        JSR Sprite2_CheckTileCollision
        
        BRA .kappa
    
    .theta
    
        JSR Sprite2_Move
    
    .kappa
    
        LDA $0D80, X : CMP.b #$04 : BEQ .nu
        
        STZ $0ED0, X
    
    .nu
    
        REP #$30 : AND.w #$00FF : ASL A : TAY
        
        ; Hidden table! gah!!!
        LDA .states, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .states
    
        dw $C2D4 ; = $2C2D4*
        dw $C403 ; = $2C403*
        dw $C490 ; = $2C490*
        dw $C4C1 ; = $2C4C1*
        dw $C4E8 ; = $2C4E8*
    }

; ==============================================================================

    ; $2C2D0-$2C2D3 DATA
    {
        db $60, $C0, $FF, $40
    }

; ==============================================================================

    ; $2C2D4-$2C330 JUMP LOCATION
    {
        JSR Sprite2_ZeroVelocity
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA $0E30, X : BEQ .beta
        
        AND.b #$07 : CMP.b #$05 : BCS .beta
        
        LDA $0E30, X : LSR #3 : AND.b #$03 : TAY
        
        LDA $C2D0, Y : STA $0DF0, X
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        STZ $0E80, X
        
        BRA .gamma
    
    .beta
    
        JSL GetRandomInt : AND.b #$3F : ADC.b #$28 : STA $0DF0, X
        
        LDA $0DE0, X : PHA
        
        JSL GetRandomInt : AND.b #$03 : STA $0DE0, X
        
        PLA : CMP $0DE0, X : BEQ .alpha
        
        EOR $0DE0, X : AND.b #$02 : BNE .alpha
    
    ; *$2C32B ALTERNATE ENTRY POINT
    shared Soldier_EnableDirectionLock:
    
    .gamma
    
        LDA.b #$0C : STA $0E00, X
    
    .alpha
    .delay
    
        RTS
    }

    ; $2C331-$2C3A0 DATA
    pool Probe:
    parallel pool Soldier:
    {
    
    .x_speeds
        db $08, $F8, $00, $00
    
    .y_speeds
        db $00, $00, $08, $F8
    
    ; $2C339
    .animation_states
        db $0B, $0C, $0D, $0C, $04, $05, $06, $05
        db $00, $01, $02, $03, $07, $08, $09, $0A
        db $11, $12, $11, $12, $07, $08, $07, $08
        db $03, $04, $03, $04, $0D, $0E, $0D, $0E
    
    ; $2C359
    .x_checked_directions
        db  1,  1, -1, -1
        db -1, -1,  1,  1
    
    ; $2C361
    .y_checked_directions
        db -1,  1,  1, -1
        db -1,  1,  1, -1
        
    ; $2C369
    .chase_x_speeds
        db $08, $00, $F8, $00
        db $F8, $00, $08, $00
    
    .chase_y_speeds
        db $00, $08, $00, $F8
        db $00, $08, $00, $F8
    
    ; $2C379
        db  0,  2,  1,  3
        db  1,  2,  0,  3
    
    .collinear_directions
        db $01, $04, $02, $08
        db $02, $04, $01, $08
    
    ; $2C389
    .orthogonal_directions
        db $08, $01, $04, $02
        db $08, $02, $04, $01
    
    .collinear_next_direction
        db  1,  2,  3,  0
        db  5,  6,  7,  4
    
    ; $2C399
    .orthogonal_next_direction
        db  3,  0,  1,  2
        db  7,  4,  5,  6
    }

    ; *$2C3A1-$2C402 JUMP LOCATION
    {
        LDY $0DA0, X
        
        LDA $C359, Y : STA $0D50, X
        
        LDA $C361, Y : STA $0D40, X
        
        JSR Sprite2_CheckTileCollision
        
        LDA $0E10, X : BEQ .alpha
        CMP.b #$2C   : BNE .beta
        
        LDY $0DA0, X
        
        LDA $C399, Y : STA $0DA0, X
        
        BRA .beta
    
    .alpha
    
        LDY $0DA0, X
        
        LDA $0E70, Y : AND $C389, Y : BNE .beta
        
        LDA.b #$58 : STA $0E10, X
    
    .beta
    
        LDY $0DA0, X
        
        LDA $0E70, Y : AND $C381, Y : BEQ .gamma
        
        LDA $C391, Y : STA $0DA0, X
    
    .gamma
    
        LDY $0DA0, X
        
        LDA Soldier.chase_x_speeds, Y : STA $0D50, X
        
        LDA Soldier.chase_y_speeds, Y : STA $0D40, X
        
        LDA $C379, Y : STA $0DE0, X : STA $0EB0, X
        
        JMP $C454 ; $2C454 IN ROM
    }

    ; *$2C403-$2C46F JUMP LOCATION
    {
        JSR Sprite_SpawnProbeStaggered
        
        LDA $0E30, X : AND.b #$07 : CMP.b #$05 : BCC .alpha
        
        JMP $C3A1 ; $2C3A1 IN ROM
    
    .alpha
    
        LDA $0DF0, X : BNE .beta
    
    ; *$2C417 ALTERNATE ENTRY POINT
    
        JSR Sprite2_ZeroVelocity
        
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$A0 : STA $0DF0, X
        
        RTS

    .beta

        LDA $0E80, X : AND.b #$01 : BNE .gamma
        
        INC $0DF0, X

    .gamma

        LDA $0E70, X : AND.b #$0F : BEQ .delta
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        JSR Soldier_EnableDirectionLock

    .delta

        LDY $0DE0, X
        
        LDA Soldier.x_speeds, Y : STA $0D50, X
        
        LDA Soldier.y_speeds, Y : STA $0D40, X
        
        TYA : STA $0EB0, X
        
        INC $0E80, X

    ; *$2C454-$2C46F ALTERNATE ENTRY POINT

        INC $0E80, X
        
        LDA $0E80, X : LSR #3 : AND.b #$03 : STA $00
        
        LDA $0DE0, X : ASL #2 : ADC $00 : TAY
        
        LDA Soldier.animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2C470-$2C48F DATA
    pool Soldier:
    {
    
    .head_looking_states
        db $00, $02, $02, $02, $00, $03, $03, $03
        db $01, $03, $03, $03, $01, $02, $02, $02
        db $02, $00, $00, $00, $02, $01, $01, $01
        db $03, $01, $01, $01, $03, $00, $00, $00
    }

; ==============================================================================

    ; $2C490-$2C4C0 JUMP LOCATION
    {
        JSR Sprite2_ZeroVelocity
        JSR Sprite_SpawnProbeStaggered
        
        LDA $0DF0, X : BNE .alpha
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA.b #$00 : STA $0D80, X
        
        RTS
    
    .alpha
    
        CMP.b #$80 : BCS .beta
        
        LSR #3 : AND.b #$07 : STA $00
        
        LDA $0DE0, X : ASL #3 : ORA $00 : TAY
        
        LDA Soldier.head_looking_states, Y : STA $0EB0, X
    
    .beta	
    
        RTS
    }

    ; *$2C4C1-$2C4E7 JUMP LOCATION
    {
        ; Green soldier submode 3
        
        JSR Sprite2_ZeroVelocity
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0EB0, X
        
        LDA $0DF0, X : BNE .alpha
        
        LDA.b #$04 : STA $0D80, X
        
        LDA.b #$FF
    
    ; *$2C4D7 ALTERNATE ENTRY POINT
    
        STA $0DF0, X
        
        STZ $0E30, X
        
        LDA $0B6B, X : AND.b #$0F : ORA.b #$60 : STA $0B6B, X
    
    .alpha
    
        RTS
    }

    ; $2C4E8-$2C4F8 JUMP LOCATION
    {
        LDA $0DF0, X : BNE BRANCH_$2C500
        
        LDY $0DE0, X
        
        LDA JavelinTrooper_Attack.scan_anbles, X : STA $0EC0, X
        
        BRL BRANCH_2C417
    }

; ==============================================================================

    ; *$2C4F9-$2C4FF LOCAL
    Sprite2_ZeroVelocity:
    {
        ; Stop horizontal and vertical velocities
        STZ $0D50, X
        STZ $0D40, X
        
        RTS
    }

; ==============================================================================

    ; $2C500-$2C53B LOCAL
    {
        TYA : EOR $1A : AND.b #$1F : BNE .alpha
        
        LDA $0ED0, X : BNE .beta
        
        LDA.b #$04 : JSL Sound_SetSfx3PanLong
        
        INC $0ED0, X
    
    .beta
    
        TXA : AND.b #$03 : TAY
        
        LDA $0E20, X : CMP.b #$42 : BEQ .gamma
    
    .gamma
    
        LDA $C566, X : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0DE0, X : STA $0EB0, X
    
    .alpha
    
        JSL Probe_SetDirectionTowardsPlayer
        
    ; *$2C535 ALTERNATE ENTRY POINT
    
        INC $0E80, X
        
        JSR $C454 ; $2C454 IN ROM
        
        RTS
    }

; ==============================================================================

    ; $2C53C-$2C541 DATA
    pool Probe_SetDirectionTowardsPlayer:
    parallel pool Sprite_PsychoSpearSoldier:
    parallel pool Sprite_PsychoTrooper:
    {
    
    .x_speeds length 4
        db $0E, $F2
    
    .y_speeds
        db $00, $00, $0E, $F2
    }

; ==============================================================================

    ; $2C542-$2C565 LONG
    Probe_SetDirectionTowardsPlayer:
    {
        PHB : PHK : PLB
        
        LDA $0E70, X : BEQ .no_tile_collision
        AND.b #$03   : BEQ .no_horiz_collision
        
        JSR Sprite2_IsBelowPlayer : INY #2 : BRA .moving_on
    
    .no_horiz_collision
    
        JSR Sprite2_IsToRightOfPlayer
    
    .moving_on
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
    
    .no_tile_collision
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $2C566-$2C5F1 DATA
    {
        db $10, $10, $10, $10
        
    ; $2C56A
        db $12, $12, $12, $12
    
    ; $2C56E
        db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
        db $F0, $F2, $F4, $F6, $F8, $FA, $FC, $FE
        
        db $00, $02, $04, $06, $08, $0A, $0C, $0E
        db $10, $10, $10, $10, $10, $10, $10, $10
        
        db $10, $10, $10, $10, $10, $10, $10, $10
        db $0E, $0C, $0A, $08, $06, $04, $02, $00
        
        db $FE, $FC, $FA, $F8, $F6, $F4, $F2, $F0
        db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    
    ; $2C5AE
        db $00, $02, $04, $06, $08, $0A, $0C, $0E
        db $10, $10, $10, $10, $10, $10, $10, $10
        
        db $10, $10, $10, $10, $10, $10, $10, $10
        db $0E, $0C, $0A, $08, $06, $04, $02, $00
        
        db $FE, $FC, $FA, $F8, $F6, $F4, $F2, $F0
        db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
        
        db $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
        db $F2, $F4, $F6, $F8, $FA, $FC, $FE, $00
    
    ; $2C5EE
        db $10, $30, $00, $20
    }

; ==============================================================================

    ; *$2C5F2-$2C66D LOCAL
    Sprite_SpawnProbeStaggered:
    {
        ; Soldiers and Archers seem to be the only two types that call this.
        ; Beamos and Blind call the alternate entry point...
        
        ; Is there some point to this store that I'm not seeing? It's
        ; overwritten later before even being used.
        TXA : ADD $1A : STA $0F
        
        AND.b #$03 : ORA $0F00, X : BNE .spawn_failed
        
        LDA $0EC0, X : INC $0EC0, X
        
        LDY $0DE0, X
        
        CLC : AND.b #$1F : ADC $C5EE, Y : AND.b #$3F : STA $0F
    
    ; *$2C612 ALTERNATIVE ENTRY POINT
    shared Sprite_SpawnProbeAlways:
    
        LDA.b #$41  ; If any of our sprites are dead, change it to a soldier
        LDY.b #$0A  ; We’ll be checking sprites in slots 0x00 through 0x0A
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        LDA $00 : ADD.b #$08 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$04 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        PHX
        
        ; The direction the statue sentry eye is facing determines the direction
        ; that the feeler will travel in.
        LDX $0F
        
        TXA : STA $0DE0, Y
        
        LDA $C56E, X : STA $0D50, Y
        
        LDA $C5AE, X : STA $0D40, Y
        
        LDA $0E40, Y : AND.b #$F0 : ORA.b #$A0 : STA $0E40, Y
        
        PLX
        
        TXA : INC A : STA $0DB0, Y
                      STA $0BA0, Y
        
        LDA.b #$40 : STA $0F60, Y
                     STA $0E60, Y
        
        LDA.b #$02 : STA $0CAA, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$2C66E-$2C675 LONG
    Sprite_SpawnProbeAlwaysLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_SpawnProbeAlways
        
        PLB
        
        RTL
    } 

; ==============================================================================

    ; *$2C676-$2C67F LONG
    Soldier_AnimateMarionetteTempLong:
    {
        PHB : PHK : PLB
        
        PHX
        
        JSR $C680 ; $2C680 IN ROM
        
        PLX
        
        PLB
        
        RTL
    }

    ; *$2C680-$2C6A2 LOCAL
    {
        JSR Sprite2_PrepOamCoord
        JSR $C6DE ; $2C6DE IN ROM
        JSR $CA09 ; $2CA09 IN ROM
        JSR $CB64 ; $2CB64 IN ROM
    
    ; *$2C68C ALTERNATE ENTRY POINT
    
        LDA $0E60, X : AND.b #$10 : BEQ .alpha
        
        LDY $0DE0, X
        
        LDA .shadow_types, Y
        
        JSL Sprite_DrawShadowLong.variable
    
    .alpha
    
        RTS
    
    .shadow_types
        db $0C, $0C, $0A, $0A
    }

    ; *$2C6DE-$2C72C LOCAL
    {
        LDY.b #$00
    
    ; *$2C6E0 ALTERNATE ENTRY POINT
    
        PHX
        
        LDA $0DC0, X : ASL A : STA $0D
        
        LDA $0EB0, X : TAX
        
        REP #$20
        
        LDA $00 : STA ($90), Y : AND.w #$0100 : STA $0E
        
        PHY
        
        LDA $02
        
        SEC
        
        LDY $0D
        SBC $C6AA, Y
        
        PLY : INY
        
        STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .alpha
        
        LDA.w #$00F0 : STA ($90), Y
    
    .alpha
    
        SEP #$20
        
        LDA $C6A2, X : INY           : STA ($90), Y
        LDA $C6A6, X : INY : ORA $05 : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLX
        
        RTS
    }

    ; *$2CA09-$2CAB7 LOCAL
    {
        LDY $0DE0, X
        
        LDA $CA05, Y : TAY
    
    ; *$2CA10 ALTERNATE ENTRY POINT
    
        LDA $0DC0, X : ASL #2 : STA $07
        LDA $0E20, X          : STA $08
        
        PHX
        
        LDX.b #$03
    
    ; *$2CA1F ALTERNATE ENTRY POINT
    
        PHX
        
        TXA : ADD $07 : TAX : STX $06
        
        LDA $08 : CMP.b #$46 : BCC .alpha
        
        LDA $C99D, X : BEQ .beta
        
        LDA $C8CD, X
        
        PLX : PHX
        
        CPX.b #$03 : BNE .alpha
        
        CMP.b #$20 : BEQ .beta
    
    .alpha
    
        LDA $06 : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $C72D, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $C7FD, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .gamma
        
        LDA.w #$00F0 : STA ($90), Y
    
    .gamma
    
        SEP #$20
        
        LDA.w #$08 : STA $0D
        
        LDX $06
        
        LDA $C8CD, X : INY : STA ($90), Y : CMP.b #$20 : BNE .delta
        
        LDA.b #$02 : STA $0D
        
        LDA $08 : CMP.b #$46 : CLC : BNE .epsilon
        
        DEY : LDA.b #$F0 : STA ($90), Y : INY
        
        BRA .epsilon
    
    .delta
    
        LDA $C99D, X : CMP.b #$01
    
    .epsilon
    
        LDA $C935, X : ORA $05
        
        BCS .zeta
        
        AND.b #$F1 : ORA $0D
    
    .zeta
    
        INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $C99D, X : ORA $0F : STA ($92), Y
        
        PLY : INY
    
    .beta
    
        PLX : DEX : BMI .theta
        
        JMP $CA1F ; $2CA1F IN ROM
    
    .theta
    
        PLX
        
        RTS
    }

    ; *$2CB64-$2CBDF LOCAL
    {
        LDA $0DC0, X : ASL A : STA $06
        
        LDA $0E20, X : SUB.b #$41 : STA $08
        
        LDY $0DE0, X
        
        LDA $CB60, Y : TAY
        
        PHX
        
        LDX.b #$01
    
    .gamma
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $CAB8, X : ADD $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $CAF0, X : ADD $02 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .alpha
        
        LDA.w #$00F0 : STA ($90), Y
    
    .alpha
    
        SEP #$20
        
        LDA $CAB8, X : STA $0FAB
        LDA $CAF0, X : STA $0FAA
        
        PLX
        
        LDA $08 : CMP.b #$02
        
        LDA $CB28, X : BCS .beta
        
        ADC.b #$03
    
    .beta
    
        INY : STA ($90), Y
        
        LDA $CB44, X : ORA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .gamma
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$2CBE0-$2CC3B JUMP LOCATION
    Sprite_PsychoSpearSoldier:
    {
        JSR $C680   ; $2C680 IN ROM
        JSR Sprite2_CheckIfActive
        JSR PsychoSpearSoldier_PlayChaseMusic
        JSL $06EB5E ; $36B5E IN ROM
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_MoveIfNotTouchingWall
        JSR Sprite2_CheckTileCollision
        JSL Sprite_CheckDamageToPlayerLong
        
        TXA : EOR $1A : AND.b #$0F : BNE .no_direction_change
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0EB0, X : STA $0DE0, X
        
        TXA : AND.b #$03 : TAY
        
        LDA $C56A, Y
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA $0E70, X : BEQ .no_direction_change
        AND.b #$03   : BEQ .horizontal_tile_collision
        
        JSR Sprite2_IsBelowPlayer
        
        INY #2
        
        BRA .gamma
    
    .horizontal_tile_collision
    
        JSR Sprite2_IsToRightOfPlayer
    
    .gamma
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
    
    .no_direction_change
    
        INC $0E80, X
        
        JSR $C454 ; $2C454 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$2CC3C-$2CC64 LOCAL
    PsychoSpearSoldier_PlayChaseMusic:
    {
        LDA $0ED0, X : CMP.b #$10 : BEQ .no_change
        INC $0ED0, X : CMP.b #$0F : BNE .no_change
        
        LDA.b #$04 : JSL Sound_SetSfx3PanLong
        
        LDA $7EF3C5 : CMP.b #$02 : BNE .no_change
        
        LDA $040A : CMP.b #$18 : BNE .no_change
        
        LDA.b #$0C : STA $012C
    
    .alpha
    .no_change
    
        RTS
    }

; ==============================================================================

    ; *$2CC65-$2CCD4 JUMP LOCATION
    Sprite_PsychoTrooper:
    {
        JSR $CCD5   ; $2CCD5 IN ROM
        JSR Sprite2_CheckIfActive
        JSR $CC3C   ; $2CC3C IN ROM
        JSL $06EB5E ; $36B5E IN ROM
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_MoveIfNotTouchingWall
        JSR Sprite2_CheckTileCollision
        JSL Sprite_CheckDamageToPlayerLong
        
        TXA : EOR $1A : AND.v #$0F : BNE .alpha
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0EB0, X : STA $0DE0, X
        
        TXA : AND.b #$03 : TAY
        
        LDA $C56A, Y
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA $0E70, X : BEQ .alpha
        AND.b #$03   : BEQ .beta
        
        JSR Sprite2_IsBelowPlayer
        
        INY #2
        
        BRA .gamma
    
    .beta
    
        JSR Sprite2_IsToRightOfPlayer
    
    .gamma
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
    
    .alpha
    
        LDA $0DE0, X : ASL #3 : STA $00
        
        INC $0E80, X : LDA $0E80, X : LSR A : AND.b #$07 : ORA $00 : TAY
        
        LDA $B0C7, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$2CCD5-$2CCE7 LOCAL
    {
        JSR Sprite2_PrepOamCoord
        
        LDY.b #$0C : JSR $B160 ; $2B160 IN ROM
        
        LDY.b #$08 : JSR $B3CD  ; $2B3CD IN ROM
        
        JSR $CD4F  ; $2CD4F IN ROM
        JMP $C68C ; $2C68C IN ROM
    }

    ; *$2CD48-$2CDD3 LOCAL
    {
        LDY.b #$00
    
    ; *$2CD4A ALTERNATE ENTRY POINT
    
        LDA $0D90, X
        
        BRA .alpha
    
    ; *$2CD4F ALTERNATE ENTRY POINT
    
        LDA $0D90, X
        
        LDY.b #$00
    
    .alpha
    
        EOR.b #$01 : ASL A : AND.b #$02 : STA $06
        
        LDA $0E20, X : STA $08
        
        LDA $0DE0, X : ASL #2 : ORA $06 : STA $06
        
        PHX
        
        LDX.b #$01
    
    .delta
    
        PHX
        
        TXA : ADD $06 : PHA : ASL A : TAX
        
        REP #$20
        
        LDA $CCE8, X : ADD $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $CD08, X : ADD $02 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .beta
        
        LDA.w #$00F0 : STA ($90), Y
    
    .beta
    
        SEP #$20
        
        LDA $CCE8, X : STA $0FAB
        LDA $CD08, X : STA $0FAA
        
        PLX
        
        LDA $08 : CMP.b #$48 : LDA $CD28, X : BCC .gamma
        
        SBC.b #$03
    
    .gamma
    
                                                           INY : STA ($90), Y
        LDA $CD38, X : ORA $05 : AND.b #$F1 : ORA.b #$08 : INY : STA ($90), Y
        
        PLX
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .delta
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$2CDD4-$2CDDC LOCAL
    Sprite2_MoveIfNotTouchingWall:
    {
        LDA $0E70, X : BNE .alpha
        
        JMP Sprite2_Move
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $2CDDD-$2CDE0 DATA
    pool Sprite_JavelinTrooper:
    {
    
    .animation_states
        db $0C, $00, $12, $08
    }

; ==============================================================================

    ; *$2CDE1-$2CE73 JUMP LOCATION
    Sprite_JavelinTrooper:
    {
        LDA $0DC0, X : PHA
        LDY $0DE0, X : PHY
        
        LDA $0E00, X : BEQ .direction_lock_inactive
        
        LDA Soldier_DirectionLockSettings.directions, Y : STA $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
    
    .direction_lock_inactive
    
        JSR JavelinTrooper_Draw
        
        BRA .beta
    
    ; *$2CDFF ALTERNATE ENTRY POINT
    shared Sprite_ArcherSoldier:
    
        LDA $0DC0, X : PHA
        LDY $0DE0, X : PHY
        
        LDA $0E00, X : BEQ .direction_lock_inactive_2
        
        LDA Soldier_DirectionLockSettings.directions, Y : STA $0DE0, X
        
        LDA Soldier_DirectionLockSettings.animation_states, Y : STA $0DC0, X
    
    .direction_lock_inactive_2
    
        JSR ArcherSoldier_Draw
    
    .beta
    
        PLA : STA $0DE0, X
        PLA : STA $0DC0, X
        
        JSR Sprite2_CheckIfActive
        
        JSR Sprite2_CheckDamage : BCS .gamma
        
        LDA $0FDC : BEQ .delta
    
    .gamma
    
        LDA $0D80, X : CMP.b #$03 : BCS .delta
        
        LDA.b #$03 : STA $0D80, X
        LDA.b #$20 : STA $0DF0, X
    
    .delta
    
        LDA $0EA0, X : BEQ .not_recoiling
        CMP.b #$04   : BCC .not_recoiling ; questionable label name
        
        JSR JavelinTrooper_NoticedPlayer.no_delay
    
    .not_recoiling
    
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_MoveIfNotTouchingWall
        JSR Sprite2_CheckTileCollision
        
        LDA $0D80, X : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        ; Hidden table! gah!!!
        LDA .states, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .states
    
        dw JavelinTrooper_Resting
        dw JavelinTrooper_WalkingAround
        dw JavelinTrooper_LookingAround
        dw JavelinTrooper_NoticedPlayer
        dw JavelinTrooper_Agitated
        dw JavelinTrooper_Attack
    }

; ==============================================================================

    ; $2CE74-$2CEA9 LOCAL
    JavelinTrooper_Resting:
    {
        JSR Sprite2_ZeroVelocity
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$7F : ADC.b #$50 : STA $0DF0, X
        
        LDA $0DE0, X : PHA
        
        JSL GetRandomInt : AND.b #$03 : STA $0DE0, X
        
        PLA : CMP $0DE0, X : BEQ .no_direction_change
        
        EOR $0DE0, X : AND.b #$02 : BNE .no_direction_lock
        
        LDA.b #$0C : STA $0E00, X
    
    .no_direction_lock
    .no_direction_change
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2CEAA-$2CF12 LOCAL
    JavelinTrooper_WalkingAround:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$A0 : STA $0DF0, X
        
        RTS
    
    .delay
    
        JSR Sprite_SpawnProbeStaggered
        
        LDA $0E70, X : AND.b #$0F : BEQ .no_tile_collision
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        JSR Soldier_EnableDirectionLock
    
    .no_tile_collision
    
        LDY $0DE0, X
        
        LDA Soldier.x_speeds, Y : STA $0D50, X
        
        LDA Soldier.y_speeds, Y : STA $0D40, X
        
        TYA : STA $0EB0, X
    
    ; $2CEE2 ALTERNATE ENTRY POINT
    shared JavelinTrooper_Animate:
    
        INC $0E80, X : LDA $0E80, X : AND.b #$0F : BNE .gamma
        
        INC $0D90, X : LDA $0D90, X : CMP.b #$02 : BNE .gamma
        
        STZ $0D90, X
    
    .gamma
    
        LDA $0DE0, X : ASL #2 : ADC $0D90, X
        
        LDY $0E20, X : CPY.b #$48 : BNE .is_archer
        
        ADD.b #$10
    
    .is_archer
    
        TAY
        
        LDA Soldier.animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2CF13-$2CF43 LOCAL
    JavelinTrooper_LookingAround:
    {
        JSR Sprite2_ZeroVelocity
        JSR Sprite_SpawnProbeStaggered
        
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA.b #$00 : STA $0D80, X
        
        RTS
    
    .delay
    
        CMP.b #$80 : BCS .mucho_time_left
        
        LSR #3 : AND.b #$07 : STA $00
        
        LDA $0DE0, X : ASL #3 : ORA $00 : TAY
        
        LDA Soldier.head_looking_states, Y : STA $0EB0, X
    
    .mucho_time_left
    
        RTS
    }

; ==============================================================================

    ; $2CF44-$2CF60 LOCAL
    JavelinTrooper_NoticedPlayer:
    {
        JSR Sprite2_ZeroVelocity
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0EB0, X
        
        LDA $0DF0, X : BNE .delay
    
    ; $2CF53 ALTERNATE ENTRY POINT
    .no_delay
    
        LDA.b #$04 : STA $0D80, X
        
        LDA.b #$3C : STA $0DF0, X
        
        STZ $0E80, X
    
    .delay:
    
        RTS
    }

; ==============================================================================

    ; $2CF61-$2CF84 DATA
    pool JavelinTrooper_Agitated:
    {
    
    .x_offsets_low
        db $B0, $50, $00, $F8
        db $B0, $50, $F8, $08
    
    .x_offsets_high
        db $FF, $00, $00, $FF
        db $FF, $00, $FF, $00
    
    .y_offsets_low
        db $08, $08, $B0, $50
        db $08, $08, $B0, $50
    
    .y_offsets_high
        db $00, $00, $FF, $00
        db $00, $00, $FF, $00
    
    .tile_collision_masks
        db $03, $03, $0C, $0C
    }

; ==============================================================================

    ; $2CF85-$2D000 LOCAL
    JavelinTrooper_Agitated:
    {
        LDY $0DE0, X
        
        LDA $0E70, X : AND .tile_collision_masks, Y : BNE .collided
        
        LDA $0DF0, X : BNE .delay
    
    .collided
    
        INC $0D80, X
        
        LDA.b #$18 : STA $0DF0, X
        
        RTS
    
    .delay
    
        TXA : EOR $1A : AND.b #$07 : BNE .delay_facing_player
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0DE0, X : STA $0EB0, X
        
        LDA $0E20, X : CMP.b #$48 : BNE .is_archer
        
        INY #4
    
    .is_archer
    
        LDA $22 : ADD .x_offsets_low, Y  : STA $04
        LDA $23 : ADC .x_offsets_high, Y : STA $05
        
        LDA $20 : ADD .y_offsets_low, Y  : STA $06
        LDA $21 : ADC .y_offsets_high, Y : STA $07
        
        LDA.b #$18
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        LDA $0E : ADD.b #$06 : CMP.b #$0C : BCS .delay_facing_player
        
        LDA $0F : ADD.b #$06 : CMP.b #$0C : BCC .collided
    
    .delay_facing_player
    
        INC $0E80, X
        
        JSR JavelinTrooper_Animate
        
        RTS
    }

; ==============================================================================

    ; $2D001-$2D044 DATA
    pool JavelinTrooper_Attack:
    {
    
    .animation_states
    
        ; Archer Soldier's states
        db $19, $19, $18, $18, $17, $17, $17, $17
        db $13, $13, $12, $12, $11, $11, $11, $11
        
        db $10, $10, $0F, $0F, $0E, $0E, $0E, $0E
        db $16, $16, $15, $15, $14, $14, $14, $14
        
        ; Javelin trooper's states
        db $14, $14, $12, $12, $12, $10, $10, $10
        db $15, $15, $08, $08, $08, $06, $06, $06
        
        db $16, $16, $04, $04, $04, $03, $03, $03
        db $17, $17, $0F, $0F, $0F, $0B, $0B, $0B
    
    .scan_angles
    
        ; Not totally sold on this name (I came up with it).
        db $0D, $0D, $0C, $0C
    }

; ==============================================================================

    ; $2D045-$2D08A LOCAL
    JavelinTrooper_Attack:
    {
        LDY $0DE0, X
        
        LDA .scan_angles, Y : STA $0EC0, X
        
        JSR Sprite2_ZeroVelocity
        
        LDA $0DF0, X : BNE .delay
        
        JMP $C417 ; $2C417 IN ROM
    
    .delay
    
        STZ $0E80, X
        
        CMP.b #$28 : BCC .beta
        
        DEC $0E80, X
    
    .beta
    
        CMP.b #$0C : BNE .gamma
        
        PHA
        
        JSR JavelinTrooper_SpawnProjectile
        
        PLA
    
    .gamma
    
        LSR #3 : STA $00
        
        LDA $0DE0, X : ASL #3 : ORA $00
        
        LDY $0E20, X : CPY.b #$48 : BNE .is_archer
        
        ADD.b #$20
    
    .is_archer
    
        TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2D08B-$2D0C4 DATA
    pool JavelinTrooper_SpawnProjectile
    {
    
    .x_offsets_low
        db $10, $F8, $03, $0B
        db $0C, $FC, $0C, $FC
    
    .x_offsets_high
        db $00, $FF, $00, $00
        db $00, $FF, $00, $FF
    
    .y_offsets_low
        db $02, $02, $10, $F8
        db $FE, $FE, $02, $F8
    
    .y_offsets_high
        db $00, $00, $00, $FF
        db $FF, $FF, $00, $FF
    
    ; $2D0AB
    .x_speeds length 8
        db $30, $D0, $00, $00
        db $20, $E0
    
    ; $2D0B1
    .y_speeds
        db $00, $00, $30, $D0
        db $00, $00, $20, $E0
    
    .unknown
        ; While it is 'unknown', it seems like these were probably
        ; meant to be the direction of the arrow / javelin sprites?
        db $03, $02, $01, $00
        db $03, $02, $01, $00
    
    ; $2D0C1
    .hit_boxes
        db $05, $05, $06, $06
    }

; ==============================================================================

    ; $2D0C5-$2D140 LOCAL
    JavelinTrooper_SpawnProjectile:
    {
        LDA.b #$1B : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$05 : JSL Sound_SetSfx3PanLong
        
        PHX
        
        LDA $0E20, X : CMP.b #$48 : LDA $0DE0, X : BCC .is_archer
        
        ADD.b #$04
    
    .is_archer
    
        TAX
        
        LDA $00 : ADD .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X  : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        TXA : AND.b #$03 : STA $0DE0, Y : TAX
        
        LDA .hit_boxes, X : STA $0F60, Y
        
        LDA.b #$00 : STA $0F70, Y
        
        PLX
        
        LDA $0E20, X : CMP.b #$48 : LDA.b #$00 : BCC .is_archer_2
        
        INC A

    .is_archer_2

        STA $0D90, Y : BEQ .dont_disable_blockability
        
        LDA $7EF35A : BNE .player_has_shield
        
        ; Make the arrow unblockable by shield (which is dumb, because we
        ; alraedy verified that the player doesn't have a shield <___<.)
        LDA $0BE0, Y : AND.b #$DF : STA $0BE0, Y

    .player_has_shield
    .dont_disable_blockability
    .spawn_failed

        RTS
    }

; ==============================================================================

    ; *$2D141-$2D191 LOCAL
    BushJavelinSoldier_Draw:
    {
        LDA $0DC0, X : PHA
        
        STZ $0DC0, X
        
        LDA $0F50, X : PHA : AND.b #$F1 : ORA.b #$02 : STA $0F50, X
        
        REP #$20
        
        LDA $0FDA : PHA : ADD.w #$0008 : STA $0FDA
        
        SEP #$20
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        REP #$20
        
        PLA : STA $0FDA
        
        SEP #$20
        
        PLA : STA $0F50, X
        PLA : STA $0DC0, X
        
        JSR Sprite2_PrepOamCoord
        
        LDY.b #$10
        
        JSR $C6E0 ; $2C6E0 IN ROM
        
        LDY.b #$0C
        
        JSR $B3CD ; $2B3CD IN ROM
        
        LDA $0DC0, X : CMP.b #$14 : BCS .alpha
        
        LDY.b #$04
        
        JSR $CD4A ; $2CD4A IN ROM

    .alpha

        JMP $C68C ; $2C68C IN ROM
    }

; ==============================================================================

    ; *$2D192-$2D1AB LOCAL
    JavelinTrooper_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDY.b #$0C
        
        JSR $B160 ; $2B160 IN ROM
        
        LDY.b #$08
        
        JSR $B3CD ; $2B3CD IN ROM
        
        LDA $0DC0, X : CMP.b #$14 : BCS .alpha
        
        JSR $CD48 ; $2CD48 IN ROM

    .alpha

        JMP $C68C ; $2C68C IN ROM
    }

; ==============================================================================

    ; *$2D1AC-$2D1F4 JUMP LOCATION
    Sprite_BushJavelinSoldier:
    {
        LDA $0D80, X : BEQ .alpha
        CMP.b #$02   : BNE .beta
        
        JSR BushJavelinSoldier_Draw
        
        BRA .alpha
    
    .beta
    
        JSR $D321 ; $2D321 IN ROM
    
    .alpha
    
        BRA .gamma
    
    ; *$2D1BF ALTERNATE ENTRY POINT
    shared Sprite_BushArcherSoldier:
    
        LDA $0D80, X : BEQ .gamma
        
        LDA $0DC0, X : CMP.b #$0E : BCC .delta
        
        JSR ArcherSoldier_Draw
        
        BRA .gamma
    
    .delta
    
        JSR $D321 ; $2D321 IN ROM
    
    .gamma
    
        JSR Sprite2_CheckIfActive
        
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D80, X
        
        REP #$30
        
        AND.w #$00FF : ASL A : TAY
        
        ; Hidden table! gah!!!
        LDA .states, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .states
    
        dw $D1F5 ; $2D1F5
        dw $D223 ; $2D223
        dw $D277 ; $2D277
        dw $D2CE ; $2D2CE
    }

    ; $2D1F5-$2D202 JUMP LOCATION
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2D203-$2D222 DATA
    {
    
    .animation_states
        db 4, 4, 4, 4, 4, 4, 4, 4
        db 0, 1, 0, 1, 0, 1, 0, 1
        db 0, 1, 0, 1, 0, 1, 0, 1
        db 0, 1, 0, 1, 0, 1, 0, 1
    }

; ==============================================================================

    ; $2D223-$2D251 JUMP LOCATION
    {
        JSL $06F2AA ; $372AA IN ROM
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
        
        JSR $F93F ; $2F93F IN ROM
        
        TYA : STA $0DE0, X : STA $0EB0, X
        
        RTS
    
    .delay
    
        CMP.b #$20 : BNE .alpha
        
        PHA
        
        JSR $D252 ; $2D252 IN ROM
        
        PLA : LSR #2 : TAY
        
        LDA $D203, Y : STA $0DC0, X
        
        RTS
    
    .alpha
    
    }

    ; $2D252-$2D276 LOCAL
    {
        LDA.b #$EC : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$06 : STA $0DD0, Y
        
        LDA.b #$20 : STA $0DF0, Y
        
        LDA $0E40, Y : ADD.b #$03 : STA $0E40, Y
        
        LDA.b #$02 : STA $0DB0, Y
    
    .spawn_failed
    
        RTS
    }

    ; $2D277-$2D2BD JUMP LOCATION
    {
        STZ $0BA0, X
        
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
        
        BRA BRANCH_$2D2CE

    BRANCH_ALPHA

        STZ $0D90, X
        
        CMP.b #$28 : BCS BRANCH_BETA
        
        DEC $0D90, X

    BRANCH_BETA

        CMP.b #$10 : BNE BRANCH_GAMMA
        
        PHA
        
        JSR JavelinTrooper_SpawnProjectile
        
        PLA

    BRANCH_GAMMA

        LSR #3 : STA $00
        
        LDA $0DE0, X : ASL #3 : ORA $00
        
        LDY $0E20, X : CPY.b #$49 : BNE BRANCH_DELTA
        
        ADD.b #$20

    BRANCH_DELTA

        TAY
        
        LDA JavelinTrooper_Attack.animation_states, Y : STA $0DC0, X
        
        RTS
    }

    ; $2D2CE-$2D2E8 JUMP LOCATION
    {
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        STZ $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        RTS
    
    BRANCH_ALPHA
    
        LSR #2 : TAY
        
        LDA $D2BE, Y : STA $0DC0, X
        
        RTS
    }

    ; *$2D321-$2D380 LOCAL
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL A : STA $06
        
        PHX
        
        LDX.b #$01
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $D2E9, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .alpha
        
        LDA.w #$00F0 : STA ($90), Y
    
    .alpha
    
        SEP #$20
        
        PLX
        
        LDA $D305, X : INY : STA ($90), Y
        
        LDA $D313, X : ORA.b #$20 : PLX : BNE .beta
        
        AND.b #$F1 : ORA $05
    
    .beta
    
        INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_subsprite
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $2D381-$2D38B DATA
    pool ArcherSoldier_Draw:
    {
    
    ; \task come up with better names for these
    .oam_indices_0 length 4
        db 0, 0, 0
    
    .oam_indices_1
        db $10, $10, $10, $00
    
    .oam_indices_2
        db $14, $14, $14, $04
    }

; ==============================================================================

    ; *$2D38C-$2D3AF LOCAL
    ArcherSoldier_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDY $0DE0, X
        
        LDA .oam_indices_1, Y : TAY
        
        JSR $C6E0   ; $2C6E0 IN ROM
        
        LDY $0DE0, X
        
        LDA .oam_indices_2, Y : TAY
        
        JSR $CA10   ; $2CA10 IN ROM
        
        LDY $0DE0, X
        
        LDA .oam_indices_0, Y : TAY
        
        JSR $D4D4   ; $2D4D4 IN ROM
        JMP $C68C   ; $2C68C IN ROM
    }

; ==============================================================================

    ; *$2D4D4-$2D53A LOCAL
    {
        LDA $0DC0, X : SUB.b #$0E : BCS .alpha
        
        PHY
        
        LDY $0DE0, X
        
        LDA $D4D0, Y
        
        PLY
    
    .alpha
    
        ASL #2 : STA $06
        
        PHX
        
        LDX.b #$03
    
    .gamma
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $D3B0, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $D410, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .beta
        
        LDA.w #$00F0 : STA ($90), Y
    
    .beta
    
        SEP #$20
        
        PLX
        
        LDA $D470, X              : INY : STA ($90), Y
        LDA $D4A0, X : ORA.b #$20 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .gamma
        
        PLX
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_tutorial_entities.asm"
    incsrc "sprite_pull_switch.asm"
    incsrc "sprite_uncle_and_priest.asm"

; ==============================================================================

    ; *$2DF6C-$2DFE4 LONG
    Sprite_DrawMultiple:
    {
        ; Widely called, seems to do with placing sprite graphics
        ; into OAM
        
        STA $06
        STZ $07
    
    ; *$2DF70 ALTERNATE ENTRY POINT
    .quantity_preset
    
        JSR $DFE9 ; $2DFE9 IN ROM
        
        BRA .moving_on
    
    ; *$2DF75 ALTERNATE ENTRY POINT
    .player_deferred
    
        JSR $DFE5 ; $2DFE5 IN ROM
    
    .moving_on
    
        ; Branch will be taken if the sprite were disabled due to being off
        ; screen or something akin to that.
        BCS .return
        
        PHX
        
        ; Routine is definitely used in drawing maidens. (<-- No shit sherlock,
        ; and lots of other stuff!)
        REP #$30
        
        LDY.w #$0000
        
        LDX $0090
    
    .next_oam_entry
    
        LDA ($08), Y : ADD $00 : STA $0000, X : AND.w #$0100 : STA $0C
        
        INY #2
        
        LDA ($08), Y : ADD $02 : STA $0001, X
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_y
        
        LDA.w #$00F0 : STA $0001, X
    
    .on_screen_y
    
        INY #2
        
        LDA $0CFE : CMP.w #$0001
        
        LDA ($08), Y : EOR $04 : BCC .dont_override_palette
        
        ; Force sprite to use palette 2.
        AND.w #$F1FF : ORA.w #$0400
    
    .dont_override_palette
    
        STA $0002, X
        
        PHX
        
        TXA : SUB.w #$0800 : LSR #2 : TAX
        
        SEP #$20
        
        INY #3
        
        LDA ($08), Y : ORA $0D : STA $0A20, X
        
        PLX
        
        REP #$20
        
        INY
        
        INX #4
        
        DEC $06 : BNE .next_oam_entry
        
        SEP #$30
        
        PLX
    
    .return
    
        RTL
    }

; ==============================================================================

    ; *$2DFE5-$2E00A LOCAL
    {
        ; Has two return values (CLC and SEC)
        
        ; Optinally alter OAM allocation region.
        JSL OAM_AllocateDeferToPlayerLong
    
    ; *$2DFE9 ALTERNATE ENTRY POINT
    
        ; Note: it is possible for this callee to abort the caller (namely, the
        ; routine we are in right now).
        JSR Sprite2_PrepOamCoord
        
        ; Preserves the CLC or SEC status
        PHP
        
        STZ $0CFE
        STZ $0CFF
        
        LDA $0DD0, X : CMP.b #$0A : BNE .notCarriedSprite
        
        LDA $7FFA2C, X
    
    .notCarriedSprite
    
        CMP.b #$0B : BNE .notFrozenSprite
        
        LDA $7FFA3C, X : STA $0CFE
    
    .notFrozenSprite
    
        PLP
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_quarrel_bros.asm"

; ==============================================================================

    ; $2E1A3-$2E1A6 DATA
    pool Sprite_ShowSolicitedMessageIfPlayerFacing:
    {
    
    .facing_direction
        db $04, $06, $00, $02
    }

; ==============================================================================

    ; *$2E1A7-$2E1EF LONG
    Sprite_ShowSolicitedMessageIfPlayerFacing:
    {
        ; Handles text messages
        
        STA $1CF0
        STY $1CF1
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .alpha
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .alpha
        
        LDA $F6 : BPL .alpha
        
        LDA $0F10, X : BNE .alpha
        
        LDA $4D : CMP.b #$02 : BEQ .alpha
        
        JSR Sprite2_DirectionToFacePlayer : PHX : TYX
        
        ; Make sure that the sprite is facing towards the player, otherwise
        ; talking can't happen. (What sprites actually use this???)
        LDA .facing_direction, X : PLX : CMP $2F : BNE .not_facing_each_other
        
        PHY
        
        LDA $1CF0
        LDY $1CF1
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$40 : STA $0F10, X
        
        PLA : EOR.b #$03
        
        SEC
        
        RTL
    
    .not_facing_each_other
    .alpha
    
        LDA $0DE0, X
        
        CLC
        
        RTL
    }

; ==============================================================================

    ; *$2E1F0-$2E218 LONG
    Sprite_ShowMessageFromPlayerContact:
    {
        ; You might be wondering how this differs from the similarly named
        ; "Sprite_ShowMessageIfPlayerTouching", and the answer is there's
        ; really not much difference at all. Feel free to let me know if you
        ; discern any significant difference, other than that this one
        ; reports a direction as a return value in the accumulator.
        
        STA $1CF0
        STY $1CF1
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .dont_show
        
        LDA $4D : CMP.b #$02 : BEQ .dont_show
        
        LDA $1CF0
        LDY $1CF1
        
        JSL Sprite_ShowMessageUnconditional
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03
        
        SEC
        
        RTL
    
    .dont_show
    
        LDA $0DE0, X
        
        CLC
        
        RTL
    }

; ==============================================================================

    ; *$2E219-$2E24C LONG
    Sprite_ShowMessageUnconditional:
    {
        ; Routine is used to display a text message with
        ; an ID that is inputted via A and Y registers.
        ; A = low byte of message ID to use.
        ; Y = high byte of message ID to use.
        
        STA $1CF0
        STY $1CF1
        
        STZ $0223
        STZ $1CD8
        
        LDA.b #$02 : STA $11
        
        LDA $10 : STA $010C
        
        LDA.b #$0E : STA $10
        
        PHX
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Player_HaltDashAttackLong
        
        STZ $4D
        STZ $46
        
        LDA $5D : CMP.b #$02 : BNE .alpha
        
        LDA.b #$00 : STA $5D
    
    .alpha
    
        PLX
        
        RTL
    }

; ==============================================================================

    incsrc "sprite_pull_for_rupees.asm"
    incsrc "sprite_gargoyle_grate.asm"
    incsrc "sprite_young_snitch_lady.asm"
    incsrc "sprite_inn_keeper.asm"
    incsrc "sprite_witch.asm"
    incsrc "sprite_arrow_target.asm"

; ==============================================================================

    ; *$2E657-$2E665 LONG UNUSED
    Sprite2_TrendHorizSpeedToZero:
    {
        ; Appears to be unsued, or orphaned code for now...
        
        LDA $0D50, X : BEQ .at_rest : BPL .positive_velocity
        
        INC A
        
        BRA .moving_on
    
    .positive_velocity
    
        DEC A
    
    .moving_on
    .at_rest
    
        STA $0D50, X
        
        RTL
    }

; ==============================================================================

    ; $2E666-$2E674 LONG UNUSED
    Sprite2_TrendVertSpeedToZero:
    {
        LDA $0D40, X : BEQ .at_rest : BPL .positive_velocity
        
        INC A
        
        BRA .moving_on
    
    .positive_velocity
    
        DEC A
    
    .moving_on
    .at_rest
    
        STA $0D40, X
        
        RTL
    }

; ==============================================================================

    incsrc "sprite_old_snitch_lady.asm"
    incsrc "sprite_running_man.asm"
    incsrc "sprite_bottle_vendor.asm"
    incsrc "sprite_zelda.asm"
    incsrc "sprite_mushroom.asm"
    incsrc "sprite_fake_sword.asm"
    incsrc "sprite_heart_upgrades.asm"
    incsrc "sprite_elder.asm"
    incsrc "sprite_medallion_tablet.asm"
    incsrc "sprite_elder_wife.asm"
    incsrc "sprite_potion_shop.asm"
    
; ==============================================================================

    ; *$2F93F-$2F943 LOCAL
    Sprite2_DirectionToFacePlayer:
    {
        JSL Sprite_DirectionToFacePlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$2F944-$2F948 LOCAL
    Sprite2_IsToRightOfPlayer:
    {
        JSL Sprite_IsToRightOfPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$2F949-$2F94D LOCAL
    Sprite2_IsBelowPlayer:
    {
        JSL Sprite_IsBelowPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$2F94E-$2F96A LOCAL
    Sprite2_CheckIfActive:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .inactive
    
    ; *$2F955 ALTERNATE ENTRY POINT
    .permissive
    
        LDA $0FC1 : BNE .inactive
        
        LDA $11 : BNE .inactive
        
        LDA $0CAA, X : BMI .active
        
        LDA $0F00, X : BEQ .active
    
    .inactive
    
        PLA : PLA
    
    .active
    
        RTS
    }

; ==============================================================================

    ; $2F96B-$2F970 DATA
    pool Sprite2_CheckIfRecoiling:
    {
    
    .frame_counter_masks
        db $03, $01, $00, $00, $0C, $03
    ]

; ==============================================================================

    ; *$2F971-$2F9EC LOCAL
    Sprite2_CheckIfRecoiling:
    {
        LDA $0EA0, X : BEQ .return
        AND.b #$7F   : BEQ .recoil_finished
        
        LDA $0D40, X : PHA
        LDA $0D50, X : PHA
        
        DEC $0EA0, X : BNE .not_halted_yet
        
        LDA $0F40, X : ADD.b #$20 : CMP.b #$40 : BCS .too_fast_so_halt
        
        LDA $0F30, X : ADD.b #$20 : CMP.b #$40 : BCC .slow_enough
    
    .too_fast_so_halt
    
        LDA.b #$90 : STA $0EA0, X
    
    .slow_enough
    .not_halted_yet
    
        LDA $0EA0, X : BMI .halted
        
        LSR #2 : TAY
        
        LDA $1A : AND .frame_counter_masks, Y : BNE .halted
        
        LDA $0F30, X : STA $0D40, X
        LDA $0F40, X : STA $0D50, X
        
        LDA $0CD2, X : BMI .no_wall_collision
        
        JSR Sprite2_CheckTileCollision
        
        AND.b #$0F : BEQ .no_wall_collision
        CMP.b #$04 : BCS .y_axis_wall_collision
        
        STZ $0F40, X
        STZ $0D50, X
        
        BRA .moving_on
    
    .y_axis_wall_collision
    
        STZ $0F30, X
        STZ $0D40, X
    
    .moving_on
    
        BRA .halted
    
    .no_wall_collision
    
        JSR Sprite2_Move
    
    .halted
    
        PLA : STA $0D50, X
        PLA : STA $0D40, X
        
        PLA : PLA
    
    .return
    
        RTS
    
    .recoil_finished
    
        STZ $0EA0, X
        
        RTS
    }

; ==============================================================================

    ; *$2F9ED-$2F9F3 LOCAL
    Sprite2_Move:
    {
        JSR Sprite2_MoveHoriz
        JSR Sprite2_MoveVert
        
        RTS
    }

; ==============================================================================

    ; *$2F9F4-$2F9FF LOCAL
    Sprite2_MoveHoriz:
    {
        TXA : ADD.b #$10 : TAX
        
        JSR Sprite2_MoveVert
        
        LDX $0FA0
        
        RTS
    }

; ==============================================================================

    ; *$2FA00-$2FA2D LOCAL
    Sprite2_MoveVert:
    {
        LDA $0D40, X : BEQ .no_velocity
        
        ASL #4 : ADD $0D60, X : STA $0D60, X
        
        LDA $0D40, X : PHP : LSR #4 : LDY.b #$00 : PLP : BPL .positive
        
        ORA.b #$F0
        
        DEY
    
    .positive
    
              ADC $0D00, X : STA $0D00, X
        TYA : ADC $0D20, X : STA $0D20, X
    
    .no_velocity
    
        RTS
    }

; ==============================================================================

    ; *$2FA2E-$2FA4F LOCAL
    Sprite2_MoveAltitude:
    {
        LDA $0F80, X : ASL #4 : ADD $0F90, X : STA $0F90, X
        
        LDA $0F80, X : PHP : LSR #4 : PLP : BPL .positive
        
        ORA.b #$F0
    
    .positive
    
        ADC $0F70, X : STA $0F70, X
        
        RTS
    }

; ==============================================================================

    ; *$2FA50-$2FA58 LOCAL
    Sprite2_PrepOamCoord:
    {
        ; Collision detecting function (at least it calls one in bank $06)
        
        JSL Sprite_PrepOamCoordLong : BCC .sprite_wasnt_disabled
        
        PLA : PLA
    
    .sprite_wasnt_disabled
    
        RTS
    }

; ==============================================================================

    ; *$2FA59-$2FAA1 LONG
    Sprite_ShowMessageIfPlayerTouching:
    {
        STA $1CF0
        STY $1CF1
        
        LDA $0E40, X : PHA
        
        LDA.b #$80 : STA $0E40, X
        
        LDA $0F60, X : PHA
        
        ; Alter the hit detection box for the purposes of seeing if the player
        ; wants to talk.
        LDA.b #$07 : STA $0F60, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong
        
        PLA : STA $0F60, X
        PLA : STA $0E40, X
        
        BCC .dontShowDialogue
        
        PHP
        
        JSL Sprite_NullifyHookshotDrag
        
        PLP
        
        STZ $0372
        STZ $5E
        
        LDA $4D : BNE .dontShowDialogue
    
    ; *$2FA8E ALTERNATE ENTRY POINT
    shared Sprite_ShowMessageMinimal:
    
        STZ $0223
        STZ $1CD8
        
        LDA.b #$02 : STA $11
        
        LDA $10 : STA $010C
        
        LDA.b #$0E : STA $10
    
    .dontShowDialogue
    
        RTL
    }

; ==============================================================================

    ; $2FAA2-$2FAC9 LONG
    Overworld_ReadTileAttr:
    {
        ; \task (rather a bug in the way I named this routine...
        ; seems more like a map16 attr reader than a map8 reader. Fixme!
        REP #$30
        
        LDA $00 : SUB $0708 : AND $070A : ASL #3 : STA $06
        
        LDA $02 : SUB $070C : AND $070E : ORA $06 : TAX
        
        LDA $7E2000, X : TAX
        
        LDA $1BF110, X ; $DF110, X THAT IS
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    incsrc "sprite_mad_batter.asm"
    incsrc "sprite_dash_item.asm"
    incsrc "sprite_trough_boy.asm"

; ==============================================================================
