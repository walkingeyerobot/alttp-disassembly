
; ==============================================================================

    ; $F297F-$F2981 DATA
    Sprite_Bumper:
    {
    
    .player_recoil_speeds
        db $00, $02, $FE
    }

; ==============================================================================

    ; *$F2982-$F2A4A JUMP LOCATION
    Sprite_Bumper:
    {
        JSR Bumper_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckTileCollision
        
        LDA $55 : BNE .using_magic_cape
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .no_player_collision
        
        JSL Player_HaltDashAttackLong
        
        LDA.b #$20 : STA $0DF0, X
        
        LDA.b #$30 : JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $F0 : LSR #2 : AND.b #$03 : TAY
        
        LDA $00 : ADD .player_recoil_speeds, Y : STA $27
        
        LDA $F0 : AND.b #$03 : TAY
        
        LDA $01 : ADD .player_recoil_speeds, Y : STA $28
        
        LDA.b #$14 : STA $46
        
        PHX
        
        JSL Player_ResetSwimState
        
        PLX
        
        LDA.b #$32 : JSL Sound_SetSfx3PanLong
    
    .no_player_collision
    .using_magic_cape
    
        LDY.b #$0F
    
    .next_sprite
    
        TYA : EOR $1A : AND.b #$03 : ORA $0F70, Y : BNE .no_sprite_collision
        
        LDA $0DD0, Y : CMP.b #$09 : BCC .no_sprite_collision
        
        LDA $0E60, Y : ORA $0F60, Y : AND.b #$40 : BNE .no_sprite_collision
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        REP #$20
        
        LDA $0FD8 : SUB $04 : ADD.w #$0010
        
        CMP.w #$0020 : BCS .no_sprite_collision
        
        LDA $0FDA : SUB $06 : ADD.w #$0010
        
        CMP.w #$0020 : BCS .no_sprite_collision
        
        SEP #$20
        
        LDA.b #$0F : STA $0EA0, Y
        
        PHY
        
        LDA.b #$40
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        PLY
        
        LDA $00 : STA $0F30, Y
        LDA $01 : STA $0F40, Y
        
        LDA #$20 : STA $0DF0, X
        
        LDA.b #$32 : JSL Sound_SetSfx3PanLong
    
    .no_sprite_collision
    
        SEP #$20
        
        DEY : BPL .next_sprite
        
        RTS
    }

; ==============================================================================

    ; $F2A4B-$F2A8A DATA
    pool Bumper_Draw:
    {
    
    .oam_groups
        dw -8, -8 : db $EC, $00, $00, $02
        dw  8, -8 : db $EC, $40, $00, $02
        dw -8,  8 : db $EC, $80, $00, $02
        dw  8,  8 : db $EC, $C0, $00, $02
        
        dw -7, -7 : db $EC, $00, $00, $02
        dw  7, -7 : db $EC, $40, $00, $02
        dw -7,  7 : db $EC, $80, $00, $02
        dw  7,  7 : db $EC, $C0, $00, $02
    }

; ==============================================================================

    ; *$F2A8B-$F2AA6 LOCAL
    Bumper_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DF0, X : LSR A : AND.b #$01 : REP #$20 : ASL #5
        
        ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JMP Sprite3_DrawMultiple
    }

; ==============================================================================
