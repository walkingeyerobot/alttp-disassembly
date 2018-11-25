
    ; Bank04.rtf
    ; Another new member of the family. After more than two years.

; ==============================================================================

    ; $26A00-$26A5F DATA
    pool Hobo_Draw:
    {
    
    .oam_groups
        dw -5,   3 : db $A6, $00, $00, $02
        dw  3,   3 : db $A7, $00, $00, $02
        dw -5,   3 : db $A6, $00, $00, $02
        dw  3,   3 : db $A7, $00, $00, $02
        
        dw -5,   3 : db $AB, $00, $00, $00
        dw  3,   3 : db $A7, $00, $00, $02
        dw -5,   3 : db $A6, $00, $00, $02
        dw  3,   3 : db $A7, $00, $00, $02
        
        dw  5, -11 : db $8A, $00, $00, $02
        dw -5,   3 : db $AB, $00, $00, $00
        dw  3,   3 : db $88, $00, $00, $02
        dw -5,   3 : db $A6, $00, $00, $02
    }

; ==============================================================================

    ; *$26A60-$26A80 LONG
    Hobo_Draw:
    {
        PHB : PHK : PLB
        
        LDA.b #$04 : STA $06
                     STZ $07
        
        LDA $0DC0, X : ASL #5
        
        ADC.b #.oam_groups                 : STA $08
        LDA.b #.oam_groups>>8 : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$26A81-$26A9C LONG
    Landmine_CheckDetonationFromHammer:
    {
        LDA $0301 : AND.b #$0A : BEQ .player_not_using_hammer
        
        LDA $44 : CMP.b #$80 : BEQ .cant_check
        
        JSL Player_SetupActionHitBoxLong
        JSL Sprite_SetupHitBoxLong
        JSL Utility_CheckIfHitBoxesOverlapLong
        
        RTL
    
    .cant_check
    .player_not_using_hammer
    
        CLC
        
        RTL
    }

; ==============================================================================

    ; *26A9D-$26B62 LONG
    EasterEgg_BageCode:
    {
        ; Code that utilizes the player's name (hidden, secret, awesome!!)
        
        LDA $F2 : AND.b #$10 : BNE .r_button_held
        
        JMP .fail
    
    .r_button_held
    
        REP #$20
        
        ; these are to check if your name is 'BAGE' (US rom) or ... 'iayuo' (JP rom)
        ; neither one makes much sense to me
        ; 'BAGE' could be 'bad game' as has been suggested
        LDA $7003D9 : CMP.w #$0001 : BNE .fail
        LDA $7003DB : CMP.w #$0000 : BNE .fail
        LDA $7003DD : CMP.w #$0006 : BNE .fail
        LDA $7003DF : CMP.w #$0004 : BNE .fail
        
        SEP #$20
        
        ; Grant 1/2 magic consumption.
        LDA.b #$01 : STA $7EF37B
        
        LDA $F6
        
        JSL .check_button_press
        
        LDA $7EF359 : CMP.b #$04 : BNE .not_golden_sword
        
        LDA.b #$03 : STA $7EF35A
        DEC A      : STA $7EF35B
    
    .not_golden_sword
    
        LDA $F4 : BPL .b_button_not_pressed
        
        ; turn on walk through walls code
        LDA $037F : EOR.b #$01 : STA $037F
    
    .b_button_not_pressed
    
        BIT $F4 : BVS .y_button_not_pressed
        
        ; refill all hearts, magic, bombs, and arrows
        LDA.b #$FF : STA $7EF372 : STA $7EF373 : STA $7EF375 : STA $7EF376
        
        ; add 255 rupees to the player's stash
                      ADD $7EF360 : STA $7EF360
        LDA $7EF361 : ADC.b #$00  : STA $7EF361
        
        ; give the player 9 keys
        LDA.b #$09 : STA $7EF36F
    
    .y_button_not_pressed
    
        RTL
    
    .fail
    
        SEP #$20
        
        ; joypad 2 R button is not being held
        LDA $F3 : AND.b #$10 : BEQ .return
        
        ; joypad 2 A button was not pressed this frame
        LDA $F7
        
    .check_button_press
    
        BPL .return
    
        LDA $7EF359 : INC A : CMP.b #$05 : BCC .valid_sword
        
        LDA.b #$01
    
    .valid_sword
    
        STA $7EF359
        
        LDA $7EF35B : INC A : CMP.b #$03 : BNE .valid_armor
        
        LDA.b #$00
        
    .valid_armor
    
        STA $7EF35B
        
        LDA $7EF35A : INC A : CMP.b #$04 : BNE .valid_shield
        
        LDA.b #$01
    
    .valid_shield
    
        STA $7EF35A
    
    .return
    
        RTL
    }

; ==============================================================================

    ; *$26B63-$26BA9 LONG
    Bomb_ProjectSpeedTowardsPlayer:
    {
        LDX.b #$00
        
        LDA $0D10, X : PHA
        LDA $0D30, X : PHA
        
        LDA $0D00, X : PHA
        LDA $0D20, X : PHA
        
        LDA $0F70, X : PHA
        
        LDA $00 : STA $0D10, X
        LDA $01 : STA $0D30, X
        
        LDA $02 : STA $0D00, X
        LDA $03 : STA $0D20, X
        
        STZ $0F70, X
        
        TYA
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        PLA : STA $0F70, X
        
        PLA : STA $0D20, X
        PLA : STA $0D00, X
        
        PLA : STA $0D30, X
        PLA : STA $0D10, X
        
        RTL
    }

; ==============================================================================

    ; \note The name of this routine has more to do with its only caller than
    ; with what it actually does. Anybody could call this and it would do the
    ; same thing regardless. However, the only caller of this subroutine
    ; replaced the player's coordinates with an ancillary object's coordinates
    ; (specifically, only bombs call this routine's caller).
    ; $26BAA-$26BB2 LONG
    Bomb_ProjectReflexiveSpeedOntoSpriteLong:
    {
        PHB : PHK : PLB
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $26BB3-$26BE4 DATA
    pool Sprite_DrawLargeWaterTurbulence:
    {
    
    .oam_groups
        dw -10, 14 : db $C0, $00, $00, $02
        dw  -5, 16 : db $C0, $40, $00, $02
        dw  -2, 18 : db $C0, $00, $00, $02
        dw   2, 18 : db $C0, $40, $00, $02
        dw   5, 16 : db $C0, $00, $00, $02
        dw  10, 14 : db $C0, $40, $00, $02
    
    .properties
        db $04, $44
    }

; ==============================================================================

    ; *$26BE5-$26C1B LONG
    Sprite_DrawLargeWaterTurbulence:
    {
        PHB : PHK : PLB
        
        LDA $0F50, X : PHA
        
        LDA $0E80, X : LSR A : AND.b #$01 : TAY
        
        LDA .properties, Y : STA $0F50, X
        
        ; \bug Why is this load not used?
        LDA.b #$18
        
        LDA $0B89, X : AND.b #$F0 : STA $0B89, X
        
        JSL OAM_AllocateFromRegionC
        
        REP #$20
        
        LDA.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$06 : JSL Sprite_DrawMultiple
        
        PLA : STA $0F50, X
        
        PLB
        
        RTL
    }
    
; ==============================================================================

    ; $26C1C-$26CBF EMPTY
    pool Empty:
    {
        ; \note Could use this for expansion.
        fillbyte $FF
        
        fill $A4
    }

; ==============================================================================

    ; $26CC0-$27FFF DATA
    pool Dungeon_ApplyOverlay:
    {
    
    .ptr_table
        dl .overlay_0
        dl .overlay_1
        dl .overlay_2
        dl .overlay_3
        dl .overlay_4
        dl .overlay_5
        dl .overlay_6
        dl .overlay_7
        dl .overlay_8
        dl .overlay_9
        dl .overlay_10
        dl .overlay_11
        dl .overlay_12
        dl .overlay_13
        dl .overlay_14
        dl .overlay_15
        dl .overlay_16
        dl .overlay_17
        dl .overlay_18
    
    .overlay_0
        db $AC, $38, $A4
        db $BC, $50, $A4
        db $B0, $70, $A4
        db $C8, $70, $A4
        db $94, $90, $A4
        db $B0, $90, $A4
        db $C8, $90, $A4
        db $94, $A8, $A4
        db $DC, $A8, $A4
        db $B8, $B8, $A4
        db $A0, $D0, $A4
        db $D0, $D0, $A4
        db $A4, $A8, $A4
        db $A0, $70, $A4
        
        db $FF, $FF
    
    .overlay_1
        db $58, $58, $A4
        db $A8, $58, $A4
        db $C8, $58, $A4
        db $C8, $A0, $A4
        db $D8, $B0, $A4
        db $C8, $C0, $A4
        db $30, $58, $A4
        db $48, $58, $A4
        db $A0, $C8, $A4
        db $B8, $80, $C7
        db $C8, $B0, $C7
        db $18, $48, $C7
        db $A0, $D8, $C7
        db $FF, $FF
    
    .overlay_2
        db $B8, $80, $A4
        db $C8, $B0, $A4
        db $18, $48, $A4
        db $A0, $D8, $A4
        db $30, $58, $C7
        db $48, $58, $C7
        db $A0, $C8, $C7
        db $C8, $A0, $C7
        db $D8, $B0, $C7
        db $C8, $C0, $C7
        db $58, $58, $C7
        db $A8, $58, $C7
        db $C8, $58, $C7
        
        db $FF, $FF
    
    .overlay_3
        db $B8, $38, $A4
        db $98, $50, $A4
        db $D8, $50, $A4
        db $B8, $A0, $A4
        db $20, $A0, $A4
        db $30, $B0, $A4
        db $40, $B0, $A4
        db $50, $A0, $A4
        db $A0, $70, $C7
        db $B8, $70, $C7
        db $D0, $70, $C7
        db $A0, $B0, $C7
        db $D0, $B0, $C7
        
        db $FF, $FF
    
    .overlay_4
        db $A0, $70, $A4
        db $B8, $70, $A4
        db $D0, $70, $A4
        db $A0, $B0, $A4
        db $D0, $B0, $A4
        db $20, $A0, $C7
        db $30, $B0, $C7
        db $40, $B0, $C7
        db $50, $A0, $C7
        db $B8, $38, $C7
        db $98, $50, $C7
        db $D8, $50, $C7
        db $B8, $A0, $C7
        
        db $FF, $FF
    
    .overlay_5
        db $78, $78, $A4
        
        db $FF, $FF
    
    .overlay_6
        db $28, $9C, $A4
        db $38, $9C, $A4
        db $38, $AC, $A4
        db $18, $AC, $A4
        db $18, $BC, $A4
        db $18, $CC, $A4
        db $38, $CC, $A4
        db $48, $BC, $A4
        db $58, $AC, $A4
        db $58, $CC, $A4
        db $28, $AC, $C7
        db $28, $BC, $C7
        db $28, $CC, $C7
        db $28, $DC, $C7
        db $48, $CC, $C7
        db $48, $DC, $C7
        db $48, $9C, $C7
        
        db $FF, $FF
    
    .overlay_7
        db $28, $AC, $A4
        db $28, $BC, $A4
        db $28, $CC, $A4
        db $28, $DC, $A4
        db $48, $CC, $A4
        db $48, $DC, $A4
        db $48, $9C, $A4
        db $18, $AC, $C7
        db $18, $BC, $C7
        db $18, $CC, $C7
        db $28, $9C, $C7
        db $38, $9C, $C7
        db $38, $AC, $C7
        db $38, $CC, $C7
        db $48, $BC, $C7
        db $58, $AC, $C7
        db $58, $CC, $C7
        
        db $FF, $FF
    
    .overlay_8
        db $30, $68, $A4
        db $30, $A0, $A4
        db $30, $78, $C7
        db $30, $90, $C7
        db $78, $48, $C7
        
        db $FF, $FF
    
    .overlay_9
        db $30, $78, $A4
        db $30, $90, $A4
        db $78, $48, $A4
        db $30, $68, $C7
        db $30, $A0, $C7
        
        db $FF, $FF
    
    .overlay_10
        db $78, $58, $A4
        db $78, $38, $C7
        
        db $FF, $FF
    
    .overlay_11
        db $78, $38, $A4
        db $78, $58, $C7
        
        db $FF, $FF
    
    .overlay_12
        db $28, $B0, $A4
        db $38, $C8, $A4
        db $40, $B0, $C7
        db $50, $D0, $C7
        db $1C, $58, $A4
        db $58, $38, $A4
        db $78, $58, $A4
        db $A0, $38, $A4
        db $38, $38, $C7
        db $58, $48, $C7
        db $B0, $38, $C7
        db $D0, $58, $C7
        
        db $FF, $FF
    
    .overlay_13
        db $40, $B0, $A4
        db $50, $D0, $A4
        db $28, $B0, $C7
        db $38, $C8, $C7
        db $38, $38, $A4
        db $58, $48, $A4
        db $B0, $38, $A4
        db $D0, $58, $A4
        db $1C, $58, $C7
        db $58, $38, $C7
        db $78, $58, $C7
        db $A0, $38, $C7
        
        db $FF, $FF
    
    .overlay_14
        db $30, $48, $A4
        db $40, $48, $A4
        db $50, $48, $A4
        db $A0, $48, $A4
        db $B8, $A8, $A4
        db $68, $38, $C7
        db $78, $38, $C7
        db $88, $38, $C7
        db $B8, $38, $C7
        
        db $FF, $FF
    
    .overlay_15
        db $68, $38, $A4
        db $78, $38, $A4
        db $88, $38, $A4
        db $B8, $38, $A4
        db $30, $48, $C7
        db $40, $48, $C7
        db $50, $48, $C7
        db $A0, $48, $C7
        db $B8, $A8, $C7
        
        db $FF, $FF
    
    .overlay_16
        db $98, $30, $A4
        db $98, $48, $A4
        db $A0, $A0, $C7
        db $B0, $A0, $C7
        db $C8, $D8, $C7
        db $D8, $D8, $C7
        
        db $FF, $FF
    
    .overlay_17
        db $98, $30, $C7
        db $98, $48, $C7
        db $A0, $A0, $A4
        db $B0, $A0, $A4
        db $C8, $D8, $A4
        db $D8, $D8, $A4
        
        db $FF, $FF
    
    .overlay_18
        db $20, $20, $A4
        db $18, $50, $A4
        db $38, $40, $A4
        db $38, $58, $A4
        db $50, $20, $A4
        db $50, $38, $A4
        db $58, $50, $A4
        
        db $FF, $FF
    }

; ==============================================================================

    ; $26F2F-$26F46 DATA (more unmapped)
    {
    pool Dungeon_LoadRoom:
    {
    
    .layout_ptrs
        dl $04EF47
        dl $04EFAF
        dl $04EFF0
        dl $04F04C
        dl $04F0A8
        dl $04F0EC
        dl $04F148
        dl $04F1A4
    
    ; $26F47
        ; \task populate this with data eventually.
    }

; ==============================================================================

