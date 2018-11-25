
; ==============================================================================

    ; $F4270-$F4273 DATA
    pook Sprite_Flame:
    {
    
    .vh_flip
        db $00, $40, $C0, $80
    }

; ==============================================================================

    ; *$F4274-$F42B3 JUMP LOCATION
    Sprite_Flame:
    {
        LDA $0DF0, X : BNE Flame_Halted
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        
        LDA $1A : LSR #2 : AND.b #$03 : TAY
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        JSR Sprite3_CheckDamageToPlayer : BCS .hit_something
        
        JSR Sprite3_Move
        
        JSR Sprite3_CheckTileCollision : BNE .hit_something
        
        RTS
    
    .hit_something
    
        LDA.b #$7F : STA $0DF0, X
        
        LDA $0F50, X : AND.b #$3F : STA $0F50, X
        
        LDA.b #$2A : JSL Sound_SetSfx2PanLong
        
        RTS
    }

; ==============================================================================

    ; $F42B4-$F42D3 DATA
    pool Flame_Halted:
    {
    
    .animation_states
        db $05, $04, $03, $01, $02, $00, $03, $00
        db $01, $02, $03, $00, $01, $02, $03, $00
        db $01, $02, $03, $00, $01, $02, $03, $00
        db $01, $02, $03, $00, $01, $02, $03, $00
    }

; ==============================================================================

    ; *$F42D4-$F42FB BRANCH LOCATION
    Flame_Halted:
    {
        ; \task figure out if this can even happen. (player damaging flame)
        JSL Sprite_CheckDamageFromPlayerLong : BCC .player_didnt_damage
        
        DEC $0DF0, X : BEQ .self_terminate
    
    .player_didnt_damage
    
        LDA $0DF0, X : DEC A : BNE .still_burning
    
    .self_terminate
    
        STZ $0DD0, X
    
    .still_burning
    
        LDA $0DF0, X : LSR #3 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        JSL Flame_Draw
        JMP Sprite3_CheckDamageToPlayer
    }

; ==============================================================================

    ; $F42FC-$F435B DATA
    pool Flame_Draw:
    {
    
    .oam_groups
        dw 0,  0 : db $8E, $01, $00, $02
        dw 0,  0 : db $8E, $01, $00, $02
        
        dw 0,  0 : db $A0, $01, $00, $02
        dw 0,  0 : db $A0, $01, $00, $02
        
        dw 0,  0 : db $8E, $41, $00, $02
        dw 0,  0 : db $8E, $41, $00, $02
        
        dw 0,  0 : db $A0, $41, $00, $02
        dw 0,  0 : db $A0, $41, $00, $02
        
        dw 0,  0 : db $A2, $01, $00, $02
        dw 0,  0 : db $A2, $01, $00, $02
        
        dw 0, -6 : db $A4, $01, $00, $00
        dw 8, -6 : db $A5, $01, $00, $00
    }

; ==============================================================================

    ; *$F435C-$F4378 LONG
    Flame_Draw:
    {
        PHB : PHK : PLB
        
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #4 : ADC.w #(.oam_groups) : STA $08
        
        SEP #$20
        
        LDA.b #$02 : JSR Sprite3_DrawMultiple
        
        PLB
        
        RTL
    }

; ==============================================================================
