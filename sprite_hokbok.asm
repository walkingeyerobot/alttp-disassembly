    
; ==============================================================================

    ; *$EC64F-$EC699 JUMP LOCATION
    Sprite_Hokbok:
    {
        LDA $0DB0, X : BEQ Hokbok_Main
    
    ; \note Label is purely informative.
    shared Sprite_Ricochet:
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckDamage
        JSR Sprite4_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .no_ground_bounce
        
        LDA.b #$10 : STA $0F80, X
        
        STZ $0F70, X
    
    .no_ground_bounce
    
        JSR Sprite4_BounceFromTileCollision : BEQ .no_tile_collision
        
        LDA.b #$21 : JSL Sound_SetSfx2PanLong
    
    .no_tile_collision
    
        LDA $0ED0, X : CMP.b #$03 : BCC .not_quite_dead
        
        LDA.b #$06 : STA $0DD0, X
        
        LDA.b #$0A : STA $0DF0, X
        
        STZ $0BE0, X
        
        LDA.b #$1E : JSL Sound_SetSfx2PanLong
    
    .not_quite_dead
    
        RTS
    }

; ==============================================================================

    ; \note $0D90, X is the number of segments in addition to the head.
    ; \note $0DA0, X is the spacing between segments. (Fairly certain of this).

    ; $EC69A-$EC718 BRANCH LOCATION
    Hokbok_Main:
    {
        JSR Hokbok_Draw
        JSR Sprite4_CheckIfActive
        
        LDA $0EA0, X : BEQ .dont_remove_segment
        
        LDY $0D90, X : BEQ .dont_remove_segment
        
        CMP.b #$0F : BNE .dont_remove_segment
        
        LDA.b #$06 : STA $0EA0, X
        
        LDA $0F70, X : ADD $0DA0, X : STA $0F70, X
        
        DEC $0D90, X : BNE .dont_reset_head_hp
        
        ; \note Apparently, the sprite's health gets restored to full once
        ; all of the other segments are picked off. This is somewhat analogous
        ; to how the last Armos Knight gets a health refill when they turn red.
        LDA.b #$11 : STA $0E50, X
    
    .dont_reset_head_hp
    
        LDA $0D50, X : BPL .positive_x_speed
        
        SUB.b #$08
    
    .positive_x_speed
    
        ADD.b #$04 : STA $0D50, X
        
        LDA $0D40, X : BPL .positive_y_speed
        
        SUB.b #$08
    
    .positive_y_speed
    
        ADD.b #$04 : STA $0D40, X
        
        ; Spawn a Ricochet sprite since a segment was knocked off of the Hokbok.
        LDA.b #$C7 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$01 : STA $0DB0, Y
                     STA $0E50, Y
        
        LDA $0F40, X : STA $0D50, Y
        
        LDA $0F30, X : STA $0D40, Y
        
        LDA.b #$40 : STA $0CAA, Y
    
    .spawn_failed
    .dont_remove_segment
    
        JSR Sprite4_CheckIfRecoiling
        JSR Sprite4_CheckDamage
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Hokbok_ResetBounceVelocity
        dw Hokbok_Moving
    }

; ==============================================================================

    ; *$EC719-$EC720 DATA
    pool Hokbok_ResetBounceVelocity:
    {
    
    .spacing_amounts
        db $08, $07, $06, $05, $04, $05, $06, $07
    }

; ==============================================================================

    ; *$EC721-$EC737 JUMP LOCATION
    Hokbok_ResetBounceVelocity:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$10 : STA $0F80, X
        
        RTS
    
    .delay
    
        LSR A : TAY
        
        LDA .spacing_amounts, Y : STA $0DA0, X
        
        RTS
    }

; ==============================================================================

    ; *$EC738-$EC777 JUMP LOCATION
    Hokbok_Moving:
    {
        JSR Sprite4_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .no_ground_bounce
        
        STZ $0F70, X
        
        STZ $0D80, X
        
        LDA.b #$0F : STA $0DF0, X
    
    .no_ground_bounce
    
    ; *$EC751 ALTERNATE ENTRY POINT
    shared Sprite4_BounceFromTileCollision:
    
        JSR Sprite4_CheckTileCollision : AND.b #$03 : BEQ .no_horiz_collision
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        INC $0ED0, X
    
    .no_horiz_collision
    
        LDA $0E70, X : AND.b #$0C : BEQ .no_vert_collision
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        INC $0ED0, X
    
    .no_vert_collision
    
        RTS
    }

; ==============================================================================

    ; *$EC778-$EC77C LONG
    Sprite_BounceFromTileCollisionLong:
    {
        JSR Sprite4_BounceFromTileCollision
        
        RTL
    
    .unused
    
        RTS
    }

; ==============================================================================

    ; *$EC77D-$EC7EA LOCAL
    Hokbok_Draw:
    {
        JSR Sprite4_PrepOamCoord
        
        LDA $0DA0, X : STA $06
                       STZ $07
        
        PHX
        
        LDA $0D90, X : TAX
        
        TYA : ADD.b #$0C : TAY
    
    .next_subsprite
    
        REP #$20
        
        LDA $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        INY
        
        LDA $02 : PHA : SUB $06 : STA $02
                  PLA           : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        LDA.b #$A0
        
        CPX.b #$00 : BNE .not_head_segment
        
        LDA.b #$A2
    
    .not_head_segment
    
        PHX
        
        LDX $06 : CPX.b #$07 : BCS .dont_use_squished_alternate
        
        SUB.b #$20
    
    .dont_use_squished_alternate
    
        PLX
        
                  INY : STA ($90), Y
        LDA $05 : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLA : SUB.b #$07 : TAY
        
        DEX : BPL .next_subsprite
        
        PLX
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
