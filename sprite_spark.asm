
; ==============================================================================

    ; $29333-$2933E DATA
    pool Sprite_Spark:
    {
    
    .vh_flip
        db $00, $40, $80, $C0
    
    .directions
        db 1, 3, 2, 0
        db 7, 5, 6, 4 ; clockwise directions? wtf???????????????????????????????
    }

; ==============================================================================

    ; *$2933F-$2940D JUMP LOCATION
    Sprite_Spark:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite2_CheckIfActive
        
        LDA $1A : AND.b #$01 : BNE .dont_toggle_palette
        
        LDA $0F50, X : EOR.b #$06 : STA $0F50, X
    
    .dont_toggle_palette
    
        LDA $0D80, X : BNE .direction_initialized
        
        INC $0D80, X
        
        LDA.b #$01 : STA $0D40, X : STA $0D50, X
        
        JSR Sprite2_CheckTileCollision
        
        PHA
        
        LDA.b #$FF : STA $0D40, X : STA $0D50, X
        
        JSR Sprite2_CheckTileCollision
        
        PLA : ORA $0E70, X : CMP.b #$04 : BCS .collided_up_or_down
        
        LDY.b #$00
        
        AND.b #$01 : BNE .collided_right
        
        INY
    
    .collided_right
    
        BRA .moving_on
    
    .collided_up_or_down
    
        LDY.b #$02
        
        AND.b #$04 : BNE .collided_downwards
        
        INY
    
    .collided_downwards
    
        LDA $0E20, X : CMP.b #$5C : BEQ .travels_counterclockwise
        
        ; And the opposite of that is... you guessed it, clockwise.
        INY #4
    
    .travels_counterclockwise
    
        LDA .directions, Y : STA $0DE0, X
    
    .direction_initialized
    
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        ; interesting.... its v and h flip settings are cyclical?
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        JSR Sprite2_Move
        JSL Sprite_CheckDamageToPlayerLong
        
        LDY $0DE0, X
        
        LDA Probe.x_checked_directions, Y : STA $0D50, X
        
        LDA Probe.y_checked_directions, Y : STA $0D40, X
        
        JSR Sprite2_CheckTileCollision
        
        LDA $0E10, X : BEQ .check_orthogonal_collision
        CMP.b #$06   : BNE .check_collinear_collision
        
        LDY $0DE0, X
        
        ; Has us temporarily move in a direction that is opposite to the usual
        ; orientation of the sprite. This is because we have run out of wall
        ; to adhere to on our near side, and have to find a new wall to adhere
        ; to, so we turn towards the orthogonal direction.
        LDA Probe.orthogonal_next_direction, Y : STA $0DE0, X
        
        BRA .check_collinear_collision
    
    .check_orthogonal_collision
    
        ; We check the orthogonal direction of the wall that we're supposed
        ; to be adhering to. If we have lost track of that directino we will
        ; end up having to do a termporary change of rotation to seek out
        ; a new wall to adhere to (in effect, momentarily switching from
        ; clockwise to counterclockwise or vice versa.
        LDY $0DE0, X
        
        LDA $0E70, X
        
        AND Probe.orthogonal_directions, Y : BNE .has_orthogonal_collision
        
        LDA.b #$0A : STA $0E10, X
    
    .has_orthogonal_collision
    .check_collinear_collision
    
        LDY $0DE0, X
        
        LDA $0E70, X
        
        AND Probe.collinear_directions, Y : BEQ .no_collinear_collision
        
        LDA Probe.collinear_next_direction, Y : STA $0DE0, X
    
    .no_collinear_collision
    
        LDY $0DE0, X
        
        LDA Probe.x_speeds, Y : ASL A : STA $0D50, X
        
        LDA Probe.y_speeds, Y : ASL A : STA $0D40, X
        
        RTS
    }

; ==============================================================================
