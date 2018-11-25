
; ==============================================================================

    ; $35892-$35899 DATA
    pool Sprite_Buzzblob:
    {
    
    .animation_states
        db 0, 1, 0, 2
        
    .buzz_palettes
        db $0A, $02, $08, $02
    }

; ==============================================================================

    ; *$3589A-$358ED JUMP LOCATION
    Sprite_Buzzblob:
    {
        LDA $0E00, X : BEQ .not_buzzing
        
        LSR A : AND.b #$03 : TAY
        
        LDA $0B89, X : AND.b #$F1 : ORA $D896, Y : STA $0B89, X
    
    .not_buzzing
    
        JSL Sprite_Cukeman
        JSR BuzzBlob_Draw
        
        LDA $0E80, X : LSR #3 : AND.b #$03 : TAY
        
        LDA .animation_states, Y
        
        LDY $0E00, X : BEQ .use_nonbuzzing_animation_states
        
        INC #3
    
    .use_nonbuzzing_animation_states
    
        STA $0DC0, X
        
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        
        INC $0E80, X
        
        LDA $0DF0, X : BNE .change_direction_delay
        
        JSR Buzzblob_SelectNewDirection
    
    .change_direction_delay
    
        LDA $0E00, X : BNE .cant_move_when_buzzing
        
        JSR Sprite_Move
    
    .cant_move_when_buzzing
    
        JSR Sprite_CheckTileCollision
        JSR Sprite_WallInducedSpeedInversion
        JMP Sprite_CheckDamage
    }

; ==============================================================================

    ; $358EE-$35905 DATA
    pool Buzzblob_SelectNewDirection:
    {
    
    .x_speeds
        db  3,  2, -2, -3, -2,  2,  0,  0
    
    .y_speeds
        db  0,  2,  2,  0, -2, -2,  0,  0
    
    .timers
        db 48, 48, 48, 48, 48, 48, 64, 64
    }

; ==============================================================================

    ; *$35906-$3591F LOCAL
    Buzzblob_SelectNewDirection:
    {
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA $D8EE, Y : STA $0D50, X
        
        LDA $D8F6, Y : STA $0D40, X
        
        LDA $D8FE, Y : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; $35920-$35952 DATA
    pool Buzzblob_Draw:
    {
    
    .x_offsets
        dw 0, 8, 0
    
    .y_offsets
        dw -8, -8, 0
    
    .chr
        db $F0, $F0, $E1
        db $00, $00, $CE
        db $00, $00, $CE
        db $E3, $E3, $CA
        db $E4, $E5, $CC
        db $E5, $E4, $CC
    
    .properties
        db $00, $40, $00
        db $00, $00, $00
        db $00, $00, $40
        db $00, $40, $00
        db $00, $00, $00
        db $40, $40, $40
    
    .oam_sizes
        db $00, $00, $02
    }

; ==============================================================================

    ; *$35953-$359BF LOCAL
    BuzzBlob_Draw:
    {
        JSR Sprite_PrepOamCoord
        
        PHX
        
        LDA $0DC0, X : ASL A : ADC $0DC0, X : STA $06
        
        LDX.b #$02
    
    .next_oam_entry
    
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX : PHX
        
        TXA : ADD $06 : TAX
        
        INY
        
        LDA .chr, X : STA ($90), Y : BNE .dont_skip_oam_entry
        
        DEY
        
        LDA.b #$F0 : STA ($90), Y
        
        INY
    
    .dont_skip_oam_entry
    
        LDA .properties, X : ORA $05 : INY : STA ($90), Y
        
        PLX
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA .oam_sizes, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_oam_entry
        
        PLX
        
        JMP Sprite_DrawShadow
    }

; ==============================================================================
