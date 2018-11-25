
; ==============================================================================

    ; *$F5C5B-$F5C67 JUMP LOCATION
    Sprite_DashBeeHive:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw DashBeeHive_WaitForDash
        dw Bee_Normal
        dw Bee_PutInbottle
    }

; ==============================================================================

    ; *$F5C68-$F5C7A JUMP LOCATION
    DashBeeHive_WaitForDash:
    {
        LDA $0E90, X : BNE .not_dashed_into_yet
        
        STZ $0DD0, X
        
        LDY.b #$0B
    
    .next_spawn_attempt
    
        PHY
        
        JSR DashBeeHive_SpawnBee
        
        PLY : DEY : BPL .next_spawn_attempt
    
    .not_dashed_into_yet
    
        RTS
    }

; ==============================================================================

    ; $F5C7B-$F5C8E DATA
    pool Bee:
    {
    
    .speeds
        db $0F, $05, $FB, $F1, $14, $0A, $F6, $EC
    
    .half_speeds
        db $08, $02, $FE, $F8, $0A, $05, $FB, $F6
    
    .timers
        db $40, $40, $FF, $FF    
    }

; ==============================================================================

    ; *$F5C8F-$F5CCE LOCAL
    DashBeeHive_SpawnBee:
    {
        LDA.b #$79 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
    
    ; $F5C9B ALTERNATE ENTRY POINT
    shared DashBeeHive_InitBee:
    
        PHX
        
        LDA.b #$01 : STA $0D80, Y
        
        TYA : AND.b #$03 : TAX
        
        LDA .timers, X : STA $0DF0, Y
                         STA $0D90, Y
        
        LDA.b #$60 : STA $0F10, Y
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA Bee.speeds, X : STA $0D50, Y
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA Bee.speeds, X : STA $0D40, Y
        
        PLX
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $F5CCF-$F5D40 LONG
    PlayerItem_ReleaseBee:
    {
        PHB : PHK : PLB
        
        LDA.b #$B2 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $EE : STA $0F20, Y
        
        LDA $22 : ADD.b #$08 : STA $0D10, X
        LDA $23 : ADD.b #$00 : STA $0D30, X
        
        LDA $20 : ADD.b #$10 : STA $0D00, X
        LDA $21 : ADD.b #$00 : STA $0D20, X
        
        PHX
        
        LDX $0202
        
        LDA $7EF33F, X : TAX
        
        LDA $7EF35B, X : CMP.b #$08 : BNE .not_good_bee
        
        LDA.b #$01 : STA $0EB0, Y
    
    .not_good_bee
    
        JSR DashBeeHive_InitBee
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA Bee.half_speeds, X : STA $0D50, Y
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA Bee.half_speeds, X : STA $0D40, Y
        
        LDA.b #$40 : STA $0DF0, Y
                     STA $0D90, Y
        
        PLX
        
        PLB
        
        LDA.b #$00
        
        RTL
    
    .spawn_failed
    
        PLB
        
        LDA.b #$FF
        
        RTL
    }

; ==============================================================================

    ; $F5D41-$F5D44 DATA
    pool Bee_Normal:
    {
    
    .box_sizes
        db 0, 5, 10, 15
    }

; ==============================================================================

    ; *$F5D45-$F5DF0 JUMP LOCATION
    Bee_Normal:
    {
        JSR Bee_SetAltitude
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Bee_DetermineInteractionStatus
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0EB0, X : BEQ .not_good_bee
        
        JSL Sprite_SpawnSparkleGarnish
    
    .not_good_bee
    
        JSR Bee_Buzz
        JSR Sprite3_Move
        
        TXA : EOR $1A : LSR A : AND.b #$01 : STA $0DC0, X
        
        LDA $0F10, X : BNE .anointeract_with_player
        
        JSR Sprite3_CheckDamageToPlayer
        
        JSL Sprite_CheckDamageFromPlayerLong : BEQ .anointeract_with_player
        
        ; "You caught a bee! What will you do?"
        ; "> Keep it in a bottle"
        ; "  Set it free"
        LDA.b #$C8
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .anointeract_with_player
    
        LDA $1A : BNE .dont_adjust_timer_supplement
        
        LDA $0D90, X : CMP.b #$10 : BEQ .dont_adjust_timer_supplement
        
        SUB.b #$08 : STA $0D90, X
    
    .dont_adjust_timer_supplement
    
        LDA $0DF0, X : BNE .delay_direction_change
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $22 : ADD .box_sizes, Y : STA $04
        LDA $23 : ADC.b #$00        : STA $05
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $20 : ADD .box_sizes, Y : STA $06
        LDA $21 : ADC.b #$00        : STA $07
        
        LDA.b #$14 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X : BPL .set_h_flip_on
        
        LDA $0F50, X : AND.b #$BF
        
        BRA .store_h_flip_status
    
    .set_h_flip_on
    
        LDA $0F50, X : ORA.b #$40
    
    .store_h_flip_status
    
        STA $0F50, X
        
        TXA : ADD $0D90, X : STA $0DF0, X
    
    .delay_direction_change
    
        RTS
    }

; ==============================================================================

    ; *$F5DF1-$F5E2D JUMP LOCATION
    Bee_PutInbottle:
    {
        JSR Bee_DetermineInteractionStatus
        JSR Sprite3_CheckIfActive
        
        LDA $1CE8 : BNE .was_set_free
        
        JSL Sprite_GetEmptyBottleIndex : BMI .no_empty_bottle
        
        LDA $0EB0, X : STA $00
        
        PHX
        
        TYX
        
        LDA.b #$07 : ADD $00 : STA $7EF35C, X
        
        JSL HUD.RefreshIconLong
        
        PLX
        
        STZ $0DD0, X
        
        RTS
    
    .no_empty_bottle
    
        LDA.b #$CA
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
    
    .was_set_free:
    
        LDA.b #$40 : STA $0F10, X
        
        LDA.b #$01 : STA $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$F5E2E-$F5E43 LONG
    Sprite_GetEmptyBottleIndex:
    {
        PHX
        
        LDX.b #$00
    
    .next_bottle
    
        LDA $7EF35C, X : CMP.b #$02 : BEQ .empty_bottle
        
        INX : CPX.b #$04 : BCC .next_bottle
        
        LDX.b #$FF
    
    .empty_bottle
    
        TXY
        
        PLX
        
        TYA
        
        RTL
    }

; ==============================================================================

    ; *$F5E44-$F5E62 LOCAL
    Bee_DetermineInteractionStatus:
    {
        LDA $11 : CMP.b #$02 : BNE .not_in_text_mode
        
        REP #$20
        
        LDA $1CF0 : CMP.w #$00C8 : BEQ .player_didnt_capture_bee
                    CMP.w #$00CA : BNE .player_captured_bee
    
    .player_didnt_capture_bee
    
        SEP #$30
        
        ; Set an 'ignore interaction' variable for the bee so it can't damage
        ; the player or be caught again for several frames.
        LDA.b #$28 : STA $0F10, X
    
    .player_captured_bee
    .not_in_text_mode
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; \note This version of the good bee is not general purpose, it's just the
    ; one that appears in the ice cave that can be collected via bug net.
    ; *$F5E63-$F5E6F JUMP LOCATION
    Sprite_GoodBee:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw GoodBee_WaitingForDash
        dw GoodBee_Activated
        dw Bee_PutInbottle
    }

; ==============================================================================

    ; *$F5E70-$F5E8F JUMP LOCATION
    GoodBee_WaitingForDash:
    {
        LDA $0E90, X : BNE .not_dashed_into_yet
        
        STZ $0DD0, X
        
        ; Apparently the good bee is designed to be 'unique'.
        LDA $7EF35C : ORA $7EF35D : ORA $7EF35E : ORA $7EF35F
        
        ; \hardcoded Checking using this bit pattern is pretty hardcoded. If
        ; more bottled item types were available, this could present a problem.
        AND.b #$08 : BNE .have_one_in_bottle
        
        JSR GoodBee_SpawnTangibleVersion
    
    .have_one_in_bottle
    .not_dashed_into_yet
    
        RTS
    }

; ==============================================================================

    ; *$F5E90-$F5ECF LOCAL
    GoodBee_SpawnTangibleVersion:
    {
        LDA.b #$79 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$01 : STA $0D80, Y
        
        LDA.b #$40 : STA $0DF0, Y
                     STA $0D90, Y
        
        LDA.b #$60 : STA $0F10, Y
        LDA.b #$01 : STA $0EB0, Y
        
        PHX
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA Bee.speeds, X : STA $0D50, Y
        
        JSL GetRandomInt : AND.b #$07 : TAX
        
        LDA Bee.speeds, X : STA $0D40, Y
        
        PLX
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $F5ED0-$F5ED1 DATA
    pool GoodBee_Activated:
    {
    
    .unknown_1
        db $0A, $14
    }

; ==============================================================================

    ; \note This version of the good bee is not general purpose, it's just the
    ; one that appears in the ice cave that can be collective via bug net.
    ; *$F5ED2-$F5F89 JUMP LOCATION
    GoodBee_Activated:
    {
        LDA.b #$01 : STA $0BA0, X
        
        JSR Bee_SetAltitude
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Bee_DetermineInteractionStatus
        JSR Sprite3_CheckIfActive
        JSR Bee_Buzz
        JSR Sprite3_Move
        
        TXA : EOR $1A : LSR A : AND.b #$01 : STA $0DC0, X
        
        ; \wtf It's almost like the devs hadn't decided that only a good bee
        ; could appear in this fashion (as a single bee) from dashing.
        LDA $0EB0, X : BEQ .not_good_bee
        
        JSL Sprite_SpawnSparkleGarnish
    
    .not_good_bee
    
        ; \unused Unless we can find an instance of this variable changing
        ; for the bee / good bee, I'd currently label this logic as unused.
        ; And therefore \optimize (remove it).
        LDA $0DA0, X : LDY $0EB0, X : CMP .unknown_1, Y : BCC .unknown_0
        
        LDA.b #$40 : STA $0CAA, X
        
        RTS
    
    .unknown_0
    
        LDA $0F10, X : BNE .return
        
        JSL Sprite_CheckDamageFromPlayerLong : BEQ .not_caught_by_player
        
        ; "You caught a bee!..."
        LDA.b #$C8
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .not_caught_by_player
    
        TXA : EOR $1A : AND.b #$03 : BNE .return
        
        JSR GoodBee_ScanForTargetableSprites : BCS .pursuing_sprite
        
        TXA : EOR $1A : AND.b #$03 : BNE .return
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $22 : ADD .box_sizes, Y : STA $04
        LDA $23 : ADC.b #$00        : STA $05
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $20 : ADD .box_sizes, Y : STA $06
        LDA $21 : ADC.b #$00        : STA $07
    
    .pursuing_sprite
    
        TXA : EOR $1A : AND.b #$07 : BNE .return
        
        LDA.b #$20
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X : BPL .pursuing_rightward
        
        LDA $0F50, X : AND.b #$BF
        
        BRA .set_h_flip_status
    
    .pursuing_rightward
    
        LDA $0F50, X : ORA.b #$40
    
    .set_h_flip_status
    
        STA $0F50, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$F5F8A-$F5FAA LOCAL
    Bee_SetAltitude:
    {
        LDA.b #$10 : STA $0F70, X
        
        LDA $0EB0, X : BEQ .not_good_bee
        
        ; \note Now this is interesting... It seems to set the bee's properties
        ; byte using some magic formula... \wtf Is this?
        LDA $0F50, X : AND.b #$F1 : STA $00
        
        LDA $1A : LSR #4 : AND.b #$03 : INC A : ASL A : ORA $00 : STA $0F50, X
    
    .not_good_bee
    
        RTS
    }

; ==============================================================================

    ; *$F5FAB-$F602D LOCAL
    GoodBee_ScanForTargetableSprites:
    {
        LDA.b #$0F : STA $00
        
        TXA : ASL #2 : AND.b #$0F : TAY
    
    .next_sprite
    
        CPY $0FA0 : BEQ .skip_sprite
        
        LDA $0DD0, Y : CMP.b #$09 : BCC .skip_sprite
        
        LDA $0F00, Y : BNE .skip_sprite
        
        LDA $0E40, Y : BMI .is_npc_sprite
        
        LDA $0F20, Y : CMP $0F20, X : BNE .skip_sprite
        
        LDA $0F60, Y : AND.b #$40 : BNE .skip_sprite
        
        LDA $0BA0, Y : BEQ .attack_sprite
        
        BRA .skip_sprite
    
    .attack_sprite
    
        ; \wtf Again, a check of a good bee. Do normal bees ever attack other
        ; sprites? I don't think so?
        LDA $0EB0, X : BEQ .skip_sprite
        
        LDA $0CD2, Y : AND.b #$40 : BNE .attack_sprite
    
    .skip_sprite
    
        DEY : TYA : AND.b #$0F : TAY
        
        DEC $00 : BPL .next_sprite
        
        CLC
        
        RTS
    
    .attack_sprite
    
        JSL GoodBee_AttackOtherSprite
        
        PHX
        
        JSL GetRandomInt : AND.b #$03 : TAX
        
        LDA $0D10, Y : ADD .box_sizes, X : STA $04
        LDA $0D30, Y : ADC.b #$00        : STA $05
        
        JSL GetRandomInt : AND.b #$03 : TAX
        
        LDA $0D00, Y : ADD .box_sizes, X : STA $06
        LDA $0D20, Y : ADC.b #$00        : STA $07
        
        PLX
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; *$F602E-$F603B LOCAL
    Bee_Buzz:
    {
        TXA : EOR $1A : AND.b #$1F : BNE .delay
        
        LDA.b #$2C : JSL Sound_SetSfx3PanLong
    
    .delay
    
        RTS
    }

; ==============================================================================
