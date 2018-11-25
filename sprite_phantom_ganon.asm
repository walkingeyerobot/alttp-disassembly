
; ==============================================================================

    ; *$E88A1-$E88BB LONG
    Sprite_SpawnPhantomGanon:
    {
        ; Spawn one of Ganon's bats? Emerges from Agahnim, seems like.
        LDA.b #$C9 : JSL Sprite_SpawnDynamically
        
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$02 : STA $0E40, Y
                     STA $0BA0, Y
        DEC A      : STA $0EC0, Y
        DEC A      : STA $0F50, Y
        
        RTL
    }

; ==============================================================================

    ; *$E88BC-$E8905 JUMP LOCATION
    Sprite_PhantomGanon:
    {
        LDA $0D80, X : BNE Sprite_GanonBat
        
        JSR PhantomGanon_Draw
        JSR Sprite4_CheckIfActive
        JSR Sprite4_MoveVert
        
        INC $0E80, X
        
        LDA $0E80, X : AND.b #$1F : BNE .delay
        
        DEC $0D40, X
        
        LDA $0D40, X : CMP.b #$FC : BNE BRANCH_BETA
        
        PHA
        
        JSR Blind_SpawnPoof
        
        LDA $0D00, Y : SUB.b #$14 : STA $0D00, Y
        LDA $0D20, Y : SBC.b #$00 : STA $0D20, Y
        
        PLA
    
    BRANCH_BETA:
    
        CMP.b #$FB : BNE .dont_transform
        
        INC $0D80, X
        
        LDA.b #$FF : STA $0DF0, X
        
        LDA.b #$FC : STA $0D40, X
    
    .dont_transform
    .delay
    
        RTS
    }

; ==============================================================================

    incsrc "sprite_ganon_bat.asm"

; ==============================================================================

    ; $E8A04-$E8A83 DATA
    pool PhantomGanon_Draw:
    {
    
    .oam_groups
        dw -16, -8 : db $46, $0D, $00, $02
        dw  -8, -8 : db $47, $0D, $00, $02
        dw   8, -8 : db $47, $4D, $00, $02
        dw  16, -8 : db $46, $4D, $00, $02
        dw -16,  8 : db $69, $0D, $00, $02
        dw  -8,  8 : db $6A, $0D, $00, $02
        dw   8,  8 : db $6A, $4D, $00, $02
        dw  16,  8 : db $69, $4D, $00, $02
        
        dw -16, -8 : db $46, $0D, $00, $02
        dw  -8, -8 : db $47, $0D, $00, $02
        dw   8, -8 : db $47, $4D, $00, $02
        dw  16, -8 : db $46, $4D, $00, $02
        dw -16,  8 : db $66, $0D, $00, $02
        dw  -8,  8 : db $67, $0D, $00, $02
        dw   8,  8 : db $67, $4D, $00, $02
        dw  16,  8 : db $66, $4D, $00, $02
    }

; ==============================================================================

    ; *$E8A84-$E8AB5 LOCAL
    PhantomGanon_Draw:
    {
        LDA.b #$00   : XBA
        LDA $0DC0, X : REP #$20 : ASL #6 : ADD.w #(.oam_groups) : STA $08
        
        LDA.w #$0950 : STA $90
        
        LDA.w #$0A74 : STA $92
        
        SEP #$20
        
        LDA.b #$08 : JMP Sprite4_DrawMultiple
    
    ; *$E8AA9 ALTERNATE ENTRY POINT
    shared Sprite_PeriodicWhirringSfx:
    
        LDA $1A : AND.b #$0F : BNE .shadow_flicker
        
        LDA.b #$06 : JSL Sound_SetSfx3PanLong
    
    .shadow_flicker
    
        RTS
    }

