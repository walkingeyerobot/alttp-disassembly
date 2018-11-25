
; ==============================================================================

    ; \note Performs movement and player interaction of the gravestone.
    ; *$46D89-$46DF8 LONG
    Gravestone_Move:
    {
        PHB : PHK : PLB
        
        LDA $11 : BNE .return
        
        LDA.b #$F8 : STA $0C22, X
        
        JSR Ancilla_MoveVert
        JSR Gravestone_RepelPlayerAdvance
        
        LDA $038A, X : STA $00
        LDA $038F, X : STA $01
        
        LDA $0BFA, X : STA $02
        LDA $0C0E, X : STA $03
        
        REP #$20
        
        ; Wait until the gravestone reaches its target y coordinate...
        ; This only works because... eh. Have to see this in action. Seems
        ; like there would be a sudden change in the underlying tiles.
        LDA $02 : CMP $00 : SEP #$20 : BCS .return
        
        STZ $0C4A, X
        STZ $03E9
        
        LDA $48 : AND.b #$FB : STA $48
        
        LDA $03BA, X : STA $72
        LDA $03B6, X : STA $73
        
        REP #$20
        
        LDA $72 : STA $0698
        
        ; This accomplishes the second part of the map16 update (which
        ; actually updates a 32x32 region)
        LDY.b #$48
        
        CMP.w #$0532 : BEQ .not_particular_addresses
        
        LDY.b #$60
        
        CMP.w #$0488 : BEQ .not_particular_addresses
        
        LDY.b #$40
    
    .not_particular_addresses
    
        TYA : AND.w #$00FF : STA $0692
        
        SEP #$20
        
        PHX
        
        JSL Overworld_DoMapUpdate32x32_Long
        
        PLX
        
        ; Yeah, it's a zero length branch, I know.
        BRA .return
    
    .return	
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $46DF9-$46E00 DATA
    pool Ancilla_Gravestone:
    {
    
    .chr
        db $C8, $C8, $D8, $D8
    
    .properties
        db $00, $40, $00, $40
    }

; ==============================================================================

    ; \note Unlike many Ancilla handlers, this guy only handles drawing
    ; of the object. The actual movement and other logic of the gravestone
    ; is driven by the player engine, called from a routine found above
    ; (Gravestone_Move).
    ; *$46E01-$46E56 JUMP LOCATION
    Ancilla_Gravestone:
    {
        PHX
        
        JSR Ancilla_PrepAdjustedOamCoord
        
        REP #$20
        
        LDA $02 : STA $06
        
        SEP #$20
        
        LDA.b #$10 : JSL OAM_AllocateFromRegionB
        
        LDY.b #$00 : TYX
    
    .next_oam_entry
    
        JSR Ancilla_SetOam_XY
        
        LDA .chr, X                     : STA ($90), Y : INY
        LDA .properties, X : ORA.b #$3D : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INX
        
        REP #$20
        
        LDA $02 : ADD.w #$0010 : STA $02
        
        CPX.b #$02 : BNE .still_drawing_left_half
        
        ; The last two are further to the right.
        LDA $00 : ADD.w #$0008 : STA $00
        LDA $06                : STA $02
    
    .still_drawing_left_half
    
        SEP #$20
        
        CPX.b #$04 : BNE .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$46E57-$46EDD LOCAL
    Gravestone_RepelPlayerAdvance:
    {
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        REP #$20
        
        LDA $00 : ADD.w #$0018 : STA $04
        LDA $02 : ADD.w #$0020 : STA $06
        
        LDA $20 : ADD.w #$0008 : STA $08 : CMP $00 : BCC .player_not_close
                                           CMP $04 : BCS .player_not_close
        
        LDA $22 : ADD.w #$0008 : CMP $02 : BCC .player_not_close
                                 CMP $06 : BCC .player_not_close
        
        LDA $08 : SUB $04 : BPL .player_below_object
        
        EOR.w #$FFFF : INC A
    
    .player_below_object
    
        STA $0A
        
        ADD $20 : STA $20
        
        LDA $30 : CMP.w #$0080 : BCC .sign_already_proper
        
        ORA.w #$FF00
    
    .sign_already_proper
    
        STA $08
        
        LDA $0A : ADD $08 : AND.w #$00FF : STA $08
        
        LDA $30 : AND.w #$FF00 : ORA $08 : STA $30
        
        LDA.w #$0004 : TSB $48
    
    .player_not_close
    
        SEP #$20
        
        LDA $2F : BEQ .dont_negate_grab_pose
        
        LDA $48 : AND.b #$FB : STA $48
    
    .dont_negate_grab_pose
    
        RTS
    }

; ==============================================================================
