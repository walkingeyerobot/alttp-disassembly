
; ==============================================================================

    ; *$428E3-$428E4 JUMP LOCATION
    Ancilla_Unused_25:
    pool Ancilla_HitStars:
    {
    
    .chr
        db $90, $91
    }
    
; ==============================================================================

    ; *$428E5-$42996 ALTERNATE ENTRY POINT
    Ancilla_HitStars:
    
        ; Special object 0x16 - hammer stars
        DEC $039F, X : BMI .begin_doing_stuff
        
        ; Do nothing for the first couple frames, not even drawing.
        RTS
    
    .begin_doing_stuff
    
        STZ $039F, X
        
        LDA $11 : BNE .just_draw
        
        DEC $03B1, X : BPL .delay
        
        STZ $03B1, X
        
        LDA.b #$01 : STA $0C5E, X
    
    .delay
    
        LDA $0C5E, X : BEQ .just_draw
        
        LDA $0C22, X : ADD.b #$FC : STA $0C22, X : STA $0C2C, X
        
        CMP.b #$E8 : BCS .dont_self_terminate
        
        STZ $0C4A, X
        
        RTS
    
    .dont_self_terminate
    
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
    
    .just_draw
    
        JSR Ancilla_PrepOamCoord
        
        LDA $0C04, X : STA $06
        LDA $0C18, X : STA $07
        
        LDA $038A, X : STA $72
        LDA $038F, X : STA $73
        
        REP #$20
        
        LDA $72 : SUB $06 : STA $08
        
        LDA $72 : ADD $08 : SUB.w #$0008 : SUB $E2 : STA $08
        
        SEP #$20
        
        LDA $0C54, X : CMP.b #$02 : BNE .dont_alter_oam_allocation
        
        LDA.b #$08 : JSR Ancilla_AllocateOam_B_or_E
    
    .dont_alter_oam_allocation
    
        PHX
        
        LDA.b #$01 : STA $72
        
        LDA $0C5E, X : TAX
        
        LDY.b #$00 : STY $73
    
    .next_oam_entry
    
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X : STA ($90), Y : INY
        
        LDA.b #$04 : ORA $65 : ORA $73 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
        
        JSR HitStars_UpdateOamBufferPosition
        
        ; Adjust the hflip on the second iteration.
        LDA.b #$40 : STA $73
        
        ; Use a different x coordinate on the second iteration. (One which
        ; is in a different direction from the first).
        LDA $08 : STA $02
        
        DEC $72 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
