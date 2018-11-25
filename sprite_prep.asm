
; ==============================================================================

    !null_ptr = $0000

    ; *$3064D-$30840 JUMP LOCATION
    SpritePrep_Main:
    {
        ; SPRITE PREP ROUTINES 1
        
        JSL Sprite_LoadProperties
        
        INC $0DD0, X
        
        LDA $0E20, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw SpritePrep_Raven                    ; 0x00 - Raven
        dw SpritePrep_Vulture                  ; 0x01 - Vulture
        dw SpritePrep_DoNothing                ; 0x02 - Flying Stalfos Head
        dw !null_ptr                           ; 0x03 - Defunct Sprite, DO NOT USE!!!!
        dw SpritePrep_GoodSwitch               ; 0x04 - Good Switch
        dw SpritePrep_DoNothing                ; 0x05 - Switch?
        dw SpritePrep_GoodSwitch               ; 0x06 - Bad Switch
        dw SpritePrep_SwitchFacingUp           ; 0x07 - Switch again, facing up
        dw SpritePrep_Octorock                 ; 0x08 - Octorock
        dw SpritePrep_GiantMoldorm             ; 0x09 - Giant Moldorm
        dw SpritePrep_Octorock                 ; 0x0A - Four Shooter Octorock
        dw SpritePrep_DoNothing                ; 0x0B - Chicken / Chicken Lady
        dw SpritePrep_DoNothing                ; 0x0C - Octorock projectile
        dw SpritePrep_DoNothing                ; 0x0D - Buzzblob
        dw SpritePrep_DoNothing                ; 0x0E - Plants with big mouths
        dw SpritePrep_Octoballoon              ; 0x0F - Octoballoon
        dw SpritePrep_DoNothing                ; 0x10 - Octospawn
        dw SpritePrep_DoNothing                ; 0x11 - Hinox
        dw SpritePrep_DoNothing                ; 0x12 - Moblin
        dw SpritePrep_Helmasaur                ; 0x13 - Helmasaur
        dw SpritePrep_GargoyleGrate            ; 0x14 - Gargoyle Grate
        dw SpritePrep_Bubble                   ; 0x15 - Bubble
        dw SpritePrep_Elder                    ; 0x16 - Sahasralah / Aginah
        dw SpritePrep_DoNothing                ; 0x17 - Rupee Crab under bush
        dw SpritePrep_Moldorm                  ; 0x18 - Moldorm
        dw SpritePrep_Poe                      ; 0x19 - Poe
        dw SpritePrep_Dwarf                    ; 0x1A - Dwarves and helper sprites
        dw SpritePrep_DoNothing                ; 0x1B - Arrow in Wall?
        dw SpritePrep_MovableStatue            ; 0x1C - Movable Statue
        dw SpritePrep_IgnoresProjectiles       ; 0x1D - Weathervane
        dw SpritePrep_CrystalSwitch            ; 0x1E - Crystal Switch
        dw SpritePrep_BugNetKid                ; 0x1F - Bug Net Kid
        dw SpritePrep_DoNothing                ; 0x20 - Sluggula
        dw SpritePrep_PushSwitch               ; 0x21 - Push Switch
        dw SpritePrep_DoNothing                ; 0x22 - Ropa
        dw SpritePrep_Bari                     ; 0x23 - Bari (Blue)
        dw SpritePrep_Bari                     ; 0x24 - Bari (Red)
        dw SpritePrep_TalkingTree              ; 0x25 - Conversational Tree
        dw SpritePrep_HardHatBeetle            ; 0x26 - Hardhat Beetle
        dw SpritePrep_DoNothing                ; 0x27 - Deadrock
        dw SpritePrep_StoryTeller_1            ; 0x28 - Story Teller Set 1
        dw SpritePrep_HumanMulti_1             ; 0x29 - Human NPC Set 1
        dw SpritePrep_IgnoresProjectiles       ; 0x2A - Sweeping lady
        dw SpritePrep_HoboEntities             ; 0x2B - Hobo under bridge
        dw SpritePrep_Lumberjacks              ; 0x2C - Lumberjack Bros.
        dw SpritePrep_IgnoresProjectiles       ; 0x2D - ???? Telepathic Stones
        dw SpritePrep_FluteBoy                 ; 0x2E - Flute Boy's Notes
        dw SpritePrep_IgnoresProjectiles       ; 0x2F - Race Game Couple
        dw SpritePrep_IgnoresProjectiles       ; 0x30 - Person? (HM Name)
        dw SpritePrep_FortuneTeller            ; 0x31 - Fortune Teller / Smithy ... thing?
        dw SpritePrep_IgnoresProjectiles       ; 0x32 - Quarrel Bros.
        dw SpritePrep_PullForRupees            ; 0x33 - Pull For Rupees
        dw SpritePrep_YoungSnitchGirl          ; 0x34 - Young Snitch Girl
        dw SpritePrep_InnKeeper                ; 0x35 - Inn Keeper
        dw SpritePrep_IgnoresProjectiles       ; 0x36 - Witch
        dw SpritePrep_IgnoresProjectiles       ; 0x37 - Waterfall
        dw SpritePrep_DoNothing                ; 0x38 - Arrow Target
        dw SpritePrep_MiddleAgedMan            ; 0x39 - Middle-aged desert guy
        dw SpritePrep_MadBatter                ; 0x3A - Mad Batter
        dw SpritePrep_DashItem                 ; 0x3B - Dash item
        dw SpritePrep_IgnoresProjectiles       ; 0x3C - Kid in village near trough
        dw SpritePrep_OldSnitchLady            ; 0x3D - Old Snitch Lady
        dw SpritePrep_DoNothing                ; 0x3E - Rupee Crab under rock
        dw SpritePrep_DoNothing                ; 0x3F - Tutorial Soldier
        dw SpritePrep_EvilBarrier              ; 0x40 - Evil barrier to Hyrule Castle 2
        dw SpritePrep_Soldier                  ; 0x41 - Green Soldier
        dw SpritePrep_Soldier                  ; 0x42 - Blue Soldier
        dw SpritePrep_Soldier                  ; 0x43 - Red Spear Soldier
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x44 - Psycho Trooper
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x45 - Psycho Spear Soldier
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x46 - Blue Archer Soldier
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x47 - Green Archer Bush Soldier
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x48 - Red Javelin Trooper
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x49 - Red Javelin Bush Soldier
        dw SpritePrep_TrooperAndArcherSoldier  ; 0x4A - Green Enemy Bombs
        dw SpritePrep_Recruit                  ; 0x4B - Green Soldier (weak version)
        dw SpritePrep_GerudoMan                ; 0x4C - Gerudo Man
        dw SpritePrep_Toppo                    ; 0x4D - Toppo
        dw SpritePrep_Popo                     ; 0x4E - Popo
        dw SpritePrep_Bot                      ; 0x4F - Bot
        dw SpritePrep_DoNothing                ; 0x50 - Metal Ball
        dw SpritePrep_Armos                    ; 0x51 - Armos
        dw SpritePrep_ZoraKing                 ; 0x52 - Zora King
        dw SpritePrep_ArmosKnight              ; 0x53 - Armos Knight
        dw SpritePrep_Lanmola                  ; 0x54 - Lanmola
        dw SpritePrep_ZoraAndFireball          ; 0x55 - Zora and Fireball
        dw SpritePrep_WalkingZora              ; 0x56 - Walking Zora
        dw SpritePrep_DesertBarrier            ; 0x57 - Desert Palace barriers
        dw SpritePrep_DoNothing                ; 0x58 - Crab
        dw SpritePrep_LostWoodsBird            ; 0x59 - Lost Woods Bird
        dw SpritePrep_LostWoodsSquirrel        ; 0x5A - Lost Woods Squirrel
        dw SpritePrep_Spark                    ; 0x5B - Spark (clockwise)
        dw SpritePrep_Spark                    ; 0x5C - Spark (counter-clockwise)
        dw SpritePrep_RollerDownUp             ; 0x5D - Roller (down then up)
        dw SpritePrep_RollerUpDown             ; 0x5E - Roller (up then down)
        dw SpritePrep_RollerRightLeft          ; 0x5F - Roller (????)
        dw SpritePrep_RollerLeftRight          ; 0x60 - Roller (????)
        dw SpritePrep_DoNothing                ; 0x61 - Beamos
        dw SpritePrep_MasterSword              ; 0x62 - Master Sword and beams of light.
        dw SpritePrep_Debirando                ; 0x63 - Debirando Pit
        dw SpritePrep_FireDebirando            ; 0x64 - Debirando
        dw SpritePrep_ArcheryGameGuyTrampoline ; 0x65 - Archery Game Guy
        dw SpritePrep_WallCannon               ; 0x66 - Wall Cannon
        dw SpritePrep_WallCannon               ; 0x67 - Wall Cannon
        dw SpritePrep_WallCannon               ; 0x68 - Wall Cannon
        dw SpritePrep_WallCannon               ; 0x69 - Wall Cannon
        dw SpritePrep_DoNothing                ; 0x6A - Ball And Chain Trooper
        dw SpritePrep_DoNothing                ; 0x6B - Cannon Trooper
        dw SpritePrep_DoNothing                ; 0x6C - Warp Vortex
        dw SpritePrep_Rat                      ; 0x6D - Rat
        dw SpritePrep_Rope                     ; 0x6E - Rope
        dw SpritePrep_Keese                    ; 0x6F - Keese
        dw SpritePrep_DoNothing_2              ; 0x70 - Helmasaur King Fireball
        dw SpritePrep_Leever                   ; 0x71 - Leever
        dw SpritePrep_IgnoresProjectiles       ; 0x72 - Pond Activator / Script
        dw SpritePrep_UncleAndSageTrampoline   ; 0x73 - Link's Uncle / Sage / Watergate Barrier (weird I know) <-- where is the evidence for the watergate part????!!!
        dw SpritePrep_RunningManTrampoline     ; 0x74 - Red Hat Wussy
        dw SpritePrep_IgnoresProjectiles       ; 0x75 - Bottle Vendor
        dw SpritePrep_ZeldaTrampoline          ; 0x76 - Princess Zelda
        dw SpritePrep_Bubble                   ; 0x77 - Alternate Bubble
        dw SpritePrep_ElderWife                ; 0x78 - Elder's Wife
        dw SpritePrep_DashTriggeredSprite      ; 0x79 - Good Bee stuck in Ice Cavern
        dw SpritePrep_Agahnim                  ; 0x7A - Agahnim
        dw SpritePrep_DoNothing_2              ; 0x7B - Agahnim energy balls
        dw SpritePrep_GreenStalfos             ; 0x7C - Green Stalfos
        dw SpritePrep_SpikeTrap                ; 0x7D - Spike Trap
        dw SpritePrep_GuruguruBar              ; 0x7E - Guruguru Bar
        dw SpritePrep_GuruguruBar              ; 0x7F - Guruguru Bar
        dw SpritePrep_DoNothing_2              ; 0x80 - Wandering Fireball Chains
        dw SpritePrep_DoNothing_2              ; 0x81 - Hover
        dw SpritePrep_BubbleGroupTrampoline    ; 0x82 - Bubble Group
        dw SpritePrep_EyegoreTrampoline        ; 0x83 - Eyegore
        dw SpritePrep_EyegoreTrampoline        ; 0x84 - Eyegore 2
        dw SpritePrep_DoNothing_2              ; 0x85 - Yellow Stalfos
        dw SpritePrep_Kodondo                  ; 0x86 - Kodondo
        dw SpritePrep_DoNothing_2              ; 0x87 - Flames (what?)
        dw SpritePrep_Mothula                  ; 0x88 - Mothula
        dw SpritePrep_DoNothing_2              ; 0x89 - Mothula Beam
        dw SpritePrep_SpikeBlock               ; 0x8A - Spike Block
        dw SpritePrep_DoNothing_2              ; 0x8B - Gibdo
        dw SpritePrep_Arghus                   ; 0x8C - Arrghus
        dw SpritePrep_Arrgi                    ; 0x8D - Arrgi
        dw SpritePrep_DoNothing_2              ; 0x8E - Chair Turtles (kill with hammer)
        dw SpritePrep_Terrorpin                ; 0x8F - Terrorpin
        dw SpritePrep_DoNothing_2              ; 0x90 - Grabber Things (Floor master?) 
        dw SpritePrep_DoNothing_2              ; 0x91 - Stalfos Knight
        dw SpritePrep_HelmasaurKing            ; 0x92 - Helmasaur King
        dw SpritePrep_Bumper                   ; 0x93 - Bumper
        dw SpritePrep_DoNothing                ; 0x94 - Pirogusu
        dw SpritePrep_LaserEyeTrampoline       ; 0x95 - Laser Eye (right)
        dw SpritePrep_LaserEyeTrampoline       ; 0x96 - Laser Eye (left)
        dw SpritePrep_LaserEyeTrampoline       ; 0x97 - Laser Eye (down)
        dw SpritePrep_LaserEyeTrampoline       ; 0x98 - Laser Eye (up)
        dw SpritePrep_DoNothing                ; 0x99 - Attack Penguin?
        dw SpritePrep_Kyameron                 ; 0x9A - Kyameron
        dw SpritePrep_DoNothing                ; 0x9B - Wizzrobe
        dw SpritePrep_Zoro                     ; 0x9C - Zoro
        dw SpritePrep_Babusu                   ; 0x9D - Babusu
        dw SpritePrep_FluteBoyOstrich          ; 0x9E - Ostrich seen with Flute Boy
        dw SpritePrep_FluteBoyAnimals          ; 0x9F - Rabbit seen with Flute Boy
        dw SpritePrep_FluteBoyAnimals          ; 0xA0 - Bird seen with Flute Boy
        dw SpritePrep_MoveDownOneTile          ; 0xA1 - Freezor
        dw SpritePrep_Kholdstare               ; 0xA2 - Kholdstare
        dw SpritePrep_KholdstareShell          ; 0xA3 - Kholdstare part 2?
        dw SpritePrep_IceBallGenerator         ; 0xA4 - Kholdstare Ice balls
        dw SpritePrep_Zazakku                  ; 0xA5 - Blue Zazak
        dw SpritePrep_Zazakku                  ; 0xA6 - Red Zazak
        dw SpritePrep_Stalfos                  ; 0xA7 - Stalfos
        dw SpritePrep_Bomber                   ; 0xA8 - Green Bomber (Zirro?)
        dw SpritePrep_Bomber                   ; 0xA9 - Blue Bomber (Zirro?)
        dw SpritePrep_Pikit                    ; 0xAA - Pikit
        dw SpritePrep_CrystalMaiden            ; 0xAB - Crystal Maiden
        dw SpritePrep_DashTriggeredSprite      ; 0xAC - Apple(s) in tree
        dw SpritePrep_OldMountainManTrampoline ; 0xAD - Old Mountain Man
        dw SpritePrep_DoNothing                ; 0xAE - Down Pipe
        dw SpritePrep_DoNothing                ; 0xAF - Up Pipe
        dw SpritePrep_DoNothing                ; 0xB0 - Right Pipe
        dw SpritePrep_DoNothing                ; 0xB1 - Left Pipe
        dw SpritePrep_GoodBee                  ; 0xB2 - Good Bee
        dw SpritePrep_HylianPlaque             ; 0xB3 - Hylian Inscription? 
        dw SpritePrep_ThiefChest               ; 0xB4 - Thief Chest
        dw SpritePrep_BombShopEntity           ; 0xB5 - Bomb Shop Guy and company
        dw SrpritePrep_Kiki                    ; 0xB6 - Kiki the monkey
        dw SpritePrep_BlindMaiden              ; 0xB7 - Blind disguised as a Maiden
        dw SpritePrep_DoNothing                ; 0xB8 - Dialogue Testing Sprite
        dw SpritePrep_BullyAndBallGuy          ; 0xB9 - Bully and Ball Guy
        dw SpritePrep_Whirlpool                ; 0xBA - Whirlpool
        dw SpritePrep_ShopKeeper               ; 0xBB - Shopkeeper / Chest game guys
        dw SpritePrep_IgnoresProjectiles       ; 0xBC - Drunk in the Inn
        dw SpritePrep_Vitreous                 ; 0xBD - Vitreous
        dw SpritePrep_Vitreolus                ; 0xBE - Smaller Vitreous Eyeballs
        dw SpritePrep_DoNothing                ; 0xBF - Vitreous Lightning Blast
        dw SpritePrep_GreatCatfish             ; 0xC0 - Giant Cranky Catfish
        dw SpritePrep_ChattyAgahnim            ; 0xC1 - Agahnim Teleporting Zelda
        dw SpritePrep_DoNothing                ; 0xC2 - Boulder
        dw SpritePrep_Gibo                     ; 0xC3 - Gibo
        dw SpritePrep_DoNothing                ; 0xC4 - Thief
        dw SpritePrep_IgnoresProjectiles       ; 0xC5 - Evil Fireball Spitters
        dw SpritePrep_IgnoresProjectiles       ; 0xC6 - Fourway Fireball Spitters
        dw SpritePrep_Hokbok                   ; 0xC7 - Hokbok
        dw SpritePrep_BigFaerie                ; 0xC8 - Big Faerie 
        dw SpritePrep_GanonHelpers             ; 0xC9 - Ganon Helpers + Tektite
        dw SpritePrep_ChainChompTrampoline     ; 0xCA - Chain Chomp
        dw SpritePrep_TrinexxComponents        ; 0xCB - Trinexx Part 1
        dw SpritePrep_TrinexxComponents        ; 0xCC - Trinexx Part 2
        dw SpritePrep_TrinexxComponents        ; 0xCD - Trinexx Part 3
        dw SpritePrep_Blind                    ; 0xCE - Blind
        dw SpritePrep_Swamola                  ; 0xCF - Swamola
        dw SpritePrep_DoNothing                ; 0xD0 - Lynel
        dw SpritePrep_DoNothing                ; 0xD1 - Yellow Transform
        dw SpritePrep_IgnoresProjectiles       ; 0xD2 - Flopping Fish
        dw SpritePrep_Stal                     ; 0xD3 - Stal
        dw SpritePrep_IgnoresProjectiles       ; 0xD4 - Landmine
        dw SpritePrep_DiggingGameGuyTrampoline ; 0xD5 - Digging Game Guy 
        dw SpritePrep_Ganon                    ; 0xD6 - Ganon
        dw SpritePrep_Ganon                    ; 0xD7 - InvinceoGanon
        dw SpritePrep_HeartRefill              ; 0xD8 - Heart Refill 
        dw SpritePrep_GreenRupee               ; 0xD9 - Green Rupee
        dw SpritePrep_BlueRupee                ; 0xDA - Blue Rupee
        dw SpritePrep_RedRupee                 ; 0xDB - Red Rupee
        dw SpritePrep_OneBombRefill            ; 0xDC - 1 Bomb Refill
        dw SpritePrep_OneBombRefill            ; 0xDD - 4 Bomb Refill
        dw SpritePrep_EightBombRefill          ; 0xDE - 8 Bomb Refill
        dw SpritePrep_SmallMagicRefill         ; 0xDF - Small Magic Refill
        dw SpritePrep_FullMagicRefill          ; 0xE0 - Full Magic Refill
        dw SpritePrep_FiveArrowRefill          ; 0xE1 - 5 Arrow Refill
        dw SpritePrep_TenArrowRefill           ; 0xE2 - 10 Arrow Refill
        dw SpritePrep_Faerie                   ; 0xE3 - Faerie
        dw SpritePrep_Key                      ; 0xE4 - Key
        dw SpritePrep_BigKey                   ; 0xE5 - Big Key
        dw SpritePrep_ShieldPickup             ; 0xE6 - Shield Pickup
        dw SpritePrep_MushroomTrampoline       ; 0xE7 - Mushroom
        dw SpritePrep_FakeSwordTrampolnie      ; 0xE8 - Fake Master Sword
        dw SpritePrep_PotionShopTrampoline     ; 0xE9 - Magic Shop Dude and his items
        dw SpritePrep_HeartContainerTrampoline ; 0xEA - Heart Container
        dw SpritePrep_HeartPieceTrampoline     ; 0xEB - Heart Piece
        dw SpritePrep_ThrowableScenery         ; 0xEC - Bush / Rock
        dw SpritePrep_DoNothing                ; 0xED - Cane of Somaria Platform
        dw SpritePrep_MovableMantle            ; 0xEE - Movable Mantle
        dw SpritePrep_DoNothing                ; 0xEF - Cane of Somaria Platform (unused?)
        dw SpritePrep_DoNothing                ; 0xF0 - Cane of Somaria Platform (unused?)
        dw SpritePrep_DoNothing                ; 0xF1 - Cane of Somaria Platform (unused?)
        dw SpritePrep_MedallionTableTrampoline ; 0xF2 - Medallion Tablet
    }

; ==============================================================================

    ; *$30841-$30853 JUMP LOCATION
    SpritePrep_MovableMantle:
    {
        LDA $0D00, X : ADD.b #$03 : STA $0D00, X
    
    ; *$3084A ALTERNATE ENTRY POINT
    shared SpritePrep_MoveRightOneTile:
    
        LDA $0D10, X : ADD.b #$08 : STA $0D10, X
        
        RTS
    }

; ==============================================================================

    ; *$30854-$30858 JUMP LOCATION
    SpritePrep_MedallionTableTrampoline:
    {
        JSL SpritePrep_MedallionTabletLong
        
        RTS
    }

; ==============================================================================

    ; *$30859-$3086D JUMP LOCATION
    SpritePrep_GoodSwitch:
    {
        LDA $048E
        
        ; Are there only three rooms where these switches work? 0_o.
        
        CMP.b #$CE : BEQ BRANCH_ALPHA
        CMP.b #$04 : BEQ BRANCH_ALPHA
        CMP.b #$3F : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA.b #$0D : STA $0F50, X
    
    ; $3086D ALTERNATE ENTRY POINT
    shared SpritePrep_SwitchFacingUp:
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; *$3086E-$30872 JUMP LOCATION
    SpritePrep_OldSnitchLady:
    {
        JSL SpritePrep_SnitchesLong
        
        RTS
    }

; ==============================================================================

    ; $30873-$30873 JUMP LOCATION
    SpritePrep_DoNothing:
    {
        RTS
    }
    
; ==============================================================================

    ; $30874-$30877
    pool SpritePrep_Rat:
    {
        db $00, $05
        
        db $02, $08
    }

; ==============================================================================

    ; *$30878-$30887 JUMP LOCATION
    SpritePrep_Rat:
    {
        LDY $0FFF
        
        LDA $8874, Y : STA $0CD2, X
        
        LDA $8876, Y : STA $0E50, X
        
        RTS
    }

; ==============================================================================

    ; $30888-$3088D DATA
    pool SpritePrep_Keese:
    {
    
    .damage_class
        db $80, $85
    
    .hp
        db 1, 4
    
    .prize_pack
        db 0, 7
    }

; ==============================================================================

    ; *$3088E-$308A3 JUMP LOCATION
    SpritePrep_Keese:
    {
        LDY $0FFF
        
        LDA .damage_class, Y : STA $0CD2, X
        
        LDA .hp, Y : STA $0E50, X
        
        LDA .prize_pack, Y : STA $0BE0, X
        
        RTS
    }

; ==============================================================================

    ; $308A4-$308A9 DATA
    pool SpritePrep_Rope:
    {
    
    .damage_class
        db 1, 5
    
    .hp
        db 4, 8
    
    .prize_pack
        db 1, 7
    }

; ==============================================================================

    ; *$308AA-$308BF JUMP LOCATION
    SpritePrep_Rope:
    {
        LDY $0FFF
        
        LDA .damage_class, Y : STA $0CD2, X
        
        LDA .hp, Y : STA $0E50, X
        
        LDA .prize_pack, Y : STA $0BE0, X
        
        RTS
    }

; ==============================================================================

    ; *$308C0-$308C6 JUMP LOCATION
    SpritePrep_Swamola:
    {
        JSL Swamola_InitSegments
        JMP SpritePrep_CacheInitialCoords
    }

; ==============================================================================

    ; *$308C7-$308CE JUMP LOCATION
    SpritePrep_Blind:
    {
        JSR SpritePrep_Bosses
        JSL Blind_Initialize
        
        RTS
    }

; ==============================================================================

    ; *$308CF-$308D6 JUMP LOCATION
    SpritePrep_Ganon:
    {
        JSR SpritePrep_Bosses
        JSL Ganon_Initialize
        
        RTS
    }

; ==============================================================================

    ; $308D7-$308DE DATA
    pool SpritePep_HokBok:
    {
    
    .x_speeds
        db 16, -16,  16, -16
    
    .y_speeds
        db 16,  16, -16, -16
    }

; ==============================================================================

    ; *$308DF-$308FC JUMP LOCATION
    SpritePrep_Hokbok:
    {
        LDA.b #$03 : STA $0D90, X
        
        LDA.b #$08 : STA $0DA0, X
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$308FD-$30900 JUMP LOCATION
    SpritePrep_Vitreolus:
    {
        JSR SpritePrep_Bosses
        
        RTS
    }

; ==============================================================================

    ; *$30901-$3090B JUMP LOCATION
    SpritePrep_Gibo:
    {
        LDA.b #$10 : STA $0F70, X
        
        LDA.b #$08 : STA $0ED0, X
        
        RTS
    }

; ==============================================================================

    ; $3090C-$3090F DATA
    pool SpritePrep_Octoballoon:
    {
    
    ; \tcrf(unconfirmed) Even though the octoballoon is only used once as a 
    ; single enemy throughout the whole game, this suggests that differentiated
    ; behavior was available for when multiples were used in the same screen.
    .timers
        db $C0, $D0, $E0, $F0
    }

; ==============================================================================

    ; *$30910-$3091A JUMP LOCATION
    SpritePrep_Octoballoon:
    {
        TXA : AND.b #$03 : TAY
        
        LDA .timers, Y : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$3091B-$3093A JUMP LOCATION
    SpritePrep_EvilBarrier:
    {
        PHX
        
        LDX $8A
        
        LDA $7EF280, X : PLX : AND.b #$40 : BEQ .not_dead
        
        LDA.b #$04 : STA $0DC0, X
    
    ; *$3092C ALTERNATE ENTRY POINT
    shared SpritePrep_GreatCatfish:
    
    .not_dead
    
        JSR SpritePrep_MoveDownOneRightTwoTiles
        
        LDA $0D00, X : SUB.b #$0C : STA $0D00, X
        
        JMP SpritePrep_IgnoresProjectiles
    }
    
; ==============================================================================

    ; *$3093B-$3094C JUMP LOCATION
    SpritePrep_ChattyAgahnim:
    {
        LDA $0403 : AND.b #$40 : BEQ .not_triggered
        
        STZ $0DD0, X
        
        RTS
    
    .not_triggered
    
        JSL ChattyAgahnim_SpawnZeldaOnAltar
        JMP SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; *$3094D-$30962 JUMP LOCATION
    SpritePrep_Vitreous:
    {
        JSR SpritePrep_Bosses
        JSR SpritePrep_MoveDownOneRightTwoTiles
        
        LDA $0D00, X : SUB.b #$10 : STA $0D00, X
        
        JSL Vitreous_SpawnSmallerEyesLong
        JMP SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; $30963-$30968 DATA
    pool SpritePrep_Raven:
    {
    
    .bump_damage
        db $81, $88
    
    .hp
        db 4, 8
    
    .prize_pack
        db 6, 2
    }

; ==============================================================================

    ; *$30969-$3099B JUMP LOCATION
    SpritePrep_Raven:
    {
        LDY $0FFF
        
        LDA .bump_damage, Y : STA $0CD2, X
        
        LDA .hp, Y : STA $0E50, X
        
        LDA .prize_pack, Y : STA $0BE0, X
    
    ; *$3097E ALTERNATE ENTRY POINT
    shared SpritePrep_Vulture:
    
        LDA.b #$00 : STA $0F70, X
        
        LDA $0D10, X : AND.b #$10 : LSR #4 : STA $0D90, X
        
        BRA .setSubtype
    
    ; *$30991 ALTERNATE ENTRY POINT
    shared SpritePrep_Poe:
    
        LDA.b #$0C : STA $0F70, X
    
    ; *$30996 ALTERNATE ENTRY POINT
    .setSubtype
    
        LDA.b #$FE : STA $0E30, X
    
    ; $3099B ALTERNATE ENTRY POINT
    shared SpritePrep_Pikit:
    
        RTS
    }

; ==============================================================================

    ; *$3099C-$309D2 JUMP LOCATION
    SpritePrep_BlindMaiden:
    {
        LDA $7EF159 : AND.b #$08 : BNE .killSprite
        
        INC $0BA0, X
        
        LDA $7EF3CC : CMP.b #$06 : BEQ .killSprite
        
        LDA.b #$06 : STA $7EF3CC
        LDA.b #$00 : STA $7EF3D3
        
        PHX
        
        STZ $02F9
        
        JSL Tagalong_LoadGfx
        JSL Tagalong_Init
        
        PLX
        
        LDA.b #$00 : STA $7EF3CC
        
        RTS
    
    .killSprite
    
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; *$309D3-$309D7 JUMP LOCATION
    SpritePrep_Moldorm:
    {
        JSL Moldorm_Initialize
        
        RTS
    }

; ==============================================================================

    ; *$309D8-$309DE JUMP LOCATION
    SpritePrep_Bomber:
    {
        LDA.b #$10 : STA $0F70, X
        
        BRA SpritePrep_Poe.setSubtype
    }

; ==============================================================================

    ; *$309DF-$30A50 JUMP LOCATION
    SpritePrep_BombShopEntity:
    {
        INC $0BA0, X
        
        ; spawn a normal set of bombs for sale
        LDA.b #$B5 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $00 : SUB.b #$18 : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : SUB.b #$18 : STA $0D00, Y
        LDA $03 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$01 : STA $0E80, Y : STA $0BA0, Y
    
    .spawn_failed
    
        ; Make sure the Misery Mire and Ice Palace dungeons have been completed.
        LDA $7EF37A : AND.b #$05 : CMP #$05 : BNE .dont_spawn_super_bomb
        
        ; make sure smithy partner has been saved
        LDA $7EF3C9 : AND.b #$20 : BEQ .dont_spawn_super_bomb
        
        ; spawn the super bomb
        LDA.b #$B5 : JSL Sprite_SpawnDynamically : BMI .super_bomb_spawn_failed
        
        LDA $00 : SUB.b #$38 : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : SUB.b #$18 : STA $0D00, Y
        LDA $03 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y : STA $0BA0, Y
    
    .super_bomb_spawn_failed
    .dont_spawn_super_bomb
    
        RTS
    }

; ==============================================================================

    ; *$30A51-$30A58 JUMP LOCATION
    SpritePrep_BullyAndBallGuy:
    {
        JSL BullyAndBallGuy_SpawnBully
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; *$30A59-$30A78 JUMP LOCATION
    SpritePrep_ThiefChest:
    {
        ; Purple Treasure chest initializer
        
        ; If Link already has the chest following him no reason to spawn another
        LDA $7EF3CC : CMP.b #$0C : BEQ .self_terminate
        
        ; If chest has been opened already just kill next time it spawns.
        LDA $7EF3C9 : AND.b #$10 : BNE .self_terminate
        
        ; Chest hasn't been opened but Smithy also hasn't been saved...
        ; In other words, saving the smithy partner allows us to start on this
        ; side quest in the first place.
        LDA $7EF3C9 : AND.b #$20 : BEQ .self_terminate
        
        INC $0BA0, X
        
        RTS
    
    parallel pool SpritePrep_Dwarf:
    
    .self_terminate
    
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; *$30A79-$30AEF JUMP LOCATION
    SpritePrep_Dwarf:
    {
        INC $0BA0, X
        
        LDA $7EF3CA : AND.w #$40 : BEQ .light_world
        
        ; In Darkworld he's a smithy frog :D
        
        LDA $7EF3C9 : AND.b #$20 : BNE .self_terminate
        
        LDA $7EF3CC : CMP.b #$00 : BNE .self_terminate
        
        LDA.b #$02 : STA $0E80, X
        
        RTS
    
    .light_world
    
        ; \note The dwarves need this in order to not be passed through by
        ; the player. Questionable technique, but I guess they did what they
        ; had to do to ship the damn game, right?
        JSL Dwarf_SpawnDwarfSolidity
        
        ; in light world he can either be one or two dwarves?
        LDA $7EF3C9 : AND.b #$20 : BNE .partner_has_been_saved
        
        LDA $0D10, X : ADD.b #$02 : STA $0D10, X
        LDA $0D00, X : SUB.b #$03 : STA $0D00, X
        
        RTS
    
    .partner_has_been_saved
    
        LDA $0D10, X : ADD.b #$02 : STA $0D10, X
        LDA $0D00, X : SUB.b #$03 : STA $0D00, X
        
        JSR Smithy_SpawnOtherSmithy
        
        PHX : PHY : TYX
        
        JSL Dwarf_SpawnDwarfSolidity
        
        PLY : PLX 
        
        TYA : STA $0E90, X
        TXA : STA $0E90, Y
        
        LDA $7EF3C9 : AND.b #$80 : BEQ .they_dont_have_player_sword
        
        LDA.b #$05 : STA $0D80, X : STA $0D80, Y
    
    .they_dont_have_player_sword
    
        RTS
    }

; ==============================================================================

    ; *$30AF0-$30B00 JUMP LOCATION
    SpritePrep_Babusu:
    {
        JSR SpritePrep_MoveDownOneTile
    
    ; *$30AF3 ALTERNATE ENTRY POINT
    shared SpritePrep_Zoro:
    
        LDA $0E20, X : SUB.b #$9C : ASL A : STA $0DE0, X
        
        DEC $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $30B01-$30B02 DATA
    ; \unused Was it at one point intended that the speed of the laser beam
    ; be variable or configured here?
    pool SpritePrep_LaserEyeTrampoline
    {
    
    ; an assumptive name
    .speeds
        db $F8, $08
    }

; ==============================================================================

    ; *$30B03-$30B07 JUMP LOCATION
    SpritePrep_LaserEyeTrampoline:
    {
        JSL SpritePrep_LaserEyeLong
        
        RTS
    }

; ==============================================================================

    ; *$30B08-$30B11 JUMP LOCATION
    SpritePrep_Popo:
    {
        LDA.b #$07
        
        BRA .set_var
    
    ; *$30B0C ALTERNATE ENTRY POINT
    shared SpritePrep_Bot:
    
        LDA.b #$0F
    
    .set_var
    
        STA $0DA0, X
        
        RTS
    }

; ==============================================================================

    ; *$30B12-$30B1B JUMP LOCATION
    SpritePrep_MovableStatue:
    {
        LDA $0D00, X : ADD.b #$07 : STA $0D00, X
        
        RTS
    }

; ==============================================================================

    ; *$30B1C-$30B2D JUMP LOCATION
    SpritePrep_Bari:
    {
        ; Height starts out at 6.
        LDA.b #$06 : STA $0F70, X
        
        ; \hardcoded In this room the bari are confined until a large block
        ; is lifted.
        LDA $048E : CMP.b #$CE : BNE .not_that_one_ice_palace_room
        
        DEC $0DB0, X
    
    .not_that_one_ice_palace_room
    
        JMP $A342 ; $32342 IN ROM
    }
    
; ==============================================================================

    ; *$30B2E-$30B33 JUMP LOCATIONAN
    shared SpritePrep_GreenStalfos:
    
        LDA.b #$09 : STA $0F70, X
        
        RTS
    }

; ==============================================================================

    ; *$30B34-$30B3D JUMP LOCATION
    SpritePrep_PushSwitch:
    {
        LDA $0D00, X : ADD.b #$05 : STA $0D00, X
        
        RTS
    }

; ==============================================================================

    ; *$30B3E-$30B80 JUMP LOCATION
    SpritePrep_FireDebirando:
    {
        LDA.b #$63 : STA $0E20, X
        
        JSL Sprite_LoadProperties
        
        DEC $0ED0, X
    
    ; \note Hyrule magic was telling the truth. 0x63 is blue, 0x64 is red.
    ; 0x63 is really the pit, but both of end up with a 0x63 (pit) and a 0x64
    ; (debirando) and $0ED0, X decides whether the debirando itself is a red
    ; (fire) debirando or a normal one that doesn't shoot fireballs.
    
    ; *$30B4A ALTERNATE ENTRY POINT
    shared SpritePrep_Debirando:
    
        INC $0ED0, X
        
        LDA.b #$00 : STA $0DF0, X
        
        LDA.b #$06 : STA $0DC0, X
        
        JSR SpritePrep_IgnoresProjectiles
        
        LDA.b #$64 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$60 : STA $0DF0, Y
        
        ; Give the pit the index of the actual debirando that was spawned.
        TYA : STA $0EB0, X
        
        ; Presumably discriminates between red and blue debirando.
        LDA $0ED0, X : STA $0ED0, Y
        
        PHX
        
        TAX
        
        ; Well that just confirms the above.
        LDA .palettes, X : STA $0F50, Y
        
        PLX
    
    .spawn_failed
    
        RTS
    
    .palettes

        db $06, $08
    }

; ==============================================================================

    ; *$30B81-$30B92 JUMP LOCATION
    SpritePrep_Recruit:
    {
        ; Green Soldier (weak version) startup routine
        
        ; Pick a starting body direction and match it up with the starting head
        ; direction
        JSL GetRandomInt : AND.b #$03 : STA $0DE0, X : STA $0EB0, X
        
        ; Start it on a 16 second timer
        LDA.b #$10 : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$30B93-$30BA1 JUMP LOCATION
    SpritePrep_WallCannon:
    {
        LDA $0E20, X : SUB.b #$66 : STA $0DE0, X
        
        AND.b #$02 : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; *$30BA2-$30BA6 JUMP LOCATION
    SpritePrep_ArcheryGameGuyTrampoline:
    {
        JSL SpritePrep_ArcheryGameGuy
        
        RTS
    }

; ==============================================================================

    ; *$30BA7-$30BAA JUMP LOCATION
    SpritePrep_IgnoresProjectiles:
    {
        ; Many nonhostile sprites use this as their initialization routine
        ; e.g. the sweeping lady
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; *$30BAB-$30BBE JUMP LOCATION
    SpritePrep_FluteBoyAnimals:
    {
        JSR Sprite_IsToRightOfPlayer
        
        TYA : STA $0DE0, X
    
    ; *$30BB2 ALTERNATE ENTRY POINT
    shared SpritePrep_FluteBoyOstrich:
    
        LDA $7EF34C : CMP.b #$02 : BCC .dont_have_flute
        
        STZ $0DD0, X
    
    .dont_have_flute
    
        BRA SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; *$30BBF-$30BC3 JUMP LOCATION
    SpritePrep_DiggingGameGuyTrampoline:
    {
        JSL SpritePrep_DiggingGameGuy
        
        RTS
    }

; ==============================================================================

    ; *$30BC4-$30BE3 JUMP LOCATION
    SpritePrep_GargoyleGrate:
    {
        LDA $7EF2D8 : AND.b #$20 : BEQ .gateNotOpened
        
        STZ $0DD0, X
    
    ; *$30BCF ALTERNATE ENTRY POINT
    shared SpritePrep_PullForRupees:
    
    .gateNotOpened
    
        INC $0BA0, X
        
        LDA $0D10, X : SUB.b #$08 : STA $0D10, X
        LDA $0D30, X : SBC.b #$00 : STA $0D30, X
        
        RTS
    }

; ==============================================================================

    ; $30BE4-$30BF0 DATA
    pool SpritePrep_ShopKeeper:
    {
    
    .rooms
        db $0F, $10, $00, $06, $18, $12, $1E, $FF
        db $1F, $23, $24, $25, $27
    }

; ==============================================================================

    ; *$30BF1-$30C36 JUMP LOCATION
    SpritePrep_ShopKeeper:
    {
        INC $0BA0, X
        
        LDA $0E40, X : ORA.b #$02 : STA $0E40, X
        
        LDA $0F50, X : ORA.b #$0C : STA $0F50, X
        
        LDA $0E60, X : ORA.b #$10 : STA $0E60, X
        
        LDA $A0 
        
        LDY.b #$00
    
    .next_room
    
        CMP .rooms, Y : BEQ .room_match
        
        ; Wow... that could cause a bug real easily
        INY : BNE .next_room
    
    .room_match
    
        TYA
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8C37 = $30C37*
        dw $8C43 = $30C43*
        dw $8C5C = $30C5C*
        dw $8C60 = $30C60*
        dw $8C67 = $30C67* ; Chest game guy in Kakkariko
        dw $8C72 = $30C72*
        dw $8C8B = $30C8B*
        dw $8C72 = $30C72*
        
        dw $8C72 = $30C72*
        dw $8C8B = $30C8B*
        dw $8C91 = $30C91*
        dw $8C95 = $30C95*
        dw $8C8B = $30C8B*
    }

    ; *$30C37-$30C98 JUMP LOCATION
    {
        LDA.b #$00
        LDY.b #$07
        
        JSL ShopKeeper_SpawnInventoryItem
        
        LDY.b #$08
        
        BRA BRANCH_ALPHA
    
    ; *$30C43 ALTERNATE ENTRY POINT
    
        LDA.b #$00
        LDY.b #$09
        
        JSL ShopKeeper_SpawnInventoryItem
        
        LDA.b #$01
        LDY.b #$0D
        
        JSL ShopKeeper_SpawnInventoryItem
        
        LDA.b #$02
        LDY.b #$0B
        
        JSL ShopKeeper_SpawnInventoryItem
        
        RTS
    
    ; *$30C5C ALTERNATE ENTRY POINT
    
        LDA.b #$04
        
        BRA BRANCH_BETA
    
    ; *$30C60 ALTERNATE ENTRY POINT
    
        LDA.b #$01 : STA $0DC0, X
        
        BRA BRANCH_BETA

    ; *$30C67 ALTERNATE ENTRY POINT

        LDA.b #$03

    BRANCH_BETA:

        STA $0E80, X
        
        LDA.b #$FF : STA $04C4
        
        RTS
    
    ; *$30C72 ALTERNATE ENTRY POINT
    
        LDA.b #$00
        LDY.b #$07
        
        JSL ShopKeeper_SpawnInventoryItem
        
        LDY.b #$0A
    
    BRANCH_ALPHA:
    
        LDA.b #$01
        
        JSL ShopKeeper_SpawnInventoryItem
        
        LDA.b #$02
        LDY.b #$0C
        
        JSL ShopKeeper_SpawnInventoryItem
        
        RTS
    
    ; *$30C8B ALTERNATE ENTRY POINT
    
        LDA.b #$02
    
    BRANCH_GAMMA:
    
        STA $0E80, X
        
        RTS

    ; *$30C91 ALTERNATE ENTRY POINT

        LDA.b #$05
        
        BRA BRANCH_GAMMA

    ; *$30C95 ALTERNATE ENTRY POINT

        LDA.b #$06
        
        BRA BRANCH_GAMMA
    }

; ==============================================================================

    ; $30C99-$30C9D DATA
    pool SpritePrep_StoryTeller_1:
    {
    
    .rooms
        db $0E, $0E, $12, $1A, $14
    }

; ==============================================================================

    ; *$30C9E-$30CBD JUMP LOCATION
    SpritePrep_StoryTeller_1:
    {
        INC $0BA0, X
        
        LDA $A0
        
        LDY.b #$00
    
    .next_room
    
        CMP .rooms, Y : BEQ .room_match
        
        INY : BNE .next_room
    
    .room_match
    
        TYA : STA $0E80, X : BNE .not_first_room
        
        LDA $0D30, X : AND.b #$01 : BEQ .left_half_of_room
        
        INC $0E80, X
    
    .left_helf_of_room
    .not_first_room
    
        RTS
    }

; ==============================================================================

    ; $30CBE-$30CC0 DATA
    pool SpritePrep_HumanMulti_1_Trampoline:
    {
    
    .rooms
        db $03, $E1, $19
    }

; ==============================================================================

    ; *$30CC1-$30CD4 JUMP LOCATION
    SpritePrep_HumanMulti_1:
    {
        INC $0BA0, X
        
        LDA $A0
        
        LDY.b #$00
    
    .next_room
    
        CMP .rooms, Y : BEQ .room_match
        
        INY : BNE .next_room
    
    .room_match
    
        TYA : STA $0E80, X
        
        RTS
    }

; ==============================================================================

    ; *$30CD5-$30CDD JUMP LOCATION
    SpritePrep_Whirlpool:
    {
        INC $0BA0, X
        
        LDA.b #$01 : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; *$30CDE-$30CEF JUMP LOCATION
    SpritePrep_Elder:
    {
        INC $0BA0, X
        
        LDA $A0 : CMP.b #$0A : BNE .notAginah
        
        INC $0E80, X
        
        ; Basically changes him to Aginah rather than Sahasralah
        LDA.b #$0B : STA $0F50, X
    
    .notAginah
    
        RTS
    }

; ==============================================================================

    ; $30CF0-$30CF1 DATA
    SpritePrep_DashItem:
    {
    
    .event_masks
        db $40, $20
    }

; ==============================================================================

    ; $30CF2-$30D45 JUMP LOCATION
    SpritePrep_DashItem:
    {
        ; Dash Item set up function
        ; E.g. book of mudora and keys (also the fake tree on the OW)
        
        ; If no, make it a dashable treetop.
        LDA $1B : BEQ .fake_tree_top
        
        LDA.b #$02 : STA $0F20, X
        
        LDA $A0 : CMP.b #$07 : BNE .key
        
        ; Hardcoded check to see if this is the library
        ; If not, probably a key?
        LDA $A1 : CMP.b #$01 : BNE .key
        
        ; If in the library, do we already have the BoM?
        LDA $7EF34E : BEQ .book_of_mudora
        
        ; Otherwise, kill the sprite
        STZ $0DD0, X 
        
        RTS
    
    .book_of_mudora
    
        PHX
        
        LDA.b #$0E
        
        JSL GetAnimatedSpriteTile.variable
        
        PLX
        
        RTS
    
    .key
    
        LDA $0B9B : STA $0CBA, X : TAY
        
        INC $0B9B
        
        LDA $0403 : AND .event_masks, Y : BEQ .key_not_grabbed
        
        STZ $0DD0, X
    
    .key_not_grabbed
    
        ; Make this into a key item
        INC $0DC0, X
        
        LDA.b #$08 : STA $0F50, X
        
        LDA $0E60, X : ORA.b #$20 : STA $0E60, X
        
        RTS
    
    .fake_tree_top
    
        LDA.b #$02 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$30D46-$30D58 JUMP LOCATION
    SpritePrep_Kiki:
    {
        ; Kiki initialization routine
        
        INC $0BA0, X
        
        PHX
        
        LDX $8A : LDA $7EF280, X : PLX : AND.b #$20 : BEQ .entranceNotOpen
        
        ; Suicide if the entrance to the Dark Palace is opened.
        STZ $0DD0, X
    
    .entranceNotOpen
    
        RTS
    }

; ==============================================================================

    ; *$30D59-$30D7E JUMP LOCATION
    SpritePrep_MiddleAgedMan:
    {
        ; Middle-aged Desert Guy initializer
        
        INC $0BA0, X
        
        LDA $7EF3CC : CMP.b #$09 : BNE .not_already_followed
        
        STZ $0DD0, X
        
        RTS
    
    .not_already_followed
    
        CMP.b #$0C : BNE .thief_chest_not_following
        
        ; Put him into a mode where he'll open the chest
        LDA.b #$02 : STA $0D80, X
    
    .thief_chest_not_following
    
        LDA $7EF3C9 : AND.b #$10 : BEQ .hasnt_opened_chest_yet
        
        LDA.b #$04 : STA $0D80, X
    
    .hasnt_opened_chest_yet
    
        RTS
    }

; ==============================================================================

    ; *$30D7F-$30D8D JUMP LOCATION
    SpritePrep_BugNetKid:
    {
        LDA $7EF34D : BEQ .dont_have_net
        
        LDA.b #$03 : STA $0D80, X
    
    .dont_have_net
    
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; $30D8E-$30D93 DATA
    pool SpritePrep_GanonHelpers:
    {
    
    .palette
        db 9, 7
    
    .hp
        db 8, 12
    
    .bump_damage
        db 3, 5
    }

; ==============================================================================

    ; *$30D94-$30DC0 JUMP LOCATION
    SpritePrep_GanonHelpers:
    {
        LDA $0D10, X : LSR #4 : AND.b #$01 : STA $0D90, X : TAY
        
        LDA .palette, Y : STA $0F50, X
        
        LDA .hp, Y : STA $0E50, X
        
        LDA .bump_damage, Y : STA $0CD2, X
        
        LDA.b #$10 : JSR Sprite_ApplySpeedTowardsPlayer
        
        LDA #$20 : STA $0F80, X
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$30DC1-$30DC5 JUMP LOCATION
    SpritePrep_ChainChompTrampoline:
    {
        JSL SpritePrep_ChainChomp
        
        RTS
    }

; ==============================================================================

    ; *$30DC6-$30DD0 JUMP LOCATION
    SpritePrep_BigFaerie:
    {
        LDA.b #$18 : STA $0F70, X
        
        JSR SpritePrep_MoveDownOneRightTwoTiles
        JMP SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; *$30DD1-$30DDF JUMP LOCATION
    SpritePrep_ElderWife:
    {
        LDA $0D00, X : ADD.b #$08 : STA $0D00, X
    
    ; *$30DDA ALTERNATE ENTRY POINT
    shared SpritePrep_Lumberjacks:
    shared SpritePrep_MadBatter:
    
        JSR SpritePrep_MoveRightOneTile
        JMP SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; *$30DE0-$30DE6 JUMP LOCATION
    SpritePrep_FortuneTeller:
    {
        JSR SpritePrep_MoveDownOneRightTwoTiles
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; $30DE7-$30DE8 DATA
    pool SpritePrep_Leever:
    {
    
    .palettes
        db $0A, $02
    }

; ==============================================================================

    ; *$30DE9-$30DFC JUMP LOCATION
    SpritePrep_Leever:
    {
        LDA $0D10, X : LSR #4 : AND.b #$01 : STA $0D90, X : TAY
        
        LDA .palettes, Y : STA $0F50, X
        
        RTS
    }

; ==============================================================================

    ; *$30DFD-$30E2F JUMP LOCATION
    SpritePrep_HoboEntities:
    {
        ; \wtf Is this test code? It spawns a bunch of normal bums...
        LDY.b #$0F
    
    .spawn_next_hobo
    
        PHY
        
        JSR Hobo_SpawnHobo
        
        PLY : DEY : BNE .spawn_next_hobo
        
        ; \wtf Then does another loop to kill them all?
        LDY #$0F
    
    .terminate_next_hobo
    
        LDA $0E20, Y : CMP.b #$2B : BNE .not_a_hobo
        
        LDA.b #$00 : STA $0DD0, Y
    
    .not_a_hobo
    
        DEY : BNE .terminate_next_hobo
        
        JSR Hobo_SpawnCampfire
        
        TXY
        
        LDA $7EF3C9 : AND.b #$01 : BEQ .dont_have_hobo_bottle
        
        LDA.b #$03 : STA $0D80
    
    .dont_have_hobo_bottle
    
        TYX
        
        LDA.b #$01 : STA $0BA0
        
        RTS
    }

; ==============================================================================

    ; *$30E30-$30E41 JUMP LOCATION
    SpritePrep_MasterSword:
    {
        LDA $0D10, X : ADD.b #$06 : STA $0D10, X
        LDA $0D00, X : ADC.b #$06 : STA $0D00, X
        
        RTS
    }

; ==============================================================================

    ; *$30E42-$30E6A JUMP LOCATION
    SpritePrep_RollerRightLeft:
    {
        LDY.b #$00 : BRA .moving_on_horiz
    
    ; *$30E46 ALTERNATE ENTRY POINT
    shared SpritePrep_RollerLeftRight:
    
        LDY.b #$01
    
    .moving_on_horiz
    
        LDA $0D10, X : EOR.b #$10 : BRA .set_length
    
    ; *$30E4F ALTERNATE ENTRY POINT
    shared SpritePrep_RollerDownUp:
    
        LDY.b #$02 : BRA .moving_on_vert
    
    ; *$30E53 ALTERNATE ENTRY POINT
    shared SpritePrep_RollerUpDown:
    
        LDY.b #$03
    
    .moving_on_vert
    
        LDA $0D00, X
    
    .set_length
    
        AND.b #$10 : LSR #4 : STA $0D80, X : BEQ .short
        
        INC $0F60, X
    
    .short
    
        TYA : STA $0DE0, X
        
        RTS
    }

; ==============================================================================

    ; *$30E6B-$30E88 JUMP LOCATION
    SpritePrep_Kodondo:
    {
        LDA $0D10, X : ADD.b #$04 : STA $0D10, X
        
        LDA $0D00, X : SUB.b #$05 : STA $0D00, X
        LDA $0D20, X : SBC.b #$00 : STA $0D20, X
    
    ; *$30E85 ALTERNATE ENTRY POINT
    shared SpritePrep_Spark:
    
        DEC $0E30, X
        
        RTS
    }

; ==============================================================================

    ; $30E89-$30EC0 DATA
    pool Unused:
    {
        ; \tcrf(unverified, but only in the sense that we don't know its
        ; purpose.) Seems pretty clear that it's unused. Are these speeds?
        ; Graphics? Really hard to say for now.
        db $00, $E0, $F8, $18
        db $E8, $18, $D0, $30
        db $E8, $18, $E0, $F8
        db $18, $00, $00, $FF
        
        db $FF, $00, $FF, $00
        db $FF, $00, $FF, $00
        db $FF, $FF, $00, $00
        db $C0, $D0, $D8, $D0
        
        db $F0, $F0, $00, $00
        db $10, $10, $28, $30
        db $30, $40, $FF, $FF
        db $FF, $FF, $FF, $FF
        
        db $00, $00, $00, $00
        db $00, $00, $00, $00
    }

; ==============================================================================

    ; *$30EC1-$30EEF JUMP LOCATION
    SpritePrep_LostWoodsBird:
    {
        JSL GetRandomInt : AND.b #$1F : SUB.b #$10 : STA $0F80, X
        
        LDA.b #$40 : STA $0F70, X
    
    ; *$30ED2 ALTERNATE ENTRY POINT
    shared SpritePrep_LostWoodsSquirrel:
    
        JSR Sprite_IsToRightOfPlayer
        
        LDA.b #$10
        
        CPY.b #$00 : BEQ BRANCH_ALPHA
        
        LDA.b #$F0
    
    BRANCH_ALPHA:
    
        STA $0D50, X
        
        LDA.b #$FC
        
        LDY $069E : BPL BRANCH_BETA
        
        LDA.b #$04
    
    BRANCH_BETA:
    
        STA $0D40, X
        STA $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; $30EF0-$30EF1 DATA
    pool SpritePrep_Bubble:
    {
    
    .x_speeds
        db $10, $F0
    }

; ==============================================================================

    ; *$30EF2-$30F07 JUMP LOCATION
    SpritePrep_Bubble:
    {
        LDA $0D10, X : LSR #4 : AND.b #$01 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA.b #$F0 : STA $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$30F08-$30F0E JUMP LOCATION
    SpritePrep_IceBallGenerator:
    {
        JSR SpritePrep_Bosses
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; *$30F0F-$30F1B JUMP LOCATION
    SpritePrep_ZoraKing:
    {
        LDA $7EF356 : BEQ .noFlippers
        
        STZ $0DD0, X
        
        RTS
    
    .noFlippers
    
        JMP SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; *$30F1C-$30F3E LOCAL
    SpritePrep_Bosses:
    {
        LDA $0403 : BPL .bossNotDeadInHere
        
        ; If a heart piece has been obtained in this room do not spawn
        
        PLA : PLA
        
        STZ $0DD0, X
        
        RTS
    
    .bossNotDeadInHere
    
        LDY.b #$0F
    
    .nextSprite
    
        PHX
        
        LDX $0E20, Y
        
        LDA $0DB266, X
        
        PLX
        
        AND.b #$10 : BNE .dontKillSprite
        
        LDA.b #$00 : STA $0DD0, Y
    
    .dontKillSprite
    
        DEY : BPL .nextSprite
        
        RTS
    }

; ==============================================================================

    ; *$30F3F-$30F4C JUMP LOCATION
    SpritePrep_ArmosKnight:
    {
        JSR SpritePrep_Bosses
        
        LDA.b #$FF : STA $0DF0, X
        
        INC $0FF8
        
        JMP SpritePrep_MoveDownOneRightTwoTiles
    }

; ==============================================================================

    ; *$30F4D-$30F6C JUMP LOCATION
    SpritePrep_DesertBarrier:
    {
        ; Desert Palace barriers
        
        LDA $0B6A : STA $0D90, X
        
        INC $0B6A
        
        JSR SpritePrep_MoveDownOneRightTwoTiles
        
        LDA $0D10, X : LDY.b #$01 : CMP.b #$30 : BCC .set_direction
        
        ; Y = 0x02
        INY
        
        CMP.b #$E0 : BCS .set_direction
        
        ; Y = 0x03
        INY
    
    .set_direction
    
        TYA : STA $0DE0, X
    
    ; $30F6C ALTERNATE ENTRY POINT
    shared SpritePrep_Armos:
    
        RTS
    }

; ==============================================================================

    ; $30F6D-$30F70 DATA
    pool SpritePrep_Octorock:
    {
    
    .bump_damage
        db 3, 5
    
    .hp
        db 2, 4
    }

; ==============================================================================

    ; *$30F71-$30F89 JUMP LOCATION
    SpritePrep_Octorock:
    {
        LDY $0FFF
        
        LDA .hp, Y : STA $0E50, X
        
        LDA .bump_damage, Y : STA $0CD2, X
        
        JSL GetRandomInt : AND.b #$7F : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$30F8A-$30F94 JUMP LOCATION
    SpritePrep_GiantMoldorm:
    {
        JSR SpritePrep_Bosses
        
        INC $0BA0, X
        
        JSL Sprite_InitializedSegmented
        
        RTS
    }

; ==============================================================================

    ; *$30F95-$30F9C JUMP LOCATION
    SpritePrep_Lanmola:
    {
        JSR SpritePrep_Bosses
        JSL Lanmola_FinishInitialization
        
        RTS
    }

; ==============================================================================

    ; *$30F9D-$30FC8 JUMP LOCATION
    SpritePrep_SpikeTrap:
    {
        JSR SpritePrep_MoveDownOneRightTwoTiles
        
        BRA .cache_coords
    
    ; *$30FA2 ALTERNATE ENTRY POINT
    shared SpritePrep_ZoraAndFireball:
    
        LDA.b #$40 : STA $0DF0, X
    
    ; *$30FA7 ALTERNATE ENTRY POINT
    shared SpritePrep_GerudoMan:
    
        LDA.b #$08 : ADD $0D10, X : STA $0D10, X
    
    ; *$30FB0 ALTERNATE ENTRY POINT
    shared SpritePrep_Toppo:
    shared SpritePrep_Kyameron:
    shared SpritePrep_CacheInitialCoords:
    
    .cache_coords
    
        ; Cache the starting coordinates so we can use them for reference.
        LDA $0D10, X : STA $0D90, X
        LDA $0D30, X : STA $0DA0, X
        
        LDA $0D00, X : STA $0DB0, X
        LDA $0D20, X : STA $0EB0, X
        
        RTS
    }

; ==============================================================================

    ; *$30FC9-$30FCE JUMP LOCATION
    SpritePrep_WalkingZora:
    {
        LDA.b #$60 : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$30FCF-$30FD5 BRANCH LOCATION
    {
        ASL $0BE0, X : LSR $0BE0, X
        
        RTS
    }

; ==============================================================================

    ; *$30FD6-$3103A JUMP LOCATION
    SpritePrep_Soldier:
    {
        LDA $0E30, X : BEQ BRANCH_ALPHA
        
        LDY.b #$00
        
        AND.b #$07 : CMP.b #$05 : BCS BRANCH_BETA
        
        DEC A : EOR.b #$01 : STA $0DE0, X
    
    BRANCH_ALPHA:
    
        LDA $1B : BNE BRANCH_30FCF
        
        LDA.b #$01 : STA $0D80, X
        
        LDA.b #$70 : STA $0DF0, X
        
        JSR Sprite_DirectionToFacePlayer
        
        TYA : STA $0DE0, X : STA $0EB0, X
    
    ; *$31001 ALTERNATE ENTRY POINT
    shared SpritePrep_TrooperAndArcherSoldier:
    
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        BEQ BRANCH_DELTA
        
        LDY.b #$04
    
    BRANCH_DELTA:
    
        LDA $0E30, X : LSR #3 : AND.b #$03 : STA $00
        
        TYA : ORA $00 : TAY
        
        LDA .unknown, Y : STA $0DA0, X
        
        LDA $0B6B, X : AND.b #$0F : ORA #$50 : STA $0B6B, X
    
    BRANCH_GAMMA:
    
        LDA $11 : PHA
        
        STZ $11
        
        SEC : ROR $0CAA, X
        
        JSR SpriteActive_Main
        JSR SpriteActive_Main
        
        ASL $0CAA, X
        
        PLA : STA $11
        
        RTS
    
    .unknown
        db $00, $02, $01, $03, $06, $04, $05, $07
    }

; ==============================================================================

    ; $3103B-$31042 DATA
    pool SpritePrep_TalkingTree:
    {
    
    ; \unused Not confirmed yet, but strongly suspected.
    .unknown_0
        db 0, 2, 1, 3, 6, 4, 5, 7
    }

; ==============================================================================

    ; *$31043-$31063 JUMP LOCATION
    SpritePrep_TalkingTree:
    {
        INC $0BA0, X
        
        LDA $0D10, X : SUB.b #$08 : STA $0D10, X
        LDA $0D30, X : SBC.b #$00 : STA $0D30, X
        
        LDA.b #$00 : JSL TalkingTree_SpawnEyes
        LDA.b #$01 : JSL TalkingTree_SpawnEyes
        
        RTS
    }

; ==============================================================================

    ; *$31064-$31074 JUMP LOCATION
    SpritePrep_CrystalSwitch:
    {
        LDA $7EC172 : AND.b #$01 : TAY
        
        LDA $B8CE, Y : ORA $0F50, X : STA $0F50, X
        
        RTS
    }

; ==============================================================================

    ; *$31075-$310CB JUMP LOCATION
    SpritePrep_FluteBoy:
    {
        INC $0BA0, X
        
        LDA $7EF3CA : ASL A : ROL #2
        
        AND.b #$01 : STA $0E80, X : BEQ .in_light_world
        
        ; See if the dark world flute boy has been arborated.
        LDA $7EF3C9 : AND.b #$08 : BNE .already_arborated
        
        LDA $7EF34C : CMP.b #$02 : BCC BRANCH_GAMMA
                                   BEQ BRANCH_DELTA
    
    .already_arborated
    
        LDA.b #$03 : STA $0DC0, X ; Put him in his tree form initially
        
        LDA.b #$05 : STA $0D80, X; Set his AI pointer to do nothing?
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        LDA.b #$01 : STA $0DC0, X
    
    BRANCH_GAMMA:
    
        JSR SpritePrep_MoveRightOneTile
        
        LDA $0D00, X : SUB.b #$08 : STA $0D00, X
        
        RTS
    
    .in_light_world
    
        LDA $7EF34C : CMP.b #$02 : BCC BRANCH_EPSILON
        
        STZ $0DD0, X ; Kill the sprite if we already have the flute.
        
        RTS
    
    BRANCH_EPSILON:
    
    ; *$310C2 ALTERNATE ENTRY POINT
    shared SpritePrep_MoveRightSevenPixels:
    
        LDA $0D10, X : ADD.b #$07 : STA $0D10, X
        
        RTS
    }

; ==============================================================================

    ; *$310CC-$310D5 JUMP LOCATION
    SpritePrep_MoveDownOneTile:
    {
        LDA $0D00, X : ADD.b #$08 : STA $0D00, X
    
    ; $310D5 ALTERNATE ENTRY POINT
    shared SpritePrep_Zazakku:
    
        RTS
    }

; ==============================================================================

    ; *$310D6-$310DF JUMP LOCATION
    SpritePrep_HylianPlaque:
    {
        INC $0BA0, X
        
        LDA $8A : CMP.b #$30 : BEQ SpritePrep_MoveRightSevenPixels
        
        RTS
    }

; ==============================================================================

    ; *$310E0-$310EF JUMP LOCATION
    SpritePrep_Stalfos:
    {
        LDA $0D10, X : AND.b #$10 : STA $0E30, X : BEQ .is_red_stalfos
        
        LDA.b #$07 : STA $0F50, X
    
    .is_red_stalfos
    
        RTS
    }

; ==============================================================================

    ; $310F0-$31115 JUMP LOCATION
    SpritePrep_KholdstareShell:
    {
        JSR SpritePrep_Bosses
        
        LDA.b #$C0 : STA $0E00, X
        
        BRA .down_one_right_two_tiles
    
    ; *$310FA ALTERNATE ENTRY POINT
    shared SpritePrep_Kholdstare:
    
        JSR SpritePrep_Bosses
        
        LDA.b #$03 : STA $0D80, X
        
        JSR SpritePrep_IgnoresProjectiles
        
        BRA .down_one_right_two_tiles
    
    ; *$31107 ALTERNATE ENTRY POINT
    shared SpritePrep_Bumper:
    
        JSR SpritePrep_IgnoresProjectiles
    
    ; *$3110A ALTERNATE ENTRY POINT
    shared SpritePrep_MoveDownOneRightTwoTiles:
    
    .down_one_right_two_tiles
    
        PHX : TXA : ADD.b #$10 : TAX
        
        JSR SpritePrep_MoveDownOneTile
        
        PLX
        
        BRA SpritePrep_MoveDownOneTile
    }

; ==============================================================================

    ; $31116-$31121 DATA
    pool SpritePrep_HardHatBeetle:
    {
    
    .palette
        db 6, 8
    
    .hp
        db 32, 6
    
    .unknown_0
        db $10, $0C
    
    .ai_state
        db $01, $03
    
    .unknown_1
        db $02, $06
    
    .bump_damage
        db 5, 3
    }

; ==============================================================================

    ; *$31122-$31150 JUMP LOCATION
    SpritePrep_HardHatBeetle:
    {
        ; Charging octopi prep routine
        
        LDY.b #$00
        
        ; Depending on whether the X coordinate is odd or even (in multiples
        ; of 16 pixels), configure it as a red or a blue hardhat beetle.
        LDA $0D10, X : AND.b #$10 : BEQ BRANCH_ALPHA
        
        INY
    
    BRANCH_ALPHA:
    
        LDA .palette, Y : STA $0F50, X
        
        LDA .hp, Y : STA $0E50, X
        
        LDA .unknown_0, Y : STA $0D90, X
        
        LDA .ai_state, Y : STA $0D80, X
        
        LDA .unknown_1, Y : STA $0BE0, X
        
        LDA .bump_damage, Y : STA $0CD2, X
        
        RTS
    }

; ==============================================================================

    ; *$31151-$3115B JUMP LOCATION
    SpritePrep_Helmasaur:
    {
        ; Effectively is the speed of the sprite.
        LDA.b #$10 : STA $0D90, X
        
        ; 
        LDA.b #$01 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$3115C-$31174 JUMP LOCATION
    SpritePrep_Faerie:
    {
        JSL GetRandomInt : AND.b #$01
        
        STA $0D90, X
        
        EOR.b #$01 : STA $0DE0, X
    
    ; *$3116A ALTERNATE ENTRY POINT
    shared SpritePrep_HeartRefill:
    shared SpritePrep_GreenRupee:
    shared SpritePrep_BlueRupee:
    shared SpritePrep_RedRupee:
    shared SpritePrep_OneBombRefill:
    shared SpritePrep_FourBombRefill:
    shared SpritePrep_EightBombRefill:
    shared SpritePrep_SmallMagicRefill:
    shared SpritePrep_FullMagicRefill:
    shared SpritePrep_FiveArrowRefill:
    shared SpritePrep_TenArrowRefill:
    
        LDA $1B : BNE .indoors
    
    ; *$3116E ALTERNATE ENTRY POINT
    shared SpritePrep_DashTriggeredSprite:
    
        INC $0E90, X
        
        INC $0BA0, X
    
    .indoors
    
    ; $31174 ALTERNATE ENTRY POINT
    shared SpritePrep_ShieldPickup:
    
        RTS
    }

; ==============================================================================

    ; *$31175-$31192 LOCAL
    SpritePrep_GoodBee:
    {
        LDA $7EF35C : ORA $7EF35D : ORA $7EF35E : ORA $7EF35F
        
        AND.b #$08 : BEQ .dont_have_good_bee
        
        STZ $0DD0, X
    
    .dont_have_good_bee
    
        INC $0E90, X
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; $31193-$31194 DATA
    pool SpritePrep_Agahnim:
    {
    
    .palettes
        db $0B, $07
    }

; ==============================================================================

    ; *$31195-$311AE JUMP LOCATION
    SpritePrep_Agahnim:
    {
        JSR SpritePrep_Bosses
        
        LDA.b #$00 : STA $0DC0, X
        
        LDA.b #$03 : STA $0DE0, X
        
        JSR SpritePrep_MoveDownOneRightTwoTiles
        
        LDY $0FFF
        
        LDA $9193, Y : STA $0F50, X
    
    ; $311AE ALTERNATE ENTRY POINT
    shared SpritePrep_DoNothing_2:
    
        RTS
    }

; ==============================================================================

    ; *$311AF-$311B3 JUMP LOCATION
    SpritePrep_EyegoreTrampoline:
    {
        JSL SpritePrep_Eyegore
        
        RTS
    }

; ==============================================================================

    ; *$311B4-$311B9 JUMP LOCATION
    SpritePrep_GuruGuruBar:
    {
        INC $0DA0, X
        
        JMP SpritePrep_IgnoresProjectiles
    }

; ==============================================================================

    ; *$311BA-$311C4 JUMP LOCATION
    SpritePrep_TrinexxComponents:
    {
        JSR SpritePrep_Bosses
        JSL TrinexxComponents_InitializeLong
        JSR SpritePrep_TerminateCachedSprites
        
        RTS
    }

; ==============================================================================

    ; *$311C5-$311D6 JUMP LOCATION
    SpritePrep_HelmasaurKing:
    {
        JSR SpritePrep_Bosses
        JSL HelmasaurKing_Initialize
    
    ; *$311CC ALTERNATE ENTRY POINT
    shared SpritePrep_TerminateCachedSprites:
    
        LDY.b #$0F
        LDA.b #$00
    
    .termination_loop
    
        STA $1D00, Y
        
        DEY : BPL .termination_loop
        
        RTS
    }

; ==============================================================================

    ; *$311D7-$311E7 JUMP LOCATION
    SpritePrep_SpikeBlock:
    {
        LDA.b #$20 : STA $0D50, X
    
    ; *$311DC ALTERNATE ENTRY POINT
    shared SpritePrep_Stal:
    
        LDA.b #-16 : STA $0D40, X
        
        JSR Sprite_MoveVert
        
        STZ $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$311E8-$311F0 JUMP LOCATION
    SpritePrep_Terrorpin:
    {
        LDA.b #$04 : STA $0DC0, X
        
        JSR SpritePrep_IgnoresProjectiles
        
        RTS
    }

; ==============================================================================

    ; *$311F1-$311F9 JUMP LOCATION
    SpritePrep_Arghus:
    {
        JSR SpritePrep_Bosses
        
        LDA.b #$18 : STA $0F70, X
        
        RTS
    }

; ==============================================================================

    ; *$311FA-$3122E JUMP LOCATION
    SpritePrep_Arrgi:
    {
        JSR SpritePrep_Bosses
        
        JSL GetRandomInt : STA $0E80, X
        
        CPX.b #$0D : BNE BRANCH_ALPHA
        
        STZ $0B0A
        STZ $0B0B
        
        PHX
        
        LDX.b #$00
        
        JSL $1EB8B4 ; $F38B4 IN ROM
        
        PLX
    
    BRANCH_ALPHA:
    
        LDA $0B0F, X : STA $0D10, X
        LDA $0B1F, X : STA $0D30, X
        
        LDA $0B2F, X : STA $0D00, X
        LDA $0B3F, X : STA $0D20, X
        
        RTS
    }

; ==============================================================================

    ; *$3122F-$31247 JUMP LOCATION
    SpritePrep_Mothula:
    {
        JSR SpritePrep_Bosses
        
        LDA.b #$50 : STA $0DF0, X
        
        INC $0BA0, X
        
        LDA.b #$02 : STA $0DC0, X
        
        INC $041A
        
        LDA.b #$70 : STA $0DB0, X
        
        RTS
    }

; ==============================================================================

    ; *$31248-$3124C JUMP LOCATION
    SpritePrep_BubbleGroupTrampoline:
    {
        JSL SpritePrep_BubbleGroup
        
        RTS
    }

; ==============================================================================

    ; $3124D-$3124D JUMP LOCATION
    SpritePrep_CrystalMaiden:
    {
        RTS
    }

; ==============================================================================

    ; *$3124E-$31270 JUMP LOCATION
    SpritePrep_BigKey:
    {
        JSR SpritePrep_MoveRightOneTile
        
        LDA.b #$FF : STA $0E30, X

    ; *$31256 ALTERNATE ENTRY POINT
    shared SpritePrep_LoadBigKeyGfx:

        PHX : PHY
        
        LDA.b #$22
        
        JSL GetAnimatedSpriteTile.variable
        
        PLY : PLX
        
        BRA .set_item_drop
    
    ; *$31262 ALTERNATE ENTRY POINT
    shared SpritePrep_Key:
    
        LDA.b #$FF : STA $0E30, X
    
    ; *$31267 ALTERNATE ENTRY POINT
    .set_item_drop
    
        ; \wtf Why is this necessary? Big keys and keys shouldn't drop anything
        ; after they die. Maybe we'll know some day.
        LDA $0B9B : STA $0CBA, X
        
        INC $0B9B
        
        RTS
    }

; ==============================================================================

    ; *$31271-$31282 LOCAL
    SpriteActive_Main:
    {
        LDA $0E20, X
        
        REP #$30
        
        AND.w #$00FF : ASL A : TAY
        
        ; Sets up a stack jump table (Weird isn't it?)
        LDA SpriteActive_Table, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    }

; ==============================================================================
