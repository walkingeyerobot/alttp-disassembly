
; ==============================================================================

    ; $47169-$4718C DATA
    pool Ancilla_SuperBombExplosion:
    {
    
    .y_offsets
        dw   0, -16, -24, -16,   0,   0,  16,  24,  16
    
    .x_offsets
        dw   0, -16,   0,  16, -24,  24, -16,   0,  16
    }

; ==============================================================================

    ; *$4718D-$4727B JUMP LOCATION
    Ancilla_SuperBombExplosion:
    {
        LDA $11 : BNE .draw
        
        DEC $039F, X : LDA $039F, X : BNE .draw
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$02 : BNE .blast_sfx_delay
        
        LDA.b #$0C : JSR Ancilla_DoSfx2
    
    .blast_sfx_delay
    
        LDA $0C5E, X : CMP.b #$0B : BNE .not_fully_exploded
        
        STZ $0C4A, X
        
        RTS
    
    .not_fully_exploded
    
        TAY
        
        LDA Ancilla_Bomb.interstate_intervals, Y : STA $039F, X
    
    .draw
    
        LDA.b #$08 : STA $09
        
        LDA.b #$30 : STA $65 : STZ $64
        
        STZ $0A
        
        LDA.b #$32 : STA $0B
        
        LDA $0C5E, X : TAY
        
        LDA Bomb_Draw.num_oam_entries, Y : STA $08
        
        LDA Ancilla_Bomb.chr_groups, Y : TAY
        
        LDA Bomb_Draw.chr_start_offset, Y : ASL A : TAY
        
        ASL A : STA $04
                STZ $05
        
        TYA : STA $0C54, X
        
        LDY.b #$00
    
    .next_blast
    
        PHX : PHY
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        LDA $09 : ASL A : TAY
        
        REP #$20
        
        LDA $00 : ADD .y_offsets, Y : SUB $E8 : STA $00
        LDA $02 : ADD .x_offsets, Y : SUB $E2 : STA $02
        
        SEP #$20
        
        PLY
        
        LDA $0C54, X : TAX
        
        LDA $01 : BNE .off_screen
        
        LDA $03 : BNE .off_screen
        
        PHX : PHY
        
        LDA.b #$18
        
        JSR Ancilla_AllocateOam
        
        PLY : PLX
        
        LDA $00 : STA $0C
        LDA $01 : STA $0D
        
        LDA $02 : STA $0E
        LDA $03 : STA $0F
        
        STZ $06
        STZ $07
        
        JSR Bomb_DrawExplosion
    
    .off_screen
    
        PLX
        
        DEC $09 : BPL .next_blast
        
        LDA $0C5E, X : CMP.b #$03 : BNE .anomute_vulnerable_tiles
        
        LDA $039F, X : CMP.b #$01 : BNE .anomute_vulnerable_tiles
        
        LDA $0BFA, X : STA $00
        LDA $0C0E, X : STA $01
        
        LDA $0C04, X : STA $02
        LDA $0C18, X : STA $03
        
        PHX
        
        JSL Bomb_CheckForVulnerableTileObjects
        
        PLX
        
        LDA.b #$00 : STA $7EF3CC
    
    .anomute_vulnerable_tiles
    
        RTS
    }

; ==============================================================================
