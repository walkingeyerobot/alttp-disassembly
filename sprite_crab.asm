
; ==============================================================================

    ; $294AF-$294B4 DATA
    pool Sprite_Crab:
    {
    
    .x_speeds
        db $1C, $E4
    
    .y_speeds
        db $00, $00, $0C, $F4
    }

; ==============================================================================

    ; *$294B5-$294FF JUMP LOCATION
    Sprite_Crab:
    {
        JSR Crab_Draw
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        
        JSR Sprite2_CheckTileCollision : BNE .collided
        
        LDA $0DF0, X : BNE .dont_change_direction
    
    .collided
    
        JSL GetRandomInt : AND.b #$3F : ADC.b #$20 : STA $0DF0, X
        
        AND.b #$03 : STA $0DE0, X
    
    .dont_change_direction
    
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        INC $0E80, X : LDA $0E80, X : LSR A
        
        CPY.b #$02 : BCC .moving_horizontally
        
        LSR #2
    
    .moving_horizontally
    
        AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $29500-$2950F DATA
    pool Crab_Draw:
    {
    
    .x_offsets
        dw -8, 8
        
        dw -8, 8
        
    .chr
        db $8E, $8E
        
        db $AE, $AE
    
    .vh_flip
        db $00, $40
        
        db $00, $40
    }

; ==============================================================================

    ; *$29510-$2956C LOCAL
    Crab_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL A : STA $06
        
        PHX
        
        LDX.b #$01
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .alpha
        
        LDA.b #$F0 : STA ($90), Y
    
    .alpha
    
        PLX
        
        LDA .chr, X               : INY : STA ($90), Y
        LDA .vh_flip, X : ORA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
