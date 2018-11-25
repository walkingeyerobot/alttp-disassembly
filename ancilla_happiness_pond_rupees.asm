
; ==============================================================================

    ; Ancilla 0x42 (rupees thrown into pond of wishing)
    
    ; *$447DE-$44818 JUMP LOCATION
    Ancilla_HappinessPondRupees:
    {
        LDA.b #$02 : STA $0309
                     STZ $0308
        
        LDX.b #$09
    
    .next_rupee_slot
    
        LDA $7F586C, X : BEQ .inactive_rupee
        
        PHX
        
        JSR HappinessPondRupees_ExecuteRupee
        
        PLX
        
        LDA $7F58AA, X : CMP.b #$02 : BNE .dont_deactivate_rupee
        
        LDA.b #$00 : STA $7F586C, X
    
    .inactive_rupee
    .dont_deactivate_rupee
    
        DEX : BPL .next_rupee_slot
        
        LDX.b #$09
    
    .find_active_rupee_loop
    
        LDA $7F586C, X : BNE .not_all_inactive
        
        DEX : BPL .find_active_rupee_loop
        
        LDX $0FA0
        
        STZ $0C4A, X
        
        RTS
    
    .not_all_inactive
    
        ; \wtf Could be wrong, but this is probably not necessary since
        ; we're done and we'll be moving on to the next Ancilla anyways, so
        ; restoring the index is not useful at all.
        BRL Ancilla_RestoreIndex
    }

; ==============================================================================

    ; *$44819-$448BD LOCAL
    HappinessPondRupees_ExecuteRupee:
    {
        ; \wtf Wait, why does this need 4 oam slots exactly?
        LDA.b #$10 : JSR Ancilla_AllocateOam
        
        PHX
        
        LDY $0FA0
        
        JSR HappinessPondRupee_LoadRupeeeState
        
        TYX
        
        LDA $0C54, X : BEQ .not_in_splash_state
        
        LDA $11 : BNE .just_draw_splash
        
        LDA $0C68, X : BNE .just_draw_splash
        
        LDA.b #$06 : STA $0C68, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$05 : BNE .just_draw_splash
        
        INC $0C54, X
        
        BRL .return
    
    .just_draw_splash
    
        JSR Ancilla_ObjectSplash.draw
        
        BRA .return
    
    .not_in_splash_state
    
        LDA $11 : BNE .just_draw_item
        
        LDA $0C68, X : BNE .just_draw_item
        
        LDA $0294, X : SUB.b #$02 : STA $0294, X
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveAltitude
        
        LDA $029E, X : BPL .just_draw_item
        CMP.b #$E4   : BCS .just_draw_item
        
        LDA.b #$E4 : STA $029E, X
        
        LDA $0BFA, X : ADD.b #$1E : STA $0BFA, X
        LDA $0C0E, X : ADC.b #$00 : STA $0C0E, X
        
        LDA $0C04, X : ADD.b #$FC : STA $0C04, X
        LDA $0C18, X : ADC.b #$FF : STA $0C18, X
        
        STZ $0C5E, X
        
        LDA.b #$06 : STA $0C68, X
        
        LDA.b #$28 : JSR Ancilla_DoSfx2
        
        INC $0C54, X
        
        BRA .return
    
    .just_draw_item
    
        LDA.b #$02 : STA $0BF0, X
        LDA.b #$00 : STA $0C7C, X
        
        JSR Ancilla_WishPondItem.draw
    
    .return
    
        TXY
        
        PLX
        
        JSR HappinessPondRupees_StoreRupeeState
        
        RTS
    }

; ==============================================================================

    ; *$448BE-$44923 LOCAL
    HappinessPondRupees_LoadRupeeeState:
    {
        ; \wtf All of these arrays appear to have been allocated 0x0C bytes
        ; apart, except there's a 2 byte gap between the arrays starting at
        ; $7F586C and $7F587A. Why?
        
        LDA $7F5824, X : STA $0BFA, Y
        LDA $7F5830, X : STA $0C0E, Y
        
        LDA $7F583C, X : STA $0C04, Y
        LDA $7F5848, X : STA $0C18, Y
        
        LDA $7F5854, X : STA $029E, Y
        
        LDA $7F5800, X : STA $0C22, Y
        
        LDA $7F580C, X : STA $0C2C, Y
        
        LDA $7F5818, X : STA $0294, Y
        
        LDA $7F5886, X : STA $0C36, Y
        
        LDA $7F5892, X : STA $0C40, Y
        
        LDA $7F589E, X : STA $02A8, Y
        
        LDA $7F587A, X : STA $0C5E, Y
        
        LDA $7F58AA, X : STA $0C54, Y
        
        LDA $7F5860, X : BEQ .timer_expired
        
        DEC A
    
    .timer_expired
    
        STA $0C68, Y
        
        RTS
    }

; ==============================================================================

    ; *$44924-$44986 LOCAL
    HappinessPondRupees_StoreRupeeState:
    {
        LDA $0BFA, Y : STA $7F5824, X
        LDA $0C0E, Y : STA $7F5830, X
        
        LDA $0C04, Y : STA $7F583C, X
        LDA $0C18, Y : STA $7F5848, X
        
        LDA $029E, Y : STA $7F5854, X
        
        LDA $0C22, Y : STA $7F5800, X
        
        LDA $0C2C, Y : STA $7F580C, X
        
        LDA $0294, Y : STA $7F5818, X
        
        LDA $0C36, Y : STA $7F5886, X
        
        LDA $0C40, Y : STA $7F5892, X
        
        LDA $02A8, Y : STA $7F589E, X
        
        LDA $0C5E, Y : STA $7F587A, X
        
        LDA $0C68, Y : STA $7F5860, X
        
        LDA $0C54, Y : STA $7F58AA, X
        
        RTS
    }

; ==============================================================================
