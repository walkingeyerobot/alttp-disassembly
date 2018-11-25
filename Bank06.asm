
; ==============================================================================

    ; *$30000-$30044 LONG
    BottleVendor_DetectFish:
    {
        PHB : PHK : PLB
        
        LDY.b #$0F
    
    .nextSprite
    
        LDA $0DD0, Y : BEQ .inactiveSprite
        
        ; Literally!
        LDA $0E20, Y : CMP.b #$D2 : BEQ .isFishOutOfWater
    
    .inactiveSprite
    
        DEY : BPL .nextSprite
        
        PLB
        
        RTL
    
    .isFishOutOfWater
    
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $08
        LDA.b #$10   : STA $02
        
        LDA $0D00, X : STA $01
        LDA $0D20, X : STA $09
        LDA.b #$10   : STA $03
        
        PHX : TYX
        
        JSR Sprite_SetupHitBox
        
        PLX
        
        JSR Utility_CheckIfHitBoxesOverlap : BCC .delta
        
        ; If the fish is close enough to the merchant, indicate as such.
        TYA : ORA.b #$80 : STA $0E90, X
    
    .delta
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $30044-$30053 DATA
    pool BottleVendor_SpawnFishRewards:
    {
    
    .x_speeds
        db $FA, $FD, $00, $04, $07
        
    .y_speeds
        db $0B, $0E, $10, $0E, $0B
    
    .item_types
        db $DB, $E0, $DE, $E2, $D9
    }

; ==============================================================================

    ; *$30054-$3009E LONG
    BottleVendor_SpawnFishRewards:
    {
        ; Only used by the bottle vendor...
        ; I think this spawns the items he gives you in the
        ; event that you give him a fish?
        
        PHB : PHK : PLB
        
        LDA.b #$13 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$04 : STA $0FB5
    
    .nextItem
    
        LDY $0FB5
        
        LDA .item_types, Y : JSL Sprite_SpawnDynamically : BMI .spawnFailed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $00 : ADD.b #$04 : STA $0D10, Y
        
        LDA.b #$FF : STA $0B58, Y
        
        PHX
        
        LDX $0FB5
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA.b #$20 : STA $0F80, Y : STA $0F10, Y
        
        PLX
    
    .spawnFailed
    
        DEC $0FB5 : BPL .nextItem
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \wtf When the boomerang is off camera and still in play, it dramatically
    ; speeds up to catch up to the player. This was confirmed by setting
    ; the 0x70 and 0x90 values in this routine to much lower values and
    ; dashing away after throwing the boomerang. It took about 2 minutes
    ; for the boomerang to get back to the player, but when it finally
    ; appeared on screen it moved at its normal speed.
    ; Anyways, this routine overrides the values set by
    ; Ancilla_ProjectSpeedTowardsPlayer when the boomerang is out of
    ; view.
    ; *$3009F-$300E5 LONG
    Boomerang_CheatWhenNoOnesLooking:
    {
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        LDA $0BFA, X : STA $04
        LDA $0C0E, X : STA $05
        
        REP #$20
        
        LDY.b #$70
        
        LDA $22 : SUB $02 : ADD.w #$00F0 : CMP.w #$01E0 : BPL .too_far_x
        
        ; Note: this is the negative version of 0x70
        LDY.b #$90
    
    .too_far_x
    
        BCC .close_enough_x
        
        STY $01
        
        BRA .return
    
    .close_enough_x
    
        LDY.b #$70
        
        LDA $20 : SUB $04 : ADD.w #$00F0 : CMP.w #$01E0 : BPL .too_far_y
        
        LDY.b #$90
    
    .too_far_y
    
        BCC .close_enough_y
        
        STY $00
    
    .close_enough_y
    .return
    
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; $300E6-$300F9 DATA
    pool Player_ApplyRumbleToSprites:
    {
    
    .x_offsets_low
        db -32, -32, -32, 16
        
    .y_offsets_low
        db -32, 32, -24, -24
        
    .y_offsets_high
        db -1, 0
        
    .x_offsets_high
        db -1, -1, -1, 0
    
    ; $300F4
        db 80, 80
        
    ; $300F6
        db 32, 32, 80, 80
        
    }

; ==============================================================================

    ; *$300FA-$3012C LONG
    Player_ApplyRumbleToSprites:
    {
        ; Grabs Link's coordinates plus an offset determined by his direction
        ; and stores them to direct page locations.
        
        PHB : PHK : PLB
        
        LDA $2F : LSR A : TAY
        
        LDA $22 : ADD .x_offsets_low,  Y : STA $00
        LDA $23 : ADC .x_offsets_high, Y : STA $08
        
        LDA $20 : ADC .y_offsets_low,  Y : STA $01
        LDA $21 : ADC .y_offsets_high, Y : STA $09
        
        LDA $80F4, Y : STA $02
        LDA $80F6, Y : STA $03
        
        JSR Entity_ApplyRumbleToSprites
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3012D-$3014A LONG
    Sprite_SpawnImmediatelySmashedTerrain:
    {
        LDY $0314 : PHY
        LDY $0FB2 : PHY
        
        PHB : PHK : PLB
        
        JSL Sprite_SpawnThrowableTerrainSilently : BMI .spawn_failed
        
        JSR $E239 ; $36239 IN ROM
    
    .spawn_failed
    
        PLB
        
        PLA : STA $0FB2
        PLA : STA $0314
        
        RTL
    }

; ==============================================================================

    ; *$3014B-$301F3 LONG
    Sprite_SpawnThrowableTerrain:
    {
        ; This routine is called when you pick up a bush/pot/etc.
        ; A =   0 - sign 
        ;       1 - small light rock
        ;       2 - normal bush / pot
        ;       3 - thick grass
        ;       4 - off color bush
        ;       5 - small heavy rock
        ;       6 - large light rock
        ;       7 - large heavy rock
        
        PHA
        
        JSL Sound_SetSfxPanWithPlayerCoords
        
        ORA.b #$1D : STA $012E
        
        PLA
    
    ; *$30156 ALTERNATE ENTRY POINT
    shared Sprite_SpawnThrowableTerrainSilently:
    
        LDX.b #$0F
    
    .next_slot
    
        ; look for dead sprites
        LDY $0DD0, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        ; can't find any slots so don't do any animation
        RTL
    
    .empty_slot
    
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        PHA
        
        LDA.b #$0A : STA $0DD0, X
        
        ; Make a bush/pot/etc. sprite appear
        LDA.b #$EC : STA $0E20, X
        
        LDA $00 : STA $0D10, X
        LDA $01 : STA $0D30, X
        
        LDA $02 : STA $0D00, X
        LDA $03 : STA $0D20, X
        
        JSL Sprite_LoadProperties
        
        ; Set the floor level to whichever the player is on.
        LDA $EE : STA $0F20, X
        
        PLA : STA $0DB0, X : CMP.b #$06 : BCC .not_heavy_object
        
        PHA
        
        LDA.b #$A6 : STA $0E40, X
        
        PLA
    
    .not_heavy_object
    
        CMP.b #$02 : BNE .notBushOrPot
        
        LDA $1B : BEQ .outdoors
        
        ; This doesn't seem to do anything because it gets overwritten just
        ; a few lines down anyways!
        LDA.b #$80 : STA $0F50, X
    
    .notBushOrPot
    .outdoors
    
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        PHB : PHK : PLB
        
        TAY
        
        LDA $AACA, Y : STA $0F50, X
        
        LDA.b #$09 : STA $7FFA2C, X
        
        LDA.b #$02 : STA $0314
                     STA $0FB2
        
        LDA.b #$10 : STA $0DF0, X
        
        LDA $EE : STA $0F20, X
        
        STZ $0DC0, X
        
        LDA $0B9C : CMP.b #$FF : BEQ .invalid_secret
        
        ORA $1B : BNE .dont_substitute
        
        LDA $0DB0, X : DEC #2 : CMP.b #$02 : BCC .dont_substitute
        
        JSL Overworld_SubstituteAlternateSecret
    
    .dont_substitute
    
        LDA $0B9C : BPL .normal_secret
        
        AND.b #$7F : STA $0DC0, X
        
        STZ $0B9C
    
    .normal_secret
    
        JSR Sprite_SpawnSecret
    
    .invalid_secret
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$30262-$30327 BRANCH LOCATION
    pool Sprite_SpawnSecret:
    {
    
    .easy_out
    
        CLC
        
        RTS
    
    ; *$30264 MAIN ENTRY POINT
    Sprite_SpawnSecret:
    
        LDA $1B : BNE .indoors
        
        JSL GetRandomInt : AND.b #$08 : BNE .easy_out
    
    .indoors
    
        LDY $0B9C  : BEQ .easy_out
        CPY.b #$04 : BNE .not_random
        
        JSL GetRandomInt : AND.b #$03 : ADD.b #$13 : TAY
    
    .not_random
    
        STY $0D
        
        ; List of sprites that can be spawned by secrets
        LDA $81F3, Y : BEQ .easy_out
        
        JSL Sprite_SpawnDynamically : BMI .easy_out
        
        PHX
        
        LDX $0D
        
        LDA $8209, X : STA $0D80, Y
        LDA $8235, X : STA $0BA0, Y
        LDA $824B, X : STA $0F80, Y
        
        LDA $00 : ADD $821F, X : STA $0D10, Y
        LDA $01 : ADC.b #$00   : STA $0D30, Y
        
        LDA $02 : STA $0D00, Y
        LDA $03 : STA $0D20, Y
        
        LDA $04 : STA $0F70, Y
        
        LDA.b #$00 : STA $0DC0, Y
        LDA.b #$20 : STA $0F10, Y
        LDA.b #$30 : STA $0E10, Y
        
        LDX $0E20, Y : CPX.b #$E4 : BNE .not_key
        
        PHX
        
        TYX
        
        JSR $9262 ; $31262 IN ROM
        
        PLX
    
    .not_key
    
        CPX.b #$0B : BNE .not_chicken
        
        ; Make a chicken noise
        LDA #$30 : STA $012E
        
        LDA $048E : CMP.b #$01 : BNE BRANCH_DELTA
        
        STA $0E30, Y
    
    BRANCH_DELTA:
    .not_chicken
    
        CPX.b #$42 : BEQ .is_soldier
        CPX.b #$41 : BEQ .is_soldier
        CPX.b #$3E : BNE .not_rock_crab
        
        LDA.b #$09 : STA $0F50, Y
        
        BRA .return
    
    .is_soldier
    
        ; Play the "pissed off soldier" sound effect
        LDA.b #$04 : STA $012F
        
        LDA.b #$00 : STA $0CE2, Y
        
        LDA.b #$A0 : STA $0EF0, Y
        
        BRA .carry_on
    
    .not_rock_crab
    
        LDA.b #$FF : STA $0B58, Y
    
    .carry_on
    
        CPX.b #$79 : BNE .return
        
        LDA.b #$20 : STA $0D90, Y
    
    .return
    
        SEC
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $30328-$303C1 LONG
    Sprite_Main:
    {
        ; ARE WE INDOORS
        LDA $1B : BNE .indoors
        
        STZ $0C7C : STZ $0C7D : STZ $0C7E : STZ $0C7F
        STZ $0C80
        
        ; Looks like this might load or unload sprites as we scroll during
        ; the overworld... Not certain of this yet.
        JSL Sprite_RangeBasedActivation
    
    .indoors
    
        PHB : PHK : PLB
        
        LDY.b #$00
        
        LDA $7EF3CA : BEQ .in_light_world
        
        ; $7E0FFF = 0 if in LW, 1 otherwise
        INY
    
    .in_light_World
    
        ; Darkworld/Lightworld indicator
        STY $0FFF
        
        LDA $11 : BNE .dont_reset_player_dragging
        
        ; \wtf Wait, so the dragging of the player is reset under normal
        ; circumstances, but not in another submodule? Does not compute.
        STZ $0B7C
        STZ $0B7D
        
        STZ $0B7E
        STZ $0B7F
    
    .dont_reset_player_dragging
    
        JSR Oam_ResetRegionBases
        JSL Garnish_ExecuteUpperSlotsLong
        JSL Tagalong_MainLong
        
        LDA $0314 : STA $0FB2
        
        STZ $0314
        
        LDA.b #$80 : STA $0FAB
        
        ; Is this a delay counter between repulse sparks for sprites?
        LDA $47 : AND.b #$7F : BEQ .done_counting
        
        DEC $47
        
        BRA .still_counting
    
    .done_counting
    
        STZ $47
    
    .still_counting
    
        STZ $0379
        STZ $0377
        STZ $037B
        
        LDA $0FDC : BEQ .projectileCounterDone
        
        DEC $0FDC
    
    .projectileCounterDone
    
        JSL Ancilla_Main
        JSL Overlord_Main
        
        STZ $0B9A
        
        LDX.b #$0F
    
    .next_sprite
    
        STX $0FA0
        
        JSR Sprite_ExecuteSingle
        
        DEX : BPL .next_sprite
        
        JSL Garnish_ExecuteLowerSlotsLong
        
        STZ $069F
        STZ $069E
        
        PLB
        
        JSL CacheSprite_ExecuteAll
        
        LDA $0AAA : BEQ .iota
        
        STA $0FC6
    
    .iota
    
        RTL
    }

; ==============================================================================

    ; $303C2-$303C6 LONG
    EasterEgg_BageCodeTrampoline:
    {
        ; \tcrf Already mentioned on tcrf, but I'm pretty sure they got that
        ; material from me, as some guy in IRC was asking about it around
        ; the time it went up on the wiki.
        ; Anyways, this code is confirmed to work, but is not accessible
        ; in an unmodified game. A hook would have to be inserted somewhere
        ; to call this.
        
        JSL EasterEgg_BageCode
        
        RTL
    }

; ==============================================================================

    ; $303C7-$303D2 DATA
    pool Oam_ResetRegionBases:
    {
    
    .bases
        db $0030, $01D0, $0000, $0030, $0120, $0140
    }

; ==============================================================================

    ; \note Appears to reset oam regions every frame that the sprite
    ; handlers are active. Whether these are just for sprites themselves
    ; and not object handlers, I dunno.
    ; *$303D3-$303E5 LOCAL
    Oam_ResetRegionBases:
    {
        LDY.b #$00
        
        REP #$20
    
    .next_oam_region
    
        LDA .bases, Y : STA $0FE0, Y
        
        INY #2 : CPY.b #$0B : BCC .next_oam_region
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$303E6-$303E9 LONG
    Utility_CheckIfHitBoxesOverlapLong:
    {
        JSR Utility_CheckIfHitBoxesOverlap
        
        RTL
    }

; ==============================================================================

    ; *$303EA-$303F1 LONG
    Sprite_SetupHitBoxLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_SetupHitBox
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$303F2-$304BC LOCAL
    {
        JSR Sprite_Get_16_bit_Coords
        
        LDA $0E40, X : AND.b #$1F : INC A : ASL #2
        
        LDY $0FB3 : BEQ .dontSortSprites
        
        LDY $0F20, X : BEQ .onBG2
        
        JSL OAM_AllocateFromRegionF : BRA .doneAllocatingOamSlot
    
    .onBG2
    
        JSL OAM_AllocateFromRegionD : BRA .doneAllocatingOamSlot
    
    .dontSortSprites
    
        JSL OAM_AllocateFromRegionA
    
    .doneAllocatingOamSlot
    
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ; checking for oddball modes
        ; typically branches along this path
        LDA $11 : ORA $0FC1 : BEQ .normalGameMode
        
        JMP $84A4 ; $304A4 IN ROM
    
    .normalGameMode
    
        ; this section decrements the sprite's 4 general purpose timers (if nonzero)
        LDA $0DF0, X : BEQ .timer_0_expired
        
        DEC $0DF0, X
    
    .timer_0_expired
    
        LDA $0E00, X : BEQ .timer_1_expired
        
        DEC $0E00, X
    
    .timer_1_expired
    
        LDA $0E10, X : BEQ .timer_2_expired
        
        DEC $0E10, X
    
    .timer_2_expired
    
        LDA $0EE0, X : BEQ .timer_3_expired
        
        DEC $0EE0, X
    
    .timer_3_expired
    
        LDA $0EF0, X : AND.b #$7F : BEQ .death_timer_inactive
        
        LDY $0DD0, X : CPY.b #$09 : BCC .sprite_inactive
        
        ; on the 0x1F tick of the damage timer we...
        CMP.b #$1F : BNE BRANCH_MU
        
        PHA
        
        ; Is the sprite Agahnim?
        LDA $0E20, X : CMP.b #$7A : BNE .not_agahnim_bitching
        
        ; branch if in the dark world
        LDA $0FFF : BNE .not_agahnim_bitching
        
        ; subtract off damage from agahnim
        LDA $0E50, X : SUB $0CE2, X : BEQ .agahnim_bitches
                                      BCS .not_agahnim_bitching
    
    .agahnim_bitches
    
        ; Agahnim bitching about you beating him in the Light world
        LDA.b #$40 : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
    
    .not_agahnim_bitching
    
        PLA
    
    BRANCH_MU:
    
        CMP.b #$18 : BNE BRANCH_LAMBDA
        
        JSR $EEC8 ; $36EC8 IN ROM
    
    BRANCH_LAMBDA:
    .sprite_inactive
    
        LDA $0CE2, X : CMP.b #$FB : BCS BRANCH_XI
        
        LDA $0EF0, X : ASL A : AND.b #$0E : STA $0B89, X
    
    BRANCH_XI:
    
        DEC $0EF0, X
        
        BRA BRANCH_OMICRON
    
    .death_timer_inactive
    
        STZ $0EF0, X
        STZ $0B89, X
    
    BRANCH_OMICRON:
    
        LDA $0F10, X : BEQ .aux_timer_4_expired
        
        DEC $0F10, X
    
    .aux_timer_4_expired
    
    ; *$304A4 ALTERNATE ENTRY POINT
    
        ; \wtf Interesting.... if player priority is super priority, all sprites
        ; follow? \task Investigate this.
        LDY $EE : CPY.b #$03 : BEQ .player_using_super_priority
        
        LDY $0F20, X
    
    .player_using_super_priority
    
        LDA $0B89, X : AND.b #$CF : ORA .priority, Y : STA $0B89, X
        
        RTS
    
    .priority
        db $20, $10, $30, $30
    }

; ==============================================================================

    ; *$304BD-$304C0 LONG
    Sprite_Get_16_bit_CoordsLong:
    {
        JSR Sprite_Get_16_bit_Coords
        
        RTL
    }

; ==============================================================================

    ; *$304C1-$304D9 LOCAL
    Sprite_Get_16_bit_Coords:
    {
        ; $0FD8 = sprite's X coordinate, $0FDA = sprite's Y coordinate
        LDA $0D10, X : STA $0FD8
        LDA $0D30, X : STA $0FD9
        
        LDA $0D00, X : STA $0FDA
        LDA $0D20, X : STA $0FDB
        
        RTS
    }

; ==============================================================================

    ; *$304DA-$304E1 LON
    Sprite_ExecuteSingleLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_ExecuteSingle
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$304E2-$30525 LOCAL
    Sprite_ExecuteSingle:
    {
        LDA $0DD0, X : BEQ .inactiveSprite
        
        PHA
        
        JSR $83F2 ; $303F2 IN ROM; Loads some sprite data into common addresses.
        
        PLA
        
        CMP.b #$09 : BEQ .activeSprite
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        ; index is $0DD0, X
        dw .inactiveSprite       ; 0x00 - Sprite is totally inactive
        dw SpriteFall_Main       ; 0x01 - sprite is falling into a hole
        dw SpritePoof_Main       ; 0x02 - Frozen Sprite being smashed by hammer, and pooferized, perhaps into a nice magic refilling item.
        dw SpriteDrown_Main      ; 0x03 - Sprite has fallen into deep water, may produce a fish
        dw SpriteExplode_Main    ; 0x04 - Explodey Mode for bosses?
        dw SpriteCustomFall_Main ; 0x05 - Sprite falling into a hole but that has a special animation (e.g. soldiers and hard hat beetles)
        dw SpriteDeath_Main      ; 0x06 - Death mode for normal creatures.
        dw SpriteBurn_Main       ; 0x07 - Being incinerated? (By Fire Rod)
        dw SpritePrep_Main       ; 0x08 - A spawning sprite
        dw SpriteActive_Main     ; 0x09 - An active sprite
        dw SpriteHeld_Main       ; 0x0A - sprite is being held above Link's head
        dw SpriteStunned_Main    ; 0x0B - sprite is frozen and immobile
    
    .activeSprite
    
        JMP SpriteActive_Main
    
    ; 3050F ALTERNATE ENTRY POINT
    shared SpritePrep_ThrowableScenery:
    
        ; Why the hell *this* is used as an alternate entry point is beyond
        ; me.
        RTS
    
    ; *$30510 ALTERNATE ENTRY POINT
    .inactiveSprite
    
        LDA $1B : BNE .indoors
        
        TXA : ASL A
        
        LDA.b #$FF : STA $0BC0, Y : STA $0BC1, Y
        
        RTS
    
    .indoors
    
        LDA.b #$FF : STA $0BC0, X
        
        RTS
    }

; ==============================================================================

    ; *$30526-$3052D LONG
    SpriteActive_MainLong:
    {
        PHB : PHK : PLB
        
        JSR SpriteActive_Main
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3052E-$30542 JUMP LOCATION
    SpriteFall_Main:
    {
        ; Sprite mode for falling into a hole
        
        LDA $0DF0, X : BNE .delay
        
        STZ $0DD0, X
        
        JSL Dungeon_ManuallySetSpriteDeathFlag
        
        RTS
    
    .delay
    
        JSR Sprite_PrepOamCoord
        JSL SpriteFall_Draw
        
        RTS
    }

; ==============================================================================

    ; *$30543-$30547 JUMP LOCATION
    SpriteBurn_Main:
    {
        JSL SpriteBurn_Execute
        
        RTS
    }

; ==============================================================================

    ; *$30548-$3054C JUMP LOCATION
    SpriteExplode_Main:
    {
        JSL SpriteExplode_ExecuteLong
        
        RTS
    }

; ==============================================================================

    ; $3054D-$3059B DATA
    pool SpriteDrown_Main:
    {
    
    .oam_groups
        dw -7, -7 : db $80, $04, $00, $00
        dw 14, -6 : db $83, $04, $00, $00
        
        dw -6, -6 : db $CF, $04, $00, $00
        dw 13, -5 : db $DF, $04, $00, $00
        
        dw -4, -4 : db $AE, $04, $00, $00
        dw 12, -4 : db $AF, $44, $00, $00
        
        dw  0,  0 : db $E7, $04, $00, $02
        dw  0,  0 : db $E7, $04, $00, $02
    
    .vh_flip
        db $00, $40, $C0, $80
    
    .chr
        db $C0, $C0, $C0, $C0, $CD, $CD, $CD, $CB
        db $CB, $CB, $CB
    }

; ==============================================================================

    ; *$3059C-$3064C JUMP LOCATION
    SpriteDrown_Main:
    {
        ; Sprite Mode 0x03
        
        LDA $0D80, X : BEQ .alpha
        
        LDA $0D90, X : CMP.b #$06 : BNE BRANCH_BETA
        
        LDA.b #$08 : JSL OAM_AllocateFromRegionC
    
    BRANCH_BETA:
    
        LDA $0E60, X : EOR.b #$10 : STA $0E60, X
        
        JSR Sprite_PrepAndDrawSingleLarge
        
        LDA $0E80, X : LSR #2 : AND.b #$03 : TAY
        
        ; Load hflip and vflip settings
        LDA .vh_flip, Y : STA $05
        
        LDA $0DF0, X : CMP.b #$01 : BNE .notLastTimerTick
        
        STZ $0DD0, X
    
    .notLastTimerTick
    
        PHX
        
        LDA.b #$8A : BCC .timerExpired
        
        LDA $0DF0, X : LSR A : TAX
        
        STZ $05
        
        ; Get address of first tile of the sprite.
        LDA .chr, X
    
    .timerExpired
    
        LDY.b #$02           : STA ($90), Y : INY
        LDA.b #$24 : ORA $05 : STA ($90), Y
        
        PLX
        
        LDA $0DF0, X : BNE BRANCH_EPSILON
        
        JSR Sprite_CheckIfActive.permissive
        
        INC $0E80, X
        
        JSR Sprite_Move
        JSR Sprite_MoveAltitude
        
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        LDA $0F70, X : BPL BRANCH_EPSILON
        
        STZ $0F70, X
        
        LDA.b #$12 : STA $0DF0, X
    
    ; *$30612 ALTERNATE ENTRY POINT
    
        LDA $0E60, X : AND.b #$EF : STA $0E60, X
    
    BRANCH_EPSILON:
    
        RTS
    
    .alpha
    
        JSR Sprite_CheckIfActive.permissive
        
        LDA $1A : AND.b #$01 : BNE BRANCH_ZETA
        
        INC $0DF0, X
    
    BRANCH_ZETA:
    
        STZ $0F50, X
        
        STZ $0EF0, X
        
        LDA.b #$00 : XBA
        
        LDA $0DF0, X : BNE BRANCH_THETA
        
        STZ $0DD0, X
    
    BRANCH_THETA:
    
        REP #$20
        
        ASL A : AND.w #$00F8 : ASL A : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_prep.asm"

; ==============================================================================
    
    ; $31283-$31468 JUMP TABLE
    SpriteActive_Table:
    {
        ; SPRITE ROUTINES 1
        
        ; This is the table for all sprite objects used in the game
        ; PARAMETER $0E20, X
        
        ; This is an unusual jump table. The jump values were fed onto the stack, and an RTS was used to jump there. In the above routine you will notice that the accumulator was decremented (DEC A). That was intentional, since after an RTS, the processor pulls an address off the stack and increments it by one, thereby allowing it to travel to the addresses you see.
        
        !null_ptr = $0000
        
        dw Sprite_RavenTrampoline            ; 0x00 - Raven
        dw Sprite_VultureTrampoline          ; 0x01 - Vulture
        dw Sprite_StalfosHead                ; 0x02 - Flying Stalfos head
        dw !null_ptr                         ; 0x03 - Since this leads to null area, we presume this is unused. i tried using it, it crashed horribly.
        dw Sprite_PullSwitchTrampoline       ; 0x04 - Good switch (down)
        dw Sprite_PullSwitchTrampoline       ; 0x05 - Bad Switch (down)
        dw Sprite_PullSwitchTrampoline       ; 0x06 - Good switch (up)
        dw Sprite_PullSwitchTrampoline       ; 0x07 - Bad switch (up)
        dw Sprite_Octorock                   ; 0x08 - Octorock
        dw Sprite_GiantMoldormTrampoline     ; 0x09 - Giant Moldorm
        dw Sprite_Octorock                   ; 0x0A - Four Shooter Octorock
        dw Sprite_Chicken                    ; 0x0B - Chicken / Chicken -> Lady transformation
        dw Sprite_Octostone                  ; 0x0C - Rock projectile that Octorocks shoot
        dw Sprite_Buzzblob                   ; 0x0D - Buzzblob
        dw Sprite_SnapDragon                 ; 0x0E - Plants with big mouths (Dark World)
        dw Sprite_Octoballoon                ; 0x0F - Octoballoon (aka Exploder?)
        dw Sprite_Octospawn                  ; 0x10 - Small things from the exploder
        dw Sprite_Hinox                      ; 0x11 - Hinox
        dw Sprite_Moblin                     ; 0x12 - Moblin
        dw Sprite_Helmasaur                  ; 0x13 - Helmasaur
        dw Sprite_GargoyleGrateTrampoline    ; 0x14 - Gargoyle's Domain Entrance
        dw Sprite_Bubble                     ; 0x15 - Fire Faerie?
        dw Sprite_ElderTrampoline            ; 0x16 - Sahasralah / Aginah
        dw Sprite_CoveredRupeeCrab           ; 0x17 - Rupee Crab under bush
        dw Sprite_Moldorm                    ; 0x18 - Moldorm
        dw Sprite_Poe                        ; 0x19 - Poe
        dw Sprite_SmithyBros                 ; 0x1A - Smithy bros.
        dw Sprite_EnemyArrow                 ; 0x1B - Arrow in wall.
        dw Sprite_MovableStatue              ; 0x1C - Movable Statue
        dw Sprite_WeathervaneTrigger         ; 0x1D - Weathervane Sprite (Useless?)
        dw Sprite_CrystalSwitch              ; 0x1E - Crystal Switches for orange/blue barriers
        dw Sprite_BugNetKid                  ; 0x1F - Sick kid who gives Link the Bug catching net
        dw Sprite_Sluggula                   ; 0x20 - Bomb Slug
        dw Sprite_PushSwitch                 ; 0x21 - Water palace push switch
        dw Sprite_Ropa                       ; 0x22 - Ropa
        dw Sprite_RedBari                    ; 0x23 - Bari (Red)
        dw Sprite_BlueBari                   ; 0x24 - Bari (Blue)
        dw Sprite_TalkingTreeTrampoline      ; 0x25 - Talking Tree
        dw Sprite_HardHatBeetle              ; 0x26 - Hard hat Beetle
        dw Sprite_DeadRock                   ; 0x27 - Deadrock
        dw Sprite_StoryTeller_1              ; 0x28 - Story Teller NPCs
        dw Sprite_HumanMulti_1_Trampoline    ; 0x29 - Guy in Blind's Old Hideout / Thieves Hideout Guy / Flute Boy's Father
        dw Sprite_SweepingLadyTrampoline     ; 0x2A - Sweeping lady
        dw Sprite_HoboEntities               ; 0x2B - Hobo under bridge (and helper sprites)
        dw Sprite_LumberjacksTrampoline      ; 0x2C - Lumberjack Bros.
        dw Sprite_UnusedTelepathTrampoline   ; 0x2D - Telepathic stones? (wtf does this name mean?)
        dw Sprite_FluteBoy                   ; 0x2E - Flute boy, and his notes?
        dw Sprite_MazeGameLadyTrampoline     ; 0x2F - Heart piece race guy / girl
        dw Sprite_MazeGameGuyTrampoline      ; 0x30 - Maze Game Guy
        dw Sprite_FortuneTellerTrampoline    ; 0x31 - Fortune Teller / Dwarf Swordsmith
        dw Sprite_QuarrelBrosTrampoline      ; 0x32 - Quarreling Brothers
        dw Sprite_PullForRupeesTrampoline    ; 0x33 - Rupee prizes hidden in walls.
        dw Sprite_YoungSnitchLadyTrampoline  ; 0x34 - Young Snitch Lady
        dw Sprite_InnKeeperTrampoline        ; 0x35 - Inn Keeper
        dw Sprite_WitchTrampoline            ; 0x36 - Witch?
        dw Sprite_WaterfallTrampoline        ; 0x37 - Waterfall sprite
        dw Sprite_ArrowTriggerTrampoline     ; 0x38 - Arrow trigger
        dw Sprite_MiddleAgedMan              ; 0x39 - Middle aged man in the desert.
        dw Sprite_MadBatterTrampoline        ; 0x3A - Magic Powder bat / lightning bolt he throws
        dw Sprite_DashItemTrampoline         ; 0x3B - Dash item (book of mudora / etc)
        dw Sprite_TroughBoyTrempoline        ; 0x3C - TroughBoy
        dw Sprite_OldSnitchLadyTrampoline    ; 0x3D - Scared ladies and chicken lady, maybe others.
        dw Sprite_CoveredRupeeCrab           ; 0x3E - Rupee Crab under rock
        dw Sprite_TutorialEntitiesTrampoline ; 0x3F - Tutorial Soldier
        dw Sprite_TutorialEntitiesTrampoline ; 0x40 - Hyrule Castle Barrier
        dw SpriteActive2_Trampoline          ; 0x41 - Blue Soldier
        dw SpriteActive2_Trampoline          ; 0x42 - Green Soldier
        dw SpriteActive2_Trampoline          ; 0x43 - 
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline ; 0x48 - Red Spear Soldier (in special armor)
        dw SpriteActive2_Trampoline ; 0x49 - Red Spear Soldier (in bushes)
        dw SpriteActive2_Trampoline ; 0x4A - Green Enemy Bomb
        dw SpriteActive2_Trampoline ; 0x4B - Green Soldier (weak version)
        dw SpriteActive2_Trampoline ; 0x4C - Sand monster
        dw SpriteActive2_Trampoline ; 0x4D - Bunnies in tall grass / on ground
        dw SpriteActive2_Trampoline ; 0x4E - Popo (aka Snakebasket)
        dw SpriteActive2_Trampoline ; 0x4F - Blobs?
        dw SpriteActive2_Trampoline ; 0x50 - Metal balls in Eastern Palace
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline ; 0x53 - Armos Knight
        dw SpriteActive2_Trampoline ; 0x54 - 
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline ; 0x57 - Desert Palace barriers
        dw SpriteActive2_Trampoline ; 0x58 - Crab
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline ; 0x60 - Roller (horizontal)
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline ; 0x68 - 
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline ; 0x6D - Rat / Bazu
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline
        dw SpriteActive2_Trampoline      ; 0x70 - 
        dw Sprite_Leever                 ; 0x71 - 
        dw Sprite_WishPond               ; 0x72 - Pond of Wishing (yes you're talking to a pond)
        dw Sprite_UncleAndSageTrampoline ; 0x73 - Uncle / Priest / Sanctury Mantle
        dw Sprite_RunningManTrampoline   ; 0x74 - Scared red hat man
        dw Sprite_BottleVendorTrampoline ; 0x75 - Bottle vendor 
        dw Sprite_ZeldaTrampoline        ; 0x76 - Princess Zelda (not the tagalong version)
        dw Sprite_Bubble                 ; 0x77 - Weird kind of Fire faerie?
        dw Sprite_ElderWifeTrampoline    ; 0x78 - Elder's Wife
        dw SpriteActive3_Transfer        ; 0x79 - 
        dw SpriteActive3_Transfer        ; 0x7A - 
        dw SpriteActive3_Transfer        ; 0x7B - 
        dw SpriteActive3_Transfer        ; 0x7C - 
        dw SpriteActive3_Transfer        ; 0x7D - 
        dw SpriteActive3_Transfer        ; 0x7E - 
        dw SpriteActive3_Transfer        ; 0x7F - 
        dw SpriteActive3_Transfer        ; 0x80 - 
        dw SpriteActive3_Transfer        ; 0x81 - 
        dw SpriteActive3_Transfer        ; 0x82 - 
        dw SpriteActive3_Transfer        ; 0x82 - 
        dw SpriteActive3_Transfer        ; 0x82 - 
        dw SpriteActive3_Transfer        ; 0x85 - Yellow Stalfos
        dw SpriteActive3_Transfer        ; 0x86 - 
        dw SpriteActive3_Transfer        ; 0x87 - 
        dw SpriteActive3_Transfer        ; 0x88 -
        dw SpriteActive3_Transfer        ; 0x89 - 
        dw SpriteActive3_Transfer        ; 0x8A - 
        dw SpriteActive3_Transfer        ; 0x8B - 
        dw SpriteActive3_Transfer        ; 0x8C - 
        dw SpriteActive3_Transfer        ; 0x8D - 
        dw SpriteActive3_Transfer        ; 0x8E - 
        dw SpriteActive3_Transfer        ; 0x8F - 
        dw SpriteActive3_Transfer        ; 0x90 - 
        dw SpriteActive3_Transfer        ; 0x91 - 
        dw SpriteActive3_Transfer        ; 0x92 - 
        dw SpriteActive3_Transfer        ; 0x93 - Bumper
        dw SpriteActive3_Transfer        ; 0x94 - 
        dw SpriteActive3_Transfer        ; 0x95 - 
        dw SpriteActive3_Transfer        ; 0x96 - 
        dw SpriteActive3_Transfer        ; 0x97 - 
        dw SpriteActive3_Transfer        ; 0x98 - 
        dw SpriteActive3_Transfer        ; 0x99 - 
        dw SpriteActive3_Transfer        ; 0x9A - Kyameron
        dw SpriteActive3_Transfer        ; 0x9B - 
        dw SpriteActive3_Transfer        ; 0x9C - 
        dw SpriteActive3_Transfer        ; 0x9D - 
        dw SpriteActive3_Transfer        ; 0x9E - 
        dw SpriteActive3_Transfer        ; 0x9F - 
        dw SpriteActive3_Transfer        ; 0xA0 - 
        dw SpriteActive3_Transfer        ; 0xA1 - 
        dw SpriteActive3_Transfer        ; 0xA2 - 
        dw SpriteActive3_Transfer        ; 0xA3 - 
        dw SpriteActive3_Transfer        ; 0xA4 - 
        dw SpriteActive3_Transfer        ; 0xA5 - 
        dw SpriteActive3_Transfer        ; 0xA6 - 
        dw SpriteActive3_Transfer        ; 0xA7 - 
        dw SpriteActive3_Transfer        ; 0xA8 - Green Bomber (Zirro?)
        dw SpriteActive3_Transfer        ; 0xA9 - Blue Bomber (Zirro?)
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer ; 0xB0 - 
        dw SpriteActive3_Transfer ; 
        dw SpriteActive3_Transfer ; 
        dw SpriteActive3_Transfer ; 
        dw SpriteActive3_Transfer ; 
        dw SpriteActive3_Transfer ; Elephant salesman
        dw SpriteActive3_Transfer ; Kiki the monkey (B6)
        dw SpriteActive3_Transfer ; 
        dw SpriteActive3_Transfer ; 0xB8 - Monologue testing sprite (debug artifact)
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer
        dw SpriteActive3_Transfer ; 0xBB - Shop Keeper / Chest Game Guys
        dw SpriteActive3_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer ; Mystery sprite  "???" in hyrule magic
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer ; 0xC0 - Cranky Lake Monster CrankyLakeMonster
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer ; 0xC8 - Big Faerie
        dw SpriteActive4_Transfer ; 0xC9 - 
        dw SpriteActive4_Transfer ; 0xCA - Chain Chomp
        dw SpriteActive4_Transfer ; 0xCB - 
        dw SpriteActive4_Transfer ; 0xCC - 
        dw SpriteActive4_Transfer ; 0xCD - 
        dw SpriteActive4_Transfer ; 0xCE - Blind
        dw SpriteActive4_Transfer ; 0xCF - Swamola
        dw SpriteActive4_Transfer ; 0xD0 - 
        dw SpriteActive4_Transfer ; Pointer for Yellow hunter
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer
        dw SpriteActive4_Transfer           ; 0xD6 - Pointer for Ganon.
        dw SpriteActive4_Transfer           ; 0xD7 - 
        dw Sprite_HeartRefill               ; 0xD8 - Heart refill
        dw Sprite_GreenRupee                ; 0xD9 - 
        dw Sprite_BlueRupee                 ; 0xDA - 
        dw Sprite_RedRupee                  ; 0xDB - 
        dw Sprite_OneBombRefill             ; 0xDC - 1 Bomb Refill
        dw Sprite_FourBombRefill            ; 0xDD - 4 Bomb Refill
        dw Sprite_EightBombRefill           ; 0xDE - 8 Bomb Refill
        dw Sprite_SmallMagicRefill          ; 0xDF - Small Magic Refill
        dw Sprite_FullMagicRefill           ; 0xE0 - Full Magic Refill
        dw Sprite_FiveArrowRefill           ; 0xE1 - 5 Arrow Refill
        dw Sprite_TenArrowRefill            ; 0xE2 - 10 Arrow Refill
        dw Sprite_Faerie                    ; 0xE3 - Faerie
        dw Sprite_Key                       ; 0xE4 - Key 
        dw Sprite_BigKey                    ; 0xE5 - Big Key
        dw Sprite_ShieldPickup              ; 0xE6 - Shield Pickup (from Pikit)
        dw Sprite_MushroomTrampoline        ; 0xE7 - Mushroom
        dw Sprite_FakeSwordTrampoline       ; 0xE8 - Fake Master Sword
        dw Sprite_PotionShopTrampoline      ; 0xE9 - Magic Shop Dude and his items
        dw Sprite_HeartContainerTrampoline  ; 0xEA - Heart Container
        dw Sprite_HeartPieceTrampoline      ; 0xEB - Heart piece
        dw Sprite_ThrowableScenery          ; 0xEC - pot/bush/etc
        dw Sprite_SomariaPlatformTrampoline ; 0xED - Cane of Somaria Platform
        dw Sprite_MovableMantleTrampoline   ; 0xEE - [pushable] Mantle in throne room
        dw Sprite_SomariaPlatformTrampoline ; 0xEF - Cane of Somaria Platform
        dw Sprite_SomariaPlatformTrampoline ; 0xF0 - Cane of Somaria Platform
        dw Sprite_SomariaPlatformTrampoline ; 0xF1 - Cane of Somaria Platform
        dw Sprite_MedallionTabletTrampoline ; 0xF2 - Medallion Tablet
}

; ==============================================================================

    ; *$31469-$3146D JUMP LOCATION
    Sprite_GiantMoldormTrampoline:
    {
        JSL Sprite_GiantMoldormLong
        
        RTS
    }

; ==============================================================================

    ; *$3146E-$31472 JUMP LOCATION
    Sprite_RavenTrampoline:
    {
        JSL Sprit_RavenLong
        
        RTS
    }

; ==============================================================================

    ; *$31473-$31477 JUMP LOCATION
    Sprite_VultureTrampoline:
    {
        JSL Sprite_VultureLong
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_deadrock.asm"
    incsrc "sprite_sluggula.asm"
    incsrc "sprite_poe.asm"
    incsrc "sprite_moldorm.asm"
    incsrc "sprite_moblin.asm"
    incsrc "sprite_snap_dragon.asm"
    incsrc "sprite_ropa.asm"
    incsrc "sprite_hinox.asm"
    incsrc "sprite_bari.asm"
    incsrc "sprite_helmasaur.asm"
    incsrc "sprite_bubble.asm"
    incsrc "sprite_chicken.asm"

; ==============================================================================

    ; *$32853-$32857 JUMP LOCATION
    Sprite_MovableMantleTrampoline:
    {
        JSL Sprite_MovableMantleLong
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_rupee_crab.asm"
    incsrc "sprite_throwable_scenery.asm"

; ==============================================================================

    ; *$32D03-$32D4F LOCAL
    Entity_ApplyRumbleToSprites:
    {
        LDY.b #$0F
    
    .next_sprite
    
        LDA $0CAA, Y : AND.b #$02 : BEQ .skip_sprite
        
        LDA $0E90, Y : BEQ .skip_sprite
        
        LDA $0FC6 : CMP.b #$0E : BEQ .collision_guaranteed
        
        PHX
        
        TYX
        
        ; Loads up all the bases and widths for the collision detection...
        JSR Sprite_SetupHitBox
        
        PLX
        
        ; Does the actual collision detection...
        JSR Utility_CheckIfHitBoxesOverlap : BCC .skip_sprite
    
    .collision_guaranteed
    
        ; Maybe other sprites react to this, but primarily the apple sprites
        ; hidden in trees split when this variable is set low.
        LDA.b #$00 : STA $0E90, Y
        
        LDA.b #$30 : STA $012F
        
        LDA.b #$30 : STA $0F80, Y
        LDA.b #$10 : STA $0D50, X
        LDA.b #$30 : STA $0EE0, Y
        LDA.b #$FF : STA $0B58, Y
        
        ; \note Interestingly enough, this is not really a heart refill,
        ; but a trigger for a bomb to be knocked out of a tree.
        ; What a mess this game's sprites system is. assassin17 knows it too,
        ; and I've known it for somewhat longer, but it still manages to
        ; surprise me now and then.
        LDA $0E20, Y : CMP.b #$D8 : BNE .not_single_heart_refill
        
        JSL Sprite_TransmuteToEnemyBomb
    
    .skip_sprite
    .not_single_heart_refill
    
        DEY : BPL .next_sprite
        
        RTS
    }

; ==============================================================================

    ; *$32D50-$32D6E LONG
    Sprite_TransmuteToEnemyBomb:
    {
        LDA.b #$4A : STA $0E20, X
        LDA.b #$01 : STA $0DB0, X
        LDA.b #$FF : STA $0E00, X
        LDA.b #$18 : STA $0E60, X
        LDA.b #$08 : STA $0F50, X
        LDA.b #$00 : STA $0E50, X
        
        RTL
    }

; ==============================================================================

    incsrc "sprite_story_teller_multi_1.asm"
    incsrc "sprite_flute_boy.asm"
    incsrc "sprite_smithy_bros.asm"
    incsrc "sprite_enemy_arrow.asm"
    incsrc "sprite_crystal_switch.asm"
    incsrc "sprite_bug_net_kid.asm"
    incsrc "sprite_push_switch.asm"
    incsrc "sprite_middle_aged_man.asm"
    incsrc "sprite_hobo.asm"

; ==============================================================================

    ; *$33FE0-$33FE4 JUMP LOCATION
    Sprite_UncleAndSageTrampoline:
    {
        ; Uncle / Priest / Santuary Mantle
        JSL Sprite_UncleAndSageLong
        
        RTS
    }

; ==============================================================================

    ; *$33FE5-$33FE9 JUMP LOCATION
    SpritePrep_UncleAndSageTrampoline:
    {
        JSL SpritePrep_UncleAndSageLong
        
        RTS
    }

; ==============================================================================

    ; *$33FEA-$33FEE JUMP LOCATION
    SpriteActive2_Trampoline:
    {
        JSL SpriteActive2_MainLong
        
        RTS
    }

; ==============================================================================

    ; *$33FEF-$33FF3 JUMP LOCATION
    SpriteActive3_Transfer:
    {
        JSL SpriteActive3_MainLong
        
        RTS
    }

; ==============================================================================

    ; *$33FF4-$33FF8 JUMP LOCATION
    SpriteActive4_Transfer:
    {
        JSL SpriteActive4_MainLong
        
        RTS
    }

; ==============================================================================

    ; *$33FF9-$33FFD JUMP LOCATION
    SpritePrep_OldMountainManTrampoline:
    {
        JSL SpritePrep_OldMountainManLong
        
        RTS
    }

; ==============================================================================

    ; *$33FFE-$34002 JUMP LOCATION
    Sprite_TutorialEntitiesTrampoline:
    {
        JSL Sprite_TutorialEntitiesLong
        
        RTS
    }

; ==============================================================================

    ; *$34003-$34007 JUMP LOCATION
    Sprite_PullSwitchTrampoline:
    {
        JSL Sprite_PullSwitch
        
        RTS
    }

; ==============================================================================

    ; *$34008-$3400C JUMP LOCATION
    Sprite_SomariaPlatformTrampoline:
    {
        JSL Sprite_SomariaPlatformLong
        
        RTS
    }

; ==============================================================================

    ; *$3400D-$34011 JUMP LOCATION
    Sprite_MedallionTabletTrampoline:
    {
        ; Medallion Tablet
        JSL Sprite_MedallionTabletLong
        
        RTS
    }

; ==============================================================================

    ; *$34012-$34016 JUMP LOCATION
    Sprite_QuarrelBrosTrampoline:
    {
        JSL Sprite_QuarrelBrosLong
        
        RTS
    }

; ==============================================================================

    ; *$34017-$3401B JUMP LOCATION
    Sprite_PullForRupeesTrampoline:
    {
        JSL Sprite_PullForRupeesLong
        
        RTS
    }

; ==============================================================================

    ; *$3401C-$34020 JUMP LOCATION
    Sprite_GargoyleGrateTrampoline:
    {
        JSL Sprite_GargoyleGrateLong
        
        RTS
    }

; ==============================================================================

    ; *$34021-$34025 JUMP LOCATION
    Sprite_YoungSnitchLadyTrampoline:
    {
        JSL Sprite_YoungSnitchLadyLong
        
        RTS
    }

; ==============================================================================

    ; *$34026-$3402A JUMP LOCATION
    SpritePrep_YoungSnitchGirl:
    {
        JSL SpritePrep_SnitchesLong
        
        RTS
    }

; ==============================================================================

    ; *$3402B-$3402F JUMP LOCATION
    Sprite_InnKeeperTrampoline:
    {
        JSL Sprite_InnKeeperLong
        
        RTS
    }

; ==============================================================================

    ; *$34030-$34034 JUMP LOCATION
    SpritePrep_InnKeeper:
    {
        JSL SpritePrep_SnitchesLong
        
        RTS
    }

; ==============================================================================

    ; *$34035-$34039 JUMP LOCATION
    Sprite_WitchTrampoline:
    {
        JSL Sprite_WitchLong
        
        RTS
    }

; ==============================================================================

    ; *$3403A-$3403E JUMP LOCATION
    Sprite_WaterfallTrampoline:
    {
        JSL Sprite_WaterfallLong
        
        RTS
    }

; ==============================================================================

    ; *$3403F-$34043 JUMP LOCATION
    Sprite_ArrowTriggerTrampoline:
    {
        JSL Sprite_ArrowTriggerLong
        
        RTS
    }

; ==============================================================================

    ; *$34044-$34048 JUMP LOCATION
    Sprite_MadBatterTrampoline:
    {
        JSL Sprite_MadBatterLong
        
        RTS
    }

; ==============================================================================

    ; *$34049-$3404D JUMP LOCATION
    Sprite_DashItemTrampoline:
    {
        JSL Sprite_DashItemLong
        
        RTS
    }

; ==============================================================================

    ; *$3404E-$34052 JUMP LOCATION
    Sprite_TroughBoyTrempoline:
    {
        JSL Sprite_TroughBoyLong
        
        RTS
    }

; ==============================================================================

    ; *$34053-$34057 JUMP LOCATION
    Sprite_OldSnitchLadyTrampoline:
    {
        JSL Sprite_OldSnitchLadyLong
        
        RTS
    }

; ==============================================================================

    ; *$34058-$3405C JUMP LOCATION
    Sprite_RunningManTrampoline:
    {
        JSL Sprite_RunningManLong
        
        RTS
    }

; ==============================================================================

    ; *$3405D-$34061 JUMP LOCATION
    SpritePrep_RunningManTrampoline:
    {
        JSL SpritePrep_RunningManLong
        
        RTS
    }

; ==============================================================================

    ; *$34062-$34066 JUMP LOCATION
    Sprite_BottleVendorTrampoline:
    {
        ; Bottle Vendor AI
        
        JSL Sprite_BottleVendorLong
        
        RTS
    }

; ==============================================================================

    ; *$34067-$3406B JUMP LOCATION
    Sprite_ZeldaTrampoline:
    {
        JSL Sprite_ZeldaLong
        
        RTS
    }

; ==============================================================================

    ; *$3406C-$34070 JUMP LOCATION
    SpritePrep_ZeldaTrampoline:
    {
        JSL SpritePrep_ZeldaLong
        
        RTS
    }

; ==============================================================================

    ; *$34071-$34075 JUMP LOCATION
    Sprite_ElderWifeTrampoline:
    {
        JSL Sprite_ElderWifeLong
        
        RTS
    }

; ==============================================================================

    ; *$34076-$3407A JUMP LOCATION
    Sprite_MushroomTrampoline:
    {
        JSL Sprite_MushroomLong
        
        RTS
    }

; ==============================================================================

    ; *$3407B-$3407F JUMP LOCATION
    SpritePrep_MushroomTrampoline:
    {
        JSL SpritePrep_MushroomLong
        
        RTS
    }

; ==============================================================================

    ; *$34080-$34084 JUMP LOCATION
    Sprite_FakeSwordTrampoline:
    {
        JSL Sprite_FakeSwordLong
        
        RTS
    }

; ==============================================================================

    ; *$34085-$34089 JUMP LOCATION
    SpritePrep_FakeSwordTrampoline:
    {
        JSL SpritePrep_FakeSword
        
        RTS
    }

; ==============================================================================

    ; *$3408A-$3408E JUMP LOCATION
    Sprite_ElderTrampoline:
    {
        JSL Sprite_ElderLong
        
        RTS
    }

; ==============================================================================

    ; *$3408F-$34093 JUMP LOCATION
    Sprite_PotionShopTrampoline:
    {
        JSL Sprite_PotionShopLong
        
        RTS
    }

; ==============================================================================

    ; *$34094-$34098 JUMP LOCATION
    SpritePrep_PotionShopTrampoline:
    {
        JSL SpritePrep_PotionShopLong
        
        RTS
    }

; ==============================================================================

    ; *$34099-$3409D JUMP LOCATION
    Sprite_HeartContainerTrampoline:
    {
        JSL Sprite_HeartContainerLong
        
        RTS
    }

; ==============================================================================

    ; *$3409E-$340A2 JUMP LOCATION
    SpritePrep_HeartContainerTrampoline:
    {
        JSL SpritePrep_HeartContainerLong
        
        RTS
    }

; ==============================================================================

    ; *$340A3-$340A7 JUMP LOCATION
    Sprite_HeartPieceTrampoline:
    {
        JSL Sprite_HeartPieceLong
        
        RTS
    }

; ==============================================================================

    ; *$340A8-$340AC JUMP LOCATION
    SpritePrep_HeartPieceTrampoline:
    {
        JSL SpritePrep_HeartPieceLong
        
        RTS
    }

; ==============================================================================

    ; $340AD-$340B1 JUMP LOCATION (UNUSED)
    FluteBoy_UnusedInvocation:
    {
        JSL Sprite_FluteBoy
        
        RTS
    }

; ==============================================================================

    ; *$340B2-$340B6 JUMP LOCATION
    Sprite_UnusedTelepathTrampoline:
    {
        JSL Sprite_UnusedTelepathLong
        
        RTS
    }

; ==============================================================================

    ; *$340B7-$340BB JUMP LOCATION
    Sprite_HumanMulti_1_Trampoline:
    {
        JSL Sprite_HumanMulti_1_Long
        
        RTS
    }

; ==============================================================================

    ; *$340BC-$340C0 JUMP LOCATION
    Sprite_SweepingLadyTrampoline:
    {
        JSL Sprite_SweepingLadyLong
        
        RTS
    }

; ==============================================================================

    ; *$340C1-$340C5 JUMP LOCATION
    Sprite_LumberjacksTrampoline:
    {
        JSL Sprite_LumberjacksLong
        
        RTS
    }

; ==============================================================================

    ; *$340C6-$340CA JUMP LOCATION
    Sprite_FortuneTellerTrampoline:
    {
        JSL Sprite_FortuneTellerLong
        
        RTS
    }

; ==============================================================================

    ; *$340CB-$340CF JUMP LOCATION
    Sprite_MazeGameLadyTrampoline:
    {
        JSL Sprite_MazeGameLadyLong
        
        RTS
    }

; ==============================================================================

    ; *$340D0-$340D4 JUMP LOCATION
    Sprite_MazeGameGuyTrampoline:
    {
        JSL Sprite_MazeGameGuyLong
        
        RTS
    }

; ==============================================================================

    ; *$340D5-$340D9 JUMP LOCATION
    Sprite_TalkingTreeTrampoline:
    {
        JSL Sprite_TalkingTreeLong
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_movable_statue.asm"
    incsrc "sprite_weathervane_trigger.asm"
    incsrc "sprite_ponds.asm"
    incsrc "sprite_leever.asm"
    incsrc "sprite_heart_refill.asm"
    incsrc "sprite_faerie.asm"
    incsrc "sptite_absorbable.asm"
    incsrc "sprite_octorock.asm"
    incsrc "sprite_octostone.asm"
    incsrc "sprite_octoballoon.asm"
    incsrc "sprite_octospawn.asm"
    incsrc "sprite_buzzblob.asm"

; ==============================================================================

    ; *$359C0-$359D4 LOCAL
    Sprite_WallInducedSpeedInversion:
    {
        LDA $0E70, X : AND.b #$03 : BEQ .no_horiz_collision
        
        JSR Sprite_InvertHorizSpeed
    
    .no_horiz_collision
    
        LDA $0E70, X : AND.b #$0C : BEQ .no_vert_collision
        
        JSR Sprite_InvertVertSpeed
    
    .no_vert_collision
    
        RTS
    }

; ==============================================================================

    ; *$359D5-$359E1 LOCAL
    Sprite_Invert_XY_Speeds:
    {
        JSR Sprite_InvertVertSpeed
    
    ; *$359D8 ALTERNATE ENTRY POINT
    shared Sprite_InvertHorizSpeed:
    
        ; Flip sign of X velocity
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        RTS
    }

; ==============================================================================

    ; *$359E2-$359EB LOCAL
    Sprite_InvertVertSpeed:
    {
        ; Flip sign of Y velocity
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$359EC-$35A08 LOCAL
    Sprite_CheckIfActive:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .inactive
    
    ; *$359F3 ALTERNATE ENTRY POINT
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

    ; $35A09-$35B03 DATA
    {
        ; \task Needs naming, but probably just a simple conversion to a pool.
        db $A0, $A2, $A0, $A2, $80, $82, $80, $82
        db $EA, $EC, $84, $4E, $61, $BD, $8C, $20
        
        db $22, $C0, $C2, $E6, $E4, $82, $AA, $84
        db $AC, $80, $A0, $CA, $AF, $29, $39, $0B
        
        db $6E, $60, $62, $63, $4C, $EA, $EC, $24
        db $6B, $24, $22, $24, $26, $20, $30, $21
        
        db $2A, $24, $86, $88, $8A, $8C, $8E, $A2
        db $A4, $A6, $A8, $AA, $84, $80, $82, $6E
        
        db $40, $42, $E6, $E8, $80, $82, $C8, $8D
        db $E3, $E5, $C5, $E1, $04, $24, $0E, $2E
        
        db $0C, $0A, $9C, $C7, $B6, $B7, $60, $62
        db $64, $66, $68, $6A, $E4, $F4, $02, $02
        
        db $00, $04, $C6, $CC, $CE, $28, $84, $82
        db $80, $E5, $24, $00, $02, $04, $A0, $AA
        
        db $A4, $A6, $AC, $A2, $A8, $A6, $88, $86
        db $8E, $AE, $8A, $42, $44, $42, $44, $64
        
        db $66, $CC, $CC, $CA, $87, $97, $8E, $AE
        db $AC, $8C, $8E, $AA, $AC, $D2, $F3, $84
        
        db $A2, $84, $A4, $E7, $8A, $A8, $8A, $A8
        db $88, $A0, $A4, $A2, $A6, $A6, $A6, $A6
        
        db $7E, $7F, $8A, $88, $8C, $A6, $86, $8E
        db $AC, $86, $BB, $AC, $A9, $B9, $AA, $BA
        
        db $BC, $8A, $8E, $8A, $86, $0A, $C2, $C4
        db $E2, $E4, $C6, $EA, $EC, $FF, $E6, $C6
        
        db $CC, $EC, $CE, $EE, $4C, $6C, $4E, $6E
        db $C8, $C4, $C6, $88, $8C, $24, $E0, $AE
        
        db $C0, $C8, $C4, $C6, $E2, $E0, $EE, $AE
        db $A0, $80, $EE, $C0, $C2, $BF, $8C, $AA
        
        db $86, $A8, $A6, $2C, $28, $06, $DF, $CF
        db $A9, $46, $46, $EA, $C0, $C2, $E0, $E8
        
        db $E2, $E6, $E4, $0B, $8E, $A0, $EC, $EA
        db $E9, $48, $58
    }

; ==============================================================================

    ; $35B04-$35BEF DATA
    {
        db $C8, $00, $6B, $00, $00, $00, $00, $00
        db $00, $CB, $00, $08, $0A, $0B, $00, $00
        
        db $0D, $00, $00, $56, $00, $00, $0F, $11
        db $00, $13, $00, $00, $00, $00, $14, $00
        
        db $15, $1B, $00, $2A, $2A, $F8, $00, $B6
        db $00, $00, $00, $AA, $00, $00, $1C, $00
        
        db $00, $00, $00, $00, $00, $00, $00, $F3
        db $F3, $00, $BB, $27, $00, $00, $42, $00
        
        ; 0x40
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $0F, $3F, $00, $00, $00, $40, $40
        
        db $44, $00, $00, $00, $00, $47, $46, $00
        db $00, $48, $4A, $65, $65, $00, $00, $00
        
        db $00, $00, $8F, $00, $00, $4C, $4E, $4E
        db $4E, $4E, $00, $30, $24, $32, $38, $3C
        
        db $81, $00, $52, $00, $00, $00, $00, $00
        db $00, $5C, $00, $62, $5E, $00, $00, $00
        
        ; 0x80
        db $65, $66, $00, $00, $00, $00, $6E, $0E
        db $00, $3B, $42, $00, $00, $75, $78, $7B
        
        db $00, $00, $CF, $00, $84, $8D, $8D, $8D
        db $8D, $00, $94, $75, $A0, $00, $00, $A2
        
        db $A6, $00, $00, $00, $B1, $00, $B5, $00
        db $BD, $00, $00, $00, $69, $00, $00, $00
        
        db $00, $00, $5C, $00, $D6, $E6, $00, $00
        db $00, $DB, $DA, $E9, $00, $00, $BE, $C0
        
        ; 0xc0
        db $6A, $00, $F9, $D7, $00, $00, $00, $D8
        db $00, $00, $DE, $E3, $00, $00, $00, $EB
        
        db $00, $00, $00, $00, $00, $00, $F4, $F4
        db $1D, $1F, $1F, $1F, $20, $20, $20, $21
        
        ; 0xe0
        db $22, $23, $23, $25, $28, $6A, $F6, $29
        db $00, $00, $CD, $CE
    }

; ==============================================================================

    ; *$35BF0-$35BF7 LONG
    Sprite_PrepAndDrawSingleLargeLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_PrepAndDrawSingleLarge
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$35BF8-$35BFF LONG
    Sprite_PrepAndDrawSingleSmallLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_PrepAndDrawSingleSmall
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $35C00-$35C0F
    {
        ; This data seems to be unused.
        db 0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3
    }

    ; *$35C10-$35C53 LOCAL
    Sprite_PrepAndDrawSingleLarge:
    {
        JSR Sprite_PrepOamCoord
    
    ; *$35C13 ALTERNATE ENTRY POINT
    .just_draw
    
        LDA $00 : STA ($90), Y
        
        LDA $01 : CMP.b #$01
        
        LDA.b #$01 : ROL A : STA ($92)
        
        REP #$20
        
        LDA $02 : INY
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCS .out_of_bounds_y
        
        SBC.b #$0F : STA ($90), Y
        
        PHY
        
        LDY $0E20, X
        
        LDA $DB04, Y : ADD $0DC0, X : TAY
        
        LDA $DA09, Y : PLY : INY : STA ($90), Y
        LDA $05            : INY : STA ($90), Y
    
    ; *$35C4C ALTERNATE ENTRY POINT
    shared Sprite_DrawShadowRedundant:
    .out_of_bounds_y
    
        ; Optinally draw a shadow for the sprite if this flag is set.
        LDA $0E60, X : AND.b #$10 : BNE Sprite_DrawShadow
        
        RTS
    }

; ==============================================================================

    ; *$35C54-$35C5B LONG
    Sprite_DrawShadowLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_DrawShadow
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$35C5C-$35C63 LONG
    pool Sprite_DrawShadowLong:
    {
    
    .variable
    
        PHB : PHK : PLB
        
        JSR Sprite_DrawShadow.variable
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$35C64-$35CEE LOCAL
    Sprite_DrawShadow:
    {
        ; This draws the shadow underneath a sprite
        
        LDA.b #$0A
    
    ; *$35C66 ALTERNATE ENTRY POINT
    .variable
    
                       ADD $0D00, X : STA $02
        LDA $0D20, X : ADC.b #$00   : STA $03
        
        ; Is the sprite disabled ("paused", you might say)
        LDA $0F00, X : BNE .dontDrawShadow
        
        LDA $0DD0, X : CMP.b #$0A : BNE .notBeingCarried
        
        LDA $7FFA1C, X : CMP.b #$03 : BEQ .dontDrawShadow
    
    .notBeingCarried
    
        REP #$20
        
        LDA $02 : SUB $E8 : STA $02
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCS .offScreenY
        
        LDA $0E40, X : AND.b #$1F : ASL #2 : TAY
        
        LDA $00 : STA ($90), Y
        
        LDA $0E60, X : AND.b #$20 : BEQ .delta
        
        INY
        
        ; This instruction doesn't seem to belong here, as it doesn't do anything
        ; (There's another LDA right after it)
        ; \optimize Simply by taking it out, saves space and time.
        LDA ($90), Y
        
              LDA $02    : INC A : STA ($90), Y
        INY : LDA.b #$38         : STA ($90), Y
        
        LDA $05 : AND.b #$30 : ORA.b #$08 : INY : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        ; Ensures the lowest priority for the shadow
        LDA $01 : AND.b #$01 : STA ($92), Y
    
    .dontDrawShadow
    
        RTS
    
    .delta
    
        LDA $02    : INY : STA ($90), Y
        LDA.b #$6C : INY : STA ($90), Y
        
        LDA $05 : AND.b #$30 : ORA.b #$08
        
        INY : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA $01 : AND.b #$01 : ORA.b #$02 : STA ($92), Y
    
    .offScreenY
    
        RTS
    }

; ==============================================================================

    ; *$35CEF-$35D37 LOCAL
    Sprite_PrepAndDrawSingleSmall:
    {
        JSR Sprite_PrepOamCoord
        
        LDA $00 : STA ($90), Y
        
        LDA $01 : CMP.b #$01
        
        LDA.b #$00 : ROL A : STA ($92)
        
        REP #$20
        
        LDA $02 : INY
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCS BRANCH_ALPHA
        
        SBC.b #$0F : STA ($90), Y
        
        PHY
        
        LDY $0E20, X
        
        LDA $DB04, Y : ADD $0DC0, X : TAY
        
        LDA $DA09, Y : PLY : INY : STA ($90), Y
        LDA $05            : INY : STA ($90), Y
    
    BRANCH_ALPHA:
    
        LDA $0E60, X : AND.b #$10 : BEQ BRANCH_BETA
        
        LDA.b #$02
        
        JMP Sprite_DrawShadow.variable
    
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; *$35D38-$35D3F LONG
    DashKey_Draw:
    {
        PHB : PHK : PLB
        
        JSR Sprite_DrawKey
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$35D40-$35DAE LOCAL
    Sprite_DrawKey:
    shared Sprite_DrawThinAndTall:
    {
        JSR Sprite_PrepOamCoord
        
        LDA $00    : STA ($90), Y
        LDY.b #$04 : STA ($90), Y
        
        ; Get bit 8 of X coordinate, and force size to 8x8.
        LDA $01 : CMP.b #$01
        
        LDA.b #$00 : ROL A
        
        LDY.b #$00 : STA ($92), Y
        INY        : STA ($92), Y
        
        REP #$20
        
        LDA $02 : LDY.b #$01 : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_upper_half_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_upper_half_y
    
        LDA $02 : ADD.w #$0008
        
        LDY.b #$05 : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_lower_half_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_lower_half_y
    
        SEP #$20
        
        LDY $0E20, X
        
        LDA $DB04, Y : ADD $0DC0, X : TAY
        
        LDA $DA09, Y : LDY.b #$02 : STA ($90), Y
        ADD.b #$10   : LDY.b #$06 : STA ($90), Y
        LDA $05      : LDY.b #$03 : STA ($90), Y
                       LDY.b #$07 : STA ($90), Y
        
        JMP Sprite_DrawShadowRedundant
    }

; ==============================================================================

    incsrc "sprite_held_mode.asm"

; ==============================================================================

    ; *$35FF2-$35FF9 LONG
    ThrownSprite_TileAndPeerInteractionLong:
    {
        PHB : PHK : PLB
        
        JSR ThrownSprite_TileAndPeerInteraction
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$35FFA-$36163 JUMP LOCATION
    SpriteStunned_Main:
    {
        JSR $E2B6 ; $362B6 IN ROM
        JSR Sprite_CheckIfActive.permissive
        
        LDA $0EA0, X : BEQ .not_recoiling
                       BPL .recoil_timer_ticking
        
        STZ $0EA0, X
    
    .recoil_timer_ticking
    
        JSR Sprite_Zero_XY_Velocity
    
    .not_recoiling
    
        ; Even though the sprite is stunned, there is still a 32 frame delay
        ; before it can be damaged.
        LDA $0DF0, X : CMP.b #$20 : BCS .delay_vulnerability
        
        JSR Sprite_CheckDamageFromPlayer
    
    .delay_vulnerability
    
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_Move
        
        LDA $0E90, X : BNE .skip_tile_collision_logic
        
        JSR Sprite_CheckTileCollision
        
        LDA $0DD0, X : BEQ BRANCH_EPSILON
    
    ; *$3602A ALTERNATE ENTRY POINT
    shared ThrownSprite_TileAndPeerInteraction:
    
        LDA $0E70, X : AND.b #$0F : BEQ .no_tile_collision
        
        JSR $E229 ; $36229 IN ROM
        
        LDA $0DD0, X : CMP.b #$0B : BNE .not_frozen
        
        ; Play clink sound because frozen sprite hit a wall.
        LDA.b #$05 : JSL Sound_SetSfx2PanLong
    
    .no_tile_collision
    .not_frozen
    .skip_tile_collision_logic
    
        ; Check collision against boundary of the area we're in? (not solid
        ; tiles, the actual border of the area / room).
        LDY.b #$68 : JSR $E73C ; $3673C IN ROM
        
        PHX
        
        LDA $0E20, X : TAX
        
        LDA $0DB359, X : PLX : AND.b #$10 : BEQ BRANCH_ZETA
        
        LDA $0E60, X : ORA.b #$10 : STA $0E60, X
        
        LDA $0FA5 : CMP.b #$20 : BNE BRANCH_ZETA
        
        ; Just unsets draw shadow flag (no reason to when over a pit)
        JSR $8612 ; $30612 IN ROM
    
    BRANCH_ZETA:
    
        JSR Sprite_MoveAltitude
        
        ; Applies gravity to the sprite
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : DEC A : CMP.b #$F0 : BCS BRANCH_THETA
        
        JMP $E149 ; $36149 IN ROM
    
    BRANCH_THETA:
    
        STZ $0F70, X
        
        LDA $0E20, X : CMP.b #$E8 : BNE .not_fake_master_sword
        
        LDA $0F80, X : CMP.b #$E8 : BPL BRANCH_IOTA
        
        ; Fake master sword has a special death animation where it sort of...
        ; poofs.
        LDA.b #$06 : STA $0DD0, X
        
        LDA.b #$08 : STA $0DF0, X
    
    ; *$36095 ALTERNATE ENTRY POINT
    
        LDA.b #$03 : STA $0E40, X
    
    BRANCH_EPSILON:
    
        RTS
    
    BRANCH_IOTA:
    .not_fake_master_sword
    
        ; Only applies to throwable scenery.
        JSR $E22F ; $3622F IN ROM
        
        LDA $0FA5 : CMP.b #$20 : BNE BRANCH_KAPPA
        
        LDA $0B6B, X : LSR A : BCS BRANCH_KAPPA
    
    ; *$360AB ALTERNATE ENTRY POINT
    
        ; \task So... 0x01 is for outdoors, and 0x05 falling state is for
        ; indoors? Double and triple check this as it alters the necessary
        ; naming scheme.
        ; Set it so the object is falling into a pit
        LDA.b #$01 : STA $0DD0, X
        LDA.b #$1F : STA $0DF0, X
        
        STZ $012E
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        RTS
    
    BRANCH_KAPPA:
    
        CMP.b #$09 : BNE BRANCH_LAMBDA
        
        LDA $0F80, X : STZ $0F80, X : CMP.b #$F0 : BPL BRANCH_MU
        
        LDA.b #$EC
        
        JSL Sprite_SpawnDynamically : BMI BRANCH_MU
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        TYX
        
        JSR $E0F6 ; $360F6 IN ROM
        
        PLX
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA:
    
        CMP.b #$08 : BNE BRANCH_MU
        
        LDA $0E20, X : CMP.b #$D2 : BEQ .is_flopping_fish
        
        JSL GetRandomInt : LSR A : BCC .anospawn_leaping_fish
    
    .is_flopping_fish
    
        JSR Fish_SpawnLeapingFish
    
    .anospawn_leaping_fish
    
    ; *$360F6 ALTERNATE ENTRY POINT
    
        JSL Sound_SetSfxPan : ORA.b #$28 : STA $012E
        
        LDA.b #$03 : STA $0DD0, X
        
        LDA.b #$0F : STA $0DF0, X
        
        STZ $0D80, X
        
        JSL GetRandomInt : AND.b #$01
        
        JMP $E095 ; $36095 IN ROM
    
    BRANCH_MU:
    
        LDA $0F80, X : BPL BRANCH_OMICRON
        
        EOR.b #$FF : INC A : LSR A : CMP.b #$09 : BCS BRANCH_PI
        
        LDA.b #$00
    
    BRANCH_PI:
    
        STA $0F80, X
    
    BRANCH_OMICRON:
    
        ; Is this arithmetic shift right? Clever, if so.
        LDA $0D50, X : ASL A : ROR $0D50, X
        
        LDA $0D50, X : CMP.b #$FF : BNE BRANCH_RHO
        
        STZ $0D50, X
    
    BRANCH_RHO:
    
        LDA $0D40, X : ASL A : ROR $0D40, X
        
        LDA $0D40, X : CMP.b #$FF : BNE BRANCH_SIGMA
        
        STZ $0D40, X
    
    ; *$36149 ALTERNATE ENTRY POINT
    BRANCH_SIGMA:
    
        LDA $0DD0, X : CMP.b #$0B : BNE BRANCH_TAU
        
        LDA $7FFA3C, X : BEQ BRANCH_UPSILON
    
    BRANCH_TAU:
    
        JSR Sprite_CheckIfLifted
        
        LDA $0E20, X : CMP.b #$4A : BEQ BRANCH_UPSILON
        
        JSR ThrownSprite_CheckDamageToPeers
    
    BRANCH_UPSILON:
    
        RTS
    }

; ==============================================================================

    ; *$36164-$36171 LOCAL
    ThrowableScenery_InteractWithSpritesAndTiles:
    {
        JSR Sprite_Move
        
        LDA $0E90, X : BNE .skip_tile_collision
        
        JSR Sprite_CheckTileCollision
    
    .skip_tile_collision
    
        JMP ThrownSprite_TileAndPeerInteraction
    }

; ==============================================================================

    ; This routine is intended to be used by 'throwable sprites' to damage
    ; other sprites.
    ; *$36172-$361B1 LOCAL
    ThrownSprite_CheckDamageToPeers:
    {
        LDA $0F10, X : BNE .delay_damaging_others
        
        LDA $0D50, X : ORA $0D40, X : BEQ .no_momentum
        
        LDY.b #$0F
    
    .next_sprite_slot
    
        PHY
        
        CPY $0FA0 : BEQ .cant_damage_self
        
        LDA $0E20, X : CMP.b #$D2 : BEQ .cant_damage
        
        LDA $0DD0, Y : CMP.b #$09 : BCC .cant_damage
        
        TYA : EOR $1A : AND.b #$03 : ORA $0BA0, Y
                                     ORA $0EF0, Y : BNE .cant_damage
        
        LDA $0F20, X : CMP $0F20, Y : BNE .cant_damage
        
        JSR ThrownSprite_CheckDamageToSinglePeer
    
    .cant_damage
    .cant_damage_self
    
        PLY : DEY : BPL .next_sprite_slot
    
    .no_momentum
    .delay_damaging_others
    
        RTS
    }

; ==============================================================================

    ; *$361B2-$3626D LOCAL
    ThrownSprite_CheckDamageToSinglePeer:
    {
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $08
        
        LDA.b #$0F : STA $02
        
        LDA $0D00, X : SUB $0F70, X : PHP : ADD.b #$08 : STA $01
        LDA $0D20, X : ADC.b #$00   : PLP : SBC.b #$00 : STA $09
        
        LDA.b #$08 : STA $03
        
        PHX
        
        TYX
        
        JSR Sprite_SetupHitBox
        
        PLX
        
        JSR Utility_CheckIfHitBoxesOverlap : BCC BRANCH_361B1 ; (RTS)
        
        LDA $0E20, Y : CMP.b #$3F : BNE .notTutorialSoldier
        
        JSL Sprite_PlaceRupulseSpark
        
        BRA BRANCH_BETA
    
    .notTutorialSoldier
    
        LDA.b #$03 : PHA
        
        LDA $0E20, X : CMP.b #$EC : BNE BRANCH_GAMMA
        
        LDA $0DB0, X : CMP.b #$02 : BNE BRANCH_GAMMA
        
        LDA $1B : BNE BRANCH_GAMMA
        
        PLA
        
        LDA.b #$01 : PHA
    
    BRANCH_GAMMA:
    
        PLA : PHX
        
        TYX
        
        PHY
        
        JSL Ancilla_CheckSpriteDamage.preset_class
        
        PLY : PLX
        
        LDA $0D50, X : ASL A : STA $0F40, Y
        LDA $0D40, X : ASL A : STA $0F30, Y
        
        LDA.b #$10 : STA $0F10, X
    
    ; *$36229 ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        JSR Sprite_Invert_XY_Speeds
        JSR Sprite_Halve_XY_Speeds
    
    ; *$3622F ALTERNATE ENTRY POINT
    
        ; Not a bush...
        LDA $0E20, X : CMP.b #$EC : BNE BRANCH_DELTA
        
        STZ $0FAC
    
    ; *$36239 ALTERNATE ENTRY POINT
    
        LDA $0DC0, X : BEQ BRANCH_EPSILON
        
        STA $0B9C
        
        JSR Sprite_SpawnSecret
        
        STZ $0B9C
    
    BRANCH_EPSILON:
    
        LDY $0DB0, X
        
        LDA $1B : BEQ BRANCH_ZETA
        
        LDY.b #$00
    
    BRANCH_ZETA:
    
        STZ $012E
        
        LDA $E272, Y : JSL Sound_SetSfx2PanLong
    
    ; *$3625A ALTERNATE ENTRY POINT
    shared Sprite_ScheduleForBreakage:
    
        LDA.b #$1F
    
    ; *$3625C ALTERNATE ENTRY POINT
    shared Sprite_CustomTimedScheduleForBreakage:
    
        STA $0DF0, Y
        
        ; Break this pot...
        LDA.b #$06 : STA $0DD0, X
        
        LDA $0E40, X : ADD.b #$04 : STA $0E40, X
    
    BRANCH_DELTA:
    
        RTS
    }

; ==============================================================================

    ; *$3626E-$3627C LOCAL
    Sprite_Halve_XY_Speeds:
    {
        ; This sequence does an arithmetic (not logical!) shift right on
        ; the x and y speeds, which effectively reduces them by
        LDA $0D50, X : ASL A
        
        ROR $0D50, X
        
        LDA $0D40, X : ASL A
        
        ROR $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$36286-$362A6 LOCAL
    Fish_SpawnLeapingFish:
    {
        ; I think this is the routine called to spawn the fish that jump out
        ; of the water after a rock or similar is thrown into the water.
        
        LDA.b #$D2 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$02 : STA $0D80, Y
        
        LDA.b #$30 : STA $0DF0, Y
        
        LDA $0E20, X : CMP.b #$D2 : BNE .not_spawned_from_other_fish
        
        ; \task Give a 20 rupee reward? Is that what this controls?
        ; Only make a grateful fish leap up if it was one rescued from water,
        ; not a fish that was perturbed by something else being thrown into
        ; the water, like a skull rock / bush / frozen sprite.
        STA $0D90, Y
    
    .not_spawned_from_other_fish
    .spawn_failed
    
        RTS
    }

    ; *$362B6-$36342 LOCAL
    {
        JSL Sprite_DrawRippleIfInWater
    
    ; *$362BA ALTERNATE ENTRY POINT
    
        JSR SpriteActive_Main
        
        LDA $7FFA3C, X : BEQ BRANCH_ALPHA
        
        LDA $0DF0, X : CMP.b #$20 : BCS BRANCH_BETA
        
        ; \note Think this sets a blue palette?
        LDA $0F50, X : AND.b #$F1 : ORA.b #$04 : STA $0F50, X
    
    BRANCH_BETA:
    
        LDA $0DF0, X : LSR #4 : TAY
        
        TXA : ASL #4 : EOR $1A : ORA $11 : AND $E2AF, Y : BNE BRANCH_GAMMA
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $E2A7, Y : STA $00
        LDA $E2AB, Y : STA $01
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $E2A7, Y : STA $02
        LDA $E2AB, Y : STA $03
        
        JSL Sprite_SpawnSimpleSparkleGarnish
    
    BRANCH_GAMMA:
    
        RTS
    
    BRANCH_ALPHA:
    
        LDA $1A : AND.b #$01 : ORA $11 : ORA $0FC1 : BNE BRANCH_DELTA
        
        LDA $0B58, X              : BEQ BRANCH_EPSILON
        DEC $0B58, X : CMP.b #$38 : BCS BRANCH_DELTA
        
        AND.b #$01 : TAY
        
        LDA .wiggle_x_speeds, Y : STA $0D50, X
        
        JSR Sprite_MoveHoriz
    
    BRANCH_DELTA:
    
        RTS
    
    BRANCH_EPSILON:
    
        LDA.b #$09 : STA $0DD0, X
        
        STZ $0F40, X
        STZ $0F30, X
        
        RTS
    
    .wiggle_x_speeds
        db 8, -8
    }

; ==============================================================================

    ; $36343-$36392 DATA
    pool SpritePoof_Main:
    {
    
    .x_offsets
        db -6,  10,   1,  13
        db -6,  10,   1,  13
        db -7,   4,  -5,   6
        db -1,   1,  -2,   0
    
    .y_offsets
        db -6,  -4,  10,   9
        db -6,  -4,  10,   9
        db -8, -10,   4,   3
        db -1,  -2,   0,   1
    
    .chr
        db $9B, $9B, $9B, $9B
        db $B3, $B3, $B3, $B3
        db $8A, $8A, $8A, $8A
        db $8A, $8A, $8A, $8A
    
    .properties
        db $24, $A4, $24, $A4
        db $E4, $64, $A4, $24
        db $24, $E4, $E4, $E4
        db $24, $E4, $E4, $E4
    
    .oam_sizes
        db $00, $00, $00, $00
        db $00, $00, $00, $00
        db $02, $02, $02, $02
        db $02, $02, $02, $02
    }

; ==============================================================================

    ; *$36393-$36415 JUMP LOCATION
    SpritePoof_Main:
    {
        ; Sprite state 0x02
        
        ; Check this timer
        LDA $0DF0, X : BNE .just_draw
        
        ; See if the enemy is a buzzblob
        LDA $0E20, X : CMP.b #$0D : BNE .not_tranny_buzzblob
        
        ; Thinking this is a transformed buzz blob exception.
        LDY $0EB0, X : BEQ .not_tranny_buzzblob
        
        LDY $0D10, X : PHY
        LDY $0D30, X : PHY
        
        JSR $F9D1 ; $379D1 IN ROM
        
        PLA : STA $0D30, X
        PLA : STA $0D10, X
        
        STZ $0F80, X
        STZ $0BA0, X
        
        RTS
    
    .not_tranny_buzzblob
    
        LDA $0CBA, X : BNE .has_specific_drop_item
        
        LDY.b #$02
        
        JMP $F9BC ; $379BC IN ROM
    
    .has_specific_drop_item
    
        JMP $F923 ; $37923 IN ROM
    
    .just_draw
    
        JSR Sprite_PrepOamCoord
        
        LDA $0DF0, X : LSR A : AND.b #$FC : STA $00
        
        PHX
        
        LDX.b #$03
    
    .next_oam_entry
    
        PHX
        
        TXA : ADD $00 : TAX
        
        LDA $0FA8 : ADD .x_offsets, X        : STA ($90), Y
        LDA $0FA9 : ADD .y_offsets, X  : INY : STA ($90), Y
                    LDA .chr, X        : INY : STA ($90), Y
                    LDA .properties, X : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA .oam_sizes, X : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        LDY.b #$FF
        LDA.b #$03
        
        JMP Sprite_CorrectOamEntries
    }

; ==============================================================================

    ; *$36416-$36419 LONG
    Sprite_PrepOamCoordLong:
    {
        JSR Sprite_PrepOamCoordSafeWrapper
        
        RTL
    }

; ==============================================================================

    ; *$3641A-$3641D LOCAL
    Sprite_PrepOamCoordSafeWrapper:
    {
        ; This wrapper is considered 'Safe' because it negates the caller
        ; termination property of 'Sprite_PrepOamCoord' by using this routine
        ; as a sacrificial intermediate. Since this subroutine only does
        ; one useful task, exiting from it early will not interrupt the caller
        ; of this subroutine, which can potentially happen if
        ; 'Sprite_PrepOamCoord' is called directly
        
        JSR Sprite_PrepOamCoord
        
        RTS
    }

; ==============================================================================

    ; *$3641E-$36495 LOCAL
    Sprite_PrepOamCoord:
    {
        ; Enable the sprite to move.
        STZ $0F00, X
        
        REP #$20
        
        ; X coordinate for the sprite
        LDA $0FD8 : SUB $E2 : STA $00
        
        ; A = (Sprite's X coord - far left of screen X coord) + 0x40
        ; Y coordinate is at most 255, so make 8 bit.
        ; If A >= 0x170 don't display at all
        ADD.w #$0040 : CMP.w #$0170 : SEP #$20 : BCS .x_out_of_bounds
        
        ; How high off the ground is the object?
        LDA $0F70, X : STA $04
                       STZ $05
        
        REP #$20
        
        ; Link's Y coord. Subtract the Y coordinate of the camera.
        LDA $0FDA : SUB $E8 : PHA
        
        ; Offset by how far the object is off the ground, to be fair.
        SUB $04 : STA $02
        
        ; Grab the non height adjusted value.
        ; Add in 0x40 and see if it's >= 0x0170
        ; If sufficiently off screen don't render at all
        PLA : ADD.w #$0040 : CMP.w #$0170 : SEP #$20 : BCC .y_inbounds
        
        ; Not sure what $0F60, X does yet... (room relevance?)
        LDA $0F60, X : AND.b #$20 : BEQ .immobilize_sprite
    
    .y_inbounds
    
        ; Signals the sprite is fine...?
        CLC
    
    .finish_up
    
        ; What palette is the sprite using?
        ; Xor it with sprite priority
        LDA $0F50, X : EOR $0B89, X : STA $05
                                      STZ $04
        
        LDA $00 : STA $0FA8
        LDA $02 : STA $0FA9
        
        LDY.b #$00
        
        RTS
    
    .x_out_of_bounds
    
        REP #$20
        
        LDA $0FDA : SUB $E8 : SUB $04 : STA $02
        
        SEP #$20
    
    .immobilize_sprite
    
        ; Make the sprite immobile.
        INC $0F00, X
        
        LDA $0CAA, X : BMI .dont_kill
        
        JSL Sprite_SelfTerminate
    
    .dont_kill
    
        PLA : PLA
        
        SEC
        
        BRA .finish_up
    }

; ==============================================================================

    ; *$36496-$364A0 LONG
    Sprite_CheckTileCollisionLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CheckTileCollision
        
        PLB
        
        LDA $0E70, X
        
        RTL
    }

; ==============================================================================

    ; *$364A1-$364DA BRANCH LOCATION
    pool Sprite_CheckTileCollision:
    {
    
    .restore_layer_property
    
        LDA $0FB6 : STA $0F20, X
        
        RTS
    
    .restrict_to_same_layer
    
        JMP Sprite_CheckTileCollisionSingleLayer
    
    ; $364AB MAIN ENTRY POINT
    Sprite_CheckTileCollision:
    
        STZ $0E70, X
        
        LDA $0F60, X : BMI .restrict_to_same_layer
        
        LDA $046C : BEQ .restrict_to_same_layer
        
        LDA $0F20, X : STA $0FB6
        
        LDA.b #$01 : STA $0F20, X
        
        JSR Sprite_CheckTileCollisionSingleLayer
        
        LDA $046C : CMP.b #$04 : BEQ .restore_layer_property
        
        STZ $0F20, X
        
        JSR Sprite_CheckTileCollisionSingleLayer
        
        LDA $0FA5 : STA $7FFABC, X
        
        RTS
    }

; ==============================================================================

    ; *$364DB-$365B7 LOCAL
    Sprite_CheckTileCollisionSingleLayer:
    {
        LDA $0E40, X : AND.b #$20 : BEQ BRANCH_ALPHA
        
        LDY.b #$6A
        
        ; $3673C IN ROM
        JSR $E73C : BCC BRANCH_BETA
        
        INC $0E70, X
    
    BRANCH_BETA:
    
        RTS
    
    BRANCH_ALPHA:
    
        LDA $0F60, X : BMI BRANCH_GAMMA
        
        LDA $046C : BNE BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDY.b #$00
        
        LDA $0D40, X : BEQ BRANCH_EPSILON : BMI BRANCH_ZETA
        
        INY
    
    BRANCH_ZETA:
    
        JSR $E5EE   ; $365EE IN ROM
    
    BRANCH_EPSILON:
    
        LDY.b #$02
        
        LDA $0D50, X : BEQ BRANCH_THETA : BMI BRANCH_IOTA
        
        INY
    
    BRANCH_IOTA:
    
        JSR $E5B8   ; $365B8 IN ROM
    
    BRANCH_THETA:
    
        BRA BRANCH_KAPPA
    
    BRANCH_DELTA:
    
        LDY.b #$01
    
    BRANCH_LAMBDA:
    
        JSR $E5EE   ; $365EE IN ROM
        
        DEY : BPL BRANCH_LAMBDA
        
        LDY.b #$03
    
    BRANCH_MU:
    
        JSR $E5B8   ; $365B8 IN ROM
        
        DEY : CPY.b #$01 : BNE BRANCH_MU
    
    BRANCH_KAPPA:
    
        LDA $0BE0, X : BMI BRANCH_NU
        
        LDA $0F70, X : BEQ BRANCH_XI
    
    BRANCH_NU:
    
        RTS
    
    BRANCH_XI:
    
        LDY.b #$68
        
        JSR $E73C ; $3673C IN ROM
        
        LDA $0FA5 : STA $7FF9C2, X : CMP.b #$1C : BNE BRANCH_OMICRON
        
        LDY $0FB3 : BEQ BRANCH_OMICRON
        
        ; Is the enemy frozen?
        ; Nope
        LDY $0DD0, X : CPY.b #$0B : BNE BRANCH_OMICRON
        
        LDA.b #$01 : STA $0F20, X
        
        RTS
    
    BRANCH_OMICRON:
    
        CMP.b #$20 : BNE BRANCH_PI
        
        LDA $0B6B, X : AND.b #$01 : BEQ BRANCH_RHO
        
        LDA $1B : BNE BRANCH_SIGMA
        
        JMP $E0AB ; $360AB IN ROM
    
    BRANCH_SIGMA:
    
        LDA.b #$05 : STA $0DD0, X
        
        LDA.b #$5F
        
        ; is it a helmasaur?
        LDY $0E20, X : CPY.b #$13 : BEQ BRANCH_TAU
                       CPY.b #$26 : BNE BRANCH_UPSILON
    
    BRANCH_TAU:
    
        LSR $0F50, X : ASL $0F50, X
        
        LDA.b #$3F
    
    BRANCH_UPSILON:
    
        STA $0DF0, X
        
        RTS
    
    BRANCH_PI:
    
        CMP.b #$0C : BNE .not_mothula_moving_floor
        
        LDA $7FFABC, X : CMP.b #$1C : BNE BRANCH_PHI
        
        JSR $E624 ; $36624 IN ROM
        
        LDA $0E70, X : ORA.b #$20 : STA $0E70, X
        
        RTS
    
    .not_mothula_moving_floor
    BRANCH_RHO:
    
        CMP.b #$68 : BCC .not_conveyor_belt
        CMP.b #$6C : BCS .not_conveyor_belt
    
    BRANCH_PSI:
    
        TAY
        
        JSL Sprite_ApplyConveyorAdjustment
        
        RTS
    
    .not_conveyor_belt
    
        CMP.b #$08 : BNE BRANCH_PHI
        
        LDA $046C : CMP.b #$04 : BNE BRANCH_PHI
        
        ; I think this indicates that flowing water makes sprites move to the
        ; left in the same way a conveyor belt would.
        LDA.b #$6A
        
        BRA BRANCH_PSI
    
    BRANCH_PHI:
    
        RTS
    }

    ; *$365B8-$365ED LOCAL
    {
        ; $3672F IN ROM
        JSR $E72F : BCC BRANCH_ALPHA
        
        LDA $E723, Y : ORA $0E70, X : STA $0E70, X
        
        LDA $0E30, X : AND.b #$07 : CMP.b #$05 : BCS BRANCH_ALPHA
        
        LDA $0EA0, X : BEQ BRANCH_BETA
        
        ; \optimize If this code is reached, it's bound to be pretty damn slow.
        ; Mainly, it's calling the same code 3 times to do 3 additions, so
        ; why not just adjust the amounts in the table by a factor of 3?
        JSR .add_offset
        JSR .add_offset
    
    .add_offset
    
        LDA $0D10, X : ADD $E727, Y : STA $0D10, X
        LDA $0D30, X : ADC $E72B, Y : STA $0D30, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$365EE-$36623 LOCAL
    {
        ; $3672F IN ROM
        JSR $E72F : BCC .return
        
        LDA $E723, Y : ORA $0E70, X : STA $0E70, X
        
        LDA $0E30, X : AND.b #$07 : CMP.b #$05 : BCS .return
        
        LDA $0EA0, X : BEQ .add_offset
        
        ; \optimize If this code is reached, it's bound to be pretty damn slow.
        ; Mainly, it's calling the same code 3 times to do 3 additions, so
        ; why not just adjust the amounts in the table by a factor of 3?
        JSR .add_offset
        JSR .add_offset
    
    ; *$36610 ALTERNATE ENTRY POINT
    .add_offset
    
        LDA $0D00, X : ADD $E727, Y : STA $0D00, X
        LDA $0D20, X : ADC $E72B, Y : STA $0D20, X
    
    .return
    
        RTS
    }

    ; *$36624-$3664A LOCAL
    {
        LDA $0310 : ADD $0D00, X : STA $0D00, X
        LDA $0311 : ADC $0D20, X : STA $0D20, X
        LDA $0312 : ADD $0D10, X : STA $0D10, X
        LDA $0313 : ADC $0D30, X : STA $0D30, X
        
        RTS
    }

    ; $3664B-$36722 DATA
    {
        dw   8,   8,   2,  14,   8,   8,  -2,  10
        dw   8,   8,   1,  14,   4,   4,   4,   4
        dw   4,   4,  -2,  10,   8,   8, -25,  40
        dw   8,   8,   2,  14,   8,   8,  -8,  23
        dw   8,   8, -20,  36,   8,   8,  -1,  16
        dw   8,   8,  -1,  16,   8,   8,  -8,  24
        dw   8,   8,  -8,  24,   8,   3
    
    ; $366B7
        dw   6,  20,  13,  13,   0,   8,   4,   4
        dw   1,  14,   8,   8,   4,   4,   4,   4
        dw  -2,  10,   4,   4, -25,  40,   8,   8
        dw   3,  16,  10,  10,  -8,  25,   8,   8
        dw -20,  36,   8,   8,  -1,  16,   8,   8
        dw  14,   3,   8,   8,  -8,  24,   8,   8
        dw  -8,  32,   8,   8,  12,   4
    }

; ==============================================================================

    ; $36723-$3672E DATA
    {
    
        db 8,  4,  2,  1
    
    
        db 1, -1,  1, -1
    
    
        db 0, -1,  0, -1
    }
    
; ==============================================================================

    ; *$3672F-$3687A LOCAL
    {
        ; Seems that $08 is a value from 0 to 3 indicating the direction
        ; to check collision in... Pretty sure anyways.
        STY $08
        
        LDA $0B6B, X : AND.b #$F0 : LSR #2 : ADC $08 : ASL A : TAY
    
    ; *$3673C ALTERNATE ENTRY POINT
    
        LDA $1B : BEQ .outdoors
        
        REP #$20
        
        ; Load Y coordinate of sprite
        LDA $0FDA : ADD.w #8 : AND.w #$01FF : ADD $E6B7, Y
        
        SUB.w #8 : STA $00 : CMP.w #$0200 : BCS .out_of_bounds
        
        ; Load X coordinate of sprite
        LDA $0FD8 : ADC.w #8 : AND.w #$01FF : ADD $E64B, Y
        
        SUB.w #8 : STA $02 : CMP.w #$0200
        
        BRA .check_if_inbounds
    
    .outdoors
    
        ; Overworld handling of collision (against perimeter?)
        REP #$20
        
        LDA $0FDA : ADD $E6B7, Y : STA $00
        
        SUB $0FBE : CMP $0FBA : BCS .out_of_bounds
        
        LDA $0FD8 : ADD $E64B, Y : STA $02
        
        SUB $0FBC : CMP $0FB8
    
    .out_of_bounds
    .check_if_inbounds
    
        SEP #$20 : BCC .inbounds
        
        JMP $E852 ; $36852 IN ROM
    
    .inbounds
    
        JSR Sprite_GetTileAttrLocal
        
        TAY
        
        LDA $0CAA, X : AND.b #$08 : BEQ .dont_use_simplified_tile_collision
        
        PHX
        
        TYX
        
        LDY $08
        
        LDA Sprite_SimplifiedTileAttr, X
        
        PLX
        
        CMP.b #$04 : BEQ BRANCH_EPSILON
        CMP.b #$01 : BCC BRANCH_ZETA
        
        LDA $0FA5
        
        CMP.b #$10 : BCC .not_sloped_tile
        CMP.b #$14 : BCS .not_sloped_tile
        
        JSR Entity_CheckSlopedTileCollision
        JMP $E878 ; $36878 IN ROM
    
    .not_sloped_tile
    
        JMP $E872 ; $36872 IN ROM
    
    BRANCH_EPSILON:
    
        LDY $1B : BNE BRANCH_ZETA
        
        STA $0E90, X
    
    BRANCH_ZETA:
    
        JMP $E877 ; $36877 IN ROM
    
    .dont_use_simplified_tile_collision
    
        LDA $0BE0, X : ASL A : BPL BRANCH_IOTA
        
        LDA $0E20, X : CMP.b #$D2 : BEQ .flopping_fish
                       CMP.b #$8A : BNE .not_moving_spike_block
    
    .flopping_fish
    
        CPY.b #$09 : BEQ .shallow_water_tile
    
    .not_moving_spike_block
    
        CMP.b #$94 : BNE .not_pirogusu
        
        LDA $0E90, X : BEQ BRANCH_XI
        
        BRA BRANCH_IOTA
    
    .not_pirogusu
    
        CMP.b #$E3 : BEQ BRANCH_XI
        CMP.b #$8C : BEQ BRANCH_XI
        CMP.b #$9A : BEQ BRANCH_XI
        CMP.b #$81 : BNE BRANCH_IOTA
    
    BRANCH_XI:
    
        CPY.b #$08 : BEQ .deep_water_tile
        CPY.b #$09
    
    .shallow_water_tile
    
        BEQ BRANCH_OMICRON
        
        BRA BRANCH_PI
    
    BRANCH_IOTA:
    
        PHX
        
        TYX
        
        LDA $1DF6CF, X
        
        PLX
        
        LDY $08
        
        CMP.b #$00 : BEQ BRANCH_OMICRON
        
        LDA $0FA5
        
        CMP.b #$10 : BCC BRANCH_RHO
        CMP.b #$14 : BCS BRANCH_RHO
        
        JSR Entity_CheckSlopedTileCollision
        
        BRA BRANCH_SIGMA
    
    BRANCH_RHO:
    
        CMP.b #$44 : BNE .not_spike_tile
        
        LDA $0EA0, X : BEQ BRANCH_PI
        
        LDA $0CE2, X : BMI BRANCH_UPSILON
        
        LDA.b #$04 : JSL Ancilla_CheckSpriteDamage.preset_class
        
        LDA $0EF0, X : BEQ BRANCH_UPSILON
        
        LDA.b #$99 : STA $0EF0, X
        
        STZ $0EA0, X
    
    BRANCH_UPSILON:
    
        BRA BRANCH_PI
    
    ; *$36852 ALTERNATE ENTRY POINT
    
        JSR $E872 ; $36872 IN ROM
        
        LDA $0E40, X : ASL A : BPL BRANCH_PHI
        
        STZ $0DD0, X
        
        CLC
        
        RTS
    
    BRANCH_PHI:
    
        SEC
        
        RTS
    
    .not_spike_tile
    
        CMP.b #$20 : BNE .not_pit_tile
        
        LDA $0B6B, X : AND.b #$01 : BEQ BRANCH_PI
        
        LDA $0EA0, X : BNE BRANCH_OMICRON
    
    ; *$36872 ALTERNATE ENTRY POINT
    .not_pit_tile
    BRANCH_PI:
    
        SEC
        
        SEP #$21
        
        BRA BRANCH_SIGMA
    
    ; *$36877 ALTERNATE ENTRY POINT
    BRANCH_OMICRON:
    .deep_water_tile
    
        CLC
    
    ; *$36878 ALTERNATE ENTRY POINT
    BRANCH_SIGMA:
    
        LDY $08
        
        RTS
    }

; ==============================================================================

    ; *$3687B-$36882 LONG
    Entity_GetTileAttr:
    {
        PHB : PHK : PLB
        
        JSR Entity_GetTileAttrLocal
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$36883-$368D5 LOCAL
    Sprite_GetTileAttrLocal:
    {
        ; Notes:
        ; $00[0x02] - Entity Y coordinate
        ; $02[0x03] - Entity X coordinate
        
        LDA $0F20, X ; Floor selector for sprites
    
    ; *$36886 ALTERNATE ENTRY POINT
    shared Entity_GetTileAttrLocal:
    
        CMP.b #$01 : REP #$30 : STZ $05 : BCC .on_bg2
        
        LDA.w #$1000 : STA $05
    
    .on_bg2
    
        LDA $1B : AND.w #$00FF : BEQ .outdoors
        
        ; Horizontal Position
        LDA $02 : AND.w #$01FF : LSR #3 : STA $04
        
        ; Vertical position
        LDA $00 : AND.w #$01F8 : ASL #3 : ADD $04 : ADD $05
        
        PHX
        
        TAX
        
        ; Retrieve tile type
        LDA $7F2000, X : PLX : SEP #$30 : STA $0FA5
        
        RTS
    
    .outdoors
    
        LDA $02 : LSR #3 : STA $02
        
        SEP #$10
        
        PHX : PHY
        
        JSL Overworld_GetTileAttrAtLocation : SEP #$30 : STA $0FA5
        
        PLY : PLX
        
        RTS
    }

; ==============================================================================

    ; $368D6-$368F5 DATA
    pool Entity_CheckSlopedTileCollision:
    {
    
    .subtile_boundaries
        db 7, 6, 5, 4, 3, 2, 1, 0
        db 0, 1, 2, 3, 4, 5, 6, 7
        db 0, 1, 2, 3, 4, 5, 6, 7
        db 7, 6, 5, 4, 3, 2, 1, 0
    }

; ==============================================================================

    ; *$368F6-$368FD LONG
    Entity_CheckSlopedTileCollisionLong:
    {
        PHB : PHK : PLB
        
        JSR Entity_CheckSlopedTileCollision
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \note Has to do with tile detection on tiles that have a slope to them
    ; (digonally)
    ; \task go into more detail figuring out how this works now that we have
    ; a foothold.
    ; *$368FE-$3692B LOCAL
    Entity_CheckSlopedTileCollision:
    {
        ; Not sure what this routine does
        
        LDA $00 : AND.b #$07 : STA $04 ; $04 = ($00 & 0x07)
        LDA $02 : AND.b #$07 : STA $05 ; $05 = ($02 & 0x07)
        
        ; tile type that was detected in the previous routine ($36883 most likely)
        ; $06 = ($0FA5 - 0x10)
        ; \bug Maybe a bug.... what tile attributes are supposed to be used
        ; with this routine? Inspection suggests 0x18 through 0x1b, but this
        ; routine seems designed for 0x10 through 0x13. Hardly comforting...
        LDA $0FA5 : SUB.b #$10 : STA $06
        
        ; Y = ($06 << 3) + $05
        ASL #3 : ADD $05 : TAY
        
        ; If original attribute was between 0x10 and 0x12
        LDA $06 : CMP.b #$02 : BCC .alpha
        
        LDA $04 : CMP .subtile_boundaries, Y
        
        BRA .beta
    
    .alpha
    
        LDA .subtile_boundaries, Y : CMP $04
    
    .beta
    
        RTS
    }

; ==============================================================================

    ; \optimize Has been identified as time consuming (relative to what it
    ; does in real terms). Similar functions in other banks will have
    ; similar performance.
    ; *$3692C-$36931 LOCAL
    Sprite_Move:
    {
        JSR .do_horiz
        JMP .do_vert
        
    ; *$36932-$3693D LOCAL
    shared Sprite_MoveHoriz:
    
    .do_horiz
    
        ; Do X position adjustment
        TXA : ADD.b #$10 : TAX
          
        JSR Sprite_MoveVert
        
        ; Reset sprite index so that we can do the Y position adjustment next.
        LDX $0FA0
        
        RTS
    
    .do_vert
    
    ; *$3693E-$3696B LOCAL
    shared Sprite_MoveVert:
    
        LDA $0D40, X : BEQ .return
        
        ASL #4 : ADD $0D60, X : STA $0D60, X
        
        LDA $0D40, X : PHP : LSR #4 : LDY.b #$00 : PLP : BPL .positive
        
        ORA.b #$F0
        
        DEY
    
    .positive
    
              ADC $0D00, X : STA $0D00, X
        TYA : ADC $0D20, X : STA $0D20, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$3696C-$3698D LOCAL
    Sprite_MoveAltitude:
    {
        ; Do... altitude adjustment...?
        
        LDA $0F80, X : ASL #4 : ADD $0F90, X : STA $0F90, X
        
        LDA $0F80, X : PHP : LSR #4 : PLP : BPL .positive
        
        ORA.b #$F0
    
    .positive
    
        ADC $0F70, X : STA $0F70, X
        
        RTS
    }

; ==============================================================================

    ; *$3698E-$36990 BRANCH LOCATION
    Sprite_ProjectSpeedTowardsPlayer_return:
    {
        STZ $00
        
        RTS
    }

; ==============================================================================

    ; *$36991-$36A03 LOCAL
    Sprite_ProjectSpeedTowardsPlayer:
    {
        ; Calculates a trajectory with a given magnitude.... but there's some
        ; broke ass trigonometry going on up in this bitch. Replacing
        ; this with the lookup tables in the dark prophecy hack could be
        ; a good idea.
        
        ; $01 is the magnitude or force of the trajectory. i should probably
        ; look up technical definitions of words like trajectory one of these
        ; days...
        
        STA $01 : CMP.b #$00 : BEQ Sprite_ProjectSpeedTowardsPlayer_return
        
        PHX : PHY
        
        JSR Sprite_IsBelowPlayer : STY $02
        
        ; Difference in the low Y coordinate bytes.
        LDA $0E : BPL .positive_1
        
        EOR.b #$FF : INC A
        ; Essentially, multiply by negative one, or in this context, absolute value.
    
    .positive_1
    
        ; $0C = |$0E| = |dY|
        STA $0C
        
        JSR Sprite_IsToRightOfPlayer : STY $03
        
        ; The difference in the low X coordinate bytes.
        LDA $0F : BPL .positive_2
        
        EOR.b #$FF : INC A
    
    .positive_2
    
        ; $0D = |$0F| = |dX|
        STA $0D
        
        LDY.b #$00
        
        ; If |dX| > |dY|
        LDA $0D : CMP $0C : BCS .dx_is_bigger
        
        ; Flag indicating |dY| >= |dX|
        INY
        
        ; |dX| -> Stack; |dY| -> $0D ; |dX| -> $0C.
        ; Either way, the larger value will end up at $0D
        PHA : LDA $0C : STA $0D
        PLA           : STA $0C
    
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
        
        LDA $00 : PHA
        LDA $01 : STA $00
        PLA     : STA $01
    
    .dx_is_bigger_2
    
        LDA $00
        
        LDY $02 : BEQ .polarity_already_correct_1
        
        EOR.b #$FF : INC A : STA $00
    
    .polarity_already_correct_1
    
        LDA $01
        
        LDY $03 : BEQ .polarity_already_correct_2
        
        EOR.b #$FF : INC A : STA $01
    
    .polarity_already_correct_2
    
        PLY : PLX
        
        RTS
    }

; ==============================================================================

    ; *$36A04-$36A11 LOCAL
    Sprite_ApplySpeedTowardsPlayer:
    {
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : STA $0D40, X
        LDA $01 : STA $0D50, X
        
        RTS
    }

; ==============================================================================

    ; *$36A12-$36A19 LONG
    Sprite_ApplySpeedTowardsPlayerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_ApplySpeedTowardsPlayer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$36A1A-$36A21 LONG
    Sprite_ProjectSpeedTowardsPlayerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$36A22-$36A29 LONG
    Sprite_ProjectSpeedTowardsEntityLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_ProjectSpeedTowardsEntity
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$36A2A-$36A2C BRANCH LOCATION
    pool Sprite_ProjectSpeedTowardsEntity:
    {
    
    .return
        STZ $00
        
        RTS
    }

; ==============================================================================

    ; *$36A2D-$36A9F LOCAL
    Sprite_ProjectSpeedTowardsEntity:
    {
        STA $01 : CMP.b #$00 : BEQ .return
        
        PHX : PHY
        
        JSR Sprite_IsBelowEntity : STY $02
        
        LDA $0E : BPL .positive_1
        
        EOR.b #$FF : INC A
    
    .positive_1
    
        STA $0C
        
        JSR Sprite_IsToRightOfEntity : STY $03
        
        LDA $0F : BPL .positive_2
        
        EOR.b #$FF : INC A
    
    .positive_2
    
        STA $0D
        
        LDY.b #$00
        
        LDA $0D : CMP $0C : BCS .dx_is_bigger
        
        INY
        
        PHA
        
        LDA $0C : STA $0D
        
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
        
        LDA $00 : PHA
        LDA $01 : STA $00
        PLA     : STA $01
    
    .dx_is_bigger_2
    
        LDA $00
        
        LDY $02 : BEQ .polarity_already_correct_1
        
        EOR.b #$FF : INC A : STA $00
    
    .polarity_already_correct_1
    
        LDA $01
        
        LDY $03 : BEQ .polarity_already_correct_2
        
        EOR.b #$FF : INC A : STA $01
    
    .polarity_already_correct_2
    
        PLY : PLX
        
        RTS
    }

; ==============================================================================

    ; *$36AA0-$36AA3 LONG
    Sprite_DirectionToFacePlayerLong:
    {
        JSR Sprite_DirectionToFacePlayer
        
        RTL
    }

; ==============================================================================

    ; *$36AA4-$36ACC LOCAL
    ; \return       $0E is low byte of player_y_pos - sprite_y_pos
    ; \return       $0F is low byte of player_x_pos - sprite_x_pos
    Sprite_DirectionToFacePlayer:
    {
        JSR Sprite_IsToRightOfPlayer : STY $00
        JSR Sprite_IsBelowPlayer     : STY $01
        
        LDA $0E : BPL .positive_1
        
        EOR.b #$FF : INC A
    
    .positive_1
    
        STA $0FB5
        
        LDA $0F : BPL .positive_2
        
        EOR.b #$FF : INC A
    
    .positive_2
    
        ; Compares absolute values of dx and dy
        CMP $0FB5 : BCC .dy_is_bigger
        
        LDY $00
        
        RTS
    
    .dy_is_bigger
    
        LDA $01 : INC #2 : TAY
        
        RTS
    }

; ==============================================================================

    ; *$36ACD-$36AD0 LONG
    Sprite_IsToRightOfPlayerLong:
    {
        JSR Sprite_IsToRightOfPlayer
        
        RTL
    }

; ==============================================================================

    ; *$36AD1-$36AE3 LOCAL
    Sprite_IsToRightOfPlayer:
    {
        LDY.b #$00
        
        ; Link X - Sprite X
        LDA $22 : SUB $0D10, X : STA $0F
        LDA $23 : SBC $0D30, X : BPL .same_or_to_left
        
        ; If Link is to the left of the sprite, Y = 1, otherwise Y = 0.
        INY
    
    .same_or_to_left
    
        RTS
    }

; ==============================================================================

    ; *$36AE4-$36AE7 LONG
    Sprite_IsBelowPlayerLong:
    {
        JSR Sprite_IsBelowPlayer
        
        RTL
    }

; ==============================================================================

    ; \return Y=0 sprite is above or level with player
    ; \return Y=1 sprite is below player
    ; *$36AE8-$36B09 LOCAL
    Sprite_IsBelowPlayer:
    {
        LDY.b #$00
        
        ; The additional 8 pixels I'm sure is to help simulate relative
        ; perspective. The altitude of the sprite is also factored in.
        LDA $20 : ADD.b #$08   : PHP 
                  ADD $0F70, X : PHP
                  SUB $0D00, X : STA $0E
        
        ; The higher byte of Link's Y coordinate
        ; The difference in their higher bytes. 
        ; Offset if Link is crossing a 0x0100 pixel boundary.
        LDA $21 : SBC $0D20, X
        PLP     : ADC.b #$00
        PLP     : ADC.b #$00   : BPL .same_or_above
        
        ; Link is above the sprite and therefore...
        ; The sprite is below the player.
        INY
    
    .same_or_above
    
        RTS
    }

; ==============================================================================

    ; *$36B0A-$36B1C LOCAL
    Sprite_IsToRightOfEntity:
    {
        ; $04 = X coordinate of an entity
        
        LDY.b #$00
        
        LDA $04 : SUB $0D10, X : STA $0F
        LDA $05 : SBC $0D30, X : BPL .same_or_to_left
        
        INY
    
    .same_or_to_left
    
        RTS
    }

; ==============================================================================

    ; *$36B1D-$36B2F LOCAL
    Sprite_IsBelowEntity:
    {
        ; $06 = coordinate of an entity
        
        LDY.b #$00
        
        LDA $06 : SUB $0D00, X : STA $0E
        LDA $07 : SBC $0D20, X : BPL .entityIsBelow
        
        INY
    
    .entityIsBelow
    
        RTS
    }

; ==============================================================================

    ; $36B30-$36B5D LONG
    Sprite_DirectionToFaceEntity:
    {
        PHB : PHK : PLB
        
        JSR Sprite_IsToRightOfEntity : STY $00
        JSR Sprite_IsBelowEntity     : STY $01
        
        LDA $0E : BPL .positive_1
        
        EOR.b #$FF : INC A
    
    .positive_1
    
        STA $0FB5
        
        LDA $0F : BPL .positive_2
        
        EOR.b #$FF : INC A
    
    .positive_2
    
        ; Compares absolute values of dx and dy
        CMP $0FB5 : BCC .dy_is_bigger
        
        LDY $00
        
        PLB
        
        RTL
    
    .dy_is_bigger
    
        LDA $01 : INC #2 : TAY
        
        PLB
        
        RTL
    }

    ; *$36B5E-$36B65 LONG
    {
        PHB : PHK : PLB
        
        JSR $EB76 ; $36B76 IN ROM
        
        PLB
        
        RTL
    }

    ; *$36B76-$36C5B LOCAL
    {
        ; Exclusively called by soldier like enemies... but not sure why...?
        
        LDA $EE : CMP $0F20, X : BNE .not_on_player_layer
        
        LDA $46 : ORA $4D
    
    .not_on_player_layer
    
                       BNE .return
        LDA $0EF0, X : BMI .return
        
        JSR $F645 ; $37645 IN ROM
        
        LDA $037A : AND.b #$10 : BNE BRANCH_GAMMA
        
        LDA $44 : CMP.b #$80 : BEQ BRANCH_GAMMA
        
        JSR Player_SetupActionHitBox
        
        LDA $3C : BMI BRANCH_DELTA
        
        JSR Utility_CheckIfHitBoxesOverlap : BCC BRANCH_DELTA
        
        LDA $0E20, X : CMP.b #$6A : BEQ BRANCH_EPSILON
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $EB66, Y : STA $0EA0, X
    
    BRANCH_EPSILON:
    
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $EB6E, Y : STA $46
        
        LDA.b #$18
        
        LDY $3C : CPY.b #$09 : BPL BRANCH_ZETA
        
        LDA.b #$20
    
    BRANCH_ZETA:
    
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : EOR.b #$FF : INC A : STA $0F30, X
        LDA $01 : EOR.b #$FF : INC A : STA $0F40, X
        
        LDA.b #$10
        
        LDY $3C : CPY.b #$09 : BPL BRANCH_THETA
        
        LDA.b #$08
    
    BRANCH_THETA:
    
        JSR Sprite_ApplyRecoilToPlayer
        JSR Player_PlaceRepulseSpark
        
        LDA.b #$90 : STA $47
    
    .return
    
        RTS
    
    BRANCH_DELTA:
    
        JSR Sprite_SetupHitBox
        
        JSR Utility_CheckIfHitBoxesOverlap : BCS BRANCH_IOTA
    
    BRANCH_GAMMA:
    
        JML Sprite_StaggeredCheckDamageToPlayerPlusRecoil
    
    ; *$36C02 ALTERNATE ENTRY POINT
    BRANCH_IOTA:
    
        LDA $0E20, X
        
        CMP.b #$7A : BEQ .attempt_electrocution
        CMP.b #$0D : BNE .not_buzzblob
        
        LDA $7EF359 : CMP.b #$04 : BCC .attempt_electrocution
    
    .not_buzzblob
    
        ; \bug If we reach here from the comparison with the sword value,
        ; well.... we're not comparing apples to apples.
        CMP.b #$24 : BEQ .is_bari_or_biri
        CMP.b #$23 : BNE .not_bari_or_biri
    
    .is_bari_or_biri
    
        LDA $0DF0, X : BEQ .cant_electrocute
    
    .attempt_electrocution
    
        ; But if the sprite's not active, it can't electrocute.
        LDA $0DD0, X : CMP.b #$09 : BNE .cant_electrocute
        
        LDA $031F : BNE .player_blinking_invulnerable
        
        LDA.b #$40 : STA $0E00, X
                     STA $0360
        
        JSR $F3DB ; $373DB IN ROM
    
    .player_blinking_invulnerable
    
        RTS
    
    .cant_electrocute
    .not_bari_or_biri
    
        LDA.b #$50
        
        LDY $3C : CPY.b #$09 : BMI BRANCH_OMICRON
        
        LDA.b #$40
    
    BRANCH_OMICRON:
    
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : EOR.b #$FF : INC A : STA $0F30, X
        LDA $01 : EOR.b #$FF : INC A : STA $0F40, X
        
        JSL $06ED3F ; $36D3F IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$36C5C-$36C7D LONG
    Medallion_CheckSpriteDamage:
    {
        ; Exclusively called by Medallion code
        
        LDA $0C4A, X : STA $0FB5
        
        LDX.b #$0F
    
    .next_sprite
    
        LDA $0DD0, X : CMP.b #$09 : BCC .inactive_sprite
        
        LDA $0BA0, X : ORA $0F00, X : BNE .inactive_sprite
        
        LDA $0FB5 : JSL Ancilla_CheckSpriteDamage.override
    
    .inactive_sprite
    
        DEX : BPL .next_sprite
        
        RTL
    }

; ==============================================================================

    ; $36C7E-$36CB6 DATA
    pool Ancilla_CheckSpriteDamage:
    {
    
    .damage_classes
        db 6,  1, 11,  0,  0,  0,  0,  8,  0,  6,  0, 12,  1,  0,  0,  0
        db 0,  1,  0,  0,  0,  0,  0,  0, 14, 13,  0,  0, 15,  0,  0,  7
        db 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 11
        db 0,  1,  1,  1,  1,  1,  1,  1,  1
    }

; ==============================================================================

    ; *$36CB7-$36D32 LONG
    Ancilla_CheckSpriteDamage:
    {
        LDY $0EF0, X : BPL .sprite_not_already_dying
        
        RTL
    
    ; \note It's called override because apparently it ignores the death timer
    ; status of the affected sprite.
    ; *$36CBD ALTERNATE ENTRY POINT
    .override
    .sprite_not_already_dying

        PHX
        
        TAX
        
        LDA.l .damage_classes, X
        
        PLX
        
        CMP.b #$06 : BNE .not_arrow_damage_class
        
        ; Do we have silver arrows?
        PHA : LDA $7EF340 : CMP.b #$03
        PLA :               BCC .not_arrow_damage_class
        
        ; Is this Ganon?
        ; \task Go back and check if this means he's invincible, or just
        ; arrow prone (to deathing).
        LDA $0E20, X : CMP.b #$D7 : BNE .not_invincible_ganon
        
        ; Set damage timer? (In the event it's the arrow-vulnerable Ganon)
        LDA.b #$20 : STA $0F10, X
    
    .not_invicible_ganon
    
        LDA.b #$09
    
    ; \task Should this really be in the Ancilla namespace? Perhaps this and
    ; its brethen should be in the Sprite_ namespace and flip around the
    ; ancilla part so it's taking damage from an ancilla or damage class.
    ; *$36CE0 ALTERNATE ENTRY POINT
    .preset_class
    .not_arrow_damage_class
    
        CMP.b #$0F : BNE .not_quake_spell
        
        LDY $0F70, X : BEQ .quake_only_affects_enemy_on_ground
        
        ; Dem's tha breaks, kiddo.
        RTL
    
    .quake_only_affects_enemy_on_ground
    .not_quake_spell
    
        CMP.b #$00 : BEQ .boomerang_or_hookshot_class
        CMP.b #$07 : BNE .not_boomerang_or_hookshot
    
    .boomerang_or_hookshot_class
    
        JSL .apply_damage
        
        LDA $0CE2, X : BNE .dont_spawn_repulse_spark
        
        LDA $0FAC : BNE .dont_spawn_repulse_spark
        
        LDA.b #$05 : STA $0FAC
        
        LDY $0FB6
        
        LDA $0C04, Y : ADC.b #$04 : STA $0FAD
        
        LDA $0BFA, Y : STA $0FAE
        
        LDA $EE : STA $0B68
        
        STZ $012E
        
        LDA.b #$05 : JSL Sound_SetSfx2PanLong

    .dont_spawn_repulse_spark

        RTL
    
    ; *$36D25 ALTERNATE ENTRY POINT
    .apply_damage
    .not_boomerang_or_hookshot

        STA $0CF2 : TAY
        
        LDA.b #$20
        
        CPY.b #$08 : BNE .not_bomb_class
        
        ; Cause the sprite to recoil more from bomb damage, right?
        LDA.b #$35

    .not_bomb_class

        BRA BRANCH_$36D89
    }

; ==============================================================================

    ; $36D33-$36D3E DATA TABLE
    {
        db 1, 2, 3, 4 ; normal strike damage indices
        db 2, 3, 4, 5 ; spin attack damage indices
        db 1, 1, 2, 3 ; stabbing damage indices
    }

    ; *$36D3F-$36EC0 LONG
    {
        ; If bit 6 is set, sprite is invincible.
        LDA $0E60, X : AND.b #$40 : BEQ .notImpervious
        
        RTL
    
    .notImpervious
    
        LDA $0372 : STA $7FFA4C, X
        
        PHX
        
        ; Load Link's sword type.
        LDA $7EF359 : DEC A
        
        LDX $0372 : BNE .notStabbingDamageType
        
        BRA .checkSwordCharging
    
    .doingSpinAttack
    
        ORA.b #$04
        
        BRA .notStabbingDamageType
    
    .checkSwordCharging
    
        ; How long has Link's sword been stuck out?
        LDX $3C    : BMI .doingSpinAttack       ; If negative, he's doing a spin attack.
        CPX.b #$09 : BMI .notStabbingDamageType ; Branch if less than 9.
        
        ORA.b #$08 ; Otherwise it gets a stabbing indicator.
    
    .notStabbingDamageType
    
        TAX
        
        ; Set the damage class.
        LDA $06ED33, X : STA $0CF2
        
        ; not sure which item types this indicates
        LDA $0301 : AND.b #$0A : BEQ .not_poised_with_hammer
        
        LDA.b #$03 : STA $0CF2
    
    .not_poised_with_hammer
    
        ; Set a timer
        LDA.b #$04 : STA $02E3
        
        PLX
        
        LDA.b #$10 : STA $47
        
        LDA.b #$9D
    
    ; *$36D89 ALTERNATE ENTRY POINT
    
        STA $00
        
        STZ $0CF3
        
        LDA $0E60, X : AND.b #$40 : BNE .impervious
        
        LDA.b #$00 : XBA
        
        LDA $0E20, X : CMP.b #$D8 : BCC .notItemSprite
    
    .impervious
    
        RTL
    
    .notItemSprite
    
        REP #$20 : ASL #4 : ORA $0CF2 : PHX : REP #$10 : TAX
        
        SEP #$20
        
        LDA $7F6000, X : STA $02
        
        SEP #$10
        
        ; (Damage class << 3) | monster
        LDA $0CF2 : ASL #3 : ORA $02 : TAX
        
        ; Get the damage value for that monster for that damage class... bah...
        LDA $0DB8F1, X
        
        PLX
    
    ; $36DC5 ALTERNATE ENTRY POINT
    
        CMP.b #$F9 : BNE .dontMakeIntoFaerie
        
        ; Turn something into a faerie
        LDA.b #$E3
    
    ; *$36DCB ALTERNATE ENTRY POINT
    
        STA $0E20, X
        
        JSL Sprite_LoadProperties
        JSL Sprite_SpawnPoofGarnish
        
        STZ $012F
        
        LDA.b #$32 : JSL Sound_SetSfx3PanLong
        
        JMP $EEC1   ; $36EC1 IN ROM
    
    .dontMakeIntoFaerie
    
        ; Turn something into a 0 HP blob
        CMP.b #$FA : BNE .dontMakeIntoBlob
        
        LDA.b #$8F
        
        JSL $06EDCB ; $36DCB IN ROM
        
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$08 : STA $0F50, X
        
        STZ $0EA0, X
        STZ $0EF0, X
        STZ $0E50, X
        
        LDA.b #$01 : STA $0CD2, X : STA $0BE0, X
        
        RTL
    
    .dontMakeIntoBlob
    
        CMP $0CE2, X : BCC .ifNewDamageLessIgnore
        
        ; if(calc_dmg < base_dmg) dmg = base_dmg
        STA $0CE2, X
    
    .ifNewDamageLessIgnore
    
        CMP.b #$00 : BNE .notZeroDamageType
        
        LDA $0CF2 : CMP.b #$0A : BEQ BRANCH_THETA
        
        LDA $0B6B, X : AND.b #$04 : BNE BRANCH_IOTA
        
        STZ $02E3
    
    BRANCH_THETA:
    
        JMP $EEC1 ; $36EC1 IN ROM; magic powder damage?
    
    .notZeroDamageType
    
        ; Freeze damage type
        CMP.b #$FE : BCC BRANCH_KAPPA
        
        ; Is sprite frozen? if so, do nothing
        LDA $0DD0, X : CMP.b #$0B : BEQ BRANCH_THETA
    
    BRANCH_KAPPA:
    
        ; Is it a water bubble (in swamp palace)
        LDA $0E20, X : CMP.b #$9A : BNE .not_water_bubble
        
        LDY $0CE2, X : CPY.b #$F0 : BCS BRANCH_LAMBDA
        
        LDA.b #$09 : STA $0DD0, X
        
        LDA.b #$04 : STA $0D80, X
        
        LDA.b #$0F : STA $0DF0, X
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
        
        RTL
    
    .not_water_bubble
    BRANCH_LAMBDA:
    
        CMP.b #$1B : BNE .not_arrow_in_wall
    
    ; *$36E60 ALTERNATE ENTRY POINT
    
        LDA.b #$05 : JSL Sound_SetSfx2PanLong
        
        JSR Sprite_ScheduleForBreakage
        JSL Sprite_PlaceRupulseSpark
        
        RTL
    
    .not_arrow_in_wall
    
        PHA
        
        LDA $00 : STA $0EF0, X
        
        PLA : CMP.b #$92 : BNE .not_helmasaur_king
        
        LDA $0DB0, X : CMP.b #$03 : BCC .no_sound_effect
        
        LDY.b #$21
        
        LDA $0B6B, X : AND.b #$02 : BNE .boss_damage_sound
    
    .not_helmasaur_king
    
        LDY.b #$08
        
        LDA $0BE0, X : AND.b #$10 : BEQ .minor_damage_sound
        
        LDY.b #$1C
    
    .minor_damage_sound
    .boss_damage_sound
    
        STY $01 : JSL Sound_SetSfxPan : ORA $01 : STA $012F
    
    .no_sound_effect
    
        LDA.b #$00
        
        LDY $0CF2 : CPY.b #$0D : BCS .medallion_damage_class
        
        LDY $0E20, X : LDA.b #$14 : CPY.b #$09 : BEQ .giant_moldorm
                       LDA.b #$0F : CPY.b #$53 : BEQ .armos_knight
                                    CPY.b #$18 : BNE .not_moldorm
    
    .armos_knight
    
        LDA.b #$0B
    
    .giant_moldorm
    .not_moldorm
    .medallion_damage_class
    
        STA $0EA0, X
        
        RTL
    }

    ; *$36EC1-$36EC7 JUMP LOCATION LONG
    {
        STZ $0EF0, X
        STZ $0CE2, X
        
        RTL
    }

    ; *$36EC8-$36F60 LOCAL
    {
        ; Is the sprite alive?
        LDA $0DD0, X : CMP.b #$09 : BCC .not_fully_active_sprite
        
        ; Store this value in a temporary location.
        STA $0FB5
        
        LDA $0CE2, X : CMP.b #$FD : BNE .not_burn_damage
        
        STZ $0CE2, X
        
        LDA.b #$09 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$07 : STA $0DD0, X
        
        LDA.b #$70 : STA $0DF0, X
        
        LDA $0E40, X : INC #2 : STA $0E40, X
        
        STZ $0CE2, X
    
    .not_fully_active_sprite
    BRANCH_ALPHA:
    
        RTS
    
    .not_burn_damage
    
        CMP.b #$FB : BCC BRANCH_36F61 ; damage routine
        
        STZ $0CE2, X
        
        STA $00
        
        LDY $0DD0, X : CPY.b #$0B : BEQ BRANCH_ALPHA
        
        LDY.b #$00
        
        CMP.b #$FE : BNE BRANCH_GAMMA
        
        INY
    
    BRANCH_GAMMA:
    
        TYA : STA $7FFA3C, X : BEQ BRANCH_DELTA
        
        LDA $0CAA, X : ORA.b #$08 : STA $0CAA, X
        
        ASL $0BE0, X : LSR $0BE0, X
        
        LDA.b #$0F : JSL Sound_SetSfx2PanLong
        
        LDA.b #$18 : STA $0F80, X
        
        ASL $0CD2, X : LSR $0CD2, X
        
        JSR Sprite_Zero_XY_Velocity
    
    BRANCH_DELTA:
    
        LDA.b #$0B : STA $0DD0, X
        LDA.b #$40 : STA $0DF0, X
        
        LDA $00 : ADD.b #$05 : TAY
        
        ; \bug(unconfirmed) This seems destined for failure, unless I'm missing
        ; something.
        LDA .stun_timer_amounts, Y : STA $0B58, X
        
        LDA $0E20, X : CMP.b #$23 : BNE BRANCH_EPSILON
        
        ; \task Figure out what the hell this means? Stunning a blue onoff makes
        ; them turn into a red one? What?
        INC A : STA $0E20, X
    
    BRANCH_EPSILON:
    
        JMP $EFE7 ; $36FE7 IN ROM (RTS)
    
    .stun_timer_amounts
        db 32, 128,  0,  0, 255
    }

; ==============================================================================

    ; *$36F61-$370AB BRANCH LOCATION
    {
        LDA $0E50, X : STA $00
        
        ; Subtract off an amount from the enemies HP.
        SUB $0CE2, X : STA $0E50, X
        
        STZ $0CE2, X
        
        BEQ BRANCH_ALPHA : BCS BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $0CBA, X : BNE BRANCH_GAMMA
        
        LDA $0DD0, X : CMP.b #$0B : BNE BRANCH_DELTA
        
        LDA.b #$03 : STA $0CBA, X
    
    BRANCH_DELTA:
    
        LDA $7FFA4C, X : BEQ BRANCH_GAMMA
        
        LDA.b #$00 : STA $7FFA4C, X
        
        STZ $0BE0, X
    
    BRANCH_GAMMA:
    
        LDY $0E20, X : CPY.b #$1B : BEQ BRANCH_EPSILON
        
        LDA.b #$09 : JSL Sound_SetSfx3PanLong
    
    BRANCH_EPSILON:
    
        CPY.b #$40 : BNE BRANCH_ZETA
        
        PHX
        
        LDX $8A
        
        LDA $7EF280, X : ORA.b #$40 : STA $7EF280, X
        
        PLX
    
    BRANCH_ZETA:
    
        TYA : CMP.b #$EC : BNE BRANCH_THETA
        
        LDY $0DB0, X : CPY.b #$02 : BNE BRANCH_BETA
        
        JMP $E239 ; $36239 IN ROM
    
    BRANCH_THETA:
    
        PHA
        
        LDA $0DD0, X : CMP.b #$0A : BNE BRANCH_IOTA
        
        STZ $0308
        STZ $0309
    
    BRANCH_IOTA:
    
        LDA.b #$06 : STA $0DD0, X
        
        PLA : CMP.b #$0C : BNE BRANCH_KAPPA
    
    ; *$36FDA ALTERNATE ENTRY POINT
    shared Sprite_ScheduleForDeath:
    
        LDA.b #$06 : STA $0DD0, X
        LDA.b #$1F : STA $0DF0, X
        
        JSR $E095 ; $36095 IN ROM
    
    BRANCH_BETA:
    
        RTS
    
    BRANCH_KAPPA:
    
        CMP.b #$92 : BNE BRANCH_LAMBDA
        
        JSL Sprite_SchedulePeersForDeath
        
        LDA.b #$FF : STA $0DF0, X
        
        JMP $F087 ; $37087 IN ROM
    
    BRANCH_LAMBDA:
    
        CMP.b #$CB : BNE .not_main_trinexx_head
        
        JMP Trinexx_ScheduleMainHeadForDeath
    
    .not_main_trinexx_head
    
        CMP.b #$CC : BEQ .trinexx_side_head
        CMP.b #$CD : BNE .not_trinexx_side_head
    
    .trinexx_side_head
    
        JMP Trinexx_ScheduleSideHeadForDeath
    
    .not_trinexx_side_head
    
        CMP.b #$53 : BEQ BRANCH_OMICRON
        CMP.b #$54 : BEQ BRANCH_PI
        CMP.b #$09 : BEQ BRANCH_RHO
        CMP.b #$7A : BNE .not_agahnim_death
        
        JMP Agahnim_ScheduleForDeath
    
    .not_agahnim_death
    
        CMP #$23 : BEQ .red_bari
        CMP #$0F : BNE BRANCH_UPSILON
    
    ; *$37025 ALTERNATE ENTRY POINT
    shared Octoballoon_ScheduleForDeath:
    
        STZ $0EF0, X
        
        LDA.b #$0F : STA $0DF0, X
        
        RTS
    
    BRANCH_UPSILON:
    
        LDA $0B6B, X : AND.b #$02 : BNE BRANCH_PHI
        
        LDA $0EF0, X : ASL A
        
        LDA.b #$0F : BCC BRANCH_CHI
        
        LDA.b #$1F
    
    BRANCH_CHI:
    
        STA $0DF0, X
        
        JMP $F10B ; $3710B IN ROM
        
        RTS
    
    BRANCH_RHO:
    
        LDA.b #$03 : STA $0D80, X
        
        LDA.b #$A0 : STA $0F10, X
        
        LDA.b #$09 : STA $0DD0, X
        
        BRA BRANCH_PSI
    
    BRANCH_PHI:
    
        ; Check if it's Kholdstare
        LDA $0E20, X : CMP.b #$A2 : BEQ BRANCH_OMEGA
        
        JSL Sprite_SchedulePeersForDeath
    
    BRANCH_OMEGA:
    
        LDA.b #$04 : STA $0DD0, X
        
        STZ $0D90, X
        
        LDA.b #$FF
    
    BRANCH_ALTIMA:
    
        STA $0DF0, X : STA $0EF0, X
        
        BRA BRANCH_PSI
    
    BRANCH_PI:
    
        LDA.b #$05 : STA $0D80, X
        
        LDA.b #$C0
        
        BRA BRANCH_ALTIMA
    
    BRANCH_OMICRON:
    
        LDA.b #$23 : STA $0DF0, X
        
        STZ $0EF0, X
        
        BRA BRANCH_ULTIMA
    
    ; *$37087 ALTERNATE ENTRY POINT
    BRANCH_PSI:
    
        INC $0FFC
    
    BRANCH_ULTIMA:
    
        STZ $012F
        
        LDA.b #$22 : JSL Sound_SetSfx3PanLong
        
        RTS
    
    .red_bari
    
        ; If nonzero, can't split again because it's a small red bari.
        LDA $0DB0, X : BNE BRANCH_UPSILON
        
        ; Initiate splitting process.
        LDA.b #$02 : STA $0D80, X
        
        ; Splitting timer.
        LDA.b #$20 : STA $0DF0, X
        
        ; Make sure Bari stays alive, otherwise it will not be able to
        ; complete the split.
        LDA.b #$09 : STA $0DD0, X
        
        STZ $0EF0, X
        
        RTS
    }

; ==============================================================================

    ; *$370AC-$37120 JUMP LOCATION
    Trinexx_ScheduleSideHeadForDeath:
    {
        LDA.b #$80 : STA $0D80, X
        
        LDA.b #$60 : STA $0DF0, X
        
        LDA.b #$09 : STA $0DD0, X
        
        ; consider merging this routine with the previous one, or splitting
        ; the one above into smaller parts.
        BRA BRANCH_$37087
    
    ; *$370BD ALTERNATE ENTRY POINT
    shared Trinexx_ScheduleMainHeadForDeath:
    
        LDA.b #$80 : STA $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
        
        LDA.b #$09 : STA $0DD0, X
        
        BRA BRANCH_$37087
    
    ; *$370CE ALTERNATE ENTRY POINT
    shared Agahnim_ScheduleForDeath:
    
        JSL Sprite_SchedulePeersForDeath
        
        LDA.b #$09 : STA $0DD0, X
                     STA $0BA0, X
        
        LDA $0FFF : BNE .in_dark_world
        
        LDA.b #$0A : STA $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        LDA.b #$20 : STA $0F80, X
        
        JMP $F087 ; $37087 IN ROM
    
    .in_dark_world
    
        LDA.b #255 : STA $0DF0, X
        
        LDA.b #$08 : STA $0D80, X
        
        INC A : STA $0D81
                STA $0D82
        
        STZ $0DC1
        STZ $0DC2
        
        JMP $F087 ; $36087 IN ROM
    
    ; *$3710B ALTERNATE ENTRY POINT
    
        LDA $0E40, X : ADD.b #$04 : STA $0E40, X
        
        LDA $0FB5 : CMP.b #$0B : BNE BRANCH_BETA
        
        LDA.b #$01 : STA $0BE0, X
    
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; *$37121-$37128 LONG
    Sprite_CheckDamageToPlayerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CheckDamageToPlayer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$37129-$37130 LONG
    Sprite_CheckDamageToPlayerSameLayerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CheckDamageToPlayer_same_layer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$37131-$37138 LONG
    Sprite_CheckDamageToPlayerIgnoreLayerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CheckDamageToPlayer_ignore_layer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $37139-$37144 DATA
    {
    
    ; \task Name this pool.
    .directions
        db 4, 6, 0, 2
        db 6, 4, 0, 0
        db 4, 6, 0, 2
    }

; ==============================================================================

    ; *$37145-$371F5 LOCAL
    Sprite_CheckDamageToPlayer:
    {
        ; Return value CLC = no damage
        ; Return value SEC = damaged
        
        ; Is Link untouchable?
        LDA $037B : BNE .no_damage
    
    ; *$3714A ALTERNATE ENTRY POINT
    .stagger
    
        ; No he's not, he's vulnerable
        TXA : EOR $1A : AND.b #$03
        
        ; Since for a sentry it's usually 0
        ; It wasn't the right frame to hit on?
        ORA $0EF0, X : BNE .no_damage
    
    ; *$37154 ALTERNATE ENTRY POINT
    .same_layer
    
        ; Is the sprite on the same floor as Link?
        ; Nope, he doesn't get hit.
        LDA $00EE : CMP $0F20, X : BNE BRANCH_BETA
    
    ; *$3715C ALTERNATE ENTRY POINT
    .ignore_layer
    
        ; Is the sprite deactivated?
        LDA $0F60, X : BEQ BRANCH_GAMMA
        
        JSR $F70A ; $3770A IN ROM; Puts Link's X / Y coords into memory
        JSR Sprite_SetupHitBox
        JSR Utility_CheckIfHitBoxesOverlap
        
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        JSR $F1F6 ; $371F6 IN ROM
    
    BRANCH_DELTA:
    
        ; If the 0x80 bit is set, it's a harmless sprite
        LDA $0E40, X : BMI BRANCH_EPSILON
                       BCC BRANCH_BETA
        
        LDA $4D : BNE BRANCH_BETA
        
        LDA $02E0 : BNE BRANCH_ZETA
        
        LDA $0308 : BMI BRANCH_ZETA
        
        LDA $0BE0, X : AND.b #$20 : BEQ .cant_be_blocked_by_shield
        
        ; LINK'S SHIELD LEVEL
        LDA $7EF35A : BEQ BRANCH_ZETA
        
        STZ $0DD0, X
        
        LDA $2F
        
        LDY $3C : BEQ BRANCH_THETA
        
        LSR A : TAY
        
        ; Use an alternate direction when the shield is beind held off to the
        ; side (when holding the B button down).
        LDA $F13D, Y
    
    BRANCH_THETA:
    
        LDY $0DE0, X
        
        CMP $F141, Y : BNE BRANCH_ZETA
        
        LDA.b #$06 : JSL Sound_SetSfx2PanLong
        
        JSL Sprite_PlaceRupulseSpark.coerce
        
        ; Check if it's one of those laser eyes
        LDA $0E20, X : CMP.b #$95 : BNE .not_laser_eye
        
        LDA.b #$26 : JSL Sound_SetSfx3PanLong
    
    .no_damage
    
        CLC
    
    BRANCH_EPSILON:
    
        RTS ; End the routine
    
    .not_laser_eye
    
        CMP.b #$9B : BNE .not_wizzrobe
        
        JSR Sprite_Invert_XY_Speeds
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        INC $0D80, X
        
        LDA.b #$09 : STA $0DD0, X
    
    BRANCH_BETA:
    
        CLC
        
        RTS
    
    .not_wizzrobe
    
        CMP.b #$1B : BEQ .arrow_in_wall
        CMP.b #$0C : BEQ .octorock_stone
        
        RTS
    
    .cant_be_blocked_by_shield
    BRANCH_ZETA:
    
        JSR $F3DB ; $373DB IN ROM
        
        LDA $0E20, X : CMP.b #$0C : BNE .not_octorock_stone
    
    .octorock_stone
    
        JSR Sprite_ScheduleForDeath
    
    .not_octorock_stone
    
        SEC
        
        RTS
        
        ; Missing a label or is this just unused?
        CLC
        
        RTS
    
    .arrow_in_wall
    
        JMP Sprite_ScheduleForBreakage
    }

    ; *$371F6-$37227 LOCAL
    {
        ; Load the sprite's Z component
        LDA $0F70, X : STA $0C
                       STZ $0D
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$000B
                                CMP.w #$0017 : BCS .no_collision
        
        LDA $20 : SUB $0FDA : ADD $0C : ADD.w #$0010
                                CMP.w #$0018 : BCS .no_collision
        
        SEP #$20
        
        SEC
        
        RTS
    
    .no_collision
    
        SEP #$20
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$37228-$372A9 LOCAL
    Sprite_CheckIfLifted:
    {
        LDA $11 : ORA $3C : ORA $0FC1 : BNE .return
        
        LDA $EE : CMP $0F20, X : BNE .return
        
        LDY.b #$0F
    
    .next_sprite
    
        ; See if any enemies are in Link's hands
        ; yes, an enemy is being held
        LDA $0DD0, X : CMP.b #$0A : BEQ .return
        
        DEY : BPL .next_sprite
        
        ; Ths bombs we speak of are enemy bombs, not Link's bombs.
        LDA $0E20, X : CMP.b #$0B : BEQ .is_chicken_or_bomb
                       CMP.b #$4A : BEQ .is_chicken_or_bomb
        
        ; Return if the sprite's velocity is nonzero
        LDA $0D50, X : ORA $0D40, X : BNE .return
    
    .is_chicken_or_bomb
    
    ; *$37257 ALTERNATE ENTRY POINT
    shared Sprite_CheckIfLiftedPermissive:
    
        LDA $0372 : BNE .return
        
        ; check if the current sprite is the same one Link is touching.
        LDA $02F4 : DEC A : CMP $0FA0 : BEQ .player_picks_up_sprite
        
        ; Set up player's hit box.
        ; $37705 IN ROM
        JSR $F705
        JSR Sprite_SetupHitBox
        
        JSR Utility_CheckIfHitBoxesOverlap : BCC .return
        
        TXA : INC A : STA $0314
                      STA $0FB2
        
        RTS
    
    .player_picks_up_sprite
    
        STZ $F6
        
        STZ $0E90, X
        
        ; Play pick up object sound.
        LDA.b #$1D : JSL Sound_SetSfx2PanLong
        
        LDA $0DD0, X : STA $7FFA2C, X
        
        LDA.b #$0A : STA $0DD0, X
        LDA.b #$10 : STA $0DF0, X
        
        LDA.b #$00 : STA $7FFA1C, X : STA $7FF9C2, X
        
        JSR Sprite_DirectionToFacePlayer
        
        LDA $F139, Y : STA $2F
        
        PLA : PLA
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$372AA-$372B3 LONG
    Sprite_CheckDamageFromPlayerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CheckDamageFromPlayer
        
        TAY
        
        PLB
        
        TYA
        
        RTL
    }

; ==============================================================================

    ; *$372B4-$373C9 LOCAL
    Sprite_CheckDamageFromPlayer:
    {
        LDA $0EF0, X : AND.b #$80 : BNE .just_began_death_sequence
        
        LDA $EE : CMP $0F20, X
    
    ; (no there is nothing missing here)
    .just_began_death_sequence
    
        BNE .no_collision
        
        LDA $44 : CMP.b #$80 : BEQ .no_collision
        
        JSR Player_SetupActionHitBox
        JSR Sprite_SetupHitBox
        
        JSR Utility_CheckIfHitBoxesOverlap : BCC .no_collision
        
        STZ $0047
        
        LDA $037A : AND.b #$10 : BNE Sprite_CheckIfLifted.return
        
        ; Is Link using the hammer or an item that's not in the game?
        LDA $0301 : AND.b #$0A : BEQ .not_frozen_kill
        
        ; Can't kill Ganon with a hammer ;)
        LDA $0E20, X : CMP.b #$D6 : BCS .no_collision
        
        ; Is the enemy frozen?
        LDA $0DD0, X : CMP #$0B : BNE .not_frozen_kill
        
        LDA $7FFA3C, X : BEQ .not_frozen_kill
        
        ; I guess this puts it into poofing mode (when a frozen enemy gets hit
        ; by the hammer... or apparently an arrow??, it puts them into a special
        ; mode where they're more likely to yield magic decanters.)
        LDA.b #$02 : STA $0DD0, X
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA $0E40, X : AND.b #$E0 : ORA.b #$03 : STA $0E40, X
        
        LDA.b #$1F
        
        JSL Sound_SetSfx2PanLong
        
        SEC
        
        RTS
    
    .not_frozen_kill
    
        ; Is it an Agahnim energy blast? (not a dud)
        LDA $0E20, X : CMP.b #$7B : BNE .not_agahnim_energy_ball
        
        LDA $3C : CMP.b #$09 : BMI .spin_attack_charging
    
    .no_collision
    
        JMP .no_collision_part_deux
    
    .spin_attack_charging
    
        JMP $F3A2 ; $373A2 IN ROM
    
    .is_baby_helmasaur
    
        LDY $0DE0, X
        
        LDA $2F : CMP $F141, Y : BNE .direction_mismatch
    
    .is_flying_stalfos_head
    
        JSR $F33D ; $3733D IN ROM
        
        STZ $0EF0, X
        
        JSR Player_PlaceRepulseSpark
        JMP $F3C7 ; $373C7 IN ROM
    
    ; *$3733D ALTERNATE ENTRY POINT
    .direction_mismatch
    .is_hardhat_bettle
    
        JSR $EC02 ; $36C02 IN ROM
        
        LDA.b #$20 : JSR Sprite_ApplyRecoilToPlayer
        
        LDA.b #$10 : STA $47 : STA $46
        
        JMP $F3C7 ; $373C7 IN ROM
    
    .not_agahnim_energy_ball
    
        CMP.b #$09 : BNE .not_giant_moldorm
        
        LDA $0D90, X : BNE .sorry_youre_not_special
        
        JSR $F445 ; $37445 IN ROM
        
        ; I don't think this would play a sound at all, actually...
        LDA.b #$32 : JSL Sound_SetSfxPan : STA $012F
        
        JMP $F3C2 ; $373C2 IN ROM
    
    .not_giant_moldorm
    
        CMP.b #$92 : BNE .not_helmasaur_king
        
        JMP $F460 ; $37460 IN ROM
    
    .not_helmasaur_king
    
        CMP.b #$26 : BEQ .is_hardhat_bettle
        CMP.b #$13 : BEQ .is_baby_helmasaur
        CMP.b #$02 : BEQ .is_flying_stalfos_head
        CMP.b #$CB : BEQ .certain_bosses
        CMP.b #$CD : BEQ .certain_bosses
        CMP.b #$CC : BEQ .certain_bosses
        CMP.b #$D6 : BEQ .certain_bosses
        CMP.b #$D7 : BEQ .certain_bosses
        CMP.b #$CE : BEQ .certain_bosses
        CMP.b #$54 : BNE .sorry_youre_not_special
    
    ; *$37395 ALTERNATE ENTRY POINT
    .certain_bosses:
    
        LDA.b #$20 : JSR Sprite_ApplyRecoilToPlayer
        
        LDA.b #$90 : STA $47
        LDA.b #$10 : STA $46
    
    ; *$373A2 ALTERNATE ENTRY POINT
    .sorry_youre_not_special
    
        LDA $0CAA, X : AND.b #$04 : BNE .okay_maybe_you_are
        
        JSR $EC02 ; $36C02 IN ROM
        
        SEC
        
        BRA BRANCH_PI
    
    .no_collision_part_deux
    
        CLC
        
        BRA BRANCH_PI
    
    ; *$373B2 ALTERNATE ENTRY POINT
    .okay_maybe_you_are
    
        LDA $47 : BNE BRANCH_RHO
        
        LDA.b #$04 : JSR Sprite_ApplyRecoilToPlayer
        
        LDA.b #$10 : STA $46
        LDA.b #$10 : STA $47
    
    ; *$373C2 ALTERNATE ENTRY POINT
    BRANCH_RHO:
    
        JSR Player_PlaceRepulseSpark
        
        SEC
    
    ; *$373C7 ALTERNATE ENTRY POINT
    BRANCH_PI:
    
        LDA.b #$00
        
        RTS
    }

; ==============================================================================

    ; *$373CA-$3741E JUMP LOCATION
    Sprite_StaggeredCheckDamageToPlayerPlusRecoil:
    {
        TXA : EOR $1A : LSR A : BCS .delay_player_damage
        
        JSR $F645 ; $37645 IN ROM
        JSR $F705 ; $37705 IN ROM
        
        JSR Utility_CheckIfHitBoxesOverlap : BCS .dont_damage_player
    
    ; *$373DB ALTERNATE ENTRY POINT
    shared Sprite_AttemptDamageToPlayerPlusRecoil:
    
        LDA $031F : ORA $037B : BNE .dont_damage_player
        
        LDA.b #$13 : STA $46
        
        LDA.b #$18 : JSR Sprite_ApplyRecoilToPlayer
        
        LDA.b #$01 : STA $4D
        
        ; determine damage for Link based on his armor value
        LDA $0CD2, X : AND.b #$0F : STA $00 : ASL A : ADC $00 : ADD $7EF35B : TAY
        
        LDA $F427, Y : STA $0373
        
        LDA $0E20, X : CMP.b #$61 : BNE .not_beamos_laser
        
        LDA $0DB0, X : BEQ .not_beamos_laser
        
        ; Double the recoil amount to the player for the beamos laser beam.
        LDA $0D50, X : ASL A : STA $28
        
        LDA $0D40, X : ASL A : STA $27
    
    .not_beamos_laser
    .dont_damage_player
    .delay_player_damage
    
        RTS
    }

; ==============================================================================

    ; *$3741F-$37426 LONG
    Sprite_AttemptDamageToPlayerPlusRecoilLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_AttemptDamageToPlayerPlusRecoil
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$37445-$3745F LOCAL
    {
        LDA.b #$30 : JSR Sprite_ApplyRecoilToPlayer
        
        LDA.b #$90 : STA $47
        LDA.b #$10 : STA $46
        
        LDA.b #$21 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$30 : STA $0E00, X
        
        JMP $F3C7 ; $373C7 IN ROM
    }

    ; *$37460-$3746C LOCAL
    {
        LDA $0DB0, X : CMP #$03 : BCS .alpha
        
        JMP $F3B2 ; $373B2 IN ROM
    
    .alpha
    
        JMP $F395 ; $37395 IN ROM
    }

    ; $37571-$3757D DATA
    {
        db 1, 1, 1, 0, 0, 0, 0, 1
        db 1, 0, 0, 1, 1
    }
    
; ==============================================================================

    ; *$3757E-$37585 LONG
    Player_SetupActionHitBoxLong:
    {
        PHB : PHK : PLB
        
        JSR Player_SetupActionHitBox
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$37594-$375DF LOCAL
    pool Player_SetupActionHitBox:
    {
    
    .spin_attack_hit_box
    
        LDA $22 : SUB.b #$0E : STA $00
        LDA $23 : SBC.b #$00 : STA $08
        
        LDA $20 : SUB.b #$0A : STA $01
        LDA $21 : SBC.b #$00 : STA $09
        
        LDA.b #$2C : STA $02
        INC A      : STA $03
        
        PLX
        
        RTS
    
    .dash_hit_box
    
        LDA $2F : LSR A : TAY
        
        LDA $22 : ADD $F588, Y : STA $00
        LDA $23 : ADC $F58C, Y : STA $08
        
        LDA $20 : ADD $F590, Y : STA $01
        LDA $21 : ADC $F586, Y : STA $09
        
        LDA.b #$10 : STA $02 : STA $03
        
        RTS
    }

; ==============================================================================

    ; *$375E0-$37644 LOCAL
    Player_SetupActionHitBox:
    {
        LDA $0372 : BNE .dash_hit_box
        
        PHX
        
        LDX.b #$00
        
        LDA $0301 : AND.b #$0A : BNE .special_pose
        
        LDA $037A : AND.b #$10 : BNE .special_pose
        
        LDY $3C : BMI .spin_attack_hit_box
        
        LDA $F571, Y : BNE .return
        
        ; Adding $3C seems to be for the pokey player hit box with the swordy.
        LDA $2F : ASL #3 : ADD $3C : TAX : INX
    
    .special_pose
    
        LDY.b #$00
        
        LDA $45 : ADD $F46D, X : BPL .positive
        
        DEY
    
    .positive
    
              ADD $22 : STA $00
        TYA : ADC $23 : STA $08
        
        LDY.b #$00
        
        LDA $44 : ADD $F4EF, X : BPL .positive_2
        
        DEY
    
    .positive_2
    
              ADC $20 : STA $01
        TYA : ADC $21 : STA $09
        
        ; Widths of the colision boxes for player? Update: yep (Nov. 2012 haha)
        LDA $F4AE, X : STA $02
        
        LDA $F530, X : STA $03
        
        PLX
        
        RTS
    
    .return
    
        LDA.b #$80 : STA $08
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$37645-$37687 LOCAL
    {
        LDY.b #$00
        
        LDA $0FAB : CMP.b #$80 : BEQ BRANCH_ALPHA
        CMP.b #$00             : BPL BRANCH_BETA
        
        DEY
    
    BRANCH_BETA:
    
              ADD $0D10, X : STA $04
        TYA : ADC $0D30, X : STA $0A
        
        LDY.b #$00
        
        LDA $0FAA : BPL BRANCH_GAMMA
        
        DEY
    
    BRANCH_GAMMA:
    
              ADD $0D00, X : STA $05
        TYA : ADC $0D20, X : STA $0B
        
        LDA.b #$03
        
        LDY $0E20, X : CPY.b #$6A : BNE BRANCH_DELTA
        
        LDA.b #$10
    
    BRANCH_DELTA:
    
        STA $06 : STA $07
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$80 : STA $0A
        
        RTS
    }

; ==============================================================================

    ; *$37688-$3769E LOCAL
    Sprite_ApplyRecoilToPlayer:
    {
        PHA
        
        JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : STA $27
        LDA $01 : STA $28
        
        PLA : LSR A : STA $29 : STA $C7
        
        STZ $24
        STZ $25
        
        RTS
    }

; ==============================================================================

    ; *$3769F-$376C9 LOCAL
    Player_PlaceRepulseSpark:
    {
        LDA $0FAC : BNE .respulse_spark_already_active
        
        LDA.b #$05 : STA $0FAC
        
        LDA $0022 : ADC $0045 : STA $0FAD
        LDA $0020 : ADC $0044 : STA $0FAE
        
        LDA $EE : STA $0B68
        
        JSL Sound_SetSfxPanWithPlayerCoords
        
        ; Make "clink" against wall noise
        ORA.b #$05 : STA $012E
    
    .respulse_spark_already_active
    
        RTS
    }

; ==============================================================================

    ; *$376CA-$37704 LONG
    Sprite_PlaceRupulseSpark:
    {
        LDA $0FAC : BNE .dont_place
        
        LDA.b #$05 : JSL Sound_SetSfx2PanLong
    
    ; \note This entry point ignores whether there is already a repulse spark
    ; active (as there's only one slot for it, this would erase the old one).
    ; *$376D5 ALTERNATE ENTRY POINT
    .coerce
    
        LDA $0D10, X : CMP $E2
        LDA $0D30, X : SBC $E3 : BNE .off_screen
        
        LDA $0D00, X : CMP $E8
        LDA $0D20, X : SBC $E9 : BNE .off_screen
        
        LDA $0D10, X : STA $0FAD
        LDA $0D00, X : STA $0FAE
        
        LDA.b #$05 : STA $0FAC
        
        LDA $0F20, X : STA $0B68
    
    .off_screen
    .dont_place
    
        RTL
    }

; ==============================================================================

    ; *$37705-$3772E LOCAL
    {
        LDA $037B : BNE .no_player_interaction_with_sprites
    
    ; *$3770A ALTERNATE ENTRY POINT
    
        LDA.b #$08 : STA $02
                     STA $03
        
        LDA $22 : ADD.b #$04 : STA $00
        LDA $23 : ADC.b #$00 : STA $08
        
        LDA $20 : ADC.b #$08 : STA $01
        LDA $21 : ADC.b #$00 : STA $09
        
        RTS
    
    .no_player_interaction_with_sprites
    
        ; \wtf Kind of .... lazy if you ask me. This ensures that the player hit
        ; box is so out of range of whatever we're going to compare with so that
        ; the hit boxes can't possibly overlap.
        ; (with a Y coordinate of 0x8000 to 0x80ff, it's highly unlikely).
        LDA.b #$80 : STA $09
        
        RTS
    }

; ==============================================================================

    ; $3772F-$377EE DATA
    {
    
    .x_offsets_low
        db   2,   3,   0,  -3,  -6,   0,   2,  -8
        db   0,  -4,  -8,   0,  -8, -16,   2,   2
        
        db   2,   2,   2,  -8,   2,   2, -16,  -8
        db -12,   4,  -4, -12,   5, -32,  -2,   4
        
    .x_offsets_high
        db  0,  0,  0, -1, -1,  0,  0, -1
        db  0, -1, -1,  0, -1, -1,  0,  0
        
        db  0,  0,  0, -1,  0,  0, -1, -1
        db -1,  0, -1, -1,  0, -1, -1,  0
    
    .unknown_0
        db  12,   1,  16,  20,  20,   8,   4,  32
        db  48,  24,  32,  32,  32,  48,  12,  12
        
        db  60, 124,  12,  32,   4,  12,  48,  32
        db  40,   8,  24,  24,   5,  80,   4,   8
    
    .y_offsets_low
        db   0,   3,   4,  -4,  -8,   2,   0, -16
        db  12,  -4,  -8,   0, -10, -16,   2,   2
        
        db   2,   2,  -3, -12,   2,  10,   0, -12
        db  16,   4,  -4, -12,   3, -16,  -8,  10
    
    .y_offsets_high
        db 0,  0,  0, -1, -1,  0,  0, -1
        db 0, -1, -1,  0, -1, -1,  0,  0
        
        db 0,  0, -1, -1,  0,  0,  0, -1
        db 0,  0, -1, -1,  0, -1, -1,  0
    
    .unknown_1
        db  14,   1,  16,  21,  24,   4,   8,  40
        db  20,  24,  40,  29,  36,  48,  60, 124
        
        db  12,  12,  17,  28,   4,   2,  28,  20
        db  10,   4,  24,  16,   5,  48,   8,  12
    }

; ==============================================================================

    ; *$377EF-$37835 LOCAL
    Sprite_SetupHitBox:
    {
        ; Check the height value of the sprite.
        LDA $0F70, X : BMI .out_of_view
        
        PHY
        
        ; Get the index for the sprite's hit detection box.
        LDA $0F60, X : AND.b #$1F : TAY
        
        ; Add an offset to the sprites X pos (lower byte)
        ; Store an offset X pos (high byte) to $0A.
        LDA $0D10, X : ADD .x_offsets_low,  Y : STA $04
        LDA $0D30, X : ADC .x_offsets_high, Y : STA $0A
        
        LDA $0D00, X : ADD .y_offsets_low, Y : PHP : SUB $0F70, X  : STA $05
        LDA $0D20, X : SBC.b #$00   : PLP : ADC .y_offsets_high, Y : STA $0B
        
        ; Box... widths? right?
        LDA .unknown_0, Y : STA $06
        
        LDA .unknown_1, Y : STA $07
        
        PLY
        
        RTS
    
    .out_of_view
    
        LDA.b #$80 : STA $0A
        
        RTS
    }

; ==============================================================================

    ; *$37836-$37863 LOCAL
    Utility_CheckIfHitBoxesOverlap:
    {
        ; returns carry clear if there was no overlap
        
        !pos1_low  = $00
        !pos1_size = $02
        !pos2_low  = $04
        !pos2_size = $06
        !pos1_high = $08
        !pos2_high = $0A
        
        !ans_low   = $0F
        !ans_high  = $0C
        
        PHX
        
        LDX.b #$01
    
    .check_other_direction
    
        ; delta p low goes to the stack...
        ; delta p high goes to $0C...
        ; delta p + width of p2 goes to $0F...
        ; delta p low + 0x80
              LDA !pos2_low, X  : SUB !pos1_low, X  : PHA
        PHP                     : ADD !pos2_size, X : STA $0F
        PLP : LDA !pos2_high, X : SBC !pos1_high, X : STA $0C
        
        ; wasn't clear at first, but the the purpose of this is to filter out
        ; delta p's [in 16-bit] that are smaller than -0x0080, and larger then
        ; 0x007F. Since the sizes (width and height) are only specified
        ; as 8-bit, perhaps that's the reason for this restriction.
        PLA                     : ADD.b #$80
        
        LDA $0C : ADC.b #$00 : BNE .out_of_range
        
        LDA !pos1_size, X : ADD !pos2_size, X : CMP $0F : BCC .not_overlapping
        
        DEX : BPL .check_other_direction
    
    .out_of_range
    .not_overlapping
    
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$37864-$3786B LONG
    OAM_AllocateDeferToPlayerLong:
    {
        PHB : PHK : PLB
        
        JSR OAM_AllocateDeferToPlayer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3786C-$378A1 LOCAL
    OAM_AllocateDeferToPlayer:
    {
        ; Might want to rename this to a Sprite_ namespace...
        
        
        ; This routine in general checks the sprite's proximity to the player,
        ; and if he's close enough, it will alter the OAM allocation region
        ; for the sprite.
        
        ; Is the sprite on the same floor as the player?
        LDA $0F20, X : CMP $EE : BNE .return
        
        JSR Sprite_IsToRightOfPlayer
        
        ; Proceed only if the difference between the sprite's X coordinate
        ; and player's satisfies : [ -16 <= dX < 16 ]
        LDA $0F : ADD.b #$10 : CMP.b #$20 : BCS .return
        
        JSR Sprite_IsBelowPlayer
        
        ; Proceed if the difference in the Y coordinates satisfies:
        ; [ -32 <= dY < 40 ]
        LDA $0E : ADD.b #$20 : CMP.b #$48 : BCS .return
        
        LDA $0E40, X : AND.b #$1F : INC A : ASL #2
        
        ; The sprite will request a different OAM range
        ; depending on player's relative position.
        CPY.b #$00 : BEQ .linkIsLower
        
        JSL OAM_AllocateFromRegionC : BRA .return
    
    .linkIsLower
    
        JSL OAM_AllocateFromRegionB
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$378A2-$37916 LOCAL
    SpriteDeath_Main:
    {
        ; Death routine for sprites
        ; (bushes and grass are exceptions)
        
        LDA $0E20, X : CMP.b #$EC : BNE .notBushOrGrass
        
        JSR ThrowableScenery_ScatterIntoDebris
        
        RTS
    
    .notBushOrGrass
    
        ; Armos Knight, Lanmolas, Helmasaur King
        CMP.b #$53 : BEQ .draw_normally
        CMP.b #$54 : BEQ .draw_normally
        CMP.b #$92 : BEQ .draw_normally
        
        ; Red Bomb soldier?
        CMP.b #$4A : BNE .notBombSoldier
        
        LDA $0DB0, X : CMP.b #$02 : BCS .draw_normally
    
    .notBombSoldier
    
        LDA $0DF0, X : BEQ BRANCH_37923
    
    ; $378C9 ALTERNATE ENTRY POINT
    
        LDA $0E60, X : BMI .draw_normally
        
        LDA $1A : AND.b #$03 : ORA $11 : ORA $0FC1 : BNE .delay_finality
        
        INC $0DF0, X
    
    .delay_finality
    
        JSR SpriteDeath_DrawPerishingOverlay
        
        LDA $0E20, X : CMP.b #$40 : BEQ .is_evil_barrier
        
        LDA $0DF0, X : CMP.b #$0A : BCC .stop_drawing_sprite
    
    .is_evil_barrier
    
        REP #$20
        
        LDA $90 : ADD.w #$0010 : STA $90
        
        LDA $92 : ADD.w #$0004 : STA $92
        
        SEP #$20
        
        LDA $0E40, X : PHA
        
        SUB.b #$04 : STA $0E40, X
        
        JSR SpriteActive_Main
        
        PLA : STA $0E40, X
    
    .stop_drawing_sprite
    
        RTS
    
    .draw_normally
    
        JSR SpriteActive_Main
        
        RTS
    }

; ==============================================================================

    ; *$37917-$3791E LONG
    {
        PHB : PHK : PLB
        
        JSR $F923 ; $37923 IN ROM
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3791F-$37922 DATA
    {
        ; \task Name this pool / routine.
    
    .pikit_drop_items
        db $DC, $E1, $D9, $E6
    }

; ==============================================================================

    ; *$37923-$37A53 LOCAL
    {
        ; Is it a Vitreous small eyeball?
        LDA $0E20, X : CMP.b #$BE : BNE .not_small_vitreous_eyeball
        
        ; \hardcoded This is how Vitreous knows whether to come out of his
        ; slime pool.
        DEC $0ED0
    
    .not_small_vitreous_eyeball
    
        ; Is it a Pikit
        CMP #$AA : BNE .not_a_pikit
        
        LDY $0E90, X : BEQ BRANCH_BETA
        
        LDA .pikit_drop_items-1, Y
        
        LDY $0E30, X : PHY
        
        JSR $F9D1 ; $379D1 IN ROM
        
        PLA : STA $0E30, X : DEC A : BNE BRANCH_GAMMA
        
        LDA.b #$09 : STA $0F50, X
        LDA.b #$F0 : STA $0E60, X
    
    BRANCH_GAMMA:
    
        INC $0EB0, X
        
        RTS
    
    .not_a_pikit
    BRANCH_BETA:
    
        ; Is it a crazy red spear soldier?
        LDA $0E20, X : CMP.b #$45 : BNE BRANCH_DELTA
        
        ; If so, are we in the "first part" (on OW)
        LDA $7EF3C5 : CMP.b #$02 : BNE BRANCH_DELTA
        
        LDA $040A : CMP.b #$18 : BNE BRANCH_DELTA
        
        ; Resets the music in the village when the crazy green guards are killed.
        LDA.b #$07 : STA $012C
    
    BRANCH_DELTA:
    
        ; Does it have a drop item?
        LDY $0CBA, X : BEQ BRANCH_EPSILON
        
        LDA $0BC0, X : STA $0E30, X
        
        LDA.b #$FF : STA $0BC0, X
        
        ; Small key
        LDA.b #$E4
        
        CPY.b #$01 : BEQ BRANCH_ZETA
        
        ; Big key
        LDA.b #$E5
        
        CPY.b #$03 : BNE BRANCH_ZETA
        
        ; Green rupee
        LDA.b #$D9
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        ; Determine prize packs...
        LDA $0BE0, X : AND.b #$0F : BEQ BRANCH_THETA
        
        DEC A : PHA
        
        ; Check luck status
        ; If no special luck, proceed as normal
        LDY $0CF9 : BEQ BRANCH_IOTA
        
        ; Increase lucky (or unlucky) drop counter
        ; Once we reach 10 drops of a type we reset luck.
        INC $0CFA : LDA $0CFA : CMP.b #$0A : BCC BRANCH_KAPPA
        
        STZ $0CF9 ; Reset luck. (per above)
    
    BRANCH_KAPPA:
    
        PLA
        
        ; Is it great luck? If so, guarantee a prize drop
        CPY.b #$01 : BEQ BRANCH_LAMBDA
    
    BRANCH_THETA:
    
        BRA BRANCH_MU ; Otherwise Luck is 2 and failure is guaranteed.
    
    BRANCH_IOTA: ; how prize packs normally drop
    
        ; Reload the prize pack #
        JSL GetRandomInt : PLY  : AND $FA5C, Y : BNE BRANCH_MU
    
    ; *$379BC ALTERNATE ENTRY POINT
    
        TYA ; Transfer prize number to A register
    
    BRANCH_LAMBDA: ; if this is branched to, the prize is guaranteed.
    
        ASL #3 : ORA $0FC7, Y : PHA
        
        LDA $0FC7, Y : INC A : AND.b #$07 : STA $0FC7, Y
        
        PLY
        
        LDA $FA72, Y
    
    ; *$379D1 ALTERNATE ENTRY POINT
    BRANCH_ZETA:
    
        ; Is the sprite we've dropped a big key?
        STA $0E20, X : CMP.b #$E5 : BNE BRANCH_NU
        
        JSR SpritePrep_LoadBigKeyGfx
        
        BRA BRANCH_XI
    
    BRANCH_NU:
    
        ; Is it a normal key?
        CMP.b #$E4 : BNE BRANCH_XI
        
        JSR SpritePrep_Key.set_item_drop
    
    BRANCH_XI:
    
        LDA.b #$09 : STA $0DD0, X
        
        LDA $0F70, X : PHA
        
        JSL Sprite_LoadProperties
        
        INC $0BA0, X
        
        LDY $0E20, X
        
        LDA $F98B, Y : PHA
        
        AND.b #$F0 : STA $0F80, X
        
        PLA : AND.b #$0F : ADD $0D10, X : STA $0D10, X
        LDA $0D30, X     : ADC.b #$00   : STA $0D30, X
        
        PLA : STA $0F70, X
        
        LDA.b #$15 : STA $0F10, X
        LDA.b #$FF : STA $0B58, X
        
        BRA BRANCH_OMICRON
    
    BRANCH_MU:
    
        STZ $0DD0, X
    
    BRANCH_OMICRON:
    
        LDA $0E20, X : CMP.b #$A2 : BNE .not_kholdstare
        
        JSL Sprite_VerifyAllOnScreenDefeated : BCC .anospawn_crystal
        
        LDA.b #$04 : JSL Sprite_SpawnFallingItem
    
    .anospawn_crystal
    .not_kholdstare
    
        JSL Dungeon_ManuallySetSpriteDeathFlag
        
        INC $0CFB
        
        LDA $0E20, X : CMP.b #$40 : BNE .not_evil_barrier
        
        LDA.b #$09 : STA $0DD0, X
        
        LDA.b #$04 : STA $0DC0, X
        
        JMP $F8C9 ; $378C9 IN ROM
    
    .not_evil_barrier
    
        RTS
    }

; ==============================================================================

    ; $37A54-$37A5B LONG
    {
        PHB : PHK : PLB
        
        JSR $F9BC  ;  $379BC IN ROM
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$37B2A-$37B95 LOCAL
    SpriteDeath_DrawPerishingOverlay:
    {
        LDA $046C : CMP.b #$04 : BNE .dont_use_super_priority
        
        LDA.b #$30 : STA $0B89, X
    
    .dont_use_super_priority
    
        JSR Sprite_PrepOamCoord
        
        LDA $0E60, X : AND.b #$20 : LSR #3 : STA $0C
        
        PHX
        
        LDA.b #$03 : STA $00
        
        LDA $0DF0, X : AND.b #$1C : EOR.b #$1C : ADD $00 : TAX
    
    .next_oam_entry
    
        PHY
        
        LDA $FAEA, X : BEQ .skip_entry
        
                                                INY #2 : STA ($90), Y
        LDA $0FA9 : SUB $0C    : ADD $FACA, X : DEY    : STA ($90), Y
        LDA $0FA8 : SUB $0C    : ADD $FAAA, X : DEY    : STA ($90), Y
        LDA $05   : AND.b #$30 : ORA $FB0A, X : INY #3 : STA ($90), Y
    
    .skip_entry
    
        PLY : INY #4
        
        DEX
        
        DEC $00 : BPL .next_oam_entry
        
        PLX
        
        LDY.b #$00
        LDA.b #$03
        
        JSR Sprite_CorrectOamEntries
        
        RTS
    }

; ==============================================================================

    ; *$37BEA-$37CB6 JUMP LOCATION
    SpriteCustomFall_Main:
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        STZ $0DD0, X
        
        JSL Dungeon_ManuallySetSpriteDeathFlag
        
        RTS
    
    BRANCH_ALPHA:
    
        CMP.b #$40 : BCC BRANCH_BETA
        
        LDA $0F50, X : CMP.b #$05 : BNE BRANCH_GAMMA
        
        LDA.b #$3F : STA $0DF0, X
        
        BRA BRANCH_BETA
    
    BRANCH_GAMMA:
    
        LDA $0DF0, X : AND.b #$07 : ORA $11 : ORA $0FC1 : BNE BRANCH_LAMBDA
        
        LDA.b #$31 : JSL Sound_SetSfx3PanLong
    
    BRANCH_LAMBDA:
    
        JSR SpriteActive_Main
        JSR Sprite_PrepOamCoord
        
        LDA $02 : SUB.b #$08 : STA $02
        LDA $03 : SUB.b #$00 : STA $03
        
        LDA $0DF0, X : ADD.b #$14 : STA $06
        
        JSL Sprite_CustomTimedDrawDistressMarker
        
        RTS
    
    BRANCH_BETA:
    
        CMP.b #$3D : BNE BRANCH_DELTA
        
        PHA
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        PLA
    
    BRANCH_DELTA:
    
        LSR A : TAY
        
        LDA $0E20, X
        
        CMP.b #$26 : BEQ BRANCH_EPSILON
        CMP.b #$13 : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        LDA $FBB6, Y : STA $0DC0, X
        
        JSR $FD17   ; $37D17 IN ROM
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDA $FB96, Y : CMP.b #$0C : BCS BRANCH_MU
        
        LDY $0DE0, X
        
        ADD $FBE6, Y
    
    BRANCH_MU:
    
        STA $0DC0, X
        
        JSR $FE5B   ; $37E5B IN ROM
    
    BRANCH_THETA:
    
        LDA $0DF0, X : LSR #3 : TAY
        
        LDA $1A : AND $FBD6, Y : ORA $11 : BNE BRANCH_IOTA
        
        LDY.b #$68
        
        JSR $E73C   ; $3673C IN ROM
        
        LDA $0FA5 : CMP.b #$20 : BEQ BRANCH_KAPPA
        
        STZ $0F30, X
        STZ $0F40, X
    
    BRANCH_KAPPA:
    
        LDA $0F30, X : STA $0D40, X
        
        ASL A : PHP : ROR $0D40, X : PLP : ROR $0D40, X
        
        LDA $0F40, X : STA $0D50, X
        
        ASL A : PHP : ROR $0D50, X : PLP : ROR $0D50, X
        
        JSR Sprite_Move
    
    BRANCH_IOTA:
    
        RTS
    }

    ; *$37D17-$37D42 LOCAL
    {
        LDA $0E20, X : CMP.b #$13 : BEQ BRANCH_ALPHA
        
        LDA $0DC0, X : ASL #3 : ADC.b #$B7 : STA $08
        
        LDA.b #$FC
    
    BRANCH_BETA:
    
        ADC.b #$00 : STA $09
        
        LDA.b #$01 : JSL Sprite_DrawMultiple
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA $0DC0, X : ASL #3 : ADC.b #$E7 : STA $08
        
        LDA.b #$FC
        
        BRA BRANCH_BETA
    }

; ==============================================================================

    ; $37D43-$37E5A DATA
    {
        ; \task Fill in data later, name stuff.
    }

; ==============================================================================

    ; *$37E5B-$37EB3 LOCAL
    {
        JSR Sprite_PrepOamCoord
        
        LDA $0DC0, X : PHA
        
        ASL #2 : STA $06
        
        PLA
        
        PHX
        
        LDX.b #$00
        
        CMP.b #$0C : BCS BRANCH_ALPHA
        AND.b #$03 : BNE BRANCH_ALPHA
        
        LDX.b #$03
    
    BRANCH_ALPHA:
    
        STX $07
    
    BRANCH_BETA:
    
        PHX
        
        TXA : ADD $06 : TAX
        
        LDA $00      : ADD $FD43, X       : STA ($90), Y
        LDA $02      : ADD $FD7B, X : INY : STA ($90), Y
        LDA $FDB3, X                : INY : STA ($90), Y
        LDA $FDEB, X : EOR $05      : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $FE23, X : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL BRANCH_BETA
        
        PLX
        
        LDY.b #$FF
        
        LDA $07
        
        JSR Sprite_CorrectOamEntries
        
        RTS
    }

; ==============================================================================

    ; *$37EB4-$37EBB LONG
    Sprite_CorrectOamEntriesLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CorrectOamEntries
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$37EBC-$37F25 LOCAL
    Sprite_CorrectOamEntries:
    {
        !spr_y_lo = $00
        !spr_y_hi = $01
        
        !spr_x_lo = $02
        !spr_x_hi = $03
        
        !spr_y_screen_rel = $06
        !spr_x_screen_rel = $07
        
        JSR Sprite_GetScreenRelativeCoords
        
        PHX
        
        REP #$10
        
        LDX $90 : STX $0C
        
        LDX $92 : STX $0E
    
    .next_oam_entry
    
        LDX $0E
        
        LDA $0B : BPL .override_size_and_upper_x_bit
        
        ; Otherwise, just preserve the size but but zero out the most sig X bit.
        LDA $00, X : AND.b #$02
    
    .override_size_and_upper_x_bit
    
        STA $00, X
        
        LDY.w #$0000
        
        LDX $0C
        
        LDA $00, X : SUB $07 : BPL .sign_extension_x
        
        DEY
    
    .sign_extension_x
    
              ADD $02 : STA $04
        TYA : ADC $03 : STA $05
        
        JSR Sprite_CheckIfOnScreenX : BCC .on_screen_x
        
        LDX $0E
        
        ; Restore the X bit, as it's been show to be in exceess of 0x100...
        ; This whole routine is kind of wonky and I have to wonder if it's
        ; buggy as well? (Compared to other oam handler code I've seen.)
        INC $00, X
    
    .on_screen_x
    
        LDY.w #$0000
        
        LDX $0C : INX
        
        LDA $00, X : SUB $06 : BPL .sign_extension_y
        
        DEY
    
    .sign_extension_y
    
              ADD $00 : STA $09
        TYA : ADC $01 : STA $0A
        
        JSR Sprite_CheckIfOnScreenY : BCC .on_screen_y
        
        LDA.b #$F0 : STA $00, X
    
    .on_screen_y
    
        INX #3 : STX $0C
        
        INC $0E
        
        DEC $08 : BPL .next_oam_entry
        
        SEP #$10
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$37F26-$37F48 LOCAL
    Sprite_GetScreenRelativeCoords:
    {
        STY $0B
        
        STA $08
        
        LDA $0D00, X : STA $00
        SUB $E8      : STA $06
        LDA $0D20, X : STA $01
        
        LDA $0D10, X : STA $02
        SUB $E2      : STA $07
        LDA $0D30, X : STA $03
        
        RTS
    }

; ==============================================================================

    ; *$37F49-$37F55 LOCAL
    Sprite_CheckIfOnScreenX:
    {
        REP #$20
        
        LDA $04 : SUB $E2 : CMP.w #$0100
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$37F56-$37F6C LOCAL
    Sprite_CheckIfOnScreenY:
    {
        REP #$20
        
        ; Is there any point to this the push and pull of A? Not really certain
        ; of that. (Not to mention the first storing of $09.)
        
        LDA $09 : PHA : ADD.w #$0010 : STA $09
        
        SUB $E8 : CMP.w #$0100 : PLA : STA $09
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $37F6D-$37F71 UNUSED
    pool Unused:
    {
        JSL Sprite_SelfTerminate
        
        RTS
    }

; ==============================================================================

    ; $37F72-$37F77 DATA
    pool Sprite_CheckIfRecoiling:
    {
    
    .frame_counter_masks
        db $03, $01, $00, $00, $0C, $03
    }

; ==============================================================================

    ; *$37F78-$37FF7 LOCAL
    Sprite_CheckIfRecoiling:
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
        
        JSL Sprite_CheckTileCollisionLong
        
        LDA $0E70, X
        
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
    
        JSR Sprite_Move
    
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

    ; $37FF8-$37FFF NULL
    pool Null:
    {
        pad $FF
        
        pad $078000
    }

; ==============================================================================
