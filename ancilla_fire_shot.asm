
; ==============================================================================

    ; *$406D2-$40758 JUMP LOCATION
    Ancilla_FireShot:
    {
        LDA $0C54, X : BEQ .traveling_shot
        
        JMP Ancilla_ConsumingFire
    
    .traveling_shot
    
        LDA $11 : BNE .just_draw
        
        STZ $0385, X
        
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveVert
        
        JSR Ancilla_CheckSpriteCollision : BCS .collided
        
        LDA $0C72, X : ORA.b #$08 : STA $0C72, X
        
        JSR Ancilla_CheckTileCollision
        
        PHP
        
        LDA $03E4, X : STA $0385, X
        
        PLP : BCS .collided
        
        LDA $0C72, X : ORA.b #$0C : STA $0C72, X
        
        LDA $028A, X : STA $74
        
        JSR Ancilla_CheckTileCollision
        
        PHP
        
        LDA $74 : STA $028A, X
        
        PLP : BCC .no_collision
    
    .collided
    
        INC $0C54, X
        
        LDA.b #$1F : STA $0C68, X
        
        LDA.b #$08 : STA $0C90, X
        
        LDA.b #$2A : JSR Ancilla_DoSfx2
    
    .no_collision
    
        INC $0C5E, X
        
        LDA $0C72, X : AND.b #$F3 : STA $0C72, X
        
        LDA $0385, X : STA $0333
        
        AND.b #$F0 : CMP.b #$C0 : BEQ .try_to_light_torch
        
        LDA $03E4, X : STA $0333
        
        AND.b #$F0 : CMP.b #$C0 : BNE .ignore_torch
    
    .try_to_light_torch
    
        PHX
        
        JSL Dungeon_LightTorch
        
        PLX
    
    .ignore_torch
    .just_draw
    
        JSR FireShot_Draw
        
        RTS
    }

; ==============================================================================

    ; $40759-$4077B DATA
    pool FireShot_Draw:
    {
    
    .x_offsets
        db 7, 0, 8, 0, 8, 4, 0, 0
        db 2, 8, 0, 0, 1, 4, 9, 0
    
    .y_offsets
        db 1, 4, 9, 0, 7, 0, 8, 0
        db 8, 4, 0, 0, 2, 8, 0, 0
    
    .chr
        db $8D, $9D, $9C
    }

; ==============================================================================

    ; *$4077C-$407CA LOCAL
    FireShot_Draw:
    {
        JSR Ancilla_BoundsCheck
        
        LDA $0280, X : BEQ .default_priority
        
        LDA.b #$30 : TSB $04
    
    .default_priority
    
        LDA $0C5E, X : AND.b #$0C : STA $02
        
        PHX
        
        LDX.b #$02
        LDY.b #$00
    
    .next_oam_entry
    
        STX $03
        
        TXA : ORA $02 : TAX
        
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        LDA $01 : ADD .y_offsets, X : INY : STA ($90), Y
        
        LDX $03
        
        LDA .chr, X          : INY : STA ($90), Y
        LDA $04 : ORA.b #$02 : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY : INY
        
        DEX : BPL .next_oam_entry
        
        PLX
        
        RTS
    
    ; \unused Like it says...
    .unused
    
        RTS
    }

; ==============================================================================

    ; *$407CB-$40852 BRANCH LOCATION
    pool Ancilla_ConsumingFire:
    {
    
    .self_terminate
    
        ; Check if it was a torch flame (not fire rod)
        LDA $0C4A, X : STZ $0C4A, X : CMP.b #$2F : BEQ .dont_burn_skull
        
        ; Check if it's Skull Woods area (0x40)
        LDA $8A : CMP.b #$40 : BNE .dont_burn_skull
        
        ; Check if it's the right tile type (0x43)
        LDA $03E4, X : CMP.b #$43 : BNE .dont_burn_skull
        
        PHX
        
        ; Initiate the sequence for burning open the final portion of the
        ; Skull Woods dungeon.
        JSL ConsumingFire_TransmuteToSkullWoodsFire
        
        PLX
    
    .dont_burn_skull
    
        RTS
    
    .chr
        db $A2, $A0, $8E
    
    ; *$407EC MAIN ENTRY POINT
    Ancilla_ConsumingFire:
    
        JSR Ancilla_CheckBasicSpriteCollision
        JSR Ancilla_BoundsCheck
        
        LDY.b #$00
        
        LDA $0C68, X : BEQ .self_terminate
        LSR #3       : BEQ .flaming_out
        
        TAX
        
        LDA $00                    : STA ($90), Y
        LDA $01              : INY : STA ($90), Y
        LDA .chr - 1, X      : INY : STA ($90), Y
        LDA.b #$02 : ORA $04 : INY : STA ($90), Y
        
        LDA.b #$02 : STA ($92)
        
        ; Exit and reload the special object's index from $0FA0
        BRL Ancilla_RestoreIndex
    
    .flaming_out
    
        TYA : STA ($92), Y
        INY : STA ($92), Y : DEY
        
        LDA $00                            : STA ($90), Y
        ADD.b #$08            : LDY.b #$04 : STA ($90), Y
        LDA $01 : ADD.b #$FD  : LDY.b #$01 : STA ($90), Y
                                LDY.b #$05 : STA ($90), Y
        LDA.b #$A4            : LDY.b #$02 : STA ($90), Y
        INC A                 : LDY.b #$06 : STA ($90), Y
        LDA.b #$02 : ORA $04  : LDY.b #$03 : STA ($90), Y
                                LDY.b #$07 : STA ($90), Y
    
    shared Ancilla_Unused_03:
    
        RTS
    }

; ==============================================================================
