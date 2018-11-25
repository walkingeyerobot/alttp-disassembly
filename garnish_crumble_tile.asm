
; ==============================================================================

    ; $4B613-$4B626 DATA
    pool Garnish_CrumbleTile:
    {
    
    .chr
        db $80, $CC, $CC, $EA, $EA
    
    .properties
        db $30, $31, $31, $31, $31
    
    .oam_sizes
        db $00, $02, $02, $02, $02
    
    ; \note The x and y offset is considered the same for this object, no
    ; fancy stuff going on here.
    .xy_offsets
        db 4, 0, 0, 0, 0
    
    }

; ==============================================================================

    ; $4B627-$4B6BF JUMP LOCATION
    Garnish_CrumbleTile:
    {
        ; Special animation 0x03
        
        ; Placing the pit tile is only intended to happen on the first
        ; frame that this garnish is active.
        LDA $7FF90E, X : CMP.B #$1E : BNE .dont_place_pit_tile
        
        LDA $11 : ORA $0FC1 : BNE .just_draw
        
        PHA
        
        LDA $7FF83C, X : STA $00
        LDA $7FF878, X : STA $01
        
        LDA $7FF81E, X : SUB.b #$10 : STA $02
        LDA $7FF85A, X : SUB.b #$00 : STA $03
        
        PHX
        
        ; Replace the targeted tile with a pit tile.
        LDY.b #$04 : JSL Dungeon_SpriteInducedTilemapUpdate
        
        PLX : PLA
    
    .dont_place_pit_tile
    .just_draw
    
        LSR #3 : TAY
        
        LDA .chr, Y        : STA $03
        LDA .properties, Y : STA $05
        LDA .oam_sizes, Y  : STA $06
        
        LDA $7FF83C, X : SUB $E2    : PHP : ADD .xy_offsets, Y : STA $00
        LDA $7FF878, X : ADC.b #$00 : PLP : SBC $E3
        
        BNE .off_screen
        
        LDA $7FF81E, X : SUB $E8    : PHP : ADD .xy_offsets, Y : STA $02
        LDA $7FF85A, X : ADC.b #$00 : PLP : SBC $E9
        
        BEQ .on_screen
    
    .off_screen
    
        RTS
    
    .on_screen
    
        LDY.b #$00
        
              LDA $00                    : STA ($90), Y
              LDA $02 : SUB.b #$10 : INY : STA ($90), Y
        INY : LDA $03                    : STA ($90), Y
        INY : LDA $05                    : STA ($90), Y
        
        LDA $06 : STA ($92)
        
        RTS
    }

; ==============================================================================
