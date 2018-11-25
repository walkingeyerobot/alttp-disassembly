
    ; \note Uses a nonstandard direction variable.
    ; 0x00 - right
    ; 0x01 - left
    ; 0x02 - down
    ; 0x03 - up
    !laser_eye_direction = $0DE0
    
    ; \note Laser eyes that have this flag set look closed most of the time.
    ; They appear to open when firing. Without this flag, the laser eye
    ; appears to be open only when *not* firing. Weird variable.
    ; \task Verify the semantics I've described.
    !requires_facing     = $0EB0

; ==============================================================================

    ; *$F2462-$F2487 LOCAL
    Sprite_LaserBeam:
    {
        JSL Sprite_PrepAndDrawSingleSmallLong
        JSR Sprite3_CheckIfActive
        JSR LaserBeam_Draw
        JSR Sprite3_Move
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong
        
        LDA !timer_0, X : BNE .delay
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        STZ $0DD0, X
        
        LDA.b #$26 : JSL Sound_SetSfx3PanLong
        
        RTS
    
    .no_tile_collision
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$F2488-$F24E6 LOCAL
    LaserBeam_Draw:
    {
        PHX : TXY
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        DEC $0FF8 : BPL .no_underflow
        
        LDA.b #$1D : STA $0FF8
    
    .no_underflow
    
        LDX $0FF8
    
    .empty_slot
    
        ; laser garnish...?
        LDA.b #$04 : STA $7FF800, X : STA $0FB4
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$10 : STA $7FF90E, X
        
        LDA $0DC0, Y : STA $7FF9FE, X
        
        TYA : STA $7FF92C, X
        
        LDA $0F20, Y : STA $7FF968, X
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$F24E7-$F24EE LONG
    SpritePrep_LaserEyeLong:
    {
        PHB : PHK : PLB
        
        JSR SpritePrep_LaserEye
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $F24EF-$F24F0 DATA
    pool SpritePrep_LaserEye:
    {
        ; \note This explains why the exact same data was found near the 
        ; sprite prep routine in bank 0x06 (and is unused)
    
    .offsets
        db -8,  8
    }

; ==============================================================================

    ; *$F24F1-$F2540 LOCAL
    SpritePrep_LaserEye:
    {
        LDA $0E20, X : CMP.b #$97 : BCC .horizontal
        
        LDA $0D10, X : ADD.b #$08 : STA $0D10, X
        
        ; Sets the direction to 2 or 3.
        LDA $0E20, X : SUB.b #$95 : STA !laser_eye_direction, X : TAY
        
        LDA $0D10, X : AND.b #$10 : EOR.b #$10 : STA !requires_facing, X
        
        BNE .dont_adjust_y
        
        LDA $0D00, X : ADD .offsets-2, Y : STA $0D00, X
    
    .dont_adjust_y
    
        RTS
    
    .horizontal
    
        LDA $0E20, X : SUB.b #$95 : STA !laser_eye_direction, X : TAY
        
        LDA $0D00, X : AND.b #$10 : STA !requires_facing, X
        
        BNE .dont_adjust_x
        
        LDA $0D10, X : ADD .offsets, Y : STA $0D10, X
    
    .dont_adjust_x
    
        RTS
    }

; ==============================================================================

    ; *$F2541-$F2559 JUMP LOCATION
    Sprite_LaserEye:
    {
        LDA $0D90, X : BEQ .not_beam
        
        JMP Sprite_LaserBeam
    
    .not_beam
    
        JSR LaserEye_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw LaserEye_MonitorFiringZone
        dw LaserEye_FiringBeam
    }

; ==============================================================================

    ; $F255A-$F255D DATA
    pool LaserEye_MonitorFiringZone:
    {
    
    .matching_directions
        db $02, $03, $00, $01
    }

; ==============================================================================

    ; *$F255E-$F25AF JUMP LOCATION
    LaserEye_MonitorFiringZone:
    {
        REP #$20
        
        LDA $20 : SUB $0FDA : STA $0C
        
        LDA $22 : SUB $0FD8 : STA $0E
        
        SEP #$20
        
        LDA $2F : LSR A : LDY !requires_facing, X : CPY.b #$01 : TAY
        
        LDA !laser_eye_direction, X : BCS .ignore_player_direction
        
        CMP .matching_directions, Y : BNE .not_in_zone
    
    .ignore_player_direction
    
        CMP.b #$02 : REP #$20 : BCS .vertically_oriented
        
        LDA $0C
        
        BRA .is_player_in_firing_zone
    
    .vertically_oriented
    
        LDA $0E
    
    .is_player_in_firing_zone
    
        ADD.w #$0010 : CMP.w #$0020 : SEP #$20 : BCS .not_in_zone
        
        LDA.b #$20
        
        LDY !requires_facing, X : BEQ .irrelevant
        
        ; \optimize Loaded value of A is the same regardless.
        LDA.b #$20
    
    .irrelevant
    
        STA !timer_0, X
        
        INC $0D80, X
        
        RTS
    
    .not_in_zone
    
        STZ $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F25B0-$F25C1 DATA
    pool LaserEye_SpawnBeam:
    {
    
    .x_offsets_low length 4
        db  12, -12
    
    .y_offsets_low
        db   4,   4,  12, -12
    
    .x_offsets_high length 4
        db   0,  -1
    
    .y_offsets_high
        db   0,   0,   0,  -1
    
    .x_speeds length 4
        db 112, -112
    
    .y_speeds
        db   0,    0,  112, -112
    }

; ==============================================================================

    ; *$F25C2-$F25D7 JUMP LOCATION
    LaserEye_FiringBeam:
    {
        LDA.b #$01 : STA $0DC0, X
        
        LDA !timer_0, X : BNE .delay
        
        STZ $0D80, X
        
        JSR LaserEye_SpawnBeam
        
        LDA.b #$0C : STA !timer_4, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$F25D8-$F2647 LOCAL
    LaserEye_SpawnBeam:
    {
        LDA.b #$95 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        LDA !laser_eye_direction, X : TAX
        
        AND.b #$02 : LSR A : STA $0DC0, Y
        
        LDA $00 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low,  X : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA.b #$20 : STA $0E40, Y : STA $0D90, Y
        
        LDA.b #$05 : STA $0F50, Y
        
        LDA.b #$48 : STA $0CAA, Y : STA $0BA0, Y
        
        LDA.b #$05 : STA !timer_0, Y
        
        LDA $7EF35A : CMP.b #$03 : BNE .not_blockable
        
        ; \note Again, this pattern... why even bother writing code to
        ; make sprites blockable if you're just going to ... eh... just a bit
        ; annoying is all.
        LDA.b #$20 : STA $0BE0, Y
    
    .not_blockable
    
        PLX
        
        LDA.b #$19 : JSL Sound_SetSfx3PanLong
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $F2648-$F2707 DATA
    pool LaserEye_Draw:
    {
    
    .oam_groups
        dw  8, -4 : db $C8, $40, $00, $00
        dw  8,  4 : db $D8, $40, $00, $00
        dw  8, 12 : db $C8, $C0, $00, $00
        
        dw  8, -4 : db $C9, $40, $00, $00
        dw  8,  4 : db $D9, $40, $00, $00
        dw  8, 12 : db $C9, $C0, $00, $00
        
        dw  0, -4 : db $C8, $00, $00, $00
        dw  0,  4 : db $D8, $00, $00, $00
        dw  0, 12 : db $C8, $80, $00, $00
        
        dw  0, -4 : db $C9, $00, $00, $00
        dw  0,  4 : db $D9, $00, $00, $00
        dw  0, 12 : db $C9, $80, $00, $00
        
        dw -4,  8 : db $D6, $00, $00, $00
        dw  4,  8 : db $D7, $00, $00, $00
        dw 12,  8 : db $D6, $40, $00, $00
        
        dw -4,  8 : db $C6, $00, $00, $00
        dw  4,  8 : db $C7, $00, $00, $00
        dw 12,  8 : db $C6, $40, $00, $00
        
        dw -4,  0 : db $D6, $80, $00, $00
        dw  4,  0 : db $D7, $80, $00, $00
        dw 12,  0 : db $D6, $C0, $00, $00
        
        dw -4,  0 : db $C6, $80, $00, $00
        dw  4,  0 : db $C7, $80, $00, $00
        dw 12,  0 : db $C6, $C0, $00, $00
    }

; ==============================================================================

    ; *$F2708-$F273E LOCAL
    LaserEye_Draw:
    {
        LDA !requires_facing, X : BEQ .open_by_default
        
        LDA.b #$01 : STA $0DC0, X
        
        LDA !timer_4, X : BEQ .closed_when_not_firing
        
        STZ $0DC0, X
    
    .closed_when_not_firing
    .open_by_default
    
        ; Always draw with super priority.
        LDA.b #$30 : STA $0B89, X
        
        LDA.b #$00 : XBA
        
        LDA !laser_eye_direction, X : ASL A : ADC $0DC0, X
        
        REP #$20
        
        ASL #3 : STA $00 : ASL A  : ADC $00 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$03 : JMP Sprite3_DrawMultiple
    }

; ==============================================================================
