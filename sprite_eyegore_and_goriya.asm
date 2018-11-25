
; ==============================================================================

    ; *$F4700-$F4720 LONG
    SpritePrep_Eyegore:
    {
        LDA $048E
        
        CMP.b #$0C : BEQ .is_goriya
        CMP.b #$1B : BEQ .is_goriya
        CMP.b #$4B : BEQ .is_goriya
        CMP.b #$6B : BNE .not_goriya
    
    .is_goriya:
    
        INC $0DA0, X
        
        LDA $0E20, X : CMP.b #$83 : BNE .not_red_goriya
        
        ; Disable some of the invulnerability properties.
        STZ $0CAA, X
    
    .not_red_goriya
    .not_goriya
    
        RTL
    }

; ==============================================================================

    ; $F4721-$F4790 DATA
    {
    
    }

; ==============================================================================

    ; *$F4791-$F479A BRANCH LOCATION
    Goriya_StayStill:
    {
        STZ $0D90, X
        
        JSR Sprite3_CheckDamage
        JSR Sprite3_CheckTileCollision
        
        RTS
    }

; ==============================================================================

    ; *$F479B-$F4838 JUMP LOCATION
    Sprite_Eyegore:
    {
        LDA $0DA0, X : BNE Sprite_Goriya
        
        JMP Eyegore_Main
    
    Sprite_Goriya:
    
        JSL Goriya_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        
        LDA $0E00, X : BEQ .phlegm_inhibit
        CMP.b #$08   : BNE .phlegm_delay
        
        JSL Sprite_SpawnFirePhlegm
    
    .phlegm_delay
    .phlegm_inhibit
    
        ; Ignore the player just pressing against a wall
        LDA $0048 : CMP.b #$00 : BNE Goriya_StayStill
        
        LDY $0E20, X
        
        LDA $F0 : AND.b #$0F : BEQ Goriya_StayStill
        
        CPY.b #$84 : BNE .not_faster_goriya
        
        ORA.b #$10
    
    .not_faster_goriya
    
        TAY
        
        LDA $C761, Y : STA $0DE0, X
        
        LDA $C721, Y : STA $0D50, X
        
        LDA $C741, Y : STA $0D40, X
        
        LDA $0E70, X : BNE .tile_collision
        
        JSR Sprite3_Move
    
    .tile_collision
    
        JSR Sprite3_CheckDamage
        JSR Sprite3_CheckTileCollision
        
        INC $0E80, X : LDA $0E80, X : AND.b #$0C : ORA $0DE0, X : TAY
        
        LDA $C781, Y : STA $0DC0, X
        
        LDA $0E20, X : CMP.b #$84 : BNE .no_fire_phlegm_logic
        
        JSR Sprite3_DirectionToFacePlayer
        
        LDA $0F : ADD.b #$08 : CMP.b #$10 : BCC .in_firing_line
        LDA $0E : ADD.b #$08 : CMP.b #$10 : BCS .not_in_firing_line
    
    .in_firing_line
    
        TYA : CMP $0DE0, X : BNE .not_facing_player
        
        LDA $0D90, X : AND.b #$1F : BNE .phlegm_charge_counter_not_maxed
        
        LDA.b #$10 : STA $0E00, X
    
    .phlegm_charge_counter_not_maxed
    
        INC $0D90, X
        
        RTS
    
    .not_facing_player
    .not_in_firing_line
    .no_fire_phlegm_logic
    
        STZ $0D90, X
        
        RTS
    }
    
; ==============================================================================

    ; *$F4839-$F4863 ALTERNATE ENTRY POINT
    Eyegore_Main:
    {
        JSR Eyegore_Draw
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        
        LDA $0E60, X : ORA.b #$40 : STA $0E60, X
        LDA $0CAA, X : ORA.b #$04 : STA $0CAA, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Eyegore_WaitUntilPlayerNearby
        dw Eyegore_OpeningEye
        dw Eyegore_ChasePlayer
        dw Eyegore_ClosingEye
    }

; ==============================================================================

    ; $F4864-$F4867 DATA
    pool Eyegore:
    {
    
    .timers
        db $60, $80, $A0, $80
    }

; ==============================================================================

    ; *$F4868-$F488A JUMP LOCATION
    Eyegore_WaitUntilPlayerNearby:
    {
        LDA $0DF0, X : BNE .delay
        
        JSR Sprite3_DirectionToFacePlayer
        
        LDA $0E : ADD.b #$30 : CMP.b #$60 : BCS .player_not_close
        
        LDA $0F : ADD.b #$30 : CMP.b #$60 : BCS .player_not_close
        
        INC $0D80, X
        
        LDA.b #$3F : STA $0DF0, X
    
    .player_not_close
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F488B-$F4892 DATA
    pool Eyegore_OpeningEye:
    {
        db $02, $02, $02, $02, $01, $01, $00, $00
    }

; ==============================================================================

    ; *$F4893-$F48BA JUMP LOCATION
    Eyegore_OpeningEye:
    {
        LDA $0DF0, X : BNE .delay
        
        JSR Sprite3_DirectionToFacePlayer : TYA : STA $0DE0, X
        
        INC $0D80, X
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA Eyegore.timers, Y : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    
    }

; ==============================================================================

    ; $F48BB-$F48CA DATA
    pool Eyegore_ChasePlayer:
    {
    
    .animation_states
        db $07, $05, $02, $09, $08, $06, $03, $0A
        db $07, $05, $02, $09, $08, $06, $04, $0B
    }

; ==============================================================================

    ; *$F48CB-$F492D JUMP LOCATION
    Eyegore_ChasePlayer:
    {
        LDA $0E60, X : AND.b #$BF : STA $0E60, X
        
        LDA $0E20, X : CMP.b #$84 : BEQ .is_red_eyegore
        
        LDA $0CAA, X : AND.b #$FB : STA $0CAA, X
    
    .is_red_eyegore
    
        LDA $0DF0, X : BNE .close_eye_delay
        
        LDA.b #$3F : STA $0DF0, X
        
        INC $0D80, X
        
        STZ $0DC0, X
        
        RTS
    
    .close_eye_delay
    
        TXA : EOR $1A : AND.b #$1F : BNE .face_player_delay
        
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : STA $0DE0, X
    
    .face_player_delay
    
        LDY $0DE0, X
        
        LDA Sprite3_Shake.x_speeds, Y : STA $0D50, X
        
        LDA Sprite3_Shake.y_speeds, Y : STA $0D40, X
        
        LDA $0E70, X : BNE .collided_with_tile
        
        JSR Sprite3_Move
    
    .collided_with_tile
    
        JSR Sprite3_CheckTileCollision
        
        INC $0E80, X : LDA $0E80, X : AND.b #$0C : ORA $0DE0, X : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F492E-$F4935 DATA
    pool Eyegore_ClosingEye:
    {
    
    .animation_states
        db $00, $00, $01, $01, $02, $02, $02, $02
    }

; ==============================================================================

    ; *$F4936-$F494E JUMP LOCATION
    Eyegore_ClosingEye:
    {
        LDA $0DF0, X : BNE .delay
        
        STZ $0D80, X
        
        LDA.b #$60 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $F494F-$F4ACE DATA
    pool Eyegore_Draw:
    {
    
    .oam_groups
        dw -4, -4 : db $A2, $00, $00, $02
        dw  4, -4 : db $A2, $40, $00, $02
        dw -4,  4 : db $9C, $00, $00, $02
        dw  4,  4 : db $9C, $40, $00, $02
        
        dw -4, -4 : db $A4, $00, $00, $02
        dw  4, -4 : db $A4, $40, $00, $02
        dw -4,  4 : db $9C, $00, $00, $02
        dw  4,  4 : db $9C, $40, $00, $02
        
        dw -4, -4 : db $8C, $00, $00, $02
        dw  4, -4 : db $8C, $40, $00, $02
        dw -4,  4 : db $9C, $00, $00, $02
        dw  4,  4 : db $9C, $40, $00, $02
        
        dw -4, -3 : db $8C, $00, $00, $02
        dw 12, -3 : db $8C, $40, $00, $00
        dw -4, 13 : db $BC, $00, $00, $00
        dw  4,  5 : db $8A, $40, $00, $02
        
        dw -4, -3 : db $8C, $00, $00, $00
        dw  4, -3 : db $8C, $40, $00, $02
        dw -4,  5 : db $8A, $00, $00, $02
        dw 12, 13 : db $BC, $40, $00, $00
        
        dw  0, -4 : db $AA, $00, $00, $02
        dw  0,  4 : db $A6, $00, $00, $02
        dw  0, -4 : db $AA, $00, $00, $02
        dw  0,  4 : db $A6, $00, $00, $02
        
        dw  0, -3 : db $AA, $00, $00, $02
        dw  0,  4 : db $A8, $00, $00, $02
        dw  0, -3 : db $AA, $00, $00, $02
        dw  0,  4 : db $A8, $00, $00, $02
        
        dw  0, -4 : db $AA, $40, $00, $02
        dw  0,  4 : db $A6, $40, $00, $02
        dw  0, -4 : db $AA, $40, $00, $02
        dw  0,  4 : db $A6, $40, $00, $02
        
        dw  0, -3 : db $AA, $40, $00, $02
        dw  0,  4 : db $A8, $40, $00, $02
        dw  0, -3 : db $AA, $40, $00, $02
        dw  0,  4 : db $A8, $40, $00, $02
        
        dw -4, -4 : db $8E, $00, $00, $02
        dw  4, -4 : db $8E, $40, $00, $02
        dw -4,  4 : db $9E, $00, $00, $02
        dw  4,  4 : db $9E, $40, $00, $02
        
        dw -4, -3 : db $8E, $00, $00, $02
        dw 12, -3 : db $8E, $40, $00, $00
        dw -4, 13 : db $BD, $00, $00, $00
        dw  4,  5 : db $A0, $40, $00, $02
        
        dw -4, -3 : db $8E, $00, $00, $00
        dw  4, -3 : db $8E, $40, $00, $02
        dw -4,  5 : db $A0, $00, $00, $02
        dw 12, 13 : db $BD, $40, $00, $00  
    }

; ==============================================================================

    ; *$F4ACF-$F4AF3 LOCAL
    Eyegore_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #5 : ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$04 : JSR Sprite3_DrawMultiple
        
        ; \note I don't get this. Most other sprites don't have this check,
        ; do they?
        LDA $0F00, X : BNE .dont_draw_shadow
        
        LDA.b #$0E : JSL Sprite_DrawShadowLong.variable
    
    .dont_draw_shadow
    
        RTS
    }

; ==============================================================================

