
; ==============================================================================

    ; *$F0BBF-$F0BD7 JUMP LOCATION
    Sprite_Pikit:
    {
        JSR Pikit_PrepThenDraw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Pikit_SetNextVelocity
        dw Pikit_FinishJumpThenAttack
        dw Pikit_AttemptItemGrab
    }

; ==============================================================================

    ; $F0BD8-$F0BDD DATA
    pool Pikit_Data:
    parallel pool Sprite3_Shake:
    {
    
    .x_speeds length 4
        db $10, $F0
    
    .y_speeds
        db $00, $00, $10, $F0
    }

; ==============================================================================

    ; *$F0BDE-$F0C24 LOCAL
    Pikit_SetNextVelocity:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        INC $0DB0, X : LDA $0DB0, X : CMP.b #$04 : BNE .pick_random_direction
        
        STZ $0DB0, X
        
        JSR Sprite3_DirectionToFacePlayer
        
        BRA .set_speed
    
    .pick_random_direction
    
        JSL GetRandomInt : AND.b #$03 : TAY
    
    .set_speed
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSL GetRandomInt : AND.b #$07 : ADC.b #$13 : STA $0F80, X
    
    .delay
    
    ; *$F0C16 ALTERNATE ENTRY POINT
    shared Pikit_Animate:
    
        INC $0E80, X : LDA $0E80, X : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F0C25-$F0C71 JUMP LOCATION
    Pikit_FinishJumpThenAttack:
    {
        JSR Sprite3_MoveXyz
        JSR Sprite3_CheckTileCollision
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .in_air
        
        STZ $0F70, X
        
        STZ $0F80, X
        
        JSR Sprite3_DirectionToFacePlayer
        
        LDA $0E : ADD.b #$30 : CMP.b #$60 : BCS .dont_activate_tongue
        
        LDA $0F : ADD.b #$30 : CMP.b #$60 : BCS .dont_activate_tongue
        
        INC $0D80, X
        
        LDA.b #$1F
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        JSL Sprite_ConvertVelocityToAngle : LSR A : STA $0DE0, X
        
        LDA.b #$5F : STA $0DF0, X
        
        RTS
    
    .dont_activate_tongue
    
        STZ $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
    
    .in_air
    
        BRA Pikit_Animate
    }

; ==============================================================================

    ; $F0C72-$F0CE1 DATA
    pool Pikit_AttemptItemGrab:
    {
    
    .animation_states
        db $02, $02, $02, $02, $03, $03, $03, $03
        db $03, $03, $03, $03, $03, $03, $03, $03
        db $03, $03, $03, $03, $02, $02, $02, $02
        
    ; $F0C8A ; \task Name these sublabels.
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $0C, $10, $18, $20, $20, $18, $10, $0C
        db $00, $00, $00, $00, $00, $00, $00, $00
        
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $F4, $F0, $E8, $E0, $E0, $E8, $F0, $F4
        db $00, $00, $00, $00, $00, $00, $00, $00
        
    ; $F0CD2
        db $18, $18, $00, $30, $30, $30, $00, $18
        db $00, $18, $18, $18, $00, $30, $30, $30
    }

; ==============================================================================

    ; *$F0CE2-$F0DC9 JUMP LOCATION
    Pikit_AttemptItemGrab:
    {
        LDA $0DF0, X : BNE .tongue_still_out
        
        STZ $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
        
        STZ $0D90, X
        STZ $0DA0, X
        STZ $0ED0, X
        
        RTS
    
    .tongue_still_out
    
        LSR #2 : PHA : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        TYA
        
        LDY $0DE0, X : PHY
        
        ADD $8CD2, Y : TAY
        
        LDA $8C8A, Y : STA $0D90, X : STA $04
                                      STZ $05
        
        BPL .sign_extend_x_offset
        
        DEC $05
    
    .sign_extend_x_offset
    
        PLY
        
        PLA : ADD $8CDA, Y : TAY
        
        ; Two STZs in a row?
        LDA $8C8A, Y : STA $0DA0, X : STA $06
                                      STZ $07
                                      STZ $07
        
        BPL .sign_extend_y_offset
        
        DEC $07
    
    .sign_extend_y_offset
    
        LDA $0ED0, X : BNE .return
        
        REP #$20
        
        LDA $0FD8 : ADD $04 : SUB $22 : ADD.w #$000C : CMP.w #$0018 : BCS .return
        
        LDA $0FDA : ADD $06 : SUB $20 : ADD.w #$000C : CMP.w #$0020 : BCS .return
        
        SEP #$20
        
        LDA $0DF0, X : CMP.b #$2E : BCS .return
        
        JSL Sound_SetSfxPanWithPlayerCoords
        
        ORA.b #$26 : STA $012E
        
        JSL GetRandomInt : AND.b #$03 : INC A : STA $0ED0, X
                                                STA $0E90, X
        
        CMP.b #$01 : BNE .not_hungry_for_bombs
        
        LDA $7EF343 : BEQ .player_has_none
        
        DEC A : STA $7EF343
        
        RTS
    
    .player_has_none
    .cant_take_that_item
    
        SEP #$20
        
        STZ $0ED0, X
        
        RTS
    
    .not_hungry_for_bombs
    
        CMP.b #$02 : BNE .not_wanting_arrows
        
        LDA $7EF377 : BEQ .player_has_none
        
        DEC A : STA $7EF377
        
        RTS
    
    .not_wanting_arrows
    
        CMP.b #$03 : BNE .not_wanting_rupees
        
        REP #$20
        
        ; Pikit steals a rupee, if any are available
        LDA $7EF360 : BEQ .player_has_none
        
        DEC A : STA $7EF360
    
    .return
    
        SEP #$20
        
        RTS
    
    .not_wanting_rupees
    
        ; Can't take a shield Link doesn't have
        LDA $7EF35A : STA $0E30, X : BEQ .player_has_none
        
        ; Can't take the Mirror Shield, thank Jebus.
        CMP.b #$03 : BEQ .cant_take_that_item
        
        ; Yo shield got took, asswipe.
        LDA.b #$00 : STA $7EF35A
        
        RTS
    }

; ==============================================================================

    ; *$F0DCA-$F0DD1 LOCAL
    Pikit_PrepThenDraw
    {
        JSR Sprite3_PrepOamCoord
        JSL Pikit_Draw
        
        RTS
    }

; ==============================================================================

