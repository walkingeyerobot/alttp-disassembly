
; ==============================================================================

    ; \unused Appears to be true.
    ; $EC412-$EC413 DATA
    {
    
    .unknown_0
        db 8, -8
    }

; ==============================================================================

    !is_faerie_cloud = $0EB0

    ; *$EC414-$EC442 JUMP LOCATION
    Sprite_BigFaerie:
    {
        ; Big Faerie / Faerie Dust cloud
        
        ; If nonzero, it is a dust cloud
        LDA !is_faerie_cloud, X : BNE Sprite_FaerieCloud
        
        JMP BigFaerie_Main
    
    shared Sprite_FaerieCloud:
    
        JSL Sprite_PrepOamCoordLong
        JSR Sprite4_CheckIfActive
        
        INC $0E80, X
        
        JSR FaerieCloud_Draw 
        
        LDA $0E80, X : AND.b #$1F : BNE .delay_healing_sfx
        
        LDA.b #$31 : JSL Sound_SetSfx2PanLong
    
    .delay_healing_sfx
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw FaerieCloud_SeekPlayer
        dw FaerieCloud_AwaitFullPlayerHealth
        dw FaerieCloud_FadeOut
    }

; ==============================================================================

    ; *$EC443-$EC488 JUMP LOCATION
    FaerieCloud_SeekPlayer:
    {
        LDA.b #$00 : STA $0D90, X
        
        LDA.b #$08 : JSL Sprite_ApplySpeedTowardsPlayerLong
        
        JSR Sprite4_Move
        JSL Sprite_Get_16_bit_CoordsLong
        
        REP #$20
        
        LDA $22 : SUB $0FD8 : ADD.w #$0003 : CMP.w #$0006 : BCS .player_too_far
        
        LDA $20 : SUB $0FDA : ADD.w #$000B : CMP.w #$0006 : BCS .player_too_far
        
        ; Add 20 hearts to the heart refill variable. This should fully heal
        ; the player no matter how many heart containers they have.
        LDA.w #$00A0 : ADD $7EF372 : STA $7EF372
        
        SEP #$20
        
        INC $0D80, X
    
    .player_too_far
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$EC489-$EC49B JUMP LOCATION
    FaerieCloud_AwaitFullPlayerHealth:
    {
        LDA $7EF36D : CMP $7EF36C : BNE .player_hp_not_full_yet
        
        INC $0D80, X
        
        ; \task Find out if this assumes that the big faerie is always in slot
        ; 0. I think it does, just not positive. \hardcoded (confirmed) 
        LDA.b #$70 : STA !timer_2
    
    .player_hp_not_full_yet
    
        RTS
    }

; ==============================================================================

    ; *$EC49C-$EC4BE JUMP LOCATION
    FaerieCloud_FadeOut:
    {
        LDA $0E80, X : AND.b #$0F : BNE .delay_self_termination
        
        ; \bug I don't think there's ever an occasion where this branch
        ; will be taken, as it self terminates immediately when this variable
        ; becomes negative (see code a few lines down).
        LDA $0D90, X : BMI .never
        
        SEC : ROL $0D90, X
        
        ; \optimize Is this really necessary? I think you could just check
        ; $0D90 for positivity (BPL) right after the ROL above.
        LDA $0D90, X : CMP.b #$80 : BCC .delay_self_termination
        
        LDA.b #$FF : STA $0D90, X
        
        STZ $02E4
        
        STZ $0DD0, X
    
    .never
    .delay_self_termination
    
        RTS
    }

; ==============================================================================

    !animation_timer = $0ED0

    ; *$EC4BF-$EC4F8 LOCAL
    BigFaerie_Main:
    {
        LDA !timer_2, X : BEQ .draw
        CMP.b #$40      : BCS .draw
        DEC A           : BNE .blinking_draw
        
        ; Self termiantes once the timer ticks down.
        STZ $0DD0, X
    
    .blinking_draw
    
        LSR A : BCC .draw
        
        ; On these frames, don't draw the sprite or do any other logic.
        RTS
    
    .draw
    
        JSR BigFaerie_Draw
        
        ; Timer ranging from 0 - 5 to delay graphic changes
        ; Don't change graphics
        DEC !animation_timer, X : BPL .animation_delay
        
        ; Reset back to five if it ends up being negative
        LDA.b #$05 : STA !animation_timer, X
        
        ; Whenever !animation_timer counts down, change the graphics
        LDA $0DC0, X : INC A : AND.b #$03 : STA $0DC0, X
    
    .animation_delay
    
        JSR Sprite4_CheckIfActive
        
        INC $0E80, X ; Sometimes a subtype, in this case it's a timer.
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw BigFaerie_AwaitClosePlayer
        dw BigFaerie_Dormant
    }

; ==============================================================================

    ; *$EC4F9-$EC54E JUMP LOCATION
    BigFaerie_AwaitClosePlayer:
    {
        JSR FaerieCloud_Draw
        
        LDA.b #$01 : STA $0D90, X
        
        JSR Sprite4_DirectionToFacePlayer
        
        LDA $0F : ADD.b #$30 : CMP.b #$60 : BCS .player_too_far
        
        LDA $0E : ADD.b #$30 : CMP.b #$60 : BCS .player_too_far
        
        JSL Player_HaltDashAttackLong
        
        INC $0D80, X
        
        ; Big Faerie's text "let me heal wounds..."
        LDA.b #$5A : STA $1CF0
        LDA.b #$01 : STA $1CF1
        
        JSL Sprite_ShowMessageMinimal
        
        LDA.b #$01 : STA $02E4 ; Make it so Link can't move
        
        ; Create the Faerie Dust cloud
        ; \note It's not checked whether the spawn was successful.
        LDA.b #$C8 : JSL Sprite_SpawnDynamically
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$01 : STA !is_faerie_cloud, Y
        
        LDA $0D00, Y : SUB $0F70, X : STA $0D00, Y
        
        LDA.b #$00 : STA $0F70, Y
    
    .player_too_far
    
        RTS
    }

; ==============================================================================

    ; $EC54F-$EC54F JUMP LOCATION
    BigFaerie_Dormant:
    {
        RTS
    }

; ==============================================================================

    ; $EC550-$EC5CF DATA
    pool BigFaerie_Draw:
    {
    
    .oam_groups
        dw -4, -8 : db $8E, $00, $00, $02
        dw  4, -8 : db $8E, $40, $00, $02
        dw -4,  8 : db $AE, $00, $00, $02
        dw  4,  8 : db $AE, $40, $00, $02
        
        dw -4, -8 : db $8C, $00, $00, $02
        dw  4, -8 : db $8C, $40, $00, $02
        dw -4,  8 : db $AC, $00, $00, $02
        dw  4,  8 : db $AC, $40, $00, $02
        
        dw -4, -8 : db $8A, $00, $00, $02
        dw  4, -8 : db $8A, $40, $00, $02
        dw -4,  8 : db $AA, $00, $00, $02
        dw  4,  8 : db $AA, $40, $00, $02
        
        dw -4, -8 : db $8C, $00, $00, $02
        dw  4, -8 : db $8C, $40, $00, $02
        dw -4,  8 : db $AC, $00, $00, $02
        dw  4,  8 : db $AC, $40, $00, $02
    }

; ==============================================================================

    ; *$EC5D0-$EC5ED LOCAL
    BigFaerie_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$04
        
        JSR Sprite4_DrawMultiple
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

    ; $EC5EE-$EC615 DATA
    pool FaerieCloud_Draw:
    {
    
    .xy_offsets_low
        db -12,  -6,   0,   6,  12,  18,  -9,  -3
        db   3,   9,  15,  21
    
    .xy_offsets_high
        db  -1,  -1,   0,   0,   0,   0,   -1,   -1
        db   0,   0,   0,   0
    
    .offset_indices
        db 0,  1,  2,  3,  4,  5,  2,  3
    
    ; \unused While this should be considered part of the previous
    ; sublabel, the bitmask on the randomly generated numbers prevents this
    ; portion from being used. Therefore, the last 4 bytes of the offsets
    ; tables are also implicitly unused.
    ; $EC60E
    .unused
        db 6,  7,  8,  9, 10, 11,  8,  9
    }

; ==============================================================================

    ; *$EC616-$EC64E LOCAL
    FaerieCloud_Draw:
    {
        ; This apparently randomly generates the faerie cloud sparkles.
        ; It's not draw in a literal sense, but it spawns garnish entities
        ; that themselves draw sparkles via oam.
        
        LDA $0D90, X : BMI .spawn_inhibited
        
        ; As $0D90 accumulates bits, less and less sparkle garnishes will be
        ; generated over time.
        AND $0E80, X : BNE .spawn_masked_this_frame
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA .offset_indices, Y : TAY
        
        ; Randomly picking an X or Y coordinate offset
        LDA .xy_offsets_low, Y  : STA $00
        LDA .xy_offsets_high, Y : STA $01
        
        JSL GetRandomInt : AND.b #$07 : TAY
        
        LDA .offset_indices, Y : TAY
        
        ; Same here... not sure which is X and which is Y
        LDA .xy_offsets_low, Y  : STA $02
        LDA .xy_offsets_high, Y : STA $03
        
        JSL Sprite_SpawnSimpleSparkleGarnish

    .spawn_masked_this_frame
    .spawn_inhibited

        RTS
    }

; ==============================================================================
