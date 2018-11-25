
; ==============================================================================

    ; Ancilla 0x27 - Travel Bird
    ; 
    ; Idiosyncrasies:
    ;   $03B5, X - 
    ;       0 - attempt to pick up player
    ;       1 - dropping off player
    ;   
    ;   $0394, X
    ;       Flapping sound effect delay timer
    ;   
    ;   

; ==============================================================================

    ; $45DD8-$45DE7 DATA
    pool Ancilla_TravelBird:
    {
    
    .chr
        db $0E, $00, $02
    
    .properties
        db $22, $2E, $2E
    
    .y_offsets
        db $00, $0C, $14
    
    .x_offsets
        db $00, $F7, $F7
    
    .vram_offsets
        db $00, $20, $40, $E0
    }

; ==============================================================================

    ; *$45DE8-$46067 JUMP LOCATION
    Ancilla_TravelBird:
    {
        LDA $11 : BEQ .execute
        
        BRL .draw_logic
    
    .execute
    
        LDA $0C68, X : BEQ .ready_to_seek_player
        
        ; Set coordinates while autotimer is counting down to be at roughly
        ; the y coordinate level of the player, and to the left of the screen.
        ; Update this every frame until the autotimer expires so the bird
        ; isn't suddenly shown midscreen if the player moves left.
        
        REP #$20
        
        LDA $20 : SUB.w #8 : STA $00
        
        LDA.w #-16 : ADD $E2 : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
        
        RTS
    
    .ready_to_seek_player
    
        DEC $0394, X : BPL .flapping_sfx_delay
        
        LDA.b #$28 : STA $0394, X
        
        LDA.b #$1E : JSR Ancilla_DoSfx3
    
    .flapping_sfx_delay
    
        LDY $0385, X : BNE .dropping_off_so_swoop_down
        
        LDA $0C54, X : BEQ .maintain_current_altitude
        
        ; Pause sprite execution.
        INC $0FC1
    
    .dropping_off_so_swoop_down
    
        LDA $0294, X : ADD.b #-1 : STA $0294, X
        
        JSR Ancilla_MoveAltitude
    
    .maintain_current_altitude
    
        JSR Ancilla_MoveHoriz
        
        LDA $0385, X : BEQ .pick_up_logic
        
        BRL .drop_off_logic
    
    .dont_pick_up_player
    
        BRL .pick_up_logic_complete
    
    .pick_up_logic
    
        LDY.b #$01
        
        JSR Ancilla_CheckPlayerCollision : BCC .dont_pick_up_player
        
        LDA $10 : CMP.b #$0F : BEQ .dont_pick_up_player
        
        LDA $1B : BNE .indoors
        
        LDA $5D
        
        CMP.b #$0A : BEQ .dont_pick_up_player
        CMP.b #$09 : BEQ .dont_pick_up_player
        CMP.b #$08 : BEQ .dont_pick_up_player
        
        LDA $5B : CMP.b #$02 : BEQ .dont_pick_up_player
        
        LDA $02DA : ORA $037E
                    ORA $03EF
                    ORA $037B : BNE .dont_pick_up_player
        
        BIT $0308 : BMI .dont_pick_up_player
        
        PHX
        
        LDX.b #$04
    
    ; Terminate other ancillae that match a list of types.
    .next_slot
    
        LDA $0C4A, X
        
        CMP.b #$2A : BEQ .terminate_ancilla
        CMP.b #$1F : BEQ .terminate_ancilla
        CMP.b #$30 : BEQ .terminate_ancilla
        CMP.b #$31 : BEQ .terminate_ancilla
        CMP.b #$41 : BNE .ignored_ancilla
    
    .terminate_ancilla
    
        STZ $0C4A, X
    
    .ignored_ancilla
    
        DEX : BPL .next_slot
        
        PLX
        
        LDA $7EF3CC : CMP.b #$09 : BNE .tagalong_not_middle_aged_sign_guy
        
        LDA.b #$00 : STA $7EF3CC
                     STA $02F9
    
    .tagalong_not_middle_aged_sign_guy
    .indoors
    
        REP #$20
        
        STZ $0308
        STZ $011A
        STZ $011C
        
        SEP #$20
        
        JSL Player_ResetState
        
        STZ $0345
        STZ $03F8
        
        LDA.b #$0C : STA $4B
        
        LDA.b #$00 : STA $5D
        
        INC A : STA $02DA
                STA $02E4
                STA $037B
                STA $02F9
        
        ; Begin rising now that the player has been picked up.
        INC A : STA $0C54, X
        
        INC $0FC1
        
        STZ $0373
        
        LDA $1B : BEQ .dont_forbid_lifting_objects
        
        STA $03FD
    
    .dont_forbid_lifting_objects
    .pick_up_logic_complete
    
        BRA .draw_logic
    
    .drop_off_logic
    
        LDA $0C04, X : STA $00
        LDA $0C18, X : STA $01
        
        LDA $0C54, X : BEQ .dont_freeze_sprites
        
        INC $0FC1
    
    .dont_freeze_sprites
    
        REP #$20
        
        LDA $00 : BMI .drop_off_player_delay
        CMP $22 : BCC .drop_off_player_delay
        
        SEP #$20
        
        LDA $0C54, X : BEQ .draw_logic
        
        STZ $0C54, X
        STZ $4B
        STZ $02F9
        STZ $02DA
        
        STZ $0C22, X
        
        STZ $02E4
        STZ $037B
        STZ $03FD
        
        LDA.b #$90 : STA $031F
        
        LDA $7EF3CC
        
        CMP.b #$0D : BEQ .super_bomb_or_chest_tagalong
        CMP.b #$0C : BNE .tagalong_neither_of_those
    
    .super_bomb_or_chest_tagalong
    
        LDA $7EF3D3 : BNE .draw_logic
    
    .tagalong_neither_of_those
    
        JSL Tagalong_Init
        
        BRA .draw_logic
    
    .drop_off_player_delay
    
        LDA $22 : SUB $00 : CMP.w #$0030 : BCS .draw_logic
        
        ; Use the pulling up tiles for the bird since it's trying to
        ; not crash as it lands the player.
        LDY.b #$03
        
        SEP #$20
        
        BRA .set_vram_offset
    
    .draw_logic
    
        SEP #$20
        
        DEC $039F, X : BPL .animation_delay
        
        LDY.b #$03
        
        STA $039F, X
        
        INC $0380, X : LDA $0380, X : CMP.b #$03 : BNE .anoreset_animation_index
        
        STZ $0380, X
    
    .animation_delay
    .anoreset_animation_index
    
        LDY $0380, X
    
    .set_vram_offset
    
        ; Set chr vram upload offset for bird body.
        LDA .vram_offsets, Y : STA $0AF4
        
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        ; \wtf(confirmed) Why does this object have to be a special snowflake?
        ; Why can't it just use altitude the way pretty much all other objects
        ; in the game do? >8^(
        LDA $029E, X : AND.w #$00FF : BEQ .treat_altitude_as_negative
        
        ORA.w #$FF00
    
    .treat_altitude_as_negative
    
        STA $04
        STA $72
        
        LDA $00 : STA $0A
        ADD $04 : STA $04
        
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDA $0C54, X : INC A : STA $08
        
        LDY.b #$00 : TYX
    
    .next_oam_entry
    
        REP #$20
        
        LDA .y_offsets, X : AND.w #$00FF
        
        CMP.w #$0080 : BCC .sign_ext_y_offset
        
        ORA.w #$FF00
    
    .sign_ext_y_offset
    
        ADD $04 : STA $00
        
        LDA .x_offsets, X : AND.w #$00FF
        
        CMP.w #$0080 : BCC .sign_ext_x_offset
        
        ORA.w #$FF00
    
    .sign_ext_x_offset
    
        ADD $06 : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X : STA ($90), Y : INY
        
        LDA .properties, X : ORA.b #$30 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY
        
        INX
        
        CPY $08 : BNE .next_oam_entry
        
        REP #$20
        
        LDA $0A : ADD.w #$001C : STA $00
        
        LDA $06 : STA $02
        
        SEP #$20
        
        LDA.b #$30 : STA $04
        
        LDX.b #$01 : JSR Ancilla_DrawShadow
        
        LDX $0FA0
        
        LDA $0C54, X : BEQ .dont_draw_player_shadow
        
        REP #$20
        
        LDA $0A : ADD.w #28 : STA $00
        
        LDA $06 : ADD.w #-7 : STA $02
        
        SEP #$20
        
        LDA.b #$30 : STA $04
        
        LDX.b #$01 : JSR Ancilla_DrawShadow
    
    .dont_draw_player_shadow
    
        PLX
        
        REP #$20
        
        LDA $06      : BMI .not_far_enough_right
        CMP.w #$0130 : BCC .not_far_enough_right
        
        SEP #$20
        
        STZ $0C4A, X
        
        LDA $0385, X : BNE .dont_transition_to_bird_travel_submodule
        
        LDA $0C54, X : BEQ .dont_transition_to_bird_travel_submodule
        
        ; Enter the BirdTravel submodule of Messaging module.
        LDA.b #$0A : STA $11
        
        LDA $10 : STA $010C
        
        LDA.b #$0E : STA $10
    
    .not_far_enough_right
    .dont_transition_to_bird_travel_submodule
    
        SEP #$20
        
        RTS
    }

; ==============================================================================
