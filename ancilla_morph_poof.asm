
; ==============================================================================

    ; $4537A-$453BB DATA
    pool MorphPoof_Draw:
    {
    
    .chr
        db $86, $A9, $9B
    
    .oam_size
        db $02, $00, $00
    
    .y_offsets
        dw  0,  0,  0,  0
        dw  0,  0,  8,  8
        dw -4, -4, 12, 12
    
    .x_offsets
        dw  0,  0,  0,  0
        dw  0,  8,  0,  8
        dw -4, 12, -4, 12
    }

; ==============================================================================

    ; *$453BC-$453FC JUMP LOCATION
    Ancilla_MorphPoof:
    {
        DEC $03B1, X : BPL MorphPoof_Draw
        
        LDA.b #$07 : STA $03B1, X
        
        ; Tick the animation index and self terminate if at index 3.
        LDA $0C5E, X : INC A : STA $0C5E, X : CMP.b #$03 : BNE MorphPoof_Draw
        
        STZ $0C4A, X
        STZ $02E1
        STZ $50
        
        LDA $0C54, X : BNE .return
        
        STZ $2E
        STZ $4B
        
        LDY.b #$00
        
        LDA $8A : AND.b #$40 : BEQ .in_light_world
        
        ; Select the bunny tileset for the player.
        INY
    
    .in_light_world
    
        STY $02E0 : STY $56 : BEQ .using_normal_player_graphics
        
        JSL LoadGearPalettes.bunny
        
        BRA .return
    
    .using_normal_player_graphics
    
        JSL LoadActualGearPalettes
    
    .return
    
        RTS
    }
    
; ==============================================================================

    ; *$453FD-$45499 ALTERNATE ENTRY POINT
    MorphPoof_Draw:
    
        LDA $0FB3 : BEQ .unsorted_sprites
        
        LDA $0C7C, X : BEQ .use_default_oam_region
        
        ; \wtf Why would we care if the boomerang is in play?
        LDA $035F : BEQ .no_boomerang_in_play
        
        LDA $1A : AND.b #$01 : BNE .use_default_oam_region
    
    .no_boomerang_in_play
    
        REP #$20
        
        LDA.w #$00D0 : PHA : ADD.w #$0800 : STA $90
        
        PLA : LSR #2 : ADD.w #$0A20 : STA $92
        
        SEP #$20
    
    .use_default_oam_region
    
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $00 : STA $04
        LDA $02 : STA $06
        
        SEP #$20
        
        PHX
        
        LDY $0C5E, X
        
        LDA .oam_size, Y : STA $08
        
        LDA .chr, Y : STA $0C
        
        TYA : ASL #2 : STA $0E
        
        LDY.b #$00 : STY $0A
    
    .next_oam_entry
    
        LDA $0E : ADD $0A : ASL A : TAX
        
        REP #$20
        
        LDA $04 : ADD .y_offsets, X : STA $00
        LDA $06 : ADD .x_offsets, X : STA $02
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        LDA $0C : STA ($90), Y : INY
        
        TXA : LSR A : TAX
        
        LDA $D380, X : ORA.b #$04 : ORA $65 : STA ($90), Y : INY : PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA $08 : STA ($92), Y
        
        PLY
        
        ; The one state of the poof that has a large sprite size also only
        ; commits one oam entry to the buffer.
        CMP.b #$02 : BEQ .large_oam_size
        
        ; We're finished after committing 4 oam entries to the buffer.
        INC $0A : LDA $0A : CMP.b #$04 : BNE .next_oam_entry
    
    .large_oam_size
    
        PLX
        
        RTS
    }

; ==============================================================================

