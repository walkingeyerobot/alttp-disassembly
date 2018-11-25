
; ==============================================================================

    ; \unused(suspected, but not fully confirmed yet)
    ; $D79E6-$D7A0B LONG
    Cukeman_Unused:
    {
        LDY.b #$00
        
        CMP.b #$00 : BPL .sign_extend
        
        DEY
    
    .sign_extend
    
              ADD $0FDA : STA $0FDA
        TYA : ADC $0FDB : STA $0FDB
        
        LDA $0F50, X : PHA
        
        JSL Sprite_Cukeman
        
        PLA : STA $0F50, X
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        RTL
    }

; ==============================================================================

    ; *$D7A0C-$D7A7D LONG
    Sprite_Cukeman:
    {
        LDA $0EB0, X : BEQ .not_transformed
        
        LDA $0DD0, X : CMP.b #$09 : BNE .dont_speak
        
        LDA $11 : ORA $0FC1 : BNE .dont_speak
        
        REP #$20
        
        LDA $0FD8 : SUB $22 : ADD.w #$0018 : CMP.w #$0030 : BCS .dont_speak
        
        LDA $20 : SUB $0FDA : ADD.w #$0020 : CMP.w #$0030 : BCS .dont_speak
        
        SEP #$20
        
        LDA $F6 : BPL .dont_speak
        
        LDA $0E30, X : INC $0E30, X : AND.b #$01
        
        ADD.b #$7A : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
    
    .dont_speak
    
        SEP #$20
        
        PHB : PHK : PLB
        
        LDA $0F50, X : AND.b #$F0 : PHA
        
        ORA.b #$08 : STA $0F50, X
        
        JSR Cukeman_Draw
        
        PLA : ORA.b #$0D : STA $0F50, X
        
        LDA.b #$10 : JSL OAM_AllocateFromRegionA
        
        PLB
        
        RTL
    
    .not_transformed
    
        RTL
    }

; ==============================================================================

    ; $D7A7E-$D7B0D DATA
    pool Cukeman_Draw:
    {
        dw  0,  0 : db $F3, $01, $00, $00
        dw  7,  0 : db $F3, $41, $00, $00
        dw  4,  7 : db $E0, $07, $00, $00
        
        dw -1,  2 : db $F3, $01, $00, $00
        dw  6,  1 : db $F3, $41, $00, $00
        dw  4,  8 : db $E0, $07, $00, $00
        
        dw  1,  1 : db $F3, $01, $00, $00
        dw  8,  2 : db $F3, $41, $00, $00
        dw  4,  8 : db $E0, $07, $00, $00
        
        dw -2,  0 : db $F3, $01, $00, $00
        dw 10,  0 : db $F3, $41, $00, $00
        dw  4,  7 : db $E0, $07, $00, $00
        
        dw  0,  0 : db $F3, $01, $00, $00
        dw  8,  0 : db $F3, $41, $00, $00
        dw  4,  6 : db $E0, $07, $00, $00
        
        dw -5,  0 : db $F3, $01, $00, $00
        dw 16,  0 : db $F3, $41, $00, $00
        dw  4,  8 : db $E0, $07, $00, $00
    }

; ==============================================================================

    ; *$D7B0E-$D7B2B LOCAL
    Cukeman_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #3 : STA $00
        
        ASL A : ADC $00 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$03 : JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================
