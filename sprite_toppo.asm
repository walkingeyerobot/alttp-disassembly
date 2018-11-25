
; ==============================================================================

    ; *$2BA85-$2BAB5 JUMP LOCATION
    Sprite_Toppo:
    {
        ; Asshole bunny
        
        LDA $0D80, X : BEQ .not_visible
        
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR Toppo_Draw
    
    .not_visible
    
        JSR Sprite2_CheckIfActive
        
        LDA $0D80, X : REP #$30 : AND.w #$00FF : ASL A : TAY
        
        ; Hidden table! gah!!!
        LDA .states, Y : DEC A : PHA
        
        SEP #$30
        
        RTS
    
    .states
        dw Toppo_PickNextGrassPlot
        dw Toppo_ChillBeforeJump
        dw Toppo_WaitThenJump
        dw Toppo_RiseAndFall
        dw Toppo_ChillAfterJump
        dw Toppo_FlusteredTrampoline
    }

; ==============================================================================

    ; $2BAB6-$2BAC5 DATA
    pool Toppo_PickNextGrassPlot:
    {
    
    .x_offsets_low
        db $E0, $20, $00, $00
    
    .x_offsets_high
        db $FF, $00, $00, $00
    
    .y_offsets_low
        db $00, $00, $E0, $20
    
    .y_offsets_high
        db $00, $00, $FF, $00
    }

; ==============================================================================

    ; $2BAC6-$2BB00 JUMP LOCATION
    Toppo_PickNextGrassPlot:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$08 : STA $0DF0, X
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA $0D90, X : ADD .x_offsets_low,  Y : STA $0D10, X
        LDA $0DA0, X : ADC .x_offsets_high, Y : STA $0D30, X
        
        LDA $0DB0, X : ADD .y_offsets_low,  Y : STA $0D00, X
        LDA $0EB0, X : ADC .y_offsets_high, Y : STA $0D20, X
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2BB01-$2BB19 JUMP LOCATION
    Toppo_ChillBeforeJump:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
        
        RTS
    
    .delay
    
        LSR #2 : AND.b #$01 : STA $0DC0, X
        
        JSR Toppo_CheckLandingSiteForGrass
        
        RTS
    }

; ==============================================================================

    ; $2BB1A-$2BB2F JUMP LOCATION
    Toppo_WaitThenJump:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0F80, X
    
    .delay
    
        LDA.b #$02 : STA $0DC0, X
        
        JSR Toppo_CheckLandingSiteForGrass
        
        RTS
    }

; ==============================================================================

    ; $2BB30-$2BB52 JUMP LOCATION
    Toppo_RiseAndFall:
    {
        JSR Sprite2_CheckDamage
        JSR Sprite2_MoveAltitude
        
        ; Simulate gravity.
        LDA $0F80, X : SUB.b #$02 : STA $0F80, X
        
        LDA $0F70, X : BPL .delay
        
        STZ $0F70, X
        
        INC $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
        
        JSR Toppo_CheckLandingSiteForGrass
    
    .delay
    
        RTS
    }

; ==============================================================================

    ; $2BB53-$2BB6C JUMP LOCATION
    Toppo_ChillAfterJump:
    {
        LDA $0DF0, X : BNE .delay
        
        STZ $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        BRA .moving_on
    
    .delay
    
        LSR #2 : AND.b #$01 : STA $0DC0, X
    
    .moving_on
    
        JSR Toppo_CheckLandingSiteForGrass
        
        RTS
    }

; ==============================================================================

    ; $2BB6D-$2BB71
    Toppo_FlusteredTrampoline:
    {
        JSL Toppo_Flustered
        
        RTS
    }

; ==============================================================================

    ; $2BB72-$2BB95 LOCAL
    Toppo_CheckLandingSiteForGrass:
    {
        LDA $0D00, X : STA $00
        LDA $0D20, X : STA $01
        
        LDA $0D10, X : STA $02
        LDA $0D30, X : STA $03
        
        LDA.b #$00 : JSL Entity_GetTileAttr : CMP.b #$40 : BEQ .is_thick_grass
        
        LDA.b #$05 : STA $0D80, X
    
    .is_thick_grass
    
        RTS
    }

; ==============================================================================

    ; $2BB96-$2BBFE DATA
    pool Toppo_Draw:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$2BBFF-$2BC89 LOCAL
    Toppo_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        LDA $0D00, X : SUB $E8 : STA $06
        LDA $0D20, X : SUB $E9 : STA $07
        
        LDA $0DC0, X : ASL A : ADC $0DC0, X : STA $08
        
        PHX
        
        LDX.b #$02
    
    .next_oam_entry
    
        PHX : TXA : ADD $08 : PHA : TAX
        
        LDA $BBF0, X : STA $0C
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $BB96, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        PHX
        
        LDX $0C : CPX.b #$01
        
        PLX
        
        LDA $02 : BCS .alpha
        
        LDA $06
    
    .alpha
    
        ADD $BBB4, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : SEP #$20 : BCC .beta
        
        LDA.b #$F0 : STA ($90), Y
    
    .beta
    
        PLX
        
        LDA $BBD2, X : INY : STA ($90), Y
        
        LDA $0C : CMP.b #$01 : LDA $BBE1, X : ORA $05 : BCS .gamma
        
        AND.b #$F0 : ORA #$02
    
    .gamma
    
        INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA $0C : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        PLX : DEX : BPL .next_oam_entry
        
        PLX
        
        RTS
    
    .unused_label
    
        RTS
    }

; ==============================================================================

