
; ==============================================================================

    ; *$EDC72-$EDC79 LONG
    Sprite_VultureLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_Vulture
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$EDC7A-$EDC9B LOCAL
    Sprite_Vulture:
    {
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR Vulture_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_CheckIfRecoiling
        JSR Sprite4_CheckDamage
        JSR Sprite4_Move
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Vulture_Dormant
        dw Vulture_Circling
    }

; ==============================================================================

    ; *$EDC9C-$EDCB4 JUMP LOCATION
    Vulture_Dormant:
    {
        INC $0E80, X : LDA $0E80, X : CMP.b #$A0 : BNE .activation_delay
        
        INC $0D80, X
        
        LDA.b #$1E : JSL Sound_SetSfx3PanLong
        
        LDA.b #$10 : STA $0DF0, X
    
    .activation_delay
    
        RTS
    }

; ==============================================================================

    ; $EDCB5-$EDCB8 DATA
    pool Vulture_Circling:
    {
    
    .animation_states
        db 1, 2, 3, 2
    }

; ==============================================================================

    ; *$EDCB9-$EDD1D JUMP LOCATION
    Vulture_Circling:
    {
        LDA $1A : LSR A : AND.b #$03 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA $0DF0, X : BEQ .finished_ascending
        
        INC $0F70, X
        
        RTS
    
    .finished_ascending
    
        TXA : EOR $1A : AND.b #$01 : BNE .dont_adjust_xy_speeds
        
        TXA : AND.b #$0F : ADD.b #$18
        
        JSL Sprite_ProjectSpeedTowardsPlayerLong
        
        LDA $00 : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA $01 : STA $0D40, X
        
        LDA $0E : ADD.b #$28 : CMP.b #$50 : BCS .too_far_from_player
        
        LDA $0F : ADD.b #$28 : CMP.b #$50 : BCS .too_far_from_player
    
    .dont_adjust_xy_speeds
    
        RTS
    
    .too_far_from_player
    
        ; This mess o' logic keep the vulture from going too far from the
        ; player by apparently reversing somewhat...
        LDA $00 : ASL $00 : PHP : ROR A : PLP : ROR A : ADD $0D40, X : STA $0D40, X
        
        LDA $01 : ASL $01 : PHP : ROR A : PLP : ROR A : ADD $0D50, X : STA $0D50, X
        
        RTS
    }

; ==============================================================================

    ; $EDD1E-$EDD5D DATA
    pool Vulture_Draw:
    {
    
    .oam_groups
        dw -8,  0 : db $86, $00, $00, $02
        dw  8,  0 : db $86, $40, $00, $02
        
        dw -8,  0 : db $80, $00, $00, $02
        dw  8,  0 : db $80, $40, $00, $02
        
        dw -8,  0 : db $82, $00, $00, $02
        dw  8,  0 : db $82, $40, $00, $02
        
        dw -8,  0 : db $84, $00, $00, $02
        dw  8,  0 : db $84, $40, $00, $02
    }

; ==============================================================================

    ; *$EDD5E-$EDD7A LOCAL
    Vulture_Draw:
    {
        LDA.b #$00 : XBA
        
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #.oam_groups : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite4_DrawMultiple
        
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================

