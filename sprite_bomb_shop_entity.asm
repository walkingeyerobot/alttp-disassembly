
; ==============================================================================

    ; *$F6111-$F611F JUMP LOCATION
    Sprite_BombShopEntity:
    {
        ; Bomb Shop Guy
        
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_BombShopGuy
        dw Sprite_BombShopBomb
        dw Sprite_BombShopSuperBomb
        dw Sprite_BombShopSnoutPuff
    }

; ==============================================================================

    ; $F6120-$F6133 DATA
    pool Sprite_BombShopGuy:
    {
    
    .messages_low
        db $17, $18
    
    .messages_high
        db $01, $01
    
    .animation_states
        db $00, $01, $00, $01, $00, $01, $00, $01
    
    .timers
        db $FF, $20, $FF, $18, $0F, $18, $FF, $0F
    }

; ==============================================================================

    ; *$F6134-$F618F JUMP LOCATION
    Sprite_BombShopGuy:
    {
        JSR BombShopEntity_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0DF0, X : BNE .delay
        
        LDA $0E90, X : TAY
        
        INC A : AND.b #$07 : STA $0E90, X
        
        LDA .timers, Y : STA $0DF0, X
        
        LDA .animation_states, Y : STA $0DC0, X : BNE .play_breathe_in_sound
        
        LDA.b #$11 : JSL Sound_SetSfx3PanLong
        
        JSR BombShopGuy_SpawnSnoutPuff
        
        BRA .moving_on
    
    .play_breathe_in_sound
    
        LDA.b #$12 : JSL Sound_SetSfx3PanLong
    
    .moving_on
    .delay
    
        LDY.b #$00
        
        LDA $7EF37A : AND.b #$05 : CMP.b #$05 : BNE .dont_have_super_bomb
        
        LDA $7EF3C9 : AND.b #$20 : BEQ .dont_have_super_bomb
        
        ; Change dialogue to reflect that the Super Bomb is present. (Doesn't
        ; actually spawn the super bomb, though. That's done during this
        ; sprite's spawn routine).
        LDY.b #$01
    
    .dont_have_super_bomb
    
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        JSL Sprite_PlayerCantPassThrough
        
        RTS
    }

; ==============================================================================

    ; *$F6190-$F61DE JUMP LOCATION
    Sprite_BombShopBomb:
    {
        JSR BombShopEntity_Draw
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC .didnt_solicit
        
        LDA $7EF370 : PHX : TAX
        
        LDA $0DDB48, X : PLX : CMP $7EF343 : BEQ .dont_need_any_bombs
        
        ; 
        LDA.b #$64
        LDY.b #$00
        
        ; $F739E IN ROM
        JSR $F39E : BCC .player_cant_afford
        
        LDA.b #$1B : STA $7EF375
        
        STZ $0DD0, X
        
        LDA.b #$19
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        LDY.b #$28
        
        JSR $F366 ; $F7366 IN ROM
    
    .didnt_solicit
    
        RTS
    
    .dont_need_any_bombs
    
        LDA.b #$6E
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        JSR $F38A   ; $F738A IN ROM
        
        RTS
    
    .player_cant_afford
    
        JMP $F1A1 ; $F71A1 IN ROM
    }

; ==============================================================================

    ; *$F61DF-$F6215 JUMP LOCATION
    Sprite_BombShopSuperBomb:
    {
        JSR BombShopEntity_Draw
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC .didnt_solicit
        
        LDA.b #$64
        LDY.b #$00
        
        ; $F739E IN ROM
        JSR $F39E : BCC .player_cant_afford
        
        LDA.b #$0D : STA $7EF3CC ; Super Bomb sprite
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        JSL Tagalong_LoadGfx
        JSL Tagalong_SpawnFromSprite
        
        STZ $0DD0, X
        
        LDA.b #$1A
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
    
    .didnt_solicit
    
        RTS
    
    .player_cant_afford
    
        JMP $F1A1 ; $F71A1 IN ROM
    }

; ==============================================================================

    ; $F6216-$F6219 DATA
    pool Sprite_BombShopSnoutPuff:
    {
    
    .properties
        db $04, $44, $C4, $84
    }

; ==============================================================================

    ; *$F621A-$F6255 JUMP LOCATION
    Sprite_BombShopSnoutPuff:
    {
        LDA.b #$04 : JSL OAM_AllocateFromRegionC
        
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite3_CheckIfActive
        
        LDA $0F50, X : AND.b #$30 : STA $0F50, X
        
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA $0F50, X : ORA .properties, Y : STA $0F50, X
        
        INC $0F80, X
        
        JSR Sprite3_MoveAltitude
        
        LDA $0DF0, X : BNE .dont_self_terminate

        STZ $0DD0, X
    
    .dont_self_terminate
    
        LSR #3 : AND.b #$03 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F6256-$F6295 LOCAL
    BombShopGuy_SpawnSnoutPuff:
    {
        ; Spawn Bomb salesman or his bombs?
        LDA.b #$B5 : JSL Sprite_SpawnDynamically
        
        LDA.b #$03 : STA $0E80, Y : STA $0BA0, Y
        
        LDA $00 : ADD.b #$04 : STA $0D10, Y
        LDA $01              : STA $0D30, Y
        
        LDA $02 : ADD.b #$10 : STA $0D00, Y
        LDA $03              : STA $0D20, Y
        
        LDA.b #$04 : STA $0F70, Y
        
        LDA.b #$F4 : STA $0F80, Y
        
        LDA.b #$17 : STA $0DF0, Y
        
        LDA $0E60, Y : AND.b #$EE : STA $0E60, Y
        
        RTS
    }

; ==============================================================================

    ; $F6296-$F62C5 DATA
    pool BombShopEntity_Draw:
    {
    
    .oam_groups
        db 0, 0, $48, $0A, $00, $02
        
        db 0, 0, $4C, $0A, $00, $02
    
    ; \note label just for informative purposes
    .bomb_groups
        db 0, 0, $C2, $04, $00, $02
        
        db 0, 0, $C2, $04, $00, $02
    
    ; \note label just for informative purposes
    .super_bomb_groups
        db 0, 0, $4E, $08, $00, $02
        
        db 0, 0, $4E, $08, $00, $02
    }

; ==============================================================================

    ; *$F62C6-$F62E8 LOCAL
    BombShopEntity_Draw:
    {
        LDA.b #$01 : STA $06
                     STZ $07
        
        LDA $0E80, X : ASL A : ADC $0DC0, X : ASL #3
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
