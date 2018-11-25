
; ==============================================================================

    ; *$F273F-$F2763 BRANCH LOCATION
    pool Sprite_Pirogusu:
    {
    
    .is_flying_tile
    
        JMP Sprite_FlyingTile
    
    ; $F2742 MAIN ENTRY POINT
    Sprite_Pirogusu:
    
        LDA $0E90, X : BNE .is_flying_tile
        
        LDA $0B89, X : ORA.b #$30 : STA $0B89, X
        
        JSR Pirogusu_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Pirogusu_WriggleInHole
        dw Pirogusu_Emerge
        dw Pirogusu_SplashIntoPlay
        dw Pirogusu_Swim
    }

; ==============================================================================

    ; $F2764-$F2767 DATA
    pool Pirogusu_WriggleInHole:
    {
    
    .animation_states
        db $02, $03, $00, $01
    }

; ==============================================================================

    ; *$F2768-$F2781 JUMP LOCATION
    Pirogusu_WriggleInHole:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$1F : STA $0DF0, X
    
    .delay
    
        STA $0BA0, X
        
        LDY $0DE0, X
        
        LDA .animation_states, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; $F2782-$F278F DATA
    pool Pirogusu_Emerge:
    {
    
    .animation_states
        db $09, $0B, $05, $07, $05, $0B, $07, $09
    
    .y_speeds length 4
        db 0,  0
    
    .x_speeds
        db 4, -4,  0, 0
    }

; ==============================================================================

    ; *$F2790-$F27CD JUMP LOCATION
    Pirogusu_Emerge:
    {
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
        
        LDA.b #$20 : STA $0DF0, X
        
        STZ $0BA0, X
        
        JSR Sprite3_Zero_XY_Velocity
        
        RTS
    
    .delay
    
        LDA $0DE0, X : ASL A : STA $00
        
        LDA $0DF0, X : LSR #3 : AND.b #$01 : ORA $00 : TAY
        
        LDA .animation_states, Y : STA $0D90, X
        
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite3_Move
        
        RTS
    }

; ==============================================================================

    ; $F27CE-$F27DB DATA
    pool Pirogusu_SplashIntoPlay:
    {
    
    .animation_states
        db $10, $11, $12, $13, $0C, $0D, $0E, $0F
    
    .x_acceleration length 2
        db $02, $FE
    
    .y_acceleration
        db $00, $00, $02, $FE
    }

; ==============================================================================

    ; *$F27DC-$F281F JUMP LOCATION
    Pirogusu_SplashIntoPlay:
    {
        JSR Sprite3_CheckDamage
        JSR Sprite3_Move
        
        LDY $0DE0, X
        
        LDA $0D50, X : ADD .x_acceleration, Y : STA $0D50, X
        
        LDA $0D40, X : ADD .y_acceleration, Y : STA $0D40, X
        
        LDA $0DF0, X : BNE .splash_delay
        
        JSL Sprite_SpawnSmallWaterSplash
        
        LDA.b #$10 : STA $0E00, X
        
        INC $0D80, X
    
    .splash_delay
    
    ; *$F280A ALTERNATE ENTRY POINT
    shared Pirogusu_Animate:
    
        LDA $0DE0, X : ASL A : STA $00
        
        LDA $1A : AND.b #$04 : LSR #2 : ORA $00 : TAY
        
        LDA .animation_states, Y : STA $0D90, X
        
        RTS
    }

; ==============================================================================

    ; *$F2820-$F284B LONG
    Sprite_SpawnSmallWaterSplash:
    {
        ; Spawn a bush sprite... but for what...
        LDA.b #$EC
        LDY.b #$0E
        
        JSL Sprite_SpawnDynamically_arbitrary : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        STZ $012E
        
        LDA.b #$28 : JSL Sound_SetSfx2PanLong
        
        LDA.b #$03 : STA $0DD0, Y
        
        LDA.b #$0F : STA $0DF0, Y
        LDA.b #$00 : STA $0D80, Y
        LDA.b #$03 : STA $0E40, Y
    
    .spawn_failed
    
        RTL
    }

; ==============================================================================

    ; $F284C-$F2851 DATA
    pool Pirogusu_Swim:
    {
    
    .x_speeds length 4
        db 24, -24
    
    .y_speeds
        db  0,   0,  24, -24
    }

; ==============================================================================

    ; *$F2852-$F2892 JUMP LOCATION
    Pirogusu_Swim:
    {
        JSR Sprite3_CheckIfRecoiling
        JSR Sprite3_CheckDamage
        JSR Pirogusu_Animate
        
        ADD.b #$08 : STA $0D90, X
        
        LDA $0E00, X : BNE .swim_logic_delay
        
        JSR Pirogusu_SpawnSplashGarnish
        JSR Sprite3_Move
        
        JSR Sprite3_CheckTileCollision : AND.b #$0F : BEQ .anochange_direction
        
        JSL GetRandomInt : LSR A : LDA $0DE0, X : ROL A : TAY
        
        ; \task Needs to be named.
        LDA $9254, Y : STA $0DE0, X
    
    .anochange_direction
    
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
    
    .swim_logic_delay
    
        RTS
    }

; ==============================================================================

    ; $F2893-$F2896 DATA
    pool Pirogusu_SpawnSplashGarnish:
    {
    
    ; \task Name this routine / pool.
    .displacements
        db 3, 4, 5, 4
    }

; ==============================================================================

    ; *$F2897-$F2902 LOCAL
    Pirogusu_SpawnSplashGarnish:
    {
        TXA : EOR $1A : AND.b #$03 : BNE .garnish_delay
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA .displacements, Y : STA $00
        
        JSL GetRandomInt : AND.b #$03 : TAY
        
        LDA .displacements, Y : STA $01
        
        PHX : TXY
        
        LDX.b #$0E
    
    .find_open_garnish_slot
    
        LDA $7FF800, X : BEQ .open_garnish_slot
        
        DEX : BPL .find_open_garnish_slot
        
        PLX
    
    .garnish_delay
    
        RTS
    
    .open_garnish_slot
    
        LDA.b #$0B : STA $7FF800, X
                     STA $0FB4
        
        LDA $0D10, Y : ADD $00    : STA $7FF83C, X
        LDA $0D30, Y : ADC.b #$00 : STA $7FF878, X
        
        LDA $0D00, Y : ADD.b #$10 : PHP : ADD $01    : STA $7FF81E, X
        LDA $0D20, Y : ADC.b #$00 : PLP : ADC.b #$00 : STA $7FF85A, X
        
        LDA.b #$0F : STA $7FF90E, X
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $F2903-$F293A DATA
    pool Pirogusu_Draw:
    {
    
    .vh_flip
        db $00, $80, $40, $00, $00, $00, $00, $80
        db $80, $C0, $40, $40, $00, $40, $80, $C0
        db $40, $C0, $00, $80, $00, $40, $80, $C0
        db $40, $C0, $00, $80
    
    .animation_states
        db $00, $00, $01, $01, $02, $03, $04, $03
        db $02, $03, $04, $03, $05, $05, $05, $05
        db $07, $07, $07, $07, $06, $06, $06, $06
        db $08, $08, $08, $08
    }

; ==============================================================================

    ; *$F293B-$F297E LOCAL
    Pirogusu_Draw:
    {
        LDY $0D90, X
        
        LDA $0F50, X : AND.b #$3F : ORA .vh_flip, Y : STA $0F50, X
        
        LDA .animation_states, Y : STA $0DC0, X
        
        CPY.b #$04 : BCS .fully_visible
        
        LDA $0FD8 : ADD.b #$04 : STA $0FD8
        LDA $0FD9 : ADC.b #$00 : STA $0FD9
        
        LDA $0FDA : ADD.b #$04 : STA $0FDA
        LDA $0FDB : ADC.b #$00 : STA $0FDB
        
        JSL Sprite_PrepAndDrawSingleSmallLong
        
        RTS
    
    .fully_visible
    
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        RTS
    }

; ==============================================================================
