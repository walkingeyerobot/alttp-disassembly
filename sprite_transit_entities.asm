
; ==============================================================================

    ; *$F7632-$F76A0 JUMP LOCATION
    Pipe_LocateTransitTile:
    {
        ; Not really certain whether this is necessary <___<.
        LDA.b #$FF : STA $1DE0
        
        LDA $0E20, X : SUB.b #$AE : STA $0DE0, X
    
    ; *$F7640 ALTERNATE ENTRY POINT
    shared SomariaPlatform_LocateTransitTile:
    
    .try_another_tile
    
        ; $F77C2 IN ROM ; Get the tile type the sprite interacted with.
        JSR $F7C2 : STA $0E90, X
        
        SUB.b #$B0 : BCS .is_upper_tile
    
    .not_pipe_tile
    
        LDA $0D10, X : ADD.b #$08 : STA $0D10, X
        LDA $0D30, X : ADC.b #$00 : STA $0D30, X
        
        LDA $0D00, X : ADD.b #$08 : STA $0D00, X
        LDA $0D20, X : ADC.b #$00 : STA $0D20, X
        
        ; \bug This seems to have the potential to crash the game if the pipe
        ; sprite is used in a room it should be used in.
        BRA .try_another_tile
    
    .is_upper_tile
    
        CMP.b #$0F : BCS .not_pipe_tile
        
        ; Reaching this address means that we were able to find a special tile
        ; (0xB0 to 0xBE) to bind to, somewhere in the map.
        LDA $0D10, X : AND.b #$F8 : ADD.b #$04 : STA $0D10, X
        
        LDA $0D00, X : AND.b #$F8 : ADD.b #$04 : STA $0D00, X
        
        LDA $0DE0, X : STA $0EB0, X
        
        JSR $F7AF ; $F77AF IN ROM
        
        INC $0BA0, X
        
        STZ $02F5
        
        LDA.b #$0E : STA $0F10, X
        
        INC $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F76A1-$F76A8 LONG
    Sprite_SomariaPlatformLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_SomariaPlatform
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $F76A9-$F76D3 DATA
    {
    
    .x_speeds
        db $00, $00, $F0, $10
    
    ; $F76AD
    .unused_1
        db $F0, $10, $10
    
    ; $F76B0
    .y_speeds
        db $F0, $10, $00, $00
    
    ; $F76B4
    .unused_2
        db $F0, $10, $F0, $10
    
    ; $F76B8
        db $00, $00, $FF, $00
    
    ; $F76BC
    .unused_3
        db $FF
    
    ; $F76BD
        db $00, $00, $FF, $01
    
        db $FF, $01, $01, $FF, $01, $00, $00, $FF
        db $01, $FF, $01, $FF, $00, $00, $00, $FF
        db $00, $FF, $00
    }

; ==============================================================================

    ; *$F76D4-$F76DE LOCAL
    Sprite_SomariaPlatform:
    {
        ; sprite types 0xED, 0xEF, $F0, and $F1 (cane of somaria platform)
        
        LDA $0DC0, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F6DF ; = $F76DF*
        dw $F709 ; = $F7709*
    }

; ==============================================================================

    ; *$F76DF-$F7708 JUMP LOCATION
    {
        JSR SomariaPlatform_LocateTransitTile
        JSL Sprite_SpawnSuperficialBombBlast
        
        ; x coordinate -= 0x08
        LDA $0D10, Y : SUB.b #$08 : STA $0D10, Y
        LDA $0D30, Y : SBC.b #$00 : STA $0D30, Y
        
        ; y coordinate -= 0x08
        LDA $0D00, Y : SUB.b #$08 : STA $0D00, Y
        LDA $0D20, Y : SBC.b #$00 : STA $0D20, Y
        
        RTS
    }

; ==============================================================================

    ; *$F7709-$F77C1 JUMP LOCATION
    {
        JSR $F860 ; $F7860 IN ROM
        JSR Sprite3_CheckIfActive
        
        LDA $0B7C : ORA $0B7D : ORA $0B7E : ORA $0B7F : BEQ BRANCH_ALPHA
    
    BRANCH_BETA:
    
        JMP $F7A3 ; $F77A3 IN ROM
    
    BRANCH_ALPHA:
    
        LDA $5B : DEC #2 : BPL BRANCH_BETA
        
        JSL Sprite_CheckDamageToPlayerIgnoreLayerLong : BCC BRANCH_GAMMA
        
        LDA.b #$01 : STA $0DB0, X
        
        JSL Player_HaltDashAttackLong
        
        LDA $5D
        
        CMP.b #$13 : BEQ BRANCH_GAMMA
        CMP.b #$03 : BEQ BRANCH_GAMMA
        
        LDA $0D80, X : BNE BRANCH_DELTA
        
        INC $0D90, X
        
        LDA.b #$02 : STA $02F5
        
        LDA $0D90, X : AND.b #$07 : BNE BRANCH_EPSILON
        
        JSR $F7C2 ; $F77C2 IN ROM
        
        CMP $0E90, X : BEQ BRANCH_EPSILON
        
        STA $0E90, X
        
        LDA $0DE0, X : STA $0EB0, X
        
        JSR $F7AF ; $F77AF IN ROM
        JSR $F901 ; $F7901 IN ROM
    
    BRANCH_EPSILON:
    
        LDA $A0 : CMP.b #$24 : BEQ BRANCH_ZETA
        
        LDY $0DE0, X
        
        LDA $F6BD, Y : ADD $0B7C : STA $0B7C
        LDA $F6B8, Y : ADC $0B7D : STA $0B7D
        
        LDA $F6C4, Y : ADD $0B7E : STA $0B7E
        LDA $F6CC, Y : ADC $0B7F : STA $0B7F
        
        JSR Sprite3_Move
        JSR $FB49 ; $F7B49 IN ROM
        
        RTS
    
    BRANCH_ZETA:
    
        JMP $FB34 ; $F7B34 IN ROM
    
    ; *$F77A3 ALTERNATE ENTRY POINT
    BRANCH_GAMMA:
    
        LDA $0DB0, X : BEQ BRANCH_THETA
        
        STZ $02F5
        STZ $0DB0, X
    
    BRANCH_THETA:
    
        RTS
    
    ; *$F77AF ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        JSR $F87D ; $F787D IN ROM
        
        LDY $0DE0, X
        
        LDA $F6A9, Y : STA $0D50, X
        
        LDA $F6B0, Y : STA $0D40, X
        
        RTS
    }

    ; *$F77C2-$F77DF LOCAL
    {
        LDA $0D00, X : STA $00
        LDA $0D20, X : STA $01
        
        LDA $0D10, X : STA $02
        LDA $0D30, X : STA $03
        
        ; Forced to check on bg2 (the main bg).
        LDA.b #$00 : JSL Entity_GetTileAttr
        
        LDA $0FA5
        
        RTS
    }

; ==============================================================================

    ; $F77E0-$F785F DATA
    {
    
    ; \task Name this pool / routine.
    .oam_groups
        dw -16, -16 : db $AC, $00, $00, $02
        dw   0, -16 : db $AC, $40, $00, $02
        dw -16,   0 : db $AC, $80, $00, $02
        dw   0,   0 : db $AC, $C0, $00, $02
        
        dw -13, -13 : db $AC, $00, $00, $02
        dw  -3, -13 : db $AC, $40, $00, $02
        dw -13,  -3 : db $AC, $80, $00, $02
        dw  -3,  -3 : db $AC, $C0, $00, $02
        
        dw -10, -10 : db $AC, $00, $00, $02
        dw  -6, -10 : db $AC, $40, $00, $02
        dw -10,  -6 : db $AC, $80, $00, $02
        dw  -6,  -6 : db $AC, $C0, $00, $02
        
        dw  -8,  -8 : db $AC, $00, $00, $02
        dw  -8,  -8 : db $AC, $40, $00, $02
        dw  -8,  -8 : db $AC, $80, $00, $02
        dw  -8,  -8 : db $AC, $C0, $00, $02
    }

; ==============================================================================

    ; *$F7860-$F787C LOCAL
    {
        LDA.b #$10 : JSL OAM_AllocateFromRegionB
        
        LDA $0F10, X : AND.b #$0C : ASL #3
        
        ADC.b #.oam_groups                 : STA $08
        LDA.b #.oam_groups>>8 : ADC.b #$00 : STA $09
        
        LDA.b #$04 : JMP Sprite3_DrawMultiple
    }

; ==============================================================================

    ; *$F787D-$F78AC LOCAL
    {
        LDA $0E90, X : SUB.b #$B0 : BCS .is_upper_tile
        
        RTS
    
    .is_upper_tile
    
        CMP.b #$0F : BCC .is_transit_tile
        
        RTS
    
    .is_transit_tile
    
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F908 ; = $F7908  ; 0xB0 - (RTS)
        dw $F908 ; = $F7908  ; 0xB1 - (RTS)
        dw $F909 ; = $F7909* ; 0xB2 - Zig zag rising slope
        dw $F912 ; = $F7912* ; 0xB3 - Zig zag falling slope
        dw $F912 ; = $F7912* ; 0xB4 - Zig zag falling slope
        dw $F909 ; = $F7909* ; 0xB5 - Zig zag rising slope
        dw $F91F ; = $F791F* ; 0xB6 - Transit tile allowing direction inversion?
        dw $F946 ; = $F7946* ; 0xB7 - T junction transit tile (can't go up)
        dw $F9A3 ; = $F79A3* ; 0xB8 - T junction transit tile (can't go down)
        dw $FA02 ; = $F7A02* ; 0xB9 - T junction transit tile (can't go left)
        dw $FA61 ; = $F7A61* ; 0xBA - T junction transit tile (can't go right)
        dw $FAC0 ; = $F7AC0* ; 0xBB - Transit tile junction that allows movement in all directions except for the one you came from.
        dw $FAFF ; = $F7AFF* ; 0xBC - Straight transit line junction? Question mark looking. Only allows travel in two colinear directions.
        dw $F908 ; = $F7908* ; 0xBD - (RTS)
        dw $FB3A ; = $F7B3A* ; 0xBE - Endpoint node transit tile
    }

    ; *$F78AD-$F78D6 LOCAL
    {
        LDA $0DE0, X : EOR $0EB0, X : AND.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $0D10, X : AND.b #$F8 : ADD.b #$04 : STA $00
        
        SUB $0D10, X : BEQ BRANCH_ALPHA
        
        STA $0B7C : BPL BRANCH_BETA
        
        LDA.b #$FF : STA $0B7D
    
    BRANCH_BETA:
    
        LDA $00 : STA $0D10, X
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$F78D7-$F7900 LOCAL
    {
        LDA $0DE0, X : EOR $0EB0, X : AND.b #$02 : BEQ BRANCH_ALPHA
        
        LDA $0D00, X : AND.b #$F8 : ADD.b #$04 : STA $00
        
        SUB $0D00, X : BEQ BRANCH_ALPHA
        
        STA $0B7E : BPL BRANCH_BETA
        
        LDA.b #$FF : STA $0B7F
    
    BRANCH_BETA:
    
        LDA $00 : STA $0D00, X
    
    BRANCH_ALPHA:
    
        RTS
    } 

    ; *$F7901-$F7907 LOCAL
    {
        JSR $F8AD ; $F78AD IN ROM
        JSR $F8D7 ; $F78D7 IN ROM
        
        RTS
    }

    ; $F7908-$F7908 JUMP LOCATION
    {
        RTS
    }

    ; *$F7909-$F7911 JUMP LOCATION
    {
        ; zig zag along y = x line. Zig zag rising slope?
        LDA $0DE0, X : EOR.b #$03 : STA $0DE0, X
        
        RTS
    }

    ; *$F7912-$F791A JUMP LOCATION
    {
        ; zig zag along y = -x line. zig zag falling slope?
        LDA $0DE0, X : EOR.b #$02 : STA $0DE0, X
        
        RTS
    }

    ; $F791B-$F791E DATA
    {
        db $04, $08, $01, $02
    }

    ; *$F791F-$F7941 JUMP LOCATION
    {
        ; Transit tile that allows you to invert your direction?
        
        LDA.b #$01 : STA $0D80, X
        
        LDA $4D : BNE BRANCH_ALPHA
        
        LDY $0DE0, X
        
        LDA $F0 : AND $F91B, Y : BEQ BRANCH_ALPHA
        
        STZ $0D80, X
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
    
    BRANCH_ALPHA:
    
        STZ $4B
        
        JMP $FB34 ; $F7B34 IN ROM
    }

; ==============================================================================

    ; $F7942-$F7945 DATA
    {
        db $03, $07, $06, $05    
    }

; ==============================================================================

    ; *$F7946-$F799E JUMP LOCATION
    {
        LDA.b #$01 : STA $0D80, X
        
        LDY $0DE0, X
        
        LDA $F0 : AND $F942, Y : STA $00 : AND.b #$08 : BEQ .always
        
        LDA.b #$00 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .always
    
        LDA $00 : AND.b #$04 : BEQ .no_pressing_down
        
        LDA.b #$01 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_down
    
        LDA $00 : AND.b #$02 : BEQ .not_pressing_left
        
        LDA.b #$02 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_left
    
        LDA $00 : AND.b #$01 : BEQ .not_pressing_right
        
        LDA.b #$03 : STA $0DE0, X
        
        STZ $0D80, X
    
    .not_pressing_right
    
        LDA $0DE0, X : BNE .not_going_up
        
        ; If we are going up, automatically head left once we hit the T
        ; intersection.
        LDA.b #$02 : STA $0DE0, X
    
    .not_going_up
    
        STZ $0D80, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $F799F-$F79A2 DATA
    {
        db $0B, $03, $0A, $09
    }

; ==============================================================================

    ; *$F79A3-$F79FD JUMP LOCATION
    {
        LDA.b #$01 : STA $0D80, X
        
        LDY $0DE0, X
        
        LDA $F0 : AND $F99F, Y : STA $00 : AND.b #$08 : BEQ .not_pressing_up
        
        LDA.b #$00 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_up
    
        LDA $00 : AND.b #$04 : BEQ .always
        
        LDA.b #$01 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .always
    
        LDA $00 : AND.b #$02 : BEQ .not_pressing_left
        
        LDA.b #$02 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_left
    
        LDA $00 : AND.b #$01 : BEQ .not_pressing_right
        
        LDA.b #$03 : STA $0DE0, X
        
        STZ $0D80, X
    
    .not_pressing_right
    
        LDA $0DE0, X : CMP.b #$01 : BNE .not_going_down
        
        ; Automatically choose left as the next direction
        LDA.b #$02 : STA $0DE0, X
    
    .not_going_down
    
        STZ $0D80, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $F79FE-$F7A01 DATA
    {
        db $09, $05, $0C, $0D
    }

; ==============================================================================

    ; *$F7A02-$F7A5C JUMP LOCATION
    {
        LDA.b #$01 : STA $0D80, X
        
        LDY $0DE0, X
        
        LDA $F0 : AND $F9FE, Y : STA $00 : AND.b #$08 : BEQ .not_pressing_up
        
        LDA.b #$00 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_up
    
        LDA $00 : AND.b #$04 : BEQ .not_pressing_up
        
        LDA.b #$01 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_up
    
        LDA $00 : AND.b #$02 : BEQ .always
        
        LDA.b #$02 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .always
    
        LDA $00 : AND.b #$01 : BEQ .not_pressing_right
        
        LDA.b #$03 : STA $0DE0, X
        
        STZ $0D80, X
    
    .not_pressing_right
    
        LDA $0DE0, X : CMP.b #$02 : BNE .not_heading_left
        
        ; Force heading to going up.
        LDA.b #$00 : STA $0DE0, X
    
    .not_going_left
    
        STZ $0D80, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $F7A5D-$F7A60 DATA
    {
        db $0A, $06, $0E, $0C
    }

; ==============================================================================

    ; *$F7A61-$F7ABB JUMP LOCATION
    {
        LDA.b #$01 : STA $0D80, X
        
        LDY $0DE0, X
        
        LDA $F0 : AND $FA5D, Y : STA $00 : AND.b #$08 : BEQ .not_pressing_up
        
        LDA.b #$00 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_up:
    
        LDA $00 : AND.b #$04 : BEQ .not_pressing_down
        
        LDA.b #$01 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_down
    
        LDA $00 : AND.b #$02 : BEQ .not_pressing_left
        
        LDA.b #$02 : STA $0DE0, X
        
        STZ $0D80, X
        
        BRA .return
    
    .not_pressing_left
    
        LDA $00 : AND.b #$01 : BEQ .always
        
        LDA.b #$03 : STA $0DE0, X
        
        STZ $0D80, X
    
    .always
    
        LDA $0DE0, X : CMP.b #$03 : BNE .not_going_right
        
        ; Default heading in reaction to this tile is going up.
        LDA.b #$00 : STA $0DE0, X
    
    .not_going_right
    
        STZ $0D80, X
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $F7ABC-$F7ABF DATA
    {
        db $0B, $07, $0E, $0D
    }

; ==============================================================================

    ; *$F7AC0-$F7AFA JUMP LOCATION
    {
        LDY $0DE0, X
        
        LDA $F0 : AND $FABC, Y : STA $00 : AND.b #$08 : BEQ BRANCH_ALPHA
        
        LDA.b #$00 : STA $0DE0, X
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $00 : AND.b #$04 : BEQ BRANCH_GAMMA
        
        LDA.b #$01 : STA $0DE0, X
        
        BRA BRANCH_BETA
    
    BRANCH_GAMMA:
    
        LDA $00 : AND.b #$02 : BEQ BRANCH_DELTA
        
        LDA.b #$02 : STA $0DE0, X
        
        BRA BRANCH_BETA
    
    BRANCH_DELTA:
    
        LDA $00 : AND.b #$01 : BEQ BRANCH_BETA
        
        LDA.b #$03 : STA $0DE0, X
    
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; $F7AFB-$F7AFE DATA
    {
        db $0C, $0C, $03, $03
    }

; ==============================================================================

    ; *$F7AFF-$F7B39 JUMP LOCATION
    {
        LDA.b #$01 : STA $0D80, X
        
        LDY $0DE0, X
        
        LDA $F0 : AND $FAFB, Y : BEQ .not_pressing_any_directions
        
        STA $00 : AND.b #$08 : BEQ .not_pressing_up
        
        LDA.b #$00 : BRA .set_direction
    
    .not_pressing_up
    
        LDA $00 : AND.b #$04 : BEQ .not_pressing_down
        
        LDA.b #$01 : BRA .set_direction
    
    .not_pressing_down
    
        LDA $00 : AND.b #$02 : BEQ .not_pressing_left
        
        LDA.b #$02 : BRA .set_direction
    
    .not_pressing_left
    
        LDA.b #$03
    
    .set_direction
    
        STA $0DE0, X
        
        STZ $0D80, X
    
    .not_pressing_any_directions
    
    ; *$F7B34 ALTERNATE ENTRY POINT
    
        LDA.b #$01 : STA $02F5
        
        RTS
    }

    ; *$F7B3A-$F7B48 JUMP LOCATION
    {
        STZ $0D80, X
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        STZ $4B
        
        BRA BRANCH_$F7B34
    }

    ; *$F7B49-$F7B77 LOCAL
    {
        REP #$20
        
        LDA $0FD8 : SUB.w #$0008 : CMP $22 : BEQ BRANCH_ALPHA
                                             BPL BRANCH_BETA
        
        DEC $0B7C
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        INC $0B7C
    
    BRANCH_ALPHA:
    
        LDA $0FDA : SUB.w #$0010 : CMP $20 : BEQ BRANCH_GAMMA
                                             BPL BRANCH_DELTA
        
        DEC $0B7E
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        INC $0B7E
    
    BRANCH_GAMMA:
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; \unused
    ; $F7B78-$F7B7D DATA
    pool Unused:
    {
        ; \note Perhaps these wwere speeds to be used for the player moving
        ; through the pipes?
        db $00, $00, $01, $FF, $00, $00
    }

; ==============================================================================

    ; \note The Pipe sprite doesn't use $0D80, X

    ; *$F7B7E-$F7B93 JUMP LOCATION
    Sprite_Pipe:
    {
        JSR Sprite3_CheckIfActive
        
        LDA $0DC0, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Pipe_LocateTransitTile
        dw Pipe_LocateTransitEndpoint
        dw Pipe_WaitForPlayer
        dw Pipe_DrawPlayerInward
        dw Pipe_DragPlayerAlong
        dw $FCD3 ; = $F7CD3*
    }

; ==============================================================================

    ; *$F7B94-$F7BBD JUMP LOCATION
    Pipe_LocateTransitEndpoint:
    {
        ; $F77C2 IN ROM ; Get tile attribute at sprite's current location.
        ; I'm thinking this is the starting tile for the pipe? Or perhaps
        ; represents an endpoint...
        JSR $F7C2 : CMP.b #$BE : BNE .not_the_tile_youre_looking_for
        
        STA $0E90, X
        
        INC $0DC0, X
        
        ; switch direction polarity... I guess so the player can go through it?
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
    
    .not_the_tile_youre_looking_for
    
        CMP $0E90, X : BEQ .beta
        
        STA $0E90, X
    
    .beta
    
        LDA $0DE0, X : STA $0EB0, X
        
        JSR $F7AF ; $F77AF IN ROM
        JSR Sprite3_Move
        
        RTS
    }

; ==============================================================================

    ; *$F7BBE-$F7BEF JUMP LOCATION
    Pipe_WaitForPlayer:
    {
        ; \note The sprite travels along with you (or ahead of you?).
        ; Entering the same pipe twice without taking the return trip results
        ; in a nonfunctional pipe that just behaves as normal empty space.
        ; This was confirmed directly by modifying the player's coordinates in
        ; a memory editor. Clearly this design limitation dictated the layout
        ; of the rooms the pipes appear in.
        LDA $1DE0 : CMP.b #$FF : BNE .cant_enter
        
        JSL Sprite_CheckDamageToPlayerIgnoreLayerLong : BCC .cant_enter
        
        PHX
        
        JSL Player_IsPipeEnterable
        
        PLX
        
        BCS .cant_pass_through
        
        INC $0DC0, X
        
        LDA.b #$04 : STA $0E00, X
        
        JSL Player_ResetState
        
        LDA.b #$01 : STA $02E4 : STA $037B
        
        TXA : STA $1DE0
    
    .cant_enter
    
        RTS
    
    .cant_pass_through
    
        JSR $F508 ; $F7508 IN ROM
        
        RTS
    }

; ==============================================================================

    ; $F7BF0-$F7BF3 DATA
    pool Pipe:
    {
    
    .player_direction
        db $08, $04, $02, $01
    }

; ==============================================================================

    ; *$F7BF4-$F7C12 JUMP LOCATION
    Pipe_DrawPlayerInward:
    {
        LDA $0E00, X : BNE .delay
        
        INC $0DC0, X
        
        ; Makes the player invisible.
        LDA.b #$0C : STA $4B
        
        RTS
    
    .delay
    
        ; Halt the player, but also take care of some of their functions?
        LDA.b #$01 : STA $02E4 : STA $037B
        
        LDY $0DE0, X
        
        LDA Pipe.player_direction, Y
        
        JSR $FCFF ; $F7CFF IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$F7C13-$F7CD2 JUMP LOCATION
    Pipe_DragPlayerAlong:
    {
        LDA.b #$03 : STA $0E80, X
        
        LDA $22 : STA $3F
        LDA $23 : STA $41
        
        LDA $20 : STA $3E
        LDA $21 : STA $40
    
    .lambda
    
        INC $0D90, X
        
        LDA $0D90, X : AND.b #$07 : BNE BRANCH_ALPHA
        
        JSR $F7C2 ; $F77C2 IN ROM
        
        PHA : CMP.b #$B2 : BCC BRANCH_BETA
              CMP.b #$B6 : BCS BRANCH_BETA
        
        LDA.b #$0B : JSL Sound_SetSfx2PanLong
    
    BRANCH_BETA:
    
        PLA : CMP $0E90, X : BEQ BRANCH_ALPHA
        
        STA $0E90, X : CMP.b #$BE : BNE .not_endpoint_node
        
        INC $0DC0, X
        
        LDA.b #$18 : STA $0E00, X
    
    .not_endpoint_node
    
        LDA $0DE0, X : STA $0EB0, X
        
        JSR $F7AF ; $F77AF IN ROM
        JSR $F901 ; $F7901 IN ROM
    
    BRANCH_ALPHA:
    
        JSR Sprite3_Move
        
        LDA $0D10, X : SUB.b #$08 : STA $00
        LDA $0D30, X : SBC.b #$00 : STA $01
        
        LDA $0D00, X : SUB.b #$0E : STA $02
        LDA $0D20, X : SBC.b #$00 : STA $03
        
        REP #$20
        
        LDA $00 : CMP $22 : BEQ BRANCH_DELTA : BCS BRANCH_EPSILON
        
        DEC $22
        
        BRA BRANCH_DELTA
    
    BRANCH_EPSILON:
    
        INC $22
    
    BRANCH_DELTA:
    
        LDA $02 : CMP $20 : BEQ BRANCH_ZETA : BCS BRANCH_THETA
        
        DEC $20
        
        BRA BRANCH_ZETA
    
    BRANCH_THETA:
    
        INC $20
    
    BRANCH_ZETA:
    
        SEP #$30
        
        DEC $0E80, X : BEQ BRANCH_IOTA
        
        JMP .lambda
    
    BRANCH_IOTA:
    
        LDA $22 : SUB $3F : STA $31
        LDA $20 : SUB $3E : STA $30

        LDY $0DE0, X
        
        LDA Pipe.player_direction, Y : STA $26
        
        PHX
        
        JSL $07E6A6 ; $3E6A6 IN ROM
        JSL $07F42F ; $3F42F IN ROM
        JSL Player_HaltDashAttackLong
        
        PLX
        
        RTS
    }

    ; *$F7CD3-$F7CFE JUMP LOCATION
    {
        LDA $0E00, X : BNE .delay
        
        STZ $02E4
        STZ $02F5
        STZ $037B
        STZ $4B
        STZ $31
        STZ $30
        
        LDA.b #$FF : STA $1DE0
        
        LDA.b #$02 : STA $0DC0, X
        
        RTS
    
    .delay
    
        LDA $0DE0, X : EOR.b #$01 : TAY
        
        LDA Pipe.player_direction, Y
        
        JSR $FCFF ; $F7CFF IN ROM
        
        RTS
    }

    ; *$F7CFF-$F7D11 LOCAL
    {
        ; Induces player movement, I do believe (in spite of the fact that
        ; we made the player invisible and 'froze' them. So... this sprite
        ; is acting as a surrogate of the player sprite, so to speak.
        PHX
        
        STA $67 : STA $26
        
        JSL $07E245 ; $3E245 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
        JSL $07F42F ; $3F42F IN ROM
        
        PLX
        
        RTS
    }

; ==============================================================================
