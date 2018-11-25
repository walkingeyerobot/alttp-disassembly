
; ==============================================================================

    ; $35E4D-$35E82 DATA
    pool SpriteHeld_Main:
    {
    
        ; \task Fill in data and label.
    }

; ==============================================================================

    ; *$35E83-$35F60 JUMP LOCATION
    SpriteHeld_Main:
    {
        ; Checks to see if the room we're in matches
        LDA $040A : STA $0C9A, X
        
        LDA $7FFA1C, X : CMP.b #$03 : BEQ .fully_lifted
        
        LDA $0DF0, X : BNE .delay_lift_state_transition
        
        LDA.b #$04
        
        LDY $0DB0, X : CPY.b #$06 : BNE .not_large
        
        LDA.b #$08
    
    .not_large
    
        STA $0DF0, X
        
        LDA $7FFA1C, X : INC A : STA $7FFA1C, X
    
    .delay_lift_state_transition
    
        BRA .x_wobble_logic
    
    .fully_lifted
    
        ; unset the "draw shadow" flag for items we're holding 
        LDA $0E60, X : AND.b #$EF : STA $0E60, X
    
    .x_wobble_logic
    
        ; \note Seems to be a wobble induced by the currently considered
        ; unused feature where a sprite can 'wake up' and leap out of the
        ; player's hands if $0F10, X is set to a nonzero value. See the tcrf
        ; note below.
        STZ $00
        
        ; \optimize Use of the bit instruction and not decrementing, plus
        ; changing the order the branches are presented in would save
        ; a byte of space and a cycle or two of execution.
        LDA $0F10, X : DEC A : CMP.b #$3F : BCS .dont_x_wobble
        AND.b #$02                        : BEQ .dont_x_wobble
        
        INC $00
    
    .dont_x_wobble
    
        LDA $2F : ASL A : ADD $7FFA1C, X : TAY
        
        LDA $22 : ADD $DE4D, Y : PHP : ADC $00      : STA $0D10, X
        LDA $23 : ADC.b #$00   : PLP : ADC $DE5D, Y : STA $0D30, X
        
        LDA $DE6D, Y : STA $0F70, X
        
        LDY $2E : CPY.b #$06 : BCC .not_last_animation_step
        
        LDY.b #$00
    
    .not_last_animation_step
    
        LDA $24 : ADD.b #$01 : PHP : ADD $DE7D, Y : STA $00
        LDA $25 : ADC.b #$00 : PLP : ADC.b #$00   : STA $0E
        
        LDA $20 : SUB $00    : PHP : ADD.b #$08 : STA $0D00, X
        LDA $21 : ADC.b #$00 : PLP : SBC $0E    : STA $0D20, X
        
        LDA $EE : AND.b #$01 : STA $0F20, X
        
        JSR SpriteHeld_ThrowQuery
        JSR Sprite_Get_16_bit_Coords
        
        LDA $7FFA2C, X : CMP.b #$0B : BEQ .frozen_sprite
        
        ; \task Presumably.... just does the drawing of the sprite? Find out
        ; what implications this has.
        JSR SpriteActive_Main
        
        LDA $0F10, X : DEC A : BNE .dont_leap_from_player_grip
        
        ; \unused The code bracketed by the above branch label.
        ; \task Upon inspection, it would be interesting to know of any time
        ; this code is actually *executed* in the game. It doesn't match
        ; anything in my experience. It's like the player has picked up a
        ; stunned enemy (\tcrf(unconfirmed) maybe?) and it eventually wakes
        ; up and leaps out of the player's hands.
        LDA.b #$09 : STA $0DD0, X
        
        STZ $0DA0, X
        
        LDA.b #$60 : STA $0F10, X
        
        LDA.b #$20 : STA $0F80, X
        
        LDA $0E60, X : ORA.b #$10 : STA $0E60, X
        
        LDA.b #$02 : STA $0309
    
    .dont_leap_from_player_grip
    
    ; $35F5D ALTERNATE ENTRY POINT
    parallel pool SpriteHeld_ThrowQuery:
    
    .easy_out
    
        RTS
    
    .frozen_sprite
    
        JMP $E2BA ; $362BA IN ROM
    }

; ==============================================================================

    ; $35F61-$35F6C DATA
    pool SpriteHeld_ThrowQuery:
    {
    
    .x_speeds
        db 0, 0, -62, 63
    
    .y_speeds
        db -62, 63, 0, 0
    
    .z_speeds
        db 4, 4, 4, 4
    }

; ==============================================================================

    ; *$35F6D-$35FF1 LOCAL
    SpriteHeld_ThrowQuery:
    {
        ; in text mode, so do nothing...
        LDA $0010 : CMP.b #$0E : BEQ .easy_out
        
        LDA $5B : CMP.b #$02 : BEQ .coerced_throw
        
        LDA $4D : AND.b #$01
        
        LDY $037B : BNE .player_ignores_sprite_collisions
        
        ; Being hit causes the player to release a held sprite.
        ORA $0046
    
    .player_ignores_sprite_collisions
    
        ORA $0345 : ORA $02E0 : ORA $02DA : BNE .coerced_throw
        
        LDA $7FFA1C, X : CMP.b #$03 : BNE .dont_throw
        
        LDA $F4 : ORA $F6 : BPL .dont_throw
        
        ; Erase these inputs as they've been used up.
        ; \optimize Why not just use TRB here with 0x80 mask?
        ASL $F6 : LSR $F6
    
    .coerced_throw
    
        LDA.b #$13 : JSL Sound_SetSfx3PanLong
        
        LDA.b #$02 : STA $0309
        
        ; This code gets called when some object flies out of Link's hand
        ; when he's falling into a pit
        LDA $7FFA2C, X : STA $0DD0, X
        
        STZ $0F80, X
        
        LDA.b #$00 : STA $7FFA1C, X
        
        PHX
        
        LDA $0E20, X : TAX
        
        LDA $0DB359, X : PLX : AND.b #$10 : STA $00
        
        LDA $0E60, X : AND.b #$EF : ORA $00 : STA $0E60, X
        
        LDA $2F : LSR A : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        LDA .z_speeds, Y : STA $0F80, X
        
        LDA.b #$00 : STA $0F10, X
    
    .dont_throw
    
        RTS
    }

; ==============================================================================
