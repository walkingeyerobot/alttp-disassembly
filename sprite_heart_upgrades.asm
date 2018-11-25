
; ==============================================================================

    ; $2EEF9-$2EF00 DATA
    pool Sprite_HeartPiece:
    {
    
    .messages_low
        db $58, $55, $56, $57
    
    .messages_high
        db $01, $01, $01, $01
    }

; ==============================================================================

    ; *$2EF01-$2EF08 LONG
    SpritePrep_HeartContainerLong:
    shared SpritePrep_HeartPieceLong:
    {
        ; Sprite Prep for Heart Container (0xEA) / Heart Pieces (0xEB)
        PHB : PHK : PLB
        
        JSR HeartUpdgrade_CheckIfAlreadyObtained
        
        PLB
        
        RTL
    } 

; ==============================================================================

    ; *$2EF09-$2EF3E LOCAL
    HeartUpdgrade_CheckIfAlreadyObtained:
    {
        LDA $1B : BNE .indoors
        
        LDA $8A : CMP.b #$3B : BNE .not_watergate_area
        
        LDA $7EF2BB : AND.b #$20 : BEQ .self_terminate
    
    .not_watergate_area
    
        PHX
        
        LDX $8A
        
        LDA $7EF280, X : AND.b #$40 : BEQ .dont_self_terminate
        
        PLX
    
    .self_terminate
    
        STZ $0DD0, X
        
        RTS
    
    .dont_self_terminate
    
        PLX
        
        RTS
    
    .indoors
    
        LDA $0D30, X : AND.b #$01 : TAY
        
        LDA $0403 : AND HeartUpgrade_IndoorAcquiredMasks, Y : BEQ .dont_self_terminate_2
        
        STZ $0DD0, X
    
    .dont_self_terminate_2
    
        RTS
    }

; ==============================================================================

    ; *$2EF3F-$2EF46 LONG
    Sprite_HeartContainerLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_HeartContainer
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2EF47-$2EFC5 LOCAL
    Sprite_HeartContainer:
    {
        LDA $040C : CMP.b #$1A : BNE .not_in_ganons_tower
        
        STZ $0DD0, X
        
        RTS
    
    .not_in_ganons_tower
    
        LDA $0ED0, X : STA $0BA0, X : BNE .beta
        
        LDA.b #$03
        
        PHX
        
        JSL GetAnimatedSpriteTile.variable
        
        PLX
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        INC $0ED0, X
    
    .beta
    
        LDA $048E : CMP.b #$06 : BNE .dont_draw_water_ripple
        
        LDA $0F70, X : BNE .dont_draw_water_ripple
        
        JSL Sprite_AutoIncDrawWaterRippleLong
    
    .dont_draw_water_ripple
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        
        DEC $0F80, X : DEC $0F80, X
        
        JSR Sprite2_MoveAltitude
        
        LDA $0F70, X : BPL .delta
        
        STZ $0F70, X
        
        LDA $0F80, X : EOR.b #$FF : INC A : LSR #2 : STA $0F80, X
        
        LDA $048E : CMP.b #$06 : BNE .delta
        
        LDA $0E30, X : BNE .delta
        
        LDA $0E40, X : ADD.b #$02 : STA $0E40, X
        
        INC $0E30, X
        
        JSL Sprite_SpawnWaterSplashLong
    
    .delta
    
        JSL Sprite_CheckIfPlayerPreoccupied : BCC .epsilon
        
        RTS
    
    .epsilon
    
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCS HeartContainer_Grant
        
        RTS
    }

; ==============================================================================

    ; *$2EFC6-$2EFDB BRANCH LOCATION
    HeartContainer_GrantFromSprite:
    {
        PHX
        
        ; \item
        LDA.b #$02 : STA $02E9
        
        LDY.b #$3E
        
        JSL Link_ReceiveItem
        
        PLX
        
        LDA $0403 : ORA.b #$80 : STA $0403
        
        RTS
    }

; ==============================================================================

    ; *$2EFDC-$2F005 BRANCH LOCATION
    HeartContainer_Grant:
    {
        STZ $0DD0, X
        
        LDA $0D90, X : BNE HeartContainer_GrantFromSprite
        
        PHX
        
        JSL Player_HaltDashAttackLong
        
        LDY.b #$26
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        PLX
        
        ; \item
        LDA $1B : BNE HeartUpgrade_SetIndoorAcquiredFlag
    
    ; *$2EFF7 ALTERNATE ENTRY POINT
    shared HeartUpgrade_SetOutdoorAcquiredFlag:
    
        PHX
        
        LDX $8A
        
        LDA $7EF280, X : ORA.b #$40 : STA $7EF280, X
        
        PLX
        
        RTS
    }


; ==============================================================================

    ; $2F006-$2F007 DATA
    HeartUpgrade_IndoorAcquiredMasks:
    {
        db $40, $20
    }

; ==============================================================================

    ; *$2F008-$2F017 BRANCH LOCATION
    HeartUpgrade_SetIndoorAcquiredFlag:
    {
        LDA $0D30, X : AND.b #$01 : TAY
        
        LDA $0403 : ORA HeartUpgrade_IndoorAcquiredMasks, Y : STA $0403
        
        RTS
    }

; ==============================================================================

    ; *$2F018-$2F01F LONG
    Sprite_HeartPieceLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_HeartPiece
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2F020-$2F0CC LOCAL
    Sprite_HeartPiece:
    {
        LDA $0D80, X : BNE .skip_acquisition_check
        
        INC $0D80, X
        
        JSR HeartUpdgrade_CheckIfAlreadyObtained
        
        LDA $0DD0, X : BEQ .return
    
    .check_acquisition_check
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .return
        
        JSR Sprite2_CheckTileCollision
        
        LDA $0E70, X : AND.b #$03 : BEQ .no_horiz_tile_collision
        
        ; \tcrf (verified)
        ; Curious, I didn't think that heart pieces and containers
        ; ever were in a position to move left or right.
        ; After testing, it was apparent that if one sets the vertical velocity,
        ; nothing will attempt to stop the heart piece from moving. Also, it
        ; seemed that moving the heart piece too fast in the horizontal
        ; directions could get it stuck in walls. Not exactly Newtonian physics
        ; here I guess...
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
    
    .no_horiz_tile_collision
    
        DEC $0F80, X
        
        JSR Sprite2_MoveAltitude
        JSR Sprite2_Move
        
        LDA $0F70, X : BPL .no_bounce
        
        STZ $0F70, X
        
        LDA $0F80, X : EOR.b #$FF : AND.b #$F8 : LSR A : STA $0F80, X
        
        LDA $0D50, X : BEQ .no_bounce
        
        CMP.b #$7F : ROR A : STA $0D50, X : CMP.b #$FF : BNE .no_bounce
        
        INC $0D50, X
    
    .no_bounce
    
        LDA $0F10, X : BNE .return
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCS .had_player_contact
    
    .return
    
        RTS
    
    .had_player_contact
    
        ; increment number of heart pieces acquired
        LDA $7EF36B : INC A : AND.b #$03 : STA $7EF36B : BNE .got_4_piecese
        
        PHX
        
        JSL Player_HaltDashAttackLong
        
        LDY.b #$26
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        PLX
        
        BRA .self_terminate
    
    .got_4_pieces
    
        LDA.b #$2D : JSL Sound_SetSfx3PanLong
        
        LDA $7EF36B : TAY
        
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
    
    .self_terminate
    
        STZ $0DD0, X
        
        LDA $1B : BEQ .outdoors
        
        JMP HeartUpgrade_SetIndoorAcquiredFlag
    
    .outdoors
    
        JMP HeartUpgrade_SetOutdoorAcquiredFlag
    }

; ==============================================================================

