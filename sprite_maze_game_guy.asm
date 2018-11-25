
; ==============================================================================

    ; *$6CBEA-$6CBF1 LONG
    Sprite_MazeGameGuyLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_MazeGameGuy
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$6CBF2-$6CC2C LOCAL
    Sprite_MazeGameGuy:
    {
        JSL MazeGameGuy_Draw
        JSR Sprite5_CheckIfActive
        JSL Sprite_MakeBodyTrackHeadDirection
        
        STZ $0EB0, X
        
        JSL Sprite_PlayerCantPassThrough
        
        LDA $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        ; Check if the event has been initialized.
        LDA $0ABF : BNE .yous_a_cheater
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MazeGameGuy_ParseElapsedTime
        dw MazeGameGuy_CheckPlayerQualification
        dw MazeGameGuy_SorryCantHaveIt
        dw MazeGameGuy_YouCanHaveIt
        dw MazeGameGuy_NothingMoreToGive
    
    .yous_a_cheater
    
        ; "You Have to enter the maze from the proper entrance or I can't..."
        LDA.b #$D0
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact
        
        RTS
    }

; ==============================================================================

    ; *$6CC2D-$6CCA6 JUMP LOCATION
    MazeGameGuy_ParseElapsedTime:
    {
        REP #$20
        
        LDA $7FFE00 : STA $7FFE04
        LDA $7FFE02 : STA $7FFE06
        
        STZ $00
        STZ $02
        STZ $04
        STZ $06
        
        ; \note This series of loops extracts the number of minutes (up to 599 
        ; minutes) and seconds it took to complete the maze. Interestingly
        ; enough, if you are patient enough to wait 599 minutes and 59 seconds
        ; and then immediately walk right over to the guy he'll give you the
        ; heart piece as this is a modulo operation which would loop at 100
        ; minutes.
        LDA $7FFE04
    
    .modulo_6000_loop
    
        CMP.w #6000 : BCC .exhausted_modulo_6000
        
        SBC.w #6000
        
        BRA .modulo_6000_loop
    
    .exhausted_modulo_6000
    
    .modulo_600_loop
    
        CMP.w #600 : BCC .exhausted_modulo_600
        
        SBC.w #600
        
        INC $06
        
        BRA .modulo_600_loop
    
    .exhausted_modulo_600
    
    .modulo_60_loop
    
        CMP.w #60 : BCC .exhausted_modulo_60
        
        SBC.w #60
        
        INC $04
        
        BRA .modulo_60_loop
    
    .exhausted_modulo_60
    
    .modulo_10_loop
    
        CMP.w #10 : BCC .exhausted_modulo_10
        
        SBC.w #10
        
        INC $02
        
        BRA .modulo_10_loop
    
    .exhausted_modulo_10
    
        ; The last digit is a number from 0 to 9.
        STA $00
        
        SEP #$30
        
        LDA $02 : ASL #4 : ORA $00 : STA $1CF2
        LDA $06 : ASL #4 : ORA $04 : STA $1CF3
        
        LDA.b #$CB
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        STA $0DE0, X : STA $0EB0, X
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$6CCA7-$6CCF3 JUMP LOCATION
    MazeGameGuy_CheckPlayerQualification:
    {
        INC $0D80, X
        
        TXY
        
        LDX $8A
        
        LDA $7EF280, X : TYX : AND.b #$40 : BEQ .heart_piece_not_acquired
        
        INC $0D80, X : INC $0D80, X
        
        ; "I don't have anything more to give you. I'm sorry!"
        LDA.b #$CF
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    
    .heart_piece_not_acquired
    
        LDA $7FFE05              : BNE .player_took_too_long
        LDA $7FFE04 : CMP.b #$10 : BCS .player_took_too_long
        
        INC $0D80, X
        
        ; "... Congratulations! I present you with a piece of Heart!"
        LDA.b #$CD
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STA $0EB0, X : STA $0DE0, X
        
        RTS
    
    .player_took_too_long
    
        ; "You're not qualified. Too bad! Why don't you try again?"
        LDA.b #$CE
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STA $0EB0, X : STA $0DE0, X
        
        RTS
    }

; ==============================================================================

    ; *$6CCF4-$6CD04 JUMP LOCATION
    MazeGameGuy_SorryCantHaveIt:
    {
        ; "You're not qualified. Too bad! Why don't you try again?"
        LDA.b #$CE
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        STA $0EB0, X : STA $0DE0, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$6CD05-$6CD15 JUMP LOCATION
    MazeGameGuy_YouCanHaveIt:
    {
        ; "... Congratulations! I present you with a piece of Heart!"
        LDA.b #$CD
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        STA $0EB0, X : STA $0DE0, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$6CD16-$6CD26 JUMP LOCATION
    MazeGameGuy_NothingMoreToGive:
    {
        ; "I don't have anything more to give you. I'm sorry!"
        LDA.b #$CF
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        STA $0EB0, X : STA $0DE0, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; $6CD27-$6CDA6 DATA
    pool MazeGameGuy_Draw:
    {
    
    .oam_groups
        dw 0, -10 : db $00, $00, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $00, $00, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $00, $00, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $00, $00, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $02, $40, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $02, $40, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $02, $00, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
        
        dw 0, -10 : db $02, $00, $00, $02
        dw 0,   0 : db $20, $00, $00, $02
   }

; ==============================================================================

    ; *$6CDA7-$6CDCE LONG
    MazeGameGuy_Draw:
    {
        PHB : PHK : PLB
        
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        PLB
        
        RTL
    }

; ==============================================================================

