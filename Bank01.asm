
    ; Bank 0x01 - a giant pain in the ass of a bank, imo

org $018000

; ==============================================================================

    ; $8000-$81FF DATA
    pool Dungeon_LoadType1Object: 
    {
    
    .subtype_1_params
        dw $03D8, $02E8, $02F8, $0328, $0338, $0400, $0410, $0388
        dw $0390, $0420, $042A, $0434, $043E, $0448, $0452, $045C
        dw $0466, $0470, $047A, $0484, $048E, $0498, $04A2, $04AC
        dw $04B6, $04C0, $04CA, $04D4, $04DE, $04E8, $04F2, $04FC
        dw $0506, $0598, $0600, $063C, $063C, $063C, $063C, $063C
        dw $0642, $064C, $0652, $0658, $065E, $0664, $066A, $0688
        dw $0694, $06A8, $06A8, $06A8, $06C8, $0000, $078A, $07AA
        dw $0E26, $084A, $086A, $0882, $08CA, $085A, $08FA, $091A
        
        dw $0920, $092A, $0930, $0936, $093C, $0942, $0948, $094E
        dw $096C, $097E, $098E, $0902, $099E, $09D8, $09D8, $09D8
        dw $09FA, $156C, $1590, $1D86, $0000, $0A14, $0A24, $0A54
        dw $0A54, $0A84, $0A84, $14DC, $1500, $061E, $0E52, $0600
        dw $03D8, $02C8, $02D8, $0308, $0318, $03E0, $03F0, $0378
        dw $0380, $05FA, $0648, $064A, $0670, $067C, $06A8, $06A8
        dw $06A8, $06C8, $0000, $07AA, $07CA, $084A, $089A, $08B2
        dw $090A, $0926, $0928, $0912, $09F8, $1D7E, $0000, $0A34
        
        dw $0A44, $0A54, $0A6C, $0A84, $0A9C, $1524, $1548, $085A
        dw $0606, $0E52, $05FA, $06A0, $06A2, $0B12, $0B14, $09B0
        dw $0B46, $0B56, $1F52, $1F5A, $0288, $0E82, $1DF2, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $03D8, $03D8, $03D8, $03D8, $05AA, $05B2, $05B2, $05B2
        dw $05B2, $00E0, $00E0, $00E0, $00E0, $0110, $0000, $0000
        dw $06A4, $06A6, $0AE6, $0B06, $0B0C, $0B16, $0B26, $0B36
        dw $1F52, $1F5A, $0288, $0EBA, $0E82, $1DF2, $0000, $0000
        
        dw $03D8, $0510, $05AA, $05AA, $0000, $0168, $00E0, $0158 ; c7
        dw $0100, $0110, $0178, $072A, $072A, $072A, $075A, $0670 ; cf
        dw $0670, $0130, $0148, $072A, $072A, $072A, $075A, $00E0 ; d7
        dw $0110, $00F0, $0110, $0000, $0AB4, $08DA, $0ADE, $0188 ; df
        dw $01A0, $01B0, $01C0, $01D0, $01E0, $01F0, $0200, $0120 ; e7
        dw $02A8, $0000, $0000, $0000, $0000, $0000, $0000, $0000 ; ef
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000 ; f7
        
        ; \unused
        ; This last row is not used, because there are only 0xf8 subtype 1
        ; scripts in actuality. Hackers can use this for whatever they want.
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000 ; ff
    }

; ==============================================================================

    ; $8200-$83EF JUMP TABLE
    pool Dungeon_LoadType1Object:
    {
    
    .subtype_1_params
        ; Subtype 1 objects (0xF8 distinct object types)
        
        ; 0x00
        dw Object_Draw2x2s_AdvanceRight_from_1_to_15_or_32
        dw Object_Draw4x2s_AdvanceRight_from_1_to_15_or_26
        dw Object_Draw4x2s_AdvanceRight_from_1_to_15_or_26
        dw Object_Draw4x2s_AdvanceRight_from_1_to_16_BothBgs
        dw Object_Draw4x2s_AdvanceRight_from_1_to_16_BothBgs
        dw $8C37 ; = $8C37
        dw $8C37 ; = $8C37
        dw $8B79 ; = $8B79
        
        ; 0x08
        dw $8B79 ; = $8B79
        dw $8C58 ; = $8C58
        dw $8C61 ; = $8C61
        dw $8C61 ; = $8C61
        dw $8C58 ; = $8C58
        dw $8C58 ; = $8C58
        dw $8C61 ; = $8C61
        dw $8C61 ; = $8C61
        
        ; 0x10
        dw $8C58 ; = $8C58
        dw $8C58 ; = $8C58
        dw $8C61 ; = $8C61
        dw $8C61 ; = $8C61
        dw $8C58 ; = $8C58
        dw $8C6A ; = $8C6A
        dw $8CB9 ; = $8CB9
        dw $8CB9 ; = $8CB9
        
        ; 0x18
        dw $8C6A ; = $8C6A
        dw $8C6A ; = $8C6A
        dw $8CB9 ; = $8CB9
        dw $8CB9 ; = $8CB9
        dw $8C6A ; = $8C6A
        dw $8C6A ; = $8C6A
        dw $8CB9 ; = $8CB9
        dw $8CB9 ; = $8CB9
        
        ; 0x20
        dw $8C6A ; = $8C6A
        dw $8D5D ; = $8D5D ; mini staircase (just slows you down)
        dw Object_HorizontalRail_short ; = $8EF0
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        
        ; 0x28
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $8FBD ; = $8FBD
        
        ; 0x30
        dw $9001 ; = $9001
        dw $90F8 ; = $90F8 ; Unused object
        dw $90F8 ; = $90F8 ; Unused object
        dw $9111 ; = $9111
        dw $9136 ; = $9136 ; 34
        dw $913F ; = $913F ; 35? (HM says unused)
        dw $92FB ; = $92FB ; Curtains in Agahnim's room (horizontal)
        dw $92FB ; = $92FB ; Curtains in Agahnim's room (vertical, but not really useful b/c it tiles horizontally)
        
        ; 0x38
        dw $9323 ; = $9323
        dw $936F ; = $936F
        dw $9387 ; = $9387
        dw $9387 ; = $9387
        dw $93B7 ; = $93B7
        dw $936F ; = $936F
        dw $9456 ; = $9456
        dw $8F62 ; = $8F62
        
        ; 0x40
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $8F62 ; = $8F62 ; outline for water pools
        dw $9466 ; = $9466 ; Thin waterfall (not used!)
        
        ; 0x48
        dw $9488 ; = $9488 ; Variable width waterfall (also unused)
        dw $94B4 ; = $94B4
        dw $94B4 ; = $94B4
        dw $9456 ; = $9456
        dw $94BD ; = $94BD
        dw $94DF ; = $94DF ; Interesting that these three objects are identical and so are their parameters...
        dw $94DF ; = $94DF
        dw $94DF ; = $94DF
        
        ; 0x50
        dw $96DC ; = $96DC
        dw $9CC6 ; = $9CC6
        dw $9CC6 ; = $9CC6
        dw $8B79 ; = $8B79
        dw $8AA3 ; = $8AA3 ; unused object
        dw $96F9 ; = $96F9
        dw $96F9 ; = $96F9
        dw $971A ; = $971A
        
        ; 0x58
        dw $971A ; = $971A
        dw $971A ; = $971A
        dw $971A ; = $971A
        dw $9CC6 ; = $9CC6
        dw $9CC6 ; = $9CC6
        dw $8F36 ; = $8F36
        dw $9338 ; = $9338
        dw Object_HorizontalRail_long
        
        ; 0x60
        dw Object_Draw2x2sDownVariableOrFull
        dw $8A89 ; = $8A89
        dw $8A89 ; = $8A89
        dw $8AA4 ; = $8AA4
        dw $8AA4 ; = $8AA4
        dw $8C4F ; = $8C4F
        dw $8C4F ; = $8C4F
        dw $8B74 ; = $8B74
        
        ; 0x68
        dw $8B74 ; = $8B74
        dw $8EC3 ; = $8EC3
        dw $8F8A ; = $8F8A
        dw $8F8A ; = $8F8A
        dw $9045 ; = $9045
        dw $908F ; = $908F
        dw $90F8 ; = $90F8 ; Unused object?
        dw $90F8 ; = $90F8 ; Unused object?
        
        ; 0x70
        dw $90F9 ; = $90F9
        dw $9120 ; = $9120
        dw $8AA3 ; = $8AA3
        dw $930E ; = $930E
        dw $930E ; = $930E
        dw $9357 ; = $9357
        dw $939F ; = $939F
        dw $939F ; = $939F
        
        ; 0x78
        dw $9446 ; = $9446
        dw $8F8A ; = $8F8A
        dw $8F8A ; = $8F8A
        dw $9446 ; = $9446
        dw $96E4 ; = $96E4
        dw $8B74 ; = $8B74
        dw $8AA3 ; = $8AA3
        dw $9702 ; = $9702
        
        ; 0x80
        dw $9702 ; = $9702
        dw $971B ; = $971B
        dw $971B ; = $971B
        dw $971B ; = $971B
        dw $971B ; = $971B
        dw $9CEB ; = $9CEB
        dw $9CEB ; = $9CEB
        dw $9357 ; = $9357
        
        ; 0x88
        dw $8F0C ; = $8F0C
        dw $9347 ; = $9347
        dw $8EBE ; = $8EBE
        dw $90E2 ; = $90E2
        dw $90E2 ; = $90E2
        dw $8F8A ; = $8F8A
        dw $8F8A ; = $8F8A
        dw $97B5 ; = $97B5
        
        ; 0x90
        dw $8A89 ; = $8A89
        dw $8A89 ; = $8A89
        dw Object_Draw2x2sDownVariableOrFull ; Blue block switch   (vertical)
        dw Object_Draw2x2sDownVariableOrFull ; Orange block switch (vertical)
        dw $90F9 ; = $90F9 ; Partially see through floor
        dw $B381 ; = $B381 ; Vertical line of pots
        dw $B47F ; = $B47F ; Vertical Line of moles
        dw $8AA3 ; = $8AA3
        
        ; 0x98
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        
        ; 0xA0
        dw $8BE0 ; = $8BE0
        dw $8BF4 ; = $8BF4
        dw $8C0E ; = $8C0E
        dw $8C22 ; = $8C22
        dw Object_Hole
        dw $8E67 ; = $8E67
        dw $8E7B ; = $8E7B
        dw $8E95 ; = $8E95
        
        ; 0xA8
        dw $8EA9 ; = $8EA9
        dw $8E67 ; = $8E67
        dw $8E7B ; = $8E7B
        dw $8E95 ; = $8E95
        dw $8EA9 ; = $8EA9
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        
        ; 0xB0
        dw $90D9 ; = $90D9
        dw $90D9 ; = $90D9
        dw $9111 ; = $9111
        dw $8F62 ; = $8F62
        dw $8F62 ; = $8F62
        dw $97DC ; = $97DC ; Fortune teller curtain
        dw Object_Draw4x2s_AdvanceRight.from_1_to_15_or_26
        dw Object_Draw4x2s_AdvanceRight.from_1_to_15_or_26
        
        ; 0xB8
        dw Object_Draw2x2s_AdvanceRight.from_1_to_15_or_32 ; Blue switch block (horizontal)
        dw Object_Draw2x2s_AdvanceRight.from_1_to_15_or_32 ; Orange switch block (horizontal)
        dw $9111 ; = $9111
        dw $9338 ; = $9338
        dw $B376 ; = $B376 ; Horizontal line of pots
        dw $B474 ; = $B474 ; Horizontal line of moles
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        
        ; 0xC0
        dw Object_DrawRectOf1x1s
        dw $8CC7 ; = $8CC7*
        dw Object_DrawRectOf1x1s
        dw $8D9E ; = $8D9E
        dw $8FA2 ; = $8FA2
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        
        ; 0xC8
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $918F ; = $918F ; Undefined object
        dw $918F ; = $918F ; Undefined object
        dw Object_HiddenWallRight
        dw Object_HiddenWallLeft
        dw $8FBC ; = $8FBC
        
        ; 0xD0
        dw $8FBC ; = $8FBC
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $9298 ; = $9298*
        dw $9298 ; = $9298*
        dw $9298 ; = $9298*
        dw $9298 ; = $9298*
        dw $8D9E ; = $8D9E
        
        ; 0xD8
        dw Object_Water ; Water
        dw $8FA5 ; = $8FA5 ; Large black space
        dw $95EF ; = $95EF* ; Water 2?
        dw $8F9D ; = $8F9D
        dw $9733 ; = $9733 ; Staircase platform
        dw $93DC ; = $93DC* ; Large rock formation in caves / variable sized table
        dw $9429 ; = $9429* ; Spike block groups
        dw $8FA5 ; = $8FA5
        
        ; 0xE0
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        dw $8FA5 ; = $8FA5
        
        ; 0xE8
        dw $8FA5 ; = $8FA5
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        
        ; 0xF0
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
        dw $8AA3 ; = $8AA3
    }

; ==============================================================================

    ; $83F0-$846F DATA
    Subtype2Params:
    {
        dw $0B66, $0B86, $0BA6, $0BC6, $0C66, $0C86, $0CA6, $0CC6
        dw $0BE6, $0C06, $0C26, $0C46, $0CE6, $0D06, $0D26, $0D46
        
        dw $0D66, $0D7E, $0D96, $0DAE, $0DC6, $0DDE, $0DF6, $0E0E
        dw $0398, $03A0, $03A8, $03B0, $0E32, $0E26, $0EA2, $0E9A
        
        dw $0ECA, $0ED2, $0EDE, $0EDE, $0F1E, $0F3E, $0F5E, $0F6A
        dw $0EF6, $0F72, $0F92, $0FA2, $0FA2, $1088, $10A8, $10A8
        
        dw $10C8, $10C8, $10C8, $10C8, $0E52, $1108, $1108, $12A8
        dw $1148, $1160, $1178, $1190, $1458, $1488, $2062, $2086
    }

; ==============================================================================

    ; $8470-$84EF JUMP TABLE
    Subtype2Routines:
    {
        ; Subtype 2 objects (0x40 distinct object types)
        
        ; 0x00
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        
        ; 0x08
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        dw Object_Draw4x4_BothBgs
        
        ; 0x10
        dw Object_Draw4x3_BothBgs
        dw Object_Draw4x3_BothBgs
        dw Object_Draw4x3_BothBgs
        dw Object_Draw4x3_BothBgs
        dw Object_Draw3x4_BothBgs
        dw Object_Draw3x4_BothBgs
        dw Object_Draw3x4_BothBgs
        dw Object_Draw3x4_BothBgs
        
        ; 0x18
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw4x4
        dw Object_Draw3x2
        dw Object_StarTile_disabled 
        dw Object_StarTile
        
        ; 0x20
        dw $9892 ; = $9892* ; lit torch (distinct from the main torch type. one usage of note is in ganon's room)
        dw Object_Draw3x2
        dw Object_Draw5x4 ; mangled bed?...
        dw Object_Draw3x4
        dw Object_Draw4x4
        dw Object_Draw4x4
        dw Object_Draw3x2
        dw Object_Draw2x2
        
        ; 0x28
        dw Object_Draw5x4 ; bed
        dw Object_Draw4x4
        dw Object_Draw2x4
        dw Object_Draw2x2
        dw Object_Draw3x6_Alternate 
        dw $A41B ; = $A41B* ; inter-room in-room up-north   staircase
        dw $A458 ; = $A458* ; inter-room in-room down-south staircase
        dw $A486 ; = $A486* ; inter-room in-room down-north staircase (subtype obscured by hidden wall)
        
        ; 0x30
        dw $A25D ; = $A25D* ; seems identical to next object, but unused in the original game
        dw $A26D ; = $A26D* ; inter-bg        in-room up-north staircase
        dw $A2C7 ; = $A2C7* ; inter-psuedo bg in-room up-north staircase
        dw $A2DF ; = $A2DF* ; inter-bg        in-room up-north staircase (subtype used in water rooms like in Swamp Palace)
        dw Object_Draw2x2 ; single block
        dw Object_WaterLadder ; Swamp Palace activated ladder
        dw Object_InactiveWaterLadder ; Swamp Palace deactivated ladder
        dw Object_Watergate
        
        ; 0x38
        dw $A4B4 ; = $A4B4* ; wall up-north spiral staircase
        dw $A533 ; = $A533* ; wall down-north spiral staircase
        dw $A4F5 ; = $A4F5* ; wall up-north spiral staircase
        dw $A584 ; = $A584* ; wall down-north spiral staircase
        dw Object_SanctuaryMantle
        dw Object_Draw3x4
        dw Object_Draw3x6
        dw Object_Draw7x8 ; Quick note: Hyrule Magic doesn't appear to display this properly. (What does it look like when used properly?)
    }

; ==============================================================================

    ; $84F0-$85EF DATA
    Subtype3Params:
    {
        dw $1614, $162C, $1654, $0A0E, $0A0C, $09FC, $09FE, $0A00
        dw $0A02, $0A04, $0A06, $0A08, $0A0A, $0000, $0A10, $0A12
        
        dw $1DDA, $1DE2, $1DD6, $1DEA, $15FC, $1DFA, $1DF2, $1488
        dw $1494, $149C, $14A4, $10E8, $10E8, $10E8, $11A8, $11C8
        
        dw $11E8, $1208, $03B8, $03C0, $03C8, $03D0, $1228, $1248
        dw $1268, $1288, $0000, $0E5A, $0E62, $0000, $0000, $0E82
        
        dw $0E8A, $14AC, $14C4, $10E8, $1614, $1614, $1614, $1614
        dw $1614, $1614, $1CBE, $1CEE, $1D1E, $1D4E, $1D8E, $1D96
        
        dw $1D9E, $1DA6, $1DAE, $1DB6, $1DBE, $1DC6, $1DCE, $0220
        dw $0260, $0280, $1F3A, $1F62, $1F92, $1FF2, $2016, $1F42
        
        dw $0EAA, $1F4A, $1F52, $1F5A, $202E, $2062, $09B8, $09C0
        dw $09C8, $09D0, $0FA2, $0FB2, $0FC4, $0FF4, $1018, $1020
        
        dw $15B4, $15D8, $20F6, $0EBA, $22E6, $22EE, $05DA, $281E
        dw $2AE0, $2D2A, $2F2A, $22F6, $2316, $232E, $2346, $235E
        
        dw $2376, $23B6, $1E9A, $0000, $2436, $149C, $24B6, $24E6
        dw $2516, $1028, $1040, $1060, $1070, $1078, $1080, $0000
    }

; ==============================================================================

    ; $85F0-$86EF JUMP TABLE
    Subtype3Routines:
    {
        ; Subtype 3 Objects (0x80 disinct object types)
        
        ; 0x00
        dw $9D29 ; = $9D29*
        dw $9D5D ; = $9D5D*
        dw $9D67 ; = $9D67*
        dw $9C3B ; = $9C3B*
        dw Object_Draw1x1
        dw Object_Draw1x1
        dw Object_Draw1x1
        dw Object_Draw1x1
        
        ; 0x08
        dw Object_Draw1x1
        dw Object_Draw1x1
        dw Object_Draw1x1
        dw Object_Draw1x1
        dw Object_Draw1x1
        dw Object_PrisonBars ; Set of prison bars with slot (unused?)
        dw $9C3B ; = $9C3B*
        dw Object_Draw1x1
        
        ; 0x10
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Rupees
        dw Object_Draw2x2 ; Telepathic tiles (Zelda, Sahasralah)
        dw Object_Draw3x4
        dw Object_KholdstareShell ; Kholdstare's shell
        dw Object_Mole ; (single mole)
        dw Object_PrisonBars ; Set of prison bars with slot (used)
        
        ; 0x18
        dw Object_BigKeyLock       ; = $98AE*
        dw Object_Chest            ; = $98D0* ; Normal Chest
        dw Object_Chest_startsOpen ; = $99B8*
        dw $A30C ; = $A30C* ; In-room up-south staircase
        dw $A31C ; = $A31C* ; In-room up-south staircase
        dw $A36E ; = $A36E* ; In-room up-south staircase
        dw $A5D2 ; = $A5D2* ; Wall up-north straight staircase
        dw $A5F4 ; = $A5F4* ; Wall down-north straight staircase
        
        ; 0x20
        dw $A607 ; = $A607* ; Wall up-south straight staircase
        dw $A626 ; = $A626* ; Wall down-south straight staircase
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw $A664 ; = $A664* ; Wall up-north straight staircase
        dw $A695 ; = $A695* ; Wall down-north straight staircase
        
        ; 0x28
        dw $A71C ; = $A71C* ; Wall up-south straight staircase
        dw $A74A ; = $A74A* ; Wall down-south straight staircase  
        dw Object_LanternLayer
        dw $B306 ; = $B306* ; Heavy (unfinished) throwable pot?
        dw Object_LargeLiftableBlock
        dw Object_AgahnimAltar 
        dw Object_AgahnimRoomFrame
        dw Object_Pot ;* Pots and Skulls in dungeons
        
        ; 0x30
        dw $B30B ; = $B30B* ; Other liftable object (graphics messed up)
        dw Object_BigChest  ; = $99BB* ; Big Chest
        dw Object_OpenedBigChest_fake
        dw $A380 ; = $A380* ; in room staircase (facing up)
        dw Object_Draw2x3
        dw Object_Draw2x3
        dw Object_Draw3x6_Alternate
        dw Object_Draw3x6_Alternate
        
        ; 0x38
        dw Object_Draw2x3
        dw Object_Draw2x3
        dw Object_Draw6x4 ; Up facing Turle Rock tube opening
        dw Object_Draw6x4 ; Down facing Turtle Rock tube opening
        dw Object_Draw4x6 ; Left facing Turtle Rock tube opening
        dw Object_Draw4x6 ; Right facing Turtle Rock tube opening
        dw Object_Draw2x2
        dw Object_Draw2x2
        
        ; 0x40
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_BombableFloor
        
        ; 0x48
        dw Object_Draw4x4 ; Fake cracked floor (2x2)
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw3x8
        dw Object_Draw8x6
        dw Object_Draw3x6
        dw Object_Draw3x4
        dw Object_Draw2x2
        
        ; 0x50
        dw Object_StarTile_disabled
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_FortuneTellerTemplate
        dw $A194 ; = $A194*
        dw Object_Draw2x2
        dw Object_Draw2x2
        
        ; 0x58
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw $9D6C ; = $9D6C*
        dw $A194 ; = $A194*
        dw Object_Draw4x6 ; Bookcase
        dw Object_Draw3x6
        dw Object_Draw2x2
        dw Object_Draw2x2
        
        ; 0x60
        dw Object_Draw6x3
        dw Object_Draw6x3
        dw $A1D1 ; = $A1D1*
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw4x4
        dw Object_Draw3x4
        
        ; 0x68
        dw Object_Draw3x4
        dw Object_Draw4x3
        dw Object_Draw4x3
        dw Object_Draw4x4
        dw Object_Draw3x4
        dw Object_Draw3x4
        dw Object_Draw4x3
        dw Object_Draw4x3
        
        ; 0x70
        dw Object_Stacked4x4s
        dw Object_BlindLight
        dw Object_TrinexxShell ; Trinexx shell
        dw Object_EntireFloorIsPit ; Whatever BG you're on, this will cover it with pit tiles. 
        dw Object_Draw8x8
        dw Object_Draw2x2 ; Minigame chest
        dw Object_Draw3x8
        dw Object_Draw3x8
        
        ; 0x78
        dw Object_Triforce
        dw Object_Draw3x4
        dw Object_Draw4x4
        dw Object_Draw10x20_With4x4
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw Object_Draw2x2
        dw $8AA3 ; = $8AA3
    }

; ==============================================================================

    ; $86F0-$86F7 JUMP TABLE
    DoorObjectRoutines:
    {
        ; A   = type
        ; X   = position (0, 2, 4, ..., 24)
        ; $02 = position (0, 2, 4, ..., 24)
        ; $04 = type
        ; $0A = type
        
        dw Door_Up    ; $A81C* ; Up
        dw Door_Down  ; $A984* ; Down
        dw Door_Left  ; $AAD7* ; Left
        dw Door_Right ; $AB99* ; Right?
    }
    
; ==============================================================================

    ; $86F8 - $8739 DATA
    Dungeon_DrawObjectOffsets:
    {
    .BG2
    
        ; $BF, $C2, $C5, $C8
        ; $CB, $CE, $D1, $D4
        ; $D7
        ; $DA
        ; $DD
        
        dl $7E2000, $7E2002, $7E2004, $7E2006
        dl $7E2080, $7E2082, $7E2084, $7E2086
        dl $7E2100
        dl $7E2180
        dl $7E2200         
    
    .BG1
    
        dl $7E4000, $7E4002, $7E4004, $7E4006
        dl $7E4080, $7E4082, $7E4084, $7E4086
        dl $7E4100
        dl $7E4180
        dl $7E4200
    }

; ==============================================================================

    ; *$873A-$88E3 LONG
    Dungeon_LoadRoom:
    {
        ; Loads dungeon room from start to finish.
        
        JSR Dungeon_LoadHeader
        
        STZ $03F4
        
        REP #$30
        
        LDX $0110
        
        ; Get pointer to object data
        LDA $1F8001, X : STA $B8
        LDA $1F8000, X : STA $B7
        
        ; Not sure.
        LDA $AD : STA $0428
        
        LDA.w #$FF30 : STA $041C
        
        STZ $041A : STZ $0420
        STZ $0312 : STZ $0310
        STZ $0422 : STZ $0424
        
        LDA.w #$FFFF : STA $0436
        
        STZ $0452 : STZ $0454 : STZ $0456
        
        STZ $068A
        
        STZ $044E : STZ $0450
        
        STZ $FC
        
        STZ $045C
        
        STZ $0438 : STZ $043A : STZ $043C : STZ $043E
        STZ $0440 : STZ $0442 : STZ $0444 : STZ $0446
        STZ $0448
        
        STZ $049A : STZ $049C : STZ $049E : STZ $04AE
        
        STZ $047E : STZ $0480 : STZ $0482 : STZ $0484
        
        STZ $04A2 : STZ $04A4 : STZ $04A6 : STZ $04A8
        
        STZ $19E2 : STZ $19E4 : STZ $19E6 : STZ $19E8
        STZ $19E0
        
        STZ $0430 : STZ $0432
        
        ; Used in some of the graphics routines for determining tile types.
        STZ $042C
        STZ $042E
        
        STZ $0496 : STZ $0498
        
        STZ $04B0
        
        LDX.w #$001E
        
        STZ $0460
    
    .initObjectBuffers
    
        STZ $19A0, X : STZ $1980, X : STZ $19C0, X
        
        STZ $04F0, X
        
        STZ $0500, X : STZ $0520, X : STZ $0540, X
        
        DEX #2 : BPL .initObjectBuffers
        
        STZ $BA
        
        JSR Dungeon_DrawFloors
        
        LDY $BA : PHY
        
        ; Y is always 1 here. Contains layout info as well as starting quadrant info.
        LDA [$B7], Y : AND.w #$00FF : STA $040E
        
        ; X = 3 * $00
        LSR #2 : STA $00 : ASL A : ADD $00 : TAX
        
        ; The offset to the pointers for each layout.
        LDA .layout_ptrs + 1, X : STA $B8
        LDA .layout_ptrs + 0, X : STA $B7
        
        STZ $BA
        
        JSR Dungeon_DrawObjects ; Load the "layout" objects.
        
        ; Y = 2
        PLY : INY : STY $BA
        
        ; Get room index * 3.
        LDX $0110
        
        LDA $1F8001, X : STA $B8
        LDA $1F8000, X : STA $B7
        
        ; Draw Layer 1 objects to BG2
        JSR Dungeon_DrawObjects
        
        INC $BA : INC $BA
        
        LDX.w #$001E
    
    .setupLayer2
    
        ; These objects are drawn onto BG1
        LDA Dungeon_DrawObjectOffsets_BG1+1, X : STA $C0, X
        
        DEX #3 : BPL .setupLayer2
        
        ; Draw Layer 2 objects to BG1
        JSR Dungeon_DrawObjects
        
        INC $BA : INC $BA
        
        LDX.w #$001E
    
    .setupLayer3
    
        ; These objects are drawn onto BG1
        LDA Dungeon_DrawObjectOffsets_BG2+1, X : STA $C0, X
        
        DEX #3 : BPL .setupLayer3
        
        ; Draw layer 3 objects to BG1
        JSR Dungeon_DrawObjects
        
        STZ $BA
    
    .next_block
    
        LDX $BA
        
        ; If the block's room matches the current room, load.
        LDA $7EF940, X : CMP $A0 : BNE .notInThisRoom
        
        ; Load the block's location
        LDA $7EF942, X : STA $08 : TAY
        
        JSR Dungeon_LoadBlock
    
    .notInThisRoom
    
        ; Move to the next block entry
        LDA $BA : ADD.w #$0004 : STA $BA
        
        ; There are 99 (decimal) blocks in the game
        CMP.w #$018C : BNE .next_block
        
        REP #$20
        
        LDA $042C : STA $042E : STA $0478
        
        ; Next load torches
        STZ $BA
    
    .notEndOfTorches
    
        LDX $BA
        
        LDA $7EFB40, X : CMP $A0 : BEQ .torchInThisRoom
        
        INX #2
    
    .nextTorch
    
        LDA $7EFB40, X
        
        INX #2 : STX $BA
        
        CMP.w #$FFFF : BNE .nextTorch
        
        CPX.w #$0120 : BNE .notEndOfTorches
        
        BRA .return

    .torchInThisroom

        INX #2
    
    .nextTorchInRoom
    
        ; get tilemap position
        LDA $7EFB40, X : STA $08
        
        INX #2 : STX $BA
        
        JSR Dungeon_LoadTorch
        
        LDX $BA
        
        LDA $7EFB40, X : CMP.w #$FFFF : BNE .nextTorchInRoom
        
        SEP #$30
    
    .return
    
        RTL
    }

; ==============================================================================

    ; *$88E4-$8915 LOCAL
    Dungeon_DrawObjects:
    {
        ; Loads Level data?
    
    .nextType1
    
        STZ $B2
        STZ $B4
        
        LDY $BA
        
        LDA [$B7], Y : CMP.w #$FFFF : BEQ .return
        
        STA $00 : CMP.w #$FFF0 : BEQ .enteredType2Section
        
        JSR Dungeon_LoadType1Object
        
        BRA .nextType1
    
    .return
    
        RTS
    
    .enteredType2Section
    
        ; After a #$FFF0 move to the next object.
        INC $BA : INC $BA
    
    .nextType2
    
        LDY $BA
        
        ; Still stop if it's an #$FFFF object.
        LDA [$B7], Y : CMP.w #$FFFF : BEQ .return 
        
        ; Store the object's information at $00.
        STA $00
        
        JSR Dungeon_LoadType2Object
        
        INC $BA : INC $BA
        
        BRA .nextType2
    }

; ==============================================================================

    ; *$8916-$893B LOCAL
    Dungeon_LoadType2Object:
    {
        ; This apparently loads doors...
        ; more generally loads 2 byte objects >_>
        
        AND.w #$00F0 : LSR #3 : STA $02
        
        LDA $00 : XBA : AND.w #$00FF : STA $0A : STA $04
        
        ; X will be even and at most 6.
        LDA $00 : AND.w #$0003 : ASL A : TAX
        
        LDA DoorObjectRoutines, X : STA $0E
        
        LDX $02
        
        LDA $04
        
        JMP ($000E)
    }

; ==============================================================================

    ; *$893C-$89DB LOCAL
    Dungeon_LoadType1Object:
    {
        ; Loads a 3 byte object into a room
        
        SEP #$20
        
        ; Basically, if object # >= 0xFC
        AND.b #$FC : CMP.b #$FC : BEQ .subtype2Object
        
        ; will become part of the tilemap offset
        STA $08
        
        ; Reload the first byte of the object.
        ; Store to this location (no idea what it does)
        LDA $00 : AND.b #$03 : STA $B2
        
        ; Same here. Excuse my ignorance.
        LDA $01 : AND.b #$03 : STA $B4
        
        ; Move to the third byte of the object.
        INY #2
        
        ; Determines the object "type". I.e. the routine to use
        LDA [$B7], Y : STA $04
        
        ; Set up the index to read the next object.
        INY : STY $BA
        
        ; This now forms a full tile map offset.
        LDA $01 : LSR #3 : ROR $08 : STA $09
        
        STZ $03
        STZ $05
        
        REP #$20
        
        ; Load the object type, multiply by two
        ; If object type >= 0xF8 goto subtype 3 objects
        LDA $04 : ASL A : CMP.w #$01F0 : BCS .subtype3Object
        
        ; Handles subtype 1 objects
        TAX
        
        LDA .subtype_1_routines, X : STA $0E
        
        LDA .subtype_1_params, X : TAX
        
        LDY $08
        
        JMP ($000E)
    
    .subtype2Object
    
        REP #$20
        
        ; Retrieve the first two bytes of the object.
        LDA $00 : XBA : AND.w #$03F0 : LSR #3 : STA $08
        
        INY
        
        LDA [$B7], Y : XBA : AND.w #$0FC0 : ASL A : ORA $08 : STA $08
        
        LDA [$B7], Y : XBA : AND.w #$003F
        
        ; Look ahead to the next object but we're not done with this one yet ;)
        INY #2 : STY $BA
        
        ASL A : TAX
        
        LDA Subtype2Routines, X : STA $0E
        
        LDA Subtype2Params, X : TAX
        
        LDY $08
        
        JMP ($000E)
    
    .subtype3Object
    
        AND.w #$000E : ASL #3 : STA $04
        
        LDA $B4 : ASL #2 : ORA $B2 : TSB $04
        
        ; A is even and at most 0xE0, Use A as an index into the following jump table
        LDA $04 : ASL A : TAX
        
        ; The basis for a jump table.
        LDA Subtype3Routines, X : STA $0E
        
        LDA Subtype3Params, X : TAX
        
        ; Contains the tile address of the object times two.
        LDY $08
        
        JMP ($000E)
    }

; ==============================================================================

    ; *$89DC-$8A43 LOCAL
    Dungeon_DrawFloors:
    {
        LDX.w #$001E
    
    .nextBg1Offset
    
        LDA Dungeon_DrawObjectOffsets_BG1,   X : STA $BF, X
        LDA Dungeon_DrawObjectOffsets_BG1+1, X : STA $C0, X
        
        ; Sets up the drawing to go to BG1 ($7E4000 and beyond)
        ; I guess we're setting up the addresses
        ; that we'll be writing to in the $BF, X array.
        ; This array extends up until $DF
        DEX #3 : BPL .nextBg1Offset
        
        LDY $BA : INC $BA
        
        STZ $0C
        
        ; Y = 0 here always, Floor 2 in Hyrule Magic
        LDA [$B7], Y : PHA : AND.w #$00F0 : STA $0490 : TAX
        
        JSR $8A1F ; $8A1F IN ROM; Draws a 32 x 32 block of tiles to screen
        
        LDX.w #$001E
    
    .nextBg2Offset
    
        LDA Dungeon_DrawObjectOffsets_BG2+1, X : STA $C0, X
        
        ; Sets up the drawing to now be to BG2 ($7E2000 and beyond)
        DEX #3 : BPL .nextBg2Offset
        
        STZ $0C
        
        ; Floor 1 in Hyrule Magic
        PLA : AND.w #$000F : ASL #4 : STA $046A : TAX
    
    ; *$8A1F ALTERNATE ENTRY POINT
    .nextQuadrant
    
        LDY $0C
        
        LDA.w Dungeon_QuadrantOffsets, Y : TAY
        
        LDA.w #$0008 : STA $0E
    
    .nextRow
    
        LDA.w #$0008
        
        ; Tells the game to draw a 4 x 32 tile block across the screen
        JSR $8A44 ; $8A44 IN ROM
        
        ADC.w #$01C0 : TAY
        
        ;  This loops 8 times. Thus, this draws a 32 x 32 tile block
        DEC $0E : BNE .nextRow
        
        INC $0C : INC $0C
        
        ; This loops 4 times 
        ; effectively drawing a 64x64 tile block
        LDA $0C : CMP.w #$0008 : BNE .nextQuadrant
        
        RTS
    }

; ==============================================================================

    ; *$8A44-$8A88 LOCAL
    {
        ; $0A = how many times to perform this routine's goal
        ; The routine draws a 32x32 pixel block from right to left
        ; and then from up to down. e.g. if $0A = 2 it will draw
        ; 2 32x32 pixels blocks from left to right, if one were to start
        ; in the upper left corner
        
        STA $0A
    
    .next_block
    
        LDA.w #$0002 : STA $04
    
    .nextRow

        ; These first four writes draw a 8 x 32 pixel block
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        LDA $9B58, X : STA [$C8], Y
        
        ; These next four draw another 8 x 32 pixel block directly below The first tiles.
        ; Thus all in all it draws a 16 x 32 pixel block.
        LDA $9B5A, X : STA [$CB], Y
        LDA $9B5C, X : STA [$CE], Y
        LDA $9B5E, X : STA [$D1], Y
        LDA $9B60, X : STA [$D4], Y
        
        ; Add enough to draw another 16 x 32 directly below the first.
        TYA : ADD.w #$0100 : TAY
        
        ; Loops once, which produces a 32 x 32 pixel region in the tilemap.
        ; So this whole loop in effect makes a 4 x 4 tile block.
        DEC $04 : BNE .nextRow
        
        ; Places the next 4 x 4 tile block directly to the right of the previous one. 
        TYA : SUB.w #$01F8 : TAY
        
        DEC $0A : BNE .next_block
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$8A89-$8A91 JUMP LOCATION
    {
        JSR Object_Size_1_to_15_or_26
        
        LDA.w #$0100
        
        JMP Object_Draw2x4s_VariableOffset
    }

; ==============================================================================

    ; *$8A92-$8AA3 JUMP LOCATION
    Object_Draw4x2s_AdvanceRight_from_1_to_15_or_26:
    {
        JSR Object_Size_1_to_15_or_26
        
        STX $0A ; Guessing this is the start of the tiles to draw.
    
    .next_block
    
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        LDX $0A
        
        DEC $B2 : BNE .next_block
    
    ; *$8AA3 ALTERNATE ENTRY POINT
    
        RTS
    }

; ==============================================================================

    ; *$8AA4-$8B0C JUMP LOCATION
    {
        ; swap X and Y (destroying A)
        TXA : TYX : TAY
        
        JSR Object_Size1to16
    
    .nextRow
    
        LDA $9B52, Y : STA $7E4000, X : STA $7E2000, X
        LDA $9B54, Y : STA $7E4002, X : STA $7E2002, X
        LDA $9B56, Y : STA $7E4004, X : STA $7E2004, X
        LDA $9B58, Y : STA $7E4006, X : STA $7E2006, X
        LDA $9B5A, Y : STA $7E4080, X : STA $7E2080, X
        LDA $9B5C, Y : STA $7E4082, X : STA $7E2082, X
        LDA $9B5E, Y : STA $7E4084, X : STA $7E2084, X
        LDA $9B60, Y : STA $7E4086, X : STA $7E2086, X
        
        TXA : ADD.w #$0100 : TAX
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$8B0D-$8B73 JUMP LOCATION
    Object_Draw4x2s_AdvanceRight_from_1_to_16_BothBgs:
    {
        ; Swap X and Y (destroying A)
        TXA : TYX : TAY
        
        JSR Object_Size1to16
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X : STA $7E2000, X
        LDA $9B54, Y : STA $7E4080, X : STA $7E2080, X
        LDA $9B56, Y : STA $7E4100, X : STA $7E2100, X
        LDA $9B58, Y : STA $7E4180, X : STA $7E2180, X
        LDA $9B5A, Y : STA $7E4002, X : STA $7E2002, X
        LDA $9B5C, Y : STA $7E4082, X : STA $7E2082, X
        LDA $9B5E, Y : STA $7E4102, X : STA $7E2102, X
        LDA $9B60, Y : STA $7E4182, X : STA $7E2182, X
        
        INX #4
        
        DEC $B2 : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$8B74-$8B78 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        BRA Object_Draw2x2sDownVariableOrFull.next_block
    }

; ==============================================================================

    ; *$8B79-$8B7D JUMP LOCATION
    {
        JSR Object_Size1to16
        
        BRA Object_Draw2x2s_AdvanceRight.next_block
    }

; ==============================================================================

    ; *$8B7E-$8B88 JUMP LOCATION
    Object_Draw2x2sDownVariableOrFull:
    {
        JSR Object_Size_1_to_15_or_32
    
    .next_block
    
        JSR Object_Draw2x2_AdvanceDown
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$8B89-$8B93 JUMP LOCATIONs
    Object_Draw2x2s_AdvanceRight:
    {
    
    .from_1_to_15_or_32
    
        ; 1 to 0x0F or 0x20 tiles wide
        JSR Object_Size_1_to_15_or_32
    
    .next_block
    
        JSR Object_Draw2x2
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$8B94-$8BDF JUMP LOCATION
    Object_DrawRectOf1x1s:
    {
        INC $B2
        INC $B4
    
    .nextRowOfBlocks
    
        LDA $B2 : STA $0A
    
    .nextColumnBlock
    
        LDA $9B52, X
        STA [$BF], Y : STA [$C2], Y
        STA [$C5], Y : STA [$C8], Y
        STA [$CB], Y : STA [$CE], Y
        STA [$D1], Y : STA [$D4], Y
        
        TYA : ADD.w #$0100 : TAY
        
        LDA $9B52, X
        STA [$BF], Y : STA [$C2], Y
        STA [$C5], Y : STA [$C8], Y
        STA [$CB], Y : STA [$CE], Y
        STA [$D1], Y : STA [$D4], Y
        
        TYA : SUB.w #$00F8 : TAY
        
        DEC $0A : BNE .nextColumnBlock
        
        LDA $08 : ADD.w #$0200 : STA $08 : TAY
        
        DEC $B4 : BNE .nextRowOfBlocks
        
        RTS
    }

; ==============================================================================

    ; *$8BE0-$8BF3 JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        ADC.w #$0080 : STA $08 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8BF4-$8C0D JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
        
        INC $B4
    
    .nextRow
    
        LDA $B4
        
        JSR $B2D0 ; $B2D0 IN ROM
        
        ADC.w #$0080 : STA $08 : TAY
        
        INC $B4
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8C0E-$8C21 JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        ADC.w #$0082 : STA $08 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8C22-$8C36 JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        SUB.w #$007E : STA $08 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8C37-$8C4E JUMP LOCATION
    {
        JSR Object_Size1to16
        
        STX $0A
    
    .next_block
    
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        TYA : ADD.w #$0008 : TAY
        
        LDX $0A
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

    ; *$8C4F-$8C57 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        LDA.w #$0300
        
        JMP Object_Draw2x4s.VariableOffset
    }

    ; *$8C58-$8C60 JUMP LOCATION
    {
        ; Sets minimum width to 7, maximum to 22
        LDA.w #$0007
        
        JSR Object_Size_N_to_N_plus_15
        
        ; In reality, the width will range from 6 to 21, because of preincrementing
        ; in this destination
        JMP $B2AA ; $B2AA IN ROM
    }

    ; *$8C61-$8C69 JUMP LOCATION
    {
        ; Sets minimum width to 7, maximum to 22
        LDA.w #$0007
        
        JSR Object_Size_N_to_N_plus_15
        
        ; In reality, the width will range from 6 to 21, because of preincrementing
        ; in this destination
        JMP $B29C ; $B29C IN ROM
    }

    ; *$8C6A-$8CB8 JUMP LOCATION
    {
        ; Swap X and Y, destroying A
        TXA : TYX : TAY
        
        LDA.w #$0006
        
        JSR Object_Size_N_to_N_plus_15
        
        LDA.w #$FF82
    
    BRANCH_$8C76:
    
        STA $0E
    
    BRANCH_ALPHA:
    
        LDA $9B52, Y : STA $7E4000, X : STA $7E2000, X
        LDA $9B54, Y : STA $7E4080, X : STA $7E2080, X
        LDA $9B56, Y : STA $7E4100, X : STA $7E2100, X
        LDA $9B58, Y : STA $7E4180, X : STA $7E2180, X
        LDA $9B5A, Y : STA $7E4200, X : STA $7E2200, X
        
        TXA : ADD $0E : TAX
        
        DEC $B2 : BNE BRANCH_ALPHA
        
        RTS
    }

    ; *$8CB9-$8CC6 JUMP LOCATION
    {
        ; Swap X and Y, destroying A
        TXA : TYX : TAY
        
        LDA.w #$0006
        
        JSR Object_Size_N_to_N_plus_15
        
        LDA.w #$0082
        
        BRA BRANCH_$8C76
    }

    ; *$8CC7-$8D46 JUMP LOCATION
    {
        LDA $B2 : ADD.w #$0004 : STA $B2 : STA $0A
        
        INC $B4
        
        JSR $8D47 ; $8D47 IN ROM
        
        STX $0006
        
        LDA $08 : STA $04
        
        ADD.w #$0180 : STA $08
        
        LDA $B4 : STA $0E
    
    .nextMiddleBlockRow
    
        LDA $B2 : STA $0A
        
        LDY $08
        LDX $06
        
        JSR Object_Draw2x3
        
        TXA : ADD.w #$000C : TAX
        
        TYA : ADD.w #$0006 : TAY
    
    .nextMiddleBlock
    
        JSR Object_Draw2x2
        
        DEC $0A : BNE .nextMiddleBlock
        
        TXA : ADD.w #$0008 : TAX
        
        JSR Object_Draw2x3
        
        LDA $08 : ADD.w #$0100 : STA $08
        
        DEC $0E : BNE .nextMiddleBlockRow
        
        TXA : ADD.w #$000C : TAX
        
        LDY $08
        
        LDA $B2 : STA $0A
        
        JSR $8D47 ; $8D47 IN ROM
        
        LDA.w #$FF80
    
    .locateVerticalMidpoint
    
        SUB.w #$0080
        
        DEC $B4 : BNE .locateVerticalMidpoint
        
        ADD $08
        
        INC $B2 : INC $B2
        
        ASL $B2 : ADD $B2 : TAY
        
        LDX.w #$0590
        
        JMP Object_Draw2x2
    }

    ; *$8D47-$8D5C LOCAL
    {
        JSR $9216 ; $9216 IN ROM
    
    .next_block
    
        LDA.w #$0002
        
        JSR Object_Draw3xN
        
        TXA : SUB.w #$000C : TAX
        
        DEC $0A : BNE .next_block
        
        JMP $9211 ; $9211 IN ROM
    }

    ; *$8D5D-$8D7F JUMP LOCATION
    {
        ; Widths range in { 0x01, 0x03, 0x05, ..., 0x1D, 0x1F }
        LDA $B2 : ASL #2 : ORA $B4 : ASL A : INC A : STA $B2
        
        LDA.w #$0002
        
        JSR Object_Draw3xN
    
    .next_two_columns
    
        TXA : SUB.w #$0006 : TAX
        
        LDA.w #$0001
        
        JSR Object_Draw3xN
        
        DEC $B2 : BNE .next_two_columns
        
        LDA.w #$0001
        
        ; (this routine segues into Object_Draw3xN)
    }
    
    ; *$8D80-$8D9D LOCAL
    Object_Draw3xN:
    {
        STA $0E
    
    .next_column
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        
        TXA : ADD.w #$0006 : TAX
        
        INY #2
        
        DEC $0E : BNE .next_column
        
        RTS
    }

    ; *$8D9E-$8DDB JUMP LOCATION
    {
        INC $B2
        INC $B4
    
    .next_row_of_blocks
    
        LDA $B2 : STA $0A
    
    .next_block_to_the_right
    
        LDA $9B52, X
        
        ; Draw a 2x3 block
        STA [$BF], Y : STA [$C2], Y : STA [$C5], Y
        STA [$CB], Y : STA [$CE], Y : STA [$D1], Y
        
        TYA : ADD.w #$0100 : TAY
        
        LDA $9B52, X : STA [$BF], Y : STA [$C2], Y : STA [$C5], Y
        
        TYA : SUB.w #$00FA : TAY
        
        DEC $0A : BNE .next_block_to_the_right
        
        LDA $08 : ADD.w #$0180 : STA $08 : TAY
        
        DEC $B4 : BNE .next_row_of_blocks
        
        RTS
    }

; ==============================================================================

    ; *$8DDC-$8E66 JUMP LOCATION
    Object_Hole:
    {
        ; Variable Size Hole object
        ; Type 1 Subtype 1 Index 0xA4
        
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
        
        STA $B4 : STA $0E
        
        PHY
    
    ; This loop draws the transparent portion
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        STA $0C
        
        ADC.w #$0080 : STA $08 : TAY
        
        DEC $0E : BNE .nextRow
       
        ; Start back at the top   
        PLY : STY $08
        
        LDA.w #$0002 : STA $0E
        
        LDX.w #$063C
    
    .repeatOnBottomRow
    
        LDA $B2 : DEC #2 : STA $0A
        
        LDA $9B52, X : STA [$BF], Y
        
        LDA $9B54, X
    
    .nextColumn
    
        STA [$C2], Y
        
        INY #2
        
        DEC $0A : BNE .nextColumn
        
        LDA $9B56, X : STA [$C2], Y
        
        TXA : ADD.w #$0006 : TAX
        
        LDY $0C
        
        DEC $0E : BNE .repeatOnBottomRow
        
        LDA $08 : ADD.w #$0080
        
        LDY $B2 : DEY : STY $B4
        
        DEC $B4
    
    .findRightBoundary
    
        INC #2
        
        DEY : BNE .findRightBoundary
        
        STA $0C
        
        LDA.w #$0002 : STA $0E
        
        LDA $08 : ADD.w #$0080 : TAY
        
        LDX.w #$0648
    
    .repeatOnRightBoundary
    
        LDA $B4 : STA $0A
    
    .nextRow2
    
        LDA $9B52, X : STA [$BF], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0A : BNE .nextRow2
        
        INX #2
        
        LDY $0C
        
        DEC $0E : BNE .repeatOnRightBoundary
        
        RTS
    }

; ==============================================================================

    ; *$8E67-$8E7A JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        ADC.w #$0080 : STA $08 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8E7B-$8E94 JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
        
        INC $B4
    
    .nextRow
    
        LDA $B4
        
        JSR $B2D0 ; $B2D0 IN ROM
        
        ADC.w #$0080 : STA $08 : TAY
        
        INC $B4
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8E95-$8EA8 JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        ADC.w #$0082 : STA $08 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8EA9-$8EBD JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        JSR $B2CE ; $B2CE IN ROM
        
        SUB.w #$007E : STA $08 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8EBE-$8EEA JUMP LOCATION
    {
        LDA.w #$0015
        
        BRA .setSize
    
    ; *$8EC3 ALTERNATE ENTRY POINT
    
        LDA.w #$0002
    
    .setSize
    
        JSR Object_Size_N_to_N_plus_15
        
        LDA.w #$00E3
        
        ; $B191 IN ROM
        JSR $B191 : BCC .dontOverwrite
        
        LDA $9B52, X : STA [$BF], Y
    
    .dontOverwrite
    .nextTile
    
        TYA : ADD.w #$0080 : TAY
        
        LDA $9B54, X : STA [$BF], Y
        
        DEC $B2 : BNE .nextTile
        
        LDA $9B56, X : STA [$CB], Y
        
        RTS
    }

    ; *$8EEB-$8F0B JUMP LOCATION
    Object_HorizontalRail:
    {
    
    .long
    
        LDA.w #$0015
        
        BRA .setWidth
    
    ; *$8EF0 ALTERNATE ENTRY POINT
    .short
    
        LDA.w #$0002 ; There's a minimum of two segments
    
    .setWidth
    
        JSR Object_Size_N_to_N_plus_15
        
        LDA.w #$00E2
        
        ; $B191 IN ROM
        JSR $B191 : BCC .beta
        
        ; If the current tile CHR is not equal to 0x00E2, draw this tile.
        LDA $9B52, X : STA [$BF], Y
    
    .beta
    
        JSR $B2CA ; $B2CA IN ROM
        
        LDA $9B54, X : STA [$BF], Y
        
        RTS
    }

    ; *$8F0C-$8F35 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        JSR Object_Draw2x2_AdvanceDown
        
        TXA : ADD.w #$0008 : TAX
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .nextRow
        
        INX #4
    
    ; *$8F30 ALTERNATE ENTRY POINT
    Object_Draw3x2:
    
        LDA.w #$0002
        
        JMP Object_Draw3xN
    }

    ; *$8F36-$8F61 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        INC $B2
        
        LDA.w #$0002
        
        JSR Object_Draw3xN
    
    .alpha
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        
        INY #2
        
        DEC $B2 : BNE .alpha
        
        INX #6
        
        LDA.w #$0002
        
        JMP Object_Draw3xN
    }

    ; *$8F62-$8F89 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        LDA.w #$01DB
        
        ; $B191 IN ROM
        ; if(grabbed byte == 0x01DB)
        JSR $B191 : BCC BRANCH_ALPHA
        
        CMP.w #$01A6 : BEQ BRANCH_ALPHA
        CMP.w #$01DD : BEQ BRANCH_ALPHA
        CMP.w #$01FC : BEQ BRANCH_ALPHA
        
        LDA $9B52, X : STA [$BF], Y
    
    BRANCH_ALPHA:
    
        JSR $B2CA ; $B2CA IN ROM
        
        LDA $9B54, X : STA [$BF], Y
        
        RTS
    }

    ; *$8F8A-$8F9C JUMP LOCATION
    {
        JSR Object_Size1to16
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$8F9D-$8FA1 JUMP LOCATION
    {
        LDX $0490
        
        BRA BRANCH_$8FA5
    }

    ; *$8FA2-$8FBB JUMP LOCATION
    {
        LDX $046A
    
    ; *$8FA5 ALTERNATE ENTRY POINT
    
        INC $B2
        INC $B4
    
    .next_block
    
        LDA $B2
        
        JSR $8A44   ; $8A44 IN ROM
        
        LDA $08 : ADD.w #$0200 : STA $08 : TAY
        
        DEC $B4 : BNE .next_block
        
        RTS
    }

    ; *$8FBC-$8FBC JUMP LOCATION
    {
        RTS
    }

    ; *$8FBD-$9000 JUMP LOCATION
    {
        LDA.w #$000A
        
        JSR Object_Size_N_to_N_plus_15
        
        LDA $9B52, X : STA $0E
        
        INX #2
        
        LDA [$BF], Y : AND.w #$03FF : CMP.w #$00E2 : BEQ .dontOverwrite
        
        JSR .draw_2x2_at_endpoint
    
    .dontOverwrite
    
        INX #4
    
    .nextColumn
    
        LDA $9B52, X : STA [$BF], Y
        
        LDA $0E : STA [$CB], Y
        
        INY #2
        
        DEC $B2 : BNE .nextColumn
        
        INX #2
    
    .draw_2x2_at_endpoint
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        
        LDA $0E : STA [$CB], Y : STA [$CE], Y
        
        INY #4
        
        RTS
    }

    ; *$9001-$9044 JUMP LOCATION
    {
        LDA.w #$000A
        
        JSR Object_Size_N_to_N_plus_15
        
        LDA $9B52, X : STA $0E
        
        INX #2
        
        LDA [$CB], Y : AND.w #$03FF : CMP.w #$00E2 : BEQ .dontOverwrite
        
        JSR .draw_2x2_at_endpoint
    
    .dontOverwrite
    
        INX #4
    
    .nextColumn
    
        LDA $0E      : STA [$BF], Y
        LDA $9B52, X : STA [$CB], Y
        
        INY #2
        
        DEC $B2 : BNE .nextColumn
        
        INY #2
    
    .draw_2x2_at_endpoint
    
        LDA $0E      : STA [$BF], Y
                       STA [$C2], Y
        LDA $9B52, X : STA [$CB], Y
        LDA $9B54, X : STA [$CE], Y
        
        INY #4
        
        RTS
    }

    ; *$9045-$908E JUMP LOCATION
    {
        LDA.w #$000A
        
        JSR Object_Size_N_to_N_plus_15
        
        LDA $9B52, X : STA $0E
        
        INX #2
        
        LDA [$BF], Y : AND.w #$03FF : CMP.w #$00E3 : BEQ BRANCH_ALPHA
        
        JSR .draw_2x2_at_endpoint
    
    BRANCH_ALPHA:
    
        INX #4
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $0E      : STA [$C2], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .nextRow
        
        INX #2
    
    .draw_2x2_at_endpoint
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        
        LDA $0E : STA [$C2], Y
                  STA [$CE], Y
        
        TYA : ADD.w #$0100 : TAY
        
        RTS
    }

    ; *$908F-$90D8 JUMP LOCATION
    {
        LDA.w #$000A
        
        JSR Object_Size_N_to_N_plus_15
        
        LDA $9B52, X : STA $0E
        
        INX #2
        
        LDA [$C2], Y : AND.w #$03FF : CMP.w #$00E3 : BEQ .dontOverwrite
        
        JSR .draw_2x2_at_endpoint
    
    .dontOverwrite
    
        INX #4
    
    .nextRow
    
        LDA $0E      : STA [$BF], Y
        LDA $9B52, X : STA [$C2], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .nextRow
        
        INX #2
    
    .draw_2x2_at_endpoint
    
        LDA $0E : STA [$BF], Y : STA [$CB], Y
        
        LDA $9B52, X : STA [$C2], Y
        LDA $9B54, X : STA [$CE], Y
        
        TYA : ADD.w #$0100 : TAY
        
        RTS
    }

    ; *$90D9-$90E1 JUMP LOCATION
    {
        LDA.w #$0008
        
        JSR Object_Size_N_to_N_plus_15
        
        JMP $B2CE ; $B2CE IN ROM
    }

    ; *$90E2-$90F7 JUMP LOCATION
    {
        LDA.w #$0008
        
        JSR Object_Size_N_to_N_plus_15
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

    ; *$90F8-$90F8 JUMP LOCATION
    {
        RTS
    }

    ; *$90F9-$9110 JUMP LOCATION
    {
        STX $0A
        
        JSR Object_Size1to16
    
    .next_block
    
        LDX $0A
        
        JSR Object_Draw4x4
        
        LDA $08 : ADD.w #$0200 : STA $08 : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

    ; *$9111-$911F JUMP LOCATION
    {
        STX $0A
        
        JSR Object_Size1to16
    
    .loop
    
        LDX $0A
        
        JSR Object_Draw4x4
        
        DEC $B2 : BNE .loop
        
        RTS
    }

    ; *$9120-$9135 JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
    
    .loop
    
        LDA $9B52, X : STA [$BF], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .loop
        
        RTS
    }

    ; *$9136-$913E JUMP LOCATION
    {
        LDA.w #$0004
        
        JSR Object_Size_N_to_N_plus_15
        JMP $B2CE ; $B2CE IN ROM
    }

    ; *$913F-$918E JUMP LOCATION
    {
        ; 1.1.0x35
        ; This object seems to do something, but it shows
        ; up in no room in the rom! (to my knowledge)
        ; however, it seems to utilize code used by doors....
        ; seems like it might have something to do with Agahnim's curtains,
        ; but it's a long shot.
        
        STY $04B0
        
        ; Check to see which BG we�re on.
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        ; Using BG1 so use an address that indexes into its wram tilemap
        TYA : ORA.w #$2000 : STA $04B0 : TAY
    
    .onBG2
    
        ; Check if a flag in the room information is set.
        ; Branch if a chest has been opened in this room?.... strange
        ; Probably doesn't mean that.
        LDA $0402 : AND.w #$1000 : BEQ .eventHasntOccurred
        
        STY $08
        
        ; Note the two consecutive loads for the Y register here
        ; (double checked). This strongly suggests that the code for and
        ; related to this object was not finished. We may be able to commandeer
        ; it later, though.
        LDY.w #$0052
        LDY $08
        
        LDA.w #$0003 : STA $0E
        
        ; Draw a 4x3 region of tiles
        JSR $AC1A ; $AC1A IN ROM
        
        ; This load of Y is also ignored
        LDY.w #$0052
        
        LDA $08 : ADD.w #$000A
        
        LDY $BF : CPY.w #$4000 : BNE .onBG2_2
        
        ADD.w #$0004
    
    .onBG2_2
    
        ; Again note that the above code is clearly nonsensical
        ; Why go to all the trouble of implementing logic to set a value for A
        ; And then just overwrite it with 0x0003 on this line.
        LDA.w #$0003 : STA $0E
        
        ; I'm fairly certain that his is overwriting the 4x3 region
        ; we drew earlier... wtf?
        JSR $AB78 ; $AB78 IN ROM
        
        RTS
    
    .eventHasntOccurred
    
        LDA.b $04B0 : ORA #$8000 : STA $04B0
        
        RTS
    }

    ; *$918F-$918F JUMP LOCATION
    {
        ; undefined objects (1.1.0xCB, 1.1.0xCC)
        RTS
    }

    ; *$9190-$921B JUMP LOCATION
    Object_HiddenWallRight:
    {
        ; hidden wall (facing right)
        
        ; $9298 IN ROM
        JSR $9298 : BCS .drawWall
        
        RTS
    
    .drawWall
    
        ; Increment the collision variable as a way of notifying the game
        ; that we should additionally check for collision with BG1, even if
        ; Link is on BG2.
        INC $0428
        
        LDA $B2 : ASL A : TAY
        
        LDA $9B0A, Y : PHA
        
        ASL A : ADC.w #$0004 : STA $0E
        
        LDA $B4 : ASL A : STA $041E : TAY
        
        LDA $9B12, Y : STA $0C : TAY
        
        LDA $08
    
    BRANCH_BETA:
    
        DEC #2
        
        DEY : BNE BRANCH_BETA
        
        PHA : STA $06
        
        LDX.w #$03D8
    
    BRANCH_DELTA:
    
        LDA $0E : STA $0A
        
        LDY $06
        
        LDA $9B52, X : STA [$BF], Y

    BRANCH_GAMMA:

        LDA $9B54, X : STA [$CB], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0A : BNE BRANCH_GAMMA
        
        LDA $9B56, X : STA [$CB], Y
        
        INC $06 : INC $06
        
        DEC $0C : BNE BRANCH_DELTA
        
        PLA : DEC #2 : STA $06 : TAY
        
        JSR $92D1 ; $92D1 IN ROM 
        
        LDY $08
        
        LDX.w #$072A
        
        JSR $9216 ; $9216 IN ROM
        
        PLA : STA $0E
        
        LDA $08 : ADD.w #$0180 : TAY
    
    BRANCH_EPSILON:
    
        JSR Object_Draw2x3
        
        TYA : ADD.w #$0100 : TAY
        
        DEC $0E : BNE BRANCH_EPSILON
    
    ; *$9210 ALTERNATE ENTRY POINT
    
        TXA
    
    ; *$9211 ALTERNATE ENTRY POINT
    
        ADD.w #$000C : TAX
    
    ; *$9216 ALTERNATE ENTRY POINT
    
        LDA.w #$0003
        
        JMP Object_Draw3xN
    }

    ; *$921C-$9297 JUMP LOCATION
    Object_HiddenWallLeft:
    {
        ; Hidden wall (facing left)
        
        ; $9298 IN ROM
        JSR $9298 : BCS .drawWall
        
        RTS
    
    .drawWall
    
        INC $0428
        
        LDY $08
        
        LDX.w #$075A
        
        JSR $9216 ; $9216 IN ROM
        
        LDA $B2 : ASL A : TAY
        
        LDA $9B0A, Y : STA $0E : PHA
        
        LDA $08 : ADD.w #$0180 : TAY
    
    BRANCH_BETA:
    
        JSR Object_Draw2x3
        
        TYA : ADD.w #$0100 : TAY
        
        DEC $0E : BNE BRANCH_BETA
        
        JSR $9210 ; $9210 IN ROM
        
        PLA : ASL A : ADC.w #$0004 : STA $0E
        
        LDA $B4 : ASL A : STA $041E : TAY
        
        LDA $9B12, Y : STA $0C
        
        LDA $08 : ADD.w #$0006 : STA $06
        
        LDX.w #$03D8
    
    BRANCH_DELTA:
    
        LDA $0E : STA $0A
        
        LDY $06
        
        LDA $9B52, X : STA [$BF], Y
    
    BRANCH_GAMMA:
    
        LDA $9B54, X : STA [$CB], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0A : BNE BRANCH_GAMMA
        
        LDA $9B56, X : STA [$CB], Y
        
        INC $06 : INC $06
        
        DEC $0C : BNE BRANCH_DELTA
        
        LDY $06
        
        JMP $92D1 ; $92D1 IN ROM
    }

; ==============================================================================

    ; *$9298-$92D0 JUMP LOCATION
    {
        ; objects (1.1.0xD3, 1.1.0xD4, 1.1.0xD5, 1.1.0xD6)
        
        STZ $041C
        STZ $041A
        
        SEP #$30
        
        LDX.b #$00 : TXY
        
        LDA $AE
        
        CMP.b #$1C : BCC .tryScript2
        CMP.b #$20 : BCC .isHiddenWallScript
    
    .tryScript2
    
        LDY.b #$02
        
        INX
        
        ; Load the Tag2 (other properties 2) setting for the room.
        LDA $AF
        
        CMP.b #$1C : BCC .notHiddenWallScript
        CMP.b #$20 : BCS .notHiddenWallScript
    
    .ishiddenWallScript
    
        LDA $0403 : AND $98C7, Y : BEQ .notYetTriggered
        
        STZ $046C
        STZ $AE, X
        STZ $0414
        
        ; Note that this has an implicit "CLC" instruction embedded in it.
        REP #$31
        
        RTS
    
    .notYetTriggered
    .notHiddenWallScript
    
        REP #$30
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; *$92D1-$92FA JUMP LOCATION
    {
        LDX.w #$007E
        LDA.w #$01EC
    
    .fill_with_value
    
        STA $7EC880, X
        
        DEX #2 : BPL .fill_with_value
        
        LDA $06 : AND.w #$003F : LSR A : STA $0A
        
        TYA : AND.w #$0040 : BEQ BRANCH_BETA
        
        LDA.w #$0400 : TSB $0A
    
    BRANCH_BETA:
    
        LDA $0A : ORA #$1000 : STA $042A
        
        RTS
    }

; ==============================================================================

    ; *$92FB-$930D JUMP LOCATION
    {
        JSR Object_Size1to16
        
        STX $0A
    
    .next_block_to_right
    
        LDX $0A
        
        JSR Object_Draw4x4
        
        INY #4
        
        DEC $B2 : BNE .next_block_to_right
        
        RTS
    }

; ==============================================================================

    ; *$930E-$9322 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        STX $0A
    
    .next_block
    
        LDX $0A
        
        JSR Object_Draw4x4
        
        TYA : ADD.w #$02F8 : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$9323-$9337 JUMP LOCATION
    {
        JSR Object_Size1to16
    
    .nextTwoColumns
    
        LDX.w #$0E26
        
        LDA.w #$0002
        
        JSR Object_Draw3xN
        
        INY #4
        
        DEC $B2 : BNE .nextTwoColumns
        
        RTS
    }

; ==============================================================================

    ; *$9338-$9346 JUMP LOCATION
    {
        JSR Object_Size1to16
    
    BRANCH_ALPHA:
    
        JSR Object_Draw2x2
        
        INY #4
        
        DEC $B2 : BNE BRANCH_ALPHA
        
        RTS
    }

; ==============================================================================

    ; *$9347-$9356 JUMP LOCATION
    {
        JSR Object_Size1to16
    
    .next_block
    
        JSR Object_Draw2x2_AdvanceDown
        
        ADD.w #$0100 : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$9357-$936E JUMP LOCATION
    {
        JSR Object_Size1to16
        
        STX $0C
    
    .next_block
    
        LDX $0C
        
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        TYA : ADD.w #$02FC : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$936F-$9386 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        STX $0C
    
    .loop
    
        LDA $0C
        
        ; two consecutive loads of A? huh...
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        TYA : ADD.w #$0008 : TAY
        
        DEC $B2 : BNE .loop
        
        RTS
    }

; ==============================================================================

    ; *$9387-$939E JUMP LOCATION
    {
        STA $0A
        
        JSR Object_Size1to16
    
    .nextFourColumns
    
        LDX $0A
        
        LDA.w #$0004
        
        JSR Object_Draw3xN
        
        TYA : ADD.w #$0008 : TAY
        
        DEC $B2 : BNE .nextFourColumns
        
        RTS
    }

; ==============================================================================

    ; *$939F-$93B6 JUMP LOCATION
    {
        STX $0A
        
        JSR Object_Size1to16
    
    .next_block
    
        LDX $0A
        
        LDA.w #$0003
        
        JSR Object_Draw4xN
        
        TYA : ADD.w #$03FA : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$93B7-$93DB JUMP LOCATION
    {
        JSR Object_Size1to16
    
    BRANCH_ALPHA:
    
        LDX.w #$08CA
        
        JSR Object_Draw2x2_AdvanceDown
        
        ADD.w #$0200 : TAY
        
        ; since this is a known quantity, why calculate it? (Hint: it's 0x08D2)
        TXA : ADD.w #$0008 : TAX
        
        JSR Object_Draw2x2_AdvanceDown
        
        LDA $08 : ADD.w #$0008 : STA $08 : TAY
        
        DEC $B2 : BNE BRANCH_ALPHA
        
        RTS
    }

; ==============================================================================

    ; *$93DC-$9428 JUMP LOCATION
    {
        ; = 1 to 4
        INC $B2
        
        ; = 1 to 7
        ASL $B4 : INC $B4
        
        JSR $93FF ; $93FF IN ROM
        
        INX #8
    
    BRANCH_ALPHA:
    
        JSR $93FF ; $93FF IN ROM
        
        DEC $B4 : BNE BRANCH_ALPHA
        
        JSR $93F7 ; $93F7 IN ROM
    
    ; *$93F7 ALTERNATE ENTRY POINT
    
        INX #8
    
    ; *$93FF ALTERNATE ENTRY POINT
    
        LDA $B2 : STA $0E
        
        LDA $9B52, X : STA [$BF], Y
    
    BRANCH_BETA:
    
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        
        INY #4
        
        DEC $0E : BNE BRANCH_BETA
        
        LDA $9B58, X : STA [$C2], Y
        
        LDA $08 : ADD.w #$0080 : STA $08 : TAY
        
        RTS
    }

; ==============================================================================

    ; *$9429-$9445 JUMP LOCATION
    {
        ; Width = 1 to 4
        INC $B2
        
        ; Height = 1 to 4
        INC $B4
    
    .next_row
    
        LDA $B2 : STA $0E
    
    .next_block_right
    
        JSR Object_Draw2x2
        
        DEC $0E : BNE .next_block_right
        
        LDA $08 : ADD.w #$0100 : STA $08 : TAY
        
        DEC $B4 : BNE .next_row
        
        RTS
    }

; ==============================================================================

    ; *$9446-$9455 JUMP LOCATION
    {
        JSR Object_Size1to16
    
    .next_piece
    
        JSR Object_Draw2x2_AdvanceDown
        
        ADD.w #$0600 : TAY
        
        DEC $B2 : BNE .next_piece
        
        RTS
    }

; ==============================================================================

    ; *$9456-$9465 JUMP LOCATION
    {
        JSR Object_Size1to16
    
    .loop
    
        JSR Object_Draw2x2_AdvanceDown
        
        ADD.w #$FF1C : TAY
        
        DEC $B2 : BNE .loop
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; *$9466-$9487 JUMP LOCATION
    {
        ; This is another unused object in the rom
        ; However it is visually something
        ; It's a thin waterfall for indoors!
        
        JSR Object_Size1to16
        
        ASL $B2
        
        JSR Object_Draw5x1
        
        TXA : ADD.w #$000A : TAX
        
        INY #2
    
    .nextColumn
    
        JSR Object_Draw5x1
        
        INY #2
        
        DEC $B2 : BNE .nextColumn
        
        TXA : ADD.w #$000A : TAX
        
        JMP Object_Draw5x1
    }

; ==============================================================================

    ; *$9488-$94B3 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        ASL $B2
        
        LDA.w #$0001
        
        JSR Object_Draw3xN
    
    .nextColumn
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        
        INY #2
        
        DEC $B2 : BNE .nextColumn
        
        INX #6
        
        LDA.w #$0001
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$94B4-$94BC JUMP LOCATION
    {
        JSR Object_Size1to16
        
        LDA.w #$0008
        
        JMP Object_Draw2x4s_VariableOffset
    }

; ==============================================================================

    ; *$94BD-$94DE JUMP LOCATION
    {
        JSR Object_Size1to16
        
        ASL $B2
        
        JSR Object_Draw3x1
        
        INY #2
        
        TXA : ADD.w #$0006 : TAX
    
    .loop
    
        JSR Object_Draw3x1
        
        INY #2
        
        DEC $B2 : BNE .loop
        
        TXA : ADD.w #$0006 : TAX
        
        JMP Object_Draw3x1
    }

; ==============================================================================

    ; *$94DF-$9500 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        LDA.w #$0001
        
        JSR Object_Draw4xN
    
    .alpha
    
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        TXA : SUB.w #$0010 : TAX
        
        DEC $B2 : BNE .alpha
        
        TXA : ADD.w #$0010 : TAX
        
        JMP Object_Draw4x1
    }

; ==============================================================================

    ; *$9501-$95EE JUMP LOCATION
    Object_Water:
    {
        LDA $B2 : ASL A : TAX
        
        LDA $9B3A, X : STA $B2
        
        LDA $9B42, X : STA $0686
        
        LDA $B4 : ASL A : TAX
        
        LDA $9B3A, X : STA $B4
        
        ; Looks like all these $06xx addreses are calculated for hdma of the 
        ; water (for rooms that have a script for that)
        LDA $9B42, X  : STA $0684
        SUB.w #$0018 : STA $0688
        
        TYA : AND.w #$007E : ASL #2 : STA $0680
        
        LDA $B2 : ASL #4 : ADD $062C : ADD $0680 : STA $0680
        
        TYA : AND.w #$1F80 : LSR #4 : STA $0682
        
        LDA $B4 : ASL #4 : ADD $062E : ADD $0682 : STA $0682
        
        SEP #$30
        
        ; (AND with 0x08)
        LDA $0403 : AND $98C9 : BEQ .notTriggered
        
        STZ $AF
        STZ $0414
        
        REP #$30
        
        LDA $0442 : STA $0440
        LDA $0444 : STA $0448
        
        STZ $0444
        STZ $0442
        
        LDA $04AE : STA $049E
        
        STZ $04AE
        
        LDA $B2 : DEC A : ASL #2 : STA $0E
        
        LDA $08 : ADC $0E : STA $08
        
        LDA $B4 : DEC A : XBA : STA $0E
        
        LDA $08 : ADC $0E : TAX
    
    ; *$95A0 ALTERNATE ENTRY POINT
    
        LDY.w #$1438
        
        LDA.w #$0004 : STA $0E
    
    .loop
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2002, X
        LDA $9B56, Y : STA $7E2004, X
        LDA $9B58, Y : STA $7E2006, X
        
        TYA : ADD.w #$0008 : TAY
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .loop
        
        RTS
    
    .notTriggered
    
        REP #$30
        
        LDX.w #$0110
        
        LDY $08
    
    .loop2
    
        LDA $B2
        
        JSR $8A44 ; $8A44 IN ROM
        
        LDA $08 : ADD.w #$0200 : STA $08 : TAY
        
        DEC $B4 : BNE .loop2
        
        RTS
    }

; ==============================================================================

    ; *$95EF-$96DB JUMP LOCATION
    {
        LDA $B2 : ASL A : TAX
        
        ; Use the initial height to index into a table to get the actual height.
        LDA $9B3A, X : STA $B2
        
        LDA $9B42, X : SUB.w #$0018 : STA $0686
        
        LDA $B4 : ASL A : TAX
        
        LDA $9B3A, X : STA $B4
        
        LDA $9B42, X : SUB.w #$0008 : STA $0688
        
        SUB.w #$0018 : STA $0684
        
        STZ $068A
        
        TYA : AND.w #$007E : ASL #2 : STA $0680
        
        LDA $B2 : ASL #4 : ADD $062C : ADD $0680 : STA $0680
        
        TYA : ADD.w #$1F80 : LSR #4 : STA $0682
        
        LDA $B4 : ASL #4 : ADD $062E : ADD $0682 : SUB.w #$0008 : STA $0682
        
        SEP #$30
        
        LDA $0403 : AND $98C9 : BEQ .alpha
        
        STZ $AF
        
        BRA BRANCH_BETA
    
    .alpha
    
        REP #$30
        
        LDA $0442 : STA $0440
        LDA $0444 : STA $0448
        
        STZ $0444 : STZ $0442
        
        LDA $04AE : STA $049E
        
        STZ $04AE
        
        STZ $0414
    
    BRANCH_BETA:
    
        REP #$30
        
        LDA $B4 : ASL A : TAX
        
        LDA $9B46, X : STA $04
        
        LDX.w #$0110
    
    BRANCH_DELTA:
    
        LDY $08
        
        LDA $B2 : STA $0A
    
    BRANCH_GAMMA:
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        LDA $9B58, X : STA [$C8], Y
        LDA $9B5A, X : STA [$CB], Y
        LDA $9B5C, X : STA [$CE], Y
        LDA $9B5E, X : STA [$D1], Y
        LDA $9B60, X : STA [$D4], Y
        
        INY #8
        
        DEC $0A : BNE BRANCH_GAMMA
        
        LDA $08 : ADD.w #$0100 : STA $08
        
        DEC $04 : BNE BRANCH_DELTA
        
        RTS
    }

; ==============================================================================

    ; *$96DC-$96E3 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        INC $B2
        
        JMP $B2CE ; $B2CE IN ROM
    }

; ==============================================================================

    ; *$96E4-$96F8 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        INC $B2
    
    .next_block
    
        LDA $95B2, X : STA [$BF], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$96F9-$9701 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        LDA.w #$0018
        
        JMP Object_Draw2x4s_VariableOffset
    }

; ==============================================================================

    ; *$9702-$9719 JUMP LOCATION
    {
        STX $0A
        
        JSR Object_Size1to16
    
    .next_block
    
        LDX $0A
        
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        ; make next block 10 tiles down?
        TYA : ADD.w #$05FC : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$971A-$971A JUMP LOCATION
    {
        RTS
    }

; ==============================================================================

    ; *$971B-$9732 JUMP LOCATION
    {
        STX $0A
        
        JSR Object_Size1to16
    
    .next_block
    
        LDX $0A
        
        LDA.w #$0003
        
        JSR Object_Draw4xN
        
        ; make next block 5 tiles down?
        TYA : ADD.w #$02FA : TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$9733-$97B4 JUMP LOCATION
    {
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$2000 : TAY
    
    .onBg2
    
        TYX ; X now holds the tilemap address
        
        LDY.w #$0AB4
        
        INC $B2
        
        ; $B4 = ($B4 * 2) + 5
        LDA $B4 : ASL A : ADD.w #$0005 : STA $B4
    
    BRANCH_DELTA
    
        JSR $975C ; $975C IN ROM
        
        DEC $B4 : BNE BRANCH_DELTA
        
        INY #2
        
        JSR $975C ; $975C IN ROM
        
        INY #2
    
    ; *$975C ALTERNATE ENTRY POINT
    
        PHX
        
        LDA $B2 : STA $0A
        
        LDA $9B52, Y : STA $7E2000, X
        
        LDA $9B58, Y
    
    BRANCH_BETA:
    
        STA $7E2002, X
        
        INX #2
        
        DEC $0A : BNE BRANCH_BETA
        
        LDA $9B5E, Y : STA $7E2002, X
        
        LDA $9B64, Y : STA $7E2004, X : STA $7E2006, X : STA $7E2008, X : STA $7E200A, X
        
        LDA $B2 : STA $0A
        
        LDA $9B6A, Y : STA $7E200C, X
        
        LDA $9B70, Y
    
    BRANCH_GAMMA:
    
        STA $7E200E, X
        
        INX #2
        
        DEC $0A : BNE BRANCH_GAMMA
        
        LDA $9B76, Y : STA $7E200E, X
        
        PLA : ADD.w #$0080 : TAX
        
        RTS
    }

; ==============================================================================

    ; *$97B5-$97DB JUMP LOCATION
    {
        LDA.w #$0002
        
        JSR Object_Size_N_to_N_plus_15
        
        ASL $B2
        
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
    
    .nextRow
    
        LDA $9B56, X : STA [$CB], Y
        LDA $9B58, X : STA [$CE], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $B2 : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$97DC-$97EC JUMP LOCATION
    {
        JSR Object_Size1to16
    
    .next_block
    
        LDX.w #$0B16
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$97ED-$9812 JUMP LOCATION
    Object_Draw4x4:
    {
        LDA.w #$0004
        
    } ; nb: routine doesn't end here
    ; *$97F0 ALTERNATE ENTRY POINT
    Object_Draw4xN:
    {
        STA $0E
    
    .nextColumn
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        LDA $9B58, X : STA [$DA], Y
        
        TXA : ADD.w #$0008 : TAX
        
        INY #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$9813-$985B JUMP LOCATION
    Object_Draw4x4_BothBgs:
    {
        TXA : TYX : TAY
        
        LDA.w #$0004
    
    .variableNumberOfColumns
    
        STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X : STA $7E2000, X
        LDA $9B54, Y : STA $7E4080, X : STA $7E2080, X
        LDA $9B56, Y : STA $7E4100, X : STA $7E2100, X
        LDA $9B58, Y : STA $7E4180, X : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }
    
    ; *$9854 ALTERNATE ENTRY POINT
    Object_Draw4x3_BothBgs:
    {
        TXA : TYX : TAY
        
        LDA.w #$0003
        
        BRA Object_Draw4x4_BothBgs_variableNumberOfColumns
    }

; ==============================================================================

    ; *$985C-$9891 JUMP LOCATION
    Object_Draw3x4_BothBgs:
    {
        ; Swap X and Y (destroying A)
        TXA : TYX : TAY
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X : STA $7E2000, X
        LDA $9B54, Y : STA $7E4080, X : STA $7E2080, X
        LDA $9B56, Y : STA $7E4100, X : STA $7E2100, X
        
        TYA : ADD.w #$0006 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$9892-$98AD JUMP LOCATION
    {
        ; Increment number of torches in room?
        INC $045A
        
        ; Segues into next routine.
    }
    
    ; *$9895 ALTERNATE ENTRY POINT
    Object_Draw2x2:
    {
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$C2], Y
        LDA $9B58, X : STA [$CE], Y
        
        INY #4
        
        RTS
    }

; ==============================================================================

    ; *$98AE-$98CF JUMP LOCATION
    Object_BigKeyLock:
    {
        ; Big Key Lock
        ; Type 1 Subtype 3 Index 0x18
        ; Concern: do these not work on BG0?
        
        LDX $0498
        
        TYA : STA $06E0, X
        
        LDA $0402 : AND $9900, X : BNE .alreadyOpened
        
        INX #2 : STX $0498
        
        LDX.w #$1494
        
        BRA Object_Draw2x2
    
    .alreadyOpened
    
        STZ $06E0, X
        
        INX #2 : STX $0498
    
    .easyOut
    
        RTS
    }

; ==============================================================================

    ; *$98D0-$99BA JUMP LOCATION
    Object_Chest:
    {
        ; Normal Chest Object ( Type 0x01.0x03.0x19 )
        
        ; Are we in the ending sequence?
        ; If so, don't bother with this shit.
        LDA $10 : AND.w #$00FF : CMP.w #$001A : BEQ Object_BigKeyLock.easyOut
        
        LDX $0496
        
        ; This is the chest's tile address shifted left by one.
        ; (The msb is set if it's a big chest.)
        TYA : STA $06E0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$2000 : STA $06E0, X
    
    .onBg2
    
        ; Check to see if the chest has already been opened.
        ; It's already been opened.
        LDA $0402 : AND $9900, X : BNE .alreadyOpened
        
        INX #2 : STX $0496 : STX $0498
        
        LDY.w #$FF00
        LDX.w #$0000
        
        ; Check the Tag1 Properties.
        LDA $AE : AND.w #$00FF
        
        CMP.w #$0027 : BEQ .hiddenChest
        CMP.w #$003C : BEQ .hiddenChest
        CMP.w #$003E : BEQ .hiddenChest
        CMP.w #$0029 : BCC .checkTag2
        CMP.w #$0033 : BCC .hiddenChest
    
    .checkTag2
    
        ; Load the tag2 properties
        LDA $AF : AND.w #$00FF
        
        CMP.w #$0027 : BEQ .hiddenChest2
        CMP.w #$003C : BEQ .hiddenChest2
        CMP.w #$003E : BEQ .hiddenChest2
        CMP.w #$0029 : BCC .notHiddenChest
        CMP.w #$0033 : BCS .notHiddenChest
    
    .hiddenChest2
    
        LDY.w #$00FF
        
        INX #2
    
    .hiddenChest
    
        ; Has the chest already been opened?
        ; (RTS); No, we're done and the chest will remain hidden
        LDA $0402 : AND $009900, X : BEQ Object_BigKeyLock_easyOut
        
        ; if the chest has been revealed, neutralize the tag routine that would
        ; trigger it.
        TYA : AND $AE : STA $AE
    
    .notHiddenChest
    
        LDY $08
        
        LDX.w #$149C
        
        JMP Object_Draw2x2
    
    .alreadyOpened
    
        ; If the chest has been opened there's obviously no reason to track its
        ; tile address.
        STZ $06E0, X
        
        INX #2 : STX $0496 : STX $0498
        
        LDY.w #$FF00
        LDX.w #$0000
        
        LDA $AE : AND.w #$00FF
        
        CMP.w #$0027 : BEQ .hiddenChest_2
        CMP.w #$003C : BEQ .hiddenChest_2
        CMP.w #$003E : BEQ .hiddenChest_2
        CMP.w #$0029 : BCC .checkTag2_2
        CMP.w #$0033 : BCC .hiddenChest_2
    
    .checkTag2_2
    
        LDA $AF : AND.w #$00FF
        
        CMP.w #$0027 : BEQ .hiddenChest2_2
        CMP.w #$003C : BEQ .hiddenChest2_2
        CMP.w #$003E : BEQ .hiddenChest2_2
        CMP.w #$0029 : BCC .notHiddenChest_2
        CMP.w #$0033 : BCS .notHiddenChest_2
    
    .hiddenChest2_2
    
        LDY.w #$00FF
        
        INX #2
    
    .hiddenChest_2
    
        TYA : AND $AE : STA $AE
    
    .notHiddenChest_2
    
        LDY $08
        
        LDX.w #$14A4
    
    ; *$99B8 ALTERNATE ENTRY POINT
    .startsOpen
    
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; *$99BB-$99EB JUMP LOCATION
    Object_BigChest:
    {
        LDX $0496
        
        ; Use this value to indicate a big chest?
        TYA : ORA.w #$8000 : STA $06E0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$A000 : STA $06E0, X
    
    .onBg2
    
        ; If the chest has already been opened.
        LDA $0402 : AND $9900, X : BNE Object_OpenedBigChest
        
        INX #2 : STX $0496 : STX $0498
        
        LDX.w #$14AC
    
    ; *$99E6 ALTERNATE ENTRY POINT
    Object_Draw3x4:
    
        LDA.w #$0004
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$99EC-$99F1 JUMP LOCATION
    Object_Draw4x3:
    {
        LDA.w #$0003
        
        JMP Object_Draw4xN
    }

; ==============================================================================

    ; $99F2-$9A05
    Object_OpenedBigChest:
    {
        ; Opened chest, so use different tiles
        STZ $06E0, X
        
        INX #2 : STX $0496 : STX $0498
        
        LDX.w #$14C4
    
    .fake
    
        ; essentially a fake big chest that is opened
        ; (but was never closed to begin with)
        
        LDA.w #$0004
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$9A06-$9A0B JUMP LOCATION
    Object_Draw3x8:
    {
        LDA.w #$0008
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$9A0C-$9A11 JUMP LOCATION
    Object_Draw3x6:
    {
        LDA.w #$0006
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$9A12-$9A65 JUMP LOCATION
    Object_Draw7x8:
    {
        TXY
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        LDA $08 : ORA.w #$2000 : STA $08
    
    .onBg2
    
        LDX $08
        
        LDA.w #$0008 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        LDA $9B5A, Y : STA $7E2200, X
        LDA $9B5C, Y : STA $7E2280, X
        LDA $9B5E, Y : STA $7E2300, X
        
        TYA : ADD.w #$000E : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; $9A66-$9A6E JUMP LOCATION
    Object_Draw8x6:
    {
        LDY.w #$1F92
        LDA.w #$0006
        
        JMP Object_Draw8xN.draw
    }

; ==============================================================================

    ; *$9A6F-$9A8F JUMP LOCATION
    Object_StarTile:
    {
        ; Star shaped switch tiles (1.2.0x1F)
        
        PHX
        
        LDX $0432
        
        TYA : LSR A : STA $06A0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$2000 : LSR A : STA $06A0, X
    
    .onBg2
    
        INX #2 : STX $0432
        
        PLX
    
    ; *$9A8D ALTERNATE ENTRY POINT
    .disabled
    
        ; dummied star shaped switch tile (1.2.0x1E)
    
        JMP Object_Draw2x2_AdvanceDown
    }

; ==============================================================================

    ; *$9A90-$9AA2 JUMP LOCATION
    Object_Draw6x4:
    {
        LDA.w #$0004
        
        JSR Object_Draw3xN
        
        LDA $08 : ADD.w #$0180 : TAY
        
        LDA.w #$0004
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$9AA3-$9AA8 JUMP LOCATION
    Object_Draw4x6:
    {
        LDA.w #$0006
        
        JMP Object_Draw4xN
    }

; ==============================================================================

    ; *$9AA9-$9AED JUMP LOCATION
    Object_Rupees:
    {
        ; Check to see if the rupees were already collected
        LDA $0402 : AND.w #$1000 : BNE .rupeesAlreadyObtained
        
        LDA.w #$0003 : STA $0E
        
        LDY.w #$1DD6
        
        LDX $08
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TXA : ORA #$2000 : TAX
    
    .onBg2
    .moveTwoColumnsRight
    
        LDA $9B52, Y : STA $7E2000, X : STA $7E2180, X : STA $7E2300, X
        LDA $9B54, Y : STA $7E2080, X : STA $7E2200, X : STA $7E2380, X
        
        INX #4
        
        DEC $0E : BNE .moveTwoColumnsRight
    
    .rupeesAlreadyObtained
    
        RTS
    }

; ==============================================================================

    ; *$9AEE-$9B17 JUMP LOCATION
    Object_Draw5x4:
    {
        LDA.w #$0005 : STA $0E
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        LDA $9B58, X : STA [$C8], Y
        
        TXA : ADD.w #$0008 : TAX
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0E : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $9B18-$9B1D LOCAL
    {
        LDA.w #$0002
        
        JMP Object_Draw4xN
    }

; ==============================================================================

    ; *$9B1E-$9B4F JUMP LOCATION
    Object_WaterLadder:
    {
        ; Object 1.2.0x35 (Water ladders)?
        
        ; branch if not the water twin tag
        LDA $AF : AND.w #$00FF : CMP.w #$001B : BNE .alpha
        
        LDA $A0 : ASL A : TAX
        
        LDA $7EF000, X : AND.w #$0100 : BNE .alpha
        
        JMP Object_InactiveWaterLadder
    
    .alpha
    
        LDX $0444
        
        TYA : LSR A : STA $06B8, X
        
        INX #2
        
        STX $0444
        
        LDX.w #$1108
    
    ; *$9B48 ALTERNATE ENTRY POINT
    Object_Draw2x4:
    
        LDA.w #$0001 : STA $B2
        
        JMP Object_Draw2x4s_VariableOffset
    }

; ==============================================================================

    ; *$9B50-$9B55 JUMP LOCATION
    Object_Draw3x6_Alternate:
    {
        ; There really is no difference between this object and the
        ; other Draw3x6 object.
        LDA.w #$0006
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$9B56-$9BD8 JUMP LOCATION
    Object_SanctuaryMantle:
    {
        TXY
        
        LDX $08
        
        LDA.w #$0006 : STA $0E
    
    .nextRow
    
        LDA $9B52, Y
        
        STA $7E2000, X : STA $7E2008, X
        STA $7E2010, X : STA $7E201C, X
        STA $7E2024, X : STA $7E202C, X
        
        ORA.w #$4000
        
        STA $7E2002, X : STA $7E200A, X
        STA $7E2012, X : STA $7E201E, X
        STA $7E2026, X : STA $7E202E, X
        
        LDA $9B5E, Y
        
        STA $7E2004, X : STA $7E200C, X
        STA $7E2020, X : STA $7E2028, X
        
        ORA.w #$4000
        
        STA $7E2006, X : STA $7E200E, X
        STA $7E2022, X : STA $7E202A, X
        
        INY #2
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .nextRow
        
        TYA : ADD.w #$000C : TAX
        
        LDA $08 : ADD.w #$0014 : TAY
        
        LDA.w #$0004
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$9BD9-$9BF7 LOCAL
    Object_Draw2x3:
    {
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        LDA $9B58, X : STA [$CB], Y
        LDA $9B5A, X : STA [$CE], Y
        LDA $9B5C, X : STA [$D1], Y
        
        RTS
    }

; ==============================================================================

    ; *$9BF8-$9C3A JUMP LOCATION
    Object_Watergate:
    {
        ; watergate barrier object
        
        LDA $0402 : AND.w #$0800 : BNE .hasBeenOpened
        
        LDA.w #$000A
        
        JSR Object_Draw4xN
        
        LDA.w #$000F : STA $0470
        
        LDA $08 : STA $0472
        
        RTS
    
    .hasBeenOpened
    
        LDX.w #$13E8
        LDA.w #$000A
        
        JSR Object_Draw4xN
        
        LDA $B7 : PHA
        LDA $B8 : PHA
        LDA $BA : PHA
        
        LDA.w #$0004 : STA $B9
        
        LDA.w #$F1CD
        
        JSR Object_WatergateChannelWater
        
        REP #$30
        
        PLA : STA $BA
        PLA : STA $B8
        PLA : STA $B7
        
        RTS
    }

; ==============================================================================

    ; *$9C3B-$9C43 JUMP LOCATION
    {
        INC $03F4 ; WTF is this?
    
    ; *$9C3E ALTERNATE ENTRY POINT
    Object_Draw1x1:
    
        LDA $9B52, X : STA [$BF], Y
        
        RTS
    }

; ==============================================================================

    ; *$9C44-$9CC5 JUMP LOCATION
    Object_PrisonBars:
    {
        TYX
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TXA : ORA.w #$2000 : TAX
    
    .onBg2
    
        PHX
        
        LDY.w #$1488
        LDA.w #$0005 : STA $0C
    
    .nextColumn
    
        LDA $9B54, Y : STA $7E2004, X :                STA $7E2012, X
        LDA $9B56, Y : STA $7E2084, X : ORA.w #$4000 : STA $7E2092, X
        LDA $9B5A, Y : STA $7E2104, X : ORA.w #$4000 : STA $7E2112, X
        LDA $9B5C, Y : STA $7E2184, X : ORA.w #$4000 : STA $7E2192, X
        
        INX #2
        
        DEC $0C : BNE .nextColumn
        
        PLX
        
        LDA $9B52, Y : STA $7E2000, X : ORA.w #$4000 : STA $7E201E, X
        LDA $9B54, Y : STA $7E2002, X                : STA $7E200E, X : STA $7E2010, X : STA $7E201C, X
        LDA $9B58, Y : STA $7E2102, X : ORA.w #$4000 : STA $7E211C, X
        
        RTS
    }

    ; *$9CC6-$9CEA JUMP LOCATION
    {
        JMP Object_Size1to16
        
        LDA.w #$0002
        
        JMP Object_Draw3xN
        
        DEC $B2 : BEQ .alpha
    
    .beta
    
        PHX
        
        LDA.w #$0002
        
        JSR Object_Draw3xN
        
        PLX
        
        DEC $B2 : BNE .beta
    
    .alpha
    
        TXA : ADD.w #$000C : TAX
        
        LDA.w #$0002
        
        JMP Object_Draw3xN
    }

    ; *$9CEB-$9D28 JUMP LOCATION
    {
        JSR Object_Size1to16
        
        JSR $9D04 ; $9D04 IN ROM
        
        DEC $B2 : BEQ .alpha
    
    .beta
    
        PHX
        
        JSR $9D04 ; $9D04 IN ROM
        
        PLX
        
        DEC $B2 : BNE .beta
    
    .alpha
    
        TXA : ADD.w #$000C : TAX
    
    ; *$9D04 ALTERNATE ENTRY POINT
    
        LDA.w #$0002 : STA $0A
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        
        INX #6
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0A : BNE .nextRow
        
        RTS
    }

    ; *$9D29-$9D95 JUMP LOCATION
    {
        ; Check if tag2 is water twin
        LDA $AF : AND.w #$00FF : CMP.w #$001B : BNE .notWaterTwinTag
        
        LDA $A0 : ASL A : TAX
        
        ; Directly compare with the save data
        LDA $7EF000, X : AND.w #$0100 : BNE BRANCH_BETA
        
        LDX.w #$1614
    
    .notWaterTwinTag
    
        SEP #$20
        
        ; Also check for the "turn on water" tag
        LDA.w #$19 : CMP $AF : BNE .notTurnOnWaterTag
        
        ; AND with 0x0008
        LDA $0403 : AND $98C9 : BNE BRANCH_BETA
    
    .notTurnOnWaterTag
    
        REP #$20
        
        STY $047C
        
        LDA.w #$0003
        
        BRA BRANCH_EPSILON
    
    ; *$9D5D ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        REP #$20
        
        LDX.w #$162C
        LDA.w #$0005
        
        BRA BRANCH_EPSILON
    
    ; *$9D67 ALTERNATE ENTRY POINT
    
        LDA.w #$0007
        
        BRA BRANCH_EPSILON
    
    ; *$9D6C ALTERNATE ENTRY POINT
    
        LDA.w #$0002
    
    BRANCH_EPSILON:
    
        STA $0E
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        LDA $9B58, X : STA [$C8], Y
        
        TXA : ADD.w #$0008 : TAX
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0E : BNE .nextRow
        
        RTS
    }

    ; *$9D96-$9DE4 JUMP LOCATION
    Object_Draw8xN:
    shared Object_KholdstareShell:
    {
    
        ; Kholdstare's Shell object (1.3.0x15)
        ; Check the 0x8000 bit
        ; if it was set, don't draw at all
        LDA $0402 : ASL A : BCS .boss_defeated
        
        LDY.w #$1DFA
        LDA.w #$000A
    
    ; *$9DA2 ALTERNATE ENTRY POINT / BRANCH LOCATION
    .draw
    
        STA $0A
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        LDA $08 : ORA.w #$2000 : STA $08
    
    .onBg2
    
        LDA.w #$0008 : STA $0C
    
    .nextRow
    
        LDA $0A : STA $0E
        
        LDX $08
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X
        
        INY #2
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDA $08 : ADD.w #$0080 : STA $08
        
        DEC $0C : BNE .nextRow
    
    .boss_defeated
    
        RTS
    
    shared Object_TrinexxShell:
    
        ; Trinexx Shell (1.3.0x72)
        LDA $0402 : ASL A : BCS .boss_defeated
        
        TXY
        
        LDA.w #$000A
        
        ; Indicates that structurally, the Trinexx shell is similar to
        ; Kholdstare's
        BRA .draw
    }

; ==============================================================================

    ; *$9DE5-$9E2F JUMP LOCATION
    Object_LanternLayer:
    {
        LDY.w #$16DC
        LDA.w #$0514
        
        JSR .drawLampPortion
        
        LDY.w #$17F6
        LDA.w #$0554
        
        JMP .drawLampPortion
        
        LDY.w #$1914
        LDA.w #$1514
        
        JMP .drawLampPortion
        
        LDY.w #$1A2A
        LDA.w #$1554
    
    .drawLampPortion
    
        STA $00
        
        LDA.w #$000C : STA $02
    
    .nextRow
    
        LDA.w #$000C : STA $0C
        
        LDX $00
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X
        
        INY #2
        INX #2
        
        DEC $0C : BNE .nextColumn
        
        LDA $00 : ADD.w #$0080 : STA $00
        
        DEC $02 : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$9E30-$9EA2 JUMP LOCATION
    Object_AgahnimAltar:
    {
        LDA.w #$000E : STA $0E
        
        LDY.w #$1B4A
        
        LDX $08
    
    .nextRow
    
        LDA $9B52, Y : STA $7E2000, X
        ORA.w #$4000 : STA $7E201A, X
        
        LDA $9B6E, Y : STA $7E2002, X : STA $7E2004, X
        EOR.w #$4000 : STA $7E2016, X : STA $7E2018, X
        
        LDA $9B8A, Y : STA $7E2006, X
        EOR.w #$4000 : STA $7E2014, X
        
        LDA $9BA6, Y : STA $7E2008, X
        EOR.w #$4000 : STA $7E2012, X
        
        LDA $9BC2, Y : STA $7E200A, X
        EOR.w #$4000 : STA $7E2010, X
        
        LDA $9BDE, Y : STA $7E200C, X
        EOR.w #$4000 : STA $7E200E, X
        
        TXA : ADD.w #$0080 : TAX
        
        INY #2
        
        DEC $0E : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$9EA3-$A094 JUMP LOCATION
    Object_AgahnimRoomFrame:
    {
        LDA.w #$0006 : STA $0E
        
        LDY.w #$1BF2
        
        LDX $08
    
    .topEdgeLoop
    
        LDA $9B52, Y : STA $7E220E, X : STA $7E221A, X : STA $7E2226, X
        LDA $9B54, Y : STA $7E228E, X : STA $7E229A, X : STA $7E22A6, X
        LDA $9B56, Y : STA $7E230E, X : STA $7E231A, X : STA $7E2326, X
        LDA $9B58, Y : STA $7E238E, X : STA $7E239A, X : STA $7E23A6, X
        
        INY #8
        INX #2
        
        DEC $0E : BNE .topEdgeLoop
        
        LDA.w #$0005 : STA $0E
        
        LDY.w #$1C22
        
        LDX $08
    
    .diagonalsLoop
    
        LDA $9B52, Y   : STA $7E2504, X : STA $7E2486, X : STA $7E2408, X
        STA $7E238A, X : STA $7E230C, X : STA $7E228E, X : STA $7E2210, X
        
        ORA.w #$4000   : STA $7E222E, X : STA $7E22B0, X : STA $7E2332, X
        STA $7E23B4, X : STA $7E2436, X : STA $7E24B8, X : STA $7E253A, X
        
        INY #2
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .diagonalsLoop
        
        LDA.w #$0006 : STA $0E
        
        LDY.w #$1C2C
        
        LDX $08
    
    .sidesLoop
    
        LDA $9B52, Y : STA $7E2584, X : STA $7E2884, X : STA $7E2B84, X
        ORA.w #$4000 : STA $7E25BA, X : STA $7E28BA, X : STA $7E2BBA, X
        
        LDA $9B54, Y : STA $7E2586, X : STA $7E2886, X : STA $7E2B86, X
        ORA.w #$4000 : STA $7E25B8, X : STA $7E28B8, X : STA $7E2BB8, X
        
        LDA $9B56, Y : STA $7E2588, X : STA $7E2888, X : STA $7E2B88, X
        ORA.w #$4000 : STA $7E25B6, X : STA $7E28B6, X : STA $7E2BB6, X
        
        LDA $9B58, Y : STA $7E258A, X : STA $7E288A, X : STA $7E2B8A, X
        ORA.w #$4000 : STA $7E25B4, X : STA $7E28B4, X : STA $7E2BB4, X
        
        INY #8
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BEQ .sidesLoopDone
        
        JMP .sidesLoop
    
    .sidesLoopDone
    
        LDA.w #$0006 : STA $0E
        
        LDY.w #$1C5C
        
        LDX $08
    
    .horizLightLoop
    
        LDA $9B52, Y : STA $7E2498, X : STA $7E24A4, X
        LDA $9B5E, Y : STA $7E2518, X : STA $7E2524, X
        
        INY #2
        INX #2
        
        DEC $0E : BNE .horizLightLoop
        
        LDA.w #$0006 : STA $0E
        
        LDY.w #$1C74
        
        LDX $08
    
    .vertLightLoop
        
        LDA $9B52, Y : STA $7E270E, X : STA $7E2A0E, X
        LDA $9B54, Y : STA $7E2710, X : STA $7E2A10, X
        
        INY #4
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .vertLightLoop
        
        LDA.w #$0005 : STA $0E
        
        LDY.w #$1C8C
        
        LDX $08
    
    .draw5x5_LightLoop
    
        LDA $9B52, Y : STA $7E248E, X
        LDA $9B54, Y : STA $7E250E, X
        LDA $9B56, Y : STA $7E258E, X
        LDA $9B58, Y : STA $7E260E, X
        LDA $9B5A, Y : STA $7E268E, X
        
        TYA : ADD.w #$000A : TAY
        
        INX #2
        
        DEC $0E : BNE .draw5x5_LightLoop
        
        LDA.w #$0004 : STA $0E
        
        LDX $08
    
    .addPriorityLoop
    
        LDA $7E2E1C, X : ORA.w #$2000 : STA $7E2E1C, X
        LDA $7E2E9C, X : ORA.w #$2000 : STA $7E2E9C, X
        
        INX #2
        
        DEC $0E : BNE .addPriorityLoop
        
        RTS
    }

; ==============================================================================

    ; *$A095-$A193 JUMP LOCATION
    Object_FortuneTellerTemplate:
    {
        LDA.w #$0006 : STA $0E
        
        LDY.w #$202E
        
        LDX $08
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2002, X : STA $7E2004, X : STA $7E2082, X : STA $7E2084, X
        
        LDA $9B54, Y : STA $7E2102, X
        ORA.w #$4000 : STA $7E2104, X
        
        INX #4
        
        DEC $0E : BNE .nextColumn
        
        LDA.w #$0003 : STA $0E
        
        LDX $08
    
    .nextRow
    
        LDA $9B56, Y : STA $7E2180, X : STA $7E2184, X : STA $7E2194, X : STA $7E2198, X
        ORA.w #$4000 : STA $7E2182, X : STA $7E2186, X : STA $7E2196, X : STA $7E219A, X
        
        LDA $9B5C, Y : STA $7E2188, X : STA $7E218C, X : STA $7E2190, X
        ORA.w #$4000 : STA $7E218A, X : STA $7E218E, X : STA $7E2192, X
        
        INY #2
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .nextRow
        
        LDX $08
        
        LDA $9B5C, Y : STA $7E2000, X : STA $7E2080, X
        ORA.w #$4000 : STA $7E201A, X : STA $7E209A, X
        
        LDA $9B5E, Y : STA $7E2100, X
        ORA.w #$4000 : STA $7E211A, X
        
        LDA.w #$0004 : STA $0E
        
        LDY.w #$202E
        
        LDX $08
    
    .nextRow2
    
        LDA $9B66, Y : STA $7E2506, X
        EOR.w #$4000 : STA $7E2514, X
        
        LDA $9B6E, Y : STA $7E2508, X
        EOR.w #$4000 : STA $7E2512, X
        
        LDA $9B76, Y : STA $7E250A, X
        EOR.w #$4000 : STA $7E2510, X
        
        LDA $9B7E, Y : STA $7E250C, X
        EOR.w #$4000 : STA $7E250E, X
        
        INY #2
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .nextRow2
        
        RTS
    }

; ==============================================================================

    ; *$A194-$A1D0 JUMP LOCATION
    {
        LDA.w #$0003 : STA $0E
        
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
    
    .nextRow
    
        LDA $9B58, X : STA [$CB], Y
        LDA $9B5A, X : STA [$CE], Y
        LDA $9B5C, X : STA [$D1], Y
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0E : BNE .nextRow
        
        LDA $9B5E, X : STA [$CB], Y
        LDA $9B60, X : STA [$CE], Y
        LDA $9B62, X : STA [$D1], Y
        
        RTS
    }

; ==============================================================================

    ; *$A1D1-$A254 JUMP LOCATION
    {
        LDY.w #$20F6
        
        LDX $08
        
        ; Draw 11x11 block
        LDA.w #$0016 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X
        LDA $9B54, Y : STA $7E4080, X
        LDA $9B56, Y : STA $7E4100, X
        LDA $9B58, Y : STA $7E4180, X
        LDA $9B5A, Y : STA $7E4200, X
        LDA $9B5C, Y : STA $7E4280, X
        LDA $9B5E, Y : STA $7E4300, X
        LDA $9B60, Y : STA $7E4380, X
        LDA $9B62, Y : STA $7E4400, X
        LDA $9B64, Y : STA $7E4480, X
        LDA $9B66, Y : STA $7E4500, X
        
        TYA : ADD.w #$0016 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDY.w #$22DA
        
        LDX $08
        
        LDA.w #$0003 : STA $0E
    
    .nextColumn2
    
        LDA $9B52, Y : STA $7E4592, X
        LDA $9B58, Y : STA $7E4612, X
        
        INY #2
        INX #2
        
        DEC $0E : BNE .nextColumn2
        
        RTS
    }

; ==============================================================================

    ; *$A255-$A25C JUMP LOCATION
    Object_EntireFloorIsPit:
    {
        STZ $0C
        
        LDX.w #$00E0
        
        JMP $8A1F ; $8A1F IN ROM
    }

; ==============================================================================

    ; *$A25D-$A2C0 JUMP LOCATION
    {
        ; In-floor in-room up-north staircase (1.2.0x30)
        
        PHX
        
        LDX $043C
        
        TYA : LSR A : STA $06B8, X
        
        INX #2 : STX $043C
        
        BRA .drawObject
    
    ; *$A26D ALTERNATE ENTRY POINT
    
    ; (1.2.0x31)
    
        PHX
        
        LDX $043E
        
        TYA : LSR A : STA $06B8, X
        
        INX #2 : STX $043E
    
    .drawObject
    
        STX $0446
        STX $0448
        
        TYX
        
        PLY
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X : STA $7E4000, X
        LDA $9B54, Y : STA $7E2080, X : STA $7E4080, X
        LDA $9B56, Y : STA $7E2100, X : STA $7E4100, X
        LDA $9B58, Y : STA $7E2180, X : STA $7E4180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$A2C1-$A2DE BRANCH LOCATION
    {
        STZ $0414
        
        LDX.w #$10C8
    
    ; *$A2C7 ALTERNATE ENTRY POINT
    
        ; (1.2.0x32) inter-psuedo-bg north staircase
        
        PHX
        
        LDX $0440
        
        TYA : LSR A : STA $06B8, X
        
        INX #2
        
        STX $0440
        STX $0446
        STX $0448
        
        PLX
        
        JMP Object_Draw4x4
    }

    ; *$A2DF-$A30B JUMP LOCATION
    {
        ; (1.2.0x33)
        
        LDA $AF : AND.w #$00FF : CMP.w #$001B : BNE .notWaterTwin
        
        LDA $A0 : ASL A : TAX
        
        LDA $7EF000, X : AND.w #$0100 : BEQ _A2C1_
    
    .notWaterTwins
    
        LDX $0442
        
        TYA : LSR A : STA $06B8, X
        
        INX #2
        
        STX $0442
        STX $0444
        
        LDX.w #$10C8
        
        JMP Object_Draw4x4
    }

    ; *$A30C-$A369 JUMP LOCATION
    {
        ; In-room up-south staircase (1.3.0x1B)
        
        PHX
        
        LDX $049A
        
        TYA : LSR A : STA $06B8, X
        
        INX #2 : STX $049A
        
        BRA .drawObject
    
    ; *$A31C ALTERNATE ENTRY POINT
    
        ; In-room up-north staircase (1.3.0x1C)
        
        PHX
        
        LDX $049C
        
        TYA : LSR A : STA $06EC, X
        
        INX #2 : STX $049C
    
    .drawObject
    
        TYX
        
        PLY
        
        ; Draw a 4x4 tile object
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X : STA $7E4000, X
        LDA $9B54, Y : STA $7E2080, X : STA $7E4080, X
        LDA $9B56, Y : STA $7E2100, X : STA $7E4100, X
        LDA $9B58, Y : STA $7E2180, X : STA $7E4180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

    ; *$A36A-$A37F BRANCH LOCATION
    {
        STZ $0414
        
        PLX
    
    ; *$A36E ALTERNATE ENTRY POINT
    
        ; In-room up-south staircase (1.3.0x1D)
        
        PHX
        
        LDX $049E
        
        TYA : LSR A : STA $06EC, X
        
        INX #2 : STX $049E
        
        PLX
        
        JMP Object_Draw4x4
    }

    ; *$A380-$A3AD JUMP LOCATION
    {
        ; In room up-staircase (1.3.0x33)
        
        PHX
        
        LDA $AF : AND.w #$00FF : CMP.w #$001B : BNE .indoors
        
        LDA $A0 : ASL A : TAX
        
        LDA $7EF000, X : AND.w #$0100 : BEQ BRANCH_$A36A
        
        LDA.w #$6202 : STA $99
    
    .indoors
    
        LDX $04AE
        
        TYA : LSR A : STA $06EC, X
        
        INX #2 : STX $04AE
        
        PLX
        
        JMP Object_Draw4x4
    }

    ; *$A3AE-$A41A JUMP LOCATION
    Object_InactiveWaterLadder:
    {
        ; Inactive ladders in the swamp palace
        ; (1.2.0x36)
        
        LDX $0446
        
        TYA : LSR A : STA $06B8, X
        
        INX #2
        
        STX $0446
        STX $0448
        
        TYX
        
        LDY.w #$1108
        
        LDA $9B52, Y : STA $7E2000, X : STA $7E4000, X
        LDA $9B54, Y : STA $7E2002, X : STA $7E4002, X
        LDA $9B56, Y : STA $7E2004, X : STA $7E4004, X
        LDA $9B58, Y : STA $7E2006, X : STA $7E4006, X
        LDA $9B5A, Y : STA $7E2080, X : STA $7E4080, X
        LDA $9B5C, Y : STA $7E2082, X : STA $7E4082, X
        LDA $9B5E, Y : STA $7E2084, X : STA $7E4084, X
        LDA $9B60, Y : STA $7E2086, X : STA $7E4086, X
        
        RTS
    }

    ; *$A41B-$A457 JUMP LOCATION
    {
        ; In-Floor up-north staircase
        ; (1.2.0x2D)
        
        LDX $0438
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBg2
    
        INX #2
        
        STX $0438 ; in-floor up-north staircase
        STX $047E ; spiral up layer 1
        STX $0482 ; spiral up layer 2
        STX $04A2 ; straight up north
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$1088
        
        JMP Object_Draw4x4
    }

    ; *$A458-$A485 JUMP LOCATION
    {
        ; In-floor inter-floor down-south staircase
        ; (1.2.0x2E)
        
        LDX $043A
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2
    
        INX #2
        
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$10A8
        
        JMP Object_Draw4x4
    }

    ; *$A486-$A4B3 JUMP LOCATION
    {
        ; In-floor inter-room down-south staircase (use with hidden wall)
        ; (1.2.0x2F)
        
        LDX $043A
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2
    
        INX #2
        
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$10A8
        
        JMP Object_Draw4x4
    }

    ; *$A4B4-$A5D1 JUMP LOCATION
    {
        ; Inter-room in-wall up-north spiral staircase
        ; (1.2.0x38)
        
        LDX $047E
        
        TYA : SUB.w #$0080 : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        TYA : SUB.w #$0080 : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2
    
        INX #2
        
        ; update number of 38, 39, 3A, 3B objects
        STX $047E ; spiral up layer 1
        STX $0482 ; spiral up layer 2
        STX $04A2 ; straight up north
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2 
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$1148
        
        BRA .drawLayer1Obj
    
    ; *$A4F5 ALTERNATE ENTRY POINT
    
        ; In-wall inter-room up-north spiral staircase (alternate)
        ; (1.2.0x3A) (note: this object is not actually used in the original game)
        
        LDX $0482
        
        TYA : SUB.w #$0080 : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2_2
        
        TYA : SUB.w #$0080 : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2_2
    
        INX #2
        
        STX $0482 ; spiral up layer 2
        STX $04A2 ; straight up north
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$1178
        
        BRA .drawLayer2Obj
    
    ; *$A533 ALTERNATE ENTRY POINT
    
        ; (1.2.0x39) In-wall inter-floor down-north spiral staircase
        
        LDX $0480
        
        ; Take the tilemap address and load it into A
        ; $06B0, X = tilemap addr of the object - 1 line (which is 0x80 bytes)
        TYA : SUB.w #$0080 : LSR A : STA $06B0, X
        
        ; Check which BG we're drawing to.
        LDA $BF : CMP.w #$4000 : BNE .onBG2_3
        
        ; We're on BG1 and we need to indicate that to whatever tracks this object
        ; This is the same as the previous write except it would modify it to be on BG0
        TYA : SUB.w #$0080 : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2_3
    
        INX #2
        
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$1160
    
    .drawLayer1Obj
    
        LDA.w #$0004
        
        JSR Object_Draw3xN
        
        LDX $08 : DEX #2
        
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E200A, X : ORA.w #$2000 : STA $7E200A, X
        
        RTS
    
    ; *$A584 ALTERNATE ENTRY POINT
    
        ; In-wall inter-room down-north spiral staircase
        ; (1.2.0x3B)
        
        LDX $0484
        
        TYA : SUB.w #$0080 : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2_4
        
        TYA : SUB.w #$0080 : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBg2_4
    
        INX #2
        
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        LDX.w #$1190
    
    .drawLayer2Obj
    
        LDA.w #$0004
        
        JSR Object_Draw3xN
        
        LDX $08
        
        DEX #2
        
        LDA $7E4000, X : ORA.w #$2000 : STA $7E4000, X
        LDA $7E400A, X : ORA.w #$2000 : STA $7E400A, X
        
        RTS
    }

    ; *$A5D2-$A663 JUMP LOCATION
    {
        ; Wall up-north staircase (1.3.0x1E)
        ; Similar to 1.3.0x26 but only BG2
        
        PHX
        
        LDX $04A2
        
        TYA : LSR A : STA $06B0, X
        
        INX #2
        
        STX $04A2 ; straight up north
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        BRA .alpha
    
    ; *$A5F4 ALTERNATE ENTRY POINT
    
        ; In-wall inter-room down-north straight staircase (1.3.0x1F) (BG2 only)
        
        PHX
        
        LDX $04A6
        
        TYA : LSR A : STA $06B0, X
        
        INX #2
        
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        BRA .alpha
    
    ; *$A607 ALTERNATE ENTRY POINT
    
        ; straight up south staircase (1.3.0x20)
        
        PHX
        
        LDX $04A4
        
        TYA : LSR A : STA $06B0, X
        
        INX #2
        
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        BRA .alpha
    
    ; *$A626 ALTERNATE ENTRY POINT
    
        ; object (1.3.0x21)
        
        PHX
        
        LDX $04A8
        
        TYA : LSR A : STA $06B0, X
        
        INX #2
        
        STX $04A8 ; straight down south
    
    .alpha
    
        TYX
        PLY
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2]
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

    ; *$A664-$A71B JUMP LOCATION
    {
        ; Wall up-straight-staircase (1.3.0x26)
        ; Similar to 1.3.0x1E, but only BG1
        
        PHX
        
        LDX $04A2
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2
    
        INX #2
        
        STX $04A2 ; straight up north
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        BRA .draw
    
    ; *$A695 ALTERNATE ENTRY POINT
    
        ; (1.3.0x27) In-wall inter-room down-north straight staircase (BG1 only)
        
        PHX
        
        LDX $04A6
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2_2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2_2
    
        INX #2
        
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
    
    .draw
    
        TYX
        
        PLY
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X : STA $7E4000, X
        LDA $9B54, Y : STA $7E4080, X
        LDA $9B56, Y : STA $7E4100, X
        LDA $9B58, Y : STA $7E4180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDA $08 : SUB.w #$0200
    
    ; *$A6EE ALTERNATE ENTRY POINT
    .increasePriority
    
        TAX
        
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2080, X : ORA.w #$2000 : STA $7E2080, X
        LDA $7E2100, X : ORA.w #$2000 : STA $7E2100, X
        LDA $7E2180, X : ORA.w #$2000 : STA $7E2180, X
        
        RTS
    }

    ; *$A71C-$A7A2 JUMP LOCATION
    {
        ; straight up south (1.3.0x28)
        
        PHX
        
        LDX $04A4
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2
    
        INX #2
        
        STX $04A4 ; straight up south
        STX $043A ; in-floor down
        STX $0480 ; spiral down layer 1
        STX $0484 ; spiral down layer 2
        STX $04A6 ; straight down north
        STX $04A8 ; straight down south
        
        BRA .draw
    
    ; *$A74A ALTERNATE ENTRY POINT
    
        ; straight down south staircase (layer2?) (1.3.0x29)
        PHX
        
        LDX $04A8
        
        TYA : LSR A : STA $06B0, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2_2
        
        TYA : ORA.w #$2000 : LSR A : STA $06B0, X
    
    .onBG2_2
    
        ; straight down south
        INX #2 : STX $04A8
    
    .draw
    
        TYX
        
        PLY
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X
        LDA $9B54, Y : STA $7E4080, X
        LDA $9B56, Y : STA $7E4100, X
        LDA $9B58, Y : STA $7E2180, X : STA $7E4180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDA $08 : ADD.w #$0200
        
        JMP $A6EE ; $A6EE IN ROM
    }

    ; *$A7A3-$A7B5 JUMP LOCATION
    Object_Draw6x3:
    {
        LDA.w #$0003
        
        JSR Object_Draw3xN
        
        LDA $08 : ADD.w #$0180 : TAY
        
        LDA.w #$0003
        
        JMP Object_Draw3xN
    }

; ==============================================================================

    ; *$A7B6-$A7D2 JUMP LOCATION
    Object_Stacked4x4s:
    {
        JSR Object_Draw4x4
        
        LDA $08 : ADD.w #$0100 : TAY
        
        LDX.w #$2376
        
        JSR Object_Draw4x4
        
        LDA $08 : ADD.w #$0300 : TAY
        
        LDX.w #$2396
        
        JMP Object_Draw4x4
    }

; ==============================================================================

    ; *$A7D3-$A7EF JUMP LOCATION
    Object_BlindLight:
    Object_8x8:
    {
        ; Specifically, checks the room "Above" Blind's to see if the
        ; floor has been bombed out, which would let in the light that pisses
        ; Blind off and makes him start fighting you. (Or does it show his true
        ; nature / dispel the magic? Don't really know, but who cares?
        LDA $7EF0CA : AND.w #$0100 : BEQ .eventNotTriggered
    
    ; *$A7DC ALTERNATE ENTRY POINT
    .draw
    
        ; Boss entrance doorways + symbol (and Blind light)
        JSR Object_Draw4x4
        JSR Object_Draw4x4
        
        LDA $08 : ADD.w #$0200 : TAY
        
        JSR Object_Draw4x4
        JSR Object_Draw4x4
    
    .eventNotTriggered
    
        RTS
    }

; ==============================================================================

    ; *$A7F0-$A808 JUMP LOCATION
    Object_Triforce:
    {
        JSR Object_Draw4x4
        
        LDA $08 : ADD.w #$01FC : TAY
        
        PHX
        
        JSR Object_Draw4x4
        
        PLX
        
        LDA $08 : ADD.w #$0204 : TAY
        
        JMP Object_Draw4x4
    }

; ==============================================================================

    ; *$A809-$A81B JUMP LOCATION
    Object_Draw10x20_With4x4:
    {
        LDA.w #$0005
        
        JSR $8A44 ; $8A44 IN ROM
        
        LDA $08 : ADD.w #$0200 : TAY
        
        LDA.w #$0005
        
        JMP $8A44 ; $8A44 IN ROM
    }

; ==============================================================================

    !door_position = $02
    !tilemap_pos   = $08

    ; *$A81C-$A983 JUMP LOCATION
    Door_Up:
    {
        ; Determine the position for the door from a table
        LDY $997E, X : STY !tilemap_pos
        
        CMP.w #$0030 : BNE .notBlastWall
        
        JMP Door_BlastWall
    
    .notBlastWall
    
        ; Invisible door...
        CMP.w #$0016 : BNE .notFloorToggleProperty
        
        TYA : SUB.w #$00FE
        
        JMP Door_AddFloorToggleProperty
    
    .notFloorToggleProperty
    
        CMP.w #$0032 : BNE BRANCH_GAMMA
        
        JMP Door_SwordActivated
    
    BRANCH_GAMMA:
    
        CMP.w #$0006 : BNE BRANCH_DELTA
        
        JMP $AF7F ; $AF7F IN ROM
    
    BRANCH_DELTA:
    
        CMP.w #$0014 : BNE .notPalaceToggleProperty
        
        TYA : SUB.w #$00FE
        
        JMP Door_AddPalaceToggleProperty
    
    .notPalaceToggleProperty
    
        CMP.w #$0002 : BNE BRANCH_ZETA
        
        ; Preserve the layer and column the door is on, but snap the
        ; Y coordinate upwards to the nearest quadrant boundary.
        TYA : AND.w #$F07F
        
        JSR Door_Prioritize7x4
        JMP $A90F ; $A90F IN ROM
    
    BRANCH_ZETA:
    
        CMP.w #$0012 : BNE .notExitDoor
        
        LDX $19E0
        
        TYA : STA $19E2, X
        
        INX #2 : STX $19E0
        
        RTS
    
    .notExitDoor
    
        CMP.w #$0008 : BNE BRANCH_IOTA
        
        JSR $A90F ; $A90F IN ROM
        
        BRA BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        CMP.w #$0020 : BEQ BRANCH_LAMBDA
        CMP.w #$0022 : BEQ BRANCH_LAMBDA
        CMP.w #$0024 : BEQ BRANCH_LAMBDA
        CMP.w #$0026 : BNE BRANCH_MU
    
    BRANCH_LAMBDA:
    
        LDX $0460
        
        LDA.w #$0000 : STA $19C0, X
        
        TYA : STA $19A0, X
        
        ; Store type and position (0000pppp tttttttt)
        TXA : LSR A : XBA : ORA $04 : STA $1980, X
        
        TXA : AND.w #$000F : TAY
        
        LDA $98C0, Y
        
        LDY !tilemap_pos
        
        AND $068C : BEQ BRANCH_NU
        
        INX #2 : STX $0460
        
        RTS
    
    BRANCH_NU:
    
        ; Branch here if it's a locked door and hasn't been unlocked.
        
        LDA $04 : CMP.w #$0024 : BCC BRANCH_RHO
        
        STX !tilemap_pos
        
        LDX $0460
        
        LDA.w #$0000
        
        JSR Door_Register
        
        LDA $CD9E, Y : TAY
        
        LDX !tilemap_pos
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        ; Apparently some of these doors can only draw to BG1
        LDA $9B52, Y : STA $7E4000, X
        LDA $9B54, Y : STA $7E4080, X
        LDA $9B56, Y : STA $7E4100, X
        
        TYA : ADD.w #$0006 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
    
    ; *$A8FA ALTERNATE ENTRY POINT
    BRANCH_KAPPA:
    
        LDX $0460
        
        LDA $199E, X : ORA.w #$2000 : STA $199E, X
        
        RTS
    
    BRANCH_MU:
    
        CMP.w #$0040 : BCC BRANCH_PI ; Branch on default and type < 0x40
        
        JMP $AD41 ; $AD41 IN ROM
    
    ; *$A90F ALTERNATE ENTRY POINT
    BRANCH_PI:
    
        ; Check the door's "Pos" or "location"
        ; If pos < 0x0C (6 in HM)
        LDX !door_position : CPX.w #$000C : BCC BRANCH_RHO
        
        PHY
        
        LDA $0460 : PHA
        
        ORA.w #$0010 : STA $0460
        
        LDY $998A, X
        
        LDA $04
        
        JSR $AA66 ; $AA66 IN ROM
        
        PLA : STA $0460
        
        PLY
        
        LDA $04 : STA $0A
    
    BRANCH_RHO:
    
        STY !tilemap_pos
        
        LDX $0460
        
        LDA.w #$0000
        
        JSR Door_Register : BCC .registrationFailed ; If failed, return
        
        LDA.w #$0018
        
        CPY.w #$0036 : BEQ .oneSidedTrapDoor
        
        LDA.w #$0000
        
        CPY.w #$0038 : BNE .notOneSidedTrapDoor
    
    .oneSidedTrapDoor
    
        STA $0E
        
        LDA $197E, X : AND.w #$00FF : ORA $0E : STA $197E, X
        
        LDY $0E
    
    .notOneSidedTrapDoor
    
        LDX $CD9E, Y
        
        LDY !tilemap_pos
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn2
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        
        TXA : ADD.w #$0006 : TAX
        
        INY #2
        
        DEC $0E : BNE .nextColumn2
    
    .registrationFailed
    
        RTS
    }

; ==============================================================================

    ; *$A984-$AAD6 JUMP LOCATION
    Door_Down:
    {
        ; get the position of the door
        LDY $9996, X : STY $08
        
        CMP.w #$0016 : BNE .notFloorToggleProperty
        
        TYA : ADD.w #$0202
        
        JMP Door_AddFloorToggleProperty
    
    .notFloorToggleProperty
    
        CMP.w #$0006 : BNE .notPrioritizeProperty
        
        JMP Door_PrioritizeDownToQuadBoundary
    
    .notPrioritizeProperty
    
        CMP.w #$0014 : BNE .notPalaceToggleProperty
        
        TYA : ADD.w #$0202
        
        JMP Door_AddPalaceToggleProperty
    
    .notPalaceToggleProperty
    
        CMP.w #$0012 : BNE .notExitDoor
        
        LDX $19E0
        
        TYA : STA $19E2, X
        
        INX #2 : STX $19E0
        
        RTS
    
    .notExitDoor
    
        CMP.w #$0040 : BCC .notTopOnBg1Door
        
        JMP $ADD4 ; $ADD4 IN ROM
    
    .notTopOnBg1Door
    
        ; Large door entrance type
        CMP.w #$000A : BNE .notBg2_LargeExit
        
        LDX $0460
        LDA.w #$0001
        
        JSR Door_Register
        
        LDA $08 : SUB.w #$0206 : STA $08
        
        LDY.w #$2656
        LDA.w #$000A
        
        JMP Object_Draw8xN.draw
    
    .notBg2_LargeExit
    
        ; Other large entrance door type
        CMP.w #$000C : BNE .notBg1_LargeExit
        
        TYA : ORA.w #$2000 : STA $08 : TAY
        
        LDX $0460
        LDA.w #$0001
        
        JSR Door_Register
        
        LDA $08 : SUB.w #$0206 : STA $08
        
        LDY.w #$2656
        LDA.w #$000A
        
        JSR Object_Draw8xN.draw
        
        LDA $08 : SUB.w #$2080 : TAX
        
        LDY.w #$000A
    
    .prioritizeLineOnBg2
    
        LDA $7E4000, X : ORA.w #$2000 : STA $7E2000, X
        
        INX #2
        
        DEY : BNE .prioritizeLineOnBg2
        
        RTS
    
    .notBg1_LargeExit
    
        CMP.w #$000E : BEQ .caveExitDoor
        CMP.w #$0010 : BNE .notCaveExitDoor
    
    ; *$AA2F ALTERNATE ENTRY POINT
        
        TYA : ADD.w #$0200
        
        JSR Door_Prioritize7x4
    
    .caveExitDoor
    
        LDX $0460
        LDA.w #$0001
        
        JSR Door_Register
        
        LDY $08
        
        LDX.w #$26F6
        LDA.w #$000A
        
        JMP Object_Draw4x4
    
    .notCaveExitDoor
    
        CMP.w #$0004 : BNE .notOtherCaveExitDoor
        
        TYA
        
        PLY
        
        ORA.w #$2000 : STA $08 : TAY
        
        JSR $AA2F ; $AA2F IN ROM
        
        PHA
        
        ADD.w #$0180 : TAX
        
        LDY.w #$0004
        
        BRA .prioritizeLineOnBg2
    
    ; *$AA66 ALTERNATE ENTRY POINT
    .notOtherCaveExitDoor
    
        CMP.w #$0002 : BNE BRANCH_XI
        
        TYA : ADD.w #$0200
        
        JSR Door_Prioritize7x4
        
        BRA BRANCH_OMICRON
    
    BRANCH_XI:
    
        CMP.w #$0008 : BNE .notWaterfallDoor
        
        JSR $AA80 ; $AA80 IN ROM
        JMP $A8FA ; $A8FA IN ROM
    
    ; *$AA80 ALTERNATE ENTRY POINT
    .notWaterfallDoor
    BRANCH_OMICRON:; Default behavior
    
        STY $08
        
        LDX $0460
        LDA.w #$0001
        
        JSR Door_Register : BCC BRANCH_PI
        
        LDA.w #$0000
        
        CPY.w #$001E : BEQ BRANCH_RHO ; Not big key -> normal door
        CPY.w #$0036 : BEQ BRANCH_RHO ; Right side only trap door
        
        LDA.w #$0018
        
        CPY.w #$0038 : BNE BRANCH_SIGMA ; Left side only trap door
    
    BRANCH_RHO:
    
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $197E, X
        
        LDY $0E
    
    BRANCH_SIGMA:
    
        LDX $CE06, Y
        
        LDY $08
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, X : STA [$CB], Y
        LDA $9B54, X : STA [$D7], Y
        LDA $9B56, X : STA [$DA], Y
        
        TXA : ADD.w #$0006 : TAX
        
        INY #2
        
        DEC $0E : BNE .nextColumn
    
    BRANCH_PI:
    
        RTS
    }

; ==============================================================================

    ; *$AAD7-$AB98 JUMP LOCATION
    Door_Left:
    {
        ; get the position of the door
        LDY $99AE, X : STY $08
        
        CMP.w #$0016 : BNE .notFloorToggleProperty
        
        TYA : ADD.w #$007C
        
        JMP Door_AddFloorToggleProperty
    
    .notFloorToggleProperty
    
        CMP.w #$0006 : BNE .notPrioritizeProperty
        
        JMP $B00D ; $B00D IN ROM
    
    .notPrioritizeProperty
    
        CMP.w #$0014 : BNE .notPalaceToggleProperty
        
        TYA : ADD.w #$007C
        
        JMP Door_AddPalaceToggleProperty
    
    .notPalaceToggleProperty
    
        CMP.w #$0002 : BNE BRANCH_DELTA
        
        TYA : AND.w #$FFC0
        
        JSR Door_Prioritize4x5
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        CMP.w #$0008 : BNE BRANCH_ZETA
        
        JSR $AB1F ; $AB1F IN ROM
        JMP $A8FA ; $A8FA IN ROM
    
    BRANCH_ZETA:
    
        CMP.w #$0040 : BCC BRANCH_EPSILON
        
        JMP $AE40 ; $AE40 IN ROM
    
    ; *$AB1F ALTERNATE ENTRY POINT
    BRANCH_EPSILON: 
    ;Default behavior
    
        LDX !door_position : CPX.w #$000C : BCC BRANCH_THETA
        
        PHY
        
        LDA $0460 : PHA
        
        ORA.w #$0010 : STA $0460
        
        LDY $99BA, X
        
        LDA $04
        
        JSR $ABC8 ; $ABC8 IN ROM
        
        PLA : STA $0460
        
        PLY
        
        LDA $04 : STA $0A
    
    BRANCH_THETA:
    
        STY $08
        
        LDX $0460
        
        LDA.w #$0002
        
        JSR Door_Register : BCC BRANCH_KAPPA
        
        LDA.w #$0018
        
        CPY.w #$0036 : BEQ BRANCH_LAMBDA
        
        LDA.w #$0000
        
        CPY.w #$0038 : BNE BRANCH_MU
    
    BRANCH_LAMBDA:
    
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $179E, X
        
        LDY $0E
    
    BRANCH_MU:
    
        LDX $CE66, Y
        
        LDY $08
        
        LDA.w #$0003 : STA $0E
    
    ; *$AB78 ALTERNATE ENTRY POINT
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        LDA $9B58, X : STA [$DA], Y
        
        TXA : ADD.w #$0008 : TAX
        
        INY #2
        
        DEC $0E : BNE .nextRow
    
    BRANCH_KAPPA:
    
        RTS
    }

; ==============================================================================

    ; *$AB99-$AC3A JUMP LOCATION
    Door_Right:
    {
        ; Draws a door?
        ; eg #$4632
        
        ; get the position of the door
        LDY $99C6, X : STY $08
        
        CMP.w #$0016 : BNE .notFloorToggleProperty
        
        TYA : ADD.w #$0088
        
        JMP Door_AddFloorToggleProperty
    
    .notFloorToggleProperty
    
        CMP.w #$0006 : BNE BRANCH_KAPPA
        
        JMP $B050 ; $B050 IN ROM
    
    BRANCH_KAPPA:
    
        CMP.w #$0014 : BNE .notPalaceToggleProperty
        
        TYA : ADD.w #$0088
        
        JMP Door_AddPalaceToggleProperty
    
    .notPalaceToggleProperty
    
        ; If less than #$0040, branch.
        CMP.w #$0040 : BCC BRANCH_THETA
        
        JMP $AEF0 ; $AEF0 IN ROM
    
    ; *$ABC8 ALTERNATE ENTRY POINT
    BRANCH_THETA:
    
        CMP.w #$0002 : BNE BRANCH_ALPHA
        
        TYA : ADD.w #$0008
        
        JSR Door_Prioritize4x5
        
        BRA BRANCH_ALPHA
    
    BRANCH_ALPHA:
    
        CMP.w #$0008 : BNE BRANCH_BETA
        
        JSR $ABE2 ; $ABE2 IN ROM
        JMP $A8FA ; $A8FA IN ROM
    
    ; *$ABE2 ALTERNATE ENTRY POINT
    ; Default behavior
    BRANCH_BETA:
    
        STY $08
        
        LDX $0460
        
        LDA.w #$0003
        
        JSR Door_Register : BCC BRANCH_GAMMA
        
        LDA.w #$0000
        
        CPY.w #$0036 : BEQ BRANCH_DELTA
        
        LDA.w #$0018
        
        CPY.w #$0038 : BNE BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $197E, X
        
        LDY $0E
    
    BRANCH_EPSILON:
    
        LDX $CEC6, Y
        
        LDY $08 : INY #2
        
        LDA.w #$0003 : STA $0E
    
    ; *$AC1A ALTERNATE ENTRY POINT
    .nextColumn
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        LDA $9B58, X : STA [$DA], Y
        
        TXA : ADD.w #$0008 : TAX
        
        INY #2
        
        DEC $0E : BNE .nextColumn
    
    BRANCH_GAMMA:
    
        RTS
    }
    
; ==============================================================================

    ; *$AC3B-$AC5A JUMP LOCATION
    Door_SwordActivated:
    {
        ; (Agahnim's curtain covered door and vines in Skull Palace).
        
        STY $08
        
        LDX $0460
        LDA.w #$0000
        
        JSR Door_Register : BCC .failedRegistration
        
        LDX $CD9E, Y
        
        BRA .drawOtherGraphic ; temp name
    
    .failedRegistration
    
        LDY $08
        LDX.w #$078A
        
        JMP Object_Draw4x4
    
    .drawOtherGraphic
    
        LDY $08
        
        JSR Object_Draw4x4
        
        RTS
    }

; ==============================================================================

    ; $AC5B-$AC6F BRANCH LOCATION
    Door_UntouchedBlastWall:
    {
        LDX $0460
        
        STZ $19C0, X
        
        TXA : LSR A : XBA : ORA.w #$0030 : STA $1980, X
        
        INX #2 : STX $0460
        
        RTS
    }

; ==============================================================================

    ; *$AC70-$AD40 JUMP LOCATION
    Door_BlastWall:
    {
        LDY $99DE, X : STY $08
        
        LDX $0460
        
        LDA $08 : ADD.w #$0014 : STA $19A0, X
        
        TXA : LSR A : XBA : ORA.w #$0030 : STA $1980, X
        
        TXA : AND.w #$000F : TAY
        
        LDA $068C : AND $98C0, Y : BEQ Door_UnopenedBlastWall
        
        ; the "door" (wall, more like it) has been opened, so we draw that instead
        SEP #$30
        
        LDX.b #$00
        
        ; check if "use switch to bomb wall" tag routine is being used.
        LDA $AE : CMP.b #$20 : BEQ .disableTag1
        
        ; check if "kill enemy to clear level" tag routine is being used.
        CMP.b #$25 : BEQ .disableTag1
        
        ; check if "pull lever to bomb wall" tag routine is being used
        CMP.b #$28 : BEQ .disableTag1
        
        INX
    
    .disableTag1
    
        STZ $AE, X
        
        REP #$30
        
        LDA $08 : PHA
        
        LDA $A7 : ORA.w #$0002 : STA $A7
        
        LDA $0452 : ORA.w #$0100 : STA $0452
        
        LDY.w #$0054
        
        LDX $CE06, Y
        
        JSR $ACE4 ; $ACE4 IN ROM
        
        PLA : ADD.w #$0300 : STA $08
        
        INC $0460 : INC $0460
        
        LDA $FC : ORA.w #$0200 : STA $FC
        
        LDY.w #$0054
        
        LDX $CD9E, Y
    
    ; *$ACE4 ALTERNATE ENTRY POINT
    
        LDA.w #$0012 : STA $B2
        
        LDY $08
        
        JSR $AD25 ; $AD25 IN ROM
        
        LDA $08 : ADD.w #$0004 : STA $08
        
        TXA : ADD.w #$000C : TAX
        
        PHX
        
        TXY
        
        LDX $08
        
        ; $9B52, Y THAT IS
        LDA $9B52, Y
    
    .nextColumn
    
        STA $7E2000, X : STA $7E2080, X : STA $7E2100, X : STA $7E2180, X
        STA $7E2200, X : STA $7E2280, X
        
        INX #2
        
        DEC $B2 : BNE .nextColumn
        
        TXY
        
        PLX
        
        INX #2
    
    ; *$AD25 ALTERNATE ENTRY POINT
    
        LDA.w #$0006 : STA $0A
    
    .nextRow
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B5E, X : STA [$C2], Y
        
        INX #2
        
        TYA : ADD.w #$0080 : TAY
        
        DEC $0A : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$AD41-$ADD3 JUMP LOCATION
    {
        LDX $02 : CPX.w #$000C : BCC BRANCH_ALPHA
        
        LDA $04 : CMP.w #$0046 : BEQ BRANCH_ALPHA
        
        PHY
        
        LDA $0460 : PHA
        
        ORA.w #$0010 : STA $0460
        
        LDY $998A, X
        
        JSR $ADD4 ; $ADD4 IN ROM
        
        PLA : STA $0460
    
    BRANCH_ALPHA:
    
        PLY : STY $08
        
        LDX $0460
        
        LDA.w #$0000
        
        JSR Door_Register
        
        LDA.w #$0044
        
        CPY.w #$0048 : BEQ BRANCH_BETA
        
        LDA.w #$0040
        
        CPY.w #$004A : BNE BRANCH_GAMMA
    
    BRANCH_BETA:
        
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $197E, X
        
        LDY $0E
    
    BRANCH_GAMMA:
    
        LDA $CD9E, Y : TAY
        
        LDX $08
        
        LDA.w #$0004 : STA $0E
    
    BRANCH_DELTA:
        
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E4080, X
        LDA $9B56, Y : STA $7E4100, X
        
        TYA : ADD.w #$0006 : TAY
        
        INX #2
        
        DEC $0E : BNE BRANCH_DELTA
        
        LDA $04 : CMP.w #$0046 : BEQ BRANCH_EPSILON
        
        LDA $08
        
        JSR $AF8B ; $AF8B IN ROM
    
    BRANCH_EPSILON:
    
        LDX $0460
        
        LDA $199E, X : ORA.w #$2000 : STA $199E, X
        
        RTS
    }

; ==============================================================================

    ; *$ADD4-$AE3F JUMP LOCATION
    {
        ; Y = tilemap address
        
        STY $08
        
        LDX $0460
        
        LDA.w #$0001
        
        JSR Door_Register
        
        LDA.w #$0040
        
        CPY.w #$0048 : BEQ .oneSidedTrapDoor
        
        LDA.w #$0044
        
        CPY.w #$004A : BNE .notOneSidedTrapDoor
    
    .oneSidedTrapDoor
    
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $197E, X
        
        LDY $0E
    
    .notOneSidedTrapDoor
    
        LDA $CE06, Y : TAY
        
        LDX $08
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, X : STA $7E4080, X
        LDA $9B54, X : STA $7E4100, X
        LDA $9B56, X : STA $7E2180, X
        
        TYA : ADD.w #$0006 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDA.b #$08 : ADD.w #$0200
        
        JSR Door_PrioritizeDownToQuadBoundary_variable
        
        LDX $0460
        
        ; Indicate that the other part of the door is on BG1 rather than BG2.
        LDA $199E, X : ORA.w #$2000 : STA $199E, X
        
        RTS
    }

; ==============================================================================

    ; *$AE40-$AEEF JUMP LOCATION
    {
        ; If position < 0x0C
        LDX $02 : CPX.w #$000C : BCC BRANCH_ALPHA
        
        PHX
        
        LDA $0460 : PHA
        
        ORA.w #$0010 : STA $0460
        
        LDY $99BA, X
        
        JSR $AEF0 ; $AEF0 IN ROM
        
        PLA : STA $0460
        
        PLY
    
    BRANCH_ALPHA:
    
        STY $08
        
        LDX $0460
        LDA.w #$0002
        
        JSR Door_Register
        
        LDA.w #$0044
        
        CPY.w #$0048 : BEQ BRANCH_BETA
        
        LDA.w #$0040
        
        CPY.w #$004A : BNE BRANCH_GAMMA
    
    BRANCH_BETA:
    
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $197E, X
        
        LDY $0E
    
    BRANCH_GAMMA:
    
        LDA $CE66, Y : TAY
        
        LDX $08
        
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        LDA.w #$0002 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E4000, X
        LDA $9B54, Y : STA $7E4080, X
        LDA $9B52, Y : STA $7E4100, X
        LDA $9B52, Y : STA $7E4180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDA $08
        
        JSR $B017 ; $B017 IN ROM
        
        LDX $0460
        
        LDA $199E, X : ORA.w #$2000 : STA $199E, X
        
        RTS
    }

; ==============================================================================

    ; *$AEF0-$AF7E LOCAL
    {
        ; Store the offset into the tile map here.
        STY $08
        
        LDX $0460
        
        LDA.w #$0003
        
        JSR Door_Register
        
        LDA.w #$0040
        
        CPY.w #$0048 : BEQ BRANCH_ALPHA
        
        LDA.w #$0044
        
        CPY.w #$004A : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        STA $0E
        
        LDA $197E, X : AND.w #$FF00 : ORA $0E : STA $197E, X
        
        LDY $0E
    
    BRANCH_BETA:
    
        ; Offset of the start of the tiles, we're going to be writing to the buffer.
        LDA $CEC6, Y : TAY
        
        LDX $08
        
        LDA.w #$0002 : STA $0E
    
    BRANCH_GAMMA:
    
        LDA $9B52, Y : STA $7E4002, X
        LDA $9B54, Y : STA $7E4082, X
        LDA $9B56, Y : STA $7E4102, X
        LDA $9B58, Y : STA $7E4182, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE BRANCH_GAMMA
        
        LDA $9B52, Y : STA $7E2002, X
        LDA $9B54, Y : STA $7E2082, X
        LDA $9B56, Y : STA $7E2102, X
        LDA $9B58, Y : STA $7E2182, X
        
        LDA $08 : ADD.w #$0008
        
        JSR $B05C ; $B05C IN ROM
        
        LDX $0460
        
        LDA $199E, X : ORA.w #$2000 : STA $199E, X
        
        RTS
    }

; ==============================================================================

    ; *$AF7F-$AFC7 LOCAL
    {
        LDA.w #$0000
        
        JSR Door_Register
        
        LDA $08 : ADD.w #$0080
    
    ; *$AF8B ALTERNATE ENTRY POINT
    
        STA $02
        
        AND.w #$F07F : TAX
    
    .nextRow
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2002, X : ORA.w #$2000 : STA $7E2002, X
        LDA $7E2004, X : ORA.w #$2000 : STA $7E2004, X
        LDA $7E2006, X : ORA.w #$2000 : STA $7E2006, X
        
        TXA : ADD.w #$0080 : TAX
        
        CPX $02 : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$AFC8-$B00C JUMP LOCATION
    Door_PrioritizeDownToQuadBoundary:
    {
        LDA.w #$0001
        
        JSR Door_Register
        
        LDA $08 : ADD.w #$0100
    
    ; *$AFD4 ALTERNATE ENTRY POINT
    .varaible
    
        TAX
    
    .nextRow
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2002, X : ORA.w #$2000 : STA $7E2002, X
        LDA $7E2004, X : ORA.w #$2000 : STA $7E2004, X
        LDA $7E2006, X : ORA.w #$2000 : STA $7E2006, X
        
        TXA : ADD.w #$0080 : TAX
        
        AND.w #$0F80 : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; *$B00D-$B04F JUMP LOCATION
    {
        LDA.w #$0002
        
        JSR Door_Register
        
        LDA $08 : INC #2
    
    ; *$B017 ALTERNATE ENTRY POINT
    
        STA $02
        
        AND.w #$FFC0 : TAX
    
    ; Add priority to a region of tiles in the tilemap
    .nextColumn
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2080, X : ORA.w #$2000 : STA $7E2080, X
        LDA $7E2100, X : ORA.w #$2000 : STA $7E2100, X
        LDA $7E2180, X : ORA.w #$2000 : STA $7E2180, X
        
        INX #2 : CPX $02 : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; $B050-$B091 LOCAL
    {
        LDA.w #$0003
        
        JSR Door_Register
        
        LDA $08 : ADD.w #$0004
    
    ; *$B05C ALTERNATE ENTRY POINT
    
        TAX
    
    ; Add priority to a region of tiles in the tilemap
    .nextColumn
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2080, X : ORA.w #$2000 : STA $7E2080, X
        LDA $7E2100, X : ORA.w #$2000 : STA $7E2100, X
        LDA $7E2180, X : ORA.w #$2000 : STA $7E2180, X
        
        INX #2
        
        TXA : AND.w #$003F : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$B092-$B09E JUMP LOCATION
    Door_AddPalaceToggleProperty:
    {
        LDX $0450
        
        LSR A : STA $06D0, X
        
        INX #2 : STX $0450
        
        RTS
    }

; ==============================================================================

    ; *$B09F-$B0AB JUMP LOCATION
    Door_AddFloorToggleProperty:
    {
        LDX $044E
        
        LSR A : STA $06C0, X
        
        INX #2 : STX $044E
        
        RTS
    }

; ==============================================================================

    ; *$B0AC-$B0BD LOCAL
    Object_Size1to16:
    {
        ; used by objects needing variable width or height ranging from 0x01 to 0x10
        LDA.w #$0001
        
        ; Segues into the next routine (Object_Size_N_to_N_plus15)
    }
    
    ; *$B0AF ALTERNATE ENTRY POINT
    Object_Size_N_to_N_plus_15:
    {
        ; alternate entry point for objects needing varaible width or height ranging
        ; from A (register) to (A (register) + 0x0F)
        STA $0E
        
        LDA $B2 : ASL #2 : ORA $B4 : ADC $0E : STA $B2
        
        ; Default width of 1?
        STZ $B4
        
        RTS
    }

; ==============================================================================

    ; *$B0BE-$B0CB JUMP LOCATION
    Object_Size_1_to_15_or_26:
    {
        ; used by objects needing variable width or height ranging from 0x01 to 0x0F
        ; or 0x1A as default in the event of both arguments being zero.
        LDA $B2 : ASL #2 : ORA $B4 : BNE .notDefault
        
        LDA.w #$001A
    
    .notDefault
    
        STA $B2
        
        RTS
    }

; ==============================================================================

    ; *$B0CC-$B0D9 LOCAL
    Object_Size_1_to_15_or_32:
    {
        ; used by objects needing variable width or height ranging from 0x01 to 0x0F
        ; or 0x20 as default in the event of both arguments being zero.
        LDA $B2 : ASL #2 : ORA $B4 : BNE .notDefault
        
        LDA.w #$0020
    
    .notDefault
    
        STA $B2
        
        RTS
    }

; ==============================================================================

    ; *$B0DA-$B190 LOCAL
    Door_Register:
    {
        ; A represents the direction (0 - up, 1 - down, 2, 3 - left, 4 -right)
        ; X is the index of the next slot to add a door at
        ; Y is the tilemap address of the door (doesn't differentiate BGs)
        
        ; Attempts to register a new door object
        ; Carry is clear on failure
        ; Carry is set on success (tentative guess)
        
        STA $19C0, X
        
        ; Store the tilemap address to this array.
        TYA : STA $19A0, X
        
        ; High byte is the object's slot in door memory, the low byte its type.
        TXA : LSR A : XBA : ORA $04 : STA $1980, X
        
        ; If index >= 0x04
        TXA : AND.w #$000F : TAY : CPY.w #$0008 : BCS BRANCH_ALPHA
        
        ; Check if door hasn't been opened?
        LDA $068C : AND $98C0, Y : BEQ BRANCH_ALPHA
        
        LDA $1980, X : AND.w #$00FF : CMP.w #$0018 : BEQ .triggeredTrapDoor
        
        ; Both 0x18 and 0x44 are trap doors...
        CMP.w #$0044 : BNE .notTrapDoor
    
    .triggeredTrapDoor
    
        ; Flag set when trap doors are down.
        LDA $0468 : BNE BRANCH_ALPHA
    
    .notTrapDoor
    
        PHX
        
        LDX $04
        
        LDA $9A02, X : STA $0A
        
        PLX
        
        LDA $1980, X : AND.w #$00FF
        
        CMP.w #$0018 : BEQ BRANCH_ALPHA
        CMP.w #$0044 : BEQ BRANCH_ALPHA
        CMP.w #$001A : BCC BRANCH_ALPHA ; Invisible door    
        CMP.w #$0040 : BEQ BRANCH_ALPHA
        CMP.w #$0046 : BEQ BRANCH_ALPHA
        
        LDA $0400 : ORA $98C0, X : STA $0400
    
    BRANCH_ALPHA:
    
        ; Load the door type
        LDY $0A
        
        INX #2 : STX $0460
        
        CPY.w #$0032 : BEQ BRANCH_DELTA ; Sword slash door
        CPY.w #$0008 : BEQ BRANCH_DELTA ; Waterfall door
        
        ; Branch away if not a trap door
        LDA $04 : CMP.w #$001A : BNE BRANCH_EPSILON ; Invisible door
        
        ; \task If this is truly for invisible doors, we should be able
        ; to set a breakpoint here and have this never really... fire?
        ; Find out!
        
        ; Check Link's direction
        LDA $2F : AND.w #$00FF : STA $0A
        
        DEX #2
        
        TXA : XBA : STA $0436
        
        ; Load the direction of the door
        LDA $00 : AND.w #$0003 : ASL A : ORA $0436 : STA $0436
        
        AND.w #$00FF : CMP $0A : BNE BRANCH_ZETA
        
        EOR.w #$0002 : CMP $0A : BEQ BRANCH_DELTA
    
    BRANCH_ZETA:
    
        LDA $068C : ORA $98C0, X : STA $068C
        
        LDY.w #$0000
    
    BRANCH_EPSILON:
    
        SEC
        
        RTS
    
    BRANCH_DELTA:
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$B191-$B19D LOCAL
    {
        STA $0E
        
        ; i.e. goto CLC; RTS
        LDA [$BF], Y : AND.w #$03FF : CMP $0E : BEQ Door_Register_BRANCH_DELTA
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $B19E-$B1A3 LOCAL
    Door_Prioritize7x4_Unreferenced:
    {
        ; Unreferenced routine (And this doesn't do anything different from
        ; what Door_Prioritize7x4 would do anyways.
        
        TAX
        
        LDA.w #$0007
        
        BRA Door_Prioritize7x4_variable
    }

; ==============================================================================

    ; *$B1A4-$B1E0 LOCAL
    Door_Prioritize7x4:
    {
        ; adds priority bit to a 7 row by 4 column region of tiles 
        TAX
        
        LDA.w #$0007
    
    .variable
    
        STA $0E
    
    .nextRow
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2002, X : ORA.w #$2000 : STA $7E2002, X
        LDA $7E2004, X : ORA.w #$2000 : STA $7E2004, X
        LDA $7E2006, X : ORA.w #$2000 : STA $7E2006, X
        
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE .nextRow
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $B1E1-$B1E6 LOCAL
    Door_Prioritize4x7:
    {
        TAX
        
        LDA.w #$0007
        
        BRA Door_Prioritize4x5_variable
    }

; ==============================================================================

    ; *$B1E7-$B21F LOCAL
    Door_Prioritize4x5:
    {
        ; adds priority bit to a 4 row by 5 column region of tiles
        TAX
        
        LDA.w #$0005
    
    .variable
    
        STA $0E
    
    .nextColumn
    
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2080, X : ORA.w #$2000 : STA $7E2080, X
        LDA $7E2100, X : ORA.w #$2000 : STA $7E2100, X
        LDA $7E2180, X : ORA.w #$2000 : STA $7E2180, X
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$B220-$B253 JUMP LOCATION
    Object_Draw2x4s_VariableOffset:
    {
        STA $0E
    
    .alpha
    
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$C2], Y
        LDA $9B56, X : STA [$C5], Y
        LDA $9B58, X : STA [$C8], Y
        LDA $9B5A, X : STA [$CB], Y
        LDA $9B5C, X : STA [$CE], Y
        LDA $9B5E, X : STA [$D1], Y
        LDA $9B60, X : STA [$D4], Y
        
        TYA : ADD.w $0E : TAY
        
        DEC $B2 : BNE .alpha
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $B254-$B263 LOCAL
    {
        STA $0E
    
    .next_block
    
        JSR Object_Draw2x2_AdvanceDown
        
        TXA : ADD.w #$0008 : TAX
        
        DEC $0E : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $B264-$B278 LOCAL
    {
        LDA $B2 : BEQ .terminated
    
    .loop
    
        LDA.w #$0002
        
        JSR Object_Draw4xN
        
        TXA : SUB.w #$0010 : TAX
        
        DEC $B2 : BNE .loop
    
    .terminated
    
        RTS
    }

; ==============================================================================

    ; *$B279-$B292 LOCAL
    Object_Draw5x1:
    {
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        LDA $9B58, X : STA [$DA], Y
        LDA $9B5A, X : STA [$DD], Y
        
        RTS
    }

; ==============================================================================

    ; *$B293-$B2AE BLOCK
    {
    
    BRANCH_ALPHA:
    
        JSR Object_Draw5x1
        
        TYA : ADD.w #$0082 : TAY
    
    ; *$B29C ALTERNATE ENTRY POINT
    
        DEC $B2 : BNE BRANCH_ALPHA
        
        RTS
    
    BRANCH_BETA:
    
        JSR Object_Draw5x1
        
        TYA : SUB.w #$007E : TAY
    
    ; *$B2AA ALTERNATE ENTRY POINT
    
        DEC $B2 : BNE BRANCH_BETA
        
        RTS
    }

; ==============================================================================

    ; *$B2AF-$B2C9 LOCAL
    Object_Draw2x2_AdvanceDown:
    {
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$C2], Y
        LDA $9B58, X : STA [$CE], Y
        
        TYA : ADD.w #$0100 : TAY
        
        RTS
    }

; ==============================================================================

    ; *$B2CA-$B2E0 LOCAL
    {
        INX #2
        INY #2
    
    ; *$B2CE ALTERNATE ENTRY POINT
    
        LDA $B2
    
    ; *$B2D0 ALTERNATE ENTRY POINT
    
        STA $0A
        
        LDA $9B52, X
    
    .nextColumn
    
        STA [$BF], Y
        
        INY #2
        
        DEC $0A : BNE .nextColumn
        
        ; addition is going to happen in the return routine
        ; funky setup... I know...
        LDA $08 : CLC
        
        RTS
    }

; ==============================================================================

    ; *$B2E1-$B2F5 JUMP LOCATION
    Object_Draw4x1:
    {
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        LDA $9B58, X : STA [$DA], Y
        
        RTS
    }

; ==============================================================================

    ; *$B2F6-$B305 JUMP LOCATION
    Object_Draw3x1:
    {
        LDA $9B52, X : STA [$BF], Y
        LDA $9B54, X : STA [$CB], Y
        LDA $9B56, X : STA [$D7], Y
        
        RTS
    }

; ==============================================================================

    ; *$B306-$B30A JUMP LOCATION
    {
        ; Strange pot I don't recognize...
        ; Although the graphics don't display correctly, this
        ; pot is heavy, as in it needs at least power glove.
        ; Was dropped from the original game.
        
        LDA.w #$1010
        
        BRA Object_LargeLiftableBlock_drawQuadrant
    }

; ==============================================================================

    ; *$B30B-$B30F ALTERNATE ENTRY POINT
    ; Some other liftable object. graphics are messed up
    {
        LDA.w #$1212
        
        BRA Object_LargeLiftableBlock_drawQuadrant
    }

; ==============================================================================

    ; *$B310-$B375 ALTERNATE ENTRY POINT
    Object_LargeLiftableBlock:
    {
    
        ; Large liftable blocks in dungeons (requires powerglove)
        
        STY $08
        
        LDX.w #$0E62
        
        LDA.w #$2020
        
        JSR .drawQuadrant
        
        LDX.w #$0E6A
        LDA.w #$2121
        
        JSR .drawQuadrant
        
        LDA $08 : ADD.w #$0100 : TAY
        
        LDX.w #$0E72
        LDA.w #$2222
        
        JSR .drawQuadrant
        
        LDX.w #$0E7A
        LDA.w #$2323
    
    .drawQuadrant
    
        PHX
        
        LDX $042C
        
        STA $0500, X
        
        INC $042C : INC $042C
        
        LDA $BA : STA $0520, X
        
        TYA : STA $0540, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$2000 : STA $0540, X
    
    .onBg2
    
        LDA [$BF], Y : STA $0560, X
        LDA [$CB], Y : STA $0580, X
        LDA [$C2], Y : STA $05A0, X
        LDA [$CE], Y : STA $05C0, X
        
        PLX
        
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; *$B376-$B380 JUMP LOCATION
    {
        ; Horizontal row of pots or skulls (doesn't seem to be used though)
        
        JSR Object_Size1to16
    
    .next_block
    
        JSR Object_Pot
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$B381-$B394 JUMP LOCATION
    {
        ; Vertical row of pots (also seems unused :\)
        
        JSR Object_Size1to16
    
    .next_block
    
        JSR Object_Pot
        
        LDA $08 : ADD.w #$0100 : STA $08
        
        TAY
        
        DEC $B2 : BNE .next_block
        
        RTS
    }

; ==============================================================================

    ; *$B395-$B3E0 JUMP LOCATION
    Object_Pot:
    {
        ; Normal pots / skull pots
        PHX
        
        LDX $042C
        
        INC $042C : INC $042C
        
        LDA.w #$1111 : STA $0500, X
        
        ; Store this object's position in the object buffer to $0520, X
        LDA $BA : STA $0520, X
        
        ; Store it's tilemap position.
        TYA : STA $0540, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        ; If it's destined for BG0 make a note of that
        TYA : ORA.w #$2000 : STA $0540, X
    
    .onBg2
    
        LDA.w #$0D0E : STA $0560, X
        LDA.w #$0D1E : STA $0580, X
        LDA.w #$4D0E : STA $05A0, X
        LDA.w #$4D1E : STA $05C0, X
        
        PLX
        
        LDA $7EF3CA : BEQ .inLightWorld
        
        LDX.w #$0E92
    
    .inLightWorld
    
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; *$B3E1-$B473 JUMP LOCATION
    Object_BombableFloor:
    {
        ; Bombable Cracked floor object
        
        ; Is this dungeon room number 0x65 (special room in Gargoyle's Domain)
        LDA $A0 : CMP.w #$0065 : BNE .notInThatOneRoom
        
        ; If this pit has already been bombed open, don't make it a cracked floor.
        LDA $0402 : AND.w #$1000 : BEQ .notBombedOpenYet
        
        STZ $B2
        STZ $B4
        
        ; Tiles for a bombed open floor
        LDX.w #$05AA
        
        JMP Object_Hole
    
    .notInThatOneRoom
    .notBombedOpenYet
    
        STY $08
        
        LDA.w #$05BA : STA $0E
        
        LDX.w #$0220
        LDA.w #$3030
        
        JSR .draw2x2
        
        LDX.w #$0228
        LDA.w #$3131
        
        JSR .draw2x2
        
        LDA $08 : ADD.w #$0100 : TAY
        
        LDX.w #$0230
        LDA.w #$3232
        
        JSR .draw2x2
        
        LDX.w #$0238
        LDA.w #$3333
    
    .draw2x2
    
        PHX
        
        LDX $042C
        
        ; Store the tile attributes here.
        STA $0500, X
        
        ; Index into the next "object" that sets its own tile type
        INC $042C : INC $042C
        
        ; Save our position in the object stream
        ; (into $0520,X apparently)
        LDA $BA : STA $0520, X
        
        ; Store the tilemap position of the object
        TYA : STA $0540, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBG2
        
        TYA : ORA.w #$2000 : STA $0540, X
    
    .onBG2
    
        PHY
        
        LDY $0E
        
        LDA $9B52, Y : STA $0560, X
        LDA $9B54, Y : STA $0580, X
        LDA $9B56, Y : STA $05A0, X
        LDA $9B58, Y : STA $05C0, X
        
        TYA : ADD.w #$0008 : STA $0E
        
        PLY
        PLX
        
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; *$B474-$B47E JUMP LOCATION
    {
        ; horizontal line of moles (1.1.0xBD)
        
        JSR Object_Size1to16
    
    .nextMole
    
        JSR Object_Mole
        
        DEC $B2 : BNE .nextMole
        
        RTS
    }

; ==============================================================================

    ; *$B47F-$B492 JUMP LOCATION
    {
        ; vertical line of moles (1.1.96)
        JSR Object_Size1to16
    
    .nextMole
    
        JSR Object_Mole
        
        LDA $08 : ADD.w #$0100 : STA $08
        
        TAY
        
        DEC $B2 : BNE .nextMole
        
        RTS
    }

; ==============================================================================

    ; *$B493-$B4D5 LOCAL
    Object_Mole:
    {
        ; Single Mole (1.3.0x16)
        
        PHX
        
        LDX $042C : INC $042C : INC $042C
        
        ; Once the mole is whacked, these will be the tile attributes for the replacement tiles
        LDA.w #$4040 : STA $0500, X
        
        LDA $BA : STA $0520, X
        
        TYA : STA $0540, X
        
        LDA $BF : CMP.w #$4000 : BNE .onBg2
        
        TYA : ORA.w #$2000 : STA $0540, X
    
    .onBg2
    
        ; This will be the appearance of the mole after being whacked (the new CHR)
        LDA.w #$19D8 : STA $0560, X
        LDA.w #$19D9 : STA $0580, X
        LDA.w #$59D8 : STA $05A0, X
        LDA.w #$59D9 : STA $05C0, X
        
        PLX
        
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; *$B4D6-$B508 LOCAL
    Dungeon_LoadBlock:
    {
        ; moveable block object
        
        LDX $042C : INC $042C : INC $042C
        
        STZ $0500, X
        
        LDA $BA : STA $0520, X
        
        TYA : STA $0540, X : AND.w #$3FFF : TAY
        
        ; store the tilemap entries that were underneath this block before it was
        ; placed on top
        LDA [$BF], Y : STA $0560, X
        LDA [$CB], Y : STA $0580, X
        LDA [$C2], Y : STA $05A0, X
        LDA [$CE], Y : STA $05C0, X
        
        LDX.w #$0E52
        
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; *$B509-$B53B LOCAL
    Dungeon_LoadTorch:
    {
        ; Load special lightable torch objects
        
        ; Store the object's tilemap position
        LDY $042E
        
        ; position in the tilemap of the torch
        STA $0540, Y
        
        DEX #2
        
        ; Store the object's position on the object stream.
        TXA : STA $0520, Y
        
        INC $042E : INC $042E
        
        LDX.w #$0EC2
        
        LDA $08 : ASL A : BCC .notPermanentlyLit
        
        ; permanently lit torch like in Ganon's room? (or in place where your uncle dies?)
        LDX.w #$0ECA
        
        ; There's a maximum of 3 light levels in a dark room.
        LDA $045A : CMP.w #$0003 : BCS .maxLightLevelReached
        
        INC $045A
    
    .notPermanentlyLit
    .maxLightLevelReached
    
        STX $0C
        
        LDA $08 : AND.w #$3FFF : TAY
        
        JMP Object_Draw2x2
    }

; ==============================================================================

    ; $B53C - $B55F NULL (use for expansion)

; ==============================================================================

    ; $B560-$B563 DATA
    DungeonHeader_SpecialAdjustment:
    {
        ; First value is for entering a room facing, right, the second
        ; is for entering a room facing left. This might actually
        ; be for intraroom transitions, but I'm not sure yet.
        ; This might not even be used in actual gameplay ever...
        dw 256, -256
    }

; ==============================================================================

    ; *$B564-$B758 LOCAL
    Dungeon_LoadHeader:
    {
        STZ $0642
        STZ $0646
        STZ $0641
        
        REP #$30
        
        ; Load submodule index
        LDA $11 : AND.w #$00FF : BNE .nonDefaultSubmodule
        
        ; BG1 horizontal scroll register.
        LDA $E2 : AND.w #$FE00 : STA $062C
        
        ; BG1 vertical scroll register.
        LDA $E8
        
        BRA .setLowerBoundY
    
    .nonDefaultSubmodule
    
        CMP.w #$0015 : BEQ .specialAdjustX
        CMP.w #$0012 : BCS .noSpecialAdjustX
        CMP.w #$0006 : BCC .noSpecialAdjustX
    
    .specialAdjustX
    
        ; Submodules 0x06 - 0x11 and 0x15 have this adjustment.
        LDA $E2 : ADD.w #$0020
        
        BRA .setLowerBoundX
    
    .noSpecialAdjustX
    
        LDA $67 : AND.w #$000F : LSR A : CMP.w #$0002 : BCS .walkingUpOrDown
        
        ASL A : TAX
        
        LDA $E2 : ADD.l DungeonHeader_SpecialAdjustment, X
    
    .setLowerBoundX
    
        AND.w #$FE00 : STA $062C
        
        LDA $E8 : ADD.w #$0020
        
        BRA .setLowerBoundY
    
    .walkingUpOrDown
    
        LSR #3 : TAX
        
        LDA $E2 : ADD.w #$0020 : AND.w #$FE00 : STA $062C
        
        LDA $E8 : ADD.l DungeonHeader_SpecialAdjustment, X
    
    .setLowerBoundY
    
        AND.w #$FE00 : STA $062E
        
        ; Load the dungeon room offset.
        LDA $A0 : ASL A : TAX
        
        ; the below is $27502, X in ROM
        ; Get the offset for the base header information    
        LDA $04F502, X : STA $0D
        
        SEP #$20
        REP #$10
        
        ; $0D = $04XXXX. I.e. $0F contains the bank number.
        LDA.b #$04 : STA $0F
        
        ; Save whatever this value is...
        LDA $0414 : STA $7EC208
        
        LDY.w #$0000
        
        ; Load the 0th (first) byte of the header.
        ; "BG2" in HM
        LDA [$0D], Y : AND.b #$E0 : ASL A : ROL #3 : STA $0414
        
        ; "collision" in HM
        LDA [$0D], Y : AND.b #$1C : LSR #2 : STA $046C
        
        ; Save whether to turn the lights out or not.
        LDA $7EC005 : STA $7EC006
        
        LDA [$0D], Y : AND.b #$01 : STA $7EC005
        
        REP #$20
        
        ; Move to byte 1. Loads a master palette number
        INY : LDA [$0D], Y : AND.w #$00FF : ASL #2 : TAX
        
        SEP #$20
        
        ; Load Palette indices
        LDA $0ED460, X : STA $0AB6  ; BG Palette index
        LDA $0ED461, X : STA $0AAC  ; SP index 0
        LDA $0ED462, X : STA $0AAD  ; SP index 1
        LDA $0ED463, X : STA $0AAE  ; SP index 2
        
        ; Move to byte 2. (Sprite graphics index)
        INY : LDA [$0D], Y : STA $0AA2
        
        ; Move to byte 3. (BG graphics index)
        INY : LDA [$0D], Y : ADD.b #$40 : STA $0AA3
        
        ; Move to byte 4. Basically sets uh.... moving floor settings.
        INY : LDA [$0D], Y : STA $AD
        
        ; Move to byte 5. Corresponds to Tag1 in Hyrule Magic.
        INY : LDA [$0D], Y : STA $AE
        
        ; Move to byte 6. Corresponds to Tag2 in Hyrule Magic
        INY : LDA [$0D], Y : STA $AF
        
        ; Move to byte 7.
        INY
        
        ; Teleporter plane
        LDA [$0D], Y : AND.w #$03 : STA $063C
        
        ; Staircase 1 plane
        LDA [$0D], Y : AND.b #$0C : LSR #2 : STA $063D
        
        ; Staircase 2 plane
        LDA [$0D], Y : AND.b #$30 : LSR #4 : STA $063E
        
        ; Staircase 3 / Door plane
        LDA [$0D], Y : AND.b #$C0 : ASL A : ROL A : ROL A : STA $063F
        
        ; Move to byte 8. (Staircase 4 / Door plane)
        INY : LDA [$0D], Y : AND.b #$03 : STA $0640
        
        ; Move to byte 9 (Teleporter room)
        INY : LDA [$0D], Y : STA $7EC000
        
        ; Move to byte A (Staircase 1 room)
        INY : LDA [$0D], Y : STA $7EC001
        
        ; Move to byte B (Staircase 2 room)
        INY : LDA [$0D], Y : STA $7EC002
        
        ; Move to byte C (Staircase 3 / Door room)
        INY : LDA [$0D], Y : STA $7EC003
        
        ; Move to byte D (Staircase 4 / Door room)
        INY : LDA [$0D], Y : STA $7EC004
        
        ; We're done with the header after reading out 14 (0x0E) bytes.
        
        REP #$30
        
        ; Put trap doors down initially.
        LDA.w #$0001 : STA $0468
        
        ; initialize dungeon overlay variable to default
        STZ $04BA
        
        ; X = $0110 = ($A0 * 3)
        LDA $A0 : ASL A : ADD $A0 : STA $0110 : TAX
        
        LDA $1F83C1, X : STA $B8
        LDA $1F83C0, X : STA $B7
        
        LDA $A0 : ASL A : TAX
        
        ; Access the dungeon room's saved data (1 word)
        LDA $7EF000, X : AND.w #$F000 : STA $0400
        
        ORA.w #$0F00 : STA $068C
        
        LDA $7EF000, X : AND.w #$0FF0 : ASL #4 : STA $0402
        
        LDA $7EF000, X : AND.w #$000F : STA $0408
        
        ; ...Okay, done loading save game data.
        
        LDX.w #$0000 : TXY
    
    .nextDoor
    
        STZ $19A0, X
        
        ; Load Door object information.
        LDA [$B7], Y : CMP.w #$FFFF : BEQ .nullDoor
        
        ; Write to this array until we hit a 0xFFFF value.
        STA $19A0, X
        
        INY #2
        INX #2
        
        BRA .nextDoor
    
    .nullDoor
    
        LDA $A0 : DEC A : TAX
        
        ; Checks to see if the room is a multiple of 0x10
        ; Room is a multiple of $10
        AND.w #$000F : CMP.w #$000F : BEQ .divisible_by_16
        
        ; All others
        LDA.w #$0024
        
        JSR Dungeon_CheckAdjacentRoomOpenedDoors
    
    .divisible_by_16
    
        LDA $A0 : INC A : TAX
        
        ; Checks to see if the room is right before a room that's a multiple of 0x10. I.e. ends in 0xF
        AND.w #$000F : BEQ .endsInF
        
        ; All others
        LDA.w #$0018
        
        JSR Dungeon_CheckAdjacentRoomOpenedDoors
    
    .endsInF
    
        ; Checks to see if it's one of the first $F rooms
        LDA $A0 : SUB.w #$0010 : TAX : BMI .first_F_rooms
        
        LDA.w #$000C
        
        JSR Dungeon_CheckAdjacentRoomOpenedDoors
    
    .first_F_rooms
    
        LDA $A0 : ADD.w #$0010 : TAX
        
        ; If room is one of the last $F rooms
        CMP.w #$0140 : BCS .last_F_rooms
        
        LDA.w #$0000
        
        JSR Dungeon_CheckAdjacentRoomOpenedDoors
    
    .last_F_rooms
    
        SEP #$20
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$B759-$B7EE LOCAL
    Dungeon_CheckAdjacentRoomOpenedDoors:
    {
        ; ARGUMENTS: A -> $04 and X -> $0E
        STA $04
        
        JSR Dungeon_LoadAdjacentRoomDoors
        
        LDY.w #$0000
    
    .nextDoor
    
        LDA $1110, Y : CMP.w #$FFFF : BEQ Dungeon_LoadHeader_return
        
        STA $02
        
        LDX $04
        
        AND.w #$00FF
        
                 CMP $9AA2, X : BEQ .matchPosition
        INX #2 : CMP $9AA2, X : BEQ .matchPosition
        INX #2 : CMP $9AA2, X : BEQ .matchPosition
        INX #2 : CMP $9AA2, X : BEQ .matchPosition
        INX #2 : CMP $9AA2, X : BEQ .matchPosition
        INX #2 : CMP $9AA2, X : BNE .skipDoor
    
    .matchPosition
    
        LDA $9AD2, X : STA $00
        
        LDX.w #$0000
    
    .tryNextDoor
    
        ; Check out the door's position (direction, orientation, and two unused bits.)
        LDA $19A0, X : AND.w #$00FF : CMP $00 : BEQ .match
        
        INX #2 : CPX.w #$0010 : BNE .tryNextDoor
        
        BRA .skipDoor
    
    .match
    
        LDA $19A0, X : AND.w #$FF00
        
        CMP.w #$3000 : BEQ .skipDoor
        CMP.w #$4400 : BEQ .trapDoor
        CMP.w #$1800 : BNE .notTrapDoor
    
    .trapDoor
    
        LDA $0E : CMP $A2 : BNE .skipDoor
        
        STZ $0468
        
        BRA .openDoor
    
    .notTrapDoor
    
        LDA $1100 : AND $98C0, Y : BEQ .skipDoor
    
    .openDoor
    
        ; Open a door in this room because of a corresponding open door
        ; in an adjacent room.
        LDA $068C : ORA $98C0, X : STA $068C
    
    .skipDoor
    
        INY #2 : CPY.w #$0010 : BEQ .return
        
        JMP .nextDoor
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$B7EF-$B83D LOCAL
    Dungeon_LoadAdjacentRoomDoors:
    {
        STX $0E
        
        ; X = the other room's index multiplied by 3.
        TXA : ASL A : ADD $0E : TAX
        
        LDA $1F83C1, X : STA $B8
        LDA $1F83C0, X : STA $B7
        
        LDA $0E : ASL A : TAX
        
        ; Obtain the door data for the given room.
        LDA $7EF000, X : AND.w #$F000 : ORA.w #$0F00 : STA $1100
        
        LDX.w #$0000 : TXY
    
    .nextDoor
    
        ; Loop until we see the terminator word (0xFFFF).
        LDA [$B7], Y : STA $1110, X : CMP.w #$FFFF : BEQ Dungeon_CheckAdjacentRoomOpenedDoors_return
        
        ; Check to see if the 0x4000 bit is set.
        AND.w #$FF00
        
        ; Checks to see if it's a 2.32 object (that type of door, i mean).
        CMP.w #$4000 : BEQ .beta
        CMP.w #$0200 : BCS .notDefaultDoor
    
    .beta
    
        ; Or in a bit that corresponds to the door's position in the buffer
        ; (0x8000, 0x4000, 0x2000, etc...)
        LDA $1100 : ORA $98C0, X : STA $1100
    
    .notDefaultDoor
    
        INY #2
        INX #2
        
        BRA .nextDoor
    }

; ==============================================================================

    ; *$B83E-$B8A7 LONG
    Dungeon_ApplyOverlay:
    {
        REP #$30
        
        LDA $BA : BNE .preloaded_pointer
        
        STZ $045E
        
        ; X = $04BA * 3
        LDA $04BA : ASL A : ADD $04BA : TAX
        
        ; Dungeon overlay data
        LDA.l .ptr_table + 1, X : STA $B8
        LDA.l .ptr_table + 0, X : STA $B7
        
        JSR Dungeon_DrawOverlay
        
        REP #$30
        
        STZ $BA
        STZ $045E
    
    .preloaded_pointer
    
        STZ $0C
    
    .next_object
    
        LDY $BA
        
        LDA [$B7], Y : CMP.w #$FFFF : BEQ .end_of_data
        
        STA $00
        
        SEP #$20
        
        LDA [$B7], Y : AND.b #$FC : STA $08
        
        INY #2
        
        LDA $01 : LSR #3 : ROR $08 : STA $09
        
        INY : STY $BA
        
        REP #$20
        
        LDA $08
        
        PHA
        
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        PLA
        
        JSR Dungeon_ApplyOverlayAttr
        
        BRA .next_object
    
    .end_of_data
    
        LDY $0C
        
        LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        ; Set a graphics flag.
        LDA.b #$01 : STA $18
        
        STZ $11
        
        RTL
    }

; ==============================================================================

    ; $B8A8-$B8B3 Jump Table
    Dungeon_LoadAttrSelectable_jumpTable:
    {
        dw Dungeon_LoadBasicAttr
        dw Dungeon_LoadBasicAttr_partial ; load the tile attributes differently?
        dw Dungeon_LoadObjAttr
        dw Dungeon_LoadDoorAttr
        dw Dungeon_InitBarrierAttr
        dw Dungeon_LoadBasicAttr_easyOut ; (RTS)
    }

; ==============================================================================

    ; *$B8B4-$B8BE LONG
    Dungeon_LoadAttrSelectable:
    {
        LDA $0200 : ASL A : TAX
        
        JSR (Dungeon_LoadAttrSelectable_jumpTable, X)
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    !numTiles      = $00
    !leftTileAttr  = $02
    !rightTileAttr = $04
    !tileOffset    = $B2
    !attrOffset    = $B4

    ; *$B8BF-$B8E2 LONG
    Dungeon_LoadAttrTable:
    {
        REP #$20
        
        STZ !tileOffset
        STZ !attrOffset
        
        LDA.w #$1000 : STA !numTiles
        
        JSR Dungeon_LoadBasicAttr_full
        
        SEP #$30
        
        JSR Dungeon_LoadObjAttr
        JSR Dungeon_LoadDoorAttr
        
        LDA $7EC172 : BEQ .dontFlipBarrierAttr
        
        JSL Dungeon_ToggleBarrierAttr ; $C22A IN ROM
    
    .dontFlipBarrierAttr
    
        STZ $0200
        
        RTL
    }

; ==============================================================================

    ; *$B8E3-$B966 JUMP LOCATION
    Dungeon_LoadBasicAttr:
    {
    .transition
        ; Notes about this routine:
        ; $04 is the behavior type of the tile just to the right of the current tile
        ; $02 is the behavior type of the current tile
        
        REP #$20
        
        INC $0200
        
        ; These are counters that are initialized
        STZ !tileOffset
        STZ !attrOffset
    
    ; *$B8EC ALTERNATE ENTRY POINT
    .partial
    
        REP #$20
        
        LDA.w #$0040 : STA !numTiles
    
    ; *$B8F3 ALTERNATE ENTRY POINT
    .full
    
        PHB : LDX.w #$7E : PHX : PLB
        
        REP #$10
    
    .nextTilePair
    
        LDX !tileOffset
        
        ; Load a tile's properties from the tile's character value.
        LDA $7E2002, X : AND.w #$03FF : TAY
        
        ; Obtains a the behavior associated with this graphical tile.
        ; e.g. chests have a behavior associated with their tile type.
        LDA $FE00, Y : STA !rightTileAttr
        
        ; Y = CHR value
        LDA $7E2000, X : AND.w #$03FF : TAY
        
        SEP #$20
        
        ; if tile type < 0x10
        LDA $FE00, Y : CMP.b #$10 : BCC .tileIgnoresFlip
        
        CMP.b #$1C
        
        ; if tyle type >= 0x1C
        BCS .tileIgnoresFlip
        
        ; tile types >= $10 and < $1C pay attention to
        ; v and hflip properties.
        LDA $7E2001, X : ASL A : ROL A : ROL A : AND.b #$03 : ORA $FE00, Y
    
    .tileIgnoresFlip
    
        STA !leftTileAttr
        
        ; Same as for the current tile, look at hFlip/vFlip ...
        LDA !tileAttr
        
        CMP.b #$10 : BCC .tileIgnoresFlip2
        CMP.b #$1C : BCS .tileIgnoresFlip2
        
        LDA $7E2003, X : ASL A : ROL #2 : AND.w #$03 : ORA !rightTileAttr
    
    .tileIgnoresFlip2
    
        XBA
        
        ; Load the tile behavior for the left
        LDA !leftTileAttr
        
        REP #$21
        
        ; Store the tile attributes for the current two tiles
        LDX !attrOffset : STA $7F2000, X : INX #2 : STX !attrOffset
        
        LDA !tileOffset : ADC.w #$0004 : STA !tileOffset
        
        DEC !numTiles : BNE .nextTilePair
        
        ; If we've reached the end of the tile attribute table we're done.
        LDA !attrOffset : CMP.w #$2000 : BNE .notEndOfTable
        
        INC $0200
    
    .notEndOfTable
    
        PLB
    
    .easyOut
    
        RTS
    }

; ==============================================================================

    ; *$B967-$BDDA LOCAL
    Dungeon_LoadObjAttr:
    {
        REP #$30
        
        ; Tell me how many stars there are
        LDX $0432 : BEQ .noStars
        
        LDY.w #$0000
        LDA.w #$3B3B
    
    .nextStar
    
        ; Place 0x3B tiles attributes in a square matching the position of the star.
        LDX $06A0, Y
        
        STA $7F2000, X : STA $7F2040, X
        
        INY #2 : CPY $0432 : BNE .nextStar
    
    .noStars
    
        LDA.w #$3030 : STA $00
        
        LDY.w #$0000
        
        ; check the number of in-floor inter-room up-north staircases.
        LDX $0438 : BEQ .noInRoomUpStaircases
    
    .nextInRoomUpStaircase
    
        LDX $06B0, Y
        
        LDA.w #$0000 : STA $7F2081, X
        LDA.w #$2626 : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X
        ADD.w #$0101 : STA $00
        
        INY #2 : CPY $0438 : BNE .nextInRoomUpStaircase
    
    .noInRoomUpStaircases
    
        ; number of 1.2.0x38 objects.
        CPY $047E : BEQ .noSpiralUpStaircases
    
    .nextSpiralUpStaircases
    
        LDX $06B0, Y
        
        LDA.w #$5E5E : STA $7F2001, X : STA $7F2081, X : STA $7F20C1, X
        
        LDA $00 : STA $7F2041, X
        
        ADD.w #$0101 : STA $00
        
        INY #2 : CPY $047E : BNE .nextSpiralUpStaircases
    
    .noSpiralUpStaircases
    
        ; number of 1.2.0x3A objects.
        CPY $0482 : BEQ .noSpiralUpStaircases2
    
    .nextSpiralUpStaircase2
    
        LDX $06B0, Y
        
        LDA.w #$5F5F : STA $7F2001, X : STA $7F2081, X : STA $7F20C1, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $0482 : BNE .nextSpiralUpStaircase2
    
    .noSpiralUpStaircases2
    
        ; Number of 1.3.0x1E and 1.3.0x26 objects.
        CPY $04A2 : BEQ .noStraightUpStaircases
    
    .nextStraightUpStaircase
    
        LDX $06B0, Y
        
        LDA.w #$0000 : STA $7F2081, X : STA $7F20C1, X
        LDA.w #$3838 : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $04A2 : BNE .nextStraightUpStaircase
    
    .noStraightUpStaircases   
    
        ; Number of 1.3.0x20 and 1.3.0x28 objects.
        CPY $04A4 : BEQ .noStraightUpSouthStaircases
    
    .nextStraightUpSouthStaircase
    
        LDX $06B0, Y
        
        LDA.w #$0000 : STA $7F2001, X : STA $7F2041, X
        
        LDA.w #$3939 : STA $7F20C1, X
        
        LDA $00 : STA $7F2081, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $04A4 : BNE .nextStraightUpSouthStaircase
    
    .noStraightUpSouthStaircases
    
        LDA $00 : AND.w #$0707 : ORA.w #$3434 : STA $00
        
        ; Number of 1.2.0x2E and 1.2.0x2F objects
        CPY $043A : BEQ .noInRoomDownSouthStaircases
    
    .nextInRoomDownSouthStaircase
    
        LDX $06B0, Y
        
        LDA.w #$2626 : STA $7F20C1, X
        
        LDA $00 : STA $7F2081, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $043A : BNE .nextInRoomDownSouthStaircase
    
    .noInRoomDownSouthStaircases
    
        ; Number of 1.2.0x39 objects
        CPY $0480 : BEQ .noSpiralDownNorthStaircases
    
    .nextSpiralDownNorthStaircase
    
        LDX $06B0, Y
        
        LDA.w #$5E5E : STA $7F2001, X : STA $7F2081, X : STA $7F20C1, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $0480 : BNE .nextSpiralDownNorthStaircase
    
    .noSpiralDownNorthStaircases
    
        ; Number of 1.2.0x3B objects
        CPY $0484 : BEQ .noSpiralDownNorthStaircases2
    
    .nextSpiralDownNorthStaircase2
    
        LDX $06B0, Y
        
        LDA.w #$5F5F : STA $7F2001, X : STA $7F2081, X : STA $7F20C1, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $0484 : BNE .nextSpiralDownNorthStaircase2
    
    .noSpiralDownNorthStaircases2
    
        ; Number of 1.3.0x1F and 1.3.0x27 objects.
        CPY $04A6 : BEQ .noStraightDownNorthStaircases
    
    .nextStraightDownNorthStaircase
    
        LDX $06B0, Y
        
        LDA.w #$0000 : STA $7F2081, X : STA $7F20C1, X
        
        LDA.w #$3838 : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $04A6 : BNE .nextStraightDownNorthStaircase
    
    .noStraightDownNorthStaircases
    
        ; Number of 1.3.0x21 and 1.3.0x29 objects.
        CPY $04A8 : BEQ .noStraightDownSouthStaircases
    
    .nextStraightDownSouthStaircase
    
        LDX $06B0, Y
        
        LDA.w #$0000 : STA $7F2001, X : STA $7F2041, X
        
        LDA.w #$3939 : STA $7F20C1, X
        
        LDA $00 : STA $7F2081, X : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $04A8 : BNE .nextStraightDownSouthStaircase
    
    .noStraightDownSouthStaircases
    
        ; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ; end of staircases? fuck no the pain is just beginning
        LDY.w #$0000 : STY $02
        
        LDA.w #$1F1F
        
        LDX $043C : BNE .optimus
        
        INC $02
        
        LDA.w #$1E1E
        
        LDX $043E : BNE .optimus
        
        LDX $0440 : BEQ .ultima
        
        INC $02
        
        LDA.w #$1D1D
    
    .optimus
    
        STA $00
        
        LDA $02 : STA $044A
        
        STX $02
    
    .aleph
    
        LDX $06B8, Y
        
        LDA.w #$0002 : STA $7F2000, X : STA $7F30C0, X
        XBA          : STA $7F2002, X : STA $7F32C2, X
        
        LDA.w #$0001 : STA $7F2040, X : STA $7F3080, X
        XBA          : STA $7F2042, X : STA $7F3082, X
        
        LDA $00 : STA $7F2041, X : STA $7F3041, X : STA $7F2081, X : STA $7F3081, X
        
        INY #2 : CPY $02 : BNE .aleph
    
    .ultima
    
        CPY $0448 : BEQ .bet
        
        LDA.w #$0002 : STA $044A
    
    .gimmel
    
        LDX $06B8, Y
        
        LDA.w #$0A03 : STA $7F2000, X : STA $7F3000, X
        
        XBA : STA $7F2002, X : STA $7F3002, X
        
        LDA.w #$0803 : STA $7F2040, X
        
        XBA : STA $7F2042, X
        
        INY #2 : CPY $0448 : BNE .gimmel
    
    .bet
    
        LDY.w #$0000
        
        LDX $0442 : BEQ .dalet
        
        LDA.w #$0002 : STA $044A
    
    .hey
    
        LDX $06B8, Y
        
        LDA.w #$0003 : STA $7F2000, X
        XBA          : STA $7F2002, X
        
        LDA.w #$0A03 : STA $7F3000, X
        XBA          : STA $7F3002, X
        
        LDA.w #$0808 : STA $7F2040, X : STA $7F2042, X
        
        INY #2 : CPY $0442 : BNE .hey
    
    .dalet
    
        CPY $0444 : BEQ .noActiveWaterLadders
        
        LDA.w #$0002 : STA $044A
    
    .nextActiveWaterLadder
    
        LDX $06B8, Y
        
        LDA.w #$0003 : STA $7F2000, X : XBA : STA $7F2002, X
        LDA.w #$0A03 : STA $7F3000, X : XBA : STA $7F3002, X
        
        INY #2 : CPY $0444 : BNE .nextActiveWaterLadder
    
    .noActiveWaterLadders
    
        LDY.w #$0000
        
        ; no misc objects
        LDX $042C : BEQ .chet
        
        LDA.w #$7070 : STA $00
    
    .nextMiscObject
    
        ; Check the replacement tile attributes
        ; if attribute & 0xF0 == 0x30, skip
        LDA $0500, Y : AND.w #$00F0 : CMP.w #$0030 : BEQ .skipMiscObject
        
        ; Check the tilemap address
        LDA $0540, Y : AND.w #$3FFF : LSR A : TAX
        
        LDA $00 : STA $7F2000, X : STA $7F2040, X
    
    .skipMiscObject
    
        LDA $00 : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $042C : BNE .nextMiscObject
    
    .chet
    
        CPY $042E : BEQ .noTorches
        
        STZ $04
        
        LDA.w #$C0C0 : STA $00
    
    .nextTorch
    
        LDA $0540, Y : AND.w #$3FFF : LSR A : TAX
        
        LDA $00 : STA $7F2000, X : STA $7F2040, X
        
        ; first torch uses 0xC0C0, second uses 0xC1C1, etc...
        AND.w #$EFEF : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $042E : BNE .nextTorch
        
        LDA $04 : STA $042E
    
    .noTorches
    
        ; The code for chest tile information. (base code anyways)
        LDA.w #$5858 : STA $00
        
        LDA.w #$0000
        
        LDX $0496 : BEQ .noChests
        
        LDA $AE : AND.w #$00FF
        
        CMP.w #$0027 : BEQ .hasHiddenChest
        CMP.w #$003C : BEQ .hasHiddenChest
        CMP.w #$003E : BEQ .hasHiddenChest
        CMP.w #$0029 : BCC .checkTag2 ; If $AE < 0x29
        CMP.w #$0033 : BCC .hasHiddenChest
    
    .checkTag2
    
        ; Load Tag2 properties
        LDA $AF : AND.w #$00FF
        
        CMP.w #$0027 : BEQ .hasHiddenChest
        CMP.w #$003C : BEQ .hasHiddenChest
        CMP.w #$003E : BEQ .hasHiddenChest
        CMP.w #$0029 : BCC .noHiddenChests ; If $AF < #$29
        CMP.w #$0033 : BCC .hasHiddenChest ; If $AF < #$33
    
    .noHiddenChests
    
        JSR Dungeon_SetChestAttr
    
    .noChests
    
        ; Number of Big Key Locks
        CPY $0498 : BEQ .noBigKeyLocks
    
    .nextBigKeyLock
    
        ; tells the game engine that this one is a big key lock instead of a big chest
        LDA $06E0, Y : ORA.w #$8000 : STA $06E0, Y
        
        AND.w #$7FFF : LSR A : TAX
        
        LDA $00 : STA $7F2000, X : STA $7F2040, X
        
        ADD.w #$0101 : STA $00
        
        INY #2 : CPY $0498 : BNE .nextBigKeyLock
    
    .noBigKeyLocks
    .hasHiddenChest
    
        LDY.w #$0000 : STY $02
        
        LDA.w #$3F3F
        
        LDX $049A : BNE .pey
        
        INC $02
        
        LDA.w #$3E3E
        
        ; interesting to note that $049A being nonzero would exclude $049C ever being used
        LDX $049C : BNE .pey
        
        LDX $049E : BEQ .fey
        
        INC $02
        
        LDA.w #$3D3D
    
    .pey
    
        STA $00
        
        LDA $02 : STA $044A
        
        STX $02
    
    .tsadie
    
        LDX $06EC, Y
        
        LDA.w #$0002 : STA $7F3000, X : STA $7F20C0, X
        LDA.w #$0001 : STA $7F3040, X : STA $7F2080, X
        LDA.w #$0200 : STA $7F3002, X : STA $7F20C2, X
        LDA.w #$0100 : STA $7F3042, X : STA $7F2082, X
        
        LDA $00 : STA $7F2041, X : STA $7F3041, X : STA $7F2081, X : STA $7F3081, X
        
        INY #2 : CPY $02 : BNE .tsadie
    
    .fey
    
        LDY.w #$0000
        
        LDX $04AE : BEQ .qof
        
        LDA.w #$0002 : STA $044A
    
    .resh
    
        LDX $06EC, Y
        
        LDA.w #$0A03 : STA $7F30C0, X : XBA : STA $7F30C2, X
        LDA.w #$0003 : STA $7F20C0, X : XBA : STA $7F20C2, X
        
        LDA.w #$0808 : STA $7F2080, X : STA $7F2082, X
        
        INY #2 : CPY $04AE : BNE .resh
    
    .qof
    
        INC $0200
        
        RTS
    }

; ==============================================================================

    ; *$BDDB-$BE16 LOCAL
    Dungeon_SetChestAttr:
    {
        ; This routine loads tile attribute information for chests and big chests
    
    .nextChest
    
        LDA $06E0, Y : BEQ .getNextChestAttr
        
        AND.w #$7FFF : LSR A : TAX
        
        ; Write the tile type to memory. (In my case, chests); So it would look like 0x5858, 0x5959, etc�
        LDA $00 : STA $7F2000, X : STA $7F2040, X
        
        LDA $06E0, Y : ASL A : BCC .getNextChestAttr
        
        ; It�s a big chest, handle it appropriately.
        LSR A : STA $06E0, Y
        
        ; Must apply this property over a larger area.
        LDA $00 : STA $7F2042, X : STA $7F2080, X : STA $7F2082, X
    
    .getNextChestAttr
    
        ; Add #$0101, makes sense b/c the next chest is 0x5959� etc.
        LDA $00 : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $0496 : BNE .nextChest
        
        RTS
    }

; ==============================================================================

    ; *$BE17-$BE34 LOCAL
    Dungeon_LoadDoorAttr:
    {
        REP #$30
        
        LDY.w #$0000
    
    .nextDoor
    
        ; Look at the tile address of each door.
        ; If zero, skip this door (doesn't exist)
        LDA $19A0, Y : BEQ .skipDoor
        
        JSR Dungeon_LoadSingleDoorAttr
    
    .skipDoor
    
        INY #2 : CPY.w #$0020 : BNE .nextDoor
        
        JSR $D51F ; $D51F IN ROM; Load door tile attributes
        JSR $C1BA ; $C1BA IN ROM; Random ass routine for an unfinished object
        
        INC $0200
        
        RTS
    }

; ==============================================================================

    ; *$BE35-$BFB1 LOCAL
    Dungeon_LoadSingleDoorAttr:
    {
        ; Low byte is the object type.
        ; Dat is sum long list o' doors
        LDA $1980, Y : AND.w #$00FE : STA $02
        
                       BEQ BRANCH_ALPHA
        CMP.w #$0006 : BEQ BRANCH_ALPHA
        CMP.w #$0012 : BEQ BRANCH_ALPHA
        CMP.w #$000A : BEQ BRANCH_ALPHA
        CMP.w #$000C : BEQ BRANCH_BETA
        CMP.w #$000E : BEQ BRANCH_ALPHA
        CMP.w #$0010 : BEQ BRANCH_BETA ; Other special doors report to branch_beta
        CMP.w #$0004 : BEQ BRANCH_BETA
        CMP.w #$0002 : BEQ BRANCH_BETA
        CMP.w #$0008 : BNE BRANCH_GAMMA ; everything else...
    
    BRANCH_BETA:
    
        JMP $C0B8 ; $C0B8 IN ROM
    
    BRANCH_GAMMA:
    
        CMP.w #$0030 : BNE .notBlastWall
        
        JMP Door_LoadBlastWallAttrStub
    
    .notBlastWall
    
        CMP.w #$0040 : BCC BRANCH_EPSILON
        
        JMP $C085 ; $C085 IN ROM
    
    BRANCH_EPSILON:
    
        CMP.w #$0018 : BEQ BRANCH_ZETA
        
        ; wondering how this point would ever be reached...
        ; (see the if(type < 0x0040) earlier)
        CMP.w #$0044 : BEQ BRANCH_ZETA
        
        TYA : AND.w #$000F
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        TYA : AND.w #$00FF
    
    BRANCH_THETA:
    
        TAX
        
        LDA $068C : AND $98C0, X : BNE BRANCH_ALPHA
        
        SEP #$20
        
        TYA : LSR A : ORA.b #$F0 : STA $00 : STA $01
        
        REP #$20
        
        LDA $19A0, Y : LSR A : TAX
        
        LDA $00 : STA $7F2041, X : STA $7F2081, X
    
    .return
    
        RTS
    
    BRANCH_ALPHA:
    
        LDX $02
        
        CPX.w #$0020 : BCC .lockedStaircaseCover
        CPX.w #$0028 : BCC .return
    
    .lockedStaircaseCover
    
        ; Load tile attributes to fill in for the door's passage way.
        LDA $9A52, X : STA $00
        
        ; check if it's an up door?
        LDA $19C0, Y : AND.w #$0003 : BNE .notUpDoor
        
        ; is an up door?
        LDA $19A0, Y
        
        CMP $19E2 : BEQ .isUpExitDoor
        CMP $19E4 : BEQ .isUpExitDoor
        CMP $19E6 : BEQ .isUpExitDoor
        CMP $19E8 : BNE .notUpExitDoor
    
    .isUpExitDoor
    
        LDX.w #$8E8E : STX $00
    
    .notUpExitDoor
    
        LSR A : TAX
        
        LDA $00        : STA $7F2001, X
        STA $7F2041, X : STA $7F2081, X
        STA $7F20C1, X : STA $7F2101, X
        STA $7F2141, X : STA $7F2181, X
        
        LDA.w #$0000 : STA $7F21C1, X
        
        RTS
    
    .notUpDoor
    
        CMP.w #$0001 : BNE .notDownDoor
        
        LDA $19A0, Y
        
        ; Apparently these types are forced to be exit doors in this context?
        CPX.w #$000A : BEQ .isDownExitDoor
        CPX.w #$000E : BEQ .isDownExitDoor
        
        CMP $19E2 : BEQ .isDownExitDoor
        CMP $19E4 : BEQ .isDownExitDoor
        CMP $19E6 : BEQ .isDownExitDoor
        CMP $19E8 : BNE .notDownExitDoor
    
    .isDownExitDoor
    
        LDX.w #$8E8E : STX $00
    
    .notDownExitDoor
    
        LSR A : TAX
        
        LDA $00        : STA $7F2041, X
        STA $7F2081, X : STA $7F20C1, X
        STA $7F2101, X : STA $7F2141, X
        
        RTS
    
    .notDownDoor
    
        CMP.w #$0002 : BNE .notLeftDoor
        
        LDA $19A0, Y : LSR A : AND.w #$FFE0 : TAX
        
        LDA $00 : ADD.w #$0101
        
        STA $7F2040, X : STA $7F2042, X
        STA $7F2080, X : STA $7F2082, X
        
        AND.w #$00FF : STA $7F2044, X : STA $7F2084, X
        
        RTS
    
    .notLeftDoor
    
        LDA $19A0, Y : LSR A : TAX
        
        LDA $00 : ADD.w #$0101
        
        STA $7F2042, X : STA $7F2044, X
        STA $7F2082, X : STA $7F2084, X
        
        AND.w #$FF00 : STA $7F2040, X : STA $7F2080, X
        
        RTS
    }

; ==============================================================================

    ; *$BFB2-$BFB2 JUMP LOCATION
    Door_LoadBlastWallAttrStub:
    {
        ; This is handled somewhere else because a blast
        ; wall is much different from typical doors.
        RTS
    }

; ==============================================================================

    ; \unused
    ; *$BFB3-$BFC0 JUMP LOCATION
    {
        TYA : AND.W #$000F : TAX
        
        LDA $068C : AND $98C0, X : BNE .alpha
        
        RTS
    
    .alpha
    
        ; leads into the following routine.... code seems to be unused as far as I can tell
    }

; ==============================================================================

    ; *$BFC1-$C084 LOCAL
    Door_LoadBlastWallAttr:
    {
        LDA $19C0, Y : AND.w #$0002 : BNE .leftOrRightDoor
        
        LDA $19A0, Y : LSR A : TAX
        
        LDA.w #$000C : STA $00
    
    .nextRow
    
        LDA.w #$0102 : STA $7F2000, X
        
        LDA.w #$0000
        
        STA $7F2002, X : STA $7F2004, X : STA $7F2006, X : STA $7F2008, X
        STA $7F200A, X : STA $7F200C, X : STA $7F200E, X : STA $7F2010, X
        STA $7F2012, X
        
        LDA.w #$0201 : STA $7F2014, X
        
        TXA : ADD.w #$0040 : TAX
        
        DEC $00 : BNE .nextRow
        
        RTS
    
    .leftOrRightDoor
    
        ; I'm pretty sure this never occurs in the actual game (unused), as
        ; The only blast wall type door only takes on a blast wall appearance
        ; when the door direction is up. Perhaps Hyrule Magic is mistaken
        ; though? Wouldn't be the first time.
        LDA $19A0, Y : LSR A : TAX
        
        LDA.w #$0005 : STA $00
    
    .nextColumn
    
        LDA.w #$0101 : STA $7F2000, X : STA $7F2540, X
        LDA.w #$0202 : STA $7F2040, X : STA $7F2500, X
        
        LDA.w #$0000
        
        STA $7F2080, X : STA $7F20C0, X : STA $7F2100, X : STA $7F2140, X
        STA $7F2180, X : STA $7F21C0, X : STA $7F2200, X : STA $7F2240, X
        STA $7F2280, X : STA $7F22C0, X : STA $7F2300, X : STA $7F2340, X
        STA $7F2380, X : STA $7F23C0, X : STA $7F2400, X : STA $7F2440, X
        STA $7F2480, X : STA $7F24C0, X
        
        INX #2
        
        DEC $00 : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$C085-$C1B9 JUMP LOCATION
    {
        CMP.w #$0040 : BEQ .alpha
        CMP.w #$0046 : BEQ .alpha
        
        TYA : AND.w #$00FF : TAX
        
        LDA $068C : AND $98C0, X : BNE .alpha
        
        SEP #$20
        
        ; The low nybble of the attribute corresponds to the door's
        ; position in the door slots (array of door information).
        TYA : LSR A : ORA.b #$F0 : STA $00 : STA $01
        
        REP #$20
        
        LDA $19A0, Y : LSR A : TAX
        
        ; In the center (2x2) of the door, write this tile attribute value,
        ; which seems to always have upper nybble 0xf.
        LDA $00 : STA $7F2041, X : STA $7F2081, X
        
        RTS
    
    ; *$C0B8 ALTERNATE ENTRY POINT
    .alpha
    
        ; Load the door type
        LDX $02
        
        ; Load the tile attributes to use
        LDA $9A52, X : STA $00
        
        LDA $19C0, Y : AND.w #$0003 : BNE .notUpDoor
        
        LDA $19A0, Y : LSR A : AND.w #$783F : TAX
        
        LDA $00
        
        STA $7F2001, X : STA $7F2041, X
        STA $7F2081, X : STA $7F20C1, X
        STA $7F2101, X : STA $7F2141, X
        STA $7F2181, X : STA $7F21C1, X
        STA $7F2201, X : STA $7F2241, X
        
        RTS
    
    .notUpDoor
    
        CMP.w #$0001 : BNE .notDownDoor
        
        CPX.w #$000C : BEQ .isExitDoor
        CPX.w #$0010 : BEQ .isExitDoor
        CPX.w #$0004 : BEQ .isExitDoor
        
        LDA $19A0, Y : AND.w #$1FFF
        
        CMP $19E2 : BEQ .isExitDoor
        CMP $19E4 : BEQ .isExitDoor
        CMP $19E6 : BEQ .isExitDoor
        CMP $19E8 : BNE .notExitDoor
    
    .isExitDoor
    
        LDX.w #$8E8E : STX $00
    
    .notExitDoor
    
        LDA $19A0, Y : LSR A : ADD.w #$0040 : TAX
        
        LDA $00
        
        STA $7F2001, X : STA $7F2041, X
        STA $7F2081, X : STA $7F20C1, X
        STA $7F2101, X : STA $7F2141, X
        STA $7F2181, X : STA $7F21C1, X
        
        RTS
    
    .notDownDoor
    
        CMP.w #$0002 : BNE .notLeftDoor
        
        LDA $19A0, Y : LSR A : AND.w #$FFE0 : TAX
        
        LDA $00 : ADD.w #$0101
        
        STA $7F2040, X : STA $7F2042, X : STA $7F2044, X : STA $7F2046, X
        STA $7F2080, X : STA $7F2082, X : STA $7F2084, X : STA $7F2086, X
        
        RTS
    
    .notLeftDoor
    
        LDA $19A0, Y : LSR A : INC A : TAX
        
        LDA $00 : ADD.w #$0101
        
        STA $7F2040, X : STA $7F2042, X : STA $7F2044, X : STA $7F2046, X
        STA $7F2080, X : STA $7F2082, X : STA $7F2084, X : STA $7F2086, X
        
        RTS
    }

; ==============================================================================

    ; *$C1BA-$C21B LOCAL
    {
        ; The code in here seems experimental, and I don't think the object
        ; that would use this is even used the actual game anywhere.
        REP #$30
        
        LDA $04B0 : BEQ .return
        
        LDA $04B0 : AND.w #$3FFF : LSR A : TAX
        
        LDY.w #$0004
        
        LDA $04B0 : ASL A : BCC .normalSize
        
        ; Add one column of 16 pixels to this attribute mapping
        INY
    
    .normalSize
    
        LDA $0402 : AND.w #$1000 : BEQ .differentConfig
    
    .nextColumn
    
        LDA.w #$0101 : STA $7F2000, X : STA $7F2280, X
        
        LDA.w #$0000 : STA $7F2080, X : STA $7F2100, X : STA $7F2180, X : STA $7F2200, X
        
        INX #2
        
        DEY : BPL .nextColumn
        
        SEP #$30
        
        RTS
    
    .differentConfig
    .nextColumn2
    
        LDA.w #$2323 : STA $7F2080, X : STA $7F2100, X : STA $7F2180, X : STA $7F2200, X
        
        INX #2
        
        DEY : BPL .nextColumn2
    
    .return
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$C21C-$C229 JUMP LOCATION
    Dungeon_InitBarrierAttr:
    {
        ; Initializes the tile attributes for the orange/blue barrier tiles
        
        INC $0200
        
        ; Check the orange/blue barrier state.
        LDA $7EC172 : BEQ .ignore

        ; if it's nonzero, flip the collision states for the barriers.
        JSL Dungeon_ToggleBarrierAttr ; $C22A IN ROM
    
    .ignore
    
        RTS
    }

; ==============================================================================

    ; *$C22A-$C27C LONG
    Dungeon_ToggleBarrierAttr:
    {
        REP #$10
        
        LDX.w #$07FF
    
    .nextAttrSet
    
        LDA $7F2000, X
        
        CMP.b #$66 : BEQ .toggle1
        CMP.b #$67 : BNE .noToggle1
    
    .toggle1
    
        EOR.b #$01 : STA $7F2000, X
        
    .noToggle1    
    
        LDA $7F2800, X
        
        CMP.b #$66 : BEQ .toggle2
        CMP.b #$67 : BNE .noToggle2
    
    .toggle2
    
        EOR.b #$01 : STA $7F2800, X
    
    .noToggle2
    
        LDA $7F3000, X
        
        CMP.b #$66 : BEQ .toggle3
        CMP.b #$67 : BNE .noToggle3
    
    .toggle3
    
        EOR.b #$01 : STA $7F3000, X
    
    .noToggle3
    
        LDA $7F3800, X
        
        CMP.b #$66 : BEQ .toggle4
        CMP.b #$67 : BNE .noToggle4
    
    .toggle4
    
        EOR.b #$01 : STA $7F3800, X
    
    .noToggle4
    
        DEX : BPL .nextAttrSet
        
        SEP #$10
        
        RTL
    }

; ==============================================================================

    ; $C27D-$C2FC JUMP TABLE
    Dungeon_TagRoutines:
    {
        ; Tag routines
        
        dw $C328 ; = $C328* ; routine 0x00 (RTS)
        dw $C432 ; = $C432* ; routine 0x01 "NW kill enemy to open"
        dw $C438 ; = $C438* ; routine 0x02 "NE kill enemy to open"
        dw $C43E ; = $C43E* ; routine 0x03 "SW kill enemy to open"
        dw $C444 ; = $C444* ; routine 0x04 "SE kill enemy to open"
        dw $C44A ; = $C44A* ; routine 0x05 "W kill enemy to open"
        dw $C450 ; = $C450* ; routine 0x06 "E kill enemy to open"
        dw $C456 ; = $C456* ; routine 0x07 "N kill enemy to open"
        
        dw $C45C ; = $C45C* ; routine 0x08 "S kill enemy to open"
        dw $C461 ; = $C461* ; routine 0x09 "clear quadrant to open"
        dw $C4BF ; = $C4BF* ; routine 0x0A "clear room to open"
        dw $C432 ; = $C432* ; routine 0x0B "NW move block to open"
        dw $C438 ; = $C438* ; routine 0x0C "NE move block to open"
        dw $C43E ; = $C43E* ; routine 0x0D "SW move block to open"
        dw $C444 ; = $C444* ; routine 0x0E "SE move block to open"
        dw $C44A ; = $C44A* ; routine 0x0F "W move block to open"
        
        dw $C450 ; = $C450* ; routine 0x10 "E move block to open"
        dw $C456 ; = $C456* ; routine 0x11 "N move block to open"
        dw $C45C ; = $C45C* ; routine 0x12 "S move block to open"
        dw $C461 ; = $C461* ; routien 0x13 "move block to open"
        dw $C4E7 ; = $C4E7* ; routine 0x14 "pull lever to Open"
        dw $C508 ; = $C508* ; routine 0x15 "clear level to open door"
        dw $C541 ; = $C541* ; routine 0x16 "switch opens doors (hold)"
        dw $C599 ; = $C599* ; routine 0x17 "switch opens doors (toggle)"
        
        dw $CA94 ; = $CA94* ; routine 0x18 (turn off water)
        dw Tag_TurnOnWater ; routine 0x19 (turn on water)
        dw Tag_Watergate   ; routine 0x1A (watergate room)
        dw $CBFF ; = $CBFF* ; (RTS) (water twin)
        dw $C8D4 ; = $C8D4* ; routine 0x1C Secret Wall (Right)
        dw $C98B ; = $C98B* ; routine 0x1D Secret Wall (Left)
        dw $CA17 ; = $CA17* ; routine 0x1E "Crash"
        dw $CA17 ; = $CA17* ; routine 0x1F "Crash"
        
        dw $C67A ; = $C67A* ; routine 0x20 "use switch to bomb wall"
        dw $CC00 ; = $CC00* ; routine 0x21 "holes(0)"
        dw $CC5B ; = $CC5B* ; routine 0x22 "open chest for holes (0)"
        dw $CC04 ; = $CC04* ; routine 0x23 "holes(1)"
        dw $CC89 ; = $CC89* ; routine 0x24 "holes(2)"
        dw $C709 ; = $C709* ; routine 0x25 "kill enemy to clear level"
        dw $C7A2 ; = $C7A2* ; routine 0x26 "kill enemy to move block"
        dw $C7CC ; = $C7CC* ; routine 0x27 "trigger activated chest"
        
        dw $C685 ; = $C685* ; routine 0x28 "use lever to bomb wall"
        dw $C432 ; = $C432* ; routine 0x29 "NW kill enemy for chest"
        dw $C438 ; = $C438* ; routine 0x2A "NE kill enemy for chest"
        dw $C43E ; = $C43E* ; routine 0x2B "SW kill enemy for chest"
        dw $C444 ; = $C444* ; routine 0x2C "SE kill enemy for chest"
        dw $C44A ; = $C44A* ; routine 0x2D "W kill enemy for chest"
        dw $C450 ; = $C450* ; routine 0x2F "E kill enemy for chest"
        dw $C456 ; = $C456* ; routine 0x2F "N kill enemy for chest"
        
        dw $C45C ; = $C45C* ; routine 0x30 "S kill enemy for chest"
        dw $C461 ; = $C461* ; routine 0x31 "clear quadrant for chest"
        dw $C4BF ; = $C4BF* ; routine 0x32 "clear room for chest"
        dw $C629 ; = $C629* ; routine 0x33 "light torches to open"
        dw $CC08 ; = $CC08* ; routine 0x34 "Holes(3)"
        dw $CC0C ; = $CC0C* ; routine 0x35 "Holes(4)"
        dw $CC10 ; = $CC10* ; routine 0x36 "Holes(5)"
        dw $CC14 ; = $CC14* ; routine 0x37 "Holes(6)"
        
        dw $C74E ; = $C74E* ; routine 0x38 "Agahnim's room"
        dw $CC18 ; = $CC18* ; routine 0x39 "Holes(7)"
        dw $CC1C ; = $CC1C* ; routine 0x3A "Holes(8)"
        dw $CC62 ; = $CC62* ; routine 0x3B "open chest for holes (8)"
        dw $C7C2 ; = $C7C2* ; routine 0x3C "move block to get chest"
        dw $C767 ; = $C767* ; routine 0x3D "Kill to open Ganon's door"
        dw $C8AE ; = $C8AE* ; routine 0x3E "light torches to get chest"
        dw $C4DB ; = $C4DB* ; routine 0x3F "kill boss again"
    }

; ==============================================================================

    ; *$C2FD-$C31E LONG
    Dungeon_CheckStairsAndRunScripts:
    {
        LDA $04C7 : BNE .return
        
        SEP #$30
        
        JSR Dungeon_DetectStaircase
        
        STZ $0E
        
        LDA $AE : ASL A : TAX
        
        ; Handle tag1 routine
        JSR (Dungeon_TagRoutines, X)
        
        ; Based on the whether it's tag1 or tag2, execute different routines. Interesting.
        LDA.b #$01 : STA $0E
        
        LDA $AF : ASL A : TAX
        
        ; Handle tag2 routine
        JSR (Dungeon_TagRoutines, X)
        
    .return
        
        STZ $04C7
        
        RTL
    }

; ==============================================================================

    ; $C31F-$C324 DATA
    {
        db $00, $01, $01
        
    ; $C322
        
        db $00, $00, $01
    }

; ==============================================================================

    ; *$C325-$C328 BRANCH LOCATION
    Dungeon_DetectStaircaseEasyOut:
    {
    ._1
    
        PLA
    
    ; *$C326 ALTERNATE ENTRY POINT
    ._2
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$C329-$C431 LOCAL
    Dungeon_DetectStaircase:
    {
        REP #$20
        
        ; If Link is not moving up or down, or isn't moving, end this routine.
        LDA $67 : AND.w #$000C : BEQ Dungeon_DetectStaircaseEasyOut_2
        
        STA $02
        
        TAY
        
        LDA $20 : ADD $99EA, Y : AND.w #$01F8 : ASL #3 : STA $00
        LDA $22                 : AND.w #$01F8 : LSR #3 : ORA $00
        
        LDX $EE : BEQ .onBg2
        
        ORA.w #$1000
    
    .onBg2
    
        REP #$10
        
        TAX
        
        PHX
        
        ; Link's directional indicator... 0x0004 denotes the down direction
        LDY $02 : CPY.w #$0004 : BNE .movingUp
        
        ; If Link is moving down, look two tiles down for the trigger tile
        ADD.w #$0080 : TAX
    
    .movingUp
    
        SEP #$20
        
        LDA $7F2000, X
        
        PLX
        
        CMP.b #$26 : BEQ .staircaseEdge
        CMP.b #$38 : BEQ .staircaseEdge ; north straight up inter-room staircases
        CMP.b #$39 : BEQ .staircaseEdge ; south straight down inter-room staircases
        CMP.b #$5E : BEQ .staircaseEdge ; Staircase
        CMP.b #$5F : BNE Dungeon_DetectStaircaseEasyOut_2
    
    .staircaseEdge
    
        PHA : STA $0E
        
        LDA $7F2040, X : TAY
        
        ; See if this is a staircase trigger ( 0x30 to 0x37 )
        ; End the routine if Link isn't touching a staircase. (This leads to an RTS)
        AND.b #$F8 : CMP.b #$30 : BNE Dungeon_DetectStaircaseEasyOut_1
        
        ; Is Link holding a pot?
        LDA $0308 : BPL .notHoldingPot
        
        PLA
        
        REP #$20
        
        LDA $0FC4 : STA $20
        
        ; Abort mission! Link is holding a pot ohnoesZ!
        BRA Dungeon_DetectStaircaseEasyOut_2
    
    .notHoldingPot
    
        REP #$20
        
        ; Store which staircase it is... (0x30 to 0x37)
        STY $0462
        
        ; Cache the current room number
        LDA $A0 : STA $A2
        
        SEP #$30
        
        JSL Dungeon_SaveRoomQuadrantData
        
        SEP #$30
        
        LDA $0E
        
        CMP.b #$38 : BEQ BRANCH_EPSILON
        CMP.b #$39 : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        LDX.b #$20 : STX $0464
        
        CMP.b #$38 : BNE .mystery
        
        ; Gets called when travelling up a straight inter-room staircase
        JSL $02B81C ; $1381C IN ROM
        
        BRA BRANCH_ZETA
    
    .mystery
    
        JSL $02B77A ; $1377A IN ROM
    
    BRANCH_ZETA:
    
        LDA $0462 : AND.b #$03 : TAX
        
        ; Load the target room.
        LDA $7EC001, X : STA $A0
        
        LDA $063D, X : STA $048A
        
        LDX.b #$02
        
        LDA $EE : BNE BRANCH_THETA
        
        LDX.b #$00
        
        LDA $0476 : BEQ BRANCH_THETA
        
        LDX.b #$02
    
    BRANCH_THETA:
    
        STX $0492
        
        STZ $B0
        STZ $48
        STZ $3D
        STZ $3A
        STZ $3C
        
        LDA $50 : AND.b #$FE : STA $50
        
        ; Do an upward floor transition
        LDX.b #$06
        
        PLA : CMP.b #$26 : BEQ BRANCH_IOTA
        
        LDX.b #$12
        
        CMP.b #$38 : BEQ BRANCH_KAPPA
        
        LDX.b #$13
        
        CMP.b #$39 : BEQ BRANCH_KAPPA
        
        JSL $07F25A ; $3F25A IN ROM
        
        ; Going up or down stairs mode.
        LDX.b #$0E : STX $11
        
        RTS
    
    BRANCH_KAPPA:
    
        STX $11
        
        JSL $07F3F3 ; $3F3F3 IN ROM
        
        RTS
    
    BRANCH_IOTA:
    
        STX $11
        
        LDY.b #$16
        
        LDA $048A : CMP.b #$34 : BCC BRANCH_LAMBDA
        
        LDY.b #$18
    
    BRANCH_LAMBDA:
    
        STY $012E ; Play one of the stairs sound effects.
        
        RTS
    }

; ==============================================================================

    ; *$C432-$C4E6 JUMP LOCATION
    {
        ; branch if Link is in the left two quadrants
        LDA $23 : LSR A : BCC .checkIfNorth
        
        RTS
    
    ; *$C438 ALTERNATE ENTRY POINT
    
        ; Tag routine 0x02 (NE Kill Enemy To Open), 0x0A (NE move block to open), 0x2A (NE kill enemy for chest)
        ; branch if Link in the right two quadrants
        LDA $23 : LSR A : BCS .checkIfNorth
        
        RTS
    
    ; *$C43E ALTERNATE ENTRY POINT
    
        LDA $23 : LSR A : BCC .checkIfSouth
        
        RTS
    
    ; *$C444 ALTERNATE ENTRY POINT
    
        ; Tag routine 0x04 (SE kill enemy to open), 0x0E (SE move block to open), 0x2C (SE kill enemy for chest)
        LDA $23 : LSR A : BCS .checkIfSouth
        
        RTS
    
    ; *$C44A ALTERNATE ENTRY POINT
    
        ; Tag routine 0x05 (W kill enemy to open), 0x0F (W move block to open), 0x2D (W kill enemy for chest)
        LDA $23 : LSR A : BCC .coordSuccess
        
        RTS
    
    ; *$C450 ALTERNATE ENTRY POINT

        LDA $23 : LSR A : BCS .coordSuccess
        
        RTS
    
    ; *$C45C ALTERNATE ENTRY POINT
    .checkIfNorth
    
        ; Branch if Link is in the upper two quadrants
        LDA $21 : LSR A : BCC .coordSuccess
    
    .coordFail
    
        RTS
    
    .checkIfSouth
    
        LDA $21 : LSR A : BCC .coordFail
    
    .coordSuccess
    
        LDX $0E
        
        LDA $AE, X
        
        CMP.b #$0B : BCC .checkIfEnemiesDead
        CMP.b #$29 : BCC .checkIfBlockMoved
        
        ; check if sprites are all dead
        JSL Sprite_VerifyAllOnScreenDefeated : BCC .dontShowChest
        
        JSR $C7D8 ; $C7D8 IN ROM
    
    .dontShowChest
    
        RTS
    
    .checkIfBlockMoved
    
        LDA $0641 : EOR.b #$01 : CMP $0468 : BEQ .noDoorStateMatch
        
        STA $0468
        
        ; play switch triggering sound
        LDA.b #$25 : STA $012F
        
        ; enter "open trap door" submodule
        LDA.b #$05 : STA $11
        
        REP #$20
        
        STZ $068E
        STZ $0690
    
    .noDoorStateMatch
    
        SEP #$30
        
        RTS
    
    .checkIfEnemiesDead
    
        JSL Sprite_VerifyAllOnScreenDefeated : BCC .dontOpenDoors
    
    .checkDoorState
    
        ; Success, sprites are all dead.
        
        REP #$30
        
        ; Trap door down flag. (If it's already unset, ignore it!)
        LDX.w #$0000 : CPX $0468 : BEQ .dontOpenDoors
        
        STZ $0468
        STZ $068E
        STZ $0690
        
        SEP #$30
        
        ; The mystery sound when a puzzle is solved.
        LDA.b #$1B : STA $012F
        
        ; Open ze doors
        LDA.b #$05 : STA $11
    
    .dontOpenDoors
    
        SEP #$30
        
        RTS
    
    ; *$C4BF ALTERNATE ENTRY POINT
    
        LDX $0E
        
        LDA $AE, X : CMP.b #$0A : BEQ .clearRoomToOpen
        
        ; (clear room for chest portion)
        
        JSL Sprite_CheckIfAllDefeated : BCC .return
        
        JSR $C7D8 ; $C7D8 IN ROM
    
    .return
    
        SEP #$30
        
        RTS
    
    .clearRoomToOpen
    
        JSL Sprite_CheckIfAllDefeated : BCC .return : BCS .checkDoorState
    
    ; *$C4DB ALTERNATE ENTRY POINT
    
        ; tag routine 0x3F "kill boss again"
        
        ; Carry clear = failure. Sprites are still onscreen.
        JSL Sprite_CheckIfAllDefeated : BCC .return
        
        STZ $0FFC
        STZ $AF
        
        RTS
    }

    ; *$C4E7-$C507 JUMP LOCATION
    {
        ; tag routine 0x14 "pull lever to open"
        
        LDA $0642 : BEQ .stillOnTrigger
        
        REP #$30
        
        LDX.w #$0000 : CPX $0468 : BEQ .trapDoorsAreUp
        
        STX $0468
        
        STZ $068E
        STZ $0690
        
        SEP #$30
        
        LDA.b #$05 : STA $11
    
    .trapDoorsAreUp
    .stillOnTrigger
    
        SEP #$30
        
        RTS
    }

    ; *$C508-$C540 JUMP LOCATION
    {
        ; Tag routine 0x16 "clear level to open doors"
        
        ; Load the dungeon index.
        LDA $040C : LSR A : TAX
        
        ; Which world are we in?
        LDA $7EF3CA : BNE .inDarkWorld
        
        ; See which pendants we have.
        LDA $7EF374 : AND.l MilestoneItem_Flags, X : BEQ .dontHaveGoalItem
        
        BRA .openDoors
    
    .inDarkWorld
    
        ; How many crystals do we have?
        LDA $7EF37A : AND.l MilestoneItem_Flags, X : BEQ .dontHaveGoalItem
    
    .openDoors
    
        REP #$30
        
        STZ $0468
        STZ $068E
        STZ $0690
        
        SEP #$30
        
        LDA.b #$05 : STA $11
        
        LDX $0E
        
        STZ $AE, X
    
    .dontHaveGoalItem
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$C541-$C598 JUMP LOCATION
    {
        ; Tag routine 0x16 - "switch opens doors (hold)"
        
        REP #$30
        
        LDA.w #$0005
        LDX.w #$FFFE
    
    .nextObject
    
        INX #2 : CPX $0478 : BEQ .endOfObjectList
        
        CMP $0500, X : BNE .nextObject
        
        LDX $0466 : CPX.w #$FFFF : BNE .testAgainstDoorState
    
    .endOfObjectList
    
        LDX.w #$0000
        
        LDA $0646 : AND.w #$00FF : BNE .testAgainstDoorState
        
        LDA $0642 : AND.w #$00FF : BNE .testAgainstDoorState
        
        ; $CDCC IN ROM
        JSR $CDCC : LDX.w #$0000 : BCS .testAgainstDoorState
        
        INX
    
    .testAgainstDoorState
    
        CPX $0468 : BEQ .noChangeInTrapDoorState
        
        STX $0468
        
        STZ $068E
        STZ $0690
        
        SEP #$30
        
        CPX.b #$00 : BNE .noSoundEffect
        
        ; play the "switch triggered" sound effect
        LDA.b #$25 : STA $012F

    .noSoundEffect

        LDA.b #$05 : STA $11

    .noChangeInTrapDoorState

        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$C599-$C5CE JUMP LOCATION
    {
        ; Dungeon Tag routine 0x17 "switch opens doors"
        
        REP #$30
        
        LDA $0430 : BNE .checkIfStandingOnSwitch
        
        ; $CD39 IN ROM
        JSR $CD39 : BCC .notStandingOnSwitch
        
        STZ $068E
        STZ $0690
        
        SEP #$30
        
        LDA.b #$25 : STA $012F
        
        LDA.b #$05
        
        ; Toggle the opened / closed status of the trap doors in the room.
        JSR $C5CF ; $C5CF IN ROM
        
        LDA $0468 : EOR.b #$01 : STA $0468
        
        INC $0430
        
        BRA .notStandingOnSwitch
    
    .checkIfStandingOnSwitch
    
        ; $CD39 IN ROM
        ; This code is waiting for Link to step off the switch before it can be pressed again.
        JSR $CD39 : BCS .stillStandingOnSwitch
        
        STZ $0430
    
    .notStandingOnSwitch
    .stillStandingOnSwitch
    
        SEP #$30
        
        RTS
    }

    ; *$C5CF-$C628 LOCAL
    {
        STA $11
        
        LDX $0C : CPX.b #$23 : BEQ BRANCH_ALPHA
        
        LDA $04B6 : ORA $04B7 : BEQ BRANCH_ALPHA
        
        LDA $11 : STA $010C
        
        LDA.b #$17 : STA $11
        
        LDA.b #$20 : STA $B0
        
        REP #$30
        
        LDA $20 : ADD.w #$0002 : STA $20
        
        LDX $04B6
        
        LDA $7F2000, X : AND.w #$FE00 : CMP.w #$2400 : BEQ .isTriggerTile
        
        INX
    
    .isTriggerTile
    
        STX $04B6
        
        TXA : STA $00
        
        LSR #3 : AND.w #$01F8 : STA $02
        
        LDA $00 : AND.w #$003F : ASL #3 : STA $00
        
        SEP #$30
        
        LDY.b #$10
        
        JSL Dungeon_SpriteInducedTilemapUpdate
    
    BRANCH_ALPHA:
    
        SEP #$30
        
        RTS
    }

    ; *$C629-$C665 JUMP LOCATION
    {
        REP #$30
        
        LDX.w #$0000 : STX $00
    
    BRANCH_BETA:
    
        LDA $0540, X : ASL A : BCC BRANCH_ALPHA
        
        INC $00
    
    BRANCH_ALPHA:
    
        INX #2 : CPX.w #$0020 : BNE BRANCH_BETA
        
        LDX.w #$0001
        
        LDA $00 : CMP.w #$0004 : BCC BRANCH_GAMMA
        
        DEX
    
    BRANCH_GAMMA:
    
        CPX $0468 : BEQ BRANCH_DELTA
        
        STX $0468
        
        STZ $068E
        STZ $0690
        
        SEP #$30
        
        LDA.b #$1B : STA $012F
        
        LDA.b #$05 : STA $11
    
    BRANCH_DELTA:
    
        SEP #$30
        
        RTS
    }

    ; $C666-$C679 DATA
    {
        dw $0004, $0006, $0000, $0000, $0000
        
    ; $C670
    
        dw $0000, $000A, $0000, $0000, $0280
    }

    ; *$C67A-$C6FB JUMP LOCATION
    {
        ; tag routine 0x20 "use switch to bomb wall"
        REP #$30
        
        ; $CD39 IN ROM
        JSR $CD39 : BCC .return
        
        REP #$30
        
        BRA .checkForBombableWall
    
    ; *$C685 ALTERNATE ENTRY POINT
    
        ; tag routine 0x28 "use lever to bomb wall"
        LDA $0642 : BEQ .return
        
        REP #$30
    
    .checkForBombableWall
    
        LDY.w #$FFFE
    
    BRANCH_GAMMA:
    
        INY #2
        
        LDA $1980, Y : AND.w #$00FE : CMP.w #$0030 : BNE BRANCH_GAMMA
        
        STY $0456
        
        ; \wtf Based on this logic, wouldn't index 6 never get used in the
        ; tables below?
        LDA $21 : AND.w #$0001 : INC A : ASL #2 : TAX
        
        LDA $19C0, Y : AND.w #$0002 : BEQ BRANCH_DELTA
        
        LDA $23 : AND.w #$0001 : ASL A : TAX
    
    BRANCH_DELTA:
    
        LDA $01C666, X : STA $7F001C
        
        LDA $19A0, Y : ADD $01C670, X : TAY
        
        AND.w #$007E : ASL #2 : ADD $062C : STA $7F001A
        
        TYA : AND.w #$1F80 : LSR #4 : ADD $062E : STA $7F0018
        
        SEP #$30
        
        ; play "puzzle solved" sound effect
        LDA.b #$1B : STA $012F
        
        LDA.b #$01 : STA $0454
        
        LDX $0E
        
        STZ $AE, X
        
        JSL AddBlastWall
    
    .return
    
        SEP #$30
        
        RTS
    }

    ; $C6FC-$C708
    {
        db $00, $00, $01, $02, $00, $06, $06, $06, $06, $06, $03, $06, $06
    }

    ; *$C709-$C74D JUMP LOCATION
    {
        ; name: Kill enemy to clear level in hyrule magic
        
        ; Has this boss room already been done with? (i.e. has a heart piece been picked up in this room?)
        LDA $0403 : AND.b #$80 : BEQ .heartPieceStillExists
        
        ; Load the dungeon index, divide by 2.
        LDA $040C : LSR A : TAX
        
        ; Are we in the dark world?
        LDA $7EF3CA : BNE .inDarkWorld
        
        ; We're in the Light World.
        LDA $7EF374 : AND.l MilestoneItem_Flags, X : BNE .criticalItemAlreadyObtained
        
        BRA .giveCriticalItem
    
    .inDarkWorld
     
        LDA $7EF37A : AND.l MilestoneItem_Flags, X : BNE .criticalItemAlreadyObtained
    
    .giveCriticalItem
    
        LDA.b #$80 : STA $04C2
        
        LDA $0E : PHA
        
        LDA $040C : LSR A : TAX
        
        LDA $01C6FC, X : JSL Sprite_SpawnFallingItem
        
        PLA : STA $0E
    
    .criticalItemAlreadyObtained
    
        LDX $0E
        
        STZ $AE, X
    
    .heartPieceStillExists
    
        RTS
    }

    ; *$C74E-$C766 JUMP LOCATION
    {
        ; Tag routine 0x38 "Agahnim's room"
        
        ; Look at the info for the Pyramid of power area.
        ; Has Ganon busted a nut on it yet? (broken in)
        LDA $7EF2DB : AND.b #$20 : BNE .return
        
        ; And it's checking if we have beaten Agahnim yet.
        LDA $0403 : ASL A : BCC .return
        
        ; Otherwise do some swapping to the palettes in memory.
        JSL Palette_RevertTranslucencySwap
        
        STZ $AE
        
        JSL PrepDungeonExit
    
    .return
    
        RTS
    }

    ; *$C767-$C7A1 JUMP LOCATION
    {
        ; Tag routine 0x3D (Kill to open Ganon's door)
        
        LDX.b #$0F
        
        LDA $0DD0, X : CMP.b #$04 : BEQ .return
        
        LDA $0F60, X : AND.b #$40 : BNE .inactiveSprite
    
    .nextSprite
    
        ; Can't open the door as long even a single sprite lives.
        LDA $0DD0, X : BNE .return
    
    .inactiveSprite
    
        DEX : BPL .nextSprite
        
        ; If Link sucks and falls into a pit after he's killed Ganon
        ; there will be no mercy for him. Because he won't get to see this 
        ; spiffy door opening.
        LDA $5D : CMP.b #$01 : BEQ .return
        
        LDA.b #$1A : STA $02E4 : STA $11
        
        STZ $B0
        STZ $AE
        
        LDA.b #$01 : STA $03EF
        
        STZ $3A
        STZ $3C
        
        ; Set a timer preventing Link from doing jackshit until the fanfare is
        ; over.
        LDA.b #$64 : STA $C8
        LDA.b #$03 : STA $C9
    
    .return
    
        RTS
    }

    ; *$C7A2-$C7C1 JUMP LOCATION
    {
        ; Tag routine 0x26 (SE kill enemy to move block)
        
        LDA $23 : LSR A : BCC .return
        
        LDA $21 : LSR A : BCC .return
        
        LDA $0E : PHA
        
        JSL Sprite_VerifyAllOnScreenDefeated : BCC .someSpritesAlive
        
        ; play puzzle solved song
        LDA.b #$1B : STA $012F
        
        PLX
        
        STZ $AE, X
    
    .someSpritesAlive
    
        RTS
        
        ; This instruction is never reached in the original game
        PLA
    
    ; *$C7BE ALTERNATE ENTRY POINT
    
        SEP #$30
    
    .return
    
        RTS
    }

    ; *$C7C2-$C8AD JUMP LOCATION
    {
        ; Tag routine 0x3C (Move block to get chest)
        
        LDA $14 : BNE .already_doing_tilemap_update
        
        LDA $0641 : BNE .showChests
    
    .already_doing_tilemap_update
    
        RTS
    
    ; *$C7CC ALTERNATE ENTRY POINT
    
        ; Tag routine 0x27 "trigger activated chest"
        ; Link is flashing, so he can't do shit, son
        LDA $031F : BNE BRANCH_$C7C1 ; (RTS)
        
        REP #$30
        
        ; $CD39 IN ROM
        JSR $CD39 : BCC BRANCH_C7BE
    
    ; *$C7D8 ALTERNATE ENTRY POINT
    .showChests
    
        SEP #$30
        
        LDX $0E
        
        STZ $AE, X
        
        REP #$30
        
        STZ $1000
        STZ $0200
        
        LDA.w #$5858 : STA $0C
    
    ; *$C7EB ALTERNATE ENTRY POINT
    .nextChest
    
        LDX $0200
        
        LDA $06E0, X : AND.w #$3FFF : TAX
        
        LDY.w #$149C
        
        LDA $9B52, Y : STA $7E2000, X : STA $02
        LDA $9B54, Y : STA $7E2080, X : STA $04
        LDA $9B56, Y : STA $7E2002, X : STA $06
        LDA $9B58, Y : STA $7E2082, X : STA $08
        
        LDY $0200
        
        LDA $06E0, Y : AND.w #$3FFF : LSR A : TAX
        
        LDA $0C : STA $7F2000, X : STA $7F2040, X

        ADD.w #$0101 : STA $0C
        
        LDX $1000
        
        LDA.w #$0000
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1002, X
        
        LDA.w #$0080
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1008, X
        
        LDA.w #$0002
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $100E, X
        
        LDA.w #$0082
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1014, X
        
        LDA $02 : STA $1006, X
        LDA $04 : STA $100C, X
        LDA $06 : STA $1012, X
        LDA $08 : STA $1018, X
        
        LDA.w #$0100 : STA $1004, X : STA $100A, X : STA $1010, X : STA $1016, X
        
        LDA.w #$FFFF : STA $101A, X
        
        TXA : ADD.w #$0018 : STA $1000
        
        LDA $0200 : INC #2 : STA $0200 : CMP $0496 : BEQ .lastChest
        
        JMP .nextChest
    
    .lastChest
    
        STZ $0200
        
        SEP #$30
        
        ; play "show chest" sound effect
        LDA.b #$1A : STA $012F
        
        ; update tilemap this frame
        LDA.b #$01 : STA $14
        
        RTS
    }

    ; *$C8AE-$C8D3 JUMP LOCATION
    {
        ; Tag routine 0x3E "light torches to get chest"
        
        REP #$30
        
        LDX.w #$0000 : STX $00
    
    .nextObject
    
        LDA $0540, X : ASL A : BCC .torchNotLit
        
        INC $00
    
    .torchNotLit
    
        INX #2 : CPX.w #$0020 : BNE .nextObject
        
        LDX.w #$0001
        
        LDA $00 : CMP.w #$0004 : BCC .dontShowChest
        
        JSR $C7D8 ; $C7D8 IN ROM
    
    .dontShowChest
    
        SEP #$30
        
        RTS
    }

    ; *$C8D4-$C960 JUMP LOCATION
    {
        REP #$20
        
        LDA $041A : BNE .horizontalMovement
        
        JSR $CA17 ; $CA17 IN ROM
        
        BRA .beta
    
    .horizontalMovement
    
        LDY.b #$01 : STY $0FC1
        
        JSR $C969 ; $C969 IN ROM
        
        LDA.w #$FFFF
        
        JSR $CA66 ; $CA66 IN ROM
    
    .beta
    
        STA $0312
        
        LDA $0422 : SUB $0312 : STA $0422
        
        ADD $E2 : STA $E0
        
        LDA $0312 : BEQ .zeroHorizontalSpeed
        
        LDX $041E
        
        LDA $0422 : CMP $9B1A, X : BCS BRANCH_DELTA
        
        JSR $CA75 ; $CA75 IN ROM
        
        LDA $0422 : CMP $9B1A, X : BCS BRANCH_DELTA
        
        ; play the puzzle solved sound.
        LDX.b #$1B : STX $012F
        
        ; "silence" ambient sfx
        LDX.b #$05 : STX $012D
        
        LDX $0E
        
        LDY.b #$00 : STY $AE, X : STY $02E4 : STY $0FC1
        
        STZ $011A
        STZ $011B
        STZ $011C
        STZ $011D
    
    BRANCH_DELTA:
    
        LDX.b #$05 : STX $17
        
        LDA.w #$0000 : SUB $0422 : STA $00
        
        AND.w #$01F8 : LSR #3 : STA $00
        
        LDA $042A : SUB $00 : AND.w #$141F : STA $0116
    
    .zeroHorizontalSpeed
    
        SEP #$20
        
        RTS
    }

    ; $C961-$C968 DATA
    {
        db  0,  1, -1, -1
        
    ; $C965
        
        db -1, -1,  1,  0
    }

    ; *$C969-$C98A LOCAL
    {
        LDA $1A : AND.w #$0001 : ASL A : TAX
        
        LDA $01C961, X : STA $011A
        LDA $01C965, X : STA $011C
        
        LDX $0E
        
        LDY $AE, X : BNE BRANCH_ALPHA
        
        STZ $011A
        STZ $011C
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$C98B-$CA16 JUMP LOCATION
    {
        REP #$20
        
        LDA $041A : BNE .wallIsMoving
        
        JSR $CA17 ; $CA17 IN ROM
        
        BRA BRANCH_BETA
    
    .wallIsMoving
    
        LDY.b #$01 : STY $0FC1
        
        JSR $C969 ; $C969 IN ROM
        
        LDA.w #$0001
        
        JSR $CA66 ; $CA66 IN ROM
    
    BRANCH_BETA:
    
        STA $0312
        
        ADD $0422 : STA $0422
        ADD $E2   : STA $E0
        
        LDA $0312 : BEQ BRANCH_GAMMA
        
        LDX $041E
        
        LDA $0422 : CMP $9B2A, X : BCC BRANCH_DELTA
        
        JSR $CA75 ; $CA75 IN ROM
        
        LDA $0422 : CMP $9B2A, X : BCC BRANCH_DELTA
        
        ; play the puzzle solved sound
        LDX.b #$1B : STX $012F
        
        ; "silence" ambient sfx.
        LDX.b #$05 : STX $012D
        
        LDX $0E
        
        LDY.b #$00 : STY $AE, X : STY $02E4 : STY $0FC1
        
        STZ $011A
        STZ $011B
        STZ $011C
        STZ $011D
    
    BRANCH_DELTA:
    
        LDX.b #$05 : STX $17
        
        LDA $0422 : AND.w #$01F8 : LSR #3 : STA $00
        
        LDA $042A : ADD $00 : STA $0116
        
        AND.w #$1020 : BEQ BRANCH_GAMMA
        
        EOR.w #$0420 : STA $0116
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$CA17-$CA65 LOCAL
    {
        REP #$10
        
        LDA $0642 : AND.b #$00FF : BNE .ignoreTorchRequirement
        
        LDX.w #$0000 : STX $00
    
    .nextObject
    
        LDA $0540, X : ASL A : BCC .torchNotLit
        
        INC $00
    
    .torchNotLit
    
        INX #2 : CPX.w #$0020 : BNE .nextObject
        
        LDA $00 : CMP.w #$0004 : BCC .notEnoughTorches
    
    .ignoreTorchRequirement
    
        INC $041A
        
        STZ $0642
        
        SEP #$20
        
        LDA $0E : ASL A : TAX
        
        LDA $0403 : ORA $98C7, X : STA $0403
        
        LDA.b #$07 : STA $012D
        
        LDA.b #$01 : STA $02E4 : STA $0FC1
        
        REP #$20
    
    .notEnoughTorches
    
        LDA.w #$0000
        
        SEP #$10
        
        RTS
    }

; ==============================================================================

    ; *$CA66-$CA74 LOCAL
    {
        LDA.w #$2200 : ADD $041C : STA $041C
        
        ROL A : AND.w #$0001
        
        RTS
    }

; ==============================================================================

    ; $CA75-$CA93 LOCAL
    {
        LDX $0E
        
        LDY $AE, X : CPY.b #$20 : BCS .alpha
        
        ; Change collision settings to default in the room.
        LDX.b #$00 : STX $046C
        
        ; Disable BG1
        LDX.b #$16 : STX $1C
    
    .alpha
    
        LDX $041E
        
        CPY.b #$20 : BCS .beta
        
        TXA : ADD.w #$0008 : TAX
    
    .beta
    
        RTS
    }

; ==============================================================================

    ; *$CA94-$CB19 JUMP LOCATION
    {
        ; routine 0x18 - turn off water
        
        LDA $0642 : BEQ BRANCH_$CA75.beta
        
        ; Change window mask settings...
        LDA.b #$03 : STA $96
        
        STZ $97 : STZ $98
        
        ; Window masking on main screen: BG2, BG3, OBJ
        LDA.b #$16 : STA $1E
        
        ; Window masking on subscreen: BG1
        LDA.b #$01 : STA $1F
        
        LDA.b #$01 : STA $0424
        
        JSL Hdma_ConfigureWaterTable
        
        ; Change to "Turn off Water" dungeon submodule.
        LDA.b #$0B : STA $11
        
        LDA.b #$00 : STA $7EC007 : STA $7EC009
        
        LDA.b #$1F : STA $7EC00B
        
        INC $15
        
        LDA.b #$00 : STA $AF
        
        LDA $0403 : ORA $0098C9 : STA $0403
        
        STZ $0642
        
        REP #$30
        
        LDA $0682 : AND.w #$01FF : SUB.w #$0010 : ASL #4 : STA $08
        LDA $0680 : AND.w #$01FF : SUB.w #$0010 : LSR #2 : TSB $08
        
        LDX $08
        
        JSR $95A0 ; $95A0 IN ROM
        JSR Dungeon_PrepOverlayDma.tilemapAlreadyUpdated
        
        LDY $0C : LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        LDA.b #$1B : STA $012F
        LDA.b #$2E : STA $012E
        
        LDA.b #$01 : STA $18
        
        RTS
    }

; ==============================================================================

    ; $CB1A-$CB48 JUMP LOCATION
    Tag_TurnOnWater:
    {
        ; routine 0x19 - turn on water
        
        LDA $0642 : BEQ BRANCH_$CB19 ; (RTS)
        
        ; Play two sound effects together (some sound effects sound good together)
        LDA.b #$1B : STA $012F
        LDA.b #$2F : STA $012E
        
        ; switch to dungeon submodule 0x0C
        LDA.b #$0C : STA $11
        
        STZ $B0
        
        LDA.b #$01 : STA $0424
        
        LDA.b #$00 : STA $AF
        
        LDA $0403 : ORA $0098C9 : STA $0403
        
        STZ $0642 : STZ $045C
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$CB49-$CBFF JUMP LOCATION
    Tag_Watergate:
    {
        ; routine 0x1A - watergate room
        
        ; ignore this routine b/c the water is already present
        LDA $0403 : AND $0098C9 : BNE Tag_TurnOnWater_return
        
        ; ignore this routine until the player pulls the lever to let water enter the room.
        LDA $0642 : BEQ Tag_TurnOnWater_return
        
        LDA.b #$0D : STA $11
        
        STZ $B0
        
        ; Disable this routine now and start filling the channel with water.
        LDA.b #$00 : STA $AF
        
        ; Set the flag so that if we walk in here again, the water will still
        ; be in the channel (and the watergate opened). Note, however, that
        ; overworld code resets this flag when you transition to another area.
        LDA $0403 : ORA $0098C9 : STA $0403
        
        ; Reset the lever trigger
        STZ $0642
        
        ; Reset some hdma stuff?
        STZ $0684 : STZ $067A
        
        ; Adjust window mask settings
        LDA.b #$03 : STA $96
        
        STZ $97 : STZ $98
        
        LDA.b #$16 : STA $1E
        LDA.b #$01 : STA $1F
        
        LDA.b #$02 : STA $99
        LDA.b #$62 : STA $9A
        
        ; Set the overworld flags so that the LW and DW areas outside the
        ; watergate have the water emptied
        LDA $7EF2BB : ORA.b #$20 : STA $7EF2BB
        LDA $7EF2FB : ORA.b #$20 : STA $7EF2FB
        
        ; Set it so the channel is full of water next time you enter
        ; Didn't we already do this with $0403?
        LDA $7EF051 : ORA.b #$01 : STA $7EF051
        
        REP #$30
        
        ; Gear up to load water tile data from $04F1CD.
        LDA.w #$0004 : STA $B9
        
        LDA.w #$F1CD
        
        JSR Object_WatergateChannelWater
        
        REP #$30
        
        ; Get the X position of the watergate barrier (in pixels)
        LDA $0472 : AND.w #$007E : ASL #2 : STA $0680
        
        ; Make the X position grid adjusted and move it 5 tiles to the right
        ; (the watergate is 10 tiles wide, so this puts it at the midpoint).
        LDA $B2 : ASL #4 : ADD $062C : ADD $0680 : ADD.w #$0028 : STA $0680
        
        ; Get the Y position of the watergate barrier.
        LDA $0472 : AND.w #$1F80 : LSR #4 : STA $0676 : STA $0678
        
        ; Make it grid adjusted.
        ADD $062E : STA $0682
        
        STZ $0686
        
        SEP #$30
        
        LDA.b #$1B : STA $012F
        LDA.b #$2F : STA $012E
        
        RTS
    }

; ==============================================================================

    ; *$CC00-$CC5A JUMP LOCATION
    {
        LDA.b #$01
        
        BRA BRANCH_ALPHA
    
    ; *$CC04 ALTERNATE ENTRY POINT
    
        LDA.b #$03
        
        BRA BRANCH_ALPHA
    
    ; *$CC08 ALTERNATE ENTRY POINT
    
        LDA.b #$06
        
        BRA BRANCH_ALPHA
    
    ; *$CC0C ALTERNATE ENTRY POINT
    
        LDA.b #$08
        
        BRA BRANCH_ALPHA
    
    ; *$CC10 ALTERNATE ENTRY POINT
    
        LDA.b #$0A
        
        BRA BRANCH_ALPHA
    
    ; *$CC14 ALTERNATE ENTRY POINT
    
        LDA.b #$0C
        
        BRA BRANCH_ALPHA
    
    ; *$CC18 ALTERNATE ENTRY POINT
    
        LDA.b #$0E
        
        BRA BRANCH_ALPHA
    
    ; *$CC1C ALTERNATE ENTRY POINT
    
        LDA.b #$10
    
    BRANCH_ALPHA:
    
        STA $0A
        
        LDY $04BA : BNE BRANCH_BETA
        
        STA $04BA
    
    BRANCH_BETA:
    
        REP #$30
        
        ; $CDCC IN ROM
        JSR $CDCC : BCC BRANCH_GAMMA
        
        SEP #$30
        
        TYA : ADD $0A : CMP $04BA : BEQ BRANCH_GAMMA
        
        STA $04BA
        
        STZ $BA
        STZ $BB
        STZ $B0
        
        ; Make the "mystery revealed" noise play.
        LDA.b #$1B : STA $012F
        
        ; Update the screen perhaps? (hint: chest appears, etc)
        LDA.b #$03 : STA $11
        
        LDA $04BC : EOR.b #$01 : STA $04BC
        
        JSL Dungeon_RestoreStarTileChr
    
    BRANCH_GAMMA:
    
        SEP #$30
        
        RTS
    }

    ; *$CC5B-$CC88 JUMP LOCATION
    {
        REP #$10
        
        ; holes (0)
        LDY.w #$0000
        
        BRA .alpha
    
    ; *$CC62 ALTERNATE ENTRY POINT
    
        ; Tag routine 0xCC62 (Open chest for holes)
        REP #$10
        
        ; holes (9)
        LDY.w #$0012
    
    .alpha
    
        LDA $0403 : AND.b #$01 : BEQ .chestNotOpened
    
    ; *$CC6E ALTERNATE ENTRY POINT
    
        ; Tell the "show dungeon overlay" submodule which overlay to use.
        STY $04BA
        
        SEP #$30
        
        STZ $BA
        STZ $BB
        STZ $B0
        
        ; Play "puzzle solved" sound effect
        LDA.b #$1B : STA $012F
        
        LDA.b #$03 : STA $11
        
        LDX $0E
        
        STZ $AE, X
    
    .chestNotOpened
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$CC89-$CC94 JUMP LOCATION
    {
        REP #$30
        
        ; $CDCC IN ROM
        JSR $CDCC : BCC BRANCH_$CC86 ; (SEP #$30, RTS)
        
        LDY.w #$0005
        
        BRA BRANCH_$CC6E
    }

; ==============================================================================

    ; *$CC95-$CD38 LOCAL
    Object_WatergateChannelWater:
    {
        STA $B7
        
        STZ $BA
    
    .nextObjectGroup
    
        STZ $B2
        STZ $B4
        
        LDY $BA : LDA [$BY], Y : CMP.w #$FFFF : BNE .validObjectData
        
        SEP #$30
        
        RTS
    
    .validObjectData
    
        !startPos = $08
        
        ; Load a dungeon the way we normally would, but in a a more limited
        ; way (hint: it's only water objects we're drawing)
        STA $00
        
        SEP #$20
        
        AND.b #$FC : STA !startPos
        
        LDA $00 : AND.b #$03 : INC A : STA $B2
        LDA $01 : AND.b #$03 : INC A : STA $B4
        
        INY #3 : STY $BA
        
        LDA $01 : LSR #3 : ROR !startPos : STA $09
        
        REP #$20
        
        LDX !startPos
        
        LDY.w #$0110
    
    .nextRow
    
        !numRows    = $B4
        !numColumns = $0A
        
        LDA $B2 : STA !numColumns
    
    .move_right_for_next_block
        
        !num2x4s = $04
        
        ; this loop draws a 4 row by 4 column block of tiles
        LDA.w #$0002 : STA !num2x4s
    
    .next2x4
    
        LDA $9B52, Y : STA $7E4000, X
        LDA $9B54, Y : STA $7E4002, X
        LDA $9B56, Y : STA $7E4004, X
        LDA $9B58, Y : STA $7E4006, X
        LDA $9B5A, Y : STA $7E4080, X
        LDA $9B5C, Y : STA $7E4082, X
        LDA $9B5E, Y : STA $7E4084, X
        LDA $9B60, Y : STA $7E4086, X
        
        TXA : ADD.w #$0100 : TAX
        
        DEC !num2x4s : BNE .next2x4
        
        TXA : SUB.w #$01F8 : TAX
        
        DEC !numColumns : BNE .moveRightFornext_block
        
        LDA !startPos : ADD.w #$0200 : STA !startPos : TAX
        
        DEC !numRows : BNE .nextRow
        
        JMP .nextObjectGroup
    }

; ==============================================================================

    ; *$CD39-$CDA4 LOCAL
    {
        LDA $02E4 : AND.w #$00FF : BNE .matchFailed
        
        LDA $4D : AND.w #$00FF : BNE .matchFailed
        
        JSR $CDA5 ; $CDA5 IN ROM
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$2424 : BEQ .partialMatch
        
        ; Try looking on the next line
        TXA : ADD.w #$0040 : TAX
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$2424 : BEQ .partialMatch
        
        INC $00
        
        LDX $00
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$2424 : BEQ .partialMatch
        
        TXA : ADD.w #$0040 : TAX
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$2424 : BNE .matchFailed
    
    .partialMatch
    
        CMP $7F2040, X : BNE .matchFailed
        
        STA $0C
        
        STX $04B6
        
        SEC
        
        RTS
    
    ; *$CDA0 ALTERNATE ENTRY POINT
    .matchFailed
    
        STZ $04B6
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$CDA5-$CDCB LOCAL
    {
        LDA $22 : ADD.w #$FFFF : AND.w #$01F8 : LSR #3 : STA $00
        LDA $20 : ADD.w #$000E : AND.w #$01F8 : ASL #3 : ORA $00
        
        LDX $EE : BEQ .onBG2
        
        ORA.w #$1000
    
    .onBG2
    
        STA $00 : TAX
        
        RTS
    }

; ==============================================================================

    !star_tiles = $3B3B

    ; *$CDCC-$CE5B LOCAL
    {
        LDA $02E4 : AND.w #$00FF : BNE _CD39_matchFailed
        
        LDA $4D : AND.w #$00FF : BNE _CD39_matchFailed
        
        JSR $CDA5 ; $CDA5 IN ROM
        
        LDY.w #$0000
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$3A3A : BEQ .partialMatch
        
        INY
        
        ; star tiles
        CMP.w #!star_tiles : BEQ .partialMatch
        
        ; Check the two tiles below
        TXA : ADD.w #$0040 : TAX
        
        LDY.w #$0000
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$3A3A : BEQ .partialMatch
        
        INY
        
        CMP.w #!star_tiles : BEQ .partialMatch
        
        INC $00
        
        LDX $00
        
        LDY.w #$0000
        
        LDA $7F2000, X
        
        CMP.w #$2323 : BEQ .partialMatch
        CMP.w #$3A3A : BEQ .partialMatch
        
        INY
        
        CMP.w #!star_tiles : BEQ .partialMatch
        
        TXA : ADD #$0040 : TAX
        
        LDY.w #$0000
        
        LDA $7F2000, X
        
        CMP.w #$2323       : BEQ .partialMatch
        CMP.w #$3A3A       : BEQ .partialMatch
        CMP.w #!star_tiles : BNE .matchFailed
        
        INY
    
    .partialMatch
    
        CMP $7F2040, X : BNE .matchFailed
        
        STA $0C
        
        STX $04B6
        
        SEC
        
        RTS
    
    .matchFailed
    
        STZ $04B6
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; $CE5C-$CE6F DATA
    {
        ; \task Name this pool and sublabels.
        
        db $02, $00, $00, $00
        db $06, $00, $04, $00
        
    ; $CE64
    
        dw $07EA, $080A, $080A, $082A
    
    ; $CE6C
        
        db $00, $00, $80, $40
    }
    
; ==============================================================================

    ; *$CE70-$D1F3 LONG
    Dungeon_ProcessTorchAndDoorInteractives:
    {
        LDA $1A : AND.b #$03 : BNE .skip_torch_logic
        
        ; Is there a custom animation in progress (e.g. medallion spells)
        LDA $0112 : BNE .skip_torch_logic
        
        LDX.b #$00
    
    .next_torch
    
        ; Count down the torch timers
        ; If timer is zero...
        LDA $04F0, X : BEQ .torch_already_out
        DEC $04F0, X : BNE .torch_still_lit
        
        ; Tells us which torch to put out...
        PHX
        
        TXA : ORA.b #$C0 : STA $0333
        
        JSL Dungeon_ExtinguishTorch
        
        PLX
    
    .torch_already_out
    .torch_still_lit
    
        ; Move on to the next torch.
        INX : CPX.b #$10 : BNE .next_torch
    
    .skip_torch_logic
    
        LDA $02E4 : BEQ .player_not_immobilized
        
        JMP $CFEA ; $CFEA IN ROM
    
    .player_not_immobilized
    
        REP #$21
        
        ; Which direction is the player facing?
        LDA $2F : AND.w #$00FF : STA $08 : TAY
        
        ; Note, data bank here is apparently $00, not $01
        LDA $20 : ADC $99EA, Y : AND.w #$01F8 : ASL #3 : STA $00
        LDA $22 : ADD $99F2, Y : AND.w #$01F8 : LSR #3 : ORA $00
        
        ; Based on what floor Link is on, we look at a specific tile.
        LDX $EE : BEQ .player_on_bg2
        
        ORA.w #$1000
    
    .player_on_bg2
    
        REP #$10
        
        TAX
        
        ; Is the tile above me a locked big key door tile?
        ; yes...
        LDA $7F2000, X : AND.w #$00F0 : CMP.w #$00F0 : BEQ .is_openable_door
        
        ; Is the one to the right of it a locked big key door tile?
        TXA : ADD $99FA, Y : TAX
        
        ; no...
        LDA $7F2000, X : AND.w #$00F0 : CMP.w #$00F0 : BNE .not_openable_door
    
    .is_openable_door
    
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY : STY $0694
        
        LDA $19C0, Y : AND.w #$0003 : ASL A : CMP $08 : BNE .not_openable_door
        
        ; Check if it's a breakable wall
        LDA $1980, Y : AND.w #$00FE
        
        CMP.w #$0028 : BEQ .is_breakable_wall
        CMP.w #$001C : BEQ .isSmallKeyDoor ; is it a small key door?
        CMP.w #$001E : BNE .notBigKeyDoor  ; is it a big key door?
        
        STZ $0690
        
        STX $068E
        
        LDY $040C
        
        ; Check which big keys we have and check it against the big key slot for this dungeon.
        ; Branch if we find a matching key.
        LDA $7EF366 : AND $98C0, Y : BNE .haveKeyToOpenDoor
        
        ; Means the "eh..." message has activated, and we haven�t moved away 
        ; from the door
        LDA $04B8 : BNE .skipDoorProcessing
        
        ; Otherwise, set that flag.
        INC $04B8
        
        ; Set up message $007A (in text mode 0xE of course)
        LDA.w #$007A : STA $1CF0
        
        SEP #$30
        
        JSL Main_ShowTextMessage
        
        REP #$30
    
    .skipDoorProcessing
    
        JMP $CFEA ; $CFEA IN ROM
    
    .not_openable_door
    
        STZ $04B8
        
        JMP $CFEA ; $CFEA IN ROM
    
    .notBigKeyDoor
    
        CMP.w #$001C : BCC .skipDoorProcessing
        CMP.w #$002C : BCS .skipDoorProcessing
        CMP.w #$002A : BEQ .skipDoorProcessing
    
    .isSmallKeyDoor
    
        LDA $7EF36F : AND.w #$00FF : BEQ .skipDoorProcessing
        
        LDA $7EF36F : DEC A : STA $7EF36F
    
    .haveKeyToOpenDoor
    
        STZ $0690
        
        ; Store the tilemap address ???
        STX $068E
        
        SEP #$30
        
        ; Go to submode 0x04.
        LDA.b #$04 : STA $11
        
        LDA.b #$14 : STA $00
        
        LDX $0694
        
        LDA $19C0, X : AND.b #$03 : TAX
        
        ; Play a sound effect b/c the door opened.
        LDA $01CE6C, X : ORA $00 : STA $012F
        
        RTL
    
    .is_breakable_wall
    
        LDA $0372 : AND.w #$00FF : BEQ .notDashing
        
        LDA $02F1 : CMP.w #$003F : BCS .notDashing
        
        STX $068E
        
        SEP #$30
        
        STY $00
        
        JSL AddDoorDebris : BCS BRANCH_OMICRON
        
        LDY $00
        
        LDA $19C0, Y : AND.b #$03 : STA $03BE, X
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $19A0, Y : AND.w #$007E : ASL #2 : ADD $062C : STA $03B6, X
        LDA $19A0, Y : AND.w #$1F80 : LSR #4 : ADD $062E : STA $03BA, X
    
    BRANCH_OMICRON:
    
        SEP #$30
        
        LDA.b #$1B : STA $012F
        
        LDA.b #$09 : STA $11
        
        JSL Sprite_RepelDashAttackLong
    
    BRANCH_TAU:
    
        RTL
    
    ; *$CFEA ALTERNATE ENTRY POINT
    .notDashing
    
        SEP #$30
        
        ; No... invisible door? Trap door? What? \task Part of another task
        ; Once $0436 is documented, we should know what logic would be
        ; skipped. Eye doors? wtf is this?
        LDA $0436 : BMI BRANCH_PI
        
        LDA $6C : BNE BRANCH_PI
        
        ; \hardcoded Checking by room? wtf man.
        LDA $23 : CMP.b #$0C : BNE BRANCH_PI
        
        LDY $0437
        
        LDX $0436 : CPX $2F : BEQ BRANCH_RHO
        
        LDA $2F : CMP $01CE5C, X : BNE BRANCH_RHO
        
        REP #$20
        
        LDA $068C : ORA $98C0, Y
        
        BRA BRANCH_SIGMA
    
    BRANCH_RHO:
    
        REP #$20
        
        LDA $068C : AND $98E0, Y
    
    BRANCH_SIGMA:
    
        CMP $068C : BEQ BRANCH_PI
        
        STA $068C
        
        STZ $0C
        
        REP #$10
        
        LDA $0437 : AND.w #$00FF : TAY
        
        JSR $D33A ; $D33A IN ROM
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDY $0460
        
        JSR $D51C ; $D51C IN ROM
        
        LDY $0C
        
        LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        LDA.b #$01 : STA $18
        
        LDA.b #$15 : STA $012F
        
        RTL
    
    BRANCH_PI:
    
        SEP #$30
        
        LDA $3A : ASL A : BCC BRANCH_TAU
        
        LDA $3C : CMP.b #$04 : BNE BRANCH_TAU
        
        ; I think.... this is checking for a sword slashable door?
        ; \task Find out how we get in here.
        REP #$31
        
        LDA $44 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_UPSILON
        
        ORA.w #$FF00
    
    BRANCH_UPSILON:
    
        ADD $20 : AND.w #$01F8 : ASL #3 : STA $00
        
        LDA $45 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_PHI
        
        ORA.w #$FF00
    
    BRANCH_PHI:
    
        ADD $22 : AND.w #$01F8 : LSR #3 : ORA $00 : TAX
        
        LDY.w #$0041
        
        ; checking for dash breakable wall? Not sure that I buy that, but it's
        ; a possibility.
        LDA $7F2000, X : AND.w #$00FC : CMP.w #$006C : BEQ BRANCH_CHI
        
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_CHI
        
        INX
        
        DEY
        
        LDA $7F2000, X : AND.w #$00FC : CMP.w #$006C : BEQ BRANCH_CHI
        
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_CHI
        
        TXA : ADD.w #$003F : TAX
        
        LDY.w #$0001
        
        LDA $7F2000, X : AND.w #$00FC : CMP.w #$006C : BEQ BRANCH_CHI
        
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_CHI
        
        INX
        
        DEY
        
        LDA $7F2000, X : AND.w #$00FC : CMP.w #$006C : BEQ BRANCH_CHI
        
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_CHI
        
        SEP #$30
        
        RTL
    
    BRANCH_CHI:
    
        STZ $0C
        
        CMP.w #$006C : BEQ BRANCH_PSI
    
        JMP $D18A ; $D18A IN ROM
    
    BRANCH_PSI:
    
        STY $0E : CPY.w #$0040 : BCC BRANCH_OMEGA
        
        TYA : AND.w #$000F : STA $0E
        
        TXA : SUB.w #$0040 : TAX
        
        LDA $7F2000, X : AND.w #$00FC : CMP.w #$006C : BEQ BRANCH_OMEGA
        
        TXA : ADD.w #$0040 : TAX
    
    BRANCH_OMEGA:
    
        LDY $0E : BEQ BRANCH_ALTIMA
        
        DEX
        
        LDA $7F2000, X : AND.w #$00FC : CMP.w #$006C : BEQ BRANCH_ALTIMA
        
        INX
    
    BRANCH_ALTIMA:
    
        TXA : SUB.w #$0041 : ASL A : STA $08
        
        LDA $7F2000, X : PHA
        
        LDA.w #$0202 : STA $7F2000, X : STA $7F2040, X
        
        PLA : AND.w #$0003 : ASL A : TAX
        
        LDA $01CE64, X : TAY
        
        LDX $08
        
        LDA.w #$0004 : STA $0E
    
    .next_column
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .next_column
        
        BRA BRANCH_OPTIMUS
    
    ; *$D18A ALTERNATE ENTRY POINT
    
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
        
        STX $068E
        
        LDA $1980, Y : AND.w #$00FE : CMP.w #$0032 : BNE BRANCH_ALIF
        
        SEP #$20
        
        LDA.b #$1B : STA $012F
        
        REP #$20
        
        LDA $19A0, Y : STA $08
        
        TYX
        
        LDA $068C : ORA $98C0, X : STA $068C
        
        LDA $0400 : ORA $98C0, X : STA $0400
        
        STZ $0692
        
        JSR $D365 ; $D365 IN ROM
        
        LDY $0460
        
        JSR $D51C ; $D51C IN ROM
    
    BRANCH_OPTIMUS:
    
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        SEP #$30
        
        LDA $08 : AND.b #$7F : ASL A
        
        JSL Sound_GetFineSfxPan
        
        ORA.b #$1E : STA $012E
        
        REP #$30
    
    ; *$D1E3 ALTERNATE ENTRY POINT
    
        LDY $0C
        
        ; Finalizes the buffer for the future DMA transfer.
        LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        ; Sets it up so that during NMI, the screen will update.
        LDA.b #$01 : STA $18
    
    BRANCH_ALIF:
    
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$D1F4-$D2C8 LONG
    Bomb_CheckForVulnerableTileObjects:
    {
        ; Check for cracked floors and expose bombable floor if necessary

        LDA $10 : CMP.b #$07 : BEQ .indoors
        
        JML Overworld_ApplyBombToTiles
    
    .indoors
    
        STZ $0F
        
        REP #$30
        
        LDA $00 : AND.w #$01F8 : ASL #3 : STA $04
        LDA $02 : AND.w #$01F8 : LSR #3 : ORA $04
        
        ; after computing result move up two tiles and one to the left
        SUB.w #$0082 : TAX
        
        LDY.w #$0002
    
    BRANCH_DELTA:
    
        ; Look for cracked floors
        LDA $7F2000, X : AND.w #$00FF : CMP.w #$0062 : BEQ BRANCH_BETA
        
        ; bombable walls
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_GAMMA
        
        INX #2
        
        ; cracked floor again
        LDA $7F2000, X : AND.w #$00FF : CMP.w #$0062 : BEQ BRANCH_BETA
        
        ; bombable walls
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_GAMMA
        
        INX #2
        
        LDA $7F2000, X : AND.w #$00FF : CMP.w #$0062 : BEQ BRANCH_BETA
        
        AND.w #$00F0 : CMP.w #$00F0 : BEQ BRANCH_GAMMA
        
        TXA : ADD.w #$007C : TAX
        
        DEY : BPL BRANCH_DELTA
              BMI BRANCH_EPSILON
    
    BRANCH_BETA:
    
        JMP $D2C9 ; $D2C9 IN ROM
    
    BRANCH_GAMMA:
    
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
        
        ; This whole section is about bombable doors, so it needs to draw a door
        ; This handles the various kinds of tiles that will get replaced in a bombing
        LDA $1980, Y : AND.w #$00FE : CMP.w #$0028 : BEQ BRANCH_ZETA
        
        CMP.w #$002A : BEQ BRANCH_ZETA
        
        CMP.w #$002E : BNE BRANCH_EPSILON
    
    BRANCH_ZETA:
    
        STX $068E
        
        LDA $0E : ASL A : TAX
        
        LDA $19A0, Y : AND.w #$007E : ASL #2 : ADD $062C : STA $03B6, X
        LDA $19A0, Y : AND.w #$1F80 : LSR #4 : ADD $062E : STA $03BA, X

        SEP #$20

        LDX $0E

        LDA $19C0, Y : AND.b #$03 : STA $03BE, X

        ; Play a "puzzle solved" noise
        LDA.b #$1B : STA $012F

        ; Put us in bombing open a door submodule
        LDA.b #$09 : STA $11

    BRANCH_EPSILON:

        SEP #$30

        RTL
    }

; ==============================================================================

    ; *$D2C9-$D2E7 JUMP LOCATION (LONG)
    {
        ; \hardcoded Obviously.
        LDA $A0 : CMP.w #$0065 : BNE .not_room_above_blind
        
        LDA $0402 : ORA.w #$1000 : STA $0402
    
    .not_room_above_blind
    
        LDA.w #$0000
        
        JSL Dungeon_CustomIndexedRevealCoveredTiles
        
        SEP #$30
        
        LDA.b #$1B : STA $012F
        
        RTL
    }

; ==============================================================================

    ; *$D2E8-$D310 LOCAL
    {
        LDX $19A0, Y : STX $08
        
        STY $0460
        STY $0694
        
        LDA $19C0, Y : AND.w #$0003 : BNE .not_up
        
        JMP $FA54 ; $FA54 IN ROM
    
    .not_up
    
        CMP.w #$0001 : BNE .not_down
        
        JMP $FB15 ; $FB15 IN ROM
    
    .not_down
    
        CMP.w #$0002 : BNE .not_left
        
        JMP $FBCC ; $FBCC IN ROM
    
    .not_left
    
        ; Must be right then, directionally...
        JMP $FC8A ; $FC8A IN ROM
    }

; ==============================================================================

    ; *$D311-$D339 LOCAL
    {
        ; Load door's tilemap address
        LDX $19A0, Y : STX $08
        
        ; Store its position in the door arrays.
        STY $0460
        STY $0694
        
        LDA $19C0, Y : AND.w #$0003 : BNE .not_up
        
        JMP $FA4A ; $FA4A IN ROM
    
    .not_up
    
        CMP.w #$0001 : BNE .not_down
        
        JMP $FB0B ; $FB0B IN ROM
    
    .not_down
    
        CMP.w #$0002 : BNE .not_left
        
        JMP $FBC2 ; $FBC2 IN ROM
    
    .not_left
    
        ; The direction must be to the right then.
        JMP $FC80 ; $FC80 IN ROM
    }

; ==============================================================================

    ; *$D33A-$D364 LOCAL
    {
        LDX $19A0, Y : STX $08
        
        STY $0460
        STY $04
        STY $0694
        
        LDA $19C0, Y : AND.w #$0003 : BNE .not_up
        
        JMP $FAD7 ; $FAD7 IN ROM
    
    .not_up
    
        CMP.w #$0001 : BNE .not_down
        
        JMP $FB8E ; $FB8E IN ROM
    
    .not_down
    
        CMP.w #$0002 : BNE .not_left
        
        JMP $FC45 ; $FC45 IN ROM
    
    .not_left
    
        JMP $FD03 ; $FD03 IN ROM
    }

; ==============================================================================

    ; *$D365-$D372 LOCAL
    {
        LDX $19A0, Y : STX $08
        
        STY $0460 : STY $0694
        
        JMP $FD3E ; $FD3E IN ROM
    }

; ==============================================================================

    ; *$D373-$D38E LOCAL
    {
        STZ $045E
        STZ $0C
        STZ $0690
        
        LDY $0456 : STY $0460
        
        LDX $19A0, Y
        
        DEX #2 : STX $08
        
        TXA : STA $19A0, Y
        
        JMP $FD92 ; $FD92 IN ROM
    }

; ==============================================================================

    ; *$D38F-$D468 LONG
    Dungeon_AnimateTrapDoors:
    {
        ; Invoked from Module 0x07.0x05
        
        ; variables
        ; Y seems to be used as the animation state for the door?
        ; it's selected by logic, of course.
        
        REP #$30
        
        STZ $0C
        
        INC $0690
        
        LDA $0690
        
        LDY $0468 : BNE .trap_doors_are_down
        
        INY #2
        
        ; Shut the door halfway
        CMP.w #$0004 : BEQ .begin_tile_animation_logic
        
        INY #2
        
        ; Shut the door all the way.
        CMP.w #$0008 : BEQ .begin_tile_animation_logic
    
    .no_tile_animation_this_frame
    
        JMP .tile_animation_complete
    
    .trap_doors_are_down
    
        LDY.w #$0002
        
        CMP.w #$0004 : BEQ .begin_tile_animation_logic
        
        DEY #2
        
        CMP.w #$0008 : BNE .no_tile_animation_this_frame
    
    .begin_tile_animation_logic
    
        ; Y = ...
        ; 0x00 - fully open
        ; 0x02 - half open
        ; 0x04 - fully shut
        STY $0692
        
        ; This means we're going to iterate over all doors (almost).
        LDY.w #$0000
    
    .check_next_door
    
        STY $068E
        
        LDA $1980, Y : AND.w #$00FE
        
        CMP.w #$0044 : BEQ .is_trap_door
        CMP.w #$0018 : BNE .aint_trap_door
    
    .is_trap_door
    
        ; \task I think the name of this branch has it backwards... find out.
        LDA $0468 : BNE .rising_trap_doors
        
        LDA $068C : AND $98C0, Y : BNE BRANCH_EPSILON
        
        LDA $0690 : CMP.w #$0008 : BNE BRANCH_THETA
        
        PHY
        
        SEP #$30
        
        LDA.b #$15 : STA $012F
        
        REP #$30
        
        PLY
        
        LDA $068C : ORA $98C0, Y
        
        BRA BRANCH_IOTA
    
    .rising_trap_doors
    
        LDA $068C : AND $98C0, Y : BEQ BRANCH_EPSILON
        
        LDA $0690 : CMP.w #$0008 : BNE BRANCH_THETA
        
        PHY
        
        SEP #$30
        
        LDA.b #$16 : STA $012F
        
        REP #$30
        
        PLY
        
        LDA $068C : AND $98E0, Y
    
    BRANCH_IOTA:
    
        STA $068C
    
    BRANCH_THETA:
    
        JSR $D311 ; $D311 IN ROM; Called in opening and closing doors
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDA $0690 : CMP.w #$0008 : BNE BRANCH_EPSILON
        
        LDY $068E
        
        JSR $D51C ; $D51C IN ROM
    
    BRANCH_EPSILON:
    .aint_trap_door
    
        LDY $068E : INY #2 : CPY.w #$0018 : BEQ .done_checking_for_trap_doors
        
        JMP .check_next_door
    
    .done_checking_for_trap_doors
    
        LDY $0C : BEQ BRANCH_LAMBDA
        
        LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        LDA.b #$01 : STA $18 : STA $0710
    
    .tile_animation_complete
    
        SEP #$20
        
        ; Check if we're finished opening / closing trap doors.
        LDA $0690 : CMP.b #$10 : BNE .not_finished_animating
    
    BRANCH_LAMBDA:
    
        SEP #$20
        
        STZ $11
        STZ $18
    
    .not_finished_animating
    
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$D469-$D50F LONG
    Dungeon_AnimateDestroyingWeakDoor:
    {
        REP #$30
        
        LDA.w #$0010 : STA $0690
        
        LDY.w #$0004
        
        BRA .set_event_flags
    
    ; *$D476 ALTERNATE ENTRY POINT
    shared Dungeon_AnimateOpeningLockedDoor:
    
        ; (Door opening)
        
        REP #$30
        
        LDY.w #$0002
        
        INC $0690
        
        LDA $0690 : CMP.w #$0004 : BEQ .halfOpenDoor
        
        INY #2
        
        CMP.w #$000C : BNE .dont_set_flags_yet
    
    .set_event_flags
    
        LDX $068E
        
        LDA $7F2000, X : AND.w #$0007 : ASL A : TAX
        
        LDA $068C : ORA $98C0, X : STA $068C
        LDA $0400 : ORA $98C0, X : STA $0400
    
    .halfOpenDoor
    
        ; Y = 0x02 or 0x04
        STY $0692
        
        STZ $0C
        
        LDX $068E
        
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
        
        JSR $D2E8 ; $D2E8 IN ROM
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDY $0C
        
        LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        LDA.b #$15 : STA $012F
        
        LDA.b #$01 : STA $18
        
        REP #$30
    
    .dont_set_flags_yet
    
        LDA $0690 : CMP.w #$0010 : BNE .notFullyOpen
        
        ; $D510 IN ROM; Blow open bombable wall, open key door
        JSR $D510
        
        LDX $068E
        
        LDA $7F2000, X : AND.w #$00FF : CMP.w #$00F0 : BCC .notKeyDoor
        
        AND.w #$000F : ASL A : TAY
        
        LDA $1980, Y : AND.w #$00FF
        
        CMP.w #$0020 : BCC .notKeyDoor
        CMP.w #$0028 : BCS .notKeyDoor
        
        ; Handles special key doors that hide spiral staircases
        JSR Object_RefreshStaircaseAttr
    
    .notKeyDoor
    
        SEP #$20
        
        STZ $11
    
    .notFullyOpen
    
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$D510-$D5A9 LOCAL
    Dungeon_LoadToggleDoorAttr:
    {
        LDX $068E
        
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
    
    ; *$D51C ALTERNATE ENTRY POINT
    
        JSR Dungeon_LoadSingleDoorAttr
    
    ; *$D51F ALTERNATE ENTRY POINT
    .extern
    
        ; Do attributes for floor toggling doors
        ; (doors that toggle which floor Link is on)
        LDX $044E : BEQ .doneWithFloorToggleDoors
        
        LDY.w #$0000
    
    .nextFloorToggleDoor
    
        LDX $06C0, Y
        
        LDA $7F2000, X : AND.w #$00F0 : CMP.w #$0080 : BNE .skipFloorToggleDoor
        
        LDA $7F2000, X : ORA.w #$1010 : STA $7F2000, X : STA $7F2040, X
        
        INY #2 : CPY $044E : BNE .nextFloorToggleDoor
        
        BRA .doneWithFloorToggleDoors
    
    .skipFloorToggleDoor
    
        LDA $7F3000, X : ORA.w #$1010 : STA $7F3000, X : STA $7E3040, X
        
        INY #2 : CPY $044E : BNE .nextFloorToggleDoor
    
    .doneWithFloorToggleDoors
    
        ; Do attributes for type 0x14 doors? (dungeon toggling doors)
        LDX $0450 : BEQ .return
        
        LDY.w #$0000
    
    .nextPalaceToggleDoor
    
        LDX $06D0, Y
        
        ; If not on BG2, see if there's an open door here on BG1
        LDA $7F2000, X : AND.w #$00F0 : CMP.w #$0080 : BNE .tryBG1
        
        ; BG2 tile attributes
        LDA $7F2000, X : ORA.w #$2020 : STA $7F2000, X : STA $7F2040, X
        
        INY #2 : CPY $0450 : BNE .nextPalaceToggleDoor
        
        BRA .return
    
    .tryBG1
    
        ; BG1 tile attributes
        LDA $7F3000, X : ORA.w #$2020 : STA $7F3000, X : STA $7E3040, X
        
        INY #2 : CPY $0450 : BNE .nextPalaceToggleDoor
    
    .return
    
        RTS
    }

    ; *$D5AA-$D6C0 LOCAL
    Object_RefreshStaircaseAttr:
    {
        LDA.w #$3030 : STA $00
        
        LDY.w #$0000
        
        LDX $0438 : BEQ .noInFloorUpStaircases
    
    .nextStaircase
    
        LDA $00 : ADD.w #$0101 : STA $00
        
        INY #2
        
        CPY $0438 : BNE .nextStaircase
    
    .noInFloorUpStaircases
    
        CPY $047E : BEQ .noSpiralUpStaircasesBG2
    
    .nextStaircase2
    
        LDX $06B0, Y
        
        LDA.w #$5E5E : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        LDA.w #$0000 : STA $7F2081, X : STA $7F20C1, X
        
        INY #2 : CPY $047E : BNE .nextStaircase2
    
    .noSpiralUpStaircasesBG2
    
        CPY $0482 : BEQ .noSpiralUpStaircasesBG1
    
    .nextStaircase3
    
        LDX $06B0, Y
        
        LDA.w #$5F5F : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        LDA.w #$0000 : STA $7F2081, X : STA $7F20C1, X
        
        INY #2 : CPY $0482 : BNE .nextStaircase3
    
    .noSpiralUpStaircasesBG1
    
        CPY $04A2 : BEQ .noInWallUpNorthStraightStaircases
    
    .nextStaircase4
    
        LDA $00 : ADD #$0101 : STA $00
        
        INY #2 : CPY $04A2 : BNE .nextStaircase4
    
    .noInWallUpNorthStraightStaircases
    
        CPY $04A4 : BEQ .noInWallUpSouthStraightStaircases
    
    .nextStaircase5
    
        LDA $00 : ADD #$0101 : STA $00
        
        INY #2 : CPY $04A4 : BNE .nextStaircase5
    
    .noInWallupSouthStraightStaircases
    
        LDA $00 : AND.b #$0707 : ORA.b #$3434 : STA $00
        
        CPY $043A : BEQ .noInFloorDownSouthStaircases
    
    .nextStaircase6
    
        LDA $00 : ADD.w #$0101 : STA $00
        
        INY #2 : CPY $043A : BNE .nextStaircase6
    
    .noInFloorDownSouthStaircases
    
        CPY $0480 : BEQ .noDownNorthSpiralStaircasesBG2
    
    .nextStaircase7
    
        LDX $06B0, Y
        
        LDA.w #$5E5E : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X : ADD.w #$0101 : STA $00
        
        LDA.w #$0000 : STA $7F2081, X : STA $7F20C1, X
        
        INY #2 : CPY $0480 : BNE .nextStaircase7
    
    .noDownNorthSpiralStaircasesBG2
    
        CPY $0484 : BEQ .noDownNorthSpiralStaircasesBG1
    
    .nextStaircase8
    
        LDX $06B0, Y
        
        LDA.w #$5F5F : STA $7F2001, X
        
        LDA $00 : STA $7F2041, X
        ADD.w #$0101 : STA $00
        
        LDA.w #$0000 : STA $7F2081, X : STA $7F20C1, X
        
        INY #2 : CPY $0484 : BNE .nextStaircase8
    
    .noDownNorthSpiralStaircasesBG1
    
        RTS
    }

; ==============================================================================

    ; *$D6C1-$D747 LONG
    Door_BlastWallExploding:
    {
        ; compare with $7F0000? .... well that's confusing
        LDA.b #$06 : STA $02E4 : STA $0FC1 : CMP $7F0000 : BNE BRANCH_ALPHA
        
        REP #$30
        
        JSR $D373 ; $D373 IN ROM
        JSR $F811 ; $F811 IN ROM
        
        LDA.w #$FFFF : STA $1100, Y : STA $0710
        
        INC $0454
        INC $0454
        
        LDA $0454 : CMP.w #$0015 : BNE .notDoneExploding
        
        LDY $0456
        
        LDA $068C : ORA $98C0, Y : STA $068C
        
        LDA $0400 : ORA $98C0, Y : STA $0400
        
        LDX.w #$0001
        
        LDA $19C0, Y : LDY.w #$0100 : AND.w #$0002 : BEQ BRANCH_GAMMA
        
        LDY.w #$0001
        
        DEX
    
    BRANCH_GAMMA:
    
        TYA : ORA $0452 : STA $0452
        
        LDA $A6, X : ORA.w #$0002 : STA $A6, X
        
        LDA $A6 : STA $7EC19C
        
        LDY $0456
        
        JSR Door_LoadBlastWallAttr
        
        STZ $0454
        STZ $0456
        
        SEP #$30
        
        JSL Dungeon_SaveRoomQuadrantData
        
        STZ $02E4
        STZ $0FC1
    
    .notDoneExploding
    
        SEP #$30
        
        LDA.b #$03 : STA $18
    
    BRANCH_ALPHA:
    
        RTL
    }

; ==============================================================================

    ; *$D748-$D7BF LONG
    Dungeon_QueryIfTileLiftable:
    {
        REP #$30
        
        ; What direction is player facing?
        LDA $2F : AND.w #$00FF : TAX
        
        LDA $20 : ADD $01D9BA, X : AND.w #$01F8 : ASL #3 : STA $06
        
        ; All this rigamarole is to find the position of this tile's data in
        ; memory.
        LDA $22 : ADD $01D9C2, X : AND.w #$01F8 : LSR #3 : ORA $06 : STA $06
        
        LDA $EE : AND.w #$00FF : BEQ .on_bg2
        
        ; If its on a higher floor (layer) just add 0x1000 to the address.
        LDA $06 : ORA.w #$1000 : STA $06
    
    .on_bg2
    
        LDX $06
        
        ; um... I'm guessing it�s checking to see if it's a pot or bush.
        LDA $7F2000, X : AND.w #$00F0 : CMP.w #$0070 : BNE .not_liftable
        
        LDA $7F2000, X : AND.w #$000F : ASL A : TAX
        
        ; Means the tile looks like a pot, but has no replacement tile and thus
        ; can't be picked up
        LDA $0500, X : BEQ .not_liftable
        
        LDY.w #$0055
        
        AND.w #$F0F0 : CMP.w #$2020 : BEQ .large_block
        
        LDA $0500, X : AND.w #$000F : ASL A : TAX
        
        LDA $01D9E2, X : TAY
    
    .large_block
    
        TYA
        
        ; note that here we're also setting the carry flag.
        SEP #$31
        
        RTL
    
    .not_liftable
    
        LDX $06
        
        LDA $7F2000, X
        
        SEP #$30
        
        CLC
        
        RTL
    }

; ==============================================================================

    ; *$D7C0-$D827 BRANCH LOCATION
    pool PushBlock_Handler:
    {
    
    .move_distances
        dw -256, 256, -4, 4
    
    .check_for_active_block
    
        LDA $0500, Y : BEQ .next_block
        CMP.w #$0001 : BNE .not_block_phase_1
        
        JSR Dungeon_EraseInteractive2x2
        
        LDX $0474
        
        ; Move the block's tilemap position 2 tiles in the
        ; appropriate direction.
        LDA $0540, Y : ADD .move_distances, X : STA $0540, Y
        
        BRA .increment_object_state
    
    .not_block_phase_1
    
        CMP.w #$0002 : BNE .not_block_phase_2
        
        SEP #$30
        
        JSL $07EDB5 ; $3EDB5 IN ROM
        
        REP #$30
        
        LDY $042C
        
        LDA $0500, Y : CMP.w #$0003 : BNE .next_block
        
        JSR PushBlock_StoppedMoving
        
        BRA .increment_object_state
    
    .not_block_phase_2
    
        CMP.w #$0004 : BNE .next_block
        
        SEP #$20
        
        JSL $07EDF9 ; $3EDF9 IN ROM
        
        BRA .next_block
    
    .increment_object_state
    
        LDX $042C
        
        INC $0500, X
    
    .next_block
    
        INC $042C : INC $042C
    
    ; *$D81B MAIN ENTRY POINT
    PushBlock_Handler:
    
        REP #$30
        
        LDY $042C : CPY $0478 : BNE .check_for_active_block
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$D828-$D8D3 LOCAL
    Dungeon_EraseInteractive2x2:
    {
        LDX $1000
        
        LDA $0560, Y : STA $1006, X
        LDA $0580, Y : STA $100C, X
        LDA $05A0, Y : STA $1012, X
        LDA $05C0, Y : STA $1018, X
        
        LDA $0540, Y : AND.w #$3FFF : TAX
        
        LDA $0560, Y : STA $7E2000, X
        LDA $0580, Y : STA $7E2080, X
        LDA $05A0, Y : STA $7E2002, X
        LDA $05C0, Y : STA $7E2082, X : AND.w #$03FF : TAX
        
        LDA $7EFE00, X : AND.w #$00FF : STA $00 : STA $01
        
        LDA $0540, Y : AND.w #$3FFF : LSR A : TAX
        
        LDA $00
    
    ; *$D87F ALTERNATE ENTRY POINT
    .partially_prepped
    
        STA $7F2000, X : STA $7F2040, X
        
        LDX $1000
        
        LDA.w #$0000
        
        JSR Dungeon_GetInteractiveVramAddr
        
        STA $1002, X
        
        LDA.w #$0080
        
        JSR Dungeon_GetInteractiveVramAddr
        
        STA $1008, X
        
        LDA.w #$0002
        
        JSR Dungeon_GetInteractiveVramAddr
        
        STA $100E, X
        
        LDA.w #$0082
        
        JSR Dungeon_GetInteractiveVramAddr
        
        STA $1014, X
        
        LDA.w #$0100 : STA $1004, X : STA $100A, X : STA $1010, X : STA $1016, X
        
        LDA.w #$FFFF : STA $101A, X
        
        TXA : ADD.w #$0018 : STA $1000
        
        SEP #$20
        
        ; A dma transfer should trigger during the next frame that will
        ; update the 4 tilemap entries we have indicated in vram.
        LDA.b #$01 : STA $14
        
        REP #$30
        
        RTS
    }

; ==============================================================================

    ; *$D8D4-$D98D LOCAL
    PushBlock_StoppedMoving:
    {
        LDA $0540, Y : AND.w #$4000 : BNE .blockTriggersSomething
        
        LDA $0641 : EOR.w #$0001 : STA $0641
    
    .blockTriggersSomething
    
        LDA $0540, Y : AND.w #$3FFF : LSR A : TAX
        
        ; Check if the block landed on a pit tile.
        LDA $7F2000, X : AND.w #$00FF : CMP.w #$0020 : BEQ .blockFellIntoPit
        
        PHA : PHY : PHX
        
        LDX $1000
        
        ; Doing preliminary work to update the tilemap with the rematerializing
        ; block that has since moved by 2 tiles in some direction.
        LDA.w #$0922 : STA $1006, X : INC A : STA $1012, X
        LDA.w #$0932 : STA $100C, X : INC A : STA $1018, X
        
        LDA $0540, Y : AND.w #$3FFF : TAX
        
        LDA.w #$0922 : STA $7E2000, X : INC A : STA $7E2002, X
        LDA.w #$0932 : STA $7E2080, X : INC A : STA $7E2082, X
        
        SEP #$20
        
        STY $72
        
        LDX.w #$0001
        
        LDA $05FC, X : DEC A : ASL A : CMP $72 : BEQ .correct_index
        
        LDX.w #$0000
    
    .correct_index
    
        ; The block has rematerialized, we no longer need to indicate that this
        ; object is active, so terminate it.
        STZ $05FC, X
        
        REP #$20
        
        PLX : PLY : PLA
        
        CMP.w #$0023 : BNE .didnt_land_on_switch
        
        LDA $0468 : EOR.w #$0001 : STA $0466
        
        LDA.w #$0004
        
        BRA .set_block_state
    
    .didnt_land_on_switch
    
        LDA.w #$FFFF
    
    .set_block_state
    
        STA $0500, Y
        
        LDA.w #$2727
        
        JMP Dungeon_EraseInteractive2x2_partially_prepped
    
    .blockFellIntoPit
    
        SEP #$20
        
        ; Play a dropping sound effect?
        LDA.b #$20 : STA $012E
        
        REP #$20
        
        LDY $042C
        
        LDX $0520, Y
        
        ; Load the room destination for warp/pits.
        ; (This code is for the ice palace dungeon)
        ; Set the block as being in that room now.
        LDA $7EC000 : AND.w #$00FF : STA $7EF940, X
        
        ; Set its new position.
        LDA $0540, Y : STA $7EF942, X
        
        RTS
    }

; ==============================================================================

    ; *$D98E-$D9B9 LOCAL
    Dungeon_GetInteractiveVramAddr:
    {
        !tile_offset = $0E
        
        STA !tile_offset
        
        LDA $0540, Y : AND.w #$3FFF : ADD !tile_offset : STA !tile_offset
        
                           AND.w #$0040 : LSR #4 : XBA     : STA $00
        LDA !tile_offset : AND.w #$303F : LSR A  : ORA $00 : STA $00
        LDA !tile_offset : AND.w #$0F80 : LSR #2 : ORA $00 : XBA
        
        RTS
    }

; ==============================================================================

    ; $D9BA-$D9EB DATA
    pool Dungeon_RevealCoveredTiles:
    ; \task Name this pool / routine.
    {
    
    ; $D9BA
    .y_offsets
        dw 3, 24, 14, 14
        
    ; $D9C2
    .x_offsets
        dw 7,  7, -3, 16
    
    ; $D9CA
      
        ; Seems to be \unused ...
        dw 0, -2, -128, -130
        dw 0,  0, -128, -128
        dw 0, -2,    0,   -2
        
    ; $D9E2
        
        dw $5252, $5050, $5454, $0000, $2323
    }
    
; ==============================================================================

    ; *$D9EC-$DABA LONG
    Dungeon_RevealCoveredTiles:
    {
        ; secrets
        
        REP #$30
        
        LDA $2F : AND.w #$00FF : TAX
        
        ; tells us how far to look from Link's sprite in the Y direction
        ; (either positive or negative depending on the direciton he's currently facing
        LDA $20 : ADD.l .y_offsets, X : STA $00 : STA $C8
        
        ; mask to increments of 8 in coordinate (one tile)
        AND.w #$01F8 : ASL #3 : STA $06
        
        ; Do the same thing for the X direction.
        LDA $22 : ADD.l .x_offsets, X : STA $02 : STA $CA
        
        ; mask to increments of 8 in coordinate (one tile)
        ; $06 = 0000yyyy yyxxxxxx
        AND.w #$01F8 : LSR #3 : TSB $06
        
        ; See what floor Link is on
        LDA $EE : AND.w #$00FF : BEQ .on_bg2
        
        LDA $06 : ORA.w #$1000 : STA $06
    
    .on_bg2
    
        LDX $06
        
        ; Examine the tile type at this target location
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
        
        ; Check replaceable tile attributes
        ; See if they're in the 0x10 to 0x1F range (I think?)
        LDA $0500, Y : AND.w #$F0F0 : CMP.w #$1010 : BNE .not_pot_tiles
        
        ; If so, push the replaceable tile attributes to the stack.
        LDA $0500, Y : PHA
        
        ; Store this offset into $0500, Y and $0540, Y for later use
        STY $042C
        
        LDA $0540, Y
        
        JSR Dungeon_LoadSecret
        
        LDY $042C
        
        JSR Dungeon_EraseInteractive2x2
        
        PLA : AND.w #$000F : ASL A : TAX
        
        LDA $01D9E2, X : STA $06
        
        BRA BRANCH_GAMMA
    
    .not_pot_tiles
    
        CMP.w #$2020 : BNE .not_large_block
        
        LDA $0500, Y : AND.w #$000F : ASL A : STA $00
        
        TYA : SUB $00
    
    ; $DA71 ALTERNATE ENTRY POINT
    shared Dungeon_CustomIndexedRevealCoveredTiles:
    
        STA $042C : PHA : TAY
        
        PHY
        
        LDA $0540, Y
        
        JSR Dungeon_LoadSecret
        
        PLY
        
        JSR Dungeon_EraseInteractive2x2
        
        INC $042C : INC $042C : LDY $042C
        
        JSR Dungeon_EraseInteractive2x2
        
        INC $042C : INC $042C : LDY $042C
        
        JSR Dungeon_EraseInteractive2x2
        
        INC $042C : INC $042C : LDY $042C
        
        JSR Dungeon_EraseInteractive2x2
        
        LDA.w #$5555 : STA $06
        
        PLA : STA $042C
    
    BRANCH_GAMMA:
    
        JSR Dungeon_GetUprootedTerrainSpawnCoords
        
        LDA $06
        
        SEP #$30
        
        RTL
    
    .not_large_block
    
    ; $DAB6 ALTERNATE ENTRY POINT
    pool Dungeon_ToolAndTileInteraction:
    
    .easy_out
    
        SEP #$30
        
        LDA.b #$00
        
        RTL
    }

; ==============================================================================

    ; *$DABB-$DB40 JUMP LOCATION
    Dungeon_ToolAndTileInteraction:
    {
        !pot_tile  = $1010
        !mole_tile = $4040
        
        REP #$30
        
        ; Only tool that dungeons check for is the hammer (for smashing pots).
        LDA $0301 : AND.w #$0002 : BEQ .easy_out
        
        LDA $00 : AND.w #$01F8 : ASL #3 : ADC $02 : STA $06
        
        LDA $EE : AND.w #$00FF : BEQ .on_bg2
        
        LDA $06 : ORA.w #$1000 : STA $06
    
    .on_bg2
    
        LDX $06
        
        LDA $7F2000, X : AND.w #$00F0 : CMP.w #$0070 : BNE .easy_out
        
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
        
        LDA $0500, Y : AND.w #$F0F0 : CMP.w #$4040 : BNE .not_mole
        
        LDA $0500, Y : PHA
        
        STY $042C
        
        JSR Dungeon_EraseInteractive2x2
        
        PLA
        
        SEP #$30
        
        LDA.b #$11 : STA $012E
        
        LDA.b #$00
        
        RTL
    
    .not_mole
    
        CMP.w #$1010 : BNE .easy_out
        
        STY $042C
        
        LDA $0540, Y
        
        JSR Dungeon_LoadSecret
        
        LDY $042C
        
        JSR Dungeon_EraseInteractive2x2
        JSR Dungeon_GetUprootedTerrainSpawnCoords
        
        SEP #$30
        
        LDA $0B9C : ORA.b #$80 : STA $0B9C
        
        LDA.b #$01
        
        JSL Sprite_SpawnImmediatelySmashedTerrain
        JML AddDisintegratingBushPoof
    }

; ==============================================================================

    ; *$DB41-$DB68 LOCAL
    Dungeon_GetUprootedTerrainSpawnCoords:
    {
        LDY $042C
        
        LDA $0540, X : PHA
        
        AND.w #$007E : ASL #2 : STA $00
        
        ; Since the sprite is instantiating because of the player, it makes
        ; sense to use their upper coordinate bytes as a guide...
        
        LDA $22 : AND.w #$FE00 : TSB $00
        
        PLA : AND.w #$1F80 : ASL A : XBA : ASL #3 : STA $02
        
        LDA $20 : AND.w #$FE00 : TSB $02
        
        RTS
    }

; ==============================================================================

    ; $DB69-$E6B1
    {
        ; Secrets data
    }

; ==============================================================================

    ; *$E6B2-$E794 LOCAL
    Dungeon_LoadSecret:
    {
        ; Seems to load "secrets" data from ROM when a secret is exposed
        ; by various means
        
        STA $04
        
        ; ???? unknown variable
        LDA $0B9C : AND.w #$FF00 : STA $0B9C
        
        ; Load the room, multiply by 2, send to X register
        LDA $A0 : ASL A : TAX
        
        ; Secrets pointer array (16-bit local pointer for each of the 0x140 rooms).
        LDA $01DB69, X : STA $00
        
        ; When moving the secrets data, this will make it cake ;)
        LDA.w #$0001 : STA $02
        
        LDY.w #$FFFD
        LDX.w #$FFFF
    
    .nextSecret
    
        INY #3
        
        ; Load up the first word of data. Terminate if it matches this value
        LDY [$00], Y : CMP.w #$FFFF : BEQ .return
        
        ; Tells us how many bits to shift in when saving this info
        INX
        
        ; $04 is the tilemap address in question. Loop until we find it or run out of options
        AND.w #$7FFF : CMP $04 : BNE .nextSecret
        
        ; In this case, the address matched
        INY #2
        
        ; Load the next word (but only need a byte)
        ; Terminate if it is nothing... (why would you put nothing?)
        LDA [$00], Y : AND.w #$00FF : BEQ .return
        
        ; If item >= 0x80, handle them specially
        CMP.w #$0080 : BCS .specialSecret
        
        ; Check to see if it's a key.
        STA $0E : CMP.w #$0008 : BEQ .isKey
        
        ; Y corresponds to the bit in the secrets data that will be set after being revealed.
        ; It will be used to set a flag that will not be set until Link leaves the dungeon
        ; or uses the magic mirror in the dungeon.
        TXY
        
        ; X = room index * 2
        LDA $A0 : ASL A : TAX
        
        STZ $00
        
        SEC
    
    .findBit
    
        ROL $00
        
        DEY : BPL .findBit
        
        LDA $7EF580, X : AND $00 : BNE .return
        
        LDA $7EF580, X : ORA $00 : STA $7EF580, X
        
        LDA $0E
    
    .isKey
    
        TSB $0B9C
    
    .return
    
        RTS
    
    .specialSecret
    
        CMP.w #$0088 : BEQ .isSwitch
        
        ; The last available option seems to be a 32x32 pixel hole...
        ; afaik this is only used in one dungeon (ice palace)
        
        LDX $06
        
        LDA $7F2000, X : AND.w #$000F : ASL A : TAY
        
        LDA $0500, Y : AND.w #$000F : ASL A : STA $00
        
        TYA : SUB $00 : STA $042C : TAY
        
        LDA.w #$0004 : STA $00
        
        SEP #$20
        
        ; Play the Zelda puzzle solved sound
        LDA.b #$1B : STA $012F
        
        REP #$20
        
        LDX.w #$05BA
    
    .drawHole
    
        LDA $009B52, X : STA $0560, Y
        LDA $009B54, X : STA $0580, Y
        LDA $009B56, X : STA $05A0, Y
        LDA $009B58, X : STA $05C0, Y
        
        TXA : ADD.w #$0008 : TAX
        
        INY #2
        
        DEC $00 : BNE .drawHole
        
        RTS
    
    .isSwitch
    
        ; switch under a pot is revealed
        
        LDY $042C
        
        ; Buffer some tiles to be saved to the tilemap after the pot is lifted
        ; the tiles are the tiles for the switch
        LDA.w #$0D0B : STA $0560, Y
        LDA.w #$0D1B : STA $0580, Y
        LDA.w #$4D0B : STA $05A0, Y
        LDA.w #$4D1B : STA $05C0, Y
        
        RTS
    }

; ==============================================================================

    ; $E795-$E7A8 DATA
    pool Dungeon_PrepSpriteInducedDma:
    {
    
    .replacement_tiles
        dw $00E0 ; 0x00 - pit (floor, rather?) (empty space?)
        dw $0ADE ; 0x02 - spike block
        dw $05AA ; 0x04 - pit
        dw $0198 ; 0x06 - hole from floor tile lifting up and attacking you
        dw $0210 ; 0x08 - ice man tile part 1
        dw $0218 ; 0x0A - ice man tile part 2
        dw $1F3A ; 0x0C - I think this one is unused. Could be interesting to know what the tiles were intended for.
        dw $0EAA ; 0x0E - Perky trigger Tile
        
        dw $0EB2 ; 0x10 - Depressed trigger tile
        dw $0140 ; 0x12 - Trinexx ice tile (pretty sure, but not certain)
    }

; ==============================================================================

    ; *$E7A9-$E7DE LONG
    Dungeon_SpriteInducedTilemapUpdate:
    {
        ; somehow this routine is related to ice men, moving spike blocks,
        ; and laser eye that can turn into doorways. could you really
        ; pick a stranger bunch? The unifying quality is that you all 
        ; have tilemap entries changing and sometimes turning into sprites
        ; Other things this is related to: swimmers in swamp palace that come
        ; out of walls.
        
        ; \note The parameter to this subroutine, the Y register, should be
        ; even when calling it.
        
        PHX
        
        STY $0E : STZ $0F
        
        PHB : LDA.b #$00 : PHA : PLB
        
        REP #$30
        
        LDA $0E : CMP.w #$0008 : BNE .not_ice_man
        
        PHA
        
        INC #2 : STA $0E
        
        LDA $00 : PHA
        
        ADD.w #$0010 : STA $00
        
        JSR Dungeon_PrepSpriteInducedDma
        
        PLA : STA $00
        PLA : STA $0E
    
    .not_ice_man
    
        JSR Dungeon_PrepSpriteInducedDma
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        PLB
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$E7DF-$E898 LOCAL
    Dungeon_PrepSpriteInducedDma:
    {
        ; Convert coordiates to tilemap position.
        LDA $02 : INC A : AND.w #$01F8 : ASL #3 : STA $06
        LDA $00         : AND.w #$01F8 : LSR #3 : ORA $06 : ASL A : STA $06
        
        LDX $0E
        
        LDA.l .replacement_tiles, X : TAY
        
        LDX $1000
        
        LDA $9B52, Y : STA $1006, X
        LDA $9B54, Y : STA $100C, X
        LDA $9B56, Y : STA $1012, X
        LDA $9B58, Y : STA $1018, X
        
        LDX $06
        
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2002, X
        LDA $9B58, Y : STA $7E2082, X
        
        AND.w #$03FF : TAX
        
        LDA $7EFE00, X : AND.w #$00FF : STA $08 : STA $09
        
        LDA $06 : LSR A : TAX
        
        LDA $08 : STA $7F2000, X
                  STA $7F2040, X
        
        LDX $1000
        
        LDA.w #$0000
        
        JSR Dungeon_GetRelativeVramAddr_2
        
        STA $1002, X
        
        LDA.w #$0080
        
        JSR Dungeon_GetRelativeVramAddr_2
        
        STA $1008, X
        
        LDA.w #$0002
        
        JSR Dungeon_GetRelativeVramAddr_2
        
        STA $100E, X
        
        LDA.w #$0082
        
        JSR Dungeon_GetRelativeVramAddr_2
        
        STA $1014, X
        
        LDA.w #$0100 : STA $1004, X : STA $100A, X : STA $1010, X : STA $1016, X
        
        LDA.w #$FFFF : STA $101A, X
        
        TXA : ADD.w #$0018 : STA $1000
        
        RTS
    }

; ==============================================================================

    ; *$E899-$E8BC LOCAL
    Dungeon_GetRelativeVramAddr_2:
    {
        ADD $06 : STA $0E
        
                  AND.w #$0040 : LSR #4 : XBA     : STA $08
        LDA $0E : AND.w #$303F : LSR A  : ORA $08 : STA $08
        LDA $0E : AND.w #$0F80 : LSR #2 : ORA $08 : XBA
        
        RTS
    }

; ==============================================================================

    ; *$E8BD-$E949 LONG
    Dungeon_ClearRupeeTile:
    {
        PHB : LDA.b #$00 : PHA : PLB
        
        REP #$30
        
        LDA $00 : AND.w #$01F8 : ASL #3 : STA $06
        LDA $02 : AND.w #$01F8 : LSR #3 : ORA $06 : ASL A : STA $06
        
        LDX $1000
        
        LDA.w #$190F : STA $1006, X : STA $100C, X
        
        LDX $06
        
        STA $7E2000, X : STA $7E2080, X
        
        AND.w #$03FF : TAX
        
        LDA $7EFE00, X : AND.w #$00FF : STA $08 : STA $09
        
        LDA $06 : LSR A : TAX
        
        LDA $08 : STA $7F2000, X : STA $7F2040, X
        
        LDX $1000
        
        LDA.w #$0000
        
        JSR Dungeon_GetRelativeVramAddr
        
        STA $1002, X
        
        LDA.w #$0080
        
        JSR Dungeon_GetRelativeVramAddr
        
        STA $1008, X
        
        LDA.w #$0100 : STA $1004, X : STA $100A, X
        
        LDA.w #$FFFF : STA $100E, X
        
        TXA : ADD.w #$0018 : STA $1000
        
        SEP #$30
        
        LDA $0403 : ORA.b #$10 : STA $0403
        
        LDA.b #$01 : STA $14
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$E94A-$E96D LOCAL
    Dungeon_GetRelativeVramAddr:
    {
        ADD $06 : STA $0C
        
                  AND.w #$0040 : LSR #4 : XBA     : STA $08
        LDA $0C : AND.w #$303F : LSR A  : ORA $08 : STA $08
        LDA $0C : AND.w #$0F80 : LSR #2 : ORA $08 : XBA
        
        RTS
    }

; ==============================================================================

    ; $E96E-$EB65
    Dungeon_ChestData:
    {
        ; top byte of each entry is the item to give, bottom 15 bits are the room
        ; if bit 15 (0x8000) is set, it's for a big chest
        dl $240032, $120055, $0C0071, $2500A8, $190113, $0B80A9, $280016, $250016
        dl $330037, $0A8036, $28010B, $1B8073, $250067, $28007E, $078058, $330058
        dl $320057, $240057, $32001F, $24007E, $22809E, $330077, $280005, $4000B9
        dl $330074, $3200B8, $120104, $4100FE, $320075, $17010C, $240068, $250085
        dl $160103, $36013D, $25002E, $36012D, $2400B3, $33003F, $24005F, $2400AE
        dl $320087, $0C0108, $2A0106, $46011C, $17010A, $3300AA, $1F8027, $250027
        dl $240059, $3300DB, $3200DB, $2500DC, $3600CB, $280065, $1C8044, $240045
        dl $2400B6, $068024, $3300B7, $2400B7, $2500D6, $320014, $3400D5, $3500D5
        dl $3600D5, $2400D5, $240004, $32003A, $24002A, $24002A, $09801A, $25001A
        dl $35001A, $24000A, $43006A, $24006A, $33002B, $280019, $240019, $240009
        dl $2400C2, $2400A2, $2500C1, $1580C3, $3300C3, $3200D1, $2400B3, $17010D
        dl $36010D, $3F0012, $2800F8, $3600F8, $410105, $280105, $410105, $180117
        dl $17002F, $36002F, $36002F, $36002F, $28002F, $240028, $250046, $360034
        dl $320035, $360076, $360076, $360066, $2400D0, $2400E0, $28007B, $44007B
        dl $36007B, $36007B, $44007C, $44007C, $28007C, $28007C, $24007D, $33008B
        dl $23808C, $44008C, $28008C, $44008C, $24008D, $25009D, $34009D, $36009D
        dl $44009D, $32001C, $44001C, $28001C, $24005B, $28003D, $28003D, $24003D
        dl $36004D, $120080, $330072, $17011D, $36011D, $36011D, $36011D, $36011D
        dl $36011E, $36011E, $36011E, $36011E, $3600EF, $3600EF, $3600EF, $3600EF
        dl $3600EF, $2800FF, $4400FF, $170124, $280123, $360123, $360123, $440123
        dl $080120, $41003C, $41003C, $41003C, $41003C, $280011, $460011, $440011
    }
    
; ==============================================================================

    ; *$EB66-$ED04 LONG
    Dungeon_OpenKeyedObject:
    {
        ; SearchForChest()
        
        ; Data loads are coming from bank00.
        PHB : LDX.b #$00 : PHX : PLB
        
        CMP.b #$63 : BNE .notMiniGameChest
        
        JMP Dungeon_OpenMinigameChest
    
    .notMiniGameChest
    
        REP #$30
        
        ; Obtain the tile type of the object and put it in the {0..5} range
        AND.w #$00FF : SUB.w #$0058 : STA $0E
        
        ASL A : PHA : TAY : PHY
        
        ; if it's not a big key lock
        LDA $06E0, Y : CMP.w #$8000 : BCC .notBigKeyLock
        
        ; It�s a big key lock. We have to examine the Big Key data.
        LDX $040C
        
        ; (this is the Big Key data)
        ; Branch if we have the Big Key.
        LDA $7EF366 : AND $0098C0, X : BNE .openBigKeyLock
        
        ; It�s the "Eh? You don�t have the big key" crap text message.
        LDA.w #$007A : STA $1CF0
        
        SEP #$30
        
        JSL Main_ShowTextMessage
        
        REP #$30
        
        BRA .cantOpenBigKeyLock
    
    .openBigKeyLock
    
        ; Set it so that the chest/lock is unlocked
        LDA $0402 : ORA $9900, Y : STA $0402
        
        ; Chest opening noise.
        LDA.w #$1529 : STA $012E
        
        LDA $06E0, Y : AND.w #$7FFF : TAX
        
        LDY $046A
        
        ; Draw floor tiles over the old ones (won't be permanent)
        LDA $9B52, Y : STA $7E2000, X : STA $02
        LDA $9B54, Y : STA $7E2080, X : STA $04
        LDA $9B56, Y : STA $7E2002, X : STA $06
        LDA $9B58, Y
        
        JMP .storeTilemapChanges
    
    .couldntFindChest
    
        PLX
    
    .cantOpenBigKeyLock
    
        PLY : PLA
        
        SEP #$30
        
        PLB
        
        CLC
        
        RTL
    
    .notBigKeyLock
    
        AND.w #$7FFF : TAX : PHX
        
        INC $0E
        
        LDX.w #$FFFD
    
    .nextChest
    
        ; This limits us to 168 chests... might have to change.
        INX #3 : CPX.w #$01F8 : BEQ .couldntFindChest
        
        ; An array of chest data, including the room and item number.
        ; Does the room in the data match the room we're in?
        LDA Dungeon_ChestData, X : AND.w #$7FFF : CMP $A0 : BNE .nextChest
        
        ; Not sure why this is here yet...
        DEC $0E : BNE .nextChest
        
        ; Load the item value.
        LDA Dungeon_ChestData+2, X : STA $0C
        
        ; Load the room index for the chest.
        LDA Dungeon_ChestData, X : ASL A : BCC .smallChest
        
        ; otherwise it�s a (you guessed it...) Big Chest.
        LDX $040C
        
        ; Make sure we have the key to it.
        LDA $7EF366 : AND $0098C0, X : BEQ .cantOpenBigChest
        
        PLX : PLA
        
        JMP Dungeon_OpenBigChest
    
    .cantOpenBigChest
    
        PLX : PLY : PLA
        
        ; Again the "eh, you don�t have the big key" message...
        LDA.w #$007A : STA $1CF0
        
        SEP #$30
        
        JSL Main_ShowTextMessage
        
        PLB
        
        CLC
        
        RTL
    
    .smallChest
    
        PLX
        
        ; Load room information about chests. Indicate to the game that this chest has been opened.
        LDA $0402 : ORA $9900, Y : STA $0402
        
        LDY.w #$14A4
        
        ; I guess this changes the tiles of the chest.
        LDA $9B52, Y : STA $7E2000, X : STA $02
        LDA $9B54, Y : STA $7E2080, X : STA $04
        LDA $9B56, Y : STA $7E2002, X : STA $06
        LDA $9B58, Y
    
    .storeTilemapChanges
    
        STA $7E2082, X : STA $08
        
        PLY
        
        LDA.w #$2727 : STA $00
        
        ; Is this a big key lock?
        LDA $06E0, Y : CMP.w #$8000 : BCC .notBigKeyLock2
        
        AND.w #$7FFF
        
        ; Use tile attr of 0x00 for each updated tile instead.
        STZ $00
    
    .notBigKeyLock2
    
        LSR A : TAX
        
        LDA $00 : STA $7F2000, X : STA $7F2040, X
        
        LDX $1000
        
        LDA.w #$0000
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1002, X
        
        LDA.w #$0080
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1008, X
        
        LDA.w #$0002
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $100E, X
        
        LDA.w #$0082
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1014, X
        
        LDA $02 : STA $1006, X
        LDA $04 : STA $100C, X
        LDA $06 : STA $1012, X
        LDA $08 : STA $1018, X
        
        ; Two bytes for each dma transfer. Source address increment mode is 
        ; incremental, vram address increment mode is horizontal.
        LDA.w #$0100 : STA $1004, X : STA $100A, X : STA $1010, X : STA $1016, X
        
        LDA.w #$FFFF : STA $101A, X
        
        TXA : ADD.w #$0018 : STA $1000
        
        SEP #$30
        
        ; A flag indicating to update the tilemap.
        LDA.b #$01 : STA $14
        
        JSR Dungeon_SaveRoomQuadrantData
        
        ; Is there a sound channel available?
        LDA $012F : BNE .sfx3ChannelNotAvailable
        
        ; Make the "chest opening" noise.
        LDA.b #$0E : STA $012F
    
    .sfx3ChannelNotAvailable
    
        REP #$30
        
        PLY
        
        ; The ReceiveItem portion of the game's code needs this as input to
        ; know the offset at which to place the item sprite.
        LDA $06E0, Y : AND.w #$7FFF : STA $72
        
        SEP #$31
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$ED05-$ED88 JUMP LOCATION
    Dungeon_OpenBigChest:
    {
        LDA $0402 : ORA $9900, Y : STA $0402
        
        STX $08
        
        LDA.w #$0004 : STA $0E
        
        LDY.w #$14C4
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        
        INY #6
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        LDA $0C : PHA
        
        JSR Dungeon_PrepOverlayDma.tilemapAlreadyUpdated
        
        LDY $0C
        
        LDA.w #$FFFF : STA $1100, Y
        
        PLA : STA $0C
        
        PLY
        
        LDA $06E0, Y : AND.w #$7FFF : PHA
        
        INC #2 : STA $72
        
        PLA : LSR A : TAX
        
        LDA.w #$2727 : STA $7F2000, X : STA $7F2002, X : STA $7F2040, X : STA $7F2042, X : STA $7F2080, X : STA $7F2082, X
        
        SEP #$31
        
        PLB
        
        JSL Dungeon_SaveRoomQuadrantData
        
        LDA.b #$0E : STA $012F
        
        LDA.b #$01 : STA $18
                     STA $0B9E
        
        SEC
        
        RTL
    }

; ==============================================================================

    ; *$ED89-$EDA2 BRANCH LOCATION
    Dungeon_ShowMinigameChestMessage:
    {
    
    .didnt_pay
    
        STA $C8
        
        REP #$20
        
        ; "Hey kid! You can open a chest after paying Rupees!"
        LDA.w #$0162
        
        BRA .showDialogue
    
    ; *$ED92 ALTERNATE ENTRY POINT
    .out_of_credits
    
        REP #$20
        
        ; "You can't open any more chests. The game is over."
        LDA.w #$0163
    
    .showDialogue
    
        STA $1CF0
        
        SEP #$20
        
        JSL Main_ShowTextMessage
        
        PLB
        
        CLC
        
        RTL
    }

; ==============================================================================

    ; $EDA3-$EDAA DATA
    Dungeon_MinigameChestPrizes:
    {
        ; 100 rupees, 50 rupees, 1 rupee, single heart, 1 array,
        ; 10 arrows, bomb refill, heart piece, respectively
        db $40, $41, $34, $42, $43, $44, $27, $17
    }

; ==============================================================================

    ; *$EDAB-$EED6 LONG
    Dungeon_OpenMiniGameChest:
    {
        ; number of credits left for opening minigame chests
        ; triggers.... "you need to buy more" message?
        LDA $04C4 : BEQ Dungeon_ShowMinigameChestMessage_out_of_credits
        
        ; triggers "you need to talk to me about my game" message?
        CMP.b #$FF : BEQ Dungeon_ShowMinigameChestMessage_didnt_pay
        
        ; reduce number of credits
        DEC $04C4
        
        REP #$30
        
        LDA $20 : SUB.w #$0004 : STA $00 : AND.w #$01F8 : ASL #3 : STA $06
        LDA $22 : ADD.w #$0007 : STA $02 : AND.w #$01F8 : LSR #3 : ORA $06 : TAX
        
        ; make sure the tiles we're touching are actually minigame chest tiles
        LDA $7F2000, X : CMP.w #$6363 : BEQ .match
        
        DEX
        
        LDA $7F2000, X : CMP.w #$6363 : BEQ .match
        
        INX #2
    
    .match
    
        ; make chest tiles impassible now
        LDA.w #$0202 : STA $7F2000, X : STA $7F2040, X
        
        TXA : ASL A : STA $72
        
        ADD.w #$0100 : TAX : STA $0C
        
        ; set replacement tiles to be drawn
        LDY.w #$14A4
        
        LDA $9B52, Y : STA $7E2000, X : STA $02
        LDA $9B54, Y : STA $7E2080, X : STA $04
        LDA $9B56, Y : STA $7E2002, X : STA $06
        LDA $9B58, Y : STA $7E2082, X : STA $08
        
        LDX $1000
        
        LDA $0C
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1002, X
        
        LDA $0C : ADD.w #$0080
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1008, X
        
        LDA $0C : ADD.w #$0002
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $100E, X
        
        LDA $0C : ADD.w #$0082
        
        JSR Dungeon_GetKeyedObjectRelativeVramAddr
        
        STA $1014, X
        
        LDA $02 : STA $1006, X
        LDA $04 : STA $100C, X
        LDA $06 : STA $1012, X
        LDA $08 : STA $1018, X
        
        LDA.w #$0100
        
        STA $1004, X : STA $100A, X
        STA $1010, X : STA $1016, X
        
        LDA.w #$FFFF : STA $101A, X
        
        TXA : ADD.w #$0018 : STA $1000
        
        SEP #$31
        
        ; just checking different rooms that shops can be in
        ; this is and the following ones are actually 0x0100 and 0x0118
        ; not rooms 0x0000 and 0x0018. it's implicit that Ganon doesn't have a shop in his room
        LDA $A0 : BEQ Dungeon_GetRupeeChestMinigamePrize_highStakes
        
        CMP.b #$18 : BEQ Dungeon_GetRupeeChestMinigamePrize_lowStakes
        
        ; must be the village of outcasts chest game room
        JSL GetRandomInt : AND.b #$07 : TAX
        
        CPX.b #$02 : BCC BRANCH_BETA
        
        ; make sure it's not the same thing we got last time?
        CPX $C8 : BNE BRANCH_BETA
        
        TXA : INC A : AND.b #$07 : TAX
    
    BRANCH_BETA:
    
        CPX.b #$07 : BNE BRANCH_GAMMA
        
        ; checking to see if you already got that heart piece
        LDA $0403 : AND.b #$40 : BNE BRANCH_DELTA
        
        ; set the flag indicating you've gotten that heart piece
        LDA $0403 : ORA.b #$40 : STA $0403
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        LDX.b #$00
    
    BRANCH_GAMMA:
    
        LDA.l Dungeon_MinigameChestPrizes, X
    
    ; *$EEC5 ALTERNATE ENTRY POINT
    prizeExternallyDetermined
    
        ; Set the index of the last item Link received
        STX $C8
        
        STA $0C : STZ $0D
        
        LDA.b #$01 : STA $14
        
        LDA.b #$0E : STA $012F
        
        PLB
        
        SEC
        
        RTL
    }

; ==============================================================================
 
    ; $EED7-$EEF6 DATA
    Dungeon_RupeeChestMinigamePrizes:
    {
        db $47, $34, $46, $34, $46, $46, $34, $47
        db $46, $47, $34, $46, $47, $34, $46, $47
        
        db $34, $47, $41, $47, $41, $41, $47, $34
        db $41, $34, $47, $41, $34, $47, $41, $34
    }

; ==============================================================================

    ; *$EEF7-$EF0E BRANCH LOCATION
    Dungeon_GetRupeeChestMinigamePrize:
    {
    
    .highStakes
    
        JSL GetRandomInt : AND.b #$0F
        
        BRA BRANCH_ALPHA
    
    ; *$EEFF ALTERNATE ENTRY POINT
    .lowStakes
    
        JSL GetRandomInt : AND.b #$0F : ADD.w #$10
    
    BRANCH_ALPHA:
    
        TAX
        
        LDA.l Dungeon_RupeeChestMinigamePrizes, X
        
        BRA Dungeon_OpenMiniGameChest.prizeExternallyDetermined
    }
    
; ==============================================================================

    ; *$EF0F-$EF33 LOCAL
    Dungeon_GetKeyedObjectRelativeVramAddr:
    {
        ; In-game tilemap address format for dungeons:
        ;    --pvyyyy yhxxxxx-
        ;
        ;   p - Plane. 0 for BG2, 1 for BG1
        ;   v - Selects whether to use an upper or lower tilemap
        ;   y - 5-bit vertical tile offset
        ;   h - Selects whether to use a left or right tilemap
        ;   x - 5-bit horizontal tile offset
        ;
        ;    00000h00 00000000
        ; || 000pv000 000xxxxx
        ; || 000000yy yyy00000
        ; -> 000pvhyy yyyxxxxx
        ; -> yyyxxxxx 000pvhyy
        
        ; Note: Whole routine takes 62 cycles. Could use some optimization?
        
        ADD $06E0, Y : STA $0E
        
                  AND.w #$0040 : LSR #4 : XBA     : STA $0A
        LDA $0E : AND.w #$303F : LSR A  : ORA $0A : STA $0A
        LDA $0E : AND.w #$0F80 : LSR #2 : ORA $0A : XBA
        
        RTS
    }
    
; ==============================================================================

    ; $EF34-$EF53 DATA
    {
        dw -1, -1, -1,  1
        dw -1, -1, -1,  1
        dw -1, -1, -1,  1
        dw -1, -1, -1,  1
    }

; ==============================================================================

    ; *$EF54-$EFEB LONG
    {
        LDA $0424 : AND.b #$07 : BNE BRANCH_ALPHA
        
        LDA $0424 : AND.b #$0C : LSR A : TAX
        
        REP #$20
        
        LDA $0684 : CMP $0688 : BEQ BRANCH_BETA
        
        ADD $01EF34, X : STA $0684
        
        LDA $0686 : ADD $01EF34, X : STA $0686
        
        SEP #$30
        
        INC $0424
        
        JSL Hdma_ConfigureWaterTable
        
        RTL
    
    BRANCH_ALPHA:
    
        SEP #$30
        
        INC $0424
        
        JSL Hdma_ConfigureWaterTable
        
        RTL
    
    BRANCH_BETA:
    
        SEP #$30
        
        LDA.b #$02 : STA $99
        LDA.b #$32 : STA $9A
        
        STZ $212D
        STZ $1D
        STZ $96
        STZ $046C
        
        REP #$30
        
        STZ $1E
        
        LDX $0442 : BEQ BRANCH_GAMMA
        
        LDY.w #$0000
    
    BRANCH_DELTA:
    
        LDX $06B8, Y
        
        LDA.w #$1D1D : STA $7F2041, X : STA $7F2081, X
        
        INY #2 : CPY $0442 : BNE BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDX $04AE : BEQ BRANCH_EPSILON
        
        LDY.w #$0000
    
    BRANCH_ZETA:
    
        LDX $06EC, Y
        
        LDA.w #$1D1D : STA $7F2041, X : STA $7F2081, X
        
        INY #2 : CPY $04AE : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        SEP #$30
        
        INC $15
        INC $B0
        
        RTL
    }

; ==============================================================================

    ; *$EFEC-$F045 LONG
    {
        REP #$30

        LDX.w #$0000
        LDY.w #$01E0

        LDA $9B52, Y

    BRANCH_ALPHA:

        STA $7E4000, X : STA $7E4200, X : STA $7E4400, X : STA $7E4600, X
        STA $7E4800, X : STA $7E4A00, X : STA $7E4C00, X : STA $7E4E00, X
        STA $7E5000, X : STA $7E5200, X : STA $7E5400, X : STA $7E5600, X
        STA $7E5800, X : STA $7E5A00, X : STA $7E5C00, X : STA $7E5E00, X

        INX #2 : CPX.w #$0200 : BNE BRANCH_ALPHA

        SEP #$30

        STZ $045C

        INC $B0

        RTL
    }

; ==============================================================================

    ; *$F046-$F062 JUMP LOCATION
    {
        JSL $0091C4 ; $11C4 IN ROM
        
        LDA $045C : ADD.b #$04 : STA $045C
        
        INC $B0 : LDA $B0 : CMP.b #$06 : BNE .notFinished
        
        STZ $045C : STZ $B0 : STZ $11
    
    .notFinished
    
        RTL
    }

; ==============================================================================

    ; $F063-$F07A DATA
    {
        dw  1,  1,  1, -1
        dw  1,  2,  1, -1
        dw  1, -1,  1, -1
    }

; ==============================================================================

    ; $F07B-$F092 JUMP TABLE
    pool Dungeon_TurnOnWaterLong:
    {
    
    .handlers
        dw $F046 ; = $F046*
        dw $F046 ; = $F046*
        dw $F046 ; = $F046*
        dw $F046 ; = $F046*
        
        dw $F09B ; = $F09B*
        dw $F09B ; = $F09B*
        dw $F09B ; = $F09B*
        dw $F09B ; = $F09B*
        
        dw $F09B ; = $F09B*
        dw $F16D ; = $F16D*
        dw $F18C ; = $F18C*
        dw $F1E1 ; = $F1E1*
    }

; ==============================================================================

    ; *$F093-$F09A LONG
    Dungeon_TurnOnWaterLong:
    {
        LDA $B0 : ASL A : TAX
        
        JMP (.handlers, X)
        
        RTL
    }

; ==============================================================================

    ; *$F09B-$F16C JUMP LOCATION
    {
        DEC $0424 : BNE BRANCH_$F09A ; (RTL)
        
        LDA.b #$04 : STA $0424
        
        INC $B0 : LDA $B0 : SUB.b #$04 : STA $0E : STZ $0F
        
        REP #$30
        
        LDA.w #$0008 : STA $0686
        
        STZ $068A
        
        LDA.w #$0030 : STA $0684
        
        LDA.w #$1654 : ADD.w #$0010 : TAY
    
    ; *$F0C9 ALTERNATE ENTRY POINT
    
        LDA $047C : ADD.w #$0100 : STA $08 : TAX
    
    BRANCH_ALPHA:
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2002, X
        LDA $9B56, Y : STA $7E2004, X
        LDA $9B58, Y : STA $7E2006, X
        
        TYA : ADD.w #$0008 : TAY
        TXA : ADD.w #$0080 : TAX
        
        DEC $0E : BNE BRANCH_ALPHA
        
        LDA.w #$0004 : STA $0A
        
        LDY.w #$0000
    
    BRANCH_BETA:
    
        LDX $08
        
        TXA : AND.w #$0040 : LSR #4 : XBA     : STA $00
        TXA : AND.w #$303F : LSR A  : ORA $00 : STA $00
        TXA : AND.w #$0F80 : LSR #2 : ORA $00 : XBA     : STA $1002, Y
        
        LDA.w #$0980 : STA $1004, Y
        
        LDA $7E2000, X : STA $1006, Y
        LDA $7E2080, X : STA $1008, Y
        LDA $7E2100, X : STA $100A, Y
        LDA $7E2180, X : STA $100C, Y
        LDA $7E2200, X : STA $100E, Y
        
        INC $08 : INC $08
        
        TYA : ADD.w #$000E : TAY
        
        DEC $0A : BNE BRANCH_BETA
        
        LDA.w #$FFFF : STA $1002, Y
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        RTL
    }

; ==============================================================================

    ; *$F16D-$F1E0 JUMP LOCATION
    {
        LDA.b #$03 : STA $96
        
        STZ $97 : STZ $98
        
        LDA.b #$16 : STA $1E
        
        LDA.b #$01 : STA $1F : STA $1D
        
        LDA.b #$02 : STA $99
        LDA.b #$62 : STA $9A
        
        STZ $0424
        
        INC $B0
    
    ; *$F18C ALTERNATE ENTRY POINT
    
        LDA $0424 : AND.b #$03 : ASL A : TAX
        
        REP #$20
        
        LDA.w #$0688 : SUB $E8 : SUB.w #$0024 : STA $00
        
        LDA $0686 : ADD.l $01F073, X : STA $0686
        LDA $068A : ADD.l $01F06B, X : STA $068A
        
        CMP $00 : BCC .alpha
        
        SEP #$20
        
        LDA.b #$07 : STA $0414 ; Make BG1 full addition
        
        INC $B0
    
    .alpha
    
        REP #$30
        
        INC $0424
        
        LDA.w #$0688 : SUB $E8 : SUB $0684 : STA $0674 : ADD $068A : STA $0A
        
        JSL $00F660 ; $7660 IN ROM
        
        RTL
    }

; ==============================================================================

    ; *$F1E1-$F2D9 JUMP LOCATION
    {
        LDA $0424 : AND.b #$07 : BNE BRANCH_ALPHA
        
        LDA $0424 : AND.b #$0C : LSR A : TAX
        
        REP #$20
        
        LDA $0684 : CMP $0688 : BEQ BRANCH_BETA
        
        ADD $01F063, X : STA $0684
        
        LDA $0686 : ADD $01F063, X : STA $0686
        
        REP #$10
        
        LDY.w #$16B4
        
        LDA $0688 : SUB $0684 : BEQ BRANCH_GAMMA
        
        CMP.w #$0008 : BNE BRANCH_DELTA
        
        LDY.w #$168C
    
    BRANCH_GAMMA:
    
        LDA.w #$0005 : STA $0E
        
        JSL $01F0C9 ; $F0C9 IN ROM
    
    BRANCH_DELTA:
    
        SEP #$30
    
    BRANCH_ALPHA:
    
        SEP #$30
        
        INC $0424
        
        JSL Hdma_ConfigureWaterTable
        
        RTL
    
    BRANCH_BETA:
    
        REP #$30
        
        STZ $1E
        
        LDX $0440 : BEQ BRANCH_EPSILON
        
        LDY.w #$0000
    
    BRANCH_ZETA:
    
        LDX $06B8, Y
        
        LDA.w #$0003 : STA $7F2000, X
        XBA          : STA $7F2002, X
        
        LDA.w #$0A03 : STA $7F3000, X
        XBA          : STA $7F3002, X
        
        LDA.w #$0808
        
        STA $7F2040, X : STA $7F2042, X
        STA $7F3040, X : STA $7F3042, X
        STA $7F3080, X : STA $7F3082, X
        STA $7F30C0, X : STA $7F30C2, X
        
        INY #2 : CPY $0440 : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        LDX $049E : BEQ BRANCH_THETA
        
        LDY.w #$0000
    
    BRANCH_IOTA:
    
        LDX $06EC, Y
        
        LDA.w #$0003 : STA $7F20C0, X
        XBA          : STA $7F20C2, X
        
        LDA.w #$0A03 : STA $7F30C0, X
        XBA          : STA $7F30C2, X
        
        LDA.w #$0808
        
        STA $7F2080, X : STA $7F2082, X
        STA $7F3000, X : STA $7F3002, X
        STA $7F3040, X : STA $7F3042, X
        STA $7F3080, X : STA $7F3082, X
        
        INY #2 : CPY $049E : BNE BRANCH_IOTA
    
    BRANCH_THETA:
    
        STZ $11
        STZ $B0
        
        RTL
    }
    
; ==============================================================================

    ; $F2DA-$F2F1
    {
        ; Unreferenced data
        
        dw 8, 16, 24, 32
        dw 0, -8, -8, -8
        
        dw $12F8, $13F8, $1398, $13E8
    }

; ==============================================================================

    ; $F2F2-$F2FD JUMP TABLE
    Watergate_MainJumpTable:
    {
        dw $F3A7 ; = $F3A7*
        dw $F3AA ; = $F3AA*
        dw $F3AA ; = $F3AA*
        dw $F3AA ; = $F3AA*
        dw $F30C ; = $F30C*
        dw $F3BD ; = $F3BD*
    }

; ==============================================================================

    ; *$F2FE-$F30B LONG
    Watergate_Main:
    {
        JSL $00F734 ; $7734 IN ROM
        
        LDA $B0 : ASL : TAX
        
        JMP (Watergate_MainJumpTable, X)
    
    .easyOut
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$F30C-$F3A6 JUMP LOCATION
    {
        INC $0470
        
        LDA $0470 : LSR A : STA $0686
        
        SUB.b #$08 : STA $00
        
        LDA $0678 : STA $0676
        
        LDA $067A : ADD.b #$01 : STA $067A
        
        ADD $00 : STA $0684
        
        LDA $0470 : AND.b #$0F : BNE _F309_easyOut ; (SEP #$30, RTL;)
        
        LDA $0470 : CMP.b #$40 : BNE BRANCH_ALPHA
        
        INC $B0
    
    BRANCH_ALPHA:
    
        REP #$30
        
        LDA $0470 : LSR #3 : TAX
        
        LDA $01F2E8, X
        
        TAY
        
        LDX $0472 : STX $08
        
        LDA.w #$000A : STA $0E
    
    BRANCH_BETA:
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE BRANCH_BETA

        STZ $0C

        LDA.w #$0003 : STA $0E
    
    BRANCH_GAMMA:
    
        LDA $08 : PHA
        
        LDA.w #$0004 : STA $0A
        
        LDY $0C
        
        LDA.w #$0881 : STA $06
        
        JSR $F77C ; $F77C IN ROM
        
        PLA : ADD.w #$0006 : STA $08
        
        DEC $0E : BNE BRANCH_GAMMA
        
        JMP $D1E3 ; $D1E3 IN ROM
    }

; ==============================================================================

    ; *$F3A7-$F3BC JUMP LOCATION
    {
        STZ $045C
    
    ; *$F3AA ALTERNATE ENTRY POINT
    
        STZ $0418
        
        JSL $0091C4 ; $11C4 IN ROM
        
        LDA $045C : ADD.b #$04 : STA $045C
        
        INC $B0
        
        RTL
    }

; ==============================================================================

    ; *$F3BD-$F3DA JUMP LOCATION
    {
        INC $0684
        
        LDA $0684 : ADD $0676 : CMP.b #$E1 : BCC .alpha
        
        STZ $045C
        STZ $11
        STZ $B0
        STZ $1E
        STZ $1F
        
        JSL ResetSpotlightTable
    
    .alpha
    
        RTL
    }

; ==============================================================================

    ; *$F3DB-$F3DE BRANCH LOCATION
    Dungeon_LightTorchFail:
    {
        STZ $0333
        
        RTL
    }

; ==============================================================================

    ; \unused
    ; $F3DF-$F3EB LONG
    {
        LDA $0333 : AND.b #$F0 : CMP.b #$C0 : BNE Dungeon_LightTorchFail
        
        LDA.b #$00
        
        BRA Dungeon_LightTorch_notGanonRoom
    }
    
; ==============================================================================

    ; *$F3EC-$F495 LONG
    Dungeon_LightTorch:
    {
        ; it's not a torch tile
        LDA $0333 : AND.b #$F0 : CMP.b #$C0 : BNE Dungeon_LightTorchFail
        
        ; normally set timer to 0xC0
        LDA.b #$C0
        
        LDY $A0 : BNE .notGanonRoom
        
        ; In Ganon's room the torches don't stay lit as long
        ; (I always thought so...)
        LDA.b #$80
    
    .notGanonRoom
    
        STA $08 : STZ $09
        
        PHA
        
        ; Set data bank to 0x00
        PHB : LDA.b #$00 : PHA : PLB
        
        REP #$30
        
        LDA $0333 : AND.w #$000F : ASL A : ADD $0478 : TAY
        
        LDA $0520, Y : AND.w #$00FF : TAX
        
        ; branch if torch is already lit
        LDA $0540, Y : ASL A : BCS .return
        
        ; Light the torch?
        LSR A : ORA.w #$8000 : STA $0540, Y
        
        LDA $08 : BNE .notZero
        
        ; why would this ever happen give the code base we have?
        ; seems like this would permanently light the torch?
        LDA $0540, Y : STA $7EFB40, X
    
    .notZero
    
        LDA $0540, Y : AND.w #$3FFF : TAX : STX $08 : PHX
        
        LDY.w #$0ECA
        
        JSR Dungeon_PrepOverlayDma
        
        LDY $0C : LDA.w #$FFFF : STA $1100, Y
        
        PLA
        
        SEP #$30
        
        AND.b #$7F : ASL A
        
        JSL Sound_GetFineSfxPan
        
        ORA.b #$2A : STA $012E
        
        PLB
        
        LDA.b #$01 : STA $18
        
        LDA $7EC005 : BEQ .dontDisableTorchBg
        
        LDA $045A : INC $045A : CMP.b #$03 : BCS .dontDisableTorchBg
        
        STZ $1D
        
        LDX $045A : LDA $02A1E5, X : STA $7EC017
        
        LDA.b #$0A : STA $11
        
        STZ $B0
    
    .dontDisableTorchBg
    
        LDA $0333 : AND.b #$0F : TAX
        
        ; Set the timer for the torch
        PLA : STA $04F0, X
        
        STZ $0333
        
        RTL
    
    .return
    
        SEP #$30
        
        PLB
        
        PLA
        
        RTL
    }

; ==============================================================================

    ; *$F496-$F527 LONG
    Dungeon_ExtinguishFirstTorch:
    {
    
        JSL Palette_AssertTranslucencySwap
        
        LDA.b #$C0 : STA $0333
        
        BRA .extinguish
    
    ; *$F4A1 ALTERNATE ENTRY POINT
    Dungeon_ExtinguishSecondTorch:
    
        LDA.b #$C1 : STA $0333
    
    .extinguish
    
    ; *$F4A6 ALTERNATE ENTRY POINT
    shared Dungeon_ExtinguishTorch:
    
        LDA.b #$C0 : STA $08 : STZ $09
        
        PHA
        
        ; Going to be using bank $00
        PHB : LDA.b #$00 : PHA : PLB
        
        REP #$30
        
        LDA $0333 : AND.w #$000F : ASL A : ADD $0478 : TAY
        
        LDA $0520, Y : AND.w #$00FF : TAX
        
        LDA $0540, Y : ASL #2 : STA $0540, Y : STA $7EFB40, X
        
        AND.w #$3FFF : TAX : STX $08
        
        LDY.w #$0EC2
        
        JSR Dungeon_PrepOverlayDma
        
        LDY $0C
        
        LDA.w #$FFFF : STA $1100, Y
        
        SEP #$30
        
        PLB
        
        LDA.b #$01 : STA $18
        
        LDA $7EC005 : BEQ .noLightLevelChange
        
        LDA $045A : BEQ .noLightLevelChange
        
        DEC A : STA $045A : CMP.b #$03 : BCS .noLightLevelChange
        
        CMP.b #$00 : BNE .notFullyDark
        
        LDA.b #$01 : STA $1D

    .notFullyDark

        LDX $045A
        
        LDA $02A1E5, X : STA $7EC017
        
        LDA.b #$0A : STA $11
        
        STZ $B0

    .noLightLevelChange

        LDA $0333 : AND.b #$0F : TAX
        
        PLA
        
        STZ $04F0, X
        STZ $0333
        
        RTL
    }

; ==============================================================================

    ; *$F528-$F584 LONG
    Dungeon_ElevateStaircasePriority:
    {
        REP #$30
        
        ; Limits us to 4... staircases?
        LDA $0462 : AND.w #$0003 : ASL A : TAY
        
        LDA $06B0, Y : ASL A : SUB.w #$0008 : TAX : STX $048C : STX $08 : PHX
        
        LDY.w #$0004
    
    .next_column
    
        ; What this is doing is setting the priority bits of all these tiles
        ; so that you can't see the player sprite past a certain point.
        LDA $7E2000, X : ORA.w #$2000 : STA $7E2000, X
        LDA $7E2080, X : ORA.w #$2000 : STA $7E2080, X
        LDA $7E2100, X : ORA.w #$2000 : STA $7E2100, X
        LDA $7E2180, X : ORA.w #$2000 : STA $7E2180, X
        
        INX #2
        
        DEY : BPL .next_column
        
        JSR Dungeon_PrepOverlayDma.tilemapAlreadyUpdated
        
        ; \task Investigate exactly what tiles are being reblitted to vram,
        ; because something about this just seems off.
        PLA : ADD.w #$0008 : STA $08
        
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        ; Finalizes oam buffer...
        JMP $D1E3 ; $D1E3 IN ROM
    }

; ==============================================================================

    ; *$F585-$F5D0 LONG
    Dungeon_DecreaseStaircasePriority:
    {
        REP #$30
        
        LDX $048C : STX $08 : PHX
        
        LDY.w #$0004
    
    .nextColumn
    
        LDA $7E2000, X : AND.w #$DFFF : STA $7E2000, X
        LDA $7E2080, X : AND.w #$DFFF : STA $7E2080, X
        LDA $7E2100, X : AND.w #$DFFF : STA $7E2100, X
        LDA $7E2180, X : AND.w #$DFFF : STA $7E2180, X
        
        INX #2
        
        DEY : BPL .nextColumn
        
        JSR Dungeon_PrepOverlayDma.tilemapAlreadyUpdated
        
        PLA : ADD.w #$0008 : STA $08
        
        JSR Dungeon_PrepOverlayDma.nextPrep
        JMP $D1E3 ; $D1E3 IN ROM
    }

; ==============================================================================

    ; $F5D1-$F5D8
    {
        dw $2556, $2596, $25D6, $2616
    }

; ==============================================================================

    ; $F5D9-$F5D9
    Object_OpenGanonDoor_easyOut:
    {
        RTL
    }

; ==============================================================================

    ; *$F5DA-$F6B3 LONG
    Object_OpenGanonDoor:
    {
        LDA.b #$01 : STA $02E4
        
        LDA $C8 : ORA $C9 : BEQ .doneCountingDown
        
        DEC $C8 : BNE Object_OpenGanonDoor_easyOut
        DEC $C9 : BNE Object_OpenGanonDoor_easyOut
        
        ; play Ganon's door opening sound effect
        LDA.b #$15 : STA $012D
        
        STZ $03EF
        STZ $50
    
    .doneCountingDown
    
        STZ $02E4
        
        INC $B0
        
        LDA $B0 : AND.b #$03 : BNE Object_OpenGanonDoor_easyOut
        
        REP #$30
        
        LDA $B0 : SUB.w #$0004 : LSR A : TAX
        
        LDA $01F5D1, X : TAY
        
        LDX.w #$0000
    
    ; open the door to the triforce room
    .nextColumn
    
        LDA $9B52, Y : STA $7E21D8, X
        LDA $9B54, Y : STA $7E2258, X
        LDA $9B56, Y : STA $7E22D8, X
        LDA $9B58, Y : STA $7E2358, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2 : CPX.w #$0010 : BNE .nextColumn
        
        LDA.w #$0008 : STA $0A
        LDA.w #$0881 : STA $06
        
        LDX.w #$01D8 : STX $08
        
        STZ $0C
        
        LDY $0C
        
        JSR $F77C ; $F77C IN ROM
        
        LDY $0C
        
        ; terminate the drawing buffer
        LDA.w #$FFFF : STA $1100, Y
        
        LDA $B0 : CMP.w #$0010 : BNE .notFinishedYet
        
        LDA.w #$0202 : STA $7F216C : STA $7F21AC
        LDA.w #$0200 : STA $7F2172 : STA $7F21B2
        
        LDX.w #$0000
        LDA.w #$0000
    
    ; Update the tile attributes for the door's region of tiles finally
    .nextColumn2
    
        STA $7F202D, X : STA $7F206D, X
        STA $7F20AD, X : STA $7F20ED, X
        STA $7F212D, X : STA $7F216D, X
        STA $7F21AD, X
        
        INX #2 : CPX.w #$0006 : BNE .nextColumn2
        
        LDA.w #$FFC0 : STA $0600
        
        SEP #$20
        
        STZ $11
        STZ $B0
    
    .notFinishedYet
    
        SEP #$30
        
        LDA.b #$01 : STA $18
        
        RTL
    }

; ==============================================================================

    ; \unused
    ; $F6B4-$F745 LOCAL
    {
        ; Sets up DMA transfers for some unknown purpose.
        
        LDA.w #$0004 : STA $0A
        
        LDY $0C
        
        LDA.w #$0080 : STA $06
        
        LDA $08 : AND.w #$003F : CMP.w #$003A : BCC BRANCH_ALPHA
        
        INC $06
    
    BRANCH_ALPHA
    
        LDX $08
        
        TXA : AND.w #$0040 : LSR #4 : XBA     : STA $00
        TXA : AND.w #$303F : LSR A            : STA $02
        TXA : AND.w #$0F80 : LSR #2 : ORA $00 : ORA $02 : STA $1100, Y
        
        LDX $045E
        
        LDA $1600, X : STA $1104, Y
        
        LDA $06 : STA $1102, Y
        
        LSR A : BCS BRANCH_BETA
        
        LDA $1602, X : STA $1106, Y
        LDA $1604, X : STA $1108, Y
        LDA $1606, X : STA $110A, Y
        
        LDA $08 : ADD.w #$0080 : STA $08
        
        TXA : ADD.w #$0008 : TAX
        
        BRA BRANCH_GAMMA

    BRANCH_BETA

        LDA $1608, X : STA $1106, Y
        LDA $1610, X : STA $1108, Y
        LDA $1618, X : STA $110A, Y
        
        INC $08 : INC $08
        
        INX #2

    BRANCH_GAMMA

        STX $045E
        
        TYA : ADD.w #$000C : TAY
        
        DEC $0A : BNE BRANCH_ALPHA
        
        RTS
    }

; ==============================================================================

    ; *$F746-$F7F0 LOCAL
    Dungeon_PrepOverlayDma:
    {
        ; Preps DMA transfers for updating tilemap during NMI
        ; I should mention that the method employed here is stunningly
        ; slow (inefficient) during NMI, taking on average 1 scanline per tile,
        ; which is INSANE.
        
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2002, X
        LDA $9B58, Y : STA $7E2082, X
    
    ; *$F762 ALTERNATE ENTRY POINT
    .tilemapAlreadyUpdated
    
        STZ $0C
    
    ; *$F764 ALTERNATE ENTRY POINT
    .nextPrep
    
        ; Going to blit 4 separate tiles...
        LDA.w #$0004 : STA $0A
        
        LDY $0C
        
        LDA.b #$0880 : STA $06
        
        ; If A < 0x3A
        LDA $08 : AND.w #$003F : CMP.w #$003A : BCC .useHorizontalDma
        
        ; As opposed to vertical dma (vram).
        INC $06
    
    ; *$F77C ALTERNATE ENTRY POINT
    .useHorizontalDma
    .nextTileGroup
    
        LDX $08
        
        TXA : AND.w #$0040 : LSR #4 : XBA     : STA $00
        TXA : AND.w #$303F : LSR A  : ORA $00 : STA $00
        TXA : AND.w #$0F80 : LSR #2 : ORA $00 : STA $1100, Y
        
        ; The data to write to VRAM
        LDA $7E2000, X : STA $1104, Y
        
        LDA $06 : STA $1102, Y
        
        LSR A : BCS .vertical
        
        LDA $7E2002, X : STA $1106, Y
        LDA $7E2004, X : STA $1108, Y
        LDA $7E2006, X : STA $110A, Y
        
        LDA $08 : ADD.w #$0080 : STA $08
        
        BRA .advanceVramBufferPosition
    
    .vertical
    
        LDA $7E2080, X : STA $1106, Y
        LDA $7E2100, X : STA $1108, Y
        LDA $7E2180, X : STA $110A, Y
        
        INC $08 : INC $08
    
    .advanceVramBufferPosition
    
        TYA : ADD.w #$000C : TAY
        
        DEC $0A : BNE .nextTileGroup
        
        STY $0C
        
        RTS
    }

; ==============================================================================

    ; \unused Pretty sure it is so far. Wonder what it was intended for...
    ; $F7F1-$F810 DATA
    {
        dw $0004, $0008, $000C, $0010, $0014, $0018, $001C, $0020
        dw $0100, $0200, $0300, $0400, $0500, $0600, $0700, $0800
    }

; ==============================================================================

    ; *$F811-$F907 LOCAL
    {
        ; Routine used with blast walls to prep vram updates for nmi.
        
        LDA.w #$0080 : STA $06
        
        STZ $0E
        
        LDA $0454 : ADD.w #$0003 : STA $0A
        
        SUB.w #$0006 : CMP.w #$0002 : BMI .alpha
        
        STA $02
        
        INC $0E
        
        LDA.w #$0003 : STA $0A
    
    .alpha
    
        LDY $0C
        
        LDX $0460
        
        LDA $19C0, X : AND.w #$0002 : BNE .beta
        
        INC $06
    
    .beta
    
        LDX $08
        
        TXA : AND.w #$0040 : LSR #4 : XBA     : STA $00
        TXA : AND.w #$303F : LSR A  : ORA $00 : STA $00
        TXA : AND.w #$0F80 : LSR #2 : ORA $00 : STA $1100, Y : PHA
        
        LDA $7E2000, X : STA $1104, Y
        
        LDA $06 : ORA.w #$0A00 : STA $1102, Y
        LDA $06 : ORA.w #$0E00 : STA $1110, Y
        
        PLA : ADD.w #$04A0 : STA $110E, Y
        
        LDA $7E2080, X : STA $1106, Y
        LDA $7E2100, X : STA $1108, Y
        LDA $7E2180, X : STA $110A, Y
        LDA $7E2200, X : STA $110C, Y
        LDA $7E2280, X : STA $1112, Y
        LDA $7E2300, X : STA $1114, Y
        LDA $7E2380, X : STA $1116, Y
        LDA $7E2400, X : STA $1118, Y
        LDA $7E2480, X : STA $111A, Y
        LDA $7E2500, X : STA $111C, Y
        LDA $7E2580, X : STA $111E, Y
        
        INC $08 : INC $08
        
        TYA : ADD.w #$0020 : TAY
        
        DEC $0A : BEQ .gamma
        
        JMP .beta
    
    .gamma
    
        LDA $0E : BEQ .delta
        
        DEC $0E
        
        LDX $02
        
        LDA $06 : LSR A : BCS .epsilon
        
        TXA : ADD.w #$0010 : TAX
    
    .epsilon
    
        LDA $01F7EF, X : ADD $08 : STA $08
        
        LDA.w #$0003 : STA $0A
        
        JMP .beta
    
    .delta
    
        STY $0C
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $F908-$F966 LOCAL
    {
        ; This routine appears to be unused and unreferenced in the rom so far...
        ; I actually only noticed it by seeing that there was a gap in addresses
        ; In any case, it's one of those routines that preps a DMA transfer for later
        ; when NMI hits. Usually these update the tilemaps.
        
        STA $0C
        
        STY $0E : STY $0A
        
        LDY.w #$0000
    
    BRANCH_ALPHA:
    
        TXA : AND.w #$0040 : LSR #4 : XBA : STA $00
        TXA : AND.w #$303F : LSR A  : STA $02
        TXA : AND.w #$0F80 : LSR #2 : ORA $00 : ORA $02 : XBA : STA $1002, Y
        
        LDA.w #$0100 : STA $1004, Y
        
        LDA $7E4000, X : STA $1006, Y
        
        INY #6
        
        INX #2
        
        DEC $0E : BNE BRANCH_ALPHA
        
        LDA $0A : STA $0E
        
        TXA : ADD.w #$0070 : TAX
        
        DEC $0C : BNE BRANCH_ALPHA
        
        LDA.W #$FFFF : STA $1002, Y
        
        SEP #$20
        
        LDA.b #$01 : STA $14
        
        REP #$20
        
        RTS
    }

; ==============================================================================

    ; *$F967-$F97F LOCAL
    Dungeon_DrawOverlay:
    {
    
    .nextObject
    
        REP #$30
        
        STZ $B2
        STZ $B4
        
        LDY $BA
        
        LDA [$B7], Y : CMP.w #$FFFF : BEQ .endOfObjects
        
        STA $00
        
        JSR $F980 ; $F980 IN ROM
        
        BRA .nextObject
    
    .endOfObjects
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$F980-$FA49 LOCAL
    {
        ; Dungeon overlay object "drawer".
        ; Note that it doesn't apply attribute modifications.
        
        SEP #$20
        
        LDA [$B7], Y : AND.b #$FC : STA $08
        
        INY #2
        
        LDA [$B7], Y : STA $04 : STZ $05
        
        LDA $01 : LSR #3 : ROR $08 : STA $09
        
        INY : STA $BA
        
        REP #$20
        
        LDA $04
        
        LDX $08
        
        CMP.w #$00A4 : BNE .notHole
        
        LDY.w #$05AA
        
        LDA $9B52, Y
        
        STA $7E2080, X : STA $7E2082, X : STA $7E2084, X : STA $7E2086, X
        STA $7E2100, X : STA $7E2102, X : STA $7E2104, X : STA $7E2106, X
        
        LDY.w #$063C
        
        LDA $9B54, Y
        
        STA $7E2000, X : STA $7E2002, X : STA $7E2004, X : STA $7E2006, X
        
        LDY.w #$0642
        
        LDA $9B54, Y
        
        STA $7E2180, X : STA $7E2182, X : STA $7E2184, X : STA $7E2186, X
        
        RTS
    
    .notHole
    
        ; Use the floor 2 pattern
        LDY $046A
        
        LDA $9B52, Y : STA $7E2000, X : STA $7E2004, X : STA $7E2100, X : STA $7E2104, X
        LDA $9B54, Y : STA $7E2002, X : STA $7E2006, X : STA $7E2102, X : STA $7E2106, X
        LDA $9B5A, Y : STA $7E2080, X : STA $7E2084, X : STA $7E2180, X : STA $7E2184, X
        LDA $9B5C, Y : STA $7E2082, X : STA $7E2086, X : STA $7E2182, X : STA $7E2186, X
        
        RTS
    }

; ==============================================================================

    ; *$FA4A-$FB0A LOCAL
    {
        LDA $0460 : AND.w #$00FF : STA $04
        
        BRA BRANCH_ALPHA
    
    ; *$FA54 ALTERNATE ENTRY POINT
    
        LDA $0460 : PHA
        
        AND.w #$000F : STA $04
        
        TXA : AND.w #$1FFF : CMP $998A : BCC BRANCH_BETA
        
        TXA : SUB.w #$0500 : STA $08
        
        PHX
        
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE : CMP.w #$0042 : BCC BRANCH_GAMMA
        
        LDA $08 : SUB.w #$0300 : STA $08
    
    BRANCH_GAMMA:
    
        LDA $0460 : EOR.w #$0010 : STA $0460
        
        JSR $FB61 ; $FB61 IN ROM
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDY $0460
        
        JSR Dungeon_LoadSingleDoorAttr
        
        PLX : STX $08
    
    BRANCH_BETA:
    
        PLA : STA $0460
    
    ; *$FAA0 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE
        
        LDX $0692    : BEQ BRANCH_DELTA
        CPX.w #$0004 : BEQ BRANCH_DELTA
        
        CMP.w #$0024 : BEQ BRANCH_EPSILON
        CMP.w #$0026 : BEQ BRANCH_EPSILON
        CMP.w #$0042 : BCC BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        INX #4
    
    BRANCH_ZETA:
    
        CMP.w #$0018 : BEQ BRANCH_THETA
        CMP.w #$0044 : BNE BRANCH_IOTA
    
    BRANCH_THETA:
    
        INX #2
    
    BRANCH_IOTA:
    
        LDY $CF24, X
        
        BRA BRANCH_KAPPA
    
    ; *$FAD7 ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        JSR $FD79 ; $FD79 IN ROM
        
        LDY $CD9E, X
    
    BRANCH_KAPPA:
    
        LDX $0460
        
        LDA $19A0, X : TAX
        
        LDA.w #$0004 : STA $0E
    
    BRANCH_LAMBDA:
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        
        TYA : ADD.w #$0006 : TAY
        
        INX #2
        
        DEC $0E : BNE BRANCH_LAMBDA
        
        RTS
    }

; ==============================================================================

    ; *$FB0B-$FBC1 JUMP LOCATION
    {
        LDA $0460 : AND.w #$00FF : STA $04
        
        BRA BRANCH_ALPHA
    
    ; *$FB15 ALTERNATE ENTRY POINT
    
        LDA $0460 : PHA
        
        AND.w #$000F : STA $04
        
        TXA : AND.w #$1FFF : CMP $99A8 : BCS BRANCH_BETA
        
        TXA : ADD.w #$0500 : STA $08
        
        PHX
        
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE : CMP.w #$0042 : BCC BRANCH_GAMMA
        
        LDA $08 : ADD.w #$0300 : STA $08
    
    BRANCH_GAMMA:
    
        LDA $0460 : EOR.w #$0010 : STA $0460
        
        JSR $FAA0 ; $FAA0 IN ROM
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDY $0460
        
        JSR Dungeon_LoadSingleDoorAttr
        
        PLX : STX $08
    
    BRANCH_BETA:
    
        PLA : STA $0460
    
    ; *$FB61 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE
        
        LDX $0692    : BEQ BRANCH_DELTA
        CPX.w #$0004 : BEQ BRANCH_DELTA
        
        CMP.w #$0042 : BCC BRANCH_EPSILON
        
        INX #4
    
    BRANCH_EPSILON:
    
        CMP.w #$0018 : BEQ BRANCH_ZETA
        CMP.w #$0044 : BNE BRANCH_THETA
    
    BRANCH_ZETA:
    
        INX #2
    
    BRANCH_THETA:
    
        LDY $CF2C, X
        
        BRA BRANCH_IOTA
    
    ; *$FB8E ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        JSR $FD79 ; $FD79 IN ROM
        
        LDY $CE06, X
    
    BRANCH_IOTA:
    
        LDX $0460
        
        LDA $19A0, X : TAX
        
        LDA.w #$0004 : STA $0E
    
    BRANCH_KAPPA:
    
        LDA $9B52, Y : STA $7E2080, X
        LDA $9B54, Y : STA $7E2100, X
        LDA $9B56, Y : STA $7E2180, X
        
        TYA : ADD.w #$0006 : TAY
        
        INX #2
        
        DEC $0E : BNE BRANCH_IOTA
        
        RTS
    }

; ==============================================================================

    ; *$FBC2-$FC7F JUMP LOCATION
    {
        LDA $0460 : AND.w #$00FF : STA $04
        
        BRA BRANCH_ALPHA
    
    ; *$FBCC ALTERNATE ENTRY POINT
    
        LDA $0460 : PHA
        
        AND.w #$000F : STA $04
        
        TXA : AND.w #$07FF : CMP $99BA : BCC BRANCH_BETA
        
        TXA : SUB.w #$0010 : STA $08
        
        PHX
        
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE : CMP.w #$0042 : BCC BRANCH_GAMMA
        
        LDA $08 : SUB.w #$000C : STA $08
    
    BRANCH_GAMMA:
    
        LDA $0460 : EOR.w #$0010 : STA $0460
        
        JSR $FCD6 ; $FCD6 IN ROM
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDY $0460
        
        JSR Dungeon_LoadSingleDoorAttr
        
        PLX : STX $08
    
    BRANCH_BETA:
    
        PLA : STA $0460
    
    ; *$FC18 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE
        
        LDX $0692    : BEQ BRANCH_DELTA
        CPX.w #$0004 : BEQ BRANCH_DELTA
        
        CMP.w #$0042 : BCC BRANCH_EPSILON
        
        INX #4
    
    BRANCH_EPSILON:
    
        CMP.w #$0018 : BEQ BRANCH_ZETA
        CMP.w #$0044 : BNE BRANCH_THETA
    
    BRANCH_ZETA:
    
        INX #2
    
    BRANCH_THETA:
    
        LDY $CF34, X
        
        BRA BRANCH_IOTA
    
    ; *$FC45 ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        JSR $FD79 ; $FD79 IN ROM
        
        LDY $CE66, X
    
    BRANCH_IOTA:
    
        LDX $0460
        
        LDA $19A0, X : TAX
        
        LDA.w #$0003 : STA $0E
    
    BRANCH_KAPPA:
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE BRANCH_KAPPA
        
        RTS
    }

; ==============================================================================

    ; *$FC80-$FD3D JUMP LOCATION
    {
        LDA $0460 : AND.w #$00FF : STA $04
        
        BRA BRANCH_ALPHA
    
    ; *$FC8A ALTERNATE ENTRY POINT
    
        LDA $0460 : PHA : AND.w #$000F : STA $04
        
        TXA : AND.w #$07FF : CMP $99D2 : BCS BRANCH_BETA
        
        TXA : ADD.w #$0010 : STA $08
        
        PHX
        
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE : CMP.w #$0042 : BCC BRANCH_GAMMA
        
        LDA $08 : ADD.w #$000C : STA $08
    
    BRANCH_GAMMA:
    
        LDA $0460 : EOR.w #$0010 : STA $0460
        
        JSR $FC18 ; $FC18 IN ROM
        JSR Dungeon_PrepOverlayDma.nextPrep
        
        LDY $0460
        
        JSR Dungeon_LoadSingleDoorAttr
        
        PLX : STX $08
    
    BRANCH_BETA:
    
        PLA : STA $0460
    
    ; *$FCD6 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDX $0460
        
        LDA $1980, X : AND.w #$00FE
        
        LDX $0692    : BEQ BRANCH_DELTA
        CPX.w #$0004 : BEQ BRANCH_DELTA
        
        CMP.w #$0042 : BCC BRANCH_EPSILON
        
        INX #4
    
    BRANCH_EPSILON:
    
        CMP.w #$0018 : BEQ .isTrapDoor
        CMP.w #$0044 : BNE .notTrapDoor
    
    .isTrapDoor
    
        INX #2
    
    .notTrapDoor
    
        LDY $CF3C, X
        
        BRA .drawDoor
    
    ; *$FD03 ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        JSR $FD79 ; $FD79 IN ROM
        
        LDY $CEC6, X
    
    .drawDoor
    
        LDX $0460
        
        LDA $19A0, X : TAX
        
        LDA.w #$0003 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2002, X
        LDA $9B54, Y : STA $7E2082, X
        LDA $9B56, Y : STA $7E2102, X
        LDA $9B58, Y : STA $7E2182, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$FD3E-$FD78 JUMP LOCATION
    {
        ; Seems to draw a very specific door type. I can only guess what...
        ; Maybe a door revealed by sword swipes like in Agahnim's first room?
        
        LDX.w #$0056
        
        LDY $CD9E, X
        
        LDX $0460
        
        LDA $19A0, X : TAX
        
        LDA.w #$0004 : STA $0E
    
    .nextColumn
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        
        TYA : ADD.w #$0008 : TAY
        
        INX #2
        
        DEC $0E : BNE .nextColumn
        
        RTS
    }

; ==============================================================================

    ; *$FD79-$FD91 LOCAL
    {
        ; Used in opening doors and closing doors.... not exactly sure what
        ; the point is though. Maybe it selects the offset of the tiles
        ; needed to draw the door's graphical state?
        
        LDY $0460
        
        LDA $1980, Y : AND.w #$00FE : TAX
        
        LDY $04
        
        LDA $068C : AND $98C0, Y : BEQ .notOpen
        
        LDA $9A02, X : TAX
    
    .notOpen
    
        RTS
    }

; ==============================================================================

    ; *$FD92-$FE40 JUMP LOCATION
    {
        ; This routine is used with the exploding walls
        ; (not bomb doors! It's easy to get confused about 
        ; terminology)
        
        LDY.w #$31EA
        
        JSR $FDDB ; $FDDB IN ROM
        
        LDA $0454 : DEC A : STA $0E : BEQ .skip
        
        LDA $9B52, Y
    
    .nextColumn
    
        STA $7E2000, X : STA $7E2080, X : STA $7E2100, X : STA $7E2180, X
        STA $7E2200, X : STA $7E2280, X : STA $7E2300, X : STA $7E2380, X
        STA $7E2400, X : STA $7E2480, X : STA $7E2500, X : STA $7E2580, X
        
        INX #2
        
        DEC $0E : BNE .nextColumn
    
    .skip
    
        INY #2
    
    ; *$FDDB ALTERNATE ENTRY POINT
    
        LDA.w #$0002 : STA $0E
    
    .nextColumn2
    
        LDA $9B52, Y : STA $7E2000, X
        LDA $9B54, Y : STA $7E2080, X
        LDA $9B56, Y : STA $7E2100, X
        LDA $9B58, Y : STA $7E2180, X
        LDA $9B5A, Y : STA $7E2200, X
        LDA $9B5C, Y : STA $7E2280, X
        LDA $9B5E, Y : STA $7E2300, X
        LDA $9B60, Y : STA $7E2380, X
        LDA $9B62, Y : STA $7E2400, X
        LDA $9B64, Y : STA $7E2480, X
        LDA $9B66, Y : STA $7E2500, X
        LDA $9B68, Y : STA $7E2580, X
        
        INX #2
        
        TYA : ADD.w #$0018 : TAY
        
        DEC $0E : BNE .nextColumn2
        
        RTS
    }

; ==============================================================================

    ; *$FE41-$FEAB LOCAL
    Dungeon_ApplyOverlayAttr:
    {
        ; This routine takes performs the modifications to the tile attribute
        ; buffer resulting from dungeon overlay objects being placed.
        ; The objects placed can only be either 4x4 blocks of generic floor
        ; tiles or 4x4 blocks of pit tiles, so as you can see it's fairly easy
        ; to deduce what tile attributes to use (0x00 or 0x20)
        STA $08
        
        LDA.w #$0004 : STA $0A
    
    .nextRow
    
        LDX $08
        
        LDA $7E2000, X : STA $00
        LDA $7E2002, X : STA $02
        LDA $7E2004, X : STA $04
        LDA $7E2006, X : STA $06
        
        LDX.w #$0006
    
    .nextTile
    
        LDA $00, X : STZ $00, X : AND.w #$03FE : CMP.w #$00EE : BEQ .notPitTile
        
        CMP.w #$00FE : BEQ .notPitTile
        
        ; pit attribute
        LDA.w #$0020 : STA $00, X
    
    .notPitTile
    
        DEX #2 : BPL .nextTile
        
        LDA $08 : LSR A : TAX
        
        SEP #$20
        
        LDA $00 : STA $7F2000, X
        LDA $02 : STA $7F2001, X
        LDA $04 : STA $7F2002, X
        LDA $06 : STA $7F2003, X
        
        REP #$20
        
        LDA $08 : ADD.w #$0080 : STA $08
        
        DEC $0A : BNE .nextRow
        
        RTS
    }
    
; ==============================================================================

    ; $FEAC-$FEAF NULL
    {
        db $FF, $FF, $FF, $FF
    }

; ==============================================================================

    ; *$FEB0-$FED1 LONG
    Dungeon_ApproachFixedColor:
    {
        LDA $9C : AND.b #$1F : CMP $7EC017 : BEQ .targetReached
        
        ; This coding scheme allows $9C to approach $7EC017 from above or below
        DEC A : BCS .aboveTarget
        
        ; (belowTarget)
        INC A : INC A
    
    .aboveTarget
    
        STA $00
    
    ; *$FEC1 ALTERNATE ENTRY POINT
    .variable
    
        ; Sets fixed color for +/-
        ORA.b #$20 : STA $9C
        AND.b #$1F : ORA.b #$40 : STA $9D
        AND.b #$1F : ORA.b #$80 : STA $9E
    
    .targetReached
    
        RTL
    }

; ==============================================================================

    ; *$FED2-$FF04 LONG
    Player_SetElectrocutionMosaicLevel:
    {
        ; This routine's primary purpose is for the Link's electrocution 
        ; mode ($5D == 0x07)
        
        LDA $0647 : BNE .mosaic_decreasing
        
        ; add to mosaic? seems related to electrocution (it almost certainly is)
        LDA $7EC011 : ADD.b #$10 : CMP.b #$C0 : BNE .mosaic_not_at_target
        
        INC $0647
        
        BRA .set_mosaic_level
    
    .mosaic_decreasing
    
        LDA $7EC011 : SUB.b #$10 : BNE .set_mosaic_level
    
    ; *$FEF0 ALTERNATE ENTRY POINT
    shared Player_SetCustomMosaicLevel:
    
        ; Reset mosaic decreasing flag.
        STZ $0647
    
    .mosaic_not_at_target
    .set_mosaic_level
    
        ; Set mosaic level
        STA $7EC011
        
        LDA.b #$09 : STA $94
        
        LDA $7EC011 : LSR A : ORA.b #$03 : STA $95
        
        RTL
    }

; ==============================================================================

    ; *$FF05-$FF27 LONG
    Player_LedgeJumpInducedLayerChange:
    {
        ; Executes when Link hits the ground after jumping off of a ledge.
        ; Make it so Link is on a lower plane.
        LDA.b #$01 : STA $0476
        
        LDA $044A : BNE .no_room_change
        
        ; \unused or \tcrf or \bug I have no idea. It's odd.
        ; I think it's pretty certain this is an unused feature since it would change
        ; the current room we're in without any of the other legwork necessary.
        LDA $A0 : ADD.b #$10 : STA $A0
    
    .no_room_change
    
        LDA $044A : CMP.b #$02 : BEQ .use_pseudo_bg
        
        ; \bug I think this is where that bug (glitch) that allows you to
        ; get under the floor by pressing select originates from. Not that this
        ; in particular is a bug. It has more to do with the player's
        ; layer probably isn't reset properly when you save and quit, and
        ; then reload the state. (Initializing problem).
        ; \task Investigate and find the actual bug location.
        LDA.b #$01 : STA $EE
    
    .use_pseudo_bg
    
        STZ $047A
        
        JML $02B8CB ; $138CB IN ROM
    }

; ==============================================================================

    ; *$FF28-$FFB5 LONG
    Player_CacheStatePriorToHandler:
    {
        ; We may be able to remove this routine...
        ; \optimize Changing the B register would speed it up a lot >_>
        
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
        
        RTL
    }

; ==============================================================================

    ; *$FFB6-$FFD8 LONG
    Link_CheckSwimCapability:
    {
        LDA $02E0 : BNE .bunnyGraphics
        
        LDA $7EF356 : BNE .hasFlippers
    
    .bunnyGraphics
    
        LDA $7EF357 : BEQ .doesntHaveMoonPearl
        
        STZ $02E0
    
    .doesntHaveMoonPearl
    
        LDA.b #$0C : STA $4B
        
        LDA.b #$2A
        
        LDX $1B : BEQ .outdoors
        
        LDA.b #$14
    
    .outdoors
    
        STA $11
    
    .hasFlippers
    
        RTL
    }

; ==============================================================================

    ; *$FFD9-$FFFC LONG
    Overworld_PitDamage:
    {
        ; Take a heart off of Link and put him in the submodule
        ; that brings him back to where he fell off from.
        ; (Damage from pits on Overworld and only in one area, at that)
        ; Maybe could be used in Dungeons too, but it's not, so... eh.
        
        LDA.b #$0C : STA $4B
        
        LDA.b #$2A
        
        LDX $1B : BEQ .outdoors
        
        LDA.b #$14
    
    .outdoors
    
        STA $11
        
        LDA $7EF36D : SUB.w #$08 : STA $7EF36D : CMP.b #$A8 : BCC .notDead
        
        LDA.b #$00 : STA $7EF36D
    
    .notDead
    
        RTL
    }

; ==============================================================================

    ; $FFFD-$FFFF NULL
    {
        db $FF, $FF, $FF
    }

; ==============================================================================
    
warnpc $028000
