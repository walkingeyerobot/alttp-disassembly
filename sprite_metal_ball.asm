
; ==============================================================================

    ; *$2B648-$2B687 JUMP LOCATION
    Sprite_MetalBall:
    {
        ; Metal Balls in Eastern Palace (needs official name)
        
        LDA $0D80, X : BNE .is_larger_ball
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        BRA .moving_on
    
    .is_larger_ball
    
        JSR MetalBall_Draw
    
    .moving_on
    
        JSR Sprite2_CheckIfActive
        
        INC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$01 : STA $0DC0, X
        
        JSR Sprite2_Move
        
        LDA $0DF0, X : BEQ .termination_timer_not_running
        DEC A        : BNE .dont_self_terminate
        
        STZ $0DD0, X
    
    .dont_self_terminate
    
        RTS
    
    .termination_timer_not_runningma
    
        JSR Sprite2_CheckDamage
        
        LDA $0E10, X : BNE .dont_start_timer
        
        JSR Sprite2_CheckTileCollision : BEQ .dont_start_timer
        
        LDA.b #$10 : STA $0DF0, X
    
    .dont_start_timer
    
        RTS
    }

; ==============================================================================

    ; $2B688-$2B6A3 DATA
    pool MetalBall_DrawLargerVariety:
    {
    
    .x_offsets
        dw -8,  8, -8,  8
    
    .y_offsets
        dw -8, -8,  8,  8
    
    .chr
        db $84, $88, $88, $88
        db $86, $88, $88, $88
    
    .vh_flip
        db $00, $00, $C0, $80
    }

; ==============================================================================

    ; *$2B6A4-$2B702 LOCAL
    MetalBall_DrawLargerVariety:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL #2 : STA $06
        
        PHX
        
        LDX.b #$03
    
    .next_subsprite
    
        PHX
        
        PHX : TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLA : ADD $06 : TAX
        
        LDA .properties, X : INY : STA ($90), Y
        
        PLX
        
        LDA .vh_flip, X : INY : ORA $05 : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $0F : ORA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_subsprite
        
        PLX
        
        RTS
    }

; ==============================================================================
