
; ==============================================================================

    ; $6BB5B-$6BB5D DATA TABLE
    pool Sound_SetSfxPan:
    {
    
    .pan_options
        dw $00, $80, $40
    }

; ==============================================================================

    ; *$6BB5E-$6BB66 LONG
    Sound_SfxPanObjectCoords:
    {
        LDA $0C18, X : XBA
        LDA $0C04, X
        
        BRA Sound_SetSfxPan.useArbitraryCoords
    }

; ==============================================================================

    ; *$6BB67-$6BB6D LONG
    Sound_SetSfxPanWithPlayerCoords:
    {
        LDA $23 : XBA
        LDA $22
        
        BRA Sound_SetSfxPan.useArbitraryCoords
    }

; ==============================================================================

    ; *$6BB6E-$6BB7B LONG
    Sound_SetSfx1PanLong:
    {
        PHY
        
        LDY $012D : BNE .channelInUse
        
        JSR Sound_AddSfxPan
        
        STA $012D
    
    .channelInUse
    
        PLY
        
        RTL
    }

; ==============================================================================

    ; *$6BB7C-$6BB89 LONG
    Sound_SetSfx2PanLong:
    {
        PHY
        
        LDY $012E : BEQ .channelInUse
        
        JSR Sound_AddSfxPan
        
        STA $012E
    
    .channelInUse
    
        PLY
        
        RTL
    }

; ==============================================================================

    ; *$6BB8A-$6BB97 LONG
    Sound_SetSfx3PanLong:
    {
        PHY
        
        ; Is there a sound effect playing on this channel?
        LDY $012F : BNE .channelInUse
        
        JSR Sound_AddSfxPan
        
        ; Picked a sound effect, play it.
        STA $012F
    
    .channelInUse
    
        PLY
        
        RTL
    }

; ==============================================================================

    ; *$6BB98-$6BBA0 LOCAL
    Sound_AddSfxPan:
    {
        ; Store the sound effect index here temporarily.
        STA $0D : JSL Sound_SetSfxPan : ORA $0D
        
        RTS
    }

; ==============================================================================

    ; *$6BBA1-$6BBC7 LONG
    Sound_SetSfxPan:
    {
        ; Used to determine stereo settings for sound effects
        ; For example, if a bomb is more towards the left of the screen, the sound will mostly
        ; come out of the left speaker. The sound engine knows how to handle these inputs
        
        LDA $0D30, X : XBA
        LDA $0D10, X
    
    ; *$6BBA8 BRANCH LOCATION
    .useArbitraryCoords
    
        REP #$20
        
        PHX
        
        LDX.b #$00
        
        ; A = Sprites X position minus the X coordinate of the scroll register for Layer 2.
        ; If A (unsigned) is less than #$50. A will be #$0.
        SUB $E2 : SUB.w #$0050 : CMP.w #$0050 : BCC .panSelected
        
        INX
        
        CMP.w #$0000 : BMI .panSelected
        
        INX ; And if all else fails, A will be #$40.
    
    .panSelected
    
        SEP #$20
        
        LDA .pan_options, X
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; $6BBC8-$6BBCF DATA
    pool Sound_GetFineSfxPan:
    {
    
    .settings
        db $80, $80, $80, $00, $00, $40, $40, $40
    }

; ==============================================================================

    ; *$6BBD0-$6BBDF LONG
    Sound_GetFineSfxPan:
    {
        SUB $E2 : LSR #5 : PHX : TAX
        
        LDA .settings, X
        
        PLX
        
        RTL
    }

; ==============================================================================

