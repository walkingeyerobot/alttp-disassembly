
; ==============================================================================

    ; *$2E3F3-$2E3FA LONG
    Sprite_WitchLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_Witch
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E3FB-$2E452 LOCAL
    Sprite_Witch:
    {
        JSR Witch_Draw
        JSR Sprite2_CheckIfActive
        
        LDA $0F60, X : PHA
        
        LDA.b #$02 : STA $0F60, X
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_not_close
        
        PHX
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Player_HaltDashAttackLong
        
        PLX
    
    .player_not_close
    
        PLA : STA $0F60, X
        
        LDA $1A : BNE .dont_change_stir_speed
        
        JSL GetRandomInt : AND.b #$01 : ADD.b #$02 : STA $0D90, X
    
    .dont_change_stir_speed
    
        LDA $0D90, X : STA $00
        
        LDA $1A
    
    ; \note (n refers to the value of $0D90, X)
    .shift_right_n_times
    
        LSR A
        
        DEC $00 : BPL .shift_right_n_times
        
        AND.b #$07 : STA $0DC0, X
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCC .not_preoccupied
        
        RTS
    
    .not_preoccupied
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Witch_Main
        dw Witch_GrantCaneOfByrna
    }

; ==============================================================================

    ; *$2E453-$2E45F JUMP LOCATION
    Witch_GrantCaneOfByrna:
    {
        ; \tcrf (verified)
        ; Apparently, the witch at one point was considered to be the
        ; means by which the Cane of Byrna was acquired... fascinating.
        ; This was tested and found to be functional by setting the witch's
        ; AI pointer ($0D80, X) to a value of 1. Under normal circumstances,
        ; it always remains zero.
        
        STZ $0D80, X
        
        LDY.b #$18
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        RTS
    }

; ==============================================================================

    ; *$2E460-$2E47B JUMP LOCATION
    Witch_Main:
    {
        STZ $00
        
        LDA $7EF344 : CMP.b #$01 : BNE .dont_have_mushroom
        
        INC $00
    
    .dont_have_mushroom
    
        LDA $00
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        ; \tcrf (unverified: not thoroughly investigated)
        ; Why so many slots? Could you originally trade her for other
        ; items? (Or was it an idea / planned but axed eventually?)
        
        dw $E47C ; = $2E47C*
        dw Witch_PlayerHasMushroom
        dw Witch_PlayerHasMushroom
        dw Witch_PlayerHasMushroom
        dw Witch_PlayerHasMushroom
    }

; ==============================================================================

    ; \task Label this location.
    ; *$2E47C-$2E4A6 JUMP LOCATION
    {
        LDA $7EF344 : CMP.b #$02 : BNE .dont_have_magic_powder
    
    .havent_given_mushroom
    
        ; "... making mushroom brew I am..."
        LDA.b #$4A
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    
    .dont_have_magic_powder
    
        PHX
        
        REP #$10
        
        LDX.w #$0212
        
        LDA $7EF000, X
        
        SEP #$30
        
        PLX
        
        CMP.b #$00 : BPL .havent_given_mushroom
        
        ; "... Come back to my shop later for something good... Heh heh..."
        LDA.b #$4B
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$2E4A7-$2E4CE JUMP LOCATION
    Witch_PlayerHasMushroom:
    {
        LDA $F0 : AND.b #$40 : BEQ .y_button_not_down
        
        ; Check if the player is giving the mushroom to the Witch.
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .dont_give_mushroom
        
        LDA $0202 : CMP.b #$05 : BNE .dont_give_mushroom
        
        LDA $7EF344 : CMP.b #$01 : BNE .dont_give_mushroom
        
        JSR Witch_PlayerHandsMushroomOver
    
    .dont_give_mushroom
    
        RTS
    
    .y_button_not_down
    
        ; "... If you give me that mushroom, I can finish my brew."
        LDA.b #$4C
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$2E4CF-$2E508 LOCAL
    Witch_PlayerHandsMushroomOver:
    {
        ; Witch
        
        ; Does Link have the mushroom?
        ; \item(Mushroom)
        LDA $7EF344 : CMP.b #$01 : BNE .not_haz_mushroom
        
        ; If so, take away the mushroom
        LDA.b #$00 : STA $7EF344
        
        PHX
        
        REP #$10
        
        LDX.w #$0212
        
        ; Make it so the witch's assistant has the magic powder ready
        LDA $7EF000, X : ORA.b #$80 : STA $7EF000, X
        
        SEP #$30
        
        STZ $012E
        
        JSL HUD.RefreshIconLong
        
        PLX
        
        ; "... Come back to my shop later for something good... Heh heh..."
        LDA.b #$4B
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$0D : JSL Sound_SetSfx1PanLong
    
    .not_haz_mushroom
    
        STZ $0ABF
        
        RTS
    }

; ==============================================================================

    ; $2E509-$2E55C DATA
    pool Witch_Draw:
    {
    
    .stirring_oam_groups
        db  -3,  8 : db $AE, $00
        db  -3, 16 : db $BE, $00
        
        db  -2,  8 : db $AE, $00
        db  -2, 16 : db $BE, $00
        
        db  -1,  8 : db $AF, $00
        db  -1, 16 : db $BF, $00
        
        db   0,  9 : db $AF, $00
        db   0, 17 : db $BF, $00
        
        db   1, 10 : db $AF, $00
        db   1, 18 : db $BF, $00
        
        db   0, 11 : db $AF, $00
        db   0, 18 : db $BF, $00
        
        db  -1, 10 : db $AE, $00
        db  -1, 18 : db $BE, $00
        
        db  -3,  9 : db $AE, $00
        db  -3, 17 : db $BE, $00
    
    ; $2E549
    .body_and_cauldron_oam_groups
        db   0, -4 : db $80, $00
        db -11, 15 : db $86, $04
        db  -3, 15 : db $86, $44
    
    ; $2E555
    .cloak_oam_groups
        db   0,  4 : db $84, $00
        
        db   0,  4 : db $82, $00       

    }

; ==============================================================================

    ; *$2E55D-$2E62A LOCAL
    Witch_Draw:
    {
        JSR Sprite2_PrepOamCoord
        JSL OAM_AllocateDeferToPlayerLong
        
        LDA $0DC0, X : STA $00
                       STZ $01
        
        PHX
        
        REP #$30
        
        ASL #3 : AND.w #$00FF : TAX
        
        LDY $90
        
        LDA .stirring_oam_groups+0, X : ADD $0FA8 : STA $0000, Y
        
        LDA .stirring_oam_groups+1, X : ADD $0FA9 : STA $0001, Y
        
        LDA .stirring_oam_groups+2, X : ORA $04 : STA $0002, Y
        
        LDA .stirring_oam_groups+4, X : ADD $0FA8 : STA $0004, Y
        
        LDA .stirring_oam_groups+5, X : ADD $0FA9 : STA $0005, Y
        
        LDA .stirring_oam_groups+6, X : ORA $04 : STA $0006, Y
        
        LDX.w #$0000
        
        LDA.w #$0002 : STA $0E
    
    .draw_body_and_cauldron
    
        LDA .body_and_cauldron_oam_groups+0, X : ADD $0FA8 : STA $0008, Y
        
        LDA .body_and_cauldron_oam_groups+1, X : ADC $0FA9 : STA $0009, Y
        
        LDA .body_and_cauldron_oam_groups+2, X : EOR $04 : STA $000A, Y
        
        INX #4
        
        INY #4
        
        DEC $0E : BPL .draw_body_and_cauldron
        
        LDA $00 : SUB.w #$0003 : CMP.w #$0003 : BCC .other_cloak_frame
        
        LDX.w #$0000
        
        BRA .draw_cloak
    
    .other_cloak_frame
    
        LDX.w #$0004
    
    .draw_cloak
    
        LDA .cloak_oam_groups+0, X : ADD $0FA8 : STA $0008, Y
        
        LDA .cloak_oam_groups+1, X : ADD $0FA9 : STA $0009, Y
        
        LDA .cloak_oam_groups+2, X : ORA $04 : STA $000A, Y
        
        LDY $92
        
        ; Set oam sizes (8x8 vs. 16x16)
        LDA.w #$0000 : STA $0000, Y
        LDA.w #$0202 : STA $0002, Y : STA $0004, Y
        
        SEP #$30
        
        PLX
        
        LDA.b #$05
        LDY.b #$FF
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    }

