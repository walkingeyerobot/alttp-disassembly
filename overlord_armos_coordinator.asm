
    ; These are specific to this overlord.
    !coordinator_angle = $0B08
    
    !radius = $0B0A
    
    !overlord_x_low  = $0B08
    !overlord_x_high = $0B10
    
    !overlord_y_low  = $0B18
    !overlord_y_high = $0B20
    
    !coordinator_ai_state = $0B28
    
    !state_timer = $0B30
    
    !angle_step = $0B40
    
    ; These are indexed for each armos knight.
    !puppet_x_low  = $0B10
    !pupper_x_high = $0B20
    
    !puppet_y_low  = $0B30
    !puppet_y_high = $0B40

; ==============================================================================

    ; *$EEBEB-$EEBF2 LONG
    ArmosCoordinatorLong:
    {
        PHB : PHK : PLB
        
        JSR ArmosCoordinator_Main
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EEBF3-$EEC11 LOCAL
    ArmosCoordinator_Main:
    {
        LDA !state_timer, X : BEQ .timer_expired
        
        ; This variable acts as an autotimer for the overlord.
        DEC !state_timer, X
    
    .timer_expired
    
        LDA !coordinator_ai_state, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ArmosCoordinator_AwaitKnightActivation
        dw ArmosCoordinator_AwaitKnightsUnderCoercion
        dw ArmosCoordinator_TimedRotateThenTransition
        dw ArmosCoordinator_RadialContraction
        dw ArmosCoordinator_TimedRotateThenTransition
        dw ArmosCoordinator_RadialDilation
        dw ArmosCoordinator_OrderKnightsToBackWall
        dw ArmosCoordinator_CascadeKnightsToFrontWall
    }

; ==============================================================================

    ; *$EEC12-$EEC33 JUMP LOCATION
    ArmosCoordinator_AwaitKnightActivation:
    {
        ; Or rather, wait for the first one to ativate, but I think they all
        ; activate at the same time (rumble then start moving).
        LDA $0D90 : BEQ .wait_for_knights_to_activate
        
        LDA.b #$78 : STA !overlord_x_low, X
        
        LDA.b #$FF : STA !angle_step, X
        
        ; \hardcoded This is.... freaking ridiculous. It assumes that
        ; this overlord is in the last slot and that no others are present
        ; in the room.
        LDA.b #$40 : STA !radius
        
        LDA.b #$C0 : STA !coordinator_angle
        LDA.b #$01 : STA !coordinator_angle+1
        
        JSR ArmosCoordinator_TimedRotateThenTransition
    
    .wait_for_knights_to_activate
    
        RTS
    }

; ==============================================================================

    ; *$EEC34-$EEC41 JUMP LOCATION
    ArmosCoordinator_AwaitKnightsUnderCoercion:
    {
        ; Check for alive knights of a certain state?
        JSR ArmosCoordinator_AreAllActiveKnightsSubmissive
        
        BCC .delay_next_state
        
        INC !coordinator_ai_state, X
        
        LDA.b #$FF : STA !state_timer, X
    
    .delay_next_state
    
        RTS
    }

; ==============================================================================

    ; $EEC42-$EEC47 DATA
    pool ArmosCoordinator_OrderKnightsToBackWall:
    {
    
    .x_positions
        db $31, $4D, $69, $83, $9F, $BB
    }

; ==============================================================================

    ; *$EEC48-$EEC68 JUMP LOCATION
    ArmosCoordinator_OrderKnightsToBackWall:
    {
        LDA !state_timer, X : BNE .delay_movement
        
        JSR ArmosCoordinator_DisableKnights_XY_Coercion
        
        LDY.b #$05
    
    .next_knight
    
        LDA .x_position, Y : STA !puppet_x_low, Y
        
        LDA.b #$30 : STA !puppet_y_low, Y
        
        DEY : BPL .next_knight
        
        INC !coordinator_ai_state, X
        
        LDA.b #$FF : STA !state_timer, X
    
    .delay_movement
    
        RTS
    }

; ==============================================================================

    ; *$EEC69-$EEC95 JUMP LOCATION
    ArmosCoordinator_CascadeKnightsToFrontWall:
    {
        LDA !state_timer, X : BNE .delay_cascade
        
        LDY.b #$05
    
    .next_knight
    
        LDA !puppet_y_low, Y : INC A : STA !puppet_y_low, Y
        
        ; \unused Wait.... is this at all useful useful?
        CPY.b #$00
        
        CMP.b #$C0 : BNE .not_at_front_wall_yet
        
        LDA.b #$01 : STA !coordinator_ai_state, X
        
        LDA !angle_step, X : EOR.b #$FF : INC A : STA !angle_step, X
        
        JSR ArmosCoordinator_DisableKnights_XY_Coercion
        JSR ArmosCoordinator_Rotate
        
        RTS
    
    .not_at_front_wall_yet
    
        DEY : BPL .next_knight
    
    .delay_cascade
    
        RTS
    }

; ==============================================================================

    ; *$EEC96-$EECAA JUMP LOCATION
    ArmosCoordinator_RadialContraction:
    {
        LDA !radius : DEC A : STA !radius : CMP.b #$20 : BNE .await_contraction
        
        INC !coordinator_ai_state, X
        
        LDA.b #$40 : STA !state_timer, X
    
    .await_contraction
    
        BRA ArmosCoordinator_Rotate
    }

; ==============================================================================

    ; $EECAB-$EECBF JUMP LOCATION
    ArmosCoordinator_RadialDilation:
    {
        LDA !radius : INC A : STA !radius : CMP.b #$40 : BNE .await_dilation
        
        INC !coordinator_ai_state, X
        
        LDA.b #$40 : STA !state_timer, X
    
    .await_dilation
    
        BRA ArmosCoordinator_Rotate
    }

; ==============================================================================

    ; $EECC0-$EECCB DATA
    pool ArmosCoordinator_Rotate:
    {
        ; \note Multiples of 0x0055, but not strictly in order.
        dw $0000, $01A9, $0154, $00FF, $00AA, $0055
    }

; ==============================================================================

    ; \task Maybe rename to soemthing like *..._SetRadialPositions?
    ; *$EECCC-$EEDB7 JUMP LOCATION
    ArmosCoordinator_TimedRotateThenTransition:
    {
        LDA !state_timer, X : BNE .delay_transition
        
        INC !coordinator_ai_state, X
    
    .delay_transition
    
    ; *$EECD4 ALTERNATE ENTRY POINT
    shared ArmosCoordinator_Rotate:
    
        LDY.b #$00
        
        LDA !angle_step, X : BPL .sign_extend_angle_step
        
        DEY
    
    .sign_extend_angle_step
    
              ADD !coordinator_angle   : STA !coordinator_angle
        TYA : ADC !coordinator_angle+1 : STA !coordinator_angle+1
        
        STZ $0FB5
    
    .next_knight
    
        LDA $0FB5 : PHA : ASL A : TAY
        
        REP #$20
        
        LDA !coordinator_angle : ADD $ECC0, Y : STA $00
        
        SEP #$20
        
        PLY
        
        LDA !radius : STA $0F
        
        PHX
        
        REP #$30
        
        LDA $00 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $04
        
        LDA $00 : ADD.w #$0080 : STA $02
        
        AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $06
        
        SEP #$30
        
        PLX
        
        LDA $04 : STA $4202
        
        LDA $0F
        
        LDY $05 : BNE BRANCH_GAMMA
        
        STA $4203
        
        NOP #8
        
        ; \bug(maybe) Is $4216 readable? What is the actual point of this?
        ; Whatever is read out is open bus so it would be the value from
        ; $4203, I think...
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_GAMMA:
    
        LSR $01 : BCC BRANCH_DELTA
        
        EOR.b #$FF : INC A
    
    BRANCH_DELTA:
    
        STZ $0A
        
        CMP.b #$00 : BPL BRANCH_EPSILON
        
        DEC $0A
    
    BRANCH_EPSILON:
    
        ADD !overlord_x_low,  X : LDY $0FB5 : STA !puppet_x_low,  Y
        LDA !overlord_x_high, X : ADC $0A   : STA !pupper_x_high, Y
        
        LDA $06 : STA $4202
        
        LDA $0F
        
        LDY $07 : BNE BRANCH_ZETA
        
        STA $4203
        
        NOP #8
        
        ; \bug(maybe) Scroll up and read.
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_ZETA:
    
        LSR $03 : BCC BRANCH_THETA
        
        EOR.b #$FF : INC A
    
    BRANCH_THETA:
    
        STZ $0A
        
        CMP.b #$00 : BPL BRANCH_IOTA
        
        DEC $0A
    
    BRANCH_IOTA:
    
        ADD !overlord_y_low, X  : LDY $0FB5 : STA !puppet_y_low,  Y
        LDA !overlord_y_high, X : ADC $0A   : STA !puppet_y_high, Y
        
        INC $0FB5
        
        LDA $0FB5 : CMP.b #$06 : BEQ .return
        
        JMP .next_knight
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$EEDB8-$EEDCA LOCAL
    ArmosCoordinator_AreAllActiveKnightsSubmissive:
    {
        LDY.b #$05
    
    .next_knight
    
        LDA $0DD0, Y : BEQ .dead_knight
        
        LDA $0D80, Y : BNE .submissive_knight
        
        ; If we find a non submissive knight (which means not in position yet),
        ; return a fail status.
        CLC
        
        RTS
    
    .submissive_knight
    .dead_knight
    
        DEY : BPL .next_knight
        
        SEC
        
        RTS
    } 

; ==============================================================================

    ; Instead of being forced to specific coordinates by the coordinator,
    ; configure the knights to be guided to specific coordinates.
    ; *$EEDCB-$EEDD5 LOCAL
    ArmosCoordinator_DisableKnights_XY_Coercion:
    {
        LDY.b #$05
    
    .next_knight
    
        LDA.b #$00 : STA $0D80, Y
        
        DEY : BPL .next_knight
        
        RTS
    }

; ==============================================================================
