
; ==============================================================================

    ; $31C20-$31C23 DATA
    pool Sprite_SnapDragon:
    {
    
    .animation_state_bases
        db 4, 0, 6, 2
    }

; ==============================================================================

    ; *$31C24-$31C4A JUMP LOCATION
    Sprite_SnapDragon:
    {
        LDY $0DE0, X
        
        LDA $0DA0, X : ADD .animation_state_bases, Y : STA $0DC0, X
        
        JSR SnapDragon_Draw
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        STZ $0DA0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw SnapDragon_Resting
        dw SnapDragon_Attack
    }

; ==============================================================================

    ; $31C4B-$31C5A DATA
    pool SnapDragon_Attack:
    {
    
    .x_speeds
        db  8,  -8,   8,  -8
        db 16, -16,  16, -16
    
    .y_speeds
        db  8,   8,  -8,  -8
        db 16,  16, -16, -16
    }
    
; ==============================================================================

    ; $31C5B-$31C5E DATA
    pool SnapDragon_Resting:
    {
    
    .timers
        db $20, $30, $40, $50
    }

; ==============================================================================

    ; *$31C5F-$31CA8 JUMP LOCATION
    SnapDragon_Resting:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$0C : LSR #2 : TAY
        
        LDA .timers, Y : STA $0DF0, X
        
        DEC $0D90, X : BPL .pick_random_direction
        
        LDA.b #$03 : STA $0D90, X
        
        LDA.b #$60 : STA $0DF0, X
        
        INC $0DB0, X
        
        JSR Sprite_IsBelowPlayer
        
        TYA : ASL A : STA $00
        
        JSR Sprite_IsToRightOfPlayer
        
        TYA : ORA $00
        
        BRA .set_direction
    
    .pick_random_direction
    
        JSL GetRandomInt : AND.b #$03
    
    .set_direction
    
        STA $0DE0, X
        
        RTS
    
    .delay
    
        AND.b #$18 : BEQ .dont_use_alternate_animation_state
        
        INC $0DA0, X
    
    .dont_use_alternate_animation_state
    
        RTS
    }

; ==============================================================================

    ; *$31CA9-$31D01 JUMP LOCATION
    SnapDragon_Attack:
    {
        ; Always has mouth open while in this state?
        INC $0DA0, X
        
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        LDA $0DE0, X : EOR.b #$03 : STA $0DE0, X
    
    .no_tile_collision
    
        LDY $0DE0, X
        
        LDA $0DB0, X : BEQ .use_slower_speeds
        
        INY #4
    
    .use_slower_speeds
    
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite_MoveAltitude
        
        LDA $0F80, X : SUB.b #$04 : STA $0F80, X
        
        LDA $0F70, X : BPL .not_grounded
        
        STZ $0F70, X
        
        LDA $0DF0, X : BNE .keep_bouncin_dude
        
        ; When timer expires, it's time to go back to resting.
        STZ $0D80, X
        
        STZ $0DB0, X
        
        LDA.b #$3F : STA $0DF0, X
        
        RTS
    
    .keep_bouncin_dude
    
        LDA.b #$14 : STA $0F80, X
    
    .not_grounded
    
        RTS
    }

; ==============================================================================

    ; $31D02-$31E01 DATA
    pool SnapDragon_Draw:
    {
    
    .oam_groups
        dw  4, -8 : db $8F, $00, $00, $00
        dw 12, -8 : db $9F, $00, $00, $00
        dw -4,  0 : db $8C, $00, $00, $02
        dw  4,  0 : db $8D, $00, $00, $02
        
        dw  4, -8 : db $2B, $00, $00, $00
        dw 12, -8 : db $3B, $00, $00, $00
        dw -4,  0 : db $28, $00, $00, $02
        dw  4,  0 : db $29, $00, $00, $02
        
        dw -4, -8 : db $3C, $00, $00, $00
        dw  4, -8 : db $3D, $00, $00, $00
        dw -4,  0 : db $AA, $00, $00, $02
        dw  4,  0 : db $AB, $00, $00, $02
        
        dw -4, -8 : db $3E, $00, $00, $00
        dw  4, -8 : db $3F, $00, $00, $00
        dw -4,  0 : db $AD, $00, $00, $02
        dw  4,  0 : db $AE, $00, $00, $02
        
        dw -4, -8 : db $9F, $40, $00, $00
        dw  4, -8 : db $8F, $40, $00, $00
        dw -4,  0 : db $8D, $40, $00, $02
        dw  4,  0 : db $8C, $40, $00, $02
        
        dw -4, -8 : db $3B, $40, $00, $00
        dw  4, -8 : db $2B, $40, $00, $00
        dw -4,  0 : db $29, $40, $00, $02
        dw  4,  0 : db $28, $40, $00, $02
        
        dw  4, -8 : db $3D, $40, $00, $00
        dw 12, -8 : db $3C, $40, $00, $00
        dw -4,  0 : db $AB, $40, $00, $02
        dw  4,  0 : db $AA, $40, $00, $02
        
        dw  4, -8 : db $3F, $40, $00, $00
        dw 12, -8 : db $3E, $40, $00, $00
        dw -4,  0 : db $AE, $40, $00, $02
        dw  4,  0 : db $AD, $40, $00, $02
    }

; ==============================================================================

    ; *$31E02-$31E1E LOCAL
    SnapDragon_Draw:
    {
        LDA #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JSL Sprite_DrawMultiple
        
        JMP Sprite_DrawShadow
    }

; ==============================================================================
