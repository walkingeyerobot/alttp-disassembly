
; ==============================================================================

    ; *$2FACA-$2FAD1 LONG
    Sprite_MadBatterLong:
    {
        ; Magic powder bat / lightning bolt he throws AI
        
        PHB : PHK : PLB
        
        JSR Sprite_MadBatter
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2FAD2-$2FAFE LOCAL
    Sprite_MadBatter:
    {
        LDA $0EB0, X : BEQ .not_thunderbolt
        
        JSL Sprite_MadBatterBoltLong
        
        RTS
    
    .not_thunderbolt
    
        LDA $0D80, X : BEQ .dont_draw
        
        JSL Sprite_PrepAndDrawSingleLargeLong
    
    .dont_draw
    
        JSR Sprite2_CheckIfActive
        JSR Sprite2_Move
        JSR Sprite2_MoveAltitude
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MadBatter_WaitForSummoning
        dw MadBatter_RisingUp
        dw MadBatter_PseudoAttackPlayer
        dw MadBatter_DoublePlayerMagicPower
        dw MadBatter_LaterBitches
    }

; ==============================================================================

    ; *$2FAFF-$2FB39 JUMP LOCATION
    MadBatter_WaitForSummoning:
    {
        LDA $7EF37B : CMP.b #$01 : BCS .magic_already_doubled
        
        ; The sprite doesn't actually damage the player, this is just to detect
        ; contact.
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .not_close_to_player
        
        ; Needs to be summoned via Magic Powder
        LDY.b #$04
    
    .next_object
    
        LDA $0C4A, Y : CMP.b #$1A : BEQ .magic_powder
        
        DEY : BPL .next_object
        
        RTS
    
    .magic_powder
    
        JSL Sprite_SpawnSuperficialBombBlast
        
        LDA.b #$0D : JSL Sound_SetSfx1PanLong
        
        INC $0D80, X
        
        LDA.b #$14 : STA $0D90, X
        
        LDA.b #$01 : STA $02E4
        
        LDA $0F50, X : ORA.b #$20 : STA $0F50, X
    
    .not_close_to_player
    .magic_already_doubled
    
        RTS
    }

; ==============================================================================

    ; $2FB3A-$2FB3B DATA
    pool MadBatter_RisingUp:
    {
    
    .x_speeds
        db -8,  7
    }

; ==============================================================================

    ; *$2FB3C-$2FB85 JUMP LOCATION
    MadBatter_RisingUp:
    {
        LDA $0DF0, X : BNE .delay
        
        DEC $0D90, X : LDA $0D90, X : STA $0DF0, X : CMP.b #$01 : BEQ .ready
        
        LSR #2 : STA $0F80, X
        
        LDA $0D90, X : AND.b #$01 : TAY
        
        LDA .x_speeds, Y : ADD $0D50, X : STA $0D50, X
        
        LDA $0DC0, X : EOR.b #$01 : STA $0DC0, X
    
    .delay
    
        RTS
    
    .ready
    
        ; Hey! Blast you for waking me from my deep, dark sleep! ...I mean..."
        LDA.b #$10
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        STZ $0DC0, X
        
        STZ $0F80, X
        
        STZ $0D50, X
        
        LDA.b #$FF : STA $0DF0, X
        
        RTS
    }

; ==============================================================================

    ; $2FB86-$2FB8D DATA
    pool MadBatter_PseudoAttackPlayer:
    {
    
    .palettes
        db $0A, $04, $02, $04, $02, $0A, $04, $02
    }

; ==============================================================================

    ; *$2FB8E-$2FBB8 JUMP LOCATION
    MadBatter_PseudoAttackPlayer:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0E00, X
        
        LDA $0DF0, X
    
    .delay
    
        LSR A : AND.b #$07 : TAY
        
        LDA $0F50, X : AND.b #$F1 : ORA .palettes, Y : STA $0F50, X
        
        LDA $0DF0, X : CMP.b #$F0 : BNE .delay_2
        
        JSL Sprite_SpawnMadBatterBolts
    
    .delay_2
    
        RTS
    }

; ==============================================================================

    ; *$2FBB9-$2FBE3 JUMP LOCATION
    MadBatter_DoublePlayerMagicPower:
    {
        LDA $0E00, X : BNE .delay
        
        ; "...I laugh at your misfortune! Now your magic power will drop..."
        LDA.b #$11
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        PHX
        
        JSL Palette_Restore_BG_And_HUD
        
        ; \note Redundant to do this, the subroutine does this.
        INC $15
        
        PLX
        
        INC $0D80, X
        
        ; Reduce the magic power consumption by 1/2.
        LDA.b #$01 : STA $7EF37B
        
        JSL HUD.RefreshIconLong
        
        RTS
    
    .delay
    
        CMP.b #$10 : BNE .dont_flash_screen
        
        STA $0FF9
    
    .dont_flash_screen
    
        RTS
    }

; ==============================================================================

    ; *$2FBE4-$2FBEE JUMP LOCATION
    MadBatter_LaterBitches:
    {
        JSL Sprite_SpawnDummyDeathAnimation
        
        STZ $0DD0, X
        
        STZ $02E4
        
        RTS
    }

; ==============================================================================
