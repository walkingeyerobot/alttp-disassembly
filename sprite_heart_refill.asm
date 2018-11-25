
; ==============================================================================

    ; *$34EC0-$34F09 JUMP LOCATION
    Sprite_HeartRefill:
    {
        JSR Sprite_DrawTransientAbsorbable
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckAbsorptionByPlayer
        JSR Sprite_HandleDraggingByAncilla
        JSR Sprite_Move
        JSR Sprite_MoveAltitude
        
        LDA $0F70, X : BPL .no_ground_collision
        
        STZ $0F70, X
        
        INC $0D80, X
        
        STZ $0DC0, X
    
    .no_ground_collision
    
        LDA $0F50, X : AND.b #$BF : STA $0F50, X
        
        LDA $0D50, X : BMI .moving_left
        
        LDA $0F50, X : EOR.b #$40 : STA $0F50, X
    
    .moving_left
    
        LDA $0D80, X : CMP.b #$03 : BCC .ai_state_not_maxed
        
        ; \note This ensures that we never run an AI handler that is beyond the
        ; given jump table. This is kind of good to do, but most components
        ; of this game do no such bound checking.
        LDA.b #$03
    
    .ai_state_not_maxed
    
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw HeartRefill_InitializeAscent
        dw HeartRefill_BeginDescending
        dw HeartRefill_GlideGroundward
        dw HeartRefill_Grounded
    }

; ==============================================================================

    ; *$34F0A-$34F1F JUMP LOCATION
    HeartRefill_InitializeAscent:
    {
        INC $0D80, X
        
        LDA.b #$12 : STA $0DF0, X
        
        LDA.b #$14 : STA $0F80, X
        
        LDA.b #$01 : STA $0DC0, X
        
        STZ $0DE0, X
        
        RTS
    }

; ==============================================================================

    ; *$34F20-$34F34 JUMP LOCATION
    HeartRefill_BeginDescending:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$FD : STA $0F80, X
        
        STZ $0D50, X
        
        RTS
    
    .delay
    
        DEC $0F80, X
        
        RTS
    }

; ==============================================================================

    ; $34F35-$34F36 DATA
    pool HeartRefill_GlideGroundward:
    {
        db 10, -10
    }

; ==============================================================================

    ; *$34F37-$34F59 JUMP LOCATION
    HeartRefill_GlideGroundward:
    {
        LDA $0DF0, X : BNE .delay
        
        LDA $0DE0, X : AND.b #$01 : TAY
        
        LDA $0D50, X : ADD $A213, Y : STA $0D50, X
        
        CMP $CF35, Y : BNE .anoswitch_direction
        
        INC $0DE0, X
        
        LDA.b #$08 : STA $0DF0, X
    
    .delay
    .anoswitch_direction
    
        RTS
    }

; ==============================================================================

    ; *$34F5A-$34F63 JUMP LOCATION
    HeartRefill_Grounded:
    shared Sprite_Zero_XYZ_Velocity:
    {
        STZ $0F80, X
    
    ; *$34F5D ALTERNATE ENTRY POINT
    shared Sprite_Zero_XY_Velocity:
    
        STZ $0D50, X
        STZ $0D40, X
        
        RTS
    }

; ==============================================================================
