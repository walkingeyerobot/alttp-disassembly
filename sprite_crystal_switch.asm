
; ==============================================================================

    ; $338CE-$338CF DATA
    pool Sprite_CrystalSwitch:
    {
    
    .palettes
        db $02, $04
    }

; ==============================================================================

    ; *$338D0-$3394B JUMP LOCATION
    Sprite_CrystalSwitch:
    {
        ; And the palette value with 0xF1
        LDA $0F50, X : AND.b #$F1 : STA $0F50, X
        
        ; Blue / Orange barrier state
        LDA $7EC172 : AND.b #$01 : TAY
        
        ; Select the palette for the peg switch based on that state.
        LDA .palettes, Y : ORA $0F50, X : STA $0F50, X
        
        JSR OAM_AllocateDeferToPlayer
        JSR Sprite_PrepAndDrawSingleLarge
        JSR Sprite_CheckIfActive
        
        JSR Sprite_CheckDamageToPlayer_same_layer : BCC .no_player_collision
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Sprite_RepelDashAttackLong
    
    .no_player_collision
    
        LDA $0DF0, X : BNE .skipSparkleGeneration
        
        LDA $1A : AND.b #$07 : STA $00
                               STZ $01
        
        JSL GetRandomInt : AND.b #$07 : STA $02
                                        STZ $03
        
        ; Attempt to add a sparkle effect
        JSL Sprite_SpawnSimpleSparkleGarnish
        
        ; Restart sparkle countdown timer.
        LDA.b #$1F : STA $0DF0, X
    
    .skipSparkleGeneration
    
        LDA $0EA0, X : BNE .switching_already_scheduled
        
        LDA $3C : DEC A : CMP.b #$08 : BPL .ignore_player_poke_attack
        
        JSR Sprite_CheckDamageFromPlayer
    
    .ignore_player_poke_attack
    
        RTS
    
    .switching_already_scheduled
    
        DEC $0EA0, X : CMP.b #$0B : BNE .dont_switch_state
        
        ; Change the orange/blue barrier state
        LDA $7EC172 : EOR.b #$01 : STA $7EC172
        
        LDA.b #$16 : STA $11
        
        LDA.b #$25 : JSL Sound_SetSfx3PanLong
    
    .dont_switch_state
    
        RTS
    }

; ==============================================================================

