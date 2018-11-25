
; ==============================================================================

    ; *$EE3ED-$EE4C7 JUMP LOCATION
    Sprite_Lightning:
    {
        ; VITREOUS EYEBALL? (Sprite 0xBF)
        
        LDA $1A : ASL A : AND.b #$0E : STA $00
        
        LDY $0D90, X
        
        LDA $0F50, X : AND.b #$B1 : ORA $E3A5, Y : ORA $00 : STA $0F50, X
        
        LDA $E39D, Y
        
        LDY $048E : CPY.b #$20 : BNE BRANCH_ALPHA
        
        ADD.b #$04
    
    BRANCH_ALPHA:
    
        STA $0DC0, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite4_CheckIfActive
        
        LDA $0DF0, X : BNE BRANCH_BETA
        
        JSR Lightning_SpawnFulgurGarnish
        
        LDA.b #$02 : STA $0DF0, X
        
        LDA $0D00, X : ADD.b #$10 : STA $0D00, X : PHA
        LDA $0D20, X : ADC.b #$00 : STA $0D20, X
        
        PLA : SUB $E8 : CMP.b #$D0 : BCC BRANCH_GAMMA
        
        STZ $0DD0, X
        
        RTS
    
    BRANCH_GAMMA:
    
        JSL GetRandomInt : AND.b #$07 : STA $00
        
        LDA $0D90, X : ASL #3 : ORA $00 : TAY
        
        STZ $01
        
        LDA $E3AD, Y : BPL BRANCH_DELTA
        
        DEC $01
    
    BRANCH_DELTA:
    
        ADD $0D10, X           : STA $0D10, X
        LDA $0D30, X : ADC $01 : STA $0D30, X
        
        LDA $00 : STA $0D90, X
    
    BRANCH_BETA:
    
        RTS
    
    ; *$EE475 ALTERNATE ENTRY POINT
    shared Lightning_SpawnFulgurGarnish:
    
        PHX : TXY
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        DEC $0FF8 : BPL .dont_reset_fulgur_count
        
        LDA.b #$1D : STA $0FF8
    
    .dont_reset_fulgur_count
    
        LDX $0FF8
    
    .empty_slot
    
        LDA.b #$09 : STA $7FF800, X : STA $0FB4
        
        LDA $0D90, Y : STA $7FF92C, X
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$20 : STA $7FF90E, X
        
        PLX
        
        RTS
    }

; ==============================================================================
