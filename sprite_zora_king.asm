
; ==============================================================================

    ; *$2995B-$29971 JUMP LOCATION
    Sprite_ZoraKing:
    {
        JSR ZoraKing_Draw
        JSR Sprite2_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ZoraKing_WaitingForPlayer
        dw ZoraKing_RumblingGround
        dw ZoraKing_Surfacing
        dw ZoraKing_Dialogue
        dw ZoraKing_Submerge
    }

; ==============================================================================

    ; $29972-$29979 DATA (UNUSED?)
    pool Unknown:
    {
        db $28, $78, $C8, $78, $60, $50, $70, $50
    }

; ==============================================================================

    ; *$2997A-$299D4 JUMP LOCATION
    ZoraKing_WaitingForPlayer:
    {
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0010 : CMP.w #$0020 : BCS .out_of_range
        
        LDA $20 : SUB $0FDA : ADD.w #$0030 : CMP.w #$0060 : BCS .out_of_range
        
        SEP #$20
        
        ; Stop any process of Link dashing, moving, etc.
        JSL Player_HaltDashAttackLong
        
        LDA.b #$7F : STA $0DF0, X
        
        ; Make rumbly noise
        LDA.b #$35 : STA $012E
        
        INC $0D80, X
        
        LDY.b #$0F
    
    .next_sprite
    
        CPY $0FA0 : BEQ .ignore_sprite
        
        LDA $0CAA, Y : BMI .ignore_sprite
        
        PHX : TYX : PHY
        
        LDA $0DD0, X : CMP.b #$0A : BNE .sprite_not_being_carried
        
        STZ $0308
        STZ $0309
    
    .sprite_not_being_carried
    
        ; Attempt to delete the sprite
        JSL Sprite_SelfTerminate
        
        PLY : PLX
    
    .ignore_sprite
    
        DEY : BPL .next_sprite
    
    .out_of_range
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $299D5-$299D8 DATA
    pool ZoraKing_RumblingGround:
    {
    
    .offsets_low
        db $01, $FF
    
    .offsets_high
        db $00, $FF
    }

; ==============================================================================

    ; *$299D9-$29A06 JUMP LOCATION
    ZoraKing_RumblingGround:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
        
        STZ $011A
        STZ $011B ; stop the shaking
        
        LDA.b #$04 : STA $0DC0, X
        
        RTS
    
    .delay
    
        ; Make the ground rumble while counting down
        AND.b #$01 : TAY
        
        LDA .offsets_low, Y  : STA $011A
        LDA .offsets_high, Y : STA $011B
        
        ; Link can't move
        LDA.b #$01 : STA $02E4
        
        RTS
    }

; ==============================================================================

    ; $29A07-$29A16 DATA
    pool ZoraKing_Surfacing:
    {
    
    .animation_states
        db $00, $00, $00, $03, $09, $08, $07, $06
        db $09, $08, $07, $06, $05, $04, $05, $04
    }

; ==============================================================================

    ; *$29A17-$29A3D JUMP LOCATION
    ZoraKing_Surfacing:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
        
        RTS
    
    .delay
    
        CMP.b #$1C : BNE .dont_make_splashes
        
        PHA
        
        LDA.b #$0F : STA $0E10, X
        
        JSR Sprite_SpawnSplashRing
        
        PLA
    
    .dont_make_splashes
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $29A3E-$29A45 DATA
    pool ZoraKing_Dialogue:
    {
    
    .animation_states
        db $00, $00, $01, $02, $01, $02, $00, $00
    }

; ==============================================================================

    ; *$29A46-$29ACE JUMP LOCATION
    ZoraKing_Dialogue:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$24 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #4 : TAY
        
        LDA $9A3E, Y : STA $0DC0, X
        
        LDA $0DF0, X : CMP.b #$50 : BEQ .initial_message
        
        CMP.b #$4F : BEQ .check_if_buying_flippers
        CMP.b #$4E : BEQ .check_if_can_afford
        CMP.b #$4D : BEQ .maybe_give_flippers
        
        RTS
    
    .initial_message
    
        ; Wah ha ha! What do you want, little man?..."
        LDA.b #$42
    
    .show_message
    
        STA $1CF0
        
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        RTS
    
    .check_if_buying_flippers
    
        LDA $1CE8 : BNE .player_says_just_came_to_visit
        
        ; ...But I don't just give flippers away for free. I sell them..."
        LDA.b #$43
        
        JSR .show_message
        
        RTS
    
    .check_if_can_afford
    
        LDA $1CE8 : BNE .not_buying
        
        REP #$20
        
        ; check if the player has 500 or more rupees (for flippers)
        LDA $7EF360 : SUB.w #$01F4 : BCC .cant_afford
        
        STA $7EF360
        
        SEP #$20
        
        ; "Wah ha ha! One pair of flippers coming up..."
        LDA.b #$44
        
        JSR .show_message
        
        INC $0E90, X
        
        RTS
    
    .player_says_just_came_to_visit
    
        ; "Great! Whenever you want to see my fishy face, you are welcome here."
        LDA.b #$46
        
        JSR .show_message
        
        LDA.b #$30 : STA $0DF0, X
        
        RTS
    
    .cant_afford
    .not_buying
    
        SEP #$20
        
        ; Wade back this way when you have more Rupees... Wah ha ha!..."
        LDA.b #$45
        
        JSR .show_message
        
        LDA.b #$30 : STA $0DF0, X
        
        RTS
    
    .maybe_give_flippers
    
        LDA $0E90, X : BEQ .didnt_pay_for_flippers
      
        ; Spawn the flippers and toss them at Link
        JSL Sprite_SpawnFlippersItem
    
    .didnt_pay_for_flippers
    
        RTS
    }

; ==============================================================================

    ; $29ACF-$29AE3 DATA
    pool ZoraKing_Submerge:
    {
    
    .animation_states
        db $0C, $0C, $0C, $0C, $0C, $0C, $0B, $0B
        db $0B, $0B, $0B, $0A, $0A, $0A, $0A, $03
        db $03, $03, $03, $03, $03
    }

; ==============================================================================

    ; *$29AE4-$29B07 JUMP LOCATION
    ZoraKing_Submerge:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL Sprite_SelfTerminate
        
        STZ $02E4
        
        RTS
    
    .delay
    
        CMP.b #$1D : BNE .dont_submerge_yet
        
        PHA
        
        LDA.b #$0F : STA $0E10, X
        
        JSR Sprite_SpawnSplashRing
        
        PLA
    
    .dont_submerge_yet
    
        LSR A : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================


    ; $29B08-$29B37 DATA
    pool Sprite_SpawnSplashRing:
    {
    
    .x_offsets_low
        db $F8, $FB, $04, $0D, $10, $0D, $04, $FB
    
    .x_offsets_high
        db $FF, $FF, $00, $00, $00, $00, $00, $FF
    
    .y_offsets_low
        db $04, $FB, $F8, $FB, $04, $0D, $10, $0D
    
    .y_offsets_high
        db $00, $FF, $FF, $FF, $00, $00, $00, $00
    
    .x_speeds
        db $F8, $FA, $00, $06, $08, $06, $00, $FA
    
    .y_speeds
        db $00, $FA, $F8, $FA, $00, $06, $08, $06
    }

; ==============================================================================

    ; *$29B38-$29B3F LONG
    Sprite_SpawnSplashRingLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_SpawnSplashRing
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$29B40-$29BBA LOCAL
    Sprite_SpawnSplashRing:
    {
        LDA.b #$24 : JSL Sound_SetSfx2PanLong
        
        NOP
        
        LDA.b #$07 : STA $0D
    
    .next_attempt
    
        LDA.b #$08
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$03 : STA $0DD0, Y
        
        PHX
        
        LDX $0D
        
        LDA .x_offsets_low, X : SUB.b #$04 : ADD $00   : STA $0D10, Y
        LDA $01               : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA .y_offsets_low, X : SUB.b #$04 : ADD $02   : STA $0D00, Y
        LDA $03               : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        TXA : STA $0D90, Y
        
        PHY : JSL GetRandomInt : PLY : AND.b #$0F : ADC.b #$18 : STA $0F80, Y
        
        LDA.b #$01 : STA $0D80, Y
        LDA.b #$00 : STA $0F70, Y
        
        LDA $0E60, Y : ORA.b #$40 : STA $0E60, Y : STA $0BA0, Y
        
        PLX
    
    .spawn_failed
    
        DEC $0D : BPL .next_attempt
        
        RTS
    }

; ==============================================================================

    ; $29BBB-$29CAA DATA
    pool ZoraKing_Draw:
    {
    
    .x_offsets
        db $F8, $08, $F8, $08, $F8, $08, $F8, $08
        db $F8, $08, $F8, $08, $F8, $08, $F8, $08
        
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $F8, $08, $F8, $08, $F8, $08, $F8, $08
        
        db $F8, $08, $F8, $08, $F8, $08, $F8, $08
        db $F7, $09, $F7, $09, $F6, $0A, $F6, $0A
        
        db $F5, $0B, $F5, $0B
    
    .y_offsets
        db $EE, $EE, $FE, $FE, $EE, $EE, $FE, $FE
        db $EE, $EE, $FE, $FE, $F4, $F4, $04, $04
        
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $F8, $F8, $08, $08, $F8, $F8, $08, $08
        
        db $F8, $F8, $08, $08, $F8, $F8, $08, $08
        db $FB, $FB, $05, $05, $FB, $FB, $05, $05
        
        db $FB, $FB, $05, $05
    
    .chr
        db $C0, $C0, $E0, $E0, $C2, $EA, $E2, $E2
        db $EA, $C2, $E2, $E2, $C0, $C0, $E4, $E6
        
        db $88, $88, $88, $88, $88, $88, $88, $88
        db $C4, $C6, $E4, $E6, $C6, $C4, $E6, $E4
        
        db $E6, $E4, $C6, $C4, $E4, $E6, $C4, $C6
        db $88, $88, $88, $88, $88, $88, $88, $88
        
        db $88, $88, $88, $88
    
    .properties
        db $00, $40, $00, $40, $00, $40, $00, $40
        db $00, $40, $00, $40, $00, $40, $05, $05
        
        db $05, $05, $05, $05, $C5, $C5, $C5, $C5
        db $05, $05, $05, $05, $45, $45, $45, $45
        
        db $C5, $C5, $C5, $C5, $85, $85, $85, $85
        db $04, $44, $84, $C4, $04, $44, $84, $C4
        
        db $04, $44, $84, $C4
    
    .whirlpool_x_offsets
        db $E9, $17, $17, $17, $EC, $F1, $0D, $12
    
    .whirlpool_y_offsets
        db $F8, $F8, $F8, $F8, $F9, $00, $00, $F9
    
    .whirlpool_chr
        db $AE, $AE, $AE, $AE, $AC, $AC, $AC, $AC
    
    .whirlpool_properties
        db $00, $40, $40, $40, $00, $00, $40, $40
    }

; ==============================================================================

    ; *$29CAB-$29D49 LOCAL
    ZoraKing_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0D80, X : CMP.b #$02 : BCC .draw_whirlpool_instead
        
        LDA $0DC0, X : ASL #2 : STA $06
        
        PHX
        
        LDX.b #$03
    
    .next_subsprite
    
        PHX : TXA : ADD $06 : TAX
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        INY
        
        LDA .y_offsets, X : ADD $02        : STA ($90), Y
        LDA .chr, X                  : INY : STA ($90), Y
        
        LDA.b #$0F : STA $0F
        
        LDA .properties, X : BIT $0F : BNE .palette_override
        
        ORA $05
    
    .palette_override
    
        INY : ORA.b #$20 : STA ($90), Y
        
        INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
        
        LDY.b #$02
        LDA.b #$03
        
        JSL Sprite_CorrectOamEntriesLong
        JSR Sprite2_PrepOamCoord
    
    .draw_whirlpool_instead
    
        LDA $0E10, X : BEQ .return
        
        LSR A : AND.b #$04 : STA $06
        
        LDA.b #$10 : JSL OAM_AllocateFromRegionC
        
        LDY.b #$00
        
        PHX
        
        LDX.b #$03
    
    .next_whirlpool_subsprite
    
        PHX
        
        TXA : ADD $06 : TAX
        
        LDA $00 : ADD .whirlpool_x_offsets, X           : STA ($90), Y
        LDA $02 : ADD .whirlpool_y_offsets, X     : INY : STA ($90), Y
        LDA .whirlpool_chr, X                     : INY : STA ($90), Y
        LDA .whirlpool_properties, X : ORA.b #$24 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_whirlpool_subsprite
        
        PLX
    
    .return
    
        RTS
    }

; ==============================================================================
