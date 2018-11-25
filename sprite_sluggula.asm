
; ==============================================================================

    ; $315C9-$315D8 DATA
    pool Sprite_Sluggula:
    {
    
    .animation_states
        db 0, 1, 0, 1, 2, 3, 4, 5
    
    .h_flip
        db $40, $40, $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$315D9-$31614 JUMP LOCATION
    Sprite_Sluggula:
    {
        LDA $0E80, X : AND.b #$08 : LSR #3 : STA $00
        
        LDA $0DE0, X : ASL A : ORA $00 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0F50, X : AND.b #$BF : ORA .h_flip, Y : STA $0F50, X
        
        JSR Sprite_PrepAndDrawSingleLarge
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckIfRecoiling
        JSR Sprite_CheckDamage
        
        INC $0E80, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Sluggula_Normal
        dw Sluggula_BreakFromBombing:
    }

; ==============================================================================

    ; $31615-$3161A DATA
    pool Sluggula_Normal:
    {
    
    .x_speeds length 4
        db 16, -16
    
    .y_speeds
        db  0,   0,  16, -16
    }

; ==============================================================================

    ; *$3161B-$31672 JUMP LOCATION
    Sluggula_Normal:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$1F : ADC.b #$20 : STA $0DF0, X
        
        AND.b #$03 : STA $0DE0, X
    
    .set_speed
    
        TAY
        
        LDA $9615, Y : STA $0D50, X
        
        LDA $9617, Y : STA $0D40, X
        
        RTS
    
    .delay
    
        CMP.b #$10 : BNE .return
        
        JSL GetRandomInt : LSR A : BCS .return
        
        JMP Sluggula_LayBomb
    
    ; *$3164F ALTERNATE ENTRY POINT
    shared Sluggula_BreakFromBombing:
    
        LDA $0DF0, X : BNE .delay_resumption_of_bombing
        
        STZ $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
    
    .delay_resumption_of_bombing
    
        JSR Sprite_Move
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .return
        
        LDA $0DE0, X : EOR.b #$01 : STA $0DE0, X
        
        JMP .set_speed
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$31673-$31685 JUMP LOCATION
    Sluggula_LayBomb:
    {
        ; Spawn a Red Bomb Soldier...
        LDA.b #$4A
        LDY.b #$0B
        
        JSL Sprite_SpawnDynamically.arbitrary : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        ; ... but once spawned, transmute it to an enemy bomb.
        JSL Sprite_TransmuteToEnemyBomb
    
    .spawn_failed
    
        RTS
    }

; ==============================================================================
