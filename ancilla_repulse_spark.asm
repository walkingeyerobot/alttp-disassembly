
; ==============================================================================

    ; $40F82-$40F88 DATA
    pool Ancilla_RepulseSpark:
    {
    
    .chr
        db $93, $82, $81
    
    .properties
        db $22, $12, $22, $22
    }

; ==============================================================================

    ; My best guess is that this handles generic hit / spark effects that
    ; don't fit anywhere else, but $0FAC is quite unfamiliar still. It never
    ; seems to receive a value higher than 5, but there are checks for
    ; it as high as 9 and beyond.
    ; *$40F89-$4107F LOCAL
    Ancilla_RepulseSpark:
    {
        LDA $0FAC : BEQ Ancilla_IsBelowPlayer.return
        
        ; Activate enemies that are listening for sounds?
        LDA.b #$02 : STA $0FDC
        
        DEC $0FAF : BPL .dont_decrement_state
        
        DEC $0FAC
        
        LDA.b #$01 : STA $0FAF
    
    .dont_decrement_state
    
        LDA.b #$10
        
        LDY $0FB3 : BEQ .dont_sort_sprites
        
        LDY $0B68 : BNE .on_bg1
        
        JSL OAM_AllocateFromRegionD
        
        BRA .check_if_on_screen
    
    .on_bg1
    
        JSL OAM_AllocateFromRegionF
        
        BRA .check_if_on_screen
    
    .dont_sort_sprites
    
        JSL OAM_AllocateFromRegionA
    
    .check_if_on_screen
    
        LDA $0FAD : SUB $00E2 : CMP.b #$F8 : BCS .off_screen
        
        STA $00
        
        LDA $0FAE : SUB $00E8 : CMP.b #$F0 : BCS .off_screen
        
        STA $01
        
        LDA $0FAC : CMP.b #$03 : BCC .later_states
        
        LDY.b #$00
        
        LDA $00       : STA ($90), Y
        LDA $01 : INY : STA ($90), Y
        
        LDA.b #$80
        
        LDX $0FAC : CPX.b #$09 : BCS .use_different_chr
        
        LDA.b #$92
    
    .use_different_chr
    
        INY : STA ($90), Y
        
        LDX $0B68
        
        LDA.l .properties, X : INY : STA ($90), Y
        
        TYA : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        RTS
    
    .off_screen
    
        ; Self terminate because the object went off screen.
        STZ $0FAC
        
        RTS
    
    .later_states
    
        ; The last three states of this object use more oam entries than the
        ; earlier ones.
        
        LDA $00 : SUB.b #$04 : LDY.b #$00 : STA ($90), Y
                               LDY.b #$08 : STA ($90), Y
        ADD.b #$08           : LDY.b #$04 : STA ($90), Y
                               LDY.b #$0C : STA ($90), Y
        LDA $01 : SUB.b #$04 : LDY.b #$01 : STA ($90), Y
                               LDY.b #$05 : STA ($90), Y
        ADD.b #$08           : LDY.b #$09 : STA ($90), Y
                               LDY.b #$0D : STA ($90), Y
        
        LDX $0B68
        
        LDA.l .properties, X : LDY.b #$03 : STA ($90), Y
        ORA.b #$40           : LDY.b #$07 : STA ($90), Y
        ORA.b #$80           : LDY.b #$0F : STA ($90), Y
        EOR.b #$40           : LDY.b #$0B : STA ($90), Y
        
        LDX $0FAC
        
        LDA .chr, X : LDY.b #$02 : STA ($90), Y
                      LDY.b #$06 : STA ($90), Y
                      LDY.b #$0A : STA ($90), Y
                      LDY.b #$0E : STA ($90), Y
        
        LDY.b #$00
        LDA.b #$00
        
        STA ($92), Y : INY
        STA ($92), Y : INY
        STA ($92), Y : INY
        STA ($92), Y
        
        RTS
    }

; ==============================================================================
