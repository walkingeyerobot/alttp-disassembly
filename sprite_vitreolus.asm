
; ==============================================================================

    ; $EE763-$EE772 DATA
    pool Sprite_Vitreolus:
    {
    
    .x_offsets
        dw 1,  0, -1,  0
    
    .y_offsets
        dw 0,  1,  0, -1
    }

; ==============================================================================

    ; *$EE773-$EE7C3 JUMP LOCATION
    Sprite_Vitreolus:
    {
        ; \note I chose this name because it sounds authentic enough and is, as
        ; best I can tell, a latin diminutive form of vitreous, or close to one.
        ; correct me if I'm wrong, anyone.
        
        ; Allows even numbers from 0 to 6 inclusive.
        LDA $0E80, X : LSR #3 : AND.b #$06 : TAY
        
        REP #$20
        
        LDA $0FD8 : ADD .x_offsets, Y : STA $0FD8
        
        LDA $0FDA : ADD .y_offsets, Y : STA $0FDA
        
        SEP #$20
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite4_CheckIfActive
        
        INC $0E80, X
        
        ; \note Interesting... active status indicated by its animation state?
        LDA $0DC0, X : BEQ .active
        
        RTS
    
    .active
    
        JSL Sprite_CheckDamageFromPlayerLong
        JSL Sprite_CheckDamageToPlayerLong
        
        LDA $0EA0, X : CMP.b #$0E : BNE .shorten_recoil_time
        
        LDA.b #$05 : STA $0EA0, X
    
    .shorten_recoil_time
    
        ; \optimize comparison with 0x01 could be changed to "dec a".
        LDA $0D80, X : BEQ Vitreolus_TargetPlayerPosition
        CMP.b #$01   : BEQ Vitreolus_PursueTargetPosition
        
        JMP Vitreolus_ReturnToOrigin
    }
    
; ==============================================================================

    ; $EE7C4-$EE7D8 BRANCH LOCATION
    Vitreolus_TargetPlayerPosition:
    {
        LDA $22 : STA $0ED0, X
        LDA $23 : STA $0EB0, X
        
        LDA $20 : STA $0EC0, X
        LDA $21 : STA $0E30, X
        
        RTS
    }
    
; ==============================================================================

    ; $EE7D9-$EE829 BRANCH LOCATION
    Vitreolus_PursueTargetPosition:
    {
        JSR Sprite4_CheckIfRecoiling
        
        TXA : EOR $1A : AND.b #$01 : BNE .stagger_retargeting
        
        LDA $0ED0, X : STA $04
        LDA $0EB0, X : STA $05
        
        LDA $0EC0, X : STA $06
        LDA $0E30, X : STA $07
        
        LDA.b #$10 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
    
    .stagger_retargeting
    
        JSR Sprite4_Move
        
        LDA $0ED0, X : SUB $0D10, X
                       ADD.b #$04 : CMP.b #$08 : BCS .not_at_target_position
        
        LDA $0EC0, X : SUB $0D00, X
                       ADD.b #$04 : CMP.b #$08 : BCS .not_at_target_position
        
        INC $0D80, X
    
    .not_at_target_position
    
        RTS
    }

; ==============================================================================

    ; *$EE82A-$EE892 JUMP LOCATION
    Vitreolus_ReturnToOrigin:
    {
        JSR Sprite4_CheckIfRecoiling
        
        TXA : EOR $1A : AND.b #$01 : BNE .stagger_retargeting
        
        LDA $0D90, X : STA $04
        LDA $0DA0, X : STA $05
        
        LDA $0DB0, X : STA $06
        LDA $0DE0, X : STA $07
        
        LDA.b #$10 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
    
    .stagger_retargeting
    
        JSR Sprite4_Move
        
        LDA $0D90, X : SUB $0D10, X
                       ADD.b #$04 : CMP.b #$08 : BCS .not_at_target_position
        
        LDA $0DB0, X : SUB $0D00, X
                       ADD.b #$04 : CMP.b #$08 : BCS .not_at_target_position
        
        LDA $0D90, X : STA $0D10, X
        LDA $0DA0, X : STA $0D30, X
        
        LDA $0DB0, X : STA $0D00, X
        LDA $0DE0, X : STA $0D20, X
        
        STZ $0D80, X
    
    .not_at_target_position
    
        RTS
    }

; ==============================================================================
