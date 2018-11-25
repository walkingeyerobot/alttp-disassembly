
    ; Two statistically likely candidates for pederasty all rolled into
    ; one file.

; ==============================================================================

    ; *$2DA29-$2DA30 LONG
    SpritePrep_UncleAndSageLong:
    {
        PHB : PHK : PLB
        
        JSR SpritePrep_UncleAndSage
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $2DA31-$2DA3C DATA
    pool SpritePrep_UncleAndSage:
    {
    
    .x_offsets
        dw -6, -6, -6
    
    .y_offsets
        dw  0, -9,  0
    }

; ==============================================================================

    ; *$2DA3D-$2DB22 LOCAL
    SpritePrep_UncleAndSage:
    {
        LDA $A0 : CMP.b #$12 : BEQ .in_sanctuary
        
        JMP .not_sage
    
    .in_sanctuary
    
        JSR Sage_SpawnMantle
        
        LDA $7EF3C5 : CMP.b #$03 : BCC .agahnim_not_defeated
        
        LDA $7EF3C6 : ORA.b #$02 : STA $7EF3C6
    
    .agahnim_not_defeated
    
        LDA $7EF3C6 : AND.b #$02 : BEQ .priest_not_already_dead
        
        STZ $0DD0, X
        
        RTS
    
    .priest_not_already_dead
    
        LDA.b #$01 : STA $0E90, X
        
        LDA $0E40, X : AND.b #$F0 : ORA.b #$02 : STA $0E40, X
        
        LDA.b #$03 : STA $0F60, X
        
        LDA $7EF359 : CMP.b #$02 : BCC .dontHaveMasterSword
        
        LDA.b #$04 : STA $0DE0, X
        
        STZ $0DC0, X
        
        LDA.b #$00
        
        BRA .epsilon
    
    .dontHaveMasterSword
    
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03
        
        STA $0EB0, X : STA $0DE0, X
        
        LDA $7EF3CC : CMP.b #$01 : BNE .iota
        
        LDA $7EF3C6 : ORA.b #$04 : STA $7EF3C6
        
        LDA $7EF29B : ORA.b #$20 : STA $7EF29B
        
        LDA.b #$AA : STA $0DF0, X
        
        LDA.b #$01
        
        BRA .epsilon
    
    .iota
    
        LDA.b #$02
    
    .epsilon
    
        STA $0E80, X
        
        ASL A : TAY
        
        LDA .x_offsets + 0, Y : ADD $0D10, X : STA $0D10, X
        LDA .x_offsets + 1, Y : ADC $0D30, X : STA $0D30, X
        
        LDA .y_offsets + 0, Y : ADD $0D00, X : STA $0D00, X
        LDA .y_offsets + 1, Y : ADC $0D20, X : STA $0D20, X
        
        INC $0BA0, X
        
        LDA.b #$00 : STA $7FFE01
        
        RTS
    
    .not_sage
    
        CMP.b #$04 : BNE .not_in_links_house
        
        ; Has your Uncle left to go get owned by two measley low rank green
        ; soldiers?
        LDA $7EF3C6 : AND.b #$10 : BNE .self_terminate
        
        LDA $0D10, X : ADD.b #$08 : STA $0D10, X
        
        RTS
    
    .not_in_links_house
    
        ; Poor dying bastard already gave you his gear?
        LDA $7EF3C6 : AND.b #$01 : BNE .self_terminate
        
        LDA.b #$03 : STA $0DE0, X
        
        LSR A : STA $0E80, X
        
        RTS
    
    .self_terminate
    
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; $2DB23-$2DB26 DATA
    pool Sage_SpawnMantle:
    {
    
    .x_coord
        dw $04F0
    
    .y_coord
        dw $0237
    }

; ==============================================================================

    ; *$2DB27-$2DB85 LOCAL
    Sage_SpawnMantle:
    {
        INC $0DDF
        
        ; Create Sage... actually create the mantle behind him.
        LDA.b #$73
        
        JSL Sprite_SpawnDynamically
        
        STZ $0DDF
        
        LDA $0E40, Y : AND.b #$F0 : ORA.b #$03 : STA $0E40, Y
        
        LDA .x_coord     : STA $0D10, Y
        LDA .x_coord + 1 : STA $0D30, Y
        
        LDA .y_coord     : STA $0D00, Y
        LDA .y_coord + 1 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E90, Y
        
        LDA.b #$0B : STA $0F60, Y
        
        LDA $0CAA, Y : ORA.b #$20 : STA $0CAA, Y
        
        LDA.b #$01 : STA $0E80, Y
        
        LDA $0D00, Y : STA $00
        LDA $0D20, Y : STA $01
        
        REP #$30
        
        LDA $20 : CMP $00 : SEP #$30 : BCS .player_below_mantle
        
        ; Otherwise initialize it as moving to the right (opening up).
        LDA.b #$01 : STA $0DB0, Y
    
    .player_below_mantle
    
        RTS
    }

; ==============================================================================

    ; *$2DB86-$2DB8D LONG
    Sprite_UncleAndSageLong:
    {
        ; Uncle / Priest
        
        PHB : PHK : PLB
        
        JSR Sprite_UncleAndSage
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2DB8E-$2DB9A LOCAL
    Sprite_UncleAndSage:
    {
        LDA $0E90, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_Uncle
        dw Sprite_Sage
        dw Sprite_SageMantle
    }

; ==============================================================================

    ; *$2DB9B-$2DBD2 JUMP LOCATION
    Sprite_SageMantle:
    {
        JSR SageMantle_Draw
        JSR Sprite2_CheckIfActive
        
        LDA $0DB0, X : BNE SageMantle_SlidingRight
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong  
        
        BCC SageMantle_NoPlayerCollision
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Sprite_RepelDashAttackLong
        
        LDA.b #$07 : STA $0E00, X
    
    ; *$2DBBB ALTERNATE ENTRY POINT
    shared SageMantle_RecentPlayerContact:
    
        STZ $0E80, X
        
        LDA.b #$81 : STA $48
        
        LDA.b #$08 : STA $5E
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $DC00 ; = $2DC00*
        dw $DC39 ; = $2DC39*
        dw $DC52 ; = $2DC52*
    }

; ==============================================================================

    ; *$2DBD3-$2DBE2 BRANCH LOCATION
    SageMantle_NoPlayerCollision:
    {
        ; \task These label names just suck, but they'll do for now.
        ; namenate this whole file better.
        LDA $0E00, X : BNE SageMantle_RecentPlayerContact
        
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $DBF5 ; = $2DBF5*
        dw SageMantle_DoNothing
    }

; ==============================================================================

    ; *$2DBE3-$2DBF4 BRANCH LOCATION
    SageMantle_SlidingRight:
    {
        LDA.b #$40 : STA $0D90, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $DC00 ; = $2DC00*
        dw $DC39 ; = $2DC39*
        dw $DC52 ; = $2DC52*
    }

; ==============================================================================

    ; *$2DBF5-$2DBFF JUMP LOCATION
    {
        STZ $0D90, X
        
        STZ $48
        
        STZ $5E
        
        INC $0E80, X
    
    ; $2DBFF ALTERNATE ENTRY POINT
    shared SageMantle_DoNothing:
    
        RTS
    }

; ==============================================================================

    ; *$2DC00-$2DC38 JUMP LOCATION
    {
        LDA $0D10, X : PHA : ADD.b #$13 : STA $0D10, X
        LDA $0D30, X : PHA : ADC.b #$00 : STA $0D30, X
        
        JSR Sprite2_DirectionToFacePlayer
        
        PLA : STA $0D30, X
        PLA : STA $0D10, X
        
        CPY.b #$03 : BEQ .alpha
        CPY.b #$01 : BNE .beta
    
    .alpha
    
        INC $0D90, X
        
        LDA $0D90, X : CMP.b #$40 : BCC .beta
        
        INC $0D80, X
        
        LDA.b #$01 : STA $02E4
    
    .beta
    
        RTS
    }

; ==============================================================================

    ; *$2DC39-$2DC51 JUMP LOCATION
    {
        LDA.b #$18 : JSL Sound_SetSfx3PanLong
        
        INC $0D80, X
        
        LDA.b #$A8 : STA $0DF0, X
        
        LDA.b #$03 : STA $0D50, X
        
        LDA.b #$02 : STA $0E00, X
        
        RTS
    }

; ==============================================================================

    ; *$2DC52-$2DC69 JUMP LOCATION
    {
        JSR Sprite2_Move
        
        LDA $0DF0, X : BNE .alpha
        
        STZ $02E4
        
        STZ $0D50, X
        STZ $0DB0, X
        
        RTS
    
    .alpha
    
        LDA.b #$02 : STA $0E00, X
        
        RTS
    }

; ==============================================================================

    ; $2DC6A-$2DC89 DATA
    pool SageMantle_Draw:
    {
    
    .animation_states
        db  0,  0 : db $2C, $16, $00, $02
        db 16,  0 : db $2C, $56, $00, $02
        db  0, 16 : db $2E, $06, $00, $02
        db 16, 16 : db $2E, $46, $00, $02
    }

; ==============================================================================

    ; *$2DC8A-$2DCA1 LOCAL
    SageMantle_Draw:
    {
        ; $2DC6A
        LDA.b (.animation_states >> 0) : STA $08
        LDA.b (.animation_states >> 8) : STA $09
        
        LDA $0DB0, X : BNE .moving
        
        LDA.b #$10 : JSL OAM_AllocateFromRegionB
    
    .moving
    
        LDA.b #$04
        
        JMP Sprite_DrawMultipleRedundantCall
    }

; ==============================================================================

    ; *$2DCA2-$2DCDD LONG
    Sprite_MakeBodyTrackHeadDirection:
    {
        LDA $0DE0, X : CMP $0EB0, X : BEQ .set_body_to_head_dir
        
        LDA $1A : AND.b #$1F : BNE .frame_not_multiple_of_32
        
        ; If only one of them is facing left or right, make the body match.
        LDA $0DE0, X : EOR $0EB0, X : AND.b #$02 : BNE .set_body_to_head_dir
        
        ; This seems like an attempt to semi-randomly set the body orientation
        ; to left or right, possibly to recover from an unusual state?
        TXA : EOR $1A : LSR #5 : ORA.b #$02 : AND.b #$03 : STA $0DE0, X
        
        ; If the head is facing up or down, this has no effect.
        ; Otherwise, it will force the body to a direction perpendicular to
        ; the head.
        LDA $0EB0, X : AND.b #$02 : EOR $0DE0, X : STA $0DE0, X
    
    .frame_not_multiple_of_32
    
        CLC
        
        RTL
    
    .set_body_to_head_dir
    
        LDA $0EB0, X : STA $0DE0, X
        
        SEC
        
        RTL
    }

; ==============================================================================

    ; $2DCDE-$2DCE5 DATA (UNUSED)
    pool Sprite_Sage:
    {
        ; Probably unused because, to my knowledge, the priest never moves at
        ; all.
        
    .x_speeds
        db $00, $00, $F7, $09
    
    .y_speeds
        db $F7, $09, $00, $00
    }

; ==============================================================================

    ; *$2DCE6-$2DD09 JUMP LOCATION
    Sprite_Sage:
    {
        LDA $0D90, X : BNE .dont_draw
        
        JSL Priest_Draw
    
    .dont_draw
    
        JSR Sprite2_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSL Sprite_MakeBodyTrackHeadDirection
        JSR Sprite2_Move
        
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sage_MortallyWounded
        dw $DD63 ; = $2DD63*
        dw $DDE5 ; = $2DDE5*
    }

; ==============================================================================

    ; *$2DD0A-$2DD1E JUMP LOCATION
    Sage_MortallyWounded:
    {
        LDA.b #$04 : STA $0EB0, X : STA $0DE0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sage_DyingWords
        dw Sage_DeathFlash
        dw Sage_Terminate
    }

; ==============================================================================

    ; *$2DD1F-$2DD3E JUMP LOCATION
    Sage_DyingWords:
    {
        ; "You are a second too late... I have failed..." message from dying priest.
        LDA.b #$1B
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .textNotTriggered
        
        INC $0D80, X
        
        INC $0DC0, X
        
        LDA $7EF3C6 : ORA.b #$02 : STA $7EF3C6
        
        LDA.b #$80 : STA $0E10, X
    
    .textNotTriggered
    
        RTS
    }

; ==============================================================================

    ; *$2DD3F-$2DD5E JUMP LOCATION
    Sage_DeathFlash:
    {
        ; Because we all know people flash when they die, right?
        
        STZ $0DC0, X
        
        LDA $0E10, X : BNE .wait
        
        INC $0D80, X
    
    .wait
    
        ; Only draw the sprite every other frame (b/c he's dying).
        LDA $1A : AND.b #$02 : STA $0D90, X
        
        LDA $0E10, X : AND.b #$07 : BNE .dont_play_sound
        
        LDA.b #$33 : JSL Sound_SetSfx2PanLong
    
    .dont_play_sound
    
        RTS
    }

; ==============================================================================

    ; *$2DD5F-$2DD62 JUMP LOCATION
    Sage_Terminate:
    {
        ; Well this is pretty pointless, why didn't we just kill him off
        ; in the previous AI state?
        
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; *$2DD63-$2DD71 JUMP LOCATION
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $DD72 ; = $2DD72*
        dw $DD9F ; = $2DD9F*
        dw $DDB3 ; = $2DDB3*
        dw $DDC5 ; = $2DDC5*
    }

; ==============================================================================

    ; $2DD72-$2DD9E JUMP LOCATION
    {
        LDA.b #$00 : STA $0EB0, X : STA $0DE0, X
        
        LDA $0DF0, X : BNE .alpha
        
        ; "Princess Zelda, you are safe! Is this your doing, [Name]?" message
        LDA.b #$17
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA.b #$01 : STA $7FFE01
        
        JSR Zelda_TransitionFromTagalong
        
        LDA.b #$01 : STA $02E4
        
        LDA.b #$01 : STA $7EF3C7
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$2DD9F-$2DDB2 JUMP LOCATION
    {
        LDA $7FFE01 : CMP.b #$02 : BNE .alpha
        
        ; "I sense that a mighty force guides the wizard's actions an
        LDA.b #$18
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$2DDB3-$2DDC4 JUMP LOCATION
    {
        LDA $1CE8 : BNE .alpha
        
        INC $0D80, X
        
        STZ $02E4
        
        RTS
    
    .alpha
    
        LDA.b #$01 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2DDC5-$2DDDE JUMP LOCATION
    {
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDA.b #$16
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .alpha
        
        ; "Meet the elder of the village and get the master sword" message
        STA $0DE0, X
        STA $0EB0, X
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; $2DDDF-$2DDE4 DATA
    {
    
    .messages_low
        db $16, $19, $1A
    
    .messages_high
        db $00, $00, $00
    }

; ==============================================================================

    ; *$2DDE5-$2DE23 JUMP LOCATION
    {
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDY.b #$00
        
        LDA $7EF374 : AND.b #$07 : CMP.b #$07 : BNE .need_moar_pendants
        
        LDY.b #$02
        
        BRA .beta
    
    .need_moar_pendants
    
        LDA $7EF3C7 : CMP.b #$03 : BCC .beta
        
        LDY.b #$01
    
    .beta
    
        LDA $DDDF, Y       : XBA
        LDA $DDE2, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .gamma
        
        STA $0DE0, X
        STA $0EB0, X
        
        LDA.b #$A0 : STA $7EF372
    
    .gamma
    
        RTS
    }

; ==============================================================================

    ; $2DE24-$2DE2B DATA
    pool Uncle_LeavingHouse:
    {
    
    .x_speeds
        db $00, $00, $F4, $0C
    
    .y_speeds
        db $F4, $0C, $00, $00
    }

; ==============================================================================

    ; *$2DE2C-$2DE3D JUMP LOCATION
    Sprite_Uncle:
    {
        JSL Uncle_Draw
        JSR Sprite2_CheckIfActive
        
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Uncle_AtHome
        dw Uncle_InSecretPassage
    }

; ==============================================================================

    ; *$2DE3E-$2DE51 JUMP LOCATION
    Uncle_AtHome:
    {
        JSR Sprite2_Move
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Uncle_TelepathicZeldaPlea
        dw Uncle_WakeUpPlayer
        dw Uncle_TellPlayerToStay
        dw Uncle_LeavingHouse
        dw Uncle_AttachZeldaTelepathTagalong
    }

; ==============================================================================

    ; *$2DE52-$2DE71 JUMP LOCATION
    Uncle_TelepathicZeldaPlea:
    {
        ; Set Link's coordinates to this specific position.
        LDA.b #$40 : STA $0FC2
        LDA.b #$09 : STA $0FC3
        
        LDA.b #$5A : STA $0FC4
        LDA.b #$21 : STA $0FC5
        
        ; "Help me... Please help me...  I am a prisoner in the dungeon of the
        ; castle..."
        LDA.b #$1F
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2DE72-$2DE99 JUMP LOCATION
    Uncle_WakeUpPlayer:
    {
        ; Lighten the screen gradually and then wake Link up partially
        
        LDA $1A : AND.b #$03 : BNE .delay
        
        LDA $9C : CMP.b #$20 : BEQ .colorTargetReached
        
        DEC $9C
        DEC $9D
    
    .delay
    
        RTS
    
    .colorTargetReached
    
        INC $0D80, X
        
        INC $037D
        INC $037C
        
        LDA.b #$57 : STA $20
        LDA.b #$21 : STA $21
        
        LDA.b #$01 : STA $02E4
        
        RTS
    }

; ==============================================================================

    ; *$2DE9A-$2DEAF JUMP LOCATION
    Uncle_TellPlayerToStay:
    {
        LDA.b #$0D
        LDY.b #$00
        
        ; [Name], I'm going out for a while. I'll be back by morning..." message
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA.b #$03 : STA $012C
        
        LDA.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2DEB0-$2DEB3 DATA
    pool Uncle_LeavingHouse:
    {
    
    .timers
        db $40, $E0
        
    .directions
        db 2, 1
    }

; ==============================================================================

    ; *$2DEB4-$2DEF7 JUMP LOCATION
    Uncle_LeavingHouse:
    {
        LDA $0DF0, X : BNE .moving
        
        LDY $0D90, X : BNE .already_stood_up
        
        ; Do a one time y coord adjustment that basically is your uncle
        ; standing up to leave.
        LDA $0D00, X : SUB #$02 : STA $0D00, X
    
    .already_stood_up
    
        LDA .data_timers, Y : STA $0DF0, X
        
        LDA .data_directions, Y : STA $0DE0, X : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        LDA .y_speeds, Y : STA $0D40, X
        
        INC $0D90, X
        
        ; \bug Confirmed that this is a bug in that it reads past the end of its
        ; designated arrays (.timer, .directions, .x_speeds, .y_speeds) by one
        ; right before the Uncle sprite self terminates. Other than that, it
        ; shouldn't have any negative impact. I'd recommend rewriting it to
        ; avoid this problem, though.
        LDA $0D90, X : CMP.b #$03 : BNE .hasnt_fully_left_yet
        
        INC $0D80, X
    
    .moving
    .hasnt_fully_left_yet
    
        ; Change animation state every 8 frames...
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$2DEF8-$2DF18 JUMP LOCATION
    Uncle_AttachZeldaTelepathTagalong:
    {
        ; Sets up Zelda to bitch at you to get into the castle.
        LDA.b #$05 : STA $7EF3CC
        
        LDA.b #$F3 : STA $02CD
        LDA.b #$0D : STA $02CE
        
        ; Make it so Link's uncle never respawns in the house again.
        LDA $7EF3C6 : ORA.b #$10 : STA $7EF3C6
        
        STZ $0DD0, X
        
        STZ $02E4
        
        RTS
    }

; ==============================================================================

    ; *$2DF19-$2DF25 JUMP LOCATION
    Uncle_InSecretPassage:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Uncle_RemoveZeldaTelepathTagalong
        dw Uncle_GiveSwordAndShield
        dw Uncle_PassedOut
    }

; ==============================================================================

    ; *$2DF26-$2DF43 JUMP LOCATION
    Uncle_RemoveZeldaTelepathTagalong:
    {
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_not_close
        
        JSL Player_HaltDashAttackLong
    
    .player_not_close
    
        LDA.b #$0E
        LDY.b #$00
        
        ; "Unnh... [Name], I didn't want you involved in this..."
        JSL Sprite_ShowMessageFromPlayerContact : BCC .player_not_close_2
        
        ; Your Uncle frees you from Zelda’s bitching >_<.
        LDA.b #$00 : STA $7EF3CC
        
        INC $0D80, X
    
    .player_not_close_2
    
    shared Uncle_PassedOut:
    
        RTS
    }

; ==============================================================================

    ; *$2DF44-$2DF6B JUMP LOCATION
    Uncle_GiveSwordAndShield:
    {
        LDY.b #$00
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        INC $0D80, X
        
        LDA.b #$01 : STA $0DC0, X
        
        LDA.b #$03 : STA $7EF3C8
        
        LDA $7EF3C6 : ORA.b #$01 : STA $7EF3C6
        
        LDA.b #$01 : STA $7EF3C5
        
        RTS
    }

; ==============================================================================

