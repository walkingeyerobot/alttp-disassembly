
; ==============================================================================

    ; $32858-$32863 DATA
    pool Sprite_CoveredRupeeCrab:
    {
    
    .animation_states
        db 3, 4, 5, 4
    
    .x_speeds
        db -12,  12,   0,  0
    
    .y_speeds
        db   0,   0, -12, 12
    }
    
; ==============================================================================

    ; $32864-$3286B
    pool Sprite_RupeeCrab:
    {
    
    .x_speeds
        db -16,  16, -16,  16
    
    .y_speeds
        db -16, -16,  16,  16
    }

; ==============================================================================

    ; *$3286C-$3291C JUMP LOCATION
    Sprite_CoveredRupeeCrab:
    {
        LDA $0D80, X : BEQ .still_covered
        
        JMP Sprite_RupeeCrab
    
    .still_covered
    
        JSR CoveredRupeeCrab_Draw
        JSR Sprite_CheckIfActive
        
        STZ $0DC0, X
        
        JSR Sprite_DirectionToFacePlayer
        
        LDA $0DF0, X : BNE BRANCH_BETA
        
        LDA $0E : ADD.b #$30 : CMP.b #$60 : BCS BRANCH_GAMMA
        LDA $0F : ADD.b #$20 : CMP.b #$40 : BCS BRANCH_GAMMA
        
        LDA.b #$20 : STA $0DF0, X
    
    BRANCH_BETA:
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA $0E70, X : BNE .tile_collision
        
        JSR Sprite_Move
    
    .tile_collision
    
        JSR Sprite_CheckTileCollision
        JSR Sprite_CheckDamageFromPlayer
        
        INC $0E80, X : LDA $0E80, X : LSR A : AND.b #$03 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
    
    BRANCH_GAMMA:
    
        ; The only real alternative is probably a bush covered crab.
        LDA $0E20, X : CMP.b #$3E : BNE .not_rock_covered_crab
        
        ; can't pick up the rock off of the crab...
        LDA $7EF354 : CMP.b #$01 : BCC .puny_girly_man
    
    .not_rock_covered_crab
    
        JSL Sprite_CheckIfLiftedPermissiveLong
    
    .puny_girly_man
    
        LDA $0DD0, X : CMP.b #$09 : BEQ .sprite_still_active
        
        LDA.b #$01
        
        LDY $0E20, X : CPY.b #$17 : BNE BRANCH_IOTA
        
        INC A
    
    BRANCH_IOTA:
    
        STA $0DB0, X
        
        LDA.b #$EC : STA $0E20, X
        
        LSR $0F50, X : ASL $0F50, X
        
        STZ $0DC0, X
        
        LDA.b #$3E : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $0E40, Y : ASL A : LSR A : STA $0E40, Y
        
        LDA.b #$80 : STA $0E10, Y
        
        LDA.b #$09 : STA $0F50, Y : STA $0D80, Y
    
    .spawn_failed
    .sprite_still_active
    
        RTS
    }

; ==============================================================================

    ; *$3291D-$32A0B LOCAL
    Sprite_RupeeCrab:
    {
        JSR Sprite_PrepAndDrawSingleLarge
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamageFromPlayer
        
        LDA $0E10, X : BNE BRANCH_ALPHA
        
        JSR Sprite_CheckDamageToPlayer
    
    BRANCH_ALPHA:
    
        INC $0E80, X : LDA $0E80, X : LSR A : AND.b #$03 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA $AA08, Y : STA $0F50, X
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        LDA.b #$10 : STA $0F10, X
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        BRA .dont_move
    
    .no_tile_collision
    
        JSR Sprite_Move
    
    .dont_move
    
        JSR Sprite_CheckTileCollision
        
        LDA $0F10, X : BNE BRANCH_DELTA
        
        TXA : EOR $1A : AND.b #$1F : BNE BRANCH_DELTA
        
        LDA.b #$10 : JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA $01 : EOR.b #$FF : INC A : STA $0D50, X
    
    BRANCH_DELTA:
    
        LDA $1A : AND.b #$01 : BNE BRANCH_EPSILON
        
        INC $0ED0, X
        
        LDA $0ED0, X : CMP.b #$C0 : BNE BRANCH_ZETA
        
        LDA.b #$0F : JSR Sprite_CustomTimedScheduleForBreakage
        
        LDY.b #$01
        
        BRA .spawn_green_rupee
    
    BRANCH_ZETA:
    
        LDA $0ED0, X : AND.b #$0F : BNE BRANCH_EPSILON
        
        LDY.b #$00
        
        LDA $0EB0, X : CMP.b #$06 : BNE .spawn_green_rupee
        
        LDA.b #$DB : BRA .red_rupee
    
    .spawn_green_rupee
    
        LDA.b #$D9
    
    .red_rupee
    
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
            
        INC $0EB0, X
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $00 : ADD.b #$08 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA.b #$20 : STA $0F80, Y
        
        LDA.b #$10 : STA $0F10, Y
        
        PHX
        
        TYX
        
        LDA.b #$10 : JSR Sprite_ApplySpeedTowardsPlayer
        
        LDA $00 : EOR.b #$FF : STA $0D40, X
        
        LDA $01 : EOR.b #$FF : STA $0D50, X
        
        PLX
        
        LDA.b #$30 : JSL Sound_SetSfx3PanLong
    
    .spawn_failed
    BRANCH_EPSILON:
    
        RTS
    
    .animation_states
        db $00, $01, $00, $01, $00, $00, $40, $00    
    }

; ==============================================================================

    ; *$32A0C-$32A13 LONG
    Sprite_CheckIfLiftedPermissiveLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_CheckIfLiftedPermissiveWrapper
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \wtf Don't ask me why this is needed rather than just calling the routine
    ; directly.
    ; \optimize See the wtf above.
    ; *$32A14-$32A17 LOCAL
    Sprite_CheckIfLiftedPermissiveWrapper:
    {
        JSR Sprite_CheckIfLiftedPermissive
        
        RTS
    }

; ==============================================================================

    ; $32A18-$32A47 DATA
    pool CoveredRupeeCrab_Draw:
    {
    
    .y_offsets
        dw  0,  0,  0, -3,  0, -5,  0, -6
        dw  0, -6,  0, -6
    
    .chr
        db $44, $44, $E8, $44, $E8, $44, $E6, $44
        db $E8, $44, $E6, $44
    
    .properties
        db $00, $0C, $03, $0C, $03, $0C, $03, $0C
        db $03, $0C, $43, $0C
    }

; ==============================================================================

    ; *$32A48-$32ABD LOCAL
    CoveredRupeeCrab_Draw:
    {
        JSR Sprite_PrepOamCoord
        
        LDA $0FC6 : CMP.b #$03 : BCS .invalid_gfx_loaded
        
        STZ $07
        
        LDA $0E20, X : CMP.b #$17 : BNE .under_rock
        
        LDA.b #$02 : STA $07
    
    .under_rock
    
        LDA $0DC0, X : ASL A : STA $06
        
        PHX
        
        LDX.b #$01
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y

        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA .chr, X : CMP.b #$44 : BNE .chr_mismatch
        
        ADD $07
    
    .chr_mismatch
    
                                                    INY : STA ($90), Y
        LDA $05 : AND.b #$FE : ORA .properties, X : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
    
    .invalid_gfx_loaded
    
        RTS
    }

; ==============================================================================
