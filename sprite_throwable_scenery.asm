
; ==============================================================================

    ; $32ABE-$32ADF DATA
    pool Sprite_ThrowableScenery:
    {
    
    .chr
        db $42, $44, $46, $00, $46, $44, $42, $44
        db $44, $00, $46, $44
    
    .palettes
        db $0C, $0C, $0C, $00, $00, $00
    
    .main_oam_table_offsets
        dw $08B0, $08B4, $08B8, $08BC
    
    .high_oam_table_offsets
        dw $0A4C, $0A4D, $0A4E, $0A4F
    }

; ==============================================================================

    ; *$32AE0-$32B59 JUMP LOCATION
    Sprite_ThrowableScenery:
    {
		; if($0FC6 >= 0x03)
        LDA $0FC6 : CMP.b #$03 : BCS .cant_draw
        
        LDA $0FB3 : BEQ .dont_use_reserved_oam_slots
        
        LDA $0F20, X : BEQ .dont_use_reserved_oam_slots
        
        TXA : AND.b #$03 : ASL A : TAY
        
        REP #$20
        
        LDA .main_oam_table_offsets, Y : STA $90
        
        LDA .high_oam_table_offsets, Y : STA $92
        
        SEP #$20
    
    .dont_use_reserved_oam_slots
    
        LDA $0DD0, X : STA $0BA0, X
        
        ; if(object != bigass_object)
        LDA $0DB0, X : CMP.b #$06 : BCC .not_bigass_scenery
        
        JSR ThrowableScenery_DrawLarge
        
        BRA .done_drawing
    
    .not_bigass_scenery
    
        JSR Sprite_PrepAndDrawSingleLarge
        
        PHX
        
        ; (checks to see if you're indoors in the dark world)
        LDA $1B : ADD $0FFF : CMP.b #$02
        
        LDA $0DB0, X : PHA : BCC .not_indoors_in_dark_world
        
        ADC.b #$05
    
    .not_indoors_in_dark_world
    
        TAX
        
        LDA $AABE, X : LDY.b #$02 : STA ($90), Y : INY
        
        LDA ($90), Y : AND.b #$F0 : PLX : ORA $AACA, X : STA ($90), Y
        
        PLX
        
        AND.b #$0F : STA $00
        
        LDA $0F50, X : AND.b #$C0 : ORA $00 : STA $0F50, X
    
    .done_drawing
    .cant_draw
    
        LDA $0DD0, X : CMP.b #$09 : BNE .skip_collision_logic
        
        JSR Sprite_CheckIfActive
        JSR ThrowableScenery_InteractWithSpritesAndTiles
    
    .skip_collision_logic
    
        RTS
    }

; ==============================================================================

    ; $32B5A-$32B75 DATA
    pool ThrowableScenery_DrawLarge:
    {
    
    .x_offsets
        dw  -8,   8,  -8,   8
    
    .y_offsets
        dw -14, -14,   2,   2
    
    .vh_flip
        db $00, $40, $80, $C0
    
    .shadow_x_offsets
        db -6,  0,  6
    
    .palettes
        db 12
    }

; ==============================================================================

    ; *$32B76-$32C30 LOCAL
    ThrowableScenery_DrawLarge:
    {
        LDY $0DB0, X
        
        ; \note They did it this way because it's assumed that $0DB0, X is
        ; >= 0x06 here.
        LDA .palettes-$06, Y : STA $0F50, X
        
        JSR Sprite_PrepOamCoord
        
        PHX
        
        LDX.b #$03
    
    .next_oam_entry
    
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA.b #$4A      : INY           : STA ($90), Y
        LDA .vh_flip, X : INY : ORA $05 : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_oam_entry
        
        PLX
        
        LDA.b #$0C : JSL OAM_AllocateFromRegionB
        
        LDY.b #$00
        
        LDA $0D00, X : SUB $E8 : STA $02
        LDA $0D20, X : SBC $E9 : STA $03
        
        PHX
        
        LDX.b #$02
    
    .next_shadow_oam_entry
    
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD .x_offsets, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD.w #$000C : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .shadow_on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .shadow_on_screen_y
    
        PLX
        
        LDA.b #$6C : INY : STA ($90), Y
        LDA.b #$24 : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_shadow_oam_entry
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $32C31-$32C40 DATA
    pool ThrowableScenery_ScatterIntoDebris:
    {
    
    .x_offsets_low
        db -8,  8, -8,  8
    
    .x_offsets_high
        db -1,  0, -1,  0
    
    .y_offsets_low
        db -8, -8,  8,  8
    
    .y_offsets_high
        db -1, -1,  0,  0
    }

; ==============================================================================

    ; *$32C41-$32D02 LOCAL
    ThrowableScenery_ScatterIntoDebris:
    {
        LDA $0DB0, X : BMI .smaller_scenery
        CMP.b #$06   : BCC .smaller_scenery
        
        LDA.b #$03 : STA $0D
    
    .spawn_next_smaller_scenery
    
        LDA.b #$EC : JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $0F70, X : STA $0F70, Y
        
        PHX
        
        LDX $0D
        
        LDA $00 : ADD .x_offsets_low,  X : STA $0D10, Y
        LDA $01 : ADC .x_offsets_high, X : STA $0D30, Y
        
        LDA $02 : ADD .y_offsets_low,  X : STA $0D00, Y
        LDA $03 : ADC .y_offsets_high, X : STA $0D20, Y
        
        LDA.b #$01 : STA $0DB0, Y
        
        TYX
        
        JSR Sprite_ScheduleForBreakage
        
        PLX
        
        LDA $0DB0, X : CMP.b #$07 : LDA.b #$00 : BCS .use_default_palette
        
        ; 0x06 type scenery uses a palette ot 6 (12 >> 1).
        LDA.b #$0C
    
    .use_default_palette
    
        STA $0F50, Y
    
    .spawn_failed
    
        DEC $0D : BPL .spawn_next_smaller_scenery
        
        STZ $0DD0, X
        
        RTS
    
    .smaller_scenery
    
        STZ $0DD0, X
        
        JSR Sprite_PrepOamCoord
        
        PHX : TXY
        
        LDX.b #$1D
    
    .find_empty_garnish_slot
    
        LDA $7FF800, X : BEQ .empty_garnish_slot
        
        DEX : BPL .find_empty_garnish_slot
        
        INX
    
    .empty_garnish_slot
    
        LDA.b #$16 : STA $7FF800, X : STA $0FB4
        
        LDA $0D10, Y : STA $7FF83C, X
        LDA $0D30, Y : STA $7FF878, X
        
        LDA $0D00, Y : SUB $0F70, Y
        
        PHP
        
        ADD.b #$10 : STA $7FF81E, X
        
        LDA $0D20, Y : ADC.b #$00
        
        PLP
        
        SBC.b #$00 : STA $7FF85A, X
        
        LDA $05 : STA $7FF9FE, X
        
        LDA $0F20, Y : STA $7FF968, X
        
        LDA.b #$1F : STA $7FF90E, X
        
        LDA $0DB0, Y : STA $7FF92C, X
        
        PLX
        
        RTS
    }

; ==============================================================================
