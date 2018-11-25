
; ==============================================================================

    ; *$2EBC7-$2EBCE LONG
    SpritePrep_ZeldaLong:
    {
        ; Sprite Prep for Princess Zelda (0x76)
        
        PHB : PHK : PLB
        
        JSR SpritePrep_Zelda
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2EBCF-$2EC4B LOCAL
    SpritePrep_Zelda:
    {
        LDA $7EF359 : CMP.b #$02 : BCS .hasMasterSword
        
        INC $0BA0, X
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03
        
        STA $0EB0, X : STA $0DE0, X
        
        LDA $7EF3CC : PHA
        
        LDA.b #$01 : STA $7EF3CC
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        PLA : STA $7EF3CC
        
        LDA $A0 : CMP.b #$12 : BNE .notInSanctuary
        
        LDA.b #$02 : STA $0E80, X
        
        LDA $7EF3C6 : AND.b #$04 : BNE .been_brought_to_sanctuary_already
    
    .hasMasterSword
    
        STZ $0DD0, X
        
        RTS
    
    .been_brought_to_sanctuary_already
    
        LDA $0D00, X : ADD.b #$0F : STA $0D00, X
        LDA $0D20, X : ADC.b #$00 : STA $0D20, X
        
        LDA $0D10, X : ADD.b #$06 : STA $0D10, X
        
        LDA.b #$03 : STA $0F60, X
        
        RTS
    
    .notInSanctuary
    
        LDA.b #$00 : STA $0E80, X
        
        LDA $7EF3CC : CMP.b #$01 : BEQ .delta
        
        LDA $7EF3C6 : AND.b #$04 : BEQ .epsilon
    
    .delta
    
        STZ $0DD0, X
    
    .epsilon
    
        RTS
    }

; ==============================================================================

    ; *$2EC4C-$2EC8D LOCAL
    Zelda_TransitionFromTagalong:
    {
        ; Transition princess Zelda back into a sprite from the tagalong
        ; state (the sage's sprite is doing this).
        
        LDA.b #$76 : JSL Sprite_SpawnDynamically
        
        PHX
        
        LDX $02CF
        
        LDA $1A64, X : AND.b #$03 : STA $0EB0, Y : STA $0DE0, Y
        
        LDA $20 : STA $0D00, Y
        LDA $21 : STA $0D20, Y
        
        LDA $22 : STA $0D10, Y
        LDA $23 : STA $0D30, Y
        
        LDA.b #$01 : STA $0E80, Y
        
        LDA.b #$00 : STA $7EF3CC
        
        LDA $0BA0, Y : INC A : STA $0BA0, Y
        
        LDA.b #$03 : STA $0F60, Y
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $2EC8E-$2EC95 DATA
    pool Sprite_Zelda:
    {
    
    .x_speeds
        db $00, $00, $F7, $09
    
    .y_speeds
        db $F7, $09, $00, $00
    }


; ==============================================================================

    ; *$2EC96-$2EC9D LONG
    Sprite_ZeldaLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_Zelda
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2EC9E-$2ECBE LOCAL
    Sprite_Zelda:
    {
        JSL CrystalMaiden_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSL Sprite_MakeBodyTrackHeadDirection : BCC .cant_move
        
        JSR Sprite2_Move
    
    .cant_move
    
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Zelda_InPrison
        dw Zelda_EnteringSanctuary
        dw Zelda_AtSanctuary
    }

; ==============================================================================

    ; $2ECBF-$2ECD8 JUMP LOCATION
    Zelda_InPrison:
    {
        ; Wonder if she made a shank?
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Zelda_AwaitingRescue
        dw Zelda_ApproachingPlayer
        dw Zelda_TheWizardIsBadMkay
        dw Zelda_WaitUntilPlayerPaysAttention
        dw Zelda_TransitionToTagalong
    }

; ==============================================================================

    ; *$2ECD9-$2ECF9 JUMP LOCATION
    Zelda_AwaitingRescue:
    {
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_not_close
        
        INC $0D80, X
        
        INC $02E4
        
        LDY $0EB0, X
        
        LDA Sprite_Zelda.x_speeds, Y : STA $0D50, X
        
        LDA Sprite_Zelda.y_speeds, Y : STA $0D40, X
        
        LDA.b #$10 : STA $0DF0, X
    
    .player_not_close
    
        RTS
    }

; ==============================================================================

    ; *$2ECFA-$2ED1F JUMP LOCATION
    Zelda_ApproachingPlayer:
    {
        LDA $0DF0, X : BNE .still_approaching
        
        INC $0D80, X
        
        ; "Thank you, [Name]. I had a feeling you were getting close."
        LDA.b #$1C
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D50, X
        STZ $0D40, X
        
        ; Play you saved the day durp durp music.
        LDA.b #$19 : STA $012C
    
    .still_approaching
    
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$2ED20-$2ED2B JUMP LOCATION
    Zelda_TheWizardIsBadMkay:
    {
        INC $0D80, X
        
        ; "[Name], listen carefully. (...) Do you understand?[Scroll]"
        ; " > Yes"
        ; "   Not at all"
        ; "   ^ Yeah Zelda, I'm really dumb, this could take a while."
        LDA.b #$25
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    }

; ==============================================================================

    ; *$2ED2C-$2ED42 JUMP LOCATION
    Zelda_WaitUntilPlayerPaysAttention:
    {
        LDA $1CE8 : BNE .sorry_zelda_wasnt_listening
        
        ; "All right, let's get out of here before the wizard notices. ..."
        LDA.b #$24
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .sorry_zelda_wasnt_listening
    
        LDA.b #$02 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2ED43-$2ED68 JUMP LOCATION
    Zelda_TransitionToTagalong:
    {
        STZ $02E4
        
        LDA.b #$02 : STA $7EF3C8
        
        JSL SavePalaceDeaths
        
        LDA.b #$01 : STA $7EF3CC
        
        PHX
        
        JSL Dungeon_SaveRoomQuadrantData
        JSL Tagalong_SpawnFromSprite
        
        PLX
        
        STZ $0DD0, X
        
        LDA.b #$10 : STA $012C
        
        RTS
    }

; ==============================================================================

    ; *$2ED69-$2ED75 JUMP LOCATION
    Zelda_EnteringSanctuary:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Zelda_WalkTowardsPriest
        dw Zelda_RespondToPriest
        dw Zelda_BeCarefulOutThere
    }

; ==============================================================================

    ; $2ED76-$2ED7D DATA
    pool Zelda_WalkTowardsPriest:
    {
    
    .timers
        db $26, $1A, $2C, $01
    
    .directions
        db $01, $03, $01, $02
    }

; ==============================================================================

    ; *$2ED7E-$2EDC3 JUMP LOCATION
    Zelda_WalkTowardsPriest:
    {
        LDA $0DF0, X : BNE .walking
        
        LDY $0D90, X : CPY.b #$04 : BCC .beta
        
        INC $0D80, X
        
        STZ $0DE0, X
        STZ $0EB0, X
        
        STZ $0D50, X
        STZ $0D40, X
        
        RTS
    
    .beta
    
        LDA .timers, Y : STA $0DF0, X
        
        LDA .directions, Y : STA $0EB0, X : STA $0DE0, X
        
        INC $0D90, X
        
        TAY
        
        LDA Sprite_Zelda.x_speeds, Y : STA $0D50, X
        
        LDA Sprite_Zelda.y_speeds, Y : STA $0D40, X
    
    .walking
    
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$2EDC4-$2EDEB JUMP LOCATION
    Zelda_RespondToPriest:
    {
        ; "Yes, it was [Name] who helped me escape from the dungeon! ..."
        LDA.b #$1D
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA.b #$02 : STA $7FFE01
        
        LDA.b #$01 : STA $7EF3C8
        
        JSL SavePalaceDeaths
        
        LDA.b #$02 : STA $7EF3C5
        
        PHX
        
        JSL Sprite_LoadGfxProperties.justLightWorld
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$2EDEC-$2EE05 JUMP LOCATION
    Zelda_BeCarefulOutThere:
    {
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        ; "[Name], be careful out there! I know you can save Hyrule!"
        LDA.b #$1E
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        STA $0DE0, X
        STA $0EB0, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; $2EE06-$2EE0B DATA
    pool Zelda_AtSanctuary:
    {
    
    .messages_lower
    
        ; "[Name], be careful out there! I know you can save Hyrule!"
        ; "You should follow the marks the elder made on your map..."
        ; "... Now, you should get the Master Sword. ..."
        db $1E, $26, $27
    
    .messages_upper
        db $00, $00, $00
    
    }

; ==============================================================================

    ; *$2EE0C-$2EE4A JUMP LOCATION
    Zelda_AtSanctuary:
    {
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDY.b #$00
        
        LDA $7EF374 : AND.b #$07 : CMP.b #$07 : BNE .need_moar_pendants
        
        LDY.b #$02
        
        BRA .pick_message
    
    .need_moar_pendants
    
        LDA $7EF3C7 : CMP.b #$03 : BCC .pick_message
        
        LDY.b #$01
    
    .pick_message
    
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .no_talky_talky
        
        STA $0DE0, X : STA $0EB0, X
        
        ; Restore player health completely.
        LDA.b #$A0 : STA $7EF372
    
    .no_talky_talky
    
        RTS
    }

; ==============================================================================

