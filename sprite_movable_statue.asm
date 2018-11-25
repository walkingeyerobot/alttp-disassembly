
; ==============================================================================

    ; $340DA-$340E7 DATA
    pool Sprite_MovableStatue:
    {
    
    .directions
        db 4, 6, 0, 2
    
    .button_masks
        db 1, 2, 4, 8
    
    .x_speeds length 4
        db -16,  16
    
    .y_speeds
        db   0,   0, -16,  16
    }

; ==============================================================================

    ; *$340E8-$341F6 JUMP LOCATION
    Sprite_MovableStatue:
    {
        ; Movable Statue
        
        LDA $0DE0, X : BEQ BRANCH_ALPHA
        
        STZ $0DE0, X
        
        STZ $5E
        
        STZ $48
    
    BRANCH_ALPHA:
    
        LDA $0DF0, X : BEQ BRANCH_BETA
        
        LDA.b #$01 : STA $0DE0, X
        
        LDA.b #$81 : STA $48
        
        LDA.b #$08 : STA $5E
    
    BRANCH_BETA:
    
        JSR MovableStatue_Draw
        JSR Sprite_CheckIfActive
        JSR $C277 ; $34277 IN ROM
        
        STZ $0642
        
        JSR MovableStatue_CheckFullSwitchCovering : BCC BRANCH_GAMMA
        
        LDA.b #$01 : STA $0642
    
    BRANCH_GAMMA:
    
        JSR Sprite_Move
        JSR Sprite_Get_16_bit_Coords
        JSR Sprite_CheckTileCollision
        JSR Sprite_Zero_XY_Velocity
        
        JSR Sprite_CheckDamageToPlayer_same_layer : BCC BRANCH_DELTA
        
        LDA.b #$07 : STA $0DF0, X
        
        JSL Sprite_RepelDashAttackLong
        
        LDA $0E00, X : BNE BRANCH_EPSILON
        
        JSR Sprite_DirectionToFacePlayer
        
        LDA $C0E2, Y : STA $0D50, X
        
        LDA $C0E4, Y : STA $0D40, X
    
    ; *$3414A ALTERNATE ENTRY POINT
    
        LDA $0376 : AND.b #$02 : BNE BRANCH_ZETA
        
        JSL Sprite_NullifyHookshotDrag
    
    BRANCH_ZETA:
    
        LDA $0E70, X : AND.b #$0F : BNE BRANCH_THETA
        
        LDA $0F10, X : BNE BRANCH_THETA
        
        LDA.b #$22 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$08 : STA $0F10, X
    
    BRANCH_THETA:
    
        RTS
    
    BRANCH_EPSILON:
    
        JSL Sprite_NullifyHookshotDrag
        
        RTS
    
    BRANCH_DELTA:
    
        LDA $0DF0, X : BNE BRANCH_IOTA
        
        LDA.b #$0D : STA $0E00, X
    
    BRANCH_IOTA:
    
        REP #$20
        
        LDA $0FD8 : SUB $22 : ADD.w #$0010 : CMP.w #$0023 : BCS BRANCH_KAPPA
        LDA $0FDA : SUB $20 : ADD.w #$000C : CMP.w #$0024 : BCS BRANCH_KAPPA
        
        SEP #$30
        
        JSR Sprite_DirectionToFacePlayer
        
        LDA $2F : CMP .directions, Y : BNE BRANCH_KAPPA
        
        LDA $0372 : BNE BRANCH_KAPPA
        
        ; Seems to be the key to action 6...
        LDA.b #$01 : STA $02FA
        
        LDA.b #$01 : STA $0D90, X
        
        LDA $0376 : AND.b #$02 : BEQ BRANCH_LAMBDA
        
        LDA $F0 : AND .button_masks, Y : BEQ BRANCH_LAMBDA
        
        LDA $30 : ORA $31 : BEQ BRANCH_LAMBDA
        
        TYA : EOR.b #$01 : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JMP $C14A ; $3414A IN ROM
    
    BRANCH_KAPPA:
    
        SEP #$30
        
        LDA $0D90, X : BEQ BRANCH_LAMBDA
        
        STZ $0D90, X
        STZ $5E
        STZ $0376
        STZ $02FA
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_LAMBDA:
    
        RTS
    }

; ==============================================================================

    ; $341F7-$34202 DATA
    pool MovableStatue_CheckFullSwitchCovering:
    {
    
    .y_offsets
        db 3, 12,  3, 12
    
    .x_offsets
        db 3,  3, 12, 12
    
    .special_tiles ; \task split this up into four labels like invoked in
    ; the code.
        db $23, $24, $25, $3B
    }

; ==============================================================================

    ; *$34203-$3424B LOCAL
    MovableStatue_CheckFullSwitchCovering:
    {
        LDY.b #$03
    
    .next_tile
    
        LDA $0D00, X : ADD $C1FB, Y : STA $00
        LDA $0D20, X : ADC.b #$00   : STA $01
       
        LDA $0D10, X : ADD $C1F7, Y : STA $02
        LDA $0D30, X : ADC.b #$00   : STA $03
        
        LDA $0F20, X
        
        PHY
        
        JSL Entity_GetTileAttr
        
        PLY
        
        LDA $0FA5
        
        CMP $C1FF : BEQ .partial_switch_covering
        CMP $C200 : BEQ .partial_switch_covering
        CMP $C201 : BEQ .partial_switch_covering
        CMP $C202 : BNE .failure
    
    .partial_switch_covering
    
        DEY : BPL .next_tile
        
        SEC
        
        RTS
    
    .failure
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; $3424C-$34263 DATA
    pool MovableStatue_Draw:
    {
    
    .oam_groups
        dw 0, -8 : db $C2, $00, $00, $00
        dw 8, -8 : db $C2, $40, $00, $00
        dw 0,  0 : db $C0, $00, $00, $02
    }

; ==============================================================================

    ; *$34264-$34276 LOCAL
    MovableStatue_Draw:
    {
        REP #$20
        
        LDA.w #.oam_groups : STA $08
        
        LDA.w #$0003 : STA $06
        
        SEP #$30
        
        JSL Sprite_DrawMultiple.player_deferred
        
        RTS
    }

; ==============================================================================

    ; *$34277-$342E4 LOCAL
    {
        LDY.b #$0F
    
    BRANCH_BETA:
    
        LDA $0E20, Y : CMP.b #$1C : BEQ BRANCH_ALPHA
          
        CPY $0FA0 : BEQ BRANCH_ALPHA
        
        TYA : EOR $1A : AND.b #$01 : BNE BRANCH_ALPHA
        
        LDA $0DD0, Y : CMP.b #$09 : BCC BRANCH_ALPHA
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        REP #$20
        
        LDA $0FD8 : SUB $04 : ADD.w #$000C : CMP.w #$0018 : BCS BRANCH_ALPHA
        
        LDA $0FDA : SUB $06 : ADD.w #$000C : CMP.w #$0024 : BCS BRANCH_ALPHA
        
        SEP #$20
        
        LDA.b #$04 : STA $0EA0, Y
        
        PHY
        
        LDA.b #$20
        
        JSR Sprite_ProjectSpeedTowardsEntity
        
        PLY
        
        LDA $00 : STA $0F30, Y
        LDA $01 : STA $0F40, Y
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        DEY : BPL BRANCH_BETA
        
        RTS
    }

; ==============================================================================
