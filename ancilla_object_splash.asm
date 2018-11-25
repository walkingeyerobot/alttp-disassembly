
; ==============================================================================

    ; $44987-$449CC DATA
    pool Ancilla_TransmuteToObjectSplash:
    {
    
    }

; ==============================================================================

    ; *$449CD-$44A84 LONG BRANCH LOCATION
    Ancilla_TransmuteToObjectSplash:
    {
        ; turn the current effect into a splash effect (0x3D)
        ; the rest of the routine initializes the new effect
        
        LDA.b #$3D : STA $0C4A, X
        
        STZ $0C5E, X
        
        LDA.b #$06 : STA $0C68, X
        
        LDA $0BFA, X : ADD.b #$0C : STA $0BFA, X
        LDA $0C0E, X : ADC.b #$00 : STA $0C0E, X
        
        LDA $0C04, X : ADD.b #$F8 : STA $0C04, X
        LDA $0C18, X : ADC.b #$FF : STA $0C18, X
        
        LDA.b #$28 : JSR Ancilla_DoSfx2
    
    ; *$44A01 ALTERNATE ENTRY POINT
    shared Ancilla_ObjectSplash:
    
        LDA.b #$08
        
        JSR Ancilla_AllocateOam
        
        LDA $11 : BNE .draw
        
        LDA $0C68, X : BNE .draw
        
        LDA.b #$06 : STA $0C68, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$05 : BNE .draw
        
        STZ $0C4A, X
        
        RTS
    
    ; *$44A22 ALTERNATE ENTRY POINT
    .draw
    
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $04
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDY.b #$00
        
        STZ $0C
        
        LDA $0C5E, X : ASL A : TAX
    
    .next_oam_entry
    
        LDA $C987, X : CMP.b #$FF : BEQ .skip_oam_entry
        
        PHX : TXA : ASL A : TAX
        
        REP #$20
        
        LDA $C99B, X : ADD $04 : STA $00
        LDA $C9AF, X : ADD $06 : STA $02
        
        SEP #$20
        
        PLX
        
        JSR Ancilla_SetOam_XY
        
        LDA $C987, X              : STA ($90), Y : INY
        LDA $C991, X : ORA.b #$24 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA $C9C3, X : STA ($92), Y
        
        PLY
    
    .skip_oam_entry
    
        INX
        
        INC $0C : LDA $0C : CMP.b #$02 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
