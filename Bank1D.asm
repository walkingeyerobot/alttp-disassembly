
; ==============================================================================

    ; $E8000-$E800F DATA
    pool Sprite_ApplyConveyorAdjustment:
    {
    
    .x_shake_values
        db  1, -1
    
    .y_shake_values
        db 0, -1
        
    .y_speeds_high length 4
        db -1,  0
    
    .x_speeds_low length 4
        db  0,  0
    
    .y_speeds_low
        db -1,  1,  0,  0
        
    .x_high
        db  0,  0, -1,  0
    }

; ==============================================================================

    ; *$E8010-$E803F LONG
    Sprite_ApplyConveyorAdjustment:
    {
        ; Seems like this handles the velocity adjustment that a conveyor
        ; belt provides. The input for Y only allows for tile types 0x68 to
        ; 0x6B
        
        LDA $1A : LSR A : BCC .return
        
        PHB : PHK : PLB
        
        ; I think it is perhaps possible that the low byte offset is an
        ; incorrectly calculated address. It overlaps with that of the Y
        ; coordinate's adjustment.
        LDA $0D10, X : ADD .x_speeds_low       , Y : STA $0D10, X
        LDA $0D30, X : ADC .x_speeds_high - $68, Y : STA $0D30, X
        
        LDA $0D00, X : ADD .y_speeds_low  - $68, Y : STA $0D00, X
        LDA $0D20, X : ADC .y_speeds_high - $68, Y : STA $0D20, X
        
        PLB
    
    .return
    
        RTL
    }

; ==============================================================================

    ; *$E8040-$E808B LONG
    Sprite_CreateDeflectedArrow:
    {
        ; Creates a ... arrow that has been deflected (as in, now it's falling)
        ; This is the opposite of the arrow ending up stuck in an enemy or wall.
        
        PHB : PHK : PLB
        
        PHY
        
        STZ $0C4A, X
        
        LDA.b #$1B : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $0C04, X : STA $0D10, Y
        LDA $0C18, X : STA $0D30, Y
        
        LDA $0BFA, X : STA $0D00, Y
        LDA $0C0E, X : STA $0D20, Y
        
        LDA.b #$06 : STA $0DD0, Y
        
        LDA.b #$1F : STA $0DF0, Y
        
        LDA $0C2C, X : STA $0D50, Y
        
        LDA $0C22, X : STA $0D40, Y
        
        LDA $EE : STA $0F20, Y
        
        PHX
        
        TYX
        
        JSL Sprite_PlaceRupulseSpark
        
        PLX
    
    .spawn_failed
    
        PLY
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$E808C-$E8093 LONG
    Sprite_MoveLong:
    {
        ; Invoked from ending mode usually...?
        PHB : PHK : PLB
        
        JSR Sprite4_Move
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$E8094-$E8098 LOCAL
    Sprite4_CheckTileCollision:
    {
        JSL Sprite_CheckTileCollisionLong
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_landmine.asm"
    incsrc "sprite_stal.asm"
    incsrc "sprite_fish.asm"
    incsrc "sprite_rabbit_beam.asm"
    incsrc "sprite_lynel.asm"
    incsrc "sprite_phantom_ganon.asm"
    incsrc "sprite_trident.asm"
    incsrc "sprite_flame_trail_bat.asm"
    incsrc "sprite_spiral_fire_bat.asm"
    incsrc "sprite_fire_bat.asm"
    incsrc "sprite_ganon.asm"
    incsrc "sprite_swamola.asm"
    incsrc "sprite_blind_entities.asm"
    incsrc "sprite_trinexx.asm"
    incsrc "sprite_sidenexx.asm"
    incsrc "sprite_chain_chomp.asm"

; ==============================================================================

    ; *$EC211-$EC219 LOCAL
    Sprite4_CheckDamage:
    {
        JSL Sprite_CheckDamageFromPlayerLong
        JSL Sprite_CheckDamageToPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$EC21A-$EC221 LONG
    SpriteActive4_MainLong:
    {
        PHB : PHK : PLB
        
        JSR SpriteActive4_Main
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EC222-$EC26C LOCAL
    SpriteActive4_Main:
    {
        ; Ranges from 0 to 0x1A (since highest pointer is 0xD7)
        LDA $0E20, X : SUB.b #$BD : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        ; Again, we have a subtle jump table by means of stack manipulation.
        LDA .handlers, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .handlers
        ; Sprite routines 4
        ; 
        ; Numbers in the index are actual sprite values, not the indexed values
        ; for the table itself in rom.
        
        dw Sprite_Vitreous             ; 0xBD - Vitreous
        dw Sprite_Vitreolus            ; 0xBE - "???" in hyrule magic 
        dw Sprite_Lightning            ; 0xBF - Vitreous' Lightning (also Agahnim)
        dw Sprite_GreatCatfish         ; 0xC0 - Lake of Ill Omen Monster
        dw Sprite_ChattyAgahnim        ; 0xC1 - Agahnim teleporting Zelda to darkworld
        dw Sprite_Boulder              ; 0xC2 - Boulders
        dw Sprite_Gibo                 ; 0xC3 - Symbion 2
        dw Sprite_Thief                ; 0xC4 - Thief
        dw Sprite_Medusa               ; 0xC5 - Evil fireball spitting faces!
        dw Sprite_FireballJunction     ; 0xC6 - Four way fireball spitters
        dw Sprite_Hokbok               ; 0xC7 - Hokbok and its segments (I call them Ricochet)
        dw Sprite_BigFaerie            ; 0xC8 - Big Faerie / Faerie Dust Cloud
        dw Sprite_GanonHelpers         ; 0xC9 - Ganon's Firebat, Tektite and friends
        dw Sprite_ChainChomp           ; 0xCA - Chain Chomp
        dw Sprite_Trinexx              ; 0xCB - Trinexx 1
        dw $B897 ; = $EB897*           ; 0xCC - Trinexx 2
        dw $B89F ; = $EB89F*           ; 0xCD - Trinexx 3
        dw Sprite_BlindEntities        ; 0xCE - Blind the Thief
        dw Sprite_Swamola              ; 0xCF - Swamola
        dw Sprite_Lynel                ; 0xD0 - Lynel
        dw Sprite_ChimneyAndRabbitBeam ; 0xD1 - Yellow Hunter pointer
        dw Sprite_Fish                 ; 0xD2 - flopping fish
        dw Sprite_Stal                 ; 0xD3 - Stal
        dw Sprite_Landmine             ; 0xD4 - Landmine
        dw Sprite_DiggingGameGuy       ; 0xD5 - Digging game guy
        dw Sprite_Ganon                ; 0xD6 - Pointer for Ganon.
        dw Sprite_Ganon                ; 0xD7 - Pointer for Ganon when he's invincible (blue mode)
    }

; ==============================================================================

    incsrc "sprite_tektite.asm"
    incsrc "sprite_big_faerie.asm"
    incsrc "sprite_hokbok.asm"
    incsrc "sprite_medusa.asm"
    incsrc "sprite_fireball_junction.asm"
    incsrc "sprite_thief.asm"
    incsrc "sprite_gibo.asm"
    incsrc "sprite_boulder.asm"
    incsrc "sprite_chatty_agahnim.asm"
    incsrc "sprite_giant_moldorm.asm"
    incsrc "sprite_vulture.asm"
    incsrc "sprite_raven.asm"

; ==============================================================================

    ; *$EDE82-$EDE89 LONG
    Vitreous_SpawnSmallerEyesLong:
    {
        PHB : PHK : PLB
        
        JSR Vitreous_SpawnSmallerEyes
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EDE8A-$EDECA DATA
    {
    
    .
        db 
    
    }

; ==============================================================================

    ; *$EDECB-$EDF44 LOCAL
    Vitreous_SpawnSmallerEyes:
    {
        LDA.b #$09 : STA $0ED0, X
        
        LDA.b #$04 : STA $0DC0, X
        
        LDY.b #$0D
        
        JSL Sprite_SpawnDynamically_arbitrary
        
        LDY.b #$0C
    
    .next_eyeball
    
        LDA.b #$09 : STA $0DD1, Y
        
        LDA.b #$BE : STA $0E21, Y
        
        PHX : TYX : INX
        
        JSL Sprite_LoadProperties
        
        PLX
        
        LDA.b #$00 : STA $0F21, Y
        
        LDA $00 : ADD $DE8A, Y : STA $0D11, Y
                                 STA $0D91, Y
        
        LDA $01 : ADC $DE97, Y : STA $0D31, Y
                                 STA $0DA1, Y
        
        LDA $02 : ADD $DEA4, Y : PHP : ADD.b #$20 : STA $0D01, Y
                                                    STA $0DB1, Y
        
        LDA $03 : ADC.b #$00   : PLP : ADC $DEB1, Y : STA $0D21, Y
                                                      STA $0DE1, Y
        
        LDA $DEBE, Y : STA $0DC1, Y : STA $0BA1, Y
        
        TYA : ASL #3 : STA $0F
        
        JSL GetRandomInt : ADC $0F : STA $0E81, Y
        
        DEY : BPL .next_eyeball
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_great_catfish.asm"
    incsrc "sprite_lightning.asm"
    incsrc "sprite_vitreous.asm"
    incsrc "sprite_vitreolus.asm"

; ==============================================================================

    ; *$EE893-$EE897 LOCAL
    Sprite4_DirectionToFacePlayer:
    {
        JSL Sprite_DirectionToFacePlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$EE898-$EE89C LOCAL
    Sprite4_IsToRightOfPlayer:
    {
        JSL Sprite_IsToRightOfPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$EE89D-$EE8A1 LOCAL
    Sprite4_IsBelowPlayer:
    {
        JSL Sprite_IsBelowPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$EE8A2-$EE8BE LOCAL
    Sprite4_CheckIfActive:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .inactive
        
        LDA $0FC1 : BNE .inactive
        
        LDA $11 : BNE .inactive
        
        LDA $0CAA, X : BMI .active
        
        LDA $0F00, X : BEQ .active
    
    .inactive
    
        PLA : PLA
    
    .active
    
        RTS
    }

; ==============================================================================

    ; *$EE8C5-$EE947 LOCAL
    Sprite4_CheckIfRecoiling:
    {
        LDA $0EA0, X : BEQ .return
        AND.b #$7F   : BEQ .recoil_finished
        
        LDA $0D40, X : PHA
        LDA $0D50, X : PHA
        
        DEC $0EA0, X : BNE .not_halted_yet
        
        LDA $0F40, X : ADD.b #$20 : CMP.b #$40 : BCS .too_fast_so_halt
        
        LDA $0F30, X : ADD.b #$20 : CMP.b #$40 : BCC .slow_enough
    
    .too_fast_so_halt
    
        LDA.b #$90 : STA $0EA0, X
    
    .slow_enough
    .not_halted_yet
    
        LDA $0EA0, X : BMI .halted
        
        LSR #2 : TAY
        
        LDA $1A : AND $E8BF, Y : BNE .halted
        
        LDA $0F30, X : STA $0D40, X
        LDA $0F40, X : STA $0D50, X
        
        LDA $0CD2, X : BMI .no_wall_collision
        
        JSR Sprite4_CheckTileCollision
        
        AND.b #$0F : BEQ .no_wall_collision
        CMP.b #$04 : BCS .y_axis_wall_collision
        
        STZ $0F40, X
        STZ $0D50, X
        
        BRA .moving_on
    
    .y_axis_wall_collision
    
        STZ $0F30, X
        STZ $0D40, X
    
    .moving_on
    
        BRA .halted
    
    .no_wall_collision
    
        JSR Sprite4_Move
    
    .halted
    
        PLA : STA $0D50, X
        PLA : STA $0D40, X
        
        ; Blind the thief. \task Apply enumerated value here when it becomes
        ; available.
        LDA $0E20, X : CMP.b #$CE : BEQ .return
        
        PLA : PLA
    
    .return
    
        RTS
    
    .recoil_finished
    
        STZ $0EA0, X
        
        RTS
    }

; ==============================================================================

    ; *$EE948-$EE951 LOCAL
    Sprite4_MoveXyz:
    {
        JSR Sprite4_MoveAltitude
    
    ; *$EE94B ALTERNATE ENTRY POINT
    shared Sprite4_Move:
    
        JSR Sprite4_MoveHoriz
        JSR Sprite4_MoveVert
        
        RTS
    }

; ==============================================================================

    ; *$EE952-$EE95C LOCAL
    Sprite4_MoveHoriz:
    {
        PHX : TXA : ADD.b #$10 : TAX
        
        JSR Sprite4_MoveVert
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$EE95D-$EE98A LOCAL
    Sprite4_MoveVert:
    {
        LDA $0D40, X : BEQ .no_velocity
        
        ASL #4 : ADD $0D60, X : STA $0D60, X
        
        LDA $0D40, X : PHP : LSR #4 : LDY.b #$00 : PLP : BPL .positive
        
        ORA.b #$F0
        
        DEY
    
    .positive
    
              ADC $0D00, X : STA $0D00, X
        TYA : ADC $0D20, X : STA $0D20, X
    
    .no_velocity
    
        RTS
    }

; ==============================================================================

    ; *$EE98B-$EE9AC LOCAL
    Sprite4_MoveAltitude:
    {
        LDA $0F80, X : ASL #4 : ADD $0F90, X : STA $0F90, X
        
        ; Sign extend the difference from 4 bits to 8.
        LDA $0F80, X : PHP : LSR #4 : PLP : BPL .sign_extend
        
        ORA.b #$F0
    
    .sign_extend
    
        ADC $0F70, X : STA $0F70, X
        
        RTS
    }

; ==============================================================================

    ; *$EE9AD-$EE9B5 LOCAL
    Sprite4_PrepOamCoord:
    {
        ; \task Perhaps come up with a better name for these sublabels?
        JSL Sprite_PrepOamCoordLong : BCC .sprite_wasnt_disabled
        
        PLA : PLA
    
    .sprite_wasnt_disabled
    
        RTS
    }

; ==============================================================================

    ; *$EE9B6-$EE9D9 LONG
    Filter_MajorWhitenMain:
    {
        LDA $0FF9 : BEQ .major_white_filter_inactive
        
        LDY $11 : BNE .major_white_filter_inactive
        
        DEC $0FF9 : BNE .filter_still_active
        
        ; What the hell, restore the whole damn set of BG palettes, even the
        ; HUD ones. I don't quite understand why this is necessary though, as
        ; the HUD palettes weren't (intentionally) modified by this
        ; particular subset of the game logic.
        JSL Palette_Restore_BG_And_HUD
        
        RTL
    
    .filter_still_active
    
        AND.b #$01 : BEQ .restore_palette
        
        JSL Filter_Majorly_Whiten_Bg
        
        BRA .set_palette_update_flag
    
    .restore_palette
    
        JSL Palette_Restore_BG_From_Flash
    
    .set_palette_update_flag
    
        INC $15
    
    .major_white_filter_inactive
    
        RTL
    }

; ==============================================================================

    ; *$EE9DA-$EE9FF LONG
    CacheSprite_ExecuteAll:
    {
        ; Some kind of special enemy "switch out"
        ; It's used on certain room transitions where the enemies from both rooms
        ; are supposed to remain visible (excludes spiral staircases)
        
        ; Don't do this outdoors
        LDA $1B : BEQ .return
        
        ; Don't use if in "normal" submode
        ; Don't use if going on a spiral staircase
        LDA $11    : BEQ .return
        CMP.b #$0E : BEQ .return
        
        ; the last screen transition occurred on the overworld, and no 
        ; sprites were cached anyways.
        LDA $0FFA : BEQ .return
        
        LDX.b #$0F
    
    .next_cached_sprite
    
        STX $0FA0
        
        LDA $1D00, X : BEQ .inactive_cached_sprite
        
        JSR CacheSprite_ExecuteSingle
    
    .inactive_cached_sprite
    
        DEX : BPL .next_cached_sprite
        
        RTL
    
    .return
    
        STZ $0FFA
        
        RTL
    }

; ==============================================================================

    ; *$EEA00-$EEB67 LOCAL
    CacheSprite_ExecuteSingle:
    {
        ; Save the relevant data of this non-cached sprite before
        ; swapping in the cached sprite data.
        LDA $0DD0, X : PHA
        LDA $0E20, X : PHA
        LDA $0D10, X : PHA
        LDA $0D30, X : PHA
        LDA $0D00, X : PHA
        LDA $0D20, X : PHA
        LDA $0DC0, X : PHA
        LDA $0D90, X : PHA
        LDA $0EB0, X : PHA
        LDA $0F50, X : PHA
        LDA $0B89, X : PHA
        LDA $0DE0, X : PHA
        LDA $0E40, X : PHA
        LDA $0F20, X : PHA
        LDA $0D80, X : PHA
        LDA $0E60, X : PHA
        LDA $0DA0, X : PHA
        LDA $0DB0, X : PHA
        LDA $0E90, X : PHA
        LDA $0E80, X : PHA
        LDA $0F70, X : PHA
        LDA $0DF0, X : PHA
        
        LDA $7FF9C2, X : PHA
        
        LDA $0BA0, X : PHA
        
        ; temporarily swap the cached sprite data in.
        LDA $1D00, X : STA $0DD0, X
        LDA $1D10, X : STA $0E20, X
        LDA $1D20, X : STA $0D10, X
        LDA $1D30, X : STA $0D30, X
        LDA $1D40, X : STA $0D00, X
        LDA $1D50, X : STA $0D20, X
        LDA $1D60, X : STA $0DC0, X
        LDA $1D70, X : STA $0D90, X
        LDA $1D80, X : STA $0EB0, X
        LDA $1D90, X : STA $0F50, X
        LDA $1DA0, X : STA $0B89, X
        LDA $1DB0, X : STA $0DE0, X
        LDA $1DC0, X : STA $0E40, X
        LDA $1DD0, X : STA $0F20, X
        LDA $1DE0, X : STA $0D80, X
        LDA $1DF0, X : STA $0E60, X
        
        LDA $7FFA5C, X : STA $0DA0, X
        LDA $7FFA6C, X : STA $0DB0, X
        LDA $7FFA7C, X : STA $0E90, X
        LDA $7FFA8C, X : STA $0E80, X
        LDA $7FFA9C, X : STA $0F70, X
        LDA $7FFAAC, X : STA $0DF0, X
        LDA $7FFACC, X : STA $7FF9C2, X
        LDA $7FFADC, X : STA $0BA0, X
        
        JSL Sprite_ExecuteSingleLong
        
        LDA $0F00, X : BEQ .active_sprite
        
        STZ $1D00, X
    
    .active_sprite
    
        ; Restore the data of the non-cached sprite from the stack.
        PLA : STA $0BA0, X
        
        PLA : STA $7FF9C2, X
        
        PLA : STA $0DF0, X
        PLA : STA $0F70, X
        PLA : STA $0E80, X
        PLA : STA $0E90, X
        PLA : STA $0DB0, X
        PLA : STA $0DA0, X
        PLA : STA $0E60, X
        PLA : STA $0D80, X
        PLA : STA $0F20, X
        PLA : STA $0E40, X
        PLA : STA $0DE0, X
        PLA : STA $0B89, X
        PLA : STA $0F50, X
        PLA : STA $0EB0, X
        PLA : STA $0D90, X
        PLA : STA $0DC0, X
        PLA : STA $0D20, X
        PLA : STA $0D00, X
        PLA : STA $0D30, X
        PLA : STA $0D10, X
        PLA : STA $0E20, X
        PLA : STA $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; $EEB68-$EEB83 DATA
    pool Sprite_SimulateSoldier:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$EEB84-$EEBEA LONG
    Sprite_SimulateSoldier:
    {
        PHB : PHK : PLB
        
        LDA $00 : STA $0D10, X
        LDA $01 : STA $0D30, X
        
        LDA $02 : STA $0D00, X
        LDA $03 : STA $0D20, X
        
        STZ $0F70, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA $04 : STA $0DE0, X : STA $0EB0, X : TAY
        
        LDA $EB68, Y : ADD $06 : STA $0DC0, X
        
        LDA.b #$10 : STA $0E60, X
        
        STZ $0B89, X
        
        LDA $05 : ORA.b #$30 : STA $0F50, X
        
        LDY.b #$41
        
        CMP.b #$39 : BEQ .normalSoldier
        
        ; red spear soldier
        LDY.b #$43
    
    .normalSoldier
    
        TYA : STA $0E20, X
        
        LDA.b #$07 : STA $0E40, X
        
        TXA : ASL A : TAY
        
        REP #$20
        
        LDA $EB6C, Y : STA $90
        LDA $EB78, Y : STA $92
        
        SEP #$20
        
        JSL Soldier_AnimateMarionetteTempLong
        
        PLB
        
        RTL
    }

; ==============================================================================

    incsrc "overlord_armos_coordinator.asm"
    incsrc "sprite_helmasaur_fireball.asm"
    incsrc "sprite_armos_crusher.asm"
    incsrc "sprite_evil_barrier.asm"

; ==============================================================================

    ; *$EF277-$EF2A4 LONG
    Moldorm_Initialize:
    {
        PHX
        
        TXY
        
        LDA $1DF7CF, X : TAX
        
        LDA.b #$1F : STA $00
    
    .next_subsprite
    
        LDA $0D10, Y : STA $7FFC00, X
        LDA $0D30, Y : STA $7FFC80, X
        
        LDA $0D00, Y : STA $7FFD00, X
        LDA $0D20, Y : STA $7FFD80, X
        
        INX
        
        DEC $00 : BPL .next_subsprite
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; $EF2A5-$EF394 DATA
    pool Sprite_DrawFourAroundOne:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$EF395-$EF3D3 LONG
    Sprite_DrawFourAroundOne:
    {
        PHB : PHK : PLB
        
        INC $0E80, X
        
        LDA $0E80, X : AND.b #$01 : ORA $0011 : ORA $0FC1 : BNE .dont_reset
        
        INC $0DC0, X : LDA $0DC0, X : CMP.b #$06 : BNE .dont_reset
        
        STZ $0DC0, X
    
    .dont_reset
    
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #3 : STA $00
        
        ASL #2 : ADC $00 : ADC.w #$F2A5 : STA $08
        
        SEP #$20
        
        LDA.b #$05 : JSR Sprite4_DrawMultiple
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EF3D4-$EF44C LONG
    Toppo_Flustered:
    {
        PHB : PHK : PLB
        
        LDA.b #$82 : STA $0E40, X : STA $0BA0, X
        
        LDA.b #$49 : STA $0E60, X
        
        LDA $0E30, X : BNE .caught_by_player
        
        JSL Sprite_CheckDamageToPlayerLong : BCC .just_animate
        
        INC $0E30, X
        
        ; "All right! Take it Thief!"
        LDA.b #$74 : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        BRA .just_animate
    
    .caught_by_player
    
        CMP.b #$10 : BCC .prize_delay
                     BNE .just_animate
        
        STZ $0BE0, X
        
        LDA.b #$06 : STA $0DD0, X
        
        LDA.b #$0F : STA $0DF0, X
        
        LDA $0E40, X : ADD.b #$04 : STA $0E40, X
        
        LDA.b #$15 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$4D : JSL Sprite_SpawnDynamically : BMI .prize_delay
        
        JSL Sprite_SetSpawnedCoords
        
        PHX : TYX : LDY.b #$06
        
        ; Transmute this thing to a prize?
        JSL $06FA54  ;  $37A54 IN ROM
        
        PLX
    
    .prize_delay
    
        INC $0E30, X
    
    .just_animate
    
        INC $0E80, X
        
        LDA $0E80, X : AND.b #$04 : LSR #2 : ADC.b #$03 : STA $0DC0, X
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EF44D-$EF588 DATA
    pool Goriya_Draw:
    {
        ; \task Fill in data
        
        ; note: it does draw multiple with a pointer table, unlike many
        ; sprites. The table is $F565, Y
    
    ; $EF565
        dw $F54D, $F555, $F55D
    
    ; $EF56B
        dw $F44D, $F46D, $F48D, $F4AD, $F4CD, $F4ED, $F50D, $F51D
        dw $F52D, $F53D
    
    ; $EF57F
        db $04, $04, $04, $04, $04, $04, $02, $02
        db $02, $02
    }

; ==============================================================================

    ; *$EF589-$EF5D3 LONG
    Goriya_Draw:
    {
        PHB : PHK : PLB
        
        LDA $0E00, X : BEQ .not_firing_fire_pleghm
        
        LDA $0DE0, X : CMP.b #$03 : BEQ .facing_right
        
        ASL A : TAY
        
        REP #$20
        
        LDA $F565, Y : STA $08
        
        SEP #$20
        
        LDA.b #$01 : JSR Sprite4_DrawMultiple
    
    .facing_right
    .not_firing_fire_pleghm
    
        LDA $0DC0, X : PHA : ASL A : TAY
        
        REP #$20
        
        LDA $F56B, Y : STA $08
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        PLY
        
        LDA $F57F, Y : JSR Sprite4_DrawMultiple
        
        DEC $0E40, X
        
        JSL Sprite_DrawShadowLong
        
        INC $0E40, X
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EF5D4-$EF613 DATA
    pool Sprite_ConvertVelocityToAngle:
    {
    
    .x_angles
        db  0,  0,  1,  1,  1,  2,  2,  2
        db  0,  0, 15, 15, 15, 14, 14, 14
        db  8,  8,  7,  7,  7,  6,  6,  6
        db  8,  8,  9,  9,  9, 10, 10, 10
    
    .y_angles
        db  4,  4,  3,  3,  3,  2,  2,  2
        db 12, 12, 13, 13, 13, 14, 14, 14
        db  4,  4,  5,  5,  5,  6,  6,  6
        db 12, 12, 11, 11, 11, 10, 10, 10
    }

; ==============================================================================

    ; *$EF614-$EF65C LONG
    Sprite_ConvertVelocityToAngle:
    {
        !x_magnitude = $08
        !y_magnitude = $09
        !sign_bits   = $0A
        
        ; ------------------------------
        
        ; This routine's purpose is unknown, but its clients are generally
        ; "segmented" enemies and bosses like the Giant Moldorm and Trinexx.
        
        PHB : PHK : PLB
        
        ; Take Y speed and extract its sign to $08
        LDA $00 : ASL A : ROL A : STA $08
        
        ; Extract the X speed's sign bit too, shift it left once, OR in the
        ; Y speed's sign bit and then isolate them to $0A. So $0A looks like
        ; 000st000, where s and y indicate the respective sign bits of x and y.
        LDA $01 : ASL A : ROL A : ASL A : ORA $08
                                        : AND.b #$03 : ASL #3 : STA !sign_bits
        
        LDA $01 : BPL .positive_x_speed
        
        EOR.b #$FF : INC A
    
    .positive_x_speed
    
        STA !x_magnitude
        
        LDA $00 : BPL .positive_y_speed
        
        EOR.b #$FF : INC A
    
    .positive_y_speed
    
        STA !y_magnitude
        
        LDA !x_magnitude : CMP !y_magnitude : BCC .y_speed_magnitude_larger
        
        LDA !y_magnitude : LSR #2 : ADD !sign_bits : TAY
        
        ; I don't think these tables are large enough (do we have a verified
        ; \bug on our hands?) for all possible combinations of velocities.
        LDA .x_angles, Y : BRA .return
    
    .y_speed_magnitude_larger
    
        LDA !x_magnitude : LSR #2 : ADD !sign_bits : TAY
        
        LDA .y_angles, Y
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EF65D-$EF6CE LONG
    Sprite_SpawnDynamically:
    {
        LDY.b #$0F
    
    ; *$EF65F ALTERNATE ENTRY POINT
    .arbitrary
    
        PHA
    
    .next_sprite_slot
    
        LDA $0DD0, Y : BEQ .empty_slot
        
        DEY : BPL .next_sprite_slot
        
        PLA : TYA
        
        RTL
    
    .empty_slot
    
        ; Change to the designated sprite type (set in the calling function.)
        PLA : STA $0E20, Y
        
        ; Bring the sprite to life.
        LDA.b #$09 : STA $0DD0, Y
        
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        LDA $0F70, X : STA $04
        
        LDA $0B08, X : STA $05
        LDA $0B10, X : STA $06
        LDA $0B18, X : STA $07
        LDA $0B20, X : STA $08
        
        ; Save our sprite's index, for now.
        PHX
        
        ; Refresh the sprite index using Y -> X
        TYX
        
        JSL Sprite_LoadProperties
        
        LDA $1B : BNE .indoors
        
        TXA : ASL A : TAX
        
        LDA.b #$FF : STA $0BC1, X
    
    .indoors
    
        LDA.b #$FF : STA $0BC0, X
        
        PLX
        
        LDA $0F20, X : STA $0F20, Y
        LDA $0DE0, X : STA $0DE0, Y
        
        LDA.b #$00 : STA $0CBA, Y : STA $0E30, Y
        
        TYA
        
        RTL
    }

; ==============================================================================

    ; $EF6CF-$EF7CE DATA
    {
        ; Used from bank 0x06. \task Document this. Though, it seems that the
        ; values here aren't really checked for anything other than being 
        ; zero.
    }

; ==============================================================================

    ; $EF7CF-$EF821 DATA
    {
    
        ; \task Fill in data.
    
    ; $EF7CF
        
    
    ; $EF7D3
    
    ; $EF7D6
    
    ; $EF7DC
    
    ; $EF7DF
    
    
    ; $EF7E2
    
    ; $EF802
    }

; ==============================================================================

    ; *$EF822-$EF942 LONG
    Moldorm_Draw:
    {
        JSL Sprite_PrepOamCoordLong : BCC .can_draw
        
        RTL
    
    .can_draw
    
        PHB : PHK : PLB
        
        LDA $0DE0, X : ADD.b #$FF : STA $06
        
        PHX
        
        LDX.b #$01
    
    .next_oam_entry
    
        LDA $06 : AND.b #$0F : ASL A
        
        PHX
        
        TAX
        
        REP #$20
        
        LDA $00 : ADD $F7E2, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $F802, X : INY : STA ($90), Y
        
        ADC.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        LDA.b #$4D : INY : STA ($90), Y
        LDA $05    : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        LDA $06 : ADD.b #$02 : STA $06
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
    
        PLX
        
        REP #$20
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        TXY
        
        LDA $0E80, X : AND.b #$1F : ADD $F7CF, X : TAX
        
        LDA $0D10, Y : STA $7FFC00, X
        LDA $0D30, Y : STA $7FFC80, X
        
        LDA $0D00, Y : STA $7FFD00, X
        LDA $0D20, Y : STA $7FFD80, X
        
        LDA.b #$02 : STA $06
        
        LDY.b #$00
    
    .next_oam_entry_2
    
        PHY
    
        LDY $06
        
        LDX $0FA0
        
        LDA $0E80, X : ADD $F7DF, Y : AND.b #$1F : ADD $F7CF, X : TAX
        
        LDA $7FFC00, X : STA $00
        LDA $7FFC80, X : STA $01
        
        LDA $7FFD00, X : STA $02
        LDA $7FFD80, X : STA $03
        
        TYA
        
        PLY
        
        PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : SUB $E2 : ADD $F7D6, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : SUB $E8 : ADD $F7D6, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y_2
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y_2
    
        PLX
        
        LDA $F7D3, X : INY : STA ($90), Y
        LDA $05      : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $F7DC, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEC $06 : BPL .next_oam_entry_2
        
        LDX $0FA0
        
        PLB
        
        RTL
    }

; ==============================================================================

    incsrc "sprite_talking_tree.asm"

; ==============================================================================

    ; $EFBCC-$EFBD6 DATA
    pool PullForRupees_SpawnRupees:
    {
    
    .x_speeds
        db -18, -12,  12,  18
    
    .y_speeds
        db  16,  24,  24,  16
    
    .rupee_types
        db $D9, $DA, $DB
    }

; ==============================================================================

    ; *$EFBD7-$EFC37 LONG
    PullForRupees_SpawnRupees:
    {
        PHB : PHK : PLB
        
        ; number of kills
        LDA $0CFB : BEQ .no_kills
        
        LDY.b #$00
        
        CMP.b #$04 : BCC .less_than_four_kills
        
        INY
        
        ; number of times you've taken damage (even if you're at full health
        ; right now).
        LDA $0CFC : BNE .players_hit_counter_nonzero
        
        INY
    
    .players_hit_counter_nonzero
    .less_than_four_kills
    
        LDA.b #$03 : STA $0FB5
        
        STY $0FB6
    
    .rupee_spawn_loop
    
        LDY $0FB6
        
        ; Select which kind of rupee to use with the "pull for rupees" thing
        LDA .rupee_types, Y
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$30 : JSL Sound_SetSfx3PanLong
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        LDX $0FB5
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA.b #$FF : STA $0B58, Y
        
        LDA.b #$20 : STA $0F10, Y : STA $0EE0, Y : STA $0F80, Y
        
        DEC $0FB5 : BPL .rupee_spawn_loop
    
    .spawn_failed
    .no_kills
    
        ; Reset hit and kill counts.
        STZ $0CFB
        STZ $0CFC
        
        PLB
        
        RTL
    }

; ==============================================================================

    incsrc "sprite_digging_game_guy.asm"

; ==============================================================================

    ; $EFE6E-$EFF0D DATA
    pool OldMountainMan_Draw:
    {
    
    .static_pose
        dw  0, 0 : db $AC, $00, $00, $02
        dw  0, 8 : db $AE, $00, $00, $02
    
    .dynamic_poses
        dw  0, 0 : db $20, $01, $00, $02
        dw  0, 8 : db $22, $01, $00, $02
        
        dw  0, 1 : db $20, $01, $00, $02
        dw  0, 9 : db $22, $41, $00, $02
        
        dw  0, 0 : db $20, $01, $00, $02
        dw  0, 8 : db $22, $01, $00, $02
        
        dw  0, 1 : db $20, $01, $00, $02
        dw  0, 9 : db $22, $41, $00, $02
        
        dw -2, 0 : db $20, $01, $00, $02
        dw  0, 8 : db $22, $01, $00, $02
        
        dw -2, 1 : db $20, $01, $00, $02
        dw  0, 9 : db $22, $01, $00, $02
        
        dw  2, 0 : db $20, $41, $00, $02
        dw  0, 8 : db $22, $41, $00, $02
        
        dw  2, 1 : db $20, $41, $00, $02
        dw  0, 9 : db $22, $41, $00, $02        
    
    .dma_config
        dw $20, $C0, $20, $C0, $00, $A0, $00, $A0
        db $40, $80, $40, $60, $40, $80, $40, $60

    }

; ==============================================================================

    ; *$EFF0E-$EFF5A LONG
    OldMountainMan_Draw:
    {
        PHB : PHK : PLB
        
        LDA $0E80, X : CMP.b #$02 : BEQ .unchanging_pose
        
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL A : TAY
        
        ; Wait... so the Old Man's graphics are updated dynamically? Why?
        LDA .dma_config, Y     : STA $0AE8
        
        LDA .dma_config + 1, Y : STA $0AEA
        
        TYA : ASL #3
        
        ADC.b #(.dynamic_poses >> 0)              : STA $08
        LDA.b #(.dynamic_poses >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        
        PLB
        
        RTL
    
    .unchanging_pose
    
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA.b #(.static_pose >> 0) : STA $08
        LDA.b #(.static_pose >> 8) : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        
        PLB
        
        RTL
    }

    ; *$EFF5B-$EFFBC LONG
    SpriteBurn_Execute:
    {
        PHB : PHK : PLB
        
        STZ $0EF0, X
        
        LDA $0DF0, X : DEC A : BNE .delay
        
        ; Do this when the timer is at 0x01.
        JSL $06F917 ; $37917 IN ROM
        
        PLB
        
        RTL
    
    .delay
    
        LDY $0DC0, X : PHY
        
        LSR #3
        
        PHX : TAX
        
        LDA $1EC2B4, X : PLX : STA $0DC0, X
        
        LDA $0F50, X : PHA
        
        LDA.b #$03 : STA $0F50, X
        
        JSL Flame_Draw
        
        PLA : STA $0F50, X
        PLA : STA $0DC0, X
        
        REP #$20
        
        ; Flame sprite took up 2 oam entries.
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        ; Once the sprite has been burning long enough, stop animating it,
        ; drawing it, letting it do any particular logic, etc.
        LDA $0DF0, X : CMP.b #$10 : BCC .normal_handling_inhibited
        
        LDA $0E40, X : PHA
        
        DEC #2 : STA $0E40, X
        
        JSL SpriteActive_MainLong
        
        PLA : STA $0E40, X
    
    .normal_handling_inhibited
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EFFBD-$EFFC4 DATA
    pool SpriteFall_Draw:
    {
    
    .chr
        db $83, $83, $83, $80, $80, $80, $B7, $B7
    }

; ==============================================================================

    ; *$EFFC5-$EFFF7 LONG
    SpriteFall_Draw:
    {
        PHB : PHK : PLB
        
        LDA $00 : ADD.b #$04       : STA ($90), Y
        LDA $02 : ADD.b #$04 : INY : STA ($90), Y
        
        LDA $0DF0, X : LSR #2
        
        PHX
        
        TAX
        
        LDA .chr, X                       : INY : STA ($90), Y
        LDA $05 : AND.b #$30 : ORA.b #$04 : INY : STA ($90), Y
        
        PLX
        
        LDY.b #$00
        LDA.b #$00
        
        JSL Sprite_CorrectOamEntriesLong
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EFFF8-$EFFFF NULL
    pool Empty:
    {
        fillbyte $FF
        
        fill $8
    }

; ==============================================================================
