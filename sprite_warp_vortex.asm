; ==============================================================================

    ; $2AF71-$2AF74 DATA
    pool Sprite_WarpVortex:
    {
    
    .vh_flip_states
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; *$2AF75-$2B018 JUMP LOCATION
    Sprite_WarpVortex:
    {
        ; Warp Vortex (Sprite 0x6C)
        
        LDA $7EF3CA : BNE .self_terminate
        
        LDA $8A : CMP.b #$80 : BCC .in_normal_area
        
        RTS
    
    .in_normal_area
    
        LDA $11 : CMP.b #$23 : BEQ .gamma
        
        LDA $0FC6 : CMP.b #$03 : BCS .gamma
        
        JSL Sprite_PrepAndDrawSingleLargeLong
    
    .gamma
    
        JSR Sprite2_CheckIfActive
        
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip_states, Y : STA $0F50, X
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .delta
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .epsilon
        
        LDA $0D90, X : BEQ .zeta
        
        LDA $037B : ORA $031F : BNE .zeta
        
        LDA $02E4 : BNE .zeta
        
        LDA.b #$23 : STA $11
        
        LDA.b #$01 : STA $02DB
        
        STZ $B0
        STZ $27
        STZ $28
        
        LDA.b #$14 : STA $5D
        
        LDA $8A : AND.b #$40 : STA $7B
    
    .self_terminate
    
        STZ $0DD0, X
        
        BRA .zeta
    
    .epsilon
    
        LDA.b #$01 : STA $0D90, X
        
        LDA $0F50, X : AND.b #$FF : STA $0F50, X
    
    .zeta
    
        INC $0DA0, X : BNE .theta
        
        LDA.b #$01 : STA $0D90, X
    
    .theta
    
        LDA $1ABF : STA $0D10, X
        LDA $1ACF : STA $0D30, X
        
        LDA $1ADF : ADD.b #$08 : STA $0D00, X
        LDA $1AEF : ADC.b #$00 : STA $0D20, X
    
    .delta
    
        RTS
    }

; ==============================================================================
