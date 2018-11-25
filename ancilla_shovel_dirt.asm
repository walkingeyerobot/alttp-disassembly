
; ==============================================================================

    ; $42997-$429A8 DATA
    pool Ancilla_ShovelDirt:
    {
    
    .xy_offsets
        dw 18, -13
        dw -9, 4
        dw 18, 13
        dw -9, -11    
        
    .chr
        db $40, $50
    }

; ==============================================================================

    ; *$429A9-$42A31 JUMP LOCATION
    Ancilla_ShovelDirt:
    {
        JSR Ancilla_PrepOamCoord
        
        LDA $0C68, X : BNE .delay
        
        LDA.b #$08 : STA $0C68, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$02 : BNE .delay
        
        ; Eventually self-terminate.
        STZ $0C4A, X
        
        RTS
    
    .delay
    
        LDA $0C5E, X : STA $0A
        
        ASL #2 : STA $08
        
        LDY.b #$00
        
        LDA $2F : CMP.b #$04 : BEQ .player_facing_left
        
        LDY.b #$08
    
    .player_facing_left
    
        TYA : ADD $08 : TAY
        
        REP #$20
        
        LDA .xy_offsets+0, Y : ADD $00 : STA $00
        
        LDA .xy_offsets+2, Y : ADD $02 : STA $02
        ADD.w #$0008         : STA $04
        
        SEP #$20
        
        PHX
        
        LDY.b #$00 : STY $72
    
    .next_oam_entry
    
        JSR Ancilla_SetOam_XY
        
        LDX $0A
        
        LDA $A9A7, X : ADD $72 : STA ($90), Y : INY
        LDA.b #$04   : ORA $65 : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : JSR Ancilla_CustomAllocateOam
        
        LDA $04 : STA $02
        LDA $05 : STA $03
        
        INC $72 : LDA $72 : CMP.b #$02 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
