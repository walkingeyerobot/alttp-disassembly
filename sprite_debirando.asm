
; ==============================================================================

    ; *$2874D-$28761 JUMP LOCATION
    Sprite_Debirando:
    {
        JSR Debirando_Draw
        JSR Sprite2_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Debirando_UnderSand
        dw Debirando_Emerge
        dw Debirando_ShootFireball
        dw Debirando_Submerge
    }

; ==============================================================================

    ; *$28762-$28772 JUMP LOCATION
    Debirando_UnderSand:
    {
        LDA $0DF0, X : STA $0BA0, X : BNE .wait
        
        INC $0D80, X
        
        LDA.b #$1F : STA $0DF0, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; $28773-$28774 DATA
    pool Debirando_Emerge:
    {
    
    .animation_states
        db $01, $00
    }

; ==============================================================================

    ; *$28775-$28791 JUMP LOCATION
    Debirando_Emerge:
    {
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$80 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #4 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$28792-$287C7 JUMP LOCATION
    Debirando_ShootFireball:
    {
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        LDA.b #$1F : STA $0DF0, X
        
        INC $0D80, X
        
        RTS
    
    .delay
    
        ; Blue debirando have $0ED0 set nonzero, so they can't shoot fireballs.
        AND.b #$1F
        ORA $0ED0, X
        ORA $11
        ORA $0F00, X
        ORA $0FC1
        
        BNE .dont_shoot_fireball
        
        JSL Sprite_SpawnFireball
    
    .dont_shoot_fireball
    
        INC $0E80, X
        
        LDA $0E80, X : LSR #3 : AND.b #$01 : ADD.b #$02 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $287C8-$287C9 DATA
    pool Debirando_Submerge:
    {
    
    .animation_states
        db $00, $01
    }

; ==============================================================================

    ; *$287CA-$287E6 JUMP LOCATION
    Debirando_Submerge:
    {
        JSR Sprite2_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        STZ $0D80, X
        
        LDA.b #$DF : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #4 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $287E7-$28856 DATA
    pool Debirando_Draw:
    {
    
    .x_offsets
        dw $0000, $0008, $0000, $0008, $0000, $0000, $0000, $0008
        dw $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    
    .y_offsets
        dw $0002, $0002, $0006, $0006, $FFFE, $FFFE, $0006, $0006
        dw $FFFC, $FFFC, $FFFC, $FFFC, $FFFC, $FFFC, $FFFC, $FFFC
    
    .chr
        db $00, $00, $D8, $D8, $00, $00, $D9, $D9
        db $00, $00, $00, $00, $20, $20, $20, $20
    
    .properties
        db $01, $41, $00, $40, $01, $01, $00, $40
        db $01, $01, $01, $01, $01, $01, $01, $01
    
    .size
        db $00, $00, $00, $00, $02, $02, $00, $00
        db $02, $02, $02, $02, $02, $02, $02, $02
    }

; ==============================================================================

    ; *$28857-$288C4 LOCAL
    Debirando_Draw:
    {
        ; Don't draw if the sprite's hidden.
        LDA $0D80, X : BEQ .return
        
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : ASL #2 : STA $06
        
        PHX
        
        LDX.b #$03
    
    .next_subsprite
    
        PHX : TXA : ADD $06 : PHA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X  : STA ($90), Y : AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA .properties, X : PHA : AND.b #$0F : CMP.b #$01
                             PLA : EOR $05    : BCS .dont_override_palette
        
        AND.b #$F0
    
    .dont_override_palette
    
        INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA $8847, X : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_subsprite
        
        PLX
    
    .return
    
        RTS
    }

; ==============================================================================

