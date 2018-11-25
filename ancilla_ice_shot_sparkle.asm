
; ==============================================================================

    ; $40405-$40434 DATA
    pool Ancilla_IceShotSparkle:
    {
    
    .x_offsets
        db 2, 7, 6, 1, 1, 7, 7,  1
        db 0, 7, 8, 1, 4, 9, 4, -1
        
    .y_offsets
        db 2, 3, 8, 7,  1, 1, 7, 7
        db 1, 0, 7, 8, -1, 4, 9, 4
        
    .chr
        db $83, $83, $83, $83, $B6, $80, $B6, $80
        db $B7, $B6, $B7, $B6, $B7, $B6, $B7, $B6
    }

; ==============================================================================

    ; *$40435-$404BF JUMP LOCATION
    Ancilla_IceShotSparkle:
    {
        !numSprites = $05
        
        LDA $0C68, X : BNE .still_alive
        
        STZ $0C4A, X
    
    .still_alive
    
        LDA $11 : BNE .no_movement
        
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveVert
    
    .no_movement
    
        JSR Ancilla_BoundsCheck
        
        LDY.b #$04
        LDA.b #$0B
    
    .next_slot
    
        CMP $0C4A, Y : BEQ .match
        
        DEY : BPL .next_slot
    
    .match
    
        LDA $0280, Y : BEQ .normal_priority
        
        LDA.b #$30 : STA $04
    
    .normal_priority
    
        LDA.b #$10
        
        LDY $0FB3 : BEQ .sort_sprites
        
        LDY $0C7C, X : BNE .other_floor
        
        JSL OAM_AllocateFromRegionD
        
        BRA .draw
    
    .other_floor
    
        JSL OAM_AllocateFromRegionE
        
        BRA .draw
    
    .sort_sprites
    
        JSL OAM_AllocateFromRegionA
    
    .draw
    
        LDY.b #$00
        
        LDA.b #$03 : STA !numSprites
        
        LDA $0C68, X : AND.b #$1C : STA $06
        
        PHX
    
    .next_sprite
    
        LDA !numSprites : ORA $06 : TAX
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y : INY
        LDA $01 : ADD .y_offsets, X : STA ($90), Y : INY
        LDA .chr, X                 : STA ($90), Y : INY
        LDA $04 : ORA.b #$04        : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
        
        DEC !numSprites : BPL .next_sprite
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $404C0-$404C7 DATA
    pool IceShotSparkle_Spawn:
    {
    
    .x_speeds
        db -4,  4,  0,  0
    
    .y_speeds
        db  0,  0, -4,  4
    }

; ==============================================================================

    ; *$404C8-$40514 LONG BRANCH LOCATION
    IceShotSparkle_Spawn:
    {
        ; Generates sparkles for.... the ice shot effect?
        
        LDA $11 : BNE .return
        
        DEC $0BF0, X : BPL .return
        
        LDA.b #$05 : STA $0BF0, X
        
        LDY.b #$09
    
    .nextSlot
    
        LDA $0C4A, Y : BEQ .emptySlot
        
        DEY : BPL .nextSlot
    
    .return
    
        RTS
    
    .emptySlot
    
        LDA.b #$13 : STA $0C4A, Y
        LDA.b #$0F : STA $0C68, Y
        
        LDA $0C72, X
        
        PHX
        
        TAX
        
        LDA .y_speeds, X : STA $0C2C, Y
        
        LDA .x_speeds, X : STA $0C22, Y
        
        PLX
        
        LDA $0C04, X : STA $0C04, Y
        
        LDA $0BFA, X : STA $0BFA, Y
        
        LDA $0C7C, X : STA $0C7C, Y
        
        LDA.b #$00 : STA $0C90, Y
        
        RTS
    }

; ==============================================================================
