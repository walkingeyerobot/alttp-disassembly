
; ==============================================================================

    ; *$E8B52-$E8BBB JUMP LOCATION
    Sprite_SpiralFireBat:
    {
        JSR FireBat_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_Load_16bit_AuxCoord
        
        LDA.b #$02
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        LDA $01 : STA $0D50, X
        
        LDA.b #$50
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $0D50, X : EOR.b #$FF : INC A : ADD $00 : STA $0D50, X
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $00
        
        LDA $01 : EOR.b #$FF : INC A : ADD $00 : STA $0D40, X
    
    ; *$E8B90 ALTERNATE ENTRY POINT
    
        JSR $8C43 ; $E8C43 IN ROM
        JSR Sprite4_Move
        
        LDA $0E80, X : AND.b #$07 : BNE BRANCH_ALPHA
        
        LDA.b #$0E
        
        JSR $BDE8 ; $EBDE8 IN ROM
        
        LDY $0EC0, X
        
        PHX
        
        LDX $00
        
        LDA.b #$10 : STA $7FF800, X
        
        LDA.b #$4F
        
        CPY.b #$05 : BNE BRANCH_BETA
        
        LDA.b #$2F
    
    BRANCH_BETA:
    
        STA $7FF90E, X
        
        PLX
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; \task Investigate the usage of this routine. I suspect that it more
    ; correctly would be called Sprite4_LoadOriginCoord, but it's not clear
    ; if the Lynel uses it differently.
    ; *$E8BBC-$E8BD0 LOCAL
    Sprite4_Load_16bit_AuxCoord:
    {
        LDA $0D90, X : STA $04
        LDA $0DA0, X : STA $05
        
        LDA $0DB0, X : STA $06
        LDA $0E90, X : STA $07
        
        RTS
    }

; ==============================================================================
