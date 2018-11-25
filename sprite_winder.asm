
; ==============================================================================

    ; $F51CD-$F51D0 DATA
    pool Sprite_Winder:
    {
    
    .vh_flip
        db $00, $40, $80, $C0    
    }

; ==============================================================================

    ; \note Appearance is that of a wandering fireball chain
    ; *$F51D1-$F51FD JUMP LOCATION
    Sprite_Winder:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        LDA $0D90, X : BEQ Winder_DefaultState
        
        ; \tcrf (unverified)
        ; The existence of this bit of code seems to suggest that there might
        ; have been a way to defeat Winders at one point, or that they died
        ; spontaneously...
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        STZ $0DD0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F51FE-$F5205 DATA
    pool Winder_DefaultState:
    {
    
    .x_speeds
        db $18, $E8, $00, $00
    
    .y_speeds
        db $00, $00, $18, $E8
    }

; ==============================================================================

    ; *$F5206-$F5238 LOCAL
    Winder_DefaultState:
    {
        JSR Sprite3_CheckDamage
        JSR Winder_SpawnFireballGarnish
        
        LDA $0E70, X : BNE .tile_collision_prev_frame
        
        JSR Sprite3_Move
    
    .tile_collision_prev_frame
    
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision_this_frame
        
        ; Pick a new direction at random
        JSL GetRandomInt : LSR A : LDA $0DE0, X : ROL A : TAY
        
        LDA $9254, Y : STA $0DE0, X
    
    .no_tile_collision_this_frame
    
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$F5239-$F528C LOCAL
    Winder_SpawnFireballGarnish:
    {
        TXA : EOR $1A : AND.b #$07 : BNE .delay
        
        PHX : TXY
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        PLX
        
        RTS
    
    .empty_slot
    
        LDA.b #$01 : STA $7FF800, X : STA $0FB4
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$20 : STA $7FF90E, X
        
        TYA : STA $7FF92C, X
        
        LDA $0F20, Y : STA $7FF968, X
        
        PLX
    
    .delay
    
        RTS
    }

; ==============================================================================
