
; ==============================================================================

    ; $46068-$46077 DATA
    pool AddSomarianBlock:
    {
    
    .initial_collision_y_offsets
        dw -8, 31, 17, 17
    
    .initial_collision_x_offsets
        dw  8,  8, -8, 23
    }

; ==============================================================================

    ; *$46078-$46160 LONG
    AddSomarianBlock:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_Spawn : BCC .spawn_success
        
        BRL .spawn_failed
    
    .spawn_success
    
        PHX : STX $00
        
        LDX.b #$04
    
    .find_somarian_block_loop
    
        CPX $00 : BEQ .ignore_slot
        
        LDA $0C4A, X : CMP.b #$2C : BNE .not_somarian_block
        
        STX $02
        
        LDA $02EC : DEC A : CMP $02 : BNE .not_closest_carryable_ancilla
        
        ; Zero that index anyways so the player can't pick it up (it's 
        ; being terminated anyways)
        STZ $02EC
    
    .not_closest_carryable_ancilla
    
        JSL AddSomarianBlockDivide
        
        PLX
        
        STZ $0C4A, X
        STZ $0646
        
        LDA $5E : CMP.b #$12 : BNE .dont_reset_player_speed
        
        STZ $48
        STZ $5E
    
    .dont_reset_player_speed
    
        BRL .return
    
    .ignore_slot
    .not_somarian_block
    
        DEX : BPL .find_somarian_block_loop
        
        PLX
        
        LDA.b #$2A : JSR Ancilla_DoSfx3_NearPlayer
        
        STZ $0C54, X
        STZ $0C22, X
        STZ $0C2C, X
        STZ $0C5E, X
        STZ $03B1, X
        STZ $039F, X
        STZ $03A4, X
        STZ $03C5, X
        
        LDA.b #$0C : STA $0394, X
        LDA.b #$12 : STA $0C68, X
        
        STZ $0385, X
        STZ $029E, X
        STZ $0380, X
        STZ $03EA, X
        STZ $0BF0, X
        
        LDA.b #$09 : STA $03A9, X
        
        STZ $03D5, X
        
        LDA $2F : LSR A : STA $0C72, X
        
        JSL Ancilla_CheckInitialTileCollision_Class2 : BCC .enough_space
        
        ; Basically, if the player is so close to a collision surface that
        ; the block could get embedded in a wall, just place it where the
        ; player actually is to be safe.
        REP #$20
        
        LDA $20 : ADD.w #$0010 : STA $00
        LDA $22 : ADD.w #$0008 : STA $02
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $02 : STA $0C04, X
        LDA $03 : STA $0C18, X
        
        BRA .return
    
    .enough_space
    
        LDY $2F
        
        LDA $20 : ADD .initial_collision_y_offsets+0, Y : STA $0BFA, X
        LDA $21 : ADC .initial_collision_y_offsets+1, Y : STA $0C0E, X
        
        LDA $22 : ADD .initial_collision_x_offsets+0, Y : STA $0C04, X
        LDA $23 : ADC .initial_collision_y_offsets+1, Y : STA $0C18, X
        
        JSR SomarianBlock_CheckForTransitLine
        
        BRA .return
    
    .spawn_failed
    
        LDX.b #$04 : JSL LinkItem_ReturnUnusedMagic
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $46161-$46190 DATA
    pool SomarianBlock_CheckForTransitLine:
    {
    
    .y_offsets
        dw -16, -16, -16,  16,  16,  16
        dw  -8,   0,   8,  -8,   0,   8
    
    .x_offsets
        dw  -8,   0,   8,  -8,   0,   8
        dw -16, -16, -16,  16,  16,  16
    }

; ==============================================================================

    ; *$46191-$461F8 LOCAL
    SomarianBlock_CheckForTransitLine:
    {
        ; If there are no transit lines, we need not even worry about this.
        LDA $03F4 : BEQ .return
        
        LDY.b #$16
    
    .next_offset
    
        LDA $0BFA, X : ADD .y_offsets+0, Y : STA $00 : STA $72
        LDA $0C0E, X : ADC .y_offsets+1, Y : STA $01 : STA $73
        
        LDA $0C04, X : ADD .x_offsets+0, Y : STA $02 : STA $74
        LDA $0C18, X : ADC .x_offsets+1, Y : STA $03 : STA $75
        
        PHY
        
        LDA $0280, X : PHA
        
        JSR Ancilla_CheckTargetedTileCollision
        
        PLA : STA $0280, X
        
        PLY
        
        LDA $03E4, X : CMP.b #$B6 : BEQ .transit_node
                       CMP.b #$BC : BEQ .transit_node
        
        DEY #2 : BPL .next_offset
        
        BRA .return
    
    .transit_node
    
        LDA $72 : STA $0BFA, X
        LDA $73 : STA $0C0E, X
        
        LDA $74 : STA $0C04, X
        LDA $75 : STA $0C18, X
        
        JSL AddSomarianPlatformPoof
    
    .return
    
        RTS
    }

; ==============================================================================
