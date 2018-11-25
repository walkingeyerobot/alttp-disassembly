
; ==============================================================================

    ; $4B284-$4B2B1 DATA
    pool Garnish_GanonBatFlame:
    {
    
    .chr
        db $AC, $AE, $66, $66, $8E, $A0, $A2
    
    .properties
        db $01, $41, $01, $41, $00, $00, $00
    
    .chr_indices
        db 7, 6, 5, 4, 5, 4, 5, 4
        db 5, 4, 5, 4, 5, 4, 5, 4
        db 5, 4, 5, 4, 5, 4, 5, 4
        db 5, 4, 5, 4, 5, 4, 5, 4
    }

; ==============================================================================

    ; \note The last several frames of the GanonBatFlame object will look
    ; like this and will not damage the player.
    ; $4B2B2-$4B305 JUMP LOCATION
    Garnish_GanonBatFlameout:
    {
        ; special animation 0x11
        
        LDA $11 : ORA $0FC1 : BNE .pause_movement
        
        LDA $7FF81E, X : SUB.b #$01 : STA $7FF81E, X
        LDA $7FF85A, X : SBC.b #$00 : STA $7FF85A, X
    
    .pause_movement
    
        JSR Garnish_PrepOamCoord
        
        REP #$10
        
        LDY $90
        
        LDA $00     : STA $0000, Y
        ADD.b #$08  : STA $0004, Y
        LDA $02     : STA $0001, Y : STA $0005, Y
        LDA.b #$A4  : STA $0002, Y
        INC A       : STA $0006, Y
        LDA.b #$22  : STA $0003, Y : STA $0007, Y 
        
        LDY $92
        
        LDA.b #$00 : STA $0000, Y : STA $0001, Y
        
        SEP #$10
        
        RTS
    }

; ==============================================================================

    ; $4B306-$4B33E JUMP LOCATION
    Garnish_GanonBatFlame:
    {
        ; special animation 0x10
        
        LDA $7FF90E, X : CMP.b #$08 : BNE .dont_transmute
        
        LDA.b #$11 : STA $7FF800, X
    
    .dont_transmute
    
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        LDA $7FF90E, X : LSR #3 : PHX : TAX
        
        LDA .chr_indices, X : TAX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA.b #$22 : ORA .properties, X
        
        PLX
        
        JSR Garnish_SetOamPropsAndLargeSize
        
        JMP Garnish_CheckPlayerCollision
    }

; ==============================================================================
