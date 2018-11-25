
    !head_x_offset = $0DA0
    !head_y_offset = $0DB0

; ==============================================================================

    ; $F4379-$F437E DATA
    pool Sprite_YellowStalfos:
    {
    
    .priority
        db $30, $00, $00, $00, $30, $00
    }

; ==============================================================================

    ; *$F437F-$F43FA JUMP LOCATION
    Sprite_YellowStalfos:
    {
        ; Yellow Stalfos
        
        LDA $0D90, X : BNE .initial_collision_check_complete
        
        LDA.b #$01 : STA $0D50, X
                     STA $0D40, X
        
        JSR Sprite3_CheckTileCollision : BEQ .dont_self_terminate
        
        ; Self terminate if the sprite would fall onto a solid tile.
        STZ $0DD0, X
        
        RTS
    
    .dont_self_terminate
    
        INC $0D90, X
        
        LDA.b #$0A : STA !head_y_offset, X
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        
        LDA.b #$20 : JSL Sound_SetSfx2PanLong
    
    .initial_collision_check_complete
    
        LDY $0D80, X
        
        LDA $0B89, X : ORA .priority, Y : STA $0B89, X
        
        JSR YellowStalfos_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $7EF359 : CMP.b #$03 : BCC .sword_too_weak_to_cause_recoil
        
        JSR Sprite3_CheckIfRecoiling
        
        BRA .run_ai_handler
    
    .sword_too_weak_to_cause_recoil
    
        LDA $0D80, X : CMP.b #$05 : BEQ .neutralized
        
        LDA $0EF0, X : BEQ .not_recoiling
        
        STZ $0EF0, X
        
        ; Stalfos is unable to move after being recoiled...? I think so.
        LDA.b #$05 : STA $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
    
    .neutralized
    .not_recoiling
    .run_ai_handler
    
        LDA.b #$01 : STA $0BA0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw YellowStalfos_Descend
        dw YellowStalfos_FacePlayer
        dw YellowStalfos_PauseThenDetachHead
        dw YellowStalfos_DelayBeforeAscending
        dw YellowStalfos_Ascend
        dw YellowStalfos_Neutralized
    }

; ==============================================================================

    ; *$F43FB-$F4430 JUMP LOCATION
    YellowStalfos_Descend:
    {
        ; Head always faces down during this step.
        LDA.b #$02 : STA $0EB0, X
        
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F80, X : CMP.b #$C0 : BMI .fall_speed_maxed
        
        SUB.b #$03 : STA $0F80, X
    
    .fall_speed_maxed
    
        PLA : EOR $0F70, X : BPL .aloft
        
        LDA $0F70, X : BPL .aloft
        
        INC $0D80, X
        
        STZ $0F70, X
        STZ $0F80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        JSR YellowStalfos_Animate
    
    .aloft
    
        RTS
    }

; ==============================================================================

    ; *$F4431-$F4456 JUMP LOCATION
    YellowStalfos_FacePlayer:
    {
        STZ $0BA0, X
        
        JSR Sprite3_CheckDamage
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0DE0, X
              STA $0EB0, X
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$7F : STA $0DF0, X
    
    .delay
    
    ; *$F444E ALTERNATE ENTRY POINT
    shared YellowStalfos_LowerShields:
    
        ; Disable invulnerability.
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        RTS
    }

; ==============================================================================

    ; $F4457-$F44B6 DATA
    pool YellowStalfos_PauseThenDetachHead:
    {
    
    .animation_states
        db 8, 5, 1, 1, 8, 5, 1, 1
        db 8, 5, 1, 1, 7, 4, 2, 2
        db 7, 4, 2, 2, 7, 4, 2, 2
        db 7, 4, 2, 2, 7, 4, 2, 2
    
    .head_x_offsets
        db $80, $80, $80, $80, $80, $80, $80, $80
        db $80, $80, $80, $80, $00, $00, $00, $00
        db $00, $00, $00, $00, $FF, $00, $01, $00
        db $FF, $00, $01, $00, $00, $00, $00, $00
    
    .head_y_offsets
        db 13, 13, 13, 13, 13, 13, 13, 13
        db 13, 13, 13, 13, 13, 13, 13, 13
        db 13, 12, 11, 10, 10, 10, 10, 10
        db 10, 10, 10, 10, 10, 10, 10, 10
    }

; ==============================================================================

    ; *$F44B7-$F44F6 JUMP LOCATION
    YellowStalfos_PauseThenDetachHead:
    {
        STZ $0BA0, X
        
        JSR Sprite3_CheckDamage
        
        LDA $0DF0, X : BNE .delay_ai_state_change
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        RTS
    
    .delay_ai_state_change
    
        CMP.b #$30 : BNE .anodetach_head
        
        PHA
        
        JSR YellowStalfos_DetachHead
        
        PLA
    
    .anodetach_head
    
        LSR #2 : AND.b #$FC : ORA $0DE0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0DF0, X : LSR #2 : TAY
        
        LDA .head_x_offsets, Y : STA !head_x_offset, X
        
        LDA .head_y_offsets, Y : STA !head_y_offset, X
        
        JMP YellowStalfos_LowerShields
    }

; ==============================================================================

    ; $F44F7-$F44FA DATA
    pool YellowStalfos_DelayBeforeAscending:
    {
    
    .animation_states
        db 6, 3, 1, 1
    }

; ==============================================================================

    ; *$F44FB-$F4514 JUMP LOCATION
    YellowStalfos_DelayBeforeAscending:
    {
        STZ $0BA0, X
        
        JSR Sprite3_CheckDamage
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
    
    .delay
    
    ; *$F4509 ALTERNATE ENTRY POINT
    shared YellowStalfos_Animate:
    
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        JMP YellowStalfos_LowerShields
    }

; ==============================================================================

    ; *$F4515-$F453E JUMP LOCATION
    YellowStalfos_Ascend:
    {
        STZ $0DC0, X
        
        LDA.b #$02 : STA $0EB0, X
        
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F80, X : CMP.b #$40 : BPL .ascend_speed_maxed
        
        INC #2 : STA $0F80, X
    
    .ascend_speed_maxed
    
        PLA : EOR $0F70, X : BPL .dont_self_terminate
        
        LDA $0F70, X : BMI .dont_self_terminate
        
        ; Only when the stalfos rises high enough does it terminate.
        STZ $0DD0, X
    
    .dont_self_terminate
    
        RTS
    }

; ==============================================================================

    ; $F453F-$F455E DATA
    YellowStalfos_Neutralized:
    {
    
    .animation_states
        db  1,  1,  1,  9, 10, 10, 10, 10
        db 10, 10, 10, 10, 10, 10, 10,  9
    
    .head_y_offsets
        db 10, 10, 10,  7,  0,  0,  0,  0
        db  0,  0,  0,  0,  0,  0,  0,  7
    }

; ==============================================================================

    ; *$F455F-$F457F JUMP LOCATION
	YellowStalfos_Neutralized:
    {
        STZ $0BA0, X
        
        JSL Sprite_CheckDamageFromPlayerLong
        
        LDA $0DF0, X : BNE .delay
        
        DEC $0D80, X
    
    .delay
    
        LSR #4 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA .head_y_offsets, Y : STA !head_y_offset, X
        
        RTS
    }

; ==============================================================================

    ; *$F4580-$F45A4 LOCAL
    YellowStalfos_DetachHead:
    {
        ; \note One of those rare occasions where the sprite id of the spawned
        ; is different from that of the parent, as far as sprite code goes.
        ; Usually there's some variable that differentiates them and they
        ; use the same id. Refreshing.
        LDA.b #$02 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$0D : STA $0F70, Y
        
        PHX
        
        TYX
        
        LDA.b #$10 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        PLX
        
        LDA.b #$FF : STA $0DF0, Y
        
        LDA.b #$20 : STA $0E00, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $F45A5-$F4654 DATA
    pool YellowStalfos_Draw:
    {
    
    .oam_groups
        dw 0, 0 : db $0A, $00, $00, $02
        dw 0, 0 : db $0A, $00, $00, $02
        
        dw 0, 0 : db $0C, $00, $00, $02
        dw 0, 0 : db $0C, $00, $00, $02
        
        dw 0, 0 : db $2C, $00, $00, $02
        dw 0, 0 : db $2C, $00, $00, $02
        
        dw 5, 5 : db $2E, $00, $00, $00
        dw 0, 0 : db $24, $00, $00, $02
        
        dw 4, 1 : db $3E, $00, $00, $00
        dw 0, 0 : db $24, $00, $00, $02
        
        dw 0, 0 : db $0E, $00, $00, $02
        dw 0, 0 : db $0E, $00, $00, $02
        
        dw 3, 5 : db $2E, $40, $00, $00
        dw 0, 0 : db $24, $40, $00, $02
        
        dw 4, 1 : db $3E, $40, $00, $00
        dw 0, 0 : db $24, $40, $00, $02
        
        dw 0, 0 : db $0E, $40, $00, $02
        dw 0, 0 : db $0E, $40, $00, $02
        
        dw 0, 0 : db $2A, $00, $00, $02
        dw 0, 0 : db $2A, $00, $00, $02
        
        dw 0, 0 : db $2A, $00, $00, $02
        dw 0, 0 : db $2A, $00, $00, $02
    }

; ==============================================================================

    ; *$F4655-$F4691 LOCAL
    YellowStalfos_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite3_DrawMultiple
        
        REP #$20
        
        LDA $90 : SUB.w #$0004 : STA $90
        
        DEC $92
        
        SEP #$20
        
        LDA $0F00, X : BNE .anodraw_shadow
        
        JSR YellowStalfos_DrawHead
        JSL Sprite_DrawShadowLong
    
    .anodraw_shadow
    
        RTS
    }

; ==============================================================================

    ; $F4692-$F4699 DATA
    pool YellowStalfos_DrawHead:
    {
    
    .chr
        db $02, $02, $00, $04
    
    .properties
        db $40, $00, $00, $00
    }

; ==============================================================================

    ; *$F469A-$F46FF LOCAL
    YellowStalfos_DrawHead:
    {
        LDA $0DC0, X : CMP.b #$0A : BEQ .return
        
        ; This constant means don't draw the head this frame.
        LDA !head_x_offset, X : STZ $0D : CMP.b #$80 : BEQ .return
        
        STA $0C : CMP.b #$00 : BPL .sign_extend
        
        DEC $0D
    
    .sign_extend
    
        LDA !head_y_offset, X : STA $0A
                                STZ $0B
        
        LDY.b #$00
        
        PHX
        
        LDA $0EB0, X : TAX
        
        REP #$20
        
        LDA $00 : ADD $0C : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : SUB $0A : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_y
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_y
    
        SEP #$20
        
        LDA .chr, X        : INY           : STA ($90), Y
        LDA .properties, X : INY : ORA $05 : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLX
    
    .return
    
        RTS
    }

; ==============================================================================
