
; ==============================================================================

    ; $2E3A3-$2E3A6 DATA
    pool Sprite_InnKeeper:
    {
    
    ; "There is a lake swimming with Zoras at the source of the river...".
    ; "...there was a boy in this village who could talk to animals ..."
    .messages_low
        db $82, $83
    
    .messages_high
        db $01, $01
    }

; ==============================================================================

    ; *$2E3A7-$2E3AE LONG
    Sprite_InnKeeperLong:
    {
        ; Inn Keeper (0x35)
        
        PHB : PHK : PLB
        
        JSR Sprite_InnKeeper
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E3AF-$2E3CB LOCAL
    Sprite_InnKeeper:
    {
        JSR InnKeeper_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $7EF356 : TAY
        
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; $2E3CC-$2E3DB DATA
    pool InnKeeper_Draw:
    {
    
    .animation_states
        dw 0, -8 : db $C4, $00, $00, $02
        dw 0,  0 : db $CA, $00, $00, $02
    }

; ==============================================================================

    ; *$2E3DC-$2E3F2 LOCAL
    InnKeeper_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA.b #(.animation_states >> 0) : STA $08
        LDA.b #(.animation_states >> 8) : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
