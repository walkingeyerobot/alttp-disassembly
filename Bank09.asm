
; ==============================================================================

    incsrc "ancilla_init.asm"
    incsrc "tagalong.asm"

; ==============================================================================

    ; *$4AC6B-$4ACF2 LONG
    Ancilla_TerminateSelectInteractives:
    {
        PHB : PHK : PLB
        
        LDX.b #$05
    
    .nextObject
    
        ; check for 3D crystal
        LDA $0C4A, X : CMP.b #$3E : BNE .not3DCrystal
        
        TXY
        
        BRA .checkIfCarryingObject
    
    .not3DCrystal
    
        ; checks if any cane of somaria blocks are in play?
        LDA $0C4A, X : CMP.b #$2C : BNE .checkIfCarryingObject
        
        STZ $0646
        
        LDA $48 : AND.b #$80 : BEQ .checkIfCarryingObject
        
        ; reset Link's grabby status
        STZ $48 : STZ $5E
    
    .checkIfCarryingObject
    
        LDA $0308 : BPL .notCarryingAnything
        
        TXA : INC A : CMP $02EC : BEQ .spareObject
        
        BRA .terminateObject
    
    .notCarryingAnything
    
        TXA : INC A : CMP $02EC : BNE .terminateObject
        
        STZ $02EC
    
    .terminateObject
    
        STZ $0C4A, X
    
    .spareObject
    
        DEX : BPL .nextObject
        
        LDA $037A : AND.b #$10 : BEQ .theta
        
        STZ $46
        STZ $037A
    
    .theta
    
        ; Reset flute playing interval timer.
        STZ $03F0
        
        ; Reset tagalong detatchment timer.
        STZ $02F2
        
        ; Only place this is written to. Never read.
        STZ $02F3
        STZ $035F
        STZ $03FC
        
        STZ $037B
        STZ $03FD
        STZ $0360
        
        LDA $5D : CMP.b #$13 : BNE .notUsingHookshot
        
        LDA.b #$00 : STA $5D
        
        LDA $3A   : AND.b #$BF : STA $3A
        LDA $50   : AND.b #$FE : STA $50
        LDA $037A : AND.b #$FB : STA $037A
        
        STZ $037E
    
    .notUsingHookshot
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4ACF3-$4AD05 LONG
    Tagalong_Disable:
    {
        ; Get rid of the tagalong following Link if it's
        ; Kiki the Monkey or the creepy Middle Aged dude with the sign.
        LDA $7EF3CC
        
        CMP.b #$0A : BEQ .kill_tagalong
        CMP.b #$09 : BNE .spare_tagalong
    
    .terminate_tagalong
    
        LDA.b #$00 : STA $7EF3CC
    
    .spare_tagalong
    
        RTL
    }

; ==============================================================================

    ; *$4AD06-$4AD1A LOCAL
    Ancilla_SetCoords:
    {
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
        
        RTS
    }

; ==============================================================================

    ; *$4AD1B-$4AD2F LOCAL
    Ancilla_GetCoords:
    {
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        RTS
    }

; ==============================================================================

    ; \note Could this routine's placement indicate that dividing the blocks
    ; came later as a designed feature?
    ; *$4AD30-$4AD66 LONG
    AddSomarianBlockDivide:
    {
        PHB : PHK : PLB
        
        LDA.b #$2E : STA $0C4A, X
        
        PHX
        
        TAX : LDA $08806F, X
        
        PLX
        
        STA $0C90, X
        
        LDA.b #$03 : STA $03B1, X
        
        STZ $0C54, X
        STZ $0C5E, X
        STZ $039F, X
        STZ $03A4, X
        STZ $03EA, X
        STZ $0280, X
        
        STZ $0646
        
        JSL Sound_SfxPanObjectCoords : ORA.b #$01 : STA $012F
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $4AD67-$4AD6B DATA
    pool GiveRupeeGift:
    {
    
    .gift_amounts
        db 1, 5, 20, 100, 50
    }

; ==============================================================================

    ; *$4AD6C-$4ADC6 LONG
    GiveRupeeGift:
    {
        ; This routine handles rupee gift
        
        PHB : PHK : PLB
        
        LDA $0C5E, X
        
        CMP.b #$34 : BEQ .lowSize
        CMP.b #$35 : BEQ .lowSize
        CMP.b #$36 : BEQ .lowSize
        CMP.b #$40 : BEQ .mediumSize
        CMP.b #$41 : BEQ .mediumSize
        CMP.b #$46 : BEQ .largeSize
        CMP.b #$47 : BNE .notRupeeGift
    
    .largeSize
    
        LDY.b #$02
        
        ; Give 20 rupees for this gift (redundant, I think) 
        ; Perhaps it uses a different graphic
        CMP.b #$47 : BEQ .setGiftIndex
        
        LDA.b #$2C : STA $00
        
        ; Gives me 300 rupees.
        LDA.b #$01 : STA $01
        
        BRA .giveRupees
    
    .mediumSize
    
        SUB.b #$40 : ADD.b #$03 : TAY
        
        BRA .setGiftIndex
    
    .lowSize
    
        ; Give 1, 5, or 20 rupees
        SUB.b #$34 : TAY
    
    .setGiftIndex
    
        LDA .gift_amounts, Y : STA $00 : STZ $01
    
    .giveRupees
    
        REP #$20
        
        ; Add this amount to my rupee collection.
        LDA $7EF360 : ADD $00 : STA $7EF360
        
        SEP #$20
        
        SEC
        
        PLB
        
        RTL
    
    .notRupeeGift
    
        CLC
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4ADC7-$4ADF0 LONG
    Ancilla_TerminateSparkleObjects:
    {
        PHX
        
        LDX.b #$04
    
    .next_slot
    
        LDA $0C4A, X
        
        CMP.b #$2A : BEQ .terminate_object
        CMP.b #$2B : BEQ .terminate_object
        CMP.b #$30 : BEQ .terminate_object
        CMP.b #$31 : BEQ .terminate_object
        CMP.b #$18 : BEQ .terminate_object
        CMP.b #$19 : BEQ .terminate_object
        CMP.b #$0C : BNE .dont_terminate
    
    .terminate_object
    
        STZ $0C4A, X
    
    .dont_terminate
    
        DEX : BPL .next_slot
        
        PLX
        
        RTL
    }

; ==============================================================================

    incsrc "ancilla_motive_dash_dust.asm"

; ==============================================================================

    ; $4AE3E-$4AE3F DATA
    pool Empty:
    {
        fillbyte $FF
        
        fill $02
    }

; ==============================================================================

    ; *$4AE40-$4AE7D LONG
    Sprite_SpawnSuperficialBombBlast:
    {
        ; Create a blast that looks like a green bomb going off? (Somaria
        ; platform uses during creation? Magic powder tossed on green altar?)
        LDA.b #$4A : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$06 : STA $0DD0, Y
        
        LDA.b #$1F : STA $0E00, Y
        
        LDA #$03 : STA $0DB0, Y : STA $0E40, Y
        
        INC A : STA $0F50, Y
        
        LDA.b #$15 : JSL Sound_SetSfx2PanLong
    
    ; *$4AE64 ALTERNATE ENTRY POINT
    shared Sprite_SetSpawnedCoords:
    
        LDA $00 : STA $0D10, Y
        LDA $01 : STA $0D30, Y
        
        LDA $02 : STA $0D00, Y
        LDA $03 : STA $0D20, Y
        
        LDA $04 : STA $0F70, Y
    
    .spawn_failed
    
        RTL
    }

; ==============================================================================

    ; $4AE7E-$4AE9F LONG
    Sprite_SpawnDummyDeathAnimation:
    {
        ; Used for the chicken swarm (has to be, I'm sure of it)
        ; Update: This seems to be used by the contradiction bat.
        
        LDA.b #$0B : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$06 : STA $0DD0, Y
        
        LDA.b #$0F : STA $0DF0, Y
        
        LDA.b #$14 : JSL Sound_SetSfx2PanLong
        
        ; Ensure the spawned death sprite is visible by giving it high priority.
        LDA.b #$02 : STA $0F20, Y
    
    .spawn_failed
    
        RTL
    }

; ==============================================================================

    ; $4AEA0-$4AEA7 DATA
    pool Sprite_SpawnMadBatterBolts:
    {
    
    .x_speeds
        -8, -4,  4,  8
    
    .initial_cycling_states
        0, 17, 34, 51
    }

; ==============================================================================

    ; \note Only used by the mad batter (naturally).
    ; *$4AEA8-$4AF31 LONG
    Sprite_SpawnMadBatterBolts:
    {
        JSL .attempt_bold_spawn
        JSL .attempt_bold_spawn
        JSL .attempt_bold_spawn
    
    ; *$4AEB4 ALTERNATE ENTRY POINT
    .attempt_bold_spawn
    
        LDA.b #$3A : JSL Sprite_SpawnDynamically : BMI .spawnFailed
        
        LDA.b #$01 : JSL Sound_SetSfx3PanLong
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $00 : ADD.b #$04 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$0C : PHP : SUB $0F70, X : STA $0D00, Y
        LDA $03 : SBC.b #$00 : PLP : ADC.b #$00   : STA $0D20, Y
        
        LDA.b #$00 : STA $0F70, Y
        
        LDA.b #$18 : STA $0D40, Y : STA $0EB0, Y : STA $0BA0, Y
        
        LDA.b #$80 : STA $0E40, Y
        
        LDA.b #$03 : STA $0E60, Y
        AND.b #$03 : STA $0F50, Y
        
        LDA.b #$20 : STA $0DF0, Y
        
        LDA.b #$02 : STA $0DC0, Y
        
        PHX
        
        LDA $0ED0, X : TAX
        
        LDA.l .x_speeds, X : STA $0D50, Y
        
        LDA.l .initial_cycling_states, X : STA $0E80, Y
        
        LDA.b #$02 : STA $0F20, Y
        
        PLX
        
        INC $0ED0, X
    
    .spawnFailed
    
        RTL
    }

; ==============================================================================

    ; *$4AF32-$4AF88 LONG
    Sprite_VerifyAllOnScreenDefeated:
    {
        PHX
        
        LDX.b #$0F ; Going to cycle through all sprite entries
    
    .next_sprite
    
        LDA $0DD0, X : BEQ .dead
        
        ; check if the sprite is always considered dead for these purposes
        ; (some sprites have this property set at load and some dynamically)
        LDA $0F60, X : AND.b #$40 : BNE .dead
        
        ; In these cases Dead apparently means offscreen.
        LDA $0D10, X : CMP $E2
        LDA $0D30, X : SBC $E3 : BNE .dead
        
        ; In these cases Dead apparently means offscreen.
        LDA $0D00, X : CMP $E8
        LDA $0D20, X : SBC $E9 : BNE .dead
        
        PLX
        
        CLC ; Not all enemies are dead, return false.
        
        RTL
    
    .dead
    
        DEX : BPL .next_sprite
        
        BRA .check_overlords
    
    ; *$4AF61 ALTERNATE ENTRY POINT
    shared Sprite_CheckIfAllDefeated:
    
        PHX
        
        ; We’re going to cycle through all the sprites in the room.
        LDX.b #$0F
    
    .next_sprite_2
    
        ; Is the sprite alive?
        LDA $0DD0, X : BEQ .dead_2
        
        ; It’s alive, but not in this room... i.e. good as dead.
        LDA $0F60, X : AND.b #$40 : BNE .dead_2
    
    .failure
    
        PLX
        
        CLC ; Not all the enemies are dead, it’s a failure
        
        RTL
    
    .dead_2
    
        DEX : BPL .next_sprite_2
    
    .check_overlords
    
        LDX.b #$07
    
    .next_overlord
    
        ; Now check to see if there are any overlords "alive"
        LDA $0B00, X
        
        CMP.b #$14 : BEQ .failure
        CMP.b #$18 : BEQ .failure
        
        ; Move on to the next value.
        DEX : BPL .next_overlord
        
        PLX
        
        ; We’ve succeeded (so do something?)
        SEC
        
        RTL
    }

; ==============================================================================

    ; *$4AF89-$4AFD5 LONG
    Sprite_ReinitWarpVortex:
    {
        PHB : PHK : PLB
        
        LDX.b #$0F
    
    .nextSprite
    
        LDA $0DD0, X : BEQ .dead
        
        ; Trying to kill the warp vortex
        LDA $0E20, X : CMP.b #$6C : BNE .notWarpVortex
        
        ; Kill the warp vortex!
        STZ $0DD0, X
    
    .dead
    .notWarpVortex
    
        DEX : BPL .nextSprite
        
        LDA.b #$6C
        
        JSL Sprite_SpawnDynamically : BPL .spawnSucceeded
        
        LDY.b #$00
    
    .spawnSuceeded
    
        LDA $001ABF : STA $0D10, Y
        LDA $001ACF : STA $0D30, Y
        
        LDA $001ADF : ADD.b #$08 : STA $0D00, Y
        LDA $001AEF : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$00 : STA $0F20, Y : INC A : STA $0BA0, Y
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4AFD6-$4B01F LONG
    InitSpriteSlots:
    {
        PHB: PHK : PLB
        
        LDX.b #$0F
    
    .nextSprite
    
        LDA $0DD0, X : BEQ .deadSprite
        
        LDY $0E20, X
        
        ; carrying something
        CMP.b #$0A : BNE .notCarrying
        
        ; carrying a bush or rock
        CPY.b #$EC : BEQ .ignoreSprite
        
        ; or carrying a fish
        CPY.b #$D2 : BEQ .ignoreSprite
        
        ; if it's not one of those two things you're carrying, you lose it
        STZ $0309 : STZ $0308
        
        BRA .killSprite
    
    .notCarrying
    
        ; is it a warp vortex?
        CPY.b #$6C : BEQ .ignoreSprite
        
        ; ignore the sprite if the area that it was loaded in is the same as the area we're in
        LDA $0C9A, X : CMP $040A : BEQ .ignoreSprite
    
    .killSprite
    
        STZ $0DD0, X
    
    .deadSprite
    .ignoreSprite
    
        DEX : BPL .nextSprite
        
        LDX.b #$07
    
    .nextOverlord
    
        ; There's no overlord loaded in that slot to begin with
        LDA $0B00, X : BEQ .noOverlord
        
        ; ignore the overlord b/c it matches the area we're already in
        LDA $0CCA, X : CMP $040A : BEQ .ignoreOverlord
        
        STZ $0B00, X
    
    .noOverlord
    .ignoreOverlord
    
        DEX : BPL .nextOverlord
        
        PLB
        
        RTL
    }

; ==============================================================================

    incsrc "garnish.asm"
    incsrc "overlord.asm"

; ==============================================================================

    ; $4C023-$4C02E DATA
    pool SpawnCrazyVillageSoldier:
    {
        ; \tcrf (verified)
        ; The inn keeper's data is unused because he's not a snitch, naturally.
        ; Use Pro Action Replay Code 09C04834 to switch the young snitch girl's
        ; soldier spawn data with that of the innkeeper's.
    
    .x_offsets_low
        db $20, $40, $E0
    
    .x_offsets_high
        db $01, $03, $02
    
    .y_offsets_low
        db $00, $B0, $60
    
    .y_offsets_high
        db $01, $03, $01
    }

; ==============================================================================

    ; *$4C02F-$4C087 LONG
    SpawnCrazyVillageSoldier:
    {
        ; Spawn the crazy nutjob that shows up when you run into the scared ladies outside
        ; their houses
        
        PHB : PHK : PLB
        
        LDA.b #$45
        LDY.b #$00
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        PHX
        
        LDA $0E20, X
        
        LDX.b #$00
        
        ; Is it one of the ladies outside of their houses?
        CMP.b #$3D : BEQ .place_soldier
        
        INX
        
        ; Innkeeper sprite... he was originally planned as someone that snitches on you?
        CMP.b #$35 : BEQ .place_soldier
        
        INX
    
    .place_soldier
    
        LDA .x_offsets_low,  X :             STA $0D10, Y
        LDA .x_offsets_high, X : ADD $0FBD : STA $0D30, Y
        
        LDA .y_offsets_low,  X :             STA $0D00, Y
        LDA .y_offsets_high, X : ADD $0FBF : STA $0D20, Y
        
        PLX
        
        LDA.b #$00 : STA $0F20, Y
        
        LDA.b #$04 : STA $0E50, Y
        
        LDA.b #$80 : STA $0CAA, Y
        
        LDA.b #$90 : STA $0BE0, Y
        
        LDA.b #$0B : STA $0F50, Y
    
    .spawn_failed
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $4C088-$4C08C DATA
    pool Overlord_CheckInRangeStatus:
    {
    
    .offsets_low
        db $30, $C0
    
    .offsets_high
        db $01, $FF
    
    .easy_out
    
        RTS
    }

; ==============================================================================

    ; I think this... might terminate overlord sprites on the overworld.
    ; But we don't realy use them there anyways...
    ; *$4C08D-$4C113 LOCAL
    Overlord_CheckInRangeStatus:
    {
        LDA $1B : BNE .easy_out
        
        LDA $1A : AND.b #$01 : STA $01
                               STA $02
                               TAY
        
        ; \optimize This would be so much faster in 16-bit code, even if
        ; this code isn't used very often, if at all.
        LDA $E2 : ADD .offsets_low, Y : ROL $00 : CMP $0B08, X         : PHP
        LDA $E3                       : LSR $00 : ADC .offsets_high, Y : PLP : SBC $0B10, X : STA $00
        
        ; We want the upper byte of the absolute difference between the
        ; offset from the scroll value to the overlord. Since that offset
        ; is negative on odd frames, we only negate the result on those frames.
        LSR $01 : BCC .sign_normalize_dx
        
        EOR.b #$80 : STA $00
    
    .sign_normalize_dx
    
        LDA $00 : BMI .terminate
        
        LDA $E8 : ADD .offsets_low, Y : ROL $00 : CMP $0B18, X         : PHP
        LDA $E9                       : LSR $00 : ADC .offsets_high, Y : PLP : SBC $0B20, X : STA $00
        
        ; See previous comment regarding sign normalization.
        LSR $02 : BCC .sign_normalize_dy
        
        EOR.b #$80 : STA $00
    
    .sign_normalize_dy
    
        LDA $00 : BPL .in_range_xy
    
    .terminate
    
        ; Terminate the overlord.
        STZ $0B00, X
        
        TXA : ASL A : TAY
        
        REP #$20
        
        LDA $0B48, Y : STA $00 : CMP.w #$FFFF : PHP
        
        LSR #3 : ADD.w #$EF80 : STA $01
        
        ; Why it wouldn't participate, I don't really know.
        PLP : SEP #$20 : BCS .not_participating_in_death_buffer
        
        LDA.b #$7F : STA $03
        
        LDA $00 : AND.b #$07 : TAY
        
        LDA [$01] : AND $F24B, Y : STA [$01]
    
    .in_range_xy
    .not_participating_in_death_buffer
    
        RTS
    }

; ==============================================================================

    ; *$4C114-$4C174 LONG
    Dungeon_ResetSprites:
    {
        ; Moves current room's data into reserve (gets ready for transition)
        
        PHB : PHK : PLB
        
        ; $4C176 IN ROM; Transfer a lot of sprite data to other places.
        JSR Dungeon_CacheTransSprites
        
        ; Make Link drop whatever he’s carrying.
        STZ $0309 : STZ $0308
        
        ; $4C22F IN ROM; Zeroes out and disables a number of memory locations.
        JSL Sprite_DisableAll
        
        REP #$20
        
        LDA.w #$FFFF : STA $0FBA : STA $0FB8
        
        LDX.b #$00
        
        LDA $048E
    
    .updateRecentRoomsList
    
        CMP $0B80, X : BEQ .alreadyInList
        
        INX #2 : CPX.b #$07 : BCC .updateRecentRoomsList
        
        LDA $0B86 : STA $00
        LDA $0B84 : STA $0B86
        LDA $0B82 : STA $0B84
        LDA $0B80 : STA $0B82
        LDA $048E : STA $0B80
        
        REP #$10
        
        LDA $00 : CMP.w #$FFFF : BEQ .nullEntry
        
        ASL A : TAX
        
        ; Tells the game that next time we enter that room the sprites need
        ; a complete fresh (e.g. if any have gotten killed)
        LDA.w #$0000 : STA $7FDF80, X
    
    .nullEntry
    .alreadyInList
    
        SEP #$30
        
        JSR Dungeon_LoadSprites
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4C175-$4C22E BRANCH LOCATION
    pool Dungeon_CacheTransSprites:
    {
    
    .easy_out
        RTS
    
    ; *$4C176 ENTRY POINT
    Dungeon_CacheTransSprites:
    {
        ; Don't do this routine if we’re outside.
        LDA $1B : BEQ .easy_out
        
        ; Use $0FFA as a place holder.
        STA $0FFA
        
        ; We’re going to cycle through all 16 sprites.
        LDX.b #$0F
    
    .nextSprite
    
        ; Transfer sprite data to an extended region
        STZ $1D00, X
        
        LDA $0E20, X : STA $1D10, X
        LDA $0D10, X : STA $1D20, X
        LDA $0DC0, X : STA $1D60, X
        LDA $0D30, X : STA $1D30, X
        LDA $0D00, X : STA $1D40, X
        LDA $0D20, X : STA $1D50, X
        
        LDA $0F00, X : BNE .inactiveSprite
        
        LDA $0DD0, X : CMP.b #$04 : BEQ .inactiveSprite
        
        ; frozen
        CMP.b #$0A : BEQ .inactiveSprite
        
        STA $1D00, X
        
        LDA $0D90, X : STA $1D70, X
        LDA $0EB0, X : STA $1D80, X
        LDA $0F50, X : STA $1D90, X
        LDA $0B89, X : STA $1DA0, X
        LDA $0DE0, X : STA $1DB0, X
        LDA $0E40, X : STA $1DC0, X
        LDA $0F20, X : STA $1DD0, X
        LDA $0D80, X : STA $1DE0, X
        LDA $0E60, X : STA $1DF0, X
        
        LDA $0DA0, X : STA $7FFA5C, X
        LDA $0DB0, X : STA $7FFA6C, X
        LDA $0E90, X : STA $7FFA7C, X
        LDA $0E80, X : STA $7FFA8C, X
        LDA $0F70, X : STA $7FFA9C, X
        LDA $0DF0, X : STA $7FFAAC, X
        
        LDA $7FF9C2, X : STA $7FFACC, X
        LDA $0BA0, X   : STA $7FFADC, X
    
    .inactiveSprite
    
        DEX : BMI .done
        
        JMP .nextSprite
    
    .return
    
        RTS
    }

; =============================================================

    ; *$4C22F-$4C28F LONG
    Sprite_DisableAll:
    {
        LDX.b #$0F
    
    .nextSprite
        
        ; sprite is deactivated already, ignore it
        LDA $0DD0, X : BEQ .ignoreSprite
        
        ; Are we indoors?
        LDA $1B : BNE .indoors
        
        ; Is it a warp vortex? (created my mirror)
        LDA $0E20, X : CMP.b #$6C : BEQ .ignoreSprite

    .indoors

        ; kill the sprite momentarily
        STZ $0DD0, X

    .ignoreSprite

        DEX : BPL .nextSprite
        
        ; going to cycle through the special effects
        LDX.b #$09

    .deactivateEffects

        ; Deactivate all special effects
        STZ $0C4A, X
        
        DEX : BPL .deactivateEffects
        
        STZ $02EC
        
        STZ $0B6A : STZ $0B9B : STZ $0B88 : STZ $0B99
        
        STZ $0FB4
        
        STZ $0B9E : STZ $0CF4
        
        STZ $0FF9 : STZ $0FF8 : STZ $0FFB : STZ $0FFC : STZ $0FFD : STZ $0FC6
        
        STZ $03FC
        
        LDX.b #$07

    .deactivateOverlords

        STZ $0B00, X
        
        DEX : BPL .deactivateOverlords
        
        LDX.b #$1D

    .disableSpecialAnimations

        ; disable all the special animations currently ongoing
        LDA.b #$00 : STA $7FF800, X
        
        DEX : BPL .disableSpecialAnimations
        
        RTL
    }

; ==============================================================================
    
    ; vars
    !dataPtr      = $00
    !spriteSlot   = $02
    !spriteSlotHi = $03 ; (high byte)
    !dataOffset   = $04
    
    ; *$4C290-$4C2D4 LOCAL
    Dungeon_LoadSprites:
    {
        ; Dungeon sprite loader
        
        REP #$30
        
        LDA $048E : ASL A : TAY
        
        ; (update: Black Magic ended up hooking $4C16E)
        ; $4D62E is the pointer table for the sprite data in each room.
        LDA $D62E, Y : STA !dataPtr
        
        ; Load the room index again. Divide by 8. why... I’m not sure.
        LDA $048E : LSR #3
        
        SEP #$30
        
        ; Used to offset the high byte of pixel addresses in rooms. (X coord)
        AND.b #$FE : STA $0FB1
        
        ; Load the room index yet again.
        ; Used to offset the high byte of pixel addresses in rooms. (Y coord)
        LDA $048E : AND.b #$0F : ASL A : STA $0FB0
        
        ; Not sure what this does yet...
        LDA (!dataPtr) : STA $0FB3
        
        LDA.b #$01 : STA !dataOffset
        
        STZ !spriteSlot
        STZ !spriteSlotHi
    
    .nextSprite
    
        LDY !dataOffset
        
        LDA (!dataPtr), Y : CMP.b #$FF
        
        BEQ .endOfSpriteList
        
        JSR Dungeon_LoadSprite ; $4C327 IN ROM
        
        ; Increment the slot we’re saving to. ($0E20, $0E21, ...)
        INC !spriteSlot
        
        INC !dataOffset
        INC !dataOffset
        INC !dataOffset
        
        BRA .nextSprite
    
    .endOfSpriteList
    
        RTS
    } 

; ==============================================================================

    ; $4C2D5-$4C2F4 DATA
    Dungeon_ManuallySetSpriteDeathFlag
    {
    
    .flags
        dw $0001, $0002, $0004, $0008, $0010, $0020, $0040, $0080
        dw $0100, $0200, $0400, $0800, $1000, $2000, $4000, $8000
    }

; ==============================================================================

    ; *$4C2F5-$4C326 LONG
    Dungeon_ManuallySetSpriteDeathFlag:
    {
        PHB : PHK : PLB
        
        LDA $1B : BEQ .return
        
        LDA $0CAA, X : LSR A : BCS .return
        
        LDA $0BC0, X : BMI .return
        
        STA $02
        STZ $03
        
        REP #$30
        
        PHX
        
        LDA $048E : ASL A : TAX
        
        LDA $02 : ASL A : TAY
        
        ; Keep this fucker from respawning
        LDA $7FDF80, X : ORA .flags, Y : STA $7FDF80, X
        
        PLX
        
        SEP #$30
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4C327-$4C3E7 LOCAL
    Dungeon_LoadSprite:
    {
        ; LOAD’S SPRITE TYPES AND INFO INTO ROOM’S MEMORY
        ; ALSO DOES OVERLORDS ($0B00, X)

        INY #2
        
        ; Examine the sprite type first... Is it a key?
        LDA (!dataPtr), Y : TAX : CPX.b #$E4 : BNE .notKey
        
        DEY #2
        
        ; Check the key's Y coordinate
        LDA (!dataPtr), Y : INY #2 : CMP.b #$FE : BEQ .isKey
        
        ; If it's 16 pixels higher than that, drop a big key
        CMP.b #$FD : BNE .notOverlord
        
        JSR $C345 ; $4C345 IN ROM
        
        ; Set $0CBA to 0x02 (means it's a big key)
        INC $0CBA, X 
        
        RTS
    
    ; *$4C345 ALTERNATE ENTRY POINT
    .isKey
    
        DEC !spriteSlot
        
        LDX !spriteSlot : LDA.b #$01 : STA $0CBA, X
        
        RTS
    
    .notKey
    
        DEY
        
        ; Examine its X coordinate, and go back to the sprite type position.
        LDA (!dataPtr), Y : INY : CMP.b #$E0 : BCC .notOverlord ; If X coord < 0xE0
        
        JSR Dungeon_LoadOverlord ; $4C3E8 IN ROM ; Load the overlord’s information into memory.
        
        ; Since this isn’t a normal sprite, we don’t want to throw off their loading mechanism, 
        ; b/c the normal sprites are loaded in a linear order into $0E20, X, while these overlords go to $0B00, X.
        DEC !spriteSlot
        
        RTS
    
        ; Normal sprite, not an overlord.
    .notOverlord
    
        ; Normal sprite, not an overlord.
        
        ; Checking for sprites with a special specific property
        LDA $0DB725, X : AND.b #$01
        
        BNE .notSpawnedYet
        
        REP #$30
        
        PHY : PHX
        
        ; Load the room index, multiply by 2.
        LDA $048E : ASL A : TAX
        
        ; $02 is the current slot in $0E20, X to load into.
        LDA !spriteSlot : ASL A : TAY
        
        ; Apparently information on whether stuff has been loaded is stored for each room?
        LDA $7FDF80, X : AND $C2D5, Y
        
        PLX : PLY
        
        CMP.w #$0000
        
        SEP #$30
        
        BEQ .notSpawnedYet
        
        ; It spawned, we’re done, genius.
        RTS

    .notSpawnedYet

        ; Give X the loading slot number.
        LDX !spriteSlot
        DEY #2
        
        ; Send the sprite an initialization message.
        LDA #$08 : STA $0DD0, X
        
        ; Examine the Y coordinate for the sprite. (Buffer at $0FB5)
        LDA (!dataPtr), Y : STA $0FB5 
        
        ; Use the MSB of the Y coordinate to determine the floor the sprite is on.
        AND.b #$80 : ASL A : ROL A : STA $0F20, X
        
        ; Load the sprite’s Y coordinate, multiply by 16 to give it’s in-game Y coordinate. (In terms of pixels)
        LDA ($00), Y : ASL #4 : STA $0D00, X
        
        LDA $0FB1 : ADC.b #$00 : STA $0D20, X
        
        ; Next load the X coordinate, and convert to Pixel coordinates.
        INY
        
        LDA (!dataPtr), Y : STA $0FB6 : ASL #4 : STA $0D10, X
        
        ; And set the upper byte of the X coordinate, of course.
        LDA $0FB0 : ADC.b #$00 : STA $0D30, X
        
        ; Looking at the sprite type now.
        INY
        
        ; Set the sprite type.
        LDA (!dataPtr), Y : STA $0E20, X
        
        ; Set the subtype to zero.
        STZ $0E30, X
        
        ; Examine bits 5 and 6 of the Y (block) coordinate.
        LDA $0FB5 : AND.b #$60 : LSR #2 : STA $0FB5
        
        ; Provides the lower three bits of the subtype. 
        ; But since all three bits cannot be set for us to be here, it follows only certain subtypes will arise.
        LDA $0FB6 : LSR #5
        
        ; Determine a subtype, if necessary.
        ORA $0FB5 : STA $0E30, X
        
        ; Store slot information into this array.
        LDA $02 : STA $0BC0, X
        
        ; Zero out the sprite drop variable (what it drops when killed).
        STZ $0CBA, X
        
        RTS
    }

; =============================================================

    ; *$4C3E8-$4C44D LOCAL
    Dungeon_LoadOverlord:
    {
        ; LOADS OVERLORD INFORMATION INTO A ROOM’S MEMORY
        
        LDX.b #$07 ; We’re going to cycle through the 8 overlord slots.
    
    .nextSlot
    
        ; Are there any overlords in this slot?
        LDA $0B00, X : BEQ .emptySlot
        
        DEX : BPL .nextSlot
        
        RTS
    
    .emptySlot
    
        ; Fill the overlord slot into $0B00, X
        LDA (!dataPtr), Y : NOP : STA $0B00, X
        
        DEY #2
        
        ; Now examine the Y coordinate.
        ; Store it’s floor status here.
        LDA (!dataPtr), Y : AND.b #$80 : ASL A : ROL A : STA $0B40, X
        
        ; Convert the Y coordinate to a pixel address, and store it here.
        LDA (!dataPtr), Y : ASL #4 : STA $0B18, X
        
        LDA $0FB1 : ADC.b #$00 : STA $0B20, X
        
        INY
        
        ; Now convert the X coordinates to pixels.
        LDA (!dataPtr), Y : ASL #4 : STA $0B08, X
        
        LDA $0FB0 : ADC.b #$00 : STA $0B10, X
        
        JSR Overworld_LoadOverlord_misc
        
        ; Load the overlord type and check for various special cases.
        LDA $0B00, X : CMP.b #$0A : BEQ .needsTimer
                       CMP.b #$0B : BEQ .needsTimer
                       CMP.b #$03 : BNE .noAdjustment
        
        LDA.b #$FF : STA $0B30, X
        
        LDA $0B08, X : SUB.b #$08 : STA $0B08, X
    
    .noAdjustment
    
        RTS
    
    .needsTimer
    
        ; Set up a timer
        LDA.b #$A0 : STA $0B30, X
        
        RTS
    }

; =============================================================

    ; *$4C44E-$4C498 LONG
    Sprite_ResetAll:
    {
        JSL Sprite_DisableAll  ; $4C22F IN ROM
    
    ; *$4C452 ALTERNATE ENTRY POINT
    .justBuffers
    
        STZ $0FDD : STZ $0FDC : STZ $0FFD
        STZ $02F0 : STZ $0FC6 : STZ $0B6A
        STZ $0FB3
        
        LDA $7EF3CC : CMP.b #$0D
        
        ; branch if Link has the super bomb tagalong following him
        BEQ .superBomb
        
        LDA.b #$FE : STA $04B4
    
    .superBomb
    
        REP #$10
        
        LDX.w #$0FFF
        LDA.b #$00
    
    .clearLocationBuffer
    
        STA $7FDF80, X : DEX
        
        BPL .clearLocationBuffer
        
        LDX.w #$01FF
    
    .clearDeathBuffer
    
        STA $7FEF80, X : DEX
        
        BPL .clearDeathBuffer
        
        SEP #$10
        
        LDY.b #$07
        LDA.b #$FF
    
    .clearRecentRoomsList
    
        STA $0B80, Y : DEY
        
        BPL .clearRecentRoomsList
        
        RTL
    }

; ==============================================================================

    ; *$4C499-$4C4AB LONG
    Sprite_OverworldReloadAll:
    {
        JSL Sprite_DisableAll
        JSL Sprite_ResetAll_justBuffers
    
    ; *$4C49D ALTERNATE ENTRY POINT
    .justLoad
    
        PHB : PHK : PLB
        
        JSR LoadOverworldSprites
        JSR $C55E ; $4C55E IN ROM
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4C4AC-$4C55D LOCAL
    LoadOverworldSprites:
    {
        ; Loads overworld sprite information into memory ($7FDF80, X is one such array)
        
        ; calculate lower bounds for X coordinates in this map
        LDA $040A : AND.b #$07 : ASL A : STZ $0FBC : STA $0FBD
        
        ; calculate lower bounds for Y coordinates in this map
        LDA $040A : AND.b #$3F : LSR #2 : AND.b #$0E : STA $0FBF : STZ $0FBE
        
        LDA $040A : TAY
        
        LDX $C635, Y : STX $0FB9 : STZ $0FB8 
        STX $0FBB    : STZ $0FBA
        
        REP #$30
        
        ; What Overworld area are we in?
        LDA $040A : ASL A : TAY
        
        SEP #$20
        
        ; load the game state variable
        LDA $7EF3C5
        
        CMP.b #$03 : BEQ .secondPart
        CMP.b #$02 : BEQ .firstPart
        
        ; Load the "Beginning" sprites for the Overworld.
        LDA $C881, Y : STA $00
        LDA $C882, Y
        
        BRA .loadData
    
    .secondPart
    
        ; Load the "Second part" sprites for the Overworld.
        LDA $CA21, Y : STA $00
        LDA $CA22, Y
        
        BRA .loadData
    
    .firstPart
    
        ; Load the "First Part" sprites for the Overworld.
        LDA $C901, Y : STA $00
        LDA $C902, Y
    
    .loadData
    
        STA $01
        
        LDY.w #$0000
    
    .nextSprite
    
        ; Read off the sprite information until we reach a #$FF byte.
        LDA ($00), Y : CMP.b #$FF : BEQ .stopLoading
        
        INY #2
        
        ; Is this a “Falling Rocks” sprite?
        LDA ($00), Y : DEY #2 : CMP.b #$F4 : BNE .notFallingRocks
        
        ; Set a "falling rocks" flag for the area and skip past this sprite
        INC $0FFD
        
        INY #3
        
        BRA .nextSprite
    
    .notFallingRocks ; Anything other than falling rocks.
    
        LDA ($00), Y : PHA : LSR #4 : ASL #2 : STA $02 : INY
        
        LDA ($00), Y : LSR #4 : ADD $02 : STA $06
        
        PLA : ASL #4 : STA $07
        
        ; All this is to tell us where to put the sprite in the sprite map.
        LDA ($00), Y : AND.b #$0F : ORA $07 : STA $05
        
        ; The sprite / overlord index as stored as one plus it’s normal index. Don’t ask me why yet.
        INY : LDA ($00), Y : LDX $05 : INC A : STA $7FDF80, X ; Load them into what I guess you might call a sprite map.
        
        ; Move on to the next sprite / overlord.
        INY
        
        BRA .nextSprite
    
    .stopLoading
    
        SEP #$10
        
        RTS
    }

; ==============================================================================
    
    ; *$4C55E-$4C58E LOCAL
    {
        LDA $E2 : PHA
        LDA $E3 : PHA
        
        LDA $069F : PHA
        
        LDA.b #$FF : STA $069F
        
        LDY.b #$15
    
    .loop
    
        PHY
        
        JSR $C5BB ; $4C5BB IN ROM
        
        PLY
        
        ; Move the scanning location right by 16 pixels each loop
        LDA $E2 : ADD.b #$10 : STA $E2
        LDA $E3 : ADC.b #$00 : STA $E3
        
        DEY : BPL .loop
        
        PLA : STA $069F
        
        PLA : STA $E3
        PLA : STA $E2
        
        RTS
    }

; ==============================================================================
    
    ; *$4C58F-$4C5B6 LONG
    Sprite_RangeBasedActivation:
    {
        PHB : PHK : PLB
        
        LDA $11 : BEQ .alpha
        
        JSR $C5BB ; $4C5BB IN ROM
        JSR $C5FA ; $4C5FA IN ROM
        
        PLB
        
        RTL
    
    .alpha
    
        LDA $0FB7 : AND.b #$01 : BNE .beta
        
        JSR $C5BB ; $4C5BB IN ROM
    
    .beta
    
        LDA $0FB7 : AND.b #$01 : BEQ .gamma
        
        JSR $C5FA ; $4C5FA IN ROM
    
    .gamma
    
        INC $0FB7
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $4C5B7-$4C5BA DATA
    {
    
    ; \task Name these sublabels and the routines that use them.
        db $10, $F0
        
        db $01, $FF
    }

; ==============================================================================
   
    ; *$4C5BB-$4C5F5 LOCAL
    {
        LDY.b #$00
        
        ; Related to bombs? (i.e. no fucking clue)
        LDA $069F : BEQ .return
                    BPL .beta
        
        INY
    
    .beta
    
        ; If $069F is negative, this subtracts 0x0010, otherwise it adds 0x0110
        LDA $E2 : ADD $C5B7, Y : STA $0E
        LDA $E3 : ADC $C5B9, Y : STA $0F
        
        ; $0C[0x2] = BG2VOFS - 0x30
        LDA $E8 : SUB.b #$30 : STA $0C
        LDA $E9 : SBC.b #$00 : STA $0D
        
        LDX.b #$15
    
    .vertical_loop
    
        JSR $C6F5 ; $4C6F5 IN ROM
        
        REP #$20
        
        ; Each loop, move 16 pixels down on the map
        LDA $0C : ADD.w #$0010 : STA $0C
        
        SEP #$20
        
        DEX : BPL .vertical_loop
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $4C5F6-$4C5F9 DATA
    {
    
    ; \task Name these sublabels and the routines that use them.
        db $10, $F0
    
        db $01, $FF
    }

; ==============================================================================

    ; *$4C5FA-$4C634 LOCAL
    {
        LDY.b #$00
        
        LDA $069E : BEQ .return
                    BPL .beta
        
        INY
    
    .beta
    
        LDA $E8 : ADD $C5F6, Y : STA $0C
        LDA $E9 : ADC $C5F8, Y : STA $0D
        
        LDA $E2 : SUB.b #$30 : STA $0E
        LDA $E3 : SBC.b #$00 : STA $0F
        
        LDX.b #$15
    
    .horizontalLoop
    
        JSR $C6F5 ; $4C6F5 IN ROM
        
        REP #$20
        
        ; Each loop, move 16 pixels to the right on the map
        LDA $0E : ADD.w #$0010 : STA $0E
        
        SEP #$20
        
        DEX : BPL .horizontalLoop
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $4C635-$4C6F4 DATA
    {
        ; \task Name these sublabels and the routines that use them.
        ; These are mostly known to be map sizes. 
        db $04, $04, $02, $04
        db $04, $04, $04, $02
        db $04, $04, $04, $04
        db $04, $04, $04, $04
        
        db $02, $02, $02, $02
        db $02, $02, $02, $02
        db $04, $04, $02, $04
        db $04, $02, $04, $04
        
        db $04, $04, $02, $04
        db $04, $02, $04, $04
        db $02, $02, $02, $02
        db $02, $02, $02, $02
        
        db $04, $04, $02, $02
        db $02, $04, $04, $02
        db $04, $04, $02, $02
        db $02, $04, $04, $02
        
        db $04, $04, $02, $04
        db $04, $04, $04, $02
        db $04, $04, $04, $04
        db $04, $04, $04, $04
        
        db $02, $02, $02, $02
        db $02, $02, $02, $02
        db $04, $04, $02, $04
        db $04, $02, $04, $04
        
        db $04, $04, $02, $04
        db $04, $02, $04, $04
        db $02, $02, $02, $02
        db $02, $02, $02, $02
        
        db $04, $04, $02, $02
        db $02, $04, $04, $02
        db $04, $04, $02, $02
        db $02, $04, $04, $02
        
        db $04, $04, $02, $04
        db $04, $04, $04, $02
        db $04, $04, $04, $04
        db $04, $04, $04, $04
        
        db $02, $02, $02, $02
        db $02, $02, $02, $02
        db $04, $04, $02, $04
        db $04, $02, $04, $04
        
        db $04, $04, $02, $04
        db $04, $02, $04, $04
        db $02, $02, $02, $02
        db $02, $02, $02, $02
        
        db $04, $04, $02, $02
        db $02, $04, $04, $02
        db $04, $04, $02, $02
        db $02, $04, $04, $02
    }

; ==============================================================================

    ; *$4C6F5-$4C730 LOCAL
    {
        REP #$20
        
        LDA $0E : SUB $0FBC : CMP $0FB8 : BCS .outOfRange
        
        XBA : STA $00
        
        LDA $0C : SUB $0FBE : CMP $0FBA : BCS .outOfRange
        
        SEP #$20
        
        XBA : ASL #2 : ORA $00 : STA $01
        
        ; $00 = $0C & 0xF0
        LDA $0C : AND.b #$F0 : STA $00
        
        ; $00 |= ($0E >> 4)
        LDA $0E : LSR #4 : ORA $00 : STA $00
        
        PHX
        
        JSR $C739 ; $4C739 IN ROM
        
        PLX
    
    .alpha
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $4C731-$4C738 DATA
    {
    
    ; \task Name these sublabels and the routines that use them.
        db $80, $40, $20, $10, $08, $04, $02, $01
    }

; ==============================================================================
    
    ; *$4C739-$4C76F LOCAL
    {
        REP #$20
        
        LDA $00 : ADD.w #$DF80 : STA $05
        
        SEP #$20
        
        ; $05 = $7FDF80 + offset.
        LDA.b #$7F : STA $07
        
        LDA [$05] : BEQ .alpha
        
        REP #$20
        
        LDA $00 : LSR #3 : ADD.w #$EF80 : STA $02
        
        SEP #$20
        
        LDA.b #$7F : STA $04 ; $07 = $7FEF80 + offset
        
        LDA $00 : AND.b #$07 : TAY
        
        LDA [$02] : AND $C731, Y : BNE .alpha
        
        JSR Overworld_LoadSprite
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$4C770-$4C80A LOCAL
    Overworld_LoadSprite:
    {
        ; For some reason, sprite indices loaded from here are one less than
        ; what is loaded. Here, we’re really referring to $F3 sprites, not a
        ; $F4 limit.
        LDA [$05] : CMP.b #$F4 : BCC .normalSprite
        
        JSR Overworld_LoadOverlord
        
        RTS
    
    .normalSprite
    
        LDX.b #$04
        
        CMP.b #$58 : BEQ .slotLimited
        
        LDX.b #$05
        
        CMP.b #$D0 : BEQ .slotLimited
        
        LDX.b #$0D
        
        CMP.b #$58 : BEQ .slotLimited
        CMP.b #$EB : BEQ .slotLimited
        CMP.b #$53 : BEQ .slotLimited
        CMP.b #$F3 : BNE .slotLimited
        
        ; By default sprites can go in slots 0 through 0x0E
        LDX.b #$0E
    
    .slotLimited
    .nextSlot
    
        LDA $0DD0, X : BEQ .emptySlot
        
        LDA $0E20, X : CMP.b #$41 : BNE .notSoldier
        
        LDA $0DB0, X : BNE .emptySlot
    
    .notSoldier
    
        DEX : BPL .nextSlot
        
        RTS
    
    .emptySlot
    
        LDA [$02] : ORA $C731, Y : STA [$02]
        
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : STA $0BC0, X
        
        SEP #$20
        
        PLX : LDA [$05] : DEC A : STA $0E20, X ; Load up a sprite here
        
        LDA.b #$08 : STA $0DD0, X
        
        LDA $00 : ASL #4 : STA $0D10, X
        
        LDA $00 : AND.b #$F0 : STA $0D00, X
        LDA $01 : AND.b #$03 : STA $0D30, X
        
        LDA $01 : LSR #2 : STA $0D20, X
        
        LDA $0D30, X : ADD $0FBD : STA $0D30, X
        LDA $0D20, X : ADD $0FBF : STA $0D20, X
        
        STZ $0F20, X : STZ $0E30, X : STZ $0CBA, X
        
        RTS
    }

; ==============================================================================

    ; *$4C80B-$4C880 LOCAL
    Overworld_LoadOverlord:
    {
        ; APPEARS TO BE THE METHOD OF LOADING OVERLORDS ON THE OVERWORLD.
        ; We’re going to cycle through the 8 Overlord positions
        LDX.b #$07
    
    .nextSlot
    
        LDA $0B00, X : BEQ .openSlot
        
        DEX : BPL .nextSlot
        
        RTS
    
    .openSlot
    
        ; Make the overlord appear alive in the "death" buffer. aka alive buffer
        LDA [$02] : ORA $C731, Y : STA [$02]
        
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        ; Store the offset into $7FDF80 that this overlord uses
        LDA $00 : STA $0B48, X
        
        SEP #$20
        
        PLX
        
        ; Overlord's type number = the original data value - 0xF3
        LDA [$05] : SUB.b #$F3 : STA $0B00, X : PHA
        
        LDA $00 : ASL #4
        
        PLY : CPY.b #$01 : BNE .gamma
        
        ADD.b #$08
    
    .gamma
    
        STA $0B08, X
        
        LDA $00 : AND.b #$F0 : STA $0B18, X
        LDA $01 : AND.b #$03 : STA $0B10, X
        
        LDA $01 : LSR #2 : STA $0B20, X
        
        LDA $0B10, X : ADD $0FBD : STA $0B10, X
        LDA $0B20, X : ADD $0FBF : STA $0B20, X
        STZ $0B40, X
    
    ; *$4C871 ALTERNATE ENTRY POINT
    .misc
    
        ; The area the overlord is residing in
        LDA $040A : STA $0CCA, X
        
        STZ $0B30, X
        STZ $0B28, X
        STZ $0B38, X
        
        RTS
    }

; ==============================================================================

    ; $4C881-$4EC9E DATA
    {
    
        ; \task Fill in a binary file or assembly file that contains
        ; the sprite pointers and data found in this range.
        ; Overworld and dungeon sprite data is here.
    }

; ==============================================================================

    ; $4EC9F-$4ED9E DATA
    pool SpriteExplode_Execute:
    {
    
    .oam_groups
        dw  0,  0 : db $60, $00, $00, $02
        dw  0,  0 : db $60, $00, $00, $02
        dw  0,  0 : db $60, $00, $00, $02
        dw  0,  0 : db $60, $00, $00, $02
        
        dw -5, -5 : db $62, $00, $00, $02
        dw  5, -5 : db $62, $40, $00, $02
        dw -5,  5 : db $62, $80, $00, $02
        dw  5,  5 : db $62, $C0, $00, $02
        
        dw -8, -8 : db $62, $00, $00, $02
        dw  8, -8 : db $62, $40, $00, $02
        dw -8,  8 : db $62, $80, $00, $02
        dw  8,  8 : db $62, $C0, $00, $02
        
        dw -8, -8 : db $64, $00, $00, $02
        dw  8, -8 : db $64, $40, $00, $02
        dw -8,  8 : db $64, $80, $00, $02
        dw  8,  8 : db $64, $C0, $00, $02
        
        dw -8, -8 : db $66, $00, $00, $02
        dw  8, -8 : db $66, $40, $00, $02
        dw -8,  8 : db $66, $80, $00, $02
        dw  8,  8 : db $66, $C0, $00, $02
        
        dw -8, -8 : db $68, $00, $00, $02
        dw  8, -8 : db $68, $00, $00, $02
        dw -8,  8 : db $68, $00, $00, $02
        dw  8,  8 : db $68, $00, $00, $02
        
        dw -8, -8 : db $6A, $00, $00, $02
        dw  8, -8 : db $6A, $40, $00, $02
        dw -8,  8 : db $6A, $80, $00, $02
        dw  8,  8 : db $6A, $C0, $00, $02
        
        dw -8, -8 : db $4E, $00, $00, $02
        dw  8, -8 : db $4E, $40, $00, $02
        dw -8,  8 : db $4E, $80, $00, $02
        dw  8,  8 : db $4E, $C0, $00, $02        
    }

; ==============================================================================

    ; Exploderatin' mode for bosses?
    ; *$4ED9F-$4EDA6 LONG
    SpriteExplode_ExecuteLong:
    {
        PHB : PHK : PLB
        
        JSR SpriteExplode_Execute
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4EDA7-$4EDEE LOCAL
    SpriteExplode_Execute:
    {
        ; 0 = explodes. > 0 = doesn't explode. :p
        LDA $0D90, X : BEQ BRANCH_$4EE0F
        
        LDA $0DF0, X : BNE .draw
        
        STZ $0DD0, X
        
        LDY.b #$0F
    
    .find_other_exploding_sprites_loop
    
        LDA $0DD0, Y : CMP.b #$04 : BEQ .found_one
        
        DEY : BPL .find_other_exploding_sprites_loop
        
        LDY.b #$01 : STY $0AAA
        
        JSL Sprite_VerifyAllOnScreenDefeated : BCS BRANCH_BETA
        
        ; Restore menu functionality. Bit of a \hack, imo.
        STZ $0FFC
    
    .found_one
    
        RTS
    
    .draw
    
        LSR #2 : EOR.b #$07 : STA $00
        
        LDA.b #$00 : XBA
        
        LDA $00
        
        REP #$20
        
        ASL #5 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================

    ; $4EDEF-$4EE0E DATA
    {
    
    .x_offsets_low
        db 0,   4,   8,  12,  -4,  -8, -12,   0
        db 0,   8,  16,  24, -24, -16,  -8,   0
    
    .x_offsets_high
        db 0,   0,   0,   0,  -1,  -1,  -1,   0
        db 0,   0,   0,   0,  -1,  -1,  -1,   0
    }

; ==============================================================================

    ; *$4EE0F-$4EF55 LOCAL
    {
        ; Force sprite to high priority (to make sure it's visible).
        LDA.b #$02 : STA $0F20, X
        
        LDA $0DF0, X : CMP.b #$20 : BEQ .check_heart_container_spawn
        
        JMP $EEAD ; $4EEAD IN ROM
    
    .check_heart_container_spawn
    
        ; Kill the sprite.
        STZ $0DD0, X
        
        STZ $02E4
        
        LDA $5B : CMP.b #$02 : BEQ .cant_spawn_heart_container
        
        JSL Sprite_VerifyAllOnScreenDefeated : BCC .cant_spawn_heart_container
        
        ; Is this sprite Ganon?
        LDY $0E20, X : CPY.b #$D6 : BCS .victory_over_ganon
        
        ; Is it Agahnim?
        CPY.b #$7A : BNE .not_victory_over_agahnim
        
        ; So it's Agahnim... what do we do.
        PHX
        
        JSL PrepDungeonExit
        
        PLX
    
    .cant_spawn_heart_container
    
        JMP $EEAD ; $4EEAD IN ROM
    
    .victory_over_ganon
    
        ; Play the victory song (yay you killed Ganon)
        LDA.b #$13 : STA $012C
        
        JMP $EEAD ; $4EEAD IN ROM
    
    .not_victory_over_agahnim
    
        STY $0FB5
        
        LDA.b #$EA
        LDY.b #$0E
        
        JSL Sprite_SpawnDynamically.arbitrary
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$20 : STA $0F80, Y
        
        LDA $EE : STA $0F20, Y
        
        LDA.b #$02
        
        CPY.b #$09 : BEQ .was_giant_moldorm
        
        LDA.b #$06
    
    .was_giant_moldorm
    
        STA $0D90, Y
        
        LDA $02 : ADD.b #$03 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA $0FB5 : CMP.b #$CE : BNE .wasnt_blind_the_thief
        
        LDA $02 : ADD.b #$10 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        RTS
    
    .wasnt_blind_the_thief
    
        CMP.b #$CB : BNE .wasnt_trinexx
        
        ; Put the heart container in the middle of the room. Probably done
        ; because Trinexx can go wildly off screen.
        LDA.b #$78 : STA $0D10, Y
                     STA $0D00, Y
        
        LDA $23 : STA $0D30, Y
        LDA $21 : STA $0D20, Y
    
    .wasnt_trinexx
    
        RTS
    
    ; *$4EEAD ALTERNATE ENTRY POINT
    
        ; \bug Probably nothing major, but these comparisons seem to assume that
        ; a value from the sprite's main timer has been loaded into A, and that
        ; is clearly not guaranteed if you look at the jump sites.
        CMP.b #$40 : BCC .skip_standard_sprite_proccessing
        CMP.b #$70 : BCS .do_standard_sprite_proccessing
        AND.b #$01 : BNE .skip_standard_sprite_proccessing
    
    .do_standard_sprite_proccessing
    
        JSL SpriteActive_MainLong
    
    .skip_standard_sprite_proccessing
    
        LDA.b #$07 : STA $0E
        
        LDA $0E20, X : STA $0F : CMP.b #$92 : BNE .not_helmasaur_king
        
        LSR $0E
    
    .not_helmasaur_king
    
        LDA $0DF0, X : CMP.b #$C0 : BCC .generate_explosion_sfx_and_sprites
        
        RTS
    
    .generate_explosion_sfx_and_sprites
    
        PHA
        
        AND.b #$03 : BNE .explosion_sfx_delay
        
        LDA.b #$0C : JSL Sound_SetSfx2PanLong
    
    .explosion_sfx_delay
    
        PLA : AND $0E : BNE .anospawn_explosion_sprite
        
        LDA.b #$1C
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$0B : STA $0AAA
        
        LDA.b #$04 : STA $0DD0, Y
        
        LDA.b #$03 : STA $0E40, Y
        
        LDA.b #$0C : STA $0F50, Y
        
        PHX
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA $0F : CMP.b #$92 : BNE .use_normal_x_offsets
        
        TXA : ORA.b #$08 : TAX
    
    .use_normal_x_offsets
    
        LDA $00 : ADD $EDEF, X : STA $0D10, Y
        LDA $01 : ADC $EDFF, X : STA $0D30, Y
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA $0F : CMP.b #$92 : BNE .use_normal_y_offsets
        
        TXA : ORA.b #$08 : TAX
    
    .use_normal_y_offsets
    
        LDA $02 : ADD $EDEF, X
        
        PHP
        
        SUB $04 : STA $0D00, Y
        
        LDA $03 : SBC.b #$00
        
        PLP
        
        ADC $EDFF, X : STA $0D20, Y
        
        PLX
        
        LDA.b #$1F : STA $0DF0, Y : STA $0D90, Y
    
    .anospawn_explosion_sprite
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; \note Current thinking is that this is what kills sprites other than
    ; the boss when a boss is dying..
    ; *$4EF56-$4EF8A LONG
    Sprite_SchedulePeersForDeath:
    {
        LDY.b #$0F
    
    .next_sprite
    
        ; ignore comparison with self
        CPY $0FA0 : BEQ .ignore_sprite
        
        LDA $0DD0, Y : BEQ .ignore_sprite
        
        LDA $0CAA, Y : AND.b #$02 : BNE .ignore_sprite
        
        ; check if sprite is Agahnim
        LDA $0E20, Y : CMP.b #$7A : BEQ .ignore_sprite
        
        LDA.b #$06 : STA $0DD0, Y
        LDA.b #$0F : STA $0DF0, Y
        LDA.b #$00 : STA $0E60, Y
                     STA $0BE0, Y
        
        LDA.b #$03 : STA $0E40, Y
    
    .ignore_sprite
    
        DEY : BPL .next_sprite
        
        RTL
    }

; ==============================================================================

    ; $4EF8B-$4F0CA DATA
    pool Garnish_ScatterDebris:
    {
    
    .x_offsets
        dw  0,  8,  0,  8, -2,  9, -1,  9
        dw -4,  9, -1, 10, -6,  9, -1, 12
        dw -7,  9, -2, 13, -9,  9, -3, 14
        dw -4, -4,  9, 15, -3, -3, -3,  9
        dw -4,  4,  6, 10, -1,  4,  6,  7
        dw  0,  2,  4,  7,  1,  1,  5,  7
        dw  0, -2,  8,  9, -1, -6,  9, 10
        dw -2, -7, 12, 11, -3, -9,  4,  6
    
    .y_offsets
        db   0,  0,  8,  8,   0, -1, 10, 10
        db   0, -3, 11,  7,   1, -4, 12,  8
        db   1, -4, 13,  9,   2, -4, 16, 10
        db  14, 14, -4, 11,  16, 16, 16, -1
        db   2, -5,  5,  1,   3, -7,  8,  2
        db   4, -8,  4, 10,  -9,  4,  4, 12
        db -10,  4,  8, 14, -12,  4,  8, 15
        db -15,  3,  8, 17, -17,  1, 18, 15
    
    .chr
        db $58, $58, $58, $58, $58, $58, $58, $58
        db $58, $58, $58, $58, $58, $58, $58, $58
        db $48, $58, $58, $58, $48, $58, $58, $48
        db $48, $48, $58, $48, $48, $48, $48, $48
        db $59, $59, $59, $59, $59, $59, $59, $59
        db $59, $59, $59, $59, $59, $59, $59, $59
        db $59, $59, $59, $59, $59, $59, $59, $59
        db $59, $59, $59, $59, $59, $59, $59, $59
    
    .properties
        db $80, $00, $80, $40, $80, $40, $80, $00
        db $00, $C0, $00, $80, $80, $40, $80, $00
        db $80, $C0, $00, $80, $00, $00, $80, $00
        db $80, $80, $80, $80, $00, $00, $00, $00
        db $40, $40, $40, $00, $40, $40, $40, $00
        db $40, $40, $00, $00, $80, $00, $40, $40
        db $40, $00, $40, $40, $40, $40, $40, $40
        db $40, $40, $00, $00, $40, $00, $00, $00
    }

; ==============================================================================

    ; $4F0CB-$4F15B JUMP LOCATION
    Garnish_ScatterDebris:
    {
        ; Special animation 0x16
        
        JSR Garnish_PrepOamCoord
        
        LDA $7FF9FE, X : STA $05
        
        LDA $0FC6 : CMP.b #$03 : BCS BRANCH_ALPHA
        
        LDA $7FF92C, X : CMP.b #$03 : BNE BRANCH_BETA
        
        JSR ScatterDebris_Draw
    
    BRANCH_ALPHA:
    
        RTS
    
    BRANCH_BETA:
    
        STA $0FB5
        
        TAY
        
        LDA $7FF90E, X : LSR #2 : EOR.b #$07 : ASL #2
        
        CPY.b #$04 : BEQ BRANCH_GAMMA
        CPY.b #$02 : BNE BRANCH_DELTA
        
        LDY $1B : BNE BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        ADD.b #$20
    
    BRANCH_DELTA:
    
        STA $06
        
        LDY.b #$00
        
        PHX
        
        LDX.b #$03
    
    BRANCH_THETA:
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $EF8B, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        SEP #$20
        
        PLX
        
        LDA $02 : ADD $F00B, X : INY : STA ($90), Y
        
        LDA $0FB5 : BNE BRANCH_EPSILON
        
        LDA.b #$4E
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON
    
        ; Feel I should leave a comment here because of this unusual sequence
        ; of instructions.
        CMP.b #$80 : LDA $F04B, X : BCC BRANCH_ZETA
        
        LDA.b #$F2
    
    BRANCH_ZETA
    
                       INY           : STA ($90), Y
        LDA $F08B, X : INY : ORA $05 : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL BRANCH_THETA
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $4F15C-$4F197 DATA
    pool ScatterDebris_Draw:
    {
    
    .x_offsets
        dw -8,  8, 16, -5,  8, 15, -1,  7
        dw 11,  1,  3,  8
    
    .y_offsets
        db  7,  2, 12,  9,  2, 10, 11,  2
        db 11,  7,  3,  8
    
    .chr
        db $E2, $E2, $E2, $E2, $F2, $F2, $F2, $E2
        db $E2, $F2, $E2, $E2
    
    .properties
        db $00, $00, $00, $00, $80, $40, $00, $80
        db $40, $00, $00, $00
    }

; ==============================================================================

    ; \note Also part of scatter debris.
    ; $4F198-$4F1F7 LOCAL
    ScatterDebris_Draw:
    {
        LDA $7FF90E, X : CMP.b #$10 : BNE .termination_delay
        
        LDA.b #$00 : STA $7FF800, X
    
    .termination_delay
    
        AND.b #$0F : LSR #2 : STA $06
        
        ASL A : ADC $06 : STA $06
        
        LDY.b #$00
        
        PHX
        
        LDX.b #$02
    
    .next_oam_entry
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        SEP #$20
        
        PLX
        
        LDA $02      : ADD .y_offsets, X : INY              : STA ($90), Y
        LDA .chr, X                      : INY              : STA ($90), Y
        LDA .properties, X               : INY : ORA.b #$22 : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$4F1F8-$4F24A LONG
    Sprite_SelfTerminate:
    {
        ; erase the sprite if this bit is set
        LDA $0CAA, X : AND.b #$40 : BNE .erase_sprite
        
        ; Are we in a dungeon? sprites leaving the screen are handled differently
        LDA $1B : BNE .indoors
    
    .erase_sprite
    
        ; If this flag is set, just kill the sprite?
        STZ $0DD0, X
        
        TXA : ASL A : TAY
        
        REP #$20
        
        ; basically the BCS later on is a BEQ in effect
        ; checks if($0BC0, Y == 0xFFFF) 
        LDA $0BC0, Y : STA $00 : CMP.w #$FFFF
        
        PHP
        
        LSR #3 : ADD.w #$EF80 : STA $01
        
        PLP
        
        ; Just realized after a second visit to this routine that... invalid
        ; address really means that it has already been killed.
        SEP #$20 : BCS .invalid_address
        
        ; use $7F as the bank of the address
        LDA.b #$7F : STA $03
        
        PHX
        
        LDA $00 : AND.b #$07 : TAX
        
        LDA [$01] : AND $09F24B, X : STA [$01]
        
        PLX
    
    .invalid_address
    
        LDA $1B : BNE .indoors_2
        
        TXA : ASL A : TAY
        
        LDA.b #$FF : STA $0BC0, Y : STA $0BC1, Y
        
        RTL
    
    .indoors_2
    
        LDA.b #$FF : STA $0BC0, X
    
    .indoors
    
        RTL
    }

; ==============================================================================

    ; $4F24B-$4F252 DATA
    {
    
    ; \task Name this pool (multiple routines use it).
        db ~$80, ~$40, ~$20, ~$10, ~$08, ~$04, ~$02, ~$01
    }

; ==============================================================================

    ; $4F253-$4F26F NULL
    {
        fillbyte $FF
        
        fill $1D
    }

; ==============================================================================

    incsrc "module_death.asm"
    incsrc "module_quit.asm"

; ==============================================================================

    ; $4F7C0-$4F7DD NULL
    pool Empty:
    {
        
    }
    
; ==============================================================================

    incsrc polyhedral.asm

; ==============================================================================
