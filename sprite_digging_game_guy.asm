
; ==============================================================================

    ; *$EFC38-$EFC5A JUMP LOCATION
    Sprite_DiggingGameGuy:
    {
        ; Diggging game guy' code
        
        JSR DiggingGameGuy_Draw
        JSR Sprite4_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSR Sprite4_Move
        
        STZ $0D50, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw DiggingGameGuy_Introduction
        dw DiggingGameGuy_DoYouWantToPlay
        dw DiggingGameGuy_MoveOuttaTheWay
        dw DiggingGameGuy_StartMinigameTimer
        dw DiggingGameGuy_TerminateMinigame
        dw DiggingGameGuy_ComeBackLater
    }

; ==============================================================================

    ; *$EFC5B-$EFC88 JUMP LOCATION
    DiggingGameGuy_Introduction:
    {
        ; If player is more than 7 pixels away...
        LDA $0D00, X : ADD.b #$07 : CMP $20 : BCS .return 
        
        ; If Link is not below this sprite.
        JSR Sprite4_DirectionToFacePlayer : CPY.b #$02 : BNE .return
        
        ; Do we have a follower?
        LDA $7EF3CC : BNE .freak_out_over_tagalong
        
        ; "Welcome to the treasure field. The object is to dig as many..."
        LDA.b #$87
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .return
        
        INC $0D80, X
    
    .return
    
        RTS
    
    .freak_out_over_tagalong
    
        ; Not really sure why tagalongs are a big deal to this sprite. I can't
        ; imagine any situations where they'd interfere direction...
        
        ; "I can't tell you details, but it's not a convenient time..."
        LDA.b #$8C
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$EFC89-$EFCDF JUMP LOCATION
    DiggingGameGuy_DoYouWantToPlay:
    {
        LDA $1CE8 : BNE .player_has_no_selected
        
        REP #$20
        
        ; Do you have eighty rupees?
        LDA $7EF360 : CMP.w #$0050 : BCC .player_cant_afford
        
        ; Subtract the eighty rupees
        SBC.w #$0050 : STA $7EF360
        
        SEP #$30
        
        ; "Then I will lend you a shovel. When you have it in your hand..."
        LDA.b #$88
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        ; Increase the AI pointer
        INC $0D80, X
        
        LDA.b #$01 : STA $0DC0, X
        
        LDA.b #$50 : STA $0DF0, X
        
        LDA.b #$00 : STA $7FFE00 : STA $7FFE01
        
        LDA.b #$05 : STA $0E00, X
        
        LDA.b #$01
        
        JSL Sprite_InitializeSecondaryItemMinigame
        
        ; Play the game time music.
        LDA.b #$0E : STA $012C
        
        RTS
    
    .plaer_has_no_selected
    .player_cant_afford

        SEP #$30
        
        ; "You suck for not having enough rupees" msg
        LDA.b #$89
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        ; Reset the sprite back to it's original state.
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$EFCE0-$EFD09 JUMP LOCATION
    DiggingGameGuy_MoveOuttaTheWay:
    {
        LDA $0DF0, X : BNE .wait_for_next_state
        
        INC $0D80, X
        
        LDA.b #$01 : STA $0DC0, X
        
        RTS
    
    .wait_for_next_state
    
        LDA $0E00, X : BNE .wait_to_move
        
        LDA $0DC0, X : EOR.b #$03 : STA $0DC0, X : AND.b #$01 : BEQ .move_not
        
        LDA.b #$F0 : STA $0D50, X
    
    .move_not
    
        LDA.b #$05 : STA $0E00, X
    
    .wait_to_move
    
        RTS
    }

; ==============================================================================

    ; *$EFD0A-$EFD17 JUMP LOCATION
    DiggingGameGuy_StartMinigameTimer:
    {
        INC $0D80, X
        
        ; Sets up a timer for the mini game.
        LDA.b #$00 : STA $04B5
        LDA.b #$1E : STA $04B4
        
        RTS
    }

; ==============================================================================

    ; *$EFD18-$EFD41 JUMP LOCATION
    DiggingGameGuy_TerminateMinigame:
    {
        LDA $04B4 : BEQ .timer_elapsed
                    BMI .timer_elapsed
        
        RTS
    
    .timer_elapsed
    
        LDA $037A : AND.b #$01 : BNE .wait_till_shoveling_finished
        
        LDA.b #$09 : STA $012C
        
        INC $0D80, X
        
        STZ $03FC
        
        ; "OK! Time's up, game over. Come back again. Good bye..."
        LDA.b #$8A :  STA $1CF0
        LDA.b #$01 :  JSR Sprite4_ShowMessageMinimal
        
        LDA.b #$FE : STA $04B4
    
    .wait_till_shoveling_finished
    
        RTS
    }

; ==============================================================================

    ; *$EFD42-$EFD4A JUMP LOCATION
    DiggingGameGuy_ComeBackLater:
    {
        ; "Come back again! I will be waiting for you."
        LDA.b #$8B
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    } 

; ==============================================================================

    ; *$EFD4B-$EFD5B LONG
    DiggingGameGuy_AttemptPrizeSpawnLong:
    {
        PHB : PHK : PLB
        
        LDA $7FFE01 : INC A : STA $7FFE01
        
        JSR DiggingGameGuy_AttemptPrizeSpawn
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EFD5C-$EFD81 LOCAL
    DiggingGameGuy_AttemptPrizeSpawn:
    {
        REP #$20
        
        LDA $20 : CMP.w #$0B18 : SEP #$30 : BCS DiggingGameGuy_GiveItem_nothing
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw DiggingGameGuy_GiveItem.basic
        dw DiggingGameGuy_GiveItem.basic
        dw DiggingGameGuy_GiveItem.basic
        dw DiggingGameGuy_GiveItem.basic
        dw DiggingGameGuy_GiveItem.heart_piece
        dw DiggingGameGuy_GiveItem.nothing
        dw DiggingGameGuy_GiveItem.nothing
        dw DiggingGameGuy_GiveItem.nothing
    }

; ==============================================================================

    ; $EFD82-$EFD89 DATA
    pool DiggingGameGuy_GiveItem:
    {
    
    .x_speeds
        db $F0
        db $10
    
    .x_offsets
        db $00
        db $13
    
    .basic_types
    
        db $DB ; Red Rupee
        db $DA ; Blue Rupee
        db $D9 ; Green Rupee
        db $DF ; Small magic refill
    }
    
; ==============================================================================

    ; *$EFD8A-$EFE02 JUMP LOCATION
    DiggingGameGuy_GiveItem:
    {
    
    .basic
    
        LDA .basic_types, Y : BRA .spawn_item
    
    .nothing
    
        RTS
    
    .heart_piece
    
        ; \tcrf (verified)
        ; In order to get the heart piece from the digging game,
        ; you must dig at least 25 holes. It is possible to get the heart piece
        ; on the 25th hole, just for clarity. This explains why a lot of people
        ; had trouble getting this heart piece, as it can be quite challenging
        ; to dig a large number of holes in this minigame. I've heard an upper
        ; limit of 35 holes per session which I find believable, but the spawn
        ; rate for the heart piece is also roughly 3%, which means it will
        ; likely take several attempts to get the heart piece.
        LDA $7FFE01 : CMP.b #$19 : BCC .nothing
        
        LDA $7FFE00 : BNE .nothing
        
        JSL GetRandomInt : AND.b #$03 : BNE .nothing
        
        LDA.b #$EB : STA $7FFE00
    
    .spawn_item
    
        JSL Sprite_SpawnDynamically
        
        LDX.b #$00
        
        LDA $2F : CMP.b #$04 : BEQ .player_facing_left
        
        INX
    
    .player_facing_left
    
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA.b #$00 : STA $0D40, Y
        LDA.b #$18 : STA $0F80, Y
        LDA.b #$FF : STA $0B58, Y
        LDA.b #$30 : STA $0F10, Y
        
        LDA $22 : ADD .x_offsets, X
                                  AND.b #$F0 : STA $0D10, Y
        LDA $23 : ADC.b #$00                : STA $0D30, Y
        
        LDA $20 : ADD.b #$16 : AND.b #$F0 : STA $0D00, Y
        LDA $21 : ADC.b #$00              : STA $0D20, Y
        
        LDA.b #$00 : STA $0F20, Y
        
        TYX
        
        LDA.b #$30 : JSL Sound_SetSfx3PanLong
        
        RTS
    }

; ==============================================================================

    ; $EFE03-$EFE4A DATA
    pool DiggingGameGuy_Draw:
    {
    
    .oam_groups
        dw  0, -8 : db $40, $0A, $00, $02
        dw  4,  9 : db $56, $0C, $00, $00
        dw  0,  0 : db $42, $0A, $00, $02
        
        dw  0, -8 : db $40, $0A, $00, $02
        dw  0,  0 : db $42, $0A, $00, $02
        dw  0,  0 : db $42, $0A, $00, $02
        
        dw -1, -7 : db $40, $0A, $00, $02
        dw -1,  0 : db $44, $0A, $00, $02
        dw -1,  0 : db $44, $0A, $00, $02
    }

; ==============================================================================

    ; *$EFE4B-$EFE6D LOCAL
    DiggingGameGuy_Draw:
    {
        LDA.b #$03 : STA $06
                     STZ $07
        
        ; ptr = 0xFE03 + (i*24);
        LDA $0DC0, X : ASL A : ADC $0DC0, X : ASL #3
        
        ADC.b #.oam_groups                 : STA $08
        LDA.b #.oam_groups>>8 : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

