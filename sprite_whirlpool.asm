
; ==============================================================================

    ; $F6E56-$F6E59 DATA
    pool Sprite_Whirlpool:
    {
    
    .vh_flip
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; *$F6E5A-$F6EEE JUMP LOCATION
    Sprite_Whirlpool:
    {
        LDA $8A : CMP.b #$1B : BNE .not_world_warp_gate
        
        ; \note This is a hardcoded facility of the whirlpool sprite that
        ; forces it to act as a gate to the Dark World after beating Agahnim.
        ; A consequence of this is that one cannot place a whirlpool in the
        ; water of this area.
        
        JSL Sprite_PrepOamCoordLong
        JSR Sprite3_CheckIfActive
        
        REP #$20
        
        LDA $0FD8 : SUB $22 : ADD.w #$0040
        
        CMP.w #$0051 : BCS .player_not_close_enough
        
        LDA $0FDA : SUB $20 : ADD.w #$000F
        
        CMP.w #$0012 : BCS .player_not_close_enough
        
        SEP #$30
        
        LDA.b #$23 : STA $11
        
        LDA.b #$01 : STA $02DB
        
        STZ $B0
        STZ $27
        STZ $28
        
        LDA.b #$14 : STA $5D
        
        LDA $8A : AND.b #$40 : STA $7B
    
    .player_not_close_enough
    
        SEP #$30
        
        RTS
    
    .not_world_warp_gate
    
        LDA $0F50, X : AND.b #$3F : STA $0F50, X
        
        LDA $1A : LSR #3 : AND.b #$03 : TAY
        
        LDA .vh_flip, Y : ORA $0F50, X : STA $0F50, X
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
        
        REP #$20
        
        LDA $0FD8 : SUB.w #$0005 : STA $0FD8
        
        SEP #$30
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .didnt_touch
        
        ; \task Note sure if this name is right, or how this variable could
        ; be set...?
        LDA $0D90, X : BNE .temporarily_disabled
        
        LDA.b #$2E : STA $11
        
        STZ $B0
    
    .temporarily_disabled
    
        RTS
    
    .didnt_touch
    
        STZ $0D90, X
        
        RTS
    }

; ==============================================================================
