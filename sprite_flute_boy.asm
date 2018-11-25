
; ==============================================================================

    ; *$32F3B-$32F45 JUMP LOCATION
    Sprite_FluteBoy:
    {
        ; Flute Boy's Code
        
        LDA $0EB0, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteBoy_Humanoid
        dw Sprite_FluteNote
    }

; ==============================================================================

    ; $32F46-$32F50 JUMP LOCATION
    FluteBoy_Humanoid:
    {
        ; In this situation, determines light world / darkworld behavior
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteBoy_HumanForm
        dw Sprite_FluteAardvark
    }

; ==============================================================================

    ; *$32F51-$32F92 JUMP LOCATION
    FluteBoy_HumanForm:
    {
        LDA $0D80, X : CMP.b #$03 : BEQ .invisible
        
        JSL FluteBoy_Draw
        
        ; what exactly is going on here...?
        LDA $01 : ORA $03 : STA $0DB0, X
    
    .invisible
    
        JSR Sprite_CheckIfActive
        
        LDA $0DB0, X : BNE .delay_playing_flute_ditty
        
        LDA $0DA0, X : BNE .delay_playing_flute_ditty
        
        LDA.b #$0B : STA $012D
                     STA $0DA0, X
    
    .delay_playing_flute_ditty
    
        LDA $1A : LSR #5 : AND.b #$01 : STA $0DC0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteBoy_Chillin
        dw FltueBoy_PrepPhaseOut
        dw FluteBoy_PhaseOut
        dw FluteBoy_FullyPhasedOut
    }

; ==============================================================================

    ; *$32F93-$32FC0 JUMP LOCATION
    FluteBoy_Chillin:
    {
        LDA $7EF34C : CMP.b #$02 : BCS .player_has_flute
        
        JSR FluteBoy_CheckIfPlayerTooClose : BCS .player_not_too_close
    
    .player_has_flute
    
        INC $0D80, X
        
        INC $0DE0, X
        
        ; \task Why increment this? What effect does it have?
        INC $0FDD
        
        LDA.b #$B0 : STA $0DF0, X
        
        ; Halt player because he got too close. Flute boy is zapping out.
        LDA.b #$01 : STA $02E4
    
    .player_not_too_close
    
        LDA $0DF0, X : BNE .spawn_note_delay
        
        LDA.b #$19 : STA $0DF0, X
        
        JSR FluteBoy_SpawnFluteNote
    
    .spawn_note_delay
    
        RTS
    }

; ==============================================================================

    ; *$32FC1-$32FF1 JUMP LOCATION
    FltueBoy_PrepPhaseOut:
    {
        LDA.b #$01 : STA $02E4
        
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$02 : STA $1D
        
        LDA.b #$30 : STA $9A
        
        LDA.b #$00 : STA $7EC007 : STA $7EC009
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        
        PLX
        
        INC $0D80, X
        
        ; .... What? \task Does this quiet sfx1 down?
        LDA.b #$80 : STA $012D
        
        LDA.b #$33 : JSL Sound_SetSfx2PanLong
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$32FF2-$33007 JUMP LOCATION
    FluteBoy_PhaseOut:
    {
        LDA $1A : AND.b #$0F : BNE .onlyEvery16Frames
        
        PHX
        
        JSL Palette_Filter_SP5F
        
        PLX
        
        LDA $7EC007 : BNE .filteringNotDone
        
        INC $0D80, X
    
    .onlyEvery16Frames
    .filteringNotDone
    
        RTS
    }

; ==============================================================================

    ; *$33008-$33018 JUMP LOCATION
    FluteBoy_FullyPhasedOut:
    {
        PHX
        
        JSL Palette_Restore_SP5F
        JSL Palette_RevertTranslucencySwap
        
        PLX
        
        STZ $0DD0, X
        
        STZ $02E4
        
        RTS
    }`

; ==============================================================================

    ; \covered($33019-$331DD)

    ; $33019-$3303F DATA
    pool FluteAardvark_Arborating:
    {
    
    .animation_states
        db $01, $01, $01, $01, $02, $01, $02, $01
        db $02, $01, $02, $03, $02, $03, $02, $03
        db $02, $03, $02, -1
    
    ; $3302D
    .timers
        db $FF, $FF, $FF, $10, $02, $0C, $06, $08
        db $0A, $04, $0E, $02, $0A, $06, $06, $0A
        db $02, $0E, $02    
    }

; ==============================================================================

    ; *$33040-$33059 JUMP LOCATION
    Sprite_FluteAardvark:
    {
        JSL FluteAardvark_Draw
        JSR Sprite_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteAardvark_InitialStateFromFluteState
        dw FluteAardvark_ReactToSupplicationResponse
        dw FluteAardvark_GrantShovel
        dw FluteAardvark_WaitForPlayerMusic
        dw FluteAardvark_Arborating
        dw FluteAardvark_FullyArborated
    }

; ==============================================================================

    ; *$3305A-$3306B JUMP LOCATION
    FluteAardvark_InitialStateFromFluteState:
    {
        ; Flute
        LDA $7EF34C : AND.b #$03
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FluteAardvark_Supplicate
        dw FluteAardvark_GetMeMyDamnFlute
        dw FluteAardvark_ThanksButYouKeepIt
        dw FluteAardvark_AlreadyArborated
    }

; ==============================================================================

    ; *$3306C-$33079 JUMP LOCATION
    FluteAardvark_Supplicate:
    {
        ; "... I enjoyed playing the flute in the original world..."
        LDA.b #$E5
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$3307A-$33082 JUMP LOCATION
    FluteAardvark_GetMeMyDamnFlute:
    {
        ; "Did you find my flute? Please keep looking for it!"
        LDA.b #$E8
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$33083-$33097 JUMP LOCATION
    FluteAardvark_ThanksButYouKeepIt:
    {
        LDA.b #$01 : STA $0DC0, X
        
        ; "Thank you, [Name]. (...) Please take it. ..."
        LDA.b #$E9
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        LDA.b #$03 : STA $0D80, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$33098-$3309D JUMP LOCATION
    FluteAardvark_AlreadyArborated:
    {
        LDA.b #$03 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$3309E-$330BA JUMP LOCATION
    FluteAardvark_ReactToSupplicationResponse:
    {
        LDA $1CE8 : BNE .player_declined
        
        ; "Then I will lend you my shovel. Good luck!"
        LDA.b #$E6
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .player_declined
    
        ; "...  ...  ... I see.  I won't ask you again... Good bye."
        LDA.b #$E7
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$330BB-$330C9 JUMP LOCATION
    FluteAardvark_GrantShovel:
    {
        STZ $02E9
        
        ; Give Link the shovel.
        LDY.b #$13
        
        PHX
        
        JSL Link_ReceiveItem
        
        PLX
        
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$330CA-$330E8 JUMP LOCATION
    FluteAardvark_WaitForPlayerMusic:
    {
        LDA $0202 : CMP.b #$0D : BNE .flute_not_equipped
        
        BIT $F0 : BVC .y_button_not_held
        
        INC $0D80, X
        
        LDA.b #$F2 : STA $012C
        
        STZ $012E
        
        LDA.b #$17 : STA $012D
        
        INC $02E4
    
    .y_button_not_held
    .flute_not_equipped
    
        RTS
    }

; ==============================================================================

    ; *$330E9-$3311D JUMP LOCATION
    FluteAardvark_Arborating:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA $0D90, X : CMP.b #$03 : BCC .anoplay_sfx
        
        LDA.b #$33 : JSL Sound_SetSfx2PanLong
    
    .anoplay_sfx
    
        LDA $0D90, X : TAY : INC A : STA $0D90, X
        
        LDA .animation_states, Y : BMI .invalid_state
        
        STA $0DC0, X
        
        LDA .timers, Y : STA $0DF0, X
    
    .delay
    
        RTS
    
    .invalid_state
    
        ; Go music back to full volume.
        LDA.b #$F3 : STA $012C
        
        INC $0D80, X
        
        STZ $02E4
        
        RTS
    }

; ==============================================================================

    ; *$3311E-$3312D JUMP LOCATION
    FluteAardvark_FullyArborated:
    {
        LDA.b #$03 : STA $0DC0, X
        
        ; Let us know that flute boy has been thoroughly arborated
        LDA $7EF3C9 : ORA.b #$08 : STA $7EF3C9
        
        RTS
    }

; ==============================================================================

    ; *$3312E-$33170 LOCAL
    FluteBoy_CheckIfPlayerTooClose:
    {
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        REP #$30
        
        LDA $02 : SUB.w #$0010 : STA $02
        
        LDA $22 : SBC $00 : BPL .positive_dx
        
        EOR.w #$FFFF
    
    .positive_dx
    
        STA $00
        
        LDA $20 : SBC $02 : BPL .positive_dy
        
        EOR.w #$FFFF
    
    .positive_dy
    
        STA $02
        
        LDA $00 : CMP.w #$0030 : BCS .far_enough_out
        
        LDA $02 : CMP.w #$0030
    
    .far_enough_out
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $33171-$33172 DATA
    pool Sprite_FluteNote:
    {
    
    .directions
        db 1, -1
    }

; ==============================================================================

    ; *$33173-$331A4 JUMP LOCATION
    Sprite_FluteNote:
    {
        JSR Sprite_PrepAndDrawSingleSmall
        JSR Sprite_CheckIfActive
        JSR Sprite_Move
        JSR Sprite_MoveAltitude
        
        LDA $0DF0, X : BNE .delay
        
        STZ $0DD0, X
    
    .delay
    
        LDA $1A : AND.b #$01 : BNE .odd_frame
        
        LDA $1A : LSR #5 : EOR $0FA0 : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD .directions, Y : STA $0D50, X
    
    .odd_frame
    
        RTS
    }

; ==============================================================================

    ; *$331A5-$331DD LOCAL
    FluteBoy_SpawnFluteNote:
    {
        LDA.b #$2E : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $00 : ADD.b #$04 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA $02 : SUB.b #$04 : STA $0D00, Y
        LDA $03 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$01 : STA $0EB0, Y
        
        LDA.b #$08 : STA $0F80, Y
        
        LDA.b #$60 : STA $0DF0, Y : STA $0BA0, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================
