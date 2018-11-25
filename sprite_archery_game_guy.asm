
; ==============================================================================

    ; $28176-$28191 DATA
    pool SpritePrep_ArcheryGameGuy:
    {
    
    .x_offests
        db $00, $40, $80, $C0, $30, $60, $90, $C0
    
    .y_offsets
        db $00, $4F, $4F, $4F, $5A, $5A, $5A, $5A
    
    .subtypes
        db $00, $01, $01, $01, $02, $02, $02, $02
    
    .x_speeds
        db $F8, $0C
    
    .hit_boxes
        db $1C, $15
    }

; ==============================================================================

    ; *$28192-$281FE LONG
    SpritePrep_ArcheryGameGuy:
    {
        ; Shooting gallery guy initialization routine
        
        PHB : PHK : PLB
        
        STZ $0B88
        
        LDA $0D00, X : SUB.b #$08 : STA $0D00, X
        
        PHX
        
        ; This loop essentially spawns 8 sprites, even overwriting the current
        ; sprite's data (almost certainly, barring strange circumstances like
        ; having many other sprites in the room). It configures a number of
        ; sprites to be hands, and others to be mops, and ensures the state
        ; of the proprietor (the humanoid you talk to to start the game)
        LDX.b #$07
    
    .next_sprite
    
        LDA.b #$65 : STA $0E20, X
        
        LDA.b #$09 : STA $0DD0, X
        
        JSL Sprite_LoadProperties
        
        LDA $23           : STA $0D30, X
        LDA .x_offsets, X : STA $0D10, X
        
        LDA $21           : STA $0D20, X
        LDA .y_offsets, X : STA $0D00, X
        
        LDA .subtypes, X : STA $0D90, X
        
        DEC A : STA $0DC0, X : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .hit_boxes, Y : STA $0F60, X
        
        LDA.b #$0D : STA $0F50, X
        
        LDA $EE : STA $0F20, X
        
        JSL GetRandomInt : STA $0E80, X
        
        DEX : BNE .next_sprite
        
        PLX : INC $0BA0, X
        
        ; Cache number of arrows that Link has when he enters the room.
        LDA $7EF377 : STA $0E30, X
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$281FF-$28212 JUMP LOCATION
    Sprite_ArcheryGameGuy:
    {
        ; Make sure arrows stay at the amount they started at when Link
        ; entered the shooting gallery. (This seems unelegant, but also
        ; seems to work well enough)
        LDA $0E30, X : STA $7EF377
        
        LDA $0D90, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ArcheryGameGuy_Main
        dw Sprite_GoodArcheryTarget
        dw Sprite_BadArcheryTarget
    }

; ==============================================================================

    ; $28213-$28216 DATA
    pool ArcheryGameGuy_Main:
    {
    
    .animation_states
        db 3, 4, 3, 2
    }
    
; ==============================================================================

    ; *$28217-$282D3 JUMP LOCATION
    ArcheryGameGuy_Main:
    {
        LDA $0B99 : BNE .have_minigame_arrows
        
        ; Disallows firing of arrows if you have no "minigame" arrows left.
        INC $0B9A
    
    .have_minigame_arrows
    
        JSL ArcheryGameGuy_Draw
        JSR Sprite2_CheckIfActive
        
        LDA.b #$00 : STA $0F60, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_collision
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Player_HaltDashAttackLong
    
    .no_player_collision
    
        LDA $0DF0, X : BEQ .not_banging_his_drum
        AND.b #$07   : BNE .sound_effect_delay
        
        LDA.b #$11 : JSL Sound_SetSfx2PanLong
    
    .sound_effect_delay
    
        LDA $0DF0, X : AND.b #$04 : LSR #2 : BRA .set_animation_state
    
    .not_banging_his_drum
    
        LDA $0D80, X : BEQ .in_ground_state
        
        ; I think this is what animtes the proprietor when you hit a target.
        LDA $1A : LSR #5 : AND.b #$03
    
    .in_ground_state
    
        TAY
        
        LDA .animation_states, Y
    
    .set_animation_state
    
        STA $0DC0, X
        
        LDA $0D80, X
        
        CMP.b #$02 : BEQ ArcheryGameGuy_RunGame
        CMP.b #$01 : BEQ .check_if_player_wants_to_play
        CMP.b #$03 : BNE .in_ground_state_2
        
        LDA $1CE8 : BNE .player_not_interested
        
        LDA.b #$01 : STA $0D80, X
        
        BRA .restart_minigame
    
    .in_ground_state_2
    
        LDA.b #$0A : STA $0F60, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_contact_2
        
        LDA $F6 : BPL .a_button_not_pressed
        
        LDA.b #$85
        
        JSR .show_message
        
        INC $0D80, X
    
    .a_button_not_pressed
    .no_player_contact_2
    
        RTS
    
    .check_if_player_wants_to_play
    
        LDA $1CE8 : BNE .player_not_interested
    
    .restart_minigame
    
        REP #$20
        
        LDA $7EF360 : CMP.w #$0014 : SEP #$20 : BCC .dont_got_the_cash
        
        STZ $0EB0, X
        STZ $0B88
        
        INC $0D80, X
        
        LDA.b #$86 : BRA .show_message
    
    .player_not_interested
    
        STZ $0D80, X
        
        ; "Well little partner, you can just turn yourself right around and..."
        LDA.b #$87
    
    .show_message
    
        STA $1CF0
        STZ $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        STZ $0DF0, X
        
        RTS
    
    .dont_got_the_cash
    
        STZ $0D80, X
        
        ; "Well little partner, you can just turn yourself right around and..."
        LDA.b #$87
        
        BRA .show_message
    
; ==============================================================================

    ; $282D4-$283CE BRANCH LOCATION
    ArcheryGameGuy_RunGame:
    {
        LDA $0EB0, X : BNE .arrows_already_laid_out
        
        LDA.b #$05 : STA $0B99
        
        LDA.b #$02
        
        JSL Sprite_InitializeSecondaryItemMinigame
        
        ; Start a delay counter to populate the counter with arrows.
        LDA.b #$27 : STA $0E00, X
        
        REP #$20
        
        ; Take 20 rupees as payment for the game.
        LDA $7EF360 : SUB.b #$0014 : STA $7EF360
        
        SEP #$20
        
        INC $0EB0, X
    
    .arrow_already_laid_out
    
        LDA.b #$34 : JSL OAM_AllocateFromRegionA
        
        JSR Sprite2_PrepOamCoord
        
        LDY $0B99 : STY $0D
        
        LDA $0E00, X : BEQ .arrow_stagger_finished
        
        ; This code is in play when the arrows on the counter are being
        ; populated one by one.
        LSR #3 : TAY : LDA .override_num_arrows_displayed, Y : STA $0D
    
    .arrow_stagger_finished
    
        PHX
        
        LDA $0D : ASL A : ADD.b #$07 : TAX
        
        ; This loop draws the boundary of the arrows on the counter and the
        ; arrows themselves. If you cheat and 
        ; have too many arrows it will look glitched.
        LDY.b #$00
    
    .next_subsprite
    
        LDA $00 : ADD.b #$EC : ADC .x_offsets, X       : STA ($90), Y
        LDA $02 : ADD.b #$D0 : ADC .y_offsets, X : INY : STA ($90), Y
        
        LDA .chr, X        : INY : STA ($90), Y
        LDA .properties, X : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_subsprite
        
        PLX
        
        LDA $0B99
        ORA $0F10, X
        ORA $0C4A
        ORA $0C4B
        ORA $0C4C
        ORA $0C4D
        ORA $0C4E
        
        BNE .game_in_progress
        
        ; Expand hit box for the proprietor, so that if we just get close to him
        ; he'll ask us if we want to play the minigame again.
        LDA.b #$0A : STA $0F60, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_retry_minigame
        
        LDA $F6 : BPL .no_retry_minigame
        
        ; "Want to shoot again? > Continue > Quit"
        LDA.b #$88
        
        JSR ArcheryGameGuy_Main.show_message
        
        INC $0D80, X
    
    .no_retry_minigame
    .game_in_progress
    
        RTS
    
    .override_num_arrows_displayed
        db 5, 4, 3, 2, 1, 0
    
    .x_offsets
        db  0,  0,  0,  0, 64, 64, 64, 64
        db  8,  8, 16, 16, 24, 24, 32, 32
        db 40, 40
    
    .y_offsets
        db -8,  0,  8, 16, -8,  0,  8, 16
        db  0,  8,  0,  8,  0,  8,  0,  8
        db  0,  8
    
    .chr
        db $2B, $3B, $3B, $2B, $2B, $3B, $3B, $2B
        db $63, $73, $63, $73, $63, $73, $63, $73
        db $63, $73
    
    .properties
        db $33, $33, $B3, $B3, $73, $73, $F3, $F3
        db $32, $32, $32, $32, $32, $32, $32, $32
        db $32, $32
    }

; ==============================================================================

    ; $283CF-$283D8 DATA
    pool Sprite_GoodArcheryTarget:
    {
    
    .prizes
        ; \tcrf (verified)
        ; Note the larger prizes available. The limit here seems to be
        ; 10 levels, though because we can only have 5 arrows, the upper
        ; level prizes are not used. Needs screenshot.
        db 4, 8, 16, 32, 64, 99, 99, 99, 99, 99
    }

; ==============================================================================

    ; *$283D9-$284AE JUMP LOCATION
    Sprite_GoodArcheryTarget:
    {
        LDA $0ED0, X : CMP.b #$05 : BCC .prize_index_in_range
        
        LDA.b #$06 : STA $0DA0, X
    
    .prize_index_in_range
    
        LDA $0E40, X : AND.b #$E0 : STA $0E40, X
        
        LDA $0E10, X : BNE .arrow_sticking_out
        
        LDA $0E80, X : LSR #3
    
    .arrow_sticking_out
    
        AND.b #$04 : ASL #4 : STA $00
        
        LDA $0F50, X : AND.b #$BF : ORA $00 : STA $0F50, X
        
        LDA $0FDA : SUB.b #$03 : STA $0FDA
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        LDA $0E10, X : BEQ .no_arrow_sticking_out
        
        PHA
        
        LDA $0E40, X : ORA.b #$05 : STA $0E40, X
        
        PLA : CMP.b #$60 : BNE .dont_grant_rupees_this_frame
        
        LDA $11 : BNE .dont_grant_rupees_this_frame
        
        ; Make the proprietor go nuts and start banging a drum, or some other
        ; type of noise making thing.
        LDA.b #$70 : STA $0DF0
        
        LDY $0DA0, X
        
        LDA.b #$00 : XBA
        
        LDA (.prizes-1), Y : REP #$20 : ADD $7EF360 : STA $7EF360
        
        SEP #$20
    
    .dont_grant_rupees_this_frame
    
        JSR GoodArcheryTarget_DrawPrize
    
    .no_arrow_sticking_out
    
        BRA .moving_on
    
    ; *$2844E ALTERNATE ENTRY POINT
    shared Sprite_BadArcheryTarget:
    
        LDA $0E40, X : AND.b #$E0 : STA $0E40, X
        
        LDA $0FDA : ADD.b #$03 : STA $0FDA
        
        JSL Sprite_PrepAndDrawSingleLargeLong
    
    .moving_on
    
        JSR Sprite2_CheckIfActive
        
        LDA $0EE0, X : DEC A : BNE .no_error_sound
        
        ; Play error noise if we hit a bad target (a "hand").
        LDA.b #$3C : STA $012E
    
    .no_error_sound
    
        INC $0E80, X
        
        JSR Sprite2_MoveHoriz
        
        LDA $0E00, X : BNE .dont_initiate_x_reset
        
        LDA $0DF0, X : STA $0BA0, X : BNE .reset_x_coordinate
        
        JSR Sprite2_CheckTileCollision : BEQ .dont_initiate_x_reset
        
        LDA.b #$10 : STA $0DF0, X
        
        ; Remove the arrow
        STZ $0E10, X
    
    .dont_initiate_x_reset
    
        RTS
    
    .reset_x_values
    
        db $E8, $08
    
    .reset_x_coordinate
    
        CMP.b #$01 : BNE .delay
        
        LDY $0DC0, X
        
        LDA .respawn_values, Y : STA $0D10, X
        LDA $23                : STA $0D30, X
        
        LDA.b #$20 : STA $0E00, X
        
        ; Reset prize indicator (probably not entirely necessary?)
        STZ $0ED0, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $284AF-$284CE DATA
    pool GoodArcheryTarget_DrawPrize:
    {
    
    .x_offsets
        
        db  -8,  -8,   0,   8,  16
    
    .y_offsets
        db -24, -16, -20, -20, -20
    
    ; $284B9
    .chr
        db $0B, $1B, $B6, $02, $30
    
    .properties
        db $38, $38, $34, $35, $35
        
    ; $84C3 (-1 based array)
    .first_digit_chr
        db $12, $32, $31, $03, $22, $33
    
    ; $84C9 (-1 based array)
    .second_digit_chr
        db $7C, $7C, $22, $02, $12, $33
    }

; ==============================================================================

    ; *$284CF-$2852C LOCAL
    GoodArcheryTarget_DrawPrize:
    {
        ; Part of shooting gallery guy code
        
        JSR Sprite2_PrepOamCoord
        
        LDA $0DA0, X : STA $06
        
        PHX
        
        LDX.b #$04
        LDY.b #$04
    
    .next_subsprite
    
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        CPX.b #$04 : BNE .not_second_digit
        
        PHX
        
        LDX $06
        
        LDA (.second_digit_chr-1), X
        
        PLX
        
        BRA .write_chr
    
    .not_second_digit
    
        CPX.b #$03 : BNE .not_first_digit
        
        PHX
        
        LDX $06
        
        LDA (.first_digit_chr-1), X
        
        PLX
        
        BRA .write_chr
    
    .not_first_digit
    
        LDA .chr, X
    
    .write_chr
    
        INY : STA ($90), Y
        
        CMP.b #$7C : INY : LDA .properties, X : BCC .not_blank
        
        ; Mask off the name table bit (b / c apparently the blank exists in the
        ; first name table)
        AND.b #$FE
    
    .not_blank
    
        STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_subsprite
        
        PLX
        
        JSL Sprite_DrawDistressMarker
        
        RTS
    }

; ==============================================================================
