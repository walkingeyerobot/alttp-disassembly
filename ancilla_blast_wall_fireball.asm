
; ==============================================================================

    ; $42A32-$42A34 DATA
    pool Ancilla_BlastWallFireball:
    {
    
    .chr
        db $9D, $9C, $8D
    }

; ==============================================================================

    ; *$42A35-$42A9F JUMP LOCATION
    Ancilla_BlastWallFireball:
    {
        LDA $11 : BNE .just_draw
        
        LDA $0C5E, X : ADD.b #$02   : STA $0C5E, X
                       ADD $0C22, X : STA $0C22, X
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        LDA $7F0040, X : DEC A : STA $7F0040, X : BPL .still_active
        
        STZ $0C4A, X
        
        RTS
    
    .just_draw
    .still_active
    
        LDA.b #$04
        
        LDY $0FB3 : BEQ .dont_sort_sprites
        
        JSL OAM_AllocateFromRegionD
        
        BRA .oam_allocation_determined
    
    .dont_sort_sprites
    
        JSL OAM_AllocateFromRegionA
    
    .oam_allocation_determined
    
        LDY.b #$00
        
        LDA $7F0040, X : STA $06 : AND.b #$08 : BNE .just_first_chr
        
        LDY.b #$01
        
        LDA $06 : AND.b #$04 : BNE .use_second_chr
        
        ; All that leaves is the third possible tile.
        LDY.b #$02
    
    .use_first_chr
    .use_second_chr
    
        LDA .chr, Y : STA $06
        
        JSR Ancilla_PrepOamCoord
        
        LDY.b #$00
        
        JSR Ancilla_SetOam_XY
        
        LDA $06    : STA ($90), Y : INY
        LDA.b #$22 : STA ($90), Y
        
        LDA.b #$00 : STA ($92)
        
        RTS
    }

; ==============================================================================
