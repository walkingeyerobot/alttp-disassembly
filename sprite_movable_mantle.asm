
; ==============================================================================

    ; *$D7C31-$D7C38 LONG
    Sprite_MovableMantleLong:
    {
        ; Sprite Logic for sprite 0xEE - pushable mantle
        PHB : PHK : PLB
        
        JSR Sprite_MovableMantle
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$D7C39-$D7C9A LOCAL
    Sprite_MovableMantle:
    {
        JSR MovableMantle_Draw
        JSR Sprite6_CheckIfActive
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .return
        
        JSL Sprite_NullifyHookshotDrag
        JSL Sprite_RepelDashAttackLong
        
        ; Only moves if Zelda is following you
        LDA $7EF3CC : CMP.b #$01 : BNE .return
        
        ; Only moves if you have the lamp
        LDA $7EF34A : BEQ .return
        
        ; Won't work if you're dashing
        LDA $0372 : BNE .return
        
        ; (for the mantle, this is how many pixels it has moved right)
        LDA $0ED0, X : CMP.b #$90 : BEQ .return
        
        ; Recoil can't induce mantle movement.
        LDA $28 : CMP.b #$18 : BMI .return
        
        ; Set a game state (numerical, not bitwise).
        LDA.b #$04 : STA $7EF3C8
        
        INC $0E80, X : LDA $0E80, X : AND.b #$01 : BNE .delay_movement
        
        INC $0ED0, X
    
    .delay_movement
    
        ; Start playing dragging sound after 8 pixels of movement.
        LDA $0ED0, X : CMP.b #$08 : BCC .return
        
        LDA $012E : BNE .sfx_slot_in_use
        
        LDA.b #$22 : STA $012E
    
    .sfx_slot_in_use
    
        LDA.b #$02 : STA $0D50, X
        
        JSL Sprite_MoveLong
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $D7C9B-$D7CB2 DATA
    pool MovableMantle_Draw:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$D7CB3-$D7CEC LOCAL
    MovableMantle_Draw:
    {
        LDA.b #$20 : JSL OAM_AllocateFromRegionB
        
        JSL Sprite_PrepOamCoordLong : BCS .not_on_screen
        
        PHX
        
        LDX.b #$05
    
    .next_subsprite
    
        LDA $00      : ADD $FC9B, X       : STA ($90), Y
        LDA $02      : ADD $FCA1, X : INY : STA ($90), Y
        LDA $FCA7, X                : INY : STA ($90), Y
        LDA $FCAD, X                : INY : STA ($90), Y : INY
        
        DEX : BPL .next_subsprite
        
        PLX
        
        LDY.b #$02
        LDA.b #$05
        
        JSL Sprite_CorrectOamEntriesLong
    
    .not_on_screen
    
        RTS
    }

; ==============================================================================
