
; ==============================================================================

    ; $E8BD1-$E8BD6 DATA
    {
        ; \task Name this routine / pool
        db  20, -18
        db   0,  -1
        db -20, -20
    }

; ==============================================================================

    ; *$E8BD7-$E8BED JUMP LOCATION
    Sprite_FireBat:
    {
        JSR FireBat_Draw
        JSR Sprite4_CheckIfActive
        JSL Sprite_CheckDamageToPlayerLong
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $8C17 ; = $E8C17*
        dw $8C38 ; = $E8C38*
        dw $8C55 ; = $E8C55*
    }

; ==============================================================================

    ; *$E8BEE-$E8C16 LOCAL
    {
        LDY $0DE0
        
        LDA $0B10, X : ADD $8BD1, Y : STA $0D10, X
        LDA $0B20, X : ADC $8BD3, Y : STA $0D30, X
        
        LDA $0B30, X : ADD $8BD5, Y : STA $0D00, X
        LDA $0B40, X : ADC.b #$FF   : STA $0D20, X
        
        RTS
    }

; ==============================================================================

    ; *$E8C17-$E8C2A JUMP LOCATION
    {
        JSR $8BEE   ; $E8BEE IN ROM
        
        LDA $0DF0, X : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        RTS
    
    ; *$E8C23 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        AND.b #$04 : LSR #2 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $E8C2B-$E8C37 DATA
    {
    
    .animation_states
        db 4, 4, 4, 3, 3, 3, 2, 2
        db 2, 4, 5, 6, 5
    }

; ==============================================================================

    ; *$E8C38-$E8C42 JUMP LOCATION
    {
        JSR $8BEE   ; $E8BEE IN ROM
        
        INC $0E80, X : LDA $0E80, X
        
        BRA BRANCH_$E8C23
    }

    ; *$E8C43-$E8C54 LOCAL
    {
        INC $0E80, X : LDA $0E80, X : LSR #2 : AND.b #$03 : TAY
        
        LDA $8C34, Y : STA $0DC0, X
        
        RTS
    }

    ; *$E8C55-$E8C8F JUMP LOCATION
    {
        JSR Sprite4_Move
        
        LDA.b #$40 : STA $0CAA, X
        
        LDA $0E00, X : BEQ BRANCH_ALPHA
        CMP.b #$01   : BEQ BRANCH_BETA
        
        LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA $0DF0, X : BEQ BRANCH_GAMMA
        DEC A        : BNE BRANCH_$E8C23
        
        LDA.b #$23 : STA $0E00, X
        
        BRA BRANCH_E8C23
    
    BRANCH_BETA:
    
        LDA.b #$30
        
        JSL Sprite_ApplySpeedTowardsPlayerLong
        
        LDA.b #$1E : JSL Sound_SetSfx3PanLong
    
    BRANCH_GAMMA:
    
        JSR $8C43   ; $E8C43 IN ROM
        
        BRA BRANCH_E8C43
    }

; ==============================================================================

    ; $E8C90-$E8CA8 DATA
    pool FireBat_Draw:
    {
    
    .x_offsets
        db -8, 8
    
    ; These are laid out this way for a reason. The vh_flip data is in pairs
    ; because the sprite consists of pairs of oam entries.
    .chr
        db $88
        db $88
        db $8A
        db $8C
        db $68
        db $AA
        db $A8
    
    .vh_flip
        db $00, $C0
        db $80, $40
        db $00, $40
        db $00, $40
        db $00, $40
        db $00, $40
        db $00, $40
        
    }

; ==============================================================================

    ; *$E8CA9-$E8D05 LOCAL
    FireBat_Draw:
    {
        JSR Sprite4_PrepOamCoord
        
        LDA $0DC0, X : STA $07
        
        ASL A : STA $06
        
        PHX
        
        LDX.b #$01
    
    .next_oam_entry
    
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        LDX $07
        
        LDA .chr, X : INY : STA ($90), Y
        
        PLA : PHA : ORA $06 : TAX
        
        LDA .vh_flip, X : ORA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================

