
; ==============================================================================

    pool Sprite_SpikeRoller:
    ; $28DD8-$28DDD DATA
    {
    
    ; Note that the overlap is intentional, it's a space optimization.
    .x_speeds
        db $F0, $10
    
    .y_speeds
        db $00, $00, $F0, $10
    }

; ==============================================================================

    ; *$28DDE-$28E20 JUMP LOCATION
    Sprite_SpikeRoller:
    {
        ; These things are surprisingly simple...
        
        LDA $0DE0, X : AND.b #$02 : STA $00
        
        ; Animation logic
        LDA $0E80, X : LSR A : AND.b #$01 : ORA $00 : STA $0DC0, X
        
        JSR SpikeRoller_Draw
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE .dont_change_direction
        
        LDA.b #$70 : STA $0DF0, X
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
    
    .dont_change_direction
    
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite2_Move
        
        ; Step the animation counter
        INC $0E80, X
        
        RTS
    }

; ==============================================================================

    ; $28E21-$28EE2 DATA
    pool SpikeRoller_Draw:
    {
    
    .x_spacing
        dw 0,  0,  0,  0,  0,  0,  0,   0
        dw 0,  0,  0,  0,  0,  0,  0,   0
        dw 0, 16, 32, 48, 64, 80, 96, 112
        dw 0, 16, 32, 48, 64, 80, 96, 112
    
    .y_spacing
        dw 0, 16, 32, 48, 64, 80, 96, 112
        dw 0, 16, 32, 48, 64, 80, 96, 112
        dw 0,  0,  0,  0,  0,  0,  0,   0
        dw 0,  0,  0,  0,  0,  0,  0,   0
    
    .chr
        db $8E, $9E, $9E, $9E, $9E, $9E, $9E, $8E
        db $8E, $9E, $9E, $9E, $9E, $9E, $9E, $8E
        db $88, $89, $89, $89, $89, $89, $89, $88
        db $88, $89, $89, $89, $89, $89, $89, $88
    
    .vh_flip
        db $00, $00, $00, $80, $00, $00, $00, $80
        db $40, $40, $40, $C0, $40, $40, $40, $C0
    
    .num_subsprites
        db 3, 7
    }

; ==============================================================================

    ; *$28EE3-$28F53 LOCAL
    SpikeRoller_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL #3 : STA $06 : TAY
        
        LDA .chr, Y : STA $08
        
        PHX
        
        ; Appears that this is the size selector for the spike roller.
        LDY $0D80, X
        
        LDX .num_subsprites, Y
        
        LDY.b #$00
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_spacing, X       : STA ($90), Y
                                             AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_spacing, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        ; After the first segment, the chr progession is specified by a table.
        LDA $08 : BNE .use_initial_segment_chr
        
        LDA .chr, X
    
    .use_initial_segment_chr
    
        STZ $08
        
        INY : STA ($90), Y
        
        LDA .vh_flip, X : ORA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
        
        RTS
    }

; ==============================================================================
