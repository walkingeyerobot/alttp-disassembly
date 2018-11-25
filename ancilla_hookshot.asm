
    ; Idiosyncrasies:
    ;
    ;   $0380[0x05]
    ;       Tile type that was last interacted with when dealing with ledges.
    ;   
    ;   $0385[0x0A]
    ;       0x00 - Does nothing
    ;       0x01 - Overrides a lot of logic, including disabling sprite
    ;       collision and collision with other ledges. Paired ledges set this
    ;       high first, then low when hitting the second ledge. This is special
    ;       logic that allows the player to cross gaps across ledges, as
    ;       normally many objects collide with ledges.
    ;   
    ;   $0394[0x05]
    ;       Delay timer to avoid 'extra' collision
    ;   
    ;
    ;   $0C54[0x0A] 
    ;       0 - protracting
    ;       1 - retracting
    ;   
    ;   $0C5E[0x0A]
    ;       indicates the 'steps' of the protraction / retraction

; ==============================================================================

    ; $43D4C-$43D73 DATA
    pool Ancilla_Hookshot:
    {
    
    .chr
        db $09, $0A, $FF, $09, $0A, $FF
        db $09, $FF, $0A, $09, $FF, $0A
    
    .properties
        db $00, $00, $FF, $80, $80, $FF
        db $40, $FF, $40, $00, $FF, $00
    
    .chain_y_speeds
        dw 8, -9,  0,  0
    
    .chain_x_speeds
        dw 0,  0,  8, -8
    }

; ==============================================================================

    ; *$43D74-$44002 JUMP LOCATION
    Ancilla_Hookshot:
    {
        LDA $11 : BNE .just_draw
        
        ; branch if no sound effect this frame...
        LDA $0C68, X : BNE .chain_sfx_delay
        
        LDA.b #$07 : STA $0C68, X
        
        LDA.b #$0A : JSR Ancilla_DoSfx2
    
    .chain_sfx_delay
    
        ; In this situation, the player module is moving the player towards
        ; a location so we don't actually have to move the head of the
        ; hookshot.
        LDA $037E : BNE .just_draw
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        ; In the protracting state? Branch.
        ; If retracting, continue on.
        LDA $0C54, X : BEQ .protracting
        
        DEC $0C5E, X : BMI .terminate_after_full_retraction
    
    .just_draw
    
        BRL .draw
    
    .terminate_after_full_retraction
    .self_terminate
    
        STZ $0C4A, X
        
        RTS
    
    .protracting
    
        ; If not at fully protracted state yet, don't begin retracting.
        LDA $0C5E, X : INC A : STA $0C5E, X
        
        CMP.b #$20 : BNE .protraction_not_maxed
        
        ; Begin retracting
        LDA.b #$01 : STA $0C54, X
        
        ; And reverse direction of the hookshot head.
        LDA $0C22, X : EOR.b #$FF : INC A : STA $0C22, X
        LDA $0C2C, X : EOR.b #$FF : INC A : STA $0C2C, X
    
    .protraction_not_maxed
    
        JSR Hookshot_IsCollisionCheckFutile : BCC .perform_collision_checks
        
        BRL .draw
    
    .perform_collision_checks
    
        LDA $0385, X : BNE .ignore_sprite_collision
        
        ; \wtf why all these checks of the protracting state? We already
        ; know if we're here that it can't be retracting.
        LDA $0C54, X : BNE .ignore_sprite_collision
        
        JSR Ancilla_CheckSpriteCollision : BCC .no_tile_collision
        
        LDA $0C54, X : BNE .ignore_sprite_collision
        
        LDA.b #$01 : STA $0C54, X
        
        LDA $0C22, X : EOR.b #$FF : INC A : STA $0C22, X
        LDA $0C2C, X : EOR.b #$FF : INC A : STA $0C2C, X
        
        BRA .check_tile_collision
    
    .unused
    
        ; \unused Interesting... was this put in here for debugging or
        ; something? Requires investigation.
        BRL .unused_2
    
    .ignore_sprite_collision
    .no_tile_collision
    .check_tile_collision
     
        JSL Hookshot_CheckTileCollison
        
        STZ $00
        
        LDA $1B : BEQ .outdoor_ledge_interaction
        
        LDY.b #$01
        
        LDA $0C72, X : AND.b #$02 : BNE .indoor_horiz_ledge_interaction
        
        LDA $036D : LSR #4 : STA $00
        
        LDY.b #$00
    
    .indoor_horiz_ledge_interaction
    
        ; Helps us get across bodies of water without being
        ; stopped.
        LDA $036D, Y : ORA $00
                       AND.b #$03 : STA $00 : BEQ .not_ledge_collision
        
        BRA .ledge_collision
    
    .outdoor_ledge_interaction
    
        LDA $036E : AND.b #$03
                    ORA $036D
                    ORA $0370
                    AND.b #$33 : BEQ .not_ledge_collision
    
    .ledge_collision
    
        DEC $0394, X : BPL .hit_ledge_on_previous_frames
        
        ; If you're here, it means that the guard for ledge collision is still
        ; up.
        LDY $0380, X : BEQ .last_tile_interaction_passable
        
        ; (As opposed to an outdoor ledge)
        LDA $00 : AND.b #$03 : BNE .hit_indoor_ledge_tile
        
        ; \note The tile detection api is supposed to set this variable.
        CPY $76 : BEQ .last_tile_interaction_passable
    
    .hit_indoor_ledge_tile
    
        LDA.b #$02 : STA $0394, X
        
        DEC $0385, X : BPL .ignore_ledges_for_now
        
        STZ $0385, X
        
        BRA .resume_normal_extra_collision
    
    .last_tile_interaction_passable
    
        ; This seems to happen when you hit a ledge tile for starters, and
        ; then it gets set low later.
        INC $0385, X
        
        LDA $76 : STA $0380, X
        
        LDA.b #$01 : STA $0394, X
    
    .ignore_ledges_for_now
    .not_ledge_collision
    .hit_ledge_on_previous_frames
    .resume_normal_extra_collision
    
        LDA $0385, X : BNE .extra_collision_logic_overrided
        
        LDA $0394, X : BMI .extra_collision_logic
        
        DEC $0394, X
    
    .extra_collision_logic_overrided
    
        BRL .draw
    
    .extra_collision_logic
    
        LDA $0E : LSR #4 : ORA $0E
                           ORA $58
                           ORA $0C
                           AND.b #$03 : BEQ .no_extra_tile_collision
        
        LDA $0C54, X : BNE .no_extra_tile_collision
        
        LDA.b #$01 : STA $0C54, X
        
        LDA $0C22, X : EOR.b #$FF : INC A : STA $0C22, X
        LDA $0C2C, X : EOR.b #$FF : INC A : STA $0C2C, X
        
        ; \note I really like this typo 'grabblable', it sounds ridiculous.
        ; Not a tile collision in this case, but it hit something grabblable.
        LDA $02F6 : AND.b #$03 : BNE .no_extra_tile_collision
        
        PHX
        
        LDY.b #$01
        LDA.b #$06
        
        JSL AddHookshotWallHit
        
        PLX
        
        ; Use a different sound if it hit a key door.
        LDY.b #$06
        
        LDA $02F6 : AND.b #$30 : BNE .hit_key_door
        
        LDY #$05
    
    .hit_key_door
    
        TYA : JSR Ancilla_DoSfx2
    
    .no_extra_tile_collision
    
        LDA $02F6 : AND.b #$03 : BEQ .draw
    
    ; \note Though this label says unused, it just means that the branch
    ; origin is unreachable in this case.
    .unused_2
    
        ; If the drag collision occurred close enough, just terminate
        ; the hookshot and don't drag the player.
        LDA $0C5E, X : CMP.b #$04 : BCS .drag_actually_required
        
        BRL .self_terminate
    
    .drag_actually_required
    
        LDA.b #$01 : STA $037E
        
        STX $039D
    
    .draw
    
        JSR Ancilla_PrepOamCoord
        
        LDA $0385, X : BEQ .max_priority_not_required
        
        LDA.b #$30 : STA $65
    
    .max_priority_not_required
    
        REP #$20
        
        LDA $00 : STA $04
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDA $0C72, X : STA $08
        
        ; X and $0A = $0C72, X * 6
        ASL A : ADD $08 : STA $0A : TAX
        
        LDA.b #$02 : STA $08
        
        LDY.b #$00
    
    .next_oam_entry
    
        LDX $0A
        
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        JSR Ancilla_SetOam_XY
        
        LDX $0A
        
        LDA .chr, X                               : STA ($90), Y : INY
        LDA .properties, X : ORA.b #$02 : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INC $0A
        
        LDA $02 : ADD.b #$08 : STA $02
        
        DEC $08 : BMI .draw_chain_links
        
        LDA $08 : BNE .next_oam_entry
        
        LDA $00 : ADD.b #$08 : STA $00
        
        LDA $06 : STA $02
        
        BRA .next_oam_entry
    
    .draw_chain_links
    
        PLX : PHX
        
        STZ $0A
        STZ $0B
        STZ $0C
        STZ $0D
        
        LDA $0C5E, X : LSR A : CMP.b #$07 : BCC .link_scaling_not_needed
        
        ; At extension state >= 7, use this as the base displacement between
        ; chain links. Otherwise, the distance between them is fixed per
        ; the data tables provided by the pool.
        SUB.b #$07 : STA $0A : STA $0C
        
        LDA.b #$06
    
    .link_scaling_not_needed
    
        STA $08 : BNE .at_least_one_chain_link_renderable
        
        ; Currently we should not draw any of the little link components,
        ; so just return for now.
        BRL .no_chain_links
    
    .at_least_one_chain_link_renderable
    
        LDA $0C72, X : AND.b #$01 : BEQ .tracting_up_or_left
        
        ; tracting down or right, so multiply the base offset by -1?
        ; It appears that this is done because the links are drawn
        ; relative to the hook at the end of the hookshot as it's tracting.
        LDA $0A : EOR.b #$FF : INC A : STA $0A
                                       STA $0C
        
        BEQ .no_sign_extension_needed
        
        ; sign extension for $0A and $0C
        LDA.b #$FF : STA $0B
                     STA $0D
    
    .tracting_up_or_left
    .no_sign_extension_needed
    
        REP #$20
        
        LDA $0C72, X : ASL A : AND.b #$00FF : TAX
        
        LDA .chain_y_speeds, X : BNE .use_actual_y_displacement
        
        ; Otherwise move the base y offset for the links down 4 pixels.
        LDA $04 : ADD.w #$0004 : STA $04
    
    .use_actual_y_displacement
    
        LDA .chain_x_speeds, X : BNE .use_actual_x_displacement
        
        ; Otherwise move the base x offset for the links right 4 pixels.
        LDA $06 : ADD.w #$0004 : STA $06
        
        SEP #$20
    
    .use_actual_x_displacement
    .next_chain_link
    
        REP #$20
        
        LDA .chain_y_speeds, X : BEQ .dont_accumulate_y_offset
        
        ; accumulate y offset.
        ADD $0A
    
    .dont_accumulate_y_offset
    
        ADD $04 : STA $04
                  STA $00
        
        LDA .chain_x_speeds, X : BEQ .dont_accumulate_x_offset
        
        ; accumulate x offset.
        ADD $0C
    
    .dont_accumulate_x_offset
    
        ADD $06 : STA $06
                  STA $02
        
        SEP #$20
        
        ; If the chain's calculated position is too close to the player,
        ; it is omitted from the oam buffer.
        JSR Hookshot_CheckChainLinkProximityToPlayer : BCS .chain_link_too_close
        
        JSR Ancilla_SetOam_XY
        
        ; Always same chr, but...
        LDA.b #$19 : STA ($90), Y : INY
        
        ; ... the chain link was probably drawn a bit off kilter so that
        ; hflip and vflip could be employed to 'animate' it. That said, if you
        ; look at the hookshot effect closely, it looks a tad cheap.
        LDA $1A : AND.b #$02 : ASL #6
        
        ORA.b #$02 : ORA $65 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .chain_link_too_close
    
        DEC $08 : BPL .next_chain_link
    
    .no_chain_links
    
        PLX
        
        RTS
    }

; ==============================================================================
