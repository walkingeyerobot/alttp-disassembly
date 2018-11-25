
; ==============================================================================

    ; \note This first label indicates that they probably had one here in the
    ; original source but never filled anything in. Which would be why the
    ; pointer table would point to this location is obviously just data,
    ; instead of the code it's supposed to be.
    ; So perhaps 'incomplete' would be a better name than unused. Dunno.
    ; $4280D-$4280E DATA
    Ancilla_Unused_14:
    pool Ancilla_JumpSplash:
    {
    
    .chr
        db $AC, $AE
    }

; ==============================================================================

    ; *$4280F-$428E2 JUMP LOCATION
    Ancilla_JumpSplash:
    {
        LDA $11 : BNE .draw
        
        DEC $03B1, X : BPL .animation_delay
        
        STZ $03B1, X
        
        LDA.b #$01 : STA $0C5E, X
    
    .animation_delay
    
        LDA $0C5E, X : BEQ .draw
        
        LDA $0C22, X : ADD.b #$FC : STA $0C22, X : STA $0C2C, X
        
        CMP.b #$E8 : BCS .speed_not_maxed
        
        ; Self terminate once the splash reaches a certain 'speed'.
        STZ $0C4A, X
        
        LDA $02E0 : BNE .player_is_bunny
        
        LDA $5D : CMP.b #$04 : BNE .not_swimming
    
    .player_is_bunny
    
        LDA $0345 : BEQ .not_touching_deep_water
        
        PHX
        
        JSL Link_CheckSwimCapability
        
        PLX
    
    .not_swimming
    .not_touching_deep_water
    
        RTS
    
    .speed_not_maxed
    
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
    
    .draw
    
        JSR Ancilla_PrepOamCoord
        
        LDA $0C04, X : STA $06
        LDA $0C18, X : STA $07
        
        REP #$20
        
        LDA $22 : SUB $06           : STA $08
        LDA $22 : ADD $08 : SUB $E2 : STA $08
        
        LDA $06 : ADD.w #$000C : SUB $E2 : STA $06
        
        SEP #$20
        
        PHX
        
        LDA $0C5E, X : STA $0A : TAX
        
        LDA.b #$01 : STA $72
        
        LDY.b #$00 : STY $0C
    
    .next_oam_entry
    
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X          : STA ($90), Y : INY
        LDA.b #$24 : ORA $0C : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : JSR Ancilla_CustomAllocateOam
        
        LDA $08 : STA $02
        
        LDA.b #$40 : STA $0C
        
        DEC $72 : BPL .next_oam_entry
        
        ; Commit one more sprite to the oam buffer.
        LDA $06 : STA $02
        
        JSR Ancilla_SetOam_XY
        
        LDA.b #$C0 : STA ($90), Y : INY
        LDA.b #$24 : STA ($90), Y : INY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        ; \bug(maybe) 
        LDA $0A : CMP.b #$01 : BNE .top_x_bit_zero
        
        STA ($92), Y
    
    .top_x_bit_zero
    
        PLX
        
        RTS
    }

; ==============================================================================

