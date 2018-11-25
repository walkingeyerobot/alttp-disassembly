
; ==============================================================================

    ; *$F6B33-$F6B3F JUMP LOCATION
    Sprite_BullyAndBallGuy:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_BallGuy
        dw BallGuy_DrawDistressMarker ; \unused Just this entry.
        dw Sprite_Bully
    }

; ==============================================================================

    ; *$F6B40-$F6C30 JUMP LOCATION
    Sprite_BallGuy:
    {
        JSL OAM_AllocateDeferToPlayerLong
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSR BallGuy_Dialogue
        
        LDA $0F50, X : AND.b #$7F : ORA $0EB0, X : STA $0F50, X
        
        JSR Sprite3_MoveXyz
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        AND.b #$03                     : BNE .horiz_tile_collision
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        LDA $0E90, X : BEQ .not_kicked
        
        JSR BallGuy_PlayBounceNoise
        
        BRA .moving_on
    
    .not_kicked
    .horiz_tile_collision
    
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $0E90, X : BEQ .not_kicked_2
        
        JSR BallGuy_PlayBounceNoise
    
    .not_kicked_2
    .no_tile_collision
    .moving_on
    
        DEC $0F80, X
        
        LDA $0F70, X : BPL .not_z_bouncing
        
        STZ $0F70, X
        
        LDA $0F80, X : EOR.b #$FF : INC A : LSR #2 : STA $0F80, X
        
        AND.b #$FC : BEQ .dont_play_sfx
        
        JSR BallGuy_PlayBounceNoise
    
    .dont_play_sfx
    
        JSR BallGuy_Friction
    
    .not_z_bouncing
    
        LDA $0E90, X : BNE .kicked_by_bully
        
        LDA $0EB0, X : BEQ .right_side_up
        
        JMP BallGuy_UpsideDown
    
    .right_side_up
    
        JSR BallGuy_DrawDistressMarker
        
        TXA : EOR $1A : PHA
        
        LSR #3 : AND.b #$01 : STA $0DC0, X
        
        PLA : AND.b #$3F : BNE .dont_pick_new_direction
        
        ; Put Ball Guy's new position somewhere in the vicinity of the player.
        ; That said, the low bytes are totally random, so it may not appear
        ; that way.
        JSL GetRandomInt : STA $04
        LDA $23          : STA $05
        
        JSL GetRandomInt : STA $06
        LDA $21          : STA $07
        
        LDA.b #$08
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $01 : STA $0DA0, X
        
        LDA $00 : STA $0D90, X : BEQ .target_location_vertical
        
        LDA $0F50, X : ORA.b #$40 : STA $0F50, X
        
        LDA $0D50, X : LSR A : AND.b #$40 : EOR $0F50, X : STA $0F50, X
    
    .target_location_vertical
    .dont_pick_new_direction
    
        LDA $0DA0, X : STA $0D50, X
        
        LDA $0D90, X : STA $0D40, X
        
        RTS
    
    .kicked_by_bully
    
        LDA $0D50, X : ORA $0D40, X : BNE .not_at_full_stop_yet
        
        STZ $0E90, X
        
        RTS
    
    .not_at_full_stop_yet
    
        TXA : EOR $1A : PHA : LSR #2 : AND.b #$01 : STA $0DC0, X
        
        PLA : ASL #2 : AND.b #$80 : STA $0EB0, X
        
        RTS
    
; ==============================================================================

    ; *$F6C31-$F6C4A ALTERNATE ENTRY POINT
    BallGuy_UpsideDown:
    {
        JSR BallGuy_DrawDistressMarker
        
        TXA : EOR $1A : BEQ .turn_right_side_up
        
        LSR #2 : AND.b #$01 : STA $0DC0, X
        
        STZ $0D50, X
        STZ $0D40, X
        
        RTS
    
    .turn_right_side_up
    
        STZ $0EB0, X
        
        RTS
    }

; ==============================================================================

    ; $F6C4B-$F6C4C DATA
    pool BallGuy_Friction:
    {
    
    .rates
        db $FE, $02
    }

; ==============================================================================

    ; *$F6C4D-$F6C73 LOCAL
    BallGuy_Friction:
    {
        LDA $0D50, X : BEQ .zero_x_velocity
        
        PHA : ASL A : ROL A : AND.b #$01 : TAY
        
        PLA : ADD .rates, Y : STA $0D50, X
    
    .zero_x_velocity
    
        LDA $0D40, X : BEQ .zero_y_velocity
        
        PHA : ASL A : ROL A : AND.b #$01 : TAY
        
        PLA : ADD .rates, Y : STA $0D40, X
    
    .zero_y_velocity
    
        RTS
    }

; ==============================================================================

    ; *$F6C74-$F6C7B JUMP LOCATION
    BallGuy_DrawDistressMarker:
    {
        JSR Sprite3_PrepOamCoord
        JSL Sprite_DrawDistressMarker
        
        RTS
    }

; ==============================================================================

    ; *$F6C7C-$F6CB1 JUMP LOCATION
    Sprite_Bully:
    {
        JSR Bully_Draw
        JSR Sprite3_CheckIfActive
        JSR Bully_Dialogue
        JSR Sprite3_MoveXyz
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        AND.b #$03                     : BNE .horiz_tile_collision
        
        LDA $0D40, X : EOR.b #$FF : INC A : STA $0D40, X
        
        BRA .moving_on
    
    .horiz_tile_collision
    
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
    
    .moving_on
    .no_tile_collision
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Bully_ChaseBallGuy
        dw Bully_KickBallGuy
        dw Bully_Waiting
    }

; ==============================================================================

    ; *$F6CB2-$F6D22 JUMP LOCATION
    Bully_ChaseBallGuy:
    {
        ; Bully State 0
        
        TXA : EOR $1A : PHA : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        PLA : AND.b #$1F : BNE .delay
        
        LDA $0EB0, X : TAY
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        ; Makes the Bully go towards the Ball Guy
        LDA.b #$0E : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X : BEQ .dont_change_orientation
        
        LDA $0D50, X : ASL A : ROL A : AND.b #$01 : STA $0DE0, X
    
    .dont_change_orientation
    .delay
    
        LDA $0EB0, X : TAY
        
        LDA $0F70, Y : BNE .cant_kick
        
        LDA $0D10, X : SUB $0D10, Y : ADD.b #$08 : CMP.b #$10 : BCS .cant_kick
        
        LDA $0D00, X : SUB $0D00, Y : ADD.b #$08 : CMP.b #$10 : BCS .cant_kick
        
        INC $0D80, X
        
        JSR BallGuy_PlayBounceNoise
    
    .cant_kick
    
        RTS
    }

; ==============================================================================

    ; *$F6D23-$F6D54 JUMP LOCATION
    Bully_KickBallGuy:
    {
        INC $0D80, X
        
        LDA $0EB0, X : TAY
        
        ; Specifies Ball Guy's new velocity as being double that of the bully's
        ; when he kicks him. However, this isn't arithmetically safe I guess.
        LDA $0D50, X : ASL A : STA $0D50, Y
        
        LDA $0D40, X : ASL A : STA $0D40, Y
        
        STZ $0D50, X
        STZ $0D40, X
        
        JSL GetRandomInt : AND.b #$1F : STA $0F80, Y
        
        LDA.b #$60 : STA $0DF0, X
        
        LDA.b #$01 : STA $0DC0, X : STA $0E90, Y
        
        RTS
    }

; ==============================================================================

    ; *$F6D55-$F6D5D JUMP LOCATION
    Bully_Waiting:
    {
        LDA $0DF0, X : BNE .delay
        
        STZ $0D80, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F6D5E-$F6D9D DATA
    pool Bully_Draw:
    {
    
    .oam_groups
        dw 0, -7 : db $E0, $46, $00, $02
        dw 0,  0 : db $E2, $46, $00, $02
        
        dw 0, -7 : db $E0, $46, $00, $02
        dw 0,  0 : db $C4, $46, $00, $02
        
        dw 0, -7 : db $E0, $06, $00, $02
        dw 0,  0 : db $E2, $06, $00, $02
        
        dw 0, -7 : db $E0, $06, $00, $02
        dw 0,  0 : db $C4, $06, $00, $02
    }

; ==============================================================================

    ; *$F6D9E-$F6DC1 LOCAL
    Bully_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DE0, X : ASL A : ADC $0DC0, X : ASL #4
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

    ; *$F6DC2-$F6DC8 LOCAL
    BallGuy_PlayBounceNoise:
    {
        LDA.b #$32 : JSL Sound_SetSfx3PanLong
        
        RTS
    }

; ==============================================================================

    ; *$F6DC9-$F6DE3 LONG
    BullyAndBallGuy_SpawnBully:
    {
        LDA.b #$B9 : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$02 : STA $0E80, Y
        
        ; Tells the Bully the index of the Ball Guy so he can harass him.
        TXA : STA $0EB0, Y
        
        LDA.b #$01 : STA $0BA0, Y
    
    .spawn_failed
    
        RTL
    }

; ==============================================================================

    ; $F6DE4-$F6DE7 DATA
    pool BallGuy_Dialogue:
    {
    
    .messages_low
        db $5B, $5C
    
    .messages_high
        db $01, $01
    }

; ==============================================================================

    ; *$F6DE8-$F6E20 JUMP LOCATION
    BallGuy_Dialogue:
    {
        LDA $0F10, X : BNE .delay
        
        LDA $7EF357 : AND.b #$01 : TAY
        
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        ; \bug um... usually you increment after doing this. Assuming for now
        ; that it's a bug unless some point to this is found.
        LDA $0D50, X : EOR.b #$FF : STA $0D50, X
        
        LDA $0D40, X : EOR.b #$FF : STA $0D40, X
        
        LDA $0E90, X : BEQ .dont_play_sfx
        
        JSR BallGuy_PlayBounceNoise
    
    .dont_play_sfx
    
        LDA.b #$40 : STA $0F10, X
    
    .didnt_speak
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F6E21-$F6E24 DATA
    pool Bully_Dialogue:
    {
    
    .messages_low
        db $5D, $5E
    
    .messages_high
        db $01, $01
    }

; ==============================================================================

    ; *$F6E25-$F6E55 LOCAL
    Bully_Dialogue:
    {
        LDA $0F10, X : BNE .delay
        
        LDA $7EF357 : AND.b #$01 : TAY
        
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        LDA $0D50, X : EOR.b #$FF : STA $0D50, X
        
        LDA $0D40, X : EOR.b #$FF : STA $0D40, X
        
        LDA.b #$40 : STA $0F10, X
    
    .didnt_speak
    .delay
    
        RTS
    }

; ==============================================================================

