
; ==============================================================================

    ; *$2E88E-$2E895 LONG
    SpritePrep_RunningManLong:
    {
        ; Sprite Prep for Red Hat Wussy (0x74)
        
        PHB : PHK : PLB
        
        JSR SpritePrep_RunningMan
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E896-$2E8A1 LOCAL
    SpritePrep_RunningMan:
    {
        LDA.b #$02 : STA $0EB0, X
                     STA $0DE0, X
        
        INC $0BA0, X
        
        RTS
    }

; ==============================================================================

    ; *$2E8A2-$2E8A9 LONG
    Sprite_RunningManLong:
    {
        ; Scared red hat man (0x74)
        
        PHB : PHK : PLB
        
        JSR Sprite_RunningMan
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $2E8AA-$2E8B1 DATA
    pool RunningMan_RunFullSpeed:
    {
    
    .x_speeds
        db   0,   0, -54,  54
    
    .y_speeds
        db -54,  54,   0,   0
    }

; ==============================================================================

    ; *$2E8B2-$2E8F4 LOCAL
    Sprite_RunningMan:
    {
        ; (Scared red hat man that runs away if you come near.)
        
        JSR RunningMan_Draw
        JSR Sprite2_CheckIfActive
        JSL Sprite_MakeBodyTrackHeadDirection
        JSL Sprite_PlayerCantPassThrough
        
        LDA.b #$FF : STA $0E30, X
        
        JSR Sprite2_CheckTileCollision
        
        LDA $0F60, X : PHA
        
        LDA.b #$07 : STA $0F60, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_collision
        
        LDA $0D80, X : STA $0DB0, X
        
        LDA.b #$03 : STA $0D80, X
    
    .no_player_collision
    
        PLA : STA $0F60, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw RunningMan_Chillin
        dw RunningMan_RunLeft
        dw RunningMan_WindingRunRight
        dw RunningMan_GotCaught
    }

; ==============================================================================

    ; $2E8F5-$2E8F6 DATA
    pool RunningMan_Chillin:
    {
    
    .x_speeds
        db $E8, $18
    }

; ==============================================================================

    ; *$2E8F7-$2E937 JUMP LOCATION
    RunningMan_Chillin:
    {
        JSL Sprite_MakeBodyTrackHeadDirection
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_not_close
        
        JSL Player_HaltDashAttackLong
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0DE0, X
        
        EOR.b #$01 : ORA.b #$02 : STA $0EB0, X : TAY
        
        AND.b #$01 : INC A : STA $0D80, X
        
        LDA .x_speeds - 2, Y : STA $0D50, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS
    
    .player_not_close
    
        STZ $0D50, X
        
        STZ $0D40, X
        
        RTS
    }

; ==============================================================================

    ; *$2E938-$2E945 BRANCH LOCATION
    RunningMan_AnimateAndRun:
    {
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        JSR Sprite2_Move
        
        RTS
    }

; ==============================================================================

    ; *$2E946-$2E964 JUMP LOCATION
    RunningMan_RunLeft:
    {
        LDA $0DF0, X : BNE RunningMan_AnimateAndRun
        
        JSR RunningMan_AnimateAndMakeDust
        JSR RunningMan_RunFullSpeed
        
        LDA $0D90, X : BNE .tick_run_countdown_timer
        
        LDA.b #$FF : STA $0D90, X
        LDA.b #$02 : STA $0EB0, X
        
        RTS

    .tick_run_countdown_timer
    
    ; *$2E961 ALTERNATE ENTRY POINT
    RunningMan_TickRunCountdownTimer:

        DEC $0D90, X
        
        RTS
    }

; ==============================================================================

    ; *$2E965-$2E96B BRANCH LOCATION
    RunningMan_ResumeChillin:
    {
        ; \tcrf(confirmed) While this is never triggered, forcing it to
        ; trigger has the predicted effect of making the running man settle
        ; back down. He will begin running again if you approach him from the
        ; left or right though. Perhaps originally he was supposed to mock
        ; you.
        
        STZ $0D80, X
        STZ $0E80, X
        
        RTS
    }

; ==============================================================================

    ; $2E96C-$2E972 DATA
    pool RunningMan_WindingRunRight:
    {
    
    ; \task Label this data and the surrounding routines when time avails.
    .timers
        db 120, 24, 128
    
    .directions
        db 3, 1, 3, -1
    
    }

; ==============================================================================

    ; *$2E973-$2E997 JUMP LOCATION
    RunningMan_WindingRunRight:
    {
        LDA $0DF0, X : BNE RunningMan_AnimateAndRun
        
        JSR RunningMan_AnimateAndMakeDust
        JSR RunningMan_RunFullSpeed
        
        LDA $0D90, X : BNE RunningMan_TickRunCountdownTimer
        
        LDY $0DA0, X : INC $0DA0, X
        
        LDA .timers, Y : STA $0D90, X
        
        LDA .direction, Y : BMI RunningMan_ResumeChillin
        
        STA $0EB0, X
        
        RTS
    }

; ==============================================================================

    ; *$2E998-$2E9AB JUMP LOCATION
    RunningMan_GotCaught:
    {
        LDA.b #$A6
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional : BCC 
        
        STA $0DE0, X
    
    .didnt_speak
    
        LDA $0DB0, X : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2E9AC-$2E9B9 LOCAL
    RunningMan_AnimateAndMakeDust:
    {
        JSL RunningMan_SpawnDashDustGarnish
        
        LDA $1A : LSR #2 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$2E9BA-$2E9CC LOCAL
    RunningMan_RunFullSpeed:
    {
        LDY $0EB0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite2_Move
        
        RTS
    }

; ==============================================================================

    ; $2E9CD-$2EA4C DATA
    pool RunningMan_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $2C, $00, $00, $02
        dw 0,  0 : db $EE, $08, $00, $02
        
        dw 0, -7 : db $2C, $00, $00, $02
        dw 0,  1 : db $EE, $48, $00, $02
        
        dw 0, -8 : db $2A, $00, $00, $02
        dw 0,  0 : db $CA, $08, $00, $02
        
        dw 0, -7 : db $2A, $00, $00, $02
        dw 0,  1 : db $CA, $48, $00, $02
        
        dw 0, -8 : db $2E, $00, $00, $02
        dw 0,  0 : db $CC, $08, $00, $02
        
        dw 0, -7 : db $2E, $00, $00, $02
        dw 0,  1 : db $CE, $08, $00, $02
        
        dw 0, -8 : db $2E, $40, $00, $02
        dw 0,  0 : db $CC, $48, $00, $02
        
        dw 0, -7 : db $2E, $40, $00, $02
        dw 0,  1 : db $CE, $48, $00, $02
    
    }

; ==============================================================================

    ; *$2EA4D-$2EA70 LOCAL
    RunningMan_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
