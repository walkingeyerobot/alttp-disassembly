
    ; Bank1E.rtf
    ; Yes the day finally has come, I have found code in the (next to :p) 
    ; last bank of the rom.

; ==============================================================================

    incsrc "sprite_helmasaur_king.asm"
    
; ==============================================================================

    ; *$F0A85-$F0A8D
    Sprite3_DivisionDelay:
    {
        ; \bug I think this is actual overkill. Probably only need NOP #4 or
        ; NOP #3 really. Also, I named the routine wrong.
        ; \task Fix the name?
        ; Used for division or multiplication delay with helmasaur king...
        NOP #8
        
        RTS
    }

; ==============================================================================
    
    incsrc "sprite_mad_batter_bolt.asm"

; ==============================================================================

    ; *$F0B11-$F0B18 LONG
    SpriteActive3_MainLong:
    {
        PHB : PHK : PLB
        
        JSR SpriteActive3_Main
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$F0B19-$F0B2D LOCAL
    SpriteActive3_Main:
    {
        LDA $0E20, X : SUB.b #$79 : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        ; Sets up a clever little jump table
        LDA SpriteActive3_Table, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$F0B2E-$F0B32 LOCAL
    Sprite3_CheckTileCollision:
    {
        JSL Sprite_CheckTileCollisionLong
        
        RTS
    }

; ==============================================================================

    ; $F0B33-$F0BBA Jump Table
    SpriteActive3_Table:
    {
        ; SPRITE ROUTINES 3
        
        ; Note that the indices in the margin are the sprite indices, not the
        ; indices into the table.
        
        dw Sprite_DashBeeHive      ; 0x79 - Good bee / Normal bee
        dw Sprite_Agahnim          ; 0x7A - Agahnim.
        dw Sprite_EnergyBall       ; 0x7B - Agahnim energy blasts
        dw Sprite_GreenStalfos     ; 0x7C - Green Stalfos
        dw Sprite_SpikeTrap        ; 0x7D - Spike Traps
        dw Sprite_GuruguruBar      ; 0x7E - Swinging Fireball Chains
        dw Sprite_GuruguruBar      ; 0x7F - Swinging Fireball Chains
        dw Sprite_Winder           ; 0x80 - Winder (wandering fireball chain0
        dw Sprite_Hover            ; 0x81 - Hover
        dw Sprite_BubbleGroup      ; 0x82 - Swirling Fire Faeries
        dw Sprite_Eyegore          ; 0x83 - Green Eyegore
        dw Sprite_Eyegore          ; 0x84 - Red Eyegore
        dw Sprite_YellowStalfos    ; 0x85 - Yellow Stalfos
        dw Sprite_Kodondo          ; 0x86 - Kodondo
        dw Sprite_Flame            ; 0x87 - Flame (from Kodondo and Fire Rod)
        dw Sprite_Mothula          ; 0x88 - Mothula
        dw Sprite_MothulaBeam      ; 0x89 - Mothula beam
        dw Sprite_SpikeBlock       ; 0x8A - Moving spike blocks
        dw Sprite_Gibdo            ; 0x8B - Gibdo
        dw Sprite_Arrghus          ; 0x8C - Arrghus
        dw Sprite_Arrghi           ; 0x8D - Arrgi
        dw Sprite_Terrorpin        ; 0x8E - Chair Turtles
        dw Sprite_Zol              ; 0x8F - Zol / Blobs
        dw Sprite_WallMaster       ; 0x90 - Wall Masters
        dw Sprite_StalfosKnight    ; 0x91 - Stalfos Knight
        dw Sprite_HelmasaurKing    ; 0x92 - Helmasaur King
        dw Sprite_Bumper           ; 0x93 - Bumper
        dw Sprite_Pirogusu         ; 0x94 - Pirogusu
        dw Sprite_LaserEye         ; 0x95 - Laser Eye
        dw Sprite_LaserEye         ; 0x96 - Laser Eye
        dw Sprite_LaserEye         ; 0x97 - Laser Eye
        dw Sprite_LaserEye         ; 0x98 - Laser Eye
        dw Sprite_Pengator         ; 0x99 - Pengator
        dw Sprite_Kyameron         ; 0x9A - Kyameron
        dw Sprite_WizzrobeAndBeam  ; 0x9B - Wizzrobe
        dw Sprite_Zoro             ; 0x9C - Zoro
        dw Sprite_Babusu           ; 0x9D - Babusu
        dw Sprite_FluteBoyOstrich  ; 0x9E - Ostrich seen with Flute Boy
        dw Sprite_FluteBoyRabbit   ; 0x9F - Flute
        dw Sprite_FluteBoyBird     ; 0xA0 - Birds with flute boy?
        dw Sprite_Freezor          ; 0xA1 - Freezor
        dw Sprite_Kholdstare       ; 0xA2 - Kholdstare
        dw Sprite_KholdstareShell  ; 0xA3 - Kholdstare Shell
        dw Sprite_IceBallGenerator ; 0xA4 - Ice Balls From Above
        dw Sprite_Zazak            ; 0xA5 - Blue Zazak
        dw Sprite_Zazak            ; 0xA6 - Red Zazak
        dw Sprite_Stalfos          ; 0xA7 - Red Stalfos
        dw Sprite_Bomber           ; 0xA8 - Green Bomber (Zirro?)
        dw Sprite_Bomber           ; 0xA9 - Blue Bomber (Zirro?)
        dw Sprite_Pikit            ; 0xAA - Pikit
        dw Sprite_CrystalMaiden    ; 0xAB - Crystal maiden
        dw Sprite_DashApple        ; 0xAC - Apple
        dw Sprite_OldMountainMan   ; 0xAD - Old Man on the Mountain
        dw Sprite_Pipe             ; 0xAE - Pipe sprite (down)
        dw Sprite_Pipe             ; 0xAF - Pipe sprite (up)
        dw Sprite_Pipe             ; 0xB0 - Pipe sprite (right)
        dw Sprite_Pipe             ; 0xB1 - Pipe sprite (left)
        dw Sprite_GoodBee          ; 0xB2 - Good bee again?
        dw Sprite_HylianPlaque     ; 0xB3 - Hylian Plaque
        dw Sprite_ThiefChest       ; 0xB4 - Thief's chest
        dw Sprite_BombShopEntity   ; 0xB5 - Bomb Salesman / others maybe?
        dw Sprite_Kiki             ; 0xB6 - Kiki the monkey
        dw Sprite_BlindMaiden      ; 0xB7 - Maiden following you in Gargoyle's Domain
        dw Sprite_DialogueTester   ; 0xB8 - debug artifact, dialogue tester
        dw Sprite_BullyAndBallGuy  ; 0xB9 - Feuding friends on DW Death Mountain
        dw Sprite_Whirlpool        ; 0xBA - Whirlpool
        dw Sprite_ShopKeeper       ; 0xBB - Shopkeeper / Chest game guy
        dw Sprite_DrinkingGuy      ; 0xBC - Drunk in the Inn
    }

; ==============================================================================

    ; $F0BBB-$F0BBE DATA
    pool Unused:
    {
        db $00, $00, $00, $00
    }

; ==============================================================================

    incsrc "sprite_pikit.asm"
    
    ; \covered($F0DD2-$F10B4)
    
    incsrc "sprite_bomber.asm"
    incsrc "sprite_stalfos_and_zazak.asm"
    incsrc "sprite_kholdstare.asm"
    incsrc "sprite_freezor.asm"
    incsrc "sprite_flute_boy_ostrich.asm"
    incsrc "sprite_flute_boy_rabbit.asm"
    incsrc "sprite_flute_boy_bird.asm"
    incsrc "sprite_zoro_and_babusu.asm"
    incsrc "sprite_wizzrobe.asm"
    incsrc "sprite_kyameron.asm"
    incsrc "sprite_pengator.asm"
    incsrc "sprite_laser_eye.asm"
    incsrc "sprite_pirogusu.asm"
    incsrc "sprite_bumper.asm"
    incsrc "sprite_stalfos_knight.asm"
    incsrc "sprite_wall_master.asm"
    incsrc "sprite_zol.asm"
    incsrc "sprite_terrorpin.asm"
    incsrc "sprite_arrgi.asm"
    incsrc "sprite_gibdo.asm"
    incsrc "sprite_mothula_beam.asm"
    incsrc "sprite_flying_tile.asm"
    incsrc "sprite_spike_block.asm"
    incsrc "sprite_mothula.asm"
    incsrc "sprite_kodondo.asm"

; ==============================================================================

    ; *$F4267-$F426F LOCAL
    Sprite3_CheckDamage:
    {
        JSL Sprite_CheckDamageFromPlayerLong
    
    ; *$F426B ALTERNATE ENTRY POINT
    shared Sprite3_CheckDamageToPlayer:
    
        JSL Sprite_CheckDamageToPlayerLong
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_flame.asm"
    incsrc "sprite_yellow_stalfos.asm"
    incsrc "sprite_eyegore_and_goriya.asm"
    incsrc "sprite_bubble_group.asm"
    incsrc "sprite_hover.asm"
    incsrc "sprite_crystal_maiden.asm"
    incsrc "sprite_spike_trap.asm"
    incsrc "sprite_guruguru_bar.asm"
    incsrc "sprite_winder.asm"
    incsrc "sprite_green_stalfos.asm"
    incsrc "sprite_agahnim.asm"
    incsrc "sprite_energy_ball.asm"
    incsrc "sprite_bees.asm"
    
    ; \covered($F603C-$F62E8)
    
    incsrc "sprite_hylian_plaque.asm"
    incsrc "sprite_thief_chest.asm"
    incsrc "sprite_bomb_shop_entity.asm"
    incsrc "sprite_kiki.asm"
    incsrc "sprite_blind_maiden.asm"
    incsrc "sprite_old_mountain_man.asm"
    incsrc "sprite_dialogue_tester.asm"
    incsrc "sprite_bully_and_ball_guy.asm"
    incsrc "sprite_whirlpool.asm"
    incsrc "sprite_shopkeeper.asm"

; ==============================================================================

    ; *$F74F3-$F7507 LONG
    Sprite_PlayerCantPassThrough:
    {
        LDA $0F60, X : PHA
        
        STZ $0F60, X
        
        ; Also, if bit 7 of $0E40, X is not set, it will hurt Link
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_contact
        
        JSR Sprite_HaltSpecialPlayerMovement
    
    .no_contact
    
        PLA : STA $0F60, X
        
        RTL
    }

; ==============================================================================

    ; *$F7508-$F7514 LOCAL
    Sprite_HaltSpecialPlayerMovement:
    {
        PHX
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E ; Set Link's speed to zero...
        
        JSL Player_HaltDashAttackLong
        
        PLX
        
        RTS
    }

; ==============================================================================

    incsrc "sprite_apple.asm"
    incsrc "sprite_drinking_guy.asm"
    incsrc "sprite_transit_entities.asm"
    
    ; \covered($F7D12-$F7FFF)

    incsrc "sprite_faerie_handle_movement.asm"

; ==============================================================================

    ; *$F7E69-$F7E6D LOCAL
    Sprite3_DirectionToFacePlayer:
    {
        JSL Sprite_DirectionToFacePlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$F7E6E-$F7E72 LOCAL
    Sprite3_IsToRightOfPlayer:
    {
        JSL Sprite_IsToRightOfPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$F7E73-$F7E77 LOCAL
    Sprite3_IsBelowPlayer:
    {
        JSL Sprite_IsBelowPlayerLong
        
        RTS
    }

; ==============================================================================

    ; *$F7E78-$F7E94 LOCAL
    Sprite3_CheckIfActive:
    {
        LDA $0DD0, X : CMP.b #$09 : BNE .inactive
    
    ; $F7E7F ALTERNATE ENTRY POINT
    .permissive
    
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

    ; $F7E95-$F7E9A DATA
    pool Sprite3_CheckIfRecoiling:
    {
    
    .frame_counter_masks
        db $03, $01, $00, $00, $0C, $03
    }

; ==============================================================================

    ; *$F7E9B-$F7F1D LOCAL
    Sprite3_CheckIfRecoiling:
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
        
        LDA $1A : AND .frame_counter_masks, Y : BNE .halted
        
        LDA $0F30, X : STA $0D40, X
        LDA $0F40, X : STA $0D50, X
        
        LDA $0CD2, X : BMI .no_wall_collision
        
        JSR Sprite3_CheckTileCollision
        
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
    
        JSR Sprite3_Move
    
    .halted
    
        PLA : STA $0D50, X
        PLA : STA $0D40, X
        
        ; explicit check for Agahnim.
        LDA $0E20, X : CMP.b #$7A : BEQ .return
        
        PLA : PLA
    
    .return
    
        RTS
    
    .recoil_finished
    
        STZ $0EA0, X
        
        RTS
    }

; ==============================================================================

    ; *$F7F1E-$F7F27 LOCAL
    Sprite3_MoveXyz:
    {
        JSR Sprite3_MoveAltitude
    
    ; *$F7F21 ALTERNATE ENTRY POINT
    shared Sprite3_Move:
    
        JSR Sprite3_MoveHoriz
        JSR Sprite3_MoveVert
        
        RTS
    }

; ==============================================================================

    ; $F7F28-$F7F33 LOCAL
    Sprite3_MoveHoriz:
    {
        TXA : ADD.b #$10 : TAX
        
        JSR Sprite3_MoveVert
        
        LDX $0FA0
        
        RTS
    }

; ==============================================================================

    ; *$F7F34-$F7F61 LOCAL
    Sprite3_MoveVert:
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

    ; *$F7F62-$F7F83 LOCAL
    Sprite3_MoveAltitude:
    {
        LDA $0F80, X : ASL #4 : ADD $0F90, X : STA $0F90, X
        
        LDA $0F80, X : PHP : LSR #4 : PLP : BPL .positive
        
        ORA.b #$F0
    
    .positive
    
        ADC $0F70, X : STA $0F70, X
        
        RTS
    }

; ==============================================================================

    ; *$F7F84-$F7F8C LOCAL
    Sprite3_PrepOamCoord:
    {
        JSL Sprite_PrepOamCoordLong : BCC .renderable
        
        PLA : PLA
    
    .renderable
    
        RTS
    }

; ==============================================================================

    ; *$F7F8D-$F7FDD LONG
    Sprite_DrawRippleIfInWater:
    {
        LDA $7FF9C2, X
        
        CMP.b #$08 : BEQ .waterTile
        CMP.b #$09 : BNE .notWaterTile
    
    .waterTile
    
        LDA $0E60, X : AND.b #$20 : BEQ .dontAdjustX
        
        LDA $0FD8 : SUB.b #$04 : STA $0FD8
        LDA $0FD9 : SBC.b #$00 : STA $0FD9
        
        ; Is it a small magic refill?
        LDA $0E20, X : CMP.b #$DF : BNE .dontAdjustY
        
        LDA $0FDA : SUB.b #$07 : STA $0FDA
        LDA $0FDB : SBC.b #$00 : STA $0FDB
    
    .dontAdjustX
    .dontAdjustY
    
        JSL Sprite_DrawWaterRipple
        JSL Sprite_Get_16_bit_CoordsLong
        
        LDA $0E40, X : AND.b #$1F : INC A : ASL #2
        
        JSL OAM_AllocateFromRegionA
    
    .notWaterTile
    
        RTL
    }

; ==============================================================================

    ; $F7FDE-$F7FFF NULL
    pool Empty:
    {
        fillbyte $FF
        
        fill $22
    }

; ==============================================================================

