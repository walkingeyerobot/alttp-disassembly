
; ==============================================================================

    ; $4B33F-$4B34E DATA
    pool Garnish_Trinexxice:
    {
    
    .chr
        db $e8, $e8, $E6, $E6, $E4, $E4, $E4, $E4
        db $E4, $E4, $E4, $E4
    
    .properties
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; $4B34F-$4B3B8 JUMP LOCATION
    Garnish_TrinexxIce:
    {
        ; special animation 0x0C
        
        LDA $7FF90E, X : CMP.b #$50 : BNE .dont_update_tiles
        
        LDA $11 : ORA $0FC1 : BNE .dont_update_tiles
        
        PHA
        
        LDA $7FF83C, X : STA $00
        LDA $7FF878, X : STA $01
        
        LDA $7FF81E, X : SUB.b #$10 : STA $02
        LDA $7FF85A, X : SBC.b #$00 : STA $03
        
        LDY.b #$12 : JSL Dungeon_SpriteInducedTilemapUpdate
        
        PLA
    
    .dont_update_tiles
    
        LDA $7FF90E, X : LSR #2 : AND.b #$03 : TAY
        
        LDA .properties, Y : STA $04
        
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        ; \wtf NOP? hrm...
        LDA $7FF90E, X : LSR #4 : NOP : PHX : TAX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA.b #$35 : ORA $04 : PLX
        
        JMP Garnish_SetOamPropsAndLargeSize
    
    .unused
    
        JMP Garnish_CheckPlayerCollision
    }

; ==============================================================================
