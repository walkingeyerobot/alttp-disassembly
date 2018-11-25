
; ==============================================================================

    ; \unused 1. Don't think ambient sound effects do panning, and 2. this
    ; is probably unused because ... probably no ancillae cause
    ; ambient sound effects to play.
    ; $40000-$40006 LOCAL 
    Ancilla_DoSfx1_NearPlayer:
    {
        JSR Ancilla_SetSfxPan_NearPlayer : STA $012D
        
        RTS
    }

; ==============================================================================

    ; *$40007-$4000D LOCAL
    Ancilla_DoSfx2_NearPlayer:
    {
        JSR Ancilla_SetSfxPan_NearPlayer : STA $012E
        
        RTS
    }

; ==============================================================================

    ; *$4000E-$40014 LOCAL
    Ancilla_DoSfx3_NearPlayer:
    {
        JSR Ancilla_SetSfxPan_NearPlayer : STA $012F
        
        RTS
    }

; ==============================================================================

    ; *$40015-$4001F LOCAL
    Ancilla_SetSfxPan_NearPlayer:
    {
        STA $0CF8
        
        JSL Sound_SetSfxPanWithPlayerCoords : ORA $0CF8
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $40020-$40026 LOCAL
    Ancilla_DoSfx1:
    {
        JSR Ancilla_SetSfxPan : STA $012D
        
        RTS
    }

; ==============================================================================

    ; *$40027-$4002D LOCAL
    Ancilla_DoSfx2:
    {
        JSR Ancilla_SetSfxPan : STA $012E
        
        RTS
    }

; ==============================================================================

    ; *$4002E-$40034 LOCAL
    Ancilla_DoSfx3:
    {
        JSR Ancilla_SetSfxPan : STA $012F
        
        RTS
    }

; ==============================================================================

    ; *$40035-$4003F LOCAL
    Ancilla_SetSfxPan:
    {
        STA $0CF8
        
        JSL Sound_SfxPanObjectCoords : ORA $0CF8
        
        RTS
    }

; ==============================================================================

; $40040-$4006E Data Table
{
    db  0,  0, -8, 16
    
    db  0,  0, -1,  0
    
    db -8, 16,  3,  3
    
    db -1,  0,  0,  0
    
    db   0,  0, -40, 40,   0,  0, -48, 48,   0,  0, -64, 64
    db -40, 40,   0,  0, -48, 48,   0,  0, -64, 64,   0,  0
    
    db   0,  0, -64, 64
    db -64, 64,   0,  0
    
    ; $40070 ($4006F + 1)
    db  8, 12, 16, 16,  4, 16, 24,  8,  8,  8,  0, 20,  0, 16, 40, 24
    db 
}

; ==============================================================================

    ; $4006F-$400B2 Data
    {
        db   0,   8,  12,  16,  16,   4,  16,  24
        db   8,   8,   8,   0,  20,   0,  16,  40
        
        db  24,  16,  16,  16,  16,  12,   8,   8
        db  80,   0,  16,   8,  64,   0,  12,  36
        
        db  16,  12,   8,  16,  16,   4,  12,  28
        db   0,  16,  20,  20,  16,   8,  32,  16
        
        db  16,  16,   4,   0, 128,  16,   4,  48
        db  20,  16,   0,  16,   0,   0,   8,   0
        
        db  16,   8, 120, 128
    }

; ==============================================================================

    ; *$400B3-$4019E LONG
    AddFireRodShot:
    {
        LDY.b #$01
        
        STA $00
        
        JSL Ancilla_CheckForAvailableSlot : BPL .slot_available
        
        ; \tcrf Astounding! While it's not that silly when you think about it,
        ; it would appear that at some point they were considering using the
        ; Somarian blasts as the projectile for the fire rod. Why else put
        ; special logic in here for it? This function is only called when
        ; creating a Fire Rod shot.
        LDA $00 : CMP.b #$01 : BEQ .no_mp_add_back
        
        ; Add back the mp cost for this class of item (rod)
        ; Oddly enough it avoids this for the Somarian blasts, for whatever
        ; reason. But, this is only in the event that there are no open slots
        ; for the object.... eh. whatever.
        LDX.b #$00 : JSL LinkItem_ReturnUnusedMagic
    
    .no_mp_add_back
    
        BRL .return
    
    .slot_available
    
        PHB : PHK : PLB
        
        PHX
        
        ; Again, the bizarro fire rod shot gets sore treatment. It's like it
        ; doesn't even exist! (which it doesn't, kind of).
        LDA $00 : CMP.b #$01 : BEQ .dont_play_sound_effect
        
        PHY
        
        LDA.b #$0E : JSR Ancilla_DoSfx2_NearPlayer
        
        PLY
    
    .dont_play_sound_effect
    
        LDA $00 : STA $0C4A, Y : TAX
        
        LDA $806F, X : STA $0C90, Y
        
        LDA.b #$03 : STA $0C68, Y
        
        LDA.b #$00 : STA $0C54, Y : STA $0C5E, Y : STA $0280, Y : STA $028A, Y
        
        LDA $2F : LSR A : STA $0C72, Y : TAX
        
        PHY : PHX : TYX
        
        ; Appears to check multiple spots around Link to see if the item can
        ; spawn there. If it can't spawn in any of those locations, I guess
        ; we have a problem? Not sure yet.
        JSL Ancilla_CheckInitialTileCollision_Class_1
        
        PLX : PLY
        
        BCS .initialize_in_spread_state
        
        LDA $0022 : ADD $8040, X : STA $0C04, Y
        LDA $0023 : ADC $8044, X : STA $0C18, Y
        
        LDA $0020 : ADD $8048, X : STA $0BFA, Y
        LDA $0021 : ADC $804C, X : STA $0C0E, Y
        
        LDA $0C4A, Y : CMP.b #$01 : BEQ .sword_determines_speed
        
        LDA $8068, X : STA $0C2C, Y
        LDA $806C, X
        
        BRA .speed_has_been_determined
    
    .sword_determines_speed
    
        ; Does this mean we should only be here if we have the Master Sword
        ; or better? This makes somaria shots move at different speeds depending
        ; on which sword we have. But it seems unused for some reason?
        LDA $7EF359 : DEC #2 : ASL #2 : STA $0F
        
        TXA : ADD $0F : TAX
        
        LDA $8050, X : STA $0C2C, Y
        
        LDA $805C, X
    
    .speed_has_been_determined
    
        STA $0C22, Y
        
        ; Floor matches that of the player.
        LDA $00EE : STA $0C7C, Y
        
        ; Pseudo floor matches that of the player.
        LDA $0476 : STA $03CA, Y
        
        PLX
        
        PLB
    
    .return
    
        RTL
    
    .initialize_in_spread_state
    
        LDA $0C4A, Y : CMP.b #$01 : BNE .not_somarian_blast
        
        ; Again, the somarian blast gets shafted in the sound effect department.
        LDA.b #$04 : STA $0C4A, Y
        LDA.b #$07 : STA $0C68, Y
        LDA.b #$10 : STA $0C90, Y
        
        BRA .return_2
    
    .not_somarian_blast
    
        LDA.b #$01 : STA $0C54, Y
        LDA.b #$1F : STA $0C68, Y
        LDA.b #$08 : STA $0C90, Y
        
        LDA.b #$2A : JSR Ancilla_DoSfx2
    
    .return_2
    
        PLX
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $4019F-$401A6 DATA
    pool SomarianBlast_SpawnCentrifugalQuad:
    {
    
    .x_offsets
        db  -8, -8, -9, -4
    
    .y_offsets
        db -15, -4, -8, -8
    }

; ==============================================================================

    ; *$401A7-$40241 LOCAL
    SomarianBlast_SpawnCentrifugalQuad:
    {
        LDA.b #$03 : STA $0FB5
        
        LDA $029E, X : CMP.b #$FF : BNE .altitude_okay
        
        LDA.b #$00
    
    .altitude_okay
    
        STA $05
        
        LDA $0C04, X : STA $00
        LDA $0C18, X : STA $01
        
        LDA $0BFA, X : SUB $05    : STA $02
        LDA $0C0E, X : SBC.b #$00 : STA $03
        
        ; Attempt to spawn four somarian blasts all moving in directions
        ; away from a central point (the location of the former somarian block).
        LDA $0C7C, X : STA $04
    
    .attempt_next_spawn
    
        LDY.b #$04
        LDA.b #$01
        
        JSL Ancilla_CheckForAvailableSlot : BMI .spawn_failed
        
        PHX
        
        LDA.b #$01 : STA $0C4A, Y : TAX
        
        LDA $806F, X : STA $0C90, Y
        
        LDA.b #$04 : STA $0C54, Y
        LDA.b #$00 : STA $0C5E, Y : STA $0280, Y
        
        LDX $0FB5 : TXA : STA $0C72, Y
        
        LDA $00 : ADD .x_offsets, X : STA $0C04, Y
        LDA $01 : ADC.b #$FF   : STA $0C18, Y
        
        LDA $02 : ADD .y_offsets, X : STA $0BFA, Y
        LDA $03 : ADC.b #$FF   : STA $0C0E, Y
        
        JSL Ancilla_TerminateIfOffscreen
        
        LDA $8050, X : STA $0C2C, Y
        LDA $805C, X : STA $0C22, Y
        
        LDA $04 : STA $0C7C, Y
        
        LDA $0476 : STA $03CA, Y
        
        PLX
    
    .spawn_failed
    
        DEC $0FB5 : BPL .attempt_next_spawn
        
        RTS
    }

; ==============================================================================

    ; *$40242-$4024C LONG
    Ancilla_Main:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_RepulseSpark
        JSR Ancilla_ExecuteObjects
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4024D-$40286 LOCAL
    Bomb_ProjectReflexiveSpeedOntoSprite:
    {
        ; This routine subs in an object's coordinates for the
        ; player's and uses a player routine to calculate a collision or some
        ; such.
        LDA $0022 : PHA
        LDA $0023 : PHA
        
        LDA $0020 : PHA
        LDA $0021 : PHA
        
        LDA $04 : STA $0022
        LDA $05 : STA $0023
        
        LDA $06 : STA $0020
        LDA $07 : STA $0021
        
        TYA
        
        JSL Bomb_ProjectReflexiveSpeedOntoSpriteLong
        
        PLA : STA $0021
        PLA : STA $0020
        
        PLA : STA $0023
        PLA : STA $0022
        
        RTS
    }

; ==============================================================================

    ; *$40287-$4032A LOCAL
    Bomb_CheckSpriteDamage:
    {
        ; collision detection used for telling if sprites need some ass whoopin'
        ; (i.e. if they are damaged by the bomb)
        
        LDY.b #$0F
    
    .check_sprite_damage_loop
    
        TYA : EOR $1A : AND.b #$03
        
        ORA $0EF0, Y : ORA $0BA0, Y : BEQ .proceed_with_damage_check
    
    .different_floors
    
        JMP .sprite_undamaged
    
    .proceed_with_damage_check
    
        LDA $0F20, Y : CMP $0C7C, X : BNE .different_floors
        
        ; won't work if the sprite is not "alive"
        LDA $0DD0, Y : CMP.b #$09 : BCC .sprite_undamaged
        
        ; setting up variables for use with collision detection
        
        LDA $0C04, X : SUB.b #$18 : STA $00
        LDA $0C18, X : SBC.b #$00 : STA $08
        
        LDA $0BFA, X : SUB.b #$18
        
        PHP
        
        SUB $029E, X : STA $01
        
        LDA $0C0E, X : SBC.b #$00
        
        PLP
        
        SBC.b #$00 : STA $09
        
        LDA.b #$30 : STA $02 : STA $03
        
        PHX : TYX
        
        JSL Sprite_SetupHitBoxLong
        
        PLX
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .sprite_undamaged
        
        LDA $0E20, Y : CMP.b #$92 : BNE .not_helmasaur_king
        
        ; Only certain parts of the HK are vulnerable.
        LDA $0DB0, Y : CMP.b #$03 : BCS .sprite_undamaged
    
    .not_helmasaur_king
    
        LDA $0C04, X : STA $04
        LDA $0C18, X : STA $05
        
        LDA $0BFA, X : STA $06
        LDA $0C0E, X : STA $07
        
        PHX : PHY
        
        LDA $0C4A, X
        
        TYX
        
        JSL Ancilla_CheckSpriteDamage
        
        ; How far the sprite gets pushed back.
        LDY.b #$40 : JSR Bomb_ProjectReflexiveSpeedOntoSprite
        
        PLY : PLX
        
        ; Reverse those speeds so that we are projecting the speed away from
        ; the Ancilla. In other words, we are causing the sprite to recoil from
        ; some damage.
        LDA $00 : EOR.b #$FF : INC A : STA $0F30, Y
        LDA $01 : EOR.b #$FF : INC A : STA $0F40, Y
    
    .sprite_undamaged
    
        DEY : BMI .checked_all_sprites
        
        JMP .check_sprite_damage_loop
    
    .checked_all_sprites
    
        RTS
    }

; ==============================================================================

    ; *$4032B-$4033B LOCAL
    Ancilla_ExecuteObjects:
    {
        LDX.b #$09
    
    .next_object
    
        STX $0FA0
        
        ; The type of effect in play. 0 designates no effect.
        LDA $0C4A, X : BEQ .inactive_object
        
        JSR Ancilla_ExecuteObject
    
    .inactive_object
    
        DEX : BPL .next_object
        
        RTS
    }

; ==============================================================================

    ; *$4033C-$40404 LOCAL
    Ancilla_ExecuteObject:
    {
        ; Push the ancilla's number to the stack.
        PHA
        
        ; If X >= 6, then...
        CPX.b #$06 : BCS .ignore_oam_allocation
        
        ; This is the number of sprites allocated for the s.o. at init.
        LDA $0C90, X
        
        ; If "sort sprites" is in effect, things are slightly different.
        LDY $0FB3 : BEQ .sort_sprites
        
        ; If the special effect is on a different floor use a different section of the OAM buffer (probably also changes priority)
        LDY $0C7C, X : BNE .on_bg1
        
        ; floor 1 sprites...
        JSL OAM_AllocateFromRegionD
        
        BRA .record_starting_oam_position
    
    .on_bg1
    
        ; floor 2 sprites...
        JSL OAM_AllocateFromRegionF
        
        BRA .record_starting_oam_position
    
    .sortSprites
    
        JSL OAM_AllocateFromRegionA
    
    .record_starting_oam_position
    
        ; The starting place in the OAM Buffer for the special effect
        TYA : STA $0C86, X
    
    .ignore_oam_allocation
    
        ; We're not in the standard submodule.
        LDY $11 : BNE .dont_tick_timer
        
        ; I'm not seeing this as terribly useful
        LDY $0C68, X : BEQ .timer_at_rest
        
        DEC $0C68, X
    
    .timer_at_rest
    .dont_tick_timer
    
        ; Note the subtraction before ASL
        ; Load a subroutine based on the anillary object's index.
        PLA : DEC A : ASL A : TAY
        
        LDA .object_routines+0, Y : STA $00
        LDA .object_routines+1, Y : STA $01
        
        JMP ($0000)
        
    .object_routines
    
        ; NOTE: PARAMETER A IS ACTUALLY object type - 1, SINCE 0 WOULD INDICATE
        ; NO EFFECT ; SOURCE : $0C4A, X
        dw Ancilla_SomarianBlast        ; 0x01 - Both the pieces of somarian block splitting and the fireballs)
        dw Ancilla_FireShot             ; 0x02 - Fire Rod flame (both flying and after hitting something)
        dw Ancilla_Unused_03            ; 0x03 - Unimplemented object type. Won't crash the game but won't ever self terminate.
        dw Ancilla_BeamHit              ; 0x04 - Effect that represents a beam splitting up after it hits something.
        dw Ancilla_Boomerang            ; 0x05 - Boomerang
        dw Ancilla_WallHit              ; 0x06 - Spark-like effect that occurs when you hit a wall with a boomerang or hookshot
        dw Ancilla_Bomb                 ; 0x07 - Blue player bomb
        
        dw Ancilla_DoorDebris           ; 0x08 - Rock fall effect (from bombing a cave)
        dw Ancilla_Arrow                ; 0x09 - Flying arrow
        dw Ancilla_HaltedArrow          ; 0x0A - Arrow stuck in something (wall or sprite)
        dw Ancilla_IceShot              ; 0x0B - Ice Rod shot
        dw Ancilla_SwordBeam            ; 0x0C - Master sword beam
        dw Ancilla_SwordFullChargeSpark ; 0x0D - The sparkle at the tip of your sword when you power up the spin attack
        dw Ancilla_Unused_0E            ; 0x0E - Unimplemented object type that points to the same location as the blast wall
        dw Ancilla_Unused_0F            ; 0x0F - Unimplemented object type that points to the same location as the blast wall
        
        dw Ancilla_Unused_0E            ; 0x10 - Unimplemented object type that points to the same location as the blast wall
        dw Ancilla_IceShotSpread        ; 0x11 - Ice rod shot dissipating after hitting a nontransitive tile.
        dw Ancilla_Unused_0E            ; 0x12 - Unimplemented object type that points to the same location as the blast wall
        dw Ancilla_IceShotSparkle       ; 0x13 - Ice Shot Sparkles (the only actual visible parts of the ice shot)
        dw Ancilla_Unused_14            ; 0x14 - Unimplemented object type. Don't use as it will crash the game.
        dw Ancilla_JumpSplash           ; 0x15 - Splash from jumping into or out of deep water
        dw Ancilla_HitStars             ; 0x16 - The Hammer's Stars / Stars from hitting hard ground with the shovel
        dw Ancilla_ShovelDirt           ; 0x17 - Dirt from digging a hole with the shovel
        
        dw Ancilla_EtherSpell           ; 0x18 - The Ether Effect
        dw Ancilla_BombosSpell          ; 0x19 - The Bombos Effect
        dw Ancilla_MagicPowder          ; 0x1A - Magic powder
        dw Ancilla_SwordWallHit         ; 0x1B - Sparks from tapping a wall with your sword
        dw Ancilla_QuakeSpell           ; 0x1C - The Quake Effect
        dw Ancilla_DashTremor           ; 0x1D - Jarring effect from hitting a wall while dashing
        dw Ancilla_DashDust             ; 0x1E - Pegasus boots dust flying
        dw Ancilla_Hookshot             ; 0x1F - Hookshot
        
        dw Ancilla_BedSpread            ; 0x20 - Player's Bed Spread
        dw Ancilla_SleepIcon            ; 0x21 - Link's Zzzz's from sleeping
        dw Ancilla_ReceiveItem          ; 0x22 - Received Item Sprite
        dw Ancilla_MorphPoof            ; 0x23 - Bunny / Cape transformation poof
        dw Ancilla_Gravestone           ; 0x24 - Gravestone sprite when in motion
        dw Ancilla_Unused_25            ; 0x25 - Unimplemented object type. Don't use as it will crash the game
        dw Ancilla_SwordSwingSparkle    ; 0x26 - Sparkles when swinging lvl 2 or higher sword
        dw Ancilla_TravelBird           ; 0x27 - the bird (when called by flute)
        
        dw Ancilla_WishPondItem         ; 0x28 - item sprite that you throw into magic faerie ponds.
        dw Ancilla_MilestoneItem        ; 0x29 - Pendants, crystals, medallions
        dw Ancilla_InitialSpinSpark     ; 0x2A - Start of spin attack sparkle
        dw Ancilla_SpinSpark            ; 0x2B - During Spin attack sparkles
        dw Ancilla_SomarianBlock        ; 0x2C - Cane of Somaria blocks
        dw Ancilla_SomarianBlockFizzle  ; 0x2D - Suspected of being in cahoots with the somaria objects
        dw Ancilla_SomarianBlockDivide  ; 0x2E - Suspected of being in cahoots with the somaria objects
        dw Ancilla_LampFlame            ; 0x2F - Torch's flame
        
        dw Ancilla_InitialCaneSpark     ; 0x30 - Initial spark for the Cane of Byrna activating
        dw Ancilla_CaneSpark            ; 0x31 - Cane of Byrna spinning sparkle
        dw Ancilla_BlastWallFireball    ; 0x32 - Flame blob, which is an ancillary effect from the blast wall
        dw Ancilla_BlastWall            ; 0x33 - Series of explosions from blowing up a wall (after pulling a switch)
        dw Ancilla_SkullWoodsFire       ; 0x34 - Burning effect used to open up the entrance to skull woods.
        dw Ancilla_SwordCeremony        ; 0x35 - Master Sword ceremony.... not sure if it's the whole thing or a part of it
        dw Ancilla_Flute                ; 0x36 - Flute that pops out of the ground in the haunted grove.
        dw Ancilla_WeathervaneExplosion ; 0x37 - Appears to trigger the weathervane explosion.
        
        dw Ancilla_TravelBirdIntro      ; 0x38 - Appears to give Link the bird enabled flute.
        dw Ancilla_SomarianPlatformPoof ; 0x39 - Cane of Somaria blast which creates platforms (sprite 0xED)
        dw Ancilla_SuperBombExplosion   ; 0x3A - super bomb explosion (also does things normal bombs can)
        dw Ancilla_VictorySparkle       ; 0x3B - Victory sparkle on sword
        dw Ancilla_SwordChargeSpark     ; 0x3C - Sparkles from holding the sword out charging for a spin attack.
        dw Ancilla_ObjectSplash         ; 0x3D - splash effect when things fall into the water
        dw Ancilla_RisingCrystal        ; 0x3E - 3D crystal effect (or transition into 3D crystal?)
        dw Ancilla_BushPoof             ; 0x3F - Disintegrating bush poof (due to magic powder)
        
        dw Ancilla_DwarfPoof            ; 0x40 - Dwarf transformation cloud
        dw Ancilla_WaterfallSplash      ; 0x41 - Water splash from player standing under waterfalls (doorways, basically)
        dw Ancilla_HappinessPondRupees  ; 0x42 - Rupees that you throw in to the Pond of Wishing
        dw Ancilla_BreakTowerSeal       ; 0x43 - Ganon's Tower seal being broken. (not opened up though!)
    }

; ==============================================================================

    incsrc "ancilla_ice_shot_sparkle.asm"
    incsrc "ancilla_somarian_blast.asm"
    incsrc "ancilla_fire_shot.asm"

; ==============================================================================

    ; $40853-$4097A DATA
    pool Ancilla_CheckTileCollisionStaggered:
    {
    
    .collision_table
        db 0, 1, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0
        db 1, 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 2, 0, 3, 3, 3
        db 0, 0, 0, 0, 0, 0, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4
        db 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 3, 3, 3
        db 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4
        db 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0
        db 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        db 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    
    .y_offsets
        db  0, 16,  5,  5,  0, 16,  4,  4,  4, 12
        db  5,  5,  4, 12, 12, 12,  0,  0,  0,  0
    
    .x_offsets
        db  8,  8,  0, 16,  4,  4,  0, 16,  4,  4
        db  4, 12, 12, 12,  4, 12,  0,  0,  0,  0
    }

; ==============================================================================

    ; *$4097B-$40ABE LOCAL
    Ancilla_CheckTileCollisionStaggered:
    {
        TXA : EOR $1A : LSR A : BCC .skip_even_frames
    
    ; *$40981 ALTERNATE ENTRY POINT
    shared Ancilla_CheckTileCollision:
    
        ; If indoors branch here
        LDA $1B : BNE .indoors
        
        LDA $0280, X : BEQ .base_priority
        
        STZ $03E4, X
    
    .skip_even_frames
    
        ; indicate failure
        CLC
        
        RTS
    
    .indoors
    .base_priority
    
        ; Check collision properties of the room
        ; default collision with one BG ("one" in HM)
        LDA $046C : BEQ .check_basic_collision
        
        CMP.b #$03 : REP #$20 : BCC .difference_between_bg_scrolls
        
        STZ $00
        STZ $02
        
        BRA .two_bg_collision_detection
    
    .difference_between_bg_scrolls
    
        LDA $E0 : SUB $E2 : STA $00
        LDA $E6 : SUB $E8 : STA $02
    
    .two_bg_collision_detection
    
        SEP #$20
        
        LDA $0C04, X : PHA : ADD $00 : STA $0C04, X
        LDA $0C18, X : PHA : ADC $01 : STA $0C18, X
        
        LDA $0BFA, X : PHA : ADD $02 : STA $0BFA, X
        LDA $0C0E, X : PHA : ADC $03 : STA $0C0E, X
        
        LDA.b #$01 : STA $0C7C, X
        
        JSR .check_basic_collision
        
        STZ $0C7C, X
        
        PLA : STA $0C0E, X
        PLA : STA $0BFA, X
        
        PLA : STA $0C18, X
        PLA : STA $0C04, X
        
        LDY.b #$01
        
        BCC .no_bg1_collision
        
        INY
    
    .no_bg1_collision
    
        PHY
        
        ; store the state of the carry flag (if set it means there was a collision on BG0)
        PHP
        
        JSR .check_basic_collision
        
        ; takes the previous carry flag state, rolls in the current carry flag state
        ; (Has to detect on BG0 for the carry to be set)
        PLA : AND.b #$01 : ROL A : CMP.b #$01
        
        PLY
        
        RTS
    
    .check_basic_collision
    
        ; Normal Collision checking for just one BG
        
        LDY $0C72, X
        
        LDA $0BFA, X : ADD .y_offsets, Y : STA $00
        LDA $0C0E, X : ADC.b #$00        : STA $01
        
        LDA $0C04, X : ADD .x_offsets, Y : STA $02
        LDA $0C18, X : ADC.b #$00        : STA $03
    
    ; *$40A26 ALTERNATE ENTRY POINT
    shared Ancilla_CheckTargetedTileCollision:
    
        REP #$20 : LDA $00 : SUB $E8
        
        CMP.w #$00E0 : SEP #$20 : BCS .ignore_off_screen_collision_y
        
        REP #$20 : LDA $02 : SUB $E2
        
        ; This one is also due to ignoring off screen collision, but in the
        ; x coordinate.
        CMP.w #$0100 : SEP #$20 : BCS .no_collision
        
        LDA $1B : BNE .check_indoor_collision
        
        REP #$20
        
        LSR $02 : LSR $02 : LSR $02
        
        PHX
        
        JSL Overworld_GetTileAttrAtLocation
        
        PLX
        
        BRA .store_tile_interaction_result
    
    .check_indoor_collision
    
        ; Floor selector for special effects apparently :)
        LDA $0C7C, X
        
        ; Retrieves tile type that the bomb is sitting on.
        JSL Entity_GetTileAttr
    
    .store_tile_interaction_result
    
        STA $03E4, X : TAY
        
        LDA .collision_table, Y : STA $0F
        
        ; Checks the special effect type
        LDA $0C4A, X : CMP #$02 : BNE .not_fire_rod_shot
        
        ; Perhaps looking for a door type tile?
        TYA : AND.b #$F0 : CMP.b #$C0 : BNE .not_torch_collision
        
        ; Make a note of which torch it touched.
        STA $0F
    
    .not_fire_rod_shot
    .not_torch_collision
    
        LDA $0280, X : BNE .forced_high_priority
        
        LDA $0F    : BEQ .tile_type_not_collision_candidate
        CMP.b #$01 : BEQ .collided
        CMP.b #$02 : BNE .not_sloped_tile
        
        JSL Entity_CheckSlopedTileCollisionLong
        
        RTS
    
    .not_sloped_tile
    
        CMP.b #$03 : BNE .not_attr_3
        
        LDY $03CA, X : BNE .collided
    
    .ignore_off_screen_collision_y
    
        BRA .no_collision
    
    .not_attr_3
    .forced_high_priority
    
        ; Educated guess: This looks like an attempt to get the object out
        ; of high priority status that resulted from hitting certain tiles
        ; in earlier frames, like ledges.
        DEC $028A, X : BPL .no_collision
        
        STZ $028A, X
        
        LDA $0F : CMP.b #$04 : BNE .no_collision
        
        LDA.b #$06 : STA $028A, X
        
        LDA $0280, X : EOR.b #$01 : STA $0280, X
        
        BRA .no_collision
    
    .tile_type_not_collision_candidate
    .no_collision
    
        CLC
        
        RTS
    
    .collided
    
        LDY.b #$00
        
        SEC
    
    ; *$40AB9 ALTERNATE ENTRY POINT
    shared Ancilla_AlertSprites:
    
        ; This seems to activate enemies that "listen" for sounds
        LDA.b #$03 : STA $0FDC
        
        RTS
    }

; ==============================================================================

    ; $40ABF-$40BCE DATA
    pool Ancilla_CheckTileCollision_Class2:
    {
    
    ; Similar to the other collision routine's behavior table, this one
    ; opts to not interact with torches or chests, but interacts more
    ; generally with doors and screen transition tiles. This may have
    ; something to do with 
    .collision_table
        db 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0
        db 1, 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 2, 0, 3, 3, 3
        db 0, 0, 0, 0, 0, 0, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4
        db 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 3, 3, 3
        db 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    
    .y_offsets_low
        db -8, 8, 0, 0
    
    .y_offsets_high
        db -1, 0, 0, 0
    
    .x_offsets_low
        db 0, 0, -8, 8
    
    .x_offsets_high
        db 0, 0, -1, 0
    }

; ==============================================================================

    ; *$40BCF-$40CD8 LOCAL
    Ancilla_CheckTileCollision_Class2:
    {
        ; Does collision detection for a number of entities, bombs being one of them
        
        ; "Collision" in Hyrule Magic. Do only collision on BG2
        LDA $046C : BEQ .check_basic_collision
        
        ; Is it the "moving floor" collision type?
        ; if it's collision with 2 BGs then branch
        CMP.b #$03 : REP #$20 : BCC .difference_between_bg_scrolls
        
        STZ $00
        STZ $02
        
        BRA .two_bg_collision_detection
    
    .difference_between_bg_scrolls
    
        ; Calculate the differences in the scroll values between the two main BGs
        ; This is for rooms that have a hidden wall (there's only like 3 of them in the original)
        
        ; $00 = BG1HOFS - BG0HOFS
        LDA $E0 : SUB $E2 : STA $00
        
        ; $02 = BG1VOFS - BG0VOFS
        LDA $E6 : SUB $E8 : STA $02
    
    .two_bg_collision_detection
    
        SEP #$20
        
        LDA $0C04, X : PHA : ADD $00 : STA $0C04, X
        LDA $0C18, X : PHA : ADC $01 : STA $0C18, X
        
        LDA $0BFA, X : PHA : ADD $02 : STA $0BFA, X
        LDA $0C0E, X : PHA : ADC $03 : STA $0C0E, X
        
        LDA.b #$01 : STA $0C7C, X
        
        JSR .check_basic_collision
        
        STZ $0C7C, X
        
        PLA : STA $0C0E, X
        PLA : STA $0BFA, X
        
        PLA : STA $0C18, X
        PLA : STA $0C04, X
        
        LDY.b #$00
        
        BCC .no_bg1_collision
        
        INY
    
    .no_bg1_collision
    
        PHY : PHP
        
        JSR .check_basic_collision
        
        PLA : AND.b #$01 : ROL A : CMP.b #$01
        
        PLY
        
        RTS
    
    .check_basic_collision
    
        ; Normal collision detect (for just one BG)
        ; Next set of operations compute Ycoord + direction dependent value, as well as for the Xcoord of the object
        
        ; direction of the bomb.... I guess... kind of a dumb way to handle this if you ask me.
        LDY $0C72, X
        
        ; $00.w = Ycoord + directionValue
        LDA $0BFA, X : ADD .y_offsets_low,  Y : STA $00
        LDA $0C0E, X : ADC .y_offsets_high, Y : STA $01
        
        ; $02.w = Xcoord + directionValue
        LDA $0C04, X : ADD .x_offsets_low,  Y : STA $02
        LDA $0C18, X : ADC .x_offsets_high, Y : STA $03
        
        REP #$20
        
        LDA $00 : SUB $E8
        
        CMP.w #$00E0 : SEP #$20 : BCS .ignore_off_screen_collision
        
        REP #$20
        
        LDA $02 : SUB $E2
        
        CMP.w #$0100 : SEP #$20 : BCS .ignore_off_screen_collision
        
        ; Are we in a dungeon?
        LDA $1B : BNE .check_indoor_collision
        
        REP #$20
        
        LSR $02 : LSR $02 : LSR $02
        
        PHX
        
        JSL Overworld_GetTileAttrAtLocation
        
        PLX
        
        BRA .store_queried_tile_attr
    
    .check_indoor_collision
    
        ; Tells us what floor the bomb is on and is an input to the next function
        LDA $0C7C, X
        
        JSL Entity_GetTileAttr
    
    .store_queried_tile_attr
    
        ; Store the retrieved tile value for further reference
        ; \task Figure out when and where attribute 3 tile are actually used.
        STA $03E4, X : CMP.b #$03 : BNE .not_attr_3
        
        LDY $03CA, X : BNE .ignore_collision_on_pseudo_bg
    
    .not_attr_3
    
        TAY
        
        ; Collision detection table
        LDA .collision_table, Y : BEQ .no_collision
        CMP.b #$02              : BNE .not_sloped_collision
        
        ; Should be noted that like the other return points for this routine, the above routine
        ; returns a boolean result via the carry flag.
        JSL Entity_CheckSlopedTileCollisionLong
        
        RTS
    
    .not_sloped_collision
    
        ; Seems like ledges kind of guarantee no collision unless the object
        ; is on a pseudo-bg?
        CMP.b #$04 : BNE .not_ledge_tile
        
        LDA $03CA, X : BNE .collided
        
        LDA.b #$01 : STA $0280, X
        
        BRA .no_collision
    
    .not_ledge_tile
    
        CMP.b #$03 : BNE .collided
        
        LDY $03CA, X : BNE .collided
    
    .ignore_off_screen_collision
    .ignore_collision_on_pseudo_bg
    .no_collision
    
        CLC ; failure, no tile can be detected
        
        RTS
    
    .collided
    
        LDY.b #$00
        
        SEC
        
        RTS
    }

; ==============================================================================

    incsrc "ancilla_beam_hit.asm"

; ==============================================================================

    ; *$40D68-$40DA1 LOCAL
    Ancilla_CheckSpriteCollision:
    {
        LDY.b #$0F
    
    .next_sprite
    
        LDA $0C4A, X
        
        CMP.b #$09 : BEQ .arrow_or_hookshot
        CMP.b #$1F : BEQ .arrow_or_hookshot
        
        TYA : EOR $1A : AND.b #$03 : ORA $0F00, Y : BNE .ignore_sprite
    
    .arrow_or_hookshot
    
        LDA $0DD0, Y : CMP.b #$09 : BCC .ignore_sprite
        
        LDA $0CAA, Y : AND.b #$02 : BNE .ignore_priority_differences
        
        LDA $0280, X : BNE .ignore_sprite
    
    .ignore_priority_differences
    
        LDA $0C7C, X : CMP $0F20, Y : BNE .ignore_sprite
        
        JSR Ancilla_CheckIndividualSpriteCollision
    
    .ignore_sprite
    
        DEY : BPL .next_sprite
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$40DA2-$40DA9 LONG
    Ancilla_CheckSpriteCollisionLong:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_CheckSpriteCollision
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $40DAA-$40DAD DATA
    pool Ancilla_CheckIndividualSpriteCollision:
    {
    
    .opposing_sprite_directions
        db 2, 3, 0, 1
    }

; ==============================================================================

    ; *$40DAE-$40E7C LOCAL
    Ancilla_CheckIndividualSpriteCollision:
    {
        JSR Ancilla_SetupHitBox
        
        PHY : PHX
        
        TYX
        
        JSL Sprite_SetupHitBoxLong
        
        PLX : PLY
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCS .hit_box_overlap
        
        JMP .no_collision
    
    .hit_box_overlap
    
        LDA $0B6B, Y : AND.b #$08 : BEQ .doesnt_deflect_arrows
        
        LDA $0C4A, X : CMP.b #$09 : BNE .not_arrow_ancilla
        
        LDA $0E20, Y : CMP.b #$1B : BEQ .not_arrow_vs_enemy_arrow
    
    .create_deflected_arrow
    
        JSL Sprite_CreateDeflectedArrow
        
        CLC
        
        RTS
    
    .not_arrow_vs_enemy_arrow
    
        ; Do we have Silver Arrows?
        LDA $7EF340 : CMP.b #$03 : BCC .not_silver_arrows
        
        JSR .undeflected_silver_arrow
        
        CLC
        
        RTS
    
    .not_silver_arrows
    
        JSR .create_deflected_arrow
    
    ; *$40DEE ALTERNATE ENTRY POINT
    .doesnt_deflect_arrows
    .not_arrow_ancilla
    .undeflected_silver_arrow
    
        LDA $0CAA, Y : AND.b #$10 : BEQ .doesnt_absorb_ancilla
        
        ; Check if the ancilla hit the sprite from the 'front', meaning
        ; that they have opposing orientations.
        LDA $0C72, X : AND.b #$03 : STA $0C72, X
        
        PHY
        
        LDA $0DE0, Y : TAY
        
        LDA .opposing_sprite_directions, Y
        
        PLY
        
        CMP $0C72, X : BEQ .collision_immunity
    
    .doesnt_absorb_ancilla
    
        LDA $0C4A, X : CMP.b #$05 : BEQ .boomerang_ancilla
                       CMP.b #$1F : BNE .not_hookshot_ancilla
        
        LDA $0E20, Y : CMP.b #$8D : BEQ .is_arrghus_spawn
    
    .boomerang_ancilla
    
        ; Can't collide because the sprite has begun dying.
        LDA $0EF0, Y : BNE .collision_immunity
        
        LDA $0CAA, Y : AND.b #$02 : BEQ .not_draggable_sprite
    
    .is_arrghus_spawn
    
        ; Initiate dragging the sprite with the hookshot or boomerang?
        TXA : INC A : STA $0DA0, Y
        
        BRA .indicate_dragging_ancilla
    
    .not_hookshot_ancilla
    .not_draggable_sprite
    
        LDA $0BA0, Y : BNE .no_collision
        
        LDA $0E20, Y : CMP.b #$92 : BNE .not_helmasaur_king_component
        
        LDA $0DB0, Y : CMP.b #$03 : BCC .collision_immunity
    
    .not_helmasaur_king_component
    
        PHX
        
        LDA $0C72, X : AND.b #$03 : TAX
        
        LDA .sprite_recoil_x, X : STA $0F40, Y
        LDA .sprite_recoil_y, X : STA $0F30, Y
        
        PLX : PHX
        
        LDA $0C4A, X : STX $0FB6
        
        TYX : PHY
        
        JSL Ancilla_CheckSpriteDamage
        
        PLY : PLX
    
    .indicate_dragging_ancilla
    
        LDA $0C4A, X : STA $0BB0, Y
    
    .collision_immunity
    
        PLA : PLA
        
        JSR Ancilla_AlertSprites
        
        SEC
        
        RTS
    
    .no_collision
    
        CLC
        
        RTS
    
    .sprite_recoil_x
        db 0, 0, -64, 64
    
    .sprite_recoil_y
        db -64, 64, 0, 0
    }

; ==============================================================================

    ; $40E7D-$40EAC DATA
    pool Ancilla_SetupHitBox:
    {
        db 4, 4, 4, 4
        db 3, 3, 2, 11
        
        db -16, -16, -1, -8
        
        
    ; $40E89
        db 8, 8, 8, 8
        db 1, 1, 1, 1
        
        db 32, 32, 8, 8
        
    ; $40E95
        db 4, 4, 4, 4
        db 2, 11, 2, 2
        
        db -1, -8, -16, -16
    
    ; $40EA1
        db 8, 8, 8, 8
        db 1, 1, 1, 1
        
        db 8, 8, 32, 32
    }

; ==============================================================================

    ; *$40EAD-$40EEC LOCAL
    Ancilla_SetupHitBox:
    {
        STZ $09
        
        PHY
        
        LDY $0C72, X
        
        LDA $0C4A, X : CMP.b #$0C : BNE .not_sword_beam
        
        DEC $09
        
        ; Use a different set of values for the sword beam. Apparently this is
        ; due to 1. The sword beam being incapable of diagonal motion? and / or
        ; 2. That the master sword beam uses a larger hit box (not the larger
        ; values overall).
        TYA : ORA.b #$08 : TAY
    
    .not_sword_beam
    
        LDA $0C04, X : ADD $8E7D, Y : STA $00
        LDA $0C18, X : ADC $09      : STA $08
        
        LDA $0BFA, X : ADD $8E95, Y : STA $01
        LDA $0C0E, X : ADC $09      : STA $09
        
        LDA $8E89, Y : STA $02
        LDA $8EA1, Y : STA $03
        
        PLY
        
        RTS
    
    .unused
    
        RTS
    }

; ==============================================================================

    ; *$40EED-$40F5B LOCAL
    Ancilla_ProjectSpeedTowardsPlayer:
    {
        STA $01
        
        PHX : PHY
        
        JSR Ancilla_IsBelowPlayer
        
        STY $02
        
        LDA $0E : BPL .delta_y_already_positive
        
        EOR.b #$FF : INC A
    
    .delta_y_already_positive
    
        STA $0C
        
        JSR Ancilla_IsToRightOfPlayer
        
        STY $03
        
        LDA $0F : BPL .delta_x_already_positive
        
        EOR.b #$FF : INC A
    
    .delta_x_already_positive
    
        STA $0D
        
        LDY.b #$00
        
        LDA $0D : CMP $0C : BCS .dx_is_bigger
        
        ; y = 1 if y component is larger, 0 if x component is larger
        INY
        
        ; swap $0C and $0D if y component is larger
        PHA : LDA $0C : STA $0D
        PLA : STA $0C
    
    .dx_is_bigger
    
        STZ $0B
        STZ $00
        
        LDX $01
    
    .still_have_velocity_to_apply
    
        ; If ($0B + $0C) <= ($0D)
        LDA $0B : ADD $0C : CMP $0D : BCC .not_accumulated_yet
        
        ; Otherwise, just subtract the larger value and increment $00.
        SBC $0D
        
        ; Apportion velocity to the direction that has less magnitude for once.
        INC $00
    
    .not_accumulated_yet
    
        STA $0B
        
        DEX : BNE .still_have_velocity_to_apply
        
        TYA : BEQ .dx_is_bigger_2
        
        ; Swap again.
        LDA $00 : PHA
        LDA $01 : STA $00
        PLA     : STA $01
    
    .dx_is_bigger_2
    
        LDA $00
        
        LDY $02 : BEQ .y_polarity_correct
        
        EOR.b #$FF : INC A : STA $00
    
    .y_polarity_correct
    
        LDA $01
        
        LDY $03 : BEQ .x_polarity_correct
        
        EOR.b #$FF : INC A : STA $01
    
    .y_polarity_correct
    
        PLY : PLX
        
        RTS
    }

; ==============================================================================

    ; $40F5C-$40F6E LOCAL
    Ancilla_IsToRightOfPlayer:
    {
        LDY.b #$00
        
        LDA $22 : SUB $0C04, X : STA $0F
        LDA $23 : SBC $0C18, X : BPL .object_leftward_of_player
        
        ; Object is rightward of player
        INY
    
    .object_leftward_of_player
    
        RTS
    }

; ==============================================================================

    ; *$40F6F-$40F81 LOCAL
    Ancilla_IsBelowPlayer:
    {
        LDY.b #$00
        
        LDA $20 : SUB $0BFA, X : STA $0E
        LDA $21 : SBC $0C0E, X : BPL .object_upward_of_player
        
        ; Object is downward of player
        INY
    
    .object_upward_of_player
    .return
    
        RTS
    }

; ==============================================================================

    incsrc "ancilla_repulse_spark.asm"

; ==============================================================================

    ; *$41080-$4108A LOCAL
    Ancilla_MoveHoriz:
    {
        ; Increments X_reg by 0x0A so that X coordinates will be handled next
        TXA : ADD.b #$0A : TAX
        
        JSR Ancilla_MoveVert
        
        ; Reload the special object's index to X
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================

    ; *$4108B-$410B6 LOCAL
    Ancilla_MoveVert:
    {
        LDA $0C22, X : ASL #4 : ADD $0C36, X : STA $0C36, X
        
        LDY.b #$00
        
        ; upper 4 bits are pixels per frame. lower 4 bits are 1/16ths of a pixel per frame.
        ; store the carry result of adding to $0C36, X
        ; check if the y pixel change per frame is negative
        LDA $0C22, X : PHP : LSR #4 : PLP : BPL .moving_down
        
        ; sign extend from 4-bits to 8-bits
        ORA.b #$F0
        
        DEY
    
    .moving_down
    
        ; modifies the y coordinates of the special object
              ADC $0BFA, X : STA $0BFA, X
        TYA : ADC $0C0E, X : STA $0C0E, X
        
        RTS
    }

; ==============================================================================

    ; *$410B7-$410DB LOCAL
    Ancilla_MoveAltitude:
    {
        LDA $0294, X : ASL #4 : ADD $02A8, X : STA $02A8, X
        
        LDY.b #$00
        
        LDA $0294, X : PHP : LSR #4 : PLP : BPL .moving_higher
        
        ORA.b #$F0
    
    .moving_higher
    
        ADC $029E, X : STA $029E, X
        
        RTS
    }

; ==============================================================================

    incsrc "ancilla_boomerang.asm"
    incsrc "ancilla_wall_hit.asm"
    incsrc "ancilla_bomb.asm"
    incsrc "ancilla_door_debris.asm"
    incsrc "ancilla_arrow.asm"
    incsrc "ancilla_halted_arrow.asm"
    incsrc "ancilla_ice_shot.asm"
    incsrc "ancilla_ice_shot_spread.asm"
    incsrc "ancilla_blast_wall.asm"
    incsrc "ancilla_jump_splash.asm"
    incsrc "ancilla_hit_stars.asm"
    incsrc "ancilla_shovel_dirt.asm"
    incsrc "ancilla_blast_wall_fireball.asm"
    incsrc "ancilla_ether_spell.asm"
    incsrc "ancilla_bombos_spell.asm"
    incsrc "ancilla_quake_spell.asm"
    incsrc "ancilla_magic_powder.asm"
    incsrc "ancilla_dash_tremor.asm"
    incsrc "ancilla_dash_dust.asm"
    incsrc "ancilla_hookshot.asm"
    incsrc "ancilla_bedspread.asm"
    incsrc "ancilla_sleep_icon.asm"
    incsrc "ancilla_victory_sparkle.asm"
    incsrc "ancilla_sword_charge_spark.asm"
    incsrc "ancilla_sword_ceremony.asm"
    incsrc "ancilla_receive_item.asm"
    incsrc "ancilla_wish_pond_item.asm"
    incsrc "ancilla_happiness_pond_rupees.asm"
    incsrc "ancilla_object_splash.asm"
    incsrc "ancilla_milestone_item.asm"
    incsrc "ancilla_rising_crystal.asm"

; ==============================================================================

    ; *$44C93-$44C9F LOCAL
    Ancilla_AddSwordChargeSpark:
    {
        ; Only on certain frames.
        LDA $1A : AND.b #$07 : BNE .sorry_ladies_no_sparkles_with_this_dress
        
        PHX
        
        JSL AddSwordChargeSpark
        
        PLX
    
    .sorry_ladies_no_sparkles_with_this_dress
    
        RTS
    }

; ==============================================================================

    incsrc "ancilla_break_tower_seal.asm"
    incsrc "ancilla_flute.asm"
    incsrc "ancilla_weathervane_explosion.asm"
    incsrc "ancilla_travel_bird_intro.asm"
    incsrc "ancilla_morph_poof.asm"
    incsrc "ancilla_dwarf_poof.asm"
    incsrc "ancilla_bush_poof.asm"
    incsrc "ancilla_sword_swing_sparkle.asm"
    incsrc "ancilla_initial_spin_spark.asm"
    incsrc "ancilla_spin_spark.asm"
    incsrc "ancilla_cane_spark.asm"

; ==============================================================================

    ; *$45DC5-$45DC9 JUMP LOCATION
    Ancilla_SwordBeam:
    {
        JSL SwordBeam
        
        RTS
    }

; ==============================================================================

    ; *$45DCA-$45DD7 JUMP LOCATION
    Ancilla_SwordFullChargeSpark:
    {
        LDA.b #$04
        
        JSR Ancilla_AllocateOam
        
        TYA : STA $0C86, X
        
        JSL SwordFullChargeSpark
        
        RTS
    }

; ==============================================================================

    incsrc "ancilla_travel_bird.asm"
    incsrc "ancilla_init_somarian_block.asm"

; ==============================================================================

    ; *$461F9-$4623C LOCAL
    Ancilla_CheckBasicSpriteCollision:
    {
        LDY.b #$0F
    
    .next_sprite
    
        ; This staggers out collision detection so only some fraction of the
        ; prites are being checked for collision with the object.
        TYA : EOR $1A : AND.b #$03 : ORA $0F00, Y : ORA $0EF0, Y
        
        BNE .no_collision
        
        LDA $0DD0, Y : CMP.b #$09 : BCC .no_collision
        
        LDA $0CAA, Y : AND.b #$02 : BNE .sprite_ignores_priority
        
        LDA $0280, X : BNE .no_collision
    
    .sprite_ignores_priority
    
        LDA $0C7C, X : CMP $0F20, Y : BNE .no_collision
        
        LDA $0C4A, X : CMP.b #$2C : BNE .not_somarian_block
        
        ; Crystal switches ignore interaction with somarian blocks apparently.
        ; (But when they are transmuted to blasts, this is no longer the case.)
        LDA $0E20, Y : CMP.b #$1E : BEQ .no_collision
        
        CMP.b #$90 : BEQ .no_collision
    
    .not_somarian_block
    
        JSR Ancilla_CheckSingleBasicSpriteCollision
    
    .no_collision
    
        DEY : BPL .next_sprite
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$4623D-$462C9 LOCAL
    Ancilla_CheckSingleBasicSpriteCollision:
    {
        JSR Ancilla_SetupBasicHitBox
        
        PHY : PHX
        
        TYX
        
        JSL Sprite_SetupHitBoxLong
        
        PLX : PLY
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .no_collision
        
        ; Helmasaur king check...
        LDA $0E20, Y : CMP.b #$92 : BNE .not_helmasaur_king_component
        
        LDA $0DB0, Y : CMP.b #$03 : BCC .not_helmasaur_king_mask
    
    .not_helmasaur_king_component
    
        ; Only make the sprite change direction if it's a Winder. At that,
        ; only somarian blocks and fire rod shots call here anyways, afaik.
        LDA $0E20, Y : CMP.b #$80 : BNE .dont_repulse_sprite
        
        LDA $0F10, Y : BNE .dont_repulse_sprite
        
        LDA.b #$18 : STA $0F10, Y
        
        LDA $0DE0, Y : EOR.b #$01 : STA $0DE0, Y
    
    .dont_repulse_sprite
    
        LDA $0BA0, Y : BNE .no_collision
        
        LDA $0C04, X : SUB.b #$08 : STA $04
        LDA $0C18, X : SBC.b #$00 : STA $05
        
        LDA $0BFA, X : SUB.b #$08 : PHP : SUB $029E, X : STA $06
        LDA $0C0E, X : SBC.b #$00 : PLP : SBC.b #$00   : STA $07
        
        LDA.b #$50
        
        PHY : PHX
        
        TYX
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        PLX : PLY
        
        LDA $00 : EOR.b #$FF : STA $0F30, Y
        LDA $01 : EOR.b #$FF : STA $0F40, Y
        
        PHX
        
        LDA $0C4A, X
        
        TYX
        
        JSL Ancilla_CheckSpriteDamage
        
        PLX
    
    .not_helmasaur_king_mask
    
        PLA : PLA
        
        SEC
        
        RTS
    
    .no_collision
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; \note By basic I mean that it is not specific to the special object's type,
    ; like the other routine does. This creates a 15x15 hit box that starts
    ; 8 pixels to the left and above the sprite.
    ; This routine, however, also takes altitude into account, whereas the
    ; more specific one doesn't, for whatever reason.
    
    ; *$462CA-$462F8 LOCAL
    Ancilla_SetupBasicHitBox:
    {
        LDA $0C04, X : SUB.b #$08 : STA $00
        LDA $0C18, X : SBC.b #$00 : STA $08
        
        LDA $0BFA, X : SUB.b #$08 : PHP : SUB $029E, X : STA $01
        LDA $0C0E, X : SBC.b #$00 : PLP : SBC.b #$00   : STA $09
        
        LDA.b #$0F : STA $02
        LDA.b #$0F : STA $03
    
    .return
    
        RTS
    }

; ==============================================================================

    incsrc "ancilla_somarian_block.asm"
    incsrc "ancilla_somarian_block_fizzle.asm"
    incsrc "ancilla_somarian_platform_poof.asm"
    incsrc "ancilla_somarian_block_divide.asm"
    incsrc "ancilla_lamp_flame.asm"
    incsrc "ancilla_waterfall_splash.asm"
    incsrc "ancilla_gravestone.asm"
    incsrc "ancilla_skull_woods_fire.asm"
    incsrc "ancilla_super_bomb_explosion.asm"
    incsrc "ancilla_revival_faerie.asm"
    incsrc "ancilla_game_over_text.asm"

; ==============================================================================

    ; *$47624-$47630 LOCAL
    Ancilla_SetSfxPan_NearEntity:
    {
        PHX
        
        LSR #5 : TAX
        
        LDA $09968A, X
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$47631-$4765E LOCAL
    Ancilla_Spawn:
    {
        PHA
        
        JSL Ancilla_CheckForAvailableSlot
        
        PLA
        
        TYX : BMI .no_open_slots
        
        STA $0C4A, X : TAY
        
        LDA $806F, Y : STA $0C90, X
        LDA $EE      : STA $0C7C, X
        LDA $0476    : STA $03CA, X
        
        STZ $0C22, X
        STZ $0C2C, X
        STZ $0280, X
        STZ $028A, X
        
        CLC
        
        RTS
    
    .no_open_slots
    
        SEC
        
        RTS
    }

; ==============================================================================

    ; \unused 
    ; $4765F-$4766C LOCAL
    Ancilla_FindMatch:
    {
        ; Looks through active effect slots to see if the one we want to
        ; put in is already there.

        LDX.b #$05
        
    .next_slot
    
        CMP $0C4A, X : BEQ .match
        
        DEX : BPL .next_slot
        
        CLC
        
        RTS
    
    .match
    
        SEC
        
        RTS
    }

; ==============================================================================

    ; $4766D-$47670 DATA
    pool Ancilla_PrepOamCoord:
    parallel pool Ancilla_PrepAdjustedOamCoord:
    {
    
    .priority
        db $20, $10, $30, $20
    }

; ==============================================================================

    ; *$47671-$476A3 LOCAL
    Ancilla_PrepOamCoord:
    {
        LDY $0C7C, X
        
        LDA .priority, Y : STA $65
                           STZ $64
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        REP #$20
        
        LDA $00 : SUB $E8 : STA $00
        LDA $02 : SUB $E2 : STA $02 : STA $04
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$476A4-$476D8 LOCAL
    Ancilla_PrepAdjustedOamCoord:
    {
        ; Identical to the preceding routine, except that it measures against
        ; the adjusted screen coordinates ($0122 and $011e) which can be
        ; manipulated via effects and.... moving floors maybe.
        
        LDY $0C7C, X
        
        LDA .priority, Y : STA $65
                           STZ $64
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        REP #$20
        
        LDA $00 : SUB $0122 : STA $00
        
        LDA $02 : SUB $011E : STA $02 : STA $04
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$476D9-$476E0 LONG
    Ancilla_PrepOamCoordLong:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_PrepOamCoord
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \note Performs a basic bounds check before deciding to write OAM x and y
    ; coordinates to the OAM buffer. While this routine is quite adequate
    ; for just displaying special effects that are expected to be fully within
    ; the framme of view, it is not quite correct for handling OAM sprites
    ; that are partially on screen and partially off screen.
    ; *$476E1-$476FD LOCAL
    Ancilla_SetOam_XY:
    {
        PHX
        
        ; Get set to push the sprite offscreen.
        LDX.b #$F0
        
        ; I'm guessing $01 and $03 indicate the sprite is offscreen.
        LDA $01 : BNE .off_screen
        
        LDA $03 : BNE .off_screen
        
        ; Store the X coordinate into OAM.
        LDA $02 : STA ($90), Y
        
        ; Indicates the sprite is already below the visible lines of the screen.
        LDA $00 : CMP.b #$F0 : BCS .off_screen
        
        TAX
    
    .off_screen
    
        INY
        
        ; Store the Y coordinate.
        TXA : STA ($90), Y : INY
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$476FE-$47701 LONG
    Ancilla_SetOam_XY_Long:
    {
        JSR Ancilla_SetOam_XY
        
        RTL
    }

; ==============================================================================

    ; \note This routine sets the x and y OAM coordinates of an ancillary
    ; object in the correct way that most other logic in the game uses.
    ; The more basic Ancilla_SetOam_XY doesn't account for OAM entries being
    ; partially on screen and partially off screen.
    ; *$47702-$4772E LOCAL
    Ancilla_SetSafeOam_XY:
    {
        REP #$20
        
        ; Store the sprite's X coordinate
        LDA $02 : STA ($90), Y : INY
        
        ; Is the sprite's X coordinate > 0x100?
        ADD.w #$0080 : CMP.w #$0180 : BCS .off_screen
        
        ; If the sprite's X coordinate exceeds 0x100
        LDA $02 : AND.w #$0100 : STA $74
        
        LDA $00 : STA ($90), Y
        
        ; Same as CMP #$00F0... I don't get it
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen
    
    .off_screen
    
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen
    
        SEP #$20
        
        INY
        
        RTS
    }

; ==============================================================================

    ; $4772F-$4776A DATA
    pool Ancilla_CheckPlayerCollision:
    {
    
    .y_offsets
        db  0,  0,  8,  0,  8,  0,  8,  0,  0,  0
    
    .x_offsets
        db  0,  0,  8,  0,  8,  0,  8,  0,  0,  0
    
    .y_windows
        db 20,  0, 20,  0,  8,  0, 28,  0, 14,  0
    
    .x_windows
        db 20,  0,  3,  0,  8,  0, 24,  0, 14,  0
    
    .player_y_offsets
        db 12,  0, 12,  0, 12,  0, 12,  0, 12,  0
    
    .player_x_offsets
        db  8,  0,  8,  0,  8,  0, 12,  0,  8,  0
        
    }

; ==============================================================================

    ; \note Checks ancilla collision or proximity with the player.
    ; *$4776B-$477DB LOCAL
    Ancilla_CheckPlayerCollision:
    {
        ; Y is probably a selector for different hit box sizes
        TYA : ASL A : TAY
        
        ; $00 = Y coordinate
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        ; $02 = X coordinate
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        STZ $0B
        
        ; $0A = "altitude"
        LDA $029E, X : STA $0A : BPL .sign_ext_z_coord
        
        LDA.b #$FF : STA $0B
    
    .sign_ext_z_coord
    
        REP #$20
        
        LDA $00 : ADD $0A : ADD .y_offsets, Y : STA $00
        LDA $02           : ADD .x_offsets, Y : STA $02
        
        LDA $20 : ADD .player_y_offsets, Y : SUB $00
        
        STA $04 : BPL .positive_delta_y
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_y
    
        STA $08 : CMP .y_windows, Y : BCC .not_collision
        
        LDA $22 : ADD .player_x_offsets, Y : SUB $02
        
        STA $06 : BPL .positive_delta_x
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_x
    
        STA $0A : CMP .x_windows, Y : BCS .not_collision
        
        SEP #$20
        
        SEC
        
        RTS

    .not_collision

        SEP #$20
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$477DC-$47823 LOCAL
    Hookshot_CheckChainLinkProximityToPlayer:
    {
        REP #$20
        
        LDA $00 : ADD.w #$0004 : STA $72
        LDA $02 : ADD.w #$0004 : STA $74
        
        LDA $20 : SUB $E8 : ADD.w #$000C : SUB $72 : BPL .positive_delta_y
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_y
    
        CMP.w #$000C : BCS .out_of_range
        
        LDA $22 : SUB $E2 : ADD.w #$0008 : SUB $74 : BPL .positive_delta_x
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_x
    
        CMP.w #$000C : BCS .out_of_range
        
        SEP #$20
        
        SEC
        
        RTS
    
    .out_of_range
    
        SEP #$20
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; $47824-$47843 DATA
    pool Ancilla_CheckIfEntranceTriggered:
    {
    
    .trigger_coord_y
        dw $0D40, $0210, $0CFC, $0100
    
    .trigger_coord_x
        dw $0D80, $0E68, $0130, $0F10
    
    .trigger_window_y
        dw $000B, $0020, $0010, $000C
    
    .trigger_window_y
        dw $0010, $0010, $0010, $0010
    }

; ==============================================================================

    ; *$47844-$4787A LOCAL
    Ancilla_CheckIfEntranceTriggered:
    {
        ; Y is the index into the coordinates where the trigger blocks are.
        TYA : ASL A : TAY
        
        REP #$20
        
        ; Centers player's Y coordinate.
        LDA $20 : ADD.w #$000C : SUB .trigger_coord_y, Y : BPL .positive_delta_y
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_y
    
        ; Is the distance less than or equal to this many pixels? 
        CMP .trigger_window_y, Y : BCS .failure
        
        ; Centers player's X coordinate.
        LDA $22 : ADD.w #$0008 : SUB .trigger_coord_x, Y : BPL .positive_delta_x
        
        ; abs(x_coord)
        EOR.w #$FFFF : INC A
    
    .positive_delta_x
    
        ; Is the distance less than or equal to this.
        CMP .trigger_window_x, Y : BCS .failure
        
        SEP #$20
        
        SEC
        
        RTS
    
    .failure
    
        SEP #$20
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; $4787B-$47896 DATA
    pool Ancilla_DrawShadow:
    {
    
    .chr
        db $6C, $6C
        db $28, $28
        db $38, $FF
        db $C8, $C8
        db $D8, $D8
        db $D9, $D9
        db $DA, $DA
    
    .properties
        db $28, $68
        db $28, $68
        db $28, $FF
        db $22, $22
        db $24, $64
        db $24, $64
        db $24, $64
    }

; ==============================================================================

    ; *$47897-$47909 LOCAL
    Ancilla_DrawShadow:
    {
        CPX.b #$02 : BNE .not_small_shadow
        
        REP #$20
        
        LDA $02 : ADD.w #$0004 : STA $02
        
        SEP #$20
    
    .not_small_shadow
    
        TXA : ASL A : TAX
        
        STZ $74
        STZ $75
        
        JSR Ancilla_SetSafeOam_XY
        
        LDA .chr, X                               : STA ($90), Y : INY
        LDA .properties, X : AND.b #$CF : ORA $04 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : ORA $75 : STA ($92), Y
        
        PLY
        
        REP #$20
        
        LDA $02 : ADD.w #$0008 : STA $02
        
        SEP #$20
        
        LDA $F87C, X : CMP.b #$FF : BEQ .only_one_oam_entry
        
        STZ $74
        STZ $75
        
        JSR Ancilla_SetSafeOam_XY
        
        LDA .chr+1, X                               : STA ($90), Y : INY
        LDA .properties+1, X : AND.b #$CF : ORA $04 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$03 : LSR #2 : TAY
        
        LDA.b #$00 : ORA $75 : STA ($92), Y
        
        PLY
    
    .only_one_oam_entry
    
        RTS
    }

; ==============================================================================

    ; *$4790A-$47919 LOCAL
    Ancilla_AllocateOam_B_or_E:
    {
        LDY $0FB3 : BNE .sort_sprites
        
        JSL OAM_AllocateFromRegionB
        
        BRA .return
    
    .sort_sprites
    
        JSL OAM_AllocateFromRegionE
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$4791A-$479B9 LONG
    Tagalong_GetCloseToPlayer:
    {
        PHB : PHK : PLB
    
    .need_to_get_closer_to_player
    
        LDX $02D3
        
        LDA $1A00, X : STA $0C03
        LDA $1A14, X : STA $0C17
        
        LDA $1A28, X : STA $0C0D
        LDA $1A3C, X : STA $0C21
        
        LDX.b #$09
        LDA.b #$18
        
        JSR Ancilla_ProjectSpeedTowardsPlayer
        
        LDA $00 : STA $0C22, X
        LDA $01 : STA $0C2C, X
        
        JSR Ancilla_MoveVert
        
        PHX
        
        JSR Ancilla_MoveHoriz
        
        PLX
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        REP #$20
        
        LDA $00 : SUB $20 : BPL .object_below_player
        
        EOR.w #$FFFF : INC A
    
    .object_below_player
    
        CMP.w #$0002 : BCS .too_far_away_from_player
        
        LDA $02 : SUB $22 : BPL .object_right_of_player
        
        EOR.w #$FFFF : INC A
    
    .object_right_of_player
    
        CMP.w #$0002 : BCC .close_enough_to_player
    
    .too_far_away_from_player
    
        SEP #$20
        
        ; Try up to 0x12 times to get closer to the player but give up after
        ; that.
        INC $02D3 : LDX $02D3 : CPX.b #$12 : BEQ .exhausted_attempts
        
        LDA $00 : STA $1A00, X
        LDA $01 : STA $1A14, X
        
        LDA $02 : STA $1A28, X
        LDA $03 : STA $1A3C, X
        
        LDY $EE
        
        LDA Ancilla_PrepOamCoord.priority, Y
        
        LSR #2 : ORA.b #$01 : STA $1A64, X
        
        BRL .need_to_get_closer_to_player
    
    .close_enough_to_player
    .exhausted_attempts
    
        SEP #$20
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$479BA-$479FF LOCAL
    Ancilla_CustomAllocateOam:
    {
        PHA : PHX
        
        REP #$20
        
        TYA : AND.w #$00FF : ADD $90
        
        LDX $0FB3 : BEQ .unsorted_sprites
        
        ; Is it in the second half of the oam buffer?
        CMP.w #$0900 : BCS .upper_region
        CMP.w #$08E0 : BCC .reset_unneeded
        
        LDA.w #$0820
        
        BRA .set_oam_pointer
    
    .upper_region
    
        CMP.w #$09D0 : BCC .reset_unneeded
        
        LDA.w #$0940
        
        BRA .set_oam_pointer
    
    .unsorted_sprites
    
        CMP.w #$0990 : BCC .reset_unneeded
        
        LDA.w #$0820
    
    .set_oam_pointer
    
        STA $90
        
        SUB.w #$0800 : LSR #2 : ADD.w #$0A20 : STA $92
        
        LDY.b #$00
    
    .reset_unneeded
    
        SEP #$20
        
        PLX : PLA
        
        RTS
    }

; ==============================================================================

    ; *$47A00-$47A2C LOCAL
    HitStars_UpdateOamBufferPosition:
    {
        PHA : PHX
        
        REP #$20
        
        TYA : AND.w #$00FF : ADD $90
        
        LDX $0FB3 : BNE .sort_sprites
        
        CMP.w #$09D0 : BCC .dont_reset_oam_pointer
        
        LDA.w #$0820 : STA $90
        
        SUB.w #$0800 : LSR #2 : ADD.w #$0A20 : STA $92
        
        LDY.b #$00
    
    .sort_sprites
    .dont_reset_oam_pointer
        
        SEP #$20
        
        PLX : PLA
        
        RTS
    }

; ==============================================================================

    ; *$47A2D-$47ADC LOCAL
    Hookshot_IsCollisionCheckFutile:
    {
        ; Only the Hookshot calls this.
        PHX : PHY
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        LDA $1B : BNE .indoors
        
        REP #$20
        
        LDA $0C72, X : AND.w #$0002 : BNE .moving_horizontally
        
        LDX $0700 : LDA $00 : SUB $02A8C4, X : CMP.w #$0004 : BCC .off_screen
        
        CMP $0716 : BCS .off_screen
        
        BRA .not_at_screen_edge
    
    .moving_horizontally
    
        LDX $0700 : LDA $02 : SUB $02A944, X : CMP.w #$0006 : BCC .off_screen
        
        CMP $0716 : BCC .not_at_screen_edge
    
    .off_screen
    
        SEP #$20
        
        PLY : PLX
        
        SEC
        
        RTS
    
    .not_at_screen_edge
    
        SEP #$20
        
        PLY : PLX
        
        CLC
        
        RTS
    
    .indoors
    
        REP #$20
        
        LDA $0C72, X : AND.w #$0002 : BNE .moving_indoors_horizontally
        
        LDA $00 : AND.w #$01FF : CMP.w #$0004 : BCC .off_screen
        
        CMP.w #$01E8 : BCS .off_screen
        
        BRA .check_indoor_same_screen_y
    
    .moving_indoors_horizontally
    
        LDA $02 : AND.w #$01FF : CMP.w #$0004 : BCC .off_screen
        
        CMP.w #$01F0 : BCS .off_screen
        
        BRA .check_indoor_same_screen_y
    
    .check_indoor_same_screen_y
    
        SEP #$20
        
        PLY : PLX
        
        LDA $01 : AND.b #$02 : STA $01
        LDA $21 : AND.b #$02 : CMP $01 : BEQ .same_screen_as_player
        
        SEC
        
        RTS
    
    .check_indoor_same_screen_y
    
        SEP #$20
        
        PLY : PLX
        
        LDA $03 : AND.b #$02 : STA $03
        LDA $23 : AND.b #$02 : CMP $03 : BEQ .same_screen_as_player
        
        SEC
        
        RTS
    
    .same_screen_as_player
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$47ADD-$47B22 LOCAL
    Ancilla_GetRadialProjection:
    {
        PHX
        
        TAX
        
        LDA $0FFC02, X : STA $4202
        LDA $08        : STA $4203
        
        ; Sign of the projected distance.
        LDA $0FFC42, X : STA $02
                         STZ $03
        
        ; Get Y projected distance?
        LDA $4216 : ASL A
        LDA $4217 : ADC.b #$00 : STA $00
                                 STZ $01
        
        LDA $0FFBC2, X : STA $4202
        LDA $08        : STA $4203
        
        ; Sign of the projected distance.
        LDA $0FFC82, X : STA $06
                         STZ $07
        
        ; Get X projected distance?
        LDA $4216 : ASL A
        LDA $4217 : ADC.b #$00 : STA $04
                                 STZ $05
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$47B23-$47B2A LONG
    Ancilla_GetRadialProjectionLong:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_GetRadialProjection
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$47B2B-$47B43 LOCAL
    Ancilla_AllocateOam:
    {
        LDY $0FB3 : BNE .sorted_sprites
        
        JSL OAM_AllocateFromRegionA
        
        RTS
    
    .sorted_sprites
    
        LDY $0C7C, X : BNE .on_bg1
        
        JSL OAM_AllocateFromRegionD
        
        RTS
    
    .on_bg1
    
        JSL OAM_AllocateFromRegionF
        
        RTS
    }

; ==============================================================================

    ; *$47B44-$47BA5 LONG BRANCH LOCATION
    BeamHit_Unknown:
    {
        JSR BeamHit_GetCoords
        
        LDY.b #$00
    
    .next_oam_entry
    
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $0B : BPL .override_size
        
        LDA ($92), Y : AND.b #$02
    
    .override_size
    
        STA ($92), Y
        
        PLY
        
        LDX.b #$00
        
        LDA ($90), Y : SUB $07 : BPL .positive_x
        
        DEX
    
    .positive_x
    
              ADD $02 : STA $04
        TXA : ADC $03 : STA $05
        
        JSR BeamHit_Get_Top_X_Bit : BCC .no_x_adjustment_needed
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA ($92), Y : ORA.b #$01 : STA ($92), Y
        
        PLY
    
    .no_x_adjustment_needed
    
        LDX.b #$00
        INY
        
        LDA ($90), Y : SUB $06 : BPL .positive_y
        
        DEX
    
    .positive_y
    
        ADD $00 : STA $09
        
        TXA : ADC $01 : STA $0A
        
        JSR BeamHit_CheckOffscreen_Y : BCC .onscreen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .onscreen_y
    
        INY #3
        
        DEC $08 : BPL .next_oam_entry
        
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================

    ; *$47BA6-$47BC8 LOCAL
    BeamHit_GetCoords:
    {
        STY $0B
        STA $08
        
        LDA $0BFA, X : STA $00 : SUB $E8 : STA $06
        LDA $0C0E, X : STA $01
        LDA $0C04, X : STA $02 : SUB $E2 : STA $07
        LDA $0C18, X : STA $03
        
        RTS
    }

; ==============================================================================

    ; *$47BC9-$47BD5 LOCAL
    BeamHit_Get_Top_X_Bit:
    {
        REP #$20
        
        LDA $04 : SUB $E2 : CMP.w #$0100
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$47BD6-$47BEC LOCAL
    BeamHit_CheckOffscreen_Y:
    {
        REP #$20
        
        LDA $09 : PHA : ADD.w #$0010 : STA $09
        SUB $E8 : CMP.w #$0100
        
        PLA : STA $09
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $47BED-$47EE9 lots of mysterious data. needs investigation
    pool QuakeSpell_DrawFirstGroundBolts:
    {
        ; \task name all of these??? I dunno.
    
    .
        db $00, $F0, $00
    
    .
        db $00, $F0, $01
    
    .
        db $00, $F0, $02
    
    .
        db $00, $F0, $03
    
    .
        db $00, $F0, $43
    
    .
        db $00, $F0, $42
    
    .
        db $00, $F0, $41
    
    .
        db $00, $F0, $40
    
    ; 6
        db $00, $F0, $40
        db $0E, $F8, $84
    
    ; 6
        db $1D, $F8, $44
        db $0D, $F9, $84
    
    ; 6
        db $1F, $F9, $44
        db $2F, $FC, $84
    
    ; 9
        db $31, $F5, $06
        db $3F, $FB, $44
        db $2F, $FC, $84
    
    ; 12
        db $24, $EF, $08
        db $31, $F5, $06
        db $3F, $FB, $44
        db $4E, $04, $08
    
    ; 12
        db $16, $E1, $08
        db $24, $EF, $08
        db $4E, $04, $08
        db $5D, $14, $08
    
    ; 15
        db $07, $D2, $08
        db $17, $D3, $48
        db $16, $E1, $08
        db $5D, $14, $08
        db $5D, $24, $48
     
     ; 18
        db $F9, $C3, $08
        db $25, $C5, $48
        db $07, $D2, $08
        db $17, $D3, $48
        db $5D, $24, $48
        db $5D, $34, $08
    
    ; 18
        db $EA, $B5, $08
        db $2F, $B6, $01
        db $F8, $C3, $08
        db $24, $C4, $48
        db $5D, $34, $08
        db $6C, $43, $08
    
    ; 18
        db $DB, $A6, $08
        db $EA, $B5, $08
        db $2F, $B6, $01
        db $3B, $C2, $81
        db $6C, $43, $08
        db $79, $50, $08
    
    ; 15
        db $D4, $98, $C9
        db $DB, $A6, $08
        db $49, $B6, $48
        db $3B, $C2, $81
        db $79, $50, $08
    
    ; 12
        db $D4, $88, $09
        db $D4, $98, $C9
        db $57, $A7, $48
        db $49, $B6, $48
    
    ; 9
        db $D4, $88, $09
        db $66, $98, $48
        db $57, $A7, $48
    
    ; 6
        db $66, $98, $48
        db $57, $A7, $48
    
    ; 6
        db $70, $8C, $48
        db $66, $98, $48
    
    ; 3
        db $70, $8C, $48
    
    ; 3
        db $F3, $F0, $00
    
    ; 3
        db $F3, $F0, $01
    
    ; 3
        db $F3, $F0, $02
    
    ; 3
        db $F3, $F0, $03
    
    ; 3
        db $F5, $F0, $43
    
    ; 3
        db $F5, $F0, $42
    
    ; 3
        db $F5, $F0, $41
    
    ; 3
        db $F5, $F0, $40
        db $E8, $F6, $04
        db $DA, $EE, $08
        db $E8, $F6, $04
        db $D8, $F9, $C4
        db $D3, $DF, $C9
        db $DA, $EE, $08
        db $C7, $F9, $04
        db $D8, $F9, $C4
        db $D0, $D3, $07
        db $D3, $DF, $C9
        db $C7, $F9, $04
        db $B9, $02, $48
        db $D0, $D3, $06
        db $B9, $02, $48
        db $BA, $12, $08
        db $D0, $D3, $05
        db $BA, $12, $08
        db $C8, $21, $08
        db $D0, $D3, $07
        db $CA, $22, $08
        db $CA, $31, $88
        db $D0, $D3, $06
        db $CA, $31, $88
        db $BB, $40, $88
        db $D0, $D3, $07
        db $BB, $40, $88
        db $AB, $49, $C4
        db $D0, $D3, $05
        db $9B, $49, $04
        db $AB, $49, $C4
        db $C4, $CB, $08
        db $D0, $D3, $06
        db $9B, $49, $04
        db $8C, $4D, $C4
        db $B5, $BD, $08
        db $C4, $CB, $08
        db $80, $4C, $04
        db $8C, $4D, $C4
        db $A6, $AE, $08
        db $B5, $BD, $08
        db $80, $4C, $04
        db $97, $9F, $08
        db $A6, $AE, $08
        db $88, $91, $08
        db $97, $9F, $08
        db $88, $91, $08
        db $00, $FB, $0A
        db $00, $FB, $0B
        db $02, $FD, $0C
        db $01, $FD, $0D
        db $00, $FD, $8D
        db $01, $FD, $8C
        db $01, $FD, $8B
        db $01, $FD, $8A
        db $FA, $0C, $89
        db $FA, $0C, $89
        db $F6, $1C, $C9
        db $F6, $1C, $49
        db $F8, $2C, $89
        db $F8, $2C, $89
        db $F6, $38, $02
        db $F6, $38, $02
        db $E9, $46, $48
        db $05, $46, $08
        db $E9, $46, $48
        db $05, $46, $08
        db $DA, $55, $48
        db $13, $55, $08
        db $DA, $55, $48
        db $13, $55, $08
        db $CC, $63, $48
        db $21, $65, $08
        db $CC, $63, $48
        db $21, $65, $08
        db $BE, $71, $48
        db $2F, $73, $08
        db $BE, $71, $48
        db $2F, $73, $08
        db $A0, $70, $20
        db $A0, $70, $21
        db $A0, $70, $66
        db $A0, $70, $22
        db $A0, $70, $23
        db $A0, $70, $63
        db $A0, $70, $62
        db $A0, $70, $26
        db $A0, $70, $27
        db $AA, $7C, $28
        db $AA, $7C, $28
        db $B8, $8B, $28
        db $B8, $8B, $28
        db $C5, $9A, $A1
        db $C5, $9A, $A1
        db $D4, $8C, $68
        db $D4, $8C, $68
        db $E3, $7E, $68
        db $E3, $7E, $68
        db $ED, $7D, $C5
        db $90, $60, $2A
        db $90, $60, $2B
        db $90, $60, $2C
        db $90, $60, $2D
        db $89, $52, $29
        db $90, $60, $2A
        db $85, $42, $E9
        db $89, $52, $29
        db $87, $32, $29
        db $85, $42, $E9
        db $7E, $22, $28
        db $8D, $22, $68
        db $87, $32, $29
        db $96, $12, $A9
        db $6F, $13, $28
        db $7E, $22, $28
        db $8D, $22, $68
        db $9C, $02, $68
        db $66, $04, $E9
        db $96, $12, $A9
        db $6F, $13, $28
        db $A5, $F2, $A9
        db $5F, $F5, $28
        db $9C, $02, $68
        db $66, $04, $E9
        db $60, $70, $60
        db $60, $70, $61
        db $60, $70, $26
        db $60, $70, $62
        db $60, $70, $63
        db $60, $70, $23
        db $60, $70, $22
        db $60, $70, $66
        db $55, $6F, $E8
        db $60, $70, $67
        db $46, $68, $24
        db $55, $6F, $E8
        db $46, $68, $24
        db $36, $6C, $E4
        db $28, $64, $28
        db $26, $6B, $24
        db $36, $6C, $E4
        db $19, $55, $28
        db $28, $64, $28
        db $26, $6B, $24
        db $16, $6E, $E4
        db $0B, $46, $28
        db $19, $55, $28
        db $07, $6C, $24
        db $16, $6E, $E4
        db $0B, $46, $28
        db $07, $6C, $24
        db $70, $70, $2A
        db $70, $70, $2B
        db $70, $70, $2C
        db $70, $70, $2D
        db $70, $70, $2A
        db $6C, $7D, $29
        db $6C, $7D, $29
        db $72, $8C, $28
        db $72, $8C, $28
        db $7C, $9C, $29
        db $7C, $9C, $29
        db $7B, $AC, $E9
        db $7B, $AC, $E9
        db $75, $B6, $E4
        db $84, $BB, $28
        db $75, $B6, $E4
        db $84, $BB, $28
        db $67, $BD, $68
        db $92, $CA, $28
        db $67, $BD, $68
        db $92, $CA, $28
        db $5F, $CC, $69
        db $9A, $D9, $29
        db $5F, $CC, $69
        db $9A, $D9, $29
        db $60, $DC, $E9
        db $9A, $E8, $E9
        db $60, $DC, $E9
        db $9A, $E8, $E9
        db $85, $F2, $29
        db $8D, $F2, $2E
        db $31, $F4, $28
    }

; ==============================================================================

    ; \task Label these arrays and pointers.
    ; Was gonna be critical, but this is ridiculous and unexpected how much
    ; work it was going to be naming these and making sense of the pointers
    ; and vast amount of data.
        
    ; $47EEA-$47FDA DATA
    pool QuakeSpell_DrawFirstGroundBolts:
    {
    
    .pointers
        dw $FBED, $FBF0, $FBF3, $FBF6, $FBF9, $FBFC, $FBFF, $FC02
        dw $FC05, $FC0B, $FC11, $FC17, $FC20, $FC2C, $FC38, $FC47
        dw $FC59, $FC6B, $FC7D, $FC8C, $FC98, $FCA1, $FCA7, $FCAD
        dw $FCB0, $FCB3, $FCB6, $FCB9, $FCBC, $FCBF, $FCC2, $FCC5
        dw $FCCB, $FCD4, $FCE0, $FCEC, $FCF5, $FCFE, $FD07, $FD10
        dw $FD19, $FD22, $FD2E, $FD3A, $FD43, $FD49, $FD4F, $FD52
        dw $FD55, $FD58, $FD5B, $FD5E, $FD61, $FD64, $FD67, $FD6D
        dw $FD73, $FD79, $FD7F, $FD88, $FD94, $FDA0, $FDAC, $FDB2
    }
    
    pool QuakeSpell_DrawGroundBolts:
    {
    
    .pointers
        dw $FDB2, $FDB5, $FDB8, $FDBB, $FDBE, $FDC1, $FDC4, $FDC7
        dw $FDCA, $FDD0, $FDD6, $FDDC, $FDE2, $FDE8, $FDEB, $FDEE
        dw $FDF1, $FDF4, $FDF7, $FDFA, $FE00, $FE06, $FE0C, $FE15
        dw $FE21, $FE2D, $FE39, $FE3C, $FE3F, $FE42, $FE45, $FE48
        dw $FE4B, $FE4E, $FE51, $FE57, $FE5D, $FE63, $FE6C, $FE78
        dw $FE84, $FE8A, $FE8D, $FE90, $FE93, $FE96, $FE9C, $FEA2
        dw $FEA8, $FEAE, $FEB7, $FEC3, $FECF, $FEDB, $FEE1, $FEEA
    }

; ==============================================================================

    ; $47FDB-$47FFF NULL
    {
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FF
    }
