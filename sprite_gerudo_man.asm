
; ==============================================================================

    ; *$2B8B3-$2B8DF JUMP LOCATION
    Sprite_GerudoMan:
    {
        LDA $0D80, X : CMP.b #$02 : BCS .draw
        
        ; (Don't draw, just prep)
        JSL Sprite_PrepOamCoordLong
        
        BRA .draw_logic_complete
    
    .draw
    
        JSR GerudoMan_Draw
    
    .draw_logic_complete
    
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D80, X
        
        REP #$30
        
        AND.w #$00FF : ASL A : TAY
        
        ; Hidden table! gah!!!
        LDA $B8E0, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .states
    
        dw GerudoMan_ReturnToOrigin
        dw GerudoMan_AwaitPlayer
        dw GerudoMan_Emerge
        dw GerudoMan_PursuePlayer
        dw GerudoMan_Submerge
    }

; ==============================================================================

    ; $2B8EA-$2B90A JUMP LOCATION
    GerudoMan_ReturnToOrigin:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA $0D90, X : STA $0D10, X
        LDA $0DA0, X : STA $0D30, X
        
        LDA $0DB0, X : STA $0D00, X
        LDA $0EB0, X : STA $0D20, X
        
        INC $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2B90B-$2B93E JUMP LOCATION
    GerudoMan_AwaitPlayer:
    {
        TXA : EOR $1A : AND.b #$07 : BNE .delay
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0030 : CMP.w #$0060 : BCS .not_close
        
        LDA $20 : SUB $0FDA : ADD.w #$0030 : CMP.w #$0060 : BCS .not_close
        
        SEP #$20
        
        INC $0D80, X
        
        LDA.b #$1F : STA $0DF0, X
    
    .not_close
    .delay
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $2B93F-$2B964 JUMP LOCATION
    GerudoMan_Emerge:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$60 : STA $0DF0, X
        
        LDA.b #$10 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        RTS
    
    .delay
    
        LSR #2 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    
    .animation_states
        db $03, $02, $00, $00, $00, $00, $00, $00
    }
    
; ==============================================================================

    ; $2B965-$2B966 DATA
    pool GerudoMan_PursuePlayer:
    {
        db $04, $05
    }
    
; ==============================================================================

    ; $2B967-$2B96B DATA
    pool GerudoMan_Submerge:
    {
        db $00, $01, $02, $03, $03
    }

; ==============================================================================

    ; $2B96C-$2B98E JUMP LOCATION
    GerudoMan_PursuePlayer:
    {
        STZ $0BA0, X
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$08 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #2 : AND.b #$01 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        
        RTS
    }

; ==============================================================================

    ; $2B98F-$2B9A5 JUMP LOCATION
    GerudoMan_Submerge:
    {
        LDA $0DF0, X : BNE .delay
        
        STZ $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR A : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $2B9A6-$2BA23 DATA
    pool GerudoMan_Draw:
    {
    
    .x_offsets
        dw   4,  4,  4
        dw   4,  4,  4
        dw  -8,  8,  8
        dw  -8,  8,  8
        dw -16,  0,  16
        dw -16,  0,  16
        
    .y_offsets
        dw 8, 8, 8
        dw 8, 8, 8
        dw 4, 4, 4
        dw 0, 0, 0
        dw 0, 0, 0
        dw 0, 0, 0
    
    .chr
        db $B8, $B8, $B8
        db $B8, $B8, $B8
        db $A6, $A6, $A6
        db $A6, $A6, $A6
        db $A4, $A2, $A0
        db $A0, $A2, $A4
    
    .vh_flip
        db $00, $00, $00
        db $40, $40, $40
        db $00, $40, $40
        db $00, $40, $40
        db $40, $40, $40
        db $00, $00, $00
    
    .sizes
        db $00, $00, $00
        db $00, $00, $00
        db $02, $02, $02
        db $02, $02, $02
        db $02, $02, $02
        db $02, $02, $02
    }

; ==============================================================================

    ; *$2BA24-$2BA84 LOCAL
    GerudoMan_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL A : ADC $0DC0, X : STA $06
        
        PHX
        
        LDX.b #$02
    
    .next_subsprite
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA .chr, X     : INY           : STA ($90), Y
        LDA .vh_flip, X : INY : ORA $05 : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA .sizes, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
        
        RTS
    }

; ==============================================================================
