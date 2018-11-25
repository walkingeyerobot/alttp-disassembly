
; ==============================================================================

    ; $4B419-$4B428 DATA
    pool Garnish_LightningTrail:
    {
    
    .chr
        db $CC, $EC, $CE, $EE, $CC, $EC, $CE, $EE
    
    .properties
        db $31, $31, $31, $31, $71, $71, $71, $71
    }

; ==============================================================================

    ; $4B429-$4B495 JUMP LOCATION
    Garnish_LightningTrail:
    {
        ; special animation 0x09
        
        JSR Garnish_PrepOamCoord
        
        LDA $00       : STA ($90), Y
        LDA $02 : INY : STA ($90), Y
        
        LDA $7FF92C, X : PHX : TAX
        
        LDA .chr, X : PHX
        
        LDX $048E : CPX.b #$20 : BNE .not_agahnim_1_room
        
        ; \wtf Is this a kludge having to do with the tileset being loaded into
        ; a different slot in Agahnim's room?
        SUB.b #$80
    
    .not_agahnim_1_room
    
        PLX
        
        INY : STA ($90), Y
        
        LDA $1A : ASL A : AND.b #$0E : ORA .properties, X
        
        PLX
        
        JSR Garnish_SetOamPropsAndLargeSize
    
    ; $4B459 ALTERNATE ENTRY POINT
    shared Garnish_CheckPlayerCollision:
    
        TXA : EOR $1A : AND.b #$07
                        ORA $031F
                        ORA $037B : BNE .no_collision
        
        LDA $22 : SBC $E2 : SBC $00 : ADC.b #$0C
                                      CMP.b #$18 : BCS .no_collision
        
        LDA $20 : SBC $E8 : SBC $02 : ADC.b #$16
                                      CMP.b #$1C : BCS .no_collision
        
        LDA.b #$01 : STA $4D
        
        LDA.b #$10 : STA $46 : STA $0373
        
        LDA $28 : EOR.b #$FF : STA $28
        LDA $27 : EOR.b #$FF : STA $27
    
    .no_collision
    
        RTS
    }

; ==============================================================================
