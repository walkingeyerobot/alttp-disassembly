
; ==============================================================================

    ; *$E8129-$E814E JUMP LOCATION
    Sprite_Stal:
    {
        LDA $0FC6 : CMP.b #$03 : BCS .improper_gfx_set_loaded
        
        LDA $0D80, X : BNE .ignore_player_oam_overlap
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
    
    .ignore_player_oam_overlap
    
        JSR Stal_Draw
    
    .improper_gfx_set_loaded
    
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckIfRecoiling
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Stal_Dormant
        dw Stal_Active
    }

; ==============================================================================

    ; *$E814F-$E8197 JUMP LOCATION
    Stal_Dormant:
    {
        LDA.b #$01 : STA $0BA0, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_didnt_bump
        
        JSL Sprite_NullifyHookshotDrag
        JSL Sprite_RepelDashAttackLong
        
        LDA $0DF0, X : BNE .still_activating
        
        LDA.b #$40 : STA $0DF0, X
        
        LDA.b #$22 : JSL Sound_SetSfx2PanLong
    
    .still_activating
    .player_didnt_bump
    
        LDA $0DF0, X : BEQ .never_bumped
        DEC A        : BEQ .fully_activated
        
        ORA.b #$40 : STA $0EF0, X
    
    .never_bumped
    
        RTS
    
    .fully_activated
    
        STZ $0BA0, X
        
        INC $0D80, X
        
        STZ $0EF0, X
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        ; Unse the top bit of this variable so that it can start damaging
        ; the player from contact.
        ASL $0E40, X : LSR $0E40, X
        
        RTS
    }

; ==============================================================================

    ; $E8198-$E819C DATA
    pool Stal_Active:
    {
    
    .animation_states
        db $02, $02, $01, $00, $01
    }

; ==============================================================================

    ; *$E819D-$E81DB JUMP LOCATION
    Stal_Active:
    {
        JSR Sprite4_CheckDamage
        JSR Sprite4_Move
        JSR Sprite4_CheckTileCollision
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .not_grounded
        
        STZ $0F70, X
        
        LDA.b #$10 : STA $0F80, X
        
        LDA.b #$0C
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
    
    .not_grounded
    
        LDA $1A : AND.b #$03 : BNE .anotick_animation_timer
        
        INC $0E80, X
        
        LDA $0E80, X : CMP.b #$05 : BNE .anoreset_animation_timer
        
        STZ $0E80, X
    
    .anoreset_animation_timer
    .anotick_animation_timer
    
        LDY $0E80, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $E81DC-$E820B DATA
    pool Stal_Draw:
    {
    
    .oam_groups
        dw 0,  0 : db $44, $00, $00, $02
        dw 4, 11 : db $70, $00, $00, $00
        
        dw 0,  0 : db $44, $00, $00, $02
        dw 4, 12 : db $70, $00, $00, $00
        
        dw 0,  0 : db $44, $00, $00, $02
        dw 4, 13 : db $70, $00, $00, $00
    }

; ==============================================================================

    ; *$E820C-$E8234 LOCAL
    Stal_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #$81DC : STA $08
        
        SEP #$20
        
        LDA.b #$02
        
        LDY $0D80, X : BNE .active
        
        DEC A
    
    .active
    
        JSL Sprite_DrawMultiple
        
        LDA $0D80, X : BEQ .dormant
        
        JSL Sprite_DrawShadowLong
    
    .dormant
    
        RTS
    }

; ==============================================================================
