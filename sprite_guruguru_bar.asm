
; ==============================================================================

    ; $F5012-$F5019 DATA
    pool Sprite_GuruguruBar:
    {
    
    .offsets_low
        db -2, 2
        db -1, 1
    
    .offsets_high
        db -1, 0
        db -1, 0
    }

; ==============================================================================

    ; *$F501A-$F5048 JUMP LOCATION
    Sprite_GuruguruBar:
    {
        JSR GuruguruBar_Main
        JSR Sprite3_CheckIfActive
        
        INC $0E80, X
        
        LDA $0E20, X : SUB.b #$7E : TAY
        
        ; \hardcoded
        LDA $040C : CMP.b #$12 : BNE .not_in_ice_palace
        
        INY #2
    
    .not_in_ice_palace
    
        LDA $0D90, X : ADD .offsets_low, Y               : STA $0D90, X
        
        LDA $0DA0, X : ADC .offsets_high, Y : AND.b #$01 : STA $0DA0, X
        
        RTS
    }

; ==============================================================================

    ; *$F5049-$F51CC LOCAL
    GuruguruBar_Main:
    {
        JSR Sprite3_PrepOamCoord
        
        LDA $05 : STA $0FB6
        
        LDA $00 : STA $0FA8
        
        LDA $02 : STA $0FA9
        
        LDA $0D90, X : STA $00
        
        LDA $0DA0, X : STA $01
        
        LDA.b #$40 : STA $0F
        
        PHX
        
        REP #$30
        
        LDA $00 : AND.w #$01FF : LSR #6 : STA $0A
        
        LDA $00 : ADD.w #$0080 : AND.w #$01FF : STA $02
        
        LDA $00 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $04
        
        LDA $02 : AND.w #$00FF : ASL A : TAX
        
        LDA $04E800, X : STA $06
        
        SEP #$30
        
        PLX
        
        LDA $04 : STA $4202
        
        LDA $0F
        
        LDY $05 : BNE BRANCH_ALPHA
        
        STA $4203
        
        JSR Sprite3_DivisionDelay
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_ALPHA:
    
        STA $0E
        
        LSR $01 : BCC BRANCH_BETA
        
        EOR.b #$FF : INC A
    
    BRANCH_BETA:
    
        STA $04
        
        LDA $06 : STA $4202
        
        LDA $0F
        
        LDY $07 : BNE BRANCH_GAMMA
        
        STA $4203
        
        JSR Sprite3_DivisionDelay
        
        ASL $4216
        
        LDA $4217 : ADC.b #$00
    
    BRANCH_GAMMA:
    
        STA $0F
        
        LSR $03 : BCC BRANCH_DELTA
        
        EOR.b #$FF : INC A
    
    BRANCH_DELTA:
    
        STA $06
        
        LDA $0E80, X : ASL #4 : AND.b #$C0 : ORA $0FB6 : STA $0D
        
        LDY.b #$00
        
        ; Draw base segment.
        LDA $04    : ADD $0FA8       : STA ($90), Y
        LDA $06    : ADD $0FA9 : INY : STA ($90), Y
        LDA.b #$28             : INY : STA ($90), Y
        LDA $0D                : INY : STA ($90), Y
        
        LDA.b #$02 : STA ($92)
        
        LDY.b #$04
        
        PHX
        
        LDX.b #$02
    
    .draw_segments_loop
    
        LDA $0E             : STA $4202
        LDA .multipliers, X : STA $4203
        
        JSR Sprite3_DivisionDelay
        
        LDA $04 : ASL A : LDA $4217 : BCC BRANCH_EPSILON
        
        EOR.b #$FF : INC A
    
    BRANCH_EPSILON:
    
        ADD $0FA8 : STA ($90), Y
        
        LDA $0F             : STA $4202
        LDA .multipliers, X : STA $4203
        
        JSR Sprite3_DivisionDelay
        
        LDA $06 : ASL A : LDA $4217 : BCC BRANCH_ZETA
        
        EOR.b #$FF : INC A
    
    BRANCH_ZETA:
    
        ADD $0FA9  : INY : STA ($90), Y
        LDA.b #$28 : INY : STA ($90), Y
        LDA $0D    : INY : STA ($90), Y
        
        PHY : TYA : LSR #2 : TAY
        
        LDA.b #$02 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .draw_segments_loop
        
        PLX
        
        LDY.b #$FF
        LDA.b #$03
        
        JSL Sprite_CorrectOamEntriesLong
        
        TXA : EOR $1A : AND.b #$03 : ORA $11
                                     ORA $0FC1 : BNE .damage_to_player_inhibit
        
        LDY.b #$00
    
    .check_damage_to_player_loop
    
        PHY : TYA : LSR #2 : TAY
        
        ; Check if offscreen per x coordinate.
        LDA ($92), Y : PLY : AND.b #$01 : BNE .no_player_collision
        
        LDA ($90), Y : ADD $E2 : SUB $22
        
        ADD.b #$0C : CMP.b #$18 : BCS .no_player_collision
        
        INY
        
        ; Check if offscreen per y coordinate.
        LDA ($90), Y : DEY : CMP.b #$F0 : BCS .no_player_collision
        
        ADD $E8 : SUB $20 : ADD.b #$04 : CMP.b #$10 : BCS .no_player_collision
        
        PHY
        
        JSL Sprite_AttemptDamageToPlayerPlusRecoilLong
        
        PLY
    
    .no_player_collision

        INY #4 : CPY.b #$10 : BCC .check_damage_to_player_loop

    .damage_to_player_inhibit

        RTS
    
    .multipliers
        db $40, $80, $C0
    }

; ==============================================================================
