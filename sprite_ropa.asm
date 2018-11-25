
; ==============================================================================

    ; *$31E1F-$31E43 JUMP LOCATION
    Sprite_Ropa:
    {
        JSR Ropa_Draw
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        INC $0E80, X : LDA $0E80, X : LSR #3 : AND.b #$03 : STA $0DC0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Ropa_Stationary
        dw Ropa_Pounce
    }

; ==============================================================================

    ; *$31E44-$31E5C JUMP LOCATION
    Ropa_Stationary:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$10
        
        JSR Sprite_ApplySpeedTowardsPlayer
        
        JSL GetRandomInt : AND.b #$0F : ADC.b #$14 : STA $0F80, X
        
        INC $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$31E5D-$31E84 JUMP LOCATION
    Ropa_Pounce:
    {
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        JSR Sprite_Zero_XY_Velocity
    
    .no_tile_collision
    
        JSR Sprite_MoveAltitude
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .not_grounded
        
        STZ $0F70, X
        
        LDA.b #$30 : STA $0DF0, X
        
        STZ $0D80, X
    
    .not_grounded
    
        RTS
    }

; ==============================================================================

    ; $31E85-$31EE4 DATA
    pool Ropa_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $26, $00, $00, $00
        dw 8, -8 : db $27, $00, $00, $00
        dw 0,  0 : db $08, $00, $00, $02
        
        dw 0, -8 : db $36, $00, $00, $00
        dw 8, -8 : db $37, $00, $00, $00
        dw 0,  0 : db $0A, $00, $00, $02
        
        dw 0, -8 : db $27, $40, $00, $00
        dw 8, -8 : db $26, $40, $00, $00
        dw 0,  0 : db $08, $40, $00, $02
        
        dw 0, -8 : db $37, $40, $00, $00
        dw 8, -8 : db $36, $40, $00, $00
        dw 0,  0 : db $08, $40, $00, $02    
    }

; ==============================================================================

    ; *$31EE5-$31F04 JUMP LOCATION
    Ropa_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X
        
        REP #$20
        
        ASL #3 : STA $00 : ASL A : ADC $00 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$03 : JSL Sprite_DrawMultiple
        
        JMP Sprite_DrawShadow
    }

; ==============================================================================
