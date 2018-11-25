
; ==============================================================================

    ; $410DC-$410FB DATA
    pool Ancilla_Boomerang:
    {
    
    .y_offsets
        dw -16,   6,   0,   0,  -8,   8,  -8,   8
    
    .x_offsets
        dw   0,   0,  -8,   8,   8,   8,  -8,  -8
    }

; ==============================================================================

    ; *$410FC-$4123A JUMP LOCATION
    Ancilla_Boomerang:
    {
        LDY.b #$04
    
    .next_object_slot
    
        ; See if any "received item sprite" objects are active
        LDA $0C4A, Y : CMP.b #$22 : BEQ .just_draw
        
        DEY : BPL .next_object_slot
        
        ; See if we're not in a normal submodule
        LDA $11 : BNE .just_draw
        
        ; every 8 frames play the whirling sound effect of the boomerang.
        LDA $1A : AND.b #$07 : BNE .no_whirling_sound
        
        LDA.b #$09 : JSR Ancilla_DoSfx2
    
    .no_whirling_sound
    
        LDA $03B1, X : BNE .position_already_set
        
        LDA $3C : CMP.b #$09 : BCS .init_position
        
        LDA $0300 : BNE .init_position
        
        ; terminate the boomerang if Link turned into a rabbit
        LDA $02E0 : BNE .bunny_link
        
        ; terminate the boomerang if Link is in another special state...?
        LDA $4D : BEQ .just_draw
    
    .bunny_link
    
        BRL Boomerang_SelfTerminate
    
    .just_draw
    
        BRL .draw
    
    .init_position
    
        LDA $03CF, X : TAY
        
        REP #$20
        
        LDA $20 : ADD.w #$0008 : ADD .y_offsets, Y : STA $00
        
        LDA $22 : ADD .y_offsets, Y : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
        
        INC $03B1, X
    
    .position_already_set
    
        ; 0 - normal, 1 - magic boomerang
        LDA $0394, X : BEQ .no_sparkle
        
        ; Generate a sparkle every other frame
        LDA $1A : AND.b #$01 : BNE .no_sparkle
        
        PHX
        
        JSL AddSwordChargeSpark
        
        PLX
    
    .no_sparkle
    
        ; 0 - moving away from Link, 1 - moving towards Link
        LDA $0C5E, X : BEQ .move_away_from_link
        
        LDA $0380, X : BEQ .not_recovering_from_deceleration
        
        INC A : STA $0380, X
    
    .not_recovering_from_deceleration
    
        REP #$20
        
        ; \bug While probably mostly harmless... this writes a 16-bit value
        ; to an 8-bit location. Not a great thing to do!
        ; Cache the player's Y coordinate in a temporary variable.
        LDA $20 : STA $038A, X
        
        ADD.w #$0008 : STA $20
        
        SEP #$20
        
        LDA $03C5, X : JSR Ancilla_ProjectSpeedTowardsPlayer
        
        JSL Boomerang_CheatWhenNoOnesLooking
        
        LDA $00 : STA $0C22, X
        LDA $01 : STA $0C2C, X
        
        REP #$20
        
        ; Restore the player's Y coordinate.
        LDA $038A, X : STA $20
        
        SEP #$20
    
    .move_away_from_link
    
        ; at rest in y axis
        LDA $0C22, X : BEQ .y_speed_at_rest
        
        ADD $0380, X : STA $0C22, X
    
    .y_speed_at_rest
    
        JSR Ancilla_MoveVert
        
        ; at rest in x axis
        LDA $0C2C, X : BEQ .x_speed_at_rest
        
        ADD $0380, X : STA $0C2C, X
    
    .y_speed_at_rest
    
        JSR Ancilla_MoveHoriz
        
        JSR Ancilla_CheckSpriteCollision
        
        LDY.b #$00 : BCC .no_sprite_collision
        
        ; Used to signify that there was a sprite collision in the code
        ; below.
        INY
    
    .no_sprite_collision
    
        LDA $0C5E, X : BNE .cant_reverse_seek_polarity_twice
        
        CPY.b #$01 : BEQ .reverse_seek_polarity
        
        JSR Ancilla_CheckTileCollision : BCC .no_tile_collision
        
        PHX
        
        JSL AddBoomerangWallHit
        
        PLX
        
        LDY.b #$06
        
        ; \wtf So only makes a different noise for the first key door? What
        ; happens when there are 2+ key doors in a room?
        LDA $03E4, X : CMP.b #$F0 : BEQ .not_key_door
        
        LDY.b #$05
    
    .not_key_door
    
        TYA : JSR Ancilla_DoSfx2
        
        BRA .reverse_seek_polarity
    
    .no_tile_collision
    
        ; If the boomerang hits the edge of the screen it will also
        ; flip polarity and go back to the player.
        JSR Boomerang_CheckForScreenEdgeReversal : BCS .reverse_seek_polarity
        
        DEC $0C54, X : LDA $0C54, X : BEQ .reverse_seek_polarity
        
        CMP.b #$05 : BCS .draw
        
        ; \wtf Is this an incomplete feature? Why is it necessary to speed
        ; up on certain frames, and the variable that controls this
        ; is not bounds checked in any way.
        DEC $0380, X
        
        BRA .draw
    
    .reverse_seek_polarity
    
        LDA $0C5E, X : EOR.b #$01 : STA $0C5E, X
        
        BRA .draw
    
    .cant_reverse_seek_polarity_twice
    
        LDA $0280, X : PHA
        LDA $0C7C, X : PHA
        
        STZ $0C7C, X
        
        JSR Ancilla_CheckTileCollision
        
        PLA : STA $0C7C, X
        PLA : STA $0280, X
        
        JSR Boomerang_SelfTerminateIfOffscreen
    
    .draw
    
        BRL Boomerang_Draw
    }

; ==============================================================================

    ; *$4123B-$41242 LONG
    Ancilla_CheckTileCollisionLong:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_CheckTileCollision
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$41243-$4124A LONG
    Ancilla_CheckTileCollision_Class2_Long:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_CheckTileCollision_Class2
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$4124B-$412AA LOCAL
    Boomerang_CheckForScreenEdgeReversal:
    {
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        REP #$30
        
        LDY.w #$0000
        
        LDA $039D : AND.w #$0003 : BEQ .no_horizontal_component
                    AND.w #$0001 : BEQ .leftward_throw
        
        LDY.w #$0010
    
    .leftward_throw
    
        TYA : ADD $02 : SUB $E2 : STA $02
        
        CMP.w #$0100 : BCS .reverse_direction
    
    .no_horizontal_component
    
        LDY.w #$0000
        
        LDA $039D : AND.w #$000C : BEQ .dont_reverse
                    AND.w #$0004 : BEQ .upward_throw
        
        LDY.w #$0010
    
    .upward_throw
    
        TYA : ADD $00 : SUB $E8 : STA $00 : CMP.w #$00E2 : BCC .dont_reverse
    
    .reverse_direction
    
        SEP #$30
        
        SEC
        
        RTS
    
    .dont_reverse
    
        SEP #$30
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$412AB-$41319 LOCAL
    Boomerang_SelfTerminateIfOffscreen:
    {
        LDA $0BFA, X : STA $04
        LDA $0C0E, X : STA $05
        
        LDA $0C04, X : STA $06
        LDA $0C18, X : STA $07
        
        REP #$20
        
        LDA $20 : ADD.w #$0018 : STA $00
        LDA $22 : ADD.w #$0010 : STA $02
        
        LDA $04 : ADD.w #$0008 : STA $04
        
        LDA $06 : ADD.w #$0008 : STA $06
        
        ; Self terminate if the boomerang is close enough to the player.
        LDA $04 : CMP $20 : BCC .dont_self_terminate
                  CMP $00 : BCS .dont_self_terminate
        
        LDA $06 : CMP $22 : BCC .dont_self_terminate
                  CMP $02 : BCS .dont_self_terminate
    
    ; *$412F5 ALTERNATE ENTRY POINT
    shared Boomerang_SelfTerminate:
    
        SEP #$20
        
        STZ $0C4A, X
        
        STZ $035F
        
        LDA $0301 : AND.b #$80 : BEQ .not_in_throw_pose
        
        STZ $0301
        
        ; Cancel any further Y button input this frame
        LDA $3A : AND.b #$BF : STA $3A : AND.b #$80 : BNE .b_button_held
        
        ; Allow Link to change direction again
        LDA $50 : AND.b #$FE : STA $50
    
    .dont_self_terminate
    .b_button_held
    .not_in_throw_pose
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $4131A-$41337 DATA
    pool Boomerang_Draw:
    {
    
    .properties
        db $A4, $E4, $64, $24, $A2, $E2, $62, $22
    
    .xy_offsets
        dw  2, -2
        dw  2,  2
        dw -2,  2
        dw -2, -2
        
    .oam_base
        dw $0180, $00D0
    
    .rotation_speed
        db $03, $02
    }

; ==============================================================================

    ; *$41338-$413E7 LONG BRANCH LOCATION
    Boomerang_Draw:
    {
        JSR Ancilla_PrepOamCoord
        
        LDA $0C5E, X : BEQ .moving_away
        
        LDA $EE : STA $0C7C, X : TAY
        
        LDA $F66D, Y : STA $65
    
    .moving_away
    
        LDA $0280, X : BEQ .normal_priority
        
        LDA.b #$30 : STA $65
    
    .normal_priority
    
        LDA $11 : BNE .leave_rotation_state_alone
        
        LDA $03B1, X : BEQ .leave_rotation_state_alone
        
        DEC $039F, X : BPL .leave_rotation_state_alone
        
        LDY $0394, X
        
        LDA .rotation_speed, Y : STA $039F, X
        
        LDY $03A4, X
        
        ; The boomerang 'spins' in opposing directions depending on whether
        ; it was thrown to the left or to the right.
        LDA $03A9, X : BEQ .left_throw
        
        DEY
        
        BRA .set_rotation_state
    
    .left_throw
    
        INY
    
    .set_rotation_state
    
        ; Rotation state of the boomerang
        TYA : AND.b #$03 : STA $03A4, X
    
    .leave_rotation_state_alone
    
        PHX
        
        LDA $0394, X : ASL #2 : STA $72
        
        LDA $03A4, X : ASL #2 : TAY
        
        REP #$20
        
        STZ $74
        
        ; The first entry in each interleaved pair is the y offset, the second
        ; being the x offset.
        LDA .xy_offsets+0, Y : ADD $00           : STA $00
        LDA .xy_offsets+2, Y : ADD $02 : STA $02 : STA $04
        
        LDA $03B1, X : AND.w #$00FF : BNE .use_general_oam_base
        
        LDA $0FB3 : AND.w #$00FF : ASL A : TAX
        
        LDA .oam_base, X : PHA
        
        LSR #2 : ADD.w #$0A20 : STA $92
        
        PLA : ADD.w #$0800 : STA $90
    
    .use_general_oam_base
    
        SEP #$20
        
        TYA : LSR #2 : ADD $72 : TAX
        
        LDY.b #$00
        
        JSR Ancilla_SetSafeOam_XY
        
        LDA.b #$26 : STA ($90), Y
        
        INY
        
        LDA $931A, X : AND.b #$CF : ORA $65 : STA ($90), Y
        
        LDA.b #$02 : ORA $75 : STA ($92)
        
        PLX
        
        RTS
    }

; ==============================================================================
