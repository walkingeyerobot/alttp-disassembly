; ==============================================================================

    ; $2AA87-$2AA8A DATA
    pool Sprite_Keese:
    {
    
    .starting_speeds_indices
        db $02, $0A, $06, $0E
    }

; ==============================================================================

    ; *$2AA8B-$2AAE1 JUMP LOCATION
    Sprite_Keese:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        
        LDA $0D80, X : BNE Keese_Agitated
        
        TXA : EOR $1A : AND.b #$03 : ORA $0DF0, X : BNE .delay
        
        JSR Sprite2_DirectionToFacePlayer
        
        LDA $0E : ADD.b #$28 : CMP.b #$50 : BCS .player_not_close
        
        LDA $0F : ADD.b #$28 : CMP.b #$50 : BCS .player_not_close
        
        LDA.b #$1E : JSL Sound_SetSfx3PanLong
        
        ; Keese gets mad when you invade its personal space :(.
        INC $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
                     STA $0DA0, X
        
        JSR Sprite2_DirectionToFacePlayer
        
        LDA .starting_speeds_indices, Y : STA $0D90, X
    
    .player_not_close
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2AAE2-$2AB03 DATA
    pool Keese_Agitated:
    {
    
    .index_step
        db 1, -1
    
    .random_x_speeds
        db   0,   8,  11,  14,  16,  14,  11,   8
        db   0,  -8, -11, -14, -16, -14, -11,  -8
    
    .random_y_speeds
        db -11,  -8, -16, -14, -11,  -8,   0,   8
        db  11,  14,  16,  14,  11,   8,   0,  -9
    }

; ==============================================================================

    ; *$2AB04-$2AB53 BRANCH LOCATION
    Keese_Agitated:
    shared Keese_JimmiesRustled:
    {
        LDA $0DF0, X : BNE .still_agitated
        
        STZ $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        STZ $0DC0, X
        
        JSR Sprite2_ZeroVelocity
        
        RTS
    
    .still_agitated
    
        AND.b #$07 : BNE .beta
        
        LDA $0DA0, X : AND.b #$01 : TAY
        
        LDA $0D90, X : ADD .index_step, Y : STA $0D90, X
        
        JSL GetRandomInt : AND.b #$03 : BNE .beta
        
        INC $0DA0, X
    
    .beta
    
        LDA $0D90, X : AND.b #$0F : TAY
        
        LDA .random_x_speeds, Y : STA $0D50, X
        
        LDA .random_y_speeds, Y : STA $0D40, X
        
        LDA $1A : LSR #2 : AND.b #$01 : INC A : STA $0DC0, X
        
        RTS
    }

; ==============================================================================
