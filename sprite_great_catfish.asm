
; ==============================================================================

    ; $EDF45-$EDF48 DATA
    pool Sprite_StandaloneItem:
    {
    
    .bounce_z_speeds
        db $20, $10, $08, $00
    }

; ==============================================================================

    ; *$EDF49-$EDFD0 JUMP LOCATION
    Sprite_GreatCatfish:
    {
        ; ILL OMEN MONSTER / QUAKE MEDALLION
        
        LDA $0D90, X : BPL .not_water_splash
        
        JSR Sprite_WaterSplash
        
        RTS
    
    .not_water_splash
    
        BEQ GreatCatfish_Main
    
    ; \note Here for informational purposes.
    shared Sprite_StandaloneItem:
    
        LDA $0F70, X : BNE .aloft
        
        JSL Sprite_AutoIncDrawWaterRippleLong
        
        LDA $11 : BNE .dont_grant_item
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .dont_grant_item
        
        STZ $0DD0, X
        STZ $02E9
        
        LDY $0D90, X
        
        PHX
        
        JSL Link_ReceiveItem
        
        PLX
    
    .dont_grant_item
    .aloft
    
        LDA !timer_3, X : BEQ .dont_use_different_oam_region
        
        ; \task Identify when this happens.
        LDA.b #$08 : JSL OAM_AllocateFromRegionC
    
    .dont_use_different_oam_region
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite4_CheckIfActive
        JSR Sprite4_MoveXyz
        
        ; Simulate gravity for the sprite.
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .not_bouncing
        
        STZ $0F70, X
        
        ; Halve x and y speeds upon bounce.
        LDA $0D50, X : ASL A : ROR $0D50, X
        
        LDA $0D40, X : ASL A : ROR $0D40, X
        
        LDY $0D80, X : CPY.b #$04 : BNE .not_final_bounce
        
        STZ $0D50, X
        STZ $0D40, X
        STZ $0F80, X
        
        BRA .return
    
    .not_final_bounce
    
        INC $0D80, X
        
        LDA .bounce_z_speeds, Y : STA $0F80, X
        
        CPY.b #$02 : BCS .dont_splash_from_bounce
        
        JSR Sprite_SpawnWaterSplash : BMI .spawn_failed
        
        LDA.b #$10 : STA !timer_0, Y
    
    .spawn_failed
    .dont_splash_from_bounce
    .return
    .not_bouncing
    
        RTS
    }
    
; ==============================================================================

    ; $EDFD1-$EDFE5 BRANCH LOCATION
    GreatCatfish_Main:
    
        JSR GreatCatfish_Draw
        JSR Sprite4_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw GreatCatfish_AwaitSpriteThrownInCircle
        dw GreatCatfish_RumbleBeforeEmergence
        dw GreatCatfish_Emerge
        dw GreatCatfish_ConversateThenSubmerge
    }

; ==============================================================================

    ; *$EDFE6-$EE038 JUMP LOCATION
    GreatCatfish_AwaitSpriteThrownInCircle:
    {
        LDY.b #$0F
    
    .drowning_sprite_in_circle_search
    
        CPY $0FA0 : BEQ .next_sprite
        
        LDA $0DD0, Y : CMP.b #$03 : BNE .next_sprite
        
        LDA $0D10, Y : STA $00
        LDA $0D30, Y : STA $01
        
        LDA $0D00, Y : STA $02
        LDA $0D20, Y : STA $03
        
        REP #$20
        
        ; Check proximity of drowning sprite to the catfish.
        LDA $0FD8 : SUB $00 : ADD.w #$0020 : CMP.w #$0040 : BCS .next_sprite
        
        LDA $0FDA : SUB $02 : ADD.w #$0020 : CMP.w #$0040 : BCS .next_sprite
        
        SEP #$20
    
    ; *$EE02A ALTERNATE ENTRY POINT
    shared GreatCatfish_AdvanceState:
    
        INC $0D80, X
        
        LDA.b #$FF : STA !timer_0, X
        
        RTS
    
    .next_sprite
    
        SEP #$20
        
        DEY : BPL .drowning_sprite_in_circle_search
        
        RTS
    }

; ==============================================================================

    ; *$EE039-$EE07B JUMP LOCATION
    GreatCatfish_RumbleBeforeEmergence:
    {
        LDA !timer_0, X : BNE .delay_emergence
        
        JSR GreatCatfish_AdvanceState
        
        ; Stop shaking the screen.
        STZ $011A
        STZ $011B
        
        ; Halt the rumbling sound.
        LDA.b #$05 : STA $012D
        
        LDA.b #$30 : STA $0F80, X
        
        LDA.b #$00 : STA $0D50, X
        
        JSR GreatCatfish_SpawnImmediatelyDrownedSprite
        
        RTS
    
    .delay_emergence
    
        CMP.b #$C0 : BCS .delay_rumbling
        
        CMP.b #$BF : BNE .anostart_rumble_ambient
        
        LDY.b #$07 : STY $012D
    
    .anostart_rumble_ambient
    
        AND.b #$01 : TAY
        
        ; Shake the screen.
        LDA $8000, Y : STA $011A
        
        LDA $8002, Y : STA $011B
        
        LDA.b #$01 : STA $02E4
    
    .delay_rumbling
    
        RTS
    }

; ==============================================================================

    ; $EE07C-$EE08B DATA
    pool GreatCatfish_Emerge:
    {
    
    .animation_states
        db 1, 2, 2, 2, 2, 3, 3, 3
        db 4, 4, 4, 5, 0, 0, 0, 0
    }

; ==============================================================================

    ; *$EE08C-$EE0BE JUMP LOCATION
    GreatCatfish_Emerge:
    {
        INC $0E80, X
        
        JSR Sprite4_MoveXyz
        
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        ; Spawn a small splash (drowning sprite, technically) when the catfish's
        ; z velocity becomes this negative.
        CMP.b #$D0 : BNE .anospawn_splash
        
        JSR GreatCatfish_SpawnImmediatelyDrownedSprite
    
    .anospawn_splash
    
        LDA $0F70, X : BPL .aloft
        
        STZ $0F70, X
        
        ; \optimizze Makes you wonder, why didn't they JSR to
        ; GreatCatfish_AdvanceState in this case too? (For space, not speed.)
        INC $0D80, X
        
        LDA.b #$FF : STA !timer_0, X
    
    .aloft
    
        LDA $0E80, X : LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $EE0BF-$EE0D2 DATA
    pool GreatCatfish_ConversateThenSubmerge:
    {
    
    .animation_states
        db 0, 6, 7, 7, 7, 7, 7, 7
        db 7, 7, 7, 7, 7, 7, 7, 7
        db 7, 7, 6, 6
    }

; ==============================================================================

    ; *$EE0D3-$EE143 JUMP LOCATION
    GreatCatfish_ConversateThenSubmerge:
    {
        LDA !timer_0, X : BNE .delay_self_termination
        
        STZ $0DD0, X
        
        RTS
    
    .delay_self_termination
    
        CMP.b #$A0 : BNE .dont_spawn_followup_slash
        
        PHA
        
        JSR Sprite_SpawnWaterSplash
        
        PLA
    
    .dont_spawn_followup_slash
    
        BCS GreatCatfish_SpawnSurfacingSplash
        
        CMP.b #$0A : BNE .dont_spawn_exiting_small_splash
        
        PHA
        
        JSR GreatCatfish_SpawnImmediatelyDrownedSprite
        
        PLA
    
    .dont_spawn_exiting_small_splash
    
        CMP.b #$04 : BNE .dont_spawn_exiting_splash
        
        PHA
        
        JSR Sprite_SpawnWaterSplash
        
        PLA
    
    .dont_spawn_exiting_splash
    
        CMP.b #$60 : BNE .not_conversating
        
        STZ $02E4
        
        LDY.b #$2A
        
        ; \item (Quake medallion)
        LDA $7EF349 : BEQ .grant_quake_medallion_mesesage
        
        ; Show message indicating "don't waste my time, go away, I already
        ; gave you a medallion".
        LDY.b #$2B
    
    .grant_quake_medallion_mesesage
    
                     STY $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        RTS
    
    .not_conversating
    
        CMP.b #$50 : BNE .dont_run_spawning_logic
        
        PHA
        
        ; \item (Quake medallion)
        LDA $7EF349 : BEQ .spawn_quake_medallion
        
        JSL GetRandomInt : AND.b #$01 : BEQ .spawn_fireball
        
        JSR Sprite_SpawnBomb : BRA .spawning_logic_complete
    
    .spawn_fireball
    
        JSL Sprite_SpawnFireball : BRA .spawning_logic_complete

    .spawn_quake_medallion
    
        JSR GreatCatfish_SpawnQuakeMedallion
    
    .spawning_logic_complete
    
        PLA
    
    .dont_run_spawning_logic
    
        ; animate.
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$EE144-$EE163 LOCAL
    Sprite_SpawnBomb:
    {
        LDA.b #$4A : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        JSL Sprite_TransmuteToEnemyBomb
        
        LDA.b #$50 : STA !timer_1, Y
        
        LDA.b #$18 : STA $0D50, Y
        
        LDA.b #$30 : STA $0F80, Y

    .spawn_failed

        RTS
    }

; ==============================================================================

    ; *$EE164-$EE16B BRANCH LOCATION
    GreatCatfish_SpawnSurfacingSplash:
    {
        CMP.b #$FC : BNE .delay_splash_spawning
        
        JSR Sprite_SpawnWaterSplash
    
    .delay_splash_spawning
    
        RTS
    }

; ==============================================================================

    ; *$EE16C-$EE1A9 LOCAL
    GreatCatfish_SpawnQuakeMedallion:
    {
        LDA.b #$C0 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        PHX : TYX
        
        LDA.b #$18 : STA $0D50, X
        
        LDA.b #$30 : STA $0F80, X
        
        LDA.b #$11 : STA $0D90, X
        
        ; play a sound effect
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$83 : STA $0E40, X
        
        LDA.b #$58 : STA $0E60, X
        
        AND.b #$0F : STA $0F50, X
        
        PLX
        
        PHX : PHY
        
        LDA.b #$1C : JSL GetAnimatedSpriteTile.variable
        
        PLY : PLX
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$EE1AA-$EE1EC LONG
    Sprite_SpawnFlippersItem:
    {
        LDA.b #$C0
        
        JSL Sprite_SpawnDynamically : BMI .spawnFailed
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        TYX
        
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$10 : STA $0D40, X
        
        LDA.b #$1E : STA $0D90, X
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$83 : STA $0E40, X
        
        LDA.b #$54 : STA $0E60, X
        
        AND.b #$0F : STA $0F50, X
        
        LDA.b #$30 : STA !timer_3, X
        
        PLX : PHX
        
        PHY
        
        LDA.b #$11
        
        JSL GetAnimatedSpriteTile.variable
        
        PLY : PLX
    
    .spawnFailed
    
        RTL
    }

; ==============================================================================

    ; *$EE1ED-$EE213 LOCAL
    GreatCatfish_SpawnImmediatelyDrownedSprite:
    {
        ; Spawn a bush...
        LDA.b #$EC : JSL Sprite_SpawnDynamically : BMI .spawnFailed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$03 : STA $0DD0, Y
        
        LDA.b #$0F : STA !timer_0, Y
        
        LDA.b #$00 : STA $0D80, Y
        LDA.b #$03 : STA $0E40, Y
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
    
    .spawnFailed
    
        RTS
    }

; ==============================================================================

    ; *$EE214-$EE21B LONG
    Sprite_SpawnWaterSplashLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_SpawnWaterSplash
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EE21C-$EE23F LOCAL
    Sprite_SpawnWaterSplash:
    {
        LDA.b #$C0
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$80 : STA $0D90, Y
        
        LDA.b #$02 : STA $0E40, Y
                     STA $0BA0, Y
        
        LDA.b #$04 : STA $0F50, Y
        
        LDA.b #$1F : STA !timer_0, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $EE240-$EE31F DATA
    pool GreatCatfish_Draw:
    {
    
    .oam_groups
        dw -4,  4 : db $8C, $00, $00, $02
        dw  4,  4 : db $8D, $00, $00, $02
        dw -4,  4 : db $8C, $00, $00, $02
        dw  4,  4 : db $8D, $00, $00, $02
        
        dw -4, -4 : db $8C, $00, $00, $02
        dw  4, -4 : db $8D, $00, $00, $02
        dw -4,  4 : db $9C, $00, $00, $02
        dw  4,  4 : db $9D, $00, $00, $02
        
        dw -4, -4 : db $8D, $40, $00, $02
        dw  4, -4 : db $8C, $40, $00, $02
        dw -4,  4 : db $9D, $40, $00, $02
        dw  4,  4 : db $9C, $40, $00, $02
        
        dw -4, -4 : db $9D, $C0, $00, $02
        dw  4, -4 : db $9C, $C0, $00, $02
        dw -4,  4 : db $8D, $C0, $00, $02
        dw  4,  4 : db $8C, $C0, $00, $02
        
        dw -4,  4 : db $9D, $C0, $00, $02
        dw  4,  4 : db $9C, $C0, $00, $02
        dw -4,  4 : db $9D, $C0, $00, $02
        dw  4,  4 : db $9C, $C0, $00, $02
        
        dw  0,  8 : db $BD, $00, $00, $00
        dw  8,  8 : db $BD, $40, $00, $00
        dw  8,  8 : db $BD, $40, $00, $00
        dw  8,  8 : db $BD, $40, $00, $00
        
        dw -8,  0 : db $86, $00, $00, $02
        dw  8,  0 : db $86, $40, $00, $02
        dw  8,  0 : db $86, $40, $00, $02
        dw  8,  0 : db $86, $40, $00, $02
    }

; ==============================================================================

    ; *$EE320-$EE33C LOCAL
    GreatCatfish_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : BEQ .dont_draw
        
        DEC A : REP #$20 : ASL #5 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JMP Sprite4_DrawMultiple
    
    .dont_draw
    
        RTS
    }

; ==============================================================================

    ; $EE33D-$EE37C DATA
    pool Sprite_WaterSplash:
    {
    
    .oam_groups
        dw -8, -4 : db $80, $00, $00, $00
        dw 18, -7 : db $80, $00, $00, $00
        
        dw -5, -2 : db $BF, $00, $00, $00
        dw 15, -4 : db $AF, $40, $00, $00
        
        dw  0, -4 : db $E7, $00, $00, $02
        dw  0, -4 : db $E7, $00, $00, $02
        
        dw  0, -4 : db $C0, $00, $00, $02
        dw  0, -4 : db $C0, $00, $00, $02
    }

; ==============================================================================

    ; *$EE37D-$EE39C LOCAL
    Sprite_WaterSplash:
    {
        LDA.b #$00 : XBA
        
        LDA !timer_0, X : BNE .self_termination_delay
        
        STZ $0DD0, X
    
    .self_termination_delay
    
        LSR #3 : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JMP Sprite4_DrawMultiple
    }

; ==============================================================================
