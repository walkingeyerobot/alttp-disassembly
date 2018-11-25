
; ==============================================================================

    ; *$355B9-$355F2 JUMP LOCATION
    Sprite_Octostone:
    {
        ; Octorock rocks sprite.
        
        LDA $0DD0, X : CMP.b #$06 : BNE .not_crumbling
        
        JSR Octostone_DrawCrumbling
        JSR Sprite_CheckIfActive.permissive
        
        LDA $0DF0, X : CMP.b #$1E : BNE .dont_play_crumble_sfx
        
        LDA.b #$1F : JSL Sound_SetSfx2PanLong
    
    .dont_play_crumble_sfx
    
        RTS
    
    .not_crumbling
    
        JSR Sprite_PrepAndDrawSingleLarge
        JSR Sprite_CheckIfActive
        JSR Sprite_CheckDamageToPlayer
        JSR Sprite_Move
        
        TXA : EOR $1A : AND.b #$03 : BNE .tile_collision_logic_delay
        
        JSR Sprite_CheckTileCollision
        
        LDA $0E70, X : BEQ .no_tile_collision
        
        JSR Sprite_ScheduleForDeath
    
    .no_tile_collision
    .tile_collision_logic_delay
    
        RTS
    }

; ==============================================================================

    ; $355F3-$35642 DATA
    pool Octostone_DrawCrumbling:
    {
    
    .x_offsets
        dw   0,   8,   0,   8,  -8,  16,  -8,  16
        dw -12,  20, -12,  20, -14,  22, -14,  22
    
    .y_offsets
        dw   0,   0,   8,   8,  -8,  -8,  16,  16
        dw -12, -12,  20,  20, -14, -14,  22,  22
    
    .vh_flip
        db $00, $40, $80, $C0, $00, $40, $80, $C0
        db $00, $40, $80, $C0, $00, $40, $80, $C0
    }

; ==============================================================================

    ; *$35643-$356A1 LOCAL
    Octostone_DrawCrumbling:
    {
        JSR Sprite_PrepOamCoord
        
        PHX
        
        LDA.b #$03 : STA $06
        
        LDA $0DF0, X : LSR A : AND.b #$0C : EOR.b #$0C : ADD $06 : TAX
    
    .next_oam_entry
    
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA.b #$BC : INY : STA ($90), Y
        
        LDA .vh_flip, X : ORA.b #$2D : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX
        
        DEC $06 : BPL .next_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================
