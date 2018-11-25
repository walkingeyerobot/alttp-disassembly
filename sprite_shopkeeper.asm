
; ==============================================================================

    ; *$F6EEF-$F6F11 JUMP LOCATION
    Sprite_ShopKeeper:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $EF12 ; = $F6F12* ; 
        dw $EF90 ; = $F6F90*
        dw $F038 ; = $F7038*
        dw $F078 ; = $F7078*
        dw $F0F3 ; = $F70F3* ; 
        dw $F14F ; = $F714F* ; Thief talkin about Ice Cave near Lake Hylia.
        dw $F14F ; = $F714F* ; Thief talkin about defeating enemies for rupees.
        dw $F16E ; = $F716E* ; 
        dw $F1F2 ; = $F71F2* ; 
        dw $F230 ; = $F7230* ;  
        dw $F27D ; = $F727D* ; 
        dw $F2AF ; = $F72AF* ; 
        dw $F2F0 ; = $F72F0* ; 
        dw $F322 ; = $F7322* ; 
    }

    ; *$F6F12-$F6F6C JUMP LOCATION
    {
        LDA $0FFF : BEQ .in_light_world
        
        JSL OAM_AllocateDeferToPlayerLong
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        LDA $0F50, X : AND.b #$3F : STA $00
        
        LDA $1A : ASL #3 : AND.b #$40 : ORA $00 : STA $0F50, X
    
    BRANCH_BETA:
    
        JSL Sprite_PlayerCantPassThrough
        
        LDY $0FFF
        
        LDA $EF69, Y       : XBA
        LDA $EF6B, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        LDA $0D80, X : BEQ BRANCH_F6F6D
        
        BRA BRANCH_F6F8F ; (RTS)
    
    .in_light_world
    
        LDA.b #$07 : STA $0F50, X
        
        JSL Shopkeeper_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        BRA BRANCH_BETA
    
    .messages_low
        ; "May I help you? Select the thing you like (...). Prices as marked!"
        ; "In such a dangerous world you may need many things..."
        db $65, $5F
    
    .messsages_high
        db $01, $01
    }

    ; *$F6F6D-$F6F8F LOCAL
    {
        REP #$20
        
        LDA $0FDA : ADD.w #$0060 : CMP $20 : SEP #$30 : BCC BRANCH_ALPHA
        
        LDY $0FFF
        
        LDA $EF69, Y       : XBA
        LDA $EF6B, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F6F90-$F6FBE JUMP LOCATION
    {
        JSL OAM_AllocateDeferToPlayerLong
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0F50, X : AND.b #$3F : STA $00
        
        LDA $1A : ASL #3 : AND.b #$40 : ORA $00 : STA $0F50, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $EFBF ; = $F6FBF*
        dw $EFD5 ; = $F6FD5*
        dw $F000 ; = $F7000*
    }

    ; $F6FBF-$F6FD4 JUMP LOCATION
    {
        LDA $04C4 : DEC A : CMP.b #$02 : BCC BRANCH_ALPHA
        
        LDA.b #$60
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC BRANCH_ALPHA
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F6FD5-$F6FFF JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        LDA.b #$1E
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_ALPHA
        
        LDA.b #$02 : STA $04C4
        
        LDA.b #$64
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$61
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; *$F7000-$F7016 JUMP LOCATION
    {
        LDA $04C4 : BNE BRANCH_ALPHA
        
        LDA.b #$63
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$7F
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

    ; *$F7017-$F7037 LOCAL
    {
        LDA $1A : AND.b #$03 : BNE BRANCH_ALPHA
        
        LDA.b #$02 : STA $0DC0, X
        
        JSR Sprite3_DirectionToFacePlayer
        
        CPY.b #$03 : BNE BRANCH_BETA
        
        LDY.b #$02
    
    BRANCH_BETA:
    
        TYA : STA $0EB0, X
    
    BRANCH_ALPHA:
    
        JSL OAM_AllocateDeferToPlayerLong
        JSL Thief_Draw
        
        RTS
    }

    ; *$F7038-$F704E JUMP LOCATION
    {
        JSR $F017 ; $F7017 IN ROM
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F04F ; = $F704F*
        dw $F05D ; = $F705D*
        dw $F074 ; = $F7074*
    ]

    ; $F704F-$F705C JUMP LOCATION
    {
        LDA.b #$76
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC BRANCH_ALPHA
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F705D-$F7077 JUMP LOCATION
    {
        LDA $0403 : AND.b #$40 : BNE BRANCH_ALPHA
        
        LDA $0403 : ORA.b #$40 : STA $0403
        
        INC $0D80, X
        
        LDY.b #$46 : JMP $F366 ; $F7366 IN ROM
    
    ; *$F7074 ALTERNATE ENTRY PONT
    BRANCH_ALPHA:
    
        STZ $0D80, X
        
        RTS
    }

    ; *$F7078-$F709B JUMP LOCATION
    {
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : EOR.b #$03 : STA $0DE0, X
        
        STZ $0DC0, X
        
        JSL MazeGameGuy_Draw
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F09C ; = $F709C*
        dw $F0B2 ; = $F70B2*
        dw $F0E1 ; = $F70E1*
    }

    ; *$F709C-$F70B1 JUMP LOCATION
    {
        LDA $04C4 : DEC A : CMP.b #$02 : BCC BRANCH_ALPHA
        
        ; "Pay me 20 Rupees and I'll let you open one chest. ...
        LDA.b #$7E
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC BRANCH_ALPHA
        
        INC $0D80, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F70B2-$F70DC JUMP LOCATION
    {
        LDA $1CE8 : BNE BRANCH_ALPHA
        
        LDA.b #$14
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_ALPHA
        
        LDA.b #$01 : STA $04C4
        
        LDA.b #$7F
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA.b #$80
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; $F70DD-$F70E0 DATA
    pool 
    {
    
    .messages_low
        ; "You can't open any more chests. The game is over."
        ; "Oh, I see...  Too bad. Drop by again after collecting Rupees."
        db $63, $7F
    
    .messages_high
        db $01, $01
    }

    ; *$F70E1-$F70F2 JUMP LOCATION
    {
        LDA $04C4 : TAY
        
        ; \bug Maybe? Don't see how the second message could ever occur so far.
        LDA $F0DD, Y       : XBA
        LDA $F0DF, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

    ; *$F70F3-$F7109 JUMP LOCATION
    {
        JSR $F017 ; $F7017 IN ROM
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F10A ; = $F710A*
        dw $F120 ; = $F7120*
        dw $F0E1 ; = $F70E1*
    }

    ; *$F710A-$F711F JUMP LOCATION
    {
        ; \bug Maybe? More like unnecessary given the structure of the minigame?
        LDA $04C4 : DEC A : CMP.b #$02 : BCC BRANCH_$F70B1 ; (RTS)
        
        ; "For 100 Rupees, I'll let you open one chest and keep the treasure..."
        LDA.b #$81
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    }

    ; *$F7120-$F714A JUMP LOCATION
    {
        LDA $1CE8 : BNE .player_declined
        
        LDA.b #$64
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC .cant_afford
        
        LDA.b #$01 : STA $04C4
        
        ; "All right! Open the chest you like!"
        LDA.b #$7F
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .cant_afford
    .player_declined
    
        ; "Oh, I see... Too bad. Drop by again after collecting Rupees."
        LDA.b #$80
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

    ; *$F714B-$F714E JUMP LOCATION
    {
    
    .messages_low
        ; "Check out the cave east of Lake Hylia. Strange and wonderful..."
        ; "You can earn a lot of Rupees by defeating enemies. It's the ..."
        db $77, $78
    
    .messages_high
        db $01, $01
    }

    ; *$F714F-$F716D JUMP LOCATION
    {
        JSR $F017   ; $F7017 IN ROM
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0E80, X : SUB.b #$05 : TAY
        
        LDA $F14B, Y : XBA
        LDA $F14D, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }


    ; *$F716E-$F71AC JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC BRANCH_ALPHA
        
        JSL Sprite_GetEmptyBottleIndex : BMI BRANCH_BETA
        
        LDA.b #$96
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC .player_cant_afford
        
        STZ $0DD0, X
        
        LDY.b #$2E : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        RTS
    
    BRANCH_BETA:
    
        LDA.b #$6D
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        JSR $F38A ; $F738A IN ROM
        
        RTS
    
    ; *$F71A1 ALTERNATE ENTRY POINT
    .player_cant_afford
    
        LDA.b #$7C
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        JSR $F38A ; $F738A IN ROM
        
        RTS
    }

; ==============================================================================

    ; $F71AD-$F71B2 DATA
    pool ShopKeeper_SpawnInventoryItem:
    {
    
    .x_offsets
        dw -44, 8, 60
    }

; ==============================================================================

    ; *$F71B3-$F71F1 LONG
    ShopKeeper_SpawnInventoryItem:
    {
        PHA : PHY
        
        LDA.b #$BB
        LDY.b #$0C
        
        JSL Sprite_SpawnDynamically.arbitrary
        
        PLA : STA $0E80, Y : STA $0BA0, Y
        
        PLA : PHX : ASL A : TAX
        
        LDA $00 : ADD.l .x_offsets + 0, X : STA $0D10, Y
        LDA $01 : ADC.l .x_offsets + 1, X : STA $0D30, Y
        
        LDA $02 : ADD.b #$27 : STA $0D00, Y
        LDA $03              : STA $0D20, Y
        
        LDA $0E40, Y : ORA.b #$04 : STA $0E40, Y
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$F71F2-$F722F JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSR $F261 ; $F7261 IN ROM
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC BRANCH_ALPHA
        
        LDA $7EF35A : BNE BRANCH_BETA
        
        LDA.b #$32
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_GAMMA
        
        STZ $0DD0, X
        
        LDY.b #$04 : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        LDA.b #$1C : STA $0F60, X
        
        RTS
    
    BRANCH_BETA:
    
        LDA.b #$66
    
    ; *$F7221 ALTERNATE ENTRY POINT
    
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        JSR $F38A   ; $F738A IN ROM
        
        RTS
    
    ; *$F722D ALTERNATE ENTRY POINT
    BRANCH_GAMMA:
    
        JMP $F1A1 ; $F71A1 IN ROM
    }

    ; *$F7230-$F7260 JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSR $F261   ; $F7261 IN ROM
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC BRANCH_ALPHA
        
        LDA $7EF35A : CMP.b #$02 : BCS BRANCH_$F7221
        
        LDA.b #$F4
        LDY.b #$01
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_$F722D
        
        STZ $0DD0, X
        
        LDY.b #$05 : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        LDA.b #$1C : STA $0F60, X
        
        RTS
    }

; ==============================================================================

    ; $F7261-$F727C LOCAL
    {
        STZ $0BA0, X
        
        LDA.b #$08 : STA $0B6B, X
        
        LDA.b #$04 : STA $0CAA, X
        
        LDA.b #$1C : STA $0F60, X
        
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA.b #$0A : STA $0F60, X
        
        RTS
    }

; ==============================================================================
    
    ; *$F727D-$F72AE JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC BRANCH_ALPHA
        
        LDA $7EF36C : CMP $7EF36D : BEQ BRANCH_BETA
        
        LDA.b #$0A
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_GAMMA
        
        STZ $0DD0, X
        
        LDY.b #$42 : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        RTS
    
    BRANCH_BETA:
    
        JSR $F38A ; $F738A IN ROM
        
        RTS
    
    BRANCH_GAMMA:
    
        JMP $F1A1 ; $F71A1 IN ROM
    }

    ; *$F72AF-$F72EF JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        JSR ShopKeeper_CheckPlayerSolicitedDamage
        
        BCC BRANCH_ALPHA
        
        LDA $7EF371
        
        PHX
        
        TAX
        
        LDA $0DDB58, X : PLX : CMP $7EF377 : BEQ BRANCH_BETA
        
        LDA.b #$1E
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_GAMMA
        
        STZ $0DD0, X
        
        LDY.b #$44 : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        RTS
    
    ; *$F72E1 ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        LDA.b #$6E
        LDY.b #$01
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        JSR $F38A   ; $F738A IN ROM
        
        RTS
    
    ; *$F72ED ALTERNATE ENTRY POINT
    BRANCH_GAMMA:
    
        JMP $F1A1 ; $F71A1 IN ROM
    }

    ; *$F72F0-$F7321 JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC BRANCH_ALPHA
        
        LDA $7EF370 : PHX
        
        TAX
        
        LDA $0DDB48, X
        
        PLX
        
        CMP $7EF343 : BEQ BRANCH_F72E1
        
        LDA.b #$32
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_$F72ED
        
        STZ $0DD0, X
        
        LDY.b #$31 : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F7322-$F7357 JUMP LOCATION
    {
        JSR ShopKeeper_DrawItemWithPrice
        JSR Sprite3_CheckIfActive
        JSL Sprite_PlayerCantPassThrough
        
        JSR ShopKeeper_CheckPlayerSolicitedDamage : BCC BRANCH_ALPHA
        
        JSL Sprite_GetEmptyBottleIndex : BMI BRANCH_BETA
        
        LDA.b #$0A
        LDY.b #$00
        
        JSR ShopKeeper_TryToGetPaid : BCC BRANCH_GAMMA
        
        STZ $0DD0, X
        
        LDY.b #$0E : JSR $F366 ; $F7366 IN ROM
    
    BRANCH_ALPHA:
    
        RTS
    
    BRANCH_BETA:
    
        LDA.b #$6D
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        JSR $F38A   ; $F738A IN ROM
        
        RTS
    
    BRANCH_GAMMA:
    
        JMP $F1A1 ; $F71A1 IN ROM
    }

; ==============================================================================

    ; $F7358-$F7365 DATA
    {
    
    .message_ids_low
        db $68, $67, $67, $6C, $69, $6A, $6B
    
    .message_ids_high
        db $01, $01, $01, $01, $01, $01, $01
    }

; ==============================================================================

    ; *$F7366-$F7389 LOCAL
    {
        ; Subroutine grants the player an item parameterized by the A register.
        
        STZ $02E9
        
        PHX
        
        JSL Link_ReceiveItem
        
        PLX
        
        LDA $0E80, X : SUB.b #$07 : BMI BRANCH_ALPHA
        
        TAY
        
        LDA .message_ids_low, Y  :       XBA
        LDA .message_ids_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
        JSL ShopKeeper_RapidTerminateReceiveItem
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F738A-$F7390 LOCAL
    {
        LDA.b #$3C : JSL Sound_SetSfx2PanLong
        
        RTS
    }

; ==============================================================================

    ; *$F7391-$F739D LOCAL
    ShopKeeper_CheckPlayerSolicitedDamage:
    {
        LDA $F6 : BPL .the_a_button_not_pressed
        
        ; \note The bcc branch seems kind of .... useless. Maybe there was
        ; some other code dummied out?
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_contact
        
        RTS
    
    .no_player_contact
    .the_a_button_not_pressed
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$F739E-$F73B5 LOCAL
    ShopKeeper_TryToGetPaid:
    {
        STA $00
        STY $01
        
        REP #$20
        
        LDA $7EF360 : CMP $00 : BCC .player_cant_afford
        
        SBC $00 : STA $7EF360
        
        SEC
    
    .player_cant_afford
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $F73B6-$F74CD DATA
    pool ShopKeeper_DrawItemWithPrice:
    {
    
    .oam_groups
        dw -4, 16 : db $31, $02, $00, $00
        dw  4, 16 : db $13, $02, $00, $00
        dw 12, 16 : db $30, $02, $00, $00
        dw  0,  0 : db $C0, $02, $00, $02
        dw  0, 11 : db $6C, $03, $00, $02
        
        dw  0, 16 : db $13, $02, $00, $00
        dw  0, 16 : db $13, $02, $00, $00
        dw  8, 16 : db $30, $02, $00, $00
        dw  0,  0 : db $CE, $04, $00, $02
        dw  4, 12 : db $38, $03, $00, $00
        
        dw -4, 16 : db $13, $02, $00, $00
        dw  4, 16 : db $30, $02, $00, $00
        dw 12, 16 : db $30, $02, $00, $00
        dw  0,  0 : db $CC, $08, $00, $02
        dw  4, 12 : db $38, $03, $00, $00
        
        dw  0, 16 : db $31, $02, $00, $00
        dw  0, 16 : db $31, $02, $00, $00
        dw  8, 16 : db $30, $02, $00, $00
        dw  4,  8 : db $29, $03, $00, $00
        dw  4, 11 : db $38, $03, $00, $00
        
        dw -4, 16 : db $03, $02, $00, $00
        dw -4, 16 : db $03, $02, $00, $00
        dw  4, 16 : db $30, $02, $00, $00
        dw  0,  0 : db $C4, $04, $00, $02
        dw  0, 11 : db $38, $03, $00, $00
        
        dw  0, 16 : db $13, $02, $00, $00
        dw  0, 16 : db $13, $02, $00, $00
        dw  8, 16 : db $30, $02, $00, $00
        dw  0,  0 : db $E8, $04, $00, $02
        dw  0, 11 : db $6C, $03, $00, $02
        
        db  0, 16 : db $31, $02, $00, $00
        db  0, 16 : db $31, $02, $00, $00
        db  8, 16 : db $30, $02, $00, $00
        db  4,  8 : db $F4, $0F, $00, $00
        db  4, 11 : db $38, $03, $00, $00
    }

; ==============================================================================

    ; *$F74CE-$F74F2 LOCAL
    ShopKeeper_DrawItemWithPrice:
    {
        LDA $0E80, X : SUB.b #$07 : REP #$20 : AND.w #$00FF : STA $00
                                               ASL #2       : ADC $00 : ASL #3
        
        ADC.w #.oam_groups : STA $08
        
        LDA.w #$0005 : STA $06
        
        SEP #$30
        
        JSL Sprite_DrawMultiple.player_deferred
        
        RTS
    }

; ==============================================================================
