
    ; \note This object doesn't self terminate. It must be that the
    ; polyhedral cyrstal submodule in the Dungoen module terminates it
    ; or related code does when gearing up to the leave the dungeon.
    
; ==============================================================================

    ; *$44BE4-$44C92 LOCAL
    Ancilla_TransmuteToRisingCrystal:
    {
        ; Start up 3D crystal effect
        LDA.b #$3E : STA $0C4A, X
        
        STZ $0C22, X
        STZ $0C2C, X
        STZ $0C36, X
    
    ; *$44BF2 ALTERNATE ENTRY POINT
    shared Ancilla_RisingCrystal:
    
        STZ $029E, X
        
        JSR Ancilla_AddSwordChargeSpark
        
        LDA $0C22, X : ADD.b #$FF : CMP.b #$F0 : BCS .ascent_speed_maxed
        
        LDA.b #$F0
    
    .ascent_speed_maxed
    
        STA $0C22, X
        
        JSR Ancilla_MoveVert
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        REP #$20
        
        LDA $00 : SUB $0122 : CMP.w #$0049 : BCS .below_target_y_position
        
        ; Keep position fixed at 0x0049
        LDA.w #$0049 : ADD $0122 : STA $00
        
        SEP #$20
        
        LDA $00 : STA $0BFA, X
        LDA $01 : STA $0C0E, X
        
        LDA $11 : BNE .delay_giving_crystal
        
        PHX
        
        LDA $040C : LSR A : TAX
        
        ; Give player the crystal associated with this dungeon
        LDA $7EF37A : ORA.l MilestoneItem_Flags, X : STA $7EF37A
        
        LDA.b #$18 : STA $11
        
        STZ $B0
        
        REP #$20
        
        LDX.b #$00
        LDA.w #$0000
    
    .zero_aux_bg_palettes
    
        STA $7EC340, X : STA $7EC360, X : STA $7EC380, X 
        STA $7EC3A0, X : STA $7EC3C0, X : STA $7EC3E0, X
        
        INX #2 : CPX.b #$20 : BNE .zero_aux_bg_palettes
        
        STA $7EC007 : STA $7EC009
        
        SEP #$20
        
        PLX
    
    .delay_giving_crystal
    .below_target_y_position
    
        SEP #$20
        
        JSR Ancilla_PrepAdjustedOamCoord
        
        REP #$20
        
        LDA $00 : STA $06
        
        SEP #$20
        
        JSR Ancilla_ReceiveItem.draw
        
        RTS
    }

; ==============================================================================
