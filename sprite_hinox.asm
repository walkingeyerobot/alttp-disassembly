
; ==============================================================================

    ; *$31F05-$31F2F JUMP LOCATION
    Sprite_Hinox:
    {
        JSR Hinox_Draw
        JSR Sprite_CheckIfActive
        
        LDA $0EA0, X : BEQ .not_recoiling
        
        JSR Hinox_FacePlayer
        
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$30 : STA $0DF0, X
    
    .not_recoiling
    
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Hinox_SelectNextDirection
        dw Hinox_Walk
        dw Hinox_ThrowBomb
    }

; ==============================================================================

    ; $31F30-$31F49 DATA
    pool Hinox_ThrowBomb:
    {
        
    .animation_states
        db 11, 10,  8,  9
        db  7,  5,  1,  3
    
    .x_offsets_low
        db   8,  -8, -13,  13
    
    .x_offsets_high
        db   0,  -1,  -1,   0
    
    .y_offsets_low
        db -11, -11, -16, -16
    
    .x_speeds length 4
        db 24, -24
    
    .y_speeds
        db  0    0,  24, -24
    }

; ==============================================================================

    ; *$31F4A-$31FB5 JUMP LOCATION
    Hinox_ThrowBomb:
    {
        LDA $0DF0, X : BNE .delay_ai_state_reset
        
        STZ $0D80, X
        
        LDA.b #$02 : STA $0DF0, X
        
        RTS
    
    .delay_ai_state_reset
    
        CMP.b #$20 : BNE .anothrow_bomb
        
        LDA.b #$4A : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_TransmuteToEnemyBomb
        
        LDA.b #$40 : STA $0E00, Y
        
        PHX
        
        LDA $0DE0, X : TAX
        
        LDA $00 : ADD .x_offsets_low, X  : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low, X : STA $0D00, Y
        LDA $03 : ADC.b #-1             : STA $0D20, Y
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        LDA.b #$28 : STA $0F80, Y
    
    .spawn_failed
    
        RTS
    
    .anothrow_bomb
    
        LDY $0DE0, X
        
        BCS .dont_use_throwing_animation_states
        
        INY #4
    
    .dont_use_throwing_animation_states
    
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $31FB6-$31FBB DATA
    pool Hinox_SetRandomDirection:
    {
    
    .x_speeds length 4
        db 8, -8
    
    .y_speeds
        db 0,  0, 8, -8
    }

; ==============================================================================

    ; *$31FBC-$31FEE JUMP LOCATION
    Hinox_SelectNextDirection:
    {
        LDA $0DF0, X : BNE Hinox_Delay
        
        JSL GetRandomInt : AND.b #$03 : BNE .change_direction
        
        ; If we got a 0, just throw another bomb while facing the same
        ; direction.
        LDA.b #$02 : STA $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        RTS
    
    .change_direction
    
        INC $0DB0, X
        
        LDA $0DB0, X : CMP.b #$04 : BNE Hinox_SetRandomDirection
        
        STZ $0DB0, X
    
    ; *$31FE1 ALTERNATE ENTRY POINT
    shared Hinox_FacePlayer:
    
        JSR Sprite_DirectionToFacePlayer
        
        TYA
        
        JSR Hinox_SetExplicitDirection
        
        ; Speed this motha up.
        ASL $0D50, X
        
        ASL $0D40, X
        
        RTS
    }

; ==============================================================================

    ; $31FEF-$31FF6 DATA
    pool Hinox_SetRandomDirection:
    {
    
    .directions
        db 2, 3, 3, 2, 0, 1, 1, 0
    }

; ==============================================================================

    ; *$31FF7-$32024 BRANCH LOCATION
    Hinox_SetRandomDirection:
    {
        JSL GetRandomInt : LSR A : LDA $0DE0, X : ROL A : TAY
        
        LDA .directions, Y
    
    ; $32004 ALTERNATE ENTRY POINT
    shared Hinox_SetExplicitDirection:
    
        STA $0DE0, X
        
        JSL GetRandomInt : AND.b #$3F : ADC.b #$60 : STA $0DF0, X
        
        INC $0D80, X
        
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X

    ; *$32024 ALTERNATE ENTRY POINT
    shared Hinox_Delay:

        RTS
    }

; ==============================================================================

    ; $32025-$32028 DATA
    pool Hinox_Walk:
    {
    
    .animation_state_bases
        db 6, 4, 0, 2
    }

; ==============================================================================

    ; *$32029-$32064 JUMP LOCATION
    Hinox_Walk:
    {
        LDA $0DF0, X : BNE .delay_ai_state_reset
    
    .reset_ai_state
    
        LDA.b #$10 : STA $0DF0, X
        
        STZ $0D80, X
        
        RTS
    
    .delay_ai_state_reset
    
        DEC $0D90, X : BPL .delay_animation_counter_tick
        
        LDA.b #$0B : STA $0D90, X
        
        INC $0E80, X
    
    .delay_animation_counter_tick
    
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        BRA .reset_ai_state
    
    .no_tile_collision
    
        LDA $0E80, X : AND.b #$01 : STA $00
        
        LDY $0DE0, X
        
        LDA .animation_state_bases, Y : ADD $00 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $32065-$321F8 DATA
    pool Hinox_Draw:
    {
    
    .oam_groups
        dw   0, -13 : db $00, $06, $00, $02
        dw  -8,  -5 : db $24, $06, $00, $02
        dw   8,  -5 : db $24, $46, $00, $02
        dw   0,   1 : db $06, $06, $00, $02
        
        dw   0, -13 : db $00, $06, $00, $02
        dw  -8,  -5 : db $24, $06, $00, $02
        dw   8,  -5 : db $24, $46, $00, $02
        dw   0,   1 : db $06, $46, $00, $02
        
        dw  -8,  -6 : db $24, $06, $00, $02
        dw   8,  -6 : db $24, $46, $00, $02
        dw   0,   0 : db $06, $06, $00, $02
        dw   0, -13 : db $04, $06, $00, $02
        
        dw  -8,  -6 : db $24, $06, $00, $02
        dw   8,  -6 : db $24, $46, $00, $02
        dw   0,   0 : db $06, $46, $00, $02
        dw   0, -13 : db $04, $06, $00, $02
        
        dw  -3, -13 : db $02, $06, $00, $02
        dw   0,  -8 : db $0C, $06, $00, $02
        dw   0,   0 : db $1C, $06, $00, $02
        
        dw  -3, -12 : db $02, $06, $00, $02
        dw   0,  -8 : db $0E, $06, $00, $02
        dw   0,   0 : db $1E, $06, $00, $02
        
        dw   3, -13 : db $02, $46, $00, $02
        dw   0,  -8 : db $0C, $46, $00, $02
        dw   0,   0 : db $1C, $46, $00, $02
        
        dw   3, -12 : db $02, $46, $00, $02
        dw   0,  -8 : db $0E, $46, $00, $02
        dw   0,   0 : db $1E, $46, $00, $02
        
        dw -13, -16 : db $6E, $05, $00, $02
        dw   0, -13 : db $00, $06, $00, $02
        dw  -8,  -5 : db $20, $06, $00, $02
        dw   8,  -5 : db $24, $46, $00, $02
        dw   0,   1 : db $06, $06, $00, $02
        
        dw  -8,  -5 : db $24, $06, $00, $02
        dw   8,  -5 : db $20, $46, $00, $02
        dw   0,   1 : db $06, $06, $00, $02
        dw   0, -13 : db $04, $06, $00, $02
        dw  13, -16 : db $6E, $05, $00, $02
        
        dw  -8, -11 : db $6E, $05, $00, $02
        dw  -3, -13 : db $02, $06, $00, $02
        dw   0,   0 : db $22, $06, $00, $02
        dw   0,  -8 : db $0C, $06, $00, $02
        
        dw   8, -11 : db $6E, $05, $00, $02
        dw   3, -13 : db $02, $46, $00, $02
        dw   0,   0 : db $22, $46, $00, $02
        dw   0,  -8 : db $0C, $46, $00, $02 
    
    .oam_group_pointers
        dw $A065, $A085, $A0A5, $A0C5, $A0E5, $A0FD, $A115, $A12D
        dw $A145, $A16D, $A195, $A1B5
    
    .num_oam_entries
        db 4, 4, 4, 4, 3, 3, 3, 3
        db 5, 5, 4, 4
    }

; ==============================================================================

    ; *$321F9-$32212 LOCAL
    Hinox_Draw:
    {
        LDA $0DC0, X : PHA
        
        ASL A : TAY
        
        REP #$20
        
        LDA .oam_group_pointers, Y : STA $08
        
        SEP #$20
        
        PLY
        
        LDA .num_oam_entries, Y : JSL Sprite_DrawMultiple
        
        JMP Sprite_DrawShadow
    }

; ==============================================================================
