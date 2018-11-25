; ==============================================================================

    ; Notes:
    ; !depression_timer = $0ED0
    ; That is, the amount of time it takes to get over being damaged, and it
    ; will stay in this state for a couple seconds because apparently walking
    ; Zora are huge babies compare to most monsters when they actually get
    ; hurt.

    ; *$29D4A-$29D7E JUMP LOCATION
    Sprite_WalkingZora:
    {
        ; Walking Zora
        
        LDA $0EA0, X : BEQ .not_recoiling
        
        ; Overrides the recoiling logic that many sprites would typically use.
        STZ $0EA0, X
        
        LDA.b #$03 : STA $0DA0, X
        LDA.b #$C0 : STA $0ED0, X
        
        LDA $0F40, X : STA $0D50, X
        ASL A        : ROR $0D50, X
        
        LDA $0F30, X : STA $0D40, X
        ASL A        : ROR $0D40, X
    
    .not_recoiling
    
        LDA $0DA0, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw WalkingZora_Waiting
        dw WalkingZora_Surfacing
        dw WalkingZora_Ambulating
        dw WalkingZora_Depressed
    }

; ==============================================================================

    ; *$29D7F-$29D9B JUMP LOCATION
    WalkingZora_Waiting:
    {
        JSL Sprite_PrepOamCoordLong
        JSR Sprite2_CheckIfActive
        
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$7F : STA $0DF0, X
        
        INC $0DA0, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$29D9C-$29DD5 JUMP LOCATION
    WalkingZora_Surfacing:
    {
        JSR Zora_Draw
        JSR Sprite2_CheckIfActive
        
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
        
        INC $0DA0, X
        
        LDA.b #$30 : STA $0F80, X
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0DE0, X : STA $0EB0, X
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA Zora_Surfacing.animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$29DD6-$29E65 JUMP LOCATION
    WalkingZora_Ambulating:
    {
        LDA $0E80, X : AND.b #$08 : LSR A : ADC $0DE0, X : TAY
        
        LDA Sprite_Recruit.animation_states, Y : STA $0DC0, X
        
        JSR WalkingZora_Draw
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckDamage
        JSR Sprite2_MoveAltitude
        
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        LDA $0F70, X : DEC A : BPL .in_air
        
        LDA $0F80, X : CMP.b #$F0 : BPL .beta
        
        ; Hold x / y velocities at zero while the Zora is popping out of the
        ; water.
        JSR Sprite2_ZeroVelocity
    
    .beta
    
        STZ $0F70, X
        STZ $0F80, X
        
        TXA : EOR $1A : AND.b #$0F : BNE .delay
        
        JSR Sprite2_DirectionToFacePlayer : TYA : STA $0EB0, X
        
        TXA : EOR $1A : AND.b #$1F : BNE .delay
        
        TYA : STA $0DE0, X
        
        LDA.b #$08 : JSL Sprite_ApplySpeedTowardsPlayerLong
    
    .delay
    .in_air
    
        JSR Sprite2_Move
        JSR Sprite2_CheckTileCollision
        
        LDA $0F70, X : DEC A : BPL .in_air_2
        
        JSR WalkingZora_DetermineShadowStatus
        
        LDA $0FA5 : CMP.b #$08 : BNE .not_in_deep_water
        
        JSL Sprite_SelfTerminate
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$03 : STA $0DD0, X
        LDA.b #$0F : STA $0DF0, X
        
        STZ $0D80, X
        
        LDA.b #$03 : STA $0E40, X
    
    .not_in_deep_water
    .in_air_2
    
        ; How the FUCK is this a good use of time? Incrementing the variable
        ; inplace would be 3x faster!
        JSR Recruit_Moving.tick_animation_clock
        
        RTS
    }

; ==============================================================================

    ; *$29E66-$29EEF JUMP LOCATION
    WalkingZora_Depressed:
    {
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA $1A : AND.b #$03 : BNE .delay
        
        ; Decrement the depression timer...
        DEC $0ED0, X : BNE .delay
        
        LDA.b #$02 : STA $0DA0, X
        
        LDY $0DD0, X
        
        LDA.b #$09 : STA $0DD0, X
        
        CPY.b #$0A : BNE .not_being_carried
        
        STZ $0308
        STZ $0309
    
    .not_being_carried
    .delay
    
        LDA $0ED0, X : CMP.b #$30 : BCS .beta
        
        LDA $1A : AND.b #$01 : BNE .beta
        
        LDA $1A : LSR A : AND.b #$01 : TAY
        
        ; Kind of a bit incestual data referencing there, amirite? >8^/
        LDA ZoraKing_RumblingGround.offsets_low, Y : ADD $0D10, X : STA $0D10, X
        LDA .offsets_x_high, Y                     : ADC $0D30, X : STA $0D30, X
    
    .beta
    
        STZ $0DC0, X
        
        STZ $0E70, X
        
        JSR WalkingZora_DrawWaterRipple
        
        DEC $0E40, X : DEC $0E40, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        INC $0E40, X : INC $0E40, X
        
        STZ $0EC0, X
        
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_Move
        JSL ThrownSprite_TileAndPeerInteractionLong
    
    ; *$29EDB ALTERNATE ENTRY POINT
    shared WalkingZora_DetermineShadowStatus:
    
        STZ $0EC0, X
        
        LDA $0F70, X : BNE .in_the_air
        
        LDA $0FA5 : CMP.b #$09 : BNE .not_in_shallow_water
        
        INC $0EC0, X
    
    .not_in_shallow_water
    .in_the_air
    
        RTS
    
    .offsets_x_high
        db $00, $FF
    }

; ==============================================================================

    ; $29EF0-$29F07 DATA
    pool WalkingZora_Draw:
    {
    
    .head_chr
        db $CE, $CE, $A4, $EE
    
    .head_properties
        db $40, $00, $00, $00
        
    .body_chr
        db $CC, $EC, $CC, $EC, $E8, $E8, $CA, $CA
    
    .body_properties
        db $40, $40, $00, $00, $00, $40, $00, $40
    }

; ==============================================================================

    ; *$29F08-$29FAB LOCAL
    WalkingZora_Draw:
    {
        JSR WalkingZora_DrawWaterRipple
        JSR Sprite2_PrepOamCoord
        
        LDY.b #$00
        
        LDA $0DC0, X : STA $06 : CMP.b #$04 : BCS .certain_animation_frame
        
        LSR A
        
        REP #$20
        
        LDA $02 : SBC.w #$0000 : STA $02
        
        SEP #$20
    
    .certain_animation_frame
    
        PHX
        
        LDA $0EB0, X : TAX
        
        REP #$20
        
        LDA $00 : STA ($90), Y : AND.w #$0100 : STA $0E
        
        LDA $02 : SUB.w #$0006 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .head_on_screen_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .head_on_screen_y_1
    
        SEP #$20
        
        LDA .head_chr, X        : INY           : STA ($90), Y
        LDA .head_properties, X : INY : ORA $05 : STA ($90), Y
        
        LDA.b #$02 : ORA $0F : STA ($92)
        
        LDA $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : INY : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : INC #2 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .body_on_screen_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .body_on_screen_y
    
        SEP #$20
        
        PLX
        
        LDA .body_chr, X                  : INY : STA ($90), Y
        LDA .body_properties, X : ORA $05 : INY : STA ($90), Y
        
        LDY.b #$01 : LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLX
        
        ; Flag being set means we're in shallow water... and the ripples are
        ; probably drawn instead?
        LDA $0EC0, X : BNE .dont_draw_shadow
        
        JSL Sprite_DrawShadowLong
    
    .dont_draw_shadow
    
        RTS
    }

; ==============================================================================

    ; $29FAC-$29FDF DATA
    pool Sprite_DrawWaterRipple:
    {
    
    .oam_groups
        dw 0, 10 : db $D8, $01, $00, $00
        dw 8, 10 : db $D8, $41, $00, $00
        
        dw 0, 10 : db $D9, $01, $00, $00
        dw 8, 10 : db $D9, $41, $00, $00
        
        dw 0, 10 : db $DA, $01, $00, $00
        dw 8, 10 : db $DA, $41, $00, $00
    
    .animation_states
        db $00, $10, $20, $10
    }

; ==============================================================================

    ; *$29FE0-$29FF9 LOCAL
    WalkingZora_DrawWaterRipple:
    {
        LDA $0EC0, X : BEQ .not_in_shallow_water
    
    ; *$29FE5 ALTERNATE ENTRY POINT
    shared Sprite_AutoIncDrawWaterRipple:
    
        ; The distinction in the name is that it auto increments the sprite
        ; base pointer.
        
        JSL Sprite_DrawWaterRipple
        
        REP #$20
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
    
    .not_in_shallow_water
    
        RTS
    }

; ==============================================================================

    ; *$29FFA-$2A028 LONG
    Sprite_DrawWaterRipple:
    {
        PHB : PHK : PLB
        
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA .animatiom_states, Y
        
        ADD.b ((.oam_groups >> 0) & $FF)              : STA $08
        LDA.b ((.oam_groups >> 8) & $FF) : ADC.b #$00 : STA $09
        
        LDA.b #$02
        
        JSR Sprite_DrawMultipleRedundantCall
        
        ; Force the palette to 2 and the nametable to 0 for both of the
        ; ripple's subsprites. Also forces the h and vflip settings to off
        ; for the first, and h flip only on the righthand subsprite.
        LDY.b #$03 : LDA ($90), Y : AND.b #$30 : ORA.b #$04 : STA ($90), Y
        LDY.b #$07 : ORA.b #$40                             : STA ($90), Y
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2A029-$2A030 LONG
    Sprite_AutoIncDrawWaterRippleLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_AutoIncDrawWaterRipple
        
        PLB
        
        RTL
    }

; ==============================================================================
