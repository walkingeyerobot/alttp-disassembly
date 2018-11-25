
; ==============================================================================

    ; *$EE4C8-$EE4EA JUMP LOCATION
    Sprite_Vitreous:
    {
        ; VITREOUS' CODE
        
        LDA $0F10, X : BEQ .not_blastin_with_lightning
        
        ; Just hanging out in green slime, right?
        LDA.b #$03 : STA $0DC0, X
    
    .not_blastin_with_lightning
    
        JSR Vitreous_Draw
        JSR Sprite4_CheckIfActive
        JSR Vitreous_SelectVitreolusToActivate
        JSR Sprite4_CheckDamage
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Vitreous_Dormant
        dw Vitreous_SpewLightning
        dw Vitreous_PursuePlayer
    }

; ==============================================================================

    ; *$EE4EB-$EE53C JUMP LOCATION
    Vitreous_Dormant:
    {
        STZ $0FF8
        
        STZ $0EA0, X
        
        ; Impervious to everything in this state.
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDA $1A : AND.b #$01 : BNE .dont_prep_lightning
        
        DEC $0D90, X : BNE .dont_prep_lightning
        
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        LDA.b #$10 : STA $0F10, X
        
        INC $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
        
        LDA $0ED0, X : BNE .dont_dislodge
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        STZ $0BA0, X
        
        LDA.b #$35 : STA $012E
        
        RTS
    
    .dont_dislodge
    .dont_prep_lightning
    
        LDY.b #$04
        
        LDA $1A : AND.b #$30 : BNE .pulsate_in_slime
        
        INY
    
    .pulsate_in_slime
    
        TYA : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $EE53D-$EE548 DATA
    {
    
    .animation_states
        db 2, 1
    
    .lightning_timers
        db 32, 32, 32, 64, 96, 128, 160, 192, 224, 0
    }

; ==============================================================================

    ; *$EE549-$EE588 JUMP LOCATION
    Vitreous_SpewLightning:
    {
        STZ $0EA0, X
        
        LDA $0DF0, X : BNE .check_lightning
        
        LDA.b #$10 : STA $0F10, X
        
        STZ $0D80, X
        
        ; Indexed off of how many homies we have left. Less means lightning
        ; more frequently.
        LDY $0ED0, X
        
        LDA .lightning_timers, Y : STA $0D90, X

        RTS
    
    ; *$EE563 ALTERNATE ENTRY POINT
    shared Vitreous_Animate:
    
    .check_lightning
    
        CMP.b #$40 : BEQ .do_lightning
        CMP.b #$41 : BEQ .do_lightning
        CMP.b #$42 : BNE .dont_lightning
    
    .do_lightning
    
        JSL Sprite_SpawnLightning
    
    .dont_lightning
    
        STZ $0DC0, X
        
        JSR Sprite4_IsToRightOfPlayer
        
        LDA $0F : ADD.b #$10 : CMP.b #$20 : BCC .set_animation_state
        
        LDA .animation_states, Y : STA $0DC0, X
    
    .set_animation_state
    
        RTS
    }

; ==============================================================================

    ; $EE589-$EE58A DATA
    pool Vitreous_PursuePlayer:
    {
    
    .x_shake_speeds
        db 8, -8
    }

; ==============================================================================

    ; *$EE58B-$EE5C9 JUMP LOCATION
    Vitreous_PursuePlayer:
    {
        ; \wtf This is nonsensical in that I don't know why it jumps to this
        ; spot unless.... they intended Vitreous to shoot lightning even when
        ; hopping around. \task Low priority, but some time try inserting code
        ; to see if we can make him shoot lightning in this state.
        JSR Vitreous_Animate
        JSR Sprite4_CheckIfRecoiling
        
        LDA $0DF0, X : BEQ .bouncing_around
        
        ; Shake a bit before coming out to face the player.
        AND.b #$02 : LSR A : TAY
        
        LDA .x_shake_speeds, Y : STA $0D50, X
        
        JSR Sprite4_MoveHoriz
        
        RTS
    
    .bouncing_around
    
        JSR Sprite4_MoveXyz
        JSR Sprite4_CheckTileCollision
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .aloft
        
        STZ $0F70, X
        
        LDA.b #$20 : STA $0F80, X
        
        LDA.b #$10
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA.b #$21 : JSL Sound_SetSfx2PanLong
    
    .aloft
    
        RTS
    }

; ==============================================================================

    ; *$EE5DA-$EE601 LOCAL
    Vitreous_SelectVitreolusToActivate:
    {
        INC $0E80, X : LDA $0E80, X : AND.b #$3F : BNE .delay
        
        JSL GetRandomInt : AND.b #$0F : TAY
        
        LDA $E5CA, Y : TAY
        LDA $0D80, Y : BNE .already_activated
        
        
        INC A : STA $0D80, Y
        
        LDA.b #$15 : STA $012E
    
    .delay
    
        RTS
    
    .already_activated
    
        ; Decrease this counter by one so we can try again on the next frame.
        DEC $0E80, X
        
        RTS
    }

; ==============================================================================

    ; $EE602-$EE611 DATA
    pool Sprite_SpawnLightning:
    {
    
    .x_offsets_low
        db -8,  8,  8, -8,  8, -8, -8,  8
    
    .x_offsets_high
        db -1,  0,  0, -1,  0, -1, -1,  0
    }

; ==============================================================================

    ; *$EE612-$EE655 LONG
    Sprite_SpawnLightning:
    {
        PHB : PHK : PLB
        
        LDA.b #$BF : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$26 : STA $012F
        
        JSL Sprite_SetSpawnedCoords
        
        JSL GetRandomInt : AND.b #$07 : STA $0D90, Y
        
        PHX
        
        TAX
        
        LDA $00 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADC.b #$0C : STA $0D00, Y
        
        PLX
        
        LDA.b #$02 : STA $0DF0, Y
        
        LDA.b #$20 : STA $0FF9
    
    .spawn_failed
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $EE656-$EE715 DATA
    pool Vitreous_Draw:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$EE716-$EE762 LOCAL
    Vitreous_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #$E656 : STA $08
        
        LDA $0D80, X : AND.w #$00FF : CMP.w #2 : BNE .use_standard_oam_region
        
        LDA $0DD0, X : AND.w #$00FF : CMP.w #9 : BNE .use_standard_oam_region
        
        ; This is a high priority oam region (start of oam is like that!).
        LDA.w #$0800 : STA $90
        
        LDA.w #$0A20 : STA $92
    
    .use_standard_oam_region
    
        SEP #$20
        
        LDA.b #$04 : JSR Sprite4_DrawMultiple
        
        LDA $0D80, X : CMP.b #$02 : BNE .not_bouncing
        
        ; If vitreous is out and bouncing around, use a different palette.
        ;
        LDA $0B89, X : AND.b #$F1 : STA $0B89, X
        
        JSL Sprite_DrawVariableSizedShadow
    
    .not_bouncing
    
        RTS
    }

; ==============================================================================
