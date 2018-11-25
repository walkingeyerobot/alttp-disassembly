
; ==============================================================================

    ; $44A85-$44A8B DATA
    pool Ancilla_MilestoneItem:
    parallel pool Ancilla_ReceiveItem:
    {
    
    .ether_medallion
        db $10
    
    .pendants
        db $37, $39, $38
    
    .heart_container
        db $26
    
    .bombos_medallion
        db $0F
    
    .crystal
        db $20
    }

; ==============================================================================

    ; *$44A8C-$44BE3 JUMP LOCATION
    Ancilla_MilestoneItem:
    {
        ; Routines for pendants waiting to be picked up in a room.
        
        ; Is it the Ether medallion?
        LDA $0C5E, X : CMP .ether_medallion  : BEQ .medallion
                       CMP .bombos_medallion : BEQ .medallion
        
        ; Has the item in this room (usually pendant or crystal) already been obtained?
        ; Yes it has been obtained. Kill this pendant process.
        LDA $0403 : AND.b #$40 : BNE .terminate_item
        
        ; Has the boss been beaten and a heart piece collected?
        LDA $0403 : AND.b #$80 : BEQ .waitForEvent
        
        ; Delay timer?
        LDA $04C2  : BEQ .countDownDone
        CMP.b #$01 : BNE .countDownAndWait
        
        ; Is it a crystal?
        LDY.b #$23
        
        LDA $0C5E, X : CMP .crystal : BNE .not_crystal
        
        LDA.b #$0F : STA $012D
        
        LDY.b #$28
    
    .not_crystal
    
        TYA : STA $72
        
        PHX
        
        JSL GetAnimatedSpriteTile.variable
        
        PLX
    
    .countDownAndWait
    
        DEC $04C2
    
    .waitForEvent
    
        RTS
    
    .terminate_item
    
        STZ $0C4A, X
        
        RTS
    
    .medallion
    
        LDA $0394, X : BEQ .no_misc_palette_load
        
        DEC $0394, X
        
        RTS
    
    ; This code is executed when the item is just on the ground, laying there.
    .countDownDone
    
        LDA $039F, X : BNE .no_misc_palette_load
        
        LDA $0C5E, X : CMP .crystal : BNE .no_misc_palette_load
        
        ; yes it's a crystal
        LDA.b #$01 : STA $039F, X
        
        PHX
        
        LDA.b #$04 : STA $0AB1
        LDA.b #$02 : STA $0AA9
        
        JSL Palette_MiscSpr.justSP6
        
        INC $15
        
        PLX
    
    .no_misc_palette_load
    
        LDA $0C5E, X : CMP .crystal : BNE .dont_sparkle
        
        JSR Ancilla_AddSwordChargeSpark
    
    .dont_sparkle
    
        LDA $11 : BNE .draw
        
        ; If altitude >= 0x18 you can't grab it.
        LDA $029E, X : CMP.b #$18 : BCS .no_player_collision
        
        LDY.b #$02
        
        JSR Ancilla_CheckPlayerCollision : BCC .no_player_collision
        
        LDA $037E : BNE .no_player_collision
        
        LDA $4D : BNE .no_player_collision
        
        STZ $0C4A, X
        
        ; Success, we've grabbed the item!
        LDA $5D
        
        CMP.b #$19 : BEQ .receiving_medallion_player_mode
        CMP.b #$1A : BNE .not_receiving_medallion
    
    .receiving_medallion_player_mode
    
        STZ $0112
        STZ $03EF
        
        LDA.b #$00 : STA $5D
    
    .not_receiving_medallion
    
        ; Indicate that the item is from an object
        LDA.b #$03 : STA $02E9
        
        PHX
        
        ; This will be the item to grant to Link.; 
        ; Will get stored to $02D8 in the following routine.
        TAY
        
        LDA $0C5E, X
        
        JSL Link_ReceiveItem
        
        PLX
        
        RTS
    
    .no_player_collision
    
        LDA $0C54, X : BEQ .hasnt_touched_grond
        CMP #$02     : BEQ .draw
        
        ; Simulate gravity.
        LDA $0294, X : SUB.b #$01 : STA $0294, X
    
    .hasnt_touched_ground
    
        JSR Ancilla_MoveAltitude
        
        LDA $029E, X : CMP.b #$F8 : BCC .draw
        
        ; It hit the ground, so make the object bounce upward a bit.
        INC $0C54, X
        
        LDA.b #$18 : STA $0294, X
        
        STZ $029E, X
    
    .draw
    
        JSR Ancilla_PrepAdjustedOamCoord
        
        REP #$20
        
        LDA $029E, X : AND.w #$00FF : STA $72
        
        LDA $00 : STA $06 : SUB $72 : STA $00
        
        SEP #$20
        
        JSR Ancilla_ReceiveItem.draw
        
        PHX
        
        DEC $03B1, X : BPL .ripple_delay
        
        LDA.b #$09 : STA $03B1, X
        
        INC $0385, X : LDA $0385, X : CMP.b #$03 : BNE .not_ripple_reset
        
        STZ $0385, X
    
    .ripple_delay
    .not_ripple_reset
    
        LDA $0385, X : STA $72
        
        LDA $029E, X : CMP.b #$00 : BNE .above_ground
        
        LDX.b #$00
        
        LDA $A0 : CMP.b #$06 : BNE .not_water_room
        
        LDA $A1 : CMP.b #$00 : BNE .not_water_room
        
        LDA $72 : ADD.b #$04 : TAX
    
        BRA .draw_underside_sprite
    
    .above_ground
    
        LDX.b #$01
        
        CMP.b #$20 : BCC .draw_underside_sprite
        
        ; Use a small shadow if the object is higher than 32 pixels off the
        ; ground.
        INX
    
    .not_water_room
    .draw_underside_sprite
    
        REP #$20
        
        LDA $06 : ADD.w #$000C : STA $00
        
        SEP #$20
        
        LDA.b #$20 : STA $04
        
        JSR Ancilla_DrawShadow
        
        PLX
        
        RTS
    }

; ==============================================================================
