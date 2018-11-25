
; ==============================================================================

    ; \note These are fireball spitting faces. Their graphics are background
    ; based, so the only visible sprite manifestation they have are the
    ; fireballs they generate.
    ; *$EC7EB-$EC852 JUMP LOCATION
    Sprite_Medusa:
    {
        JSL Sprite_PrepOamCoordLong
        
        LDA $1B : BNE .indoors
        
        ; \note These are apparently triggers for Poes on the overworld. When
        ; a gravestone is pushed into them, they appear as if from inside the
        ; gravestone.
        LDA.b #$FF : STA $0D50, X : STA $0E30, X
        
        JSR Sprite4_CheckTileCollision : BEQ .didnt_collide
        
        JSR Sprite4_CheckIfActive
        
        LDA.b #$19 : STA $0E20, X
        
        JSL Sprite_LoadProperties
        
        INC $0E90, X
        
        LDA $0D10, X : ADC.b #$08 : STA $0D10, X
        
        LDA $0D00, X : SBC.b #$07 : STA $0D00, X
        
        LDA.b #$19 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$80 : STA $0CAA, X
    
    .didnt_collide
    
        RTS
    
    .indoors
    
        JSR Sprite4_CheckIfActive
        
        INC $0E80, X : LDA $0E80, X : AND.b #$7F : BNE .dont_spawn
        
        LDA $0F20, X : CMP $EE : BNE .dont_spawn
        
        JSL Sprite_SpawnFireball : BMI .spawn_failed
    
    ; *$EC845 ALTERNATE ENTRY POINT
    shared Medusa_ConfigFireballProperties:
    
        LDA $0CAA, Y : ORA.b #$08 : STA $0CAA, Y
        
        LDA.b #$04 : STA $0CD2, Y
    
    .spawn_failed
    .dont_spawn
    
        RTS
    }

; ==============================================================================
