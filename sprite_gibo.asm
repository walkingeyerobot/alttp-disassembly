
    !is_nucleus_expelled = $0D90

; ==============================================================================

    ; $ECCDB-$ECCDE DATA
    pool Sprite_GiboNucleus:
    {
    
    .vh_flip
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; $ECCDF-$ECCE0 DATA
    pool Gibo_Draw:
    {
    
    .palettes
        db $0B, $07
    }

; ==============================================================================

    ; *$ECCE1-$ECD11 JUMP LOCATION
    Sprite_Gibo:
    {
        LDA $0DA0, X : BEQ Gibo_Main
    
    shared Sprite_GiboNucleus:
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckDamage
        
        INC $0E80, X
        
        LDA $0E80, X : LSR #2 : AND.b #$03 : TAY
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        LDA !timer_0, X : BEQ .halt_movement
        
        JSR Sprite4_Move
        JSR Sprite4_BounceFromTileCollision
    
    .halt_movement
    
        RTS
    }

; ==============================================================================

    ; $ECD12-$ECD61 BRANCH LOCATION
    Gibo_Main:
    {
        JSR Gibo_Draw
        JSR Sprite4_CheckIfActive
        
        INC $0EC0, X
        
        LDY $0EB0, X
        
        LDA $0DD0, Y : CMP.b #$06 : BNE .nucleus_not_dying
        
        STA $0DD0, X
        
        LDA !timer_0, Y : STA !timer_0, X
        
        LDA $0E40, X : ADD.b #$04 : STA $0E40, X
        
        RTS
    
    .nucleus_not_dying
    
        LDA $1A : LSR #3 : AND.b #$03 : STA $0E80, X
        
        LDA $1A : AND.b #$3F : BNE .dont_pursue_player
        
        JSR Sprite4_IsToRightOfPlayer
        
        TYA : ASL #2 : STA $0DE0, X
    
    .dont_pursue_player
    
        JSL Sprite_CheckDamageToPlayerLong
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Gibo_ExpelNucleus
        dw Gibo_DelayPursuit
        dw Gibo_PursueNucleus
    }

; ==============================================================================

    ; $ECD62-$ECD71 DATA
    pool Gibo_ExpelNucleus:
    {
    
    .x_speeds
        db  16,  16,   0, -16, -16, -16,   0,  16
    
    .y_speeds
        db   0,   0,  16, -16,  16,  16, -16, -16
    }

; ==============================================================================

    ; *$ECD72-$ECDE1 JUMP LOCATION
    Gibo_ExpelNucleus:
    {
        LDA !timer_0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$30 : STA !timer_0, X
        
        INC !is_nucleus_expelled, X
        
        ; \bug Maybe. What if the nucleus fails to spawn? Will the thing
        ; just break completely? It's good that they check the return value,
        ; but it shouldn't advance to the next AI state, imo.
        LDA.b #$C3 : JSL Sprite_SpawnDynamically : BMI .nucleus_spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        ; Store the index of the spawned child sprite (Gibo nucleus).
        TYA : STA $0EB0, X
        
        LDA.b #$01 : STA $0E40, Y
                     STA $0DA0, Y
        
        LDA.b #$10 : STA $0E60, Y
        
        LDA $0ED0, X : STA $0E50, Y
        
        LDA.b #$07 : STA $0F50, Y
        
        LDA.b #$30 : STA !timer_0, Y
        
        PHX
        
        INC $0DB0, X : LDA $0DB0, X : CMP.b #$03 : BNE .pick_random_direction
        
        ; Otherwise pursue the player? \task confirm that it's not fleeing
        ; in this case.
        STZ $0DB0, X
        
        PHY
        
        JSR Sprite4_DirectionToFacePlayer : TYX
        
        PLY
        
        BRA .set_xy_speeds
    
    .pick_random_direction
    
        JSL GetRandomInt : AND.b #$07 : TAX
    
    .set_xy_speeds
    
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
    
    .nucleus_spawn_failed
    
        RTS
    
    .delay
    
        ; \task Terrible branch name, but maybe semiaccurate.
        CMP.b #$20 : BNE .dont_special_draw
        
        STA !timer_1, X
    
    .dont_special_draw
    
        RTS
    }

; ==============================================================================

    ; *$ECDE2-$ECDEA JUMP LOCATION
    Gibo_DelayPursuit:
    {
        LDA !timer_0, X : BNE .delay
        
        INC $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$ECDEB-$ECE5D JUMP LOCATION
    Gibo_PursueNucleus:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .stagger_retargeting
        
        ; \note Y was preloaded with the index of the nucleus before calling
        ; this.
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        REP #$20
        
        LDA $0FD8 : SUB $04 : ADD.w #$0002 : CMP.w #$0004 : BCS .dont_recombine
        
        LDA $0FDA : SUB $06 : ADD.w #$0002 : CMP.w #$0004 : BCS .dont_recombine
        
        SEP #$20
        
        LDY $0EB0, X
        
        ; Terminate the nucleus now that we've recombined (another will spawn
        ; soon).
        LDA.b #$00 : STA $0DD0, Y
        
        STZ !is_nucleus_expelled, X
        
        STZ $0D80, X
        
        LDA $0E50, Y : STA $0ED0, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$20 : STA !timer_0, X
        
        RTS
    
    .dont_recombine
    
        SEP #$20
        
        ; Go towards the nucleus.
        LDA.b #$10 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
    
    .stagger_retargeting
    
        JSR Sprite4_Move
        
        RTS
    }

; ==============================================================================

    ; $ECE5E-$ECF5D DATA
    pool Gibo_Draw:
    {
    
    .oam_groups
        dw  4, -4 : db $8A, $40, $00, $02
        dw -4, -4 : db $8F, $40, $00, $00
        dw 12, 12 : db $8E, $40, $00, $00
        dw -4,  4 : db $8C, $40, $00, $02
        
        dw  4, -4 : db $AA, $40, $00, $02
        dw -4, -4 : db $9F, $40, $00, $00
        dw 12, 12 : db $9E, $40, $00, $00
        dw -4,  4 : db $AC, $40, $00, $02
        
        dw  3, -3 : db $AA, $40, $00, $02
        dw -3, -3 : db $9F, $40, $00, $00
        dw 11, 11 : db $9E, $40, $00, $00
        dw -3,  3 : db $AC, $40, $00, $02
        
        dw  3, -3 : db $8A, $40, $00, $02
        dw -3, -3 : db $8F, $40, $00, $00
        dw 11, 11 : db $8E, $40, $00, $00
        dw -3,  3 : db $8C, $40, $00, $02
        
        dw -3, -4 : db $8A, $00, $00, $02
        dw 13, -4 : db $8F, $00, $00, $00
        dw -3, 12 : db $8E, $00, $00, $00
        dw  5,  4 : db $8C, $00, $00, $02
        
        dw -3, -4 : db $AA, $00, $00, $02
        dw 13, -4 : db $9F, $00, $00, $00
        dw -3, 12 : db $9E, $00, $00, $00
        dw  5,  4 : db $AC, $00, $00, $02
        
        dw -2, -3 : db $AA, $00, $00, $02
        dw 12, -3 : db $9F, $00, $00, $00
        dw -2, 11 : db $9E, $00, $00, $00
        dw  4,  3 : db $AC, $00, $00, $02
        
        dw -2, -3 : db $8A, $00, $00, $02
        dw 12, -3 : db $8F, $00, $00, $00
        dw -2, 11 : db $8E, $00, $00, $00
        dw  4,  3 : db $8C, $00, $00, $02
    }

; ==============================================================================

    ; *$ECF5E-$ECFC2 LOCAL
    Gibo_Draw:
    {
        LDA !is_nucleus_expelled, X : BNE .is_currently_expelled
        
        LDA $0E40, X : PHA
        
        LDA.b #$01 : STA $0E40, X
        
        LDA !timer_1, X : AND.b #$04 : LSR #2 : STA $00
        
        LDA $0EC0, X : LSR #2 : AND.b #$03 : TAY
        
        LDA $0F50, X : PHA
        
        LDA Sprite_GiboNucleus.vh_flip, Y
        
        LDY $00
        
        ORA .palettes, Y : STA $0F50, X
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        PLA : STA $0F50, X
        PLA : STA $0E40, X
    
    .is_currently_expelled
    
        LDA.b #$00 : XBA
        
        LDA $0E80, X : ADD $0DE0, X
        
        REP #$20
        
        ASL #5 : ADC.w #.oam_groups : STA $08
        
        REP #$20
        
        LDA $90 : ADD.w #$0008 : STA $90
        
        INC $92 : INC $92
        
        SEP #$20
        
        LDA.b #$04 : JMP Sprite4_DrawMultiple
    }

; ==============================================================================
