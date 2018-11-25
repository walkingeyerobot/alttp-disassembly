
; ==================================================

    ; $DD218-$DD307 DATA
    ; Main Sprite Palettes (divided by world, naturally)
    {
        ; $DD218 - light world sprite palettes
        dw $7FFF, $08D9, $1E07, $4ACA, $14A5, $133F, $19DF, $0000, $7FFF, $1979, $14B6, $39DC, $14A5, $66F7, $45EF
        dw $7FFF, $6949, $62EC, $6FF4, $14A5, $7F51, $7E4F, $0000, $7FFF, $5A1F, $55AA, $76B2, $14A5, $2ADF, $1597
        dw $7FFF, $1AF6, $1596, $369E, $14A5, $41FE, $2517, $0000, $14A5, $14A5, $14A5, $14A5, $14A5, $14A5, $14A5
        dw $7FFF, $319B, $1596, $369E, $14A5, $7E56, $65CA, $0000, $7FFF, $0CD9, $1A49, $3B53, $14A5, $1F5F, $1237
        
        ; $DD290 - dark world sprite palettes
        dw $7FFF, $08D9, $1A2F, $32F5, $14A5, $133F, $19DF, $0000, $7FFF, $1979, $14B6, $39DC, $14A5, $66F7, $45EF
        dw $7FFF, $2DC4, $66CF, $7FD5, $14A5, $5F50, $468A, $0000, $7FFF, $5A1F, $55AA, $76B2, $14A5, $2ADF, $1597
        dw $7FFF, $0EFB, $1596, $369E, $14A5, $41FE, $2517, $0000, $14A5, $14A5, $14A5, $14A5, $14A5, $14A5, $14A5
        dw $7FFF, $319B, $1596, $369E, $14A5, $7E56, $65CA, $0000, $7FFF, $0CD9, $1A49, $3B53, $14A5, $1F5F, $1237
    }
    
    ; $DD308-$DD39D DATA
    ; Armor Palettes
    {
        dw $7FFF, $237E, $11B7, $369E, $14A5, $01FF, $1078, $599D, $3647, $3B68, $0A4A, $12EF, $2A5C, $1571, $7A18
        dw $7FFF, $237E, $11B7, $369E, $14A5, $01FF, $1078, $599D, $6980, $7691, $26B8, $437F, $2A5C, $1199, $7A18
        dw $7FFF, $237E, $11B7, $369E, $14A5, $01FF, $1078, $599D, $1057, $457E, $6DF3, $7EB9, $2A5C, $2227, $7A18
        dw $7FFF, $237E, $11DA, $369E, $14A5, $01FF, $1078, $3D97, $3647, $3B68, $0A4A, $12EF, $567E, $1872, $7A18
        dw $0000, $0EFA, $7DD1, $0000, $7F1A, $0000, $7F1A, $716E, $7DD1, $40A7, $7DD1, $40A7, $48E9, $50CF, $7FFF
    }
    
    ; $DD39E-$DD445 DATA
    ; Spr Aux 3 palettes
    {
        dw $10C6, $1214, $3B3D, $66DE, $5219, $42ED, $2629
        dw $7FFF, $0D66, $2D58, $463D, $14A5, $3290, $1DEB
        dw $25F1, $0D09, $512A, $7251, $14A5, $21CF, $194B
        dw $3676, $04EA, $12A0, $2F80, $14A5, $21D1, $114D
        dw $7FFF, $4FF3, $1175, $369E, $14A5, $0DFF, $00F9
        dw $7FFF, $273A, $1175, $369E, $14A5, $132F, $0669
        dw $7FFF, $314A, $4A2F, $570F, $14A5, $57AF, $30EA
        dw $7FFF, $191B, $16AC, $3BD5, $14A5, $267E, $0D98
        dw $7FFF, $1D2C, $4DAD, $4DAD, $14A5, $2A14, $1D91
        dw $7FFF, $2185, $2D58, $463D, $14A5, $428D, $3209
        dw $7FFF, $5294, $44C7, $61AE, $14A5, $1A3B, $1175
        dw $377F, $54E9, $165F, $1016, $2C43, $6B18, $61EF
    }
    
    ; $DD446-$DD4DF DATA
    {
        dw $14C4, $2D6B, $612E, $5DB4, $7AD9, $77BD, $5294
        dw $14C4, $2D6B, $4DE8, $66AE, $7F74, $77BD, $5294
        dw $14C4, $2D6B, $011F, $01FF, $03DF, $77BD, $5294
        dw $7FFF, $0000, $0000, $0000, $7810, $7F7F, $7C17
        dw $7FFF, $0000, $5907, $6E0E, $0000, $7FBB, $7672
        dw $7FFF, $5F9F, $000A, $7E15, $2C24, $75D0, $612B
        dw $14A5, $3A0A, $1DE5, $2669, $3234, $5FB6, $4AEF
        dw $14A5, $14A5, $158D, $2211, $3234, $4AEF, $3A0A
        dw $08C4, $21C9, $4DB1, $72D3, $12B7, $4F34, $366E
        dw $0C63, $08C4, $196E, $29F2, $29F2, $366E, $21C9
        dw $18C6, $2D6B, $29F5, $1ABA, $252F, $77BD, $5294
    }
    
    ; $DD4E0-$DD62F
    {
        dw $7FFF, $7B14, $5C92, $791A, $14A5, $02BF, $11BD
        dw $7FFF, $32DB, $00B6, $263E, $14A5, $5694, $39AD
        dw $7FFF, $0551, $5D8D, $7272, $14A5, $0EFD, $0DF6
        dw $7FFF, $237E, $1175, $369E, $14A5, $1B71, $1E60
        dw $7FFF, $209A, $0DB4, $2AFB, $14A5, $036F, $026B
        dw $7FFF, $0975, $34D2, $51B9, $14A5, $2EDF, $11FC
        dw $77BD, $08FC, $09D4, $12DC, $14A5, $4ED8, $29D1
        dw $7FFF, $1966, $0D9C, $02BB, $14A5, $4B0A, $2E28
        dw $7FFF, $0CEA, $0EF9, $0F5F, $14A5, $0E75, $0DB0
        dw $7FFF, $5A3C, $626E, $7F34, $0000, $7F3F, $6E9E
        dw $7FFF, $08D9, $1175, $369E, $14A5, $231A, $0E33
        dw $7FFF, $0914, $1665, $5F6E, $14A5, $267F, $15B9
        dw $7FFF, $5929, $117B, $22BF, $14A5, $7EB5, $75CF
        dw $7FFF, $4547, $0591, $1698, $14A5, $5331, $562A
        dw $7FFF, $4118, $1636, $3B1D, $14A5, $1F52, $120D
        dw $7FFF, $369B, $228B, $3F72, $14A5, $35BC, $2115
        dw $7FFF, $1414, $0F40, $231F, $14A5, $123D, $14FA
        dw $7FFF, $5E5F, $0972, $2638, $14A5, $7636, $512F
        dw $7E35, $187B, $1175, $369E, $14A5, $7FFF, $7E35
        dw $7FFF, $5A94, $08D7, $219D, $14A5, $1698, $0591
        dw $7FFF, $0CD2, $017B, $16BF, $14A5, $361D, $1D16
        dw $4E73, $34E4, $0532, $0DF8, $0000, $04D7, $45C6
        dw $7FFF, $366E, $15F4, $231C, $14A5, $4F34, $5FB8
        dw $294A, $77BD, $6318, $4631, $77BD, $4631, $6318
    }
    
    ; $DD630-$DD647
    ; Sword Palettes
    {
        dw $7FFF, $27FF, $5E2D ; no sword and fighter sword
        dw $7E4E, $6FF4, $1CF5 ; fighter sword
        dw $093B, $169F, $7E8D ; tempered sword
        dw $033F, $67FF, $2640 ; golden sword
    }
    
    ; $DD648-$DD65F
    ; Shield Palettes
    {
        dw $7FFF, $1CE7, $7A10, $64A5
        dw $4F5F, $1CE7, $2E9C, $14B6
        dw $7399, $1CE7, $02F9, $0233
    }
    
    ; $DD660-$DD6DF
    ; HUD Palettes
    {
        dw $0000, $0198, $56B5, $0000
        dw $0000, $0018, $7FFF, $0000
        dw $0000, $02BC, $7FFF, $0000
        dw $0000, $69C9, $7FFF, $0000
        dw $0000, $18C6, $39AD, $0000
        dw $0000, $00B8, $433D, $0000
        dw $0000, $3800, $7FFF, $0018
        dw $0000, $1704, $7FFF, $0000
        
        dw $0000, $216F, $2E59, $14C8
        dw $0000, $0018, $7FFF, $0000
        dw $0000, $0000, $2FE5, $0000
        dw $0000, $0000, $1F1F, $0000
        dw $0000, $3ED8, $2E54, $27BD
        dw $0000, $3ED8, $2E54, $1DD0
        dw $0000, $3800, $1D5E, $0000
        dw $0000, $0000, $7FFF, $0000
    }
    
    ; $DD6E0-$DD709 DATA
    ; (unused palettes? (each one being 7 colors long -> 3bpp graphics) )
    {
        dw $033F, $67FF, $2640, $7599, $7599, $7599, $7599
        
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
    }
    
    ; $DD70A-$DD733 DATA
    ; Palace Map Sprite Palettes
    {
        dw $7FFF, $0019, $7FFF, $7FFF, $14A5, $0000, $0000
        dw $7FFF, $17FF, $7F52, $216E, $14A5, $0000, $0000
        dw $7DD3, $7F8E, $66AD, $2CF7, $14A5, $7ED8, $0000
    }
    
    ; $DD734-$DE543 DATA
    ; DungeonMain BG palettes (6 in each group)
    {
        dw $0CC6, $152B, $19D0, $3675, $535D, $1CEE, $1089, $7FFF, $0CC6, $152B, $19D0, $3675, $535D, $1CEE, $1089
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $0C84, $3168, $3DCB, $460D, $28E7, $19D0, $1CEE
        dw $0CC6, $152B, $1A33, $3B19, $14AC, $4DC7, $4546, $7FFF, $0C84, $2925, $3166, $39A8, $7D6B, $152B, $1089
        dw $10C6, $216E, $21F3, $3ADC, $18CD, $66DE, $59D9, $7FFF, $0CA5, $2D29, $2D71, $35B3, $28E7, $19D0, $1CEE
        dw $1463, $2110, $35B8, $739C, $4108, $16DB, $61AD, $7FFF, $0CA5, $2D29, $210E, $2950, $28E7, $314A, $7D6B
        dw $0CC6, $152B, $19D0, $3675, $535D, $152B, $7D6B, $7FFF, $0CA5, $150A, $0000, $0000, $18CD, $3675, $19D0
        
        dw $1463, $2CC7, $3D2A, $49AE, $6274, $1CEC, $1089, $7FFF, $1463, $2CC7, $3D2A, $49AE, $6274, $1D2D, $10CA
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $1463, $2D26, $3989, $3DCB, $2D26, $3D2A, $1D2D
        dw $1463, $2CC7, $3D2A, $49AE, $6274, $1CEC, $1089, $7FFF, $1463, $24E4, $2905, $3147, $24E4, $2CC7, $10CA
        dw $18C6, $1D0B, $2590, $21F4, $14C8, $1CEC, $1089, $7FFF, $0C86, $10C8, $190A, $214C, $3635, $4B1C, $6FBF
        dw $18C6, $2110, $35B8, $739C, $4108, $16DB, $61AD, $7FFF, $1463, $24E4, $2D26, $3989, $3989, $4E73, $5EF7
        dw $1463, $6507, $6949, $7F51, $44E7, $5D69, $7E4F, $7FFF, $1063, $28C7, $24E4, $15A5, $15A5, $49AE, $3D2A
        
        dw $14A7, $214F, $21B3, $3215, $3EBA, $56F8, $250F, $7FFF, $14A7, $214F, $21B3, $3215, $3EBA, $56F8, $1CEC
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $14A7, $3168, $3DCB, $460D, $3168, $2193, $1CEC
        dw $14A7, $214F, $21B3, $3258, $64C8, $7DAF, $7FFF, $7FFF, $0CA5, $192D, $216F, $29B1, $192D, $214F, $18CA
        dw $14E9, $21B1, $3657, $3A9A, $03AB, $56D9, $4A77, $7FFF, $0CA5, $192D, $216F, $29B1, $192D, $2193, $1CEC
        dw $18C6, $2110, $35B8, $739C, $3D08, $1ABA, $5DCE, $7FFF, $0CA5, $2504, $3166, $39A8, $7FFF, $214F, $18CA
        dw $14A7, $0673, $21AD, $21EF, $7FFF, $7FFF, $7FFF, $7FFF, $0CA5, $0885, $14E8, $2984, $2984, $14A7, $14A7
        
        dw $14A5, $1946, $25C8, $3AB0, $5359, $418C, $3529, $7FFF, $14A5, $1946, $25C8, $3AB0, $5359, $3D28, $28E7
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $0C63, $3128, $394A, $418C, $2CE6, $29C8, $3D28
        dw $14A5, $1946, $25C8, $3AB0, $5359, $2A9C, $2955, $7FFF, $0C63, $2CC6, $2CE7, $3529, $28C5, $1D24, $28E7
        dw $1505, $2168, $2DCB, $3E4F, $4B5D, $3699, $25F5, $7FFF, $14A5, $2108, $294A, $318C, $4E73, $6B5A, $7FFF
        dw $18C6, $2110, $35B8, $739C, $3D08, $1ABA, $5DCE, $7FFF, $1084, $1CA7, $24C9, $2D0B, $394A, $5294, $739C
        dw $14A5, $4568, $59ED, $6650, $2985, $3A48, $532B, $7FFF, $14A5, $1525, $0000, $1CED, $1CED, $3AB0, $25C8
        
        dw $24A4, $5925, $6A4B, $7795, $7FFB, $5DCE, $558C, $7FFF, $24A4, $5925, $6A4B, $7795, $7FFB, $5DEE, $4D6A
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $24A4, $4D6A, $55AC, $5DEE, $4D25, $5DEE, $51A8
        dw $24A4, $5925, $6A4B, $77BB, $117B, $75CF, $7EB5, $7FFF, $24A4, $4D6A, $55AC, $5DEE, $3D47, $5DEE, $51A8
        dw $24A4, $78A9, $7DD0, $76CB, $7FFA, $64A9, $55AC, $7FFF, $34C8, $4D6A, $55AC, $5DEE, $6AB3, $7B58, $7FFF
        dw $1463, $2910, $3DB8, $739C, $614A, $1ABA, $7E31, $7FFF, $24A4, $5D8B, $4D28, $4106, $5B09, $5294, $739C
        dw $24A4, $4988, $5EE4, $7367, $44E7, $5D69, $7E4F, $7FFF, $2084, $5505, $0000, $0000, $5D8B, $7795, $7FF9
        
        dw $0CA5, $10EA, $194D, $29F3, $3EB6, $2DCB, $2589, $7FFF, $0CA5, $10EA, $194D, $29F3, $3EB6, $2168, $1906
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $0C63, $2168, $29AA, $29AD, $2190, $194D, $2168
        dw $0CA5, $10EA, $194D, $29F3, $3EB6, $2ACC, $15E5, $7FFF, $0C63, $1926, $2167, $216B, $1905, $10EA, $1906
        dw $0CA5, $10EA, $194D, $29F3, $3EB6, $29AD, $29AA, $7FFF, $10E7, $154A, $1DAD, $2A10, $42F7, $5FBD, $7FFF
        dw $18C6, $2110, $35B8, $739C, $4108, $1ABA, $61AD, $7FFF, $0C63, $15AE, $1DF0, $15AE, $29AA, $5294, $739C
        dw $24C6, $4526, $6167, $65C9, $4547, $59C8, $6A8C, $7FFF, $0CA5, $10EA, $0000, $1DEC, $1DEC, $29F3, $194D
        
        dw $1084, $18CA, $252E, $39D3, $529A, $418C, $3529, $7FFF, $1084, $18CA, $252E, $39F3, $52BA, $2D29, $24E7
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $0C63, $3529, $394A, $418C, $3108, $252E, $2D29
        dw $1084, $18CA, $252E, $39D3, $52BA, $1E5A, $1CF5, $7FFF, $0C63, $28C6, $2CE7, $3129, $28C6, $18CA, $24E7
        dw $1084, $18CA, $252E, $39D3, $52BA, $3D6B, $3529, $7FFF, $1CE4, $2545, $2D86, $35C7, $5A2F, $7738, $7FFF
        dw $1084, $2110, $35B8, $739C, $4108, $16DB, $5D8C, $7FFF, $1084, $14C9, $14CC, $190D, $3529, $5294, $739C
        dw $28A5, $3128, $396A, $41AC, $40E7, $5D69, $720E, $7FFF, $0C64, $14A9, $0000, $1CEB, $1CEB, $39F3, $212F
        
        dw $1085, $10C8, $18EB, $1D91, $2E35, $254F, $210C, $7FFF, $1085, $10C9, $192D, $1D91, $2E35, $4209, $3187
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $1085, $14C9, $18EB, $212E, $10C8, $216E, $190B
        dw $18C6, $1984, $2646, $3B69, $19FF, $18D5, $10A9, $7FFF, $1085, $1088, $10A9, $14CB, $1086, $192C, $10C8
        dw $1085, $216E, $21F3, $42B7, $65AA, $190B, $18EB, $7FFF, $1085, $14C9, $18EB, $212E, $2DB2, $4298, $67BF
        dw $1084, $2110, $35B8, $739C, $4126, $16DB, $61CB, $7FFF, $0C63, $110D, $1D91, $2E35, $212D, $5294, $739C
        dw $1463, $58E6, $6149, $658B, $44E7, $5D69, $7A2E, $7FFF, $1085, $10C9, $0000, $0000, $35A5, $1085, $1085
        
        dw $0C63, $2108, $35AD, $4A52, $6739, $31CC, $298A, $7FFF, $0C63, $2108, $35AD, $4A52, $6739, $2569, $1D27
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $1084, $2148, $298A, $31AC, $2148, $35AD, $2569
        dw $0C63, $2108, $35AD, $4A52, $6739, $1AD7, $19AE, $0000, $1084, $1906, $1D27, $2569, $1906, $2108, $1D27
        dw $0C63, $2D6B, $5294, $739C, $2E26, $4F8A, $3AA6, $7FFF, $10C7, $1109, $1D8D, $29F0, $42F8, $5F9D, $7FFF
        dw $18C6, $2110, $35B8, $739C, $4108, $1ABA, $61AD, $7FFF, $1084, $10E9, $152B, $1D6D, $298A, $5294, $739C
        dw $1084, $2148, $31CC, $3677, $44E7, $5D69, $7E4F, $7FFF, $0C63, $1CE7, $0000, $0000, $1DCC, $4A52, $35AD
        
        dw $1084, $18E6, $194C, $29F2, $46D8, $298C, $114A, $7FFF, $1084, $18E6, $194C, $29F2, $46D8, $14AA, $1086
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $1463, $1148, $114A, $298C, $1945, $258A, $14AA
        dw $1084, $18E6, $194C, $29F2, $46D8, $298C, $14AA, $7FFF, $1463, $1087, $14A8, $1508, $7FFF, $1D07, $1086
        dw $1084, $18E6, $194C, $29F2, $46D8, $298C, $14AA, $7FFF, $20C6, $3108, $416B, $51CE, $6252, $7F39, $7FFF
        dw $1463, $2110, $35B8, $739C, $4108, $16DB, $61AD, $7FFF, $1084, $3924, $4986, $5A0B, $114A, $4631, $5AD6
        dw $1463, $7F51, $6949, $6507, $44E7, $5D69, $7E4F, $7FFF, $1463, $2CC7, $2108, $7FFF, $18CD, $29F2, $216D
        
        dw $1084, $2508, $314A, $45EF, $66F7, $3188, $1986, $7FFF, $1084, $2508, $314A, $45EF, $66F7, $1D87, $1926
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $1084, $1525, $1986, $3188, $198D, $314A, $1D87
        dw $1084, $2508, $314A, $45EF, $66F7, $3188, $1986, $7FFF, $1084, $10A7, $14C8, $18E9, $10A6, $2508, $1926
        dw $1084, $190A, $214C, $298E, $6B18, $3188, $1986, $7FFF, $10E9, $192A, $216C, $29AE, $3634, $571A, $6FBF
        dw $18C6, $2110, $35B8, $739C, $4108, $16DB, $61AD, $7FFF, $1084, $1525, $1986, $3188, $1986, $5294, $739C
        dw $1463, $6507, $6949, $7F51, $44E7, $5D69, $7E4F, $7FFF, $0C63, $14A5, $18C6, $198D, $198D, $45EF, $294A
        
        dw $0C63, $1945, $1DE6, $3AD0, $5777, $426A, $3608, $7FFF, $0C63, $1945, $1DE6, $3AD0, $5777, $1DAF, $114B
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $0C63, $29A7, $3608, $426A, $2565, $19E6, $1DAF
        dw $0C63, $1945, $1DE6, $3AD0, $29A7, $3608, $426A, $7FFF, $0C63, $2545, $2985, $2DC7, $2545, $1545, $114B
        dw $14A5, $1966, $2EEB, $4B0A, $7FFF, $25B1, $1CED, $7FFF, $14E9, $152B, $1D6D, $29D0, $3633, $46B7, $6FBF
        dw $1463, $2110, $35B8, $739C, $4108, $16DB, $61AD, $7FFF, $0C63, $10A7, $14EA, $1D2B, $2DC7, $5294, $739C
        dw $18C6, $7000, $7C84, $7CA5, $3543, $41A3, $5243, $7FFF, $0C42, $1525, $0000, $0000, $1DD0, $3AD0, $256D
        
        dw $1085, $10C9, $192D, $1D91, $2E35, $254F, $210C, $7FFF, $1085, $10C9, $192D, $1D91, $2E35, $4209, $3187
        dw $18C6, $2D6B, $5294, $77BD, $252F, $1ABA, $29F5, $7FFF, $1085, $14C9, $18EB, $212E, $10C8, $216E, $190B
        dw $7FFF, $3673, $3718, $37BD, $14A5, $3529, $35CE, $7FFF, $1085, $1088, $10A9, $14CB, $1086, $192C, $10C8
        dw $1463, $1508, $196B, $3252, $5318, $190C, $18EB, $7FFF, $1085, $14C9, $18EB, $212E, $2DB2, $4298, $67BF
        dw $1084, $2110, $35B8, $739C, $3528, $16DB, $59AC, $7FFF, $0C63, $110D, $1D91, $2E35, $212D, $5294, $739C
        dw $14A5, $0C72, $109C, $11FF, $4D27, $61EC, $7E4E, $7FFF, $1085, $10C9, $0000, $19CE, $35A5, $1085, $1085
        
        dw $0C63, $24CB, $296F, $3634, $4AF9, $39AD, $316B, $7FFF, $0C63, $24CB, $296F, $3634, $4AF9, $3187, $2525
        dw $18C6, $2D6B, $5294, $739C, $252F, $1ABA, $29F5, $7FFF, $0C63, $2D4A, $316B, $39AD, $14AA, $296F, $3187
        dw $0C63, $24CB, $296F, $3634, $4AF9, $16A6, $15C5, $0000, $0C63, $20E7, $2508, $2929, $20C6, $24CB, $2525
        dw $0C63, $24CB, $296F, $3634, $4AF9, $25F1, $1DAF, $7FFF, $1088, $14AA, $18CD, $2533, $463A, $6B5D, $7FFF
        dw $18C6, $2110, $35B8, $739C, $3D28, $1ABA, $5DCE, $7FFF, $1088, $14AA, $18CD, $2533, $18CD, $2533, $0000
        dw $14A5, $3505, $51C6, $5A69, $4AF9, $24CB, $0000, $7FFF, $0C63, $24CA, $0000, $0000, $34E7, $3634, $3E75
        
        dw $0C63, $14C9, $218D, $3E73, $5739, $114E, $11CE, $7FFF, $0C63, $14C9, $218D, $3E73, $5739, $114E, $11CE
        dw $14C4, $2D6B, $5294, $77BD, $2532, $16DB, $25F9, $7FFF, $0C63, $14E9, $190C, $1D2D, $14E9, $112B, $10C9
        dw $0C63, $18CA, $11D0, $1683, $16BF, $7D4D, $0C7B, $7FFF, $0C63, $10C6, $14E8, $1909, $10C6, $112B, $10C9
        dw $0C63, $1CAA, $1130, $2A13, $108D, $7FFF, $24EC, $7FFF, $0C63, $108D, $2953, $4218, $631F, $112B, $10C9
        dw $1084, $1CF5, $35BB, $739C, $3529, $16DB, $59AD, $7FFF, $0C63, $10C6, $14E8, $1909, $190C, $5294, $739C
        dw $0C63, $1110, $19F7, $26FD, $7D29, $18DB, $1683, $7FFF, $0C63, $14C9, $0000, $108D, $108D, $1104, $1104
        
        dw $1084, $24EA, $252F, $39D3, $4E7A, $3ED6, $156B, $7FFF, $1084, $24EA, $252F, $39D3, $4E7A, $3ED6, $156B
        dw $14C4, $2D6B, $5294, $77BD, $2532, $16DB, $25F9, $7FFF, $1084, $210C, $252E, $2950, $1986, $2D92, $156B
        dw $1084, $24EA, $252F, $39D3, $7F9C, $7D8C, $64A5, $7FFF, $2084, $3908, $3D4A, $458C, $1986, $2D92, $156B
        dw $1084, $1D2C, $21F0, $3274, $1CFB, $7F9C, $4D29, $7FFF, $1084, $6DA0, $7F60, $3274, $7FFF, $3DFF, $1CFB
        dw $1084, $1275, $4929, $739C, $1505, $3DFF, $1CFB, $7FFF, $1084, $28C9, $310B, $354C, $1986, $2D92, $156B
        dw $1084, $2D91, $290B, $229B, $11A8, $1CFB, $0853, $7FFF, $1084, $3589, $0120, $1DA7, $1986, $0CC3, $0CC3
        
        dw $0CA5, $10E9, $1D6E, $2E54, $433B, $46B1, $320C, $7FFF, $0CA5, $10EB, $1D6E, $2E54, $3F39, $1D47, $14C5
        dw $14C4, $2D6B, $5294, $77BD, $2532, $16DB, $25F9, $7FFF, $1084, $2D08, $354A, $398C, $7FFF, $1D6E, $1D47
        dw $0CA5, $10E9, $1D6E, $2E54, $433B, $1E59, $1555, $7FFF, $0C63, $1D2C, $1D91, $21D2, $24E5, $110B, $14C5
        dw $0CA5, $1926, $29CA, $4290, $5B5A, $2E54, $1D6E, $7FFF, $10E7, $10EB, $1D6E, $2E54, $42F7, $5FBD, $7FFF
        dw $1084, $1CF5, $35BB, $739C, $3529, $16DB, $59AD, $7FFF, $0C63, $24A5, $28C6, $28C6, $2D08, $5294, $739C
        dw $1084, $210D, $3191, $4E78, $77DF, $1D6E, $2E54, $7FFF, $0C84, $10CA, $0000, $0000, $1CF1, $2E54, $2E11
        
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $0000, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE, $77DE
        dw $14A5, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $14A5, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        dw $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        
        dw $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $14A5, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        dw $14A5, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        dw $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $14A5, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        dw $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        dw $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
        dw $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F, $0000, $0000, $380E, $6018, $7C1F, $7DBF, $7E7F, $7F3F
    }

    ; $DE544-$DE603 DATA
    ; Palace Map BG palettes
    {
        dw $0000, $71E7, $71E7, $71E7, $71E7, $71E7, $7EB5, $1CE7, $0000, $7FFF, $02BD, $4E2D, $66F3, $7F99, $4E2D, $7F99
        dw $0000, $34E0, $34E0, $34E0, $34E0, $34E0, $7EB5, $1CE7, $0000, $7FFF, $4D67, $01FE, $02BD, $3F7E, $66F3, $7F99
        dw $0000, $71E7, $3B5F, $71E7, $71E7, $71E7, $7EB5, $1CE7, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $71E7, $71E7, $2DFF, $3B5F, $71E7, $7EB5, $1CE7, $0000, $7FFF, $4D67, $4E2D, $66F3, $7F99, $02BD, $3F7E
        dw $0000, $0069, $04AB, $0D0E, $1552, $1DB4, $2614, $2A55, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $38C0, $4102, $4944, $5186, $59C8, $620A, $6A4C, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    }
    
    ; $DE604-$DE6C7 DATA
    ; Overworld Auxiliary 3 palettes
    {
        dw $190A, $3549, $45EC, $6E50, $258D, $3A32, $5F3A
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $1084, $000E, $1059, $291F, $1CE8, $0842, $2109
        dw $0C63, $40A5, $5D67, $7EAE, $7F18, $19CF, $7B5C
        dw $08C4, $0044, $1540, $3226, $10CA, $1980, $1D90
        dw $14A5, $3D26, $5587, $7ACE, $14E9, $620B, $1D8F
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000
    }
    
    ; $DE6C8-$DE86B DATA
    ; main overworld area palettes (theme, sort of)
    {
        dw $14A5, $14E9, $152C, $1D8F, $19C6, $2669, $25F1
        dw $14A5, $14E9, $152C, $1D8F, $158D, $2211, $25F1
        dw $14A5, $14E9, $152C, $1D8F, $152C, $25F1, $25F1
        dw $14A5, $3A0A, $4AEF, $5FB6, $1565, $2669, $1B46
        dw $14A5, $194C, $25D1, $3234, $1DE5, $2669, $2628
        
        dw $0C63, $0C87, $10CA, $112D, $198C, $2A32, $1D90
        dw $0C63, $0CA7, $10CA, $112D, $196E, $29F2, $1D90
        dw $0C63, $0CA7, $10CA, $112D, $112D, $1D90, $1D90
        dw $08C4, $21C9, $366E, $4F34, $198C, $2A32, $3274
        dw $08C4, $4DB1, $72D3, $12B7, $198C, $2A32, $1DCF
        
        dw $0C63, $0C87, $10CA, $112D, $158D, $19CF, $1D90
        dw $0C63, $0C87, $10CA, $112D, $6FB6, $2150, $7FFF
        dw $0C63, $0C87, $10CA, $112D, $112D, $1D90, $1D90
        dw $14E6, $3A0A, $4AEF, $5FD6, $158D, $19CF, $7DBF
        dw $14A5, $114C, $1DD1, $2E35, $158D, $19CF, $1D90
        
        dw $0884, $0CC7, $150A, $154D, $150A, $1D4C, $21AF
        dw $0884, $0CC7, $1509, $196C, $41F5, $0842, $569A
        dw $0884, $0CC7, $1509, $196C, $1509, $21AF, $21AF
        dw $1084, $21C9, $366E, $4F34, $150A, $1D4C, $258E
        dw $1084, $4DB1, $72D3, $12B7, $10E9, $1D4C, $150A
        
        dw $0084, $00A5, $00E7, $00E8, $014B, $010D, $0118
        dw $00A0, $0100, $0942, $0D83, $11A4, $258C, $1908
        dw $24E6, $1462, $1CA4, $2907, $1CCD, $250F, $20EE
        dw $398B, $3149, $2906, $24E6, $14A4, $258C, $1908
        dw $1084, $1908, $258C, $4273, $52F7, $188B, $1532
        
        dw $5D8C, $558A, $76B3, $7AF4, $0D23, $11C4, $2287
        dw $4908, $558A, $76B3, $7AF4, $2CA3, $3584, $3E09
        dw $6A0F, $6E50, $6E71, $76B3, $558A, $69EE, $7B17
        dw $190A, $3549, $45EC, $6E50, $258D, $3A32, $5F3A
        dw $1084, $1908, $258C, $4273, $52F7, $188B, $1532
    }
    
    ; $DE86C-$DEBB3
    ; overworld auxiliary palettes (pool of palettes for aux 1 and aux 2)
    {
        dw $14C5, $216E, $29F3, $3677, $1CED, $2952, $46D7
        dw $14C5, $3A0A, $4AEF, $5FB6, $6BDA, $19C6, $2669
        dw $14A5, $194C, $21D1, $3255, $21A5, $21E8, $1965
        
        dw $14A5, $3570, $5237, $6B1C, $2273, $498B, $6250
        dw $14A5, $194C, $21D1, $1965, $2952, $19C6, $1CEE
        dw $14A5, $29D1, $4ED8, $77BD, $1947, $320D, $19C6
        
        dw $14A5, $1D91, $1E19, $26BD, $6B5F, $2D77, $4A1B
        dw $14A5, $7FFF, $3DA4, $4631, $1CF1, $7FFF, $7FFF
        dw $14C7, $2DCF, $3E74, $635C, $19C6, $2669, $7BFF
        
        dw $7F13, $7F55, $7FD9, $7FFD, $31C8, $0000, $7ED0
        dw $044E, $0009, $0CFC, $63DF, $4E73, $323F, $0C75
        dw $7FFF, $3DEF, $14A5, $14A5, $0000, $6318, $4E73
        
        dw $18C6, $1D8F, $620B, $6B98, $1DE7, $2669, $25F1
        dw $18C6, $5187, $1E36, $3F9E, $1DE7, $2669, $620B
        dw $14A5, $14E9, $152C, $1D8F, $19C6, $2669, $25F1
        
        dw $0884, $052A, $21EF, $3AB5, $4B39, $1D4C, $18AC
        dw $0884, $052A, $21EF, $3AB5, $4B39, $1D4C, $18AC
        dw $0884, $1508, $196C, $21AF, $41F5, $1D4C, $569A
        
        dw $38C2, $5903, $75A7, $7EEB, $7FB2, $19CF, $0C63
        dw $0C63, $152B, $2A12, $3AD8, $146A, $1D90, $14E9
        dw $0C63, $1D2C, $2150, $2676, $6FB6, $19CF, $7FFF
        
        dw $0C63, $0C87, $10CA, $112D, $158D, $19CF, $1D90
        dw $0C63, $0C87, $10CA, $112D, $6FB6, $7FFF, $1D90
        dw $0C63, $3186, $39C6, $2DD1, $7F18, $326A, $7B5C
        
        dw $14A5, $3A0A, $4AEF, $5794, $19C6, $3A33, $46B6
        dw $14A5, $1D6D, $2DF1, $7FFF, $21A5, $49F7, $3594
        dw $14A5, $216E, $29F3, $3677, $3125, $45A8, $46D7
        
        dw $14A5, $25AB, $3271, $4717, $1926, $14E9, $25F1
        dw $14A5, $194C, $21D1, $2211, $1A53, $2253, $15AE
        dw $14A5, $25AB, $3271, $4717, $5F5A, $19AE, $2211
        
        dw $2800, $3840, $44A1, $5104, $658C, $6A0C, $2669
        dw $1CE7, $320B, $46F3, $5399, $6BFE, $41A8, $2669
        dw $1505, $114C, $2669, $19A4, $2605, $3265, $36C8
        
        dw $00E8, $3336, $298E, $4654, $2AB1, $15EB, $3AF5
        dw $0884, $04EA, $114D, $21D1, $1216, $1EDA, $0150
        dw $0884, $0D2B, $19F1, $3EB7, $5BBD, $196E, $29F2
        
        dw $0000, $0821, $1063, $18A5, $2CE7, $3529, $496B
        dw $0CA7, $294E, $4614, $5EFA, $1DAD, $7FFF, $3AF5
        dw $0884, $218C, $2E52, $3AF5, $1DCC, $2E50, $1129
        
        dw $2504, $2D68, $41EC, $4E6C, $5AD0, $1980, $6F75
        dw $0884, $1980, $0D6A, $1A2F, $3319, $09F5, $2EBC
        dw $0884, $1540, $10C0, $1DF0, $196E, $29F2, $1980
        
        dw $0C63, $112D, $1980, $2A02, $198C, $2A32, $1D90
        dw $0C63, $1540, $7FFF, $7FFF, $198C, $2A32, $1980
        dw $0C63, $0C87, $10CA, $112D, $198C, $2A32, $1D90
        
        dw $14E8, $1DB0, $2E75, $3F1A, $7FFF, $4718, $4F5A
        dw $0884, $04EA, $114D, $21D1, $31D7, $467B, $2553
        dw $10C6, $25B2, $3257, $3ADB, $2D94, $3A18, $4EBC
        
        dw $0C63, $25B2, $3257, $36FB, $2948, $396C, $4A10
        dw $14E6, $21C9, $366E, $4F34, $5FB8, $198C, $2A32
        dw $0884, $04EA, $114D, $21D1, $19AC, $262F, $1D67
        
        dw $148E, $1914, $21D9, $32FF, $0C01, $0C01, $180A
        dw $0884, $04EA, $114D, $21D1, $498E, $5A13, $3D2A
        dw $0884, $0D6E, $19F3, $2656, $2E97, $110C, $00CA
        
        dw $0884, $0509, $116B, $2A31, $3AB5, $1D4C, $01D0
        dw $0884, $0CC7, $150A, $154D, $5BFF, $569A, $21AF
        dw $0842, $0842, $0C63, $0849, $1CE8, $0C63, $2109
        
        dw $1084, $0407, $106A, $04CE, $1552, $1925, $0CE8
        dw $0884, $1CCB, $1DCE, $3694, $4718, $1D4C, $18AC
        dw $0884, $1508, $196C, $21AF, $41F5, $1D4C, $569A
    }
    
    ; $DEBB4-$DEBC0 DATA
    {
        db $00, $00, $06, $0C, $12, $18, $1E, $24
        db $2A, $30, $36, $3C, $42
    }
    
    ; $DEBC1-$DEBC5 DATA
    {
        db $00, $00, $08, $10, $18
    }
    
    ; $DEBC6-$DEBD5 DATA
    {
        db $00, $0E, $1C, $2A, $38, $46, $54, $62
        db $70, $7E, $8C, $9A, $A8, $B6, $C4, $D2
    }
    
    ; $DEBD6-$DEC05 DATA
    {
        dw $0000, $000E, $001C, $002A, $0038, $0046, $0054, $0062
        dw $0070, $007E, $008C, $009A, $00A8, $00B6, $00C4, $00D2
        dw $00E0, $00EE, $00FC, $010A, $0118, $0126, $0134, $0142
    }
    
    ; $DEC06-$DEC0A DATA
    {
        db $00, $0F, $1E, $2D, $3C
    }
    
    ; \unused maybe
    ; $DEC0B - $DEC12 DATA
    {
        db $00, $1C, $38, $54, $70, $8C, $A8, $C4
    }
    
    ; $DEC13-$DEC3A DATA
    {
        dw $0000, $002A, $0054, $007E, $00A8, $00D2, $00FC, $0126
        dw $0150, $017A, $01A4, $01CE, $01F8, $0222, $024C, $0276
        dw $02A0, $02CA, $02F4, $031E
    }
    
    ; $DEC3B-$DEC46 DATA
    {
        dw $0000, $0046, $008C, $00D2, $0118, $015E
    }
    
    ; $DEC47-$DEC4A DATA
    {
        db $00, $40, $00, $30
    }
    
    ; $DEC4B-$DEC72 DATA
    {
        dw $0000, $00B4, $0168, $021C, $02D0, $0384, $0438, $04EC
        dw $05A0, $0654, $0708, $07BC, $0870, $0924, $09D8, $0A8C
        dw $0B40, $0BF4, $0CA8, $0D5C
    }
    
    ; $DEC73-$DEC76 DATA
    {
        dw $0000, $0078
    }

; ==================================================

    ; *$DEC77-$DEC9D LONG
    Palette_SpriteAux3:
    {
        REP #$21
        
        ; Palette 1
        LDX $0AAC
        
        LDA $1BEBC6, X : AND.w #$00FF : ADC.w #$D39E : STA $00
        
        REP #$10
        
        ; Target SP-0 (first half)
        LDA.w #$0102
        
        ; Depending on this flag, use different palette areas.
        LDX $0ABD : BEQ .useSP0
        
        ; Target SP-7 (first half) instead
        LDA.w #$01E2
    
    .useSP0
    
        ; Write a palette consisting of 7 colors to cgram buffer
        LDX.w #$0006
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DEC9E-$DECC4 LONG
    Palette_MainSpr:
    {
        ; Loads palettes for the commonly used sprites like faeries, blue / red creatures,
        ; hearts, rupees, etc
        REP #$21
        
        ; X = 0x00 for light world
        LDX.b #$00
        
        LDA $8A : AND.w #$0040 : BEQ .lightWorld
        
        ; X = 0x02 for dark world
        INX #2
    
    .lightWorld
    
        LDA $1BEC73, X : ADC.w #$D218 : STA $00
        
        REP #$10
        
        ; Target SP-1 through SP-4 (full), Each palette has 15 colors, Load 4 palettes    
        LDA.w #$0122
        LDX.w #$000E
        LDY.w #$0003
        
        JSR Palette_MultiLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DECC5-$DECE3 LONG
    Palette_SpriteAux1:
    {
        REP #$31
        
        ; Load sprite palette 2 value
        LDA $0AAD : AND.w #$00FF : ASL A : TAX
        
        ; ($DEBD6, X)
        LDA $1BEBD6, X : ADC.w #$D4E0 : STA $00
        
        LDA.w #$01A2 ; Target SP-5 (first half)
        LDX.w #$0006 ; Palette has 7 colors
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DECE4-$DED02 LONG
    Palette_SpriteAux2:
    {
        REP #$31
        
        ; Load sprite palette 3 value
        LDA $0AAE : AND.w #$00FF : ASL A : TAX
        
        ; $DEBD6, X IN ROM
        LDA $1BEBD6, X : ADC.w #$D4E0 : STA $00
        
        LDA $01C2    ; Target SP-6 (first half)
        LDX.w #$0006 ; Palette has 7 colors
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DED03-$DED28 LONG
    Palette_Sword:
    {
        ; Load sword palette
        
        REP #$21
        
        ; Figure out what kind of sword Link has.
        LDA $7EF359 : AND.w #$00FF : TAX
        
        ; $DEBB4, X THAT IS
        LDA $1BEBB4, X : AND.w #$00FF : ADC.w #$D630 : STA $00
        
        REP #$10
        
        LDA.w #$01B2    ; Target SP-5 (second half)
        LDX.w #$0002    ; palette has 3 colors
        
        JSR Palette_ArbitraryLoad
        
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==================================================

    ; *$DED29-$DED4E LONG
    Palette_Shield:
    {
        ; Load shield palette
        
        REP #$21
        
        ; Figure out what kind of shield Link has.
        LDA $7EF35A : AND.w #$00FF : TAX
        
        LDA $1BEBC1, X : AND.w #$00FF : ADC.w #$D648 : STA $00
        
        REP #$10
        
        ; Target SP-5 (second half), load 4 colors
        LDA.w #$01B8
        LDX.w #$0003
        
        JSR Palette_ArbitraryLoad
        
        SEP #$30
        
        ; Set the palette update flag
        INC $15
        
        RTL
    }

; ==================================================

    ; $DED4F-$DED6D
    Palette_Unused:
    {
        ; This routine isn't referenced anywhere in the game... that i can tell...
        
        REP #$21
        
        LDX $0AB0
        
        LDA $1BEBC6, X : AND.w #$00FF : ADC.w #$D446 : STA $00
        
        REP #$10
        
        ; Target SP-6 (first half)
        LDA.w #$01C2
        LDX.w #$0006
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DED6E-$DEDDC LONG
    Palette_MiscSpr:
    {
        ; If we're outdoors do something else...
        LDA $1B : BEQ .outdoors
    
    ; *$DED72 ALTERNATE ENTRY POINT 
    .justSP6
    
        REP #$21
        
        LDX $0AB1
        
        LDA $1BEBC6, X : AND.w #$00FF
        
        ADC.w #$D446 : STA $00
        
        REP #$10
        
        LDA.w #$01D2  ; Target SP-6 (second half)
        LDX.w #$0006  ; Palette has 7 colors
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    
    .outdoors
    
        ; This section loads the palette for thrown objects like bushes and rocks.
        REP #$21
        
        LDX.w #$07
        
        ; See if we're in the dark world.
        LDA $8A : AND.w #$0040 : BEQ .lightWorld
        
        INX #2
    
    .lightWorld
    
        PHX
        
        ; X = 0x07 or 0x09
        LDA $1BEBC6, X : AND.w #$00FF : ADC.w #$D446 : STA $00
        
        REP #$10
        
        ; Target SP-0 (second half)
        LDA.w #$0112
        
        ; not sure but it's definitely palette related.
        LDX $0ABD : BEQ .useSP0
        
        LDA.w #$01F2    ; Target SP-7 (second half) instead
    
    .useSP0
    
        LDX.w #$0006    ; 7 color palette
        
        JSR Palette_SingleLoad
        
        SEP #$10
        
        PLX : DEX
        
        LDA $1BEBC6, X : AND.w #$00FF : ADD.w #$D446 : STA $00
        
        REP #$10
        
        LDA.w #$01D2    ; Target SP-6 (second half)
        LDX.w #$0006    ; 7 color palette
        
        JSR Palette_SingleLoad
        
        REP #$30
        
        RTL
    }

; ==================================================

    ; *$DEDDD-$DEDF4 LONG
    Palette_PalaceMapSpr:
    {
        ; Load palettes for Palace Map sprite graphics.
    
        REP #$21
        
        ; Load palettes from $1BD70A
        LDA.w #$D70A : STA $00
        
        REP #$10
        
        ; Starting target palette is SP4, 7 colors each, load 3 palettes
        LDA.w #$0182
        LDX.w #$0006
        LDY.w #$0002
        
        JSR Palette_MultiLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; $DEDF5-$DEDF8 DATA - glove colors (other than skin colored)
    dw $52F6, $0376
    
    ; *$DEDF9-$DEE39 LONG
    ; Palette_ChangeGloveColor:
    Palette_ArmorAndGloves:
    {
        ; Load armor palette
        
        REP #$21
        
        ; Check what Link's armor value is.
        LDA $7EF35B : AND.w #$00FF : TAX
        
        ; (DEC06, X)
        LDA $1BEC06, X : AND.w #$00FF : ASL A : ADC.w #$D308 : STA $00
        
        REP #$10
        
        LDA.w #$01E2 ; Target SP-7 (sprite palette 6)
        LDX.w #$000E ; Palette has 15 colors
        
        JSR Palette_ArbitraryLoad
        
    ; *$DEE1B ALTERNATE ENTRY POINT
    .justGloves

        REP #$30
        
        ; Check what type of Gloves Link has.
        ; If Link has no special gloves I guess you use a default?
        LDA $7EF354 : AND.w #$00FF : BEQ .defaultGloveColor
        
        DEC A : ASL A : TAX
        
        ; $DEDF5, X THAT IS
        LDA $1BEDF5, X : STA $7EC4FA : STA $7EC6FA
    
    .defaultGloveColor
    
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==================================================

    ; *$DEE3A-$DEE51 LONG
    Palette_PalaceMapBg:
    {
        ; Much like the name implies, loads the palettes for
        ; the Palace Map BG graphics.
        
        REP #$21
        
        ; Sets source address to $1BE544 (cpu address)
        ; The bank of 0x1B is plugged in by Palette_MultiLoad
        LDA.w #$E544 : STA $00
        
        REP #$10
        
        LDA.w #$0040    ; Starting target palette is BP-2
        LDX.w #$000F    ; Each palette has 16 colors
        LDY.w #$0005    ; Load 6 palettes
        
        JSR Palette_MultiLoad
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$DEE52-$DEE73 LONG
    Palette_Hud:
    {
        REP #$21
        
        LDX $0AB2
        
        LDA $1BEC47,X : AND.w #$00FF : ADC.w #$D660 : STA $00
        
        ; X/Y registers are 8-bit
        REP #$10
        
        ; Target BP0 through BP1 (full)
        ; Each palette has 16 colors.
        ; Load 2 palettes
        LDA.w #$0000
        LDX.w #$000F
        LDY.w #$0001
        
        JSR Palette_MultiLoad
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$DEE74-$DEEA7 LONG
    Palette_DungBgMain:
    {
        ; Note this resets the carry. (For the ADC below.)
        REP #$21
        
        ; This is the palette index for a certain background
        LDX $0AB6
        
        LDA $1BEC4B, X : ADC.w #$D734 : STA $00 : PHA
        
        REP #$10
        
        LDA.w #$0042    ; Target BP-2 through BP-7 (full)
        LDX.w #$000E    ; (Length - 1) (in words) of the palettes.
        LDY.w #$0005    ; Load 6 palettes
        
        JSR Palette_MultiLoad
        
        ; Now get that value of A before the subroutine.
        PLA
        
        ; Reload it to $00.
        STA $00
        
        ; Target SP-0 (second half)
        LDA.w #$0112
        
        ; Unknown variable
        LDX $0ABD : BEQ .useSP0
        
        ; Target SP-7 (second half)
        LDA.w #$01F2
    
    .useSP0
    
        LDX.w #$0006
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$DEEA8-$DEEC6 LONG
    Palette_OverworldBgAux3:
    {
        REP #$21
        
        LDX $0AB8
        
        LDA $1BEBC6, X : AND.w #$00FF : ADC.w #$E604 : STA $00
        
        REP #$10
        
        LDA.w #$00E2  ; Target BP-7 (first half)
        LDX.w #$0006
        
        JSR Palette_SingleLoad
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; *$DEEC7-$DEEE7 LONG
    Palette_OverworldBgMain:
    {
        REP #$21
        
        LDA $0AB3 : ASL A : TAX
        
        LDA $1BEC3B, X : ADC.w #$E6C8 : STA $00
        
        REP #$10
        
        ; Target BP2 through BP6 (first halves)
        ; each palette has 7 colors
        ; Load 5 palettes
        LDA.w #$0042
        LDX.w #$0006
        LDY.w #$0004
        
        JSR Palette_MultiLoad
        
        SEP #$30
        
        RTL
    }

; =============================================

    ; $DEEE8-$DEF0B LONG
    Palette_OverworldBgAux1:
    {
        REP #$21
        
        LDA $0AB4 : AND.w #$00FF : ASL A : TAX
        
        LDA $1BEC13, X : ADC.w #$E86C : STA $00
        
        REP #$10
        
        LDA.w #$0052  ; Target BP-2 through BP-4 (second halves)
        LDX.w #$0006  ; each one has 7 colors
        LDY.w #$0002  ; Load 3 palettes
        
        JSR Palette_MultiLoad
        
        REP #$30
        
        RTL
    }

; =============================================

    ; *$DEF0C-$DEF2F LONG
    Palette_OverworldBgAux2:
    {
        REP #$21
        
        LDA $0AB5 : AND.w #$00FF : ASL A : TAX
        
        LDA $1BEC13, X : ADC.w #$E86C : STA $00
        
        REP #$10
        
        LDA.w #$00B2  ; Target BP-5 through BP-7 (second halves)
        LDX.w #$0006  ; each one has 7 colors
        LDY.w #$0002  ; load 3 palettes
        
        JSR Palette_MultiLoad
        
        SEP #$30
        
        RTL
    }

; ==================================================

    ; *$DEF30-$DEF4A LOCAL
    Palette_SingleLoad:
    {
        ; Unlike like the Subroutine after this one, it only loads one palette to memory.
        ; Parameters: X = number of colors (i.e. number of words/16-bit values to write)
        ;             A = offset for placing palette in memory.
        ; Name = Palette_SingleLoad(X, A)
        
        ; Ensures the counter is saved
        ; Generally the place to look for this value is $0AA9 (high byte)
        TXY : ADD $0AA8 : TAX
        
        ; Ensure the data bank being drawn from is 1B = #$D in Rom
        LDA.w #$001B : STA $02

    .copyPalette
    
        ; Since this is a long indirect, that's why #$1B was put in $02.
        LDA [$00] : STA $7EC300, X
        
        INC $00 : INC $00
        
        INX #2
        
        DEY : BPL .copyPalette
        
        RTS
    }

; ==================================================

    ; *$DEF4B-$DEF7A LOCAL
    Palette_MultiLoad:
    {
        ; Description: Generally used to load multiple palettes for BGs.
        ; Upon close inspection, one sees that this algorithm is almost the same as the
        ; last subroutine.
        ; Name = Palette_MultiLoad(A, X, Y)
        
        ; Parameters: X = (number of colors in the palette - 1)
        ;             A = offset to add to $7EC300, in other words, where to write in palette
        ;             memory
        ;             Y = (number of palettes to load - 1)
        ; 
        
        STA $04 ; Save the values for future reference.
        STX $06
        STY $08
        
        LDA.w #$001B    ; The absolute address at $00 was planted in the calling function. This value 
                        ; is the bank #$1B ( => D in Rom) The address is found from $0AB6
        STA $02         ; And of course, store it at $02
    
    .nextPalette
    
        ; $0AA8 + A parameter will be the X value.
        LDA $0AA8 : ADD $04 : TAX
        
        LDY $06 ; Tell me how long the palette is.
    
    .copyColors
    
        ; We're loading A from the address set up in the calling function.
        LDA [$00] : STA $7EC300, X 
        
        ; Increment the absolute portion of the address by two, and decrease the color count by one
        INC $00 : INC $00
        
        INX #2
        
        ; So basically loop (Y+1) times, taking (Y * 2 bytes) to $7EC300, X        
        DEY : BPL .copyColors
        
        ; This technique bumps us up to the next 4bpp (16 color) palette.
        LDA $04 : ADD.w #$0020 : STA $04
        
        ; Decrease the number of palettes we have to load.
        DEC $08
        
        BPL .nextPalette
        
        ; We're done loading palettes.
        
        RTS
    }

; =============================================

    ; *$DEF7B-$DEF95 LOCAL
    Palette_ArbitraryLoad:
    {
        ; This routine accepts a 2 byte pointer local to bank 0x1B
        ; A = starting offset into the palette buffer to copy to
        ; X = the number of colors in the palette
        
        TXY : TAX
        
        LDA.w #$001B : STA $02
    
    .loop
    
        LDA [$00] : STA $7EC300, X : STA $7EC500, X
        
        INC $00 : INC $00
        
        INX #2
        
        DEY : BPL .loop
        
        RTS
    }

; ==============================================================================

    ; *$DEF96-$DF031 LONG
    Palette_SelectScreen:
    {
        ; This routine sets up the palettes for each of the three Links on the
        ; Select screen.
        
        ; Set data bank to 0x1B
        PHB : LDA.b #$1B : PHA : PLB
        
        REP #$30
        
        ; save slot 1
        
        LDX.w #$0000
        
        ; This tells us what kind of gloves link has.
        LDA $700354 : STA $0C
        
        ; The value for your armor
        LDA $70035B
        
        JSR Palette_SelectScreenArmor
        
        LDX.w #$0000
        
        LDA $700359
        
        JSR Palette_SelectScreenSword
        
        LDX.w #$0000
        
        LDA $70035A
        
        JSR Palette_SelectScreenShield
        
        ; save slot two
        
        LDX.w #$0040
        
        ; Again we need the palette for his gloves
        LDA $700854 : STA $0C
        
        ; The value for the armor
        LDA $70085B
        
        JSR Palette_SelectScreenArmor
        
        LDX.w #$0040
        
        LDA $700859
        
        JSR Palette_SelectScreenSword
        
        LDX.w #$0040
        
        LDA $70085A
        
        JSR Palette_SelectScreenShield
        
        ; save slot three
        
        LDX.w #$0080
        
        ; Again we need the palette for his gloves
        LDA $700D54 : STA $0C
        
        LDA $700D5B
        
        JSR Palette_SelectScreenArmor
        
        LDX.w #$0080
        
        LDA $700D59
        
        JSR Palette_SelectScreenSword
        
        LDX.w #$0080
        
        LDA $700D5A
        
        JSR Palette_SelectScreenShield
        
        LDY.w #$0000
        LDX.w #$0000
    
    .loadFaeriePalette
    
        ; This section of code has to do with loading the faerie sprite used
        ; For selecting which game you're in.
        
        LDA $D226, Y : STA $7EC4D0, X : STA $7EC6D0, X
        LDA $D244, Y : STA $7EC4F0, X : STA $7EC6F0, X
        
        INY #2
        INX #2
        
        CPX.w #$000E
        
        BNE .loadFaeriePalette
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$DF032-$DF071 LOCAL
    Palette_SelectScreenArmor:
    {
        ; And gloves!
        
        PHX
        
        ;  Varies among #$00, #$40, #$80
        AND.w #$00FF : ASL A : TAY
        
        ; $DEC06 IN ROM, will be 0, 30, or 60
        LDA $EC06, Y : AND.w #$00FF : ADD.w #$00F0 : TAY
        
        ; Length of the palette in Words
        LDA.w #$000F : STA $0E
    
    .loadArmorPalette
    
        ; Load the faeries's palette data?
        LDA $D218, Y : STA $7EC402, X : STA $7EC602, X
        
        INY #2
        
        INX #2 ; Hence we will be writing #$F * 2 bytes = #$1E
        
        DEC $0E : BNE .loadArmorPalette
        
        PLX
        
        ; This had $700354 (or 834 or D34)'s value.
        LDA $0C : AND.w #$00FF : BEQ .defaultGloveColor
        
        ; We're here if $0C was nonzero.
        ; Y = 2*(A - 1)
        DEC A : ASL A : TAY
        
        ; X will be #$00, #$40, #$80...
        LDA $EDF5, Y : STA $7EC41A, X : STA $7EC61A, X
    
    .defaultGloveColor
    
        RTS
    }

; =============================================

    ; *$DF072-$DF099 LOCAL
    Palette_SelectScreenSword:
    {
        ; Expects A to be the sword's value.
        AND.w #$00FF : TAY ; Will be 0-4.
        
        ; $DEBB4 IN ROM. A will be #$00, #$06, #$0C, #$12...
        ; Generally A will be #$418, #$41E, #$424, #$42A
        LDA $EBB4, Y : AND.w #$00FF : ADD.w #$0418 : TAY
        
        ; The length of the palette in Word Length
        LDA.w #$0003 : STA $0E
    
    .copyPalette
    
        ; $DD218 IN ROM
        LDA $D218, Y : STA $7EC432, X : STA $7EC632, X
        
        INY #2
        
        INX #2
        
        ; Branch 3 times, write 6 bytes, go home...
        DEC $0E : BNE .copyPalette
        
        RTS
    }
    
; =============================================

    ; *$DF09A-$DF0C1 LOCAL
    Palette_SelectScreenShield:
    {
        ; This routine is generally the same as the two above.
        ; A is expected to be the value of your shield. (0 - 3)
        AND.w #$00FF : TAY
        
        ; #$00, #$08, #$10
        ; A will be #$430, #$438, #$440
        LDA $EBC1, Y : AND.w #$00FF : ADD.w #$0430 : TAY
        
        ; Length of the palette in Word Length. (8 bytes)
        LDA.w #$0004 : STA $0E
    
    .copyPalette
    
        ; $D218 appears to be the base address for palette data.
        LDA $D218, Y : STA $7EC438, X : STA $7EC638, X
        
        INY #2
        
        INX #2
        
        DEC $0E : BNE .copyPalette
        
        RTS
    }

; ==============================================================================

    ; \task Perhaps rename this routine when we have a better idea of what its
    ; exact use is. As it stands, it's named so due to the circumstances under
    ; which it is called.
    ; *$DF0C2-$DF107 LONG
    Palette_AgahnimClones:
    {
        ; The only place this routine is referenced from is the
        ; (assumed for now) unused submodule 0x06 of module 0x0E
        ; Seems to have something to do with Agahnim 2 though.
        
        ; In general terms this loads the upper halves of SP_3, SP_4, SP_5,
        ; and SP_6.
        REP #$31
        
        LDA $1BEBF2 : ADC.w #$D4E0 : STA $00
        
        PHA
        
        LDA.w #$0162
        LDX.w #$0006
        
        JSR Palette_ArbitraryLoad
        
        PLA : STA $00
        
        PHA
        
        LDA.w #$0182
        LDX.w #$0006
        
        JSR Palette_ArbitraryLoad
        
        PLA : STA $00
        
        LDA.w #$01A2
        LDX.w #$0006
        
        JSR Palette_ArbitraryLoad
        
        LDA $1BEC00 : ADD.w #$D4E0 : STA $00
        
        LDA.w #$01C2
        LDX.w #$0006
        
        JSR Palette_ArbitraryLoad
        
        SEP #$30
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; $DF108-$DF10F NULL
    {
        fillbyte $FF
        
        fill $08
    }

; ==============================================================================

    ; \note some kind of tile properties data for bank $05... Seems to be
    ; indexed by map16 values.
    ; $DF110-$DFFBF DATA
    {

    }

; ==============================================================================

    ; $DFFC0-$DFFFF NULL
    pool Null:
    {
        fillbyte $FF
        
        fill $40
    }

; ==============================================================================
