
    !is_altar_zelda = $0D90

; ==============================================================================

    ; *$ED1FD-$ED233 LONG
    ChattyAgahnim_SpawnZeldaOnAltar:
    {
        LDA $0D10, X : ADD.b #$08 : STA $0D10, X
        
        LDA $0D00, X : ADD.b #$06 : STA $0D00, X
        
        ; Spawn the Zelda companion sprite so Agahnim has something to teleport.
        LDA.b #$C1 : JSL Sprite_SpawnDynamically
        
        LDA.b #$01 : STA !is_altar_zelda, Y
                     STA $0BA0, Y
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $02 : ADD.b #$28 : STA $0D00, Y
        
        LDA.b #$00 : STA $0E40, Y
        
        LDA.b #$0C : STA $0F50, Y
        
        RTL
    }

; ==============================================================================

    ; *$ED234-$ED23E JUMP LOCATION
    Sprite_ChattyAgahnim:
    {
        LDA !is_altar_zelda, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ChattyAgahnim_Main
        dw Sprite_AltarZelda
    }

; ==============================================================================

    ; *$ED23F-$ED284 JUMP LOCATION
    ChattyAgahnim_Main:
    {
        LDA $0DB0, X : BEQ .not_afterimage
        
        LDA !timer_0, X : BNE .delay_self_termination
        
        STZ $0DD0, X
    
    .delay_self_termination
    
        AND.b #$01 : BNE .dont_draw
        
        JSR ChattyAgahnim_Draw
    
    .dont_draw
    
        RTS
    
    .not_afterimage
    
        JSR ChattyAgahnim_Draw
        JSR ChattyAgahnim_DrawTelewarpSpell
        
        ; Basically checking if off screen or in transition?
        ; Update: This gives the player time enough to walk up the stairs to see
        ; Zelda. Otherwise Agahnim would just start blabbing right away and
        ; begin the teleport sequence. \task Add telewarp to the list. heh.
        LDA $0F00, X : BEQ .not_paused
        
        STZ $0D80, X
        STZ $0DA0, X
        STZ $0DC0, X
        
        LDA.b #$40 : STA !timer_0, X
    
    .not_paused
    
        JSR Sprite4_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ChattyAgahnim_Problab
        dw ChattyAgahnim_LevitateZelda
        dw ChattyAgahnim_DoTelewarpSpell
        dw ChattyAgahnim_CompleteTelewarpSpell
        dw ChattyAgahnim_Epiblab
        dw ChattyAgahnim_TeleportTowardCurtains
        dw ChattyAgahnim_LingerThenTerminate
    }

; ==============================================================================

    ; *$ED285-$ED2A0 JUMP LOCATION
    ChattyAgahnim_Problab:
    {
        LDA !timer_0, X : BNE .delay_message
        
        LDA.b #$01 : STA $02E4
        
        ; "Ahah... [Name]! I have been waiting for you! Heh heh heh..."
        LDA.b #$3D : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        INC $0D80, X
    
    .delay_message
    
        RTS
    }

; ==============================================================================

    ; $ED2A1-$ED2A4 DATA
    pool ChattyAgahnim_LevitateZelda:
    {
    
    .animation_states
        db 2, 0, 3, 0
    }

; ==============================================================================

    ; *$ED2A5-$ED2EE JUMP LOCATION
    ChattyAgahnim_LevitateZelda:
    {
        INC $0DA0, X : LDA $0DA0, X : PHA : LSR #5 : AND.b #$03 : TAY
        
        LDA .animation_states, Y
        
        ; \hardcoded This Agahnim sprite is laboring under the assumption that
        ; the altar zelda sprite is in slot 0x0F. While this works, adding
        ; even one more sprite to the room would break it.
        LDY $0F7F : CPY.b #$10 : BCC .use_variable_animation_state
        
        LDA.b #$01
    
    .use_variable_animation_state
    
        STA $0DC0, X
        
        PLA : AND.b #$0F : BNE .anoincrement_zelda_altitude
        
        ; Set Zelda's animation state a certain way.
        ; \hardcoded Same as above.
        LDA.b #$01 : STA $0DCF
        
        ; \hardcoded Same as above.
        INC $0F7F : LDA $0F7F : CMP.b #$16 : BNE .delay_telewarp_spell
        
        LDY.b #$27 : STY $012F
        
        INC $0D80, X
        
        LDA.b #$FF : STA !timer_0, X
        
        LDA.b #$02 : STA $0E80, X
        
        LDA.b #$FF : STA $0E30, X
    
    .delay_telewarp_spell
    .anoincrement_zelda_altitude
    
        RTS
    }

; ==============================================================================

    ; *$ED2EF-$ED321 JUMP LOCATION
    ChattyAgahnim_DoTelewarpSpell:
    {
        LDA !timer_0, X : BEQ .advance_ai_state
        CMP.b #$78      : BEQ .start_flash_effect
        CMP.b #$80      : BCS .anoplay_spell_sfx
        AND.b #$03      : BNE .anoplay_spell_sfx
        
        LDA.b #$2B : STA $012F
        
        LDA $0E80, X : CMP.b #$0E : BEQ .anoplay_spell_sfx
        
        ADD.b #$04 : STA $0E80, X
    
    .anoplay_spell_sfx
    
        RTS
    
    .start_flash_effect
    
        LDA.b #$78 : STA $0FF9
        
        RTS
    
    .advance_ai_state
    
        INC $0D80, X
        
        LDA.b #$50 : STA !timer_0, X
        
        RTS
    }

; ==============================================================================

    ; *$ED322-$ED34E JUMP LOCATION
    ChattyAgahnim_CompleteTelewarpSpell:
    {
        LDA !timer_0, X : BEQ .finish_warping_zelda
        AND.b #$03      : BNE .return
        
        LDA $0E30, X : CMP.b #$09 : BEQ .return
        
        ADD.b #$02 : STA $0E30, X
        
        RTS
    
    .finish_warping_zelda
    
        ; \hardcoded Starts Zelda's timer to make her into a warping sprite.
        LDA.b #$13 : STA $0DFF
        
        INC $0D80, X
        
        LDA.b #$50 : STA !timer_0, X
        
        STZ $0E80, X
        
        LDA.b #$33 : STA $012E
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$ED34F-$ED36A JUMP LOCATION
    ChattyAgahnim_Epiblab:
    {
        LDA !timer_0, X : BNE .delay_message
        
        ; "... With this, the seal of the seven wise men is at last broken..."
        LDA.b #$3E : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        INC $0D80, X
        
        LDA.b #$02 : STA !timer_0, X
    
    .delay_message
    
        RTS
    }

; ==============================================================================

    ; *$ED36B-$ED391 JUMP LOCATION
    ChattyAgahnim_TeleportTowardCurtains:
    {
        LDA !timer_0, X : DEC A : BNE .delay_sfx
        
        LDA.b #$28 : STA $012F
    
    .delay_sfx
    
        LDA.b #$E0 : STA $0D40, X
        
        JSR Sprite4_MoveVert
        
        LDA $0D00, X : CMP.b #$30 : BCS .spawn_afterimage
        
        ; Set a timer to remain near the entrance for a bit once he reaches it.
        LDA.b #$42 : STA $0F10, X
        
        INC $0D80, X
    
    .spawn_afterimage
    
        JSL Sprite_SpawnAgahnimAfterImage
        
        RTS
    }

; ==============================================================================

    ; *$ED392-$ED3B8 LONG
    Sprite_SpawnAgahnimAfterImage:
    {
        LDY.b #$FF
        
        LDA $1A : AND.b #$03 : BNE .spawn_delay
        
        LDA.b #$C1 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $0DC0, X : STA $0DC0, Y
        
        LDA.b #$20 : STA !timer_0, Y
                     STA $0BA0, Y
                     STA $0DB0, Y
    
    .spawn_delay
    .spawn_failed
    
        TYA
        
        RTL
    }

; ==============================================================================

    ; *$ED3B9-$ED3D0 JUMP LOCATION
    ChattyAgahnim_LingerThenTerminate:
    {
        LDA $0F10, X : BNE .delay_self_termination
        
        STZ $02E4
        
        STZ $0DD0, X
        
        JSL Dungeon_ManuallySetSpriteDeathFlag
        
        LDA $0403 : ORA.b #$40 : STA $0403
    
    .delay_self_termination
    
        RTS
    }

; ==============================================================================

    ; $ED3D1-$ED450 DATA
    pool ChattyAgahnim_Draw:
    {
    
    .oam_groups
        dw -8, -8 : db $82, $0B, $00, $02
        dw  8, -8 : db $82, $4B, $00, $02
        dw -8,  8 : db $A2, $0B, $00, $02
        dw  8,  8 : db $A2, $4B, $00, $02
        
        dw -8, -8 : db $80, $0B, $00, $02
        dw  8, -8 : db $80, $4B, $00, $02
        dw -8,  8 : db $A0, $0B, $00, $02
        dw  8,  8 : db $A0, $4B, $00, $02
        
        dw -8, -8 : db $80, $0B, $00, $02
        dw  8, -8 : db $82, $4B, $00, $02
        dw -8,  8 : db $A0, $0B, $00, $02
        dw  8,  8 : db $A2, $4B, $00, $02
        
        dw -8, -8 : db $82, $0B, $00, $02
        dw  8, -8 : db $80, $4B, $00, $02
        dw -8,  8 : db $A2, $0B, $00, $02
        dw  8,  8 : db $A0, $4B, $00, $02
    }

; ==============================================================================

    ; *$ED451-$ED48C LOCAL
    ChattyAgahnim_Draw:
    {
        LDA $0F10, X : AND.b #$01 : BNE .dont_draw
        
        LDA $0DB0, X : STA $00
                       STZ $01
        
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #.oam_groups : STA $08
        
        LDA $00 : BNE .typical_oam_positioning
        
        ; Use special position for OAM (for after image version of the guy).
        ; \hardcoded Assumes these oam slots are unoccupied.
        LDA.w #$0900 : STA $90
        
        LDA.w #$0A60 : STA $92
    
    .typical_oam_positioning
    
        SEP #$20
        
        LDA.b #$04 : JSR Sprite4_DrawMultiple
        
        LDA.b #$12 : JSL Sprite_DrawShadowLong.variable
    
    .dont_draw
    
        RTS
    }

; ==============================================================================

    ; $ED48D-$ED515 DATA
    pool ChattyAgahnim_DrawTelewarpSpell:
    {
        ; \task This looks like a pain. Finish the labeling later.
    
    ; $ED48D
        db -10, -16 : db $CE, $06
        db  18,  16 : db $CE, $06
        db  20, -13 : db $26, $06
        db  20,  -5 : db $36, $06
        
        db -12, -13 : db $26, $46
        db -12,  -5 : db $36, $46
        db  18,   0 : db $26, $06
        db  18,   8 : db $36, $06
        
        db -10,   0 : db $26, $46
        db -10,   8 : db $36, $46
        db  -8,   0 : db $22, $06
        db   8,   0 : db $22, $46
        
        db  -8,  16 : db $22, $86
        db   8,  16 : db $22, $C6
    
    ; $ED4C5
        db -10, -16 : db $CE, $04
        db  18, -16 : db $CE, $04
        db  20, -13 : db $26, $44
        db  20,  -5 : db $36, $44
        
        db -12, -13 : db $26, $04
        db -12,  -5 : db $36, $04
        db  18,   0 : db $26, $44
        db  18,   8 : db $36, $44
        
        db -10,   0 : db $26, $04
        db -10,   8 : db $36, $04
        db  -8,   0 : db $20, $04
        db   8,   0 : db $20, $44
        
        db  -8,  16 : db $20, $84
        db   8,  16 : db $20, $C4
    
    ; $ED4FD
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $02, $02, $02, $02
    
    ; $ED50B
        db $00, $04, $08, $0C, $10, $14, $18, $1C
        db $20, $24, $28
    }

; ==============================================================================

    ; *$ED516-$ED57C LOCAL
    ChattyAgahnim_DrawTelewarpSpell:
    {
        LDA.b #$38 : JSL OAM_AllocateFromRegionA
        
        LDA $1A : LSR #2 : REP #$20 : LDA.w #$D48D : BCS .use_first_oam_group
        
        ADC.w #$0038
    
    .use_first_oam_group
    
        STA $08
        
        LDA.w #$D4FD : STA $0A
        
        SEP #$20
        
        LDA $0E80, X : BEQ .dont_draw_spell_at_all
        
        LDY $0E30, X
        
        STY $0D
        
        PHX
        
        DEC A : TAX
        
        INY
        
        LDA $D50B, Y : TAY
    
    .next_oam_entry
    
        LDA $00 : ADD ($08), Y : STA ($90), Y
        
        LDA $02 : ADD.b #$F8   : CLC
        INY     : ADC ($08), Y              : STA ($90), Y
        INY     : LDA ($08), Y              : STA ($90), Y
        INY     : LDA ($08), Y : ORA.b #$31 : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        ; \optimize This test / and branch is useless, A is clobbered again
        ; immediately.
        ; Also \unused (technically speaking)
        LDA.b #$00
        
        CPX.b #$04 : BCS .irrelevant
        
        LDA.b #$02
    
    .irrelevant
    
        LDA ($0A), Y : STA ($92), Y
        
        PLY : INY
        
        DEX : CPX $0D : BNE .next_oam_entry
        
        PLX
    
    .dont_draw_spell_at_all
    
        RTS
    }

; ==============================================================================

    ; *$ED57D-$ED580 JUMP LOCATION
    Sprite_AltarZelda:
    {
        JSR AltarZelda_Main
        
        RTS
    }

; ==============================================================================

    ; $ED581-$ED5A0 DATA
    pool AltarZelda_Main:
    {
    
    .oam_groups
        dw -4, 0 : db $03, $01, $00, $02
        dw  4, 0 : db $04, $01, $00, $02
        
        dw -4, 0 : db $00, $01, $00, $02
        dw  4, 0 : db $01, $01, $00, $02
    }

; ==============================================================================

    ; *$ED5A1-$ED5D8 LOCAL
    AltarZelda_Main:
    {
        LDA !timer_0, X : BEQ .not_telewarping_zelda
        
        ; If we end up here, we're drawing the telewarp sprite.
        PHA
        
        JSR AltarZelda_DrawWarpEffect
        
        PLA : CMP.b #$01 : BNE .delay_self_termination
        
        STZ $0DD0, X
    
    .delay_self_termination
    
        CMP.b #$0C : BCS .also_draw_zelda_body
        
        RTS
    
    .also_draw_zelda_body
    .not_telewarping_zelda
    
        LDA.b #$08 : JSL OAM_AllocateFromRegionA
        
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite4_DrawMultiple
        
        JSR AltarZelda_DrawBody
        
        RTS
    }

; ==============================================================================

    ; $ED5D9-$ED5E8 DATA
    pool AltarZelda_DrawBody:
    {
    
    .xy_offsets
        db 4, 4, 3, 3, 2, 2, 1, 1
        db 0, 0, 0, 0, 0, 0, 0, 0
    }

; ==============================================================================

    ; *$ED5E9-$ED660 LOCAL
    AltarZelda_DrawBody:
    {
        LDA.b #$08 : JSL OAM_AllocateFromRegionA
        
        LDA $0F70, X : CMP.b #$1F : BCC .z_coord_not_maxed
        
        ; \unused The code never allows Zelda's altitude to get this high.
        ; \optimize Therefore, could take out this whole check.
        LDA.b #$1F
    
    .z_coord_not_maxed
    
        LSR A : TAY
        
        LDA .xy_offsets, Y : STA $07
        
        ; Get 16-bit Y coordinate.
        LDA $0D00, X : SUB $E8 : STA $02
        LDA $0D20, X : SBC $E9 : STA $03
        
        LDY.b #$00
        
        LDA $00 : PHA : ADD $07              : STA ($90), Y
                  PLA : SUB $07 : LDY.b #$04 : STA ($90), Y
        
        REP #$20
        
        LDA $02 : ADD.w #$0007 : LDY.b #$01 : STA ($90), Y
                                 LDY.b #$05 : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0             : STA ($90), Y
                    LDY.b #$01 : STA ($90), Y
    
    .on_screen_y
    
        ; Writ chr and properties bytes to oam entry.
        LDA.b #$6C : LDY.b #$02 : STA ($90), Y
                     LDY.b #$06 : STA ($90), Y
        LDA.b #$24 : LDY.b #$03 : STA ($90), Y
                     LDY.b #$07 : STA ($90), Y
        
        ; Both are 16x16 sprites.
        LDA.b #$02 : LDY.b #$00 : STA ($92), Y
                     INY        : STA ($92), Y
        
        RTS
    }

; ==============================================================================

    ; $ED661-$ED6B0 DATA
    pool AltarZelda_DrawWarpEffect:
    {
    
    .oam_groups
        dw  4, 4 : db $80, $04, $00, $00
        dw  4, 4 : db $80, $04, $00, $00
        
        dw  4, 4 : db $B7, $04, $00, $00
        dw  4, 4 : db $B7, $04, $00, $00
        
        dw -6, 0 : db $24, $05, $00, $02
        dw  6, 0 : db $24, $45, $00, $02
        
        dw -8, 0 : db $24, $05, $00, $02
        dw  8, 0 : db $24, $45, $00, $02
        
        dw  0, 0 : db $C6, $05, $00, $02
        dw  0, 0 : db $C6, $05, $00, $02   
    }

; ==============================================================================

    ; *$ED6B1-$ED6D0 LOCAL
    AltarZelda_DrawWarpEffect:
    {
        LDA.b #$08 : JSL OAM_AllocateFromRegionA
        
        LDA.b #$00 : XBA
        
        LDA !timer_0, X : LSR #2 : REP #$20 : ASL #4
        
        ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite4_DrawMultiple
    }

; ==============================================================================
