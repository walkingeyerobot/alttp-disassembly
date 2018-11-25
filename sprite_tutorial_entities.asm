
; ==============================================================================

    ; *$2D53B-$2D542 LONG
    Sprite_TutorialEntitiesLong:
    {
        ; Tutorial Soldier (0x3F) / Evil Barrier (0x40)
        
        PHB : PHK : PLB
        
        JSR Sprite_TutorialEntities
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2D543-$2D547 BRANCH LOCATION
    Sprite_EvilBarrierTrampoline:
    {
        JSL Sprite_EvilBarrierLong
        
        RTS
    }

; ==============================================================================

    ; $2D548-$2D54B DATA
    pool Sprite_TutorialEntities:
    {
    
    .animation_states
        db $02, $01, $00, $03
    }

; ==============================================================================

    ; *$2D54C-$2D5BE LOCAL
    Sprite_TutorialEntities:
    {
        ; check if it's the hyrule castle electric fence
        LDA $0E20, X : CMP.b #$40 : BEQ Sprite_EvilBarrierTrampoline_2
        
        LDY $0DE0, X : PHY
        
        LDA $0E00, X : BEQ .direction_lock_inactive
        
        LDA $B5CB, Y : STA $0DE0, X
    
    .direction_lock_inactive
    
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        ; draw the soldier's sprites
        JSR TutorialSoldier_Draw
        
        PLA : STA $0DE0, X
        
        JSR Sprite2_CheckIfActive ; checks if sprite is inactive (in which case it forces us out of this routine)
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA $040A : CMP.b #$1B : BNE .use_default_tutorial_messages
        
        ; "...I suppose it's only a matter of time before I'm affected, too."
        LDA.b #$B2
        
        LDY $0D00, X : CPY.b #$50 : BEQ .guy_on_rampart
        
        ; "...You're not allowed in the castle, son! Go home..."
        LDA.b #$B3   : CPY.b #$90 : BNE .use_default_tutorial_messages
    
    .guy_on_rampart
    
        LDY.b #$00
        
        JSL Sprite_ShowMessageIfPlayerTouching
        
        BRA .moving_on
    
    .use_default_tutorial_messages
    
        LDA $0B69 : PHA : ADD.b #$0F
        LDY.b #$00
        
        JSL Sprite_ShowMessageIfPlayerTouching
        
        PLA : BCC .message_not_shown
        
        INC A : CMP.b #$07 : BNE .no_message_index_reset
        
        LDA.b #$00
    
    .no_message_index_reset
    .message_not_shown
    
        STA $0B69
    
    .moving_on
    
        JSR Sprite2_CheckDamage
        
        TXA : EOR $1A : AND.b #$1F : BNE .delay_facing
        
        JSR Trooper_FacePlayer
    
    .delay_facing
    
        RTS
    }

; ==============================================================================

    ; $2D5BF-$2D64A DATA
    pool TutorialSoldier_Draw:
    {
    
    .x_offsets
        dw  4,  0, -6, -6,  2,  0,  0, -7
        dw -7, -7,  0,  0, 15, 15, 15,  6
        dw 14, -4,  4,  0
    
    .y_offsets
        dw  0, -10, -4, 12,  12,  0, -9, -11
        dw -3,   5,  0, -9, -11, -3,  5, -11
        dw  5,   0,  0, -9
    
    .chr
        db $46, $40, $00, $28, $29, $4E, $42, $39
        db $2A, $3A, $4E, $42, $39, $2A, $3A, $26
        db $38, $64, $64, $44
    
    .vh_flip
        db $40, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $40, $40, $40, $40, $40, $00
        db $40, $00, $40, $00
    
    .sizes
        db $02, $02, $02, $00, $00, $02, $02, $00
        db $00, $00, $02, $02, $00, $00, $00, $02
        db $00, $02, $02, $02        
    }

; ==============================================================================

    ; *$2D64B-$2D6BB LOCA
    TutorialSoldier_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        ; $06 = ($0DC0, X * 5)
        LDA $0DC0, X : ASL #2 : ADC $0DC0, X : STA $06
        
        PHX
        
        LDX.b #$04
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $D5BF, X : ADD $00       : STA ($90), Y
                                       AND.w #$0100 : STA $0E
        
        LDA $D5E7, X : ADD $02 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_y
        
        ; hide the sprite
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_y
    
        SEP #$20
        
        PLX
        
        LDA .chr, X : INY : STA ($90), Y : CMP.b #$40
        
        LDA .vh_flip, X : ORA $05 : BCS .no_palette_override
        
        AND.b #$F1 : ORA.b #$08
    
    .no_palette_override
    
        INY
        
        STA ($90), Y
        
        PHY
        
        TYA : LSR A : LSR A : TAY
        
        LDA .sizes, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX : LDA.b #$0C
        
        JSL Sprite_DrawShadowLong.variable
        
        RTS
    }

; ==============================================================================

