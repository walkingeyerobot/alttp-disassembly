
; ==============================================================================

    ; *$2B703-$2B7DE JUMP LOCATION
    Sprite_Armos:
    {
        JSR Armos_Draw
        
        LDA $0EA0, X : BEQ .not_recoiling
        
        JSR Sprite2_ZeroVelocity
    
    .not_recoiling
    
        JSR Sprite2_CheckIfActive
        JSR Sprite2_MoveAltitude
        
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        LDA $0F70, X : BPL .beta
        
        STZ $0F70, X
        STZ $0F80, X
        
        JSR Sprite2_ZeroVelocity
    
    .beta
    
        LDA $0D80, X : BEQ .gamma
        
        JMP .active
    
    .gamma
    
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDY $0DF0, X : CPY.b #$01 : BNE .delta
        
        AND.b #$BF : STA $0E60, X
        
        INC $0D80, X
        
        ASL $0E40, X : LSR $0E40, X
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        LDA.b #$0B : STA $0F50, X
        
        RTS
    
    .delta
    
        TXA : EOR $1A : AND.b #$03 : BNE .epsilon
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$001F : CMP.w #$003E : BCS .epsilon
        
        LDA $20 : ADD.w #$0008 : SUB $0FDA : ADD.w #$0030 : CMP.w #$0058 : BCS .epsilon
        
        SEP #$20
        
        LDA $0DF0, X : BNE .epsilon
        
        LDA.b #$30 : STA $0DF0, X
        
        LDA.b #$22 : JSL Sound_SetSfx2PanLong
    
    .epsilon
    
        SEP #$20
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .zeta
        
        JSL Sprite_NullifyHookshotDrag
        JSL Sprite_RepelDashAttackLong
    
    .zeta
    
        LDA $0DF0, X : BEQ .theta
        
        LSR A : AND.b #$0E : EOR $0F50, X : STA $0F50, X
    
    .theta
    
        RTS
    
    .active
    
        JSR Sprite2_CheckDamage
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_Move
        JSR Sprite2_CheckTileCollision
        
        LDA $0DF0, X : ORA $0F70, X : BNE .iota
        
        LDA.b #$08 : STA $0DF0, X
        
        LDA.b #$10 : STA $0F80, X
        
        LDA.b #$0C : JSL Sprite_ApplySpeedTowardsPlayerLong
    
    .iota
    
        RTS
    }

; ==============================================================================

    ; $2B7DF-$2B7EE DATA
    pool Armos_Draw:
    {
    
    .oam_groups
        dw 0, -16 : db $C0, $00, $00, $02
        dw 0,   0 : db $E0, $00, $00, $02
    }

; ==============================================================================

    ; *$2B7EF-$2B809 LOCAL
    Armos_Draw:
    {
        ; \task Find out why it would only prep sometimes. Does it use a
        ; different oam region when it's not fully activated?
        LDA $0D80, X : BNE .use_low_priority_oam_region
        
        JSR Sprite2_PrepOamCoord
    
    .use_low_priority_oam_region
    
        REP #$20
        
        LDA.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite_DrawMultipleRedundantCall
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
