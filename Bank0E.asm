
org $0E8000

    ; \covered($70000-$70FFF)

    ; $70000-$70FFF FILE
    incbin "binary_files/font_gfx.bin"

; ==============================================================================

    ; $71000-$71429 DATA
    pool Dungeon_LoadCustomTileAttr:
    {
    
    .group_offsets
        dw $0000, $0000, $0000, $0080, $0080, $0100, $0100, $0100
        dw $0180, $0000, $0100, $0200, $0280, $0300, $0380, $0100
        dw $0100, $0080, $0100, $0380, $0100
    
    .groups
        ; This consists of customized tile behaviors based on the value of the current
        ; BG tileset ($0AA2)
        db $02, $02, $02, $02, $02, $02, $6E, $6F
        db $01, $6C, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $00, $00
        db $00, $00, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $6E, $6F
        db $01, $6C, $02, $02, $02, $02, $01, $02
        db $00, $00, $22, $00, $00, $00, $02, $02
        db $02, $02, $02, $02, $00, $00, $01, $00
        db $01, $01, $01, $01, $01, $01, $01, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $01, $01, $01, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $18, $00, $00, $00
        db $00, $00, $02, $02, $01, $01, $01, $01
        db $02, $02, $02, $01, $02, $02, $08, $08
        db $08, $08, $09, $09, $09, $09, $09, $09
        
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $18, $00, $00, $00
        db $00, $00, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $02, $02, $08, $08
        db $08, $08, $09, $09, $09, $09, $09, $09
        
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $00, $00
        db $00, $00, $02, $02, $00, $00, $02, $00
        db $01, $01, $01, $01, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $00, $00, $00, $00
        db $00, $00, $02, $02, $02, $02, $02, $02
        db $6B, $6A, $02, $01, $02, $02, $08, $08
        db $08, $08, $09, $09, $09, $09, $68, $69
        
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $09, $09, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $02, $02
        db $02, $02, $02, $02, $00, $00, $00, $00
        db $01, $01, $01, $00, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $08, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $18, $00, $00, $00
        db $00, $00, $02, $02, $02, $02, $02, $02
        db $08, $08, $02, $01, $01, $09, $08, $08
        db $08, $08, $09, $09, $09, $09, $09, $09
        
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $02, $02
        db $02, $02, $02, $02, $00, $00, $00, $00
        db $01, $01, $01, $01, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $00, $0F, $00
        db $00, $00, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $02, $02, $08, $08
        db $08, $08, $0E, $0E, $0E, $0E, $00, $00
        
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $02, $02
        db $01, $02, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $00, $00
        db $00, $00, $02, $02, $00, $00, $00, $00
        db $01, $01, $01, $01, $02, $02, $02, $0D
        db $0D, $02, $02, $02, $02, $02, $02, $02
        db $01, $01, $01, $01, $02, $02, $02, $0D
        db $0D, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $00, $00, $00
        db $00, $00, $02, $02, $02, $02, $02, $02
        db $6B, $6A, $02, $01, $02, $02, $08, $08
        db $08, $08, $09, $09, $09, $09, $68, $69
        
        db $B2, $B4, $B1, $BB, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $B3, $B5, $B0, $B6, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $02, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $02, $02
        db $02, $02, $02, $02, $00, $00, $00, $00
        db $B1, $B2, $B3, $B4, $B5, $B1, $B0, $02
        db $BE, $02, $02, $02, $02, $02, $B7, $B8
        db $B0, $B2, $B3, $B4, $B5, $02, $B0, $02
        db $00, $02, $B1, $BE, $00, $BD, $B9, $BA
        db $02, $02, $B1, $B0, $02, $00, $00, $00
        db $BD, $BC, $02, $02, $02, $02, $02, $02
        db $00, $00, $00, $00, $00, $0E, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $01, $01, $01, $01, $01
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $01, $01, $02, $02, $02, $02, $02, $02
        db $00, $00, $22, $00, $00, $00, $00, $00
        db $00, $00, $02, $02, $00, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $00, $00, $00, $00, $00, $00, $02, $02
        db $01, $01, $01, $01, $01, $01, $01, $01
        db $00, $00, $00, $00, $00, $00, $02, $02
        db $02, $02, $02, $02, $18, $00, $00, $00
        db $00, $00, $00, $00, $01, $01, $01, $01
        db $6B, $6A, $02, $01, $02, $02, $08, $08
        db $08, $08, $0E, $0E, $0E, $0E, $68, $69
    }

; ==============================================================================

    ; *$7142A-$71458 LONG
    Dungeon_LoadCustomTileAttr:
    {
        ; Loads tile attributes that are specific to a tileset type.
        ; The group loaded is dependent on the value of $0AA2.
        PHB : PHK : PLB
        
        REP #$30
        
        LDA $0AA2 : AND.w #$00FF : ASL A : TAX
        
        LDA .group_offsets, X : TAY
        
        LDX.w #$0000
    
    .load_loop
    
        LDA .blocks, Y       : STA $7EFF40, X
        LDA .blocks + $40, Y : STA $7EFF80, X
        
        INY #2
        
        INX #2 : CPX.w #$0040 : BNE .load_loop
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $71459-$71658 DATA (Note: This data is not accessed from this bank)
    Overworld_TileAttr:
    {
        db $27, $27, $27, $27, $27, $27, $02, $02, $01, $01, $01, $00, $00, $00, $00, $00
        db $27, $01, $01, $01, $01, $01, $02, $02, $27, $27, $27, $00, $00, $00, $00, $00
        db $27, $01, $01, $01, $20, $01, $02, $02, $27, $27, $27, $00, $00, $00, $00, $00
        db $27, $01, $01, $01, $01, $20, $02, $02, $02, $02, $02, $00, $00, $00, $00, $00
        db $01, $01, $01, $01, $1A, $01, $12, $01, $01, $02, $01, $01, $28, $2E, $2A, $2B
        db $01, $01, $18, $18, $1A, $01, $12, $01, $01, $2C, $02, $2D, $29, $2F, $02, $02
        db $01, $01, $01, $01, $01, $01, $02, $01, $02, $2E, $00, $00, $2C, $00, $4E, $4F
        db $01, $01, $01, $01, $01, $01, $02, $01, $02, $00, $2E, $00, $00, $00, $02, $22
        db $01, $01, $02, $00, $00, $00, $18, $12, $02, $02, $00, $48, $00, $00, $00, $00
        db $01, $01, $02, $00, $01, $01, $10, $1A, $02, $00, $00, $48, $00, $00, $00, $00
        db $10, $10, $02, $00, $01, $01, $01, $01, $00, $00, $48, $00, $00, $09, $00, $00
        db $02, $02, $02, $00, $01, $01, $2B, $00, $00, $09, $00, $00, $00, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00
        db $01, $01, $01, $46, $01, $01, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00
        db $02, $02, $42, $02, $02, $02, $02, $02, $02, $02, $29, $22, $00, $00, $00, $00
        db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $29, $22, $00, $00, $00, $00
        db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00, $00, $00, $00
        db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $02, $44
        db $01, $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $00, $00, $00, $02, $44
        db $01, $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $00, $00, $00, $00, $00
        db $01, $01, $43, $01, $01, $01, $01, $01, $02, $02, $02, $00, $00, $00, $00, $00
        db $50, $02, $54, $51, $57, $57, $56, $56, $27, $27, $27, $00, $40, $40, $48, $48
        db $50, $02, $54, $51, $57, $2A, $56, $56, $27, $27, $27, $00, $40, $40, $57, $48
        db $27, $02, $52, $53, $02, $01, $12, $18, $55, $55, $00, $00, $48, $02, $02, $00
        db $27, $02, $52, $53, $09, $01, $1A, $10, $55, $55, $00, $00, $48, $02, $02, $00
        db $02, $02, $18, $08, $08, $08, $09, $09, $08, $08, $29, $02, $02, $02, $1A, $02
        db $08, $08, $10, $08, $12, $00, $09, $09, $09, $09, $09, $48, $09, $29, $00, $4B
        db $02, $02, $02, $00, $08, $02, $02, $00, $00, $00, $00, $01, $00, $00, $20, $00
        db $02, $02, $02, $02, $02, $02, $02, $00, $00, $01, $01, $01, $02, $00, $08, $00
    }

; ==============================================================================

    ; $71659-$717D8 DATA
    Dungeon_DefaultAttr:
    {
        db $01, $01, $01, $00, $02, $01, $02, $00, $01, $01, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $00, $00, $01, $00, $00, $02, $00, $00, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $01, $01, $01, $02, $02, $02, $02, $02, $01, $01, $00, $00
        db $02, $02, $02, $02, $02, $02, $01, $02, $02, $02, $02, $02, $01, $01, $00, $00
        
        db $00, $00, $00, $2A, $01, $20, $01, $01, $04, $01, $01, $18, $01, $02, $1C, $01
        db $28, $28, $2A, $2A, $01, $02, $01, $01, $04, $00, $00, $00, $28, $01, $0A, $00
        db $01, $01, $0C, $0C, $02, $02, $02, $02, $28, $2A, $20, $20, $20, $02, $08, $00
        db $04, $04, $01, $01, $01, $02, $02, $02, $00, $00, $20, $20, $00, $02, $00, $00
        
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $02
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $18, $10, $10, $01, $01, $01
        db $01, $01, $04, $04, $04, $04, $04, $04, $01, $02, $02, $00, $00, $00, $00, $00
        db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $02
        
        db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $62, $62
        db $00, $00, $24, $24, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $62, $62
        db $27, $02, $02, $02, $27, $27, $01, $00, $00, $00, $00, $24, $00, $00, $00, $00
        db $27, $27, $27, $27, $27, $10, $02, $01, $00, $00, $00, $24, $00, $00, $00, $00
        
        db $27, $02, $02, $02, $27, $27, $27, $27, $02, $02, $02, $24, $00, $00, $00, $00
        db $27, $27, $27, $27, $27, $20, $02, $02, $01, $02, $02, $23, $02, $00, $00, $00
        db $27, $27, $27, $27, $27, $20, $02, $27, $02, $54, $00, $00, $27, $02, $02, $02
        db $27, $27, $27, $27, $27, $27, $02, $27, $02, $54, $00, $00, $27, $02, $02, $02
        
        ; \note Values before this comment go to $7EFE00-$7EFF3F, values after
        ; it end up at $7EFFC0-$7EFFFF. The remaining memory contains values
        ; from the custom attributes data.
        
        db $27, $27, $00, $27, $60, $60, $01, $01, $01, $01, $02, $02, $0D, $00, $00, $4B
        db $67, $67, $67, $67, $66, $66, $66, $66, $00, $00, $20, $20, $20, $20, $20, $20
        db $27, $63, $27, $55, $55, $01, $44, $00, $01, $20, $02, $02, $1C, $3A, $3B, $00
        db $27, $63, $27, $53, $53, $01, $44, $01, $0D, $00, $00, $00, $09, $09, $09, $09
    }
    
; ==============================================================================

    ; *$717D9-$71813 LONG
    Init_LoadDefaultTileAttr:
    {
        REP #$20
        
        LDX.b #$3E
    
    .loop
    
        LDA Dungeon_DefaultAttr + $000, X : STA $7EFE00, X
        LDA Dungeon_DefaultAttr + $040, X : STA $7EFE40, X
        LDA Dungeon_DefaultAttr + $080, X : STA $7EFE80, X
        LDA Dungeon_DefaultAttr + $100, X : STA $7EFEC0, X
        LDA Dungeon_DefaultAttr + $140, X : STA $7EFF00, X
        LDA Dungeon_DefaultAttr + $180, X : STA $7EFFC0, X
        
        DEX #2 : BPL .loop
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; $71814-$7181F EMPTY
    pool Empty:
    {
        fillbyte $FF
        
        fill $0C
    }

; ==============================================================================

    ; $71820-$7186D DATA TABLE
    {
        ; Usage: Main Module 1A
        
        ; Parameter: $11
        
        ; Notes: the combination 9889, 9958 is an outdoor scene
        ; the combination 9891, 99C5 is an indoor scene (sanctuary, etc)
        ; Anything after those combinations is of the second part of the ending
        ; Specifically, the credits set against the Triforce spinning in the 
        ; air, overlooking the golden land.
        
        dw $9889 ; 0:  = $71889* ; Hyrule Castle restored
        dw $9958 ; 1:  = $71958*
        dw $9891 ; 2:  = $71891* ; Priest Recovers
        dw $99C5 ; 3:  = $719C5*
        dw $9889 ; 4:  = $71889* ; Sahasralah's Homecoming
        dw $9958 ; 5:  = $71958*
        dw $9889 ; 6:  = $71889* ; Vultures rule the desert
        dw $9958 ; 7:  = $71958*
        
        dw $9889 ; 8:  = $71889* ; The Bully makes a friend
        dw $9958 ; 9:  = $71958*
        dw $9889 ; A:  = $71889* ; Uncle recovers
        dw $9958 ; B:  = $71958*
        dw $9889 ; C:  = $71889* ; Zora's Area Scene
        dw $9958 ; D:  = $71958*
        dw $9889 ; E:  = $71889* ; Witch and Assistant
        dw $9958 ; F:  = $71958*
        
        dw $9889 ; 10: = $71889* ; Twin Lumberjacks
        dw $9958 ; 11: = $71958*
        dw $9889 ; 12: = $71889* ; Fluteboy plays again
        dw $9958 ; 13: = $71958*
        dw $9891 ; 14: = $71891* ; Venus, queen of Faeries (and herpes)
        dw $99C5 ; 15: = $719C5*
        dw $9891 ; 16: = $71891* ; Dwarven Swordsmiths
        dw $99C5 ; 17: = $719C5*
        
        dw $9889 ; 18: = $71889* ; The Bug Catching Kid
        dw $9958 ; 19: = $71958*
        dw $9889 ; 1A: = $71889* ; The Lost Old Man
        dw $9958 ; 1B: = $71958*
        dw $9889 ; 1C: = $71889* ; The Forest Thief
        dw $9958 ; 1D: = $71958*
        dw $9889 ; 1E: = $71889* ; Master Sword Sleeps Again, Forever!
        dw $9958 ; 1F: = $71958*
        
        dw $BC6D ; 20: = $73C6D* ; Sets up for mode 0x22. Various other things
        dw $C37C ; 21: = $7437C* ; Light up the triforce and the screen
        dw $BD8B ; 22: = $73D8B* ; Scrolls the credits, and number of deaths, etc.
        dw $C391 ; 23: = $74391*
        dw $C3B8 ; 24: = $743B8* ; ?????
        dw $C3D5 ; 25: = $743D5*
        dw $C41A ; 26: = $7441A*
    }

; ==============================================================================

    ; *$7186E-$71888 JUMP LOCATION
    Module_EndSequence:
    {
        ; Beginning of Module 1A, Ending Sequence Mode
        
        REP #$20
        
        LDA.w #$0030 : STA $0FE0
        LDA.w #$01D0 : STA $0FE2
        
        STZ $0FE4
        
        SEP #$20
        
        ; Load the level 1 submodule index and used it to index into a jump table.
        LDA $11 : ASL A : TAX
        
        JSR ($9820, X) ; ($71820, X) that is.
        
        RTL
    }
    
    ; *$71889-$71890 LOCAL
    {
        ; For overworld portions
        JSL $0285BA ; $105BA IN ROM
        JSR $C303   ; $74303 IN ROM
        
        RTS
    }
    
    ; *$71891-$71898 LOCAL
    {
        ; For dungeon portions
        JSL $0286FD     ; $106FD IN ROM ; Module 1A's basecamp in Bank02
        JSR $C303       ; $74303 IN ROM
    }

    ; $71899-$718B8 JUMP TABLE
    {
        dw $9CFE ; = $71CFE* ; 
        dw $9D84 ; = $71D84* ; Priest recovers
        dw $9C27 ; = $71C27*
        dw $9C2F ; = $71C2F*
        dw $9CFE ; = $71CFE*
        dw $9CFE ; = $71CFE*
        dw $9C1A ; = $71C1A*
        dw $9CCA ; = $71CCA*
        dw $9CFE ; = $71CFE*
        dw $9C5B ; = $71C5B*
        dw $9D5C ; = $71D5C* ; Venus, goddess of faeries
        dw $9D70 ; = $71D70*
        dw $9CD1 ; = $71CD1*
        dw $9CFE ; = $71CFE*
        dw $9C92 ; = $71C92*
        dw $9CB4 ; = $71CB4*
    }

    ; *$718B9-$718D7 LONG
    {
        PHB : PHK : PLB
        
        LDX.b #$0F

    .loop

        JSL Sprite_ResetProperties
        
        STZ $0DD0, X
        STZ $0BE0, X
        STZ $0CAA, X
        
        DEX : BPL .loop
        
        LDA $11 : AND.b #$FE : TAX
        
        JSR ($9899, X)  ; ($71899, X THAT IS) SEE JUMP TABLE
        
        PLB
        
        RTL
    }

    ; *$71958-$719A4 LOCAL
    {
        PHB : PHK : PLB
        
        LDX.b #$0F
    
    BRANCH_BETA:
    
        LDA $0DF0, X : BEQ BRANCH_ALPHA
        
        DEC $0DF0, X
    
    BRANCH_ALPHA:
    
        DEX : BPL BRANCH_BETA
        
        LDA $11 : AND.b #$FE : TAX
        
        STZ $30
        STZ $31
        
        REP #$20
        
        LDA $C8
        
        CMP.w #$0040 : BCC BRANCH_GAMMA
        AND.w #$0001 : BNE BRANCH_GAMMA
        
        ; $718D8, X THAT IS
        LDA $E8 : CMP $98D8, X : BEQ BRANCH_DELTA
        
        ; // $71918, X THAT IS
        LDY $9918, X : STY $30
    
    BRANCH_DELTA:
    
        ; $718F8, X THAT IS
        LDA $E2 : CMP $98F8, X : BEQ BRANCH_GAMMA
        
        ; $91938, X THAT IS
        LDY $9938, X : STY $31
    
    BRANCH_GAMMA:
    
        REP #$20
        
        PHX
        
        JSL $0286B3 ; $106B3 IN ROM
        
        PLX
        
        JSR ($99A5, X) ; ($719A5, X THAT IS)
        
        JMP $9A2A ; $71A2A IN ROM
    }

; ==============================================================================

    ; $719A5-$719C4 LOCAL JUMP TABLE
    {
        dw $9E9C ; = $71E9C* ; whew just one was a lot of work.
        dw $A9AD ; = $729AD* ; Priest recovers
        dw $A0E2 ; = $720E2*
        dw $A941 ; = $72941*
        dw $9F53 ; = $71F53*
        dw $A27C ; = $7227C*
        dw $A74C ; = $7274C*
        dw $A9D3 ; = $729D3*
        dw $A393 ; = $72393*
        dw $AA91 ; = $72A91*
        dw $A3C7 ; = $723C7*
        dw $A802 ; = $72802*
        dw $A54F ; = $7254F*
        dw $A358 ; = $72358*
        dw $ABF5 ; = $72BF5*
        dw $AD22 ; = $72D22*
    }

    ; *$719C5-$71A09 LOCAL
    {
        ; Dungeon Engine for Ending sequence (module 1A)
        
        PHB : PHK : PLB
        
        LDX.b #$0F
    
    BRANCH_BETA:
    
        LDA $0DF0, X
        
        BEQ BRANCH_ALPHA
        
        ; Countdown sprite timer
        DEC $0DF0, X
    
    BRANCH_ALPHA:
    
        DEX
        
        BPL BRANCH_BETA
        
        LDA $11 : AND.b #$FE : TAX
        
        REP #$20
        
        LDA $C8 : CMP.w #$0040
        
        BCC BRANCH_GAMMA
        
        AND.w #$0001
        
        BNE BRANCH_GAMMA
        
        LDA $E8 : CMP $98D8, X
        
        BEQ BRANCH_DELTA
        
        ADD $9918, X : STA $E8
    
    BRANCH_DELTA:
    
        LDA $E2 : CMP $98F8, X
        
        BEQ BRANCH_GAMMA
        
        ADD $9938, Y : STA $E2
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        JSR ($99A5, X) ; SEE JUMP TABLE AT $719A5
        JMP $9A2A      ; $71A2A
    }

    ; *$71A2A-$71A75 JUMP LOCATION
    {
        LDA $11 : AND.b #$FE : TAX
        
        REP #$20
        
        LDA $C8 : CMP $9A0A, X : SEP #$20 : BCC BRANCH_ALPHA
        
        LDA $C8 : AND.b #$01 : BNE BRANCH_BETA
        
        DEC $13 : BNE BRANCH_BETA
        
        INC $11
        
        BRA BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        LDA $C8 : AND.b #$01 : BNE BRANCH_BETA
        
        LDA $13 : CMP.b #$0F : BEQ BRANCH_BETA
        
        INC $13
    
    BRANCH_BETA:
    
        REP #$20
        
        INC $C8
        
        SEP #$20
    
    BRANCH_GAMMA:
    
        REP #$20
        
        LDA $E2 : STA $011E
        LDA $E8 : STA $0122
        LDA $E0 : STA $0120
        LDA $E6 : STA $0124
        
        SEP #$20
        
        PLB
        
        RTS
    }

    ; *$71C1A-$71C55 LOCAL
    {
        LDA.b #$FF : STA $0DF0 : STA $0DF1 : STA $0DF2
        
        BRA .beta
    
    ; *$71C27-$71C55 ALTERNATE ENTRY POINT
    
        LDA $AE62 : STA $0D46
        
        BRA .beta
    
    ; *$71C2F ALTERNATE ENTRY POINT
    
        LDA.b #$16 : STA $0D95
        
        LDA $AE62 : STA $0D40
        LDA $AE61 : STA $0D41
        
        LDA.b #$01 : STA $0EB1
        
        LDY.b #$02
    
    .alpha
    
        LDA.b #$57 : STA $0E22, Y
        
        LDA.b #$31 : STA $0F52, Y
        
        DEY : BPL .alpha
    
    .beta
    
        BRA $71C90
    }

    ; $71C56-$71C5A DATA [ ]

    ; *$71C5B-$71D5B LOCAL
    {
        LDY.b #$04
    
    BRANCH_1:
    
        LDA $9C56, Y : STA $0DF0, Y
        
        LDA.b #$00 : STA $0DD0, Y
        
        DEY : BPL BRANCH_1
        
        LDA.b #$2E : STA $0E25
        
        LDY.b #$01
    
    BRANCH_2:
    
        LDA.b #$9F : STA $0E27, Y
        LDA.b #$A0 : STA $0E29, Y
        
        LDA.b #$01 : STA $0E47, Y : INC A : STA $0E49, Y
        LDA.b #$10 : STA $0E67, Y :         STA $0E69, Y
        
        DEY : BPL BRANCH_2
    
    ; *$71690 EXTERNAL BRANCH POINT
    
        BRA BRANCH_5
    
    ; *$71C92 ALTERNATIVE ENTRY POINT
    
        LDA $AE62 : STA $0D45
        LDA $AE61 : STA $0D46
        
        LDA.b #$01 : STA $0EB6
        LDA.b #$08 : STA $0D90
        
        LDY.b #$03
    
    BRANCH_3:
    
        LDA.b #$04 : STA $0D41, Y
        
        DEY : BPL BRANCH_3
        
        BRA BRANCH_5
    
    ; *71CB4 ALTERNATIVE ENTRY POINT
    
        LDA.b #$02 : STA $0DB4
        LDA.b #$08 : STA $0D45
        LDA.b #$13 : STA $0DF1
        
        LDA.b #$40 : STA $0DF4
        
        BRA BRANCH_5
    
    ; *$71CCA ALTERNATIVE ENTRY POINT
    
        LDA.b #$FF : STA $0DF1
        
        BRA BRANCH_5
    
    ; *$71CD1 ALTERNATIVE ENTRY POINT
    
        LDY.b #$01
    
    BRANCH_4:
    
        LDA.b #$39 : STA $0F53, Y
        LDA.b #$0B : STA $0E23, Y
        LDA.b #$10 : STA $0E63, Y
        LDA.b #$01 : STA $0E43, Y
        
        DEY : BPL BRANCH_4
        
        LDA.b #$2A : STA $0E25
        
        LDA.b #$79 : STA $0E26
        LDA.b #$01 : STA $0D86
        LDA.b #$05 : STA $0F76
    
    ; *$71CFE ALTERNATIVE ENTRY POINT
    BRANCH_5:
    
        LDA $9BCA, X : STA $04
        LDA $9BCB, X : STA $05
        LDA $9BEA, X : STA $06
        LDA $9BEB, X : STA $07
        
        TXA : LSR A : TAX
        
        LDA $9C0A, X : TAX
    
    BRANCH_6:
    
        TXA : ASL A : TAY
        
        REP #$20
        
        LDA.w #$FFFF : STA $0FBA
                       STA $0FB8
        
        LDA $040A : ASL A : XBA : AND.w #$0F00 : ADD ($04), Y : STA $00
        
        LDA $040A : LSR A : LSR A : XBA : AND.w #$0E00 : ADD ($06), Y : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0D10
        LDA $01 : STA $0D30
        LDA $02 : STA $0D00
        LDA $03 : STA $0D20
        
        DEX : BPL BRANCH_6
        
        RTS
    }

    ; *$71D5C-$71DFF LOCAL
    {
        LDA.b #$10 : STA $0DF1
        LDA.b #$20 : STA $0DF2
        
        LDA.b #$08 : STA $0F53 : STA $0F54
        
        BRA BRANCH_1
    
    ; *$71D70 ALTERNATE ENTRY POINT
    
        LDA.b #$79 : STA $0F54
        LDA.b #$39 : STA $0F55
        
        LDA.b #$01 : STA $0DE1
        LDA.b #$04 : STA $0D91
    
    BRANCH_1:
    ; *$71D84 ALTERNATE ENTRY POINT
    
        REP #$20
        
        LDA $048E : LSR #3
        
        SEP #$20
        
        AND.b #$FE : STA $0FB1
        
        LDA $048E : AND.b #$0F : ASL A : STA $0FB0
        
        ; $71BCA, X THAT IS
        LDA $9BCA, X : STA $04
        LDA $9BCB, X : STA $05
        LDA $9BEA, X : STA $06
        LDA $9BEB, X : STA $07
        
        TXA : LSR A : TAX
        
        ; $71C0A in Rom. Number of sprites in ending sequence
        LDA $9C0A, X : TAX
    
    BRANCH_2:
    
        TXA : ASL A : TAY
        
        LDA $0FB1 : XBA
        
        LDA.b #$00
        
        REP #$20
        
        ADD ($06), Y : STA $02
        
        SEP #$20
        
        LDA $0FB0 : XBA
        
        LDA.b #$00
        
        REP #$20
        
        ADD ($04), Y : STA $00
        
        SEP #$20
        
        LDA $00 : STA $0D10, X
        LDA $01 : STA $0D30, X
        LDA $02 : STA $0D00, X
        LDA $03 : STA $0D20, X
        
        DEX
        
        BPL BRANCH_2
        
        RTS
    }

; *$71E9C-$71EE0 LOCAL
{
	PHX
	
	LDX.b #$0B

.alpha

	LDA $9E90, X : STA $0F50, X
	
	LDA $9E84, X
    LDY $9E78, X
	
	JSR $A703 ; $72703 IN ROM
	
	DEX : CPX.b #$07
	
	BNE .alpha

.beta

	LDA $1A : ASL #2 : AND.b #$40 : ORA $9E90, X : STA $0F50, X
	
	LDA $9E84, X
	LDY $9E78, X
	
	JSR $A703 ; $72703 IN ROM
    
	DEX : CPX.b #$01
	
	BNE .beta

.gamma

	LDA $9E90, X : STA $0F50, X
	
	LDA $9E84, X
	LDY $9E78, X
	
	JSR $A703 ; $72703 IN ROM
    
	DEX
	
	BPL .gamma
    
	PLX
	
	RTS
}

; *$71F53-$71FBF LOCAL
{
    PHX
    
    LDY.b #$02
    
    LDA.b #$35 : STA $0F50, X
    
    LDA.b #$01
    LDY.b #$3C
    
    JSR $A703 ; $72703 IN ROM

BRANCH_BETA:

	DEX
	
	LDA $0D50, X : DEC A : LSR A : AND.b #$40 : EOR.b #$72 : STA $0F50, X
	
	LDA $1A : LSR #3 : AND.b #$10 : STA $0DC0, X
	
	TXA : ASL A : TAY
	
	REP #$20
	
	LDA $C8 : CMP $9F2D, Y
	
	SEP #$20
	
	BCC BRANCH_ALPHA
    
	LDA $0DF0, X : BNE BRANCH_ALPHA
    
	LDY $0D90, X
    
	LDA $9F3B, Y : PHA : AND.b #$F8 : STA $0DF0, X
	
	PLA : AND.b #$07 : TAY
	
	LDA $9F33, Y : STA $0D40, X
	LDA $9F31, Y : STA $0D50, X
    
    INC $0D90, X
	
BRANCH_ALPHA:

	LDA $9F2B, Y
	LDY $9F29, X
	
	JSR $A703   ; $72703 IN ROM
	JSR $A5FD   ; $725FD IN ROM
	JSL Sprite_MoveLong
    
	DEX : BPL BRANCH_BETA
    
	PLX
    
	RTS
}

; ==============================================================================

    ; $71FC0-$720E1 DATA
    {
    
    ; $71FC0
        dw -4,   1 : db $68, $0C, $00, $00
        dw  0,  -8 : db $40, $0C, $00, $02
        dw  0,   1 : db $42, $0C, $00, $02
        
        dw -4,   1 : db $78, $0C, $00, $00
        dw  0,  -8 : db $40, $0C, $00, $02
        dw  0,   1 : db $42, $0C, $00, $02
    
    ; $71FF0
        dw  8,   5 : db $79, $06, $00, $00
        dw  0, -10 : db $8E, $08, $00, $02
        dw  0,   0 : db $6E, $06, $00, $02
        
        dw  0, -10 : db $8E, $08, $00, $02
        dw  0, -10 : db $8E, $08, $00, $02
        dw  0,   0 : db $6E, $06, $00, $02
        
        dw  0,   0 : db $82, $08, $00, $02
        dw  0,   7 : db $4E, $0A, $00, $02
        dw  0,   0 : db $80, $48, $00, $02
        
        dw  0,   7 : db $4E, $0A, $00, $02
        dw  0,   0 : db $82, $08, $00, $02
        dw  0,   7 : db $4E, $0A, $00, $02
        
        ; \wtf Why the leftovers? Is this a mess up or intentional?
        dw  0,   0 : db $80, $08, $00, $02
        dw  0,   7 : db $4E, $0A, $00, $02
    
    ; $72060
        dw 11,  -3 : db $69, $08, $00, $00
        dw  0, -12 : db $04, $08, $00, $02
        dw  0,   0 : db $60, $08, $00, $02
        
        dw 10,  -3 : db $67, $08, $00, $00
        dw  0, -12 : db $04, $08, $00, $02
        dw  0,   0 : db $60, $08, $00, $02
    
    ; $72090
        dw -2,   1 : db $68, $08, $00, $00
        dw  0,  -8 : db $C0, $08, $00, $02
        dw  0,   0 : db $C2, $08, $00, $02
        
        dw -3,   1 : db $78, $08, $00, $00
        dw  0,  -8 : db $C0, $08, $00, $02
        dw  0,   0 : db $C2, $08, $00, $02
        
        dw  0,   0 : db $0E, $00, $00, $02
        dw  0,  64 : db $6C, $00, $00, $02
    
    ; $720D0
    .timers
        db 48, 16
    
    ; $720D2
    .oam_pointers
        db $28, $2A, $2C, $2E, $2C
    
    ; $720D7
    .num_oam_entries
        db 3, 3, 3, 3, 3
    
    ; $720DC
        ; \unused ?
        db 2, 2
    
    ; $720DE
        db $20, $40
    
    ; $720E0
        db 16, -16
        
        ; \task Finish naming these sublabels and the routine they belong to.
    }

; ==============================================================================

    ; *$720E2-$72163 LOCAL
    {
        PHX
        
        LDX.b #$06
        
        LDA $00001A : LSR #2 : AND.b #$01 : TAY
        
        ; Alternate the travel bird's graphics for flappage.
        LDA $A0DE, Y : STA $0AF4
        
        LDA $0D50, X : ROL A : ROR A : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD $A0E0, X : LSR A : AND.b #$40
                                              ORA.b #$32 : STA $0F50, X
        
        LDA.b #$02
        LDY.b #$24
        
        JSR $A703 ; $72703 IN ROM
        JSR $AE63 ; $72E63 IN ROM
        
        DEX
        
        LDA.b #$31 : STA $0F50, X
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA $0D90, X : TAY
        
        EOR.b #$01 : STA $0D90, X
        
        LDA $A0D0, X : STA $0DF0, X
        
        LDA $0DC0, X : INC A : AND.b #$03 : STA $0DC0, X
    
    BRANCH_ALPHA:
    
        LDY.b #$26
        LDA.b #$02
        
        JSR $A703 ; $72703 IN ROM
        
        DEX
    
    BRANCH_GAMMA:
    
        LDA $1A : AND.b #$0F : BNE BRANCH_BETA
        
        LDA $0DC0, X : EOR.b #$01 : STA $0DC0, X
    
    BRANCH_BETA:
    
        LDA.b #$31 : STA $0F50, X
        
        LDY $A0D2, X
        LDA $A0D7, X
        
        JSR $A703 ; $72703 IN ROM
        JSR $A5FD ; $725FD IN ROM
        
        DEX : BPL BRANCH_GAMMA
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $72164-$7227B DATA
    {
        ; \task Fill in data later and name routine / pool.
    }

; ==============================================================================

    ; *$7227C-$722F7 LOCAL
    {
        PHX
        
        REP #$20
        
        LDA $C8 : CMP.w #$0200 : BNE BRANCH_ALPHA
        
        LDY.b #$01
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        CMP.w #$0208 : BNE BRANCH_GAMMA
        
        LDY.b #$2C
    
    BRANCH_BETA:
    
        STY $012E
    
    BRANCH_GAMMA:
    
        SUB.w #$0208 : CMP.w #$0030 : SEP #$20 : BCS BRANCH_DELTA
        
        LDY.b #$02
        
        JSR $ACE5 ; $72CE5 IN ROM
    
    BRANCH_DELTA:
    
        LDX.b #$03
        
        REP #$20
        
        LDA $C8 : CMP.w #$0200 : SEP #$20 : BCS BRANCH_EPSILON
        
        LDA.b #$01 : STA $0DC0, X
    
    BRANCH_EPSILON:
    
        LDA.b #$31 : STA $0F50, X
        
        LDA.b #$04
        LDY.b #$08
        
        JSR $A703 ; $72703 IN ROM
        JSR $A5FD ; $725FD IN ROM
        
        LDA $0DC0, X : DEX : STA $0DC0, X : TAY
        
        STZ $0107
        
        LDA $A274, Y : STA $0108
        
        LDA.b #$30 : STA $0F50, X
        
        PHY : TYA : ASL A : TAY
        
        REP #$20
        
        LDA $A276, Y : STA $0100
        
        SEP #$20
        
        PLY
        
        LDA $A27A, Y : TAY
        
        LDA.b #$05
        
        JSR $A703 ; $72703 IN ROM
        JSR $A5FD ; $725FD IN ROM
        
        PLX
        
        RTS
    }

    ; *$72358-$72392 LOCAL
    {
        PHX
        
        LDX.b #$00
        
        REP #$20
        
        LDA $C8 : CMP.w #$0200
        
        SEP #$20 : BNE BRANCH_ALPHA
        
        LDA.b #$FC : STA $0D50, X
    
    BRANCH_ALPHA:
    
        LDA $1A : AND.b #$10 : LSR #4 : STA $0DC0, X
        
        LDA $0D10, X : CMP.b #$38 : BNE BRANCH_BETA
        
        STZ $0D50, X
        
        INC $0DC0, X : INC $0DC0, X
    
    BRANCH_BETA:
    
        LDA.b #$03
        LDY.b #$34
        
        JSR $A703   ; $72703 IN ROM
        JSL Sprite_MoveLong
        
        PLX
        
        RTS
    }

    ; *$72393-$723C6 LOCAL
    {
        PHX
        
        LDX.b #$00
        
        LDA.b #$2C : STA $0E20, X
        
        LDA.b #$2C : JSL OAM_AllocateFromRegionA
        
        LDA.b #$3B : STA $0F50, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA.b #$02
        
        REP #$10
        
        LDY $C8 : CPY.w #$01C0 : SEP #$10 : BCS BRANCH_ALPHA
        
        TYA : AND.b #$20
        
        ASL #3 : ROL A
    
    BRANCH_ALPHA:
    
        STA $0DC0, X
        
        JSL SpriteActive_MainLong
        
        PLX
        
        RTS
    }

    ; *$723C7-$7242C LOCAL
    {
        PHX
        
        LDX.b #$05
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA $0F00, X : BNE BRANCH_ALPHA
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA $06C309, X : ADD $0FD8 : PHA
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA $06C311, X : ADD $0FDA
        
        PLX
        
        LDY.b #$03
        
        JSR $ACE5   ; $72CE5 IN ROM
    
    BRANCH_ALPHA:
    
        LDX.b #$03
    
    BRANCH_GAMMA:
    
        LDA $0E00, X : BEQ BRANCH_BETA
        
        DEC $0E00, X
    
    BRANCH_BETA:
    
        LDA.b #$E3 : STA $0E20, X
        
        LDA.b #$01
        
        JSR $ACA2 ; $72CA2 IN ROM
        JSR $A692 ; $72692 IN ROM
        
        INX : CPX.b #$05 : BNE BRANCH_GAMMA
        
        LDA.b #$72 : STA $0E20, X
        LDA.b #$3B : STA $0F50, X
        LDA.b #$09 : STA $0DD0, X : STA $0DA0, X
        
        LDA.b #$30
        
        JSR $A6B3   ; $726B3 IN ROM
        
        PLX
        
        RTS
    }

    ; *$7254F-$725F7 LOCAL
    {
        PHX
        
        LDX.b #$06
        
        LDA $1A : AND.b #$01 : STA $0DC0, X : BNE BRANCH_ALPHA
        
        LDA.b #$01
        
        LDY $D010, X : CPY.b #$80 : BMI BRANCH_BETA
        
        LDA.b #$FF
    
    BRANCH_BETA:
    
        ADD $0D50, X : STA $0D50, X
        
        LDA.b #$01
        
        LDY $0D00, X : CPY.b #$B0 : BMI BRANCH_GAMMA
        
        LDA.b #$FF
    
    BRANCH_GAMMA:
    
        ADD $0D40, X : STA $0D40, X
        
        JSL Sprite_MoveLong
    
    BRANCH_ALPHA:
    
        LDA $0D50, X : LSR A : AND.b #$40 : EOR.b #$7E : STA $0F50, X
        
        LDA.b #$01 : STA $0E40, X
        LDA.b #$30 : STA $0E60, X
        LDA.b #$10 : STA $0F70, X
        
        JSR $A6B1 ; $726B1 IN ROM
        
        DEX
        
        LDA.b #$37 : STA $0F50, X
        
        LDA.b #$02
        
        JSR $ACA2 ; $72CA2 IN ROM
        
        LDA.b #$0C
        
        JSR $A694 ; $72694 IN ROM
        
        DEX
        
        JSR $A692 ; $72692 IN ROM
        
        DEX
        
        JSR $A692 ; $72692 IN ROM
        
        DEX
    
    BRANCH_KAPPA:
    
        TXA : ASL A : TAY
        
        LDA $A53D, X
        
        JSR $A703 ; $72703 IN ROM
        
        TXA : BNE BRANCH_DELTA
        
        JSR $A643 ; $72643 IN ROM
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LSR A : BEQ BRANCH_ZETA
        
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDY.b #$00
        
        LDA $1A : AND.b #$1F : CMP.b #$0F : BCS BRANCH_IOTA
        
        TAY
        
        LDA $A540, Y : STA $0F70, X
        
        LDY.b #$01
    
    BRANCH_IOTA:
    
        TYA : STA $0DC0, X
        
        JSR $A5F8 ; $725F8 IN ROM
    
    BRANCH_THETA:
    
        DEX : BPL BRANCH_KAPPA
        
        PLX
        
        RTS
    }

    ; *$725F8-$7260C LOCAL
    {
        LDA.b #$30
    
    ; *$725FA ALTERNATE ENTRY POINT
    
        STA $0F50, X
    
    ; *$725FD ALTERNATE ENTRY POINT
    
        LDA.b #$00
        
        JSR $ACA2 ; $72CA2 IN ROM
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionA
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

    ; $7260D-$72642 DATA
    {
        ; \task Name this routine / pool. Fill in data.
    }

; ==============================================================================

    ; *$72643-$72691 LOCAL
    {
        LDA.b #$30
    
    ; *$72645 ALTERNATE ENTRY POINT
    
        JSR $A5FA ; $725FA IN ROM
        
        LDY $0D90, X
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INY : CPY.b #$08 : BNE BRANCH_BETA
        
        LDY.b #$06
    
    BRANCH_BETA:
    
        CPY.b #$16 : BNE BRANCH_GAMMA
        
        LDY.b #$15
    
    BRANCH_GAMMA:
    
        CPY.b #$1C : BNE BRANCH_DELTA
        
        LDY.b #$1B
    
    BRANCH_DELTA:
    
        TYA : STA $0D90, X
        
        LDA $A60C, X : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        LDA $A627, X : BPL BRANCH_EPSILON
        
        LDA $1A : AND.b #$08 : LSR #3
    
    BRANCH_EPSILON:
    
        STA $0DC0, X
        
        CPY.b #$05 : BCC BRANCH_ZETA
        CPY.b #$0A : BCC BRANCH_THETA
        CPY.b #$0F : BCS BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDA $1A : AND.b #$01 : BNE BRANCH_THETA
        
        INC $0D00, X
    
    BRANCH_THETA:
    
        RTS
    }

    ; *$72692-$726B0 LOCAL
    {
        LDA.b #$08
    
    ; *$72694 ALTERNATE ENTRY POINT
    
        STX $0FA0
        
        JSL OAM_AllocateFromRegionA
        JSR Sprite_Get_16_bit_CoordsLong
        
        LDA $11 : PHA
        
        STZ $11
        
        LDA.b #$09 : STA $0DD0, X
        
        JSL SpriteActive_MainLong
        
        PLA : STA $11
        
        RTS
    }

    ; *$726B1-$726C2 LOCAL
    {
        LDA.b #$08
    
    ; *$726B3 ALTERNATE ENTRY POINT
    
        JSL OAM_AllocateFromRegionA
        
        STX $0FA0
        
        JSL Sprite_Get_16_bit_CoordsLong
        JSL SpriteActive_MainLong
        
        RTS
    }

; ==============================================================================

    ; $726C3-$72702 DATA
    {
        dw $A42D
        dw $A48D
        dw $A4BD
        dw $A79A
        dw $A164
        dw $A1A4
        dw $A995
        dw $A194
        
        ; 0x10
        dw $AA73
        dw $AA53
        dw $ACAB
        dw $9E48
        dw $AB45
        dw $A1F4
        dw $ADB7
        dw $9DF0
        
        ; 0x20
        dw $9E20
        dw $9E38
        dw $A0C0
        dw $A020
        dw $9FC0
        dw $9FF0
        dw $A060
        dw $A090
        
        ; 0x30
        dw $9EE1
        dw $9F01
        dw $A2F8
        dw $A888
        dw $A8E5
        dw $A925
        dw $9F21
        dw $A7FA
    }

; ==============================================================================

    ; *$72703-$7273C LOCAL
    {
        ; \param A number of oam entries to allocate for and to draw.
        ; \param Y Index into above pointer table to use for drawing oam
        ; entries.
        
        PHA : PHY
        
        PHA : ASL #2 : JSL OAM_AllocateFromRegionA
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        PLA : STA $4202
        
        LDA.b #$08 : STA $4203
        
        ; \optimize Are they seriously using the multiplication registers to
        ; multiply by 8? Rather than just shifting left three times in 16-bit
        ; mode...
        NOP #4
        
        LDA $4216 : STA $4202
        
        ; This part I can understand as it's variable, potentially.
        LDA $0DC0, X : STA $4203
        
        REP #$20
        
        PLY
        
        LDA $A6C3, Y : ADD $4216, Y : STA $08
        
        SEP #$20
        
        PHA
        
        JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================

    ; *$7274C-$72799 LOCAL
    {
        PHX
        
        TXA : LSR A : TAX
        
        LDA $9C0A, X : TAX
    
    BRANCH_GAMMA:
    
        STX $0FA0
        
        LDA $A73D, X : STA $0E20, X
        
        LDA $A740, X : JSL OAM_AllocateFromRegionA
        
        LDA $A743, X : STA $0D80, X
        
        TXY
        
        REP #$20
        
        LDA $C8 : CMP.w #$026F : BNE BRANCH_ALPHA
        
        PHY
        
        LDY.b #$21 : STY $012F ; SOUND EFFECT BEING PLAYED
        
        PLY
    
    BRANCH_ALPHA:
    
        SEP #$20 : BCC BRANCH_BETA
        
        INY #3
    
    BRANCH_BETA:
    
        LDA $A746, Y : STA $0DC0, X
        
        LDA.b #$33 : STA $0F50, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        JSL SpriteActive_MainLong
        
        DEX : BPL BRANCH_GAMMA
        
        PLX
        
        RTS
    }

    ; *$72802-$72887 LOCAL
    {
        PHX
        
        LDX.b #$00
        
        REP #$20
        
        LDA $C8 : CMP.w #$0170 : SEP #$20 : BCC BRANCH_ALPHA
        
        LDX.b #$04
    
    BRANCH_BETA:
    
        LDA.b #$01
        LDY.b #$3E
        
        JSR $A703 ; $72703 IN ROM
        
        INX : CPX.b #$06 : BNE BRANCH_BETA
        
        LDX.b #$00
        
        LDA.b #$39 : STA $0F50, X
        
        REP #$20
        
        LDA $C8 : CMP.w #$01C0 : SEP #$20 : BCS BRANCH_GAMMA
        
        LDA.b #$02
        
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA $0DF0, X : BNE BRANCH_EPSILON
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA $0DC0, X : EOR.b #$01 : AND.b #$01
    
    BRANCH_DELTA:
    
        STA $0DC0, X
    
    BRANCH_EPSILON:
    
        LDA.b #$04
        LDY.b #$06
        
        JSR $A703 ; $72703 IN ROM
        
        PLX
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA $1A : STA $0E20, X
        
        LDA.b #$39 : STA $0F50, X
        
        LDA.b #$02
        
        JSR $ACA2 ; $72CA2 IN ROM
        
        LDA $10 : PHA
        
        LDA.b #$0C
        
        JSR $A694 ; $72694 IN ROM
        
        PLA : STA $10
        
        LDA $0DA0, X : CMP.b #$0F : BNE BRANCH_ZETA
        
        LDA $0D90, X : CMP.b #$04 : BNE BRANCH_ZETA
        
        LDA.b #$0F : STA $0DF2, X
    
    BRANCH_ZETA:
    
        JSR $A8C8 ; $728C8 IN ROM
        
        INX : CPX.b #$02 : BNE BRANCH_THETA
        
        PLX
        
        RTS
    }

    ; *$728C8-$728E4 LOCAL
    {
        PHX
        
        INX #2
        
        LDA $0DF0, X
        
        BEQ BRANCH_ALPHA
        
        TAY
        
        LDA.b #$02 : STA $0F50, X
        
        LDA $A8B8, Y : STA $0DC0, X
        
        LDA.b #$02
        LDY.b #$36
        
        JSR $A703 ; $72703 IN ROM
    
    BRANCH_ALPHA:
    
        PLX
        
        RTS
    }

    ; *$72941-$72994 LOCAL
    {
        PHX
        
        LDX.b #$00
    
    BRANCH_GAMMA:
    
        CPX.b #$02
        
        BCS BRANCH_ALPHA
        
        LDA.b #$01 : STA $0E20, X
        LDA.b #$0B : STA $0F50, X
        
        LDA.b #$02
        
        JSR $ACA2 ; $72CA2 IN ROM
        
        LDA.b #$30 : STA $0F70, X
        
        LDA $1A : ADD $A95F, X : LSR #2 : AND.b #$03 : TAY
        
        LDA $A93D, Y : STA $0DC0, X
        
        JSR $AE63 ; $72E63 IN ROM
        
        LDA.b #$0C
        
        JSR $A6B3 ; $726B3 IN ROM
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA.b #$10
        
        JSR $A6B3 ; $726B3 IN ROM
    
    BRANCH_BETA:
    
        INX : CPX.b #$05
        
        BCC BRANCH_GAMMA
        
        LDA.b #$02
        LDY.b #$38
        
        JSR $A703 ; $72703 IN ROM
        JSR $A643 ; $72643 IN ROM
        
        INX
        
        LDA.b #$03
        LDY.b #$3A
        
        JSR $A703 ; $72703 IN ROM
        
        PLX
        
        RTS
    }

    ; *$729AD-$729D0 LONG
    {
        PHX
        
        LDX.b #$00
        LDY.b #$0C
        LDA.b #$03
        
        JSR $A703 ; $72703 IN ROM
        JSR $A5F8 ; $725F8 IN ROM
        
        INX
        
        ; Put the Priest in the ending sanctuary
        LDA.b #$73 : STA $0E20, X
        LDA.b #$27 : STA $0F50, X
        LDA.b #$02 : STA $0E90, X
        
        LDA.b #$10
        
        JSR $A6B3 ; $726B3 IN ROM ; Keep sprites alive?
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $729D1-$729D2 DATA
    {
    
    .animation_step_amounts
        db  1, -1
    }

; ==============================================================================

    ; *$729D3-$72A52 LOCAL
    {
        PHX
        
        LDX.b #$01
        LDA.b #$02
        
        JSR $ACA2 ; $72CA2 IN ROM
        
        LDA.b #$E9 : STA $0E20, X
        
        LDA.b #$0C : JSL OAM_AllocateFromRegionA
        
        LDA.b #$37 : STA $0F50, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA $1A : AND.b #$0F : BNE BRANCH_ALPHA
        
        LDA $0DC0, X : EOR.b #$01 : STA $0DC0, X
    
    BRANCH_ALPHA:
    
        JSL SpriteActive_MainLong
        
        REP #$20
        
        LDA $C8 : CMP.w #$0180 : SEP #$20 : BCC BRANCH_BETA
        
        LDA.b #$04 : STA $0D40, X
        
        LDA $0D00, X : CMP.b #$7C : BEQ BRANCH_BETA
        
        JSL Sprite_MoveLong
    
    BRANCH_BETA:
    
        DEX
        
        LDA.b #$36 : STA $0E20, X
        
        LDA.b #$18 : JSL OAM_AllocateFromRegionA
        
        LDA.b #$39 : STA $0F50, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA $0DF0, X : BNE BRANCH_GAMMA
        
        LDA.b #$04 : STA $0DF0, X
        
        LDA $C9 : LSR A : AND.b #$01 : TAY
        
        LDA $0DC0, X : ADD .animation_step_amounts, Y
                       AND.b #$07
                       STA $0DC0, X
    
    BRANCH_GAMMA:
    
        JSL SpriteActive_MainLong
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $72A53-$72A90 DATA
    {
        ; \task Data seems unused for the moment... except for:
    
    .oam_groups
        dw -16, -24 : db $04, $37, $00, $02
        dw -16, -16 : db $64, $37, $00, $02
        dw -16, -24 : db $62, $37, $00, $02
        dw -16, -16 : db $64, $37, $00, $02
        dw   0, -19 : db $AF, $39, $00, $00
    
    ; $72A7B
        db 1, -1
        
    ; $72A7D
        ; up to the end maybe?
        ; \task Fill in this data and label it.
    }

; ==============================================================================

    ; *$72A91-$72B44 LOCAL
    {
        PHX
        
        LDX.b #$00
    
    BRANCH_DELTA:
    
        LDA $0DF0, X : BNE .delay
        
        ; \bug
        ; This seems like.... a mistake.
        ; Writing 0x60 into $0DD0 could possibly cause a crash.
        LDA.b #$60 : STA $0DF0, X
                     STA $0DD0, X
        
        STZ $0D50, X
        
        LDA.b #$EE : STA $0D10, X
        LDA.b #$04 : STA $0D30, X
        
        LDA.b #$18 : STA $0D00, X
        LDA.b #$0B : STA $0D20, X
    
    .delay
    
        LDA $0DD0, X : BEQ BRANCH_BETA
        
        LDA.b #$F8 : STA $0D40, X
        
        JSL Sprite_MoveLong
        
        LDA $1A : LSR A : BCS BRANCH_GAMMA
        
        STX $00
        
        LDA $1A : LSR #5 : EOR $00 : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD.b #$7B : TAX : STA $0D50, X
    
    BRANCH_GAMMA:
    
        LDY.b #$10
        LDA.b #$01
        
        JSR $A703 ; $62703 IN ROM
    
    BRANCH_BETA:
    
        INX : CPX.b #$05 : BCC BRANCH_DELTA
    
    BRANCH_IOTA:
    
        LDY $0D90, X
        
        LDA $0DF0, X : BNE BRANCH_EPSILON
        
        LDA $AA7D, Y : CPX.b #$05 : BEQ BRANCH_ZETA
        
        LDA $AA81, Y
    
    BRANCH_ZETA:
    
        STA $0DF0, X
        
        TYA : INC A : AND.b #$03 : STA $0D90, X
        
        LDA $0DC0, X : EOR.b #$01 : STA $0DC0, X
    
    BRANCH_EPSILON:
    
        CPX.b #$05 : BNE BRANCH_THETA
        
        LDA.b #$31 : STA $0F50, X
        
        LDA.b #$10
        
        JSR $A6B3 ; $726B3 IN ROM
        
        INX
        
        BRA BRANCH_IOTA
    
    BRANCH_THETA:
    
        LDX.b #$12
        LDA.b #$02
        
        JSR $A703 ; $72703 IN ROM
        
        INX
    
    BRANCH_KAPPA:
    
        LDA $AA82, X : STA $0F50, X
        LDA $AA86, X : STA $0DE0, X
        
        LDA $AA7E, X
        
        JSR $A694   ; $72694 IN ROM
        
        INX : CPX.b #$0B : BCC BRANCH_KAPPA
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $72B45-$72BF4 DATA
    {
    
    .oam_groups
        dw  0, -7 : db $00, $0D, $00, $02
        dw  0, -7 : db $00, $0D, $00, $02
        dw  0,  0 : db $06, $0D, $00, $02
        
        dw  0, -7 : db $00, $0D, $00, $02
        dw  0, -7 : db $00, $0D, $00, $02
        dw  0,  0 : db $06, $4D, $00, $02
        
        dw  0, -8 : db $00, $0D, $00, $02
        dw  0, -8 : db $00, $0D, $00, $02
        dw  0,  0 : db $20, $0D, $00, $02
        
        dw  0, -8 : db $02, $0D, $00, $02
        dw  0, -8 : db $02, $0D, $00, $02
        dw  0,  0 : db $2C, $0D, $00, $02
        
        dw -3,  0 : db $2F, $0D, $00, $00
        dw  0, -7 : db $02, $0D, $00, $02
        dw  0,  0 : db $2C, $0D, $00, $02
        
        dw -5,  2 : db $2F, $0D, $00, $00
        dw  0, -8 : db $02, $0D, $00, $02
        dw  0,  0 : db $2C, $0D, $00, $02
        
        dw -5,  2 : db $3F, $0D, $00, $00
        dw  0, -8 : db $02, $0D, $00, $02
        dw  0,  0 : db $2C, $0D, $00, $02
    
    ; $72BEC
    
        ; \unused \task Find out if really unused.
        db $00, $01, $00, $02, $08, $20, $20, $08    
    }

; ==============================================================================

    ; *$72BF5-$72CA1 LOCAL
    {
        PHX
        
        LDX.b #$06
    
    ; *$72BF8 ALTERNATE ENTRY POINT
    
        CPX.b #$05 : BCC BRANCH_ALPHA
        
        LDA.b #$00 : STA $0E20, X
        
        LDA.b #$01
        
        JSR $ACA2 ; $72CA2 IN ROM
        
        LDA $1A : ADD $AC09, X : AND.b #$08 : LSR #3 : STA $0DC0, X
        
        LDA.b #$20 : STA $0F70, X
        
        JSR $AE63 ; $72E63 IN ROM
        
        LDA $0D50, X : LSR A : AND.b #$40 : EOR.b #$0F : STA $0F50, X
        
        LDA.b #$08
        
        JSR $A6B3 ; $726B3 IN ROM
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA.b #$0D : STA $0E20, X
        
        CPX.b #$01 : BNE BRANCH_GAMMA
        
        STA $0EB0, X
    
    BRANCH_GAMMA:
    
        LDA.b #$03
        
        JSR $ACA2   ; $72CA2 IN ROM
        
        LDA.b #$2B : STA $0F50, X
        
        LDA $0DF0, X : BNE BRANCH_DELTA
        
        LDA.b #$C0 : STA $0DF0, X
    
    BRANCH_DELTA:
    
        LSR A : BNE BRANCH_EPSILON
        
        STA $0D40, X
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        CMP $ABF0, X : BCS BRANCH_THETA
        
        LDA $1A : AND.b #$03 : BNE BRANCH_THETA
        
        LDA $0D40, X : BEQ BRANCH_THETA
        
        DEC A : STA $0D40, X
        
        ADD.b #$FC
        
        CPX.b #$03 : BCS BRANCH_ZETA
        
        EOR.b #$FF : INC A
    
    BRANCH_ZETA:
    
        STA $0D50, X
    
    BRANCH_THETA:
    
        JSL Sprite_MoveLong
        
        LDA $1A : LSR #3 : AND.b #$03 : TAY
        
        LDA $ABED, Y : STA $0DC0, X
        
        LDA.b #$10
        
        JSR $A6B3   ; $726B3 IN ROM
    
    BRANCH_BETA:
    
        DEX : BEQ BRANCH_IOTA
        
        JMP $ABF8   ; $72BF8 IN ROM
    
    BRANCH_IOTA:
    
        LDY.b #$18
        LDA.b #$03
        
        JSR $A703   ; $72703 IN ROM
        
        LDA.b #$20
        
        JSR $A645   ; $72645 IN ROM
        
        PLX
        
        RTS
    }

    ; *$72CA2-$72CAA LOCAL
    {
        STA $0E40, X
        
        LDA.b #$10 : STA $0E60, X
        
        RTS
    }

    ; *$72CE5-$72D21 LOCAL
    {
        STX $00
        STA $02
        STY $0DB0
        
        LDX.b #$00
    
    BRANCH_DELTA:
    
        LDY $0DC0, X
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INY : CPY.b #$06 : BCC BRANCH_BETA
        
        LDA $00 : STA $0D10, X
        LDA $02 : STA $0D00, X
        
        LDY.b #$00
    
    BRANCH_BETA:
    
        TYA : STA $0DC0, X
        
        LDA $ACD7, Y : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        TYA : BEQ BRANCH_GAMMA
        
        LDY.b #$1C
        LDA.b #$01
        
        JSR $A703   ; $72703 IN ROM
    
    BRANCH_GAMMA:
    
        INX : CPX $0DB0 : BCC BRANCH_DELTA
        
        RTS
    }

    ; *$72D22-$72DBE LOCAL
    {
        PHX
        
        LDY $1A
        
        LDA $AD25, Y : AND.b #$03 : TAY
        
        LDX $ACDD, Y
        
        LDA $E1B9, Y
        
        LDY $02A0
        
        JSR $ACE5   ; $72CE5 IN ROM
        
        LDA.b #$62 : STA $0E20, X
        LDA.b #$39 : STA $0F50, X
        
        LDA.b #$18
        
        JSR $A6B3 ; $726B3 IN ROM
        
        LDY.b #$01
    
    BRANCH_ZETA:
    
        INX
        
        LDA $0E00, X : 	BEQ BRANCH_ALPHA
        
        DEC $0E00, X
    
    BRANCH_ALPHA:
    
        LDA $0D50, X : LSR A : AND.b #$40 : EOR $ACCB, Y : STA $0F50, X
        
        LDA $0DF0, X : BNE BRANCH_BETA
        
        LDA.b #$80 : STA $0DF0, X
        
        STZ $0D90, X
    
    BRANCH_BETA:
    
        LDA $0D90, X : BNE BRANCH_GAMMA
        
        LDA $1A : LSR #2 : AND.b #$01 : INC #2 : STA $0DC0, X
        
        PHY
        
        JSR $AE35   ; $72E35 IN ROM
        
        PLY
        
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA $0E00, X : BNE BRANCH_DELTA
        
        LDA $0DA0, X : CMP.b #$08 : BNE BRANCH_EPSILON
        
        STZ $0DA0, X
    
    BRANCH_EPSILON:
    
        PHY
        
        LDA $0DA0, X : AND.b #$07 : TAY
        
        LDA $AFCF, Y : STA $0E00, X
        
        PLY
        
        LDA $0DC0, X : AND.b #$01 : EOR.b #$01 : STA $0DC0, X
        
        INC $0DA0, X
    
    BRANCH_DELTA:
    
        PHY
        
        LDA.b #$01
        LDY.b #$14
        
        JSR $A703   ; $72703 IN ROM
        JSR $A5FD   ; $725FD IN ROM
        
        PLY : DEY : BPL BRANCH_ZETA
        
        INX
        
        JSR $ADF7   ; $72DF7 IN ROM
        
        PLX
        
        RTS
    }

    ; *$72DF7-$72E2C LOCAL
    {
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        LDA $0DC0, X : INC A : AND.b #$07 : STA $0DC0, X
        
        LDA.b #$04 : STA $0DF0, X
    
    BRANCH_ALPHA:
    
        LDA $0DC0, X : ASL A : TAY
        
        REP #$20
        
        LDA $ADE7, Y : STA $0100
        
        SEP #$20
        
        LDA.b #$20 : STA $0F50, X
        
        LDA.b #$02
        LDY.b #$1A
        
        JSR $A703   ; $72703 IN ROM
        JSR $A5FD   ; $725FD IN ROM
        JSL Sprite_MoveLong
        
        RTS
    }

; ==============================================================================

    ; $72E2D-$72E34 DATA
    {
    
    .x_speeds
        db  32,  24, -32, -24
    
    .y_speeds
        db   8,  -8,  -8,   8
    }

; ==============================================================================

    ; *$72E35-$72E5C LOCAL
    {
        LDA $0DF0, X : CMP.b #$40 : BCS .delay
        
        LDA $0DB0, X : INC A : AND.b #$03 : STA $0DB0, X
        
        INC $0D90, X
        
        RTS
    
    .delay
    
        LDY $0DB0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSL Sprite_MoveLong
        
        RTS
    }

; ==============================================================================

    ; $72E5D-$72E62 DATA
    {
    
    .acceleration
        db 1, -1
    
    .x_speed_limits
        db 32, -32
    
    .y_speed_limits
        db 16, -16
    }

; ==============================================================================

    ; *$72E63-$72E9D LOCAL
    {
        LDA $0DE0, X : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD .acceleration, X : STA $0D50, X
        
        CMP .x_speed_limits, Y : BNE .anotoggle_x_acceleration
        
        INC $0DE0, X
    
    .anotoggle_x_direction
    
        LDA $1A : AND.b #$01 : BNE .delay
        
        LDA $0EB0, X : AND.b #$01 : TAY
        
        LDA $0D40, X : ADD .acceleration, X : STA $0D40, X
        
        CMP y_speed_limits, Y : BNE .anotoggle_y_acceleration
        
        INC $0EB0, X

    .anotoggle_y_acceleration
    .delay

        JSL Sprite_MoveLong
        
        RTS
    }

; ==============================================================================

    ; $72E9E-$72EA5 DATA
    {
    
    .flags
        dw $0008, $0004, $0002, $0001
    }

; ==============================================================================

    ; *$72EA6-$72FF1 LONG
    {
        PHB : PHK : PLB
        
        REP #$20
        
        LDA.w #$0001 : STA $00
        
        LDA $30 : AND.w #$00FF : BNE BRANCH_ALPHA
        
        JMP $AF1E   ; $72F1E IN ROM
    
    BRANCH_ALPHA:
    
        CMP.w #$0080 : BCC BRANCH_BETA
        
        EOR.w #$00FF : INC A
        
        DEC $00 : DEC $00
        
        STA $02
        
        LDY.b #$00
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        STA $02
        
        LDY.b #$02
    
    BRANCH_GAMMA:
    
        LDX.b #$06
        
        JSR $AFF2   ; $72FF2 IN ROM
        
        LDA $04 : STA $069E
        
        LDX $8C : CPX.b #$97 : BEQ BRANCH_DELTA
        
        CPX.b #$9D : BEQ BRANCH_DELTA
        
        LDA $04 : BEQ BRANCH_DELTA
        
        STZ $00
        
        LSR A : ROR $00
        
        LDX $8C
        
        CPX.b #$B5 : BEQ BRANCH_EPSILON
        CPX.b #$BE : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        LSR A : ROR $00
        
        CMP.w #$3000 : BCC BRANCH_IOTA
        
        ORA.w #$F000
        
        BRA BRANCH_IOTA
    
    BRANCH_ZETA:
    
        CMP.w #$7000 : BCC BRANCH_IOTA
        
        ORA.w #$F000
    
    BRANCH_IOTA:
    
        STA $06
        
        LDA $0622 : ADD $00 : STA $0622
        
        LDA $E6 : ADC $06 : STA $E6
    
    ; *$72F1E ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        LDA.w #$0001 : STA $00
        
        LDA $31 : AND.w #$00FF : BNE BRANCH_THETA
        
        JMP $AF91   ; $72F91 IN ROM
    
    BRANCH_THETA:
    
        CMP.w #$0080 : BCC BRANCH_KAPPA
        
        EOR.w #$00FF : INC A
        
        DEC $00 : DEC $00
        
        STA $02
        
        LDY.b #$04
        
        BRA BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        STA $02
        
        LDY.b #$06
    
    BRANCH_LAMBDA:
    
        LDX.b #$00
        
        JSR $AFF2   ; $72FF2 IN ROM
        
        LDA $04 : STA $069F
        
        LDX $8C
        
        CPX.b #$97 : BEQ BRANCH_MUNU
        CPX.b #$9D : BEQ BRANCH_MUNU
        
        LDA $04 : BEQ BRANCH_MUNU
        
        STZ $00
        
        LSR A : ROR $00
        
        LDX $8C
        
        CPX.b #$95 : BEQ BRANCH_XI
        CPX.b #$9E : BNE BRANCH_OMICRON
    
    BRANCH_XI:
    
        LSR A : ROR $00
        
        CMP.w #$3000 : BCC BRANCH_PI
        
        ORA.w #$F000
        
        BRA BRANCH_PI
    
    BRANCH_OMICRON:
    
        CMP.w #$7000 : BCC BRANCH_PI
        
        ORA.w #$F000
    
    BRANCH_PI:
    
        STA $06
        
        LDA $0620 : ADD $00 : STA $0620
        LDA $E0   : ADC $06 : STA $E0
    
    ; *$72F91 ALTERNATE ENTRY POINT
    BRANCH_MUNU:
    
        LDX $8C
        
        CPX.b #$9C : BEQ BRANCH_RHO
        CPX.b #$97 : BEQ BRANCH_SIGMA
        CPX.b #$9D : BNE BRANCH_TAU
    
    BRANCH_SIGMA:
    
        LDA $0622 : ADD.w #$2000 : STA $0622
        LDA $E6   : ADC.w #$0000 : STA $E6
        LDA $0620 : ADD.w #$2000 : STA $0620
        LDA $E0   : ADC.w #$0000 : STA $E0
        
        BRA BRANCH_TAU
    
    BRANCH_RHO:
    
        LDA $0622 : SUB.w #$2000 : STA $0622
        
        LDA $E6 : SUB.w #$0000 : ADD $069E : STA $E6
        LDA $E2                              : STA $E0
    
    BRANCH_TAU:
    
        LDA $A0 : CMP.w #$0181 : BNE BRANCH_UPSILON
        
        LDA $E8 : ORA.w #$0100 : STA $E6
        LDA $E2                : STA $E0
    
    BRANCH_UPSILON:
    
        SEP #$20
        
        PLB
        
        RTL
    }

    ; *$72FF2-$73037 LOCAL
    {
        STZ $04
        STZ $06
    
    BRANCH_ALPHA:
    
        LDA $E2, X : ADD $00 : STA $E2, X
        
        INC $06
        
        LDA $04 : ADD $00 : STA $04
        
        DEC $02 : BNE BRANCH_ALPHA
        
        TYA : ORA.w #$0002 : TAX
        
        LDA $0624, Y : ADD $06 : STA $0624, Y
        
        CMP.w #$0010 : BMI BRANCH_BETA
        
        SUB.w #$0010 : STA $0624, Y
        
        LDA .flags, Y : ORA $0416 : STA $0416
    
    BRANCH_BETA:
    
        LDA.w #$0000 : SUB $0624, Y : STA $0624, X
        
        RTS
    }

; ==============================================================================

    ; $73038-$73C6C DATA
    {
        ; \task Data needs to be filled in or supplied with a binary file,
        ; etc. Seems to be text data for the credits sequence?
    }

; ==============================================================================

    ; *$73C6D-$73D4D LOCAL
    {
        JSL EnableForceBlank          ; $93D in ROM. Set up the screen values, resets HDMA, etc.
        JSL Vram_EraseTilemaps_normal ; $8333 in rom
        JSL CopyFontToVram            ; $6556 in rom
        JSL $0286C0 ; $106C0 IN ROM
        JSL $0CCA81 ; $64A81 IN ROM
        
        ; Force blank the screen
        LDA.b #$80 : STA $13
        
        LDA.b #$02 : STA $0AA9
        
        ; Load a couple of palettes
        LDA.b #$01 : STA $0AB2
        
        JSL Palette_Hud ; $DEE52 IN ROM
        
        ; note that cgram should be updated for the next frame
        INC $15
        
        REP #$20
        
        LDA.w #$0000 : STA $7EF3EF
        
        ; The counter for the number of times you�ve saved/died.
        LDA $7EF403 : ADD $7EF401 : STA $7EF401
        
        LDX.b #$18

    BRANCH_ALPHA:

        ; Read values up to $7EF3FF (WORD)
        ; Cycle through all the dungeons
        ADD $7EF3E7, X : STA $7EF405
        
        DEX #2 : BPL BRANCH_ALPHA
        
        ; Zero out the overall life counter.
        LDA.w #$0000 : STA $7EF403
        
        SEP #$20
        
        ; Find our max health and divide by 8.
        ; Gives us how many heart containers we have. 
        ; (Each heart container counts for 8 health)
        LDA $7EF36C : LSR #3 : TAX
        
        ; This is the table of how many hearts to give when you start up.
        LDA $09F4AC, X : STA $7EF36D
        
        ; Puts us in the Dark World.
        LDA.b #$40 : STA $7EF3CA
        
        JSL Main_SaveGameFile
        
        REP #$20
        
        LDA.w #$0000 : STA $7EC34C : STA $7EC54D
        LDA.w #$0000 : STA $7EC300 : STA $7EC500

        LDA.w #$0016 : STA $1C
        LDA.w #$6800 : STA $C8
        
        STZ $CA
        STZ $CC
        
        LDA.w #$FFB8 : STA $E8
        LDA.w #$0090 : STA $E2
        
        STZ $EA
        STZ $E4
        
        JSR $BE24   ; $73E24 IN ROM
        
        SEP #$20
        
        LDA.b #$22 : STA $012C
        
        STZ $99
        
        LDA.b #$A2 : STA $9A
        
        LDA.b #$12 : STA $2108
        
        LDA.b #$3F : STA $9C
        LDA.b #$5F : STA $9D
        LDA.b #$9F : STA $9E
        LDA.b #$40 : STA $B0
        
        STZ $13
        
        LDX.b #$04
    
    BRANCH_BETA:
    
        LDA $0EBD4E, X : STA $4370, X
        
        DEX : BPL BRANCH_BETA
        
        STZ $4377
        
        LDA.b #$80 : STA $9B
        
        BRL BRANCH_$73DEB
    }

    ; $73D4E-$73D65 DATA
    {
        db $42     ; -> DMAP7
        db $0F     ; -> BBAD7
        dl $0EBD53 ; -> A1T7 and A1B7
    
    .table
    
        db $52
        dw $0600
        
        db $08
        dw $00E2
        
        db $08
        dw $0602
        
        db $05
        dw $0604
        
        db $10
        dw $0606
        
        db $81
        db $00E2
        
        db $00
    }


    ; *$73D66-$73D8A LOCAL
    {
        ; Gradually neutralizes color addition / subtraction to neutral
        
        DEC $B0 : BNE BRANCH_ALPHA
        
        LDA.b #$10 : STA $B0
        
        LDA $9C : CMP.b #$20 : BEQ BRANCH_BETA
        
        DEC $9C
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        LDA $9D : CMP.b #$40 : BEQ BRANCH_GAMMA
        
        DEC $9D
        
        BRA BRANCH_ALPHA
    
    BRANCH_GAMMA:
    
        LDA $9E : CMP.b #$80 : BEQ BRANCH_ALPHA
        
        DEC $9E
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$73D8B-$73E03 LOCAL
    {
        ; Gradually neutralize color add/sub
        JSR $BD66 ; $73D66 IN ROM
        
        LDA.b #$01 : STA $0710
        
        SEP #$30
        
        ; Presumably something to do with the 3D triforce
        JSL $0CCBA2 ; $64BA2 IN ROM
        
        REP #$30
        
        LDA $1A : AND.w #$0003 : BNE .return
        
        ; Advance the scenery background to the right 1 pixel
        INC $E2
        
        LDA $E2 : CMP.w #$0C00 : BNE .noTilemapAdjust
        
        ; Adjust the tilemap size and locations of BG1 and BG2... not entirely clear yet as to why
        LDY.w #$1300 : STY $2107
    
    .noTilemapAdjust
    
        ; $0604 = BG2HOFS / 2, $0600 = BG2HOFS * 3 / 2, $0602 = BG2HOFS * 3 / 4
        LSR A : STA $0604 : ADD $E2 : STA $0600 : LSR A : STA $0602
        
        ; $0606 = BG2HOFS / 4
        LDA $0604 : LSR A : STA $0606
        
        LDA $EA : CMP.w #$0CD8 : BNE .notDoneWithSubmodule
        
        LDA.w #$0080 : STA $C8
        
        INC $11
        
        BRA .return
    
    .notDoneWithSubmodule
    
        ; Scroll the credit list up one pixel
        ADD.w #$0001 : STA $EA : TAY : AND.w #$0007
        
        BNE .return
        
        TYA : LSR #3 : STA $CA
        
        JSR $BE24 ; $73E24 IN ROM
    
    ; *$73DEB LONG BRANCH LOCATION
    .return
    
        REP #$20
        
        LDA $E2 : STA $011E
        LDA $E8 : STA $0122
        
        LDA $E0 : STA $0120
        LDA $E6 : STA $0124
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $73E04-$73E23 DATA
    {
    
    .unknown_0
        dw $3CE6, $3CF6
    
    .death_count_offsets
        dw  2,  0,  4,  6, 20, 12, 10, 16
        db 22, 18, 14, 24, 26, 30
    }

; ==============================================================================

    ; *$73E24-$73F4B LOCAL
    {
        PHB : PHK : PLB
        
        REP #$30
        
        LDX $1000
        
        LDA $C8 : XBA : STA $1002, X
        
        LDA.w #$3E40 : STA $1004, X
        
        ; load the value for a transparent tile on BG3
        LDA $B176 : STA $1006, X
        
        TXA : ADD.w #$0006 : TAX
        
        LDA $CA : ASL A : TAY
        
        ; 0x0314 is the overall height of the credit screen in groups of 16 pixels
        CPY.w #$0314 : BCC .notAtEnd
        
        BRL BRANCH_EPSILON
    
    .notAtEnd
    
        ; Gives us an idea of what row of tiles to look at.
        LDA $B93D, Y : TAY
        
        ; basically a tab in terms of tiles
        ; If it's ...1, that means it's a blank line.
        LDA $B178, Y : AND.w #$00FF : CMP.w #$00FF : BEQ BRANCH_BETA
        
        ADD $C8 : XBA : STA $1002, X
        
        INY : LDA $B178, Y : AND.w #$00FF : XBA : STA $1004, X
        
        ; This gives us the number of tiles to grab after this byte.
        XBA : INC A : LSR A : STA $02
        
        INY : STY $00
    
    .nextTile
    
        LDY $00
        
        ; Grab the next tile of text
        LDA $B178, Y : AND.w #$00FF : ASL A : TAY
        
        ; Here we're loading the actual tile indices for the letters
        LDA $B038, Y : STA $1006, X
        
        INC $00
        
        INX #2
        
        ; count down until we run out of tiles to grab.
        DEC $02 : BNE .nextTile
        
        INX #4
    
    BRANCH_BETA:
    
        LDA $CC : AND.w #$0001 : TAY : BNE BRANCH_DELTA
        
        LDA $CC : AND.w #$00FE : TAY
        
        LDA $CA : ASL A : CMP $BC51, Y : BNE BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        TYA : AND.w #$0001 : ASL A : TAY
        
        LDA .uknown_0, Y : STA $CE
        
        LDA $C8 : ADD.w #$0019 : XBA : STA $1002, X
        
        LDA.w #$0500 : STA $1004, X
        
        PHX
        
        LDA $CC : LSR A : ASL A : TAX
        
        LDA .death_count_offsets, X : TAX
        
        LDA $7EF3E7, X
        
        PLX
        
        CMP.w #$03E8 : BCC .lessThanThousand
        
        LDA.w #$0009 : ADD $CE : STA $1006, X : STA $1008, X : STA $100A, X
        
        BRA BRANCH_THETA
    
    .lessThanThousand
    
        LDY.w #$0000
    
    BRANCH_KAPPA:
    
        CMP.w #$000A : BMI BRANCH_IOTA
        
        SUB.w #$000A
        
        INY
        
        BRA BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        ADD $CE : STA $100A, X
        
        TYA
        
        LDY.w #$0000
    
    BRANCH_MU:
    
        CMP.w #$000A : BMI BRANCH_LAMBDA
        
        SUB.w #$000A
        
        INY
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA:
    
        ADD $CE : STA $1008, X
        
        TYA : ADD $CE : STA $1006, X
    
    BRANCH_THETA:
    
        INC $CC
        
        TXA : ADD.w #$000A : TAX
    
    BRANCH_EPSILON:
    
        STX $1000
        
        LDA $C8 : ADD.w #$0020 : TAY : AND.w #$03FF : BNE BRANCH_NU
        
        LDA $C8 : AND.w #$6800 : EOR.w #$0800 : TAY
    
    BRANCH_NU:
    
        STY $C8
        
        SEP #$30
        
        LDA.b #$FF : STA $1002, X
        
        LDA.b #$01 : STA $14
        
        PLB
        
        RTS
    }

; ==============================================================================

    ; $73F4C-$74302 DATA
    {
    
    ; $73F4C
    
        ; fill in data later or with binary file.
    
    ; $742E1
    
    ; $742E3
    
    }

; ==============================================================================

    ; *$74303-$7437B LOCAL
    {
        ; Does this draw the tag lines for the ending sequence?
        ; (The text)
        PHB : PHK : PLB
        
        REP #$30
        
        LDA.w #$0060 : STA $1002
        LDA.w #$FE47 : STA $1004
        
        ; $73176 THAT IS; = 0x3CA9
        LDA $B176 : STA $1006
        
        ; Take $11, round to the nearest lowest even integer
        LDA $11 : AND.w #$00FE : TAY
        
        LDA $C2E3, Y : STA $04
        
        LDA $C2E1, Y : TAY
        
        LDX.w #$0000
    
    BRANCH_BETA:
    
        ; $73F4C, Y THAT IS
        LDA $BF4C, Y : STA $1008, X
        
        INY #2
        INX #2
        
        ; $73F4C, Y THAT IS
        LDA $BF4C, Y : STA $1008, X
        
        XBA : AND.w #$00FF : LSR A : STA $00
        
        INY #2
        INX #2
        
        STY $02
    
    BRANCH_ALPHA:
    
        LDY $02
        
        LDA $BF4C, Y : AND.w #$00FF : ASL A : TAY
        
        LDA $B038, Y : STA $1008, X
        
        INC $02
        
        INX #2
        
        DEC $00
        
        BPL BRANCH_ALPHA
        
        LDY $02 : CPY $04
        
        BNE BRANCH_BETA
        
        TXA : ADD.w #$0006 : STA $1000
        
        SEP #$30
        
        LDA.b #$FF : STA $1008, X
        
        LDA.b #$01 : STA $14
        
        PLB
        
        RTS
    }

    ; *$7437C-$743D4 LOCAL
    {
        LDA $1A : AND.b #$0F
        
        BNE BRANCH_ALPHA
        
        INC $13
        
        LDA $13 : CMP.b #$0F
        
        BNE BRANCH_ALPHA
            
        INC $11
    
    BRANCH_ALPHA:
    
        JSL $0CCBA2 ; $64BA2 IN ROM
        
        RTS
    
    ; *$74391 ALTERNATE ENTRY POINT
    
        DEC $C8
            
        BNE BRANCH_BETA
        
        REP #$20
        
        STZ $0AA6
        
        LDA.w #$0000 : STA $7EC009 : STA $7EC007
        
        LDA.w #$001F : STA $7EC00B
        
        SEP #$20
        
        INC $11
        
        LDA.b #$C0 : STA $C8
        
        STZ $CA
    
    BRANCH_BETA:
    
        BRA BRANCH_ALPHA
    
    ; *$743B8 ALTERNATE ENTRY POINT
    
        DEC $C8
        
        LDA $CA : BNE BRANCH_GAMMA
        
        JSL PaletteFilter.doFiltering
        
        LDA $7EC007 : BNE BRANCH_BETA
        
        INC $CA
    
    BRANCH_GAMMA:
    
        LDA $C8 : BNE BRANCH_BETA
        
        INC $11
        
        JSL PaletteFilter_InitTheEndSprite
        
        RTS
    }

    ; *$743D5-$743E9 LOCAL
    {
        LDA $1A : AND.b #$07 : BNE .frameNotMultipleOf8
        
        ; Do some palette filtering
        JSL Palette_Filter_SP5F
        
        LDA $7EC007 : BNE .notDoneFiltering
        
        INC $11
    
    .frameNotMultipleOf8
    .notDoneFiltering
    
        JMP $C3FA ; $743FA IN ROM
    }

    ; $743EA-$743F9 "The End" Oam buffer data for displaying it
    {
        db $A0, $B8, $00, $3B
        db $B0, $B8, $02, $3B
        db $C0, $B8, $04, $3B
        db $D0, $B8, $06, $3B
    }
    
    ; *$743FA-$7441B JUMP LOCATION LOCAL
    {
        ; The End!
    
    .infiniteLoop
    
        REP #$20
        
        LDX.b #$0E
    
    .writeTheEndWithSprites
    
        ; $743EA, X THAT IS
        LDA $0EC3EA, X : STA $0800, X
        
        DEX #2
        
        BPL .writeTheEndWithSprites
        
        SEP #$20
        
        LDA.b #$02 : STA $0A20 : STA $0A21 : STA $0A22 : STA $0A23
        
        RTS
    
    ; Once you reach this point, you'll have to turn off or reset the system to continue
    ; *$7441A ALTERNATE ENTRY POINT
    
        BRA .infiniteLoop
    }

    ; $7441C-$7443F NULL
    
; ==============================================================================

    incsrc "vwf.asm"
    
; ==============================================================================

    ; $7544B-$7545F - NULL (bytes with value 0xFF)

    ; $75460-$75503 - used in dungeons to set $0AB6, $0AAC, $0AAD, and $0AAE
    
    ; $75504-$7557F - used to set $0AB4, $0AB5, and $0AB8
    
    ; $75580-$755A7 - used to set $0AAD and $0AAE

    ; *$755A8-$755F3 LONG
    Overworld_LoadPalettes:
    {
        ASL #2 : TAX
        
        STZ $0AA9
        
        LDA $0ED504, X : BMI .noPaletteChange1
        
        STA $0AB4
    
    .noPaletteChange1
    
        ; $75505, X THAT IS
        LDA $0ED505, X : BMI .noPaletteChange2
        
        STA $0AB5
    
    .noPaletteChange2
    
        ; $75506, X THAT IS
        LDA $0ED506, X : BMI .noPaletteChange3
        
        STA $0AB8
    
    .noPaletteChange3
    
        LDA $00 : ASL A : TAX
        
        ; $75580, X THAT IS
        LDA $0ED580, X : BMI .noPaletteChange4
        
        STA $0AAD
    
    .noPaletteChange4
    
        ; $75581, X THAT IS
        LDA $0ED581, X : BMI .noPaletteChange5
        
        STA $0AAE
    
    .noPaletteChange5
    
        JSL Palette_OverworldBgAux1
        JSL Palette_OverworldBgAux2
        JSL Palette_OverworldBgAux3
        JSL Palette_SpriteAux1
        JSL Palette_SpriteAux2
    
    ; *$755F3 ALTERNATE ENTRY POINT
    
        RTL
    }

    ; *$755F4-$75617 LONG
    Palette_BgAndFixedColor:
    {
    
    .zeroBgColor
    
        REP #$20
        
        LDA.w #$0000
    
    ; *$755F9 ALTERNATE ENTRY POINT
    .setBgColor
    
        STA $7EC500
        STA $7EC540
        STA $7EC300
        STA $7EC340
        
        SEP #$30
    
    ; *$7560B ALTERNATE ENTRY POINT
    .justFixedColor
    
        ; Sets color add / sub settings to normal intensity
        LDA.b #$20 : STA $9C
        LDA.b #$40 : STA $9D
        LDA.b #$80 : STA $9E
        
        RTL
    }

    ; *$75618-$7561C LONG
    Palette_SetOwBgColor_Long:
    {
        JSR Palette_GetOwBgColor
        
        ; Sets fixed color to normal and zeroes the first color of some palettes
        BRA Palette_BgAndFixedColor_setBgColor
    }

    ; *$7561D-$75621 LONG
    {
        JSR Palette_GetOwBgColor
        
        BRA BRANCH_$7560B
    }

    ; *$75622-$75652 LOCAL
    Palette_GetOwBgColor:
    {
        REP #$30
        
        ; default green color
        LDX.w #$2669
        
        ; If area number < 0x80
        LDA $8A : CMP.w #$0080 : BCC .notSpecialArea
        
        ; Check for special areas
        LDA $A0
        
        CMP.w #$0183 : BEQ .specialArea
        CMP.w #$0182 : BEQ .specialArea
        CMP.w #$0180 : BNE .finished
    
    .specialArea
    
        ; The special areas apparently have a slightly different shade of green
        ; for their background
        LDX.w #$19C6
        
        BRA .finished
    
    .notSpecialArea
    
        LDX.w #$2669
        
        LDA $8A : AND.w #$0040 : BEQ .finished
        
        LDX.w #$2A32
    
    .finished
    
        TXA
        
        RTS
    }

    ; \unused Only the top label is unused.
    ; *$75653-$756B8 LONG
    Palette_AssertTranslucencySwap_ForcePlayerToBg1:
    {
        ; ???
        ; these two instructions don't seem to have a reference.
        LDA.b #$01 : STA $EE
    
    ; *$75657 ALTERNATE ENTRY POINT
    shared Palette_AssertTranslucencySwap:
    
        LDA.b #$01 : STA $0ABD
    
    ; *$7565C ALTERNATE ENTRY POINT
    shared Palette_PerformTranslucencySwap:
    
        REP #$21
        
        LDX.b #$00
    
    .swap_palettes
    
        ; e.g. $415 means $7EC415, for your reference
        ; description: the below swaps memory regions $400-$41F and $4B0-
        ; $4BF with $4E0-$4FF and $470-$47F, respectively.
        ; This suggests 3bpp since each 0x10 byte region could be considered
        ; a full palette.
        ; At the same time, it also copies this info in the Main palette 
        ; buffer and the Auxiliary palette buffer.
        
        ; \optimize This could, at the very least, utilize a data bank value of
        ; 0x7E to speed things up and save space.
        
        ; swap SP0_L with SP7_L.
        LDA $7EC400, X : PHA
        
        LDA $7EC4E0, X : STA $7EC400, X
                         STA $7EC600, X
        
        PLA : STA $7EC4E0, X
              STA $7EC6E0, X
        
        ; swap SP0_H with SP7_H.
        LDA $7EC410, X : PHA
        
        LDA $7EC4F0, X : STA $7EC410, X
                         STA $7EC610, X
        
        PLA : STA $7EC4F0, X
              STA $7EC6F0, X
        
        ; swap SP5_H with SP3_H.
        LDA $7EC4B0, X : PHA
        
        LDA $7EC470, X : STA $7EC4B0, X
                         STA $7EC6B0, X
        
        PLA : STA $7EC470, X
              STA $7EC670, X
        
        INX #2 : CPX.b #$10 : BNE .swap_palettes
        
        SEP #$20
        
        INC $15
        
        RTL
    }

; ==============================================================================
    
    ; \unused Again, only the top label is unused.
    ; $756B9-$756BF LONG
    Palette_RevertTranslucencySwap_ForcePlayerBg2:
    {
        STZ $EE
    
    shared Palette_RevertTranslucencySwap:
    
        STZ $0ABD
        
        BRA Palette_PerformTranslucencySwap
    }

; =============================================

    ; *$756C0-$756D0 LONG
    LoadActualGearPalettes:
    {
        ; Called "actual" because none of the types of gear (sword, shield, armor)
        ; are faked or substituted with preset values.
    
        REP #$20
        
        ; Link�s sword and shield value
        LDA $7EF359 : STA $0C
        
        ; Link's armor value
        LDA $7EF35B : AND.w #$00FF
        
        BRA LoadGearPalettes.variable
    }

; =============================================

    ; \note Loads player palettes for unusual states, such as being electrocuted
    ; or using the Ether spell
    ; *$756D1-$756DC LONG
    Palette_ElectroThemedGear:
    {
        REP #$20
        
        LDA.w #$0202 : STA $0C
        
        LDA.w #$0404
        
        BRA LoadGearPalettes.variable
    }

; =============================================

    ; *$756DD-$75740 LONG
    LoadGearPalettes:
    {
    
    .bunny
    
        REP #$20
        
        ; What type of sword and armor does Link have? (2 bytes)
        LDA $7EF359 : STA $0C
        
        ; ....... ? .......
        LDA.w #$0303
    
    .variable
    
        STA $0E
        
        ; Setting up the bank for the source data
        LDA.w #$001B : STA $02
        
        ; X = #$0, #$1, #$2, #$3, or #$4 (sword value)
        LDX $0C
        
        ; A = #$0, #$0, #$6, #$C, or #$12
        LDA $1BEBB4, X : AND.w #$00FF : ADD.w #$D630
        
        REP #$10
        
        LDX.w #$01B2 ; Offset into the palette array.
        LDY.w #$0002 ; Length of the palette in words.
        
        JSR LoadGearPalette
        
        SEP #$10
        
        ; X = #$0, #$1, #$2, or #$3 (shield value)
        LDX $0D
        
        ; A = #$0, #$0, #$8, or #$10
        LDA $1BEBC1, X : AND.w #$00FF : ADD.w #$D648
        
        REP #$10
        
        LDX.w #$01B8
        LDY.w #$0003
        
        JSR LoadGearPalette
        
        SEP #$10
        
        ; Armor value
        LDX $0E
        
        LDA $1BEC06, X : AND.w #$00FF : ASL A : ADD.w #$D308
        
        REP #$10
        
        LDX.w #$01E2
        LDY.w #$000E
        
        JSR LoadGearPalette
        
        SEP #$30
        
        INC $15
        
        RTL
    }

; =============================================
    
    ; *$75741-$75756 LOCAL
    LoadGearPalette:
    {
        ; ($00 is variable input)
        STA $00

    .nextColor

        ; LDA from address $1BXXXX into auxiliary cgram buffer and normal cgram buffer. 
        LDA [$00] : STA $7EC300, X : STA $7EC500, X

        ; Y is the length of the palette in colors (words)
        INC $00 : INC $00
        
        INX #2
        
        DEY : BPL .nextColor

        RTL
    }

; ==============================================================================

    ; *$75757-$757FD LONG
    Filter_Majorly_Whiten_Bg:
    {
        REP #$20
        
        LDX.b #$00
    
    .next_color_in_each_palette
    
        LDA $7EC340, X : JSR Filter_Majorly_Whiten_Color : STA $7EC540, X
        LDA $7EC350, X : JSR Filter_Majorly_Whiten_Color : STA $7EC550, X
        LDA $7EC360, X : JSR Filter_Majorly_Whiten_Color : STA $7EC560, X
        LDA $7EC370, X : JSR Filter_Majorly_Whiten_Color : STA $7EC570, X
        LDA $7EC380, X : JSR Filter_Majorly_Whiten_Color : STA $7EC580, X
        LDA $7EC390, X : JSR Filter_Majorly_Whiten_Color : STA $7EC590, X
        LDA $7EC3A0, X : JSR Filter_Majorly_Whiten_Color : STA $7EC5A0, X
        LDA $7EC3B0, X : JSR Filter_Majorly_Whiten_Color : STA $7EC5B0, X
        LDA $7EC3C0, X : JSR Filter_Majorly_Whiten_Color : STA $7EC5C0, X
        LDA $7EC3D0, X : JSR Filter_Majorly_Whiten_Color : STA $7EC5D0, X
        LDA $7EC3E0, X : JSR Filter_Majorly_Whiten_Color : STA $7EC5E0, X
        LDA $7EC3F0, X : JSR Filter_Majorly_Whiten_Color : STA $7EC5F0, X
        
        INX #2 : CPX.b #$10 : BEQ .finished_whitening_increment
        
        JMP .next_color_in_each_palette
    
    .finished_whitening_increment
    
        REP #$10
        
        LDA $7EC540 : TAY
        
        LDA $7EC300 : BNE .non_black_backdrop_color
        
        ; What this is saying is don't whiten or muck with a black backdrop,
        ; but other colors are fine to alter.
        TAY
    
    .non_black_backdrop_color
    
        TYA : STA $7EC500
        
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$757FE-$75839 LOCAL
    Filter_Majorly_Whiten_Color:
    {
        STA $00
        
        AND.w #$001F : ADD.w #$000E
        
        CMP.w #$001F : BCC .red_not_maxed
        
        LDA.w #$001F
    
    .red_not_maxed
    
        STA $02
        
        LDA $00 : AND.w #$03E0 : ADD.w #$01C0
        
        CMP.w #$03E0 : BCC .green_not_maxed
        
        LDA.w #$03E0
    
    .green_not_maxed
    
        STA $04
        
        LDA $00 : AND.w #$7C00 : ADD.w #$3800
        
        CMP.w #$7C00 : BCC .blue_not_maxed
        
        LDA.w #$7C00
    
    .blue_not_maxed
    
        ORA $02 : ORA $04
        
        RTS
    }

; ==============================================================================

    ; *$7583A-$758FA LONG
    Palette_Restore_BG_From_Flash:
    {
        REP #$20
        
        LDX.b #$00
    
    .restore_loop
    
        LDA $7EC340, X : STA $7EC540, X
        LDA $7EC350, X : STA $7EC550, X
        LDA $7EC360, X : STA $7EC560, X
        LDA $7EC370, X : STA $7EC570, X
        LDA $7EC380, X : STA $7EC580, X
        LDA $7EC390, X : STA $7EC590, X
        LDA $7EC3A0, X : STA $7EC5A0, X
        LDA $7EC3B0, X : STA $7EC5B0, X
        LDA $7EC3C0, X : STA $7EC5C0, X
        LDA $7EC3D0, X : STA $7EC5D0, X
        LDA $7EC3E0, X : STA $7EC5E0, X
        LDA $7EC3F0, X : STA $7EC5F0, X
        
        INX #2 : CPX.b #$10 : BNE .restore_loop
        
        LDA $7EC540 : STA $7EC500
        
        SEP #$30
    
    ; *$758AE ALTERNATE ENTRY POINT
    
        LDA $1B : BNE BRANCH_BETA
        
        REP #$10
        
        LDX.w #$4020 : STX $9C
        LDX.w #$8040 : STX $9D
        
        LDX.w #$4F33
        LDY.w #$894F
        
        LDA $8A    : BEQ BRANCH_BETA
        CMP.b #$40 : BEQ BRANCH_BETA
        CMP.b #$5B : BEQ BRANCH_GAMMA
        
        LDX.w #$4C26
        LDY.w #$8C4C
        
        CMP.b #$03 : BEQ BRANCH_GAMMA
        CMP.b #$05 : BEQ BRANCH_GAMMA
        CMP.b #$07 : BEQ BRANCH_GAMMA
        
        LDX.w #$4A26
        LDY.w #$874A
        
        ; death mountain (breadcrumb)
        CMP.b #$43 : BEQ BRANCH_GAMMA
        CMP.b #$45 : BEQ BRANCH_GAMMA
        CMP.b #$47 : BNE BRANCH_BETA
    
    BRANCH_GAMMA:
    
        STX $9C
        STY $9D
    
    BRANCH_BETA:
    
        SEP #$10
        
        RTL
    }

; ==============================================================================

    ; *$758FB-$75919 LONG
    Palette_Restore_BG_And_HUD:
    {
        REP #$20
        
        LDX.b #$7E
    
    .next_color
    
        LDA $7EC300, X : STA $7EC500, X
        LDA $7EC380, X : STA $7EC580, X
        
        DEX #2 : BPL .next_color
        
        SEP #$20
        
        INC $15
        
        JMP $D8AE ; $758AE IN ROM
    }

; ==============================================================================

    ; $7591A-$7593F NULL

; =============================================

    ; *$75940-$7594B JUMP LOCATION (LONG)
    PalaceMap_LightenUpMap:
    {
        INC $13
        
        LDA $13 : CMP.b #$0F : BNE .stillTooDark
        
        INC $0200
    
    .stillTooDark
    .return
    
        RTL
    }

; =============================================
    
    ; *$7594C-$75A36 JUMP LOCATION (LONG)
    PalaceMap_Backup:
    {
        ; Darken the screen until it's fully dark.
        ; Then we can do some actual work.
        DEC $13 : BNE PalaceMap_LightenUpMap_return
        
        ; Turn off mosaic on BG1 and BG2
        LDA.b #$03 : STA $95
        
        ; Cache the hdma setup for later when we're done with the map
        ; because EnableForceBlank turns off hdma
        LDA $9B : STA $7EC229
        
        JSL EnableForceBlank ; $93D IN ROM
        
        ; Move on to next step of the submodule, and initialize the initilization indicator ($020D)
        INC $0200 : STZ $020D
        
        ; set the fixed color to neutral (a value of 0,0,0)
        LDA.b #$20 : STA $9C
        LDA.b #$40 : STA $9D
        LDA.b #$80 : STA $9E
        
        REP #$20
        
        ; Set's Link's graphics to a particular configuration useful during the palace map mode.
        LDA.w #$0250 : STA $0100
        
        LDX.b #$7E
    
    .cachePaletteBuffer
    
        ; Store the CGRAM buffer away for safe keeping until we get back from map mode.
        LDA $7EC500, X : STA $7FDD80, X : LDA $7EC580, X : STA $7FDE00, X
        LDA $7EC600, X : STA $7FDE80, X : LDA $7EC680, X : STA $7FDF00, X
        
        DEX #2 : BPL .cachePaletteBuffer
        
        ; cache BG scroll offset (for quaking and such)
        LDA $011A : STA $7EC221
        LDA $011C : STA $7EC223
        
        STZ $011A : STZ $011C
        
        ; cache all BG scroll value
        LDA $E0 : STA $7EC200
        LDA $E2 : STA $7EC202
        LDA $E6 : STA $7EC204
        LDA $E8 : STA $7EC206
        
        ; zero all the BG scroll values after that.
        STZ $E0 : STZ $E2 : STZ $E4
        STZ $E6 : STZ $E8 : STZ $EA
        
        ; cache CGWSEL register
        LDA $99 : STA $7EC225
        
        ; set cg +/- to be subscreen addition and turn on half color math
        ; (but enable it on no layers?)
        LDA.w #$2002 : STA $99
        
        LDX.b #$00
        LDA.w #$0300
    
    .writeLoop
    
        STA $7F0000, X : STA $7F0100, X : STA $7F0200, X : STA $7F0300, X
        STA $7F0400, X : STA $7F0500, X : STA $7F0600, X : STA $7F0700, X
        STA $7F0800, X : STA $7F0900, X : STA $7F0A00, X : STA $7F0B00, X
        STA $7F0C00, X : STA $7F0D00, X : STA $7F0E00, X : STA $7F0F00, X
        
        DEX #2 : BNE .writeLoop
        
        SEP #$20
        
        ; Play sound effect for opening the Palace Map.
        LDA.b #$10 : STA $012F
        
        ; Quiet the music a bit when we're in map mode
        LDA.b #$F2 : STA $012C
        
        RTL
    }

; =============================================

    ; *$75A37-$75A78 JUMP LOCATION (LONG)
    PalaceMap_FadeMapToBlack:
    {
        DEC $13 : BNE .notDoneDarkening
        
        ; Forceblank the screen
        JSL EnableForceBlank ; $93D IN ROM
        
        ; Move to next step of submodule
        INC $0200
        
        REP #$30
        
        LDA $7EC225 : STA $99
        LDA $7EC200 : STA $E0
        LDA $7EC202 : STA $E2
        LDA $7EC204 : STA $E6
        LDA $7EC206 : STA $E8
        
        STZ $E4
        STZ $EA
        
        LDA $7EC221 : STA $011A
        LDA $7EC223 : STA $011C
        
        SEP #$30
        
        INC $15
    
    .notDoneDarkening
    
        RTL
    }

; ==============================================================================

    ; *$75A79-$75A9B JUMP LOCATION (LONG)
    PalaceMap_LightenUpDungeon:
    {
        JSL OrientLampBg
        
        INC $13
        
        LDA $13 : CMP.b #$0F : BNE .notDoneBrightening
        
        LDA $010C : STA $10
        
        STZ $11
        STZ $0200
        STZ $B0
        
        ; bring screen brightness to full
        LDA.b #$0F : STA $13
    
        ; Restore hdma settings from before being in map mode.
        LDA $7EC229 : STA $9B
    
    .notDoneBrightening
    
        RTL
    }

; ==============================================================================

    ; \unused A bit of an enigma. I can't figure out what this data is for
    ; yet. (If anything) Qualifies as a \task , but low priority.
    ; $75A9C-$75D3F DATA
    {
        
    }

; ==============================================================================

    ; *$75D40-$75D60 LONG
    Overworld_Memorize_Map16_Change:
    {
        ; Keeps track of map modifications for when warping between worlds.
        
        ; shovel hole
        CMP.w #$0DC5 : BEQ .dontRemember
        
        ; hole from picking up a bush / rock
        CMP.w #$0DC9 : BEQ .dontRemember
        
        PHA : PHX : TXY
        
        LDX $04AC : STA $7EFA00, X
        
        TYA : STA $7EF800, X : INX #2 : STX $04AC
        
        PLX : PLA
    
    .dontRemember
    
        RTL
    }

; ==============================================================================

    ; $75D61-$75D66
    LwTurtleRockPegPositions:
    {
        dw $0826
        dw $05A0
        dw $081A
    }

    ; *$75D67-$75DFB LONG
    HandlePegPuzzles:
    {
        LDA $8A : CMP.w #$0007
        
        BNE .notLwTurtleRock
        
        LDA $7EF287 : AND.w #$0020
        
        BNE .warpAlreadyOpen
        
        ; Y in this routine apparently contains the map16 address of the peg tile that Link hit
        STY $00
        
        LDX $04C8 : CPX.w #$FFFF
        
        BEQ .puzzleFailed
        
        ; As you all probably realize, the 3 pegs in this area have to be hit in a specific order
        ; in order for the warp to open up. If you fail, you have to exit the screen and come back.
        ; That's what $04C8 being -1 (0xFFFF) indicates
        LDA LwTurtleRockPegPositions, X : CMP $00
        
        BNE .puzzleFailed
        
        ; Play the successful puzzle step sound effect
        LDA.w #$2D00 : STA $012E
        
        ; Move to the next peg
        INX #2 : STX $04C8 : CPX.w #$0006
        
        BNE .puzzleIncomplete
        
        ; Play mystery solved sound effect
        LDA.w #$1B00 : STA $012E
        
        ; Set a flag so that next time we enter this screen
        ; The puzzle will already be complete
        LDA $7EF287 : ORA.w #$0020 : STA $7EF287
        
        SEP #$20
        
        LDA.b #$2F : STA $11
        
        REP #$20
    
    .puzzleIncomplete
    
        LDX $00
        
        RTL
    
    .puzzleFailed
    
        LDA.w #$003C : STA $012E
        LDA.w #$FFFF : STA $04C8
        
        LDX $00
    
    .warpAlreadyOpen
    
        RTL
    
    .notLwTurtleRock
    
        CMP.w #$0062
        
        BNE .notDwSmithyHouse
        
        INC $04C8
        
        LDA $04C8 : CMP.w #$0016
        
        BNE .notEnoughPegs
        
        PHX
        
        SEP #$20
        
        LDA $7EF2E2 : ORA.b #$20 : STA $7EF2E2
        
        LDA.b #$1B : STA $012F
        
        REP #$20
        
        LDA.w #$0050 : STA $0692
        LDA.w #$0D20 : STA $0698
        
        JSL Overworld_DoMapUpdate32x32_Long
        
        REP #$30
        
        PLX
    
    .notDwSmithyHouse
    .notEnoughPegs
    
        RTL
    }

    ; $75DFC-$75E28 LONG
    {
        LDA $B0 : BNE BRANCH_ALPHA
        
        LDA.b #$29 : STA $012E
        
        JML $0EF404 ; $77404 IN ROM
    
    BRANCH_ALPHA:
    
        JSL $00EEF1 ; $6EF1 IN ROM
        
        REP #$30
        
        LDA $7EC009 : CMP.w #$00FF : BNE BRANCH_BETA
        
        STA $7EC007
        STA $7EC009
        
        SEP #$30
        
        INC $B0
        
        RTL
    
    BRANCH_BETA:
    
        JML $0EF48C ; $7748C IN ROM
    }

    ; $75E29-$75E48 DATA
    {
        ; corresponding warp types that lead to special overworld areas
        dw $0105, $01E4, $00AD, $00B9
        
        ; Lost woods, Hyrule Castle Bridge, Entrance to Zora falls, and in Zora Falls...
        ; (I think the last one is broken or a mistake)
        dw $0000, $002D, $000F, $0081
        
        ; Direction Link will face when he enters the special area
        dw $0008, $0002, $0008, $0008
        
        ; Exit value for the special area. In Hyrule Magic these are those White markers.
        dw $0180, $0181, $0182, $0189
    }

    ; *$75E49-$75E99 LONG
    {
        ; This routine specifically checks to see if Link will enter a special area (areas >= 0x80)
        
        REP #$31
        
        ; get the map16 address of Link's coordinates
        JSR $DE9A ; $75E9A IN ROM
        
        ; get the CHR at that location...
        LDA $0F8000, X : AND.w #$01FF : STA $00
        
        LDX.w #$0008
    
    .matchFailed
    
        LDA $00
    
    .nextChrValue
    
        DEX #2
        
        ; We've run out of CHR types to check (there's only 4)
        BMI .return
        
        ; compare map8 CHR number to see if the scroll to the next area has triggered
        CMP $0EDE29, X
        
        BNE .nextChrValue
        
        ; compare the area number, b/c only specific locations lead to the special OW areas.
        LDA $8A : CMP $0EDE31, X
        
        ; The CHR value and the area number must match for a warp to occur. (this is bizarre, I know)
        BNE .matchFailed
        
        ; Loads the exit number to use (so that we can get to the proper destination)
        LDA $0EDE41, X : STA $A0
        
        SEP #$20
        
        ; Sets the direction Link will face when he comes in or out of the special area.
        LDA $0EDE39, X : STA $67 : STA $0410 : STA $0416
        
        LDX.w #$0004
    
    ; converts a bitwise direction indicator to a value based one
    .convertLoop
    
        DEX
        
        LSR A : BCC .convertLoop
        
        STX $0418 : STX $069C
        
        LDA.b #$17 : STA $11
        
        ; Go to special overworld mode (under bridge and master sword)
        LDA.b #$0B : STA $10
    
    .return
    
        SEP #$30
        
        RTL
    }

    ; *$75E9A-$75ECD LOCAL
    {
        LDA $20 : ADD.w #$000C : STA $00
        SUB $0708 : AND $070A : ASL #3 : STA $06
        
        LDA $22 : ADD.w #$0008 : LSR #3 : STA $02
        SUB $070C : AND $070E : ADD $06 : TAY : TAX
        
        LDA $7E2000, X : ASL #3 : TAX
        
        RTS
    }

; ==============================================================================

    ; $75ECE-$75EDF DATA
    {
        ; Again, CHR values that must match with a respective area number
        dw $017C, $01E4, $00AD
        
        ; Master Sword grove, Under Hyrule bridge, Zora Falls.
        ; Note only 3 areas to warp back from whereas there were 4 areas to warp to
        ; However I think this just confirms that the last warp to special areas was something unfinished
        dw $0080, $0080, $0081
        
        ; Direction Link faces when getting back to the normal overworld area
        dw $0004, $0001, $0004
    }

; ==============================================================================

    ; $75EE0-$75EE2
    WeirdAssPlaceForAnExit:
    {
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; *$75EE3-$75F2E LONG
    {
        ; The reverse of $75E49, in that it detects tiles and area numbers that lead back to normal OW areas (from special areas)
        
        REP #$31
        
        JSR $DE9A   ; $75E9A IN ROM
        
        LDA $0F8000, X : AND.w #$01FF : STA $00
        
        LDX.w #$0006
    
    .matchFailed
    
        LDA $00
    
    .nextChrValue
    
        DEX #2
        
        ; ends the routine (Link is not going back to the normal Overworld this frame.)
        BMI WeirdAssPlaceForAnExit
        
        CMP $0EDECE, X
        
        BNE .nextChrValue
        
        LDA $8A : CMP $0EDED4, X
        
        BNE .matchFailed
        
        SEP #$30
        
        LDA $0EDEDA, X : STA $67
        
        LDX.b #$04
    
    ; converts a bitwise direction indicator to a value based one
    .convertLoop
    
        DEX
        
        LSR A
        
        BCC .convertLoop
        
        TXA : STA $0418
        
        LDA $67 
        
        LDX.b #$04
    
    ; Same idea here but for Link's walking direction.
    ; This loops is actually pointless and redundant
    ; because it generates the exact same result
    ; as the previous one.
    .convertLoop2
    
        DEX
        
        LSR A : BCC .convertLoop2
        
        TXA : STA $069C
        
        LDA.b #$24 : STA $11
        
        STZ $B0
        STZ $A0
        
        RTL
    }

; ==============================================================================

    ; $75F2F-$75F3F NULL
    {
    
    }
    
; ==============================================================================

    ; $75F40-$76E21 Remainder of the dialogue data (unmapped)
    {
    
    }
    
; ==============================================================================

    ; $76E22-$773FF NULL
    pool Null:
    {
        fillbyte $FF
        
        fill $5DE
    }

; ==============================================================================

    ; *$77400-$774EA LONG
    {
        ; causes the screen to flash white (e.g. the master sword retrieval and
        ; ganon's tower opening)
        
        ; don't do the following section if it's not the 0th part of a sub-submodule
        LDA $B0 : BNE BRANCH_ALPHA
    
    ; *$77404 ALTERNATE ENTRY POINT
    
        REP #$20
        
        LDX.b #$00
    
    .cache_colors_and_whiten_loop
    
        ; this loop turns all the colors in the temporary palette buffer to white
        ; It also saves them to a a temporary buffer (0x7FDD80[0x200])
        LDA $7EC300, X : STA $7FDD80, X
        LDA $7EC380, X : STA $7FDE00, X
        LDA $7EC400, X : STA $7FDE80, X
        LDA $7EC480, X : STA $7FDF00, X
        
        LDA.w #$7FFF : STA $7EC300, X
                       STA $7EC380, X
                       STA $7EC400, X
                       STA $7EC480, X
        
        INX #2 : CPX.b #$80 : BNE .cache_colors_and_whiten_loop
        
        ; save the background color to another area of the palette buffer
        LDA $7EC500 : STA $7EC540
        
        ; mosaic level is zero
        LDA.w #$0000 : STA $7EC007
        
        ; turn on color filtering
        LDA.w #$0002 : STA $7EC009
        
        SEP #$20
        
        INC $B0
        
        RTL
    
    BRANCH_ALPHA:
    
        JSL $00EEF1 ; $6EF1 IN ROM
        
        REP #$30
        
        LDA $7EC009 : CMP.w #$00FF : BNE BRANCH_GAMMA
        
        LDX.w #$000E : LDA.w #$0000
    
    BRANCH_DELTA:
    
        STA $7EC3B0, X : STA $7EC5B0, X
        
        DEX #2 : BPL BRANCH_DELTA
        
        STA $7EC007
        STA $7EC009
        
        SEP #$20
        
        STZ $11
        
        SEP #$30
        
        RTL
    
    BRANCH_GAMMA:
    
        CMP.w #$0000 : BNE BRANCH_EPSILON
        
        LDA $7EC007 : CMP.w #$001F : BNE BRANCH_EPSILON
        
        LDX.w #$0000
    
    .restore_cached_colors_loop
    
        LDA $7FDD80, X : STA $7EC300, X
        LDA $7FDDC0, X : STA $7EC340, X
        LDA $7FDE00, X : STA $7EC380, X
        LDA $7FDE40, X : STA $7EC3C0, X
        LDA $7FDE80, X : STA $7EC400, X
        LDA $7FDEC0, X : STA $7EC440, X
        LDA $7FDF00, X : STA $7EC480, X
        LDA $7FDF40, X : STA $7EC4C0, X
        
        INX #2 : CPX.w #$0040 : BNE .restore_cached_colors_loop
        
        SEP #$20
        
        STZ $1D
    
    BRANCH_EPSILON:
    
        SEP #$30
        
        RTL
    }

; ==============================================================================

    ; $77581-$77581
    Overworld_DwDeathMountainPaletteAnimation_easyOut:
    {
        RTL
    }

    ; *$77582-$77651 LONG
    Overworld_DwDeathMountainPaletteAnimation:
    {
        LDA $04C6 : BNE .easyOut
        
        LDA $8A
        
        CMP.b #$43 : BEQ .dwDeathMountain
        CMP.b #$45 : BEQ .dwDeathMountain
        CMP.b #$47 : BNE .easyOut
    
    .dwDeathMountain
    
        PHB : PHK : PLB
        
        LDA $1A
        
        CMP.b #$03 : BEQ .alter_palettes
        CMP.b #$05 : BEQ .restore_palettes
        CMP.b #$24 : BEQ .play_sound
        CMP.b #$2C : BEQ .restore_palettes
        CMP.b #$58 : BEQ .alter_palettes
        CMP.b #$5A : BNE .abstain
    
    .restore_palettes:
    
        REP #$20
        
        LDX.b #$02
    
    .loop_1
    
        LDA $7EC360, X : STA $7EC560, X
        LDA $7EC370, X : STA $7EC570, X
        LDA $7EC390, X : STA $7EC590, X
        LDA $7EC3E0, X : STA $7EC5E0, X
        LDA $7EC3F0, X : STA $7EC5F0, X
        
        INX #2 : CPX.b #$10 : BNE .loop_1
        
        BRA .abstain
    
    .play_sound
    
        LDX.b #$36 : STX $012E
    
    .alter_palettes
    
        REP #$20
        
        LDX.b #$02
        LDY.b #$00
    
    .loop_2
    
        LDA $F4EB, Y : STA $7EC560, X
        LDA $F4F9, Y : STA $7EC570, X
        LDA $F507, Y : STA $7EC590, X
        LDA $F515, Y : STA $7EC5E0, X
        LDA $F523, Y : STA $7EC5F0, X
        
        INY #2
        
        INX #2 : CPX.b #$10 : BNE .loop_2
    
    .abstain
    
        SEP #$20
        
        LDX.b #$00
        LDY.b #$40
        
        LDA $8A
        
        CMP.b #$43 : BEQ .check_flag
        CMP.b #$45 : BNE .do_palette_animation
    
    .check_flag
    
        LDA $7EF2C3 : AND.b #$20 : BNE .ganons_tower_opened
        
        LDA $1A : AND.b #$0C : ASL #2 : TAY
    
    .do_palette_animation
    .palette_write_loop
    
        REP #$20
        
        LDA $F531, Y : STA $7EC5D0, X
        
        INY #2
        
        INX #2 : CPX.b #$10 : BNE .palette_write_loop
    
    .ganons_tower_opened
    
        SEP #$20
        
        PLB
        
        INC $15
        
        RTL
    }

; ==============================================================================

    ; *$77652-$77663 LONG
    Overworld_LoadEventOverlay:
    {
        PHB
        
        ; Set the data bank to $7E.
        LDA.b #$7E : PHA : PLB
        
        REP #$30
        
        ; Check to see what Overworld area we�re in.
        ; Use it as an index into a jump table.
        LDA $8A : ASL A : TAX
        
        JSR (Overworld_EventOverlayTable, X)
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $77664-$77763 JUMP TABLE
    Overworld_EventOverlayTable:
    {
        ; Overlay pointers (for use with the 0x20 overlays on OW)
        
        dw $F764 ; = $77764* ; 0x00
        dw $F764 ; = $77764*
        dw $F764 ; = $77764*
        dw $F7AA ; = $777AA*
        dw $F7AA ; = $777AA*
        dw $F7AA ; = $777AA*
        dw $F7AA ; = $777AA*
        dw $F7AA ; = $777AA*
        
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7B1 ; = $777B1*
        dw $F7C7 ; = $777C7*
        dw $F7E4 ; = $777E4*
        dw $F7E4 ; = $777E4*
        dw $F7E4 ; = $777E4*
        
        dw $F7E4 ; = $777E4* ;Used in drawing over the weather vane after it has been exploded.
        dw $F7E4 ; = $777E4*
        dw $F7FE ; = $777FE*
        dw $F7FE ; = $777FE*
        dw $F7FE ; = $777FE*
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        
        dw $F7E4 ; = $777E4*
        dw $F7E4 ; = $777E4*
        dw $F827 ; = $77827*
        dw $F7E4 ; = $777E4*
        dw $F7E4 ; = $777E4*
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        dw $F827 ; = $77827*
        dw $F82D ; = $7782D*
        dw $F82D ; = $7782D*
        dw $F82D ; = $7782D*
        dw $F82D ; = $7782D*
        
        dw $F82D ; = $7782D* ; to move weathervane, this may be need changing to match area $18.
        dw $F82D ; = $7782D*
        dw $F833 ; = $77833*
        dw $F833 ; = $77833*
        dw $F833 ; = $77833*
        dw $F833 ; = $77833*
        dw $F833 ; = $77833*
        dw $F833 ; = $77833*
        
        dw $F82D ; = $7782D*
        dw $F82D ; = $7782D*
        dw $F839 ; = $77839*
        dw $F83F ; = $7783F*
        dw $F9E6 ; = $779E6*
        dw $F9E6 ; = $779E6*
        dw $F9E6 ; = $779E6*
        dw $F9E6 ; = $779E6*
        
        dw $F9E6 ; = $779E6*
        dw $F9E6 ; = $779E6*
        dw $FA2E ; = $77A2E*
        dw $FA2E ; = $77A2E* ; Ganon's Tower Overlay (opened tower stairs)
        dw $FA2E ; = $77A2E*
        dw $FA5B ; = $77A5B*
        dw $FA5B ; = $77A5B*
        dw $FA61 ; = $77A61*
        
        dw $F9E6 ; = $779E6*
        dw $F9E6 ; = $779E6*
        dw $FAB4 ; = $77AB4*
        dw $FA2E ; = $77A2E*
        dw $FA2E ; = $77A2E*
        dw $FA5B ; = $77A5B*
        dw $FA5B ; = $77A5B*
        dw $FAB4 ; = $77AB4*
        
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FACF ; = $77ACF*
        dw $FACF ; = $77ACF*
        dw $FACF ; = $77ACF*
        dw $FAF6 ; = $77AF6*
        dw $FAF6 ; = $77AF6*
        dw $FAF6 ; = $77AF6*
        
        dw $FAB4 ; = $77AB4*
        dw $FAB4 ; = $77AB4*
        dw $FB0B ; = $77B0B*
        dw $FACF ; = $77ACF*
        dw $FACF ; = $77ACF*
        dw $FB11 ; = $77B11*
        dw $FAF6 ; = $77AF6*
        dw $FAF6 ; = $77AF6*
        
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        dw $F827 ; = $77827*
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        dw $FB64 ; = $77B64* ; Caution, as far as I know this is in fact blank space
        dw $FB64 ; = $77B64* ; It may be that some code is mapped here
        dw $FB64 ; = $77B64* ; But as it stands this portion is a sea of "FF"s
        dw $FB64 ; = $77B64*
        dw $FB64 ; = $77B64*
        dw $F833 ; = $77833*
        
        dw $FB11 ; = $77B11*
        dw $FB11 ; = $77B11*
        dw $FB64 ; = $77B64*
        dw $F83F ; = $7783F*
        dw $FB64 ; = $77B64*
        dw $FB64 ; = $77B64*
        dw $FB64 ; = $77B64*
        dw $FB64 ; = $77B64*
    
    ; Note there is nothing here for the Master Sword resting place and Zora falls. 
    ; Must be handled elsewhere.
    }


    ; *$77764-$777A9 LOCAL
    {
        LDA.w #$0E32
        
        STA $2816 : STA $2818 : STA $281A 
        STA $281C : STA $2896 : STA $289C
        
        INC A : STA $2898
        INC A : STA $2E9A
        INC A : STA $2916
        INC A : STA $2918
        INC A : STA $291A
        INC A : STA $291C
        INC A : STA $2996
        INC A : STA $2998
        INC A : STA $299A
        INC A : STA $299C
        INC A : STA $2A18
        INC A : STA $2A1A
        
        RTS
    }

    ; *$777AA-$777B0 LOCAL
    {
        LDA.w #$0212 : STA $2720
        
        RTS
    }

    ; *$777B1-$777C6 LOCAL
    {
        LDX.w #$0506
    
    ; *$777B4 ALTERNATIVE ENTRY POINT
    
        LDA.w #$0918 : STA $2000, X
        INC A        : STA $2002, X
        INC A        : STA $2080, X
        INC A        : STA $2082, X
        
        RTS
    }

    ; *$777C7-$777E3 LOCAL
    {
        LDA.w #$0DD1 : STA $2532
        INC A        : STA $2534
        
        LDA.w #$0DD7 : STA $25B2
        INC A        : STA $25B4
        INC A        : STA $2632
        INC A        : STA $2634
        
        RTS
    }

    ; *$777E4-$777FD LOCAL
    {
        LDA.w #$0E21 : STA $2C3E : STA $2C42
        INC A        : STA $2C40
        INC A        : STA $2CBE
        INC A        : STA $2CC0
        INC A        : STA $2CC2
        
        RTS
    }

    ; *$777FE-$77826 LOCAL
    {
        LDA.w #$0DC1 : STA $33BC
        INC A        : STA $33BE
        
        LDA.w #$0DBE : STA $343C
        INC A        : STA $343E
        
        LDA.w #$0DC2 : STA $33C0
        INC A        : STA $33C2
        
        LDA.w #$0DBF : STA $3440
        INC A        : STA $3442
        
        RTS
    }

    ; *$77827-$7782C LOCAL
    {
        LDX.w #$0330
        
        JMP $F7B4 ; $777B4 IN ROM
    }

    ; *$7782D-$77832 LOCAL
    {
        LDX.w #$0358
        
        JMP $F7B4 ; $777B4 IN ROM
    }

    ; *$77833-$77838 LOCAL
    {
        LDX.w #$040C
        
        JMP $F7B4 ; $777B4 IN ROM
    }

    ; *$77839-$7783E LOCAL
    {
        LDX.w #$0A1E
        
        JMP $F7B4 ; $777B4
    }

    ; *$7783F-$779E5 LOCAL
    {
        LDA.w #$0DDF
        
        STA $23AC : STA $2424 : STA $24A0 : STA $251E
        STA $261C : STA $2734
        
        INC A : STA $23AE : STA $24A2
        INC A : STA $23B0 : STA $2438 : STA $24BA : STA $25AA : STA $273A
        INC A : STA $2426 : STA $2428 : STA $242A : STA $2432 : STA $2434 : STA $2436
        INC A : STA $242C : STA $24A4 : STA $2520 : STA $261E
        
        INC A
        
        STA $242E : STA $2426 : STA $24A8 : STA $24B0
        STA $24B6 : STA $2522 : STA $2524 : STA $2526
        STA $2538 : STA $25A0 : STA $25A2 : STA $25A4
        STA $25A6 : STA $2620 : STA $2622 : STA $269E
        STA $26A0 : STA $271E : STA $2720 : STA $2826
        STA $28A6 : STA $28A8 : STA $2926
        
        INC A
        
        STA $2430 : STA $24B8 : STA $25A8 : STA $262A
        
        INC A
        
        STA $24AA : STA $24B2 : STA $2528 : STA $25B8
        STA $28AA : STA $2928
        
        INC A
        
        STA $24AC : STA $2530 : STA $279E : STA $27A0
        STA $29A6 : STA $29B8
        
        INC A
        
        STA $24AE : STA $24B4 : STA $2536 : STA $27A2
        STA $2824
        
        INC A
        
        STA $252E : STA $2534 : STA $279C : STA $2822
        STA $2934 : STA $29B6
        
        INC A
        
        STA $253A : STA $2638 : STA $26B8 : STA $293A
        
        INC A
        
        STA $259E : STA $25B6 : STA $2636 : STA $269C
        STA $26B6 : STA $271C : STA $28A4 : STA $2924
        
        INC A : STA $2624 : STA $26A2
        INC A : STA $2626
        INC A : STA $2628
        INC A : STA $26A4 : STA $27B6
        
        INC A
        
        STA $26A6 : STA $2726 : STA $2728 : STA $272A
        STA $27AA : STA $2836 : STA $2838
        
        INC A : STA $26A8 : STA $27B8
        INC A : STA $26AA
        INC A : STA $2727 : STA $27A4 : STA $2828
        INC A : STA $2724
        INC A : STA $27A6
        INC A : STA $27A8 : STA $28B6
        INC A : STA $27B4
        INC A : STA $27BA
        INC A : STA $282A
        INC A : STA $2834
        INC A : STA $283A
        INC A : STA $28B4
        INC A : STA $28B8
        INC A : STA $28BA
        INC A : STA $2936
        INC A : STA $2938
        INC A : STA $252A : STA $2532 : STA $292A
        INC A : STA $25BA : STA $29A8 : STA $29BA
        INC A : STA $29A4
        INC A : STA $2736
        INC A : STA $2738
        
        RTS
    }

    ; *$779E6-$77A2D LOCAL
    {
        LDA.w #$0E13 : STA $2590
        INC A        : STA $2596
        INC A        : STA $2610
        INC A        : STA $2612
        INC A        : STA $2614
        INC A        : STA $2616
        INC A        : STA $2692
        INC A        : STA $2694
        
        LDA.w #$0E06 : STA $2812 : STA $2814
        INC A        : STA $2710 : STA $2790
        INC A        : STA $2712 : STA $2792
        INC A        : STA $2714 : STA $2794
        INC A        : STA $2716 : STA $2796
        
        RTS
    }

    ; *$77A2E-$77A5A LOCAL
    {
        LDA.w #$0E96 : STA $7E245E
        INC A        : STA $7E2460
        
        LDA.w #$0E9C : STA $7E24DE : STA $7E255E
        INC A        : STA $7E24E0 : STA $7E2560
        
        LDA.w #$0E9A : STA $7E25DE
        INC A        : STA $7E25E0
        
        RTS
    }

    ; *$77A5B-$77A60 LOCAL
    {
        LDX.w #$0868
        
        JMP $F7B4   ; $777B4 IN ROM
    }

    ; *$77A61-$77AB3 LOCAL
    {
        LDA.w #$0E78 : STA $7E299E
        INC A        : STA $7E29A0
        INC A        : STA $7E29A2
        INC A        : STA $7E29A4
        INC A        : STA $7E2A1E
        INC A        : STA $7E202A
        INC A        : STA $7E2A22
        INC A        : STA $7E2A24
        INC A        : STA $7E2A9E
        INC A        : STA $7E2AA0
        INC A        : STA $7E2AA2
        INC A        : STA $7E2AA4
        INC A        : STA $7E2B1E
        INC A        : STA $7E2B20
        INC A        : STA $7E2B22
        INC A        : STA $7E2B24
        
        RTS
    }

    ; *$77AB4-$77ACE LOCAL
    {
        LDA.w #$0E1B : STA $2D3E
        INC A        : STA $2D40
        INC A        : STA $2DBE
        INC A        : STA $2DC0
        INC A        : STA $2E3E
        INC A        : STA $2E40
        
        RTS
    }

    ; *$77ACF-$77AF5 LOCAL
    {
        LDA.w #$0E3F : STA $23BC
        INC A        : STA $23BE
        INC A        : STA $23C0
        INC A        : STA $243C
        INC A        : STA $243E
        INC A        : STA $2440
        INC A        : STA $24BC
        INC A        : STA $24BE
        INC A        : STA $24C0
        
        RTS
    }

    ; *$77AF6-$77B0A LOCAL
    {
        LDA.w #$0E31 : STA $21E6
        
        LDA.w #$0E2D : STA $226A
        
        INC A : STA $22EA
        INC A : STA $236A
        
        RTS
    }

    ; *$77B0B-$77B10 LOCAL
    {
        LDX.w #$0D20
        
        JMP $F7B4 ; $777B4 IN ROM
    }

    ; $77B11-$77B63 LOCAL
    {
        LDA.w #$0E64 : STA $2522
        
        INC A : STA $2524
        INC A : STA $2526
        INC A : STA $2528
        INC A : STA $25A2
        INC A : STA $25A4
        INC A : STA $25A6
        INC A : STA $25A8
        INC A : STA $2622
        INC A : STA $2624
        INC A : STA $2626
        INC A : STA $2628
        INC A : STA $26A2
        INC A : STA $26A4
        INC A : STA $26A6
        INC A : STA $26A8
        INC A : STA $2722
        INC A : STA $2724
        INC A : STA $2726
        INC A : STA $2728
        
        RTS
    }

warnpc $0F8000
