
; ==============================================================================
    
    ; *$49E90-$49EF7 LONG
    Tagalong_CheckBlindTriggerRegion:
    {
        PHB : PHK : PLB
        
        LDX $02CF
        
        LDA $1A00, X : STA $00
        LDA $1A14, X : STA $01
        
        LDA $1A28, X : STA $02
        LDA $1A3C, X : STA $03
        
        STZ $0B
        
        LDA $1A50, X : STA $0A : BPL .non_negative_altitude
        
        LDA.b #$FF : STA $0B
    
    .non_negative_altitude
    
        REP #$20
        
        LDA $00 : ADD $0A : ADD.w #$000C : STA $00
        
        LDA $02 : ADD.w #$0008 : STA $02
        
        LDA.w #$1568 : SUB $00 : BPL .non_negative_delta_x
        
        EOR.w #$FFFF : INC A
    
    .non_negative_delta_x
    
        CMP.w #$0018 : BCS .out_of_range
        
        LDA.w #$1980 : SUB $02 : BPL .non_negative_delta_y
        
        EOR.w #$FFFF : INC A
    
    .non_negative_delta_y
    
        CMP.w #$0018 : BCS .out_of_range
        
        SEP #$20
        
        PLB
        
        SEC
        
        RTL
    
    .out_of_range
    
        SEP #$20
        
        PLB
        
        CLC
        
        RTL
    }

; ==============================================================================

    ; $49EF8-$49EFB DATA
    pool Tagalong_Init:
    {
    
    .priorities
        db $20, $10, $30, $20
    }

; ==============================================================================

    ; *$49EFC-$49F38 LONG
    Tagalong_Init:
    {
        PHB : PHK : PLB
        
        ; Load Link's x and y coordinates byte by byte
        LDA $20 : STA $1A00
        LDA $21 : STA $1A14
        
        LDA $22 : STA $1A28
        LDA $23 : STA $1A3C
        
        ; $00 = Link's direction
        LDA $2F : LSR A : STA $00
        
        LDY $EE
        
        ; Link's sprite priority?
        LDA .priorities, Y : LSR #2 : ORA $00 : STA $1A64
        
        LDA.b #$40 : STA $02D2
        
        STZ $02CF
        STZ $02D3
        STZ $02D0
        STZ $02D6
        
        STZ $5E
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$49F39-$49F90 LONG
    Tagalong_SpawnFromSprite:
    {
        PHB : PHK : PLB : PHX
        
        STZ $02F9
        
        LDA $0D00, X : ADD.b #$FA : STA $1A00
        LDA $0D20, X : ADC.b #$FF : STA $1A14
        
        LDA $0D10, X : ADD.b #$01 : STA $1A28
        LDA $0D30, X : ADC.b #$00 : STA $1A3C
        
        LDY $EE
        
        LDA Tagalong_Init.priorities, Y : LSR #2 : ORA.b #$01 : STA $1A64
        
        LDA #$40 : STA $02D2
        
        STZ $02D3
        STZ $02CF
        STZ $02D0
        STZ $02D6
        
        STZ $5E
        STZ $02F9
        
        ; Super bomb is no longer going off?
        LDA.b #$00 : STA $7EF3D3
        
        JSL Tagalong_GetCloseToPlayer
        
        PLX : PLB
        
        RTL
    }

; ==============================================================================

    ; *$49F91-$49F98 LONG
    Tagalong_MainLong:
    {
        PHB : PHK : PLB
        
        JSR Tagalong_Main
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $49F99-$49FB4 JUMP TABLE LOCAL
    pool Tagalong_Main:
    {
        ; Tagalong Routines 1 (and only so far)
        ; Index into table is the value of $7EF3CC
    
    .handlers
    
        dw $A197 = $4A197* ; 0x01 - Princess Zelda 
        dw Tagalong_OldMountainMan ; 0x02 - Old man (unused alternate) Dashing or jumping off a ledge will disconnect the Tagalong from moving with the player.
        dw $A41F = $4A41F* ; 0x03 - Old man (unused alternate) waiting around for player to pick them up.
        dw Tagalong_OldMountainMan ; 0x04 - Old man (the one that the game uses)
        dw $A024 = $4A024* ; 0x05 - 
        dw $A197 = $4A197* ; 0x06 - 
        dw $A197 = $4A197* ; 0x07 - 
        dw $A197 = $4A197* ; 0x08 - 
        
        dw $A197 = $4A197* ; 0x09 
        dw $A197 = $4A197* ; 0x0A 
        dw $A41F = $4A41F* ; 0x0B - same as (3) \unused Probably from an earlier design for the chest, much like the old man's earlier design.
        dw $A197 = $4A197* ; 0x0C - Thief's chest
        dw $A197 = $4A197* ; 0x0D - Super Bomb
        dw $A024 = $4A024* ; 0x0E - Zelda screaming about Agahnim goons.
    }

; ==============================================================================

    ; $49FB5-$49FC3 DATA
    pool Tagalong_Main:
    {
    
    .messaging_tagalongs
        db $05, $09, $0A
    
    .message_timers
        dw $0DF3, $06F9, $0DF3
    
    .message_ids
        dw $0020, $0180, $011D
    }

; ==============================================================================

    ; *$49FC4-$4A196 LOCAL
    Tagalong_Main:
    {
        LDA $7EF3CC : BNE .player_has_tagalong
        
        RTS
    
    .player_has_tagalong
    
        CMP.b #$0E : BNE .not_boss_victory
        
        BRL BRANCH_4A59E
    
    .not_boss_victory
    
        LDY.b #$02
    
    .next_tagalong
    
        LDA $7EF3CC : CMP .message_tagalongs, Y : BEQ .tagalongWithTimer
        
        DEY : BPL .next_tagalong
        
        BRL BRANCH_IOTA
    
    .tagalongWithTimer
    
        ; Check if not in the default standard submodule
        LDA $11 : BNE BRANCH_EPSILON
        
        ; Special case for kiki
        CPY.b #$02 : BNE .not_kiki
        
        LDA $8A : AND.b #$40 : BNE BRANCH_EPSILON
    
    .not_kiki
    
        REP #$20
        
        ; Tick down the timer until Zelda bitches at you again.
        DEC $02CD : BPL BRANCH_EPSILON
        
        SEP #$20
        
        JSL Tagalong_CanWeDisplayMessage : BCS .can_display
        
        STZ $02CD : STZ $02CE
        
        BRA BRANCH_EPSILON
    
    .can_display
    
        REP #$20
        
        PHY
        
        TYA : AND.w #$00FF : ASL A : TAY
        
        LDA .message_timers, Y : STA $02CD
        
        LDA .message_ids, Y : STA $1CF0
        
        SEP #$20
        
        JSL Main_ShowTextMessage
        
        PLY
    
    ; *$4A024 ALTERNATE ENTRY POINT
    BRANCH_EPSILON:
    
        SEP #$20
        
        CPY.b #$00 : BNE BRANCH_IOTA
        
        RTS
    
    BRANCH_IOTA:
    
        SEP #$20
        
        LDA $7EF3D3 : BEQ .super_bomb_not_going_off
        
        BRL BRANCH_ALIF
    
    .super_bomb_not_going_off
    
        ; Is if the thief's chest tagalong?
        LDA $7EF3CC : CMP.b #$0C : BNE .not_thief_chest
        
        LDA $4D : BNE BRANCH_MU
        
        BRA BRANCH_NU
    
    .not_thief_chest
    
        LDA $7EF3CC : CMP.b #$0D : BEQ BRANCH_XI
    
    BRANCH_MU:
    
        BRL BRANCH_PI
    
    BRANCH_XI:
    
        LDA $4D : CMP.b #$02 : BEQ BRANCH_OMICRON
        
        LDA $5B : CMP.b #$02 : BEQ BRANCH_OMICRON
    
    BRANCH_NU:
    
        LDA $11 : BNE BRANCH_MU
        
        LDA $4D : CMP.b #$01 : BEQ BRANCH_PI
        
        BIT $0308 : BMI BRANCH_PI
        
        LDA $02F9 : BNE BRANCH_PI
        
        LDA $02D0 : BNE BRANCH_PI
        
        LDX $02CF
        
        LDA $1A50, X : BEQ BRANCH_RHO
                       BPL BRANCH_PI
    
    BRANCH_RHO:
    
        LDA $F6 : AND.b #$80 : BEQ BRANCH_PI
    
    BRANCH_OMICRON:
    
        LDA $7EF3CC : CMP.b #$0D : BNE BRANCH_SIGMA
        
        LDA $1B : BNE BRANCH_SIGMA
        
        LDA $5D
        
        CMP.b #$08 : BEQ BRANCH_PI
        CMP.b #$09 : BEQ BRANCH_PI
        CMP.b #$0A : BEQ BRANCH_PI
        
        LDA.b #$03 : STA $04B4
        LDA.b #$BB : STA $04B5
    
    BRANCH_SIGMA:
    
        ; This occurs when the bomb is set to trigger by Link
        LDA.b #$80 : STA $7EF3D3
        
        LDA.b #$40 : STA $02D2
        
        LDX $02CF
        
        LDA $1A00, X : STA $7EF3CD
        LDA $1A14, X : STA $7EF3CE
        
        LDA $1A28, X : STA $7EF3CF
        LDA $1A3C, X : STA $7EF3D0
        
        LDA $EE : STA $7EF3D2
        
        LDA $1B : STA $7EF3D1
    
    BRANCH_ALIF:
    
        BRL BRANCH_4A2B2
    
    BRANCH_PI:
    
        SEP #$20
        
        LDA $02E4 : BNE BRANCH_TAU
        
        LDX $10
        
        LDY $11 : CPY.b #$0A : BEQ BRANCH_TAU
        
        CPX.b #$09 : BNE BRANCH_UPSILON
        
        CPY.b #$23 : BEQ BRANCH_TAU
    
    BRANCH_UPSILON:
    
        CPX.b #$0E : BNE BRANCH_PHI
        
        CPY.b #$01 : BEQ BRANCH_TAU
        CPY.b #$02 : BNE BRANCH_PHI
    
    BRANCH_TAU:
    
        BRL BRANCH_CHI
    
    BRANCH_PHI:
    
        LDA $30 : ORA $31 : BEQ BRANCH_CHI
        
        LDX $02D3 : INX : CPX.b #$14 : BNE BRANCH_PSI
        
        LDX.b #$00
    
    BRANCH_PSI:
    
        STX $02D3
        
        LDA $24 : CMP.b #$F0 : BCC BRANCH_OMEGA
        
        LDA.b #$00
    
    BRANCH_OMEGA:
    
        STA $00
        STZ $01
        
        LDA $00 : STA $1A50, X
        
        REP #$20
        
        LDA $20 : SUB $00 : STA $00
        
        SEP #$20
        
        LDA $00 : STA $1A00, X
        LDA $01 : STA $1A14, X
        LDA $22 : STA $1A28, X
        LDA $23 : STA $1A3C, X
        
        LDA $2F : LSR A : STA $1A64, X
        
        LDY $EE
        
        LDA Tagalong_Init.priorities, Y : LSR #2 : ORA $1A64, X : STA $1A64, X
        
        LDA $5D : CMP.b #$04 : BNE BRANCH_ALTIMA
        
        LDY.b #$20
        
        BRA BRANCH_ULTIMA
    
    BRANCH_ALTIMA:
    
        CMP.b #$13 : BNE BRANCH_OPTIMUS
        
        LDA $037E : BEQ BRANCH_OPTIMUS
        
        LDA.b #$10 : ORA $1A64, X : STA $1A64, X
    
    BRANCH_OPTIMUS:
    
        LDY.b #$80
        
        LDA $0351  : BEQ BRANCH_CHI
        CMP.b #$01 : BEQ BRANCH_ULTIMA
        
        LDY.b #$40
    
    BRANCH_ULTIMA:
    
        TYA : ORA $1A64, X : STA $1A64, X
    
    BRANCH_CHI:
    
        LDA $7EF3CC : DEC A : ASL A : TAX
        
        JMP (.handlers, X)
    
    .unused
    
        RTS
    }

    ; *$4A197-$4A2B0 JUMP LOCATION
    {
        LDA $02E4 : BNE BRANCH_ALPHA
        
        LDX $10
        
        LDY $11 : CPY.b #$0A : BEQ BRANCH_ALPHA
        
        CPX.b #$09 : BNE BRANCH_BETA
        
        CPY.b #$23 : BEQ BRANCH_ALPHA
    
    BRANCH_BETA:
    
        CPX.b #$0E : BNE BRANCH_GAMMA
        
        CPY.b #$01 : BEQ BRANCH_ALPHA
        CPY.b #$02 : BNE BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        BRL BRANCH_NU
    
    BRANCH_GAMMA:
    
        JSR $A59E ; $4A59E IN ROM
        
        LDA $7EF3CC : CMP.b #$0A : BNE BRANCH_DELTA
        
        LDA $4D : BEQ BRANCH_DELTA
        
        LDA $031F : BEQ BRANCH_DELTA
        
        LDA $02CF : INC A : CMP.b #$14 : BNE BRANCH_EPSILON
        
        LDA.b #$00
    
    BRANCH_EPSILON:
    
        JSL Kiki_AbandonDamagedPlayer
        
        LDA.b #$00 : STA $7EF3CC
        
        RTS
    
    BRANCH_DELTA:
    
        ; Check if tagalong == Blind in disguise as maiden.
        LDA $7EF3CC : CMP.b #$06 : BNE .blind_not_triggered
        
        REP #$20
        
        ; Check if it's Blind's boss room.
        LDA $A0 : CMP.w #$00AC : BNE .blind_not_triggered
        
        ; Check if the hole in the floor in the room above has been bombed out
        ; in order to let light in from the window.
        LDA $7EF0CA : AND.w #$0100 : BEQ .blind_not_triggered
        
        SEP #$20
        
        JSL Tagalong_CheckBlindTriggerRegion : BCC .blind_not_triggered
        
        LDX $02CF
        
        LDA $1A28, X : STA $00
        LDA $1A3C, X : STA $01
        
        LDA $1A00, X : STA $02
        LDA $1A14, X : STA $03
        
        LDA.b #$00 : STA $7EF3CC
        
        JSL Blind_SpawnFromMaidenTagalong
        
        INC $0468
        
        STZ $068E
        STZ $0690
        
        LDA.b #$05 : STA $11
        
        LDA.b #$15 : STA $012C
        
        RTS
    
    BRANCH_ZETA:
    
        SEP #$20
        
        LDY $5D
        
        LDA $02D0 : BNE BRANCH_THETA
        
        CPY.b #$13 : BNE BRANCH_IOTA
        
        LDA $037E : BEQ BRANCH_IOTA
        
        LDA.b #$01 : STA $02D0
        
        BRA BRANCH_KAPPA
    
    BRANCH_THETA:
    
        CPY.b #$13 : BEQ BRANCH_KAPPA
        
        LDA $02D1 : CMP $02CF : BNE BRANCH_LAMBDA
        
        STZ $02D0
    
    BRANCH_IOTA:
    
        LDX $02CF
        
        LDA $1A50, X : BEQ BRANCH_MU : BMI BRANCH_MU
        
        LDA $02D3 : CMP $02CF : BNE BRANCH_LAMBDA
        
        STZ $1A50, X
        
        LDA $20 : STA $1A00, X
        LDA $21 : STA $1A14, X
        LDA $22 : STA $1A28, X
        LDA $23 : STA $1A3C, X
    
    BRANCH_MU:

        LDA $30 : ORA $31 : BEQ BRANCH_NU
    
    BRANCH_KAPPA:
    
        LDA $02D3 : SUB.b #$0F : BPL BRANCH_XI
        
        ADD.b #$14
    
    BRANCH_XI:
    
        CMP $02CF : BNE BRANCH_NU
    
    BRANCH_LAMBDA:
    
        LDX $02CF : INX : CPX.b #$14 : BNE BRANCH_OMICRON
        
        LDX.b #$00
    
    BRANCH_OMICRON:
    
        STX $02CF
    
    BRANCH_NU:
    
        BRL BRANCH_$4A907
    }

    ; $4A2B1-$4A2B1 BRANCH LOCATION
    {
        RTS
    }
    
    ; *$4A2B2-$4A308 JUMP LOCATION
    {
        LDA $7EF3D1 : CMP $1B : BNE BRANCH_$4A2B1 ; (RTS) ; if indoors, don't branch
        
        ; Is Link dashing?
        LDA $0372 : BNE BRANCH_ALPHA; Yes... branch to alpha
        
        JSR Tagalong_CheckPlayerProximity : BCS BRANCH_ALPHA
        
        JSL Tagalong_Init
        
        LDA $1B : STA $7EF3D1
        
        LDA $7EF3CC : CMP.b #$0D : BNE BRANCH_BETA
        
        LDA.b #$FE : STA $04B4
        
        STZ $04B5
    
    BRANCH_BETA:
    
        LDA.b #$00 : STA $7EF3D3
        
        BRL BRANCH_$4A907
    
    BRANCH_ALPHA:
    
        ; Is it a super bomb?
        LDA $7EF3CC : CMP.b #$0D : BNE BRANCH_GAMMA ; no, get out of here
        
        ; Are we indoors?
        LDA $1B : BNE BRANCH_GAMMA; yes, get out of here >:(
        
        LDA $04B4 : BNE BRANCH_GAMMA
        
        LDY.b #$00
        LDA.b #$3A
        
        JSL AddSuperBombExplosion
        
        LDA.b #$00 : STA $7EF3D3
    
    BRANCH_GAMMA:
    
        BRL BRANCH_$4A450
    }

; ==============================================================================

    ; $4A309-$4A317 DATA
    pool Tagalong_OldMountainMan:
    {
    
    .replacement_tagalong
        db 0, 0, 3, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    }

; ==============================================================================

    ; *$4A318-$4A40F JUMP LOCATION
    Tagalong_OldMountainMan:
    {
        ; Old Man on the Mountain tagalong routine
        
        ; Can Link move?
        LDA $02E4 : BNE BRANCH_ALPHA
        
        ; Is Link coming out of a door into the overworld?
        LDX $10
        
        LDY $11 : CPY.b #$0A : BEQ BRANCH_ALPHA
        
        CPX.b #$09 : BNE BRANCH_BETA
        
        ; Is the magic mirror being used?
        CPY.b #$23 : BEQ BRANCH_ALPHA
    
    BRANCH_BETA:
    
        ; Are we in text mode?
        CPX.b #$0E : BNE BRANCH_GAMMA
        
        CPY.b #$01 : BEQ BRANCH_ALPHA
        CPY.b #$02 : BNE BRANCH_GAMMA ; Text message mode
    
    BRANCH_ALPHA:
    
        BRL BRANCH_NU
    
    BRANCH_GAMMA:
    
        ; Make an exception for movement speeds. It's not dashing speed, so
        ; I'm not sure what speed type this is.
        LDA $5E : CMP.b #$04 : BEQ BRANCH_DELTA
        
        LDA.b #$0C : STA $5E
    
    BRANCH_DELTA:
    
        JSR $A59E ; $4A59E IN ROM
        
        SEP #$30
        
        LDA $7EF3CC : BNE BRANCH_EPSILON
        
        RTS
    
    BRANCH_EPSILON:
    
        CMP.b #$04
    
    BRANCH_ZETA
    
        LDX $02CF
        
        LDA $1A50, X : BEQ BRANCH_THETA : BMI BRANCH_THETA
        
        LDA $02CF : CMP $02D3 : BEQ BRANCH_THETA
        
        BRL BRANCH_OMICRON
    
    BRANCH_THETA:
    
        BRL BRANCH_LAMBDA
    
    BRANCH_ZETA:
    
        LDA $4D : AND.b #$01 : BEQ BRANCH_IOTA
        
        ; Is Link in a recoil state?
        LDA $5D : CMP.b #$06 : BNE BRANCH_IOTA ; if not, then branch away
        
        LDA $02D3 : CMP $02CF : BNE BRANCH_KAPPA
        
        DEX : STX $02CF : BPL BRANCH_KAPPA
        
        LDA.b #$13 : STA $02CF
    
    BRANCH_IOTA:
    
        LDA $4D : AND.b #$02 : BEQ BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        LDA $7EF3CC : TAX
        
        LDA .replacement_tagalong, X : STA $7EF3CC
        
        LDA.b #$40 : STA $02D2
        
        LDX $02CF
        
        LDA $1A00, X : STA $7EF3CD
        LDA $1A14, X : STA $7EF3CE
        
        LDA $1A28, X : STA $7EF3CF
        LDA $1A3C, X : STA $7EF3D0
        
        LDA $EE : STA $7EF3D2
        
        BRA BRANCH_$4A41F
    
    BRANCH_LAMBDA:
    
        LDA $30 : ORA $31 : BNE BRANCH_MU
        
        LDA $1A : AND.b #$03 : BNE BRANCH_NU
        
        LDA $02D3 : CMP $02CF : BEQ BRANCH_NU
        
        SUB.b #$09 : BPL BRANCH_XI
        
        ADD.b #$14
    
    BRANCH_XI:
    
        CMP $02CF : BNE BRANCH_OMICRON
        
        BRL BRANCH_NU
    
    BRANCH_MU:
    
        LDA $02D3 : SUB.b #$14 : BPL BRANCH_PI
        
        ADD.b #$14
    
    BRANCH_PI:
    
        CMP $02CF : BNE BRANCH_NU
    
    BRANCH_OMICRON:
    
        LDX $02CF : INX : CPX.b #$14 : BCC BRANCH_RHO
        
        LDX.b #$00
    
    BRANCH_RHO:
    
        STX $02CF
    
    BRANCH_NU:
    
        BRL BRANCH_4A907
        
        RTS
    }

; ==============================================================================

    ; $4A410-$4A41E DATA
    {
    
    ; Task name this pool / routine
    .replacement_tagalong
        db $00, $00, $00, $02, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$4A41F-$4A48D JUMP LOCATION
    {
        ; Slow down the player...
        LDA.b #$10 : STA $5E
        
        ; Is Link dashing?
        LDA $0372 : BNE BRANCH_ALPHA
        
        LDA $4D : BNE BRANCH_ALPHA
        
        ; Is player swimming?
        LDA $5D : CMP.b #$04 : BEQ BRANCH_ALPHA
        
        STZ $5E
        
        ; Is player in hookshot mode?
        LDA $5D : CMP.b #$13 : BEQ BRANCH_ALPHA
        
        JSR Tagalong_CheckPlayerProximity : BCS BRANCH_ALPHA
        
        JSL Tagalong_Init
        
        LDA $7EF3CC : TAX
        
        LDA .replacement_tagalong, X : STA $7EF3CC
        
        RTS
    
    ; *$4A450 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        LDA $7EF3D2 : TAX : CPX $EE : BNE BRANCH_BETA
        
        LDX $EE
    
    BRANCH_BETA:
    
        LDA Tagalong_Init.priorities, X : STA $65
                                          STZ $64
        
        LDA $7EF3CD : STA $00
        LDA $7EF3CE : STA $01
        
        LDA $7EF3CF : STA $02
        LDA $7EF3D0 : STA $03
        
        LDX.b #$02
        
        LDA $7EF3CC : CMP.b #$0D : BEQ BRANCH_GAMMA
                      CMP.b #$0C : BEQ BRANCH_GAMMA
        
        LDX.b #$01
    
    BRANCH_GAMMA:
    
        TXA
        
        BRL BRANCH_$4A957
    }

; ==============================================================================

    ; *$4A48E-$4A4C7 LOCAL
    Tagalong_CheckPlayerProximity:
    {
        DEC $02D2 : BPL .delay
        
        STZ $02D2
        
        REP #$20
        
        LDA $7EF3CD : SUB.w #$0001 : CMP $20 : BCS .not_in_range
                      ADD.w #$0014 : CMP $20 : BCC .not_in_range
        
        LDA $7EF3CF : SUB.w #$0001 : CMP $22 : BCS .not_in_range
                      ADD.w #$0014 : CMP $22 : BCC .not_in_range
        
        SEP #$20
        
        CLC
        
        RTS
    
    .delay
    .not_in_range
    
        SEP #$20
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; $4A4C8-$4A59D DATA
    {
    
    .rooms_with_special_text_1
        dw $00F1
        dw $0061
        dw $0051
        dw $0002
        dw $00DB
        dw $00AB
        dw $0022
    
    ; $4A4D6 to $4A54D
    .room_data_1
        ; ?
        ; ?
        ; ?
        ; text message number,
        ; tagalong number
        dw $1EF0, $0288, $0001, $0099, $0004
        dw $1E58, $02F0, $0002, $009A, $0004
        dw $1EA8, $03B8, $0004, $009B, $0004
        dw $0CF8, $025B, $0001, $0021, $0001
        dw $0CF8, $039D, $0002, $0021, $0001
        dw $0C78, $0238, $0004, $0021, $0001
        dw $0A30, $02F8, $0001, $0022, $0001
        dw $0178, $0550, $0001, $0023, $0001
        dw $0168, $04F8, $0002, $002A, $0001
        dw $1BD8, $16FC, $0001, $0124, $0006
        dw $1520, $167C, $0001, $0124, $0006
        dw $05AC, $04FC, $0001, $0029, $0001
    
    ; $4A54E
    .areas_with_special_text_1
        dw $0003
        dw $005E
        dw $0000
    
    ; $4A554 to $4A585
    .area_data_1
        dw $03C0, $0730, $0001, $009D, $0004
        dw $0648, $0F50, $0000, $FFFF, $000A
        dw $06C8, $0D78, $0001, $FFFF, $000A
        dw $0688, $0C78, $0002, $FFFF, $000A
        dw $00E8, $0090, $0000, $0028, $000E
    
    ; $4A586 ($4A588 too, in a way)
    .room_data_boundaries_1
        dw 0, 30, 60, 70, 90, 100, 110, 120, 
    
    ; $4A596
    .area_data_boundaries_1
        dw 0, 10, 40, 50
    }

; ==============================================================================

    ; *$4A59E-$4A6CC LOCAL
    {
        LDA $11 : BNE .no_text_message
        
        REP #$30
        
        LDY #$0000
        
        LDA $1B : AND.w #$00FF : BEQ .check_areas
        
        INY
        
        LDX.w #$000C
        
        LDA $A0
    
    .check_next_room
    
        CMP $A4C8, X : BEQ .room_match
        
        DEX #2 : BPL .check_next_room
        
        BRA .no_text_message
    
    .check_areas
    
        LDX.w #$0004
        
        LDA $8A
    
    .check_next_area
    
        ; Select graphics based on certain areas maybe?
        ; the areas mentioned in this array are the mountain, the forest,
        ; and the maze in the dark world (i.e. ???, old man, and kiki)
        CMP $A54E, X : BEQ .area_match
        
        DEX #2 : BPL .check_next_area
    
    .no_text_message
    
        BRL .return
    
    .room_match
    
        LDA $A588, X : STA $08
        
        LDA $A586, X : TAX
    
    .next_room_data_block
    
        STX $0C
        
        STZ $0A
        
        LDA $7EF3CC : AND.w #$00FF : CMP $A4DE, X : BNE .not_room_data_match
        
        LDA $A4D6, X : STA $00
        LDA $A4D8, X : STA $02
        LDA $A4DA, X : STA $06
        LDA $A4DC, X : STA $04
        
        SEP #$30
        
        JSR Tagalong_CheckTextTriggerProximity : BCS .check_flags_and_proximity
        
        REP #$30
    
    .not_room_data_match
    
        LDA $0C : ADD.w #$000A : TAX
        
        CPX $08 : BNE .next_room_data_block
        
        BRL .return
    
    .area_match
    
        LDA $A598, X : STA $08
        LDA $A596, X : TAX
    
    .next_area_data_block
    
        STX $0C
        STZ $0A
        
        LDA $7EF3CC : AND.w #$00FF : CMP $A55C, X : BNE .not_area_data_match
        
        LDA $A554, X : STA $00
        LDA $A556, X : STA $02
        LDA $A558, X : STA $06
        LDA $A55A, X : STA $04
        
        SEP #$30
        
        JSR Tagalong_CheckTextTriggerProximity : BCS .check_flags_and_proximity
        
        REP #$30
    
    .not_area_data_match
    
        LDA $0C : ADD.w #$000A : TAX
        
        CPX $08 : BNE .next_area_data_block
        
        BRA .return
    
    .check_flags_and_proximity
    
        SEP #$10
        REP #$20
        
        ; Message has already triggered once during this instance of being
        ; in this room or area.
        LDA $02F2 : AND $06 : BNE .return
        
        LDA $06 : TSB $02F2
        
        ; Configure the text message index.
        LDA $04 : STA $1CF0
        
        CMP.w #$FFFF : BEQ .no_text_message
        CMP.w #$009D : BEQ .certain_kiki_message
        CMP.w #$0028 : BNE .show_text_message
        
        SEP #$20
        
        LDA #$00 : STA $7EF3CC
        
        BRA .show_text_message
    
    .certain_kiki_message
    
        SEP #$20
        
        LDA $02CF : INC A : CMP.b #$14 : BNE .tagalong_state_index_not_maxed
        
        LDA.b #$00
    
    .tagalong_state_index_not_maxed
    
        JSL OldMountainMan_TransitionFromTagalong
    
    .show_text_message
    
        SEP #$20
        
        JSL Main_ShowTextMessage
        
        BRA .return
    
    .no_text_message
    
        SEP #$30
        
        LDA $02CF : INC A : CMP.b #$14 : BNE .tagalong_state_index_not_maxed_2
        
        LDA.b #$00
    
    .tagalong_state_index_not_maxed_2
    
        PHA
        
        LDA $06 : AND.b #$03 : BNE .kiki_first_begging_sequence
        
        PLA
        
        JSL Kiki_InitiatePalaceOpeningProposal
        
        BRA .return
    
    .kiki_first_begging_sequence
    
        PLA : STA $00
        
        LDX $8A
        
        LDA $7EF280, X : AND.b #$01 : BNE .return
        
        LDA $00
        
        JSL Kiki_InitiateFirstBeggingSequence
    
    .return
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $4A6CD-$4A906 DATA
    {
        ; \task Fill in data later and name these routines.
        
    }

; ==============================================================================

; *$4A907-$4ABF8 LOCAL
{
    ; best guess so far: zero if your tagalong is transforming, nonzero
    ; otherwise
    LDA $02F9 : BEQ .continue
    
    RTS

.continue

    PHX : PHY
    
    LDX $02CF
    
    LDA $1A50, X : BEQ BRANCH_BETA
    
    LDA $1B : BNE BRANCH_BETA
    
    LDA.b #$20
    
    BRA BRANCH_GAMMA

BRANCH_BETA:

    LDA $11 : CMP.b #$0E : BNE BRANCH_DELTA
    
    LDY $EE : LDA Tagalong_Init.priorities, Y
    
    BRA BRANCH_GAMMA

BRANCH_DELTA:

    LDA $1A64, X : AND.b #$0C : ASL #2

BRANCH_GAMMA:

    STA $65 : STZ $64
    
    LDX $02CF : BPL BRANCH_EPSILON
    
    LDX.b #$00

BRANCH_EPSILON:

    LDA $1A00, X : STA $00
    LDA $1A14, X : STA $01
    
    LDA $1A28, X : STA $02
    LDA $1A3C, X : STA $03
    
    LDA $1A64, X
    
    BRA BRANCH_ZETA

; *$4A957 ALTERNATE ENTRY POINT

    PHX : PHY

BRANCH_ZETA:

    STA $05 : AND.b #$20 : LSR #2 : TAY
    
    LDA $05 : AND.b #$03 : STA $04
    
    STZ $72
    
    CPY.b #$08 : BNE BRANCH_THETA
    
    LDY.b #$00
    
    LDA $7EF3CC
    
    CMP.b #$06 : BEQ BRANCH_IOTA
    CMP.b #$01 : BNE BRANCH_THETA

BRANCH_IOTA:

    LDY.b #$08
    
    LDA $033C : ORA $033D : ORA $033E : ORA $033F : BEQ BRANCH_KAPPA
    
    LDA $1A : AND.b #$08 : LSR A
    
    BRA BRANCH_LAMBDA

BRANCH_KAPPA:

    LDA $1A : AND.b #$10 : LSR #2
    
    BRA BRANCH_LAMBDA

BRANCH_THETA:

    LDA $11
    
    CMP.b #$0E : BEQ BRANCH_MU
    CMP.b #$08 : BEQ BRANCH_MU
    CMP.b #$10 : BEQ BRANCH_MU
    
    LDA $7EF3CC
    
    CMP.b #$0B : BEQ BRANCH_NU
    CMP.b #$0D : BEQ BRANCH_XI
    CMP.b #$0C : BNE BRANCH_OMICRON

BRANCH_XI:

    LDA $7EF3D3 : BNE BRANCH_PI

BRANCH_OMICRON:

    LDA $02E4 : BNE BRANCH_OMICRON
    
    LDA $11 : CMP.b #$0A : BEQ BRANCH_OMICRON
    
    LDA $10 : CMP.b #$09 : BNE BRANCH_RHO
    
    LDA $11 : CMP.b #$23 : BEQ BRANCH_PI

BRANCH_RHO:

    LDA $10 : CMP.b #$0E : BNE BRANCH_SIGMA
    
    LDA $11
    
    CMP.b #$01 : BEQ BRANCH_PI
    CMP.b #$02 : BEQ BRANCH_PI

BRANCH_SIGMA:

    LDA $30 : ORA $31 : BNE BRANCH_MU

BRANCH_PI:

    LDA.b #$04 : STA $72
    
    BRA BRANCH_LAMBDA

BRANCH_MU:

    LDA $0372 : BEQ BRANCH_NU
    
    LDA $1A : AND.b #$04
    
    BRA BRANCH_LAMBDA

BRANCH_NU:

    LDA $1A : AND.b #$08 : LSR A

BRANCH_LAMBDA:

    ADD $04 : STA $04
    
    TYA : ADD $04 : STA $04
    
    REP #$20
    
    LDA $0FB3 : AND.w #$00FF : ASL A : TAY
    
    LDA $20 : CMP $00 : BEQ BRANCH_TAU
    
    BCS #$0E
    
    BRA #$07

BRANCH_TAU:

    LDA $05 : AND.w #$0003 : BNE BRANCH_UPSILON
    
    LDA $A8F1, Y
    
    BRA BRANCH_PHI

BRANCH_UPSILON:

    LDA $A8F5, Y

BRANCH_PHI:

    PHA
    
    LSR #2 : ADD.w #$0A20 : STA $92
    
    PLA : ADD.w #$0800 : STA $90
    
    LDA $00 : SUB $E8 : STA $06
    
    LDA $02 : SUB $E2 : STA $08
    
    SEP #$20
    
    LDY.b #$00
    LDX.b #$00
    
    LDA $7EF3CC
    
    CMP.b #$01 : BEQ BRANCH_PSI
    CMP.b #$06 : BEQ BRANCH_PSI
    
    LDA $05 : AND.b #$20 : BEQ BRANCH_PSI
    
    BRA BRANCH_CHI

BRANCH_PSI:

    LDA $05 : AND.b #$C0 : BNE BRANCH_OMEGA
    
    BRL BRANCH_THEL

BRANCH_OMEGA:

    LDA $05 : AND.b #$80 : BNE BRANCH_CHI
    
    LDX.b #$0C
    
    LDA $72 : BEQ BRANCH_CHI
    
    LDA.b #$00
    
    BRA BRANCH_ALTIMA

BRANCH_CHI:

    LDA $1A : AND.b #$07 : BNE BRANCH_ULTIMA
    
    LDA $02D7 : INC A : CMP.b #$03 : BNE BRANCH_ALTIMA
    
    LDA.b #$00

BRANCH_ALTIMA:

    STA $02D7

BRANCH_ULTIMA:

    LDA $02D7 : ASL #2 : STA $05
    
    TXA : ADD $05 : TAX
    
    REP #$20
    
    LDA $06 : ADD.w #$0010 : STA $00
    
    LDA $08 : STA $02
    
    STZ $74
    
    SEP #$20
    
    JSR Tagalong_SetOam_XY
    
    LDA $A8D9, X : STA ($90), Y : INY
    LDA $A8DA, X : STA ($90), Y : INY
    
    PHY
    
    TYA : SUB.b #$04 : LSR #2 : TAY
    
    LDA.b #$00 : ORA $75 : STA ($92), Y
    
    PLY
    
    REP #$20
    
    LDA $02 : ADD.w #$0008 : STA $02
    
    STZ $74
    
    SEP #$20
    
    JSR Tagalong_SetOam_XY
    
    LDA $A8DB, X : STA ($90), Y : INY
    LDA $A8DC, X : STA ($90), Y : INY
    
    PHY
    
    TYA : SUB.b #$04 : LSR #2 : TAY
    
    LDA.b #$00 : ORA $75 : STA ($92), Y
    
    PLY

BRANCH_THEL:

    LDA $7EF3CC : TAX
    
    LDA $A8F9, X : CMP.b #$07 : BNE BRANCH_OPTIMUS
    
    TAX
    
    LDA $0ABD : BEQ BRANCH_ALIF
    
    LDX.b #$00

BRANCH_ALIF:

    TXA

BRANCH_OPTIMUS:

    ASL A : STA $72
    
    LDA $7EF3CC : CMP.b #$0D : BNE BRANCH_BET
    
    LDA $04B4 : CMP.b #$01 : BNE BRANCH_BET
    
    LDA $1A : AND.b #$07 : ASL A : STA $72

BRANCH_BET:

    LDA $7EF3CC
    
    CMP.b #$0D : BEQ BRANCH_DEL
    CMP.b #$0C : BEQ BRANCH_DEL
    
    REP #$30
    
    PHY
    
    LDA $04 : AND.w #$00FF : ASL #3 : TAY
    
    LDA $7EF3CC : AND.w #$00FF : ASL A : TAX
    
    TYA : ADD $A8BD, X : TAX
    
    LDA $A6FD, X : ADD $06 : STA $00
    LDA $A6FF, X : ADD $08 : STA $02
    
    PLY
    
    SEP #$30
    
    JSR Tagalong_SetOam_XY
    
    LDA.b #$20 : STA ($90), Y
    
    INY
    
    LDA $04 : ASL A : ADD $04 : TAX
    
    LDA $A6CD, X : STA $0AE8
    
    LDA $A6CF, X : AND.b #$F0 : ORA $72 : ORA $65 : STA ($90), Y
    
    INY : PHY
    
    TYA : SUB.b #$04 : LSR #2 : TAY
    
    LDA #$02 : ORA $75 : STA ($92), Y
    
    PLY

BRANCH_DEL:

    REP #$30
    
    PHY
    
    LDA $04 : AND.w #$00FF : ASL #3 : TAY
    
    LDA $7EF3CC : AND.w #$00FF : ASL A : TAX
    
    TYA : ADD $A8BD, X : TAX
    
    LDA $A701, X : ADD $06 : ADD.w #$0008 : STA $00
    
    LDA $A703, X : ADD $08 : STA $02
    
    PLY
    
    SEP #$30
    
    JSR Tagalong_SetOam_XY
    
    LDA.b #$22 : STA ($90), Y
    
    INY
    
    LDA $04 : ASL A : ADD $04 : TAX
    
    LDA $A6CE, X : STA $0AEA
    
    LDA $A6CF, X : AND.b #$0F : ASL #4 : ORA $72 : ORA $65 : STA ($90), Y
    
    INY : TYA : SUB.b #$04 : LSR #2 : TAY
    
    LDA.b #$02 : ORA $75 : STA ($92), Y
    
    PLY : PLX
    
    RTS
}

; ==============================================================================

    ; *$4ABF9-$4AC25 LOCAL
    Tagalong_SetOam_XY:
    {
        REP #$20
        
        LDA $02 : STA ($90), Y
        
        INY
        
        ADD.w #$0080 : CMP.w #$0180 : BCS .off_screen_x
        
        LDA $02 : AND.w #$0100 : STA $74
        
        LDA $00 : STA ($90), Y
        
        ADD.w #$0010 : CMP.w #$0100 : BCC .on_screen
    
    .off_screen_x
    
        LDA.w #$00F0 : STA ($90), Y
    
    .on_screen
    
        SEP #$20
        
        INY
        
        RTS
    }

; ==============================================================================

    ; *$4AC26-$4AC6A LOCAL
    Tagalong_CheckTextTriggerProximity:
    {
        REP #$20
        
        LDA $00 : ADD $0A : ADD.w #$0008 : STA $00
        
        LDA $02 : ADD.w #$0008 : STA $02
        
        LDA $20 : ADD.w #$000C : SUB $00 : BPL .positive_delta_y
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_y
    
        CMP.w #$001C : BCS .not_in_trigger
        
        LDA $22 : ADD.w #$000C : SUB $02 : BPL .positive_delta_x
        
        EOR.w #$FFFF : INC A
    
    .positive_delta_x
    
        CMP.w #$0018 : BCS .not_in_trigger
        
        SEP #$20
        
        SEC
        
        RTS
    
    .not_in_trigger
    
        SEP #$20
        
        CLC
        
        RTS
    }

; ==============================================================================
