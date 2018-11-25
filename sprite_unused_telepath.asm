
; ==============================================================================

    ; $6C6DE-$6C6E5 LONG
    Sprite_UnusedTelepathLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_UnusedTelepath
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \tcrf(verified)
    ; This sprite appears to be a prototype or alternate for the telepathic
    ; tiles found in dungeons, which are background (tilemap) based. It is
    ; unknown what it was meant to look like, though note that it does
    ; alternate between two graphical states, similarly to Sahasrahla.
    ; No existing sprite graphics pack seems to match the configuration of how
    ; this sprite is drawn. I can only assume that the graphics were removed
    ; at some point during development.
    
    ; *$6C6E6-$6C706 LOCAL
    Sprite_UnusedTelepath:
    {
        JSR UnusedTelepath_Draw
        JSR Sprite5_CheckIfActive
        
        ; "...it is I, Sahasrahla the elder. An orb known as the Moon Pearl..."
        LDA.b #$B5
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        JSL Sprite_PlayerCantPassThrough
        
        LDA $1A : LSR A : ORA $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $6C707-$6C736 DATA
    pool UnusedTelepath_Draw:
    {
    
    .oam_groups
        dw 4, -14 : db $AE, $00, $00, $00
        dw 0, -16 : db $82, $00, $00, $02
        dw 0,   0 : db $AA, $00, $00, $02
        
        dw 4, -16 : db $AE, $00, $00, $00
        dw 0, -16 : db $80, $00, $00, $02
        dw 0,   0 : db $A0, $00, $00, $02
    }

; ==============================================================================

    ; *$6C737-$6C759 LOCAL
    UnusedTelepath_Draw:
    {
        LDA.b #$03 : STA $06
                     STZ $07
        
        LDA $0DC0, X : ASL A : ADC $0DC0, X : ASL #3
        
        ADC.b #(.oam_groups >> 0)              : STA $08
        LDA.b #(.oam_groups >> 8) : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
