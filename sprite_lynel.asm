
; ==============================================================================

    ; *$E866A-$E8689 JUMP LOCATION
    Sprite_Lynel:
    {
        ; Lynel sprite code (Those Centaur looking things on DW Death Mountain)
        
        JSR Lynel_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckIfRecoiling
        
        JSR Sprite4_DirectionToFacePlayer : TYA : STA $0DE0, X
        
        JSR Sprite4_CheckDamage
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Lynel_TargetPlayer
        dw Lynel_ApproachPlayer
        dw Lynel_Attack
    }

; ==============================================================================

    ; $E868A-$E8697 DATA
    pool Lynel_TargetPlayer:
    {
    
    ; \wtf These are out of the usual order... smart compiler or clever grunt?
    .x_offsets_low length 4
        db -96, 96
    
    .y_offsets_high
        db   0,  0, - 1,   0
    
    .x_offsets_high
        db  -1,  0,   0,   0
    
    .y_offsets_low
        db   8,  8, -96, 112
    }

; ==============================================================================

    ; *$E8698-$E86CC JUMP LOCATION
    Lynel_TargetPlayer:
    {
        LDA $0DF0, X : BNE .delay
        
        LDY $0DE0, X
        
        LDA .x_offsets_low,  Y : ADD $22 : STA $0D90, X
        LDA .x_offsets_high, Y : ADC $23 : STA $0DA0, X
        
        LDA .y_offsets_low,  Y : ADD $20 : STA $0DB0, X
        LDA .y_offsets_high, Y : ADC $21 : STA $0E90, X
        
        INC $0D80, X
        
        LDA.b #$50 : STA $0DF0, X
    
    .delay
    
        JMP Lynel_AnimationController
    }

; ==============================================================================

    ; $E86CD-$E86D4 DATA
    pool Lynel_ApproachPlayer:
    {
    
    .animation_states
        db 3, 0, 6, 9, 4, 1, 7, 10
    }

; ==============================================================================

    ; *$E86D5-$E873B JUMP LOCATION
    Lynel_ApproachPlayer:
    {
        LDA $0DF0, X : BEQ .prepare_attack
        
        TXA : EOR $1A : AND.b #$03 : BNE .anoadjust_direction
        
        JSR Sprite4_Load_16bit_AuxCoord
        
        REP #$20
        
        LDA $04 : SUB $0FD8 : ADD.w #$0005 : CMP.w #$000A : BCS .not_in_range
        
        LDA $06 : SUB $0FDA : ADD.w #$0005 : CMP.w #$000A : BCS .not_in_range
    
    .prepare_attack
    
        SEP #$20
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        RTS
    
    .not_in_range
    
        SEP #$20
        
        LDA.b #$18
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
    
    .anoadjust_direction
    
        JSR Sprite4_Move
        
        JSR Sprite4_CheckTileCollision : BNE .prepare_attack
        
        INC $0E80, X
    
    ; *$E872C ALTERNATE ENTRY POINT
    shared Lynel_AnimationController:
    
        LDA $0E80, X : AND.b #$04 : ORA $0DE0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $E873C-$E873F DATA
    pool Lynel_Attack:
    {
    
    .animation_states
        db $05, $02, $08, $0A
    }

; ==============================================================================

    ; *$E8740-$E8777 JUMP LOCATION
    Lynel_Attack:
    {
        LDA $0DF0, X : BNE .delay
        
        JSL GetRandomInt : AND.b #$0F : ADC.b #$10 : STA $0DF0, X
        
        STZ $0D80, X
        
        RTS
    
    .delay
    
        CMP.b #$10 : BNE .anospawn_projectile
        
        JSL Sprite_SpawnFirePhlegm : BMI .spawn_failed
        
        LDA $7EF35A : CMP.b #$03 : BEQ .blockable_projectile
        
        LDA.b #$00 : STA $0BE0, Y
    
    .blockable_projectile
    .spawn_failed
    .anospawn_projectile
    
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        JSR Sprite4_CheckTileCollision
        
        RTS
    }

; ==============================================================================

    ; $E8778-$E887F DATA
    pool Lynel_Draw:
    {
    
    .oam_groups
        dw -5,  -5 : db $CC, $00, $00, $02
        dw -4,   0 : db $E4, $00, $00, $02
        dw  4,   0 : db $E5, $00, $00, $02
        
        dw -5, -10 : db $CC, $00, $00, $02
        dw -4,   0 : db $E7, $00, $00, $02
        dw  4,   0 : db $E8, $00, $00, $02
        
        dw -5, -11 : db $C8, $00, $00, $02
        dw -4,   0 : db $E4, $00, $00, $02
        dw  4,   0 : db $E5, $00, $00, $02
        
        dw  5, -11 : db $CC, $40, $00, $02
        dw -4,   0 : db $E5, $40, $00, $02
        dw  4,   0 : db $E4, $40, $00, $02
        
        dw  5, -10 : db $CC, $40, $00, $02
        dw -4,   0 : db $E8, $40, $00, $02
        dw  4,   0 : db $E7, $40, $00, $02
        
        dw  5, -11 : db $C8, $40, $00, $02
        dw -4,   0 : db $E8, $40, $00, $02
        dw  4,   0 : db $E7, $40, $00, $02
        
        dw  0,  -9 : db $CE, $00, $00, $02
        dw -4,   0 : db $EA, $00, $00, $02
        dw  4,   0 : db $EB, $00, $00, $02
        
        dw  0,  -9 : db $CE, $00, $00, $02
        dw -4,   0 : db $EB, $40, $00, $02
        dw  4,   0 : db $EA, $40, $00, $02
        
        dw  0,  -9 : db $CA, $00, $00, $02
        dw -4,   0 : db $EB, $00, $00, $02
        dw  4,   0 : db $EB, $40, $00, $02
        
        dw  0, -14 : db $C6, $00, $00, $02
        dw -4,   0 : db $ED, $00, $00, $02
        dw  4,   0 : db $EE, $00, $00, $02
        
        dw  0, -14 : db $C6, $00, $00, $02
        dw -4,   0 : db $EE, $40, $00, $02
        dw  4,   0 : db $ED, $40, $00, $02
    }

; ==============================================================================

    ; *$E8880-$E88A0 LOCAL
    Lynel_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #3 : STA $00 : ASL A : ADC $00
        
        ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$03
        
        JSR Sprite4_DrawMultiple
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
