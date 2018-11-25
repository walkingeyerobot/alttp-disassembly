
; ==============================================================================

    ; *$474CA-$474D1 LONG
    Ancilla_GameOverTextLong:
    {
        PHB : PHK : PLB
        
        JSR Ancilla_GameOverText
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $474D2-$474D7 Jump Table
    pool Ancilla_GameOverText:
    {
        ; \task interleaved!
        
        dw GameOverText_SweepLeft
        dw GameOverText_UnfurlRight
        dw GameOverText_Draw
    }

; ==============================================================================

    ; *$474D8-$474ED LOCAL
    Ancilla_GameOverText:
    {
        ; It looks as though these routines do ancillary objects of the death
        ; world. Maybe faeries and powder that they scatter on the player.
        ; Either way, it seems to utilize the existing Ancilla framework a bit.
        LDX $0C4A : BEQ .no_active_objects
        
        DEX
        
        LDA $F4D2, X : STA $00
        LDA $F4D5, X : STA $01
        
        JMP ($0000)
    
    .no_active_objects
    
        INC $11
        
        RTS
    }

; ==============================================================================

    ; $474EE-$474F5 DATA
    pool GameOverText_SweepLeft:
    {
    
    .target_x_coords
        db 64
        db 80
        db 96
        db 112
        db 136
        db 152
        db 168
        db 64
    }

; ==============================================================================

    ; *$474F6-$47564 JUMP LOCATION
    GameOverText_SweepLeft:
    {
        LDX $035F : STX $0FA0
        
        ; \wtf(odd, but not really a big deal)
        ; The result is the same regardless for the value of Y.
        LDY.b #$80
        
        CPX.b #$07 : BNE .useless
        
        LDY.b #$80
    
    .useless
    
        ; Rapidly move the object off screen? (The boomerang, I assume.)
        TYA : STA $0C2C, X
        
        JSR Ancilla_MoveHoriz
        
        LDA $0C18, X                : BNE .to_right_of_target
        LDA $0C04, X : CMP $F4EE, X : BCS .to_right_of_target
        
        LDA .target_x_coords, X : STA $0C04, X
        
        ; Add another letter, and move on if we've got all the letters in
        ; place.
        INX : STX $035F : CPX.b #$08 : BNE .not_time_to_unfurl
        
        LDA.b #$07 : STA $035F
        
        ; Move on to the next phase and unfurl the letters back to the right
        ; and to their final resting positions.
        INC $0C4A
        
        STZ $039D
        
        ; Agahnim's lightning sound.
        LDA.b #$26 : STA $012F
        
        BRA .draw
    
    .to_right_of_target
    .not_time_to_unfurl
    
        CPX.b #$07 : BNE .draw
        
        LDY.b #$06 : CPY $039D : BEQ .dont_do_tandem_move_yet
    
    .follow_leading_letter
    
        LDA $0C04, X : STA $0C04, Y
        
        ; Only move the letters that have been 'picked up' thus far.
        DEY : CPY $039D : BNE .follow_leading_letter
    
    .dont_do_tandem_move_yet
    
        LDA $0C18, X : BNE .draw
        
        LDA $0C04, X : LDX $039D : CMP .target_x_coords, X : BCS .draw
        
        ; When the lead letter touches or cross to the left of one of the other
        ; letters, pick up that letter and make it follow the lead letter ('R').
        DEC $039D
    
    .draw
    
        BRL GameOverText_Draw
    } 

; ==============================================================================

    ; $47565-$4756C DATA
    pool GameOverText_UnfurlRight:
    {
    
    .target_x_coords
        db 88
        db 96
        db 104
        db 112
        db 136
        db 144
        db 152
        db 160
    }

; ==============================================================================

    ; *$4756D-$475B3 LOCAL
    GameOverText_UnfurlRight:
    {
        LDX $035F : STX $0FA0
        
        LDA.b #$60 : STA $0C2C, X
        
        JSR Ancilla_MoveHoriz
        
        LDY $039D
        
        LDA $0C04, X : CMP .target_x_coords, Y : BCC .left_of_limit
        
        LDA .target_x_coords, Y : STA $0C04, Y
        
        INC $039D : LDA $039D : CMP.b #$08 : BNE .not_all_letters_in_position
        
        INC $11
        INC $0C4A
        
        BRA .draw
    
    .left_of_limit
    .not_all_letters_in_position
    
        ; As letters drop into position, less of them will be following the
        ; lead letter (which is 'R', as in the last letter of 'Game Over' )
        LDA $039D : DEC A : STA $00
        
        LDX $035F : TXY
    
    .follow_leading_letter
    
        LDA $0C04, X : STA $0C04, Y
        
        DEY : CPY $00 : BNE .follow_leading_letter
    
    .draw
    
        BRA GameOverText_Draw
    } 

; ==============================================================================

    ; $475B4-$475C3 DATA
    GameOverText_Draw:
    {
    
    .chr
        db $40, $50
        db $41, $51
        db $42, $52
        db $43, $53
        db $44, $54
        db $45, $55
        db $43, $53
        db $46, $56
    }

; ==============================================================================

    ; *$475C4-$47623 BRANCH LOCATION LONG
    GameOverText_Draw:
    {
        ; Start the oam buffer from scratch.
        LDA.b #$00 : STA $90
        LDA.b #$08 : STA $91
        
        LDA.b #$20 : STA $92
        LDA.b #$0A : STA $93
        
        LDX $035F
        
        LDY.b #$00
    
    .next_oam_entry
    
        PHX
        
        LDA.b #$57 : STA $00 : STZ $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        JSR Ancilla_SetOam_XY
        
        TXA : ASL A : TAX
        
        LDA .chr+0, X : STA ($90), Y : INY
        LDA.b #$3C    : STA ($90), Y : INY
        
        LDA.b #$5F : STA $00
                     STZ $01
        
        JSR Ancilla_SetOam_XY
        
        LDA .chr+1, X : STA ($90), Y : INY
        LDA.b #$3C    : STA ($90), Y : INY
        
        PHY : TYA : SUB.b #$08 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        INY : STA ($92), Y
        
        PLY
        
        PLX : DEX : BPL .next_oam_entry
        
        RTS
    }

; ==============================================================================

