
; ==============================================================================

    ; *$6BA80-$6BA9D LONG
    OAM_AllocateFromRegionA:
    {
        LDY.b #$00
        
        BRA .allocate
    
    ; *$6BA84 ALTERNATE ENTRY POINT
    shared OAM_AllocateFromRegionB:
    
        LDY.b #$02
        
        BRA .allocate
    
    ; *$6BA88 ALTERNATE ENTRY POINT
    shared OAM_AllocateFromRegionC:
    
        LDY.b #$04
        
        BRA .allocate
    
    ; *$6BA8C ALTERNATE ENTRY POINT
    shared OAM_AllocateFromRegionD:
    
        LDY.b #$06
        
        BRA .allocate
    
    ; *$6BA90 ALTERNATE ENTRY POINT
    shared OAM_AllocateFromRegionE:
    
        LDY.b #$08
        
        BRA .allocate
    
    ; \note Seems to be for sorted, bg1 sprites
    ; *$6BA94 ALTERNATE ENTRY POINT
    shared OAM_AllocateFromRegionF:
    
        LDY.b #$0A
    
    .allocate
    
        PHB : PHK : PLB
        
        JSR OAM_GetBufferPosition
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $6BA9E-$6BB09 DATA TABLE
    pool OAM_GetBufferPosition:
    {
    
    ; upper limits for each OAM region
    .limits
        dw $0171 ; 0x0030 - 0x016F? (For now calling this region A)
        dw $0201 ; 0x01D0 - 0x01FF? (For now calling this region B)
        dw $0031 ; 0x0000 - 0x002F? (For now calling this region C)
        dw $00C1 ; 0x0030 - 0x00BF? (For now calling this region D)
        dw $0141 ; 0x0120 - 0x013F? (For now calling this region E)
        dw $01D1 ; 0x0140 - 0x01CF? (For now calling this region F)
    
    ; fall back points for each OAM region
    ; (in case of overflow)
    ; formula for accessing this table: ($0C * 8 + $0E)
    .fallback_points
        
        dw $0030 ; $0C = 0, $0E = 0
        dw $0050
        dw $0080
        dw $00B0
        dw $00E0
        dw $0110
        dw $0140
        dw $0170 ; $0C = 0, $0E = 7
        
        dw $01D0 ; $0C = 2, $0E = 0
        dw $01D4
        dw $01DC
        dw $01E0
        dw $01E4
        dw $01EC
        dw $01F0
        dw $01F8
        
        dw $0000 ; $0C = 4, $0E = 0
        dw $0004
        dw $0008
        dw $000C
        dw $0010
        dw $0014
        dw $0018
        dw $001C ; $0C = 4, $0E = 7
        
        dw $0030 ; $0C = 6, $0E = 0
        dw $0038
        dw $0050
        dw $0068
        dw $0080
        dw $0098
        dw $00B0
        dw $00C8 ; $0C = 6, $0E = 7
        
        dw $0120 ; $0C = 8, $0E = 0
        dw $0124
        dw $0128
        dw $012C
        dw $0130
        dw $0134
        dw $0138
        dw $013C ; $0C = 8, $0E = 7
        
        dw $0140 ; $0C = A, $0E = 0
        dw $0150
        dw $0160
        dw $0170
        dw $0180
        dw $0190
        dw $01A0
        dw $01B8 ; $0C = A, $0E = 7
    }

; ==============================================================================

    ; *$6BB0A-$6BB5A LOCAL
    OAM_GetBufferPosition:
    {
        ; Inputs:
        ; A : Number of bytes requested for use in the OAM table. (number of subsprites * 4)
        ; Y : Even value taken from { 0x00, ..., 0x0A }. Represents the region in the table to allocate from.
        ; Hidden argument? (Not sure?) It is either 0 or 1, based on input from $0FB3 (sort sprites variable)
        
        STA $0E
        STZ $000F
        
        REP #$20
        
        ; ($0FE0[0x10] is some kind of OAM allocator table)
        LDA $0FE0, Y : STA $90 : ADD $0E : CMP .limits, Y : BCC .within_limit
        
        ; (Sprite overflow, doesn't happen very often)
        ; (I think what happens is it resets the OAM buffer)
        STY $0C
        STZ $0D
        
        ; wtf...
        LDA $0FEC, Y : PHA : INC A : STA $0FEC, Y
        
        PLA : AND.w #$0007 : ASL A : STA $0E
        
        ; Y = (sprite field * 8) + $0E... whatever that is
        LDA $0C : ASL #3 : ADC $0E : TAY
        
        ; Reset the OAM Position (effectively ignores existing sprites)
        ; \note I find it fairly interesting that there are set fallback points
        ; that increment state whenever this happens. This is kind of what
        ; induces the famous 'flicker' effect in video games, I imagine.
        LDA .fallback_points, Y : STA $90
        
        SEC
        
        BRA .moving_on
    
    .within_limit
    
        STA $0FE0, Y ; Store the new position in the OAM region
    
    .moving_on
    
        LDA $90 : PHA : LSR #2 : ADD.w #$0A20 : STA $92
        
        PLA : ADD.w #$0800 : STA $90
        
        SEP #$20
        
        LDY $90
        
        RTS
    }

; ==============================================================================
