
; ==============================================================================

    ; *$4503D-$45185 JUMP LOCATION
    Ancilla_WeathervaneExplosion:
    {
        ; EFFECT 0x37. WEATHER VANE EXPLOSION
        
        REP #$20
        
        ; an initial timer. starts at 0x0280, counts down to zero.
        LDA $7F58B6 : DEC A : STA $7F58B6 : BNE .return
        
        SEP #$20
        
        INC A : STA $7F58B6
        
        LDA $7F58B8 : BNE .music_at_full_volume
        
        ; This code is executed once. after that, $7F58B8 is set
        INC A : STA $7F58B8
        
        ; Put the music back to full volume.
        LDA.b #$F3 : STA $012C
        
        BRA .music_at_full_volume
    
    .return
    
        SEP #$20
        
        BRA Ancilla_Flute.return
    
    .music_at_full_volume
    
        ; Start ticking down the timer for the explosion to occur.
        ; How much time left on the timer?
        ; Still time left, quit the routine.
        DEC $0394, X : LDA $0394, X : BNE .return
        
        ; Otherwise, put one frame back on the timer.
        INC A : STA $0394, X
        
        LDA $039F, X : BNE .explosion_sfx_already_played
        
        ; This code should only get executed once?
        INC A : STA $039F, X
        
        LDA.b #$0C : JSR Ancilla_DoSfx2_NearPlayer
    
    .explosion_sfx_already_played
    
        ; Which step of the effect are we in?
        LDA $0C54, X : BNE .past_first_step
        
        DEC $03B1, X : BPL .past_first_step
        
        ; Switch to the second step of the effect.
        LDA.b #$01 : STA $0C54, X
        
        PHX
        
        JSL Overworld_AlterWeathervane
        
        ; Trigger the sprite animations, such as the particles and the bird.
        LDY.b #$00
        LDA.b #$38
        
        JSL AddTravelBirdIntro
        
        PLX
    
    .past_first_step
    
        TXA : STA $7F5878
        
        LDA.b #$00 : STA $7F5879
        
        LDX.b #$0B
    
    .next_chunk
    
        LDA $7F586C, X : CMP.b #$FF : BNE .active_chunk
        
        BRL .finished_this_chunk
    
    .active_chunk
    
        LDA $7F5860, X : DEC A : STA $7F5860, X : BPL .chr_toggle_delay
        
        LDA.b #$01 : STA $7F5860, X
        
        ; Alternate their appearance.
        LDA $7F586C, X : EOR.b #$01 : STA $7F586C, X
    
    .chr_toggle_delay
    
        PHX
        
        LDA $7F5878 : TAY
        
        LDA $7F586C, X : STA $0C5E, Y
        LDA $7F5824, X : STA $0BFA, Y
        LDA $7F5830, X : STA $0C0E, Y
        LDA $7F583C, X : STA $0C04, Y
        LDA $7F5848, X : STA $0C18, Y
        LDA $7F5854, X : STA $029E, Y
        LDA $7F5800, X : STA $0C22, Y
        LDA $7F580C, X : STA $0C2C, Y
        
        LDA $7F5818, X : SUB.b #$01 : STA $7F5818, X : STA $0294, Y
        
        TYX
        
        JSR Ancilla_MoveVert
        JSR Ancilla_MoveHoriz
        JSR Ancilla_MoveAltitude
        
        STZ $74
        
        LDA $029E, X : CMP.b #$F0 : BCC .not_below_ground_enough
        
        LDA.b #$FF : STA $74
    
    .not_below_ground_enough
    
        JSR WeathervaneExplosion_DrawWoodChunk
        
        PLX
        
        LDA $74 : BPL .dont_deactivate_yet
        
        STA $7F586C, X
    
    .dont_deactivate_yet
    
        LDA $7F5878 : TAY
        
        LDA $0BFA, Y : STA $7F5824, X
        LDA $0C0E, Y : STA $7F5830, X
        LDA $0C04, Y : STA $7F583C, X
        LDA $0C18, Y : STA $7F5848, X
        LDA $029E, Y : STA $7F5854, X
    
    .finished_this_chunk
    
        ; Examine the next weather vane piece.
        DEX : BMI .executed_all_chunks
        
        BRL .next_chunk
    
    .executed_all_chunks
    
        LDA $7F5878 : TAY
        
        LDX.b #$0B
    
    .find_active_wood_chunk
    
        LDA $7F586C, X : CMP.b #$FF : BNE .at_least_one_active_chunk
        
        DEX : BPL .find_active_wood_chunk
        
        TYX
        
        ; Self terminate, naturally, if there are no chunks left.
        STZ $0C4A, X
    
    .at_least_one_active_chunk
    
        TYX
        
        RTS
    }

; ==============================================================================

    ; $45186-$45187 DATA
    pool WeathervaneExplosion_DrawWoodChunk:
    {
    
    .chr
        db $4E, $4F
    }

; ==============================================================================

    ; *$45188-$451D3 LOCAL
    WeathervaneExplosion_DrawWoodChunk:
    {
        JSR Ancilla_PrepOamCoord
        
        REP #$20
        
        LDA $029E, X : AND.w #$00FF : CMP.w #$0080 : BCC .sign_ext_z_coord
        
        ORA.w #$FF00
    
    .sign_ext_z_coord
    
        EOR.w #$FFFF : INC A : ADD $00 : STA $00
        
        SEP #$20
        
        LDA $0C5E, X : STA $72 : BMI .inactive_component
        
        PHX
        
        LDA $7F5879 : TAY
        
        JSR Ancilla_SetOam_XY
        
        LDX $72
        
        LDA .chr, X  : STA ($90), Y : INY
        LDA.b #$3C   : STA ($90), Y : INY
        
        TYA : STA $7F5879
        
        SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLX
    
    .inactive_component
    
        RTS
    }

; ==============================================================================

