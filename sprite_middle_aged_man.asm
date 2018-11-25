
; ==============================================================================

    ; *$33CAC-$33CC8 JUMP LOCATION
    Sprite_MiddleAgedMan:
    {
        ; Middle aged guy in the desert
        
        JSR MiddleAgedMan_Draw
        JSR Sprite_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MiddleAgedMan_Chillin
        dw MiddleAgedMan_TransitionToTagalong
        dw MiddleAgedMan_OfferChestOpening
        dw MiddleAgedMan_ReactToSecretKeepingResponse
        dw MiddleAgedMan_PromiseReminder
        dw MiddleAgedMan_SilenceDueToOtherTagalong
    }

; ==============================================================================

    ; *$33CC9-$33D00 JUMP LOCATION
    MiddleAgedMan_Chillin:
    {
        ; "... .... ..... ......"
        LDA.b #$07
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        LDA $0D10, X : PHA
        
        SUB.b #$10 : STA $0D10, X
        
        JSR Sprite_Get_16_bit_Coords
        
        LDA.b #$01 : STA $0D50, X : STA $0D40, X
        
        JSL Sprite_CheckTileCollisionLong : BNE .sign_wasnt_taken
        
        INC $0D80, X
        
        LDA $7EF3CC : CMP.b #$00 : BEQ .player_lacks_tagalong
        
        LDA.b #$05 : STA $0D80, X
    
    .player_lacks_tagalong
    .sign_wasnt_taken
    
        PLA : STA $0D10, X
        
        RTS
    }

; ==============================================================================

    ; *$33D01-$33D1F JUMP LOCATION
    MiddleAgedMan_TransitionToTagalong:
    {
        LDA.b #$09 : STA $7EF3CC
        
        PHX
        
        STZ $02F9
        
        JSL Tagalong_LoadGfx
        JSL Tagalong_Init
        
        PLX
        
        LDA.b #$40 : STA $02CD
                     STZ $02CE
        
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; *$33D20-$33D45 JUMP LOCATION
    MiddleAgedMan_OfferChestOpening:
    {
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .return
        
        ; \optimize He says the same thing regardless of whether the chest
        ; is close by.
        LDA $7EF3D3 : BEQ .chest_connected_to_player
        
        LDA.b #$09  ; Message from the middle aged man saying he'll open
        LDY.b #$01  ; the chest for you.
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .return
        
        BRA .advance_ai_state
    
    .chest_connected_to_player
    
        LDA.b #$09
        LDY.b #$01
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .return
    
    .advance_ai_state
    
        INC $0D80, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$33D46-$33D89 JUMP LOCATION
    MiddleAgedMan_ReactToSecretKeepingResponse:
    {
        LDA $1CE8 : BNE .angry_reply
        
        LDA $7EF3D3 : BEQ .chest_directly_connected_to_player
        
        LDA #$0C
        LDY #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$02 : STA $0D80, X
        
        RTS
    
    .chest_directly_connected_to_player
    
        ; Give Link an empty bottle... but from who? Middle aged guy?
        LDY.b #$16
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        LDA $7EF3C9 : ORA.b #$10 : STA $7EF3C9
        
        INC $0D80, X
        
        LDA.b #$00 : STA $7EF3CC
        
        RTS
    
    .angry_reply
    
        ; "OK, ..., I hope you drag that chest around forever!"
        LDA.b #$0A
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$02 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$33D8A-$33D92 JUMP LOCATION
    MiddleAgedMan_PromiseReminder:
    {
        ; "Remember, you promised... Don't tell anyone."
        LDA.b #$0B
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$33D93-$33D9B JUMP LOCATION
    MiddleAgedMan_SilenceDueToOtherTagalong:
    {
        ; "... .... ..... ......"
        LDA.b #$07
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; $33D9C-$33DAB DATA
    pool MiddleAgedMan_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $EA, $00, $00, $02
        dw 0,  0 : db $EC, $00, $00, $02
    }

; ==============================================================================

    ; *$33DAC-$33DC0 LOCAL
    MiddleAgedMan_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA.b #.oam_groups    : STA $08
        LDA.b #.oam_groups>>8 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JMP Sprite_DrawShadow
    }

; ==============================================================================

