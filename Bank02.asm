
org $028000

; ==============================================================================

    ; Bank 0x02 - not for the faint of heart

; ==============================================================================

    ; *$10000-$10053 LONG
    Intro_SetupScreen:
    {
        ; Indicate to NMI that updates to sprites will not be occurring
        LDA.b #$80 : STA $0710
        
        JSL EnableForceBlank ; $93D in Rom, resets screen and HDMA
        
        ; only enable OBJ on main screen
        LDA.b #$10 : STA $1C
        
        ; subscreen has nothing on it.
        STZ $1D
        
        JSR Intro_InitBgSettings
        
        ; Indicates that clipping is done using the inverted window mask mode.
        LDA.b #$20 : STA $99
        
        ; Sets sprites to 8x8 or 16x16, name select to 0, and puts sprite tables
        ; at 0x4000 and 0x5000 in VRAM (word addresses).
        LDA.b #$02 : STA $2101
        
        ; This selects the offset to load the "Nintendo" sprite graphics pack.
        LDA.b #$14 : STA $0AAA
        
        JSL Graphics_LoadChrHalfSlot
        
        ; Reset this setting b/c we only needed it for loading the "Nintendo" logo.
        STZ $0AAA
        
        JSR Overworld_LoadMusicIfNeeded
        
        REP #$20
        
        LDX.b #$80 : STX $2115
        
        ; target vram address is $27F0 (word)
        LDA.w #$27F0 : STA $2116
        
        LDX.b #$20 : LDA.w #$7FFF
    
    ; Will plug initialize sprite palette 1 to be completely white
    .initSP1
    
        ; zero out this portion of VRAM
        STZ $2118
        
        STA $7EC620, X
        
        DEX #2 : BPL .initSP1
        
        LDA.w #$1FFE : STA $C8
        LDA.w #$1BFE : STA $CA
        
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; *$10054-$10115 LONG
    Intro_ValidateSram:
    {
        REP #$30
        
        STZ $00
    
    .checkNextSlot
    
        ; $848C contains the offsets for each sram save slot. i.e. #$0000, #$500, #$A00
        LDX $00 : LDA $00848C, X : TAX : PHX
        
        LDY.w #$0000 : TYA
    
    .calcChecksum
    
        ; Compute the checksum of the save file.
        ADD $700000, X
        
        ; Since #$280 = #$500 / 2, we'll loop through #$500 bytes.
        INX #2
        
        INY : CPY.w #$0280 : BNE .calcChecksum
        
        ; restore the sram save file offset
        PLX
        
        ; If it worked, go to the next file
        ; See if the checksum adds up to this value.
        CMP.w #$5A5A : BEQ .prepareNextSlot
        
        ; If not...
        PLX
        
        ; Try the mirrored version.
        LDY.w #$0000 : TYA
    
    .calcMirrorSum
    
        ; This time we check the mirrored version #$F00 bytes ahead.
        ADD $700F00, X
        
        INX #2
        
        INY : CPY.w #$0280 : BEQ .calcMirrorSum
        
        ; restore the sram save file offset
        PLX
        
        ; Do the same check to see if it adds up correctly.
        ; If it didn't add up correctly again, just go and delete it.
        CMP.w #$5A5A : BNE .delete
        
        LDY.w #$0000
    
    .restoreLoop
    
        ; If it check outs, however, let's copy the good mirrored version to The bad version's slot too!
        LDA $700F00, X : STA $700000, X
        LDA $701000, X : STA $700100, X
        LDA $701100, X : STA $700200, X
        LDA $701200, X : STA $700300, X
        LDA $701300, X : STA $700400, X
        
        INX #2
        
        INY : CPY.w #$0080 : BNE .restoreLoop
    
    .prepareNextSlot
    
        ; Then when we're done, move on to the next save slot.
        INC $00 : INC $00
        
        ; There is no fourth save slot, so if the index is 0x06, we're done.
        LDX $00 : CPX.w #$0006 : BNE .checkNextSlot
        
        ; If we're done, let X = #$FE.
        LDX.w #$00FE
    
    .zeroLoop
    
        ; Then zero out the memory region between $0D00 and $0FFF.
        STZ $0D00, X : STZ $0E00, X : STZ $0F00, X
        
        DEX #2 : BPL .zeroLoop
        
        SEP #$30
        
        ; Finally we're done.
        RTL
    
    .delete
    
        ; Load Y with a big fat zero.
        LDY.w #$0000 : TYA
    
    .deleteLoop
    
        ; We're going to zero out the whole save file. Are you happy? You created a corrupt file!
        STA $700F00, X : STA $700000, X
        STA $701000, X : STA $700100, X
        STA $701100, X : STA $700200, X
        STA $701200, X : STA $700300, X
        STA $701300, X : STA $700400, X
        
        ; Don't forget that 0x80 is half of 0x100, so this make sense.        
        INX #2
        
        DEY : CPY.w #$0080 : BNE .deleteLoop
        
        BRA .prepareNextSlot
    }

; ==============================================================================

    ; *$10116-$1011D JUMP LOCATION
    Intro_LoadTextPointersAndPalettes:
    {
        JSL Text_GenerateMessagePointers
    
    .justPalettes
    
        JSR Intro_LoadPalettes
        
        RTL
    }

; ==============================================================================

    ; $1011E-$10135 DATA TABLE
    {
        ; 0x18 entries used for animated tiles
        db $5D, $5D, $5D, $5D, $5D, $5D, $5D, $5F
        db $5D, $5F, $5F, $5E, $5F, $5E, $5E, $5D
        db $5D, $5E, $5D, $5D, $5D, $5D, $5D, $5D
    }

; ==============================================================================

    ; *$10136-$103B4 JUMP LOCATION
    Module_LoadFile:
    {
        ; Beginning of Module 5, Loading Game Mode
        
        ; 93D IN ROM; Disable Screen (force blank)
        JSL EnableForceBlank
        
        ; Initialize a bunch of tagalong, submodule and other related variables
        ; (document these at some point in the future, but for now they're just confusing)
        STZ $0200
        STZ $03F4
        STZ $02D4
        STZ $02D7
        STZ $02F9
        STZ $0379
        STZ $03FD
        
        JSL Vram_EraseTilemaps.normal
        
        ; Set OAM CHR position to $8000 (byte) / $4000 (word) in VRAM 
        LDA.b #$02 : STA $2101
        
        JSL LoadDefaultGfx
        JSL Sprite_LoadGfxProperties
        JSL Init_LoadDefaultTileAttr
        JSL DecompSwordGfx
        JSL DecompShieldGfx
        JSL Init_Player
        JSL Tagalong_LoadGfx
        
        ; Is this even useful? Seems to set all sprite graphics slots to default
        ; graphics sets really, b/c they're all the same.
        LDA.b #$46 : STA $7EC2FC
                     STA $7EC2FD
                     STA $7EC2FE
                     STA $7EC2FF
        
        ; The Zelda message tagalong counter is 0x200 (frames)
                     STZ $02CD
        LDA.b #$02 : STA $02CE
        
        ; V-IRQ triggers at scanline 0x30
        LDA.b #$30 : STA $FF
        
        ; Check if we’re in the dark world
        LDA $7EF3CA : BEQ .inLightWorld
        
        ; We’re in the dark world, but are we in a dungeon?
        LDA $1B : BNE .indoors
        
        JSL Equipment_DrawItem
        JSL HUD.RebuildLong2
        JSL Equipment_UpdateEquippedItemLong
        
        ; Dying outside in the Dark World apparently doesn't have any bearing on the next load.
        STZ $010A
        
        ; This is the exit that takes Link to the Pyramid of Power.
        ; It's done this way because the PreOverworld module operates via exits
        ; rather than area numbers.
        LDA.b #$20 : STA $A0
                     STZ $A1
        
        ; Go to pre-overworld mode
        LDA.b #$08 : STA $10
        
        STZ $11
        STZ $B0
        
        STZ $04AA
        
        RTL
    
    .inLightWorld
    
        ; If mosaic enabled, branch? This makes very little sense
        LDA $7EC011 : BNE .indoors
        
        LDA $010A : BEQ .notSavedAndContinue
        
        ; See if we need to load a starting point entrance
        LDA $04AA : BEQ .indoors
    
    .notSavedAndContinue
    
        ; If we're not in game state 2 yet, $7EF3C8 alone decides the starting location
        LDA $7EF3C5 : CMP.b #$02 : BCC .indoors
        
        ; If we got here, it means we’re in game state 2 or above
        
        ; Only starting location 5 is enforced when the game state is >= 0x02
        ; I didn't even realize this until recently (9/19/2007)
        ; but this is a starting location that only happens if you die
        ; on the way to returning the Old Man to his cave. It's like 2 rooms, but I guess they figured 
        ; some people would really really suck at the game. So they made starting location 5 put you in the cave
        ; where you meet the old man. I guess the only way you'd conceivably die is from pits or enemies outside.
        LDA $7EF3C8 : CMP.b #$05 : BEQ .indoors
        
        REP #$10
        
        LDX.w #$0185
        
        ; Does Link have the mirror?
        LDA $7EF353 : CMP.b #$02 : BEQ .hasMirror
        
        ; Add the extra entrance to Old Man's cave
        LDX.w #$0184
    
    .hasMirror
    
        STX $1CF0
        
        SEP #$10
        
        JSL Main_ShowTextMessage
        JSR Dungeon_LoadPalettes
        
        LDA.b #$0F : STA $13
        
        LDA.b #$04 : STA $1C
        
        STZ $1D
        
        ; Bring up the box that asks where you'd like to start from
        ; module 1B will fake a text mode engine and wait for input
        LDA.b #$1B : STA $10
        
        RTL
    
    ; *$10208 ALTERNATE ENTRY POINT
    .indoors
    
        LDA.b #$00 : STA $7EC011
        
        ; Apply mosaic settings to BGs 1,2, and 3
        ORA.b #$07 : STA $95
        
        JSL Equipment_DrawItem
        JSL HUD.RebuildLong2
        JSL Equipment_UpdateEquippedItemLong
    
    ; *$1021E JUMP LOCATION
    shared Module_PreDungeon:
    
        ; Beginning of Module 6: Predungeon Mode
        
        REP #$20
        
        ; play an ambient sound effect. (This one is probably silence)
        LDA.w #$0005 : STA $012D
        
        ; zero out the dungeon room index and the previous dungeon room index.
        STZ $A0 : STZ $A2
        
        ; Initialize the room's memory record
        STZ $0402
        
        LDA.w #$0000
        
        ; initialize some color filtering variables related to agahnim.
        STA $7EC019 : STA $7EC01B : STA $7EC01D
        STA $7EC01F : STA $7EC021 : STA $7EC023
        
        SEP #$20
        
        JSR Dungeon_LoadEntrance
        
        ; Tell me what level I’m in. (swamp palace, misery mire, etc.)
        ; 0xff means it’s not a true dungeon. Don’t need keys. Etc..
        LDA $040C : CMP.b #$FF : BEQ .notPalace
        
        ; Is it Hyrule Castle 1?
        CMP.b #$02 : BNE .notHyruleCastle
        
        ; I guess we treat the Hyrule castle keys the same as the Sewer ones.
        ; Why? Because for some reason the developers want them to be
        ; considered the same dungeon in most cases. That's why!    
        LDA.b #$00
    
    .notHyruleCastle
    
        LSR A : TAX
        
        ; Load the number of keys for this dungeon from gameplay data.
        LDA $7EF37C, X
        
    .notPalace
    
        JSL HUD.RebuildIndoor_palace
        
        STZ $045A
        STZ $0458
        
        JSR Dungeon_LoadAndDrawRoom
        
        ; then, Draws BG0 and 1 tilemaps into VRAM from $7E2000 and $7E4000
        ; Loads graphics dependent behavior types for tiles.
        JSL Dungeon_LoadCustomTileAttr
        
        ; Derived from entrance index.
        LDX $0AA1
        
        LDA $02811E, X : TAY
        
        JSL DecompDungAnimatedTiles
        JSL Dungeon_LoadAttrTable
        
        LDA.b #$0A : STA $0AA4
        
        JSL InitTilesets
        
        ; Specify the tileset for throwable objects (rocks, pots, etc).
        LDA.b #$0A : STA $0AB1
        
        JSR Dungeon_LoadPalettes
        
        LDA $02E0 : ORA $56 : BEQ .player_not_using_bunny_gfx
        
        JSL LoadGearPalettes.bunny
    
    .player_not_using_bunny_gfx
    
        REP #$30
        
        LDA $A0 : AND.w #$000F : ASL A  : XBA : STA $062C
        LDA $A0 : AND.w #$0FF0 : LSR #3 : XBA : STA $062E
        
        LDA $A0 : CMP.w #$0104 : BNE .notLinksHouse
        
        LDA $7EF3C6 : AND.w #$0010 : BEQ .hasNoEquipment
        
        ; apparently under these conditions a room can never be dark?
        LDA.w #$0000 : STA $7EC005
    
    .notLinksHouse
    .hasNoEquipment
    
        SEP #$30
        
        JSL $02B8CB ; $138CB IN ROM 
        
        ; set color addition parameters
        LDA.b #$02 : STA $99
        LDA.b #$B3 : STA $9A
        
        ; check light level in room
        LDX $045A
        
        LDA $7EC005 : BNE .darkTransition
        
        LDX.b #$03
        
        ; Have a look at the BG2 setting
        LDY $0414 : BEQ .defaultGfxSetting
        
        LDA.b #$32
        
        ; If "addition"
        CPY.b #$07 : BEQ .customColorMath
        
        LDA.b #$62
        
        ; If "translucent"
        CPY.b #$04 : BEQ .customColorMath
    
    .defaultGfxSetting
    
        LDA.b #$20
    
    .customColorMath
    
        STA $9A
        
    .darkTransition
    
        LDA $02A1E5, X : STA $7EC017
        
        JSL Dungeon_ApproachFixedColor_variable ; $FEC1 IN ROM
        
        LDA.b #$1F : STA $7EC007
        LDA.b #$00 : STA $7EC008
        LDA.b #$02 : STA $7EC009
        
        STZ $0AA9
        STZ $57
        STZ $3A
        STZ $3C
        
        JSR Dungeon_ResetTorchBackgroundAndPlayer
        JSL Link_CheckBunnyStatus ; $7FD22 IN ROM
        JSR $8D71   ; $10D71 IN ROM ; performs initialization and cacheing of some variables
        
        LDA $7EF3CC : CMP.b #$0D : BNE .notSuperBombTagalong
        
        ; If we saved the game having a super bomb, sad to say it's going to be gone.
        LDA.b #$00 : STA $7EF3CC
        
        STZ $04B4
        
        JSL FloorIndicator_hideIndicator ; $57D90 IN ROM
    
    .notSuperBombTagalong
    
        LDA.b #$09 : STA $94
        
        JSL Tagalong_Init
        JSL Sprite_ResetAll      ; $4C44E IN ROM
        JSL Dungeon_ResetSprites
        
        STZ $02F0
        
        INC $04C7
        
        LDA $7EF3C5 : BNE .notOpeningScene
        
        LDA $7EF3C6 : AND.b #$10 : BNE .notOpeningScene
        
        ; Set fixed color at the very start of the game to a .... bluish tint I guess.
        LDA.b #$30 : STA $9C
        LDA.b #$50 : STA $9D
        LDA.b #$80 : STA $9E
        
        LDA.b #$00 : STA $7EC005 : STA $7EC006
        
        JSL $079A2C ; $39A2C IN ROM ; Puts Link into a sleep state at the beginning of the game
    
    .notOpeningScene
    
        ; Put us into the dungeon module
        LDA.b #$07 : STA $010C : STA $10
        
        ; With initial state 0x0F...
        LDA.b #$0F : STA $11
        
        JSR Dungeon_LoadSongBankIfNeeded
        
    ; *$1038C ALTERNATE ENTRY POINT
    .setAmbientSfx
    
        ; If worldstate >= 2
        LDA $7EF3C5 : CMP.b #$02 : BCS .noAmbientRainSfx
        
        ; By default set the ambient sound effect to silence
        LDA.b #$05 : STA $012D
        
        LDA $A4 : BMI .noAmbientRainSfx
        
        REP #$20
        
        ; If this is the sewer room right before sanctuary
        LDA $A0 : CMP.w #$0002 : BEQ .noAmbientRainSfx
        
        ; Is it Sanctuary itself?
        CMP.w #$0012 : BEQ .noAmbientRainSfx
        
        SEP #$20
        
        ; Play the rain ambient sound effect
        LDA.b #$03 : STA $012D
    
    .noAmbientRainSfx
    
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; $103B5-$103B8 LONG
    {
        JSR $8D81   ; $10D81 IN ROM
        
        RTL
    }

; ==============================================================================

    ; $103B9-$103BE Jump Table
    PreOverworld_JumpTable:
    {
        dw PreOverworld_LoadProperties  ; $103C7* Pre-Overworld submodule 0: Loads palettes
        dw $AF19 ; = $12F19* Pre-Overworld submodule 1: Loads overlays
        dw $EDB9 ; = $16DB9* Pre-Overworld submodule 2: Loads level data
    }

; ==============================================================================

    ; *$103BF-$103C6 JUMP LOCATION
    Module_PreOverworld:
    {
        ; Module 0x08, 0x0A
        ; AKA Pre-Overworld 1 and 2:
        
        LDA $11 : ASL A : TAX
        
        ; $103B9 IN ROM; Use the above jump table
        JSR (PreOverworld_JumpTable, X)
        
        RTL
    }

; =============================================

    ; *$103C7-$10569 LOCAL
    PreOverworld_LoadProperties:
    {
        ; Module 0x08.0x00, 0x0A.0x00
        
        ; Clip colors to black before color math inside the color window
        ; (this logic may be inverted by another register, though)
        ; Also enables subscreen addition rather than fixed color addition
        LDA.b #$82 : STA $99
        
        ; Cane of Somaria variable?
        STZ $03F4
        
        ; $1056A IN ROM; If Link has moon pearl
        ; Load his default graphic states and otherwise
        JSL $02856A
        
        ; special branch for if you are outside the normal
        ; overworld area e.g. Master Sword woods
        LDA $10 : CMP.b #$08 : BNE .specialArea
        
        JSR Overworld_LoadExitData
        
        BRA .normalArea
    
    .specialArea
    
        JSR $E9BC ; $169BC IN ROM
    
    .normalArea
    
        JSL Overworld_SetSongList
        
        ; We have no keys on the overworld
        LDA.b #$FF : STA $7EF36F
        
        JSL HUD.RefillLogicLong
        
        LDY.b #$58
        
        ; not sure what theme this is. might be the beginning song
        LDX.b #$02
        
        LDA $8A
        
        CMP.b #$03 : BEQ .setCustomSong
        CMP.b #$05 : BEQ .setCustomSong
        CMP.b #$07 : BEQ .setCustomSong
        
        ; death mountain theme
        LDX.b #$09
        
        LDA $8A
        
        CMP.b #$43 : BEQ .setCustomSong
        CMP.b #$45 : BEQ .setCustomSong
        CMP.b #$47 : BEQ .setCustomSong
        
        LDY.b #$5A
        
        ; If we're in the dark world
        LDA $8A : CMP.b #$40 : BCS .darkWorld
        
        ; Default village theme
        LDX.b #$07
        
        ; Check what phase we're in (If less than phase 3)
        LDA $7EF3C5 : CMP.b #$03 : BCC .beforeAgahnim
        
        ; Default light world theme
        LDX.b #$02
    
    .beforeAgahnim
    
        ; Were we just in the smithy's well?
        LDA $A0 : CMP.b #$E3 : BEQ .setCustomSong
        
        ; Or were we just near a hole with a big fairy?
        CMP.b #$18 : BEQ .setCustomSong
        
        ; Or were we just in the village hole?
        CMP.b #$2F : BEQ .setCustomSong
        
        LDA $A0 : CMP.b #$1F : BNE .notWeirdoShopInVillage
        
        ; Check if we're entering the village
        LDA $8A : CMP.b #$18 : BEQ .setCustomSong
    
    .notWeirdoShopInVillage
    
        LDX.b #$05
        
        ; check if we've received the master sword yet or not
        LDA $7EF300 : AND.b #$40 : BEQ .noMasterSword
        
        ; Set music to default Light World theme
        LDX.b #$02
    
    .noMasterSword
    
        LDA $A0    : BEQ .setCustomSong
        CMP.b #$E1 : BEQ .setCustomSong
    
    .darkWorld
    
        LDX.b #$F3
        
        ; If the volume was set to half, set it back to full
        LDA $0132 : CMP.b #$F2 : BEQ .setSong
        
        ; Use the normal overworld (light world) music
        LDX.b #$02
        
        ; Check phase        ; In phase >= 2
        LDA $7EF3C5 : CMP.b #$02 : BCS .setCustomSong
        
        ; If phase < 2, play the legend music
        LDX.b #$03
    
    .setCustomSong
    
        ; Check world status
        LDA $7EF3CA : BEQ .setSong
        
        ; Not in the lightworld, so play the dark woods theme
        LDX.b #$0D
        
        ; But only in certain OW areas
        LDA $8A : CMP.b #$40 : BEQ .checkMoonPearl
        
        ; Check a certain list of overworld locations
        ; That have the dark forest theme
        CMP.b #$43 : BEQ .checkMoonPearl
        CMP.b #$45 : BEQ .checkMoonPearl
        CMP.b #$47 : BEQ .checkMoonPearl
        
        ; Otherwise play the normal dark world overworld music
        LDX.b #$09
    
    .checkMoonPearl
    
        ; Does Link have a moon pearl?
        LDA $7EF357 : BNE .setSong
        
        ; If not, play that stupid music that plays when you're a bunny in the Dark World.
        LDX.b #$04
    
    .setSong
    
        ; The value written here will take effect during NMI
        STX $0132
        
        JSL DecompOwAnimatedTiles       ; $5394 IN ROM
        JSL InitTilesets                ; $619B IN ROM; Decompress all other graphics
        JSR Overworld_LoadAreaPalettes  ; $14692 IN ROM; Load palettes for overworld
        
        LDX $8A
        
        LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes      ; $755A8 IN ROM; Load some other palettes
        JSL Palette_SetOwBgColor_Long   ; $75618 IN ROM; Sets the background color (changes depending on area)
        
        LDA $10 : CMP.b #$08 : BNE .specialArea2
        
        ; $1465F IN ROM; Copies $7EC300[0x200] to $7EC500[0x200]
        JSR $C65F
        
        BRA .normalArea2
    
    .specialArea2
    
        ; apparently special overworld handles palettes a bit differently?
        JSR $C6EB ; $146EB IN ROM
    
    .normalArea2
    
        JSL $0BFE70 ; $5FE70 IN ROM; Sets fixed colors and scroll values
        
        ; Something fixed color related
        LDA.b #$00 : STA $7EC017
        
        ; Sets up properties in the event a tagalong shows up
        JSL Tagalong_Init
        
        LDA $8A : AND.b #$3F : BNE .notForestArea
        
        LDA.b #$1E
        
        JSL GetAnimatedSpriteTile.variable
    
    .notForestArea
    
        LDA.b #$09 : STA $010C
        
        JSL Sprites_OverworldReloadAll
        
        ; Are we in the dark world? If so, there's no warp vortex there.
        LDA $8A : AND.b #$40 : BNE .noWarpVortex
        
        JSL Sprite_ReinitWarpVortex ; $4AF89 IN ROM
    
    .noWarpVortex
    
        ; The sound of silence (as in, no ambient sound effect)
        LDX.b #$05
        
        LDA $7EF3C5 : CMP.b #$02 : BCS .dontMakeRainSound
        
        ; Ambient rain noise
        LDX.b #$01
    
    .dontMakeRainSound
    
        STX $012D
        
        ; Check if Blind disguised as a crystal maiden was following us when
        ; we left the dungeon area
        LDA $7EF3CC : CMP.b #$06 : BNE .notBlindGirl
        
        ; If it is Blind, kill her (him)!
        LDA.b #$00 : STA $7EF3CC
    
    .notBlindGirl
    
        STZ $6C
        STZ $3A
        STZ $3C
        STZ $50
        STZ $5E
        STZ $0351
        
        ; Reinitialize many of Link's gameplay variables
        JSR $8B0C ; $10B0C IN ROM
        
        LDA $7EF357 : BNE .notBunny
        
        LDA $7EF3CA : BEQ .notBunny
        
        LDA.b #$01 : STA $02E0 : STA $56
        
        LDA.b #$17 : STA $5D
        
        JSL LoadGearPalettes.bunny
    
    .notBunny
    
        ; Set screen to mode 1 with BG3 priority.
        LDA.b #$09 : STA $94
        
        LDA.b #$00 : STA $7EC005
        
        STZ $046C
        STZ $EE
        STZ $0476
        
        INC $11
        INC $16
        
        STZ $0402 : STZ $0403
    
    ; *$1054C ALTERNATE ENTRY POINT
    shared Overworld_LoadMusicIfNeeded:
    
        LDA $0136 : BEQ .no_music_load_needed
        
        SEI
        
        ; Shut down NMI until music loads
        STZ $4200
        
        ; Stop all HDMA
        STZ $420C
        
        STZ $0136
        
        LDA.b #$FF : STA $2140
        
        JSL Sound_LoadLightWorldSongBank
        
        ; Re-enable NMI and joypad
        LDA.b #$81 : STA $4200
    
    .no_music_load_needed
    
        RTS
    }

; ==============================================================================

    ; *$1056A-$10582 LONG
    {
        ; Do we have the Moon pearl?
        LDA $7EF357 : BEQ .noMoonPearl
    
    ; *$10570 ALTERNATE ENTRY POINT
    
        ; Set Link's initial state
        LDA.b #$00 : STA $5D
        
        ; Link is not a bunny, so reset variables relating to his
        ; bunny transformation state
        STZ $03F5
        STZ $03F6
        STZ $03F7
        
        ; Link's graphics are his normal ones, not bunny
        STZ $56
        STZ $02E0
    
    .noMoonPearl
    
        RTL
    }

; ==============================================================================

    ; $10583-$10585 DATA
    pool Module_LocationMenu:
    {
    
    .starting_points
        db 0, 1, 6
    }

; ==============================================================================

    ; *$10586-$105B3 JUMP LOCATION LONG
    Module_LocationMenu:
    {
        ; Beginning of Module 0x1B, Start Location Select
        
        JSL Messaging_Text
        
        LDA $11 : BNE .notBaseSubmodule
        
        STZ $14
        
        JSL EnableForceBlank
        JSL Vram_EraseTilemaps.normal
        
        LDA $7EF3C8 : PHA
        
        LDX $1CE8
        
        LDA.l .starting_points, X : STA $7EF3C8
        
        STZ $B0
        
        ; Finish up with pre dungeon mode after the selection is made
        JSL Module_LoadGame.indoors
        
        PLA : STA $7EF3C8
    
    .notBaseSubmodule
    
        RTL
    }

; ==============================================================================

    ; $105B4-$105B9 JUMP TABLE
    {
        dw $8604 ; = $10604
        dw $8697 ; = $10697
        dw $86A5 ; = $106A5
    }

; ==============================================================================

    ; *$105BA - $105C1 LONG
    {
        ; Note: ending sequence code
        
        ; As usual, the level 2 submodule index.
        LDA $B0 : ASL A : TAX
        
        JSR ($85B4, X) ; ($105B4, X) IN ROM, SEE JUMP TABLE
        
        RTL
    }

; ==============================================================================

    ; $105C2-$10603 DATA TABLE
    {
        dw $1000 ; overworld
        dw $0002 ; dungeon
        dw $1002 ; overworld
        dw $1012 ; overworld
        dw $1004
        dw $1006
        dw $1010
        dw $1014
        dw $100A
        dw $1016
        dw $005D ; dungeon
        dw $0064 ; 
        dw $100E
        dw $1008
        dw $1018
        dw $0180
        dw $4628
        dw $2E27
        dw $2B2B
        dw $2C0E
        dw $291A
        dw $2847
        dw $2827
        dw $282A
        dw $012D
        dw $0140
        dw $0104
        dw $0101
        dw $0111
        dw $4701
        dw $0140
        dw $0101
        dw $0101
    }

; ==============================================================================

    ; *$10604-$10696 LOCAL
    {
        JSL EnableForceBlank          ; $93D IN ROM; Sets the screen mode.
        JSL Vram_EraseTilemaps.normal
        
        ; Activates subscreen color add/subtract mode.
        LDA.b #$82 : STA $99
        
        REP #$20
        
        ; Load the level 1 submodule index.
        LDX $11
        
        ; $105C2, X THAT IS; See the data table at $105C2. Since this is called every other submodule,
        LDA $0285C2, X : STA $A0
        
        SEP #$20
        
        CPX.b #$0C : BEQ .specialArea ; if this is the seventh sequence in the ending
        CPX.b #$1E : BEQ .specialArea
        
        JSR Overworld_LoadExitData
        
        BRA .normalArea
    
    .specialArea
    
        JSR $E851 ; $16851 IN ROM; Needed for running sequence 0xC or 0x1E
        ; This is because they are special outdoor areas (zora's domain and master sword)
    
    .normalArea
    
        STZ $012C   ; No change of music
        STZ $012D   ; No change of sound effects
        
        LDY.b #$58
        
        ; 0x03, 0x05, and 0x07 are all mountain areas.
        LDA $8A : AND.b #$BF
        
        CMP.b #$03 : BEQ .deathMountain
        CMP.b #$05 : BEQ .deathMountain
        CMP.b #$07 : BEQ .deathMountain
        
        ; Just load a different overlay in that case.
        LDY.b #$5A
    
    .deathMountain
    
        JSL DecompOwAnimatedTiles ; $5394 IN ROM
        
        LDA $11 : LSR A : TAX
        
        LDA $0285E2, X : STA $0AA3
        
        LDA $0285F3, X : PHA
        
        JSL InitTilesets                ; $619B IN ROM
        JSR Overworld_LoadAreaPalettes  ; $14692 IN ROM ; Load Palettes
        
        PLA : STA $00
        
        LDX $8A
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes ; $755A8 IN ROM
        
        LDA.b #$01 : STA $0AB2
        
        JSL Palette_Hud ; $DEE52 IN ROM
        
        LDA $11 : BNE BRANCH_4
        
        JSL CopyFontToVram  ; $6556 IN ROM
    
    BRANCH_4:
    
        JSR $C65F   ; $1465F IN ROM
        JSL $0BFE70 ; $5FE70 IN ROM
        
        LDA $8A : CMP.b #$80 : BCC BRANCH_5
        
        JSL Palette_SetOwBgColor_Long ; $75618 IN ROM
    
    BRANCH_5:
    
        LDA.b #$09 : STA $94
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10697-$106A4 LOCAL
    {
        JSR $AF1E ; $12F1E IN ROM
        
        STZ $012C
        STZ $012D
        
        DEC $11
        
        INC $B0
        
        RTS
    }

    ; *$106A5-$106B2 LOCAL
    {
        JSR Overworld_LoadAmbientOverlayAndMapData
        JSL $0E98B9 ; $718B9 IN ROM
        
        STZ $C8
        STZ $C9
        STZ $B0
        
        RTS
    }

    ; *$106B3-$106BF LONG
    {
        JSL $0EAEA6 ; $72EA6 IN ROM
        
        LDA $0416 : BEQ .alpha
        
        JSR Overworld_ScrollMap ; $17273 IN ROM
    
    .alpha
    
        RTL
    }

    ; *$106C0-$106FC LONG
    {
        ; Not sure...
        LDA.b #$21 : STA $0AA1
        
        ; Loads the proper tile set for the scrolling view of Hyrule.
        LDA.b #$3B : STA $0AA2
        
        ; Not sure...
        LDA.b #$2D : STA $0AA3
        
        ; Using the parameters above, loads all the necessary tile sets
        JSL InitTilesets ; $619B IN ROM
        
        ; Put us at the pyrmaid of power
        LDX.b #$5B : STX $8A
        
        ; sets an index for setting $0AB8
        LDA.b #$13 : STA $00
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes ; $755A8 IN ROM; Loads several palettes based on the X = 0x5B above.
        
        ; reload the BG auxiliary 2 palette with a different value
        LDA.b #$03 : STA $0AB5
        
        JSL Palette_OverworldBgAux2    ; $DEF0C IN ROM
        
        JSR Overworld_CgramAuxToMain
        
        JSR $AF1E ; $12F1E IN ROM
        
        STZ $E6
        STZ $E7
        STZ $E0
        STZ $E1
        
        DEC $11
        
        RTL
    }

; ==============================================================================

    ; *$106FD-$1076B LONG
    {
        ; This is only called from the ending module (1A)
        ; It's an initializer for the cinema sequences that are indoors.
        
        JSL EnableForceBlank          ; $93D IN ROM.
        JSL Vram_EraseTilemaps.normal
        
        REP #$20
        
        LDX $11
        
        ; Load the dungeon entrance to use
        LDA $0285C2, X : STA $010E
        
        SEP #$20
        
        JSR Dungeon_LoadEntrance
        
        STZ $045A
        STZ $0458
        
        JSR Dungeon_LoadAndDrawRoom
        
        ; $1011E IN ROM
        LDX $0AA1 : LDA $02811E, X : TAY
        
        JSL DecompDungAnimatedTiles ; $5337 IN ROM
        
        LDA $11 : LSR A : TAX
        
        LDA $0285E2, X : STA $0AA3
        
        LDA $0285F3, X : ASL #2 : TAX
        
        LDA $0ED462, X : STA $0AAD
        LDA $0ED463, X : STA $0AAE
        
        ; Use indoor liftable sprites (pointless for an ending but whatever)
        LDA.b #$0A : STA $0AA4
        
        JSL InitTilesets
        
        LDA.b #$0A : STA $0AB1
        
        JSR Dungeon_LoadPalettes
        
        ; Set screen mode
        LDA.b #$09 : STA $94
        
        STZ $C8
        STZ $C9
        STZ $13
        
        INC $11
        
        JSL $0E98B9 ; $718B9 IN ROM ; Do sprite loading specific to ending mode
        
        RTL
    }

; ==============================================================================

    ; $1076C-$107A1 JUMP TABLE FOR MODULE 0x07
    pool Module_Dungeon:
    {
        ; PARAMETER: X
    
    .submodules
        dw Dungeon_Normal             ; 0x00: Default behavior
        dw Dungeon_IntraRoomTrans     ; 0x01: Intra-room transition
        dw Dungeon_InterRoomTrans     ; 0x02: Inter-room transition
        dw $8C05 ; = $10C05*          ; 0x03: Perform overlay change (e.g. adding holes)
        dw Dungeon_OpeningLockedDoor  ; 0x04: opening key or big key door
        dw $8C0F ; = $10C0F*          ; 0x05: Trigger an animation?
        dw $8C14 ; = $10C14*          ; 0x06: Upward floor transition
        dw $8E27 ; = $10E27*          ; 0x07: Downward floor transition
        
        dw $8F0C ; = $10F0C*          ; 0x08: Walking up/down an in-room staircase
        dw Dungeon_DestroyingWeakDoor ; 0x09: Bombing or using dash attack to open a door.
        dw $9014 ; = $11014*          ; 0x0A: Think it has to do with Agahnim's room in Ganon's Tower (before Ganon pops out) (or light level in room changing?)
        dw Dungeon_TurnOffWater       ; 0x0B: Turn off water (used in swamp palace)
        dw Dungeon_TurnOnWater        ; 0x0C: Turn on water submodule (used in swamp palace)
        dw Dungeon_Watergate          ; 0x0D: Watergate room filling with water submodule (no other known uses at the moment)
        dw Dungeon_SpiralStaircase    ; 0x0E: Going up or down inter-room spiral staircases (floor to floor)
        dw $931D ; = $1131D*          ; 0x0F: ????
        
        dw $8F88 ; = $10F88*          ; 0x10: Going up or down in-room staircases (clarify, how is this different from 0x08. Did I mean in-floor staircases?!
        dw Dungeon_StraightStairs     ; 0x11: ??? adds extra sprites on screen
        dw Dungeon_StraightStairs     ; 0x12: Walking up straight inter-room staircase
        dw Dungeon_StraightStairs     ; 0x13: Walking down straight inter-room staircase
        dw $9520 ; = $11520*          ; 0x14: What Happens when Link falls into a damaging pit.
        dw Dungeon_Teleport           ; 0x15: Warping to another room.
        dw $972A ; = $1172A*          ; 0x16: Orange/blue barrier state change?
        dw $97C8 ; = $117C8*          ; 0x17: Quick little submodule that runs when you step on a switch to open trap doors?
       
        dw Dungeon_Crystal            ; 0x18: Used in the crystal sequence.
        dw $98F7 ; = $118F7*          ; 0x19: Magic mirror as used in a dungeon. (Only works in palaces, specifically)
        dw Dungeon_OpenGanonDoor      ; 0x1A:   
    }

; ==============================================================================

    ; \note Beginning of Module 0x07, Dungeon Mode.
        
    ; *$107A2-$1085D JUMP LOCATION
    Module_Dungeon:
    {
        SEP #$30
        
        JSL Effect_Handler
        
        LDA $11 : ASL A : TAX
        
        JSR (.submodules, X)
        
        STZ $042C
        
        JSL PushBlock_Handler
        
        LDA $11 : BNE .enteredNonDefaultSubmodule
        
        JSL Graphics_LoadChrHalfSlot
        JSR $BA31   ; $13A31 IN ROM
        
        LDA $11 : BNE .enteredNonDefaultSubmodule
        
        JSL Dungeon_CheckStairsAndRunScripts
        
        LDA $11 : BNE .enteredNonDefaultSubmodule
        
        JSL Dungeon_ProcessTorchAndDoorInteractives
        
        LDA $0454 : BEQ .blastWallNotOpening
        
        JSL Door_BlastWallExploding
    
    .blastWallNotOpening
    
        ; Is Link standing in a door way?
        LDA $6C : BNE .standingInDoorway
        
        ; Check if the player triggered an inter-room transition this frame.
        JSR $885E ; $1085E IN ROM
    
    .enteredNonDefaultSubmodule
    .standingInDoorway
    
        JSL OrientLampBg
        
        REP $21
        
        LDA $E2 : PHA : ADC $011A : STA $E2 : STA $011E
        
        LDA $E8 : PHA : ADD $011C : STA $E8 : STA $0122
        
        LDA $E0 :       ADD $011A : STA $E0 : STA $0120
        
        LDA $E6 : PHA : ADD $011C : STA $E6 : STA $0124
        
        LDA $0428 : AND.w #$00FF : BEQ .noMovingFloor
        
        ; Adjusts BG0 by the offset of the moving floor.
        PLA : PLA
        
        LDA $0422 : ADD $E2 : STA $0120 : STA $E0 : PHA
        LDA $0424 : ADD $E8 : STA $0124 : STA $E6 : PHA
    
    .noMovingFloor
    
        SEP #$20
        
        JSL $07F0AC ; $3F0AC IN ROM. Handle the sprites of pushed blocks.
        JSL Sprite_Main
        
        REP #$20
        
        PLA : STA $E6
        PLA : STA $E0
        PLA : STA $E8
        PLA : STA $E2
        
        SEP #$20
        
        JSL PlayerOam_Main
        JSL HUD.RefillLogicLong
        JML FloorIndicator ; $57D0C IN ROM. Handles HUD floor indicator
    }

; =====================================================

    ; *$1085E-$108C0 LOCAL
    {
        REP #$20
        
        LDA $30 : AND.w #$00FF : BEQ .noChangeY
        
        ; Is Link walking in the up or down direction?
        LDA $67 : AND.w #$000C : STA $00
        
        LDA $20 : AND.w #$01FF
        
        ; Up transition
        LDX.b #$03
        
        CMP.w #$0004 : BCC .triggerRoomTransition
        
        ; Down transition
        LDX.b #$02
        
        CMP.w #$01DC : BCS .triggerRoomTransition
    
    .noChangeY
    
        LDA $31 : AND.w #$00FF : BEQ .noChangeX
        
        ; See if Link is facing right or left.
        LDA $67 : AND.w #$0003 : STA $00
        
        LDA $22 : AND.w #$01FF
        
        ; Left transition
        LDX.b #$01
        
        CMP.w #$0008 : BCC .triggerRoomTransition
        
        ; Right transition
        LDX.b #$00
        
        CMP.w #$01E9 : BCC .noRoomTransition
    
    .triggerRoomTransition
    
        SEP #$20
        
        JSL Player_IsScreenTransitionPermitted : BCS .noRoomTransition
        
        ; Are we in dungeon mode?
        LDA $10 : CMP.b #$07 : BNE .noRoomTransition
        
        JSL Dungeon_StartInterRoomTrans
        
        LDA $10 : CMP.b #$07 : BNE .noRoomTransition
        
        ; Set the submode to dungeon inter-room transition
        LDA.b #$02 : STA $11
    
    .noChangeX
    .noRoomTransition
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $108C1-$108C4 DATA
    {
        db $03, $03, $0C, $0C
    }

; ==============================================================================

    ; *$108C5-$108DD LONG
    Dungeon_StartInterRoomTrans:
    {
        ; Forces Link to be moving on one axis (negates diagonal movement
        ; while scrolling)
        LDA $67 : AND $0288C1, X : STA $67
        
        TXA
        
        JSL UseImplicitRegIndexedLongJumpTable
        
        dl $02B63A ; = $1363A*
        dl $02B6D9 ; = $136D9*
        dl $02B77A ; = $1377A*
        dl $02B81C ; = $1381C*
    ]

; ==============================================================================
    
    ; *$108DE-$1094B LOCAL
    Dungeon_Normal:
    {
        LDA $0112 : ORA $02E4 : ORA $0FFC : BEQ .allowJoypadInput
        
        JMP .ignoreInput
    
    .allowJoypadInput
    
        ; Is the start button down?
        LDA $F4 : AND.b #$10 : BEQ .startNotDown
        
        STZ $0200
        
        ; switch to the item menu
        LDA.b #$01
        
        BRA .switchMode
    
    .startNotDown
    
        ; Is the X button being pressed?
        LDA $F6 : AND.b #$40 : BEQ .dontActivateMap
        
        ; Do we actually have a map? 0xFF indicates that a series of rooms is not in a dungeon.
        LDA $040C : CMP.b #$FF : BEQ .dontActivateMap
        
        ; Apparently Ganon's room is in a dungeon? Can't explain that. In any case
        ; this hard coded check prevents you from opening a map in Ganon's room.
        LDA $A0 : BEQ .dontActivateMap
        
        STZ $0200
        
        ; Change to dungeon map mode in the text module.
        LDA.b #$03
    
    .switchMode
    
        ; A is loaded with the submodule that module E will use.
        STA $11
        
        ; The mode that text mode is called from goes to $010C.
        LDA $10 : STA $010C
        
        ; Change to text mode (0E)
        LDA.b #$0E : STA $10
        
        RTS
    
    .dontActivateMap
    
        ; Is select being held/pressed?
        LDA $F0 : AND.b #$20 : BEQ .ignoreInput
        
        ; Select was pressed. But has Link woken up and gotten out of bed?
        ; No, so don’t bring up the start menu.
        LDA $7EF3C5 : BEQ .ignoreInput
        
        ; Here select was pressed and Link has gotten out of his house.
        LDA $1CE8 : STA $1CF4
        
        REP #$20
        
        ; message index for the "continue / save and quit menu"
        LDA.w #$0186 : STA $1CF0
        
        SEP #$20
        
        LDA $10 : PHA
        
        ; Switch to text mode and wait for input
        JSL Main_ShowTextMessage
        
        PLA : STA $10
        
        STZ $B0
        
        ; This will go to $11, and it is the continue/ save submodule in mode E.
        LDA.b #$0B
        
        BRA .switchMode
        
    .ignoreInput
        
        JSL Player_Main
        
        RTS
    }

; ==============================================================================

    ; $1094C-$1096B DATA
    {
    
        db 0,  1,  1, -1,  1,  1,  1,  1
    
    ; $10954
    
        dw $00C8, $0033, $0007, $0020
    
    ; $1095C
    
        dw $0006, $005A, $0029, $0090, $00DE, $00A4, $00AC, $000D
    }

; ==============================================================================

    ; $1096C-$1097B JUMP TABLE
    Dungeon_IntraRoomTransTable:
    {
        dw Dungeon_IntraRoomTransInit
        dw Dungeon_IntraRoomTransFilter
        dw Dungeon_IntraRoomTransShutDoors
        dw $BE03 ; = $13E03*
        dw $C110 ; = $14110*
        dw $C170 ; = $14170*
        dw Dungeon_IntraRoomTransFilter
        dw Dungeon_IntraRoomTransOpenDoors
    }

; ==============================================================================

    ; *$1097C-$10994 LOCAL
    Dungeon_IntraRoomTrans:
    {
        ; Module 0x07.0x01 - room transition?
        REP #$20
        
        ; cache link's coordinates
        LDA $22 : STA $0FC2
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        ; only seems to handle aspects of Link's appearance during the transition (speculative)
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        LDA $B0 : ASL A : TAX
        
        JMP (Dungeon_IntraRoomTrans, X)
    }

; ==============================================================================

    ; *$10995-$109B5 JUMP LOCATION
    Dungeon_IntraRoomTransShutDoors:
    {
        ; open trap doors?
        STZ $0468
        
        ; open trap doors?
        LDA.b #$07 : STA $0690
        
        LDA $11 : PHA
        
        JSL Dungeon_AnimateTrapDoors
        
        PLA : STA $11
        
        LDA.b #$1F : STA $7EC007
        
        LDA.b #$00 : STA $7EC00B
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$109B6-$109D7 JUMP LOCATION
    Dungeon_IntraRoomTransInit:
    {
        REP #$20
        
        LDA.w #$0000 : STA $7EC009 : STA $7EC007
        
        LDA.w #$001F : STA $7EC00B
        
        ; while this variable is zeroed a few places around the rom,
        ; no sign that it's actually used anywhere
        STZ $0AA6
        
        SEP #$20
        
        ; reset dungeon variables pertaining to switches
        STZ $0646
        STZ $0642
        
        INC $B0
        
        RTS
    }

    ; *$109D8-$109EF JUMP LOCATION
    Dungeon_IntraRoomTransFilter:
    {
        LDA $7EC005 : BEQ .noFiltering
        
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : BEQ .doneFiltering
        
        JSL PaletteFilter.doFiltering
    
    .doneFiltering
    
        RTS
    
    .noFiltering
    
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$109F0-$10A05 JUMP LOCATION
    Dungeon_IntraRoomTransOpenDoors:
    {
        ; make any applicable trap doors shut.
        
        JSR $8D71 ; $10D71 IN ROM
        
        LDA $0468 : BNE .alpha
        
        INC $0468
        
        STZ $068E
        STZ $0690
        
        LDA.b #$05 : STA $11
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $10A06-$10A25 Jump Table
    {
        dw $8A4F ; = $10A4F* ; configure graphics settings
        dw $8A5B ; = $10A5B* ; load dungeon room objects
        dw $8B92 ; = $10B92* ; palette filtering for dark rooms
        dw $8A87 ; = $10A87* ; transitiony actions...
        dw $8AC8 ; = $10AC8* ; updates BG2 tilemap
        dw $8AB3 ; = $10AB3* ; updates BG1 tilemap
        dw $8AC8 ; = $10AC8* ; updates BG2 tilemap
        dw $8B2E ; = $10B2E* ; updates BG1 tilemap
        dw $BE03 ; = $13E03* ; more scrolling transitionary shit...
        dw $8ABA ; = $10ABA* ; do more palette filtering and tilemap updating
        dw $8AA5 ; = $10AA5* ; even more palette filtering + tilemap updating
        dw $8ABA ; = $10ABA* ; do more palette filtering and tilemap updating
        dw $8ACF ; = $10ACF* ; transitioning...
        dw $C162 ; = $14162* ; transitioning.....ughhghh
        dw $8B92 ; = $10B92* ; filtering.......
        dw $8BAE ; = $10BAE* ; 
    }

; ==============================================================================

    ; *$10A26-$10A4E JUMP LOCATION
    Dungeon_InterRoomTrans:
    {
        ; module 0x07.0x02
        
        REP #$20
        
        LDA $22 : STA $0FC2
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        LDA $B0    : BEQ .alpha
        CMP.b #$07 : BCC .beta
        
        JSL Graphics_IncrementalVramUpload
    
    .beta
    
        JSL Dungeon_LoadAttrSelectable
    
    .alpha
    
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        LDA $B0 : ASL A : TAX
        
        JMP ($8A06, X) ; $10A06 IN ROM
    }

    ; *$10A4F-$10A5A JUMP LOCATION
    {
        LDA $0458 : PHA
        
        JSR $8CAC ; $10CAC IN ROM
        
        PLA : STA $0458
        
        RTS
    }

    ; *$10A5B-$10A86 JUMP LOCATION
    {
        ; module 0x07.0x02.0x01
        
        JSL Dungeon_LoadRoom
        JSL Dungeon_InitStarTileChr
        JSL $00D6F9 ; $56F9 IN ROM
        
        INC $B0
        
        STZ $0200
        
        LDA $A2 : PHA
        
        LDA $A0 : STA $048E
        
        PLA : STA $A2
        
        JSL Dungeon_ResetSprites
        
        LDA $0458 : BNE .darkRoomWithTorch
        
        JSR $BB7B ; $13B7B IN ROM
    
    .darkRoomWithTorch
    
        STZ $0458
        
        RTS
    }

    ; *$10A87-$10AA4 JUMP LOCATION
    {
        LDA $7EC005 : ORA $7EC006 : BEQ .notDarkRoom
        
        ; hide torch bg.
        STZ $1D
    
    .notDarkRoom
    
        JSL $02B5DC ; $135DC IN ROM
        JSL $00E031 ; $6031 IN ROM
        JSR $BB7B   ; $13B7B IN ROM ; set BG1 scroll to BG2 scroll values
        JSL $0091C4 ; $11C4 IN ROM ; does tile updates of a room.
        
        INC $B0
        
        RTS
    }

    ; *$10AA5-$10AB9 JUMP LOCATION
    {
        LDA $7EC005 : ORA $7EC006 : BEQ .noDarkTransition
    
    ; *$10AAF ALTERNATE ENTRY POINT
    
        JSL PaletteFilter.doFiltering
    
    ; *$10AB3 ALTERNATE ENTRY POINT
    .noDarkTransition
    
        JSL $0091C4 ; $11C4 IN ROM
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10ABA-$10ACE JUMP LOCATION
    {
        LDA $7EC005 : ORA $7EC006 : BEQ .notDarkRoom
    
    ; *$10AC4 ALTERNATE ENTRY POINT
    
        JSL PaletteFilter.doFiltering
    
    ; *$10AC8 ALTERNATE ENTRY POINT
    .notDarkRoom
    
        JSL $00913F ; $113F IN ROM
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; $10ACF-$10B2D JUMP LOCATION
    {
        LDA $11 : CMP.b #$02 : BNE BRANCH_ALPHA
        
        LDA $0200 : CMP.b #$05 : BNE .return
        
        JSR $C12C ; $1412C IN ROM; ugh... wtf does this do.
        
        LDA $7EC005 : ORA $7EC006 : BEQ BRANCH_ALPHA
        
        JSL PaletteFilter.doFiltering
    
    ; $10AED ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        INC $B0
    
    ; $10AEF ALTERNATE ENTRY POINT
    shared Dungeon_ResetTorchBackgroundAndPlayer:
    
    .configScreens
    
        ; "screens" as in the main and subscreen designations
        
        LDY.b #$16
        
        ; Load BG1 properties setting
        LDX $0414 : LDA $02894C, X : BPL .bg1OnSubscreen
        
        ; This setting corresponds to the "on top" setting for BG1
        LDY.b #$17
        LDA.b #$00
    
    .bg1OnSubscreen
    
        CPX.b #$02 : BNE .notDarkRoom
        
        ; Put BG1 and BG2 both on the subscreen
        LDA.b #$03
    
    .notDarkRoom
    
        ; set main and subscreen designation mirror registers
        STY $1C
        STA $1D
        
        JSL RestoreTorchBackground
    
    ; *$10B0C ALTERNATE ENTRY POINT
    
        ; not really sure, terminates some ancillae, probably
        JSL Ancilla_TerminateSelectInteractives
        
        ; check if Link will bounce off of a wall if he touches one.
        LDA $0372 : BEQ .return
        
        ; all this appears to reset Link's dashing /
        ; bounce off wall state during a screen transition
        STZ $4D : STZ $46
        
        LDA.b #$FF : STA $29 : STA $C7
        
        STZ $3D : STZ $5E : STZ $032B : STZ $0372
        
        LDA.b #$00 : STA $5D
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$10B2E-$10B91 JUMP LOCATION
    {
        REP #$10
        
        LDX $E2 : STX $E0
        LDX $E8 : STX $E6
        
        LDX $A0
        
        CPX.w #$0036 : BEQ BRANCH_ALPHA
        CPX.w #$0038 : BEQ BRANCH_ALPHA
        
        ; Check the BG0 value
        LDX $0414
        
        LDY.w #$0016
        
        LDA $02894C, X : BEQ BRANCH_BETA
        
        LDY.w #$0116
    
    BRANCH_BETA:
    
        ; Check the Y value against main/sub settings.
        CPY $1C : BEQ BRANCH_ALPHA
        
        LDA $1C : CMP.b #$17 : BEQ BRANCH_GAMMA
        
        ORA $1D : CMP.b #$17 : BEQ BRANCH_ALPHA
    
    BRANCH_GAMMA:
    
        STY $1C
    
    BRANCH_ALPHA:
    
        SEP #$10
    
    ; *$10B67 ALTERNATE ENTRY POINT
    
        LDA $7EC005 : ORA $7EC006 : BEQ .notDarkTransition
        
        LDX.b #$03
        
        LDA $7EC005 : BEQ .currentRoomNotDarkTransition
        
        LDX $045A
    
    .currentRoomNotDarkTransition
    
        LDA $02A1E5, X : STA $7EC017
        
        JSL Dungeon_ApproachFixedColor.variable
        
        LDA.b #$00 : STA $7EC00B
    
    .notDarkTransition
    
        JSR $A1E9 ; $121E9 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$10B92-$10BAD JUMP LOCATION
    {
        LDA $7EC005 : ORA $7EC006 : BEQ .noFilteringNeeded
        
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : BEQ .beta
        
        JSL PaletteFilter.doFiltering
    
    .beta
    
        RTS
    
    .noFilteringNeeded
    
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10BAE-$10C04 JUMP LOCATION
    {
        ; Reset variables and return to normal dungeon mode next frame.
        JSR $8D71 ; $10D71 IN ROM
        
        LDA $0468 : BNE .doorDown
        
        LDA $A0 : CMP.b #$AC : BNE .notBlindsRoom
        
        LDA $0403 : AND.b #$20 : BNE .eventCompleted
        
        LDA $0403 : AND.b #$10 : BEQ .doorDown
    
    .notBlindsRoom
    .eventCompleted
    
        INC $0468
        
        STZ $068E
        STZ $0690
        
        LDA.b #$05 : STA $11
    
    ; *$10BD7 ALTERNATE ENTRY POINT
    .doorDown
    
        REP #$20
        
        ; value for Sanctuary music
        LDX.b #$14
        
        LDA $A0 : CMP.w #$0012 : BEQ .setSong
        
        ; value for Hyrule Castle music
        LDX.b #$10
        
        CMP.w #$0002 : BEQ .setSong
        
        ; value for cave music
        LDX.b #$18
    
    .nextEntry
    
        DEX #2 : BMI .noSongChange
        
        CMP $028954, X : BNE .nextEntry
        
        SEP #$20
        
        JSL Sprite_VerifyAllOnScreenDefeated : BCS .noSongChange
        
        ; Activate boss music
        LDX.b #$15
    
    .setSong
    
        STX $012C
    
    .noSongChange
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$10C05-$10C09 JUMP LOCATION
    {
        ; Module 0x07.0x03
        
        JSL Dungeon_ApplyOverlay
        
        RTS
    }

; ==============================================================================

    ; *$10C0A-$10C0E JUMP LOCATION
    Dungeon_OpeningLockedDoor:
    {
        JSL Dungeon_AnimateOpeningLockedDoor
        
        RTS
    }

; ==============================================================================

    ; *$10C0F-$10C13 JUMP LOCATION
    {
        ; Module 0x07.0x05
        JSL Dungeon_AnimateTrapDoors
        
        RTS
    }

; ==============================================================================

    ; *$10C14-$10C77 JUMP LOCATION
    {
        LDA $B0 : CMP.b #$03 : BCC BRANCH_ALPHA
        
        JSL Dungeon_LoadAttrSelectable
    
    BRANCH_ALPHA:
    
        LDA $B0 : CMP.b #$0D : BCC BRANCH_BETA
        
        JSL Graphics_IncrementalVramUpload
        
        LDA $0464 : BEQ BRANCH_GAMMA
        
        DEC $0464
        
        CMP.b #$10 : BNE BRANCH_DELTA
        
        LDA.b #$02 : STA $57
    
    BRANCH_DELTA:
    
        LDX.b #$08
        
        LDA $0462 : AND.b #$04 : BEQ BRANCH_EPSILON
        
        LDX.b #$04
    
    BRANCH_EPSILON:
    
        STX $67
        
        JSL $07E245 ; $3E245 IN ROM
        JSR $BA31   ; $13A31 IN ROM
    
    BRANCH_BETA:
    
        JSL $07E6A6 ; $3E6A6 IN ROM
    
    BRANCH_GAMMA:
    
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8CA9 ; = $10CA9*
        dw $8D01 ; = $10D01*
        dw $8CE2 ; = $10CE2*
        dw $8E0F ; = $10E0F*
        dw $8E1D ; = $10E1D*
        dw $8D10 ; = $10D10*
        dw $8D1B ; = $10D1B*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AAF ; = $10AAF*
        dw $8AC4 ; = $10AC4*
        dw $8AAF ; = $10AAF*
        dw $8AC4 ; = $10AC4*
        dw $9094 ; = $11094*
        dw $8AED ; = $10AED*
        dw $8D5F ; = $10D5F*
    }

; ==============================================================================

    ; *$10C78-$10CE1 JUMP LOCATION
    {
        REP #$20
        
        LDA $A0 : CMP.w #$0007 : BEQ .moldormRoom
        
        CMP.w #$0017 : BNE BRANCH_BETA
        
        LDX $0130 : CPX.b #$11 : BEQ BRANCH_BETA
    
    .moldormRoom
    
        ; Check if Link has the Pendant of Courage
        LDA $7EF374 : LSR A : BCS BRANCH_BETA
        
        LDX.b #$F1 : STX $012C
    
    BRANCH_BETA:
    
        SEP #$20
        
        LDX.b #$58
        
        LDA $0462 : AND.b #$04 : BEQ BRANCH_GAMMA
        
        LDX.b #$6A
    
    BRANCH_GAMMA:
    
        STX $0464
    
    ; $10CA9 ALTERNATE ENTRY POINT
    
        STZ $0200
    
    ; $10CAC ALTERNATE ENTRY POINT
    
        REP #$30
        
        ; set all mosaic settings to disabled
        LDA.w #$0000 : STA $7EC011 : STA $7EC009 : STA $7EC007
        
        ; Set the color filtering state to "unfiltered"
        LDA.w #$001F : STA $7EC00B
        
        STZ $0AA6 : STZ $045A
        
        LDA $0458 : BEQ .torchBgNotActivated
        
        ; configure color +/- to add the subscreen instead of fixed color
        ; also configure CGADSUB to use color subtraction, 
        ; with background, OBJ, and BG2 having the subscreen applied to them.
        LDA.w #$B302 : STA $99
    
    .torchBgNotActivated
    
        SEP #$30
        
        STZ $0458
        
        ; Performs a lot of resetting of Link's game engine variables
        ; $10B0C IN ROM
        JSR $8B0C
        
        JSR Overworld_CgramAuxToMain
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10CE2-$10D00 JUMP LOCATION
    {
        JSR $A2F0   ; $122F0 IN ROM
        JSL Dungeon_LoadRoom
        JSL Dungeon_InitStarTileChr
        JSL LoadTransAuxGfx
        JSL Dungeon_LoadCustomTileAttr
        
        LDA $A0 : STA $048E
        
        JSL Tagalong_Init
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10D01-$10D0F JUMP LOCATION
    {
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : BEQ BRANCH_ALPHA
        
        JSL PaletteFilter.doFiltering
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$10D10-$10D1A JUMP LOCATION
    {
        JSL $00E031              ; $6031 IN ROM ; prep some graphics for loading
        JSL Dungeon_ResetSprites
        JMP $8B67   ; $10B67 IN ROM
    }

; ==============================================================================

    ; *$10D1B-$10D5E JUMP LOCATION
    {
        JSR $BB7B   ; $13B7B IN ROM
        JSL $02B5DC ; $135DC IN ROM
        
        LDY.b #$16
        
        LDX $0414
        
        LDA $02894C, X : BPL BRANCH_ALPHA
        
        LDY.b #$17
        LDA.b #$00
    
    BRANCH_ALPHA:
    
        STY $1C
        STA $1D
        
        INC $A4
        
        LDA.b #$01 : STA $57
        
        LDY.b #$17
        LDX.b #$30
        
        LDA $0462 : AND.b #$04 : BEQ BRANCH_BETA
        
        LDY.b #$19
        
        DEC $A4 : DEC $A4
        
        LDX.b #$20
    
    BRANCH_BETA:
    
        STX $0464
        STY $012E
        
        LDA.b #$24 : STA $012F
        
        JSR $8EC9 ; $10EC9 IN ROM
        JMP $8AB3 ; $10AB3 IN ROM
    }

; ==============================================================================

    ; *$10D5F-$10E0E JUMP LOCATION
    {
        LDA $7EC009 : ORA $7EC007 : BEQ BRANCH_ALPHA
    
    BRANCH_BETA:
    
        RTS
    
    BRANCH_ALPHA:
    
        LDA $0200 : CMP.b #$05 : BNE BRANCH_BETA
    
    ; $10D71 ALTERNATE ENTRY POINT
    .reset
    
        STZ $0200
        STZ $B0
        STZ $0418
        STZ $11
        STZ $0642
        STZ $0641
    
    ; $10D81 ALTERNATE ENTRY POINT
    .justCache
    
        REP #$20
        
        LDA $E2 : STA $7EC180
        
        LDA $E8 : STA $7EC182
        
        LDA $20 : STA $7EC184
        
        LDA $22 : STA $7EC186
        
        LDA $0600 : STA $7EC188
        LDA $0604 : STA $7EC18A
        LDA $0608 : STA $7EC18C
        LDA $060C : STA $7EC18E
        LDA $0610 : STA $7EC190
        LDA $0612 : STA $7EC192
        LDA $0614 : STA $7EC194
        LDA $0616 : STA $7EC196
        LDA $0618 : STA $7EC198
        LDA $061C : STA $7EC19A
        
        LDA $A6 : STA $7EC19C
        LDA $A9 : STA $7EC19E
        
        SEP #$20
        
        LDA $2F : STA $7EC1A6
        LDA $EE : STA $7EC1A7
        
        LDA $0476 : STA $7EC1A8
        
        LDA $6C : STA $7EC1A9
        LDA $A4 : STA $7EC1AA
        
        RTS
    }

; ==============================================================================

    ; *$10E0F-$10E1C JUMP LOCATION
    {
        JSL PrepTransAuxGfx ; $5F1A IN ROM
        
        LDA.b #$09 : STA $17 : STA $0710
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10E1D-$10E26 JUMP LOCATION
    {
        LDA.b #$0A : STA $17 : STA $0710
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10E27-$10E62 JUMP LOCATION
    {
        LDA $B0 : CMP.b #$06 : BCC .alpha
        
        JSL Graphics_IncrementalVramUpload
        JSL Dungeon_LoadAttrSelectable
        JSL Dungeon_ApproachFixedColor
    
    .alpha
    
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8E63 ; = $10E63*
        dw $A2A0 ; = $122A0*
        dw $8CE2 ; = $10CE2*
        dw $8E0F ; = $10E0F*
        dw $8E1D ; = $10E1D*
        dw $8D10 ; = $10D10*
        dw $8E80 ; = $10E80*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AED ; = $10AED*
        dw $8EA1 ; = $10EA1*
        dw $8EE0 ; = $10EE0*
        dw $8EFA ; = $10EFA*
    }

; ==============================================================================

    ; *$10E63-$10E7F JUMP LOCATION
    {
        REP #$20
        
        LDA $A0
        
        CMP.w #$0010 : BEQ .fadeMusicOut
        CMP.w #$0007 : BEQ .fadeMusicOut
        CMP.w #$0017 : BNE .dontFade
    
    .fadeMusicOut
    
        LDX.b #$F1 : STX $012C
    
    .dontFade
    
        SEP #$20
        
        JMP $8CA9 ; $10CA9 IN ROM
    }

; ==============================================================================

    ; *$10E80-$10EA0 JUMP LOCATION
    {
        JSR $BB7B   ; $13B7B IN ROM
        JSL $02B5DC ; $135DC IN ROM
        
        LDY.b #$16
        
        LDX $0414
        
        LDA $02894C, X : BPL BRANCH_ALPHA
        
        LDY.b #$17
        LDA.b #$00
    
    BRANCH_ALPHA:
    
        STY $1C
        STA $1D
        
        JSL $0091C4 ; $11C4 IN ROM
        
        INC $B0
        
        RTS
    }

    ; *$10EA1-$10EDF JUMP LOCATION
    {
        JSL PaletteFilter.doFiltering
        
        LDA $7EC009 : BNE BRANCH_ALPHA
        
        LDA $21
        
        LDY $20 : CPY $51 : BCC BRANCH_BETA
        
        INC A
    
    BRANCH_BETA:
    
        STA $52
        
        JSR $9165   ; $11165 IN ROM
        
        LDA $A0
        
        CMP.b #$89 : BEQ BRANCH_ALPHA
        CMP.b #$4F : BEQ BRANCH_ALPHA
        CMP.b #$A7 : BEQ BRANCH_GAMMA
        
        ; Drop one level in the palace / dungeon.
        DEC $A4
    
    ; *$10EC9 ALTERNATE ENTRY POINT
    
        LDA.b #$01 : STA $04A0
        
        LDA.b #$24 : STA $012F
        
        JSL $02B8CB ; $138CB IN ROM
    
    BRANCH_ALPHA:
    
        RTS
    
    BRANCH_GAMMA:
    
        STZ $04A0
        
        LDA.b #$01 : STA $A4
        
        RTS
    }

    ; *$10EE0-$10EF9 JUMP LOCATION
    {
        JSL $079520 ; $39520 IN ROM
        
        LDA $11 : BNE BRANCH_ALPHA
        
        LDA.b #$07 : STA $11
        
        LDA.b #$11 : STA $B0
        
        LDA.b #$01 : STA $0AAA
        
        JSL Graphics_LoadChrHalfSlot
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$10EFA-$10F0B JUMP LOCATION
    {
        LDA $0200 : CMP.b #$05 : BNE BRANCH_ALPHA
        
        JSR $8D71   ; $10D71 IN ROM
        JSR $8BD7   ; $10BD7 IN ROM
        JSL Graphics_LoadChrHalfSlot
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$10F0C-$10F34 JUMP LOCATION
    {
        LDA $0464 : BEQ BRANCH_ALPHA
        
        DEC $0464
        
        CMP.b #$14 : BNE BRANCH_BETA
        
        LDA.b #$02 : STA $57
    
    BRANCH_BETA:
    
        JSL $07E245 ; $3E245 IN ROM
        JSL $07E9D3 ; $3E9D3 IN ROM
        JSR $BA31   ; $13A31 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
    
    BRANCH_ALPHA:
    
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8F35 ; = $10F35*
        dw $8F5F ; = $10F5F*
    }

; ==============================================================================

    ; *$10F35-$10F5E JUMP LOCATION
    {
        STZ $0351
        
        LDY.b #$19
        LDX.b #$3C
        
        LDA $67 : AND.b #$08 : BEQ BRANCH_ALPHA
        
        LDY.b #$17
        LDX.b #$38
        
        STZ $0476
        
        LDA $044A : CMP.b #$02 : BEQ BRANCH_ALPHA
        
        STZ $EE
    
    BRANCH_ALPHA:
    
        STX $0464
        STY $012E
        
        LDA.b #$01 : STA $57
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10F5F-$10F87 JUMP LOCATION
    {
        LDA $0464 : BNE BRANCH_$10F5E ; (RTS)
        
        LDA $67 : AND.b #$04 : BEQ BRANCH_ALPHA
        
        LDA.b #$01 : STA $0476
        
        LDA $044A : CMP.b #$02 : BEQ BRANCH_ALPHA
        
        LDA.b #$01 : STA $EE
        
        BRA BRANCH_ALPHA
    
    BRANCH_ALPHA:
    
        STZ $B0
        STZ $0418
        STZ $11
        
        JSL $02B8CB ; $138CB IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$10F88-$10FB0 JUMP LOCATION
    {
        LDA $0464 : BEQ BRANCH_ALPHA
        
        DEC $0464
        
        CMP.b #$14 : BNE BRANCH_BETA
        
        LDA.b #$02 : STA $57
    
    BRANCH_BETA:
    
        JSL $07E245 ; $3E245 IN ROM
        JSL $07E9D3 ; $3E9D3 IN ROM
        JSR $BA31   ; $13A31 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
    
    BRANCH_ALPHA:
    
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8FB1 ; = $10FB1*
        dw $8FE1 ; = $10FE1*
    }

; ==============================================================================

    ; *$10FB1-$10FE0 JUMP LOCATION
    {
        LDY.b #$19
        LDX.b #$3C
        
        LDA $67 : AND.b #$04 : BEQ BRANCH_ALPHA
        
        LDY.b #$17
        LDX.b #$38
        
        LDA $0476 : EOR.b #$01 : STA $0476
        
        LDA $044A : CMP.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $EE : EOR.b #$01 : STA $EE
    
    BRANCH_ALPHA:
    
        STX $0464
        STY $012E
        
        LDA.b #$01 : STA $57
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$10FE1-$1100E JUMP LOCATION
    {
        LDA $0464 : BNE BRANCH_$10FE0 ; (RTS)
        
        LDA $67 : AND.b #$08 : BEQ BRANCH_ALPHA
        
        LDA $0476 : EOR.b #$01 : STA $0476
        
        LDA $044A : CMP.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $EE : EOR.b #$01 : STA $EE
        
        BRA BRANCH_ALPHA
    
    BRANCH_ALPHA:
    
        STZ $B0
        STZ $0418
        STZ $11
        
        JSL $02B8CB ; $138CB IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$1100F-$11013 JUMP LOCATION
    Dungeon_DestroyingWeakDoor:
    {
        JSL Dungeon_AnimateDestroyingWeakDoor
        
        RTS
    }

; ==============================================================================

    ; *$11014-$1102C JUMP LOCATION
    {
        JSL OrientLampBg
        JSL Dungeon_ApproachFixedColor
        
        LDA $00009C : AND.b #$1F : CMP $7EC017 : BNE .notAtTarget
        
        STZ $11
        STZ $B0
    
    .notAtTarget
    
        RTS
    }

; ==============================================================================

    ; *$1102D-$11031 JUMP LOCATION
    Dungeon_TurnOffWater:
    {
        ; I don't quite understand why it was necessary to call a long routine
        ; from the same bank. The work could have been done in this routine
        ; just as easily.
        
        JSL Dungeon_TurnOffWaterActual ; $11032 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$11032-$11049 LONG
    Dungeon_TurnOffWaterActual:
    {
        LDA $B0
        
        JSL UseImplicitRegIndexedLongJumpTable
        
        dl $01EF54 ; = $EF54*
        dl $01EFEC ; = $EFEC*
        dl $01F046 ; = $F046*
        dl $01F046 ; = $F046*
        dl $01F046 ; = $F046*
        dl $01F046 ; = $F046*
    }

; ==============================================================================

    ; *$1104A-$1104E JUMP LOCATION
    Dungeon_TurnOnWater:
    {
        JSL Dungeon_TurnOnWaterLong ; $F093 IN ROM
        
        RTS
    }

; ==============================================================================

    ; $1104F-$11053 JUMP LOCATION
    Dungeon_Watergate:
    {
        JSL Watergate_Main
        
        RTS
    }

; ==============================================================================

    ; *$11054-$11093 JUMP LOCATION
    Dungeon_SpiralStaircase:
    {
        LDA $B0 : CMP.b #$07 : BCC BRANCH_ALPHA
        
        JSL Graphics_IncrementalVramUpload
        JSL Dungeon_LoadAttrSelectable
    
    BRANCH_ALPHA:
    
        JSL $07F2C1 ; $3F2C1 IN ROM
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $91C4 ; = $111C4*
        dw $8C78 ; = $10C78*
        dw $90A1 ; = $110A1*
        dw $8CE2 ; = $10CE2*
        dw $8E0F ; = $10E0F*
        dw $8E1D ; = $10E1D*
        dw $8D10 ; = $10D10*
        dw $90C7 ; = $110C7*
        
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AAF ; = $10AAF*
        dw $8AC4 ; = $10AC4*
        dw $8AAF ; = $10AAF*
        dw $8AC4 ; = $10AC4*
        dw $9094 ; = $11094*
        
        dw $915B ; = $1115B*
        dw $919B ; = $1119B*
        dw $91B5 ; = $111B5*
        dw $91DD ; = $111DD*
    }

; ==============================================================================

    ; *$11094-$110A0 JUMP LOCATION
    {
        JSL PaletteFilter.doFiltering
        JSL PaletteFilter.doFiltering
        JSL Dungeon_ApproachFixedColor
        
        RTS
    }

; ==============================================================================

    ; *$110A1-$110C6 JUMP LOCATION
    {
        LDA $0464 : CMP.b #$09 : BCS BRANCH_ALPHA
        
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : BEQ BRANCH_ALPHA
        
        JSL PaletteFilter.doFiltering
    
    BRANCH_ALPHA:
    
        LDA $0464 : BNE BRANCH_BETA
        
        LDA.b #$0C : STA $4B : STA $02F9
        
        RTS
    
    BRANCH_BETA:
    
        DEC $0464
        
        RTS
    }

; ==============================================================================

    ; *$110C7-$1115A JUMP LOCATION
    {
        LDA $7EF3CC : CMP.b #$06 : BNE BRANCH_ALPHA
        
        LDA $A0 : CMP.b #$64 : BNE BRANCH_ALPHA
        
        LDA.b #$00 : STA $7EF3CC
    
    BRANCH_ALPHA:
    
        LDA $EE : PHA
        
        REP #$10
        
        LDX.w #$0030
        
        LDA $0462 : AND.b #$04 : BNE BRANCH_BETA
        
        LDX.w #$FFD0
    
    BRANCH_BETA:
    
        REP #$20
        
        TXA : ADD $20 : STA $20
        
        SEP #$30
        
        LDX $048A
        
        LDA $01C322, X : STA $EE
        
        JSR $92B1 ; $112B1 IN ROM
        
        PLA : STA $EE
        
        REP #$10
        
        LDX.w #$FFD0
        
        LDA $0462 : AND.b #$04 : BNE BRANCH_GAMMA
        
        LDX.w #$0030
    
    BRANCH_GAMMA:
    
        REP #$20
        
        TXA : ADD $20 : STA $20
        
        JSR $BB7B ; $13B7B IN ROM
        
        SEP #$30
        
        JSL $02B5DC ; $135DC IN ROM
        
        LDY.b #$16
        
        LDX $0414
        
        LDA $02894C, X : BPL BRANCH_DELTA
        
        LDY.b #$17
        LDA.b #$00
    
    BRANCH_DELTA:
    
        CPX.b #$02 : BNE BRANCH_EPSILON
        
        LDA.b #$03
    
    BRANCH_EPSILON:
    
        STY $1C
        STA $1D
        
        INC $A4 ; going up a flight of stairs
        
        LDA $0462 : AND.b #$04 : BEQ .upStaircase
        
        ; going down a flight of stairs
        DEC $A4 : DEC $A4
    
    .upStaircase
    
        LDX.b #$18 : STX $0464
        
        JSR $8EC9   ; $10EC9 IN ROM
        JSL RestoreTorchBackground
        JMP $8AB3   ; $10AB3 IN ROM
    }

; ==============================================================================

    ; *$1115B-$1119A LOCAL
    {
        JSR $8B0C ; $10B0C IN ROM
        
        LDA.b #$38 : STA $0464
        
        INC $B0
    
    ; *$11165 ALTERANTE ENTRY POINT
    
        REP #$20
        
        LDX.b #$1C
        
        LDA $A0 : CMP.w #$0010 : BEQ BRANCH_ALPHA
        
        LDX.b #$15
        
        CMP.w #$0007 : BEQ BRANCH_BETA
        
        LDX.b #$11
        
        CMP.w #$0017 : BNE BRANCH_GAMMA
        
        CPX $0130 : BEQ BRANCH_GAMMA
    
    BRANCH_BETA:
    
        LDA $0130 : AND.w #$00FF : CMP.w #$00F1 : BEQ BRANCH_ALPHA
        
        LDA $7EF374 : LSR A : BCS BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        STX $012C
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$1119B-$111B4 JUMP LOCATION
    {
        JSL $07F391 ; $3F391 IN ROM
        
        DEC $0464 : BNE BRANCH_ALPHA
        
        LDX.b #$0A
        
        LDA $0462 : AND.b #$04 : BNE .upStaircase
        
        LDX.b #$18
    
    .upStaircase
    
        STX $0464
        
        INC $B0
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$111B5-$111C3 JUMP LOCATION
    {
        JSL $07F391 ; $3F391 IN ROM
        
        DEC $0464 : BNE BRANCH_ALPHA
        
        INC $B0
        
        STZ $0200
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$111C4-$111DC JUMP LOCATION
    {
        JSL Dungeon_ElevateStaircasePriority
        
        LDA $EE : BEQ .onBG2
        
        LDA $1C : AND.b #$0F : STA $1C
        
        LDA.b #$10 : TSB $1D
        LDA.b #$03 : STA $EE
    
    .onBG2
    
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$111DD-$11209 JUMP LOCATION
    {
        LDX $048A
        
        LDA $01C31F, X : STA $0476
        
        LDA $01C322, X : STA $EE
        
        LDA.b #$10 : TSB $1C
        
        LDA $1D : AND.b #$0F : STA $1D
        
        LDA $0462 : AND.b #$04 : BNE .up_staircase
        
        JSL Dungeon_DecreaseStaircasePriority
    
    .up_staircase
    
        LDA $A0 : STA $048E
        
        JMP $8D71 ; $10D71 IN ROM
    }

; ==============================================================================

    ; $1120A-$11219 DATA
    pool 
    {
    
    .x_offsets
        dw -28, -28,  24,  24
    
    .y_offsets
        dw  16, -10, -10, -32
    }

; ==============================================================================

    ; *$1121A-$112B0 LONG
    {
        SEP #$30
        
        STZ $4B
        STZ $02F9
        
        LDX.b #$00
        
        LDA $048A : BNE BRANCH_ALPHA
        CMP $0492 : BEQ BRANCH_ALPHA
        
        LDX.b #$02
    
    BRANCH_ALPHA:
    
        LDA $0462 : AND.b #$04 : BEQ BRANCH_BETA
        
        TXA : ADD.b #$04 : TAX
        
    BRANCH_BETA:

        REP #$20
        
        ; Staircases and how they affect
        ; Your X and Y coordinates
        LDA $22 : ADD $02920A, X : STA $22
        LDA $20 : ADD $029212, X : STA $20
        
        SEP #$20
        
        ; See if the sprite layer is not enabled
        ; Not enabled.
        LDA $1C : AND.b #$10 : BEQ BRANCH_DELTA
        
        ; Is enabled
        LDA $048A : CMP.b #$02 : BNE BRANCH_GAMMA
        
        LDA.b #$03 : STA $EE
        
        LDA $1C : AND.b #$0F : STA $1C
        
        LDA.b #$10 : TSB $1D
        
        LDA $0492 : CMP.b #$02 : BEQ BRANCH_GAMMA
        
        REP #$20
        
        LDA $20 : ADD.w #$0018 : STA $20
        
    BRANCH_GAMMA:

        SEP #$20
        
        JSL Tagalong_Init
        
        REP #$20
        
        RTL

    BRANCH_DELTA:

        LDA $048A : CMP.b #$02 : BEQ BRANCH_EPSILON
        
        LDA.b #$10 : TSB $1C
        
        LDA $1D : AND.b #$0F : STA $0F
        
        LDA $0492 : CMP.b #$02 : BEQ BRANCH_GAMMA
        
        REP #$20
        
        LDA $20 : SUB.w #$0018 : STA $20
        
    BRANCH_EPSILON:

        SEP #$20
        
        JSL Tagalong_Init
        
        REP #$20
        
        RTL
    }

; ==============================================================================

    ; *$112B1-$11318 LOCAL
    {
        LDA $0462 : AND.b #$04 : BNE BRANCH_ALPHA
        
        REP #$30
        
        LDA $048C : ADD.w #$0008 : AND.w #$007F : STA $00
        
        LDX.w #$FFFE
    
    BRANCH_BETA:
    
        INX #2
        
        LDA $06B0, X : ASL A : AND.w #$007F : CMP $00 : BNE BRANCH_BETA
        
        LDA $06B0, X : ASL A : SUB.w #$0008 : STA $048C : TAX
        
        LDY.w #$0004
    
    BRANCH_GAMMA:
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2080, X : ORA.w #$2000 : STA $7E2080, X
        LDA $7E2100, X : ORA.w #$2000 : STA $7E2100, X
        LDA $7E2180, X : ORA.w #$2000 : STA $7E2180, X
        
        INX #2
        
        DEY : BPL BRANCH_GAMMA
        
        SEP #$30
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $11319-$1131C Jump Table
    {
        dw $932D ; = $1132D*
        dw $9334 ; = $11334*
    }

    ; *$1131D-$1132C JUMP LOCATION
    {
        LDA $B0 : ASL A : TAX
        
        JSR ($9319, X) ; $11319 IN ROM
        
        JSL $07E6A6 ; $3E6A6 IN ROM
        JSL PlayerOam_Main
        
        RTS
    }

; ==============================================================================

    ; *$1132D-$11333 JUMP LOCATION
    {
        JSL Spotlight_open
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$11334-$11356 JUMP LOCATION
    {
        JSL Sprite_Main
        JSL ConfigureSpotlightTable
        
        LDA $11 : BNE BRANCH_ALPHA
        
        STZ $96
        STZ $97
        STZ $98
        STZ $1E
        STZ $1F
        STZ $B0
        
        LDA $0132 : CMP.b #$FF : BEQ BRANCH_ALPHA
        
        STA $012C
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$11357-$113BA JUMP LOCATION
    Dungeon_StraightStairs:
    {
        LDA $B0 : CMP.b #$03 : BCC .doneWithAttrLoads
        
        JSL Dungeon_LoadAttrSelectable
    
    .doneWithAttrLoads
    
        LDA $B0 : CMP.b #$0D : BCC .waitForVramConfig
        
        JSL Graphics_IncrementalVramUpload
    
    .waitForVramConfig
    
        LDA $0464 : BEQ .counterElapsed
        
        DEC $0464
        
        CMP.b #$10 : BNE .noSlow
        
        ; When the counter is down to 0x10, slow the player sprite down.
        LDA.b #$02 : STA $57
    
    .noSlow
    
        LDX.b #$08
        
        LDA $11 : CMP.b #$12 : BEQ .downfacingStaircase
        
        LDX.b #$04
    
    .downfacingStaircase
    
        STX $67
        
        JSL $07E245 ; $3E245 IN ROM
    
    .counterElapsed
    
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw StraightStairs_0
        dw StraightStairs_1
        dw StraightStairs_2
        dw StraightStairs_3  ;
        dw StraightStairs_4  ;
        dw $8AAF ; = $10AAF* ; Loading tilemaps for the target room loading...
        dw $8AC4 ; = $10AC4*
        dw $8AAF ; = $10AAF*
        dw $8AC4 ; = $10AC4*
        dw StraightStairs_9  ;
        dw StraightStairs_10 ;
        dw StraightStairs_11 ;
        dw $8AC8 ; = $10AC8* ; Loading tilemaps for the target room...
        dw $8AB3 ; = $10AB3* ; ""
        dw $8AC8 ; = $10AC8* ; ""
        dw $9094 ; = $11094* ; Initiate some palette filtering crap we will likely continue in the subsequent submodules.
        dw $94ED ; = $114ED*
        dw $9518 ; = $11518*
        dw $8D71 ; = $10D71* ; Reset a lot of state variables
    }

; ==============================================================================

    ; *$113BB-$113EC JUMP LOCATION
    StraightStairs_0:
    {
        LDA $0372 : BEQ .notDashing
        
        STZ $0372
        
        LDA.b #$02 : STA $5E
    
    .notDashing
    
        LDX.b #$16
        
        ; Walking on an up staircase makes a different sound from a down one.
        LDA $0462 : AND.b #$04 : BEQ .upStaircase
        
        LDX.b #$18
    
    .upStaircase
    
        STX $012E
        
        REP #$20
        
        ; Fade the music when transitioning on the staircases between Agahnim's
        ; first room and the HC 2 floor that connects to it (going either up or
        ; down). This let's the player notice that the music is about to change.
        LDA $A0
        
        CMP.w #$0030 : BEQ .fadeMusicOut
        CMP.w #$0040 : BNE .dontFade
    
    .fadeMusicOut
    
        LDX.b #$F1 : STX $012C
    
    .dontFade
    
        SEP #$20
        
        JMP $8CA9 ; $10CA9 IN ROM
    }

; ==============================================================================

    ; *$113ED-$11402 JUMP LOCATION
    StraightStairs_1:
    {
        LDA $0464 : CMP.b #$09 : BCS BRANCH_ALPHA
        
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : CMP.b #$17 : BNE BRANCH_ALPHA
        
        INC $B0
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$11403-$11421 JUMP LOCATION
    StraightStairs_2:
    {
        JSL PaletteFilter.doFiltering
        JSL Dungeon_LoadRoom
        JSL Dungeon_RestoreStarTileChr
        JSL LoadTransAuxGfx
        JSL Dungeon_LoadCustomTileAttr
        JSL $02B5DC ; $135DC IN ROM
        JSL Tagalong_Init
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$11422-$11429 JUMP LOCATION
    StraightStairs_3:
    {
        JSL PaletteFilter.doFiltering
        JSR $8E0F ; $10E0F IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$1142A-$1143A JUMP LOCATION
    StraightStairs_4:
    {
        JSL PaletteFilter.doFiltering
        JSR $8E1D ; $10E1D IN ROM
        
        LDA $A0 : STA $048E
        
        JSL Dungeon_ResetSprites
        
        RTS
    }

; ==============================================================================

    ; *$1143B-$114DF JUMP LOCATION
    StraightStairs_11:
    {
        LDY.b #$16
        
        LDX $0414
        
        LDA $02894C, X : BPL .subscreenEnabled
        
        LDY.b #$17
        LDA.b #$00
    
    .subscreenEnabled
    
        STY $1C
        STA $1D
        
        LDY.b #$17
        
        INC $A4
        
        LDA.b #$01 : STA $57
        
        LDX.b #$3C
        
        ; The timer ($0464) and sound effect differ based on whether we're
        ; going up a staircase or down.
        LDA $0462 : AND.b #$04 : BEQ .upStaircase
        
        LDY.b #$19
        
        DEC $A4 : DEC $A4
        
        LDX.b #$32
    
    .upStaircase
    
        STX $0464
        STY $012E
        
        STZ $00
        
        LDY $11
        
        LDA $EE : BEQ .onBg2
        
        REP #$20
        
        LDA.w #$0020
        
        CPY.b #$12 : BNE .walkingDownStaircase
        
        LDA.w #$FFE0
    
    .walkingDownStaircase
    
        ADD $20 : STA $20
        
        INC $00
        
        SEP #$20
    
    .onBg2
    
        LDX $048A
        
        LDA $01C31F, X : STA $0476
        
        LDA $01C322, X : STA $EE : BEQ BRANCH_EPSILON
        
        REP #$20
        
        LDA.w #$0020
        
        CPY.b #$12 : BNE BRANCH_ZETA
        
        LDA.w #$FFE0
    
    BRANCH_ZETA:
    
        ADD $20 : STA $20
        
        INC $00
        
        SEP #$20
    
    BRANCH_EPSILON:
    
        LDA $00 : BNE BRANCH_THETA
        
        REP #$20
        
        LDA.w #$000C
        
        CPY.b #$12 : BNE BRANCH_IOTA
        
        REP #$10
        
        LDX.w #$FFE8
        
        LDA $0462 : AND.w #$0004 : BNE BRANCH_KAPPA
        
        LDX.w #$FFF8
    
    BRANCH_KAPPA:
    
        TXA
    
    BRANCH_IOTA:
    
        ADD $20 : STA $20
        
        SEP #$30
    
    BRANCH_THETA:
    
        JSR $8EC9   ; $10EC9 IN ROM
        JSL RestoreTorchBackground
        JMP $8AB3   ; $10AB3 IN ROM
    }

; ==============================================================================

    ; *$114E0-$114EC JUMP LOCATION
    StraightStairs_9:
    {
        JSL PaletteFilter.doFiltering
        
        DEC $B0
        
        JSL $00E031 ; $6031 IN ROM
        JMP $A1E9   ; $121E9 IN ROM
    }

; ==============================================================================

    ; *$114ED-$11517 JUMP LOCATION
    {
        LDA $0200 : CMP.b #$05 : BNE BRANCH_ALPHA
        
        LDA $7EC009 : BNE BRANCH_ALPHA
        
        INC $B0
        
        REP #$20
        
        LDX.b #$1C
        
        LDA $A0
        
        CMP.w #$0030 : BEQ BRANCH_BETA
        CMP.w #$0040 : BNE BRANCH_GAMMA
        
        LDX.b #$10
    
    BRANCH_BETA:
    
        STX $012C
    
    BRANCH_GAMMA:
    
        SEP #$20
    
    ; *$11513 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        JSL Dungeon_ApproachFixedColor
        
        RTS
    }

; ==============================================================================

    ; *$11518-$1151F JUMP LOCATION
    {
        LDA $0464 : BNE BRANCH_$11513
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$11520-$11529 JUMP LOCATION
    {
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $952A ; = $1152A*
        dw $9583 ; = $11583*
    }

; ==============================================================================

    ; *$1152A-$11582 JUMP LOCATION
    {
        REP #$20
        
        ; Compare the stored BG1 H value with current one.
        LDA $E2 : CMP $7EC180 : BEQ BRANCH_ALPHA : BCC BRANCH_BETA ; If the current value is < stored value
        
        DEC A : CMP $7EC180 : BEQ BRANCH_ALPHA
        
        DEC A
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        ; Increment so we can back to the origin.
        INC A : CMP $7EC180 : BEQ BRANCH_ALPHA
        
        INC A
    
    BRANCH_ALPHA:
    
        STA $E2
        
        LDA $E8 : CMP $7EC182 : BEQ BRANCH_GAMMA : BCC BRANCH_DELTA
        
        DEC A : CMP $7EC182 : BEQ BRANCH_GAMMA
        
        DEC A
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        INC A : CMP $7EC182 : BEQ BRANCH_GAMMA
        
        INC A
    
    BRANCH_GAMMA:
    
        STA $E8 : CMP $7EC182 : BNE BRANCH_EPSILON
        
        LDA $E2 : CMP $7EC180 : BNE BRANCH_EPSILON
        
        INC $B0
    
    BRANCH_EPSILON:
    
        LDA $0458 : BNE BRANCH_ZETA
        
        JSR $BB7B ; $13B7B IN ROM
    
    BRANCH_ZETA:
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$11583-$11679 JUMP LOCATION
    {
        REP #$20
        
        LDA $7EC184 : STA $20
        LDA $7EC186 : STA $22
        LDA $7EC188 : STA $0600
        LDA $7EC18A : STA $0604
        LDA $7EC18C : STA $0608
        LDA $7EC18E : STA $060C
        LDA $7EC190 : STA $0610
        LDA $7EC192 : STA $0612
        LDA $7EC194 : STA $0614
        LDA $7EC196 : STA $0616
        
        LDA $1B : AND.w #$00FF : BEQ .outdoors
        
        LDA $7EC198 : STA $0618
        
        INC #2 : STA $061A
        
        LDA $7EC19A : STA $061C
        
        INC #2 : STA $061E

    .outdoors

        LDA $7EC19C : STA $A6
        LDA $7EC19E : STA $A9
        
        LDA $1B : AND.w #$00FF : BNE .indoors

        LDA $0618 : DEC #2 : STA $061A
        LDA $061C : DEC #2 : STA $061E
    
    .indoors
    
        SEP #$20
        
        LDA $7EC1A6 : STA $2F
        LDA $7EC1A7 : STA $EE
        
        LDA $7EC1A8 : STA $0476
        
        LDA $7EC1A9 : STA $6C
        
        LDA $7EC1AA : STA $A4
        
        STZ $4B
        
        LDA.b #$90 : STA $031F
        
        JSR $8EC9 ; $10EC9 IN ROM
        
        STZ $037B
        
        JSL $07984B ; $3984B IN ROM
        
        STZ $02F9
        
        JSL Tagalong_Init
        
        STZ $0642
        STZ $0200
        STZ $B0
        STZ $0418
        STZ $11
        
        LDA $7EF36D : BNE .notDead
        
        LDA.b #$00 : STA $7EF36D
        
        LDA $1C : STA $7EC211
        LDA $1D : STA $7EC212
        
        LDA $10 : STA $010C
        
        LDA.b #$12 : STA $10
        LDA.b #$01 : STA $11
        
        STZ $031F
    
    .notDead
    
        RTS
    }

; ==============================================================================

    ; *$1167A-$116AB JUMP LOCATION
    Dungeon_Teleport:
    {
        ; Module 0x07.0x15 (????)
        
        LDA $B0 : CMP.b #$03 : BCC .alpha
        
        JSL Graphics_IncrementalVramUpload
        JSL Dungeon_LoadAttrSelectable
    
    .alpha
    
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8CA9 ; = $10CA9*
        dw $96AC ; = $116AC*
        dw $8CE2 ; = $10CE2*
        dw $8D10 ; = $10D10*
        dw $96BA ; = $116BA*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AED ; = $10AED*
        dw $96EC ; = $116EC*
        dw $970F ; = $1170F*
    }

    ; *$116AC-$116B9 JUMP LOCATION
    {
        JSR Overworld_ResetMosaic
        
        LDA $7EC011 : ORA.b #$03 : STA $95
        
        JMP $A2A0 ; $122A0 IN ROM
    }

    ; *$116BA-$116EB JUMP LOCATION
    {
        JSL Dungeon_ApproachFixedColor
        
        REP #$20
        
        LDA $A0 : CMP.w #$0017 : BNE .notRoomRightBeforeMoldorm
        
        ; Set floor to "F5"?
        LDX.b #$04 : STX $A4
    
    .notRoomRightBeforeMuldorm
    
        JSR $BB7B   ; $13B7B IN ROM
        JSL $02B5DC ; $135DC IN ROM
        
        LDY.b #$16
        
        LDX $0414
        
        LDA $02894C, X : BPL .subscreenEnabled
        
        LDY.b #$17
        LDA.b #$00
    
    .subscreenEnabled
    
        STY $1C
        STA $1D
        
        JSL $0091C4 ; $11C4 IN ROM
        
        INC $B0
        
        RTS
    }

    ; *$116EC-$1170E JUMP LOCATION
    {
        LDA $7EC007 : LSR A : BCC .mosaicDisabled
        
        LDA $7EC011 : BEQ .mosaicDisabled
        
        SUB.b #$10 : STA $7EC011
    
    .mosaicDisabled
    
        LDA.b #$09 : STA $94
        
        LDA $7EC011 : ORA.b #$03 : STA $95
        
        JMP $A2A0 ; $122A0 IN ROM
    }

; ==============================================================================

    ; *$1170F-$1171F JUMP LOCATION
    {
        LDA $0200 : CMP.b #$05 : BNE .alpha
        
        JSL $02B8CB ; $138CB IN ROM
        
        STZ $11
        
        JSR $8D71 ; $10D71 IN ROM
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $11720-$11729 Jump Table
    {
        dw $9739 ; = $11739* ; First four steps perform animation to show one barrier type
        dw $9739 ; = $11739* ; Going up while the other goes down.
        dw $974D ; = $1174D* ; The last step updates the tile attribute table
        dw $9761 ; = $11761*
        dw $97A9 ; = $117A9* ; Swap the barrier collision states.
    }

    ; *$1172A-$11738 JUMP LOCATION
    {
        ; Module 0x07.0x16 - Orange/Blue Barrier swapping
        
        INC $B0 : LDA $B0 : AND.b #$03 : BNE BRANCH_$1171F ; (RTS)
        
        LDA $B0 : LSR A : TAX
        
        JMP ($9720, X) ; $11720 IN ROM
    }

    ; *$11739-$117A8 JUMP LOCATION
    {
        REP #$10
        
        LDX.w #$0100
        LDY.w #$0080
        
        LDA $7EC172 : BEQ BRANCH_ALPHA
        
        TYX
        
        LDY.w #$0100
    
    BRANCH_ALPHA:
    
        BRA BRANCH_BETA
    
    ; *$1174D ALTERNATE ENTRY POINT
    
        REP #$10
        
        LDX.w #$0080
        LDY.w #$0100
        
        LDA $7EC172 : BEQ BRANCH_EPSILON
        
        TYX
        
        LDY.w #$0080
    
    BRANCH_EPSILON:
    
        BRA BRANCH_BETA
    
    ; *$11761 ALTERNATE ENTRY POINT
    
        REP #$10
        
        LDX.w #$0000
        LDY.w #$0180
        
        LDA $7EC172 : BEQ BRANCH_BETA
        
        TYX
        
        LDY.w #$0000
    
    ; *$11773 ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        STY $0E
        
        PHB : LDA.b #$7F : PHA : PLB
        
        REP #$20
        
        LDY.w #$0000
    
    BRANCH_GAMMA:
    
        LDA $7EB340, X : STA $0000, Y
        
        INX #2
        
        INY #2 : CPY.w #$0080 : BNE BRANCH_GAMMA
        
        LDX $0E
    
    BRANCH_DELTA:
    
        LDA $7EB340, X : STA $0000, Y
        
        INX #2
        
        INY #2 : CPY.w #$0100 : BNE BRANCH_DELTA
        
        SEP #$30
        
        PLB
        
        LDA.b #$17 : STA $17
        
        RTS
    }

    ; *$117A9-$117B1 JUMP LOCATION
    {
        JSL Dungeon_ToggleBarrierAttr ; $C22A IN ROM
        
        STZ $B0
        STZ $11
        
        RTS
    }

    ; *$117B2-$117C7 LONG
    {
        REP #$10
        
        LDX.w #$0000
        LDY.w #$0180
        
        LDA $7EC172 : BEQ BRANCH_ALPHA
        
        TYX
        
        LDY.w #$0000
    
    BRANCH_ALPHA:
    
        JSR $9773; $11773 IN ROM
        
        RTL
    }

; ==============================================================================

    ; *$117C8-$117F9 JUMP LOCATION
    {
        DEC $B0 : BNE .stillCountingDown
        
        REP #$30
        
        LDA $20 : SUB.w #$0002 : STA $20
        
        ; restore the button to its rightful graphics?
        LDA $04B6 : LSR #3 : AND.w #$01F8 : STA $02
        
        LDA $04B6 : AND.w #$003F : ASL #3 : STA $00
        
        SEP #$30
        
        LDY.b #$0E
        
        JSL Dungeon_SpriteInducedTilemapUpdate
        
        LDA $010C : STA $11
    
    .stillCountingDown
    
        RTS
    }

; ==============================================================================

    ; $117FA-$11809 DATA
    {
        dw $1618, $1658, $1658, $1618, $0658, $1618, $1658, $0000
    }

; ==============================================================================

    ; *$1180A-$11825 JUMP LOCATION
    Dungeon_Crystal:
    {
        ; Module 0x07.0x18 - Crystal Maiden sequence
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $9826 ; = $11826*
        dw $9888 ; = $11888* ; Figure out which quadrant the crystal is in.
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8* ; 
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $8AB3 ; = $10AB3*
        dw $8AC8 ; = $10AC8*
        dw $98E7 ; = $118E7*
    }

; ==============================================================================

    ; *$11826-$11887 JUMP LOCATION
    {
        JSL PaletteFilter_Restore_Strictly_Bg_Subtractive
        
        LDA $7EC540 : STA $7EC500
        LDA $7EC541 : STA $7EC501
        
        LDA $7EC009 : CMP.b #$FF : BNE BRANCH_ALPHA
        
        REP #$30
        
        LDX.w #$0000
        LDA.w #$01EC
    
    BRANCH_BETA:
    
        STA $7E2000, X : STA $7E2800, X : STA $7E3000, X : STA $7E3800, X
        STA $7E4000, X : STA $7E4800, X : STA $7E5000, X : STA $7E5800, X
        
        INX #2 : CPX.w #$0800 : BNE BRANCH_BETA
        
        STZ $011C
        STZ $011A
        
        STZ $0422
        STZ $0424
        
        SEP #$30
        
        STZ $0418
        STZ $045C
        
        INC $B0
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$11888-$118E6 JUMP LOCATION
    {
        JSL PaletteFilter_Crystal
        
        LDA.b #$01 : STA $1D
        
        LDA.b #$02 : STA $02E4
        
        REP #$20
        
        LDX.b #$0E
        
        LDA $A0
    
    BRANCH_ALPHA:
    
        DEX #2
        
        CMP $02895C, X : BNE BRANCH_ALPHA
        
        LDA $0297FA, X : STA $08
        
        REP #$10
        
        LDA.w #$0004 : STA $0C
        STZ $0E
    
    BRANCH_GAMMA:
    
        LDY.w #$0007
        
        LDX $08
    
    BRANCH_BETA:
    
        LDA $0E : ORA.w #$1F80 : STA $7E4000, X
                  ORA.w #$1F88 : STA $7E4200, X
        
        INC $0E
        
        INX #2
        
        DEY : BPL BRANCH_BETA
        
        LDA $0E : ADD.w #$0008 : STA $0E
        LDA $08 : ADD.w #$0080 : STA $08
        
        DEC $0C : BNE BRANCH_GAMMA
        
        SEP #$30
        
        INC $B0
        
        RTS
    }

    ; *$118E7-$118F6 JUMP LOCATION
    {
        INC $012A
        
        JSL Polyhedral_InitThread
        JSL CrystalMaiden_Configure
        
        STZ $11
        STZ $B0
        
        RTS
    }

    ; *$118F7-$11915 JUMP LOCATION
    {
        ; Module 0x07.0x19
        
        JSR Overworld_ResetMosaic_alwaysIncrease ; $142EB IN ROM
        
        DEC $13 : BNE .notFullyDarkened
        
        ; Go to "load game" module...?
        LDA.b #$05 : STA $10
        
        STZ $11
        STZ $14
        
        LDA $0130 : STA $0133
        
        LDA $0ABD : BEQ .noPaletteSwap
        
        JSL Palette_RevertTranslucencySwap
    
    .noPaletteSwap
    .notFullyDarkened
    
        RTS
    }

    ; *$11916-$1191A JUMP LOCATION
    Dungeon_OpenGanonDoor:
    {
        ; Module 0x07.0x1A
        
        JSL Object_OpenGanonDoor ; $F5DA IN ROM
        
        RTS
    }

    ; *$1191B-$11921 JUMP LOCATION
    Module_Unknown0:
    {
        ; Beginning of Module #$C, ???? Mode
        
        JSR Overworld_ResetMosaic
        JSR $9922 ; $11922 IN ROM
        
        RTL
    }

    ; *$11922-$1192D LOCAL
    {
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8CA9 ; = $10CA9*
        dw $A2A0 ; = $122A0*
        dw $992E ; = $1192E*
    }

    ; *$1192E-$11937 JUMP LOCATION
    {
        LDA $010C : STA $10
        
        STZ $11
        STZ $B0
        
        RTS
    }

    ; *$11938-$11950 JUMP LOCATION
    Module_Unknown1:
    {
        ; Beginning of Module 0x0D,
        
        LDA $7EC007 : LSR A : BCC BRANCH_ALPHA
        
        LDA $7EC011 : SUB.b #$10 : STA $7EC011
    
    BRANCH_ALPHA:
    
        JSR $C2F6 ; $142F6 IN ROM
        JSR $9951 ; $11951 IN ROM
        
        RTL
    }

    ; *$11951-$1195A LOCAL
    {
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $A2A0 ; = $122A0*
        dw $995B ; = $1195B*
    }

    ; *$1195B-$11979 JUMP LOCATION
    {
        STZ $11
        STZ $B0
        
        LDA $010C : STA $10 : CMP.b #$09 : BNE BRANCH_ALPHA
        
        LDA $0696 : ORA $0698 : BEQ BRANCH_ALPHA
        
        LDA.b #$0A : STA $11 ; mode for coming out of a special door?
        
        LDA.b #$10 : STA $069A

    BRANCH_ALPHA:

        RTS
    }

    ; $1197A-$1197D DATA

    ; $1197E-$11981 Jump Table
    {
        dw $99CA ; = $119CA*
        dw $9A19 ; = $11A19*
    }

; ==============================================================================

    ; *$11982-$119C9 JUMP LOCATION
    Module_CloseSpotlight:
    {
        ; Beginning of Module 0x0F, "HDMA spotlights closing"
        
        JSL Sprite_Main
        
        LDA $11 : ASL A : TAX
        
        JSR ($997E, X) ; $1197E IN ROM
        
        LDA $1B : BNE BRANCH_ALPHA
        
        LDA $8A : CMP.b #$0F : BNE BRANCH_BETA
        
        LDA.b #$01 : STA $0351
    
    BRANCH_BETA:
    
        LDA.b #$06 : STA $5E
        
        JSL $07E245 ; $3E245 IN ROM
        
        STZ $31
        STZ $30
    
    BRANCH_ALPHA:
    
        LDA $2F : LSR A : TAX
        
        LDA $1B : BNE BRANCH_GAMMA
        
        LDX.b #$00
        
        LDA $010E : CMP.b #$43 : BNE BRANCH_GAMMA
        
        INX
    
    BRANCH_GAMMA:
    
        LDA $02997A, X : STA $26 : STA $67
        
        JSL $07E6A6 ; $3E6A6 IN ROM
        JML PlayerOam_Main
    }

; ==============================================================================

    ; *$119CA-$11A18 JUMP LOCATION
    {
        STZ $012A
        STZ $1F0C
        
        LDA $1B : BNE BRANCH_ALPHA
        
        JSL Ancilla_TerminateWaterfallSplashes
        
        REP #$20
        
        LDA $20 : STA $7EC148
        
        SEP #$20
    
    BRANCH_ALPHA:
    
        LDX $010E
        
        LDA $02D82E, X : CMP.b #$03 : BNE BRANCH_BETA
        
        LDA $7EF3C5 : CMP.b #$02 : BCC BRANCH_GAMMA
    
    BRANCH_BETA:
    
        CMP.b #$F2 : BNE BRANCH_DELTA
        
        LDX $0130 : CPX.b #$0C : BNE BRANCH_EPSILON
        
        LDA.b #$07
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LDA.b #$F1
    
    BRANCH_EPSILON:
    
        STA $012C
    
    BRANCH_GAMMA:
    
        STZ $04A0
        
        JSL $0AFD0C ; $57D0C IN ROM
        
        INC $16
        
        JSL Spotlight_close
        
        INC $11
        
        RTS
    }

    ; *$11A19-$11AD2 JUMP LOCATION
    {
        JSL ConfigureSpotlightTable
        
        ; Disable IRQ logic
        STZ $012A
        STZ $1F0C
        
        LDA $11 : BNE BRANCH_$11A18 ; (RTS)
        
        LDA $10 : CMP.b #$06 : BNE BRANCH_ALPHA
        
        REP #$20
        
        LDA $7EC148 : STA $20
        
        SEP #$20
    
    ; *$11A37 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDA $10 : CMP.b #$09 : BEQ BRANCH_BETA
        
        ; Force V-blank in preperation for Dungeon mode
        JSL EnableForceBlank ; $93D IN ROM
        
        JSL $07B107 ; $3B107 IN ROM
    
    BRANCH_BETA:
    
        LDA $10 : CMP.b #$09 : BNE BRANCH_GAMMA
        
        LDA $A1 : BNE BRANCH_DELTA
        
        LDA $A0 : CMP.b #$20 : BEQ BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LDA.b #$0A
        
        LDX $2F : BNE BRANCH_ZETA
        
        LDA.b #$0B
    
    BRANCH_ZETA:
    
        STA $11
    
    BRANCH_EPSILON:
    
        LDA.b #$10 : STA $069A
        
        LDA $0696 : ORA $0698 : BEQ BRANCH_GAMMA ; not an extended door type (palace or sanctuary)
        
        LDA $0699 : BEQ BRANCH_GAMMA
        
        LDX.b #$00
        
        ASL A : BCC BRANCH_THETA
        
        LDX.b #$18
    
    BRANCH_THETA:
    
        LDA $0699 : AND.b #$7F : STA $0699
        
        STX $0692
        
        STZ $0690
        
        LDA.b #$09 : STA $11
        
        STZ $B0
        
        LDA.b #$15 : STA $012F
    
    BRANCH_GAMMA:
    
        STZ $96 : STZ $97 : STZ $98
        STZ $1E : STZ $1F : STZ $03EF
        
        REP #$30
        
        ; Setup fixed color values based on area number
        
        LDX.w #$4C26
        LDY.w #$8C4C
        
        LDA $8A
        
        CMP.w #$0003 : BEQ .mountain
        CMP.w #$0005 : BEQ .mountain
        CMP.w #$0007 : BEQ .mountain
        
        LDX.w #$4A26 : LDY.w #$874A
        
        CMP.w #$0043 : BEQ .mountain
        CMP.w #$0045 : BEQ .mountain
        CMP.w #$0047 : BNE .other
    
    .mountain
    
        STX $9C : STY $9D
    
    .other
    
        SEP #$30
        
        RTS
    }

; =============================================

    ; $11AD3-$11AD6 Jump Table
    {
        dw $9AE6 ; = $11AE6*
        dw $9A19 ; = $11A19*
    }

; =============================================

    ; *$11AD7-$11AE5 JUMP LOCATION LONG
    Module_OpenSpotlight:
    {
        ; Module 0x10
        
        JSL Sprite_Main
        
        LDA $11 : ASL A : TAX
        
        JSR ($9AD3, X) ; $11AD3 IN ROM
        
        JML PlayerOam_Main
    }

; =============================================

    ; $11AE6-$11AEC JUMP LOCATION
    {
        ; Module 0x10.0x00
        
        JSL Spotlight_open
        
        ; Move to the next submodule
        INC $11
        
        RTS
    }

; ==============================================================================

    ; $11AED-$11AF8 Jump Table
    pool Module_HoleToDungeon:
    {
    
    .submodules
        dw HoleToDungeon_FadeMusic
        dw HoleToDungeon_PaletteFilter
        dw HoleToDungeon_LoadDungeon
        dw $8D10 ; = $10D10*
        dw $9C0F ; = $11C0F*
        dw $9C1C ; = $11C1C*
    }

; ==============================================================================

    ; *$11AF9-$11B00 JUMP LOCATION LONG
    Module_HoleToDungeon:
    {
        LDA $B0 : ASL A : TAX
        
        JSR (.submodules, X)
        
        RTL
    }

; ==============================================================================

    ; *$11B01-$11B1B LOCAL
    HoleToDungeon_FadeMusic:
    {
        ; Module 0x11.0x00
        
        LDX $010E
        
        LDA $02D82E, X : CMP.b #$03 : BNE .not_legend_theme
        
        LDA $7EF3C5 : CMP.b #$02 : BCC .dont_fade
    
    .not_legend_theme
    
        LDA.b #$F1 : STA $012C
    
    .dont_fade
    
        JMP $8CA9 ; $10CA9 IN ROM
    }

; ==============================================================================

    ; *$11B1C-$11C0E LOCAL
    HoleToDungeon_LoadDungeon:
    {
        ; Module 0x11.0x02 (falling into a hole)
        
        JSL EnableForceBlank
        
        LDA.b #$02 : STA $99
        
        JSR Dungeon_LoadEntrance
        
        LDA $040C : CMP.b #$FF : BEQ .not_palace
                    CMP.b #$02 : BNE .not_sewer
        
        LDA.b #$00
    
    .not_sewer
    
        LSR A : TAX
        
        LDA $7EF37C, X
    
    .not_palace
    
        JSL HUD.RebuildIndoor.palace
        
        LDA.b #$04 : STA $5A
        LDA.b #$03 : STA $5B
        LDA.b #$0C : STA $4B
        LDA.b #$10 : STA $57
        
        LDA $20 : SUB $E8 : STA $00 : STZ $01 
        
        STZ $0308
        STZ $0309
        STZ $030B
        
        REP #$30
        
        LDA $A0 : STA $A2
        
        LDA.w #$0010 : ADD $00 : STA $00
        
        LDA $20 : STA $51
        
        SUB $00 : STA $20
        
        SEP #$30
        
        LDA $B0 : PHA
        
        STZ $045A
        STZ $0458
        
        JSR Dungeon_LoadAndDrawRoom
        JSL Dungeon_LoadCustomTileAttr
        
        ; Load main tileset index.
        LDX $0AA1
        
        ; Use it to compress the appropriate animated tiles?
        LDA $02811E, X : TAY
        
        JSL DecompDungAnimatedTiles
        JSL Dungeon_LoadAttrTable
        
        ; Increment to next submodule
        PLA : INC A : STA $B0
        
        LDA.b #$0A : STA $0AA4
        
        ; Set OBJSEL.
        LDA.b #$02 : STA $2101
        
        JSL InitTilesets
        
        LDA.b #$0A : STA $0AB1
        
        JSR Dungeon_LoadPalettes
        JSL HUD.RestoreTorchBackground
        
        STZ $3A
        STZ $3C
        
        JSR Dungeon_ResetTorchBackgroundAndPlayer
        
        LDA $02E0 : BEQ .using_normal_player_gfx
        
        JSL LoadGearPalettes.bunny 
    
    .using_normal_player_gfx
    
        LDA.b #$80 : STA $9B
        
        JSL HUD.RefillLogicLong
        JSL Module_PreDungeon.setAmbientSfx
        
        LDA.b #$07 : STA $11
    
    ; $11BD7 ALTERNATE ENTRY POINT
    shared Dungeon_LoadSongBankIfNeeded:
    
        ; Is there no music loading?
        LDA $0132
        
        CMP.b #$FF : BEQ .dontLoadMusic
        CMP.b #$F2 : BEQ .dontLoadMusic ; Half volume music.
        CMP.b #$03 : BEQ .song_is_in_outdoor_bank
        CMP.b #$07 : BEQ .song_is_in_outdoor_bank
        CMP.b #$0E : BEQ .song_is_in_outdoor_bank
        
        LDA $0136 : BNE .dontLoadMusic
        
        SEI
        
        STZ $4200
        STZ $420C
        
        INC $0136
        
        LDA.b #$FF : STA $2140
        
        JSL Sound_LoadIndoorSongBank
        
        LDA.b #$81 : STA $4200
    
    .dontLoadMusic
    
        RTS
    
    .song_is_in_outdoor_bank
    
        JMP Overworld_LoadMusicIfNeeded
    }

; ==============================================================================

    ; *$11C0F-$11C3D LOCAL
    {
        LDA $13 : INC A : AND.b #$0F : STA $13
        
        CMP.b #$0F : BNE .notFullyBright
        
        INC $B0
    
    ; *$11C1C ALTERNATE ENTRY POINT
    .notFullyBright
    
        JSL $079520 ; $39520 IN ROM
        
        LDA $11 : BNE .notDefaultSubmodule
        
        LDA.b #$07 : STA $10
        
        ; Disable tag routines while Link is still falling
        INC $04C7
        
        JSR $8EC9 ; $10EC9 IN ROM
        JSR $8D71 ; $10D71 IN ROM
        
        LDA $0132 : STA $012C
        
        LDA $0130 : STA $0133
    
    .notDefaultSubmodule
    
        RTS
    }

; ==============================================================================

    ; $11C3E-$11C49 Jump Table
    {
        dw $9C59 ; = $11C59*
        dw $9C93 ; = $11C93*
        dw $9CAD ; = $11CAD*
        dw $9CD1 ; = $11CD1*
        dw $99CA ; = $119CA*
        dw $9A19 ; = $11A19*
    }

; ==============================================================================

    ; *$11C4A-$11C58 JUMP LOCATION
    Module_GanonVictory:
    {
        ; Beginning of Module 0x13, Boss Victory and Refill Mode
        
        LDA $11 : ASL A : TAX
        
        JSR ($9C3E, X)  ; $11C3E IN ROM
        
        JSL Sprite_Main
        JML PlayerOam_Main
    }

; ==============================================================================

    ; *$11C59-$11C92 LOCAL
    {
        JSL HUD.RefillMagicPower : BCS BRANCH_ALPHA
        
        INC $0200
    
    BRANCH_ALPHA:
    
        JSL HUD.RefillHealth : BCS BRANCH_BETA
        
        INC $0200
    
    BRANCH_BETA:
    
        LDA $0200 : BNE BRANCH_GAMMA
        
        LDA $3A : AND.b #$BF : STA $3A
        
        JSR $8B0C ; $10B0C IN ROM
        
        LDA.b #$02 : STA $2F
        
        ASL A : STA $26
        
        INC $16 : INC $11
        
        LDA.b #$10 : STA $B0
        
        ; Make it so Link can’t move.
        INC $02E4
    
    BRANCH_GAMMA:
    
        STZ $0200
        
        JSL HUD.RefillLogicLong
        
        RTS
    }

; ==============================================================================

    ; *$11C93-$11CAC JUMP LOCATION
    {
        DEC $B0 : BNE .countingDown
        
        STZ $02E4
        
        LDA.b #$02 : STA $2F
        
        JSL $07A7B0 ; $3A7B0 IN ROM
        JSL Ancilla_TerminateSelectInteractives
        JSL AddVictorySpinEffect
        
        INC $11
    
    .countingDown
    
        RTS
    }

; ==============================================================================

    ; *$11CAD-$11CD0 JUMP LOCATION
    {
        JSL Player_Main
        
        LDA $5D : CMP.b #$00 : BNE .return
        
        ; What the deuce... are we supposed to be able to get
        ; the master sword without having the original sword?
        ; The sound effect only triggers if you have the fighter sword, or the tempered sword
        LDA $7EF359 : INC A : AND.b #$FE : BEQ .noSound
        
        ; Play "pulling master sword out" sound
        LDA.b #$2C : STA $012E
    
    .noSound
    
        LDA.b #$01 : STA $03EF
        
        LDA.b #$20 : STA $B0
        
        INC $11
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$11CD1-$11CE1 JUMP LOCATION
    {
        DEC $B0 : BNE BRANCH_ALPHA
        
        INC $11
        
        STZ $30
        STZ $31
        
        LDA.b #$00 : STA $7EC017
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $11CE2-$11CFB Jump Table
    pool Module_Mirror:
    {
    
    .states
        dw Mirror_LoadMusic
        dw Mirror_Init
        dw $9E06 ; = $11E06* ; 
        dw $9E0F ; = $11E0F*
        dw $9E15 ; = $11E15*
        dw $9D5D ; = $11D5D*
        dw $9DB6 ; = $11DB6*
        dw $9DC2 ; = $11DC2*
        dw $9DF5 ; = $11DF5*
        dw $9C59 ; = $11C59*
        dw $9C93 ; = $11C93*
        dw $9CAD ; = $11CAD*
        dw $9E22 ; = $11E22*
    }

; ==============================================================================

    ; *$11CFC-$11D15 JUMP LOCATION LONG
    Module_Mirror:
    {
        ; Beginning of Module 0x15, Magic Mirror?
        
        LDA $11 : ASL A : TAX
        
        JSR (.states, X)
        
        LDA $11
        
        CMP.b #$02 : BCC .runCoreTasks
        CMP.b #$05 : BCC .ignoreCoreTasks

    .runCoreTasks

        JSL Sprite_Main
        JSL PlayerOam_Main

    .ignoreCoreTasks

        RTL
    }

; ==============================================================================

    ; *$11D16-$11D21 LOCAL
    Mirror_LoadMusic:
    {
        STZ $0710
        
        INC $0200
        INC $11
        
        JSR Overworld_LoadMusicIfNeeded
        
        RTS
    }

; ==============================================================================

    ; *$11D22-$11D5C LOCAL
    Mirror_Init:
    {
        ; Play the mirror warp "music"
        LDA.b #$08 : STA $012C
                     STA $0410
        
        JSL Mirror_InitHdmaSettings
        
        STZ $0200
        
        JSL Palette_InitWhiteFilter
        JSR Overworld_LoadMapProperties
        
        INC $11
        
        ; Put player into the "Being magic mirror warped state"
        LDA.b #$14 : STA $5D
        
        REP #$20
        
        STZ $011A
        STZ $011C
        STZ $0402
        STZ $30
        
        LDA.w #$7FFF : STA $7EC500 : STA $7EC540
        
        SEP #$20
        
        JSL $0BFFEE ; $5FFEE IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$11D5D-$11DB5 LOCAL
    {
        REP #$30
        
        LDA.w #$2641 : STA $4370
        
        LDX.w #$003E
        LDA.w #$FF00
    
    .alpha
    
        STA $1B00, X : STA $1B40, X : STA $1B80, X : STA $1BC0, X
        STA $1C00, X : STA $1C40, X : STA $1C80, X
        
        DEX #2 : BPL .alpha
        
        LDA.w #$0000 : STA $7EC007 : STA $7EC009
        
        SEP #$20
        
        LDX.w #$0035 : STX $1CF0
        
        SEP #$10
        
        JSL Main_ShowTextMessage
        JSL $00D788 ; $5788 IN ROM
        JSL HUD.RebuildIndoor
        
        LDA.b #$80 : STA $9B
        
        LDA.b #$15 : STA $10
        LDA.b #$06 : STA $11
        LDA.b #$18 : STA $B0
        
        RTS
    }

; ==============================================================================

    ; *$11DB6-$11DC1 LOCAL
    {
        DEC $B0 : BNE BRANCH_ALPHA
        
        INC $11
        
        LDA.b #$09 : STA $012D
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$11DC2-$11DF4 LOCAL
    {
        JSL Messaging_Text
        
        LDA $11 : BNE BRANCH_ALPHA
        
        STZ $0200
        
        LDA.b #$05 : STA $012D
        
        LDX.b #$09
        
        LDA $7EF357 : BNE BRANCH_BETA
        
        REP #$20
        
        LDA.w #$0036 : STA $1CF0
        
        SEP #$20
        
        JSL Main_ShowTextMessage
        
        STZ $012D
        
        LDA.b #$15 : STA $10
        
        LDX.b #$09
        
        DEX
    
    BRANCH_BETA:
    
        STX $11
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$11DF5-$11E05 LOCAL
    {
        JSL Messaging_Text
        
        LDA $11 : BNE BRANCH_ALPHA
        
        LDA.b #$20 : STA $B0
        LDX.b #$0C : STX $11
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$11E06-$11E0E LOCAL
    {
        JSL $00FE5E ; $7E5E IN ROM
        
        INC $11
        
        STZ $B0
        
        RTS
    }

    ; *$11E0F-$11E21 LOCAL
    {
        JSL $00FE64 ; $7E64 IN ROM
        
        BRA BRANCH_ALPHA
    
    ; *$11E15 ALTERNATE ENTRY POINT
    
        JSL $00FF2F ; $7F2F IN ROM
    
    BRANCH_ALPHA:
    
        LDA $B0 : BEQ BRANCH_BETA
        
        STZ $B0
        
        INC $11
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$11E22-$11E5E LOCAL
    {
        DEC $B0 : BNE .stillCountingDown
        
        JSL $029E6E ; $11E6E IN ROM
        JSL Overworld_SetSongList
        
        LDA $7EF29B : ORA.b #$20 : STA $7EF29B
        
        LDA.b #$FF : STA $040C
        
        STZ $11
        STZ $0200
        STZ $0710
        
        LDA.b #$09 : STA $10
        
        STZ $E6
        
        LDX.b #$09
        
        LDA $7EF357 : BNE .hasMoonPearl
        
        ; Set the music differently if Link has no moon pearl
        LDX.b #$04
    
    .hasMoonPearl
    
        STX $012C
        
        LDA.b #$06 : STA $7EF3C7
    
    .stillCountingDown
    
        RTS
    }

; =============================================

    ; *$11E5F-$11E7F LONG
    {
        ; If Link is not currently in a mirror warp, return
        ; This seems silly though, because the only routine that references this
        ; is from the mirror module...
        LDA $10 : CMP.b #$15 : BNE .not_in_mirror_module
        
        JSR Overworld_LoadExitData
        
        LDY.b #$5A
        
        ; \task address naming of this routine.
        JSL DecompOwAnimatedTiles ; $5394 IN ROM
    
    ; *$11E6E ALTERNATE ENTRY POINT
    
        JSL Ancilla_TerminateSelectInteractives
        
        STZ $037B
        
        STZ $3C : STZ $3A
        
        STZ $03EF : STZ $02E4
    
    .not_in_mirror_module
    
        RTL
    }

; ==============================================================================

    ; $11E80-$11E89 Jump Table
    pool Module_Victory:
    {
    
    .states
        dw $9C59 ; = $11C59*
        dw $9C93 ; = $11C93*
        dw $9CAD ; = $11CAD*
        dw $9CD1 ; = $11CD1*
        dw $9E9A ; = $11E9A*
    }

; ==============================================================================

    ; *$11E8A-$11E98 JUMP LOCATION LONG
    Module_Victory:
    {
        ; Beginning of Module 0x16 (refilling stats after boss fight)
        
        LDA $11 : ASL A : TAX
        
        JSR (.states, X)
        
        JSL Sprite_Main
        JML PlayerOam_Main
    }

; ==============================================================================

    ; $11E99
    ????_easyOut:
    {
        RTS
    }
    
    ; *$11E9A-$11EC9 LOCAL
    {
        DEC $13 : BNE BRANCH_$11E99 ; (RTS)
        
        REP #$20
        
        STZ $011A : STZ $011C : STZ $30
        
        SEP #$20
        
        STZ $02E4
        
        JSL Palette_RevertTranslucencySwap
        
        LDA.b #$00 : STA $5D
        
        STZ $02D8 : STZ $02DA : STZ $037B
        
        LDA $010C : STA $10
        
        STZ $11 : STZ $B0
        
        JMP $9A37 ; $11A37 IN ROM
    }

; ==============================================================================

    incsrc "module_ganon_emerges.asm"

; ==============================================================================

    ; $11FCE-$11FEB Jump Table
    pool Module_TriforceRoom:
    {
    
    .submodules
        dw TriforceRoom_Step0 ; = $12021*
        dw TriforceRoom_Step1 ; = $1202F*
        dw TriforceRoom_Step2 ; = $12035*
        dw TriforceRoom_Step3 ; = $12065*
        dw TriforceRoom_Step4 ; = $12089*
        dw TriforceRoom_Step5 ; = $120CD*
        dw TriforceRoom_Step6 ; = $120E4*
        dw TriforceRoom_Step7 ; = $12100*
        dw $A137 ; = $12137*
        dw TriforceRoom_Step9 ; = $12121*
        dw $A137 ; = $12137*
        dw TriforceRoom_Step11 ; = $12151*
        dw TriforceRoom_Step12 ; = $12164*
        dw TriforceRoom_Step13 ; = $12173*
        dw TriforceRoom_Step14 ; = $12186*
    }

; ==============================================================================

    ; *$11FEC-$12020 JUMP LOCATION LONG
    Module_TriforceRoom:
    {
        LDA $B0 : ASL A : TAX
        
        JSR (.submodules, X)
        
        REP #$20
        
        LDA $E0 : STA $0120
        
        LDA $E6 : STA $0124
        
        LDA $E2 : STA $011E
        
        LDA $E8 : STA $0122
        
        SEP #$20
        
        LDA $B0 : CMP.b #$07 : BCC BRANCH_ALPHA
                  CMP.b #$0B : BCC BRANCH_BETA
    
    BRANCH_ALPHA:
    
        JSL $07E245 ; $3E245 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
    
    BRANCH_BETA:
    
        JML PlayerOam_Main
    }

; ==============================================================================

    ; *$12021-$1202E LOCAL
    TriforceRoom_Step0:
    {
        JSL Player_ResetState
        
        STZ $66
        
        ; Make music fade out.
        LDA.b #$F1 : STA $012C
        
        JMP $8CA9 ; $10CA9 IN ROM
    }

    ; *$1202F-$12034 LOCAL
    TriforceRoom_Step1:
    {
        JSR Overworld_ResetMosaic
        JMP $A2A0 ; $122A0 IN ROM
    }

    ; *$12035-$12064 LOCAL
    TriforceRoom_Step2:
    {
        JSL EnableForceBlank ; $93D IN ROM
        
        SEI
        
        ; disable NMI, IRQ, and automatic joypad reads
        STZ $4200
        
        LDA.b #$FF : STA $2140
        
        JSL Sound_LoadEndingSongBank
        
        ; reenable NMI and automatic joypad reads
        LDA.b #$81 : STA $4200
        
        ; Set exit identifier to 0x0189 (special area, probably)
        LDA.b #$89 : STA $A0
        LDA.b #$01 : STA $A1
        
        JSL Vram_EraseTilemaps.normal
        JSL Palette_RevertTranslucencySwap
        JSR $E851   ; $16851 IN ROM
        JSR $AF1E   ; $12F1E IN ROM
        
        INC $B0
        
        BRA BRANCH_$120C6
    }

    ; *$12065-$12088 LOCAL
    TriforceRoom_Step3:
    {
        ; Module 0x19.0x03
    
        LDA.b #$24 : STA $0AA1
        LDA.b #$7D : STA $0AA3
        LDA.b #$51 : STA $0AA2
        
        JSL InitTilesets ; $619B IN ROM
        
        LDX.b #$04
        
        JSR $C6AD   ; $146AD IN ROM
        
        LDA.b #$0E
        
        JSL Overworld_LoadPalettes ; $755A8 IN ROM
        JSR $C6EB                  ; $146EB IN ROM
        
        INC $B0
        
        RTS
    }

    ; *$12089-$120CC LOCAL
    TriforceRoom_Step4:
    {
        LDA $B0 : PHA
        
        JSR $EDB9 ; $16DB9 IN ROM
        
        PLA : INC A : STA $B0
        
        LDA.b #$0F : STA $13
        
        LDA.b #$1F : STA $7EC007
        LDA.b #$00 : STA $7EC00B
        
        LDA.b #$01 : STA $E1
        
        LDA.b #$02 : STA $99
        LDA.b #$32 : STA $9A
        
        LDA.b #$F0 : STA $7EC011
        
        LDA.b #$EC : STA $20
        LDA.b #$78 : STA $22
        
        LDA.b #$02 : STA $EE
        
        LDA.b #$20 : STA $012C
    
    ; *$120C6 ALTERNATE ENTRY POINT
    
        LDA.b #$19 : STA $10
        
        STZ $11
        
        RTS
    }

    ; *$120CD-$120E3 LOCAL
    TriforceRoom_Step5:
    {
        LDA.b #$08 : STA $67 : STA $26
        
        STZ $2F
        
        LDA $20 : CMP.b #$C0 : BCS .alpha
        
        STZ $67
        STZ $26
        STZ $2E
        
        INC $B0
    
    .alpha
    
        RTS
    }

    ; *$120E4-$120FF LOCAL
    TriforceRoom_Step6:
    {
        LDA $7EC007 : LSR A : BCS BRANCH_ALPHA
        
        LDA $7EC011 : BEQ BRANCH_ALPHA
        
        SUB.b #$10 : STA $7EC011
    
    BRANCH_ALPHA:
    
        JSR $C2F6                       ; $142F6 IN ROM
        JSL PaletteFilter.doFiltering
        
        RTS
    }

    ; *$12100-$12120 LOCAL
    TriforceRoom_Step7:
    {
        JSL $0CCA54 ; $64A54 IN ROM
        
        REP #$20
        
        LDA.w #$0173 : STA $1CF0
        
        SEP #$20
        
        JSL Main_ShowTextMessage
        JSL Messaging_Text
        
        LDA.b #$80 : STA $C8
        LDA.b #$19 : STA $10
        
        INC $B0
        
        RTS
    }

    ; *$12121-$12136 LOCAL
    TriforceRoom_Step9:
    {
        JSL $0CCAB1 ; $64AB1 IN ROM
        JSL Messaging_Text
        
        LDA $11 : BNE .waitForTextToEnd
        
        STZ $0200
        
        LDA.b #$19 : STA $10
        
        INC $B0
    
    .waitForTextToEnd
    
        RTS
    }

    ; *$12137-$12150 LOCAL
    {
        JSL $0CCAB1 ; $64AB1 IN ROM
        
        LDA $B0 : CMP.b #$0B : BNE BRANCH_ALPHA
        
        LDA.b #$21 : STA $012C
        
        LDA.b #$19 : STA $10
        
        STZ $67
        STZ $26
        
        INC $11
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$12151-$12163 LOCAL
    TriforceRoom_Step11:
    {
        JSL $0CCAB1 ; $64AB1 IN ROM
        JSL Player_ApproachTriforce
        
        LDA $B0 : CMP.b #$0C : BNE .alpha
        
        STZ $67
        STZ $26
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$12164-$12172 LOCAL
    TriforceRoom_Step12:
    {
        ; submodule ??? of triforce room scene (fades screen to white after a time)
        
        JSL $0CCAB1 ; $64AB1 IN ROM
        
        DEC $C8 : BNE .alpha
        
        JSL $0EF404 ; $77404 IN ROM
        
        INC $11
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$12173-$12185 LOCAL
    TriforceRoom_Step13:
    {
        ; totally brighten the screen (manipulate almost all palettes to be fully white)
        JSL $0CCAB1 ; $64AB1 IN ROM
        JSL $00EF8A ; $6F8A IN ROM
        
        LDA $7EC009 : CMP.b #$FF : BNE .alpha
        
        INC $B0
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$12186-$121A3 LOCAL
    TriforceRoom_Step14:
    {
        ; make the screen dark and transition to the ending sequence module
        DEC $13 : BNE .continue_darkening
        
        LDA.b #$1A : STA $10
        
        STZ $11
        STZ $B0
        
        LDA.b #$FF : STA $0128
        
        STZ $012A
        STZ $1F0C
        
        LDA.b #$00 : STA $7EF3CA
    
    .continue_darkening
    
        RTS
    }

; ==============================================================================

    ; \note Crystals and pendant bitfiels indicating status.
    ; $121A4-$121B0
    pool MilestoneItem_Flags:
    {
        db $00, $00, $04, $02, $00, $10, $02, $01
        db $40, $04, $01, $20, $08
    }

; ==============================================================================

    ; *$121B1-$121E4 LONG
    Dungeon_SaveRoomData:
    {
        LDA $040C : CMP.b #$FF : BEQ .notInPalace
        
        LDA.b #$19 : STA $11
        
        STZ $B0
        
        LDA.b #$33 : STA $012E
        
        JSL Dungeon_SaveRoomQuadrantData
    
    ; *$121C7 ALTERNATE ENTRY POINT
    .justKeys
    
        ; branch if in a non palace interior.
        LDA $040C : CMP.b #$FF : BEQ .return
        
        ; Is it the Sewer?
        CMP.b #$02 : BNE .notSewer
        
        ; If it's the sewer, put them in the same slot as Hyrule Castles's. annoying :p
        LDA.b #$00
    
    .notSewer
    
        LSR A : TAX
        
        ; Load our current count of keys for this dungeon.
        ; Save it to an appropriate slot.
        LDA $7EF36F : STA $7EF37C, X
    
    .return
    
        RTL
    
    .notInPalace
    
        ; Play the error sound effect
        LDA.b #$3C : STA $012E
        
        RTL
    }

; ==============================================================================

    ; $121E5-$121E8 DATA
    {
        ; \task Name this pool / apply to routines that use it.
        db 31,  8,  4,  0
    }

; ==============================================================================

    ; *$121E9-$12280 LOCAL
    {
        LDA $0ABD : BEQ .no_swap
        
        JSL Palette_RevertTranslucencySwap
    
    .no_swap
    
        LDA.b #$02 : STA $99
        LDA.b #$B3 : STA $9A
        
        LDX $045A
        
        LDA $7EC005 : BNE .darkTransition
        
        LDA.b #$20
        LDX.b #$03
        
        LDY $0414 : BEQ .setColorMath
        
        LDA.b #$32
        
        CPY.b #$07 : BEQ .setColorMath
        
        LDA.b #$62
        
        CPY.b #$04 : BEQ .setColorMath
        
        LDA.b #$20
        
        CPY.b #$02 : BNE .setColorMath
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        
        PLX
        
        LDA $A0 : CMP.b #$0D : BNE .notAgahnim2
        
        REP #$20
        
        LDA.w #$0000
        
        STA $7EC019 : STA $7EC01B : STA $7EC01D
        STA $7EC01F : STA $7EC021 : STA $7EC023
        
        SEP #$20
        
        JSL Palette_AgahnimClones
    
    .notAgahnim2
    
        LDA.b #$70
    
    .setColorMath
    
        STA $9A
    
    .darkTransition
    
        LDA $02A1E5, X : STA $7EC017
        
        LDA.b #$1F : STA $7EC007
        LDA.b #$00 : STA $7EC00B
        LDA.b #$02 : STA $7EC009
        
        STZ $0AA9
        
        JSL Palette_DungBgMain
        JSL Palette_SpriteAux3
        JSL Palette_SpriteAux1
        JSL Palette_SpriteAux2
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; *$12281-$1229A LOCAL
    {
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : BNE .stillFiltering
        
        ; turn off the dark transition
        LDA.b #$00 : STA $7EC005
        
        LDA $010C : STA $10
        
        STZ $B0 : STZ $11
    
    .stillFiltering
    
        RTS
    }

; ==============================================================================

    ; *$1229B-$1229F LOCAL
    HoleToDungeon_PaletteFilter:
    {
        JSL PaletteFilter
        
        RTS
    }

; ==============================================================================

    ; $122A0-$122A4 JUMP LOCATION
    {
        JSL PaletteFilter.doFiltering
        
        RTS
    }

; ==============================================================================

    ; *$122A5-$122A8 JUMP LOCATION LONG
    {
        JSR $8CA9 ; $10CA9 IN ROM

        RTL
    }

; ==============================================================================

    ; *$122A9-$122AC JUMP LOCATION LONG
    {
        ; only known reference is from a seemingly unused submodule of module 0x0E (submodule 0x06)
        
        JSR $A1E9 ; $121E9 IN ROM
        
        RTL
    }

    ; *$122AD-$122B0 JUMP LOCATION LONG
    {
        JSR $A281 ; $12281 IN ROM

        RTL
    }

    ; *$122F0-$1237B LOCAL
    {
        LDA $A2 : AND.b #$0F : STA $00
        
        ; $00 = ( (prev_room & 0x0F) - (current_room & 0x0F) ) << 1
        LDA $A0 : AND.b #$0F : SUB $00 : ASL A : STA $00
            
        LDA $23 : ADD $00 : STA $23
        
        LDA $E3 : ADD $00 : STA $E3
        
        LDA $060D : ADD $00 : STA $060D
        LDA $060F : ADD $00 : STA $060F
        LDA $0609 : ADD $00 : STA $0609
        LDA $060B : ADD $00 : STA $060B
        
        LDA $A2 : AND.b #$F0 : LSR #3 : STA $00
        LDA $A0 : AND.b #$F0 : LSR #3 : STA $01
        
        SUB $00 : STA $00
        
        LDA $21 : ADD $00 : STA $21
        
        LDA $E9 : ADD $00 : STA $E9
        
        LDA $0605 : ADD $00 : STA $0605
        LDA $0607 : ADD $00 : STA $0607
        LDA $0601 : ADD $00 : STA $0601
        LDA $0603 : ADD $00 : STA $0603
        
        RTS
    }

    ; *$1237C-$1240C LOCAL
    Dungeon_AdjustCoordsForLinkedRoom:
    {
        ; Y indicates the X direction we're moving in (-1 - left, 1 - right)
        ; A is (new room number - 1)
        
        ; It seems like this attempts to find the difference in X and Y
        ; coordinates between the source room and the target room and adjust
        ; the high bytes of the X and Y coordinates accordingly. Whether it's
        ; 100% sound logic, I'm not sure.
        
        STY $00
        
        STA $048E : STA $A2
        
        LDA $A2 : AND.b #$0F : ASL A : SUB $23 : ADD $00 : STA $00
        
        LDA $23 : ADD $00 : STA $23
        
        LDA $E3 : ADD $00 : STA $E3
        
        LDA $060D : ADD $00 : STA $060D
        LDA $060F : ADD $00 : STA $060F
        LDA $0609 : ADD $00 : STA $0609
        LDA $060B : ADD $00 : STA $060B
        
        LDA $A2 : AND.b #$F0 : LSR #3 : SUB $21 : STA $00
        
        LDA $21 : ADD $00 : STA $21
        
        LDA $E9 : ADD $00 : STA $E9
        
        LDA $0605 : ADD $00 : STA $0605
        LDA $0607 : ADD $00 : STA $0607
        LDA $0601 : ADD $00 : STA $0601
        LDA $0603 : ADD $00 : STA $0603
        
        LDY.b #$00
    
    .updateTagalong_y_coord
    
        LDA $21 : STA $1A14, Y
        
        INY : CPY.b #$14 : BNE .updateTagalong_y_coord
        
        RTS
    }

    ; $1240D-$1246C JUMP TABLE FOR MODULE 0x09
    pool Module_Overworld:
    {
        ; (Indexed by $11)
    
    .submodules
        dw $A53C ; = $1253C*  ; 0:
        dw Overworld_LoadTransGfx               ; 1: AB88 = $12B88* ; 1 through 8 seem to be screen transitioning.
        dw Overworld_FinishTransGfx             ; ; 0x02 - Blits the remainder of the bg / spr graphics to vram
        dw Overworld_TransMapData               ; 3: ABC6 = $12BC6* ; Loads map32 data, converts it to map16 and map8, along with event overlay
        dw Overworld_TransMapData2              ; 4: ABED = $12BED* ; 
        dw Overworld_TransMapData2_justScroll   ; 5: AC27 = $12C27*
        dw $ABDA ; = $12BDA* ; 6:     
        dw $AC3A ; = $12C3A* ; 7:     ????
        
        dw $C242 ; = $14242* ; 8:     referenced in relation to bombs
        dw $AD4A ; = $12D4A* ; 9:     exiting a fancy door mode?
        dw $AC8F ; = $12C8F* ; A:     Positioning Link after coming out a door.
        dw $ACC2 ; = $12CC2*   B:     
        dw $AC6C ; = $12D6C* ; C:     submodule for opening fancy doors
        dw $AE5E ; = $12E5E* ; D:     getting into a forest submodule (areas 0x40 or 0x00)
        dw $AF19 ; = $12F19* ; E:     
        dw Overworld_LoadTransGfx   ; 0x0F - AB88 = $12B88*
        
        dw Overworld_FinishTransGfx             ; 0x10 - referenced in relation to bombs
        dw Overworld_TransMapData               ; 0x11 - ABC6 = $12BC6*
        dw Overworld_TransMapData2              ; 0x12 - ABED = $12BED* ; ???
        dw Overworld_TransMapData2.justScroll   ; 0x13 - AC27 = $12C27*
        dw $ABDA ; = $12BDA*              ; 0x14 - 
        dw $AC3A ; = $12C3A*              ; 0x15 - 
        dw $B0D2 ; = $130D2*              ; 0x16 - 
        dw $AE5E ; = $12E5E*              ; 0x17 - #$17 - #$1C occurs entering Master Sword area.
        
        dw $B1C8 ; = $131C8*              ; 0x18 - Load exit data and palettes for special areas?
        dw $B1DF ; = $131DF*              ; 0x19 - Loads map data for module B?
        dw Overworld_LoadTransGfx         ; 0x1A - AB88 = $12B88* ; Starts loading new graphics on a module B scrolling transition
        dw Overworld_FinishTransGfx       ; 0x1B - Finishes loading new graphics
        dw $B150 ; = $13150*              ; 0x1C -   
        dw $AECE ; = $12ECE*              ; 0x1D - 
        dw $AEEA ; = $12EEA*              ; 0x1E - 
        dw $C2A4 ; = $142A4*              ; 0x1F - Coming out of Lost woods
        
        dw $AF1E ; = $12F1E*              ; 0x20 - Coming back from Overworld Map.... reloads subscreen overlay to wram?
        dw Overworld_LoadAmbientOverlay   ; 0x21 - Coming back from Overworld Map.... sends command to reupload subscreen overlay to vram?
        dw $B1BB ; = $131BB*              ; 0x22 - Brightens screen
        dw Overworld_MirrorWarp           ; 0x23 - Magic Mirror routine (normal warp between worlds)
        dw $AE5E ; = $12E5E*              ; 0x24 – Also part of magic mirror stuff?
        dw $AF0B ; = $12F0B*              ; 0x25 – Occurs leaving Master Sword area
        dw Overworld_LoadTransGfx         ; 0x26 - AB88 = $12B88*
        dw Overworld_FinishTransGfx       ; 0x27 - 
        dw Overworld_LoadAmbientOverlayAndMapData ; 0x28 -    
        
        dw $B0D2 ; = $130D2*              ; 0x29 -
        dw $B528 ; = $13528*              ; 0x2A -
        dw $B40A ; = $1340A*              ; 0x2B - Retrieving the master sword from its pedestal
        dw Overworld_MirrorWarp           ; 0x2C - Magic Mirror routine (warping back from a failed warp)
        dw Overworld_WeathervaneExplosion ; 0x2D - Used for breaking open the weather vane. (RTS!)
        dw $B40F ; = $1340F*              ; 0x2E - 0x2E and 0x2F are used for the whirlpool teleporters
        dw $B521 ; = $13521*              ; 0x2F - Is jumped to from the previous submodule 
    }

    ; $1246D - $12474 DATA 
    {
        dw $0001
        dw $0001
        dw $1100
        dw $1100    
    }

    ; *$12475-$1252C Jump Location
    Module_Overworld:
    {
        ; Module 0x09
        ; Beginning of Module 9 and Module B: Overworld Module
        
        REP #$30
        
        ; Submodule index
        LDA $11 : ASL A : TAX
        
        JSR (.submodules, X)
        
        REP #$21
        
        LDA $E2 : PHA : ADC $011A : STA $E2 : STA $011E
        LDA $E8 : PHA : ADD $011C : STA $E8 : STA $0122
        LDA $E0 : PHA : ADD $011A : STA $E0 : STA $0120
        LDA $E6 : PHA : ADD $011C : STA $E6 : STA $0124
        
        SEP #$20
        
        JSL Sprite_Main
        
        REP #$20
        
        PLA : STA $E6
        PLA : STA $E0
        PLA : STA $E8
        PLA : STA $E2
        
        SEP #$20
        
        JSL PlayerOam_Main
        JSL HUD.RefillLogicLong
    
    ; *$124CD ALTERNATE ENTRY POINT
    
        LDA $8A : CMP.b #$70 : BEQ .evilSwamp
        
        ; Check the progress indicator
        LDA $7EF3C5 : CMP.b #$02 : BCS .skipMovement
    
    .evilSwamp
    
        ; If misery mire has been opened already, we’re done
        LDA $7EF2F0 : AND.b #$20 : BNE .skipMovement
        
        ; Check the frame counter.
        ; On the third frame do a flash of lightning.
        LDA $1A
        
        CMP.b #$03 : BEQ .lightning
        CMP.b #$05 : BEQ .normalLight
        CMP.b #$24 : BEQ .thunder     ; On the 0x24th frame, cue the thunder.
        CMP.b #$2C : BEQ .normalLight ; On the 0x2Cth frame, normal light level.
        CMP.b #$58 : BEQ .lightning   ; On the 0x58th frame, cue the lightning
        CMP.b #$5A : BNE .moveOverlay ; On the 0x5Ath frame, normal light level.
    
    .normalLight
    
        ; Keep the screen semi-dark.
        LDA.b #$72
        
        BRA .setBrightness
    
    .thunder
    
        ; Play the thunder sound when outdoors.
        LDX.b #$36 : STX $012E
    
    .lightning
    
        LDA.b #$32 ; Make the screen flash with lightning.
    
    .setBrightness
    
        STA $9A
    
    .moveOverlay
    
        ; Overlay is only moved every 4th frame.
        LDA $1A : AND.b #$03 : BNE .skipMovement
        
        LDA $0494 : INC A : AND.b #$03 : STA $0494 : TAX
        
        LDA $E1 : ADD.l $02A46D, X : STA $E1
        LDA $E7 : ADD.l $02A471, X : STA $E7
    
    .skipMovement
    
        RTL
    }

; $1252D-$1253B DATA (unused?)

; ==============================================================================

    ; *$1253C-$125EB JUMP LOCATION
    {
        ; main overworld submodule
        ; Module 0x09.0x00, Module 0x0B.0x00
    
        LDA $0121 : ORA $02E4                         ; stop everything flag.
                    ORA $0FFC                         ; Link's can't bring up menu flag
                    ORA $04C6 : BEQ .checkButtonInput ; special animation trigger
        
        JMP .skipButtonInput
    
    .checkButtonInput
    
        ; Check the start button
        LDA $F4 : AND.b #$10 : BEQ .startButtonNotDown
        
        STZ $0200
        
        LDA.b #$01
        
        BRA .changeSubmodule    ; Go to menu submodule of module 0x0E
        
    .startButtonNotDown
        
        ; AXLR----
        LDA $F6 : AND.b #$40 : BEQ .xButtonNotDown
        
        STZ $0200
        
        ; Go to map submodule of module 0x0E
        LDA.b #$07
    
    .changeSubmodule
    
        STA $11
        
        LDA $10 : STA $010C
        
        LDA.b #$0E : STA $10
        
        RTS
        
    .xButtonNotDown
    
        ; Check unfiltered output for "select" button
        LDA $F0 : AND.b #$20 : BEQ .selectButtonNotDown
        
        LDA $1CE8 : STA $1CF4
        
        REP #$20
        
        LDA.w #$0186 : STA $1CF0
        
        SEP #$20
        
        LDA $10 : PHA
        
        JSL Main_ShowTextMessage
        
        ; Indicates that above Subroutine may have altered play mode
        PLA : STA $10
        
        STZ $B0
        
        LDA.b #$0B
        
        BRA .changeSubmodule
    
    ; *$12597 ALTERNATE ENTRY POINT
    .selectButtonNotDown
    .skipButtonInput
    
        ; Is there a special animation to do?
        LDA $04C6 : BEQ .noEntranceAnimation
        
        JSL Overworld_EntranceSequence
    
    .noEntranceAnimation
    
        SEP #$30
        
        JSL Player_Main
        
        LDA $04B4 : CMP.b #$FF : BEQ .noSuperBombIndicator
        
        JSL $0AFDA8 ; $57DA8 IN ROM ; Handles Super bomb countdown indicator on HUD
    
    .noSuperBombIndicator
    
        REP #$20
        
        LDA $20 : AND.w #$1E00 : ASL #3                : STA $0700
        LDA $22 : AND.w #$1E00 : ORA $0700 : XBA       : STA $0700
        
        SEP #$20
        
        JSL Graphics_LoadChrHalfSlot
        JSR $BB90   ; $13B90 IN ROM
        
        ; If special outdoors mode skip this part
        LDA $10 : CMP.b #$0B : BEQ .specialOverworld
        
        JSL Overworld_Entrance
        JSL Overworld_DwDeathMountainPaletteAnimation
        JSR $A9C4   ; $129C4 IN ROM
        
        BRA .return
    
    .specialOverworld
    
        JSR $AB7B   ; $12B7B IN ROM
    
    .return
    
        SEP #$20
        
        RTL
    }

; =============================================

    ; *$129C4-$12B07 LOCAL
    {
        ; Tells us which direction we're scrolling in
        LDA $0416 : BEQ .noScroll
        
        JSR Overworld_ScrollMap     ; $17273 IN ROM
    
    .noScroll
    
        REP #$20
        
        LDA $30 : AND.w #$00FF : BEQ .noDeltaY
        
        ; check if link is moving up/down
        LDA $67 : AND.w #$000C : STA $00
        
        LDX $0700 : LDA $20 : SUB $02A8C4, X
        
        LDY.b #$06 : LDX.b #$08
        
        CMP.w #$0004 : BCC BRANCH_GAMMA
        
        LDY.b #$04 : LDX.b #$04
        
        CMP $0716 : BCS BRANCH_GAMMA
    
    .noDeltaY
    
        LDA $31 : AND.w #$00FF : BEQ .noDeltaX
        
        LDA $0716 : ADD.w #$0004 : STA $02
        
        LDA $67 : AND.w #$0003 : STA $00
        
        LDX $0700 : LDA $22 : SUB $02A944, X
        
        LDY.b #$02 : LDX.b #$02 : CMP.w #$0006 : BCC BRANCH_GAMMA
        
        LDY.b #$00 : LDX.b #$01 : CMP $02 : BCC BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        CPX $00 : BEQ BRANCH_EPSILON
    
    BRANCH_DELTA:
    .noDeltaX
    
        JSL $0EDE49 ; $75E49 IN ROM

        RTS

    BRANCH_EPSILON: ; triggers when Link finally reaches the edge of the screen.

        SEP #$20
        
        ; just makes sure we're not using a medallion or input is disabled
        JSL Player_IsScreenTransitionPermitted : BCS BRANCH_DELTA
        
        STY $02 : STZ $03
        
        JSR $8B0C ; $10B0C IN ROM
        
        REP #$31
        
        LDX $02 : LDA $84 : AND $02A62C, X : STA $84
        
        LDA $0700 : ADD $02A834, X : PHA : STA $04
        
        TXA : ASL #6 : ORA $04 : TAX
        
        LDA $84 : ADD $02A634, X : STA $84
        
        PLA : LSR A : TAX
        
        SEP #$30
        
        LDA $8A : PHA : CMP.b #$2A : BNE .notFluteBoyGrove
        
        LDA.b #$80 : STA $012D    ; Flute boy area has special flute sound effect (surprise?)
    
    .notFluteBoyGrove
    
        ; sets the OW area number
        LDA $02A5EC, X : ORA $7EF3CA : STA $8A : STA $040A : TAX
        
        LDA $7EF3CA : BEQ .lightWorld
        
        ; Check for moon pearl
        LDA $7EF357 : BEQ BRANCH_IOTA
    
    .lightWorld
    
        ; Extract the ambient sound from this array
        LDA $7F5B00, X : LSR #4 : BNE .ambientSound
        
        LDA.b #$05 : STA $012D ; No ambient sound
    
    .ambientSound
    
        LDA $7F5B00, X : AND.b #$0F : CMP $0130 : BEQ .noMusicChange
        
        LDA.b #$F1 : STA $012C
    
    .noMusicChange
    
        JSR Overworld_LoadMapProperties
        
        LDA.b #$01 : STA $11
        
        LDA $00 : STA $0410 : STA $0416
        
        LDX.b #$04
    
    BRANCH_LAMBDA:
    
        DEX : LSR A : BCC BRANCH_LAMBDA
        
        STX $0418 : STX $069C : STZ $0696 : STZ $0698 : STZ $0126
        
        PLA : AND.b #$3F : BEQ BRANCH_MU ; um...
        
        ; um...
        LDA $8A : AND.b #$BF : BNE BRANCH_NU
    
    BRANCH_MU:
    
        ; probably only for areas 0x00 and 0x40
        
        STZ $B0
        
        ; Send us to a submodule that will handle going into a forest
        LDA.b #$0D : STA $11
        
        ; Reset mosaic settings
        LDA.b #$00 : STA $95 : STA $7EC011
        
        RTS
    
    BRANCH_NU:
    
        LDX $8A : LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes      ; $755A8 IN ROM
        JSR Overworld_CgramAuxToMain
        
        RTS
    }
    
; =============================================

    ; $12B08-$12B7A LOCAL
    Overworld_LoadMapProperties:
    {
        LDX $8A
        
        ; Reset the incremental counter for updating VRAM from frame to frame
        STZ $0412
        
        ; This array was loaded up based on the world state variable ($7EF3C5)
        ; It contains 0x40 entries (disputed)
        ; $0AA3 is the sprite graphics index
        LDA $7EFCC0, X : STA $0AA3
        
        ; $0AA2 is the secondary background graphics index
        LDA $00FC9C, X : STA $0AA2
        
        ; Overworld screen widths and heights match for DW and LW    
        TXA : AND.b #$3F : TAX
        
        ; cache previous dimension setting in $0714    
        LDA $0712 : STA $0714
        
        ; sets width and height of the OW area (512x512 or 1024x1024)
        LDA $02A844, X : STA $0712
        LDA $02A884, X : STA $0717
        
        LDY.b #$20 : LDX.b #$00
        
        LDA $8A : AND.b #$40 : BEQ .lightWorld
        
        ; $0AA1 = 0x21 for dark world, 0x20 for light world.
        INY 
        
        ; $0AA4 = 0x08 for dark world, 0x00 for light world.
        LDX.b #$08
    
    .lightWorld
    
        STY $0AA1 
        
        ; $0AA4 = 0x01 in LW, 0x0B in DW    
        LDA $00D8F4, X : STA $0AA4
        
        REP #$30
        
        ; This is misleading as the subsequent arrays are only 0x80 bytes
        LDA $8A : AND.w #$00BF : ASL A : TAX
        
        LDA $02A8C4, X : STA $0708
        
        LDA $02A944, X : LSR #3 : STA $070C
        
        LDA.w #$03F0 : LDX $0712 : BNE .largeOwMap
        
        LDA.w #$01F0    ; the 512x512 maps have smaller limits of course
    
    .largeOwMap
    
        STA $070A : LSR #3 : STA $070E
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$12B7B-$12B87 LOCAL
    {
        LDA $0416 : BEQ .alpha
        
        JSR Overworld_ScrollMap
    
    .alpha
    
        ; Checks for tiles that lead back to normal overworld
        JSL $0EDEE3 ; $75EE3 IN ROM
        
        RTS
    }

; ==============================================================================

    ; $12B88-$12BC5 JUMP LOCATION
    Overworld_LoadTransGfx:
    {
        ; Module 0x09.0x01, 0x09.0x0F, 0x09.0x1A, 0x09.0x26
        ; Also referenced one other place
        
        ; Reset the water outside the watergate.
        LDA $7EF2BB : AND.b #$DF : STA $7EF2BB
        
        ; Reset the water outside the swamp palace.        
        LDA $7EF2FB : AND.b #$DF : STA $7EF2FB
        
        ; Reset the water inside the watergate.
        LDA $7EF216 : AND.b #$7F : STA $7EF216
        
        ; Reset the water inside the swamp palace.
        LDA $7EF051 : AND.b #$FE : STA $7EF051
        
        ; $566E IN ROM. Load the graphics that have changed during the screen transition.
        JSL LoadTransAuxGfx
        
        ; $5F1A IN ROM. Convert those graphics to 4bpp while copying them into the buffer starting at $7F0000
        ; It's necessary to do it this way because we can't blank the screen (no screen fade / darkness)
        JSL PrepTransAuxGfx
        
        LDA.b #$09
        
        BRA Overworld_FinishTransGfx_firstHalf
    }

; ==============================================================================

    ; $12BBC ALTERNATE ENTRY POINT
    Overworld_FinishTransGfx:
    {
        ; Module 0x09.0x02, 0x09.0x10, 0x09.0x1B, 0x09.0x27
        ; Also referenced one other place
        
        ; The purpose of this submodule is to finish blitting the rest of the graphics
        ; That were decompressed in the previous module to vram (from the $7F0000 buffer)
        
        LDA.b #$0A
    
    .firstHalf
    
        ; Signal for a graphics transfer in the NMI routine later        
        STA $17 : STA $0710
        
        ; Move on to next submodule
        INC $11
        
        RTS
    }

; ==============================================================================

    ; *$12BC6-$12BD9 LOCAL
    Overworld_TransMapData:
    {
        ; Module 0x09.0x03, 0x09.0x11
        
        ; unknown variables
        STZ $04C8 : STZ $04C9
        
        JSR Overworld_LoadTransMapData
        
        INC $0710
        
        ; This mess all looks like it does map16 to map8 conversion, and the subsequent one sets up the 
        ; system to blit it to vram during the next vblank
        ; $17031 IN ROM        
        JSR Overworld_StartTransMapUpdate
        
        ; $6031 IN ROM
        JSL $00E031
        
        RTL
    }

    ; *$12BDA - $12BEC LOCAL JUMPED
    {
        
        JSL $07E6A6 ; $3E6A6 IN ROM
        JSL Graphics_IncrementalVramUpload
        JSR $C001   ; $14001 IN ROM
        
        AND.b #$0F : BEQ .alpha
        
        RTS

    .alpha

        JMP $AC30 ; $12C30
    }

; =============================================

    ; *$12BED - $12C39 JUMP LOCATION
    Overworld_TransMapData2:
    {
        ; Module 0x09.0x04, 0x09.0x12
        
        LDA $0418 : CMP.b #$01 : BNE .notDownTransitiion
        
        REP #$20
        
        ; Move down 2 pixels if transitioning down
        ; Why this is a special case... I don't quite get
        LDA $E8 : ADD.w #$0002 : STA $E8
        LDA $20 : ADD.w #$0002 : STA $20
        
        SEP #$20
    
    .notDownTransition
    
        JSL Sprite_OverworldReloadAll_justLoad  ; $4C49D IN ROM
        
        ; Reset tile modification index (keeps track of modified tiles when warping between worlds)
        STZ $04AC : STZ $04AD
        
        LDA $7EF3C5 : CMP.b #$02 : BCS .rescuedZeldaOnce
    
    .specialTransition
    
        JMP .skipBgColor
    
    .rescuedZeldaOnce
    
        LDA $11 : CMP.b #$12 : BEQ .specialTransition
        
        ; load bg color and other shit
        JSL $0BFE70 ; $5FE70 IN ROM
    
    ; *$12C27 ALTERNATE ENTRY POINT
    .justScroll
    .skipBgColor
        
        INC $11
        
        ; Horizontal transitions apparently don't do this step...
        LDX $0410 : CPX.b #$04 : BCC .notVerticalTrans
    
    ; *$12C30 ALTERNATE ENTRY POINT
    .alwaysScroll
        
        STX $0416
        
        JSR $F20E ; $1720E IN ROM
        
        STZ $0416
    
    .notVerticalTans
    
        RTS
    }

; =============================================

    ; *$12C3A - $12C8E LOCAL JUMPED
    {

        LDX $8A
        
        LDA $02F88D, X : BEQ .largeArea
        
        LDX $0410 : STX $0416
        
        JSR $F20E ; $1720E IN ROM
        
        STZ $0416
    
    .largeArea
    
        ; $B0 is used as an index counter.
        INC $B0 : LDA $B0 : CMP.b #$08 : BCC .return
        
        LDX $0410 : CPX.b #$08 : BEQ .scrollUpOrLeft
        
        CPX.b #$02 : BNE .scrollDownOrRight
    
    .scrollUpOrLeft
    
        CPX.b #$09 : BCC .return
    
    .scrollDownOrRight
    
        STZ $B0
        STZ $0410
        
        LDX $8A
        
        LDA $02F88D, X : BEQ .largeArea2
        
        REP #$20
        
        LDA $7EC172 : STA $84
        LDA $7EC174 : STA $86
        LDA $7EC176 : STA $88
        
        SEP #$20
    
    .largeArea2
    
        INC $11
        
        JSL Tagalong_Disable ; $4ACF3 IN ROM
    
    .return
    
        RTS
    }

    ; *$12C8F-$12CC1 JUMP LOCATION
    {
        JSL $07E69D ; $3E69D IN ROM
        
        REP #$20
        
        LDA $20 : ADD.w #$0001 : STA $20
        
        SEP #$20
        
        DEC $069A : BNE .timedWait
        
        STZ $11
        
        REP #$20
        
        ; Move Link down by 3 pixels
        LDA $20 : ADD.w #$0003 : STA $20
        
        SEP #$20
        
        LDA.b #$03 : STA $30
        
        JSR $BB90 ; $13B90 IN ROM
        
        LDA $0416 : BEQ .noScroll
        
        JSR Overworld_ScrollMap     ; $17273 IN ROM
    
    .timedWait
    .noScroll
    
        RTS
    }

    ; *$12CC2-$12CD9 JUMP LOCATION
    {
        JSL $07E6A6    ; $3E6A6 IN ROM
        
        REP #$20
        
        LDA $20 : SUB.w #$0001 : STA $20
        
        SEP #$20
        
        DEC $069A : BNE BRANCH_ALPHA
        
        STZ $11
    
    BRANCH_ALPHA:
    
        RTS
    }

; $12CDA-$12D49 DATA

    ; *$12D4A-$12D5B JUMP LOCATION
    {
        LDA $0690 : CMP.b #$03 : BNE BRANCH_12D7B
        
        LDA.b #$24 : STA $069A
        
        STZ $0416
        
        INC $11
        
        RTS
    }

; ==============================================================================

    ; *$12D5C-$12D62 LONG
    Overworld_DoMapUpdate32x32_Long:
    {
        JSR Overworld_DoMapUpdate32x32
        
        STZ $0692
        
        RTL
    }

; ==============================================================================

    ; *$12D63-$12D6B LONG (UNUSED?)
    {
        REP #$30
        
        JSR $AD87   ; $12D87 IN ROM; Involved in picking up large rocks
        
        STZ $0692
        
        RTL
    }

    ; *$12D6C-$12E5D LOCAL
    {
        LDA $0690 : CMP.b #$03 : BNE BRANCH_ALPHA
        
        STZ $B0 : STZ $11 : STZ $0416
        
        RTS
    
    ; *$12D7B ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDA $0692 : AND.b #$07 : BEQ BRANCH_BETA
        
        JMP $AE5A   ; $12E5A IN ROM
    
    ; *$12D85 ALTERNATE ENTRY POINT
    shared Overworld_DoMapUpdate32x32:
    
    BRANCH_BETA:
    
        REP #$30
    
    ; *$12D87 ALTERNATE ENTRY POINT
    
        ; This appears to happen if you pick up a large rock
        ; (Or other map16 modifications like a place sanctuary door opening)
        
        PHB : PHK : PLB
        
        ; This is the starting address for the 2x2 (map16) replacement
        ; Store the address of the map16 modification
        LDA $0698 : LDX $04AC : STA $7EF800, X : TAX
        
        ; Load a map16 tile type based on this input and store it to the tile map.
        LDY $0692 : LDA $ACDA, Y : STA $7E2000, X
        
        ; Store the actual map16 value to our array for failed warps
        LDX $04AC : STA $7EFA00, X
        
        LDY.w #$0000 : LDX $0698
        
        JSL Overworld_DrawMap16_Anywhere
        
        LDA $0698 : LDX $04AC : INC #2 : STA $7EF802, X
        
        ; Load the next tile type.
        LDX $0698 : LDY $0692 : LDA $ACDC, Y : STA $7E2002, X ; Store it to the next location in the tilemap
        
        LDX $04AC : STA $7EFA02, X
        
        LDY.w #$0002 : LDX $0698
        
        JSL Overworld_DrawMap16_Anywhere
        
        LDA $0698 : LDX $04AC : ADD.w #$0080 : STA $7EF804, X
        
        ; Load the third tile (block?) type, and then store in a place to be blitted to VRAM.
        LDX $0698 : LDY $0692 : LDA $ACDE, Y : STA $7E2080, X
        
        LDX $04AC : STA $7EFA04, X
        
        LDY.w #$0080 : LDX $0698
        
        JSL Overworld_DrawMap16_Anywhere
        
        LDA $0698 : LDX $04AC : ADD.w ADC #$0082 : STA $7EF806, X
        
        LDX $0698 : LDY $0692 : LDA $ACE0, Y : STA $7E2082, X
        
        LDX $04AC : STA $7EFA06, X
        
        LDY.w #$0082 : LDX $0698
        
        JSL Overworld_DrawMap16_Anywhere
        
        LDY $1000 : LDA.w #$FFFF : STA $1002, X ; Put the finishing touches on the VRAM package that will be sent
        
        ; increment the modification index by 8 (indicates we replaced 4 tiles)
        LDA $04AC : ADD.w #$0008 : STA $04AC
        
        INC $0690
        
        LDA $0692 : CMP.w #$0020 : BNE BRANCH_ALPHA
        
        INC $0690

    BRANCH_ALPHA:
        
        PLB
        
        SEP #$30
        
        LDA.b #$01 : STA $14
    
    ; *$12E5A ALTERNATE ENTRY POINT
    
        INC $0692
        
        RTS
    }

    ; *$12E5E-$12E6C JUMP LOCATION
    {
        ; Modules 0x09.0x0D, 0x09.0x17, 0x09.0x24
        
        ; Set Mosaic level
        JSR Overworld_ResetMosaic
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $AE6D ; = $12E6D*
        dw $A2A0 ; perform color filtering ( darken the screen )
        dw $AE86 ; = $12E86*
    }
    
; =========================================

    ; $12E6D-$12E85 JUMP LOCATION
    {
        ; module 0x0B.0x24/0x17/0x0D.0x00
        
        ; check if it's the master sword area / area under bridge
        LDX $8A : CPX.b #$80 : BEQ .noFadeout
        
        ; Check if the currently playing music is the same as the target area
        LDA $7F5B00, X : AND.b #$0F : CMP $0130 : BEQ .noFadeout
        
        ; fade the music out if they differ
        LDA.b #$F1 : STA $012C
    
    .noFadeout
    
        ; do more basic common initialization of OW variables
        JMP $8CA9   ; $10CA9 IN ROM
    }

; =========================================
    
    ; *$12E86-$12ECD JUMP LOCATION
    {
        ; forceblank the screen
        LDA.b #$80 : STA $13
        
        STZ $B0
        
        ; forest areas are 0x00 and 0x40
        LDA $8A : AND.b #$3F : BNE .notForestArea
        
        LDA.b #$1E
        
        ; load animated graphics into WRAM
        JSL GetAnimatedSpriteTile.variable
    
    .notForestArea
    
        LDA $040A : BEQ .lostWoods
        
        ; check for special overworld areas
        LDA $10 : CMP.b #$0B : BEQ .lostWoods
        
        ; OBJ, BG2, and BG3 on main screen, BG1 on subscreen
        LDY.b #$16 : LDA.b #$01
        STY $1C    : STA $1D
        
        ; Set CGWSEL to clip colors to black "inside color window only" 
        ; and enabled subscreen addition (not fixed color.)
        LDA.b #$82 : STA $99
        
        ; add the subscreen only to the background, though
        LDA.b #$20 : STA $9A
        
        ; move to next submodule
        INC $11
        
        RTS
    
    .lostWoods
    
        LDA $11 : CMP.b #$24 : BNE BRANCH_GAMMA
        
        JSR $E9BC ; $169BC IN ROM
        
        LDA $8A : AND.b #$3F : BNE BRANCH_GAMMA
        
        LDA.b #$1E
        
        ; load a certain sprite into the animated tiles buffer
        JSL GetAnimatedSpriteTile.variable
    
    BRANCH_GAMMA:
    
        INC $11
        
        RTS
    }

    ; $12ECE-$12EDC JUMP LOCATION
    {
        JSR Overworld_ResetMosaic
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8CA9 ; = $10CA9*
        dw $A2A0 ; = $122A0*
        dw $AEDD ; = $12EDD*
    }

    ; *$12EDD-$12EE9 JUMP LOCATION 
    {
        LDA.b #$80 : STA $13 : STZ $B0
        
        LDA.b #$0A : STA $10 : STZ $11
        
        RTS
    }

    ; *$12EEA-$12EF8 JUMP LOCATION
    {
        JSR Overworld_ResetMosaic
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8CA9 ; = $10CA9*
        dw $A2A0 ; = $122A0*
        dw $AEF9 ; = $12EF9*
    }

    ; *$12EF9-$12F0A JUMP LOCATION
    {
        LDA.b #$80 : STA $13
        
        JSR $E9BC ; $169BC IN ROM
        
        LDA.b #$09 : STA $10
        LDA.b #$0F : STA $11
        
        STZ $B0
        
        RTS
    }

; ==============================================================================

    ; *$12F0B-$130D1 JUMP LOCATION
    {
        JSL InitSpriteSlots
        JSL Sprite_OverworldReloadAll
        
        STZ $0308
        STZ $0309
    
    ; *$12F19 ALTERNATE ENTRY POINT
    
        ; Module 0x08.0x01, 0x09.0x0E, 0x0A.0x01
        
        LDA.b #$05 : STA $012D ; play silence. yes, literally play silence.
    
    ; *$12F1E ALTERNATE ENTRY POINT
    
        REP #$30
        
        ; Feed the Overworld index to this location.
        LDA $8A : STA $7EC213
        LDA $84 : STA $7EC215
        LDA $88 : STA $7EC217
        LDA $86 : STA $7EC219
        
        LDA $0418 : STA $7EC21B
        LDA $0410 : STA $7EC21D
        LDA $0416 : STA $7EC21F
        
        STZ $8C
        STZ $0622
        STZ $0620
        
        LDY.w #$0390
        
        ; important
        LDA $8A : CMP.w #$0080 : BCC .notExtendedArea
        
        LDX.w #$0097
        
        ; checking for exit rooms (the faked way of getting from one overworld area to another)
        LDA $A0 : CMP.w #$0180 : BNE .notMasterSwordArea
        
        ; If the Master sword is retrieved, don't do the mist overlay
        LDX.w #$0080
        
        ; branch if the sword has in fact been pulled out
        LDA $7EF280, X
        
        LDX.w #$0097
        
        AND.w #$0040 : BNE .noSubscreenOverlay 
    
    .loadOverlay
    
        JMP .noRain
    
    .notMasterSwordArea
    
        LDX.w #$0094
        
        CMP.w #$0181 : BEQ .loadOverlay
        
        LDX.w #$0093
        
        CMP.w #$0189 : BEQ .loadOverlay
        CMP.w #$0182 : BEQ .zoraFalls
        CMP.w #$0183 : BNE .noSubscreenOverlay
    
    .zoraFalls ; I think....
    
        SEP #$30
        
        LDA.b #$01 : STA $012D
    
    .noSubscreenOverlay
    
        SEP #$30
        
        STZ $1D
        
        INC $11
        
        RTS
    
    .notExtendedArea
    
        AND.w #$003F : BNE .notForest
        
        LDA $8A : AND.w #$0040 : BNE .skullWoods
        
        LDX.w #$0080 : LDA $7EF280, X
        
        ; The forest canopy subscreen overlay
        LDX.w #$009E
        
        AND.w #$0040 : BNE .noRain
    
    .skullWoods
    
        LDX.w #$009D
        
        BRA .noRain
    
    .notForest
    
        LDX.w #$0095
        
        LDA $8A
        
        CMP.w #$0003 : BEQ .noRain
        CMP.w #$0005 : BEQ .noRain
        CMP.w #$0007 : BEQ .noRain
        
        LDX.w #$009C
        
        CMP.w #$0043 : BEQ .noRain
        CMP.w #$0045 : BEQ .noRain
        CMP.w #$0047 : BEQ .noRain
        
        CMP.w #$0070 : BNE .notSwampOfEvil
        
        ; Has Misery Mire been triggered yet?
        ; yes it has been triggered   
        LDA $7EF2F0 : AND.w #$0020 : BNE .noRain
        
        BRA .makeItRain ; on those hoes
    
    .notSwampOfEvil
    
        ; I guess by default, most areas load the Pyramid of Power's overlay...
        ; (Unless we're in phase 0 or phase 1).
        LDX.w #$0096
        
        ; If $7EF3C5 >= 0x02
        LDA $7EF3C5 : AND.w #$00FF : CMP.w #$0002 : BCS .noRain
    
    .makeItRain
    
        ; Otherwise, I think we need some rain.
        LDX.w #$009F
    
    ; *$1300B ALTERNATE ENTRY POINT
    .noRain
    
        STY $84
        
        STX $8A : STX $8C
        
        LDA $84 : SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
        
        STZ $0418 : STZ $0410 : STZ $0416
        
        SEP #$30
        
        ; Color +/- buffered register.
        LDA.b #$82 : STA $99
        
        ; Puts OBJ, BG2, and BG3 on the main screen
        LDA.b #$16 : STA $1C
        
        ; Puts BG1 on the subscreen
        LDA.b #$01 : STA $1D
        
        ; Save X for uno momento.
        PHX
        
        ; Set the ambient sound effect
        LDX $8A : LDA $7F5B00, X : LSR #4 : STA $012D
        
        PLX 
        
        ; One possible configuration for $2131 (CGADSUB)
        LDA.b #$72
        
        ; comparing different screen types?
        CPX.b #$97 : BEQ .loadOverlay
        CPX.b #$94 : BEQ .loadOverlay
        CPX.b #$93 : BEQ .loadOverlay
        CPX.b #$9D : BEQ .loadOverlay
        CPX.b #$9E : BEQ .loadOverlay
        CPX.b #$9F : BEQ .loadOverlay
        
        ; alternative setting for CGADSUB (only background is enabled on subscreen)
        LDA.b #$20 
        
        CPX.b #$95 : BEQ .loadOverlay
        CPX.b #$9C : BEQ .loadOverlay
        
        LDA $7EC213 : TAX
        
        LDA.b #$20
        
        CPX.b #$5B : BEQ .loadOverlay
        CPX.b #$1B : BNE .disableSubscreen
        
        LDX $11
        
        CPX.b #$23 : BEQ .loadOverlay
        CPX.b #$2C : BEQ .loadOverlay
    
    .disableSubscreen
    
        STZ $1D
    
    .loadOverlay
    
        ; apply the selected settings to CGADSUB's mirror ($9A)
        STA $9A
        
        JSR LoadSubscreenOverlay
        
        ; This is the "under the bridge" area.
        LDA $8C : CMP.b #$94 : BNE .notUnderBridge
        
        ; All this is doing is setting the X coordinate of BG1 to 0x0100
        ; Rather than 0x0000. (this area usees the second half of the data only, similar to the master sword area.
        LDA $E7 : ORA.b #$01 : STA $E7
    
    .notUnderBridge
    
        REP #$20
        
        ; We were pretending to be in a different area to load the subscreen
        ; overlay, so we're restoring all those settings.
        LDA $7EC213 : STA $8A
        LDA $7EC215 : STA $84
        LDA $7EC217 : STA $88
        LDA $7EC219 : STA $86
        
        LDA $7EC21B : STA $0418
        LDA $7EC21D : STA $0410
        LDA $7EC21F : STA $0416
        
        SEP #$20
        
        RTS
    }

; ==============================================================================
    
    ; *$130D2-$130F2 JUMP LOCATION
    {
        LDA $7EC007 : LSR A : BCC BRANCH_ALPHA
        
        LDA $7EC011 : SUB.b #$10 : STA $7EC011
    
    BRANCH_ALPHA:
    
        JSR $C2F6 ; $142F6 IN ROM
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $B0F3 ; = $130F3*
        dw $B195 ; = $13195*
        dw $B105 ; = $13105*
    }

    ; *$130F3-$1314F JUMP LOCATION
    {
        LDX $8A
        
        LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes ; $755A8 IN ROM
        
        BRA BRANCH_$13171
    
    ; *$13105 ALTERNATE ENTRY POINT
    
        LDA $0130 : STA $0133
        
        LDA $8A
        
        CMP.b #$80 : BEQ BRANCH_ALPHA
        CMP.b #$2A : BEQ BRANCH_ALPHA
        
        LDX $8A
        
        LDA $7F5B00, X : LSR #4 : BNE BRANCH_BETA
        
        LDA.b #$05
    
    BRANCH_BETA:
    
        STA $012D
        
        LDA $7F5B00, X : AND.b #$0F : CMP $0130 : BEQ BRANCH_ALPHA
        
        STA $012C
    
    BRANCH_ALPHA:
    
        STZ $11
        
        LDA.b #$08 : STA $11
        
        STZ $B0
        
        LDA $10 : CMP.b #$0B : BNE BRANCH_GAMMA
        
        ; go from special overworld to normal overworld
        LDA.b #$09 : STA $10
        
        LDA.b #$1F : STA $11
        
        LDA.b #$0C : STA $069A
    
    BRANCH_GAMMA:
    
        RTS
    }

    ; *$13150-$13170 JUMP LOCATION
    {
        ; if(!($7EC007 % 2)) goto BRANCH_ALPHA
        LDA $7EC007 : LSR A : BCC BRANCH_ALPHA
        
        ; $7EC011 -= 0x10
        LDA $7EC011 : SUB.b #$10 : STA $7EC011
    
    BRANCH_ALPHA:
    
        JSR $C2F6 ; $142F6 IN ROM
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $B171 ; = $13171*
        dw $B195 ; = $13195*
        dw $B19E ; = $1319E*
    }

    ; *$13171-$13194 JUMP LOCATION
    {
        JSL $00E031 ; $6031 IN ROM
        
        LDA.b #$0F : STA $13
        LDA.b #$80 : STA $9B
        
        LDA $7EC00B : DEC A : STA $7EC007
        
        LDA.b #$00 : STA $7EC00B
        LDA.b #$02 : STA $7EC009
        
        INC $B0
        
        RTS
    }

    ; *$13195-$1319D JUMP LOCATION
    {
        JSL Graphics_IncrementalVramUpload
        JSL PaletteFilter.doFiltering
        
        RTS
    }

    ; *$1319E-$131BA JUMP LOCATION
    {
        LDA $8A : CMP.b #$80 : BCS BRANCH_ALPHA
        
        LDA.b #$02 : STA $012C
        
        LDA $8A : AND.b #$3F : BNE BRANCH_ALPHA
        
        LDA.b #$05 : STA $012C
    
    BRANCH_ALPHA:
    
        LDA.b #$08 : STA $11
        
        STZ $B0
        
        RTS
    }

    ; *$131BB-$131C7 JUMP LOCATION
    {
        INC $13
        
        LDA $13 : CMP.b #$0F : BNE .notBrightEnough
        
        STZ $11
        STZ $B0
    
    .notBrightEnough
    
        RTS
    }

    ; *$131C8-$131DE JUMP LOCATION
    {
        ; Module 0x09.0x18 (overworld loading an area submodule)
        
        STZ $032A
        
        LDA $10 : PHA ; save module number
        LDA $11 : PHA ; save submodule number
        
        JSR $E851 ; $16851 IN ROM
        JSR $AF0B ; $12F0B IN ROM
        
        PLA : INC A : STA $11 ; move on to the next module (0x19)
        PLA : STA $10
        
        RTS
    }

    ; *$131DF-$131EF JUMP LOCATION
    {
        ; Goes on to load a bunch of OW data like Map16 / Map32
        
        LDA $10 : PHA
        LDA $11 : PHA
        
        JSR $EDB9 ; $16DB9 IN ROM
        
        PLA : INC A : STA $11
        PLA : STA $10
        
        RTS
    }

; ==============================================================================

    ; *$131F0-$131F3 LONG
    {
        JSR Overworld_LoadAmbientOverlayAndMapData
        
        RTL
    }

; ==============================================================================

    ; *$131F4-$131F9 LONG
    {
        JSR $AF1E; $12F1E IN ROM
        
        DEC $11
        
        RTL
    }

; ==============================================================================

    ; *$131FA-$131FE JUMP LOCATION
    Overworld_MirrorWarp:
    {
        JSL Overworld_MirrorWarp_Main
        
        RTS
    }

; ==============================================================================

    ; *$131FF-$13216 LONG
    Overworld_MirrorWarp_Main:
    {
        INC $0710
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLongJumpTable
        
        dl Overworld_InitMirrorWarp
        
        ; these three appear to do palette filtering and manipulation of the
        ; hdma table, but how the latter works exactly is not understood yet.
        dl $00FE5E ; = $7E5E*  1:
        dl $00FE64 ; = $7E64*  2: 
        dl $00FF2F ; = $7F2F*  3: 
        dl Overworld_FinishMirrorWarp
    }

; ==============================================================================

    ; *$13217-$1325F JUMP LOCATION (LONG)
    Overworld_InitMirrorWarp:
    {
        LDA $8A : CMP.b #$80 : BCC .not_extended_area
        
        STZ $11
        STZ $B0
        STZ $0200
        
        RTL
    
    .not_extended_area
    
        LDA.b #$08 : STA $012C : STA $0ABF
        
        LDA.b #$90 : STA $031F
        
        JSL Mirror_InitHdmaSettings
        
        ; SWAP DARKWORLD / LIGHTWORLD STATUS
        LDA $7EF3CA : EOR.b #$40 : STA $7EF3CA
        
        STZ $04C8
        STZ $04C9
        
        LDA $8A : AND.b #$3F : ORA $7EF3CA : STA $8A : STA $040A
        
        STZ $0200
        
        JSL Palette_InitWhiteFilter
        JSR Overworld_LoadMapProperties
        
        INC $B0
        
        RTL
    }

; ==============================================================================

    ; *$13260-$132D3 JUMP LOCATION (LONG)
    Overworld_FinishMirrorWarp:
    {
        REP #$20
        
        LDA.w #$2641 : STA $4370
        
        LDX.b #$3E
        
        LDA.w #$FF00
    
    .clear_hdma_table
    
        STA $1B00, X : STA $1B40, X
        STA $1B80, X : STA $1BC0, X
        STA $1C00, X : STA $1C40, X
        STA $1C80, X
        
        DEX #2 : BPL .clear_hdma_table
        
        LDA.w #$0000 : STA $7EC007 : STA $7EC009
        
        SEP #$20
        
        JSL $00D788               ; $5788 IN ROM
        JSL Overworld_SetSongList
        
        LDA.b #$80 : STA $9B
        
        LDX $8A
        
        LDA $7F5B00, X : AND.b #$0F : STA $012C
        
        LDA $7F5B00, X : LSR #4 : STA $012D
        
        CPX.b #$40 : BCC .not_bunny_music
        
        LDA $7EF357 : BNE .not_bunny_music
        
        LDA.b #$04 : STA $012C
    
    .not_bunny_music
    
        LDA $11 : STA $010C
        
        STZ $11
        STZ $B0
        STZ $0200
        STZ $0710
        
        RTL
    }

; ==============================================================================

    ; *$132D4-$132E5 LONG
    {
        JSR $AF19 ; $12F19 IN ROM
        
        LDA $8A
        
        CMP.b #$1B : BEQ .isPyramidOrCastle
        CMP.b #$5B : BNE .notPyramidOrCastle
    
    .isPyramidOrCastle
    
        LDA.b #$01 : STA $1D
    
    .notPyramidOrCastle
    
        RTL
    }

; ==============================================================================

    ; *$132E6-$13333 LONG
    {
        REP #$20
        
        LDA $84 : PHA
        LDA $86 : PHA
        LDA $88 : PHA
        
        LDX $8A
        
        LDA $02F88D, X : AND.w #$00FF : BEQ .large_area
        
        LDA.w #$0390 : STA $84
        
        SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
    
    .large_area
    
        SEP #$20
        
        JSR Overworld_LoadMapData
        
        ; Compare it to the other magic mirror mode
        LDA $11 : CMP.b #$2C : BNE .notFailedWarp
        
        JSR Overworld_RestoreFailedWarpMap16
    
    .notFailedWarp
    
        REP #$20
        
        PLA : STA $88
        PLA : STA $86
        PLA : STA $84
        
        SEP #$20
        
        RTL
    }

; ==============================================================================

    ; *$13334-$13409 LONG
    {
        LDA.b #$90 : STA $031F
        
        REP #$20
        
        LDA $84 : PHA
        LDA $86 : PHA
        LDA $88 : PHA
        
        LDA.w #$FFFF : STA $C8
        
        STZ $CA : STZ $CC
        
        LDX $8A
        
        LDA $02F88D, X : AND.w #$00FF : BEQ BRANCH_ALPHA
        
        LDA.w #$0390 : STA $84
        
        SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        JSR Map16ToMap8_normalArea
        
        REP #$20
        
        PLA : STA $88
        PLA : STA $86
        PLA : STA $84
        
        SEP #$20
        
        JSR Overworld_LoadAreaPalettes ; $14692 IN ROM
        
        LDX $8A
        
        LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        JSL $0ED5A8 ; $755A8 IN ROM
        JSL $0ED61D ; $7561D IN ROM
        JSL $0BFE70 ; $5FE70 IN ROM
        
        LDA $8A
        
        CMP.b #$1B : BEQ .activateSubscreenBg0
        CMP.b #$5B : BNE .ignoreBg0
    
    .activateSubscreenBg0
    
        LDA.b #$01 : STA $1D
    
    .ignoreBg0
    
        REP #$20
        
        LDX.b #$00
        
        LDA.w #$7FFF
    
    .setBgPalettesToWhite
    
        STA $7EC540, X : STA $7EC560, X : STA $7EC580, X
        STA $7EC5A0, X : STA $7EC5C0, X : STA $7EC5E0, X
        
        INX #2 : CPX.b #$20 : BNE .setBgPalettesToWhite
        
        ; Also set the background color to white
        STA $7EC500
        
        LDA $8A : CMP.w #$005B : BNE .notPyramidOfPower
        
        LDA.w #$0000 : STA $7EC500 : STA $7EC540
    
    .notPyramidOfPower
    
        SEP #$20
        
        JSL Sprite_ResetAll
        JSL Sprite_OverworldReloadAll
        JSL $07B107 ; $3B107 IN ROM
        JSR $8B0C   ; $10B0C IN ROM
        
        LDA.b #$14 : STA $5D
        
        LDA $8A : AND.b #$40 : BNE .darkWorld
        
        JSL Sprite_ReinitWarpVortex
    
    .darkWorld
    
        RTL
    }

    ; *$1340A-$1340E JUMP LOCATION
    {
        ; module 0x09.0x2B - making the screen flash white during the master sword retrieval
        
        JSL $0EF400 ; $77400 IN ROM
    
    shared Overworld_WeathervaneExplosion:
    
        RTS
    }

    ; *$1340F-$13431 JUMP LOCATION
    {
        INC $0710
        
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $B432 ; = $13432*
        dw $B44C ; = $1344C*
        dw $B451 ; = $13451*
        dw $B46E ; = $1346E*
        dw $B48A ; = $1348A*
        dw $B490 ; = $13490*
        dw $B48A ; = $1348A*
        dw $B49A ; = $1349A*
        dw $B49F ; = $1349F*
        dw $B4AE ; = $134AE*
        dw $B45F ; = $1345F*
        dw $B456 ; = $13456*
        dw $B4EF ; = $134EF*
    }

    ; *$13432-$1344B JUMP LOCATION
    {
        LDA.b #$34 : STA $012E
        LDA.b #$05 : STA $012D
        
        STZ $0200
        
        LDA.b #$00 : STA $7EC007 : STA $7EC008
        
        INC $B0
        
        RTS
    }

    ; *$1344C-$13450 JUMP LOCATION
    {
        JSL WhirlpoolSaturateBlue ; $6F97 IN ROM
        
        RTS
    }

    ; *$13451-$13455 JUMP LOCATION
    {
        JSL WhirlpoolIsolateBlue ; $700C IN ROM
        
        RTS
    }

    ; *$13456-$1345E JUMP LOCATION
    {
        JSL Graphics_IncrementalVramUpload
        JSL WhirlpoolRestoreBlue ; $704A IN ROM
        
        RTS
    }

    ; *$1345F-$1346D JUMP LOCATION
    {
        JSL WhirlpoolRestoreRedGreen
        
        LDA $7EC007 : BEQ .alpha
        
        JSL WhirlpoolRestoreRedGreen
    
    .alpha
    
        RTS
    }

    ; *$1346E-$134EE JUMP LOCATION
    {
        LDA.b #$9F : STA $9E
        
        STZ $0AA9
        STZ $0AB2
        
        JSL Whirlpool_LookUpAndLoadTargetArea
        
        STZ $B2
        
        JSL $02B1F4 ; $131F4 IN ROM
        
        LDA.b #$0C : STA $17
        
        STZ $15
        
        BRA BRANCH_DELTA
    
    ; *$1348A ALTERNATE ENTRY POINT
    
        LDA.b #$0D : STA $17
        
        BRA BRANCH_ALPHA
    
    ; *$13490 ALTERNATE ENTRY POINT
    
        JSL BirdTravel_LoadAmbientOverlay
        
        LDA.b #$0C : STA $17
        
        BRA BRANCH_BETA
    
    ; *$1349A ALTERNATE ENTRY POINT
    
        JSR Overworld_LoadTransGfx
        
        BRA BRANCH_GAMMA
    
    ; *$1349F ALTERNATE ENTRY POINT
    
        JSR Overworld_FinishTransGfx
        
        LDA.b #$0F : STA $13
        
        INC $0710
    
    BRANCH_GAMMA:
    
        DEC $11
        INC $B0
        
        RTS
    
    ; *$134AE ALTERNATE ENTRY POINT
    
        STZ $0AA9
        
        JSL Palette_MainSpr         ; $DEC9E IN ROM
        JSL Palette_MiscSpr         ; $DED6E IN ROM
        JSL Palette_SpriteAux3      ; $DEC77 IN ROM
        JSL Palette_Hud             ; $DEE52 IN ROM
        JSL Palette_OverworldBgMain ; $DEEC7 IN ROM
        
        LDX $8A
        
        LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes      ; $755A8 IN ROM
        JSL Palette_SetOwBgColor_Long   ; $75618 IN ROM
        JSL $0BFE70                     ; $5FE70 IN ROM
        JSL $00E031                     ; $6031 IN ROM
    
    BRANCH_DELTA:
    
        LDA.b #$80 : STA $9E
    
    BRANCH_BETA:
    
        LDA.b #$0F : STA $13
    
    BRANCH_ALPHA:
    
        INC $0710
        INC $B0
        
        RTS
    }

    ; *$134EF-$13520 JUMP LOCATION
    {
        LDA.b #$90 : STA $031F
        
        JSL $00D788 ; $5788 IN ROM
        
        LDA.b #$80 : STA $9B
        
        LDX $8A
        
        LDA $7F5B00, X : LSR #4 : STA $012D
        
        LDX.b #$02
        
        LDA $7EF3CA : BEQ BRANCH_ALPHA
        
        LDX.b #$09
    
    BRANCH_ALPHA:
    
        STX $012C
        
        STZ $11
        STZ $B0
        STZ $0200
        STZ $0710
        
        RTS
    }

; ==============================================================================

    ; $13521-$13527 JUMP LOCATION
    {
        JSL Overworld_DrawWarpTile
        
        STZ $11    
        
        RTS
    }

; ==============================================================================

    ; *$13528-$13531 JUMP LOCATION
    {
        LDA $B0
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $B532 ; = $13532*
        dw $9583 ; = $11583*
    }

    ; *$13532-$135AB JUMP LOCATION
    {
        REP #$20
        
        STZ $00
        STZ $02
        
        LDA $22 : CMP $7EC186 : BEQ BRANCH_ALPHA : BCC BRANCH_BETA
        
        DEC $02
        
        DEC A : CMP $7EC186 : BEQ BRANCH_ALPHA
        
        DEC $02
        
        DEC A
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        INC $02
        
        INC A : CMP $7EC186 : BEQ BRANCH_ALPHA
        
        INC $02
        
        INC A
    
    BRANCH_ALPHA:
    
        STA $22
        
        LDA $20 : CMP $7EC184 : BEQ BRANCH_GAMMA : BCC BRANCH_DELTA
        
        DEC $00
        
        DEC A : CMP $7EC184 : BEQ BRANCH_GAMMA
        
        DEC $00
        
        DEC A
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        INC $00
        
        INC A : CMP $7EC184 : BEQ BRANCH_GAMMA
        
        INC $00
        
        INC A
    
    BRANCH_GAMMA:
    
        STA $20
        
        CMP $7EC184 : BNE BRANCH_EPSILON
        
        LDA $22 : CMP $7EC186 : BNE BRANCH_EPSILON
        
        INC $B0
        
        STZ $46
    
    BRANCH_EPSILON:
    
        SEP #$20
        
        LDA $00 : STA $30
        LDA $02 : STA $31
        
        JSR $BB90 ; $13B90 IN ROM
        
        LDA $0416 : BEQ BRANCH_ZETA
        
        JSR Overworld_ScrollMap     ; $17273 IN ROM
    
    BRANCH_ZETA:
    
        RTS
    }

    ; $135AC-$135CB DATA
    {
        db $0F, $0F, $0F, $0F ; layout 0
        db $0B, $0B, $07, $07 ; layout 1
        db $0F, $0B, $0F, $07 ; layout 2, etc...
        db $0B, $0F, $07, $0F
        db $0E, $0D, $0E, $0D
        db $0F, $0F, $0E, $0D
        db $0E, $0D, $0F, $0F
        db $0A, $09, $06, $05
    }
    
    ; $135CC-$135DB
    {
        db $08, $04, $02, $01, $0C, $0C, $03, $03
        db $0A, $05, $0A, $05, $0F, $0F, $0F, $0F
    }
    
; ==============================================================================

    ; *$135DC-$1362D LONG
    {
        PHB : PHK : PLB
        
        SEP #$30
        
        JSR $BA27 ; $13A27 IN ROM; set $A8 to a composite of quadrants we're in
        
        STZ $A6
        
        LDY.b #$02
        
        LDA $A9 : BNE .inRightHalf
        
        ; value for left half of screen
        LDY.b #$01
    
    .inRightHalf
    
        STY $00
        
        ; Since there are no horizontal blast walls in the original game,
        ; this code is kind of moot. See other comment on them below, though.
        LDA $0452 : BNE .blastWallOpenHoriz
        
        LDX $A8
        
        LDA $B5AC, X : AND $00 : BNE .gamma
    
    .blastWallOpenHoriz
    
        LDA.b #$02 : STA $A6
    
    .gamma
    
        STZ $A7
        
        LDY.b #$08
        
        LDA $AA : BNE .inLowerHalf
        
        ; Value for upper half
        LDY.b #$04
    
    .inLowerHalf
    
        STY $00
        
        ; I think this has to do with scroll control. Opening up a blast wall
        ; alters a room's scrolling regions, or something like that.
        LDA $0453 : BNE .blastWallOpenVert
        
        LDX $A8
        
        LDA $B5AC, X : AND $00 : BNE .zeta
    
    .blastWallOpenVert
    
        LDA.b #$02 : STA $A7
    
    .zeta
    
        LDA $FC : BEQ .blastWallHorizOverride
        
        STA $A6
    
    .blastWallHorizOverride
    
        LDA $FD : BEQ .blastWallVertOverride
        
        STA $A7
    
    .blastWallVertOverride
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$1362E-$136CC LONG
    {
        REP #$20
        
        LDA $22 : ADD.w #$0008 : STA $22   
        
        SEP #$20
    
    ; *$1363A ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
        
        LDA $A9 : EOR.b #$01 : STA $A9
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$08
        
        JSR $B968 ; $13968 IN ROM
        JSR $B947 ; $13947 IN ROM
        
        LDA $A9
        
        JSR $BDC8 ; $13DC8 IN ROM
        
        LDY.b #$02
        
        JSR $B9DC ; $139DC IN ROM
        
        INC $11
        
        LDA $A9 : BNE BRANCH_ALPHA
        
        LDX.b #$08
        
        JSR $B981 ; $13981 IN ROM
        
        LDA $A0 : STA $A2
        
        ; Load the tile type we're standing on.
        ; Is it the linking doorway?
        LDA $0114 : AND.b #$CF : CMP.b #$89 : BNE .notRoomLinkDoor
        
        ; yep
        LDA $7EC004 : STA $A0 : DEC A
        
        ; Moving right, so add positive to X coords.
        LDY.b #$01
        
        JSR Dungeon_AdjustCoordsForLinkedRoom
        
        BRA BRANCH_GAMMA
    
    .notRoomLinkDoor
    
        ; Load the room number
        ; compare it to the... um, room number?
        LDA $048E : CMP $A0 : BEQ BRANCH_DELTA
        
        STA $A2
        
        JSR $A2F0 ; $122F0 IN ROM
    
    BRANCH_DELTA:
    
        INC $A0
    
    BRANCH_GAMMA:
    
        INC $11
        
        LDA $EF : AND.b #$01 : BEQ BRANCH_EPSILON
        
        LDA $EE : EOR.b #$01 : STA $EE : STA $0476
    
    BRANCH_EPSILON:
    
        LDA $EF : AND.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $040C : EOR.b #$02 : STA $040C
    
    BRANCH_ALPHA:
    
        STZ $EF
        STZ $A7
        
        LDY.b #$08
        
        LDA $AA : BNE BRANCH_THETA
        
        LDY.b #$04
    
    BRANCH_THETA:
    
        STY $00
        
        LDA $0453 : BNE BRANCH_IOTA
        
        LDX $A8
        
        LDA $B5AC, X : AND $00 : BNE BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        LDA.b #$02 : STA $A7
    
    BRANCH_KAPPA:
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$136CD-$1376D LONG
    {
        REP #$20
        
        LDA $22 : SUB.w #$0008 : STA $22
        
        SEP #$20
    
    ; *$136D9 ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
        
        LDA $A9 : EOR.b #$01 : STA $A9
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$08
        
        JSR $B99A ; $1399A IN ROM
        JSR $B947 ; $13947 IN ROM
        
        LDA $A9 : EOR.b #$01
        
        JSR $BDC8 ; $13DC8 IN ROM
        
        LDY.b #$03
        
        JSR $B9DC ; $139DC IN ROM
        
        INC $11
        
        LDA $A9 : BNE BRANCH_ALPHA
        
        LDX.b #$08
        
        JSR $B9B3 ; $139B3 IN ROM
        
        LDA $A0 : STA $A2
        
        ; Is it a linking doorway?
        LDA $0114 : AND.b #$CF : CMP.b #$89 : BNE .notRoomLinkDoor
        
        ; yep
        LDA $7EC003 : STA $A0 : DEC A
        
        LDY.b #$FF ; Moving left... so add negatives to X cooords.
        
        JSR Dungeon_AdjustCoordsForLinkedRoom
        
        BRA BRANCH_GAMMA
    
    .notRoomLinkDoor
    
        LDA $048E : CMP $A0 : BEQ BRANCH_DELTA
        
        STA $A2
        
        JSR $A2F0 ; $122F0 IN ROM
    
    BRANCH_DELTA:
    
        DEC $A0
    
    BRANCH_GAMMA:
    
        INC $11
        
        LDA $EF : AND.b #$01 : BEQ BRANCH_EPSILON
        
        LDA $EE : EOR.b #$01 : STA $EE : STA $0476
    
    BRANCH_EPSILON:
    
        LDA $EF : AND.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $040C : EOR.b #$02 : STA $040C
    
    BRANCH_ALPHA:
    
        STZ $EF
        STZ $A7
        
        LDY.b #$08
        
        LDA $AA : BNE BRANCH_THETA
        
        LDY.b #$04
    
    BRANCH_THETA:
    
        STY $00
        
        LDA $0453 : BNE BRANCH_IOTA

        LDX $A8
        
        LDA $B5AC, X : AND $00 : BNE BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        LDA.b #$02 : STA $A7
    
    BRANCH_KAPPA:
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$1376E-$1381B LONG
    {
        REP #$20
        
        LDA $20 : ADD.w #$0010 : STA $20
        
        SEP #$20
    
    ; *$1377A ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
        
        ; Alternate between being in the lower half and the upper half of the room.
        LDA $AA : EOR #$02 : STA $AA
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$00
        
        JSR $B968 ; $13968 IN ROM
        JSR $B947 ; $13947 IN ROM
        
        LDA $AA
        
        JSR $BDE2 ; $13DE2 IN ROM
        
        LDY.b #$00
        
        JSR $B9DC ; $139DC IN ROM
        
        INC $11
        
        LDA $AA : BNE .inRoomLowerHalf
        
        LDX.b #$00
        
        JSR $B981 ; $13981 IN ROM
        
        LDA $A0 : STA $A2
        
        LDA $0114 : CMP.b #$8E : BNE .notGoingToOverworld
    
    ; *$137AE ALTERNATE ENTRY POINT
    
        JSL Dungeon_SaveRoomData_justKeys ; $121C7 IN ROM
        JSL $02B8E5                       ; $138E5 IN ROM
        
        LDA.b #$08 : STA $010C
        
        ; Go to pre-overworld mode.
        LDA.b #$0F : STA $10
        
        STZ $11
        STZ $B0
        
        JSR $8B0C ; $10B0C IN ROM
        
        PLB
        
        RTL
    
    .notGoingToOverworld
    
        LDA $048E : CMP $A0 : BEQ .gamma
        
        STA $A2
        
        JSR $A2F0 ; $122F0 IN ROM
    
    .gamma
    
        ; Move down to the next room.
        LDA $A0 : ADD.b #$10 : STA $A0
        
        INC $11
        
        LDA $EF : AND.b #$01 : BEQ BRANCH_DELTA
        
        LDA $EE : EOR.b #$01 : STA $EE : STA $0476
    
    BRANCH_DELTA:
    
        LDA $EF : AND.b #$0 : BEQ BRANCH_ALPHA
        
        LDA $040C : EOR.b #$02 : STA $040C
    
    .inRoomLowerHalf
    
        STZ $EF
        STZ $A6
        
        LDY.b #$02
        
        LDA $A9 : BNE BRANCH_EPSILON
        
        LDY.b #$01
    
    BRANCH_EPSILON:
    
        STY $00
        
        LDA $0452 : BNE BRANCH_ZETA
        
        LDX $A8
        
        LDA $B5AC, X : AND $00 : BNE BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDA.b #$02 : STA $A6
    
    BRANCH_THETA:
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$1381C-$138BC LONG
    {
        PHB : PHK : PLB
        
        LDA $AA : EOR.b #$02 : STA $AA
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$00
        
        JSR $B99A ; $1399A IN ROM
        JSR $B947 ; $13947 IN ROM
        
        LDA $AA : EOR.b #$02
        
        JSR $BDE2 ; $13DE2 IN ROM
        
        LDY.b #$01
        
        JSR $B9DC ; $139DC IN ROM
        
        INC $11
        
        LDA $AA : BEQ .inRoomUpperHalf
        
        LDX.b #$00
        
        JSR $B9B3 ; $139B3 IN ROM
        
        LDA $A0 : STA $A2
        
        LDA $0114 : CMP.b #$8E : BNE .notGoingToOverworld
        
        JMP $B7AE ; $137AE IN ROM
    
    .notGoingToOverworld
    
        LDA $A0 : ORA $A1 : BNE .notInGanonsRoom
        
        JSL Dungeon_SaveRoomData_justKeys ; $121C7 IN ROM
        
        ; Go to the triforce room scene.
        LDA.b #$19 : STA $10
        
        STZ $11
        STZ $B0
        
        PLB
        
        RTL
    
    .notInGanonsRoom
    
        LDA $048E : CMP $A0 : BEQ BRANCH_DELTA
        
        STA $A2
        
        JSR $A2F0 ; $122F0 IN ROM
    
    BRANCH_DELTA:
    
        ; Set the room number to the room "north" of the current one.
        LDA $A0 : SUB.b #$10 : STA $A0
        
        ; enter room transition mode
        INC $11
        
        LDA $EF : AND.b #$01 : BEQ .noFloorToggle
        
        LDA $EE : EOR.b #$01 : STA $EE : STA $0476
    
    .noFloorToggle
    
        ; Do we need to do a transition between sewer / HC
        LDA $EF : AND.b #$02 : BEQ .noPalaceToggle
        
        ; Toggle between sewer / HC
        LDA $040C : EOR.b #$02 : STA $040C
    
    .noPalaceToggle
    .inRoomUpperHalf
    
        STZ $EF
        STZ $A6
        
        LDY.b #$02
        
        LDA $A9 : BNE .inRoomRightHalf
        
        LDY.b #$01
    
    .inRoomRightHalf
    
        STY $00
        
        LDA $0452 : BNE .iota
        
        LDX $A8
        
        LDA $B5AC, X : AND $00 : BNE .kappa
    
    .iota
    
        LDA.b #$02 : STA $A6
    
    .kappa
    
        PLB
        
        RTL
    }

    ; *$138BD-$138F8 LONG
    {
        LDA $A9 : EOR #$01 : STA $A9
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$08
        
        JSR $B968 ; $13968 IN ROM
    
    ; *$138CB ALTERNATE ENTRY POINT
    ; Update qudrants visited and store to sram
    
        LDA $A7 : ASL #2 : STA $00
        LDA $A6 : ASL A  : ORA $00
        ORA $AA
        ORA $A9
        
        TAX
        
        LDA $02B5CC, X : ORA $0408 : STA $0408
    
    ; *$138E5 ALTERNATE ENTRY POINT
    
        REP #$30
        
        LDA $A0 : ASL A : TAX
        
        ; Save quadrants explored to save ram buffer
        LDA $7EF000, X : ORA $0408 : STA $7EF000, X
        
        SEP #$30
        
        RTL
    }

    ; *$138F9-$13946 LONG
    {
        LDA $A9 : EOR #$01 : STA $A9
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$08
        
        JSR $B99A ; $1399A IN ROM
        
        BRA BRANCH_$138CB
    
    ; *$13909 ALTERNATE ENTRY POINT
    
        LDA $AA : EOR.b #$02 : STA $AA
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$00
        
        ; moving down...
        JSR $B968 ; $13968 IN ROM
        
        BRA BRANCH_$138CB
    
    ; *$13919 ALTERNATE ENTRY POINT
    
        LDA $AA : EOR.b #$02 : STA $AA
        
        JSR $BA27 ; $13A27 IN ROM
        
        LDX.b #$00
        
        ; moving up...
        JSR $B99A ; $1399A IN ROM
        
        BRA BRANCH_$138CB
    
    ; *$13929 ALTERNATE ENTRY POINT
    shared Dungeon_SaveRoomQuadrantData:
    
        ; figures out which Quadrants Link has visited in a room.
        
        ; Mapped to bit 3.
        LDA $A7 : ASL #2 : STA $00
        
        ; Mapped to bit 2.
        LDA $A6 : ASL A : ORA $00
        
        ; Mapped to bit 1.
        ORA $AA
        
        ; Mapped to bit 0.        
        ORA $A9
        
        ; X ranges from 0x00 to 0x0F
        TAX
        
        ; These determine the quadrants Link has seen in this room.
        LDA $02B5CC, X : ORA $0408 : STA $0408
        
        JSR $B947 ; $13947 IN ROM ; Save the room data and exit.
        
        RTL
    }

; ==============================================================================

    ; *$13947-$13967 LOCAL
    {
        ; Saves data for the current room
        
        REP #$30
        
        ; What room are we in... use it as an index.
        LDA $A0 : ASL A : TAX
        
        ; Store other data, like chests opened, bosses killed, etc.
        LDA $0402 : LSR #4 : STA $06
        
        ; Store information about this room when it changes.
        LDA $0400 : AND.w #$F000 : ORA $0408 : ORA $06 : STA $7EF000, X
        
        SEP #$30
        
        RTS
    }

    ; *$13968-$13980 LOCAL
    {
        ; moving on down....
        
        REP #$20
        
        LDA $0600, X : ADD.w #$0100 : STA $0600, X
        LDA $0604, X : ADD.w #$0100 : STA $0604, X
        
        SEP #$20
        
        RTS
    }

    ; *$13981-$13999 LOCAL
    {
        REP #$20
        
        LDA $0602, X : ADD.w #$0200 : STA $0602, X
        LDA $0606, X : ADD.w #$0200 : STA $0606, X
        
        SEP #$20
        
        RTS
    }

    ; *$1399A-$139B2 LOCAL
    {
        ; movin on up....
        
        REP #$20
        
        LDA $0600, X : SUB.w #$0100 : STA $0600, X
        LDA $0604, X : SUB.w #$0100 : STA $0604, X
        
        SEP #$20
        
        RTS
    }

    ; *$139B3-$139CB LOCAL
    {
        REP #$20
        
        LDA $0602, X : SUB.w #$0200 : STA $0602, X
        LDA $0606, X : SUB.w #$0200 : STA $0606, X
        
        SEP #$20
        
        RTS
    }

    ; $139CC-$139DB DATA

    ; *$139DC-$13A26 LOCAL
    {
        STY $0418
        
        LDA $67 : AND.b #$03 : BEQ BRANCH_ALPHA
        
        REP #$20
        
        LDX.b #$04
        
        LDA $67 : AND.w #$0001 : BEQ BRANCH_BETA
        
        LDX.b #$00
    
    BRANCH_BETA:
    
        LDY $A9 : BEQ BRANCH_GAMMA
        
        INX #2
    
    BRANCH_GAMMA:
    
        LDA $B9D4, X : STA $061C
        
        INC A : INC A : STA $061E
        
        SEP #$20
        
        RTS
    
    BRANCH_ALPHA:
    
        REP #$20
        
        LDX.b #$04
        
        LDA $67 : AND.w #$0004 : BEQ BRANCH_DELTA
        
        LDX.b #$00
    
    BRANCH_DELTA:
    
        LDY $AA : BEQ BRANCH_EPSILON
        
        INX #2
    
    BRANCH_EPSILON:
    
        LDA $B9CC, X : STA $0618
        
        INC A : INC A : STA $061A
        
        SEP #$20
        
        RTS
    }

    ; *$13A27-$13A30 LOCAL
    {
        LDA $040E : ORA $AA : ORA $A9 : STA $A8
        
        RTS
    }

; ==============================================================================

    ; *$13A31-$13B87 LOCAL
    {
        REP #$20
        
        LDA.w #$0001 : STA $00
        
        LDA $78 : AND.w #$00FF : BEQ BRANCH_ALPHA
        
        LDA $24 : CMP.w #$FFFF : BNE BRANCH_ALPHA
        
        LDA.w #$0000
    
    BRANCH_ALPHA:
    
        STA $0E
        
        LDA $20 : SUB $0E : AND.w #$01FF : ADD.w #$000C : STA $0E
        
        LDA $30 : AND.w #$00FF : BEQ BRANCH_BETA
        
        LDX $A7
        
        CMP.w #$0080 : BCC BRANCH_GAMMA
        
        EOR.w #$00FF : INC A
        
        DEC $00 : DEC $00
    
    BRANCH_GAMMA:
    
        TAY
    
    BRANCH_IOTA:
    
        LDX $A7
        
        LDA $30 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_DELTA
        
        LDA $0618 : CMP $0E : BCS BRANCH_EPSILON : BCC BRANCH_ZETA
    
    BRANCH_DELTA:
    
        LDA $0E : CMP $061A : BCC BRANCH_ZETA
        
        INX #4
    
    BRANCH_EPSILON:
    
        ; comapare against y coordinate limits
        LDA $E8 : CMP $0600, X : BEQ BRANCH_ZETA
        
        ADD $00 : STA $E8
        
        LDA $A0 : CMP.w #$FFFF : BEQ BRANCH_ZETA
        
        LDA $00
        
        STZ $04
        
        LSR A : ROR $04 : CMP.w #$7000 : BCC BRANCH_THETA
        
        ORA.w #$F000
    
    BRANCH_THETA:
    
        STA $06
        
        LDA $0622 : ADD $04 : STA $0622
        
        LDA $E6 : ADC $06 : STA $E6

        LDA $0618 : ADD $00 : STA $0618
        
        INC #2 : STA $061A
    
    BRANCH_ZETA:
    
        DEY : BNE BRANCH_IOTA
    
    BRANCH_BETA:
    
        LDA.w #$0001 : STA $00
        
        LDA $22 : AND.w #$01FF : ADD.w #$0008 : STA $0E
        
        LDA $31 : AND.w #$00FF : BEQ BRANCH_KAPPA
        
        LDX $A6
        
        CMP.w #$0080 : BCC BRANCH_LAMBDA
        
        EOR #$00FF : INC A
        
        DEC $00 : DEC $00
    
    BRANCH_LAMBDA:
    
        TAY
    
    BRANCH_PI:
    
        LDX $A6
        
        LDA $31 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_MU
        
        LDA $061C : CMP $0E : BCS BRANCH_NU : BCC BRANCH_XI
    
    BRANCH_MU:
    
        LDA $0E : CMP $061E : BCC BRANCH_XI
        
        INX #4
    
    BRANCH_NU:
    
        ; compare with screen coordinate limits...? (x coordinate)
        LDA $E2 : CMP $0608, X : BEQ BRANCH_XI
        
        ADD $00 : STA $E2
        
        LDA $A0 : CMP.w #$FFFF : BEQ BRANCH_XI
        
        LDA $00 : STZ $04 : LSR A : ROR $04 : CMP.w #$7000 : BCC BRANCH_OMICRON
        
        ORA.w #$F000
    
    BRANCH_OMICRON:
    
        STA $06
        
        LDA $0620 : ADD $04 : STA $0620
        
        LDA $E0 : ADC $06 : STA $E0
        
        LDA $061C : ADD $00 : STA $061C
        
        INC #2 : STA $061E
    
    BRANCH_XI:
    
        DEY : BNE BRANCH_PI
    
    BRANCH_KAPPA:
    
        LDA $A0 : CMP.w #$FFFF : BEQ BRANCH_RHO
        
        LDX $0414  : BEQ BRANCH_SIGMA
        CPX.b #$06 : BCS BRANCH_SIGMA
        CPX.b #$04 : BEQ BRANCH_SIGMA
        CPX.b #$03 : BEQ BRANCH_SIGMA
        CPX.b #$02 : BNE BRANCH_RHO
    
    ; *$13B7B ALTERNATE ENTRY POINT
    BRANCH_SIGMA:
    
        REP #$20
        
        ; synchronize BG2 and BG1 scroll regs
        LDA $E2 : STA $E0
        LDA $E8 : STA $E6
    
    BRANCH_RHO:
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $13B88-$13B8F DATA - bit masks describing which direction(s) to update the OW tilemap in
    {
        dw $0008, $0004, $0002, $0001
    }

; ==============================================================================

    ; *$13B90-$13D61 LOCAL
    {
        PHB : PHK : PLB
        
        REP #$20
        
        LDA $78 : AND.w #$00FF : BEQ BRANCH_ALPHA
        
        LDA $24 : CMP.w #$FFFF : BNE BRANCH_ALPHA
        
        LDA.w #$0000
    
    BRANCH_ALPHA:
    
        STA $0E
        
        LDA $20 : SUB $0E : ADD.w #$000C : STA $0E
        
        LDA.w #$0001 : STA $00
        
        LDA $30 : AND.w #$00FF : BNE BRANCH_BETA
        
        JMP $BC60 ; $13C60 IN ROM
    
    BRANCH_BETA:
    
        STZ $04
        
        CMP.w #$0080 : BCC BRANCH_GAMMA
        
        EOR.w #$00FF : INC A
        
        DEC $00 : DEC $00
    
    BRANCH_GAMMA:
    
        STA $02
        
        STZ $08
    
    BRANCH_THETA:
    
        LDA $30 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_DELTA
        
        LDA $0618 : CMP $0E : BCC BRANCH_EPSILON
        
        LDY.b #$00
        
        BRA BRANCH_ZETA
    
    BRANCH_DELTA:
    
        LDA $0E : CMP $061A : BCC BRANCH_EPSILON
        
        LDY.b #$02
    
    BRANCH_ZETA:
    
        LDX.b #$06
        
        JSR $BD62 ; $13D62 IN ROM
    
    BRANCH_EPSILON:
    
        DEC $02 : BNE BRANCH_THETA
        
        LDA $04 : STA $069E
        
        LDX $8C
        
        CPX.w #$97 : BEQ BRANCH_IOTA
        CPX.b #$9D : BEQ BRANCH_IOTA
        
        LDA $04 : BEQ BRANCH_IOTA
        
        STZ $00
        
        LSR A : ROR $00
        
        LDX $8C
        
        CPX.b #$B5 : BEQ BRANCH_KAPPA
        CPX.b #$BE : BNE BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        LSR A : ROR $00 : CMP.w #$3000 : BCC BRANCH_MU
        
        ORA.w #$F000
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA:
    
        CMP.w #$7000 : BCC BRANCH_MU
        
        ORA.w #$F000
    
    BRANCH_MU:
    
        STA $06
        
        LDA $0622 : ADD $00 : STA $0622
        
        LDA $E6 : ADC $06 : STA $E6
        
        LDA $8A : AND.w #$003F : CMP.w #$001B : BNE BRANCH_IOTA
        
        LDA.w #$0600 : CMP $E6 : BCC BRANCH_NU
        
        STA $E6
    
    BRANCH_NU:
    
        LDA.w #$06C0 : CMP $E6 : BCS BRANCH_IOTA
        
        STA $E6
    
    ; *$13C60 ALTERNATE ENTRY POINT
    BRANCH_IOTA:
    
        LDA $22 : ADD.w #$0008 : STA $0E
        
        LDA.w #$0001 : STA $00
        
        LDA $31 : AND.w #$00FF : BNE BRANCH_XI
        
        JMP $BCFB ; $13CFB IN ROM
    
    BRANCH_XI:
    
        STZ $04
        
        CMP.w #$0080 : BCC BRANCH_OMICRON
        
        EOR.w #$00FF : INC A : DEC $00 : DEC $00
    
    BRANCH_OMICRON:
    
        STA $02
        
        LDX.b #$04 : STX.b $08
    
    BRANCH_TAU:
    
        LDA $31 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_PI
        
        LDA $061C : CMP $0E : BCC BRANCH_RHO
        
        LDY.b #$04
        
        BRA BRANCH_SIGMA
    
    BRANCH_PI:
    
        LDA $0E : CMP $061E : BCC BRANCH_RHO
        
        LDY.b #$06
    
    BRANCH_SIGMA:
    
        LDX.b #$00
        
        JSR $BD62 ; $13D62 IN ROM
    
    BRANCH_RHO:
    
        DEC $02 : BNE BRANCH_TAU
        
        LDA $04 : STA $069F
        
        LDX $8C
        
        CPX.b #$97 : BEQ BRANCH_UPSILON
        CPX.b #$9D : BEQ BRANCH_UPSILON
        
        LDA $04 : BEQ BRANCH_UPSILON
        
        STZ $00 : LSR A : ROR $00
        
        LDX $8C
        
        CPX.b #$95 : BEQ BRANCH_PHI
        CPX.b #$9E : BNE BRANCH_CHI
    
    BRANCH_PHI:
    
        LSR A : ROR $00 : CMP.w #$3000 : BCC BRANCH_PSI
        
        ORA.w #$F000
        
        BRA BRANCH_PSI
    
    BRANCH_CHI:
    
        CMP.w #$7000 : BCC BRANCH_PSI
        
        ORA.w #$F000
    
    BRANCH_PSI:
    
        STA $06
        
        LDA $0620 : ADD $00 : STA $0620
        
        LDA $E0 : ADC $06 : STA $E0
    
    ; *$13CFB ALTERNATE ENTRY POINT
    BRANCH_UPSILON:
    
        LDX $8A : CPX.b #$47 : BEQ BRANCH_OMEGA
        
        LDX $8C
        
        CPX.b #$9C : BEQ BRANCH_ALTIMA
        CPX.b #$97 : BEQ BRANCH_ULTIMA
        CPX.b #$9D : BNE BRANCH_OMEGA
    
    BRANCH_ULTIMA:
    
        LDA $0622 : ADD.w #$2000 : STA $0622
        
        LDA $E6 : ADC.w #$0000 : STA $E6
        
        LDA $0620 : ADD.w #$2000 : STA $0620
        
        LDA $E0 : ADC.w #$0000 : STA $E0
        
        BRA BRANCH_OMEGA
    
    BRANCH_ALTIMA:
    
        LDA $0622 : SUB.w #$2000 : STA $0622
        
        LDA $E6 : SBC.w #$0000 : ADD $069E : STA $E6
        
        LDA $E2 : STA $E0
    
    BRANCH_OMEGA:
    
        LDA $A0 : CMP.w #$0181 : BNE BRANCH_OPTIMUS
        
        LDA $E8 : ORA.w #$0100 : STA $E6
        
        LDA $E2 : STA $E0
    
    BRANCH_OPTIMUS:
    
        SEP #$20
        
        PLB
        
        RTS
    }

; ==============================================================================

    ; *$13D62-$13DBF LOCAL
    {
        ; Compare X or Y scroll coordinate to the current position coordinate
        LDA $E2, X : CMP $0600, Y : BNE BRANCH_ALPHA
        
        TYA : EOR.w #$0002 : TAX
        
        ; clears out both $0624 and $0626 (this is a silly trick, they could
        ; have just done STZ $0624 : STZ $0626)
        LDA.w #$0000 : STA $0624, Y : STA $0624, X
        
        RTS
    
    BRANCH_ALPHA:
    
        ; updating a number of coordinates, including the scroll register mirror.
        ADD $00 : STA $E2, X
        
        LDA $04 : ADD $00 : STA $04
        
        LDX $08 : LDA $061A, X : ADD $00 : STA $061A, X : INC #2 : STA $0618, X    
        
        TYA : EOR.w #$0002 : TAX
        
        ; a coordinate that is not on the 16 pixel grid
        LDA $0624, Y : INC A : STA $0624, Y : CMP.w #$0010 : BMI .notGrid
        
        SUB.w #$0010 : STA $0624, Y
        
        ; Sets the side (east , north, etc) the tilemap needs to be updated on.
        
        LDA $BB88, Y : ORA $0416 : STA $0416
    
    .notGrid
    
        ; $0624,X = -($0624,Y)
        LDA.w #$0000 : SUB $0624, Y : STA $0624, X
        
        RTS
    }

    ; $13DC0-$13DC7 DATA
    {
        dw $0000, $0100, $0100, $0000
    }

; ==============================================================================

    ; *$13DC8-$13DD9 LOCAL
    {
        ASL #2 : TAY
        
        LDX.b #$00
    
    .nextDirection
    
        LDA $BDC0, Y : STA $0614, X
        
        INX #2 : CPX.b #$04 : BNE .nextDirection
        
        RTS
    }

    ; $13DDA-$13DE1 DATA
    {
        dw $0000, $0110, $0100, $0010
    }

; ==============================================================================

    ; *$13DE2-$13DF2 LOCAL
    {
        ASL A : TAY
        
        LDX.b #$00
    
    .nextDirection
    
        LDA $BDDA, Y : STA $0610, X
        
        INY
        
        INX : CPX.b #$04 : BNE .nextDirection
        
        RTS
    }

; ==============================================================================

    ; $13DF3-$13E02 DATA
    {
        dw 4, -4, 4, -4
        
    ; $13DFB
    
        dw $0034, $0034, $003B, $003A
    }

; ==============================================================================

    ; *$13E03-$13E6C JUMP LOCATION
    {
        PHB : PHK : PLB
        
        INC $0126
        
        ; direction of the transition.
        LDA $0418 : ASL A : TAY
        
        REP #$20
        
        STZ $011A
        STZ $011C
        
        LDX.b #$00
        
        CPY.b #$04 : BCS .horizontalScrolling
        
        ; operate on the vertical scroll registers
        LDX.b #$06
    
    .horizontalScrolling
    
        LDA $E2, X : ADD $BDF3, Y : AND.w #$FFFE : STA $E2, X : STA $E0, X : STA $00
        
        LDX.b #$00
        
        CPY.b #$04 : BCC .verticalScrolling
        
        LDX.b #$02
    
    .verticalScrolling ; ???? is this name correct?
    
        LDA $0126 : AND.w #$00FF : CMP $BDFB, Y : BCC BRANCH_GAMMA
        
        LDA $20, X : ADD $BDF3, Y : STA $20, X
    
    BRANCH_GAMMA:
    
        ; check the scroll register mirror against the target scroll value
        LDA $00 : AND.w #$01FC : CMP $0610, Y : BNE BRANCH_DELTA
        
        SEP #$20
        
        JSL $02B8CB ; $138CB IN ROM
        
        PLB
        
        INC $B0
        
        STZ $0126
        
        LDA $11 : CMP.b #$02 : BNE BRANCH_EPSILON
        
        JSL $0091C4 ; $11C4 IN ROM
        
        RTS
    
    BRANCH_DELTA:
    
        PLB
        
        SEP #$20
    
    BRANCH_EPSILON:
    
        RTS
    }

    ; $13E6D-$13E74 DATA

; ==============================================================================

    ; *$13E75-$13EB9 JUMP LOCATION
    StraightStairs_10:
    {
        PHB : PHK : PLB
        
        LDA.b #$0C : STA $4B : STA $02F9
        
        LDA $0418 : ASL A : TAX
        
        REP #$20
        
        LDA $E8 : ADD $BDF3, X : AND.w #$FFFC : STA $E8 : STA $E6
        
        AND.w #$01FC : CMP $0610, X : BNE .alpha
        
        LDY $11 : CPY.b #$12 : BCC .beta
        
        INX #4
    
    .beta
    
        LDA $20 : ADD $BE6D, X : STA $20
        
        SEP #$20
        
        STZ $4B
        STZ $02F9
        
        INC $B0
    
    .alpha
    
        SEP #$20
        
        PLB
        
        RTS
    }

; ==============================================================================

    ; $13EBA-$13FF9 DATA

    ; *$13FFA-$14000 BRANCH LOCATION
    {
        SEP #$20
        
        PLB
        
        LDX $0410
        
        RTS
    }

    ; *$14001-$140C2 LOCAL
    {
        PHB : PHK : PLB
        
        INC $0126
        
        LDA $0418 : ASL A : TAY
        
        LDX.b #$01
        
        CPY.b #$04 : BCS .horizScroll
        
        LDX.b #$00
    
    .horizScroll
    
        LDA $BEBA, Y : STA $069E, X
        
        REP #$20
        
        PHY
        
        LDX.b #$00
        
        CPY.b #$04 : BCS .horizScroll2
        
        ; Affect the Y scroll offset instead
        LDX.b #$06
    
    .horizScroll2
    
        LDA $E2, X : ADD $BEBA, Y : STA $E2, X
        
        ; Hyrule Castle and Pyramid of Power have special BG1 overlays 
        ; that must remain in fixed scroll position
        LDY $8A
        
        CPY.b #$1B : BEQ .dontMoveBg1
        CPY.b #$5B : BEQ .dontMoveBg1
        
        STA $E0, X
    
    .dontMoveBg1
    
        STA $00
        
        PLY
        
        LDX.b #$00
        
        CPY.b #$04 : BCC .verticalScroll
        
        LDX.b #$02
    
    .verticalScroll
    
        LDA $0126 : AND.w #$00FF : CMP $BFF2, Y : BCC .dontMoveLink
        
        LDA $20, X : ADD $BEBA, Y : STA $20, X
    
    .dontMoveLink
    
        ; return
        LDA $00 : CMP $0610, Y : BNE BRANCH_$13FFA
        
        LDA $0418 : AND.w #$00FF : BNE .notUpScroll
        
        LDA $E8 : SUB.w #$0002 : STA $E8
    
    .notUpScroll
    
        ; Snap Link's coordinate to an 8-pixel grid
        LDA $20, X : AND.w #$FFF8 : STA $20, X
        
        ADD $BECA, Y : PHA
        
        ; X = 0x00 or 0x04
        TXA : ASL A : TAX
        
        PLA : ADD.w #$000B : STA $061A, X
        
        INC #2 : STA $0618, X
        
        PHX
        
        LDX.b #$00
        
        LDA $0712 : BEQ .largeOwMap
        
        INX #2
    
    .largeOwMap
    
        LDA $0700 : ADD $A83C, Y : TAY
        
        JSR $C0C3 ; $140C3 IN ROM
        
        PLX
        
        STZ $0624, X : STZ $0626, X
        
        SEP #$20
        
        LDA.b #$01 : STA $0ABF
        
        LDX $0410
        
        ; Move on to next submodule
        INC $11
        
        STZ $B0
        STZ $0126
        
        PLB
        
        LDA $00
        
        PHA : PHX
        
        ; $4AFD6 IN ROM
        JSL InitSpriteSlots
        
        PLX : PLA 
        
        RTS
    }

; =============================================

    ; *$140C3-$140F7 LOCAL
    {
        ; Inputs:
        ; Y - an overworld area number * 2
        ; X - 0 for small map, 2 for large map
        
        LDA $A8C4, Y : STA $0600 : ADD $BFE2, X : STA $0602
        LDA $A944, Y : STA $0604 : ADD $BFE6, X : STA $0606
        LDA $BEE2, Y : STA $0610 : ADD $BFEA, X : STA $0612
        LDA $BF62, Y : STA $0614 : ADD $BFEE, X : STA $0616
        
        RTS
    }

; ==============================================================================

    ; $140F8-$141FB DATA
    {
        db $00, $05, $0A, $0F
    }
    
    ; $140FC-$1410F DATA
    {
        
    }

; ==============================================================================

    ; *$14110-$1412B JUMP LOCATION
    {
        ; this routine apparently positions link after the transition has occurred?
        JSR $8B0C   ; $10B0C IN ROM ; erases special effects and resets dash status
        JSR $C12C   ; $1412C IN ROM
        
        INC $B0
        
        REP #$30
        
        LDA $A0 : ASL A : TAX
        
        ; save current quadrant status to save game buffer
        LDA $7EF000, X : ORA $0408 : STA $7EF000, X
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$1412C-$14161 LOCAL
    {
        LDA $0418 : AND.b #$02
        
        PHA
        
        JSR $C1E5 ; $141E5 IN ROM
        
        LDX $0418
        
        ; the above subroutine returns a tile type in the A register
        CMP.b #$02 : BNE .notDefault
        
        LDA.b #$01
    
    .notDefault
    
        CMP.b #$04 : BNE .beta
        
        LDA.b #$02
    
    .beta
    
        ADD $02C0F8, X : TAX
        
        LDY.b #$08
        
        LDA $02C0FC, X : BPL .positive
        
        LDY.b #$F8
    
    .positive
    
        ; Y = 8 or -8, depending
        STY $00
        
        SUB $00
        
        PLY
        
        STA $0020, Y
        
        LDX.b #$00 : STX $4B
        
        RTS
    }

; =====================================================

    ; *$14162-$14190 JUMP LOCATION
    {
        LDA $7EC005 : ORA $7EC006 : BEQ .noDarkTransition
        
        JSL PaletteFilter.doFiltering
    
    ; *$14170 ALTERNATE ENTRY POINT
    .noDarkTransition
    
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        ; $14191 IN ROM
        JSR $C191 : BCC BRANCH_BETA
        
        LDX $4E
        
        CPX.b #$02 : BEQ BRANCH_GAMMA
        CPX.b #$04 : BNE BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        STZ $6C
    
    BRANCH_DELTA:
    
        STZ $6F
        STZ $49
        STZ $4E
        STZ $0418
        
        INC $B0
    
    BRANCH_BETA:
    
        RTS
    }

; =====================================================

    ; *$14191-$141E4 LOCAL
    {
        LDX $0418
        
        ; Add to a multiple of 4 based on the current direction.
        LDA $4E : ADD $02C0F8, X : TAX
        
        LDY.b #$02
        
        LDA $0418 : LSR A : BCC BRANCH_ALPHA
        
        LDY.b #$FE
    
    BRANCH_ALPHA:
    
        STY $00
        
        LSR A : BCS BRANCH_BETA
        
        LDY.b #$FF
        
        LDA $00 : BMI BRANCH_GAMMA
        
        INX
    
    BRANCH_GAMMA:
    
        ADD $20 : STA $20
        
        TYA : ADC $21 : STA $21
        
        LDA $20 : AND.b #$FE : CMP $02C0FC, X : BEQ BRANCH_DELTA
    
    BRANCH_ZETA:
    
        CLC
        
        RTS
    
    BRANCH_BETA:
    
        LDY.b #$FF
        
        LDA $00 : BMI BRANCH_EPSILON
        
        INX
    
    BRANCH_EPSILON:
    
              ADD $22 : STA $22
        TYA : ADC $23 : STA $23
        
        LDA $22 : AND.b #$FE : CMP $02C0FC, X : BNE BRANCH_ZETA
    
    BRANCH_DELTA:
    
        SEC
        
        RTS
    }

    ; *$141E5-$1423D LOCAL
    {
        REP #$20
        
        LDA $20 : ADD.w #$000C : AND.w #$01F8 : ASL #3 : STA $00
        LDA $22 : ADD.w #$0008 : AND.w #$01F8 : LSR #3 : ORA $00
        
        LDX $EE : BEQ .onBg2
        
        ADD.w #$1000
    
    .onBg2
    
        REP #$10
        
        TAX
        
        ; grab tile attribute
        LDA $7F2000, X
        
        SEP #$30
        
        LDY.b #$00
        
        CMP.b #$00 : BEQ .beta
        CMP.b #$09 : BEQ .beta
        
        INY ; Y = 1
        
        AND.b #$8E : CMP.b #$80 : BEQ .beta
        
        INY ; Y = 2
        
        CMP.b #$82 : BEQ .beta
        
        INY ; Y = 3
        
        CMP.b #$84 : BEQ .beta
        CMP.b #$88 : BEQ .beta
        
        INY ; Y = 4
        
        CMP.b #$86 : BEQ .beta
        
        DEY #2 ; Y = 2
    
    .beta
    
        STY $4E
        
        TYA
        
        RTS
    }

    ; $1423E-$14241 DATA

    ; *$14242-$142A3 JUMP LOCATION
    {
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        LDY.b #$02
        
        LDA $069C : LSR A : BCS BRANCH_ALPHA
        
        LDY.b #$FE
    
    BRANCH_ALPHA:
    
        STY $00
        
        LDX.b #$02
        
        LSR A : BCS BRANCH_BETA
        
        LDX.b #$00
    
    BRANCH_BETA:
    
        LDY.b #$FF
        
        LDA $00 : BMI BRANCH_GAMMA
        
        INY
    
    BRANCH_GAMMA:
    
        ADD $20, X : STA $20, X
        
        TYA : ADC $21, X : STA $21, X
        
        LDA $20, X
        
        LDX $069C
        
        AND.b #$FE : CMP $02C23E, X : BNE BRANCH_DELTA
        
        ; return to normal overworld operating mode
        STZ $11
        STZ $B0
        
        LDX $8A
        
        LDA $7F5B00, X : LSR #4 : STA $012D
        
        LDA $0130 : CMP.b #$F1 : BNE BRANCH_DELTA
        
        LDA $7F5B00, X : AND.b #$0F : STA $012C
    
    BRANCH_DELTA:
    
        JSR $BB90 ; $13B90 IN ROM
        
        LDA $0416 : BEQ BRANCH_EPSILON
        
        JSR Overworld_ScrollMap ; $17273 IN ROM
    
    BRANCH_EPSILON:
    
        RTS
    }

    ; *$142A4-$142E3 JUMP LOCATION
    {
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        LDY.b #$01
        
        LDA $069C : LSR A : BCS BRANCH_ALPHA
        
        LDY.b #$FF
    
    BRANCH_ALPHA:
    
        STY $00
        
        LDX.b #$02
        
        LSR A : BCS BRANCH_BETA
        
        LDX.b #$00
    
    BRANCH_BETA:
    
        LDY.b #$FF
        
        LDA $00 : BMI BRANCH_GAMMA
        
        INY
    
    BRANCH_GAMMA:
    
              ADD $20, X : STA $20, X
        TYA : ADC $21, X : STA $21, X
        
        TXA : LSR A : TAX
        
        LDA $00 : STA $30, X
        
        DEC $069A : BNE BRANCH_DELTA
        
        LDA.b #$09 : STA $10
        
        STZ $11
        STZ $B0
    
    BRANCH_DELTA:
    
        JSR $BB90 ; $13B90 IN ROM
        
        RTS
    }

; =========================================

    ; *$142E4-$14302 JUMP LOCATION
    Overworld_ResetMosaic:
    {
        ; if(($7EC007 & 0x01) == 0)
        LDA $7EC007 : LSR A : BCC .init
    
    ; *$142EB ALTERNATE ENTRY POINT
    .alwaysIncrease
    
        LDA $7EC011 : ADD.b #$10 : STA $7EC011
    
    ; *$142F6 ALTERNATE ENTRY POINT
    .init
    
        ; The purpose of this is ensure that the priority bit is set
        LDA.b #$09 : STA $94
        
        ; enable mosaic on BG1, BG2, and BG3 and set the mosaic level to 0 (for startsrs)
        LDA $7EC011 : ORA.b #$07 : STA $95
        
        RTS
    }

; =========================================

; $14303-$14462 DATA

; =========================================

    ; *$14463-$144BF LONG
    Overworld_SetSongList:
    {
        ; Interesting note on this routine:
        ; There's actually four sets of song / sound effect data
        ; 1st - before getting Fighter Sword
        ; 2nd - after escaping with Zelda
        ; 3rd - after obtaining Master Sword
        ; 4th - after beating Agahnim
        
        PHB : PHK : PLB
        
        REP #$10
        
        LDA.b #$02 : STA $00
        
        LDX.w #$0000
        LDY.w #$00C0
        
        ; See if we've already beaten agahnim
        LDA $7EF3C5 : CMP.b #$03 : BCS .writeLightWorldSongs
        
        LDY.b #$0080
        
        LDA $7EF359 : CMP.b #$02 : BCS .writeLightWorldSongs
        
        LDA.b #$05 : STA $00
        
        LDY.w #$0040
        
        LDA $7EF3C5 : CMP.b #$02 : BCS .writeLightWorldSongs
        
        LDY.w #$0000
    
    .writeLightWorldSongs
    .lightWorldLoop
    
        LDA $C303, Y : STA $7F5B00, X
        
        INY
        
        INX : CPX.w #$0040 : BNE .lightWorldLoop
        
        LDY.w #$0000
    
    .darkWorldLoop
    
        LDA $C403, Y : STA $7F5B00, X
        
        INX
        
        INY : CPY.w #$0060 : BNE .darkWorldLoop
        
        ; The song for the master sword grove depends on $7EF3C5 in the same
        ; way the other light world songs do.
        LDA $00 : STA $7F5B80
        
        SEP #$10
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $144C0-$144FF NULL

    ; *$14500-$14532 LOCAL
    Intro_InitBgSettings:
    {
        ; Setini variable. No interlacing and such.
        STZ $2133
        
        ; Give BG1 priority, and we’re in mode 1.
        LDA.b #$09 : STA $94
        
        ; No mosaic effect.
        STZ $95
        
        ; BG1 Tile map begins at $800 in VRAM. Tile map is 64x64.
        LDA.b #$13 : STA $2107
        
        ; BG2 Tile map begins at $0 in VRAM. Tile map is 64x64.
        LDA.b #$03 : STA $2108
        
        ; BG3 Tile map begins at $6000 in VRAM. Tile map is 64x64.
        LDA.b #$63 : STA $2109
        
        ; BG1 Character Data is at $4000 in VRAM. Same for BG2
        LDA.b #$22 : STA $210B
        
        ; BG3 Character Data is at $E000 in VRAM. BG4 is at $0
        ; Note: BG4 is never used in the game
        LDA.b #$07 : STA $210C
        
        ; Means that only the backdrop will be participating in color addition
        ; currently.
        LDA.b #$20 : STA $9A
        
        ; Set fixed color to neutral (no fixed color)
        LDA.b #$20 : STA $9C
        LDA.b #$40 : STA $9D
        LDA.b #$80 : STA $9E
        
        RTS
    }

; ==============================================================================

    ; *$14533-$14545 LONG
    Attract_LoadDungeonRoom:
    {
        ; Loads an entrance
        
        STA $010E
        
        JSR Dungeon_LoadEntrance
        
        STZ $045A : STZ $0458
        
        JSR Dungeon_LoadAndDrawRoom
        JSR Dungeon_ResetTorchBackgroundAndPlayer
        
        RTL
    }

; ==============================================================================

    ; *$14546-$1457A LONG
    Attract_LoadDungeonGfxAndTiles:
    {
        STX $0AA3
        STA $0AA1
        STA $0AA2
        
        JSL InitTilesets
        
        LDA.b #$02 : STA $0AA9
        
        INC $15
        
        JSL Palette_BgAndFixedColor ; $755F4 in Rom
    
    ; *$1455E ALTERNATE ENTRY POINT
    .justPalettes
    
        JSL Palette_SpriteAux3
        JSL Palette_MainSpr
        JSL Palette_SpriteAux1
        JSL Palette_SpriteAux2
        JSL Palette_MiscSpr_justSp6
        JSL Palette_Hud
        JSL Palette_DungBgMain
        
        RTL
    }

; ==============================================================================

    ; *$1457B-$145B1 LOCAL
    Dungeon_LoadAndDrawRoom:
    {
        ; Calls routines that 1. Load the room's header.
        ; 2. Load dungeon objects into a temporary tile map
        ; Then this function writes those into a tile map 
        
        LDA $9B : PHA
        
        STZ $420C
        STZ $9B
        
        JSL Dungeon_LoadRoom
        
        STZ $0418
        STZ $045C
        STZ $0200
    
    .next_quadrant
    
        JSL $0091D3 ; $11D3 IN ROM ; Draws the dungeons.
        JSL $0090E3 ; $10E3 IN ROM ; Since we are in forced v-blank
        JSL $00913F ; $113F IN ROM ; We can do these DMA transfers
        JSL $0090E3 ; $10E3 IN ROM
        
        ; Each iteration draws a quadrant on BG1 and BG2
        ; i.e. it draws the tilemaps, which are taken from WRAM.
        LDA $045C : CMP.b #$10 : BNE .next_quadrant
        
        PLA : STA $9B
        
        STZ $17
        STZ $0200
        STZ $B0
        
        RTS
    }

; ==============================================================================

    ; *$145B2-$1462F LOCAL
    Intro_LoadPalettes:
    {
        REP #$20
        
        LDX.b #$00
        
        LDA.w #$0000
    
    .zeroOutPalettes
    
        ; Zeroes out $7EC480-$7EC6FF
        STA $7EC480, X : STA $7EC500, X
        STA $7EC580, X : STA $7EC600, X
        STA $7EC680, X
        
        INX #2 : CPX.b #$80 : BNE .zeroOutPalettes
        
        SEP #$20
        
        LDA.b #$05 : STA $0AB3
        
        LDA.b #$03 : STA $0AB4 : STA $0AB5
        
        LDA.b #$00 : STA $0AB8
        LDA.b #$05 : STA $0AB1
        LDA.b #$0B : STA $0AAC
        
        STZ $0ABD
        STZ $0AA9
        
        JSL Palette_BgAndFixedColor
        JSL Palette_SpriteAux3
        JSL Palette_MainSpr
        JSL Palette_OverworldBgMain 
        JSL Palette_OverworldBgAux1
        JSL Palette_OverworldBgAux2
        JSL Palette_OverworldBgAux3
        JSL Palette_MiscSpr_justSp6 
        JSL Palette_Hud
        
        REP #$20
        
        LDX.b #$00
    
    .copyHalfPalette
    
        ; Copies $7EC4D0-8 -> $7EC6B0-8
        LDA $7EC4D0, X : STA $7EC6B0, X
        
        INX #2 : CPX.b #$10 : BNE .copyHalfPalette
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$14630-$1468D LOCAL
    Dungeon_LoadPalettes:
    {
        ; Loads dungeon palettes
        
        STZ $0AA9
        
        JSL Palette_BgAndFixedColor
        JSL Palette_SpriteAux3
        JSL Palette_MainSpr
        JSL Palette_SpriteAux1
        JSL Palette_SpriteAux2
        JSL Palette_Sword
        JSL Palette_Shield
        JSL Palette_MiscSpr
        JSL Palette_ArmorAndGloves
        JSL Palette_Hud
        JSL Palette_DungBgMain
    
    ; *$1465F ALTERNATE ENTRY POINT
    .cacheSettings
    
        ; this alternate entry point can be used for the pre-overworld module    
        
        LDA $0AB6 : STA $7EC20A
        LDA $0AB8 : STA $7EC20B
        LDA $0AB7 : STA $7EC20C
        
        REP #$20
        
        LDA.w #$0002 : STA $7EC009
        LDA.w #$0000 : STA $7EC007
        LDA.w #$0000 : STA $7EC00B
        
        JMP Overworld_CgramAuxToMain
    }

; ==============================================================================

    ; \unused Perhaps was used at one time, but not in the final build.
    ; *$1468E-$14691 LONG
    Overworld_LoadAreaPalettesLong:
    {
        JSR Overworld_LoadAreaPalettes
        
        RTL
    }

; ==============================================================================

    ; *$14692-$146EA LOCAL
    Overworld_LoadAreaPalettes:
    {
        ; Loads overworld palettes (based upon area and world, mainly)
        
        LDX.b #$02
        
        ; Checks for 6 specific areas in the light world (death mountain LW & DW)
        LDA $8A : AND.b #$3F
        
        CMP.b #$03 : BEQ .deathMountain
        CMP.b #$05 : BEQ .deathMountain
        CMP.b #$07 : BEQ .deathMountain
        
        ; Use a different index if we're not on death mountain
        LDX.b #$00
    
    .deathMountain
    
        LDA $8A : AND.b #$40 : BEQ .lightWorld
        
        ; Adjust for the dark world / light world difference
        INX
    
    ; *$146AD ALTERNATE ENTRY POINT
    .lightWorld
    
        ; $0AB3 = 0 - LW 1 - DW, 2 - LW death mountain, 3 - DW death mountain
        STX $0AB3
        
        STZ $0AA9
        
        JSL Palette_MainSpr         ; $DEC9E IN ROM; load SP1 through SP4
        JSL Palette_MiscSpr         ; $DED6E IN ROM; load SP0 (2nd half) and SP6 (2nd half)
        JSL Palette_SpriteAux1      ; $DECC5 IN ROM; load SP5 (1st half)
        JSL Palette_SpriteAux2      ; $DECE4 IN ROM; load SP6 (1st half)
        JSL Palette_Sword           ; $DED03 IN ROM; load SP5 (2nd half, 1st 3 colors), which is the sword palette
        JSL Palette_Shield          ; $DED29 IN ROM; load SP5 (2nd half, next 4 colors), which is the shield
        JSL Palette_ArmorAndGloves  ; $DEDF9 IN ROM; load SP7 (full) Link's whole palette, including Armor
        
        LDX.b #$01
        
        LDA $7EF3CA : AND.b #$40 : BEQ .lightWorld2
        
        LDX.b #$03
    
    .lightWorld2
    
        STX $0AAC
        
        JSL Palette_SpriteAux3      ; $DEC77 IN ROM; load SP0 (first half) (or SP7 (first half))
        JSL Palette_Hud             ; $DEE52 IN ROM; load BP0 and BP1 (first halves)
        JSL Palette_OverworldBgMain ; $DEEC7 IN ROM; load BP2 through BP5 (first halves)
        
        RTS
    }

; =============================================

    ; *$146EB-$14768 LOCAL
    
    {
        REP #$20
        
        LDX.b #$00
        LDA.w #$0000
    
    .zero4bppPalettes
    
        STA $7EC540, X : STA $7EC580, X : STA $7EC5C0, X : STA $7EC600, X 
        STA $7EC640, X : STA $7EC680, X : STA $7EC6C0, X
        
        INX #2 : CPX.b #$40 : BNE .zero4bppPalettes
        
        LDX.b #$00
    
    .copyFromAuxPalette
    
        ; looks like it copies all the hud palettes (2bpp) and two sprite palettes (4bpp)
        LDA $7EC300, X : STA $7EC500, X
        LDA $7EC310, X : STA $7EC510, X
        LDA $7EC320, X : STA $7EC520, X
        LDA $7EC330, X : STA $7EC530, X
        LDA $7EC4B0, X : STA $7EC6B0, X
        LDA $7EC4D0, X : STA $7EC6D0, X
        LDA $7EC4E0, X : STA $7EC6E0, X
        LDA $7EC4F0, X : STA $7EC6F0, X
        
        INX #2 : CPX.b #$10 : BNE .copyFromAuxPalette
        
        SEP #$20
        
        ; Set mosaic settings to full
        LDA.b #$F7 : STA $95 : STA $7EC011
        
        ; Tell the game to update CGRAM this frame
        INC $15 
        
        RTS
    }

; ==============================================================================

    ; $14769-$147B7 LOCAL
    Overworld_CgramAuxToMain:
    {
        ; copies the auxiliary CGRAM buffer to the main one and causes NMI to reupload the palette.
        
        REP #$20
        
        LDX.b #$00
    
    .loop
    
        LDA $7EC300, X : STA $7EC500, X
        LDA $7EC340, X : STA $7EC540, X
        LDA $7EC380, X : STA $7EC580, X
        LDA $7EC3C0, X : STA $7EC5C0, X
        LDA $7EC400, X : STA $7EC600, X
        LDA $7EC440, X : STA $7EC640, X
        LDA $7EC480, X : STA $7EC680, X
        LDA $7EC4C0, X : STA $7EC6C0, X
        
        INX #2 : CPX.b #$40 : BNE .loop
        
        SEP #$20
        
        ; tell NMI to upload new CGRAM data
        INC $15
        
        RTS
    }

; ==============================================================================
    
    ; *$147B8-$147F1 LONG
    {
        ; seems mode7 related... (hdma for mode 7 manipulation, I mean)
        
        PHB : PHK : PLB
        
        ; Set up this channel we'll be using for hdma (spotlight?)
        LDX.b #$04
    
    .configure_dma_channel
    
        LDA $C807, X : STA $4370, X
        
        DEX : BPL .configure_dma_channel
        
        LDA.b #$00 : STA $4377
        
        LDA.b #$33 : STA $96
        LDA.b #$03 : STA $97
        LDA.b #$33 : STA $98
        
        LDA $1C : STA $1E
        LDA $1D : STA $1F
        
        LDA.b #$80 : STA $9B
        
        ; \optimize Would be faster with 16-bit zeroing.
        REP #$10
        
        LDX.w #$01DF
    
    .zeroing_spotlight_buffer
    
        STZ $1B00, X
        
        DEX : BPL .zeroing_spotlight_buffer
        
        SEP #$10
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \unused(not totally verified yet)
    ; $147F2-$158B2 DATA (entrance data?)
    {
        ; seems to be unreferenced data, but what is interesting is it appears to be some sort
        ; of .... disabled hdma table (note the presence of $1B00 and $1BF0 in this data)
        ; this information appears to be unused in the final product.
        dl $FF0001, $FF0001, $FF0001, $FF0001, $000081,
        dl $260100
        
        dw $1B00
        db $00
    
    ; $14807
        dw $2641
        db $0C
        
        dw $02C8
        db $F8
        
        dw $1B00
        db $F8
        
        dw $1BF0
        db $00
    }
    
; ==============================================================================

    incsrc "entrance_data.asm"
    
; ==============================================================================

    ; *$158B3-$15B6D LOCAL
    Dungeon_LoadEntrance:
    {
        ; Routine initializes dungeons
        
        PHB : PHK : PLB
        
        ; Link is officially in a dungeon now.
        LDA.b #$01 : STA $1B
        
        ; Did Link just die and he's being respawned in this dungeon?
        LDA $010A : BEQ .notDeathReload
        
        STZ $010A
        
        ; if Link died in this dungeon, presumably all these variables are still cached
        ; anyway
        JMP .skipCaching
    
    .notDeathReload
    
        REP #$20
        
        LDA $040A : STA $7EC140 ; Mirror the aux overworld area number
        
        LDA $1C   : STA $7EC142 ; Mirror the main screen designation
        
        LDA $E8   : STA $7EC144 ; Mirror BG1 V scroll
        LDA $E2   : STA $7EC146 ; Mirror BG1 H scroll
        
        LDA $20   : STA $7EC148 ; Mirror Link's Y coordinate
        LDA $22   : STA $7EC14A ; Mirror Link's X coordinate
        
        LDA $0618 : STA $7EC150 ; Mirror Camera Y coord lower bound. 
        LDA $061C : STA $7EC152 ; Mirror Camera X coord lower bound.
        
        LDA $8A   : STA $7EC14C ; Mirror the overworld area number
        
        LDA $84   : STA $7EC14E ; Not sure about this one.
        
        STZ $8A
        STZ $8C
        
        LDA $0600 : STA $7EC154
        LDA $0602 : STA $7EC156
        LDA $0604 : STA $7EC158
        LDA $0606 : STA $7EC15A
        
        LDA $0610 : STA $7EC15C
        LDA $0612 : STA $7EC15E
        LDA $0614 : STA $7EC160
        LDA $0616 : STA $7EC162
        
        LDA $0624 : STA $7EC16A
        LDA $0626 : STA $7EC16C
        LDA $0628 : STA $7EC16E
        LDA $062A : STA $7EC170
        
        SEP #$20
        
        ; cache graphics settings
        LDA $0AA0 : STA $7EC164
        LDA $0AA1 : STA $7EC165
        LDA $0AA2 : STA $7EC166
        LDA $0AA3 : STA $7EC167
        
        REP #$30
    
    .skipCaching
    
        STZ $011A : STZ $011C : STZ $010A
        
        ; Check which character is following Link. Check if it’s the old man
        ; Yep, must use an entrance
        LDA $7EF3CC : CMP.w #$0004 : BEQ .useStartingPointEntrance
        
        LDA $04AA : BEQ .notSaveAndContinue
    
    .useStartingPointEntrance
    
        ; Load using an starting point entrance index instead.
        JMP Dungeon_LoadStartingPoint
    
    .notSaveAndContinue
    
        ; Use a normal entrance instead
        LDA $010E : AND.w #$00FF : ASL A : TAX : ASL #2 : TAY
        
        LDA $C813, X : STA $A0 : STA $048E
        
        LDA $CE4F, X : STA $E8 : STA $E6 : STA $0122 : STA $0124
        
        LDA $CD45, X : STA $E2 : STA $E0 : STA $011E : STA $0120
        
        ; Has Link woken up yet?
        LDA $7EF3C5 : BEQ .beforeUncleGear
        
        ; $14F59, X THAT IS
        LDA $CF59, X : STA $20
        LDA $D063, X : STA $22
    
    .beforeUncleGear
    
        LDA $D16D, X : STA $0618 : INC #2 : STA $061A
        LDA $D277, X : STA $061C : INC #2 : STA $061E
        
        LDA.w #$01F8 : STA $EC
        
        LDA $D724, X : STA $0696 : STZ $0698
        
        LDA.w #$0000 : STA $0610
        LDA.w #$0110 : STA $0612
        LDA.w #$0000 : STA $0614
        LDA.w #$0100 : STA $0616
        
        LDA $010E : AND.w #$00FF : TAX
        
        SEP #$20
        
        ; HM calls these scroll edges. Must investigate.
        LDA $C91D, Y : STA $0601
        LDA $C91E, Y : STA $0603
        LDA $C91F, Y : STA $0605
        LDA $C920, Y : STA $0607
        LDA $C921, Y : STA $0609
        LDA $C922, Y : STA $060B
        LDA $C923, Y : STA $060D
        LDA $C924, Y : STA $060F
        
        STZ $0600 : STZ $0602
        
        LDA.b #$10 : STA $0604 : STA $0606 : STA $0608 : STA $060A : STA $060C : STA $060E
        
        ; Make it so Link faces south (down) at most entrances.
        LDA.b #$02
        
        CPX.w #$0000 : BEQ .linkFacesSouth
        
        ; one special cases where Link enters from the top. potential for an edit here ;)
        CPX.w #$0043 : BEQ .linkFacesSouth
        
        LDA.b #$00 ; Make it so Link faces north
    
    .linkFacesSouth
    
        STA $2F
        
        ; Main blockset value
        LDA $D381, X : STA $0AA1
        
        ; Music value. Is it the beginning music?
        LDA $D82E, X : STA $0132 : CMP.b #$03 : BNE .notBeginningMusic
        
        ; Check game status
        ; Is it less than first part?
        LDA $7EF3C5 : CMP.b #$02 : BCC .haventSavedZelda
        
        ; Play the cave music if it's first or second part.
        LDA.b #$12
    
    .haventSavedZelda
    
        STA $0132
    
    .notBeginningMusic
    
        LDA $D406, X : STA $A4
        
        ; Load the palace number.
        LDA $D48B, X : STA $040C
        
        ; Interestingly enough, this could allow for horizontal doorways?
        LDA $D510, X : STA $6C
        
        ; Set the position that Link starts at.
        LDA $D595, X : LSR #4 : STA $EE
        
        ; Set Pseudo bg level
        LDA $D595, X : AND.b #$0F : STA $0476
        
        LDA $D61A, X : LSR #4     : STA $A6
        LDA $D61A, X : AND.b #$0F : STA $A7
        LDA $D69F, X : LSR #4     : STA $A9
        LDA $D69F, X : AND.b #$0F : STA $AA
        
        LDX $A0 : CPX.w #$0100 : BCC .notExtendedRoom
        
        ; rooms above room 255 apparently can't have multiple floors?
        ; probably b/c they can't utilize exits
        STZ $A4
    
    ; *$15ADB ALTERNATE ENTRY POINT
    .notExtendedRoom
    
        LDA.b #$80 : STA $45 : STA $44
        
        LDA.b #$0F : STA $42 : STA $43
        
        LDA.b #$FF : STA $24 : STA $29
        
        SEP #$30
        
        PLB
        
        ; Make 0x7E the data bank.
        PHB : LDA.b #$7E : PHA : PLB
        
        REP #$20
        
        LDX.b #$00
    
    .loadPushBlocks
    
        ; Note that we are now storing data in bank $7E.
        ; Hence this goes to $7EF940, X
        LDA $04F1DE, X : STA $F940, X
        LDA $04F25E, X : STA $F9C0, X
        LDA $04F2DE, X : STA $FA40, X
        LDA $04F35E, X : STA $FAC0, X
        LDA $04F36A, X : STA $FB40, X
        LDA $04F3EA, X : STA $FBC0, X
        LDA $04F46A, X : STA $FC40, X
        
        INX #2 : CPX.b #$80 : BNE .loadPushBlocks
        
        LDX.b #$3E
        LDA.w #$0000
    
    .resetSecretsObtained
    
        ; $7EF580[0x280] is an array that stores which "secret" items have been obtained
        ; while you're in a dungeon. This is resetting those (either via mirror or reentry to the dungeon world)
        STA $F800, X : STA $F840, X : STA $F880, X : STA $F8C0, X 
        STA $F580, X : STA $F5C0, X : STA $F600, X : STA $F640, X
        STA $F680, X : STA $F6C0, X : STA $F700, X : STA $F740, X
        STA $F780, X : STA $F7C0, X
        
        DEX #2 : BPL .resetSecretsObtained
        
        ; Initial orange/blue barrier state is orange down, blue up (0)
        STA $7EC172
        
        STZ $04BC
        
        SEP #$30
        
        PLB
        
        RTS
    }

    ; *$15B6E-$15C54 DATA - mapped
    {
    .rooms
    
        dw $0104, $0012, $0080, $0055, $0051, $00F0, $00E4
    
    ; $15B7C
    .relativeCoords
    
        db $21, $20, $21, $21, $09, $09, $09, $0A
        db $02, $02, $02, $03, $04, $04, $04, $05
        db $10, $10, $10, $11, $01, $00, $01, $01
        db $0A, $0A, $0A, $0B, $0B, $0A, $0B, $0B
        db $0A, $0A, $0A, $0B, $02, $02, $02, $03
        db $1E, $1E, $1E, $1F, $01, $00, $01, $01
        db $1D, $1C, $1D, $1D, $08, $08, $08, $09
    
    ; $15BB4
    .scrollX
    
        dw $0900, $0480, $00DB, $0A8E, $0280, $0100, $0800
    
    ; $15BC2
    .scrollY
    
        dw $2110, $0231, $1000, $0A03, $0A22, $1E8C, $1D10        
    
    ; $15BD0
    .linkY
    
        dw $0978, $04F8, $0160, $0B06, $02F8, $01A8, $0878        
    
    ; $15BDE
    .linkX
    
        dw $2178, $029C, $1041, $0A70, $0A8F, $1EF8, $1D98
    
    ; $15BEC
    .cameraY
    
        dw $017F, $00FF, $0167, $010D, $00FF, $017F, $007F        
    
    ; $15BFA
    .cameraX
    
        dw $017F, $00A7, $0083, $007B, $009A, $0103, $0187
    
    ; $15C08
    .mainGraphics
    
        db $03, $04, $04, $01, $04, $06, $14
    
    ; $15C0F
    .startingFloor
    
        db $00, $00, $FD, $FF, $01, $00, $00
    
    ; $15C16
    .palace
    
        db $FF, $00, $02, $FF, $02, $FF, $FF
    
    ; $15C1D
    .startingBg
    
        db $00, $00, $00, $01, $00, $00, $01
    
    ; $15C24
    .quadrant1
    
        db $00, $22, $20, $20, $22, $22, $02
    
    ; $15C2B
    .quadrant2
    
        db $02, $00, $10, $10, $00, $10, $02        
    
    ; $15C32
    .doorSettings
    
        dw $0816, $0000, $0000, $0000, $0000, $0000, $0000
    
    ; $15C40
    .associatedEntrance
    
        dw $0000, $0002, $0002, $0032, $0004, $0006, $0030
    
    ; $15C4E
    .song
    
        db $07, $14, $10, $03, $10, $12, $12
    }

    ; *$15C55-$15D89 JUMP LOCATION
    Dungeon_LoadStartingPoint:
    {
        ; An SRAM value that tells us what starting location to use?
        LDA $7EF3C8 : AND.w #$00FF : ASL A : TAX : ASL #2 : TAY
        
        ; Set the entrance
        LDA $DC40, X : STA $010E
        
        ; Load the dungeon room index
        LDA $DB6E, X : STA $A0 : STA $048E
        
        ; Load Camera Y and X coordinates
        LDA $DBC2, X : STA $E8 : STA $E6 : STA $0122 : STA $0124
        LDA $DBB4, X : STA $E2 : STA $E0 : STA $011E : STA $0120
        
        ; You goin' to bed!
        LDA $7EF3C5 : BEQ .veryBeginning
        
        ; Set Link's Y and X coordinates
        LDA $DBD0, X : STA $20
        LDA $DBDE, X : STA $22
    
    .veryBeginning
    
        ; Set camera scroll boundaries
        LDA $DBEC, X : STA $0618 : INC #2 : STA $061A
        LDA $DBFA, X : STA $061C : INC #2 : STA $061E
        
        ; Set coordinate mask
        LDA.w #$01F8 : STA $EC
        
        ; Load the door settings (for use when exiting)
        LDA $DC32, X : STA $0696
        
        ; scroll boundaries for intraroom and interroom transitions
        LDA.w #$0000 : STA $0610
        LDA.w #$0110 : STA $0612
        LDA.w #$0000 : STA $0614
        LDA.w #$0100 : STA $0616
        
        LDA $7EF3C8 : AND.w #$00FF : TAX
        
        SEP #$20
        
        ; set a bunch of quadrant boundaries?
        LDA $DB7C, Y : STA $0601
        LDA $DB7D, Y : STA $0603
        LDA $DB7E, Y : STA $0605
        LDA $DB7F, Y : STA $0607
        LDA $DB80, Y : STA $0609
        LDA $DB81, Y : STA $060B
        LDA $DB82, Y : STA $060D
        LDA $DB83, Y : STA $060F 
        
        STZ $0600 : STZ $0602
        
        LDA.b #$10 : STA $0604 : STA $0606 : STA $0608 : STA $060A : STA $060C : STA $060E
        
        ; Make Link face south
        LDA.b #$02 : STA $2F
        
        ; set main bg graphics 
        LDA $DC08, X : STA $0AA1
        
        ; set starting floor
        LDA $DC0F, X : STA $A4
        
        ; set palace Link is in, if any
        LDA $DC16, X : STA $040C
        
        ; start off by not being in a doorway
        STZ $6C
        
        ; set starting floor level for Link (BG2 or BG1)
        LDA $DC1D, X : LSR #4 : STA $EE
        
        ; set starting speudo bg level
        LDA $DC1D, X : AND.w #$0F : STA $0476
        
        ; set quadrant information
        LDA $DC24, X : LSR #4     : STA $A6
        LDA $DC24, X : AND.b #$0F : STA $A7
        LDA $DC2B, X : LSR #4     : STA $A9
        LDA $DC2B, X : AND.b #$0F : STA $AA
        
        ; set musicical number to play
        LDA $DC4E, X : STA $0132
        
        CPX.w #$0000 : BNE .notVeryStart
        
        LDA $7EF3C5 : BNE .notVeryStart
        
        ; set music variable as to... initiate a load of music data?
        LDA.b #$FF : STA $0132
    
    .notVeryStart
    
        ; disable starting point now (upon save and continue you'll use the associated entrance value)
        STZ $04AA
        
        JMP Dungeon_LoadEntrance_notExtendedRoom
    }

; =============================================

    ; *$164A3-$165D3 LOCAL
    Overworld_LoadExitData:
    {
        ; Loads a bunch of exit data (e.g. Link's coordinates)
        
        ; Data Bank = Program Bank
        PHB : PHK : PLB
        
        ; Set it so that we are outdoors...
        STZ $1B
        
        ; Reset dark room settings? (why we'd do this in the overworld, I dunno)
        STZ $0458
        
        REP #$20
        
        ; something relating to fixed color
        LDA.w #$0000 : STA $7EC017
        
        ; Since we're not in a dungeon, set our palace index to -1
        LDA.w #$00FF : STA $040C
        
        ; Reset the variable that tracks tile modifications to the current area
        STZ $04AC
        
        ; If we're exiting Link's house...
        LDA $A0 : CMP.w #$0104 : BEQ .hasExitData
        
        ; special outdoor areas like Zora falls
        CMP.w #$0180 : BCS .hasExitData
        
        ; Rooms less than 0x0100 can have exit data (though they don't
        ; necessarily have any.
        CMP.w #$0100 : BCC .hasExitData
        
        ; This code apparently executes for all rooms >= 0x0100 and < 
        ; 0x0180. (Excluding Link's house)
        ; these rooms only exit out the way we came.
        ; (Meaning they have no specific exit data)
        
        JSR Overworld_SimpleExit
        
        JMP .skipComplexExit
    
    .hasExitData
    
        ; search for an exit from this overworld area
        LDX.b #$9E
    
    .findRoomExit
    
        DEX #2
        
        ; Tries to find the appropriate room in a large array.
        ; X in this case becomes the exit number * 2
        ; Note the lack of any kind of error handling here, which can lead
        ; to infinite loops in hacked or unintentionally corrupted games.
        ; In other words, in Vanilla ALTTP, if your room has a door that exits
        ; to the overworld, it had better be in this list.
        CMP $DD8A, X : BNE .findRoomExit
        
        ; Load things like scroll data
        LDA $DF15, X : STA $E6 : STA $E8 : STA $0122 : STA $0124
        
        LDA $DFB3, X : STA $E0 : STA $E2 : STA $011E : STA $0120
        
        ; Loads up Link's coordinates
        LDA $E051, X : STA $20
        
        ; See the data document for details
        LDA $E0EF, X : STA $22
        
        LDA $DE77, X                               : STA $84
        SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
        
        LDA $E18D, X : STA $0618
        DEC #2       : STA $061A
        
        LDA $E22B, X : STA $061C
        DEC #2       : STA $061E
        
        ; Make Link face the downwards direction
        LDA.w #$0002 : STA $2F
        
        LDA $E367, X : STA $0696
        
        LDA $E405, X : STA $0698
        
        TXA : LSR A : TAX
        
        SEP #$20
        
        ; $15E28, X that is; These are the exits
        LDA $DE28, X : STA $8A : STA $040A
        
        ; zero out the upper byte of the area index
        STZ $8B
        
        STZ $040B
        
        LDA $E2C9, X : STA $0624 : STZ $0625 : ASL A : BCC .positive1
        
        DEC $0625 ; sign extends to 16-bit
    
    .positive1
    
        LDA $E318, X : STA $0628 : STZ $0629 : ASL A : BCC .positive2
        
        DEC $0629 ; sign extend to 16-bit
    
    .positive2
    
        REP #$20
        
        LDA.w #$0000 : SUB $0624 : STA $0626
        LDA.w #$0000 : SUB $0628 : STA $062A
    
    .skipComplexExit
    
        PLB
    
    ; *$1658B ALTERNATE ENTRY POINT
    
        ; $EC = -8. Will be used during tilemap calculations to provide granularity for
        ; tile width. Here it's setting it so that tile calculations occur on an 8x8 pixel grid 
        ; (as it ought to, since the tiles are an 8x8 grid)
        LDA.w #$FFF8 : STA $EC
        
        SEP #$30
        
        PHB : PHK : PLB
        
        JSR Overworld_LoadMapProperties
        
        LDA.b #$E4 : STA $0716
        
        STZ $0713
        
        LDA $8A : AND.b #$3F : ASL A : TAY
        
        REP #$20
        
        LDX.b #$00
        
        LDA $0712 : BEQ .largeOwMap
        
        INX #2
    
    .largeOwMap
    
        ; Sets up numerous boundaries ($06xx vars) but I don't know their exact function
        JSR $C0C3 ; $140C3 IN ROM
        
        SEP #$20
        
        PLB
        
        STZ $A9
        
        LDA.b #$02 : STA $AA : STA $A6 : STA $A7
        
        LDA.b #$80 : STA $45 : STA $44
        
        LDA.b #$0F : STA $42 : STA $43
        
        LDA.b #$FF : STA $24 : STA $29
        
        RTS
    }

; =============================================

    ; *$165D4-$166E0 LOCAL
    Overworld_SimpleExit:
    {
        ; Unlike some dungeon rooms that have specific exit data attached to them
        ; this type of exit merely restores data that was cached away when the
        ; player entered the dungeon room. In other words, we are merely
        ; going back to the overworld area we came in from.
        
        REP #$20
        
        LDA $7EC140 : STA $040A    
        
        LDA $7EC142 : STA $1C
        
        LDA $7EC144 : STA $E8 : STA $0122 : STA $E6 : STA $0124
        LDA $7EC146 : STA $E2 : STA $011E : STA $E0 : STA $0120
        
        LDA $7EC14A : STA $22
        LDA $7EC148 : STA $20
        
        ; If $A0 >= #$0124, don't take back a 0x10 offset on the Y axis
        LDA $A0 : CMP.w #$0124 : BCS .dontOffsetY
        
        ; The exits where this branch would be taken are special in that
        ; they're exits to caves under rocks or similar types of rooms
        
        LDA $20 : SUB.w #$0010 : STA $20

    .dontOffsetY
    
        ; default is to face downwards on exit
        LDA.w #$0002 : STA $2F
        
        ; (0xFFFF means that Link will exit facing up)
        LDA $0696 : CMP.w #$FFFF : BNE .notFacingUp
        
        ; Move Link down 32 pixels if he's going to be facing up coming out of the exit
        LDA $20 : ADD.w #$0020 : STA $20
        
        STZ $2F

    .notFacingUp
    
        ; Restore various settings that were cahced when we entered the dungeon room
        LDA $7EC14C : STA $8A
        
        LDA $7EC14E : STA $84 : SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
        
        LDA $7EC150 : STA $0618 : DEC #2 : STA $061A
        LDA $7EC152 : STA $061C : DEC #2 : STA $061E
        
        LDA $7EC154 : STA $0600
        LDA $7EC156 : STA $0602
        LDA $7EC158 : STA $0604
        LDA $7EC15A : STA $0606
        
        LDA $7EC15C : STA $0610
        LDA $7EC15E : STA $0612
        LDA $7EC160 : STA $0614
        LDA $7EC162 : STA $0616
        
        LDA $7EC16A : STA $0624
        LDA $7EC16C : STA $0626
        LDA $7EC16E : STA $0628
        LDA $7EC170 : STA $062A
        
        SEP #$20
        
        LDA $7EC164 : STA $0AA0
        LDA $7EC165 : STA $0AA1
        LDA $7EC166 : STA $0AA2
        LDA $7EC167 : STA $0AA3
        
        REP #$20
        
        RTS
    }

; =============================================

    ; *$16851-$169BB Local
    {
        ; caches a bunch of values and...?
        
        REP #$20
        
        STZ $04AC
        
        LDA $040A : STA $7EC100
        
        LDA $1C : STA $7EC102
        LDA $E8 : STA $7EC104
        LDA $E2 : STA $7EC106
        LDA $20 : STA $7EC108
        LDA $22 : STA $7EC10A
        
        LDA $0618 : STA $7EC110
        LDA $061C : STA $7EC112
        
        LDA $8A : STA $7EC10C
        LDA $84 : STA $7EC10E
        
        LDA $0600 : STA $7EC114
        LDA $0602 : STA $7EC116
        LDA $0604 : STA $7EC118
        LDA $0606 : STA $7EC11A
        LDA $0610 : STA $7EC11C
        LDA $0612 : STA $7EC11E
        LDA $0614 : STA $7EC120
        LDA $0616 : STA $7EC122
        LDA $0624 : STA $7EC12A
        LDA $0626 : STA $7EC12C
        LDA $0628 : STA $7EC12E
        LDA $062A : STA $7EC130
        
        SEP #$20
        
        LDA $0AA0 : STA $7EC124
        LDA $0AA1 : STA $7EC125
        LDA $0AA2 : STA $7EC126
        LDA $0AA3 : STA $7EC127
        
        SEP #$20
        
        JSR Overworld_LoadExitData
        
        REP #$20
        
        LDA $A0 : CMP.w #$1010 : BNE .notZoraFalls
        
        LDA.w #$0182 : STA $A0
    
    .notZoraFalls
    
        SEP #$20
        
        PHB : PHK : PLB
        
        LDA $A0 : PHA : SUB.b #$80 : STA $A0 : TAX
        
        LDA $02E801, X : STA $2F : STZ $0412
        
        LDA $02E811, X : STA $0AA3
        
        LDA $02E821, X : STA $0AA2 : PHX
        
        LDA $02E841, X : STA $00
        
        LDA $02E831, X
        
        JSL Overworld_LoadPalettes ; $755A8 IN ROM
        
        PLX
        
        REP #$30
        
        LDA.w #$03F0 : STA $00
        
        LDA $A0 : AND.w #$003F : ASL A : TAX
        
        LDA $02E6E1, X : STA $0708
        
        LDA $02E7E1, X : LSR #3 : STA $070C
        
        LDA $00 : STA $070A 
        
        LDA $00 : LSR #3 : STA $070E
        
        LDA $A0 : ASL A : TAY
        
        SEP #$10
        
        LDA $E6E1, Y : STA $0600
        LDA $E701, Y : STA $0602
        LDA $E721, Y : STA $0604
        LDA $E741, Y : STA $0606
        LDA $E761, Y : STA $0610
        LDA $E7A1, Y : STA $0612
        LDA $E781, Y : STA $0614
        LDA $E7C1, Y : STA $0616
        
        SEP #$20
        
        PLA : STA $A0
        
        PLB
        
        JSL $0ED61D ; $7561D IN ROM
        
        RTS
    }

    ; *$169BC-$16AE4 LOCAL
    {
        ; returns from a special area to a normal overworld area
        
        REP #$20
        
        STZ $04AC
        
        LDA $7EC100 : STA $040A
        
        LDA $7EC102 : STA $1C
        
        LDA $7EC104 : STA $E8 : STA $0122 : STA $E6 : STA $0124
        LDA $7EC106 : STA $E2 : STA $011E : STA $E0 : STA $0120
        
        LDA $7EC108 : STA $20
        LDA $7EC10A : STA $22
        LDA $7EC10C : STA $8A
        
        LDA $7EC10E : STA $84 : SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
        
        LDA $7EC110 : STA $0618 : DEC #2 : STA $061A
        LDA $7EC112 : STA $061C : DEC #2 : STA $061E
        
        LDA $7EC114 : STA $0600
        LDA $7EC116 : STA $0602
        LDA $7EC118 : STA $0604
        LDA $7EC11A : STA $0606
        LDA $7EC11C : STA $0610
        LDA $7EC11E : STA $0612
        LDA $7EC120 : STA $0614
        LDA $7EC122 : STA $0616
        LDA $7EC12A : STA $0624
        LDA $7EC12C : STA $0626
        LDA $7EC12E : STA $0628
        LDA $7EC130 : STA $062A
        
        SEP #$20
        
        LDA $7EC124 : STA $0AA0
        LDA $7EC125 : STA $0AA1
        LDA $7EC126 : STA $0AA2
        LDA $7EC127 : STA $0AA3
        
        LDX $8A : LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        ; set palettes and background color
        JSL Overworld_LoadPalettes ; $755A8 IN ROM
        JSL $0ED61D                ; $7561D IN ROM

        STZ $A9

        LDA.b #$02 : STA $AA : STA $A6 : STA $A7
        LDA.b #$80 : STA $45 : STA $44
        LDA.b #$0F : STA $42 : STA $43
        LDA.b #$FF : STA $24 : STA $29

        SEP #$30

        JSL Player_ResetSwimState
        JSR Overworld_LoadMapProperties

        LDA.b #$E4 : STA $0716

        STZ $0713

        RTS
    }

; ==============================================================================

    ; $16AE5 - $16C38 DATA
    pool BirdTravel_LoadTargetAreaData:
    {
    
        ; \task Figure out and apply labels to these arrays.
    
    ; $eae5
        dw $0003, $0016, $0018, $002C, $002F, $0030, $003B, $003F
        dw $005B, $0035, $000F, $0015, $0033, $0012, $003F, $0055
        dw $007F
    
    ; $eb07
        dw $1600, $0888, $0B30, $0588, $0798, $1880, $069E, $0810
        dw $002E, $1242, $0680, $0112, $059E, $048E, $0280, $0112
        dw $0280
    
    ; $eb29
        dw $02CA, $0516, $0759, $0AB9, $0AFA, $0F1E, $0EDF, $0F05
        dw $0600, $0E46, $02C6, $042A, $0CBA, $049A, $0E56, $042A
        dw $0E56
    
    ; $eb4b
        dw $060E, $0C4E, $017E, $0840, $0EB2, $0000, $06F2, $0E75
        dw $0778, $0C0A, $0E06, $0A8A, $06EA, $0462, $0E00, $0A8A
        dw $0E00
    
    ; $eb6d
        dw $0328, $0578, $07B7, $0B17, $0B58, $0FA8, $0F3D, $0F67
        dw $065C, $0EA8, $0328, $0488, $0D18, $04F8, $0EB8, $0488
        dw $0EB8
    
    ; $eb8f
        dw $0678, $0CC8, $0200, $08B8, $0F30, $0078, $0778, $0EF3
        dw $07F0, $0C90, $0E80, $0B10, $0770, $04E8, $0E68, $0B10
        dw $0E68
    
    ; $ebb1
        dw $0337, $0583, $07C6, $0B26, $0B67, $0F8D, $0F4C, $0F72
        dw $066D, $0EB3, $0333, $0497, $0D27, $0507, $0EC3, $0497
        dw $0EC3
    
    ; $ebd3
        dw $0683, $0CD3, $020B, $08BF, $0F37, $008D, $077F, $0EFA
        dw $07F7, $0C97, $0E8B, $0B17, $0777, $04EF, $0E85, $0B17
        dw $0E85
    
    ; $ebf5
        dw -10, -6, 7, -9, -10, 0, -15, -5
        dw 0, -6, 10, -10, -10, -10, -6, -10
        dw -6
    
    ; $ec17
        dw -14, -14, 2, 0, 14, 0, -2, 11
        dw -8, 6, -6, -6, 6, 14, 0, -6
        dw 0
    }

; ==============================================================================

    ; *$16C39-$16CDC LONG
    BirdTravel_LoadTargetAreaData:
    {
        PHB : PHK : PLB
        
        REP #$20
        
        STZ $04AC
        
        ASL $1AF0
        
        LDX $1AF0
    
    ; *$16C47 ALTERNATE ENTRY POINT
    shared Whirlpool_LoadTargetAreaData:
    
        LDA $EB29, X : STA $E6 : STA $E8 : STA $0122 : STA $0124
        LDA $EB4B, X : STA $E0 : STA $E2 : STA $011E : STA $0120
        
        LDA $EB6D, X : STA $20
        LDA $EB8F, X : STA $22
        
        LDA $EBF5, X : STA $0624
        
        LDA.w #$0000 : SUB $0624 : STA $0626
        
        LDA $EC17, X : STA $0628
        
        LDA.w #$0000 : SUB $0628 : STA $062A
        
        LDA $EAE5, X : STA $8A : STA $040A
        
        LDA $EB07, X : STA $84 : SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
        
        LDA $EBB1, X : STA $0618 : DEC #2 : STA $061A
        LDA $EBD3, X : STA $061C : DEC #2 : STA $061E
        
        STZ $0696 : STZ $0698
        
        PLB
        
        JSR $E58B   ; $1658B IN ROM
        JSL Sprite_ResetAll
        JSL Sprite_OverworldReloadAll
        
        STZ $6C
        
        JSR $8B0C ; $10B0C IN ROM
        
        RTL
    }

; ==============================================================================

    ; *$16CDD-$16CF7 LONG
    BirdTravel_LOadTargetAreaPalettes:
    {
        JSR Overworld_LoadAreaPalettes
        
        LDX $8A
        
        LDA $7EFD40, X : STA $00
        
        LDA $00FD1C, X
        
        JSL Overworld_LoadPalettes
        JSL Palette_SetOwBgColor_Long
        JSR $C65F   ; $1465F IN ROM
        
        RTL
    }

; ==============================================================================

    ; $16CF8 - $16D07 DATA
    pool Whirlpool_LookUpAndLoadTargetArea:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$16D08-$16D24 LONG
    Whirlpool_LookUpAndLoadTargetArea:
    {
        PHB : PHK : PLB
        
        REP #$20
        
        LDX.b #$10
        
        LDA $8A
    
    .locate_target_area
    
        ; Appears to be a routine dealing with whirlpool warps.
        DEX #2 : CMP $02ECF8, X : BNE .locate_target_area
        
        TXA : ADD.w #$0012 : TAX
        
        STZ $04AC
        
        JMP Whirlpool_LoadTargetAreaData
    }

; ==============================================================================

    ; \task This and its companion routines probably need better naming.
    ; *$16D25-$16DB8 LOCAL
    Overworld_LoadAmbientOverlay:
    {
        REP #$20
        
        LDA $84 : PHA
        LDA $86 : PHA
        LDA $88 : PHA
        
        LDX $8A
        
        LDA $02F88D, X : AND.w #$00FF : BEQ .large_area
        
        LDA.w #$0390 : STA $84
        
        SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
        
        BRA .load_overlay
    
    ; *$16D59 ALTERNATE ENTRY POINT
    shared Overworld_LoadAmbientOverlayAndMapData:
    
        REP #$20
        
        ; A = overlay value
        LDA $84 : PHA
        LDA $86 : PHA
        LDA $88 : PHA
        
        ; X = Area number
        LDX $8A : LDA $02F88D, X : AND.w #$00FF : BEQ .large_area_2
        
        LDA.w #$0390 : STA $84
        
        SUB.w #$0400 : AND.w #$0F80 : ASL A : XBA : STA $88
        
        LDA $84 : SUB.w #$0010 : AND.w #$003E : LSR A : STA $86
    
    .large_area_2
    
        SEP #$20
        
        JSR Overworld_LoadMapData
        
        REP #$20
    
    .load_overlay
    
        LDA.w #-1 : STA $C8
        
        STZ $CA
        STZ $CC
        
        SEP #$20
        
        JSR Map16ToMap8.normalArea
    
    .large_area
    
        REP #$20
        
        PLA : STA $88
        PLA : STA $86
        PLA : STA $84
        
        SEP #$20
        
        ; upload subscreen overlay command
        LDA.b #$04 : STA $17
                     STA $0710
        
        ; move to next submodule
        INC $11
        
        ; set screen brightness to zero
        STZ $13
        
        RTS
    }

; ==============================================================================

    ; *$16DB9-$16DC4 LOCAL
    {
        ; Module 0x08.0x02, 0x0A.0x02
        
        JSR Overworld_LoadAmbientOverlayAndMapData
        
        ; Put us in the Opening Spotlight module
        
        LDA.b #$10 : STA $10
        
        STZ $B0 : STZ $11
        
        RTS
    }

    ; $16DC5-$16EC4 DATA (Map16 locations of bombable doors)

; ==============================================================================

    ; *$16EC5-$16F79 LOCAL
    Overworld_LoadMapData:
    {
        REP #$30
        
        ; $1754A IN ROM; Decompresses and loads the Area's map16 data
        JSR Overworld_LoadMap32
        
        LDX.w #$001E
        
        LDA.w #$0DC4
    
    .blankBuffer
    
        STA $7E4000, X
        
        ; Why did this repeat? probably just a mistake
        STA $7E4020, X
        STA $7E4020, X
        
        STA $7E4040, X
        STA $7E4060, X
        
        DEX #2 : BPL .blankBuffer
        
        ; Load the doorway value for this overworld area
        ; (determines where to draw a door frame, if at all)
        LDX $0696 : BEQ .noDoor
        
        ; 0xFFFF indicates you will come out of the building heading north rather than south
        ; (but it still doesn't draw a door frame)
        CPX.w #$FFFF : BEQ .noDoor
        
        ; if $0696 > 0x8000 we'll draw a bombable door
        CPX.w #$8000 : BCS .drawBombableDoor
        
        LDA.w #$0DA4 : STA $7E2000, X
        
        JSL Overworld_Memorize_Map16_Change
        
        ; 0x0DA4 and 0x0DA6 are the wooden door frames
        LDA.w #$0DA6
        
        BRA .finishDoor
    
    .drawBombableDoor
    
        TXA : AND.w #$1FFF : TAX
        
        ; Bombable door tile (left)
        LDA.w #$0DB4
        
        JSL Overworld_Memorize_Map16_Change
        
        STA $7E2000, X
        
        ; Bombable door tile (right)
        LDA.w #$0DB5
    
    .finishDoor
    
        STA $7E2002, X : INX #2
        
        JSL Overworld_Memorize_Map16_Change
        
        ; Doorway has been handled, zero it out.
        DEX #2 : STZ $0696
    
    ; *$16F29 ALTERNATE ENTRY POINT
    ; this alternate entry point is for scrolling OW area loads
    ; b/c drawing a door only applies to when you transition from a dungeon to the OW
    ; the exceptioon is OW areas 0x80 and above which are handled similar to entrances
    .justOverlays
    
        ; Area that contains the warp near the watergate in the LW
        LDA.w #$020F : LDX $8A : CPX.w #$0033 : BNE .noRock
        
        ; This places a rock at a particular part of area 0x33. Why?
        ; Well basiclly it's because the data between area 0x33 and 0x73 only differ by this (one rock)
        ; so they hardcoded it in. What a stupid place to put this though, if you ask me.
        ; all that unused overlay flag space and they didn't use it for this.
        STA $7E22A8
    
    .noRock
    
        ; Same for this other area. 
        CPX.w #$002F : BNE .noRock2
        
        STA $7E2BB2
    
    .noRock2
    
        SEP #$30
        
        LDX $8A : CPX.b #$80 : BCS .dontDrawOverlay
        
        ; If some flag has already been triggered… do something appropriate, such as changing tiles to reflect this.
        LDA $7EF280, X : AND.b #$20 : BEQ .dontDrawOverlay
        
        ; $77652 IN ROM; The routine that makes the overlay show up
        JSL Overworld_LoadEventOverlay
    
    .dontDrawOverlay
    
        LDX $8A
        
        ; Check the overworld flags array In the second position.
        ; Only pertains to bombs?
        ; If the flag is set, draw a bombed open door (and sometimes other stuff)
        LDA $7EF280, X : AND.b #$02 : BEQ .noBombedDoor
        
        REP #$30
        
        LDA $8A : ASL A : TAX
        
        ; Designates locations to write opened bomb doors to.
        ; i.e. it contains the map16 coordinates for them.
        LDA $02EDC5, X : TAX
        
        LDA.w #$0DB4 : STA $7E2000, X
        LDA.w #$0DB5 : STA $7E2002, X
        
        SEP #$30
    
    .noBombedDoor
    
        RTS
    }

; ==============================================================================

    ; *$16F7A-$16FB2 LOCAL
    Overworld_TransVertical:
    {
        SEP #$30
        
        LDA.b #$08 : STA $0416
        
        LDA.b #$03 : STA $17
        
        REP #$30
        
        LDY $0E : LDA.w #$0080 : STA $1100, Y
        
        INY #2 : STY $0E
    
    .alpha
    
        JSR Overworld_DrawVerticalStrip
        
        LDA $84 : SUB.w #$0080 : STA $84
        
        LDA $88 : DEC A : AND.w #$001F : STA $88
        
        DEC $08 : BNE .alpha
        
        LDA.w #$FFFF : LDX $0E : STA $1100, X
        
        RTS
    }

; =============================================

    ; $16FB3-$16FE7 LOCAL
    Overworld_TransHorizontal:
    {
        SEP #$30
        
        LDA.b #$02 : STA $0416
        
        LDA.b #$03 : STA $17
        
        REP #$30
        
        LDY $0E : LDA.w #$8040 : STA $1100, Y
        
        INY #2 : STY $0E
    
    .alpha
    
        JSR Overworld_DrawHorizontalStrip
        
        DEC $84 : DEC $84
        
        LDA $86 : DEC A : AND.w #$001F : STA $86
        
        DEC $08 : BNE .alpha
        
        LDA.w #$FFFF : LDX $0E : STA $1100, X
        
        RTS
    }

; ==============================================================================

    ; $16FE8-$1700C LOCAL
    Overworld_LoadTransMapData:
    {
        REP #$30
        
        JSR Overworld_LoadMap32
        
        LDX.w #$001E
        
        LDA.w #$0DC4
    
    .default
    
        ; Fills $7E4000-$7E407F with the map16 value 0x0DC4, which is a blank transparent tile.
        STA $7E4000, X : STA $7E4020, X : STA $7E4040, X : STA $7E4060, X
        
        DEX #2 : BPL .default
        
        ; Draws the "overlay", which is an event sensitive set of map16 tiles that show that an event has occurred.
        ; One example is the Misery Mire dungeon's entrance being overdrawn as open rather than close
        JSR Overworld_LoadMapData_justOverlays
        
        ; clean up and finish up all the stuff a dungeon->OW load would do,
        ; except for drawing an opened door. Next we'll be moving on to turning
        ; the map16 data into map8
        
        INC $11
        
        RTS
    }

; ==============================================================================

    ; $1700D-$1701E Jump Table
    Overworld_LargeTransTable:
    {
        dw Overworld_TransError
        dw Overworld_LargeTransRight
        dw Overworld_LargeTransLeft
        dw Overworld_TransError
        dw Overworld_LargeTransDown
        dw Overworld_TransError
        dw Overworld_TransError
        dw Overworld_TransError
        dw Overworld_LargeTransUp
    }

    ; $1701F-$17030 Jump Table
    Overworld_SmallTransTable:
    {
        dw Overworld_TransError
        dw Overworld_SmallTransRight
        dw Overworld_SmallTransLeft
        dw Overworld_TransError
        dw Overworld_SmallTransDown
        dw Overworld_TransError
        dw Overworld_TransError
        dw Overworld_TransError
        dw Overworld_SmallTransUp
    }

; =============================================

    ; *$17031-$1704A LOCAL
    Overworld_StartTransMapUpdate:
    {
        SEP #$30
        
        LDX $8A
        
        ; performa a different routine depending on whether the area is 512x512 or 1024x1024
        LDA $02F88D, X : BNE .smallArea
        
        LDA $0416 : ASL A : TAX
        
        JMP (Overworld_LargeTransTable, X) ; $1700D IN ROM
    
    .smallArea
    
        LDA $0416 : ASL A : TAX
        
        JMP (Overworld_SmallTransTable, X) ; $1701F IN ROM
    }

    ; *$1706B-$17086 JUMP LOCATION
    Overworld_LargeTransUp:
    {
        REP #$30
        
        LDA $84 : ADD.w #$0380 : STA $84
        
        LDA.w #$001F : STA $88
        
        STZ $0E
        
        LDA.w #$0007 : STA $08
        
        JSR Overworld_TransVertical ; $16F7A IN ROM
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; *$17087-$170BF JUMP LOCATION
    Overworld_LargeTransDown:
    {
        REP #$30
        
        LDA $84
    
    BRANCH_BETA:
    
        CMP.w #$0080 : BCC BRANCH_ALPHA
        
        SBC.w #$0080
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        ADD.w #$0780 : STA $84
        
        STZ $0E
        
        LDA.w #$0007 : STA $88
        
        LDA.w #$0008 : STA $08
        
        JSR Overworld_TransVertical ; $16F7A IN ROM
        
        LDA $88 : ADD.w #$0009 : AND.w #$001F : STA $88
        
        LDA $84 : SUB.w #$0B80 : STA $84
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; *$170C0-$170DB JUMP LOCATION
    Overworld_LargeTransLeft:
    {
        REP #$30
        
        LDA $84 : ADD.w #$000E : STA $84
        
        LDA.w #$001F : STA $86
        
        STZ $0E
        
        LDA.w #$0007 : STA $08
        
        JSR Overworld_TransHorizontal
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; *$170DC-$1710E JUMP LOCATION
    Overworld_LargeTransRight:
    {
        REP #$30
        
        LDA $84 : SUB.w #$0060 : ADD.w #$001E : STA $84
        
        STZ $0E
        
        LDA.w #$0007 : STA $86
        
        LDA.w #$0008 : STA $08
        
        JSR Overworld_TransHorizontal
        
        LDA $86 : ADD.w #$0009 : AND.w #$001F : STA $86
        
        LDA $84 : SUB.w #$002E : STA $84
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; *$1710F-$17140 JUMP LOCATION
    Overworld_SmallTransUp:
    {
        REP #$30

        ; Cache a bunch of overworld update related variables
        LDA $84 : SUB.w #$0700 : STA $7EC172

        LDA $86 : STA $7EC174

        LDA.w #$000A : STA $7EC176

        LDA.w #$1390 : STA $84
        
        STZ $86
        
        LDA.w #$001F : STA $88
        
        STZ $0E
        
        LDA.w #$0007 : STA $08
        
        JSR Overworld_TransVertical
        
        SEP #$30

        RTS
    }

; =============================================

    ; *$17141-$17184 JUMP LOCATION
    Overworld_SmallTransDown:
    {
        REP #$30
        
        LDA $84 : AND.w #$00FF : STA $7EC172
        
        LDA $86 : STA $7EC174
        
        LDA.w #$0018 : STA $7EC176
        
        LDA.w #$0790 : STA $84
        
        STZ $86
        
        LDA.w #$0007 : STA $88
        
        STZ $0E
        
        LDA.w #$0008 : STA $08
        
        JSR Overworld_TransVertical
        
        LDA $88 : ADD.w #$0009 : AND.w #$001F : STA $88
        
        LDA $84 : SUB.w #$0B80 : STA $84
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; *$17185-$171B6 JUMP LOCATION
    Overworld_SmallTransLeft:
    {
        REP #$30
        
        LDA $84 : SUB.w #$0020 : STA $7EC172
        
        LDA.w #$0008 : STA $7EC174
        
        LDA $88 : STA $7EC176
        
        LDA.w #$044E : STA $84
        
        STZ $88
        
        LDA.w #$001F : STA $86
        
        STZ $0E
        
        LDA.w #$0007 : STA $08
        
        JSR Overworld_TransHorizontal
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; *$171B7-$171FB JUMP LOCATION
    Overworld_SmallTranRight:
    {
        REP #$30

        LDA $84 : SUB.w #$0060 : STA $7EC172

        LDA.w #$0018 : STA $7EC174

        LDA $88 : STA $7EC176

        LDA.w #$041E : STA $84

        STZ $88

        LDA.w #$0007 : STA $86

        STZ $0E

        LDA.w #$0008 : STA $08

        JSR Overworld_TransHorizontal

        LDA $86 : ADD.w #$0009 : AND.w #$001F : STA $86

        LDA $84 : SUB.w #$002E : STA $84
        
        SEP #$30
        
        RTS
    }

; =============================================

    ; $171FC-$1720D Jump Table
    {
        dw Overworld_TransError
        dw $F24A                ; = $1724A*      
        dw $F241                ; = $17241*
        dw Overworld_TransError
        dw $F238                ; = $17238*
        dw Overworld_TransError
        dw Overworld_TransError
        dw Overworld_TransError
        dw $F218                ; = $17218*
    }

    ; *$1720E-$17217 LOCAL
    {
        SEP #$30

        LDA $0416 : ASL A : TAX

        JMP ($F1FC, X) ; $171FC IN ROM
    }

    ; *$17218-$17237 JUMP LOCATION
    {
        REP #$30
        
        STZ $0E
        
        JSR $F2F1 ; $172F1 IN ROM

    ; *$1721F ALTERNATE ENTRY POINT

        LDY $0E
        
        LDA.w #$FFFF : STA $1100, Y : STA $1102, Y
        
        CPY.w #$0000 : BEQ .noUpdate
        
        SEP #$30
        
        LDA.b #$03 : STA $17

    .noUpdate

        SEP #$30
        
        RTS
    }

    ; *$17238-$17240 JUMP LOCATION
    {
        REP #$30
        
        STZ $0E
        
        JSR $F325 ; $17325 IN ROM
        
        BRA BRANCH_$1721F
    }

    ; *$17241-$17249 JUMP LOCATION
    {
        REP #$30
        
        STZ $0E
        
        JSR $F363 ; $17363 IN ROM
        
        BRA BRANCH_$1721F
    }

    ; *$1724A-$17252 JUMP LOCATION
    {
        REP #$30
        
        STZ $0E
        
        JSR $F39D   ; $1739D IN ROM
        
        BRA BRANCH_$1721F
    }

    ; $17253-$17272 LOCAL JUMP TABLE
    Overworld_ScrollTable:
    {
        dw Overworld_TransError  ; no direction = no update
        dw Overworld_ScrollRight ; moving right
        dw Overworld_ScrollLeft  ; moving left
        dw Overworld_TransError  ; impossible (left + right)
        dw Overworld_ScrollUp    ; moving up
        dw $F2BA                 ; $172BA ; moving up + right
        dw $F2BA                 ; $172BA ; moving up + left
        dw Overworld_TransError  ; impossible (up + left + right)
        dw Overworld_ScrollDown  ; moving down
        dw $F2CF                 ; $172CF ; moving down + right
        dw $F2CF                 ; $172CF ; moving down + left
        dw Overworld_TransError  ; impossible (down + left + right)
        dw Overworld_TransError  ; impossible (down + up)
        dw Overworld_TransError  ; impossible (down + up + right)
        dw Overworld_TransError  ; impossible (down + up + left)
        dw Overworld_TransError  ; impossible (down + up + left + right)
    }

    ; *$17273-$172A1 LOCAL
    Overworld_ScrollMap:
    {
        REP #$30
        
        STZ $0E
        
        SEP #$30
        
        ; Based on the flags in the 
        LDA $0416 : ASL A : TAX
        
        JSR ($F253, X) ; ($17253, X) THAT IS
        
        REP #$30
        
        LDY $0E : LDA.w #$FFFF : STA $1100, Y : STA $1102, Y
        
        CPY.w #$0000 : BEQ .noTilemapUpdate
        
        SEP #$30
        
        LDA.b #$03 : STA $17
    
    .noTilemapUpdate
    
        SEP #$30
        
        LDA $0416 : STA $0418
        
        RTS
    }

; ==============================================================================

    ; *$172A2-$172A4 LOCAL
    Overworld_TransError:
    {
        ; Resets the submodule index to normal. 
        ; This routine... should never occur under normal circumstances if I understand correctly
        STZ $11
        
        RTS
    }

; ==============================================================================

    ; *$172A5-$172AB LOCAL
    Overworld_ScrollRight:
    {
        JSR $F37F    ; $1737F IN ROM
        
        STZ $0416
        
        RTS
    }

; ==============================================================================

    ; *$172AC-$172B2 LOCAL
    Overworld_ScrollLeft:
    {
        JSR $F345 ; $17345 IN ROM
        
        STZ $0416
        
        RTS
    }

; ==============================================================================

    ; *$172B3-$172B9 LOCAL
    Overworld_ScrollUp:
    {
        JSR $F311 ; $17311 IN ROM
        
        STZ $0416
        
        RTS
    }

; ==============================================================================

    ; *$172BA-$172C7 LOCAL
    {
        JSR $F311 ; $17311 IN ROM
        
        SEP #$30
        
        LDA $0416 : AND.b #$03 : STA $0416
        
        RTS
    }

    ; *$172C8-$172CE LOCAL
    Overworld_ScrollDown:
    {
        JSR $F2DD ; $172DD IN ROM
        
        STZ $0416
        
        RTS
    }

    ; *$172CF-$172DC LOCAL
    {
        JSR $F2DD ; $172DD IN ROM
        
        SEP #$30
        
        LDA $0416 : AND.b #$03 : STA $0416
        
        RTS
    }

    ; *$172DD-$17310 LOCAL
    {
        REP #$30
        
        LDA $84 : CMP.w #$0080 : BMI BRANCH_ALPHA
        
        LDX $8A : LDA $02F88D, X : AND.w #$00FF : BNE BRANCH_BETA
    
    ; *$172F1 ALTERNATE ENTRY POINT
    
        LDY $0E
        
        LDA.w #$0080 : STA $1100, Y
        
        INY #2 : STY $0E
        
        JSR Overworld_DrawVerticalStrip
    
    BRANCH_BETA:
    
        LDA $84 : SUB.w #$0080 : STA $84
        
        LDA $88 : DEC A : AND.w #$001F : STA $88
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$17311-$17344 LOCAL
    {
        REP #$30
        
        LDA $84 : CMP.w #$1800 : BCS BRANCH_ALPHA
        
        ; $1788D, X THAT IS
        LDX $8A : LDA $02F88D, X : AND.w #$00FF : BNE BRANCH_BETA
    
    ; *$17325 ALTERNATE ENTRY POINT
    
        LDY $0E
        
        LDA.w #$0080 : STA $1100, Y
        
        INX #2
        
        STY $0E
        
        JSR Overworld_DrawVerticalStrip
    
    BRANCH_BETA:
    
        LDA $84 : ADD.w #$0080 : STA $84
        
        LDA $88 : INC A : AND.w #$001F : STA $88
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$17345-$1737E LOCAL
    {
        REP #$30
        
        LDA $84
    
    BRANCH_BETA:
    
        CMP.w #$0080 : BCC BRANCH_ALPHA
        
        SBC.w #$0080
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        CMP.w #$0000 : BEQ BRANCH_GAMMA
        
        LDX $8A : LDA $02F88D, X : AND.w #$00FF : BNE BRANCH_DELTA
    
    ; *$17363 ALTERNATE ENTRY POINT
    
        LDY $0E
        
        LDA.w #$8040 : STA $1100, Y
        
        INY #2 : STY $0E
        
        JSR Overworld_DrawHorizontalStrip
    
    BRANCH_DELTA:
    
        DEC $84 : DEC $84
        
        LDA $86 : DEC A : AND.w #$001F : STA $86
    
    BRANCH_GAMMA:
    
        RTS
    }

; ==============================================================================

    ; *$1737F-$173B8 LOCAL
    {
        REP #$30
        
        LDA $84
    
    BRANCH_BETA:
    
        CMP.w #$0080 : BCC BRANCH_ALPHA
        
        SBC.w #$0080
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        CMP.w #$0060 : BCS BRANCH_GAMMA
        
        ; $1788D, X THAT IS
        LDX $8A : LDA $02F88D, X : AND.w #$00FF : BNE BRANCH_DELTA
    
    ; *$1739D ALTERNATE ENTRY POINT
    
        LDY $0E
        
        LDA.w #$8040 : STA $1100, Y
        
        INY #2 : STA $0E
        
        JSR Overworld_DrawHorizontalStrip
    
    BRANCH_DELTA:
    
        INC $84 : INC $84
        
        LDA $86 : INC A : AND.w #$001F : STA $86
    
    BRANCH_GAMMA:
    
        RTS
    }

; ==============================================================================

    ; *$173B9-$17481 LOCAL
    Overworld_DrawHorizontalStrip:
    {
        LDA $0416 : AND.w #$0002 : TAX
        
        LDA $84 : SUB $02F883, X : TAY
        
        LDA $88 : ASL A : TAX
        
        ; $00[3] = $7E2000
        ; $03[2] = $0010
        LDA.w #$2000 : STA $00
        LDA.w #$007E : STA $02
        LDA.w #$0010 : STA $03
        
        LDA [$00], Y : STA $0500, X
        
        INX #2
        
        TXA : AND.w #$003F : TAX
        
        ; Move down one map16 tile
        TYA : ADD.w #$0080 : TAY
    
    .fillBuffer
    
        ; Populate the buffer ( $0500[0x40] ) with 0x10 map16 entries (256 pixels)
        LDA [$00], Y : STA $0500, X : INX #2
        
        ; advance by one map16 tile in our temporary buffer
        TXA : AND.w #$003F : TAX
        
        ; Move down one map16 tile
        TYA : ADD.w #$0080 : TAY
        
        DEC $03 : BNE .fillBuffer
        
        STZ $00
        
        LDA $86 : STA $02 : CMP.w #$0010 : BCC .inBounds
        
        AND.w #$000F : STA $02
        
        LDA.w #$0400 : STA $00
    
    .inBounds
    
        LDA $02 : ASL A : ADD $00 : STA $00 : ADD.w #$0800 : STA $0C
        
        LDA $02F889
        
        JSR $F435 ; $17435 IN ROM
        
        LDA $0C : STA $00
        
        LDA $02F88B
    
    ; *$17435 ALTERNATE ENTRY POINT
    
        STA $02
        
        LDY $0E : LDA $00 : STA $1100, Y : INC A : STA $1142, Y : INY #2
        
        LDA.w #$0010 : STA $06
    
    .copyToNmiBuf
    
        LDX $02 : LDA $0500, X : INX #2 : STX $02
        
        ASL #3 : TAX
        
        LDA $0F8000, X : STA $1100, Y
        LDA $0F8002, X : STA $1142, Y
        
        INY #2
        
        LDA $0F8004, X : STA $1100, Y
        LDA $0F8006, X : STA $1142, Y
        
        INY #2
        
        DEC $06 : BNE .copyToNmiBuf
        
        ; 0x10 map16 tiles = 0x40 bytes of map8 data
        ; And there's also 2 bytes of header information in the nmi buffer, so
        ; we advance by that much.
        TYA : ADD.w #$0042 : STA $0E
        
        RTS
    }

; ==============================================================================

    ; $17482-$17549 LOCAL
    Overworld_DrawVerticalStrip:
    {
        LDA $0416 : AND.w #$0004 : LSR A : TAX
        
        LDA $84 : SUB $02F885, X : TAY
        
        LDA $86 : ASL A : TAX
        
        ; $00[3] = $7E2000
        LDA.w #$2000 : STA $00
        LDA.w #$007E : STA $02
        
        ; $03[2] = 0x0010    
        LDA.w #$0010 : STA $03
    
    .fillBuffer
    
        ; writes 0x40 bytes to $0500[0x40]
        LDA [$00], Y : STA $0500, X
        
        INX #2 : TXA : AND.w #$003F : TAX
        INY #2
        
        LDA [$00], Y : STA $0500, X
        
        INX #2 : TXA : AND.w #$003F : TAX
        INY #2
        
        DEC $03 : BNE .fillBuffer
        
        STZ $00
        
        LDA $88 : STA $02 : CMP.w #$0010 : BCC .inBounds
        
        AND.w #$000F : STA $02
        
        LDA.w #$0800 : STA $00
    
    .inBounds
    
        LDA $02 : ASL #6 : ADD $00 : STA $00
        
        ADD.w #$0400 : STA $0C
        
        LDY $0E
        
        LDA $00 : STA $1100, Y : INY #2
        
        LDA $02F889 ; $17889 THAT IS
        
        JSR $F50A   ; $1750A IN ROM
        
        LDY $0E
        
        LDA $0C : STA $1100, Y : INY #2
        
        LDA $02F88B ; $1788B THAT IS
    
    ; *$1750A ALTERNATE ENTRY POINT
    
        STA $02
        
        LDA.w #$0010 : STA $06
    
    .nextMap16Tile
    
        LDX $02
        
        LDA $0500, X : INX #2 : STX $02 : ASL #3 : TAX
        
        ; $78000, X; place the top left map8 tile
        LDA $0F8000, X : STA $1100, Y
        
        ; place the bottom left map8 tile
        LDA $0F8004, X : STA $1140, Y
        
        INY #2
        
        ; place the top right map8 tile    
        LDA $0F8002, X : STA $1100, Y
        
        ; place the bottom right map8 tile    
        LDA $0F8006, X : STA $1104, Y
        
        INY #2
        
        DEC $06 : BNE .nextMap16Tile
        
        TYA : ADD.w #$0040 : STA $0E
        
        RTS
    }

; ==============================================================================

    ; $1754A-$17637 LOCAL
    Overworld_LoadMap32:
    {
        ; This routine loads the tile data for the OW section
        ; $00[3] is the target address, in this case $7E2000[0x2000]
        ; $03[3] is the target address + 0x80
        ; $C8[3] is the source address for the data to be written
        
        ; X = $8A * 3
        LDA $8A : ASL A : ADC $8A : TAX
        
        LDA.w #$007E : STA $02 : STA $05
        
        LDA.w #$2000
        
        JSR .loadQuadrant
        
        ; X = 3 * ($8A + 1)
        LDA $8A : INC A : STA $00 : ASL A : ADC $00 : TAX
        
        ; This should be written as just "LDA.w #$2040"
        LDA.w #$2000 : ADD.w #$0040
        
        JSR .loadQuadrant
        
        ; $00 = ($8A + 8)
        LDA $8A : ADD.w #$0008 : STA $00
        
        ; X = 3 * ($8A + 8)
        ASL A : ADC $00 : TAX
        
        LDA.w #$3000
        
        JSR .loadQuadrant
        
        ; $00 = ($8A + 9)
        LDA $8A : ADD.w #$0009 : STA $00
        
        ; X = 3 * ($8A + 9)
        ASL A : ADC $00 : TAX
        
        ; This should be written as just "LDA.w #$0304"
        LDA.w #$3000 : ADD.w #$0040
    
    .loadQuadrant
    
        STA $00 : ADD.w #$0080 : STA $03
        
        ; load the source address into $C8[3]
        LDA.l .high_byte_packs+0, X : STA $C8
        LDA.l .high_byte_packs+1, X : STA $C9
        
        LDA $00 : PHA
        LDA $02 : PHA
        LDA $04 : PHA
        
        LDA.w #$4400 : STA $00
        
        LDA.w #$007F : STA $02
        
        PHX
        
        SEP #$30
        
        ; decompresses the map32 data packet
        JSR Overworld_Decomp
        
        REP #$30
        
        JSR InterlaceMap32.highBytes
        
        PLX
        
        LDA.l .low_byte_packs+0, X : STA $C8
        LDA.l .low_byte_packs+1, X : STA $C9
        
        ; $00[3] = $7F4400
        LDA.w #$4400 : STA $00
        LDA.w #$007F : STA $02
        
        PHX
        
        SEP #$30
        
        JSR Overworld_Decomp
        
        REP #$30
        
        JSR InterlaceMap32.lowBytes
        
        PLX
        
        PLA : STA $04
        PLA : STA $02
        PLA : STA $00
        
        ; $08[3] = 0x7F4000 (source address)        
        LDA.w #$4000 : STA $08
        LDA.w #$007F : STA $0A
        
        SEP #$20
        
        ; data bank = 0x7F        
        PHB : LDA.b #$7F : PHA : PLB
        
        REP #$30
        
        LDA.w #$FFFF : STA $4440
        
        STZ $06 : STZ $0B
    
    .yLoop
        
        LDA.w #$0010 : STA $0D
    
    .xLoop
    
        LDY $0B
        
        LDA [$08], Y : ASL A 
        
        LDY $06
        
        JSR Map32ToMap16
        
        STY $06
        
        INC $0B : INC $0B
        
        DEC $0D : BNE .xLoop
        
        LDA $06 : ADD.w #$00C0 : STA $06 : CMP.w #$1000 : BCC .yLoop
        
        PLB
        
        RTS
    }

; ==============================================================================
    
    ; *$17638-$17690 LOCAL
    InterlaceMap32:
    {
    
    .highBytes
    
        ; Copies decompressed map32 data into the odd bytes in $7F4000[0x200]
        
        SEP #$20
        
        ; Set the data bank to $7F.
        PHB : LDA.b #$7F : PHA : PLB
        
        ; Changing the bank of the target address.
        STA $02
        
        REP #$30
        
        LDX.w #$0000
        LDY.w #$0001
        
        ; $00[3] = $7F4000
        LDA.w #$4000 : STA $00
        
        SEP #$20
    
    .doInterlace
    
        ; Copy $7F4400, X to $7F4000, Y
        LDA $4400, X : STA [$00], Y : INY #2 : INX
        LDA $4400, X : STA [$00], Y : INY #2 : INX
        LDA $4400, X : STA [$00], Y : INY #2 : INX
        LDA $4400, X : STA [$00], Y : INY #2 : INX
        
        CPX.w #$0100 : BCC .doInterlace
        
        REP #$30
        
        PLB
        
        RTS
    
    ; *$17679 ALTERNATE ENTRY POINT
    .lowBytes
    
        ; Copies decompressed map32 data into the even bytes in $7F4000[0x200]
        
        SEP #$20
        
        PHB : LDA.b #$7F : PHA : PLB
        
        STA $02
        
        REP #$30
        
        LDX.w #$0000 : TXY
        
        ; $02[3] = $7F4000
        LDA.w #$4000 : STA $00
        
        SEP #$20
        
        BRA .doInterlace
    }

; ==============================================================================

    ; *$17691-$177CA LOCAL
    Map32ToMap16:
    {
        ; converts a map32 tile to its 4 map16 tiles
        
        ; map32 value...
        ; if(A != $4440) goto BRANCH_1
        PHA : AND.w #$FFF8 : CMP $4440 : BNE .different
        
        ; this is a shortcut to load the same data if the new map32 value matches
        ; the previous one
        JMP .same
    
    .different
    
          ; $4440 = input
        STA $4440
        
           ; $4442 = input >> 1
        LSR A : STA $4442
        
        ; X = (input >> 2) + (input >> 1)
        ; Thus the formula is X = (input / 4) + (input / 2) = input * (3 / 4)
        ; The map32 to map16 conversion data is packed 12 bits at time, hence we take a 16-bit index
        ; and multiply it by (3/4) to get a 12-bit index
        LSR A : ADC $4442 : TAX
        
        SEP #$20
        
        LDA $038000, X : STA $4400
        LDA $038001, X : STA $4402
        LDA $038002, X : STA $4404
        LDA $038003, X : STA $4406
        
        LDA $038004, X : PHA : LSR #4     : STA $4401
                         PLA : AND.b #$0F : STA $4403
        
        LDA $038005, X : PHA : LSR #4     : STA $4405
                         PLA : AND.b #$0F : STA $4407
        
        LDA $03B400, X : STA $4410
        LDA $03B401, X : STA $4412
        LDA $03B402, X : STA $4414
        LDA $03B403, X : STA $4416
        
        LDA $03B404, X : PHA : LSR #4     : STA $4411
                         PLA : AND.b #$0F : STA $4413
        
        LDA $03B405, X : PHA : LSR #4     : STA $4415
                         PLA : AND.b #$0F : STA $4417
        
        LDA $048000, X : STA $4420
        LDA $048001, X : STA $4422
        LDA $048002, X : STA $4424
        LDA $048003, X : STA $4426
        
        LDA $048004, X : PHA : LSR #4     : STA $4421
                         PLA : AND.b #$0F : STA $4423
        
        LDA $048005, X : PHA : LSR #4     : STA $4425
                         PLA : AND.b #$0F : STA $4427
        
        LDA $04B400, X : STA $4430
        LDA $04B401, X : STA $4432
        LDA $04B402, X : STA $4434
        LDA $04B403, X : STA $4436
        
        LDA $04B404, X : PHA : LSR #4     : STA $4431
                         PLA : AND.b #$0F : STA $4433
        
        LDA $04B405, X : PHA : LSR #4     : STA $4435
                         PLA : AND.b #$0F : STA $4437
        
        REP #$30
    
    ; *$177AD ALTERNATE ENTRY POINT
    .same
    
        PLA : AND.w #$0007 : TAX
        
        LDA $4400, X : STA [$00], Y
        LDA $4420, X : STA [$03], Y : INY #2
        LDA $4410, X : STA [$00], Y
        LDA $4430, X : STA [$03], Y : INY #2
        
        RTS
    }

; ==============================================================================

    ; *$177CB-$1787E LOCAL
    LoadSubOverlayMap32:
    {
        ; X = (3 * $8A)
        LDA $8A : ASL A : ADC $8A : TAX
        
        ; $00 = $7E4000, $03 = $7E4080
        LDA.w #$007E : STA $02 : STA $05
        LDA.w #$4000 : STA $00 : ADD.w #$0080 : STA $03
        
        ; $C8[3] = base address of the compressed map32 data
        LDA.l .high_byte_packs+0, X : STA $C8
        LDA.l .high_byte_packs+1, X : STA $C9
        
        ; We’re going to save those two long addresses for later.
        LDA $00 : PHA
        LDA $02 : PHA
        LDA $04 : PHA
        
        ; $00[3] = $7F4400
        LDA.w #$4400 : STA $00
        LDA.w #$007F : STA $02
        
        ; push ($8A * 3) to the stack.
        PHX
        
        SEP #$30
        
        ; Decompress data to $7F4400
        JSR Overworld_Decomp
        
        REP #$30
        
        JSR InterlaceMap32.highBytes
        
        PLX 
        
        ; Change the source address for the decompression.
        LDA.l .low_byte_packs+0, X : STA $C8
        LDA.l .low_byte_packs+1, X : STA $C9
        
        ; TargetAddress = $7F4400
        LDA.w #$4400 : STA $00
        LDA.w #$007F : STA $02
        
        PHX
        
        SEP #$30
        
        JSR Overworld_Decomp
        
        REP #$30
        
        JSR InterlaceMap32.lowBytes
        
        PLX
        
        ; Restore the old long addresses.
        ; ($00 = $7E4000, $03 = $7E4080)
        PLA : STA $04
        PLA : STA $02
        PLA : STA $00
        
        ; $08[3] = $7F4000
        LDA.w #$4000 : STA $08
        LDA.w #$007F : STA $0A
        
        SEP #$20
        
        ; Set data bank to 0x7F
        PHB : LDA.b #$7F : PHA : PLB
        
        REP #$30
        
        ; Store to $7F4440
        LDA.w #$FFFF : STA $4440
        
        STZ $06 : STZ $0B
    
    .nextLine
    
        ; By line, we mean a 32 x 512 pixel swath. 0x10 map32 tiles consists of exactly this
        
        ; Set up a loop of 0x10 iterations
        LDA.w #$0010 : STA $0D
        
    .nextTile
    
        ; X = ($7F4000 + Y) << 1, the map32 value
        LDY $0B : LDA [$08], Y : ASL A : TAX
        
        LDY $06
        
        JSR Map32ToMap16
        
        STY $06
        
        ; increment by two to obtain the next map32 value
        INC $0B : INC $0B
        
        DEC $0D : BNE .nextTile
        
        ; $06 += 0xC0
        ; if($06 < 0x100)
        LDA $06 : ADD.w #$00C0 : STA $06 : CMP.w #$1000 : BCC .nextLine 
        
        PLB
        
        RTS
    }

; ==============================================================================

    ; \unused Best intelligence available says this is not used.
    ; $1787F-$1794C DATA
    {
        db $02, $00, $04, $00, $D0, $03, $10, $04
        db $10, $F4, $00, $00, $20, $00, $00, $00
        db $01, $00, $00, $00, $00, $01, $00, $00
        db $01, $00, $00, $00, $00, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $00, $00
        db $01, $00, $00, $01, $00, $00, $00, $00
        db $01, $00, $00, $01, $00, $00, $01, $01
        db $01, $01, $01, $01, $01, $01, $00, $00
        db $01, $01, $01, $00, $00, $01, $00, $00
        db $01, $01, $01, $00, $00, $01, $00, $00
        db $01, $00, $00, $00, $00, $01, $00, $00
        db $01, $00, $00, $00, $00, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $00, $00
        db $01, $00, $00, $01, $00, $00, $00, $00
        db $01, $00, $00, $01, $00, $00, $01, $01
        db $01, $01, $01, $01, $01, $01, $00, $00
        db $01, $01, $01, $00, $00, $01, $00, $00
        db $01, $01, $01, $00, $00, $01, $01, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; $1794D-$17D0C DATA
    pool Overworld_LoadMap32:
    parallel pool LoadSubOverlayMap32:
    {
    
    .high_byte_packs
        dl $0B8000, $0B80D6, $0B81C2, $0B8316
        dl $0B83EA, $0B850E, $0B8671, $0B880F
        dl $0B89D3, $0B8B90, $0BD709, $0B8D24
        dl $0B8EE3, $0B9070, $0B91EA, $0B93CC
        
        dl $0B9527, $0BE39A, $0BE557, $0B96D5
        dl $0B9843, $0B998C, $0B9B55, $0BEDC2
        dl $0B9D07, $0B9E89, $0BA016, $0BA209
        dl $0BA3A6, $0BA543, $0BA714, $0BA819
        
        dl $0BA94E, $0BAACE, $0BAC5F, $0BAE22
        dl $0BAFA0, $0C84BD, $0BB140, $0BB2F3
        dl $0BB4B1, $0BB644, $0C8D6C, $0C8F2B
        dl $0C9106, $0BB800, $0C94D0, $0C96BF
        
        dl $0BB9BB, $0BBAFE, $0BBBFE, $0C9DAF
        dl $0C9F73, $0BBDC7, $0BBFA1, $0CA4BA
        dl $0BC18F, $0BC2A4, $0BC3B8, $0CAC5F
        dl $0CAE37, $0BC590, $0BC76C, $0CB3D2
        
        dl $0BC93F, $0BCA19, $0BCB5A, $0BCCD0
        dl $0BCE13, $0BCF6C, $0BD0B1, $0BD244
        dl $0BD3F6, $0BD588, $0BD709, $0BD8E9
        dl $0BDAA7, $0BDC4D, $0BDE23, $0BE011
        
        dl $0BE1DE, $0BE39A, $0BE557, $0BE74B
        dl $0BE8DF, $0BEA37, $0BEC01, $0BEDC2
        dl $0BEF9A, $0BF156, $0BF2F4, $0BF4E4
        dl $0BF5BB, $0BF6B3, $0BF8A4, $0BF9AA
        
        dl $0BFB15, $0BFCB9, $0C8000, $0C81C4
        dl $0C8321, $0C84BD, $0C8688, $0C880D
        dl $0C89CC, $0C8B9A, $0C8D6C, $0C8F2B
        dl $0C9106, $0C92E8, $0C94D0, $0C96BF
        
        dl $0C98B0, $0C9A48, $0C9BC2, $0C9DAF
        dl $0C9F73, $0CA132, $0CA329, $0CA4BA
        dl $0CA6B2, $0CA898, $0CAA6D, $0CAC5F
        dl $0CAE37, $0CB016, $0CB20B, $0CB3D2
        
        dl $0CB83C, $0CB97C, $0CBAF2, $0B8000
        dl $0B8000, $0B8000, $0B8000, $0B8000
        dl $0CC0B4, $0CBCAE, $0CBE4B, $0B8000
        dl $0B8000, $0B8000, $0B8000, $0B8000
        
        dl $0B8000, $0B8000, $0B8000, $0CC0B4
        dl $0CB83C, $0CBFFA, $0CBFD7, $0CB67B
        dl $0B8000, $0B8000, $0B8000, $0B8000
        dl $0CC0AC, $0CB67B, $0CB5C8, $0CB6BE
    
    ; $17B2D
    .lower_byte_packs
        dl $0B8004, $0B80DA, $0B8238, $0B8340
        dl $0B8460, $0B85A3, $0B8724, $0B88E0
        dl $0B8A91, $0B8C35, $0BD7F0, $0B8DF6
        dl $0B8F87, $0B9118, $0B92CF, $0B9465
        
        dl $0B95E7, $0BE468, $0BE64A, $0B9775
        dl $0B98C7, $0B9A65, $0B9C18, $0BEEA7
        dl $0B9DAC, $0B9F39, $0BA107, $0BA2C1
        dl $0BA45E, $0BA622, $0BA746, $0BA86A
        
        dl $0BA9FB, $0BAB79, $0BAD2E, $0BAECD
        dl $0BB064, $0C8598, $0BB204, $0BB3CA
        dl $0BB567, $0BB718, $0C8E3B, $0C900C
        dl $0C91F1, $0BB8D3, $0C95C4, $0C97B3
        
        dl $0BBA25, $0BBB3C, $0BBCDA, $0C9E82
        dl $0CA049, $0BBEAC, $0BC08B, $0CA5B3
        dl $0BC200, $0BC300, $0BC49A, $0CAD4A
        dl $0CAF24, $0BC673, $0BC848, $0CB4C8
        
        dl $0BC948, $0BCA78, $0BCBE3, $0BCD58
        dl $0BCEB0, $0BCFF6, $0BD169, $0BD30B
        dl $0BD4A4, $0BD61C, $0BD7F0, $0BD9BF
        dl $0BDB60, $0BDD2A, $0BDF13, $0BE0F0
        
        dl $0BE2A3, $0BE468, $0BE64A, $0BE807
        dl $0BE976, $0BEB0F, $0BECCB, $0BEEA7
        dl $0BF067, $0BF213, $0BF3E3, $0BF51F
        dl $0BF612, $0BF7A4, $0BF8DE, $0BFA3F
        
        dl $0BFBD5, $0BFD6D, $0C80D2, $0C8265
        dl $0C83E6, $0C8598, $0C8734, $0C88DD
        dl $0C8AA4, $0C8C73, $0C8E3B, $0C900C
        dl $0C91F1, $0C93D4, $0C95C4, $0C97B3
        
        dl $0C996E, $0C9AF4, $0C9CB3, $0C9E82
        dl $0CA049, $0CA226, $0CA3DC, $0CA5B3
        dl $0CA799, $0CA971, $0CAB64, $0CAD4A
        dl $0CAF24, $0CB10C, $0CB2E6, $0CB4C8
        
        dl $0CB8AC, $0CBA16, $0CBBB9, $0B8004
        dl $0B8004, $0B8004, $0B8004, $0B8004
        dl $0CC0B8, $0CBD5E, $0CBF05, $0B8004
        dl $0B8004, $0B8004, $0B8004, $0B8004
        
        dl $0B8004, $0B8004, $0B8004, $0CC0B8
        dl $0CB8AC, $0CC044, $0CBFDE, $0CB67F
        dl $0B8004, $0B8004, $0B8004, $0B8004
        dl $0CC0B0, $0CB67F, $0CB5CC, $0CB743
    }

; ==============================================================================

    ; *$17D0D-$17D25 LOCAL
    LoadSubscreenOverlay:
    {
        REP #$30

        ; Loads data for the overlay and converts from map32 to map16.
        JSR LoadSubOverlayMap32
        
        LDA.w #$1000 : STA $CC
        
        SEP #$30
        
        JSR Map16ToMap8.subscreenOverlay
        
        ; Trigger an NMI routine that will upload the subscreen overlay to
        ; vram during vblank    
        LDA.b #$04 : STA $17 : STA $0710

        INC $11
        
        RTS
    }

; ==============================================================================

    ; *$17D26-$17D86 LOCAL
    Map16ToMap8:
    {

        !srcAddr    = $04
        !srcBank    = $06
        !counter    = $08
        
        ; -------------------------------
    
    .subscreenOverlay
    
        ; data bank = 0x0F
        PHB : LDA.b #$0F : PHA : PLB
        
        REP #$30
        
        ; $04[3] = $7E4000, which is the source address 
        LDA.w #$4000 : STA !srcAddr
        LDA.w #$007E
        
        BRA .ready
    
    ; *$17D37 ALTERNATE ENTRY POINT
    .normalArea
    
        ; data bank = 0x0F
        PHB : LDA.b #$0F : PHA : PLB
        
        REP #$30
        
        ; $04[3] = $7E2000, which is the source address
        LDA.w #$2000 : STA !srcAddr
        LDA.w #$007E
    
    .ready
    
        STA !srcBank
        
        ; $84 += 0x1000
        LDA $84 : ADD.w #$1000 : STA $84
        
        STZ $0A : STA $0E
        
        LDA.w #$0010 : STA !counter
        
    .conversionLoop
    
        JSR Map16ChunkToMap8
        
        ; $84 -= 0x0080, $88 = ($88 - 1) % 32
        LDA $84 :        SUB.w #$0080 : STA $84
        LDA $88 : DEC A : AND.w #$001F : STA $88
        
        JSR Map16ChunkToMap8
        
        ; $84 -= 0x0080, $88 = ($88 - 1) & 32
        LDA $84 :        SUB.w #$0080 : STA $84
        LDA $88 : DEC A : AND.w #$001F : STA $88
        
        DEC !counter : BNE .conversionLoop
        
        SEP #$30
        
        PLB
        
        RTS
    }

; ==============================================================================
    
    ; *$17D87 - $17E46 LOCAL
    Map16ChunkToMap8:
    {
        ; Converts Map16 data to Map8 data (normal tile data) 0x40 bytes at a time.
        ; Also populates $7F4000 with the addresses of each of the resultant Map8 chunks.
        
        !srcAddr    = $04
        !map16Buf   = $0500
        
        ; ---------------------------------------
        
        ; Y = ($84 - 0x0410) & 0x1FFF
        ; X = $86 << 1
        ; $00 = 0x0010
        LDA $84      : SUB.w #$0410 : AND.w #$1FFF : TAY
        LDA $86      : ASL A : TAX
        LDA.w #$0010 : STA $00
    
    .getMap16Chunk
    
        ; grab 0x20 map16 tiles (which is a 16 X 512 pixel swath) and populate the buffer with these tiles
        
        LDA [!srcAddr], Y : STA !map16Buf, X
        
        ; X = (X + 2) & 0x003F, Y = (Y + 2) & 0x1FFF
        INX #2 : TXA : AND.w #$003F : TAX
        INY #2 : TYA : AND.w #$1FFF : TAY
        
        LDA [!srcAddr], Y : STA !map16Buf, X
        
        ; X = (X + 2) & 0x003F, Y = (Y + 2) & 0x1FFF
        INX #2 : TXA : AND.w #$003F : TAX
        INY #2 : TYA : AND.w #$1FFF : TAY
        
        DEC $00 : BNE .getMap16Chunk
        
        LDA $88 : STA $02 : CMP.w #$0010 : BCC .inRange
        
        ; limit $02 to the range 0x00 to 0x0F
        AND.w #$000F : STA $02
        
        LDA.w #$0800 : STA $00
    
    .inRange
    
        ; $00 += ($02 * 0x40)
        LDA $02 : ASL #6 : ADD $00 : STA $00
        
        ; why they needed to use a long address for this, I don't know. LDA.w #$0000 would have sufficed.
        LDA $02F889
        
        JSR .prepForUpload
        
        ; $00 += 0x0400
        LDA $00 : ADD.w #$0400 : STA $00
        
        ; why they needed to use a long address for this, I don't know. LDA.w #$0020 would have sufficed.
        LDA $02F88B
    
    .prepForUpload
    
        ; $02 = either 0x0000 or 0x0020
        STA $02
        
        ; this is how the DMA transfer later knows where to blit to.
        LDX $0A : LDA $00 : ORA $CC : STA $7F4000, X : INX #2 : STX $0A
        
        ; The index for the target array.
        LDX $0E
        
        ; Going to loop #$10 times and write #$80 bytes overall.
        LDA.w #$0010 : STA $0C
    
    .nextMap16Tile
    
        ; Load a map16 value from the buffer at $7E0500
        LDY $02 : LDA !map16Buf, Y
        
        ; increment to the next map16 value's position
        INY #2 : STY $02
        
        ; A *= 8
        ASL #3 : TAY
        
        ; The data in $7F2000 will end up as the tilemap for BG0 or BG1 (depending on settings)
        ; Also note that $8000 and its cousins here represent $0F8000, etc, in actuality.
        LDA $8000, Y : STA $7F2000, X
        LDA $8004, Y : STA $7F2040, X : INX #2
        LDA $8002, Y : STA $7F2000, X
        LDA $8006, Y : STA $7F2040, X : INX #2
        
        DEC $0C : BNE .nextMap16Tile
        
        ; Increment the index for the target array by #$40 (since we weren’t doing it during
        ; the loop)
        TXA : ADD.w #$0040 : STA $0E
        
        RTS
    }

; ==============================================================================
    
    ; *$17E47-$17E70 LOCAL
    Overworld_RestoreFailedWarpMap16:
    {
        ; When Link warps between worlds and the warp fails, he has to warp
        ; back to the world he came from. This routine ensures that any rocks,
        ; bushes, signs Link picked up before he warped retain that state
        ; after he gets warped back. If the warp was successful, however,
        ; this routine will not be used. This prevents you from say,
        ; getting stuck on a rock b/c and having and infinite loop of
        ; failed warps from the DW to the LW and back.
        ; It makes it like the warp never happened, from a graphical standpoint.
        
        REP #$30
        
        LDA $04AC : BEQ .return
        
        LDX.w #$0000 : STX $00
    
    .loop
    
        ; Supply the address of the modification to the tilemap
        LDX $00 : LDA $7EF800, X : TAY
        
        ; Supply the actual map16 tile value to be used
        LDA $7EFA00, X : TYX : STA $7E2000, X : INC $00 : INC $00
        
        LDA $00 : CMP $04AC : BNE .loop
    
    .return
    
        SEP #$30
        
        RTS
    }

; ==============================================================================
    
    ; *$17E71 - $17EBA JUMP LOCATION
    Intro_LoadSpriteStats:
    {
        ; Decompresses and then stores battle information relevant to enemy
        ; sprites.
        
        ; Target address at $00 = $7F4000
        LDA.b #$00 : STA $00
        LDA.b #$40 : STA $01
        LDA.b #$7F : STA $02
        
        ; Source address at $C8 =  $03E800 = $1E800 in Rom.
        LDA.b #$00 : STA $C8
        LDA.b #$E8 : STA $C9
        LDA.b #$03 : STA $CA
        
        JSR Overworld_Decomp
        
        ; Long address at $00 = $7F4000
        LDA.b #$00 : STA $00
        LDA.b #$40 : STA $01
        LDA.b #$7F : STA $02
        
        ; Index registers will be 16-bit for the loop.
        REP #$10
        
        LDX.w #$0000 : TXY
    
    .loadLoop
    
        ; Addresses accessed will be $7F4000-$7F47FF
        ; Divide by 16
        LDA [$00], Y : PHA : LSR #4 : STA $7F6000, X
        
        ; Get the original value, take the least four bits, and store it at
        ; the high byte location.
        PLA : AND.b #$0F : STA $7F6001, X
        
        ; Addresses written to will be $7F6000-$7F6FFF
        INY
        
        INX #2 : CPX.w #$1000 : BCC .loadLoop
        
        SEP #$30
        
        RTL
    }

; ==============================================================================
    
    ; *$17EBB-$17F5E LOCAL
    Overworld_Decomp:
    {
        ; A slight variant on the normal Decomp routine (the only difference is an extra XBA somewhere in the routine)
        
        REP #$10
        
        LDY.w #$0000
    
    ; *$17EC0 JUMP LOCATION    
    BRANCH_GETNEXTCODE: 
    
        JSR OverworldDecomp_GetNextSourceOctet
        
        ; Is it 0xFF? If not get data until we get a 0xFF byte.
        CMP.b #$FF : BNE BRANCH_ITERATE
        
        SEP #$10 ; If yes, set the X-flag and exit the subroutine.
            
        RTS
    
    BRANCH_ITERATE:
    
        STA $CD : AND.b #$E0 : CMP.b #$E0 : BEQ BRANCH_EXPANDED ; [111]
        
        PHA
        
        LDA $CD
        
        REP #$20
        
        AND.w #$001F ; Now get me the bottom five bits.
        
        BRA BRANCH_NORMAL
    
    BRANCH_EXPANDED: EXPANDED MODE APPEARS TO ALLOW US TO INTERFACE WITH VALUES LARGER THAN #$32, MAYBE AS LARGE AS $132?
    
        ; Get $CD, and shift it left three times.
        ; Again we're interested in the top three bits.
        LDA $CD : ASL #3 : AND.b #$E0 : PHA
        
        LDA $CD : AND.b #$03 : XBA
        
        JSR OverworldDecomp_GetNextSourceOctet
        
        REP #$20
        
    BRANCH_NORMAL:

        ; Increment the value and save it to $CB
        INC A : STA $CB
        
        SEP #$20; Return to 8-bit accumulator.
        
        ; Get the top three bits that were set in $CD.
        ; If none of the top three bits were set…[000]
        PLA : BEQ BRANCH_NONREPEATING
        
        BMI BRANCH_COPY ; If the top most bit was set…[101], [110], [100]
        
        ASL A : BPL BRANCH_REPEATING ; Provided nothing shifted into the MSB… [001]
        
        ; If it was negative, shift again.
        ASL A : BPL BRANCH_REPEATINGWORD ; [010]
        
        JSR $FF5F ; And of course the last case, [011]
        
        LDX $CB
    
    BRANCH_INCREMENTWRITE:
    
        STA [$00], Y
        
        INC A
        
        INY
        
        DEX : BNE BRANCH_INCREMENTWRITE
        
        BRA BRANCH_GETNEXTCODE
    
    BRANCH_NONREPEATING:
    
        JSR $FF5F ; Get the next value.
        
        ; Store it at TargetAddress, Y
        STA [$00], Y
        
        INY
        
        ; This is the bottom LSB's of $CD + 1
        ; Decrement $CB until it's zero.
        LDX $CB : DEX : STX $CB : BNE BRANCH_NONREPEATING
        
        BRA BRANCH_GETNEXTCODE
    
    BRANCH_REPEATING:
    
        JSR $FF5F ; Get the next value.
        
        LDX $CB ; Get the 5 LSB plus one.
    
    BRANCH_LOOPBACK:
    
        STA [$00], Y; Store to TargetAddress, Y
        
        INY
        
        ; Loop until X = 0.
        DEX : BNE BRANCH_LOOPBACK
        
        BRA BRANCH_GETNEXTCODE
    
    BRANCH_REPEATINGWORD:
    
        JSR OverworldDecomp_GetNextSourceOctet
        
        XBA
        
        JSR OverworldDecomp_GetNextSourceOctet
        
        LDX $CB
    
    BRANCH_MOREBYTES:
    
        ; Two byte were read, this is the first one
        XBA : STA [$00], Y
        
        INY
        
        DEX : BEQ BRANCH_OUTOFBYTES
        
        XBA : STA [$00], Y ; Store the second value, alternate, repeat.
        
        INY
        
        DEX : BNE BRANCH_MOREBYTES
    
    BRANCH_OUTOFBYTES:
    
        JMP $FEC0 ; $17EC0 IN ROM.
    
    BRANCH_COPY:
    
        ; // If the topmost bit was set, retrieve the next value.
        
        JSR OverworldDecomp_GetNextSourceOctet
        
        XBA ; Exchange the accumulators.
        
        JSR OverworldDecomp_GetNextSourceOctet
        
        TAX ; Put that sucker in X (full 16-bit)
    
    BRANCH_LOOPBACK2:
    
        ; And push the current Y index, Then shove X into Y
        ; (The newest byte value)
        PHY : TXY
        
        ; Load from TargetAddress, Y
        LDA [$00], Y : TYX
        
        ; Retrieve the proper index
        PLY
        
        STA [$00], Y
        
        INY
        
        INX
        
        REP #$20
        
        DEC $CB : SEP #$20 : BNE BRANCH_LOOPBACK2
        
        JMP $FEC0 ;$17EC0 IN ROM. SAME EXPLANATION AS BEFORE.
    }
    
; ==============================================================================

    ; *$17F5F-$17F6D LOCAL
    OverworldDecomp_GetNextSourceOctet:
    {
        LDA [$C8]
        
        LDX $C8 : INX : BNE .didnt_cross_bank_boundary
        
        ; Made to avoid crossing the 0x8000 wide bank boundaries
        ; We can see this since $CA (the bank) is incremented.
        LDX.w #$8000
        
        INC $CA
    
    .didnt_cross_bank_boundary
    
        ; X might be one more than it was, or 0x8000, depending.
        STX $C8
        
        RTS
    }

; ==============================================================================
   
   ; $17F6E-$17FFF NULL (Use for expansion)
   
; ==============================================================================

    warnpc $038000
