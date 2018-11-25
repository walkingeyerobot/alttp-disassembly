
; ==============================================================================

    ; $2BC8A-$2BCA1 DATA
    pool Sprite_Recruit:
    {
    
    .x_speeds
        db  12, -12,   0,   0
        db  18, -18,   0,   0
    
    .y_speeds
        db   0,   0,  12, -12
        db   0,   0,  18, -18
    
    .animation_states
        db 0, 2, 4, 6, 1, 3, 5, 7
    }

; ==============================================================================

    ; *$2BCA2-$2BD15 JUMP LOCATION
    Sprite_Recruit:
    {
        ; Green Soldier (weak version)
        ; Brief variable listing: 
        ; $0D80, X - AI variable, has two states: 0 - stopped and looking, 1 - in motion
        ; $0DC0, X - as usual, a generalized variable for a sprite's overall graphic state.
        ; $0DE0, X - body direction
        ; $0E80, X - running 8-bit counter that increments every time the sprite moves.
        ; It's used to determine the status of the sprite's "feet"
        ; $0EB0, X - head direction
        
        LDA $0E80, X : AND.b #$08 : LSR A : ADC $0DE0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        JSR Recruit_Draw
        JSR Sprite2_CheckIfActive
        JSR Sprite2_CheckIfRecoiling
        JSR Sprite2_CheckDamage
        JSR Sprite2_Move
        JSR Sprite2_CheckTileCollision
        
        LDA $0D80, X : BNE Recruit_Moving
        
        LDA $0DF0, X : BNE .wait
        
        ; Set the delay timer to a new value.
        JSL GetRandomInt : AND.b #$3F : ADC.b #$30 : STA $0DF0, X
        
        ; Put the soldier back in motion again.
        INC $0D80, X
        
        ; Set the direction of the body to that of the head.
        LDA $0EB0, X : STA $0DE0, X
        
        JSR Sprite2_DirectionToFacePlayer : TYA
        
        LDY $0DE0, X : CMP $0DE0, X : BNE .not_facing_player
        
        LDA $0E : ADD.b #$10 : CMP.b #$20 : BCC .close_to_player
        LDA $0F : ADD.b #$10 : CMP.b #$20 : BCS .not_close_to_player
    
    .close_to_player
    
        ; For whatever reason, this guy's speed is faster when very close to
        ; the player (16 pixels or less).
        INY #4
        
        LDA.b #$80 : STA $0DF0, X
    
    .not_facing_player
    .not_close_to_player
    
        LDA .x_speeds, Y : STA $0D50, X
        LDA .y_speeds, Y : STA $0D40, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; $2BD16-$2BD1D DATA
    pool Recruit_Moving:
    {
    
    .next_head_direction
        db 2, 3, 2, 3, 0, 1, 0, 1
    }
    
; ==============================================================================

    ; *$2BD1E-$2BD55 BRANCH LOCATION
    Recruit_Moving:
    {
        LDA.b #$10
        
        LDY $0E70, X : BNE .hit_a_wall
        LDA $0DF0, X : BNE .still_moving
        
        LDA.b #$30
    
    .hit_a_wall
    
        STA $0DF0, X
        
        JSR Sprite2_ZeroVelocity
        
        JSL GetRandomInt : AND.b #$01 : STA $00
        
        LDA $0DE0, X : ASL A : ORA $00 : TAY
        
        LDA .next_head_direction, Y : STA $0EB0, X
        
        STZ $0D80, X
    
    .still_moving
    
        LDA $0E00, X : BEQ .tick_animation_clock
        
        INC $0E80, X
    
    ; *$2BD52 ALTERNATE ENTRY POINT
    .tick_animation_clock
    
        INC $0E80, X
        
        RTS
    }

; ==============================================================================

    ; $2BD56-$2BD7D DATA
    pool Recruit_Draw:
    {
    
    
    .x_offsets
        dw 2, 2, -2, -2, 0, 0, 0, 0
    
    .chr
        db $8A, $8C, $8A, $8C, $86, $88, $8E, $A0
    
    .vh_flip
        db $40, $40, $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$2BD7E-$2BE09 LOCAL
    Recruit_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0DC0, X : STA $06
        
        PHX
        
        ; Check head status
        LDA $0EB0, X : TAX
        
        REP #$20
        
        ; This is the base OAM X coordinate
        ; Store it into the OAM buffer (X position)
        LDA $00 : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        ; This is the base OAM Y coordinate
        ; Since this is the head sprite, lift it up a bit.
        ; Store to the OAM buffer (Y position)
        LDA $02 : SUB.w #$000B : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen
        
        ; Turn the sprite off entirely if it's too far down
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen
    
        SEP #$20
        
        LDA $C6A2, X : INY           : STA ($90), Y
        LDA $C6A6, X : INY : ORA $05 : STA ($90), Y
        
        ; Set extended X coordinate and priority settings
        LDA.b #$02 : ORA $0F : STA ($92)
        
        LDA $06 : PHA : ASL A : TAX
        
        REP #$20
        
        ; Now start setting up the sprites for the body portion
        LDA $00 : ADD .x_offsets, X : INY : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen_2
        
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen_2
    
        SEP #$20
        
        PLX
        
        LDA .chr, X               : INY : STA ($90), Y
        LDA .vh_flip, X : ORA $05 : INY : STA ($90), Y
        
        LDY.b #$01
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLX
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
