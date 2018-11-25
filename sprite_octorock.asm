
; ==============================================================================

    ; $35363-$35376 DATA
    pool Sprite_Octorock:
    {
    .next_direction
        db   3,   2,   0,   1
        
    .x_speed
        db  24, -24,   0,   0
        
    .y_speed
        db   0,   0,  24, -24
        
    .unused
        ; Unused?
        db   1,   2,   4,   8
    
    .delays
        ; Unused?
        db  60, -128, -96, -128
    }

; ==============================================================================

    !ai_state  = $0D80
    !graphic   = $0DC0
    !direction = $0DE0
    !type      = $0E20
    !oam_4     = $0F50
    
    ; *$35377-$35450 JUMP LOCATION
    Sprite_Octorock:
    {
        !force_hflip = $00
        !gfx_vert    = $00
        
        ; ------------------------------
        
        ; Octorock Routine (Sprites 0x08 and 0x0A)
        LDY !direction, X : PHY
        
        LDA !timer_1, X : BEQ .timer_1_elapsed
        
        LDA .next_direction, Y : STA !direction, X
    
    .timer_1_elapsed
    
        STZ $00
        
        LDA !graphic, X : CMP.b #$07 : BNE .no_forced_hflip
        
        LDA.b #$40 : STA !force_hflip
    
    .no_forced_hflip
    
        LDA !oam_4, X : AND.b #$BF
        
        ORA $D2AE, Y : ORA !force_hflip : STA !oam_4, X
        
        JSR Octorock_Draw
        
        PLA : STA !direction, X
        
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_Move
        JSR Sprite_CheckDamage
        
        LDA !ai_state, X : AND.b #$01 : BNE .stop_and_spit_maybe
        
        LDA !direction, X : AND.b #$02 : ASL A : STA !gfx_vert
        
        INC $0E80, X
        
        LDA $0E80, X : LSR #3 : AND.b #$03 : ORA !gfx_vert : STA !graphic, X
        
        LDA !timer_0, X : BNE .wait_1
        
        ; Switch to the other main AI state.
        INC !ai_state, X
        
        LDY !type, X
        
        LDA .delays-8, Y : STA !timer_0, X
        
        RTS
    
    .wait_1
    
        LDY !direction, X
        
        ; Make this little bugger move.
        LDA .x_speed, Y : STA $0D50, X
        LDA .y_speed, Y : STA $0D40, X
        
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .epsilon
        
        LDA !direction, X : EOR.b #$01 : STA !direction, X
        
        BRA .return_2
    
    .epsilon
    
        RTS
    
    .stop_and_spit_maybe
    
        JSR Sprite_Zero_XY_Velocity
        
        LDA !timer_0, X : BNE .wait_2
        
        INC !ai_state, X
        
        LDA !direction, X : PHA
        
        ; Set a new countdown timer and direction slightly at random.
        JSL GetRandomInt : AND.b #$3F : ADC.b #$30 : STA !timer_0, X
        
        AND.b #$03 : STA !direction, X
        
        ; Note this odd... certainty that both outcomes result in the same
        ; branch location.
        PLA : CMP !direction, X : BEQ .same_direction
        EOR !direction, X       : BNE .different_direction
        
        ; Thus, this line of code is not reachable, as far as I can tell.
        LDA.b #$08 : STA !timer_1, X
    
    .same_direction
    .different_direction
    .return_2
    
        RTS
    
    .wait_2
    
        LDA !type, X : SUB.b #$08 : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        ; Hidden Jump table, Argghghh!
        LDA Octorock_AI_Table, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .handlers
    
        !nullptr = 0
        
        dw Octorock_Normal
        dw !nullptr
        dw Octorock_FourShooter
    }

; ==============================================================================

    ; $35451-$3546E DATA
    pool Octorock_Normal:
    {
    
    .unknown
        db 0, 2, 2, 2, 1, 1, 1, 0
        db 0, 0, 0, 0, 2, 2, 2, 2
        db 2, 1, 1  0
    }
        
; ==============================================================================

    ; $35465-$3546E DATA
    pool Octorock_FourShooter:
    {
    
    .unknown
        db 2, 2, 2, 2 2, 2, 2, 2, 1, 0
    }

; ==============================================================================

    ; $3546F-$35485 JUMP LOCATION (LOCAL)
    Octorock_Normal:
    {
        LDA !timer_0, X : CMP.b #$1C : BNE .dont_spit_rock
        
        PHA
        
        JSR Octorock_SpitOutRock
        
        PLA
    
    .dont_spit_rock
    
        LSR #3 : TAY
        
        LDA .unknown, Y : STA $0DB0, X
        
        RTS
    }

; ==============================================================================

    ; $35486-$35489 DATA
    pool Octorock_FourShooter:
    {
    
    .next_direction
        db 2, 3, 1, 0
    }

; ==============================================================================

    ; $3548A-$354B4 JUMP LOCATION (LOCAL)
    Octorock_FourShooter:
    {
        LDA !timer_0, X : PHA
        
        CMP.b #$80 : BCS .just_animate
        AND.b #$0F : BNE .dont_rotate
        
        PHA
        
        LDY !direction, X
        
        LDA .next_direction, Y : STA !direction, X
        
        PLA
    
    .dont_rotate
    
        CMP.b #$08 : BNE .dont_shoot
        
        JSR Octorock_SpitOutRock
    
    .dont_shoot
    .just_animate
    
        PLA : LSR #4 : TAY
        
        LDA .unknown, Y : STA $0DB0, X
        
        RTS
    }

; ==============================================================================

    ; $354B5-$354CC DATA
    pool Octorock_SpitOutRock:
    {
    
    ; \task Label these sublabels.
    
        db  12, -12,   0,   0
    
    ; $354B9
        db   0,  -1,   0,   0
    
    ; $354BD
        db   4,   4,  12, -12
    
    ; $354C1
        db   0,   0,   0,  -1
    
    ; $354C5
        db  44, -44,   0,   0
    
    ; $354C9
        db   0,   0,  44, -44
    }

; ==============================================================================

    ; $354CD-$35513 LOCAL
    Octorock_SpitOutRock:
    {
        LDA.b #$07 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$0C
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        PHX
        
        ; The position and velocity of the newly created rock depends on the
        ; direction that the Octorok is currently facing.
        LDA !direction, X : TAX
        
        LDA $00 : ADD $D4B5, X : STA $0D10, Y
        LDA $01 : ADC $D4B9, X : STA $0D30, Y
        
        LDA $02 : ADD $D4BD, X : STA $0D00, Y
        LDA $03 : ADC $D4C1, X : STA $0D20, Y
        
        LDA !direction, Y : TAX
        
        LDA $D4C5, X : STA $0D50, Y
        LDA $D4C9, X : STA $0D40, Y
        
        PLX
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $35514-$35549 DATA
    pool Octorock_Draw:
    {
    
    .x_offsets
        dw  8,  0,  4,  8,  0,  4,  9, -1,  4
    
    .y_offsets
        dw  6,  6,  9,  6,  6,  9,  6,  6,  9
    
    .chr
        db $BB, $BB, $BA, $AB, $AB, $AA, $A9, $A9, $B9
    
    .properties
        db $65, $25, $25, $65, $25, $25, $65, $25, $25
    }

; ==============================================================================

    ; *$3554A-$355B8 LOCAL
    Octorock_Draw:
    {
        !top_x_bit_low  = $0E
        !top_x_bit_high = $0F
        
        JSR Sprite_PrepOamCoord
        
        ; perhaps this draws the octorock's snout?
        LDA !direction, X : CMP.b #$03 : BEQ .dont_draw_this_part
        
        ; $07 = [3 * $0DB0, X] + !direction
        LDA $0DB0, X : ASL A : ADC $0DB0, X : ADC !direction, X : STA $07
        
        PHX : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA !top_x_bit_low
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .not_off_screen
        
        LDA.b #$F0 : STA ($90), Y
    
    .not_off_screen
    
        PLX
        
        LDA .chr, X : INY : STA ($90), Y
        
        LDA .properties, X : INY : ORA $05 : STA ($90), Y
        
        LDA !top_x_bit_high : STA ($92)
        
        PLX
    
    .dont_draw_this_part
    
        REP #$20
        
        LDA $90 : ADD.w #$0004 : STA $90
        
        INC $92
        
        SEP #$20
        
        DEC $0E40, X
        
        LDY.b #$00
        
        JSR Sprite_PrepAndDrawSingleLarge.just_draw
        
        INC $0E40, X
        
        RTS
    }

; ==============================================================================
