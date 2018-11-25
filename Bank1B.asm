
    ; $D8000 - $DB1D6 - tail end of the music (spc) data

    
    ; $DB1D7 - $DB29A - possibly a test block of spc data, but seems to be unused
    {
        ; \task Fill in data and find out if that part about spc data seems
        ; credible.
    }
    
    ; $DB29B - $DB7FF - null bytes / empty space
    pool Null:
    {
        ; \task Put in fillbyte / fill directives.
    }

; ==============================================================================

    ; $DB800-$DB85F DATA
    pool Overworld_Hole:
    {
    
    .map16
    
        ; $DB800 - map16 coordinates for holes
        dw $0CE0, $124E, $12CE, $1162, $11E2, $073C, $07BC, $0CE0
        dw $003C, $00BE, $003E, $0388, $0170, $03A4, $0424, $0518
        dw $028A, $020A, $0108
    
    .area
    
        ; $DB826 - area numbers for holes
        dw $0040, $0040, $0040, $0040, $0040, $0040, $0040, $0000
        dw $005B, $005B, $005B, $0015, $001B, $0022, $0022, $0002, $0018, $0018, $0014
    
    .entrance
    
        ; $DB84C - dungeon entrance to go into
        db $76, $77, $77, $78, $78, $79, $79, $7A
        db $7B, $7B, $7B, $7C, $7D, $7E, $7E, $7F
        db $80, $80, $81, $82
    }

; ==============================================================================

    ; *$DB860-$DB8BE LONG
    Overworld_Hole:
    {
        ; routine used to find the entrance to send Link to when he falls into a hole
        
        PHB : PHK : PLB
        
        REP #$31
        
        LDA $20 : AND.w #$FFF8 : STA $00 : SUB $0708 : AND $070A : ASL #3 : STA $06
        
        LDA $22 : AND.w #$FFF8 : LSR #3 : STA $02 : SUB $070C : AND $070E : ADD $06 : STA $00
        
        LDX.w #$0024

    .nextHole

        LDA $00   : CMP .map16, X
        
        BNE .wrongMap16
        
        LDA $040A : CMP .area, X
        
        BEQ .matchedHole

    .wrongMap16

        DEX #2
        
        BPL .nextHole
        
        ; Send us to the Chris Houlihan room        
        LDX.w #$0026
        
        SEP #$20
        
        ; Put Link in the Light World
        LDA.b #$00 : STA $7EF3CA

    .matchedHole

        SEP #$30
        
        TXA : LSR A : TAX
        
        ; Set an entrance index...
        LDA .entrance, X : STA $010E : STZ $010F
        
        PLB
        
        RTL
    }

    ; $DB8BF-$DB916 - chr types indicating door entrances
    dw $00FE, $00C5, $00FE, $0114, $0115, $0175, $0156, $00F5
    dw $00E2, $01EF, $0119, $00FE, $0172, $0177, $013F, $0172
    dw $0112, $0161, $0172, $014C, $0156, $01EF, $00FE, $00FE
    dw $00FE, $010B, $0173, $0143, $0149, $0175, $0103, $0100
    dw $01CC, $015E, $0167, $0128, $0131, $0112, $016D, $0163
    dw $0173, $00FE, $0113, $0177
    
    ; $DB917 - $DB96E
    dw $014A, $00C4, $014F, $0115, $0114, $0174, $0155, $00F5
    dw $00EE, $01EB, $0118, $0146, $0171, $0155, $0137, $0174
    dw $0173, $0121, $0164, $0155, $0157, $0128, $0114, $0123
    dw $0113, $0109, $0118, $0161, $0149, $0171, $0174, $0101
    dw $01CC, $0131, $0051, $014E, $0131, $0121, $017A, $0163
    dw $0172, $01BD, $0152, $0167
    
    ; $DB96F - $DBA70 - Area list for entrances
    dw $002C, $0013, $001B, $001B, $001B, $000A, $0003, $001E
    
    ; $DBA71 - $DBB72 - Map16 list for entrances
    
    ; $DBB73 - $DBBF3 - references to the dungeon entrance to go into for each entry
    db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10
    db $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20
    db $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30
    db $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40
    db $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50
    db $51, $52, $53, $54, $55, $5E, $60, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60
    db $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $56, $5E, $5E, $58, $60, $5E
    db $4D, $5E, $65, $60, $57, $6B, $71, $71, $6D, $6E, $6F, $70, $6C, $72, $83, $84
    db $5E

    ; *$DBBF4-$DBD79 LONG
    Overworld_Entrance:
    {
        REP #$31
        
        LDA $20 : ADD.w #$0007 : STA $00 : SUB $0708 : AND $070A : ASL #3 : STA $06
        
        LDA $22 : LSR #3 : STA $02 : SUB $070C : AND $070E : ADD $06 : TAY : TAX
        
        LDA $7E2000, X : ASL #3 : TAX
        
        ; If player is facing a different direction than up, branch
        LDA $2F : AND.w #$00FF : BNE .notFacingUp
        
        LDA $0F8002, X : AND.w #$41FF : CMP.w #$00E9 : BEQ BRANCH_BETA
                                        CMP.w #$0149 : BEQ BRANCH_GAMMA
                                        CMP.w #$0169 : BEQ BRANCH_GAMMA
        
        TYX
        
        LDA $7E2002, X : ASL #3 : TAX
        
        LDA $0F8000, X : AND.w #$41FF : CMP.w #$4149 : BEQ BRANCH_DELTA
                                        CMP.w #$4169 : BEQ BRANCH_DELTA
                                        CMP.w #$40E9 : BNE BRANCH_EPSILON
        
        DEY #2
    
    BRANCH_BETA:
    
        ; This section opens a normal door on the overworld
        ; It replaces the existing tiles with an open door set of tiles
        
        TYX
        
        LDA.w #$0DA4
        
        JSL Overworld_DrawPersistentMap16
        
        LDA.w #$0DA6 : STA $7E2002, X
        
        LDY.w #$0002
        
        JSL Overworld_DrawMap16_Anywhere
        
        SEP #$30
        
        ; Play a sound effect
        LDA.b #$15 : STA $012F
        
        ; Make sure to update the tilemap
        LDA.b #$01 : STA $14
        
        RTL
    
    .notFacingUp
    
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        DEY #2
    
    BRANCH_GAMMA:
    
        STZ $0692
        
        AND.w #$03FF : CMP.w #$0169 : BNE BRANCH_IOTA
        
        ; Check if we've beaten agahnim, and if so, don't open the door.
        LDA $7EF3C5 : AND.w #$000F : CMP.w #$0003 : BCS BRANCH_EPSILON
        
        LDA.w #$0018 : STA $0692
    
    BRANCH_IOTA:
    
        TYA : SUB.w #$0080 : STA $0698
        
        SEP #$20
        
        LDA.b #$15 : STA $012F
        
        STZ $B0 : STZ $0690
        
        LDA.b #$0C : STA $11
        
        SEP #$30
        
        RTL
    
    BRANCH_EPSILON:
    
        LDA $0F8004, X : AND.w #$01FF : STA $00
        LDA $0F8006, X : AND.w #$01FF : STA $02
        
        LDX.w #$0056
    
    BRANCH_THETA:
    
        LDA $00 : CMP $1BB8BF, X : BNE BRANCH_ZETA
        
        LDA $02 : CMP $1BB917, X : BEQ BRANCH_KAPPA
    
    BRANCH_ZETA:
    
        DEX #2 : BPL BRANCH_THETA
        
        STZ $04B8
    
    BRANCH_MU:
    
        SEP #$30
        
        RTL
    
    BRANCH_LAMBDA:
    
        LDA $04B8 : BNE BRANCH_MU
        
        INC $04B8
        
        ; "You can't enter with something following you" (this variable holds the message index.)
        LDA.w #$0005 : STA $1CF0
        
        SEP #$30
        
        JML Main_ShowTextMessage
    
    BRANCH_KAPPA:
    
        TYA : STA $00
        
        ; Number of entrance entries * 2
        LDX.w #$0102
    
    BRANCH_PI:
    
        LDA $00
    
    BRANCH_OMICRON:
    
        DEX #2 : BMI BRANCH_XI
        
        CMP $1BBA71, X : BNE BRANCH_OMICRON
        
        LDA $040A : CMP $1BB96F, X : BNE BRANCH_PI
        
        LDA $7EF3D3 : AND.w #$00FF : BNE BRANCH_RHO
        
        LDA $02DA : AND.w #$00FF : CMP.w #$0001 : BEQ BRANCH_LAMBDA
        
        LDA $7EF3CC : AND.w #$00FF : BEQ BRANCH_RHO
        
        CMP.w #$0005 : BEQ BRANCH_RHO
        CMP.w #$000E : BEQ BRANCH_RHO
        CMP.w #$0001 : BEQ BRANCH_RHO
        CMP.w #$0007 : BEQ BRANCH_SIGMA
        CMP.w #$0008 : BNE BRANCH_LAMBDA
        
        CPX.w #$0076 : BCC BRANCH_LAMBDA
        
        TXA : LSR A : TAX
        
        SEP #$30
        
        LDA $1BBB73, X : STA $010E
        
        STZ $4D
        STZ $46
        
        LDA.b #$0F : STA $10
        
        LDA.b #$06 : STA $010C
        
        STZ $11
        STZ $B0
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$DBD7A-$DBF1D LONG
    Overworld_Map16_ToolInteraction:
    {
        ; Handles Map16 interactions with sword, hammer, shovel, magic powder, etc
        
        LDA $1B : BEQ .outdoors ; Yes... branch
        
        JML Dungeon_ToolAndTileInteraction
    
    .outdoors
    
        REP #$30
        
        ; Zero out ??? affected when dashing apparently, Zero out tile interaction
        STZ $04B2 : STZ $76
        
        LDA $00 : SUB $0708 : AND $070A : ASL #3 : STA $06
        
        LDA $02 : SUB $070C : AND $070E : ADD $06 : TAX
        
        ; Is Link using the hammer?
        LDA $0301 : AND.w #$0002 : BNE .usingHammer
        
        ; Is Link using anything else?
        ; No, branch
        LDA $0301 : AND.w #$0040 : BEQ .notUsingMagicPowder
        
        ; We end up here if Link sprinkled magic powder on something.
        LDA $7E2000, X : PHA
        
        LDY.w #$0002
        
        ; Is it a bush?
        CMP.w #$0036 : BEQ .isBush
        
        LDY.w #$0004
        
        ; Is it a dark world bush?
        CMP.w #$072A : BNE .notBush
    
    .isBush
    
        JMP .isBush2
    
    ; HAMMER TIME!
    .usingHammer
    
        ; Is it a peg to be pounded down?
        LDA $7E2000, X : PHA : CMP.w #$021B : BNE .notPeg
        
        SEP #$20
        
        ; Play the peg gettin' knocked down sound.
        LDA.b #$11 : STA $012E
        
        REP #$20
        
        JSL HandlePegPuzzles    ; $75D67 IN ROM
        
        ; Choose the map16 tile with the "peg pounded down" tile
        LDA.w #$0DCB
    
        JMP .noSecret
    
    .notPeg
    
        JSR Overworld_HammerSfx
    
    .notBush
    
        JMP .return
    
    .notUsingMagicPowder
    
        ; Normal tile interactions
        LDA $7E2000, X : PHA
        
        CMP.w #$0034 : BEQ .shovelable   ; normal blank green ground
        CMP.w #$0071 : BEQ .shovelable   ; non thick grass
        CMP.w #$0035 : BEQ .shovelable   ; non thick grass
        CMP.w #$010D : BEQ .shovelable   ; non thick grass
        CMP.w #$010F : BEQ .shovelable   ; non thick grass
        CMP.w #$00E1 : BEQ .shovelable   ; animated flower tile
        CMP.w #$00E2 : BEQ .shovelable   ; animated flower tile
        CMP.w #$00DA : BEQ .shovelable   ; non thick grass
        CMP.w #$00F8 : BEQ .shovelable   ; non thick grass
        CMP.w #$010E : BEQ .shovelable   ; non thick grass
        CMP.w #$037E : BEQ .isThickGrass ; thick grass
        
        LDY.w #$0002
        
        ; normal bush
        CMP.w #$0036 : BEQ .isBush2
        
        LDY.w #$0004
        
        ; off color bush
        CMP.w #$072A : BEQ .isBush2
    
    .notShoveling
    
        JMP .return
    
    .shovelable
    
        ; Is Link shoveling?
        LDA $037A : AND.w #$00FF : CMP.w #$0001 : BNE .notShoveling
        
        ; Is this the forest grove?
        LDA $8A : CMP.w #$002A : BNE .notFluteLocation
        
        ; Is it that one special spot the flute is at?
        CPX.w #$0492 : BNE .notFluteLocation
        
        STX $04B2
    
    .notFluteLocation
    
        ; replacement tile after you shovel out the ground
        LDY.w #$0DC9
        
        BRA .checkForSecret
    
    .isThickGrass
    
        LDA $037A : AND.w #$00FF : CMP.w #$0001 : BNE .notShoveling2
        
        JMP .return
    
    .notShoveling2
    
        LDA $02 : ASL #3        : SUB.w #$0008 : PHA
        LDA $00 : SUB.w #$0008 : AND.w #$FFF8  : STA $74
        
        ; why was it pushed in the first place? -____-
        PLA : STA $72
        
        LDA.w #$0003 : STA $76
        
        LDY.w #$0DC5
        
        BRA .checkForSecret
    
    ; *$DBE8D ALTERNATE ENTRY POINT
    .isBush2
    
        LDA $037A : AND.w #$00FF : CMP.w #$0001 : BEQ .shoveling
        
        LDA $02 : AND.w #$FFFE : ASL #3 : PHA
        
        LDA $00 : AND.w #$FFF0 : STA $74
        
        ; again... why?
        PLA : STA $72
        
        STY $76
        
        PLA : PHA
        
        LDY.w #$0DC7
        
        CMP.w #$072A : BNE .notOffColorBush
        
        ; use a different replacement map16 tile for the off color bushes
        LDY.w #$0DC8
    
    .notOffColorBush
    .checkForSecret
    
        STY $0E
        
        ; check for secrets under the bush?
        JSR Overworld_RevealSecret : BCS .noSecret
        
        ; if there's a secret under the bush, like a hole or a cave
        ; it would require a different replacement map16 tile
        LDA $0E
    
    .noSecret
    
        STA $7E2000, X
        
        JSL Overworld_Memorize_Map16_Change
        JSL Overworld_DrawMap16
        
        SEP #$20
        
        ; Tell NMI to update the tilemap
        LDA.b #$01 : STA $14
        
        REP #$20
        
        PLA
        
        BRA .setTileFlags
    
    .shoveling
    
        PLA
    
        LDA $7E2000, X
    
    .setTileFlags
    
        ASL #2 : STA $06
        
        LDA $00 : AND.w #$0008 : LSR #2 : TSB $06
        
        LDA $02 : AND.w #$0001 : ORA $06 : ASL A : TAX
        
        LDA $0F8000, X : AND.w #$01FF : TAX
        
        LDA Overworld_TileAttr, X : PHA
        
        LDA $72 : STA $00
        LDA $74 : STA $02
        
        SEP #$30
        
        LDA $76 : BEQ .noAncilla
        
        JSL Sprite_SpawnImmediatelySmashedTerrain
        JSL AddDisintegratingBushPoof
    
    .noAncilla
    
        REP #$30
        
        PLA
    
    .return
    
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DBF1E-$DBF4B LOCAL
    Overworld_HammerSfx:
    {
        ASL #3 : TAX
        
        LDA $0F8000, X : AND.w #$01FF : TAX
        
        LDA Overworld_TileAttr, X
        
        SEP #$30
        
        CMP.b #$50
        
        BCC .noSoundEffect
        
        ; we're hitting a bush, so play the swish sound
        LDY.b #$1A
        CMP.b #$52
        
        BCC .playSoundEffect
        
        ; we're hitting a sign post, so play the "hitting a peg" sound
        LDY.b #$11
        CMP.b #$54
        
        BEQ .playSoundEffect
        
        ; we're hitting a small rock, so play the "tink" from hitting a rock
        LDY.b #$05
        CMP.b #$58
        
        BCC .noSoundEffect
    
    .playSoundEffect
    
        STY $012E
    
    .noSoundEffect
    
        REP #$30
        
        RTS
    }
    
; ==============================================================================

    ; $DBF4C-$DBF63 DATA
    {
        dw    0,   -2, -128, -130
    
    ; $DBF54
        dw    0,   0,  -128, -128
    
    ; $DBF5C
        dw    0,   -2,    0,   -2
    }

; ==============================================================================

    ; *$DBF64-$DBF9C LOCAL
    Overworld_GetLinkMap16Coords:
    {
        LDA $2F : AND.w #$00FF : TAX

        LDA $20    : ADD $07D365, X : AND.w #$FFF0  : STA $00
        SUB $0708 : AND $070A       : ASL #3        : STA $06

        LDA $22 : ADD $07D36D, X : AND.w #$FFF0 : STA $02
        LSR #3  : SUB $070C      : AND $070E    : ADD $06 : TAX
        
        RTS
    }

; ==================================================

    ; *$DBF9D-$DC054 LONG
    Overworld_LiftableTiles:
    {
        ; Handles Map16 tiles that are liftable.
        
        REP #$30
        
        JSR Overworld_GetLinkMap16Coords
        
        LDA $00 : PHA
        LDA $02 : PHA
        
        LDA $7E2000, X
        
        LDY.w #$0000
        CMP.w #$036D ; Is it a big light colored rock?
        
        BEQ .liftingLargeRock
        
        INY
        CMP.w #$036E ; Also a big light colored rock...
        
        BEQ .liftingLargeRock
        
        INY
        CMP.w #$0374 ; ditto
        
        BEQ .liftingLargeRock
        
        INY
        CMP.w #$0375 ; ditto
        
        BEQ .liftingLargeRock
        
        LDY.w #$0000
        CMP.w #$023B ; dark colored big rock?
        
        BEQ .liftingLargeRock
        
        INY
        CMP.w #$023C ; same
        
        BEQ .liftingLargeRock
        
        INY
        CMP.w #$023D ; same
        
        BEQ .liftingLargeRock
        
        CMP.w #$023E ; same
        
        BNE .notLiftingRock
        
        INY
    
    .liftingLargeRock
    
        JMP Overworld_SmashRockPile_isRockPile
    
    .notLiftingRock
    
        LDY.w #$0DC7
        CMP.w #$0036 ; Is it a green bush?
        
        BEQ .liftingSmallObject
        
        LDY.w #$0DC8
        CMP.w #$072A ; Is it a brown bush?
        
        BEQ .liftingSmallObject
        
        LDY.w #$0DCA
        CMP.w #$020F ; Is it a small light colored rock?
        
        BEQ .liftingSmallObject
        
        CMP.w #$0239 ; How about a small dark colored rock?
        
        BEQ .liftingSmallObject
        
        CMP.w #$0101 ; Is it one of those sign posts?
        
        BNE .notLiftingSmallObject
        
        LDY.w #$0DC6
    
    .liftingSmallObject
    
        STY $0E
        
        PHA
        
        JSR Overworld_RevealSecret
        
        BCS .noSecret
        
        LDA $0E
    
    .noSecret
    
        STA $7E2000, X
        
        JSL Overworld_Memorize_Map16_Change
        JSL Overworld_DrawMap16
        
        SEP #$20
        
        LDA.b #$01 : STA $14
    
    .getTileAttribute
    
        REP #$30
        
        PLA
    
    .notLiftingSmallObject
    
        ASL #2 : STA $06
        
        LDA $02 : AND.w #$0008 : LSR #2 : TSB $06
        
        LDA $00 : LSR #3 : AND.w #$0001 : ORA $06 : ASL A : TAX
        
        LDA $0F8000, X : AND.w #$01FF : TAX
        
        PLA : STA $00
        PLA : STA $02
        
        LDA Overworld_TileAttr, X
        
        SEP #$31
        
        RTL
    }

; ==================================================

    ; *$DC055-$DC062 BRANCH LOCATION
    Overworld_SmashRockPile:
    {
    
    .checkForBush
    
        LDY.w #$0DC7
        CMP.w #$0036    ; check if the map16 tile is a bush

        BEQ Overworld_LiftableTile_liftingSmallObject

        PLA : PLA

        SEP #$30

        CLC

        RTL
    
    ; *$DC063-$DC075 LONG
    .downOneTile
    
        REP #$30
        
        LDA $20 : PHA
        
        ADD.w #$0008 : STA $20
        
        JSR Overworld_GetLinkMap16Coords
        
        PLA : STA $20
        
        .presetCoords
    
    ; *$DC076-$DC0F7 LONG
    .normalCoords
    
        REP #$30
        
        JSR Overworld_GetLinkMap16Coords
    
    .presetCoords
    
        LDA $00 : PHA
        LDA $02 : PHA
        
        LDA $7E2000, X : LDY.w #$0000
        
        CMP.w #$0226    ; check if it's a rock pile
        
        BEQ .isRockPile
        
        INY
        
        CMP.w #$0227    ; same
        
        BEQ .isRockPile
        
        INY
        
        CMP.w #$0228    ; same
        
        BEQ .isRockPile
        
        CMP.w #$0229    ; same
        
        BNE .checkForBush
        
        INY

    .isRockPile

        STY $0C
        
        ; why store to $0C then TSB it again...?
        PHA : TSB $0C
        
        TXA : CLC
        
        LDX $0C : ADC $1BBF4C, X : STA $0698 : TAX
        
        LDA.w #$0028 : STA $0692
        
        STZ $0E
        
        JSR Overworld_RevealSecret
        
        LDA $0E : CMP.w #$FFFF
        
        BNE .noBurrowUnderneath
        
        SEP #$20
        
        ; Remember that the burrow has been uncovered.
        LDY $8A : LDA $7EF280, X : ORA.b #$20 : STA $7EF280, X
        
        ; Play puzzle solved sound
        LDA.b #$1B : STA $012F
        
        REP #$20
        
        LDA.b #$0050 : STA $0692
    
    .noBurrowUnderneath
    
        LDX $0C
        
        LDA $00 : ADD $1BBF54, X : STA $00
        LDA $02 : ADD $1BBF5C, X : STA $02
        
        JSL Overworld_DoMapUpdate32x32_Long
        JMP Overworld_LiftableTile_getTileAttribute
    }

; ==================================================

    ; *$DC0F8-$DC154 LONG
    Overworld_ApplyBombToTiles:
    {
    	REP #$30
        
    	STZ $0E
    	STZ $08
        
    	LDA.w #$0003 : STA $C8
        
    	LDA $00 : SUB.w #$0014 : AND.w #$FFF8 : STA $0488
    	LDA $02 : SUB.w #$0017 : AND.w #$FFF8 : STA $0486
    
    .downOneRow
    
    	LDA $0488 : SUB $0708 : AND $070A : ASL #3 : STA $CA
        
    	LDA $0486
        
    	JSR Overworld_ApplyBombToTile
        
    	LDA $0486 : ADD.w #$0010
        
    	JSR Overworld_ApplyBombToTile
        
    	LDA $0486 : ADD.w #$0020
        
    	JSR Overworld_ApplyBombToTile
        
    	LDA $0488 : ADD.w #$0010 : STA $0488
        
    	DEC $C8
        
    	BNE .downOneRow
        
    	SEP #$30
        
    	RTL
    }

; ==================================================

    ; *$DC155-$DC21C LOCAL
    Overworld_ApplyBombToTile:
    {
        PHA
        
        LSR #3 : SUB $070C : AND $070E : ADD $CA : TAX : STX $04
        
        ; Check to see if Link has a super bomb.
        LDA $7EF3CC : AND.w #$00FF : CMP.w #$000D
        
    	BEQ .checkForBomableCave
        
    	LDA $7E2000, X
        
        LDY.w #$0DC7
    	LDX.w #$0002
        
    	CMP.w #$0036    ; normal bush
        
        BEQ .grassOrBush
        
    	LDX.w #$0004
    	LDY.w #$0DC8
        
    	CMP.w #$072A    ; off color bush
        
    	BEQ .grassOrBush
        
    	CMP.w #$037E    ; thick grass
        
        BNE .checkForBombableCave
        
        LDY.w #$0DC5
        LDX.w #$0003
    
    .grassOrBush
    
        STX $0A
        STY $0E
        
        LDX $04
        
        JSR Overworld_RevealSecret
        
        BCS .noSecret
        
        LDA $0E
    
    .noSecret
    
        STA $7E2000, X
        
        JSL Overworld_Memorize_Map16_Change
        
        LDY.w #$0000
        
        JSL Overworld_DrawMap16_Anywhere
        
        PLA       : AND.w #$FFF8 : STA $00
        LDA $0488 : AND.w #$FFF8 : STA $02
        
        LDA $08 : PHA
        
        SEP #$30
        
        LDA $0A
        
        JSL Sprite_SpawnImmediatelySmashedTerrain
        
        LDA.b #$01 : STA $14
        
        REP #$30
        
        PLA : STA $08
        
        RTS
    
    .checkForBomableCave
    
        LDX $04
        
        JSR Overworld_RevealSecret
        
        LDA $0E : CMP.w #$0DB4 : BEQ .bombableCave
        
        PLA
        
        RTS
    
    .bombableCave
    
        STA $7E2000, X
        
        JSL Overworld_Memorize_Map16_Change
        
        LDY.w #$0000
        
        JSL Overworld_DrawMap16_Anywhere
        
        LDA.w #$0DB5 : STA $7E2002, X
        
        JSL Overworld_Memorize_Map16_Change
        
        LDY.w #$0002
        
        JSL Overworld_DrawMap16_Anywhere
        
        STZ $0E
        
        SEP #$20
        
        LDA.b #$01 : STA $14
        
        ; A cave has been bombed open. Remember it.
        LDX $8A : LDA $7EF280, X : ORA.b #$02 : STA $7EF280, X
        
        REP #$30
        
        PLA
        
        RTS
    }

; ==================================================

    ; *$DC21D-$DC263 LONG
    Overworld_AlterWeathervane:
    {
        ; Called when the weather vane is about exploded.
        ; Draws fresh tiles over the weathercock and displays the N (north) 
        ; symbol by blitting them to VRAM, and setting $14 to 1, so it will register.
        ; But note that in order for this to work you have to use the array
        ; starting at $1000 in WRAM, which this routine does.
        
        REP #$30
        
        ; the replacement map16 tile to use?
        LDA.w #$0068 : STA $0692
        
        ; The index in the tile map to start from.
        LDA.w #$0C3E : STA $0698
        
        JSL Overworld_DoMapUpdate32x32_Long
        
        REP #$30
        
        LDX.w #$0C42
        
        LDA.w #$0E21 : STA $7E2000, X
        
        LDY.w #$0000
        
        JSL Overworld_DrawMap16_Anywhere
        
        LDX.w #$0CC0
        
        LDA.w #$0E25 : STA $7E2002, X
        
        LDY.w #$0002
        
        JSL Overworld_DrawMap16_Anywhere
        
        SEP #$30
        
        ; Indicate that the weather vane has already been smashed open.
        LDA $7EF298 : ORA.b #$20 : STA $7EF298
        
        ; Update the screen.
        LDA.b #$01 : STA $14
        
        RTL
    }

; ==============================================================================

    ; *$DC264-$DC2A6 LONG
    Overworld_AlterGargoyleEntrance:
    {
        ; Seems to me that this routine does the tile modification for the
        ; entrance to Gargoyle's Domain
        
        REP #$30
        
        LDX.w #$0D3E
        LDA.w #$0E1B
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0D40
        LDA.w #$0E1C
        
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDX.w #$0DBE
        
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDX.w #$0E3E
        
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, Y
        
        SEP #$30
        
        LDA $7EF2D8 : ORA.b #$20 : STA $7EF2D8
        
        LDA.b #$1B : STA $012F
        
        LDA.b #$01 : STA $14
        
        RTL
    }

; ==============================================================================

    ; *$DC2A7-$DC2F8 LONG
    Overworld_CreatePyramidHole:
    {
        ; Does tile modification for... the pyramid of power hole
        ; after Ganon slams into it in bat form?
        
        REP #$30
        
        LDX.w #$03BC
        LDA.w #$0E3F
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$03BE
        LDA.w #$0E40
        
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDX.w #$043C
        
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDX.w #$04BC
        
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, Y
        
        LDA.w #$3515 : STA $012D
        
        SEP #$30
        
        LDA $7EF2DB : ORA.b #$20 : STA $7EF2DB
        
        LDA.b #$03 : STA $012F
        
        LDA.b #$01 : STA $14
        
        RTL
    }

; ==================================================

    ; $DC2F9 - $DC3F8 - overworld secrets pointer table
    
    ; $DC3F9 - overworld secrets data

; ==================================================

    ; *$DC8A4-$DC942 LOCAL
    Overworld_RevealSecret:
    {
        ; Routine is used for checking if there's secrets underneath a newly exposed map16 tile
        
        STX $04
        
        LDA $0B9C : AND.w #$FF00 : STA $0B9C
        
        LDA $8A : CMP.w #$0080
        
        ; special areas don't have secrets
        BCS .failure
        
        ASL A : TAX
        
        ; Get pointer to secrets data for this area.
        LDA $1BC2F9, X : STA $00
        
        ; Set source bank for data
        LDA.w #$001B : STA $02
        
        LDY.w #$FFFD
    
    .nextSecret
    
        INY #3
        
        LDA [$00], Y : CMP.w #$FFFF : BEQ .failure
        
        AND.w #$7FFF : CMP $04 : BNE .nextSecret
        
        INY #2
        
        LDA [$00], Y : AND.w #$00FF : BEQ .emptySecret
        
        CMP.w #$0080 : BCS .extendedSecret
        
        TSB $0B9C
    
    .emptySecret
    .extendedSecret
    
        AND.w #$00FF : CMP.w #$0080
        
        BCC .normalSecret
        
        PHA
        
        LDA $0B9C : ORA.w #$00FF : STA $0B9C
        
        PLA : CMP.w #$0084 : BEQ .notBurrow
        
        LDX $8A
        
        LDA $7EF280, X : AND.w #$0002 : BNE .overlayAlreadyActivated
        
        LDA $8A : CMP.w #$005B : BNE .notAtPyramidOfPower
        
        LDA $7EF3CC : AND.w #$00FF : CMP.w #$000D : BNE .failure
    
    .notAtPyramidOfPower
    
        SEP #$20
        
        LDA.b #$1B : STA $012F
        
        REP #$20
    
    .notBurrow
    .overlayAlreadyActivated
    
        LDA [$00], Y : AND.w #$000F : TAX
        
        LDA $1BC89C, X : STA $0E
    
    .failure
    
        JSR $C943   ; $DC943 IN ROM
        
        LDX $04
        
        CLC
        
        RTS
    
    .normalSecret
    
        JSR $C943   ; $DC943 IN ROM
        
        LDX $04
        
        LDA $0E
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; *$DC943-$DC951 LOCAL
    {
        LDA $0301 : AND.w #$0040 : BEQ .notUsingMagicPowder
        
        LDA.w #$0004 : STA $0B9C
    
    .notUsingMagicPowder
    
        RTS
    }

; ==============================================================================

    ; *$DC952-$DC97B LONG
    Overworld_DrawWoodenDoor:
    {
        BCS .draw_closed_door
        
        ; The only other option is to, you guessed it your cleverness, an open
        ; door.
        LDA.w #$0DA4
        
        JSL Overworld_DrawPersistentMap16
        
        LDA.w #$0DA6
        
        BRA .draw_right_half
    
    .draw_closed_door
    
        LDA.w #$0DA5
        
        JSL Overworld_DrawPersistentMap16
        
        LDA.w #$0DA7
    
    .draw_right_half
    
        STA $7E2002, X
        
        LDY.w #$0002
        
        JSL Overworld_DrawMap16_Anywhere
        
        SEP #$3
        
        LDA.b #$01 : STA $14
        
        RTL
    }

; ==============================================================================

    ; *$DC97C-$DC9DD LONG
    Overworld_DrawPersistentMap16:
    {
        STA $7E2000, X
    
    ; *$DC980 ALTERNATE ENTRY POINT
    shared Overworld_DrawMap16:
    
        LDY.w #$0000
    
    ; *$DC983 ALTERNATE ENTRY POINT
    shared Overworld_DrawMap16_Anywhere
    
        PHX
        
        ; Store the index into the tiles to use in $0C
        ASL #3 : STA $0C
        
        STY $00
        
        TXA : ADD $00 : STA $00
        
        JSR $CA69 ; $DCA69 IN ROM
        
        LDY $1000
        
        ; write the base vram (tilemap) address of the first two tiles
        LDA $02 : XBA : STA $1002, Y
        
        ; write the base vram address of the second two tiles
        LDA $02 : ADD.w #$0020 : XBA : STA $100A, Y
        
        ; probably indicates the number of tiles and some other information
        LDA.w #$0300 : STA $1004, Y : STA $100C, Y
        
        LDX $0C
        
        LDA $0F8000, X : STA $1006, Y
        LDA $0F8002, X : STA $1008, Y
        LDA $0F8004, X : STA $100E, Y
        LDA $0F8006, X : STA $1010, Y
        
        LDA.w #$FFFF : STA $1012, Y
        
        TYA : ADD.w #$0010 : STA $1000
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$DC9DE-$DCA68 LOCAL
    {
        ; Has to do with solidity of the tiles being written.
        PHA : STA $7E2000, X
        
        PHX
        
        ; Multiply by 8. Will be an index into a set of tiles
        ASL #3 : STA $0C
        
        TXA : ADD.w #$0000 : STA $00
        
        STZ $02
        
        AND.w #$003F : CMP.w #$0020
        
        BCC BRANCH_ALPHA    ; $If A < #$20, then...
        
        LDA.w #$0400 : STA $02
    
    BRANCH_ALPHA:
    
        LDA $00 : AND.w #$0FFF : CMP.w #$0800
        
        BCC BRANCH_BETA     ; If A < #$800 then...
        
        LDA $02 : ADC.w #$07FF : STA $02
    
    BRANCH_BETA:
    
        LDA $00 : AND.w #$001F : ADC $02 : STA $02
        
        LDA $00 : AND.w #$0780 : LSR A : ADC $02 : STA $02
        
        LDY $1000
        
        XBA
        
        STA $1002, Y
        
        LDA $02 : ADD.w #$0020 : XBA : STA $100A, Y
        
        LDA.w #$0300 : STA $1004, Y : STA $100C, Y
        
        LDX $0C
        
        ; Load tile indices from ROM.
        LDA $0F8000, X : STA $1006, Y   ; Writes to the top left corner of the block
        LDA $0F8002, X : STA $1008, Y   ; Writes the top right 8x8 tile of the block
        LDA $0F8004, X : STA $100E, Y   ; The bottom left corner.
        LDA $0F8006, X : STA $1010, Y   ; The bottom right corner
        
        TYA : ADD.w #$0010 : STA $1000
        
        PLX
        
        INX #2
        
        PLA : INC A
        
        RTS
    }

; ==============================================================================

    ; *$DCA69-$DCA9E LOCAL
    {
        ; I guess this calculates some sort of vram type address for an
        ; outdoor tile?
        
        STZ $02
        
        LDA $00 : AND.w #$003F : CMP.w #$0020 : BCC BRANCH_ALPHA
        
        LDA.w #$0400 : STA $02
    
    BRANCH_ALPHA:
    
        LDA $00 : AND.w #$0FFF : CMP.w #$0800 : BCC BRANCH_BETA
        
        LDA $02 : ADC.w #$07FF : STA $02
    
    BRANCH_BETA:
    
        LDA $00 : AND.w #$001F : ADC $02 : STA $02
        
        LDA $00 : AND.w #$0780 : LSR A : ADC $02 : STA $02
        
        RTS
    }

; ==============================================================================

    ; $DCA9F-$DCAB9 LONG
    Overworld_DrawWarpTile:
    {
        REP #$30 
        
        LDA.w #$0212
        LDY.w #$0720
        
        STA $7E2000, X
        
        JSL Overworld_Memorize_Map16_Change
        JSL Overworld_DrawMap16
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        RTL
    }

; ==============================================================================

    ; $DCABA-$DCAC3 JUMP TABLE
    pool Overworld_EntranceSequence:
    {
    
    .handlers
        dw DarkPalaceEntrance_Main
        dw $CBA6 ; = $DCBA6 ; Skull Woods Entrance Animation
        dw MiseryMireEntrance_Main
        dw TurtleRockEntrance_Main
        dw $CFD9 ; = $DCFD9 ; Ganon's Tower Entrance Animation
    }

; ==============================================================================

    ; $DCAC4-$DCAD3 LONG
    Overworld_EntranceSequence:
    {
        ; The input to the function is which animation is currently ongoing ($04C6 I think)
        
        STA $02E4 ; Link can't move.
        STA $0FC1 ; not sure...
        STA $0710 ; There is a special graphical effect about to happen
        
        DEC A : ASL A : TAX
        
        JSR (.handlers, X)
        
        RTL
    }

; ==============================================================================

    ; $DCAD4-$DCADD JUMP TABLE
    pool DarkPalaceEntrance_Main:
    {
    
    .handlers
        dW $CAE5
        dW $CB2B
        dW $CB47
        dW $CB6C
        dW $CB91
    }

; ==============================================================================

    ; $DCADE-$DCAE4 JUMP LOCATION
    DarkPalaceEntrance_Main:
    {
        LDA $B0 : ASL A : TAX
        
        JMP (.handlers, X)
    }

; ==============================================================================

    ; $DCAE5-$DCB2A JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$40 : BNE .alpha
        
        JSR $D00E ; $DD00E IN ROM
        
        LDA $7EF2DE : ORA.b #$20 : STA $7EF2DE
        
        REP #$30
        
        LDX.w #$01E6
        LDA.w #$0E31
        
        JSL Overworld_DrawPersistentMap16
    
    ; $DCB18 ALTERNATE ENTRY POINT
    
        LDX.w #$02EA
    
    ; $DCB1B ALTERNATE ENTRY POINT
    
        LDA.w #$0E30
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$026A
        LDA.w #$0E26
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$02EA
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, X
        
        SEP #$30
        
        LDA.b #$01 : STA $14
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $DCB2B-$DCB46 JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$20 : BNE BRANCH_DCB2A
        
        JSR $D00E ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$026A
        LDA.w #$0E28
        
        JSL Overworld_DrawPersistentMap16
        
        LDA.w #$0E29
        
        BRA BRANCH_DCB18
    }

; ==============================================================================

    ; $DCB47-$DCB6B JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$20 : BNE BRANCH_DCB2A
        
        JSR $D00E ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$026A
        LDA.w #$0E2A
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$02EA
        LDA.w #$0E2B
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$036A
        
        BRA BRANCH_DCB1B
    }

; ==============================================================================

    ; $DCB6C-$DCB90 JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$20 : BNE BRANCH_DCB2B
        
        JSR $D00E ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$026A
        LDA.w #$0E2D
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$02EA
        LDA.w #$0E2E
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$036A
        
        BRA BRANCH_DCB1B
    }

; ==============================================================================

    ; $DCB91-$DCB9B JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$20 : BNE BRANCH_DCB2A
        
        JMP $CF40 ; $DCF40 IN ROM
    }

; ==============================================================================

    ; $DCB9C-$DCBA5 JUMP TABLE
    {
        dw $CBAD
        dw $CBEE
        dw $CC27
        dw $CC4D
        dw $CC8C
    }

; ==============================================================================

    ; $DCBA6-$DCBAC JUMP LOCATION
    {
        LDA $B0 : ASL A : TAX
        
        JMP ($CB9C, X) ; $DCB9C IN ROM
    }

; ==============================================================================

    ; $DCBAD-$DCBED JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$04 : BNE .delay
        
        INC $B0
        
        STZ $C8
        
        REP #$30
        
        LDX.w #$0812
        LDA.w #$0E06
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0814
        LDA.w #$0E06
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012
        
        SEP #$30
        
        LDX $8A
        
        LDA $7EF280, X : ORA.b #$20 : STA $7EF280, X
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        LDA.b #$16 : STA $012F
    
    ; $DCBED ALTERNATE ENTRY POINT
    .delay
    
        RTS
    }

; ==============================================================================

    ; $DCBEE-$DCC26 JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$0C : BNE BRANCH_DCBED
        
        INC $B0
        
        STZ $C8
        
        REP #$30
        
        LDX.w #$0790
        LDA.w #$0E07
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0792
        LDA.w #$0E08
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
    
    ; $DCC12 ALTERNATE ENTRY POINT
    
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, X
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        LDA.b #$16 : STA $012F
        
        RTS
    }

; ==============================================================================

    ; $DCC27-$DCC4C JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$0C : BNE BRANCH_DCBED
        
        INC $B0
        
        STZ $C8
        
        REP #$30
        
        LDX.w #$0710
        LDA.w #$0E07
        
        JSL $1BC97C
        
        LDX.w #$0712
        LDA.w #$0E08
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        BRA BRANCH_DCC12
    }

; ==============================================================================

    ; $DCC4D-$DCC8B JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$0C : BNE BRANCH_DCBED
        
        INC $B0
        
        STZ $C8
        
        REP #$30
        
        LDX.w #$0590
        LDA.w #$0E11
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0596
        LDA.w #$0E12
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0610
        LDA.w #$0E0D
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0692
        LDA.w #$0E0B
        
        JSR $C9DE ; $DC9DE IN ROM
        
        JMP $CC12 ; $DCC12 IN ROM
    }

; ==============================================================================

    ; $DCC8C-$DCCC7 JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$0C : BNE BRANCH_DCBED
        
        INC $B0
        
        STZ $C8
        
        REP #$30
        
        LDX.w #$0590
        LDA.w #$0E13
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0596
        LDA.w #$0E14
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0610
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0692
        
        JSR $C9DE ; $DC9DE IN ROM
        
        JSR $CC12 ; $DCC12 IN ROM
        
        JMP $CF40 ; $DCF40 IN ROM
    }

; ==============================================================================

    ; $DCCC8-$DCCD3 JUMP TABLE
    pool MiseryMireEntrance_Main:
    {
    
    .handlers
        dw MiseryMireEntrance_PhaseOutRain
        dw $CD41 ; = $DCD41*; Set up the rumbling noise 
        dw $CD41 ; = $DCD41*; Do the first graphical change
        dw $CDA9 ; = $DCDA9*; Do the second graphical change
        dw $CDD7 ; = $DCDD7*; Do the third graphical change
        dw $CE05 ; = $DCE05*
    }

; ==============================================================================

    ; *$DCCD4-$DCCF9 LOCAL
    MiseryMireEntrance_Main:
    {
        ; if($B0 < 0x02)
        LDA $B0 : CMP.b #$02 : BCC .anoshake_screen
        
        REP #$20
        
        ; Load the frame counter.
        LDA $1A : AND.w #$0001 : ASL A : TAX
        
        ; Shake the earth! This is the earthquake type effect.
        LDA.l $01C961, X : STA $011A
        LDA.l $01C965, X : STA $011C
        
        SEP #$20
    
    .anoshake_screen
    
        LDA $B0 : ASL A : TAX
        
        JMP (.handlers, X)
    }

; ==============================================================================

    ; $DCCFA-$DCD13 DATA
    pool MiseryMireEntrance_PhaseOutRain:
    {
    
    .phase_masks
        db $FF, $F7, $F7, $FB, $EE, $EE, $EE, $EE
        db $EE, $EE, $AA, $AA, $AA, $AA, $AA, $AA
        db $AA, $88, $88, $88, $88, $80, $80, $80
        db $80, $80
    }

; ==============================================================================

    ; *$DCD14-$DCD40 JUMP LOCATION
    MiseryMireEntrance_PhaseOutRain:
    {
        ; \note Assume a data bank register value of 0x00 here. Yeah, strange,
        ; I know.
        
        INC $C8
        
        ; If $C8 <= #$20. Delay for 20 frames basically.
        LDA $C8 : CMP.b #$20 : BCC .delay
        
        ; ($C8 - 0x20) != 0xCF
        SUB.b #$20 : CMP.b #$CF : BNE .not_next_step_yet
        
        ; After 0xEF frames have counted down, go on to the next step
        ; And reset the substep index.
        INC $B0
        STZ $C8
    
    .not_next_step_yet
    
        PHA : AND.b #$07 : ASL A : TAY
        
        PLA : AND.b #$F8 : LSR #3 : TAX
        
        ; $98C1, Y THAT IS
        LDA $98C1, Y
        
        STZ $1D
        
        AND.l .phase_masks, X : BEQ .no_rain
        
        ; turn the overlay back on if the two numbers share some bits
        INC $1D
    
    .no_rain
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$DCD41-$DCDA8 JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$10 : BNE .delay
        
        ; On the 0x10th frame move to the next step.
        INC $B0
        
        ; Play a sound effect.
        LDY.b #$07 : STY $012D
    
    .delay
    
        ; If $C8 != 0x48, end the routine.
        CMP.b #$48 : BNE .return
        
        JSR $D00E ; $DD00E IN ROM; SFX FOR THE ENTRANCE OPENING
        
        ; So, on the 0x48th frame, 
        
        ; Check off the fact that this has been opened.
        LDX $8A : LDA $7EF280, X : ORA.b #$20 : STA $7EF280, X
        
        REP #$30
        
        ; A tile grid coordinate for the animation.
        ; Add 0x80 to move down one block. Add #$02 to move over one block.
        LDX.w #$0622
        
        ; An index into the set of tiles to use.
        LDA.w #$0E48
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0624 : LDA.w #$0E49
    
    ; *$DCD75 ALTERNATE ENTRY POINT
    
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM Draw the next 3 tiles
        
        LDX.w #$06A2
        
        JSR $C9DE ; $DC9DE IN ROM Draw the next 4 tiles
        JSR $C9DE ; $DC9DE IN ROM one line below
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0722
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, Y
        
        SEP #$30
        
        LDA.b #$01 : STA $14
    
    ; *$DCDA8 ALTERNATE ENTRY POINT
    .return
    
        RTS
    }

    ; *$DCDA9-$DCDD6 JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$48
        
        BNE BRANCH_$DCDA8
        
        JSR $D00E   ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$05A2
        LDA.w #$0E54
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$05A4
        LDA.w #$0E55
    
    ; *$DCDC6 BRANCH LOCATION
    
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDX.w #$0622
        
        JSR $C9DE   ; $DC9DE IN ROM
        
        BRA BRANCH_$DCD75
    }

    ; *$DCDD7-$DCE04 JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$50 : BNE BRANCH_$DCDA8
        
        JSR $D00E   ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$0522
        LDA.w #$0E64
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0524
        LDA.w $0E65
        
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDX.w #$05A2
        
        JSR $C9DE   ; $DC9DE IN ROM
        
        BRA BRANCH_$DCDC6
    }

    ; *$DCE05-$DCE15 JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$80 : BNE BRANCH_ALPHA
        
        JSR $CF40 ; $DCF40 IN ROM; CLEAN UP, PLAY A SOUND AND RETURN NORMALCY
        
        LDA.b #$05 : STA $012D
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $DCE16-$DCE27 DATA
    pool TurtleRockEntrance_Main:
    {
    
    .handlers
        dW $CE48
        dW $CE5E
        dW $CE62
        dW $CE66
        dW $CE8A
        dW $CEAC
        dW $CEF8
        dW $CF17
        dW $CF40
    }

; ==============================================================================

    ; $DCE28-$DCE47 JUMP LOCATION
    TurtleRockEntrance_Main:
    {
        REP #$20
        
        LDA $1A : AND.w #$0001 : ASL A : TAX
        
        LDA $01C961, X : STA $011A
        
        LDA $01C965, X : STA $011C
        
        SEP #$20
        
        LDA $B0 : ASL : TAX
        
        JMP (.handlers, X)
    }

; ==============================================================================

    ; $DCE48-$DCE89 JUMP LOCATION
    {
        LDX $8A
        
        LDA $7EF280, X : ORA.b #$20 : STA $7EF280, X
        
        LDA.b #$00
        
        JSL Dungeon_ApproachFixedColor.variable
        
        LDA.b #$10
        
        BRA BRANCH_DCE68
    
    ; $DCE5E ALTERNATE ENTRY POINT
    
        LDA.b #$14
        
        BRA BRANCH_DCE68
    
    ; $DCE62 ALTERNATE ENTRY POINT
    
        LDA.b #$18
        
        BRA BRANCH_DCE68
    
    ; $DCE66 ALTERNATE ENTRY POINT
    
        LDA.b #$1C
    
    ; $DCE68 ALTERNATE ENTRY POINT
    
        STA $1002
        STZ $1003
        
        REP #$30
        
        LDA.w #$FE47 : STA $1004
        
        LDA.w #$01E3 : STA $1006
        
        SEP #$20
        
        LDA.b #$FF : STA $1008
        
        INC $B0
        
        LDA.b #$01 : STA $14
        
        RTS
    }

; ==============================================================================

    ; $DCE8A-$DCEAB JUMP LOCATION
    {
        REP #$20
        
        LDX.b #$0E
        
        LDA.w #$0000
    
    .loop
    
        STA $7EC5B0, X
        STA $7EC3D0, X
        
        DEX #2 : BPL .loop
        
        LDA $E8 : STA $E6
        
        LDA $E2 : STA $E0
        
        SEP #$20
        
        INC $B0
        
        INC $15
        
        RTS
    }

; ==============================================================================

    ; $DCEAC-$DCEF7 JUMP LOCATION
    {
        JSR $CF60
        
        LDA.b #$01 : STA $1D
        
        LDA.b #$02 : STA $99
        
        LDA.b #$22 : STA $9A
        
        REP #$30
        
        LDX.w #$0000
    
    .gamma
    
        LDA $1002, X : ORA.w #$0010 : STA $1002, X
        
        LDA $1006, X : CMP.w #$08AA : BNE .alpha
        
        LDA.w #$01E3 : STA $1006, X
    
    .alpha
    
        LDA $1008, X : CMP.w #$08AA : BNE .beta
        
        LDA.w #$01E3 : STA $1008, X
    
    .beta
    
        INX #8
        
        CPX $00 : BNE .gamma
        
        SEP #$30
        
        STZ $C8
        
        INC $B0
        
        RTS
    }

; ==============================================================================

    ; $DCEF8-$DCF16 JUMP LOCATION
    {
        LDA $1A : LSR A : BCS .alpha
        
        LDA $C8 : AND.b #$07 : BNE .beta
        
        JSL $00EDB1 ; $6DB1 IN ROM
        
        LDA.b #$02 : STA $012F
        
    .beta
    
        DEC $C8 .alpha
        
        LDA.b #$30 : STA $C8
        
        INC $B0
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $DCF17-$DCF3F JUMP LOCATION
    {
        LDA $1A : LSR A : BCS .alpha
        
        LDA $C8 : AND.b #$07 : BNE .alpha
        
        LDA.b #$02 : STA $012F
        
    .alpha
    
        DEC $C8 : BNE BRANCH_DCF16
        
        JSR $CF60 ; $DCF60 IN ROM
        
        STZ $1D
        
        LDA.b #$82 : STA $99
        
        LDA.b #$20 : STA $9A
        
        INC $B0
        
        LDA.b #$05 : STA $012D
        
        RTS
    }

; ==============================================================================

    ; *$DCF40-$DCF5F LOCAL
    {
        ; Pretty much puts a stop to any entrance animation
        
        ; Play the mystery sound that happens when you beat a puzzle.
        LDA.b #$1B : STA $012F
        
        STZ $04C6
        STZ $B0
        STZ $0710
        STZ $02E4
        
        STZ $0FC1
        
        STZ $011A
        STZ $011B
        STZ $011C
        STZ $011D
        
        RTS
    }

; ==============================================================================

    ; $DCF60-$DCFBE JUMP LOCATION
    {
        REP #$30
        
        LDX.w #$099E
        LDA.w #$0E78
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$09A0
        LDA.w #$0E79
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0A1E
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0A9E
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$0B1E
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, Y
        
        TYA : ADD.w #$0010 : STA $00
        
        SEP #$30
        
        LDA.b #$01 : STA $14
                     STA $0710
        
        RTS
    }

; ==============================================================================


    ; $DCFBF-$DCFD8 JUMP TABLE
    {
        dw $CFE0 ; = $DCFE0
        dw $CFE0 ; = $DCFE0
        dw $CFF1 ; = $DCFF1
        dw $D01D ; = $DD01D
        dw $D062 ; = $DD062*
        dw $D093 ; = $DD093*
        dw $D0DE ; = $DD0DE*
        dw $D107 ; = $DD107*
        dw $D127 ; = $DD127*
        dw $D14D ; = $DD14D*
        dw $D16D ; = $DD16D* 
        dw $D19F ; = $DD19F* ; place the last step of Ganon's Tower.
        dw $D1C0 ; = $DD1C0* ; restore music, play some sfx, and let Link move again
    }

    ; $DCFD9-$DCFDF ????
    {
        LDA $B0 : ASL A : TAX

        JMP ($CFBF, X) ; SEE JUMP TABLE AT $DCFBF
    }

    ; $DCFE0-$DCFF0 JUMP LOCATION
    {
        LDX $8A
        
        LDA $7EF280, X : ORA.b #$20 : STA $7EF280, X
        
        JSL $0EDDFC ; $75DFC IN ROM
        
        RTS
    }

    ; $DCFF1-$DD00D JUMP LOCATION
    {
        JSL $0EDDFC ; $75DFC IN ROM
        
        LDA $1D : BNE BRANCH_BETA
        
        INC $1D
        
        INC $C8 : LDA $C8 : CMP.b #$03 : BNE BRANCH_ALPHA
        
        STZ $C8
        
        LDA.b #$07 : STA $012D
        
        RTS
    
    BRANCH_ALPHA:
    
        STZ $B0
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$DD00E-$DD01C LOCAL
    {
        INC $B0
        
        STZ $C8
        
        LDA.b #$0C : STA $012E ; PLAY SFX
        LDA.b #$07 : STA $012F ; PLAY SFX IN CONJUNCTION WITH THE FIRST.
        
        RTS
    }

    ; $DD01D-$DD061 LOCAL
    {
        INC $C8
        
        LDA $C8 : CMP.b #$30
        
        BNE BRANCH_ALPHA
        
        JSR $D00E ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$045E
        LDA.w #$0E88
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0460
        LDA.w #$0E89
        
        JSR $C9DE ; $DC9DE IN ROM
        
        LDX.w #$04DE
        LDA.w #$0EA2
        
        JSR $C9DE ; $DC9DE IN ROM
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$0E8A
    
    ; *$DD04C ALTERNATE ENTRY POINT
    
        LDX.w #$055E
    
    ; *$DD04F ALTERNATE ENTRY POINT
    
        JSR $C9DE ; $DC9DE IN ROM
    
    ; *$DD052 ALTERNATE ENTRY POINT
    
        JSR $C9DE ; $DC9DE IN ROM
        
        LDA.w #$FFFF : STA $1012, Y
        
        SEP #$30
        
        LDA.b #$01 : STA $14
    
    ; *$DD061 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        RTS
    }

    ; $DD062-$DD092 JUMP LOCATION
    {
        INC $C8
        
        LDA $C8 : CMP.b #$30 : BNE BRANCH_$DD061; (RTS)
        
        JSR $D00E ; $DD00E in Rom.
        
        REP #$30
        
        LDX.w #$045E
        LDA.w #$0E8C
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0460
        LDA.w #$0E8D
        
        JSR $C9DE ; $DC9DE in Rom.
        
        LDX.w #$04DE
        LDA.w #$0E8E
        
        JSR $C9DE ; $DC9DE in Rom.
        JSR $C9DE ; $DC9DE in Rom.
        
        LDA.w #$0E90
        
        BRA BRANCH_$DD04C
    }

    ; *$DD093-$DD0DD JUMP LOCATION
    {
    	INC $C8
    	
    	LDA $C8 : CMP.b #$34
    	
    	BNE BRANCH_$DD0DD; (RTS)
        
    	JSR $D00E ; $DD00E IN ROM
        
    	REP #$30
    	
    	LDX.w #$045E
    	LDA.w #$0E92
    	
    	JSL Overworld_DrawPersistentMap16
        
    	LDX.w #$0460
    	LDA.w #$0E93
    	
    	JSR $C9DE ; $DC9DE IN ROM
        
    	LDX.w #$04DE
    	LDA.w #$0E94
    	
    	JSR $C9DE ; $DC9DE in Rom.
    	
    	LDA.w #$0E94
    	
    	JSR $C9DE ; $DC9DE in Rom.
    	
    	LDX.w #$055E
    	LDA.w #$0E95
    	
    	JSR $C9DE ; $DC9DE in Rom.
    	
    	LDA.w #$0E95
    	
    	JSR $C9DE ; $DC9DE in Rom.
        
    	LDA.w #$FFFF : STA $1012, Y
    	
    	SEP #$30
        
    	LDA.b #$01 : STA $14

    ; *$DD0DD ALTERNATE ENTRY POINT

    	RTS
    }

    ; *$DD0DE-$DD106 JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$20 : BNE BRANCH_$DD0DD ; (RTS)
        
        JSR $D00E ; $DD00E
        
        REP #$30
        
        LDX.w #$045E
        LDA.w #$0E9C
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0460
        LDA.w #$0E97
        
        JSR $C9DE ; $DC9DE in rom
        
        LDX.w #$04DE
        LDA.w #$0E98
        
        JMP $D04F   ; $DD04F IN ROM
    }

    ; *$DD107-$DD126 JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$20 : BNE BRANCH_$DD0DD; (RTS)
        
        JSR $D00E   ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$04DE
        LDA.w #$0E9A
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$04E0
        LDA.w #$0E9B
        
        JMP $D052   ; $DD052 IN ROM
    }

    ; *$DD127-$DD14C JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$20 : BNE BRANCH_$DD0DD
        
        JSR $D00E   ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$04DE
        LDA.w #$0E9C
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$04E0
        LDA.w #$0E9D
        
        JSR $C9DE   ; $DC9DE IN ROM
        
        LDA.w #$0E9E
        
        JMP $D04C   ; $DD052 IN ROM
    }

    ; *$DD14D-$DD16C JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$20 : BNE BRANCH_DD0DD ; (RTS)
        
        JSR $D00E ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$055E
        LDA.w #$0E9A
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0560
        LDA.w #$0E9B
        
        JMP $D052   ; $DD052 IN ROM
    }

    ; *$DD16D-$DD19E JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$20  BNE BRANCH_DD1D7; (RTS)
        
        JSR $D00E ; $DD00E in Rom.
        
        REP #$30
        
        LDX.w #$055E
        LDA.w #$0E9C
        
        JSL Overworld_DrawPersistentMap16
        
        LDX.w #$0560
        LDA.w #$0E9D
        
        JSR $C9DE ; $DC9DE
        
        LDX.w #$05DE
        LDA.w #$0EA0
        
        JSR $C9DE ; $DC9DE in Rom.
        
        LDA.w #$0EA1
        LDX.w #$05E0
        
        JMP $D052 ; $DD052 IN ROM.
    }

    ; $DD19F-$DD1BF JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$20 : BNE BRANCH_DD1D7 ; (RTS)
        
        LDA.b #$05 : STA $012D 
        
        JSR $D00E ; $DD00E IN ROM
        
        REP #$30
        
        LDX.w #$05DE
        LDA.w #$0E9A
        
        JSL Overworld_DrawPersistentMap16
        
        LDA.w #$0E9B
        
        BRA BRANCH_$DD199
    }

    ; *$DD1C0-$DD1D7 JUMP LOCATION
    {
        INC $C8 : LDA $C8 : CMP.b #$48 : BNE .waitForTimer
        
        JSR $CF40 ; $DCF40 IN ROM; Play "you solved puzzle" sound
        
        STZ $C8
        
        ; Restore music to DW Death Mountain music.
        LDA.b #$0D : STA $012C
        
        ; Rumble sound effect.
        LDA.b #$09 : STA $012D
    
    ; *$DD1D7 ALTERNATE ENTRY POINT
    .waitForTimer
    
        RTS
    }

; ==================================================

    ; $DD1D8-$DD217 NULL
    {
        fillbyte $FF
        
        fill $40
    }

; ==================================================

    incsrc "palettes.asm"
