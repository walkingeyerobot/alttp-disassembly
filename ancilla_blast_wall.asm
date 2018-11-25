
; ==============================================================================

    ; *$4260E-$42755 JUMP LOCATION
    Ancilla_Unused_0E:
    Ancilla_Unused_0F:
    Ancilla_Unused_10:
    Ancilla_Unused_12:
    Ancilla_BlastWall:
    {
        LDA $11 : BNE .state_logic_finished
        
        LDA $7F0000, X : BEQ .inactive_component
        
        LDA $7F0008, X : DEC A : STA $7F0008, X : BNE .state_logic_finished
        
        LDA $7F0000, X : INC A : STA $7F0000, X : BEQ .anospawn_fireball
                                 CMP.b #$09     : BCS .anospawn_fireball
        
        PHX
        
        TXA : ASL #2 : STA $04
        
        LDY.b #$0A
        LDA.b #$32
        
        JSL AddBlastWallFireball
        
        PLX
    
    .anospawn_fireball
    
        LDA $7F0000, X : CMP.b #$0B : BNE .anoreset_component_state
        
        LDA.b #$00 : STA $7F0000, X : STA $7F0008, X
        
        BRA .state_logic_finished
    
    .anoreset_component_state
    
        ; \wtf This instruction doesn't appear to serve any useful purpose.
        TAY
        
        LDA.b #$03 : STA $7F0008, X
    
    .state_logic_finished
    
        BRL .draw
    
    .inactive_component
    
        ; Switch to the other slot? Why?
        TXA : EOR.b #$01 : TAX
        
        LDA $7F0000, X : CMP.b #$06 : BNE .state_logic_finished
        
        LDA $7F0008, X : CMP.b #$02 : BNE .state_logic_finished
        
        ; \wtf(confirmed) Was the blast wall designed to have more than one
        ; spawn point? Multiple blast wall objects working at once?
        LDX $0380
        
        LDA $0C5E : INC A : CMP.b #$07 : BCC .reset_inactive_component
        
        BRL .draw
    
    .reset_inactive_component
    
        STA $0C5E
        
        LDA.b #$01 : STA $7F0000, X
        LDA.b #$03 : STA $7F0008, X
        
        PHX
        
        LDA.b #$03 : STA $06
    
    .adjust_next_explosion_position
    
        STZ $00
        STZ $01
        
        STZ $02
        STZ $03
        
        STX $04
        
        LDX.b #$00
        
        ; What was the index into the blast wall data tables that was used
        ; to set this up?
        ; \task Check if this branch ever is taken. How many blast walls are
        ; in the game? Skull Woods and Ganon's Tower are all I can think of
        ; at the moment.
        LDA $7F001C : CMP.b #$04 : BCS .diverge_vertically
        
        ; (Diverge horizontally in this case.)
        LDX.b #$02
    
    .diverge_vertically
    
        LDA.b #$0D : STA $00, X
        
        LDA $06 : AND.b #$02 : BEQ .first_two_adjustments
        
        ; Invert the sign of the variable. (Couldn't we just do this shit in
        ; 16-bit? Anyways, it looks like the point of this is to allow the
        ; explosions to diverge out in opposing directions.
        ; \optimize Maybe do this in 16-bit logic.
        LDA $00, X : EOR.b #$FF : INC A : STA $00, X
                     LDA.b #$FF         : STA $01, X
    
    .first_two_adjustments
    
        LDA $04 : ASL #3 : STA $08
        
        LDA $06 : ASL A : ADD $08 : TAX
        
        REP #$20
        
        LDA $7F0020, X : ADD $00 : STA $7F0020, X
        LDA $7F0030, X : ADD $02 : STA $7F0030, X
        
        SUB $E2 : STA $72
        
        SEP #$20
        
        ; The explosion would be off screen, so don't play the sfx.
        LDA $73 : BNE .anoplay_explosion_sfx
        
        LDA $72
        
        JSR Ancilla_SetSfxPan_NearEntity : ORA.b #$0C : STA $012E
    
    .anoplay_explosion_sfx
    
        LDX $04
        
        DEC $06 : BPL .adjust_next_explosion_position
        
        PLX
    
    .draw
    
        LDX $0380
        
        LDA $7F0000, X : BEQ .dont_draw_component
        
        LDY.b #$07
        
        ; As previously noted, this branch should almost certainly never
        ; happen. I would label it as 'never' but there's another branch
        ; that points there and forms a loop, and that would be confusing.
        CPX.b #$01 : BEQ .indexing_second_component
        
        LDY.b #$03
    
    .indexing_second_component
    .draw_next_explosion
    
        PHY : PHX
        
        TYA : ASL A : TAX
        
        REP #$20
        
        LDA $7F0020, X : STA $00
        LDA $7F0030, X : STA $02
        
        SEP #$20
        
        PLX : PLY
        
        JSR BlastWall_DrawExplosion
        
        SEP #$20
        
        DEY : TYA : AND.b #$03 : CMP.b #$03 : BNE .draw_next_explosion
    
    .dont_draw_component
    
        LDA $0C5E : CMP.b #$06 : BNE .return
        
        LDX.b #$01
    
    .find_active_component
    
        LDA $7F0000, X : BNE .return
        
        DEX : BPL .find_active_component
        
        ; Self terminate when there are no active components left.
        STZ $0C4A
        
        STZ $0C4B
        
        STZ $0112
    
    ; *$42752 ALTERNATE ENTRY POINT
    shared Ancilla_RestoreIndex:
    
    .return
    
        LDX $0FA0
        
        RTS
    }

; ==============================================================================

    ; *$42756-$427AA LOCAL
    BlastWall_DrawExplosion:
    {
        PHX : PHY
        
        LDA.b #$30 : STA $65
                     STZ $64
        
        LDA $7F0000, X : TAY
        
        LDA Bomb_Draw.num_oam_entries, Y : STA $08
        
        LDA Ancilla_Bomb.chr_groups, Y : TAY
        
        LDA Bomb_Draw.chr_start_offset, Y : ASL A : TAX
        
        ASL A : STA $04
                STZ $05
        
        STZ $0A
        
        LDA.b #$32 : STA $0B
        
        STZ $06
        STZ $07
        
        LDA.b #$18
        
        LDY $0FB3 : BEQ .dont_sort_sprites
        
        JSL OAM_AllocateFromRegionD
        
        BRA .finished_allocating
    
    .dont_sort_sprites
    
        JSL OAM_AllocateFromRegionA
    
    .finished_allocating
    
        REP #$20
        
        LDA $00 : SUB $E8 : STA $0C
        LDA $02 : SUB $E2 : STA $0E
        
        SEP #$20
        
        LDY.b #$00
        
        JSR Bomb_DrawExplosion
        
        PLY : PLX
        
        RTS
    }

; ==============================================================================

    ; *$427AB-$4280C LOCAL
    Bomb_DrawExplosion:
    {
    
    .next_oam_entry
    
        LDA .chr, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        ; offset index for placing the sprites?
        STX $72
        
        REP #$20
        
        STZ $74
        
        LDA $06 : ASL #2 : ADD $04 : TAX
        
        LDA .y_offsets, X : ADD $0C : STA $00
        LDA .x_offsets, X : ADD $0E : STA $02
        
        SEP #$20
        
        LDX $72
        
        JSR Ancilla_SetSafeOam_XY
        
        LDA .chr, X : STA ($90), Y : INY
        
        LDA .properties, X : AND.b #$C1
                             ORA $65
                             ORA $0B    : STA ($90), Y : INY
        
        STY $72
        STX $73
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        TXA : LSR A : TAX
        
        LDA .oam_sizes, X : ORA $75 : STA ($92), Y
        
        LDX $73
        LDY $72
    
    .skip_oam_entry
    
        INX #2
        
        ; Compare with the number of sprites needed for the bomb
        INC $06 : LDA $06 : CMP $08 : BNE .next_oam_entry
        
        RTS
    }

; ==============================================================================
