
; ==============================================================================

    ; $2966A-$2967A DATA
    pool Sprite_ZoraAndFireball:
    {
    
    .shield_x_offsets_low
        db $04, $04, $FC, $10
    
    ; note: data segment overlaps with the next one (length = 4)
    ; other segments also overlap, but using the length keyword we've conjured
    ; up, this will indicate to a parser the actual length in bytes of
    ; the array.
    .shield_to_the_side_indices length 4
        db $03, $02
    
    .shield_x_offests_high length 4
        db $00, $00, $FF
    
    .shield_y_offsets_low length 4
        db $00, $10
    
    .shield_hit_box_size_x length 4
        db $08, $08
    
    .shield_hit_box_size_y
        db $04, $04, $08, $08
    }

; ==============================================================================

    ; *$2967B-$29724 JUMP LOCATION
    Sprite_ZoraAndFireball:
    {
        ; Fireball sprite (from Zora or similar)
        
        LDA $0E90, X : BNE Sprite_Fireball
        
        JMP Sprite_Zora
    
    ; \note Only here for informational purposes.
    shared Sprite_Fireball:
    
        STA $0BA0, X
        
        LDA $0DF0, X : BEQ .dont_allocate_oam
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionC
    
    .dont_allocate_oam
    
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite2_CheckIfActive
        JSL ZoraFireball_SpawnTailGarnish
        
        JSL Sprite_CheckDamageToPlayerLong : BCC .no_player_contact
    
    .self_terminate
    
        STZ $0DD0, X
        
        RTS
    
    .no_player_contact
    
        JSR Sprite2_Move
        
        LDA $1B : BEQ .ignore_tile_collision
        
        LDA $0E00, X : BNE .ignore_tile_collision
        
        TXA : EOR $1A : AND.b #$03 : BNE .ignore_tile_collision
        
        JSR Sprite2_CheckTileCollision : BNE .self_terminate
    
    .ignore_tile_collision
    
        ; What we really mean is to ignore *further* player collision detection.
        ; We already checked earlier if there was a collision for this. So
        ; in effect we are explicitly checking for shield collision here.
        LDA $02E0 : ORA $037B : BNE .ignore_shield_collision
        
        LDA $0308 : BMI .ignore_shield_collision
        
        ; Does Link have a level two shield or higher?
        ; Nope... so make him suffer
        LDA $7EF35A : CMP.b #$02 : BCC .ignore_shield_collision
        
        ; Otherwise, the fireball might get blocked by the shield
        ; Are Link and the sprite on the same level?
        ; No... so don’t hurt him.
        LDA $EE : CMP $0F20, X : BNE .ignore_shield_collision
        
        JSL Sprite_SetupHitBoxLong
        
        ; Okay, so normally (bread crumb) you might think a general collision
        ; function would handle this, and indeed there is code for some
        ; sprites that generically handle collisions with shields. However,
        ; this sprite has an unconventional direction variable setup ($0DE0)
        ; and thus it must be duplicated here in a slightly altered fashion.
        
        ; Which direction is Link facing?
        LDA $2F : LSR A : TAY
        
        LDA $3C : BEQ .shield_not_to_the_side
        
        LDA .shield_to_the_side_indices, Y : TAY
    
    .shield_not_to_the_side
    
        LDA $22 : ADD .shield_x_offsets_low, Y  : STA $00
        LDA $23 : ADD .shield_x_offsets_high, Y : STA $08
        
        LDA .shield_hit_box_size_x, Y : STA $02
        
        LDA $20 : ADD .shield_y_offsets_low, Y : STA $01
        LDA $21 : ADC.b #$00    : STA $09
        
        LDA .shield_hit_box_size_y, Y : STA $03
        
        JSL Utility_CheckIfHitBoxesOverlapLong : BCC .no_shield_collision
        
        JSL Sprite_PlaceRupulseSpark.coerce
        
        ; Kill off the sprite.
        STZ $0DD0, X
        
        LDA.b #$06 : JSL Sound_SetSfx2PanLong
    
    .no_shield_collision
    .ignore_shield_collision
    
        RTS
    }

; ==============================================================================

    ; *$29725-$29749 BRANCH LOCATION
    Sprite_Zora:
    {
        LDA $0D80, X : BNE .draw_sprite
        
        JSL Sprite_PrepOamCoordLong
        
        BRA .moving_on
    
    .draw_sprite
    
        JSR Zora_Draw
    
    .moving_on
    
        JSR Sprite2_CheckIfActive
        
        LDA $0D80, X : BEQ Zora_ChooseSurfacingLocation
        DEC A        : BEQ .surfacing
        DEC A        : BEQ .attack
        
        JMP Zora_Submerging
    
    .attack
    
        JMP Zora_Attack
    
    .surfacing
    
        JMP Zora_Surfacing
    }

; ==============================================================================

    ; $2974A-$29759 DATA
    pool Zora_ChooseSurfacingLocation:
    {
    
    .offsets_low
        db $E0, $E8, $F0, $F8, $08, $10, $18, $20
    
    .offsets_high
        db $FF, $FF, $FF, $FF, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$2975A-$297B4 BRANCH LOCATION
    Zora_ChooseSurfacingLocation:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        ; Attempt to find a location for the Zora to spawn at, but it has
        ; to be in deep water. Note that Zora will not follow you, as this
        ; logic indicates that it surfacing point is bounded by its starting
        ; coordinates.
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $0D90, X : ADD .offsets_low, Y  : STA $0D10, X
        LDA $0DA0, X : ADC .offsets_high, Y : STA $0D30, X
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $0DB0, X : ADD .offsets_low, Y  : STA $0D00, X
        LDA $0EB0, X : ADC .offsets_high, Y : STA $0D20, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        JSR Sprite2_CheckTileCollision
        
        LDA $0FA5 : CMP.b #$08 : BNE .not_in_deep_water
        
        LDA.b #$7F : STA $0DF0, X
        
        INC $0D80, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
    
    .not_in_deep_water
    .delay
    
        RTS
    }

; ==============================================================================

    ; $297B5-$297C4 DATA
    pool Zora_Surfacing:
    {
    
    .animation_states
        db $04, $03, $02, $01, $02, $01, $02, $01
        db $02, $01, $02, $01, $02, $01, $00, $00
    }

; ==============================================================================

    ; *$297C5-$297E8 LOCAL
    Zora_Surfacing:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
        
        ; Sprite is no longer impervious.
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $297E9-$297F0 DATA
    pool Zora_Attack:
    {
    
    .animation_states
        db $05, $05, $06, $0A, $06, $05, $05, $05
    }

; ==============================================================================

    ; *$297F1-$29817 LOCAL
    Zora_Attack:
    {
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$17 : STA $0DF0, X
        
        RTS
    
    .delay
    
        CMP.b #$30 : BNE .dont_spawn_fireball
        
        PHA
        
        JSL Sprite_SpawnFireball
        
        PLA
    
    .dont_spawn_fireball
    
        LSR #4 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $29818-$29823 DATA
    pool Zora_Submerging:
    {
    
    .animation_states
        db $0C, $0B, $09, $08, $07, $00, $00, $00
        db $00, $00, $00, $00
    }

; ==============================================================================

    ; *$29824-$2983E LOCAL
    Zora_Submerging:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$80 : STA $0DF0, X
        
        STZ $0DC0, X
        STZ $0D80, X
        
        RTS
    
    .delay
    
        LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2983F-$298F4 DATA
    pool Zora_Draw:
    {
    
    .x_offsets
        dw   4,   4,   0,   0,   0,   0,   0,   0
        dw   0,   0,   0,   0,   0,   0,   0,   0
        dw   0,   0,  -4,  11,   0,   4,  -8,  18
        dw  -8,  18
    
    .y_offsets
        dw   4,   4,   0,   0,   0,   0,   0,  -3
        dw   0,  -3,  -3,  -3,  -3,  -3,  -3,  -3
        dw  -6,  -6,  -8,  -9,  -3,   5, -10, -11
        dw -10, -11
    
    .chr
        db $A8, $A8, $88, $88, $88, $88, $88, $A4
        db $88, $A4, $A4, $A4, $A6, $A6, $A4, $C0
        db $8A, $8A, $AE, $AF, $A6, $8D, $CF, $CF
        db $DF, $DF
    
    .properties
        db $25, $25, $25, $25, $E5, $E5, $25, $20
        db $E5, $20, $20, $20, $20, $20, $20, $24
        db $25, $25, $24, $64, $20, $26, $24, $64
        db $24, $64
    
    .size_bit
        db $00, $00, $02, $02, $02, $02, $02, $02
        db $02, $02, $02, $02, $02, $02, $02, $02
        db $02, $02, $00, $00, $02, $00, $00, $00
        db $00, $00
    }

; ==============================================================================

    ; *$298F5-$2995A LOCAL
    Zora_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL A : STA $06
        
        PHX
        
        LDX.b #$01
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA.b #$0F : STA $0D
        
        LDA .properties, X : BIT $0D : BNE .override_intended_palette
        
        ORA $05
    
    .override_intended_palette
    
        INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA .size_bit, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
        
        RTS
    }

; ==============================================================================
