
; ==============================================================================

    ; *$F3BB9-$F3BDA JUMP LOCATION
    Sprite_FlyingTile:
    {
        LDA.b #$30 : STA $0B89, X
        
        JSR FlyingTile_Draw
        JSR Sprite3_CheckIfActive.permissive
        
        LDA $0EF0, X : BNE FlyingTile_Shatter
        
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FlyingTile_EraseTilemapEntries
        dw FlyingTile_RiseUp
        dw FlyingTile_CareenTowardsPlayer
    }

; ==============================================================================

    ; *$F3BDB-$F3C00 JUMP LOCATION
    FlyingTile_EraseTilemapEntries:
    {
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        
        LDA $0D00, X : ADD.b #$08 : STA $02
        LDA $0D20, X              : STA $03
        
        LDY.b #$06 : JSL Dungeon_SpriteInducedTilemapUpdate
        
        INC $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; *$F3C01-$F3C4E JUMP LOCATION
    FlyingTile_CareenTowardsPlayer:
    {
        STZ $0BA0, X
        
        ; \note This is why the tiles give up after a short while. These could
        ; be made really nasty with some adjustments...
        LDA $0DF0, X : BEQ .dont_refresh_player_tracking
        AND.b #$03   : BNE .dont_refresh_player_tracking
        
        JSR FlyingTile_TrackPlayer
    
    .dont_refresh_player_tracking
    
        JSR Sprite3_CheckDamage : BCS .shatter
        
        JSR Sprite3_Move
        
        LDA $0FDA : SUB $0F70, X : STA $0FDA
        LDA $0FDB : SBC.b #$00   : STA $0FDB
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
    
    .shatter
    
    ; $F3C2F ALTERNATE ENTRY POINT
    shared FlyingTile_Shatter:
    
        LDA.b #$1F : JSL Sound_SetSfx2PanLong
        
        LDA.b #$06 : STA $0DD0, X
        
        LDA.b #$1F : STA $0DF0, X
        
        LDA.b #$EC : STA $0E20, X
        
        STZ $0EF0, X
        
        LDA.b #$80 : STA $0DB0, X
        
        RTS
    
    .no_tile_collision
    
        BRA FlyingTile_NoisilyAnimate
    }

; ==============================================================================

    ; *$F3C4F-$F3C89 JUMP LOCATION
    FlyingTile_RiseUp:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
    
    ; *$F3C5C ALTERNATE ENTRY POINT
    shared FlyingTile_TrackPlayer:
    
        LDA.b #$20
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        RTS
    
    .delay
    
        CMP.b #$40 : BCC .stop_rising
        
        LDA.b #$04 : STA $0F80, X
        
        JSR Sprite3_MoveAltitude
    
    .stop_rising
    
    ; *$F3C6F ALTERNATE ENTRY POINT
    shared FlyingTile_NoisilyAnimate:
    
        INC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$01 : STA $0DC0, X
        
        TXA : EOR $1A : AND.b #$07 : BNE .delay_sfx
        
        LDA.b #$07 : JSL Sound_SetSfx2PanLong
    
    .delay_sfx
    
        RTS
    }

; ==============================================================================

    ; $F3C8A-$F3CC9 DATA
    pool FlyingTile_Draw:
    {
    
    .oam_groups
        dw 0, 0 : db $D3, $00, $00, $00
        dw 8, 0 : db $D3, $40, $00, $00
        dw 0, 8 : db $D3, $80, $00, $00
        dw 8, 8 : db $D3, $C0, $00, $00
        
        dw 0, 0 : db $C3, $00, $00, $00
        dw 8, 0 : db $C3, $40, $00, $00
        dw 0, 8 : db $C3, $80, $00, $00
        dw 8, 8 : db $C3, $C0, $00, $00
    }

; ==============================================================================

    ; *$F3CCA-$F3CE7 LOCAL
    FlyingTile_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JSR Sprite3_DrawMultiple
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
