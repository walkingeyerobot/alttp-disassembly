
; ==============================================================================

    ; $3374A-$33753 DATA
    pool Sprite_EnemyArrow:
    {
        ; \wtf Was it supposed to have variable speed per frame originally?
        ; very unsual structure for a speed table.
    
    .x_speeds length 8
        db 0, 0
    
    .y_speeds
        db 16, 16, 0, 0, -16, -16, 0, 0
    }

; ==============================================================================

    ; *$33754-$337C2 JUMP LOCATION
    Sprite_EnemyArrow:
    {
        JSR EnemyArrow_Draw
        JSR Sprite_CheckIfActive.permissive
        
        LDA $0DD0, X : CMP.b #$09 : BNE BRANCH_337C7
        
        LDA $0DF0, X : BEQ BRANCH_ALPHA
        DEC A        : BNE BRANCH_BETA
        
        STZ $0DD0, X
        
        RTS
    
    BRANCH_BETA:
    
        CMP.b #$20 : BCC BRANCH_GAMMA
        AND.b #$01 : BNE BRANCH_GAMMA
        
        LDA $1A : ASL A : AND.b #$04 : ORA $0DE0, X : TAY
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite_Move
    
    BRANCH_GAMMA:
    
        RTS
    
    BRANCH_ALPHA:
    
        JSR Sprite_CheckDamageToPlayer_same_layer
        
        LDA $0E90, X : BNE BRANCH_DELTA
        
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ BRANCH_DELTA
        LDY $0D90, X : BEQ BRANCH_EPSILON
        
        JSL $06EE60 ; $36E60 IN ROM
        
        RTS
    
    BRANCH_EPSILON:
    
        LDA.b #$30 : STA $0DF0, X
        
        LDA.b #$02 : STA $0D90, X
        
        LDA.b #$08 : JSL Sound_SetSfx2PanLong
        
        RTS
        
        ; \task Why is there no branch to this location?
        
        STZ $0DD0, X
        
        JSL Sprite_PlaceRupulseSpark
    
    BRANCH_DELTA:
    
        JMP Sprite_Move
    }

; ==============================================================================

    ; $337C3-$337C6 DATA
    {
    
    .directions
        db 0, 2, 1, 3
    }

; ==============================================================================

    ; *$337C7-$33805 BRANCH LOCATION
    {
        LDA $0D80, X : BNE .prepped_for_fall_already
        
        JSR $E229   ; $36229 IN ROM
        
        LDA.b #$18 : STA $0F80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        INC $0D80, X
        
        STZ $0EF0, X
    
    .prepped_for_fall_already
    
        LDA $0DF0, X : LSR #3 : AND.b #$03 : TAY
        
        LDA $B7C3, Y : STA $0DE0, X
        
        JSR Sprite_MoveAltitude
        JSR Sprite_Move
        
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        LDA $0F70, X : BPL .hasnt_hit_ground
        
        STZ $0DD0, X
    
    .hasnt_hit_ground
    
        RTS
    }

; ==============================================================================

    ; $33806-$33866 DATA
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$33867-$338CD LOCAL
    EnemyArrow_Draw:
    {
        JSR Sprite_PrepOamCoord
        
        LDA $0DE0, X : ASL A : STA $06
        
        LDA $0D90, X : ASL #3 : STA $07
        
        PHX
        
        LDX.b #$01
    
    .next
    
        PHX
        
        TXA : ADD $06 : PHA
        
        ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $B807, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $B817, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .inRangeY
        
        LDA.b #$F0 : STA ($90), Y
    
    .inRangeY
    
        PLA : ADD $07 : TAX
        
        LDA $B827, X           : INY : STA ($90), Y
        LDA $B847, X : ORA $05 : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next
        
        PLX
        
        RTS
    }

; ==============================================================================
