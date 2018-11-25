
; ==============================================================================

    ; *$33DC1-$33DCF JUMP LOCATION
    Sprite_HoboEntities:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sprite_Hobo
        dw Sprite_HoboBubble
        dw Sprite_HoboFire
        dw Sprite_HoboSmoke
    }

; ==============================================================================

    ; *$33DD0-$33DF9 JUMP LOCATION
    Sprite_Hobo:
    {
        JSL Hobo_Draw
        JSR Sprite_CheckIfActive
        
        LDA.b #$03 : STA $0F60, X
        
        JSR Sprite_CheckDamageToPlayer.same_layer : BCC .no_player_collision
        
        JSL Sprite_NullifyHookshotDrag
        
        STZ $5E
        
        JSL Player_HaltDashAttackLong
    
    .no_player_collision
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Hobo_Sleeping
        dw Hobo_WakeUp
        dw Hobo_GrantBottle
        dw Hobo_BackToSleep
    }

; ==============================================================================

    ; *$33DFA-$33E29 JUMP LOCATION
    Hobo_Sleeping:
    {
        LDA.b #$07 : STA $0F60, X
        
        JSR Sprite_CheckDamageToPlayer.same_layer : BCC .dont_wake_up
        
        LDA $F6 : BPL .dont_wake_up
        
        INC $0D80, X
        
        LDY $0E90, X
        
        LDA.b #$04 : STA $0DF0, Y
        
        LDA.b #$01 : STA $02E4
    
    .dont_wake_up
    
        LDA $0E10, X : BNE .delay_bubble_spawn
        
        LDA.b #$A0 : STA $0E10, X
        
        JSR Hobo_SpawnBubble
        
        TYA : STA $0E90, X
    
    .delay_bubble_spawn
    
        RTS
    }

; ==============================================================================

    ; $33E2A-$33E38 DATA
    pool Hobo_WakeUp:
    {
    
    .animation_states
        db 0, 1, 0, 1, 0, 1, 2, -1
    
    .timers
        db 6, 2, 6, 6, 2, 100, 30
    }

; ==============================================================================

    ; *$33E39-$33E5E JUMP LOCATION
    Hobo_WakeUp:
    {
        LDA $0DF0, X : BNE .delay
        
        LDY $0D90, X
        
        LDA .animation_states, Y : BMI .invalid_state
        
        STA $0DC0, X
        
        LDA .timers, Y : STA $0DF0, X
        
        INC $0D90, X
    
    .delay
    
        RTS
    
    .invalid_state
    
        ; "Yo! [Name]! You seem to be in a heap of trouble, ... this is all..."
        LDA.b #$D7
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$33E5F-$33E88 JUMP LOCATION
    Hobo_GrantBottle:
    {
        INC $0D80, X
        
        LDA.b #$01 : STA $0DC0, X
        
        PHX
        
        LDX $8A
        
        ; \event
        LDA $7EF280, X : ORA.b #$20 : STA $7EF280, X
        
        LDY.b #$16
        
        STZ $02E9
        
        ; \item
        ; Hobo gives you his bottle
        JSL Link_ReceiveItem
        
        ; \event
        LDA $7EF3C9 : ORA.b #$01 : STA $7EF3C9
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$33E89-$33E9C JUMP LOCATION
    Hobo_BackToSleep:
    {
        STZ $02E4
        
        STZ $0DC0, X
        
        LDA $0DF0, X : BNE .bubble_spawn_delay
        
        LDA.b #$A0 : STA $0DF0, X
        
        JSR Hobo_SpawnBubble
    
    .bubble_spawn_delay
    
        RTS
    }

; ==============================================================================

    ; \note I know, why would this guy spawn himself? Makes no sense.
    ; *$33E9D-$33EB1 LOCAL
    Hobo_SpawnHobo:
    {
        LDA.b #$2B : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$00 : STA $0E80, Y
                     STA $0BA0, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; \unused Probably speeds. Maybe at one point the bubble bobbed up and down
    ; above the hobo's mouth?
    ; $33EB2-$33EB3 DATA
    pool Sprite_HoboBubble:
    {
    
    .unused
        db 1, -1
    }

; ==============================================================================

    ; *$33EB4-$33EEC JUMP LOCATION
    Sprite_HoboBubble:
    {
        LDA.b #$04 : JSL OAM_AllocateFromRegionC
        
        JSR Sprite_PrepAndDrawSingleSmall
        JSR Sprite_CheckIfActive
        
        LDA $1A : LSR #4 : AND.b #$01 : INC #2 : STA $0DC0, X
        
        LDA $0E00, X : BNE .ascend_delay
        
        INC $0DC0, X
        
        JSR Sprite_MoveAltitude
        
        LDA $0DF0, X : BNE .termination_delay
        
        STZ $0DD0, X
    
    .ascend_delay
    .termination_delay
    
        LDA $0DF0, X : CMP.b #$04 : BCS .anowrap_animation_counter
        
        LDA.b #$03 : STA $0DC0, X
    
    .anowrap_animation_state
    
        RTS
    }

; ==============================================================================

    ; *$33EED-$33F14 LOCAL
    Hobo_SpawnBubble:
    {
        ; Spawn the sleep bubble hanging out of the hobo's nose?
        LDA.b #$2B
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$01 : STA $0E80, Y
        
        LDA.b #$02 : STA $0F80, Y
        
        LDA.b #$60 : STA $0DF0, Y
        
        LSR A : STA $0E00, Y : STA $0BA0, Y
    
    ; *$33F0F ALTERNATE ENTRY POINT
    shared Sprite_ZeroOamAllocation:
    
        ; Zeroes out the sprite's oam slot allocation making it impossible to
        ; store any entries to the oam buffer, sort of...
        ; This seems to suggest that sprites that call this have manual
        ; oam allocation somewhere in their logic.
        LDA.b #$00 : STA $0E40, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; *$33F15-$33F4A JUMP LOCATION
    Sprite_HoboFire:
    {
        JSR Sprite_PrepAndDrawSingleSmall
        JSR Sprite_CheckIfActive
        
        LDA $1A : LSR #3 : AND.b #$03 : STA $00
        
        AND.b #$01 : STA $0DC0, X
        
        LDA $00 : ASL #4 : AND.b #$40 : STA $00
        
        ; Toggle... hflip? what? \wtf
        LDA $0F50, X : AND.b #$BF : ORA $00 : STA $0F50, X
        
        LDA $0DF0, X : BNE .delay_smoke_spawn
        
        JSR HoboFire_SpawnSmoke
        
        LDA.b #$2F : STA $0DF0, X
    
    .delay_smoke_spawn
    
        RTS
    }

; ==============================================================================

    ; *$33F4B-$33F7C LOCAL
    Hobo_SpawnCampfire:
    {
        LDA.b #$2B
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA.b #$94 : STA $0D10, Y
        
        LDA.b #$01 : STA $0D30, Y
        
        LDA.b #$3F : STA $0D00, Y
        
        LDA.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y : STA $0BA0, Y
        
        JSR Sprite_ZeroOamAllocation
        
        LDA $0F50, Y : AND.b #$F1 : ORA.b #$02 : STA $0F50, Y
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================

    ; $33F7D-$33F80 DATA
    pool Sprite_HoboSmoke:
    {
    
    .vh_flip
        db $00, $40, $80, $C0
    }

; ==============================================================================

    ; *$33F81-$33FAE JUMP LOCATION
    Sprite_HoboSmoke:
    {
        LDA.b #$06 : STA $0DC0, X
        
        JSR Sprite_PrepAndDrawSingleSmall
        JSR Sprite_CheckIfActive
        JSR Sprite_Move
        JSR Sprite_MoveAltitude
        
        LDA $1A : LSR #4 : AND.b #$03 : TAY
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        LDA $0DF0, X : BNE .termination_delay
        
        STZ $0DD0, X
    
    .termination_delay
    
        RTS
    }

; ==============================================================================

    ; *$33FAF-$33FDF LOCAL
    HoboFire_SpawnSmoke:
    {
        LDA.b #$2B
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        LDA $02 : SUB.b #$04 : STA $0D00, Y
        LDA $03 : SBC.b #$00 : STA $0D20, Y
        
        LDA.b #$03 : STA $0E80, Y
        
        LDA.b #$07 : STA $0F80, Y
        
        LDA.b #$60 : STA $0DF0, Y : STA $0BA0, Y
        
        JSR Sprite_ZeroOamAllocation
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================
