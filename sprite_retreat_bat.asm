
; ==============================================================================

    pool Sprite_RetreatBat:
    ; $D75D5-$D75D8 DATA
    {
        db  1, -1
    
    ; $D75D7
        db  0, -1
    }

; ==============================================================================

    ; \note Ganon bat that crashes into the pyramid of power.

    ; *$D75D9-$D763C JUMP LOCATION
    Sprite_RetreatBat:
    {
        JSR RetreatBat_Draw
        JSR Sprite6_CheckIfActive
        JSL Sprite_MoveLong
        JSR RetreatBat_DrawSomethingElse
        
        STZ $011C
        STZ $011D
        
        LDA $0EE0, X : BEQ BRANCH_ALPHA
        
        DEC A : BNE BRANCH_BETA
        
        LDY.b #$05 : STY $012D
    
    BRANCH_BETA:
    
        AND.b #$01 : TAY
        
        LDA $F5D5, Y : STA $011C
        LDA $F5D7, Y : STA $011D
    
    BRANCH_ALPHA:
    
        LDA $0DF0, X : BNE BRANCH_GAMMA
        
        LDA $0DC0, X : INC A : AND.b #$03 : STA $0DC0, X : BNE BRANCH_DELTA
        
        LDA $0D80, X : CMP.b #$02 : BCS BRANCH_DELTA
        
        LDA.b #$03 : JSL Sound_SetSfx2PanLong
    
    BRANCH_DELTA:
    
        LDY $0DE0, X
        
        LDA $F5A0, Y : STA $0DF0, X
    
    BRANCH_GAMMA:
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $F63D ; = $D763D*
        dw $F684 ; = $D7684*
        dw $F6C8 ; = $D76C8* ; ???
        dw RetreatBat_FinishUp
    ]

    ; *$D763D-$D7683 JUMP LOCATION
    {
        LDA $0D90, X : ASL A : TAY
        
        REP #$20
        
        LDA $F590, Y : CMP $0FD8
        
        SEP #$30 : BCS BRANCH_ALPHA
        
        CPY.b #$04 : BCC BRANCH_BETA
        
        INC $0D80, X
        
        LDA.b #$D0 : STA $0E00, X
    
    BRANCH_BETA:
    
        INC $0D90, X
        INC $0DE0, X
    
    ; *$D7660 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDA $1A : AND.b #$07 : BNE BRANCH_GAMMA
        
        REP #$20
        
        LDA $F598, Y : CMP $0FDA : SEP #$30 : BCC BRANCH_DELTA
        
        INC $0D40, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        DEC $0D40, X
    
    BRANCH_GAMMA:
    
        LDA $1A : AND.b #$0F : BNE BRANCH_EPSILON
        
        INC $0D50, X
    
    BRANCH_EPSILON:
    
        RTS
    }

    ; *$D7684-$D76C7 JUMP LOCATION
    {
        LDA $0E00, X : BNE BRANCH_ALPHA
        
        INC $0D80, X
        
        LDA.b #$26 : JSL Sound_SetSfx3PanLong
        
        INC $0DE0, X
        
        LDA.b #$E8 : STA $0D10, X
        LDA.b #$07 : STA $0D30, X
        LDA.b #$E0 : STA $0D00, X
        LDA.b #$05 : STA $0D20, X
        
        STZ $0D50, X
        
        LDA.b #$40 : STA $0D40, X
        LDA.b #$2D : STA $0E00, X
        
        RTS
    
    BRANCH_ALPHA:
    
        LDA $1A : AND.b #$03 : BNE BRANCH_BETA
        
        DEC $0D50, X
    
    BRANCH_BETA:
    
        LDA $0D90, X : ASL A : TAY
        
        JMP $F660 ; $D7660 IN ROM
    }


    ; *$D76C8-$D76E8 JUMP LOCATION
    {
        LDA $0E00, X : BNE .advancement_delay
        
        STZ $0D40, X
        
        LDA.b #$60 : STA $0E00, X
        
        INC $0D80, X
    
    .advancement_delay
    
        LDA $0E00, X : CMP.b #$09 : BNE .smash_delay
        
        JSR RetreatBat_SpawnPyramidDebris
        
        PHX
        
        JSL Overworld_CreatePyramidHole
        
        PLX
    
    .smash_delay
    
        RTS
    }

; ==============================================================================

    ; *$D76E9-$D76F4 JUMP LOCATION
    RetreatBat_FinishUp:
    {
        LDA $0E00, X : BNE .delay
        
        STZ $0DD0, X
        
        ; This allows the GanonEmerges module to continue on and let the player
        ; land on the pyramid.
        INC $0200

    .delay

        RTS
    }

; ==============================================================================

    ; *$D76F5-$D772F LONG
    GanonEmerges_SpawnRetreatBat:
    {
        ; Create the bat to break into Pyramid of Power
        
        LDA.b #$37 : JSL Sprite_SpawnDynamically
        
        LDA.b #$00 : STA $0D40, Y
                     STA $0DA0, Y
                     STA $0DE0, Y
                     STA $0F20, Y
        
        INC A : STA $0E80, Y
                STA $0E40, Y
                STA $0E60, Y
                STA $0F50, Y
        
        LDA.b #$CC : STA $0D10, Y
        LDA.b #$07 : STA $0D30, Y
        
        LDA.b #$32 : STA $0D00, Y
        LDA.b #$06 : STA $0D20, Y
        
        LDA.b #$80 : STA $0CAA, Y
        
        RTL
    }

; ==============================================================================

    ; $D7730-$D774F DATA
    pool RetreatBat_DrawSomethingElse:
    {
    
    .oam_entries
        db $68, $97, $57, $01
        db $78, $97, $57, $01
        db $88, $97, $57, $01
        
        db $68, $A7, $57, $01
        db $78, $A7, $57, $01
        db $88, $A7, $57, $01
        
        db $65, $90, $57, $01
        db $8B, $90, $57, $01        
    }

; ==============================================================================

    ; $D7750-$D776C LOCAL
    RetreatBat_DrawSomethingElse:
    {
        REP #$20
        
        LDY.b #$20
    
    .write_oam_low_buffer_entries
    
        LDA .oam_entries - 2, Y : STA $092E, Y
        
        DEY #2 : BNE .write_oam_low_buffer_entries
        
        LDY.b #$08
        
        ; Use all large oam-sized sprites.
        LDA.w #$0202
    
    .write_oam_high_buffer_entries
    
        STA $0A6C, Y
        
        DEY #2 : BPL .write_oam_high_buffer_entries
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$D77E5-$D7809 LOCAL
    RetreatBat_SpawnPyramidDebris:
    {
        LDY.b #$1D
    
    .spawn_another
    
        LDA $F76D, Y : STA $00
        LDA $F78B, Y : STA $01
        
        LDA $F7A9, Y : STA $02
        LDA $F7C7, Y : STA $03
        
        PHY
        
        JSL Garnish_SpawnPyramidDebris
        
        PLY : DEY : BPL .spawn_another
        
        LDA.b #$20 : STA $0EE0, X
        
        RTS
    }

; ==============================================================================

    ; $D780A-$D7832 DATA
    pool RetreatBat_Draw:
    {
    
    .ptr_low_bytes
        db $00, $00, $08, $08, $10, $10, $18, $18
        db $20, $20, $30, $30, $40, $50, $60, $50
        db $70, $70, $70, $70
    
    .ptr_high_byte
        db $F5
    
    .num_oam_entries
        db 1, 1, 1, 1, 1, 1, 1, 1
        db 2, 2, 2, 2, 2, 2, 2, 2
        db 4, 4, 4, 4
    }

; ==============================================================================

    ; *$D7833-$D785B LOCAL
    RetreatBat_Draw:
    {
        REP #$20
        
        LDA.w #$0960 : STA $90
        LDA.w #$0A78 : STA $92
        
        SEP #$20
        
        LDA $0DE0, X : ASL #2 : ADC $0DC0, X : TAY
        
        LDA .ptr_low_bytes, Y : STA $08
        LDA .ptr_high_byte    : STA $09
        
        LDA .num_oam_entries, Y : JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================
