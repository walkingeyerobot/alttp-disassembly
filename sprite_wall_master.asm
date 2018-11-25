
; ==============================================================================

    ; *$F2EA4-$F2F2A JUMP LOCATION
    Sprite_WallMaster:
    {
        ; Floor master sprite (0x90)
        
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR WallMaster_Draw
        
        LDA $0DD0, X : CMP.b #$09 : BEQ .dont_release_player
        
        STZ $02E4
        STZ $037B
    
    .dont_release_player
    
        JSR Sprite3_CheckIfActive
        
        LDA $0D90, X : BEQ .player_not_ensnared
        
        LDA $0D10, X : STA $22
        LDA $0D30, X : STA $23
        
        LDA $0D00, X : SUB $0F70, X
        
        PHP
        
        ADD.b #$03 : STA $20
        
        LDA $0D20, X : ADC.b #$00
        
        PLP
        
        SBC.b #$00 : STA $21
        
        LDA.b #$01 : STA $02E4
                     STA $037B
        
        STZ $46
        STZ $28
        STZ $27
        STZ $30
        STZ $31
        
        REP #$20
        
        LDA $20 : SUB $E8 : SUB.w #$0010
        
        CMP.w #$0100 : SEP #$20 : BCC .delay_sending_player_to_entrance
        
        STZ $02E4
        STZ $037B
        
        PHX
        
        JSL WallMaster_SendPlayerToLastEntrance
        JSL Init_Player
        
        PLX
        
        RTS
    
    .player_not_ensnared
    
        JSL Sprite_CheckDamageFromPlayerLong
    
    .delay_sending_player_to_entrance
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw WallMaster_Descend
        dw WallMaster_GrabAttempt
        dw $AF82 ; = $F2F82*
    }

; ==============================================================================

    ; *$F2F2B-$F2F58 JUMP LOCATION
    WallMaster_Descend:
    {
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F80, X : CMP.b #$C0 : BMI .descend_speed_maxed
        
        SUB.b #$03 : STA $0F80, X
    
    .descend_speed_maxed
    
        PLA : EOR $0F70, X : BPL .no_z_coord_sign_change
        
        LDA $0F70, X : BPL .aloft
        
        INC $0D80, X
        
        STZ $0F70, X
        STZ $0F80, X
        
        LDA.b #$3F : STA $0DF0, X
    
    .aloft
    .no_z_coord_sign_change
    
        RTS
    }

; ==============================================================================

    ; *$F2F59-$F2F81 JUMP LOCATION
    WallMaster_GrabAttempt:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
    
    .delay
    
        LDY.b #$00
        
        AND.b #$20 : BNE .use_first_animation_state
        
        INY
    
    .use_first_animation_state
    
        TYA : STA $0DC0, X
        
        JSR Sprite3_CheckDamageToPlayer : BCC .didnt_grab_player
        
        LDA.b #$01 : STA $0D90, X
        
        ; Sprite is invincible.
        LDA.b #$40 : STA $0E60, X
        
        LDA.b #$2A : JSL Sound_SetSfx3PanLong
    
    .didnt_grab_player
    
        RTS
    }

; ==============================================================================

    ; *$F2F82-$F2FA3 JUMP LOCATION
    {
        LDA $0F70, X : PHA
        
        JSR Sprite3_MoveAltitude
        
        LDA $0F80, X : CMP.b #$40 : BPL .ascend_speed_maxed
        
        INC #2 : STA $0F80, X
    
    .ascend_speed_maxed
    
        PLA : EOR $0F70, X : BPL .no_z_coord_sign_change
        
        LDA $0F70, X : BMI .hasnt_left_ground_yet
        
        STZ $0DD0, X
    
    .hasnt_left_ground_yet
    .no_z_coord_sign_change
    
        RTS
    }

; ==============================================================================

    ; $F2FA4-$F2FE3 DATA
    pool WallMaster_Draw:
    {
    
    .oam_groups
    
    }

; ==============================================================================

    ; *$F2FE4-$F3001 LOCAL
    WallMaster_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #$AFA4 : STA $08
        
        SEP #$20
        
        LDA.b #$04
        
        JSR Sprite3_DrawMultiple
        JSL Sprite_DrawVariableSizedShadow
        
        RTS
    }

; ==============================================================================

