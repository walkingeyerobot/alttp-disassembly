
; ==============================================================================

    ; $40515-$4051A DATA
    pool Ancilla_SomarianBlast:
    {
    
    .delay_masks
        db $07, $03, $01, $00, $00, $00
    }

; ==============================================================================

    ; *$4051B-$40561 JUMP LOCATION
    Ancilla_SomarianBlast:
    {
        ; Special Effect 0x01: Not sure what this is in the game
        
        LDA $11 : BNE .just_draw
        
        LDY $0C54, X
        
        ; For the first three states, this will slow the object down.
        LDA $1A : AND .delay_masks, Y : BNE .movement_delay
        
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveVert
    
    .movement_delay
    
        LDA $0C68, X : BNE .delay
        
        ; Reset the delay countdown timer to 3.
        LDA.b #$03 : STA $0C68, X
        
        LDA $0C54, X : INC A : CMP.b #$06 : BCC .not_last_state
        
        ; Eventually the object will toggle between states 4 and 5.
        LDA.b #$04
    
    .not_last_state
    
        STA $0C54, X
    
    .delay
    
        JSR Ancilla_CheckSpriteCollision : BCS .collided
        
        JSR Ancilla_CheckTileCollisionStaggered : BCC .no_collision
    
    .collided
    
        ; Transmute into another object type (sword beam spreading out?)
        LDA.b #$04 : STA $0C4A, X
        LDA.b #$07 : STA $0C68, X
        LDA.b #$10 : STA $0C90, X
    
    .no_collision
    .just_draw
    
        BRL SomarianBlast_Draw
    }

; ==============================================================================

    ; $40562-$40621 DATA
    pool SomarianBlast_Draw:
    {
    
    .chr_a
        db $50, $50, $44, $44, $52, $52
        db $50, $50, $44, $44, $51, $51
        db $43, $43, $42, $42, $41, $41
        db $43, $43, $42, $42, $40, $40
    
    .chr_b
        db $50, $50, $44, $44, $51, $51
        db $50, $50, $44, $44, $52, $52
        db $43, $43, $42, $42, $40, $40
        db $43, $43, $42, $42, $41, $41
    
    .properties_a
        db $C0, $C0, $C0, $C0, $80, $C0
        db $40, $40, $40, $40, $00, $40
        db $40, $40, $40, $40, $40, $C0
        db $00, $00, $00, $00, $00, $80
    
    .properties_b
        db $80, $80, $80, $80, $80, $C0
        db $00, $00, $00, $00, $00, $40
        db $C0, $C0, $C0, $C0, $40, $C0
        db $80, $80, $80, $80, $00, $80
    
    .x_offsets_a
        db 0, 0, 0, 0, 4, 4
        db 0, 0, 0, 0, 4, 4
        db 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0
     
     .x_offsets_b
        db 8, 8, 8, 8, 4, 4
        db 8, 8, 8, 8, 4, 4
        db 0, 0, 0, 0, 8, 8
        db 0, 0, 0, 0, 8, 8
    
    .y_offsets_a
        db 128, 0, 0, 0, 0, 0
        db   0, 0, 0, 0, 0, 0
        db   0, 0, 0, 0, 4, 4
        db   0, 0, 0, 0, 4, 4
    
    .y_offsets_b
        db   0, 0, 0, 0, 8, 8
        db 128, 0, 0, 0, 8, 8
        db 128, 8, 8, 8, 4, 4
        db 128, 8, 8, 8, 4, 4
    }

; ==============================================================================

    ; *$40622-$40629 POOL
    pool Ancilla_BoundsCheck:
    {
    
    .self_terminate
    
        PLA : PLA
        
        STZ $0C4A, X
        
        RTS
    
    .unknown
        db $BC, $7C
    }
    
; ==============================================================================

    ; *$4062A-$4064D LOCAL
    Ancilla_BoundsCheck:
    
        ; Load a value based on which floor the special object is on.
        LDY $0C7C, X
        
        LDA .unknown, Y : STA $04
        
        LDY $0C86, X
        
        ; If the object is close to the edge of the screen, make it
        ; self-terminate.
        LDA $0C04, X : SUB $E2 : CMP.b #$F4 : BCS .self_terminate
        
        ; Get the x coordinate for OAM
        STA $00
        
        LDA $0BFA, X : SUB $E8 : CMP.b #$F0 : BCS .self_terminate
        
        ; Get the y coordinate for OAM
        STA $01
        
        RTS
    }

; ==============================================================================

    ; $4064E-$4064F DATA
    pool SomarianBlast_Draw:
    {
        ; Interesting. Somarian blasts were designed to have more than one
        ; palette option?
    
    .palettes
        db $02, $06
    }

; ==============================================================================

    ; *$40650-$406D1 LONG BRANCH LOCATION
    SomarianBlast_Draw:
    {
        JSR Ancilla_BoundsCheck
        
        LDY $0C5E, X
        
        LDA $04 : ORA .palettes, Y : STA $04
        
        LDA $0280, X : BEQ .normal_priority
        
        LDA.b #$30 : TSB $04
    
    .normal_priority
    
        LDY.b #$00
        
        ; X = (direction * 6) + state_index
        LDA $0C72, X : ASL #2 : ADC $0C72, X : ADC $0C72, X : ADC $0C54, X : TAX
        
        LDA .x_offsets_a, X : ADD $00              : STA ($90), Y
        LDA .x_offsets_b, X : ADD $00 : LDY.b #$04 : STA ($90), Y
        
        ; The sprite consists of two oam entries, and we're calling them
        ; "part a" and "part b" here. Since this object encompasses both the
        ; separation of the somarian block into blasts and the blasts themselves,
        ; it's natural not all of the states of this object will necessarily use
        ; oam entries.
        LDA .y_offsets_a, X : BMI .hide_part_a
        
        ADD $01 : LDY.b #$01 : STA ($90), Y
    
    .hide_part_a
    
        LDA .y_offsets_b, X : BMI .hide_part_b
        
        ADD $01 : LDY.b #$05 : STA ($90), Y
    
    .hide_part_b
    
        LDA .chr_a, X        : ADD.b #$82 : LDY.b #$02 : STA ($90), Y
        LDA .chr_b, X        : ADD.b #$82 : LDY.b #$06 : STA ($90), Y
        LDA .properties_a, X : ORA $04    : LDY.b #$03 : STA ($90), Y
        LDA .properties_b, X : ORA $04    : LDY.b #$07 : STA ($90), Y
        
        ; Designate both of these sprites as small.
        ; \bug Not a serious bug, but if it's true, it might mean that its
        ; calculations near screen edges are not quite accurate, because it's
        ; assuming that the 9th X bit is always zero.
        ; aka shoddy oam offset calculation. However, there might be other safe
        ; safeguards in place that kill the sprite before it ever gets in that
        ; situation anyway.
        LDY #$00 : TYA : STA ($92), Y
                   INY : STA ($92), Y
        
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================
