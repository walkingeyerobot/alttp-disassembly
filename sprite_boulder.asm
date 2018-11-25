
    !animation_step_polarity = $0DE0

; ==============================================================================

    ; $ECFC3-$ECFCA DATA
    pool Boulder_Main:
    {
    
    ; \note The second number in the pairs on each line correspond to the
    ; value used if the boulder hit a solid tile on the previous frame.
    .z_speeds
        db  32,  48
    
    .y_speeds
        db   8,  32
    
    .x_speeds
        db  24,  16
        db -24, -16
    }

; ==============================================================================

    ; *$ECFCB-$ED029 JUMP LOCATION
    Sprite_Boulder:
    ; \note Name I gave to the Lanmolas rocks that fly out. 
    ; Sharpnolas ? lol.
    shared Sprite_Shrapnel:
    {
        ; This sprite manifests as a boulder outdoors, and as shrapnel indoors.
        LDA $1B : BEQ Boulder_Main
        
        ; Check if we can draw.
        LDA $0FC6 : CMP.b #$03 : BCS .invalid_gfx_loaded
        
        JSL Sprite_PrepAndDrawSingleSmallLong
    
    .invalid_gfx_loaded
    
        JSR Sprite4_CheckIfActive
        
        LDA $1A : ASL #2 : AND.b #$C0 : ORA.b #$00 : STA $0F50, X
        
        JSR Sprite4_MoveXyz
        
        TXA : EOR $1A : AND.b #$03 : BNE .delay
        
        REP #$20
        
        LDA $0FD8 : SUB $22 : ADD.w #$0004
        
        CMP.w #$0010 : BCS .player_not_close
        
        LDA $0FDA : SUB $20 : ADD.w #$FFFC
        
        CMP.w #$000C : BCS .player_not_close
        
        SEP #$20
        
        JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
    
    .player_not_close
    
        SEP #$20
        
        TXA : EOR $1A : AND.b #$03 : BNE .delay
        
        JSR Sprite4_CheckTileCollision : BEQ .no_tile_collision
        
        STZ $0DD0, X
    
    .no_tile_collision
    .delay
    
        RTS
    }
    
; ==============================================================================

    ; $ED02A-$ED087 BRANCH LOCATION
    Boulder_Main:
    {
        ; Uses super priority for oam.
        LDA.b #$30 : STA $0B89, X
        
        JSR Boulder_Draw
        JSR Sprite4_CheckIfActive
        
        LDA $0E80, X : SUB !animation_step_polarity, X : STA $0E80, X
        
        JSR Sprite4_CheckDamage
        JSR Sprite4_MoveXyz
        
        DEC $0F80, X : DEC $0F80, X
        
        LDA $0F70, X : BPL .aloft
        
        ; Once the boulder hits the ground, we have to select new xyz speeds
        ; for it (in other words, it bounces or tumbles periodically).
        STZ $0F70, X
        
        JSR Sprite4_CheckTileCollision
        
        LDY.b #$00
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        INY
    
    .no_tile_collision
    
        LDA .z_speeds, Y : STA $0F80, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSL GetRandomInt : AND.b #$01 : BEQ .bounce_right
        
        ; (bounce left)
        INY #2
    
    .bounce_right
    
        LDA .x_speeds, Y : STA $0D50, X
        
        ; Choose the next polarity for the animation counter to step (Could
        ; end up the same as previous. It's random.)
        TYA : AND.b #$02 : DEC A : STA !animation_step_polarity, X
        
        LDA.b #$0B : JSL Sound_SetSfx2PanLong
    
    .aloft
    
        RTS
    }

; ==============================================================================

    ; $ED088-$ED107 DATA
    pool Boulder_Draw:
    {
    
    .oam_groups
        dw -8, -8 : db $CC, $01, $00, $02
        dw  8, -8 : db $CE, $01, $00, $02
        dw -8,  8 : db $EC, $01, $00, $02
        dw  8,  8 : db $EE, $01, $00, $02
        
        dw -8, -8 : db $CE, $41, $00, $02
        dw  8, -8 : db $CC, $41, $00, $02
        dw -8,  8 : db $EE, $41, $00, $02
        dw  8,  8 : db $EC, $41, $00, $02
        
        dw -8, -8 : db $EE, $C1, $00, $02
        dw  8, -8 : db $EC, $C1, $00, $02
        dw -8,  8 : db $CE, $C1, $00, $02
        dw  8,  8 : db $CC, $C1, $00, $02
        
        dw -8, -8 : db $EC, $81, $00, $02
        dw  8, -8 : db $EE, $81, $00, $02
        dw -8,  8 : db $CC, $81, $00, $02
        dw  8,  8 : db $CE, $81, $00, $02
    }
    
; ==============================================================================

    ; $ED108-$ED184 DATA
    pool Sprite_DrawLargeShadow:
    {
    
    .oam_groups
        dw -6, 19 : db $6C, $08, $00, $02
        dw  0, 19 : db $6C, $08, $00, $02
        dw  6, 19 : db $6C, $08, $00, $02
        
        dw -5, 19 : db $6C, $08, $00, $02
        dw  0, 19 : db $6C, $08, $00, $02
        dw  5, 19 : db $6C, $08, $00, $02
        
        dw -4, 19 : db $6C, $08, $00, $02
        dw  0, 19 : db $6C, $08, $00, $02
        dw  4, 19 : db $6C, $08, $00, $02
        
        dw -3, 19 : db $6C, $08, $00, $02
        dw  0, 19 : db $6C, $08, $00, $02
        dw  3, 19 : db $6C, $08, $00, $02
        
        dw -2, 19 : db $6C, $08, $00, $02
        dw  0, 19 : db $6C, $08, $00, $02
        dw  2, 19 : db $6C, $08, $00, $02
    
    .multiples_of_24
        db $00, $18, $30, $48, $60
        
    }

; ==============================================================================

    ; *$ED185-$ED1A7 LOCAL
    Boulder_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0E80, X : LSR #3 : AND.b #$03 : REP #$20 : ASL #5
        
        ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$04
        
        JSR Sprite4_DrawMultiple
        JSL Sprite_DrawVariableSizedShadow
        
        RTS
    }

; ==============================================================================

    ; *$ED1A8-$ED1FC LONG
    Sprite_DrawLargeShadow:
    {
        PHB : PHK : PLB
        
        LDY.b #$00 : BRA .dont_use_smallest
    
    ; *$ED1AF ALTERNATE ENTRY POINT
    shared Sprite_DrawVariableSizedShadow:
    
        PHB : PHK : PLB
        
        LDA $0F70, X : LSR #3 : TAY
        
        CPY.b #$04 : BCC .dont_use_smallest
        
        LDY.b #$04
    
    .dont_use_smallest
    
        LDA $0F70, X : STA $0E
                       STZ $0F
        
        LDA .multiples_of_24, Y : STA $00
                                  STZ $01
        
        REP #$20
        
        LDA $0FDA : ADD $0E : STA $0FDA
        
        LDA $90 : ADD.w #$0010 : STA $90
        
        LDA $92 : ADD.w #$0004 : STA $92
        
        LDA.w #(.oam_groups) : ADD.w $00 : STA $08
        
        SEP #$20
        
        LDA.b #$03 : JSR Sprite4_DrawMultiple
        
        ; Since we modified the coordinates of the sprite in order to
        ; draw the shadow, restore them to what they ought to be.
        JSL Sprite_Get_16_bit_CoordsLong
        
        PLB
        
        RTL
    }

; ==============================================================================
