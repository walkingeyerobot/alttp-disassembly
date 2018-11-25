
; ==============================================================================

    ; *$446F2-$447DD JUMP LOCATION
    Ancilla_WishPondItem:
    {
        ; Special Object 0x28 (item sprite thrown into ponds)
        LDA.b #$10
        
        JSR Ancilla_AllocateOam
        
        LDA $11 : BEQ .execute
                  BRL .draw
    
    .execute
    
            LDA $0C68, X : BNE .draw
        
        LDA.b #$02 : STA $0309
        
        STZ $0308
        
        ; Begin z-deceleation (i.e. simulating gravity).
        LDA $0294, X : SUB.b #$02 : STA $0294, X
        
        JSR Ancilla_MoveAltitude
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        
        LDA $029E, X : BPL .draw
        CMP.b #$E4   : BCS .draw
        
        LDA.b #$E4 : STA $029E, X
        
        LDY $0C5E, X
        
        LDA $0BFA, X : ADD.b #$12 : STA $0BFA, X
        LDA $0C0E, X : ADC.b #$00 : STA $0C0E, X
        
        LDA.b #$08 : STA $00
        
        ; \bug(confirmed) This is suposed to be a long address mode, not
        ; local. Looks like even the Z3 programmers and their fancy assembler
        ; or compiler or whatever the hell they used, were also fallible.
        ; This particular read indexes into the code region of the
        ; "ice shot sparkle" ancilla, if you belee dat.
        LDA $8450, Y : BNE .dont_use_4_pixel_offset
        
        LDA.b #$04 : STA $00
    
    .dont_use_4_pixel_offset
    
        LDA $0C04, X : ADD $00    : STA $0C04, X
        LDA $0C18, X : ADC.b #$00 : STA $0C18, X
        
        BRL Ancilla_TransmuteToObjectSplash
    
    ; *$44760 ALTERNATE ENTRY POINT
    .draw
    
        JSR Ancilla_PrepAdjustedOamCoord
        
        ; \wtf
        ; Looks like this is making a special exception for the master sword
        ; (level 2 only), but I can't say for sure what the purpose of this
        ; is...
        LDA $0C5E, X : CMP.b #$01 : BNE .unknown
        
        LDA $C37B : STA $0BF0, X
    
    .unknown
    
        REP #$20
        
        LDA $029E, X : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_z_coord
        
        ORA.w #$FF00
    
    .sign_ext_z_coord
    
        STA $04
        
        EOR.w #$FFFF : INC A : ADD $00 : STA $00 : STA $06
        
        ADD.w #$0008 : STA $08
        
        SEP #$20
        
        JSR Ancilla_ReceiveItem.draw
        
        ; Done throwing?
        LDA $0309 : CMP.b #$02 : BNE .return
        
        LDA $0294, X : BMI .shadow_draw
        CMP.b #$02   : BCS .return
    
    .draw_shadow
    
        PHX
        
        LDA $0C5E, X : TAX
        
        ; \bug(confirmed) Same bug, different part of the routine.
        LDA $8450, X : TAX
        
        REP #$20
        
        LDA $06 : ADD $04 : ADD.w #$0028 : STA $00
        
        CPX.b #$02 : BEQ .wide_sprite
        
        LDA $02 : ADD.w #-4 : STA $02
    
    .wide_sprite
    
        SEP #$20
        
        LDA.b #$01
        
        CPX.b #$02 : BEQ .use_wide_shadow
        
        LDA.b #$02
    
    .use_wide_shadow
    
        TAX
        
        LDA $65 : STA $04
        
        JSR Ancilla_DrawShadow
        
        PLX
    
    .return
    
        RTS
    }

; ==============================================================================
