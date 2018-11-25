
; ==============================================================================

    ; $4B150-$4B177 DATA
    pool Garnish_ArrghusSplash:
    {
    
    .y_offsets
        db -12,  20, -10,  10,  -8,   8,  -4,   4
    
    .x_offsets
        db  -4,  -4,  -2,  -2,   0,   0,   0,   0
    
    .chr
        db $AE, $AE, $AE, $AE, $AE, $AE, $AC, $AC
    
    .properties
        db $34, $74, $34, $74, $34, $74, $34, $74
    
    .oam_sizes
        db $00, $00, $02, $02, $02, $02, $02, $02
    }

; ==============================================================================

    ; $4B178-$4B1BC JUMP LOCATION
    Garnish_ArrghusSplash:
    {
        JSR Garnish_PrepOamCoord
        
        LDA $7FF90E, X : LSR A : AND.b #$06 : STA $06
        
        ; Number of sprites to draw (2)
        LDA.b #$01 : STA $07
        
        PHX
    
    .next_oam_entry
    
        LDA $06 : ORA $07 : TAX
        
        LDA $00 : ADD .y_offsets, X       : STA ($90), Y
        LDA $02 : ADD .x_offsets, X : INY : STA ($90), Y
        
        LDA .chr, X        : INY : STA ($90), Y
        LDA .properties, X : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA .oam_sizes, X : STA ($92), Y
        
        PLY : INY
        
        DEC $07 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

