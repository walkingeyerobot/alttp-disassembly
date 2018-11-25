
; ==============================================================================

    ; $4ADF1-$4ADF3 DATA
    pool Ancilla_MotiveDashDust:
    {
        db $A9, $CF, $DF
    }

; ==============================================================================

    ; *$4ADF4-$4AE3D LONG
    Ancilla_MotiveDashDust:
    {
        PHB : PHK : PLB
        
        LDA $0C68, X : BNE .delay
        
        LDA #$03 : STA $0C68, X
        
        INC $0C5E, X : LDA $0C5E, X : CMP.b #$03 : BNE .delay
        
        STZ $0C4A, X
        
        BRA .return
    
    .delay:
    
        LDA $2F : CMP.b #$02 : BNE .not_behind_player
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
    
    .not_behind_player
    
        JSL Ancilla_PrepOamCoordLong
        
        PHX
        
        LDA $0C5E, X : TAX
        
        LDY.b #$00
        
        JSL Ancilla_SetOam_XY_Long
        
        LDA .chr, X          : STA ($90), Y : INY
        LDA.b #$04 : ORA $65 : STA ($90), Y
        
        LDA.b #$00 : STA ($92)
        
        PLX
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================
