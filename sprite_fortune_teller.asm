
; ==============================================================================

    ; *$6C75A-$6C761 LONG
    Sprite_FortuneTellerLong:
    {
        ; Fortune teller / Dwarf Swordsmith.
        
        PHB : PHK : PLB
        
        JSR Sprite_FortuneTeller
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$6C762-$6C76C LOCAL
    Sprite_FortuneTeller:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FortuneTeller_Main
        dw Sprite_DwarfSolidity
    }

; ==============================================================================

    ; *$6C76D-$6C782 JUMP LOCATION
    Sprite_DwarfSolidity:
    {
        ; \note The sole purpose of this sprite is to add solidity to the Dwarf
        ; sprite (0x1A). Strange but true, as they could have just added this
        ; logic to the dwarf sprite logic and be done with it. Very peculiar...
        
        JSR Sprite5_CheckIfActive
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .player_didnt_touch
        
        PHX
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Player_HaltDashAttackLong
        
        PLX
    
    .player_didnt_touch
    
        RTS
    }

; ==============================================================================

    ; *$6C783-$6C799 JUMP LOCATION
    FortuneTeller_Main:
    {
        JSR FortuneTeller_Draw
        JSR Sprite5_CheckIfActive
        
        LDA $7EF3CA : ASL A : ROL #2 : AND.b #$01
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FortuneTeller_LightWorld
        dw FortuneTeller_DarkWorld
    }

; ==============================================================================

    ; *$6C79A-$6C7B0 JUMP LOCATION
    FortuneTeller_LightWorld:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw LW_FortuneTeller_WaitForInquiry
        dw LW_FortuneTeller_NotEnoughRupees
        dw LW_FortuneTeller_AskIfPlayerWantsReading
        dw LW_FortuneTeller_ReactToPlayerResponse
        dw FortuneTeller_GiveReading
        dw LW_FortuneTeller_ShowCostMessage
        dw LW_FortuneTeller_DeductPayment
        dw LW_FortuneTeller_DoNothing
    }

; ==============================================================================

    ; $6C7B1-$6C7B8 DATA
    FortuneTeller_Prices:
    {
        dw 10, 15, 20, 30
    }

; ==============================================================================

    ; *$6C7B9-$6C7DD JUMP LOCATION
    LW_FortuneTeller_WaitForInquiry:
    {
        STZ $0DC0, X
        
        JSL GetRandomInt : AND.b #$03 : ASL A : STA $0D90, X : TAY
        
        REP #$20
        
        LDA $7EF360 : CMP FortuneTeller_Prices, Y : SEP #$30 : BCS .has_enough
        
        INC $0D80, X
        
        RTS
    
    .has_enough
    
        LDA.b #$02 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$6C7DE-$6C7E6 JUMP LOCATION
    LW_FortuneTeller_NotEnoughRupees:
    {
        "... my condition isn't very good today. But I want you to come back..."
        LDA.b #$F2
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$6C7E7-$6C7FE JUMP LOCATION
    LW_FortuneTeller_AskIfPlayerWantsReading:
    {
        "...you might have an interesting destiny... May I tell your fortune?"
        LDA.b #$F3
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        LDA.b #$01 : STA $02E4
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$6C7FF-$6C828 JUMP LOCATION
    LW_FortuneTeller_ReactToPlayerResponse:
    {
        LDA $1CE8 : BNE .player_said_no
        
        LDA $0DF0, X : BNE .delay_and_animate
        
        INC $0D80, X
    
    .delay_and_animate
    
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        RTS
    
    .player_said_no
    
        ; "It is indeed a poor man who is not interested in his future..."
        LDA.b #$F5
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$02 : STA $0D80, X
        
        STZ $02E4
        
        RTS
    }

; ==============================================================================

    ; $6C829-$6C848 DATA
    pool FortuneTeller_GiveReading:
    {
    
    .messages_low
        db $EA, $EB, $EC, $ED, $EE, $EF, $F0, $F1
        db $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD
    
    .messages_high
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$6C849-$6C952 JUMP LOCATION
    FortuneTeller_GiveReading:
    {
        STZ $0DC0, X
        
        INC $0D80, X
        
        STZ $03
        
        LDA $7EF3C7 : CMP.b #$03 : BCS .three_pendant_map_icons_or_better
        
        STZ $00
        STZ $01
        
        JMP .show_message
    
    .three_pendant_map_icons_or_better
    
        LDA $7EF34E : BNE .has_book_of_mudora
        
        LDA.b #$02
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCC .also_load_next_1
        
        JMP .show_message
    
    .also_load_next_1
    .has_book_of_mudora
    
        LDA $7EF374 : AND.b #$02 : BNE .has_pendant_of_wisdom
        
        LDA.b #$01
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCC .also_load_next_2
        
        JMP .show_message
    
    .also_load_next_2
    .has_pendant_of_wisdom
    
        LDA $7EF344 : CMP.b #$02 : BCS .has_magic_powder
        
        LDA.b #$03
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCC .also_load_next_3
        
        JMP .show_message
    
    .also_load_next_3
    .has_magic_powder
    
        LDA $7EF356 : BNE .has_flippers
        
        LDA.b #$04
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCC .also_load_next_4
        
        JMP .show_message
    
    .also_load_next_4
    .has_flippers
    
        LDA $7EF357 : BNE .has_moon_pearl
        
        LDA.b #$05
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .has_moon_pearl
    
        LDA $7EF3C5 : CMP.b #$03 : BCS .beaten_agahnim
        
        LDA.b #$06
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .beaten_agahnim
    
        LDA $7EF37B : BNE .has_halved_magic_usage
        
        LDA.b #$07
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .has_halved_magic_usage
    
        LDA $7EF347 : BNE .has_bombos_medallion
        
        LDA.b #$08
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .has_bombos_medallion
    
        LDA $7EF3C9 : AND.b #$10 : BNE .opened_thieves_chest
        
        LDA.b #$09
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .opened_thieves_chest
    
        LDA $7EF3C9 : AND.b #$20 : BNE .saved_smithy_frog
        
        LDA.b #$0A
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .saved_smithy_frog
    
        LDA $7EF352 : BNE .has_magic_cape
        
        LDA.b #$0B
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .has_magic_cape
    
        LDA $7EF2DB : AND.b #$02 : BNE .bombed_open_pyramid
        
        LDA.b #$0C
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .bombed_open_pyramid
    
        LDA $7EF359 : CMP.b #$04 : BCS .has_golden_sword
        
        LDA.b #$0D
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
    
    .has_golden_sword
    
        LDA.b #$0E
        
        JSR FortuneTeller_PopulateNextMessageSlot : BCS .show_message
        
        LDA.b #$0F
        
        JSR FortuneTeller_PopulateNextMessageSlot
    
    .show_message
    
        ; Allows the fortune teller to alternate between two different messages
        ; within one group.
        LDA $7EF3C6 : EOR.b #$40 : STA $7EF3C6
        
        AND.b #$40 : ROL #3 : AND.b #$01 : TAY
        
        LDA $0000, Y : TAY
        
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
        
        RTS
    }

; ==============================================================================

    ; *$6C953-$6C95F LOCAL
    FortuneTeller_PopulateNextMessageSlot:
    {
        LDY $03
        
        ; Note that with subsequent calls we can always overwrite the second
        ; slot, but never the first. However, the above logic pretty much
        ; guarantees that this subroutine is always called exactly twice per
        ; reading.
        STA $0000, Y
        
        INY : CPY.b #$02 : BCS .both_slots_filled
        
        STY $03
    
    .both_slots_filled
    
        RTS
    }

; ==============================================================================

    ; $6C960-$6C975 LOCAL
    LW_FortuneTeller_ShowCostMessage:
    {
        STZ $0DC0, X
        
        REP #$20
        
        STZ $00
        STZ $02
        STZ $04
        STZ $06
        
        LDY $0D90, X
        
        LDA FortuneTeller_Prices, Y
        
        JMP DW_FortuneTeller_ShowCostMessage.known_amount
    }

; ==============================================================================

    ; *$6C976-$6C995 LOCAL
    LW_FortuneTeller_DeductPayment:
    {
        LDY $0D90, X
        
        REP #$20
        
        LDA $7EF360 : SUB FortuneTeller_Prices, Y : STA $7EF360
        
        SEP #$30
        
        INC $0D80, X
        
        LDA.b #$A0 : STA $7EF372
        
        STZ $02E4
    
    ; $6C995 ALTERNATE ENTRY POINT
    shared LW_FortuneTeller_DoNothing:
    
        RTS
    }

; ==============================================================================

    ; *$6C996-$6C9AC JUMP LOCATION
    FortuneTeller_DarkWorld:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw DW_FortuneTeller_WaitForInquiry
        dw DW_FortuneTeller_NotEnoughRupees
        dw DW_FortuneTeller_AskIfPlayerWantsReading
        dw DW_FortuneTeller_ReactToPlayerResponse
        dw FortuneTeller_GiveReading
        dw DW_FortuneTeller_ShowCostMessage
        dw DW_FortuneTeller_DeductPayment
        dw DW_FortuneTeller_DoNothing
    }

; ==============================================================================

    ; *$6C9AD-$6C9D1 JUMP LOCATION
    DW_FortuneTeller_WaitForInquiry:
    {
        STZ $0DC0, X
        
        JSL GetRandomInt : AND.b #$03 : ASL A : STA $0D90, X : TAY
        
        REP #$20
        
        LDA $7EF360 : CMP FortuneTeller_Prices, Y : SEP #$30 : BCS .has_enough
        
        INC $0D80, X
        
        RTS
    
    .has_enough
    
        LDA.b #$02 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$6C9D2-$6C9DA JUMP LOCATION
    DW_FortuneTeller_NotEnoughRupees:
    {
        "... my condition isn't very good today. But I want you to come back..."
        LDA.b #$F2
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$6C9DB-$6C9F2 JUMP LOCATION
    DW_FortuneTeller_AskIfPlayerWantsReading:
    {
        "...you might have an interesting destiny... May I tell your fortune?"
        LDA.b #$F3
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        LDA.b #$01 : STA $02E4
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$6C9F3-$6CA1C JUMP LOCATION
    DW_FortuneTeller_ReactToPlayerResponse:
    {
        LDA $1CE8 : BNE .player_said_no
        
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
    
    .delay
    
        RTS
    
    .player_said_no
    
        LDA.b #$F5
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        LDA.b #$02 : STA $0D80, X
        
        STZ $02E4
        
        RTS
    }


; ==============================================================================

    ; *$6CA1D-$6CA80 JUMP LOCATION
    DW_FortuneTeller_ShowCostMessage:
    {
        REP #$20
        
        STZ $00
        STZ $02
        STZ $04
        STZ $06
        
        LDY $0D90, X
        
        LDA FortuneTeller_Prices, Y
    
    ; $6CA2D ALTERNATE ENTRY POINT
    .known_amount
    
    .modulus_10000
    
        CMP.w #10000 : BCC .below_10000
        
        SBC.w #10000
        
        BRA .modulus_10000
    
    .below_10000
    .modulus_1000
    
        CMP.w #1000 : BCC .below_1000
        
        ; \bug Fortune teller costs never exceed 30
        ; rupees anyways, but this value looks ... it just looks wrong.
        ; Either way, it should get the job done equivalently, it'll just take
        ; longer.
        SBC.w #100
        
        INC $06
        
        BRA .modulus_1000
    
    .below_1000
    
    .modulus_100
    
        CMP.w #100 : BCC .below_100
        
        SBC.w #100
        INC $04
        
        BRA .modulus_100
    
    .below_100
    .modulus_10
    
        CMP.w #10 : BCC .below_10
        
        SBC.w #10
        
        INC $02
        
        BRA .modulus_10
    
    .below_10
    
        STA $00
        
        SEP #$30
        
        LDA $00 : ASL #4 : ORA $02 : STA $1CF2
        
        LDA $06 : ASL #4 : ORA $04 : STA $1CF3
        
        ; "Now I will take (amount) Rupees. (...) Yeehah ha hah!"
        LDA.b #$F4
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$6CA81-$6CAA0 JUMP LOCATION
    DW_FortuneTeller_DeductPayment:
    {
        LDY $0D90, X
        
        REP #$20
        
        LDA $7EF360 : SUB FortuneTeller_Prices, Y : STA $7EF360
        
        SEP #$30
        
        INC $0D80, X
        
        LDA.b #$A0 : STA $7EF372
        
        STZ $02E4
    
    ; $6CAA0
    shared DW_FortuneTeller_DoNothing:
    
        RTS
    }

; ==============================================================================

    ; $6CAA1-$6CB00 DATA
    pool FortuneTeller_Draw:
    {
    
    .oam_groups
        dw  0, -48 : db $0C, $00, $00, $02
        dw  0, -32 : db $2C, $00, $00, $00
        dw  8, -32 : db $2C, $40, $00, $00
        
        dw  0, -48 : db $0A, $00, $00, $02
        dw  0, -32 : db $2A, $00, $00, $00
        dw  8, -32 : db $2A, $40, $00, $00
        
        dw -4, -40 : db $66, $00, $00, $02
        dw  4, -40 : db $66, $40, $00, $02
        dw -4, -40 : db $66, $00, $00, $02
        
        dw -4, -40 : db $68, $00, $00, $02
        dw  4, -40 : db $68, $40, $00, $02
        dw -4, -40 : db $68, $00, $00, $02        
    }

; ==============================================================================

    ; *$6CB01-$6CB29 LOCAL
    FortuneTeller_Draw:
    {
        LDA $7EF3CA : ASL A : ROL #2 : AND.b #$01 : STA $00
        
        ASL A : ADC $00 : ADC $0DC0, X : ASL A : ADC $0DC0, X : ASL #3
        
        ; $6CAA1
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        LDA.b #$03 : JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================

    ; *$6CB2A-$6CB53 LONG
    Dwarf_SpawnDwarfSolidity:
    {
        LDA.b #$31 : JSL Sprite_SpawnDynamically
        
        LDA $00 : STA $0D10, Y
        LDA $01 : STA $0D30, Y
        
        LDA $02 : STA $0D00, Y
        LDA $03 : STA $0D20, Y
        
        LDA.b #$01 : STA $0E80, Y
        
        LDA.b #$00 : STA $0F60, Y
        
        LDA.b #$01 : STA $0BA0, Y
        
        RTL
    }

; ==============================================================================
