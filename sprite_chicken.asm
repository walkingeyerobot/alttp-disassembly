
; ==============================================================================

    ; \unused Presumably
    ; $32540-$325BF DATA
    {
        dw -24,  -8,   8,  24, -24,  -8,   8,  24
        dw -24,  -8,   8,  24, -24,  -8,   8,  24
        dw -22,  -7,   7,  22, -22,  -7,   7,  22
        dw -22,  -7,   7,  22, -22,  -7,   7,  22
        dw -24, -24, -24, -24,  -8,  -8,  -8,  -8
        dw   8,   8,   8,   8,  24,  24,  24,  24
        dw -22, -22, -22, -22,  -7,  -7,  -7,  -7
        dw   7,   7,   7,   7,  22,  22,  22,  22
    }

    ; $325C0-$325C1 DATA
    {
    
    .h_flip
        db $40, $00
    }

; ==============================================================================

    ; *$325C2-$326B0 JUMP LOCATION
    Sprite_Chicken:
    {
        LDA $0D50, X : BEQ .x_speed_at_rest
        
        ; Change h-flip status mainly when 
        ASL A : ROL A : AND.b #$01 : TAY
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
    
    .x_speed_at_rest
    
        JSR Sprite_PrepAndDrawSingleLarge
        
        LDA $0EB0, X : BEQ .not_transmutable_to_human
        
        LDA.b #$3D : STA $0E20, X
        
        JSL Sprite_LoadProperties
        
        INC $0E30, X
        
        LDA.b #$30 : STA $0DF0, X
        
        LDA.b #$15 : STA $012E : STA $0BA0, X
        
        RTS
    
    .not_transmutable_to_human
    
        LDA $0DD0, X : CMP.b #$0A : BNE .not_being_held_by_player
        
        LDA.b #$03 : STA $0D80, X
        
        LDA $11 : BNE .inactive_game_submodule
        
        JSR Chicken_SlowAnimate
        JSR Chicken_DrawDistressMarker
        
        LDA $1A : AND.b #$0F : BNE .no_bawk_bawk
        
        JSR Chicken_BawkBawk
    
    .no_bawk_bawk
    .inactive_game_submodule
    .not_being_held_by_player
    
        JSR Sprite_CheckIfActive
        
        LDA $0DB0, X : BEQ .not_part_of_horde
        
        LDA $0F50, X : ORA.b #$10 : STA $0F50, X
        
        JSR Sprite_Move
        
        LDA.b #$0C : STA $0F70, X : STA $0BA0, X
        
        TXA : EOR $1A : AND.b #$07 : BNE .horde_damage_delay
        
        JSR Sprite_CheckDamageToPlayer
    
    .horde_damage_delay
    
        JMP Chicken_FastAnimate
    
    .not_part_of_horde
    
        LDA.b #$FF : STA $0E50, X
        
        ; Begin spawning attack chickens if the player has hit this chicken
        ; too many times.
        LDA $0DA0, X : CMP.b #$23 : BCC .anospawn_attack_chicken
        
        JSR Chicken_SpawnAvengerChicken
    
    .anospawn_attack_chicken
    
        LDA $0EA0, X : BEQ .no_new_hits_from_player
        
        STZ $0EA0, X
        
        ; If saturated, don't make this particular chicken bawk, because the
        ; others will be doing a lot of it.
        LDA $0DA0, X : CMP.b #$23 : BCS .saturated_with_hits
        
        INC $0DA0, X
        
        JSR Chicken_BawkBawk
    
    .saturated_with_hits
    
        LDA.b #$02 : STA $0D80, X
    
    .no_new_hits_from_player
    
        JSR Sprite_CheckDamageFromPlayer
        
        LDA $0D80, X : BEQ .calm
        CMP.b #$01   : BEQ Chicken_Hopping
        CMP.b #$02   : BNE .aloft
        
        JMP Chicken_FleeingPlayer
    
    .aloft
    
        JMP Chicken_Aloft
    
    .calm
    
        LDA $0DF0, X : BNE .delay_direction_change
        
        JSL GetRandomInt : AND.b #$0F
        
        PHX : TXY
        
        TAX
        
        LDA $05AAE4, X : STA $0D50, Y
        
        LDA $05AAF4, X : STA $0D40, Y
        
        PLX
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$10 : STA $0DF0, X
        
        INC $0D80, X
    
    .delay_direction_change
    
        STZ $0DC0, X
    
    ; *$326AD ALTERNATE ENTRY POINT
    shared Chicken_CheckIfLifted:
    
        JSR Sprite_CheckIfLifted
        
        RTS
    }

; ==============================================================================

    ; *$326B1-$326FB BRANCH LOCATION
    Chicken_Hopping:
    {
        TXA : EOR $1A : LSR A : BCC .skip_tile_collision_logic
        
        JSR Chicken_Move_XY_AndCheckTileCollision : BEQ .no_tile_collision
        
        STZ $0D80, X
    
    .no_tile_collision
    .skip_tile_collision_logic
    
        JSR Sprite_MoveAltitude
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .tick_animation_counter
        
        STZ $0F70, X
        
        LDA $0DF0, X : BNE .delay_hopping_halt
        
        LDA.b #$20 : STA $0DF0, X
        
        STZ $0D80, X
    
    .delay_hopping_halt
    
        LDA.b #$0A : STA $0F80, X
    
    .tick_animation_counter
    
    ; *$326E2 ALTERNATE ENTRY POINT
    shared Chicken_FastAnimate:
    
        INC $0E80, X
    
    ; *$326E5 ALTERNATE ENTRY POINT
    shared Chicken_SlowAnimate:
    
        INC $0E80, X : INC $0E80, X : INC $0E80, X
        
        LDA $0E80, X : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        BRA Chicken_CheckIfLifted
    }

; ==============================================================================

    ; *$326FC-$3272E JUMP LOCATION
    Chicken_FleeingPlayer:
    {
        JSR Chicken_CheckIfLifted
        JSR Chicken_Move_XY_AndCheckTileCollision
        
        STZ $0F70, X
        
        TXA : EOR $1A : AND.b #$1F : BNE .flee_delay
    
    ; *$3270C ALTERNATE ENTRY POINT
    shared Chicken_SetFleePlayerSpeeds:
    
        LDA.b #$10 : JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $00 : EOR.b #$FF : INC A : STA $0D40, X
        LDA $01 : EOR.b #$FF : INC A : STA $0D50, X
    
    .flee_delay
    
        INC $0E80, X
        
        JSR Chicken_FastAnimate
    
    ; *$32727 ALTERNATE ENTRY POINT
    shared Chicken_DrawDistressMarker:
    
        JSR Sprite_PrepOamCoord
        JSL Sprite_DrawDistressMarker
        
        RTS
    }

; ==============================================================================

    ; *$3272F-$3278D LONG
    Sprite_DrawDistressMarker:
    {
        LDA $1A : STA $06
    
    ; *$32733 ALTERNATE ENTRY POINT
    shared Sprite_CustomTimedDrawDistressMarker:
    
        ; Allocate some oam space...
        LDA.b #$10 : JSL OAM_AllocateFromRegionA
        
        LDA $06 : AND.b #$18 : BEQ .return
        
        PHX
        
        LDX.b #$03
        LDY.b #$00
    
    .next_oam_entry
    
        PHX : PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD.l .x_offsets, X       : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD.l .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA.b #$83 : INY : STA ($90), Y
        LDA.b #$22 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
    
    .return
    
        RTL
    }

; ==============================================================================

    ; *$3278E-$327B7 LOCAL
    Chicken_Aloft:
    {
        JSR Chicken_Move_XYZ_AndCheckTileCollision : BEQ .no_tile_collision
        
        JSR Sprite_Invert_XY_Speeds
        JSR Sprite_Move
        JSR Sprite_Halve_XY_Speeds
        JSR Sprite_Halve_XY_Speeds
        JSR Chicken_BawkBawk
    
    .no_tile_collision
    
        DEC $0F80, X
        
        LDA $0F70, X : BPL .not_grounded
        
        STZ $0F70, X
        
        LDA.b #$02 : STA $0D80, X
        
        JMP Chicken_SetFleePlayerSpeeds:
    
    .not_grounded
    
        JMP Chicken_FastAnimate
    }
    
; ==============================================================================

    ; *$327B8-$327C2 ALTERNATE ENTRY POINT
    Chicken_Move_XYZ_AndCheckTileCollision:
    {
    
        JSR Sprite_MoveAltitude
    
    ; $327BB ALTERNATE ENTRY POINT
    shared Chicken_Move_XY_AndCheckTileCollision:
    
        JSR Sprite_Move
        JSL Sprite_CheckTileCollisionLong
        
        RTS
    }

; ==============================================================================

    ; $327C3-$327D2 DATA
    pool Sprite_DrawDistressMarker:
    {
    
    ; \task Name this pool / routine.
    .x_offsets
        dw -3,  2,  7, 11
    
    .y_offsets
        dw -5, -7, -7, -5
    }

; ==============================================================================

    ; *$327D3-$32852 LOCAL
    Chicken_SpawnAvengerChicken:
    {
        TXA : EOR $1A : AND.b #$0F : ORA $1B : BNE .spawn_delay
        
        LDA.b #$0B
        LDY.b #$0A
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        PHX
        
        TYX
        
        LDA.b #$1E : JSL Sound_SetSfx3PanLong
        
        PLX
        
        LDA.b #$01 : STA $0DB0, Y
        
        PHX
        
        JSL GetRandomInt : STA $0F : AND.b #$02 : BEQ .vertical_entry_point
        
        LDA $0F : ADC $E2    : STA $0D10, Y
        LDA $E3 : ADC.b #$00 : STA $0D30, Y
        
        LDA $0F : AND.b #$01 : TAX
        
        LDA $9F3C, X : ADC $E8    : STA $0D00, Y
        LDA $E9      : ADC.b #$00 : STA $0D20, Y
        
        BRA .set_velocity
    
    .vertical_entry_point
    
        LDA $0F : ADC $E8    : STA $0D00, Y
        LDA $E9 : ADC.b #$00 : STA $0D20, Y
        
        LDA $0F : AND.b #$01 : TAX
        
        LDA $9F3C, X : ADC $E2    : STA $0D10, Y
        LDA $E3      : ADC.b #$00 : STA $0D30, Y
    
    .set_velocity
    
        TYX
        
        LDA.b #$20 : JSR Sprite_ApplySpeedTowardsPlayer
        
        PLX
    
    ; *$3284C ALTERNATE ENTRY POINT
    shared Chicken_BawkBawk:
    
        LDA.b #$30 : JSL Sound_SetSfx2PanLong
    
    .spawn_failed
    .spawn_delay
    
        RTS
    }

; ==============================================================================
