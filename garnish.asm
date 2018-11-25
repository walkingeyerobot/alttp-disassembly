
; ==============================================================================

    ; *$4B020-$4B06D LONG
    ZoraFireball_SpawnTailGarnish:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .skip_frame
        
        PHX
        
        LDX.b #$1D
    
    .next_slot
    
        LDA $7FF800, X : BEQ .empty_slot
        
        DEX : BPL .next_slot
        
        PLX
    
    .skip_frame
    
        RTL
    
    .empty_slot
    
        LDA.b #$08 : STA $7FF800, X : STA $0FB4
        LDA.b #$0B : STA $7FF90E, X
        
        LDA $0FD8 : STA $7FF83C, X
        LDA $0FD9 : STA $7FF878, X
        
        LDA $0FDA : ADD.b #$10 : STA $7FF81E, X
        LDA $0FDB : ADC.b #$00 : STA $7FF85A, X
        
        LDA $0FA0 : STA $7FF92C, X
        
        PLX
        
        RTL
    }

; ==============================================================================

    ; *$4B06E-$4B07E LONG
    Garnish_ExecuteUpperSlotsLong:
    {
        ; \note Maybe I'm nitpickin', but doesn't this seem a bit out of place
        ; here?
        JSL Filter_MajorWhitenMain
        
        LDA $0FB4 : BEQ .no_spawned_garnishes
        
        PHB : PHK : PLB
        
        JSR Garnish_ExecuteUpperSlots
        
        PLB
    
    .no_spawned_garnishes
    
        RTL
    }

; ==============================================================================

    ; *$4B07F-$4B08B LONG
    Garnish_ExecuteLowerSlotsLong:
    {
        LDA $0FB4 : BEQ .no_spawned_garnishes
        
        PHB : PHK : PLB
        
        JSR Garnish_ExecuteLowerSlots
        
        PLB
    
    .no_spawned_garnishes
    
        RTL
    }

; ==============================================================================

    ; *$4B08C-$4B096 LOCAL
    Garnish_ExecuteUpperSlots:
    {
        LDX.b #$1D
    
    .next_animation
    
        JSR Garnish_ExecuteSingle
        
        DEX : CPX.b #$0E : BNE .next_animation
        
        RTS
    }

; ==============================================================================

    ; *$4B097-$4B09F LOCAL
    Garnish_ExecuteLowerSlots:
    {
        LDX.b #$0E
    
    .next_animation
    
        JSR Garnish_ExecuteSingle
        
        DEX : BPL .next_animation
        
        RTS
    }

; ==============================================================================

    ; $4B0A0-$4B0B5 DATA
    pool Garnish_ExecuteSingle:
    {
    
    .oam_allocation
        db  4,  4,  4,  4,  4,  4,  4,  4
        db  4,  4,  4,  4,  4,  4,  4,  4
        db  8,  4,  4,  4,  8, 16
    }

; ==============================================================================

    ; $4B0B6-$4B14F LOCAL
    Garnish_ExecuteSingle:
    {
        STX $0FA0
        
        LDA $7FF800, X : BEQ .return
        CMP.b #$05     : BEQ .ignore_submodule
        
        LDA $11 : ORA $0FC1 : BNE .dont_self_terminate
    
    .ignore_submodule
    
        LDA $7FF90E, X : BEQ .dont_self_terminate
        
        DEC A : STA $7FF90E, X : BNE .dont_self_terminate
        
        STA $7FF800, X
        
        BRA .return
    
    .dont_self_terminate
    
        LDY $0FB3 : BEQ .dont_sort_sprites
        
        LDA $7FF968, X : BEQ .on_bg2
        
        LDA $7FF800, X : TAY
        
        LDA .oam_allocation-1, Y : JSL OAM_AllocateFromRegionF
        
        BRA .execute_handler
    
    .on_bg2
    
        LDA $7FF800, X : TAY
        
        LDA .oam_allocation-1, Y : JSL OAM_AllocateFromRegionD
        
        BRA .execute_handler
    
    .dont_sort_sprites
    
        LDA $7FF800, X : TAY
        
        LDA .oam_allocation-1, Y : JSL OAM_AllocateFromRegionA
    
    .execute_handler
    
        LDA $7FF800, X : DEC A
        
        REP #$30
        
        AND.w #$00FF : ASL A : TAY
        
        ; These damn sneaky hidden jump tables, I swear...
        LDA .handlers, Y : DEC A : PHA
        
        SEP #$30
    
    .return
    
        RTS
    
    .handlers
    
        !nullptr = $0000
        
        dw Garnish_WinderTrail         ; 0x01 - 
        dw Garnish_MothulaBeamTrail    ; 0x02 - 
        dw Garnish_CrumbleTile         ; 0x03 - 
        dw Garnish_LaserBeamTrail      ; 0x04 - 
        dw Garnish_SimpleSparkle       ; 0x05 - 
        dw Garnish_ZoroDander          ; 0x06 - 
        dw Garnish_BabusuFlash         ; 0x07 -
        
        dw Garnish_Nebule              ; 0x08 - 
        dw Garnish_LightningTrail      ; 0x09 - 
        dw Garnish_CannonPoof          ; 0x0A - 
        dw Garnish_WaterTrail          ; 0x0B - Pirogusu trail? (water trails from them?)
        dw Garnish_TrinexxIce          ; 0x0C - 
        dw !nullptr                    ; 0x0D - Clearly this is an invalid pointer, so it shouldn't be used
        dw Garnish_TrinexxLavaBubble   ; 0x0E - 
        dw Garnish_BlindLaserTrail     ; 0x0F -
        
        dw Garnish_GanonBatFlame       ; 0x10 - 
        dw Garnish_GanonBatFlameout    ; 0x11 - 
        dw Garnish_Sparkle             ; 0x12 - Sparkle that animates based on its autotimer.
        dw Garnish_PyramidDebris       ; 0x13 - 
        dw Garnish_RunningManDashDust  ; 0x14 - 
        dw Garnish_ArrghusSplash       ; 0x15 - 
        dw Garnish_ScatterDebris       ; 0x16 - Pot, bush, sign, or rock shattering after being broken up
    }

; ==============================================================================

    incsrc "garnish_running_man_dash_dust.asm"
    incsrc "garnish_pyramid_debris.asm"

; ==============================================================================

    ; $4B252-$4B283 LOCAL
    Garnish_Move_XY:
    {
        PHX
        
        TXA : ADD.b #$1E : TAX
        
        JSR Garnish_MoveVert
        
        PLX
    
    ; \note While no one else calls this location, it mirrors the
    ; availability of routines in other object classes.
    ; 4B25C ALTERNATE ENTRY POINT 
    shared Garnish_MoveVert:
    
        LDA $7FF896, X : ASL #4 : ADD $7FF8D2, X : STA $7FF8D2, X
        
        LDA $7FF896, X : PHP : LSR #4 : PLP : BPL .alpha
        
        ORA.b #$F0
    
    .alpha
    
        ADC $7FF81E, X : STA $7FF81E, X
        
        RTS
    }

; ==============================================================================

    incsrc "garnish_ganon_bat_flame_objects.asm"
    incsrc "garnish_trinexx_ice.asm"
    incsrc "garnish_running_man_dust_and_water_trail.asm"
    incsrc "garnish_cannon_poof.asm"
    incsrc "garnish_lightning_trail.asm"
    incsrc "garnish_babusu_flash.asm"
    incsrc "garnish_nebule.asm"
    incsrc "garnish_zoro_dander.asm"
    incsrc "garnish_sparkle_objects.asm"
    incsrc "garnish_trinexx_lava_bubble.asm"
    incsrc "garnish_blind_laser_trail.asm"
    incsrc "garnish_laser_beam_trail.asm"

; ==============================================================================

    ; $4B5DE-$4B612 LOCAL
    Garnish_PrepOamCoord:
    {
        LDA $7FF83C, X : SUB $E2 : STA $00
        LDA $7FF878, X : SBC $E3 : STA $01
        
        BNE .off_screen
        
        LDA $7FF81E, X : SUB $E8 : PHA
        LDA $7FF85A, X : SBC $E9
        
        BEQ .on_screen
        
        PLA
    
    .off_screen
    
        ; self terminate?
        LDA.b #$00 : STA $7FF800, X
        
        PLA : PLA
        
        RTS
    
    .on_screen
    
        PLA : SBC.b #$10 : STA $02
        
        LDY.b #$00
        
        RTS
    }

; ==============================================================================

    incsrc "garnish_crumble_tile.asm"
    incsrc "garnish_winder_trail.asm"
    incsrc "garnish_mothula_beam_trail.asm"

; ==============================================================================
