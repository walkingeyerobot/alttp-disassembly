
; ==============================================================================

    ; *$38000-$38020 LONG
    Player_Main:
    {
        PHB : PHK : PLB
        
        REP #$20
        
        ; Mirror Link's coordinate variables
        LDA $22 : STA $0FC2
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        STZ $0FC1
        
        ; By frozen we generally mean he's not being allowed to move due to some kind of
        ; cinema scene or something similar
        LDA $02E4 : BNE .linkFrozen
        
        JSR $807F ; $3807F IN ROM
    
    .linkFrozen
    
        JSR $8689 ; $38689 IN ROM
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; \unused Much like the Ancilla version of this routine, seems like
    ; ambient sfx gets no love.
    ; *$38021-$38027 LOCAL
    Player_DoSfx1:
    {
        JSR Player_SetSfxPan : STA $012D
        
        RTS
    }

; ==============================================================================

    ; *$38028-$3802E LOCAL
    Player_DoSfx2:
    {
        JSR Player_SetSfxPan : STA $012E
        
        RTS
    }

; ==============================================================================

    ; *$3802F-$38035 LOCAL
    Player_DoSfx3:
    {
        JSR Player_SetSfxPan : STA $012F
        
        RTS
    }

; ==============================================================================

    ; *$38036-$38040 LOCAL
    Player_SetSfxPan:
    {
        STA $0CF8
        
        ; A will be 0x0, 0x80, or 0x40. (ORed with this address, too.)
        JSL Sound_SetSfxPanWithPlayerCoords : ORA $0CF8
        
        RTS
    }

; ==============================================================================

    ; $38041-$3807E JUMP TABLE
    {
        ; Indexed by $5D.
        
        dw $8109 ; = $38109* 0x00 - Ground state (normal mode)
        dw $92D3 ; = $392D3* 0x01 - Falling into a hole or getting close to edge of hole
        dw $86B5 ; = $386B5* 0x02 - Recoil from hitting a wall (other such movement)
        dw $A804 ; = $3A804* 0x03 - Spin Attack Mode
        dw $963B ; = $3963B* 0x04 - Swimming Mode
        dw $8872 ; = $38872* 0x05 - Turtle Rock Platforms
        dw $86B5 ; = $386B5* 0x06 - recoil mode 2
        dw Player_Electrocution ; 0x07 - Electrocution Mode
        
        dw $A50F ; = $3A50F* 0x08 - Ether Medallion Mode
        dw $A5F7 ; = $3A5F7* 0x09 - Bombos Medallion Mode
        dw $A6D6 ; = $3A6D6* 0x0A - Quake Medallion Mode
        dw $894E ; = $3894E* 0x0B - Falling into hole by jumping off a ledge
        dw $8B74 ; = $38B74* 0x0C - Falling to the left/right off a ledge
        dw $8DC6 ; = $38DC6* 0x0D - Jumping off a ledge diagonally up and left/right
        dw $8E15 ; = $38E15* 0x0E - Jumping off a ledge diagonally down and left/right
        dw $8C69 ; = $38C69* 0x0F - More jumping off a ledge but with dashing maybe + some directions
        
        dw $8C69 ; = $38C69* 0x10 - Same as 0x0F?
        dw $8F86 ; = $38F86* 0x11 - Falling off a ledge / Dashing
        dw $915E ; = $3915E* 0x12 - Coming out of dash due to button press in the direction we're not going
        dw $AB7C ; - $3AB7C* 0x13 - Hookshot
        dw $A9B1 ; = $3A9B1* 0x14 - Magic Mirror
        dw $99AC ; = $399AC* 0x15 - Holding up an item (RTS)
        dw $9A5A ; = $39A5A* 0x16 - Asleep in bed
        dw $83A1 ; = $383A1* 0x17 - Permabunny mode
        
        dw $8481 ; = $38481*  ; 0x18 - stuck under heavy lifted object
        dw Player_EtherSpell  ; 0x19 - Receiving Ether Medallion Mode
        dw Player_BombosSpell ; 0x1A - Receiving Bombos Medallion Mode
        dw $867B ; = $3867B* 0x1B - Opening Desert Palace Mode
        dw $8365 ; = $38365* 0x1C - Temp bunny mode
        dw $B416 ; = $3B416* 0x1D - Rolling back from Gargoyle gate or PullForRupees
        dw $A804 ; = $3A804* 0x1E - Spin attack mode 2
    }

    ; *$3807F-$38108 LOCAL
    {
        ; Is Link being damaged?
        LDA $0373 : BEQ .linkNotDamaged
        
        ; Is Link in cape mode?
        LDA $55 : BEQ .capeNotActivated
        
        STZ $0373   ; Nullify any Damage Link will receive, since he's in cape mode.
        STZ $4D 
        STZ $46     ; Link can receive movement input.
        
        BRA .linkNotDamaged
    
    .capeNotActivated
    
        ; Can Link interact with sprites (no, if the Cane of Byrna is being used.)
        LDA $037B : BNE .linkNotDamaged
        
        ; Otherwise, tell me how much damage it will be.
        LDA $0373 : STA $00
        
        STZ $0373
        
        ; Is the boomerang effect going on?
        LDA $0C4A : CMP.b #$05 : BEQ .delta
        
        ; Are we being electrocuted?
        LDA $0300 : BEQ .delta
        
        ; Is there any delay left in the electrocution step?
        LDA $3D : BEQ .delta
        
        ; Kill that boomerang effect.
        STZ $0C4A
        
        ; No idea...
        STZ $035F
    
    .delta
    
        LDA $031F : BNE .blinkingFromDamage
        
        LDA.b #$3A : STA $031F
    
    .blinkingFromDamage
    
        ; Selects the "Link has been hurt" sound.
        LDA.b #$26 : JSR Player_DoSfx2
        
        INC $0CFC
        
        ; Link's health variable. Each full heart = #$08.
        LDA $7EF36D
        
        ; This is damage from enemies/ weapons. Not falls.
        ; Subtract however much damage from Link.
        ; If Link's health drops to zero, then he dies
        SUB $00 : CMP.b #$00 : BEQ .linkIsDead
        
        ; The equivalent of (A * 2 * 8) + 8 => 168 life points => 20 hearts plus another heart.
        ; If health is >= 21 hearts, Link dies. Wonderful.
        CMP.b #$A8 : BCC .linkNotDead
    
    .linkIsDead
    
        LDA $1C : STA $7EC211
        LDA $1D : STA $7EC212
        
        ; Save the current mode so that the game knows what mode to go to after you've died
        LDA $10 : STA $010C
        
        ; Enter death mode.
        LDA.b #$12 : STA $10
        
        ; And in death mode, go to the second submodule.
        LDA.b #$01 : STA $11
        
        ; Disable heart filling
        LDA.b #$00 : STA $031F : STA $7EF372
    
    .linkNotDead
    
        ; Change Link's health accordingly
        STA $7EF36D
    
    .linkNotDamaged
    
        ; Is Link in the ground state?
        LDA $5D : BEQ .inGroundState
        
        JSR $AE8F ; $3AE8F IN ROM
    
    .inGroundState
    
        ; Link's main handling variable. This determines his actions.
        LDA $5D : ASL A : TAX
        
        JMP ($8041, X) ; (38041, X) THAT IS
    }

; *$38109-$38364 JUMP LOCATION
{
    JSR $F514 ; $3F514 IN ROM
    
    LDA $F5 : AND.b #$80 : BEQ .notDebugWallWalk
    
    ; \tcrf(confirmed, submitted) Debug feature where if you pressed the 
    ; second control pad's B button It lets you walk through all walls.
    LDA $037F : EOR.b #$01 : STA $037F

.notDebugWallWalk

    ; $382DA IN ROM; Checks whether Link can move.
    ; C clear = Link can move. C set = opposite.
    JSR $82DA : BCC .linkCanMove
    
    ; Link can't move... is Link in the Temp Bunny mode?
    ; No... so do nothing extra.
    LDA $5D : CMP.b #$17 : BNE .notTempBunnyCantMove
    
    ; How to handle a permabunny.
    BRL BRANCH_$383A1

.notTempBunnyCantMove

    RTS

.linkCanMove

    STZ $02CA
    
    ; Is Link in a ground state? Yes...
    LDA $4D : BEQ BRANCH_DELTA

; *$38130 ALTERNATE ENTRY POINT

    STZ $0301 ; Link is in some other submode.
    STZ $037A
    STZ $020B
    STZ $0350
    STZ $030D
    STZ $030E
    STZ $030A
    
    STZ $3B
    
    ; Ignore calls to the Y button in these submodes.
    LDA $3A : AND.b #$BF : STA $3A
    
    STZ $0308
    STZ $0309
    STZ $0376
    
    STZ $48
    
    JSL Player_ResetSwimState
    
    LDA $50 : AND.b #$FE : STA $50
    
    STZ $25
    
    LDA $0360 : BEQ BRANCH_EPSILON
    
    ; Is Link in cape mode?
    LDA $55 : BEQ BRANCH_ZETA
    
    JSR $AE54 ; $3AE54 IN ROM; Link's in cape mode.

BRANCH_ZETA:

    JSR $9D84 ; $39D84 IN ROM
    
    LDA.b #$01 : STA $037B
    
    STZ $0300
    
    LDA.b #$02 : STA $3D
    
    STZ $2E
    
    LDA $67 : AND.b #$F0 : STA $67
    
    LDA.b #$2B : JSR Player_DoSfx3
    
    ; Link got hit with the Agahnim bug zapper
    LDA.b #$07 : STA $5D
    
    ; GO TO ELECTROCUTION MODE
    BRL Player_Electrocution

BRANCH_EPSILON:

    ; Checking for indoors, but really \optimize Because it's doing nothing
    ; with this information. (Take out the branch)
    LDA $1B : BNE .zero_length_branch

    ; It is a secret to everybody.

.zero_length_branch

    STZ $6B
    
    LDA.b #$02 : STA $5D
    
    BRL BRANCH_$386B5 ; go to recoil mode.

; Pretty much normal mode. Link standing there, ready to do stuff.
BRANCH_DELTA:

    LDA.b #$FF : STA $24
                 STA $25
                 STA $29
    
    STZ $02C6
    
    ; $3B5D6 IN ROM ; If Carry is set on Return, don't read the buttons.
    JSR $B5D6 : BCS BRANCH_IOTA
    
    JSR $9BAA ; $39BAA IN ROM
    
    LDA $0308 : ORA $0376 : BNE BRANCH_IOTA
    
    LDA $0377 : BNE BRANCH_IOTA
    
    ; Is Link falling off of a ledge?    ; Yes...
    LDA $5D : CMP.b #$11 : BEQ BRANCH_IOTA
    
    JSR $9B0E ; $39B0E IN ROM ; Handle Y button items?
    
    ; \hardcoded This is pretty unfair.
    ; \item Relates to ability to use the sword if you have one.
    LDA $7EF3C5 : BEQ .cant_use_sword
    
    JSR Player_Sword
    
    ; Is Link in spin attack mode?  No...
    LDA $5D : CMP.b #$03 : BNE BRANCH_IOTA
    
    STZ $30
    STZ $31
    
    BRL BRANCH_$382D2

.cant_use_sword
BRANCH_IOTA:

    JSR $AE88 ; $3AE88 IN ROM
    
    LDA $46 : BEQ BRANCH_KAPPA
    
    LDA $6B : BEQ BRANCH_LAMBDA
    
    STZ $6B

BRANCH_LAMBDA:

    STZ $030D
    STZ $030E
    STZ $030A
    STZ $3B
    STZ $0309
    STZ $0308
    STZ $0376
    
    LDA $3A : AND.b #$80 : BNE BRANCH_MU
    
    LDA $50 : AND.b #$FE : STA $50

BRANCH_MU:

    BRL BRANCH_$38711

BRANCH_KAPPA:

    LDA $0377 : BEQ BRANCH_NU
    
    STZ $67
    
    BRA BRANCH_OMICRON

BRANCH_NU:

    LDA $02E1 : BNE BRANCH_OMICRON
    
    LDA $0376 : AND.b #$FD : BNE BRANCH_OMICRON
    
    LDA $0308 : AND.b #$7F : BNE BRANCH_OMICRON
    
    LDA $0308 : AND.b #$80 : BEQ BRANCH_PI
    
    LDA $0309 : AND.b #$01 : BNE BRANCH_OMICRON

BRANCH_PI:

    LDA $0301 : BNE BRANCH_OMICRON
    
    LDA $037A : BNE BRANCH_OMICRON
    
    LDA $3C : CMP.b #$09 : BCC BRANCH_RHO
    
    LDA $3A : AND.b #$20 : BNE BRANCH_RHO
    
    LDA $3A : AND.b #$80 : BEQ BRANCH_RHO

BRANCH_OMICRON:

    BRA BRANCH_PHI

BRANCH_RHO:

    LDA $034A : BEQ BRANCH_TAU
    
    LDA.b #$01 : STA $0335 : STA $0337
    LDA.b #$80 : STA $0334 : STA $0336
    
    BRL BRANCH_$39715

BRANCH_TAU:

    JSR Player_ResetSwimCollision
    
    LDA $49 : AND.b #$0F : BNE BRANCH_UPSILON
    
    LDA $0376 : AND.b #$02 : BNE BRANCH_PHI
    
    ; Branch if there are any directional buttons down.
    LDA $F0 : AND.b #$0F : BNE BRANCH_UPSILON
    
    STA $30 : STA $31 : STA $67 : STA $26
    
    STZ $2E
    
    LDA $48 : AND.b #$F0 : STA $48
    
    LDX.b #$20 : STX $0371
    
    ; Ledge countdown timer resets here because of lack of directional input...
    LDX.b #$13 : STX $0375
    
    BRA BRANCH_PHI

BRANCH_UPSILON:

    ; Store the directional data at $67. Is it equal to the previous reading?
    ; Yes, so branch.
    STA $67 : CMP $26 : BEQ BRANCH_CHI
    
    ; If the reading changed, we have to do all this.
    STZ $2A
    STZ $2B
    STZ $6B
    STZ $48
    
    LDX.b #$20 : STX $0371
    
    ; Reset ledge timer here because direction of ... (automated?) player
    ; changed?
    LDX.b #$13 : STX $0375

BRANCH_CHI:

    STA $26

BRANCH_PHI:

    JSR $B64F   ; $3B64F IN ROM
    JSL $07E245 ; $3E245 IN ROM
    JSR $B7C7   ; $3B7C7 IN ROM; Has to do with opening chests.
    JSL $07E6A6 ; $3E6A6 IN ROM
    
    LDA $0377 : BEQ BRANCH_PSI
    
    STZ $30
    STZ $31

; *$382D2 LONG BRANCH LOCATION
BRANCH_PSI:

    STZ $0302
    
    JSR $E8F0 ; $3E8F0 IN ROM

BRANCH_OMEGA:

    CLC
    
    RTS
}

    ; *$382DA ALTERNATE ENTRY POINT
    {
        ; Has the tempbunny timer counted down yet?
        LDA $03F5 : ORA $03F6 : BEQ routineabove_return
        
        ; Check if Link first needs to be transformed.
        LDA $03F7 : BNE .doTransformation
        
        ; Is Link a permabunny or tempbunny?
        LDA $5D
        
        CMP.b #$17 : BEQ .inBunnyForm
        CMP.b #$1C : BEQ .inBunnyForm
        
        LDA $0309 : AND.b #$02 : BEQ .notLiftingAnything
        
        STZ $0308
    
    .notLiftingAnything
    
        LDA $0308 : AND.b #$80 : PHA
        
        JSL Player_ResetState
        
        PLA : STA $0308
        
        LDX.b #$04
    
    .nextObjectSlot
    
        LDA $0C4A, X
        
        CMP.b #$30 : BEQ .killByrnaObject
        CMP.b #$31 : BNE .notByrnaObject
    
    .killByrnaObject
    
        STZ $0C4A, X
    
    .notByrnaObject
    
        DEX : BPL .nextObjectSlot
        
        JSR Player_HaltDashAttack
        
        LDY.b #$04
        LDA.b #$23
        
        ; $4912C IN ROM
        JSL AddTransformationCloud
        
        LDA.b #$14 : JSR Player_DoSfx2
        
        ; It will take 20 frames for the transformation to finish
        LDA.b #$14 : STA $02E2
        
        ; Indicate that a transformation is in progress by way of flags
        LDA.b #$01 : STA $037B : STA $03F7
        
        ; Make Link invisible during the transformation
        LDA.b #$0C : STA $4B
    
    .doTransformation
    
        ; $02E2 is a timer that counts down when Link changes shape.
        DEC $02E2 : BPL .return
        
        ; Turn Link into a temporary bunny
        LDA.b #$1C : STA $5D
        
        ; Change Link's graphics to the bunny set
        LDA.b #$01 : STA $02E0 : STA $56
        
        JSL LoadGearPalettes.bunny
        
        STZ $4B
        STZ $037B
        
        ; Link no longer has to be changed into a bunny.
        STZ $03F7

        BRA .return
    
    .inBunnyForm
    
        ; Set the bunny timer to zero.
        STZ $03F5
        STZ $03F6
        
        ; Link can move.
        CLC
        
        RTS
    
    .return
    
        ; Link can't move.
        SEC
        
        RTS
    }

    ; *$38365-$38480 JUMP LOCATION
    {
        ; This is the tempbunny submodule.
        
        ; Check the bunny timer.
        LDA $03F5 : ORA $03F6 : BNE BRANCH_ALPHA ; If it is not zero, branch.
        
        LDY.b #$04 ; If time is up, then...
        LDA.b #$23
        
        JSL AddTransformationCloud
        
        LDA.b #$15 : JSR Player_DoSfx2
        
        LDA.b #$20 : STA $02E2
        
        LDA.b #$00 : STA $5D
        
        JSL $07F1FA ; $3F1FA IN ROM. Reinstates your abilities.
        
        STZ $03F7
        STZ $56
        STZ $02E0
        
        JSL LoadActualGearPalettes
        
        STZ $03F7
        
        BRL BRANCH_$38109 ; Return to normal mode.
        
        RTS
    
    BRANCH_ALPHA:
    
        REP #$20
        
        DEC $03F5 ; To access the 16-bit timer, we 16-bit registers
        
        SEP #$20
    
    ; *$383A1 LONG BRANCH LOCATION. Jump here directly to handle a permabunny.
    
        JSR $F514 ; $3F514 IN ROM
        
        LDA $F5 : AND.b #$80 : BEQ BRANCH_BETA
        
        ; If the number is odd, change it to the closest lower even number.
        LDA $037F : EOR.b #$01 : STA $037F
    
    BRANCH_BETA:
    
        STZ $02CA
        
        LDA $0345 : BNE BRANCH_GAMMA
        
        LDA $4D : BEQ BRANCH_DELTA
        
        LDA $7EF357 : BEQ BRANCH_GAMMA
        
        STZ $02E0
    
    ; *$383C7 LONG BRANCH LOCATION
    BRANCH_GAMMA:
    
        STZ $03F7
        STZ $03F5
        STZ $03F6
        
        LDA $7EF357 : BEQ BRANCH_EPSILON
        
        STZ $56
        STZ $4D
    
    BRANCH_EPSILON:
    
        STZ $2E
        STZ $02E1
        STZ $50
        
        JSL Player_ResetSwimState
        
        ; Link hit a wall or an enemy hit him, making him go backwards.
        LDA.b #$02 : STA $5D
        
        LDA $7EF357 : BEQ BRANCH_ZETA
        
        LDA.b #$00 : STA $5D
        
        JSL LoadActualGearPalettes
    
    BRANCH_ZETA:
    
        BRL BRANCH_NU
    
    BRANCH_DELTA:
    
        LDA $46 : BEQ BRANCH_THETA
        
        BRL BRANCH_$383A1 ; Permabunny mode.
    
    BRANCH_THETA:
    
        LDA.b #$FF : STA $24 : STA $25 : STA $29
        
        STZ $02C6
        
        LDA $034A : BEQ BRANCH_IOTA
        
        LDA.b #$01 : STA $0335 : STA $0337
        
        LDA.b #$80 : STA $0334 : STA $0336
        
        BRL BRANCH_$39715
    
    BRANCH_IOTA:
    
        JSR Player_ResetSwimCollision
        JSR $9B0E ; $39B0E IN ROM
        
        LDA $49 : AND.b #$0F : BNE BRANCH_KAPPA
        
        LDA $F0 : AND.b #$0F : BNE BRANCH_KAPPA
        
        STA $30 : STA $31 : STA $67 : STA $26
        
        STZ $2E
        
        LDA $48 : AND.b #$F6 : STA $48
        
        LDX.b #$20 : STX $0371
        
        ; Ledge timer is reset here the same way as for normal link (unbunny).
        LDX.b #$13 : STX $0375
        
        BRA BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        STA $67 : CMP $26 : BEQ BRANCH_MU
        
        STZ $2A
        STZ $2B
        STZ $6B
        STZ $4B
        
        LDX.b #$20 : STX $0371
        
        ; Ledge timer is reset here the same way as for normal link (unbunny).
        LDX.b #$13 : STX $0375
    
    BRANCH_MU:
    
        STA $26
    
    BRANCH_LAMBDA:
    
        JSR $B64F   ; $3B64F IN ROM
        JSL $07E245 ; $3E245 IN ROM
        JSR $B7C7   ; $3B7C7 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        STZ $0302
        
        JSR $E8F0   ; $3E8F0 IN ROM
    
    BRANCH_NU:
    
        RTS
    }

    ; *$38481-$38559 JUMP LOCATION
    {
        ; Mode 0x18 - stuck under heavy lifted object
        
        LDA $4D : BEQ BRANCH_ALPHA
        
        STZ $0301
        STZ $037A
        STZ $020B
        STZ $0350
        STZ $030D
        STZ $030E
        STZ $030A
        STZ $3B
        STZ $0308
        STZ $0309
        STZ $0376
        STZ $48
        
        LDA $50 : AND.b #$FE : STA $50
        
        STZ $25
        
        LDA $0360 : BEQ BRANCH_BETA
        
        JSR $9D84 ; $39D84 IN ROM
        
        LDA.b #$01 : STA $037B
        
        STZ $0300
        
        LDA.b #$02 : STA $3D
        
        STZ $2E
        
        LDA $67 : AND.b #$F0 : STA $67
        
        LDA.b #$2B : JSR Player_DoSfx3
        
        LDA.b #$07 : STA $5D
        
        BRL Player_Electrocution
    
    BRANCH_BETA:
    
        LDA.b #$02 : STA $5D
        
        BRL BRANCH_$386B5   ; GO TO RECOIL MODE
    
    BRANCH_ALPHA:
    
        LDA.b #$FF : STA $24
                     STA $25
                     STA $29
        
        STZ $02C6
        
        LDA $46 : BEQ BRANCH_GAMMA
        
        STZ $030D
        STZ $030E
        STZ $030A
        STZ $3B
        STZ $0308
        STZ $0309
        STZ $0376
        
        LDA $3A : AND.b #$80 : BNE BRANCH_DELTA
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_DELTA:
    
        BRL BRANCH_$38711
    
    BRANCH_GAMMA:
    
        JSR $9BAA ; $39BAA
        
        LDA $50 : AND.b #$0F : BNE BRANCH_EPSILON
        
        STA $30 : STA $31 : STA $67 : STA $26
        
        STZ $2E
        
        LDA $48 : AND.b #$F6 : STA $48
        
        LDX.b #$20 : STX $0371
        LDX.b #$13 : STX $0375
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        STA $67 : CMP $26 : BEQ BRANCH_THETA
        
        STZ $2A
        STZ $2B
        STZ $6B
        STZ $48
        
        LDX.b #$20 : STX $0371
        
        LDX.b #$13 : STX $0375
    
    BRANCH_THETA:
    
        STA $26
    
    BRANCH_ZETA:
    
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        STZ $0302
        
        JSR $E8F0 ; $3E8F0 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *3855A-$3856F LONG
    Player_InitiateFirstEtherSpell:
    {
        REP #$20
        
        LDA.w #$00C0 : STA $3C
        
        SEP #$20
        
        LDA.b #$19 : STA $5D
        
        LDA.b #$01 : STA $037B : STA $0FFC
        
        RTL
    }

; ==============================================================================

    ; *$38570-$3858D JUMP LOCATION
    Player_EtherSpell:
    {
        STZ $4D
        STZ $46
        STZ $0373
        
        REP #$20
        
        DEC $3C : LDA $3C : BMI BRANCH_ALPHA
                            BEQ BRANCH_BETA
        CMP.w #$00A0      : BEQ BRANCH_GAMMA
        CMP.w #$00BF      : BEQ BRANCH_DELTA
        
        SEP #$20
        
        RTS
    
    BRANCH_ALPHA:
    
        SEP #$20
        STZ $3C
        STZ $3D
        
        RTS
    
    BRANCH_DELTA:
    
        SEP #$20
        
        LDA.b #$01 : STA $03EF
        
        RTS
    
    BRANCH_BETA:
    
        SEP #$20
        
        LDX.b #$00
        LDY.b #$04
        LDA.b #$29
        
        JSL AddPendantOrCrystal
        
        LDA.b #$01 : STA $02E4
        
        STZ $0FFC
        
        RTS
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        LDA $20 : PHA
        LDA $21 : PHA
        LDA $22 : PHA
        LDA $23 : PHA
        
        LDA.b #$37 : STA $20
        LDA.b #$00 : STA $21
        LDA.b #$B0 : STA $22
        LDA.b #$06 : STA $23
        
        LDY.b #$00
        LDA.b #$18
        
        JSL AddEtherSpell
        
        PLA : STA $23
        PLA : STA $22
        PLA : STA $21
        PLA : STA $20
        
        RTS
    }

; ==============================================================================

    ; *$385E5-$385FA LONG
    Player_InitiateFirstBombosSpell:
    {
        REP #$20
        
        LDA.w #$00E0 : STA $3C
        
        SEP #$20
        
        ; Link is receiving Bombos medallion
        LDA.b #$1A : STA $5D
        
        LDA.b #$01 : STA $037B : STA $0112
        
        RTL
    }

; ==============================================================================

    ; *$385FB-$3866C JUMP LOCATION
    Player_BombosSpell:
    {
        STZ $4D
        STZ $46
        STZ $0373
        
        REP #$20
        
        DEC $3C : LDA $3C : BMI BRANCH_ALPHA : BEQ BRANCH_BETA
        
        CMP.w #$00A0 : BEQ BRANCH_GAMMA
        CMP.w #$00DF : BEQ BRANCH_DELTA
        
        SEP #$20
        
        RTS
    
    BRANCH_DELTA:
    
        SEP #$20
        
        LDA.b #$01 : STA $03EF
        
        RTS
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        STZ $3C
        STZ $3D
        
        RTS
    
    BRANCH_BETA:
    
        SEP #$20
        
        LDY.b #$04
        LDX.b #$05
        LDA.b #$29
        
        JSL AddPendantOrCrystal
        
        LDA.b #$01 : STA $02E4
        
        RTS
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        LDA $20 : PHA
        LDA $21 : PHA
        LDA $22 : PHA
        LDA $23 : PHA
        
        LDA.b #$B0 : STA $20
        LDA.b #$0E : STA $21
        LDA.b #$78 : STA $22
        LDA.b #$03 : STA $23
        
        LDY.b #$00
        LDA.b #$19
        
        JSL AddBombosSpell
        
        PLA : STA $23
        PLA : STA $22
        PLA : STA $21
        PLA : STA $20
        
        RTS
    }

    ; *$3866D-$3867A LONG
    {
        ; Enters the desert palace opening mode
        REP #$20
        
        LDA.w #$0001 : STA $3C
        
        SEP #$20
        
        LDA.b #$1B : STA $5D
        
        RTL
    }

    ; *$3867B-$38688 JUMP LOCATION
    {
        DEC $3C : LDA $3C : BNE .waitForSpinAttack
        
        LDA.b #$00 : STA $5D
        
        JSR $AA6C ; $3AA6C IN ROM
    
    .waitForSpinAttack
    
        RTS
    }

    ; *$38689-$386B4 LOCAL
    {
        ; Are we in a dungeon?
        LDA $1B : BNE .indoors
        
        LDA $03E9 : BEQ .no_gravestones_active
        
        LDX.b #$04
    
    .next_ancilla
    
        LDA $0C4A, X : CMP.b #$24 : BNE .not_gravestone
        
        JSL Gravestone_Move
    
    .not_gravestone
    
        DEX : BPL .next_ancilla
    
    .indoors
    .no_gravestones_active
    
        LDX.b #$04
    
    .next_ancilla_2
    
        LDA $0C4A, X : CMP.b #$2C : BNE .not_somarian_block
        
        JSL SomarianBlock_PlayerInteraction
        
        BRA .return
    
    .not_somarian_block
    
        DEX : BPL .next_ancilla_2
    
    .return
    
        RTS
    }

; *$386B5-$38871 LONG BRANCH LOCATION
{
    ; RECOIL MODE (2 and 6 are both recoil mode)

    LDA $20 : STA $3E
    LDA $21 : STA $40

; *$386BD ALTERNATE ENTRY POINT

    LDA $22 : STA $3F
    LDA $23 : STA $41
    
    JSR $8926 ; $38926 IN ROM
    
    STZ $50
    STZ $0351
    
    LDA $24 : BPL BRANCH_ALPHA
    
    LDA $29 : BPL BRANCH_ALPHA
    
    LDY.b #$05
    
    JSR $D077 ; $3D077 IN ROM
    
    LDA $0341 : AND.b #$01 : BEQ BRANCH_BETA
    
    ; Put Link into Swimming mode
    LDA.b #$04 : STA $5D
    
    JSR $8C44 ; $38C44 IN ROM
    JSR $9D84 ; $39D84 IN ROM
    
    LDA.b #$15
    LDY.b #$00
    
    JSL AddTransitionSplash ; $498FC IN ROM
    
    BRL BRANCH_BETA

BRANCH_BETA:

    INC $02C6 : LDA $02C6 : CMP.b #$04 : BEQ BRANCH_GAMMA
    
    TAX
    
    LDA $02C7

BRANCH_DELTA:

    LSR A
    
    DEX : BEQ BRANCH_DELTA
    
    STA $29 : BNE BRANCH_ALPHA

BRANCH_GAMMA:

    LDA.b #$03 : STA $02C6

; *$38711 ALTERNATIVE ENTRY POINT
BRANCH_ALPHA:

    STZ $68
    STZ $69
    STZ $6A
    
    JSR $E1BE ; $3E1BE IN ROM
    
    DEC $46 : LDA $46 : BEQ BRANCH_EPSILON

BRANCH_IOTA:

    BRL BRANCH_ZETA

BRANCH_EPSILON:

    INC A : STA $46
    
    LDA $24 : AND.b #$FE : BEQ BRANCH_THETA : BPL BRANCH_IOTA

BRANCH_THETA:

    LDA $29 : BPL BRANCH_IOTA
    
    LDA $4D : BNE BRANCH_KAPPA
    
    BRL BRANCH_LAMBDA

BRANCH_KAPPA:

    STZ $037B
    
    LDA $5D : STA $72
    
    LDA $5D : CMP.b #$06 : BEQ BRANCH_MU
    
    STZ $3C
    STZ $3A
    STZ $3D
    STZ $79

BRANCH_MU:

    JSR $8F1D   ; $38F1D IN ROM
    
    LDA $02E0 : BEQ BRANCH_NU
    
    LDA $0345 : BEQ BRANCH_NU
    
    BRL BRANCH_XI

BRANCH_NU:

    LDA $02F8 : BEQ BRANCH_OMICRON
    
    STZ $02F8
    
    BRA BRANCH_PI

BRANCH_OMICRON:

    LDA $72 : CMP.b #$02 : BEQ BRANCH_RHO
    
    LDA $5D : CMP.b #$04 : BEQ BRANCH_RHO

BRANCH_PI:

    LDA.b #$21 : JSR Player_DoSfx2

BRANCH_RHO:

    LDY $5D : CPY.b #$04 : BNE BRANCH_SIGMA
    
    JSR $AE54 ; $3AE54 IN ROM
    
    LDA $1B : BEQ BRANCH_TAU
    
    LDA $72 : CMP.b #$02 : BEQ BRANCH_TAU
    
    LDA $7EF356 : BEQ BRANCH_TAU
    
    LDA.b #$01 : STA $EE

BRANCH_TAU:
    
    LDA.b #$15
    LDY.b #$00
    
    JSL AddTransitionSplash ; $498FC IN ROM

BRANCH_SIGMA:

    LDY.b #$00
    
    JSR $D077 ; $3D077 IN ROM
    
    LDA $0357 : AND.b #$01 : BEQ BRANCH_UPSILON
    
    ; Make grass swishy sound effect
    LDA.b #$1A : JSR Player_DoSfx2

BRANCH_UPSILON:

    LDA $0359 : AND.b #$01 : BEQ BRANCH_PHI
    
    LDA $012E : CMP.b #$24 : BEQ BRANCH_PHI
    
    LDA.b #$1C : JSR Player_DoSfx2

BRANCH_PHI:

    LDA $0341 : AND.b #$01 : BEQ BRANCH_BETA
    
    LDA.b #$04 : STA $5D
    
    JSR $8C44 ; $38C44 IN ROM
    JSR $9D84 ; $39D84 IN ROM
    
    LDA.b #$15
    LDY.b #$00
    
    JSL AddTransitionSplash

BRANCH_BETA:

    LDA $EE : CMP.b #$02 : BNE BRANCH_CHI
    
    STZ $EE

BRANCH_CHI:

    LDA $047A : BEQ BRANCH_XI
    
    JSL Player_LedgeJumpInducedLayerChange

BRANCH_XI:

    STZ $24
    STZ $25
    STZ $4D
    STZ $5E
    STZ $50
    STZ $0301
    STZ $037A
    STZ $0300
    STZ $037B
    STZ $0360
    STZ $27
    STZ $28

BRANCH_LAMBDA:

    STZ $2E
    STZ $46

BRANCH_ZETA:

    LDA $5D : CMP.b #$05 : BEQ BRANCH_PSI
    
    LDA $46 : CMP.b #$21 : BCC BRANCH_PSI
    
    DEC $02C5 : BPL BRANCH_OMEGA
    
    LSR #4 : STA $02C5

BRANCH_PSI:

    JSR $92A0 ; $392A0 IN ROM
    
    LDA $5D : CMP.b #$06 : BEQ BRANCH_DIALPHA
    
    JSR $B64F ; $3B64F IN ROM
    
    LDA $67 : AND.b #$03 : BNE BRANCH_DIBETA
    
    STZ $28

BRANCH_DIBETA:

    LDA $67 : AND.b #$0C : BNE BRANCH_DIBETA
    
    STZ $27

BRANCH_DIALPHA:

    JSL $07E370 ; $3E370 IN ROM

BRANCH_OMEGA:

    LDA $5D : CMP.b #$06 : BEQ BRANCH_DIGAMMA
    
    JSR $B7C7 ; $3B7C7 IN ROM
    
    STZ $0302

BRANCH_DIGAMMA:

    JSR $E8F0 ; $3E8F0 IN ROM
    
    LDA $24    : BEQ BRANCH_DIDELTA
    CMP.b #$E0 : BCC BRANCH_DIEPSILON

BRANCH_DIDELTA:

    JSR Player_TileDetectNearby
    
    LDA $59 : AND.b #$0F : CMP.b #$0F : BNE BRANCH_DIEPSILON
    
    LDA.b #$01 : STA $5D
    LDA.b #$04 : STA $5E

BRANCH_DIEPSILON:

    STZ $25
    
    RTS
}

; *$38872-$38925 JUMP LOCATION
{
    ; MODE 5 TURTLE ROCK PLATFORMS
    
    LDA $1B : BNE BRANCH_ALPHA
    
    BRL BRANCH_NU

BRANCH_ALPHA:

    LDX.b #$00
    
    LDA $EE : BEQ BRANCH_BETA
    
    STZ $EE
    
    JSR $CF7E ; $3CF7E IN ROM
    
    LDX.b #$00
    
    LDA.b #$01 : STA $EE
    
    LDA $034C : AND.b #$03 : CMP.b #$03 : BEQ BRANCH_BETA
    
    LDX.b #$01

BRANCH_BETA:

    STX $034E

BRANCH_PI:

    DEC $3D : BPL BRANCH_GAMMA
    
    LDA.b #$03 : STA $3D
    
    LDA $0300 : EOR.b #$01 : STA $0300

BRANCH_GAMMA:

    LDA $F0 : AND.b #$0F : BNE BRANCH_DELTA
    
    ; Isn't this equivalent to STZ?
    STA $30 : STA $31 : STA $67 : STA $26
    
    STZ $2E
    
    BRA BRANCH_EPSILON

BRANCH_DELTA:

    STA $67 : CMP $26 : BEQ BRANCH_ZETA
    
    STZ $2A
    STZ $2B
    STZ $6B

BRANCH_ZETA:

    STA $26

BRANCH_EPSILON:

    LDX.b #$10
    
    LDA $67
    
    AND.b #$0F : BEQ BRANCH_THETA
    AND.b #$0C : BEQ BRANCH_IOTA
    
    LDA $67 : AND.b #$03 : BEQ BRANCH_IOTA
    
    LDX.b #$0A

BRANCH_IOTA:

    STX $00
    
    LDA $67
    
    AND.b #$0C : BEQ BRANCH_KAPPA
    AND.b #$08 : BEQ BRANCH_LAMBDA
    
    TXA : EOR.b #$FF : INC A : TAX

BRANCH_LAMBDA:

    STX $27

BRANCH_KAPPA:

    LDX $00
    
    LDA $67 : AND.b #$03 : BEQ BRANCH_THETA
    
    AND.b #$02 : BEQ BRANCH_MU
    
    TXA : EOR.b #$FF : INC A : TAX

BRANCH_MU:

    STX $28

BRANCH_THETA:

    JSL $07E6A6 ; $3E6A6 IN ROM
    
    BRL BRANCH_$386B5 ; GO TO RECOIL MODE (Revision: really recoil mode or just jumping?)
    
    LDY.b #$00

BRANCH_NU:

    JSR $D077 ; $3D077 IN ROM
    
    LDA $035B : AND.b #$01 : BEQ BRANCH_XI
    
    LDA.b #$02 : STA $EE
    
    BRA BRANCH_OMICRON

BRANCH_XI:

    STZ $00EE

BRANCH_OMICRON:

    LDA.b #$01 : STA $034E
    
    BRL BRANCH_PI
}

    ; *$38926-$3894D LOCAL
    {
        LDX.b #$02
        
        ; What mode is Link in ?; Is he on a Turtle Rock platform?
        LDA $5D : CMP.b #$05 : BNE BRANCH_ALPHA
        
        LDX.b #$01
    
    BRANCH_ALPHA:
    
        STX $00
    
    ; *$38932 ALTERNATE ETNRY POINT
    
        LDA $29 : BPL BRANCH_BETA
        
        LDA $24 : BEQ BRANCH_GAMMA : BPL BRANCH_BETA
        
        LDA.b #$FF : STA $24 : STA $25 : STA $29
        
        BRA BRANCH_GAMMA
    
    ; *$38946 ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        LDA $29 : SUB $00 : STA $29
    
    BRANCH_GAMMA:
    
        RTS
    }

    ; *$3894E-$38A04 JUMP LOCATION LOCAL
    {
        ; Link mode 0x0B - falling down ledge to water or a hole? (Is that it?)
        
        ; Last direction Link moved in was down?
        LDA.b #$01 : STA $66
        
        STZ $50
        STZ $27
        STZ $28
        STZ $0351
        
        LDA $46 : BNE BRANCH_ALPHA
        
        LDA $0362 : BNE BRANCH_ALPHA
        
        ; Play the "something's falling" sound effect
        LDA.b #$20 : JSR Player_DoSfx2
        
        JSR $8AD1 ; $38AD1 IN ROM
        
        LDA $1B : BNE .indoors
        
        LDA.b #$02 : STA $EE
    
    BRANCH_ALPHA:
    .indoors
    
        LDA $0362 : STA $29
        
        LDA $0363 : STA $02C7
        
        LDA $0364 : STA $24
        LDA $0365 : STA $25
        
        LDA.b #$02 : STA $00
        
        JSR $8946   ; $38946 IN ROM
        JSL $07E370 ; $3E370 IN ROM
        
        LDA $29 : BPL BRANCH_BETA
        
        CMP.b #$A0 : BCS BRANCH_GAMMA
        
        LDA.b #$A0 : STA $29
    
    BRANCH_GAMMA:
    
        REP #$20
        
        LDA $24 : CMP.w #$FFF0 : BCC BRANCH_BETA
        
        STZ $24
        
        SEP #$20
        
        JSR $8F1D ; $38F1D IN ROM
        
        LDA $5B : BEQ BRANCH_DELTA
        
        LDA.b #$01 : STA $5D
    
    BRANCH_DELTA:
    
        LDA $5D
        
        CMP.b #$04 : BEQ BRANCH_EPSILON
        CMP.b #$01 : BEQ BRANCH_EPSILON
        
        LDA $0345 : BNE BRANCH_EPSILON
        
        ; The sound of something hitting the ground?
        LDA.b #$21 : JSR Player_DoSfx2
    
    BRANCH_EPSILON:
    
        STZ $037B
        STZ $78
        STZ $4D
        
        LDA.b #$FF : STA $29 : STA $24 : STA $25
        
        STZ $46
        
        LDA $1B : BNE BRANCH_ZETA
        
        STZ $EE
    
    BRANCH_ZETA:
    
        BRA BRANCH_THETA
    
    BRANCH_BETA:
    
        SEP #$20
        
        LDA $0364 : SUB $24 : STA $30
        
        LDA $29   : STA $0362
        LDA $02C7 : STA $0363
        LDA $24   : STA $0364
        LDA $25   : STA $0365
        
        RTS
    }

    ; $38A05-$38AC8 LOCAL
    {
        LDA $0362 : STA $29
        LDA $0362 : STA $02C7
        LDA $0364 : STA $24
        
        LDA.b #$02 : STA $00
        
        JSR $8946 ; $38946 IN ROM
        
        JSL $07E370 ; $3E370 IN ROM
        
        LDA $29 : BMI .alpha
        
        BRL .beta
    
    .alpha
    
        CMP.b #$A0 : BCS .gamma
        
        LDA.b #$A0 : STA $A9
    
    .gamma
    
        LDA $24 : CMP.b #$F0 : BCC .beta
        
        STZ $24
        STZ $25
        
        LDA $5D
        
        CMP.b #$0C : BEQ .delta
        CMP.b #$0E : BNE .epsilon
    
    .delta
    
        LDY.b #$00
        
        JSR $D077 ; $3D077
        
        LDA $0341 : AND.b #$01 : BEQ .zeta
        
        LDA.b #$04 : STA $5D
        
        JSR $8C44 ; $38C44 in Rom.
        JSR $9D84 ; $39D84 in Rom.
        
        ; Add transition splash
        LDA.b #$15
        LDY.b #$00
        
        JSL AddTransitionSplash ; $498FC IN ROM
        
        BRA .epsilon
    
    .zeta
    
        LDA $59 : AND.b #$01 : BEQ .epsilon
        
        LDA.b #$09 : STA $5C
        
        STZ $5A
        
        LDA.b #$01 : STA $5B
        
        LDA.b #$01 : STA $5D
        
        BRA .theta
    
    .epsilon
    
        JSR $8F1D ; $38F1D in Rom.
        
        LDA $5D : CMP.b #$04 : BEQ .theta
        
        LDA $0345 : BNE .theta
        
        LDA.b #$21 : JSR Player_DoSfx2
    
    .theta
    
        LDA $5D : CMP.b #$04 : BNE .iota
        
        LDA $02E0 : BNE .kappa
    
    .iota
    
        STZ $037B
    
    .kappa
    
        STZ $78
        STZ $4D
        
        LDA.b #$FF : STA $29 : STA $24 : STA $25
        
        STZ $46
        
        LDA $1B : BNE .lambda
        
        STZ $EE
    
    .lambda
    
        BRA .mu
    
    .beta
    
        LDA $0364 : SUB $24 : STA $30
    
    .mu
    
        LDA $29 : STA $0362
        
        LDA $02C7 : STA $0363
        
        LDA $24 : STA $0364
        
        RTS
    }

    ; $38AC9-$38AD0 DATA
    {
        db -8, -1, 8, 0
        
    
    ; $38ACD
    
        db -16, -1, 16, 0
    }

    ; *$38AD1-$38B73 LOCAL
    {
        LDA $21 : STA $33
        LDA $20 : STA $32
        
        SUB $3E : STA $30
    
    BRANCH_ALPHA:
    
        LDA $66 : ASL A : TAY
        
        REP #$20
        
        LDA $8AC9, Y : ADD $20 : STA $20
        
        SEP #$20
        
        JSR $CDCB ; $3CDCB IN ROM
        
        LDA $0343 : ORA $59 : ORA $035B : ORA $0357 : ORA $0341
        
        AND.b #$07 : CMP.b #$07 : BNE BRANCH_ALPHA
        
        LDA $0341 : AND.b #$07 : BEQ BRANCH_BETA
        
        LDA.b #$01 : STA $0345
        
        LDA $4D : CMP.b #$04 : BEQ BRANCH_GAMMA
        
        LDA.b #$02 : STA $4D
    
    BRANCH_GAMMA:
    
        LDA $0026 : STA $0340
        
        JSL Player_ResetSwimState
        
        STZ $0376
        STZ $5E
    
    BRANCH_BETA:
    
        LDA $59 : AND.b #$07 : BEQ BRANCH_DELTA
        
        LDA.b #$09 : STA $5C
        
        STZ $5A
        
        LDA.b #$01 : STA $5B
    
    BRANCH_DELTA:
    
        LDA $66 : ASL A : TAY
        
        REP #$20
        
        LDA $8ACD, Y : ADD $20 : STA $20
        
        SEP #$20
        
        LDA $20 : STA $3E
        LDA $21 : STA $40
        
        LDA.b #$01 : STA $46
        
        LDA $24 : CMP.b #$F0 : BCC BRANCH_DELTA
        
        LDA.b #$00
    
    BRANCH_DELTA:
    
        STA $00
        STZ $01
        
        REP #$20
        
        LDA $20 : SUB $32 : ADD $00 : STA $0364 : STA $24
        
        SEP #$20
        
        RTS
    }

    ; *$38B74-$38B8A JUMP LOCATION
    {
        ; Link mode 0x0C - ????
        LDX.b #$01
        
        LDA $28 : BPL .alpha
        
        LDX.b #$02
    
    .alpha
    
        TXA : ORA.b #$04 : STA $67
        
        STZ $50
        STZ $27
        STZ $0351
        
        BRL BRANCH_$38A05 ; (RTS)
    }

    ; *$38B9B-$38C58 LOCAL
    {
        LDA $21 : STA $33
        LDA $20 : STA $32
        
        SUB $3E : STA $30
        
        LDA $66 : ASL A : TAY
        
        REP #$20
        
        LDA $8AC9, Y : ADD $20 : STA $20
        
        SEP #$20
        
        JSR $CDCB ; $3CDCB IN ROM
        
        LDA $0343 : ORA $035B : ORA $0357 : ORA $0341
        
        AND.b #$07 : CMP.b #$07 : BEQ BRANCH_ALPHA
        
        LDA $33 : STA $21
        LDA $32 : STA $20
        
        LDY.b #$00
        
        LDA.b #$01 : STA $46
        
        LDA $28 : BPL BRANCH_BETA
        
        LDY.b #$FF
        
        EOR.b #$FF : INC A
    
    BRANCH_BETA:
    
        LSR #4 : TAX
        
        LDA $8B8B, X : STA $0362 : STA $0363
        
        LDA $8B93, X
        
        CPY.b #$FF : BNE BRANCH_GAMMA
        
        EOR.b #$FF : INC A
    
    BRANCH_GAMMA:
    
        STA $28
        
        BRA BRANCH_DELTA
    
    BRANCH_ALPHA:

        LDA $66 : ASL A : TAY
        
        REP #$20
        
        LDA $8ACD, X : ADD $20 : STA $20
        
        SEP #$20
        
        LDA $20    : STA $3E
        LDA $21    : STA $40
        
        LDA.b #$01 : STA $46
        
        LDA $24 : CMP.b #$FF : BNE BRANCH_EPSILON
        
        LDA.b #$00
    
    BRANCH_EPSILON:
    
        STA $00
        STZ $01
        
        REP #$20
        
        LDA $20 : SUB $32 : ADD $00 : STA $0364 : STA $24
        
        SEP #$20
    
    BRANCH_DELTA:
    
        LDA $0341 : AND.b #$07 : BEQ BRANCH_ZETA
        
        LDA.b #$02 : STA $4D
    
    ; *$38C44 ALTERNATE ENTRY POINT
    
        LDA.b #$01 : STA $0345
        
        LDA $0026 : STA $0340
        
        JSL Player_ResetSwimState
        
        STZ $0376
        STZ $5E
    
    BRANCH_ZETA:
    
        RTS
    }

; *$38C69-$38CEE JUMP LOCATION
{
    ; Link modes 0x0F and 0x10 - ????
    
    LDY.b #$03
    
    LDA $28 : BPL BRANCH_ALPHA
    
    LDY.b #$02

BRANCH_ALPHA:

    STY $66
    
    STZ $50
    STZ $27
    STZ $0351
    
    LDA $46 : BNE BRANCH_BETA
    
    LDA $0362 : BNE BRANCH_BETA
    
    LDA $5D : SUB.b #$0F : ASL #2 : STA $00
    
    TYA : AND.b #$FD : ASL A : ADD $00 : TAX
    
    LDA $22 : PHA
    LDA $23 : PHA
    
    REP #$20
    
    LDA $22 : ADD $8C59, X : STA $22
    
    SEP #$20
    
    TXA : LSR #2 : TAX
    
    LDA $8C65, X
    
    CPY.b #$02 : BNE BRANCH_GAMMA
    
    EOR.b #$FF : INC A

BRANCH_GAMMA:

    STA $28
    
    LDA $24 : CMP.b #$FF : BNE BRANCH_DELTA
    
    LDA.b #$00

BRANCH_DELTA:

    ADD $8C67, X : STA $0364 : STA $24
    
    TXA : ASL A : TAX
    
    REP #$20
    
    LDA $8C61, X : ADD $20 : STA $20
    
    SEP #$20
    
    LDA $20 : STA $3E
    LDA $21 : STA $40
    
    PLA : STA $23
    PLA : STA $22
    
    LDA $1B : BNE BRANCH_BETA
    
    LDA.b #$02 : STA $EE

BRANCH_BETA:

    BRL BRANCH_$38A05 ; (RTS)
}

; *$38D2B-$38DC5 LOCAL
{
    LDA $23 : STA $33
    LDA $22 : STA $32
    
    LDX.b #$07

BRANCH_GAMMA:

    PHX
    PHY
    
    REP #$20
    
    LDA $8CEF, Y : ADD $22 : STA $22
    
    SEP #$20
    
    LDA $66 : ASL A : TAY
    
    JSR $CE2A ; $3CE2A IN ROM
    
    PLY
    PLX
    
    LDA $0343 : ORA $035B : ORA $0357 : ORA $0341 : ORA $59
    
    AND.b #$07 : CMP.b #$07 : BNE BRANCH_ALPHA
    
    LDA $0341 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_BETA
    
    LDA.b #$01 : STA $0345 : INC A : STA $4D
    
    LDA $0026 : STA $0340
    
    STZ $02CB
    STZ $5E
    STZ $0376
    
    JSR Player_ResetSwimCollision
    
    BRA BRANCH_BETA

BRANCH_ALPHA:

    DEX : BPL BRANCH_GAMMA
    
    REP #$20
    
    LDA $8CF3, Y : ADD $32 : STA $22
    
    SEP #$20

BRANCH_BETA:

    PHX
    
    REP #$20
    
    LDA $8CF7, Y : ADD $22 : STA $22
    
    LDA $32 : SUB $22 : BPL BRANCH_DELTA
    
    EOR.w #$FFFF : INC A

BRANCH_DELTA:

    LSR #3 : TAX
    
    SEP #$20
    
    LDA $8CFB, X : CPY.b #$02 : BEQ BRANCH_EPSILON
    
    EOR.b #$FF : INC A

BRANCH_EPSILON:

    STA $28
    
    LDA $8D13, X : STA $0362 : STA $0363
    
    PLX
    
    RTS
}

; *$38DC6-$38DFC JUMP LOCATION
{
    ; Link mode 0x0D - ????
    
    STZ $0315
    
    LDA.b #$02 : STA $00
    
    JSR $8932   ; $38932 IN ROM
    JSL $07E370 ; $3E370 IN ROM
    
    LDA $24 : BPL BRANCH_ALPHA
    
    JSR $8F1D ; $38F1D IN ROM
    
    LDA $5D : CMP.b #$04 : BEQ .swimming
    
    LDA $0345 : BNE BRANCH_BETA
    
    LDA.b #$21 : JSR Player_DoSfx2

BRANCH_BETA:
.swimming

    STZ $037B
    STZ $4D

    LDA.b #$FF : STA $29 : STA $24 : STA $25 : STA $46 : STA $50

BRANCH_ALPHA:

    RTS
}

; *$38E15-$38E6C JUMP LOCATION
{
    ; Link Submode 0x0E
    
    LDY.b #$03
    
    LDA $28 : BPL .horizontalRecoilPresent
    
    LDY.b #$02

.horizontalRecoilPresent

    STY $66
    
    STZ $50
    STZ $27
    STZ $0351
    
    LDA $46 : BNE .cantMove
    
    LDA $0362 : BNE BRANCH_BETA
    
    LDA.b #$01 : STA $66
    
    PHY
    
    LDA $22 : PHA
    LDA $23 : PHA
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    JSR $8E7B ; $38E7B IN ROM
    
    PLA : STA $23
    PLA : STA $22
    
    PLX
    
    REP #$20
    
    LDA $20 : SUB $32 : LSR #3 : TAY
    
    SEP #$20
    
    LDA $8DFD, Y
    
    CPX.b #$02 : BNE BRANCH_GAMMA
    
    EOR.b #$FF : INC A

BRANCH_GAMMA:

    STA $28
    
    LDA $1B : BNE .indoors
    
    LDA.b #$02 : STA $EE

.indoors
.cantMove
BRANCH_BETA:

    BRL BRANCH_$38A05 ; (RTS)
}

; *$38E7B-$38F1C LOCAL
{
    LDA $21 : STA $33
    LDA $20 : STA $32
    
    SUB $3E : STA $30

BRANCH_BETA:

    LDY.b #$00
    
    LDA $28
    
    BMI 
    
    LDY.b #$02

BRANCH_ALPHA:

    PHY
    
    REP #$20
    
    LDA $8E6D, Y : ADD $22 : STA $22
    
    LDA $66 : AND.w #$00FF : ASL A : TAY
    
    LDA $8E71, Y : ADD $20 : STA $20
    
    SEP #$20
    
    JSR $CDCB ; $3CDCB IN ROM
    
    PLY : TYA : LSR A : TAY
    
    LDA $8E79, Y : STA $72
    
    LDA $0343 : ORA $035B : ORA $0357 : ORA $0341
    
    AND $72 : CMP $72 : BNE BRANCH_BETA
    
    LDA $0341 : AND $72 : BEQ BRANCH_GAMMA
    
    LDA.b #$01 : STA $0345
    
    LDA.b #$02 : STA $45
    
    LDA $0026 : STA $0340
    
    JSL Player_ResetSwimState
    
    STZ $5E
    STZ $0376

BRANCH_GAMMA:

    LDA $66 : ASL A : TAY
    
    REP #$20
    
    LDA $8E75, Y : ADD $20 : STA $20
    
    SEP #$20
    
    LDA $20 : STA $3E
    LDA $21 : STA $40
    
    LDA.b #$01 : STA $46
    
    LDA $24 : STA $00
    
    STZ $01
    
    REP #$20
    
    LDA $20 : SUB $32 : ADD $00 : STA $0364 : STA $24
    
    SEP #$20
    
    RTS
}

    ; *$38F1D-$38F60 LOCAL
    {
        PHX : PHY
        
        LDA $02E0 : BEQ .notBunny
        
        LDA $0345 : BEQ .notSwimming
        
        LDA.b #$15
        LDY.b #$00
        
        JSL AddTransitionSplash  ; $498FC IN ROM
        
        PLY : PLX
        
        BRL BRANCH_$383C7
    
    .notSwimming
    
        LDX.b #$17
        
        ; change to permabunny b/c we don't have a moon pearl
        LDA $7EF357 : BEQ .changeLinkMode
        
        LDX.b #$1C
        
        ; otherwise assume that he's a temp bunny
        BRA .changeLinkMode
    
    .notBunny
    
        LDX.b #$00
        
        ; Not a bunny and not swimming, must be in normal mode
        LDA $0345 : BEQ .changeLinkMode
        
        ; Check if Link is recoiling from something that hit him
        LDA $5D : CMP.b #$06 : BEQ .notRecoiling
        
        LDA.b #$15
        LDY.b #$00
        
        JSL AddTransitionSplash  ; $498FC IN ROM
    
    .notRecoiling
    
        JSR $AE54 ; $3AE54 IN ROM
        
        LDX.b #$04
    
    .changeLinkMode
    
        STX $5D
        
        PLY
        PLX
        
        RTS
    }

    ; *$38F86-$39194 LONG BRANCH LOCATION
    {
        ; MODE 0x11 FALLING OFF A LEDGE / Dashing
        
        JSR $F514 ; $3F514 IN ROM ; Buffers a number of important variables
        JSR $82DA ; $382DA IN ROM ; 
        
    BCC BRANCH_ALPHA
        
        LDA $5D : CMP.b #$17 : BNE BRANCH_BETA
        
        BRL BRANCH_$383A1 ; PERMABUNNY MODE
    
    BRANCH_BETA:
    
        RTS
    
    BRANCH_ALPHA:
    
        ; Is Link dashing?
        LDA $0372 : BNE BRANCH_GAMMA
        
        STZ $037B
        STZ $0374
        STZ $5E
        
        LDA.b #$00 : STA $5D
        
        STZ $50
        
        BRL BRANCH_ULTIMA
    
    BRANCH_GAMMA:
    
        BIT $3A : BPL BRANCH_DELTA
        
        LDA $3C : CMP.b #$09 : BCC BRANCH_DELTA
        
        LDA.b #$09 : STA $3C

    BRANCH_DELTA:

        STZ $02CA
        
        ; Branch if link has no special status
        LDA $4D : BEQ BRANCH_EPSILON
        
        STZ $037B
        STZ $0374
        STZ $5E
        STZ $50
        STZ $0372
        STZ $48
        
        LDA $0360 : BEQ BRANCH_ZETA
        
        LDA $55 : BEQ BRANCH_THETA
    
        JSR $AE54 ; $3AE54 IN ROM
    
    BRANCH_THETA:
    
        JSR $9D84 ; $39D84 IN ROM
        
        LDA.b #$01 : STA $037B
        
        STZ $0300
        
        LDA.b #$02 : STA $3D
        
        STZ $2E
        
        LDA $67 : AND.b #$F0 : STA $67
        
        LDA.b #$2B : JSR Player_DoSfx3
        
        LDA.b #$07 : STA $5D
        
        BRL Player_Electrocution
    
    BRANCH_ZETA:
    
        ; go to recoil mode.
        LDA.b #$02 : STA $5D
    
        BRL BRANCH_$386BD ; GO TO RECOIL MODE. 
        ; IF YOU ASK ME, THIS SHOULD GO TO $386B5. I THINK IT WAS AN ERROR.
        ; TESTING WOULD CONFIRM THIS THOUGH.
    
    BRANCH_EPSILON:
    
        ; Check the dash countdown timer
        LDA $0374 : LSR #4 : TAX
        
        LDA $0374 : BNE BRANCH_IOTA
        
        LDA $4F : DEC $4F
    
    BRANCH_IOTA:
    
        ; $38F65, X THAT IS
        AND $8F65, X : BNE BRANCH_KAPPA
        
        LDA.b #$23 : JSR Player_DoSfx2
    
    BRANCH_KAPPA:
    
        DEC $0374 : BPL BRANCH_LAMBDA
        
        STZ $0374
        
        ; If the current tagalong is the (not used) alternate old man, change
        ; it to a Tagalong that is waiting for the player to come back (0x03).
        LDA $7EF3CC : TAX : CMP $8F68, X : BNE BRANCH_MU
        
        LDA $8F77, X : STA $7EF3CC
    
    BRANCH_MU:
    
        BRL BRANCH_SIGMA
    
    BRANCH_LAMBDA:
    
        LDA.b #$00 : STA $4F
        
        BIT $F2 : BMI BRANCH_NU
        
        STZ $2E
        STZ $0374
        STZ $5E
        
        LDA.b #$00 : STA $5D
        
        STZ $0372
        
        BIT $3A : BMI BRANCH_XI
        
        STZ $50
    
    BRANCH_XI:
    
        BRL BRANCH_ULTIMA
    
    BRANCH_NU:
    
        LDY.b #$00
        LDA.b #$1E
        
        JSL AddDashingDust.notYetMoving
        
        STZ $30
        STZ $31
        
        LDA.b #$40 : STA $02F1
        
        LDA.b #$10 : STA $5E
        
        LDA $3A : AND.b #$80 : BNE BRANCH_OMICRON
        
        LDA $6C : BNE BRANCH_OMICRON
        
        LDA $F0 : AND.b #$0F : BNE BRANCH_PI
    
    BRANCH_OMICRON:
    
        LDA $2F : LSR A : TAX
        
        LDA $8F61, X
    
    BRANCH_PI:
    
        STA $26 : STA $67 : STA $0340
        
        STZ $6B
        
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        LDA $20 : STA $00 : STA $3E
        LDA $22 : STA $01 : STA $3F
        LDA $21 : STA $02 : STA $40
        LDA $23 : STA $03 : STA $41
        
        JSR $E595 ; $3E595 IN ROM
        JSR $E5F0 ; $3E5F0 IN ROM
        
        LDA $02F5 : BEQ BRANCH_RHO
        
        JSL $07E3DD ; $3E3DD IN ROM
    
    BRANCH_RHO:
    
        LDA $20 : SUB $3E : STA $30
        LDA $22 : SUB $3F : STA $31
        
        JSR $B7C7 ; $3B7C7 IN ROM
        JSR $E8F0 ; $3E8F0 IN ROM
        
        BRL BRANCH_ULTIMA
    
    BRANCH_SIGMA:
    
        LDA $2E : CMP.b #$06 : BCC BRANCH_TAU
        
        STZ $2E
    
    BRANCH_TAU:
    
        DEC $02F1 : LDA $02F1 : CMP.b #$20 : BCS BRANCH_UPSILON
        
        LDA.b #$20 : STA $02F1
    
    BRANCH_UPSILON:
    
        LDY.b #$00
        LDA.b #$1E
        
        JSL AddDashingDust
        
        STZ $79
        
        ; LINK'S SWORD VALUE
        LDA $7EF359 : INC A : AND.b #$FE : BEQ BRANCH_PHI
        
        LDY.b #$07
        
        JSR $D077 ; $3D077 IN ROM
    
    BRANCH_PHI:
    
        LDA $7EF3C5 : BEQ BRANCH_CHI
        
        LDA.b #$80 : TSB $3A
        LDA.b #$09 : STA $3C

    BRANCH_CHI:

        STZ $46
        
        LDA $2F : LSR A : TAX
        
        LDA $8F61, X : STA $00
        
        LDA $F0 : AND.b #$0F : BEQ BRANCH_PSI
        CMP $00              : BEQ BRANCH_PSI
        
        ; Come out of the dashing submode
        LDA.b #$12 : STA $5D
        
        LDA $3A : AND.b #$7F : STA $3A
        
        STZ $3C
        STZ $3D
        
        BRL BRANCH_ALTIMA
    
    BRANCH_PSI:
    
        LDA $49 : AND.b #$0F : BNE BRANCH_OMEGA
        
        LDA $2F : LSR A : TAX
        
        LDA $8F61, X
    
    BRANCH_OMEGA:
    
        STA $67 : STA $26
        
        JSR $B64F   ; $3B64F IN ROM
        JSL $07E245 ; $3E245 IN ROM
        JSR $B7C7   ; $3B7C7 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        STZ $0302
        
        JSR $E8F0   ; $3E8F0 IN ROM
    
    BRANCH_ULTIMA:
    
        RTS
    
    ; *$3915E ALTERNATE ENTRY POINT
    BRANCH_ALTIMA:
    
        JSR $F514 ; $3F514 IN ROM
        
        LDA $F0 : AND.b #$0F : BNE BRANCH_ALPHA2
        
        LDA $0374 : CMP.b #$10 : BCC BRANCH_BETA2
    
    BRANCH_ALPHA2:
    
        STZ $0374
        STZ $5E
        
        LDA.b #$00 : STA $5D
        
        STZ $0372
        STZ $032B
        
        LDA $3C : CMP.b #$09 : BCS BRANCH_GAMMA2
        
        STZ $50
        
        BRA BRANCH_GAMMA2
    
    BRANCH_BETA2:
    
        LDA $0374 : ADD.b #$01 : STA $0374
    
    BRANCH_GAMMA2:
    
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$39195-$391B8 LOCAL
    Player_HaltDashAttack:
    {
        ; Routine essentially stops all dashing activities, usually due to some\
        ; specific cause, like getting too near to water or a sprite
        
        ; Is Link going to collide?
        LDA $0372 : BEQ .notDashing
        
        PHX
        
        LDX.b #$04
    
    .nextObjectSlot
    
        ; Is Link using the pegasus boots?
        LDA $0C4A, X : CMP.b #$1E : BNE .notPegasusBootDust
        
        STZ $0C4A, X
    
    .notPegasusBootDust
    
        DEX : BPL .nextObjectSlot
        
        PLX
        
        STZ $0374   ; reset dash timer
        STZ $5E     ; reset speed to zero
        STZ $0372   ; reset dash collision variable (means Link will bounce if he hits a wall)
        STZ $50     ; allow Link to change direction again
        STZ $032B   ; ....?
    
    .notDashing
    
        RTS
    }

; ==============================================================================

    ; *$391B9-$391BC LONG
    Player_HaltDashAttackLong:
    {
        JSR Player_HaltDashAttack
        
        RTL
    }

; ==============================================================================

    ; $391BD-$391F0
    {
    
    .y_recoil
        db $18, $E8, $00, $00
        
    .x_recoil
        db $00, $00, $18, $E8
    
    ; $391C5
    .??????
        db 1, 0, 0, 0
        
        db 0, 0, 1, 0
        
    }
    
    ; *$391F1-$39290 LOCAL
    {
        LDA $0372 : BEQ .no_dash_bounce
        
        LDA $02F1 : CMP.b #$40 : BNE .dash_hasnt_just_begun
    
    .no_dash_bounce
    
        BRL .return
    
    .dash_hasnt_just_begun
    
        JSL Player_ResetSwimState
        
        LDY.b #$01
        LDA.b #$1D
        
        JSL AddDashTremor
        JSL Player_ApplyRumbleToSprites
        
        LDA $012F : AND.b #$3F
        
        CMP.b #$1B : BEQ BRANCH_GAMMA
        CMP.b #$32 : BEQ BRANCH_GAMMA
        
        LDA.b #$03 : JSR Player_DoSfx3
    
    ; *$39222 LONG BRANCH LOCATION
    BRANCH_GAMMA:
    
        LDX $66
        
        ; recoil in the opposite direction from the dash
        LDA $91BD, X : STA $27
        
        LDA $91C1, X : STA $28
        
        LDA.b #$18 : STA $46
        
        LDA.b #$24 : STA $29 : STA $02C7
        
        LDA $034A : BEQ BRANCH_DELTA
        
        LDA $91ED, X : STA $0340 : STA $67
        
        LDA $91C5, X : STA $0338
        LDA $91C9, X : STA $033A
        
        PHX
        
        LDA $034A : DEC A : ASL #3 : STA $08
        
        TXA : ASL A : ADD $08 : TAX
        
        REP #$20
        
        LDA $91CD, X : STA $033C
        LDA $91DD, X : STA $033E
        
        SEP #$20
        
        PLX
    
    BRANCH_DELTA:
    
        LDA.b #$01 : STA $4D : STA $02F8
        
        STZ $74
        STZ $0360
        STZ $5E
        STZ $50
        STZ $6B
        
        TXA : AND.b #$02 : BNE .left_or_right_recoil
        
        STZ $31
        
        BRA .return
    
    .left_or_right_recoil
    
        STZ $30
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$39291-$3929F LONG
    Sprite_RepelDashAttackLong:
    {
        PHB : PHK : PLB
        
        PHX
        
        ; Update the last direction the player moved in.
        LDA $2F : LSR A : STA $66
        
        JSR $91F1 ; $391F1 IN ROM
        
        PLX : PLB
        
        RTL
    }

; ==============================================================================

    ; *$392A0-$392BE LOCAL
    {
        STZ $67
        
        LDY.b #$00
        
        LDA $27 : BEQ BRANCH_ALPHA : BMI BRANCH_BETA
        
        LDY.b #$01
    
    BRANCH_BETA:
    
        JSR $92B9 ; $392B9 IN ROM
    
    BRANCH_ALPHA:
    
        LDY.b #$02
        
        LDA $28 : BEQ BRANCH_GAMMA : BMI BRANCH_DELTA
        
        LDY.b #$03
    
    ; *$392B9 ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        LDA $91ED, Y : TSB $67
    
    BRANCH_GAMMA:
    
        RTS
    }

    ; *$392D3-$3951D JUMP LOCATION
    {
        ; Link mode 0x01 - Link falling into a hole
        
        STZ $67
        
        LDA $0302 : BEQ BRANCH_ALPHA
        
        INC $02CA : LDA $02CA : CMP.b #$20 : BNE BRANCH_ALPHA
        
        ; Ensures the next time around that this 
        LDA.b #$1F : STA $02CA
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $0372 : BEQ BRANCH_GAMMA
        
        LDA $0374 : BEQ BRANCH_DELTA
        
        BRL BRANCH_$38F86
    
    BRANCH_DELTA:
    
        ; Check if any directional buttons are being pressed on the Joypad
        LDA $F0 : AND.b #$0F : BEQ BRANCH_BETA
        
        AND $67 : BNE BRANCH_BETA
        
        JSR Player_HaltDashAttack
    
    BRANCH_GAMMA:
    
        LDA $4D : CMP.b #$01 : BEQ BRANCH_BETA
        
        LDA $F0 : AND.b #$0F : STA $67
    
    BRANCH_BETA:
    
        LDY.b #$04
        
        JSR $D077 ; $3D077 IN ROM
        
        LDA $59 : AND.b #$01 : BNE BRANCH_DELTA
        
        LDA $0372 : BEQ BRANCH_EPSILON
        
        BRL BRANCH_$38F86
    
    BRANCH_EPSILON:
    
        STZ $5E
        
        JSR Player_HaltDashAttack
        
        LDA $3A : AND.b #$80 : BNE BRANCH_ZETA
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_ZETA:
    
        STZ $5B
        
        LDY.b #$00
        
        LDA $02E0 : BEQ BRANCH_THETA
        
        LDY.b #$17
        
        LDA $7EF357 : BEQ BRANCH_THETA
        
        LDY.b #$1C
    
    BRANCH_THETA:
    
        STY $5D
        
        CPY.b #$17 : BEQ BRANCH_IOTA
        CPY.b #$1C : BEQ BRANCH_KAPPA
        
        BRL BRANCH_$38109 ; NORMAL MODE
    
    BRANCH_IOTA:
    
        BRL BRANCH_$383A1 ; PERMABUNNY MODE
    
    BRANCH_KAPPA: ; TEMP BUNNY MODE
    
        BRL BRANCH_$38365; TEMPBUNNY MODE
    
    BRANCH_DELTA:
    
        JSR Player_TileDetectNearby
        
        LDA.b #$04 : STA $5E
        
        LDA $59 : AND.b #$0F : BNE BRANCH_LAMBDA
        
        STZ $5B
        STZ $5E
        
        LDY.b #$00
        
        LDA $02E0 : BEQ BRANCH_MU
        
        LDY.b #$17
        
        LDA $7EF357 : BEQ BRANCH_MU
        
        LDY.b #$1C
    
    BRANCH_MU:
    
        STY $5D
        
        JSR Player_HaltDashAttack
        
        LDA $3A : AND.b #$80 : BNE BRANCH_NU
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_NU:
    
        ; ?????
        BRL 0095
    
    BRANCH_LAMBDA:
    
        CMP.b #$0F : BNE BRANCH_XI
        
        LDA $5B : CMP.b #$02 : BEQ BRANCH_OMICRON
        
        LDA $7EF357 : BEQ BRANCH_PI
        
        STZ $03F7
        STZ $56
        STZ $02E0
        STZ $03F5
        STZ $03F6
    
    BRANCH_PI:
    
        STZ $67
        STZ $00
        
        LDA.b #$02 : STA $5B
        
        LDA.b #$01 : STA $037B
        
        STZ $3A
        STZ $3C
        STZ $0301
        STZ $037A
        STZ $46
        STZ $4D
        
        LDA.b #$1F : JSR Player_DoSfx3
    
    BRANCH_OMICRON:
    
        BRA BRANCH_RHO
    
    BRANCH_XI:
    
        LDX.b #$03
    
    BRANCH_UPSILON:
    
        LDA $59 : AND.b #$0F : CMP $92CF, X : BNE BRANCH_SIGMA
        
        TXA : ADD.b #$04 : TAX
        
        BRA BRANCH_TAU
    
    BRANCH_SIGMA:
    
        DEX : BPL BRANCH_UPSILON
        
        LDX.b #$03
        
        LDA $59
    
    BRANCH_PHI:
    
        LSR A : BCS BRANCH_TAU
        
        DEX : BPL BRANCH_PHI
    
    BRANCH_TAU:
    
        STX $02C9
        
        LDA $67 : AND $92C7, X : BEQ BRANCH_CHI
        
        LDA $67 : STA $26
        
        LDA.b #$06 : STA $5E
        
        BRA BRANCH_PSI
    
    BRANCH_CHI:
    
        LDA $67 : STA $00
        
        LDX $02C9
        
        LDA $92BF, X : TSB $67
        
        LDA $00 : BEQ BRANCH_OMEGA
    
    BRANCH_PSI:
    
        JSL $07E6A6 ; $3E6A6 IN ROM
    
    BRANCH_OMEGA:
    
        JSR $B64F   ; $3B64F IN ROM
        JSL $07E245 ; $3E245 IN ROM
        JSR $B7C7   ; $3B7C7 IN ROM
        JSL $07E9D3 ; $3E9D3 IN ROM
    
    BRANCH_ALTIMA:
    
        RTS
    
    BRANCH_RHO:
    
        STZ $50
        STZ $46
        STZ $24
        STZ $25
        STZ $29
        STZ $4D
        STZ $0373
        STZ $02E1
        
        JSR $AE54 ; $3AE54 IN ROM
        
        INC $037B
        
        DEC $5C : BPL BRANCH_ALTIMA
        
        INC $5A : LDX $5A
        
        LDA.b #$09 : STA $5C
        
        LDA $7EF3CC : CMP.b #$0D : BEQ BRANCH_ULTIMA
        
        CPX.b #$01 : BNE BRANCH_ULTIMA
        
        STX $02F9
    
    BRANCH_ULTIMA:
    
        CPX.b #$06 : BNE BRANCH_ALTIMA
        
        JSR Player_HaltDashAttack
        
        LDY.b #$07 : STY $11
        
        LDA.b #$06 : STA $5A
        LDA.b #$03 : STA $5B
        LDA.b #$0C : STA $4B
        LDA.b #$10 : STA $57
        
        LDA $20 : SUB $E8 : STA $00
        
        STZ $01
        STZ $0308
        STZ $0309
        STZ $0376
        STZ $030B
        
        REP #$30
        
        LDA $1B : AND.w #$00FF : BEQ BRANCH_LATIMUS
        
        LDA $00 : PHA
        
        SEP #$30
        
        LDA $A0 : STA $A2
        
        JSL Dungeon_SaveRoomQuadrantData
        
        REP #$30
        
        PLA : STA $00
        
        LDX.w #$0070
        
        LDA $A0
    
    BRANCH_BETA2:
    
        CMP $00990C, X : BEQ BRANCH_ALPHA2
        
        DEX #2 : BPL BRANCH_BETA2
    
    BRANCH_LATIMUS:
    
        SEP #$20
        
        LDA $A0 : STA $A2
        
        LDA $7EC000 : STA $A0
        
        REP #$20
        
        LDA.w #$0010 : ADD $00 : STA $00
        
        LDA $20 : STA $51 : SUB $00 : STA $20
        
        SEP #$30
        
        LDA $1B : BNE BRANCH_GAMMA2
        
        LDA $8A : CMP.b #$05 : BNE .delta2
        
        JSL Overworld_PitDamage
        
        RTS
    
    .delta2
    
        JSL Overworld_Hole
        
        LDA.b #$11 : STA $10
        
        STZ $11
        STZ $B0
        
        RTS
    
    BRANCH_GAMMA2:
    
    ; *$394F1 ALTERNATE ENTRY POINT
    
        ; Hole / teleporter plane
        LDX $063C
        
        LDA $01C31F, X : STA $0476
        
        LDA $01C322, X : STA $EE
        
        RTS
    
    BRANCH_ALPHA2:
    
        SEP #$30
        
        ; Return Link from the damaging pit.
        LDA.b #$14 : STA $11
        
        ; Subtract one heart from Link's HP. Could replace this with a BPL... maybe.
        LDA $7EF36D : SUB.b #$08 : STA $7EF36D : CMP.b #$A8 : BCC .notDead
        
        ; Instakill if Link's HP is >= 0xA8. Kinda counter intuitive, but whatever.
        LDA.b #$00 : STA $7EF36D
    
    .notDead
    
        RTS
    }

; ==============================================================================

    ; \unused Can't seem to find any reference to it.
    ; $3951E-$3951F DATA
    {
    
    .unknown_0
        db $21, $24
    }

; ==============================================================================

    ; *$39520-$39634 LONG
    {
        PHB : PHK : PLB
        
        JSL PlayerOam_Main
        
        REP #$20
        
        LDA $22 : STA $0FC2
        
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        LDA $11 : CMP.b #$07 : BNE BRANCH_ALPHA
        
        STZ $4B
    
    BRANCH_ALPHA:
    
        LDA $1A : AND.b #$03 : BNE BRANCH_BETA
        
        INC $5A : LDA $5A : CMP.b #$0A : BNE BRANCH_BETA
        
        LDA.b #$06 : STA $5A
    
    BRANCH_BETA:
    
        LDA.b #$04 : STA $67
        
        JSL $07E245 ; $3E245 IN ROM
        
        REP #$20
        
        LDA $20 : BPL BRANCH_GAMMA
        
        LDA $51 : BMI BRANCH_GAMMA
        
        LDA $20 : EOR.w #-1 : INC A : ADD $51 : BMI BRANCH_DELTA
        
        BRL BRANCH_EPSILON
    
    BRANCH_GAMMA:
    
        LDA $51 : CMP $20 : BCC BRANCH_DELTA
        
        BRL BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        LDA $51 : STA $20
        
        SEP #$20
        
        STZ $2E
        STZ $57
        STZ $5A
        STZ $5B
        STZ $5E
        STZ $B0
        STZ $11
        STZ $037B
        
        LDA $7EF3CC : BEQ BRANCH_ZETA
        CMP.b #$03  : BEQ BRANCH_ZETA
        
        STZ $02F9
        
        CMP.b #$0D : BNE BRANCH_THETA
        
        LDA.b #$00 : STA $7EF3CC : STA $04B4 : STA $04B5 : STA $7EF3D3
        
        BRA BRANCH_ZETA
    
    BRANCH_THETA:
    
        JSL Tagalong_Init
    
    BRANCH_ZETA:
    
        LDY.b #$00
        
        JSR $D077 ; $3D077 IN ROM
        
        LDA $0359 : AND.b #$01 : BEQ BRANCH_IOTA
        
        LDA.b #$24 : JSR Player_DoSfx2
    
    BRANCH_IOTA:
    
        JSR Player_TileDetectNearby
        
        LDA $012E : AND.b #$3F : CMP.b #$24 : BEQ BRANCH_KAPPA
        
        LDA.b #$21 : JSR Player_DoSfx2
    
    BRANCH_KAPPA:
    
        LDA $AD : CMP.b #$02 : BNE BRANCH_LAMBDA
        
        LDA $034C : AND.b #$0F : BEQ BRANCH_LAMBDA
        
        LDA.b #$03 : STA $0322
    
    BRANCH_LAMBDA:
    
        LDA $0341 : AND.b #$0F : CMP.b #$0F : BNE BRANCH_MU
        
        LDA.b #$01 : STA $0345
        
        LDA $26 : STA $0340
        
        JSL Player_ResetSwimState
        
        LDA.b #$01 : STA $EE
        
        LDA.b #$15
        LDY.b #$00
        
        JSL AddTransitionSplash     ; $498FC IN ROM
        
        LDA.b #$04 : STA $5D
        
        JSR $AE54; $3AE54 IN ROM
        
        STZ $0308
        STZ $0309
        STZ $0376
        STZ $5E
        
        BRA BRANCH_EPSILON
    
    BRANCH_MU:
    
        LDA $59 : AND.b #$0F : BNE BRANCH_NU
        
        LDA.b #$00 : STA $5D
        
        BRA BRANCH_EPSILON
    
    BRANCH_NU:
    
        ; Ahhhhhhh fallllllling into a hoooooole
        LDA.b #$01 : STA $5D
    
    BRANCH_EPSILON:
    
        SEP #$20
        
        PLB
        
        RTL
    }

    ; *$3963B-$39784 JUMP LOCATION
    {
        ; MODE 4 SWIMMING
        
        LDA $4D : BEQ BRANCH_ALPHA
        
        LDA.b #$02 : STA $5D
        
        STZ $25
        
        JSR Player_ResetSwimCollision
        
        STZ $032A
        STZ $034F
        
        LDA $50 : AND.b #$FE : STA $50
        
        BRL BRANCH_$386B5 ; GO TO RECOIL MODE
    
    BRANCH_ALPHA:
    
        STZ $3A
        STZ $3C
        STZ $3D
        STZ $79
        STZ $0308
        STZ $0309
        
        LDA $7EF356 : BNE .hasFlippers
        
        RTS
    
    .hasFlippers
    
        LDA $033C : ORA $033D : ORA $033E : ORA $033F : BNE BRANCH_GAMMA
        
        LDA $032B : CMP.b #$02 : BEQ BRANCH_DELTA
        
        LDA $032D : CMP.b #$02 : BEQ BRANCH_DELTA
        
        JSR Player_ResetSwimCollision
    
    BRANCH_DELTA:
    
        LDA $2E : AND.b #$01 : STA $2E
        
        INC $2D : LDA $2D : CMP.b #$10 : BCC BRANCH_EPSILON
        
        STZ $2D
        STZ $02CC
        
        LDA $2E : AND.b #$01 : EOR.b #$01 : STA $2E
        
        BRA BRANCH_EPSILON
    
    BRANCH_GAMMA:
    
        INC $2D
        
        LDA $2D : CMP.b #$08 : BCC BRANCH_EPSILON
        
        STZ $2D
        
        LDA $2E : INC A : AND.b #$03 : STA $2E : TAX
        
        LDA $9635, X : STA $02CC
    
    BRANCH_EPSILON:
    
        LDA $034F : BNE BRANCH_ZETA
        
        LDA $033C : ORA $033D : ORA $033E : ORA $033F : BEQ BRANCH_THETA
        
        LDA $F6 : AND.b #$80 : STA $00
        
        LDA $F4 : ORA $00 : AND.b #$C0 : BEQ BRANCH_THETA
        
        STA $034F
        
        LDA $25 : JSR Player_DoSfx2
        
        LDA.b #$01 : STA $032A
        LDA.b #$07 : STA $02CB
        
        JSR $98A8   ; $398A8 IN ROM
    
    BRANCH_ZETA:
    
        DEC $02CB : BPL BRANCH_THETA
        
        LDA.b #$07 : STA $02CB
        
        INC $032A : LDA $032A : CMP.b #$05 : BNE BRANCH_THETA
        
        STZ $032A
        
        LDA $034F : AND.b #$3F
        
        STA $034F
    
    ; *$39715 LONG BRANCH LOCATION
    BRANCH_THETA:
    
        LDA $49 : AND.b #$0F : BNE BRANCH_IOTA
        
        LDA $F0 : AND.b #$0F : BNE BRANCH_IOTA
        
        STZ $30
        STZ $31
        
        JSR $9785 ; $39785 IN ROM
        
        LDA $034A : BEQ BRANCH_KAPPA
        
        LDA $0372 : BEQ BRANCH_LAMBDA
        
        LDA $0340
        
        BRA BRANCH_IOTA
    
    BRANCH_LAMBDA:
    
        LDA $033C : ORA $033D : ORA $033E : ORA $033F : BNE BRANCH_MU
        
        STZ $48
        
        JSL Player_ResetSwimState
        
        BRA BRANCH_MU
    
    BRANCH_KAPPA:
    
        LDA $5D : CMP.b #$04 : BEQ BRANCH_MU
        
        STZ $2E
        
        BRA BRANCH_MU
    
    BRANCH_IOTA:
    
        CMP $0340 : BEQ BRANCH_NU
        
        STZ $2A
        STZ $2B
        STZ $6B
        STZ $48
    
    BRANCH_NU:
    
        STA $0340
        
        JSR $97A6 ; $397A6 IN ROM
        JSR $97C7 ; $397C7 IN ROM
        JSR $9903 ; $39903 IN ROM
    
    BRANCH_MU:
    
        JSR $B64F   ; $3B64F IN ROM
        JSL $07E245 ; $3E245 IN ROM
        JSR $B7C7   ; $3B7C7 IN ROM
        JSL $07E6A6 ; $3E6A6 IN ROM
        
        STZ $0302
        
        JSR $E8F0 ; $3E8F0 IN ROM
        
        RTS
    }

    ; *$39785-$397A5 LOCAL
    {
        REP #$20
        
        LDA $034A : AND.w #$00FF : BEQ .linkNotMoving
        
        LDX.b #$02
    
    BRANCH_GAMMA:
    
        LDA $033C, X : BEQ BRANCH_BETA
        
        STA $0334, X
        
        LDA.w #$0001 : STA $032B
    
    BRANCH_BETA:
    
        DEX #2 : BPL BRANCH_GAMMA
    
    .linkNotMoving
    
        SEP #$20
        
        RTS
    }

    ; *$397A6-$397BE LOCAL
    {
        REP #$20
        
        LDA $034A : AND.w #$00FF : BEQ BRANCH_ALPHA
        
        LDX.b #$02
    
    BRANCH_BETA:
    
        LDA.w #$0180 : STA $0334, X
        
        DEX #2 : BPL BRANCH_BETA
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        RTS
    }

    ; *$397C7-$39839 BLOCK
    {
        SEP #$20
        
        LDA $F0 : AND.b #$0F : STA $00
        
        STZ $01
        
        REP #$30
        
        LDA.w #$0003 : STA $02
        
        LDX.w #$0002 : STX $04
    
    BRANCH_ZETA:
    
        LDY.w #$0000
        
        LDA $00
        
        AND $02    : BEQ BRANCH_ALPHA
        AND.b #$04 : BNE BRANCH_BETA
        
        LDY.w #$0001
    
    BRANCH_BETA:
    
        LDA.w #$0020 : STA $0326, X
        
        LDA $034A : AND.w #$00FF : BEQ BRANCH_GAMMA
        
        PHY
        
        DEC A : ASL A : TAY
        
        LDA $97C3, Y : STA $0326, X
        
        PLY
    
    BRANCH_GAMMA:
    
        LDA $0340 : ORA $67 : AND $02 : CMP $02 : BNE BRANCH_DELTA
        
        LDA.w #$0002 : STA $032B, X
        
        BRA BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        TYA : STA $0338, X
        
        STZ $032B, X
    
    BRANCH_EPSILON:
    
        LDA $0334, X : BNE BRANCH_ALPHA
        
        LDA $9639 : STA $0334, X
    
    BRANCH_ALPHA:
    
        ASL $02 : ASL $02
        
        ASL $04 : ASL $04
        
        DEX #2 : BPL BRANCH_ZETA
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$3983A-$3984A LONG
    Player_ResetSwimState:
    {
        PHB : PHK : PLB
        
        STZ $02CB
        STZ $034F
        STZ $032A
        
        JSR Player_ResetSwimCollision
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3984B-$39872 LONG
    {
        PHB : PHK : PLB
        
        JSL Player_ResetSwimState
        
        LDY.b #$00
        
        LDA $56 : BEQ .alpha
        
        LDA $7EF357 : BNE .alpha
        
        LDY.b #$17
    
    .alpha
    
        STY $5D
        
        LDA $0340 : STA $26
        
        STZ $0345
        STZ $037B
        
        STZ $5A
        STZ $5B
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$39873-$39895 LOCAL
    Player_ResetSwimCollision:
    {
        REP #$20
        
        STZ $032F
        STZ $0331
        STZ $0326
        STZ $0328
        STZ $032B
        STZ $032D
        STZ $033C
        STZ $033E
        STZ $0334
        STZ $0336
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$398A8-$39902 LOCAL
    {
        REP #$30
        
        LDX.w #$0002
        
        LDA.w #$0003 : STA $02
    
    BRANCH_ZETA:
    
        LDA $F0 : AND $02 : BEQ BRANCH_ALPHA
        
        LDA $033C, X : BEQ BRANCH_BETA
        
        LDA $0334, X : CMP.w #$0180 : BCC BRANCH_BETA
        
        LDY.w #$0000
    
    BRANCH_DELTA:
    
        LDA $9896, Y : CMP $033C, X : BCS BRANCH_GAMMA
        
        INY #2 : CPY.w #$0012 : BNE BRANCH_DELTA
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        LDA $0334, X : BEQ BRANCH_EPSILON
        
        ADD.w #$00A0 : CMP.w #$0180 : BCC BRANCH_GAMMA
        
        LDA.w #$0180
        
        BRA BRANCH_GAMMA
    
    BRANCH_EPSILON:
    
        LDA.w #$0001 : STA $033C, X
        
        LDA $9639
    
    BRANCH_GAMMA:
    
        STA $0334, X
    
    BRANCH_ALPHA:
    
        ASL $02 : ASL $02
        
        DEX #2 : BPL BRANCH_ZETA
        
        SEP #$30
        
        RTS
    }

    ; *$39903-$3996B LOCAL
    {
        REP #$30
        
        LDA $034A : AND.w #$00FF : BNE BRANCH_ALPHA
        
        LDA $034F : AND.w #$00FF : BNE BRANCH_ALPHA
        
        LDX.w #$0002
        
        LDA.w #$0003 : STA $02
    
    BRANCH_EPSILON:
    
        LDA $F0 : AND $02 : BEQ BRANCH_BETA
        
        LDA $032B, X : CMP.w #$0002 : BEQ BRANCH_BETA
        
        LDA $032F, X : BNE BRANCH_GAMMA
        
        STZ $032F, X
        
        LDA $033C, X : CMP $9639 : BCC BRANCH_DELTA
        
        CMP $0334, X : BEQ BRANCH_GAMMA : BCC BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        STZ $032B, X
        
        LDA $033C, X : CMP $9639 : BCC BRANCH_BETA
        
        LDA.w #$0001 : STA $032B, X : STA $032F, X
        
        BRA BRANCH_DELTA
    
    BRANCH_BETA:
    
        LDA $9639 : STA $0334, X
        
        STZ $032F, X
    
    BRANCH_DELTA:
    
        ASL $02 : ASL $02
        
        DEX #2 : BPL BRANCH_EPSILON
    
    BRANCH_ALPHA:
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$3996C-$399AC LONG BRANCH POINT
    Player_Electrocution:
    {
        JSR $F514 ; $3F514 in Rom.
        JSL Player_SetElectrocutionMosaicLevel
        
        ; Decrease the delay counter
        DEC $3D : BPL .return
        
        ; Set up a three frame delay for this next step.
        LDA.b #$02 : STA $3D
        
        ; $0300 is the cycle counter for the electrocution animation.
        LDA $0300 : INC A : STA $0300 : AND.b #$01 : BEQ .use_normal_palettes
        
        JSL Palette_ElectroThemedGear
        
        BRA .palette_logic_complete
    
    .use_normal_palettes
    
        JSL LoadActualGearPalettes
    
    .palette_logic_complete
    
        ; On the eighth step release player (fling them back).
        LDA $0300 : CMP.b #$08 : BNE .return
        
        ; Reset the steps of the electrocution
        STZ $0300
        
        ; Reset player to ground state
        LDA.b #$00 : STA $5D
        
        STZ $037B
        STZ $0360
        STZ $4D
        
        LDA.b #$00
        
        JSL Player_SetCustomMosaicLevel
    
    .return
    
    ; *$399AC ALTERNATE ENTRY POINT
    
        RTS
    }

; ==============================================================================

    ; *$399AD-$39A2B LONG
    Link_ReceiveItem:
    {
        ; Grant link the item he earned, if possible
        PHB : PHK : PLB
        
        ; Is Link in another type of mode besides ground state?
        LDA $4D : BEQ .groundState
        
        ; If not, bring him back to normal so he can get this item.
        STZ $4D : STZ $46
        
        STZ $031F : STZ $0308
    
    .groundState
    
        ; The index of the item we're going to give to Link.
        ; Did Link receive a heart container?
        STY $02D8 : CPY.b #$3E : BNE .notHeartContainer
        
        ; Link received a heart container.. handle it.
        LDA.b #$2E : JSR Player_DoSfx3
    
    .notHeartContainer
    
        LDA.b #$60 : STA $02D9
        
        LDA $02E9 : BEQ .fromTextOrObject
        
        ; 0x03 = grabbed an item off the floor (from an ancillary object).
        CMP.b #$03 : BNE .fromChestOrSprite
    
    .fromTextOrObject
    
        STZ $0308
        
        STZ $3A : STZ $3B : STZ $3C
        
        STZ $5E : STZ $50
        
        STZ $0301 : STZ $037A : STZ $0300
        
        ; Put Link in a position looking up at his item.
        LDA.b #$15 : STA $5D
        
        LDA.b #$01 : STA $02DA : STA $037B
        
        ; Is the item a crystal?
        CPY.b #$20 : BNE .notCrystal
        
        ; up the ante or whatever >_>
        ; (Puts Link in a different pose holding the item up with two hands)
        INC A : STA $02DA
    
    .notCrystal
    .fromChestOrSprite
    
        PHX
        
        LDY.b #$04
        LDA.b #$22
        
        JSL AddReceivedItem
        
        ; Is it a crystal?
        LDA $02D8
        
        CMP.b #$20 : BEQ .noHudRefresh
        CMP.b #$37 : BEQ .noHudRefresh
        CMP.b #$38 : BEQ .noHudRefresh
        CMP.b #$39 : BEQ .noHudRefresh
        
        JSL HUD.RefreshIconLong
    
    .noHudRefresh
    
        JSR Player_HaltDashAttack
        
        PLX
        
        CLC
        
        PLB
        
        RTL
    
    ; are we missing a label during disassembly? or is this just unused code?
    ; .failure?
    
        SEC
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$39A2C-$39A53 LONG
    {
        ; Puts link in bed asleep
        
        PHB : PHK : PLB
        
        REP #$20
        
        ; Link's Y coordinate is #$215A; Link's X coordinate is #$0940
        LDA.w #$215A : STA $20
        LDA.w #$0940 : STA $22
        
        SEP #$20
        
        ; Link's mode is the "asleep in bed" one.
        LDA.b #$16 : STA $5D
        
        STZ $037C : STZ $037D
        
        LDA.b #$03 : STA $0374
        
        ; Spawn the "Link's bedspread" ancilla.
        LDA.b #$20
        
        JSL AddLinksBedSpread
        
        PLB
        
        RTL
    }

    ; $39A54-$39A59 JUMP TABLE
    {
        dw $9A62 ; = $39A62*
        dw $9A71 ; = $39A71*
        dw $9AA1 ; = $39AA1*
    }

    ; *$39A5A-$39A61 JUMP LOCATION
    {
        ; Link mode 0x16 (asleep in bed)
        
        LDA $037C : ASL A : TAX
        
        JMP ($9A54, X)
    }

    ; *$39A62-$39A70 JUMP LOCATION
    {
        LDA $1A : AND.b #$1F : BNE .noZzzz
        
        ; Generate Z sprites from Link sleeping
        LDY.b #$01
        LDA.b #$21
        
        JSL AddLinksSleepZs
    
    .noZzzz
    
        RTS
    }

    ; *$39A71-$39AA0 JUMP LOCATION
    {
        LDA $11 : BNE BRANCH_ALPHA
        
        DEC $0374 : BPL BRANCH_ALPHA
        
        STZ $0374
        
        LDA $F4 : AND.b #$E0 : STA $00
        
        LDA $F4 : ASL #4 : ORA $00 : ORA $F6 : AND.b #$F0 : BEQ BRANCH_ALPHA
        
        INC $037D
        
        LDA.b #$06 : STA $2F
        
        INC $037C
        
        LDA.b #$04 : STA $0374
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$39AA1-$39AC1
    {
        DEC $0374 : BPL .countingDown
        
        LDA.b #$04 : STA $27
        LDA.b #$15 : STA $28
        
        LDA.b #$18 : STA $29 : STA $02C7
        
        LDA.b #$10 : STA $46
        
        LDA.b #$02 : STA $4D
        
        LDA.b #$06 : STA $5D
    
    .countingDown
    
        RTS
    }

    ; *$39AC2-$39AE5 LOCAL
    Player_Sword:
    {
        DEC $02E3 : BPL BRANCH_ALPHA
        
        STZ $02E3
        
        LDA $0301 : ORA $037A : BNE BRANCH_ALPHA
        
        LDA $3C : CMP.b #$09 : BCS .spin_attack_jerks
        
        LDA $0372 : BNE BRANCH_ALPHA
        
        JSR $9CD9 ; $39CD9 IN ROM
        
        BRA BRANCH_ALPHA
    
    .spin_attack_jerks
    
        JSR $9D72 ; $39D72 IN ROM
    
    ; *$39AE5 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        RTS
    }

    ; $39AE6-$39B0D JUMP TABLE
    {
        ; Subprograms that handle the Y button weapons.
        
        dw $A138 ; = $3A138*  ; Bombs
        dw LinkItem_Boomerang
        dw LinkItem_Bow
        dw LinkItem_Hammer
        dw LinkItem_Rod
        dw LinkItem_Rod
        dw $AFF8 ; = $3AFF8*  ; Bug Catching Net
        dw LinkItem_ShovelAndFlute
        
        dw LinkItem_Lamp
        dw LinkItem_MagicPowder
        dw $A15B ; = $3A15B* ; Bottle(s)
        dw $A471 ; = $3A471* ; Book of Mudora
        dw PlayerItem_CaneOfByrna
        dw $AB25 ; = $3AB25* ; Hookshot
        dw $A569 ; = $3A569* ; Bombos Medallion
        dw LinkItem_EtherMedallion
        
        dw LinkItem_Quake
        dw LinkItem_CaneOfSomaria
        dw LinkItem_Cape
        dw LinkItem_Mirror
    }

    ; *$39B0E-$39B91 LOCAL
    {
        LDA $3C    : BEQ BRANCH_ALPHA
        CMP.b #$09 : BCC BRANCH_39AE5
    
    BRANCH_ALPHA:
    
        LDA $02E0 : BEQ BRANCH_BETA
        
        LDA $0303
        
        CMP.b #$0B : BEQ BRANCH_BETA
        CMP.b #$14 : BEQ BRANCH_BETA
        
        RTS
    
    BRANCH_BETA:
    
        LDY $03FC : BEQ BRANCH_GAMMA
        
        LDA $02E0 : BNE BRANCH_GAMMA
        
        CPY.b #$02 : BEQ BRANCH_DELTA
        
        BRL LinkItem_Shovel
    
    BRANCH_DELTA:
    
        BRL LinkItem_Bow
    
    BRANCH_GAMMA:
    
        LDY $0304 : CMP $0303 : BEQ BRANCH_EPSILON
        
        LDA $0304 : CMP.b #$08 : BNE BRANCH_ZETA
        
        ; Does Link have the flute?
        LDA $7EF34C : AND.b #$02 : BEQ BRANCH_ZETA
        
        LDA $3A : AND.b #$BF : STA $3A
    
    BRANCH_ZETA:
    
        LDA $0304 : CMP.b #$13 : BNE BRANCH_EPSILON
        
        LDA $55 : BEQ BRANCH_EPSILON
        
        JSR $AE47 ; $3AE47 IN ROM
    
    BRANCH_EPSILON:
    
        LDA $0301 : ORA $037A : BNE BRANCH_THETA
        
        LDY $0303 : STY $0304
    
    BRANCH_THETA:
    
                     BEQ BRANCH_IOTA
        CPY.b #$05 : BEQ BRANCH_KAPPA
        CPY.b #$06 : BNE BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        ; Only gets triggered if the previous item was one of the rods.
        LDA $0304 : SUB.b #$05 : INC A : STA $0307
    
    BRANCH_LAMBDA:
    
        DEY : BMI BRANCH_IOTA
        
        TYA : ASL A : TAX
        
        JMP ($9AE6, X) ; $39AE6, X; USE JUMP TABLE
    
    BRANCH_IOTA:
    
        RTS
    }

    ; $39B92-$39BA1 JUMP TABLE
    {
        dw $AAA1 ; = $3AAA1*; RTS, basically
        dw $B1CA ; = $3B1CA* ; pick up a pot / bush / bomb / etc
        dw $B2ED ; = $3B2ED*
        dw $B322 ; = $3B322* ; Grabbing wall... prep?
        dw Link_Read_return  ; Reading.... prep?
        dw $B5BF ; = $3B5BF* ; (RTS); The chest is already open, we're done.
        dw $B389 ; = $3B389*
        dw $B40C ; = $3B40C*
    }

    ; *$39BAA-$39C4E LOCAL
    {
        STZ $02F4
        
        ; Is Link using a special item already?
        LDA $0301 : BNE .cantDoAnyAction
        
        ; Is Link in some sort of special pose? (praying, shoveling, etc.)?
        LDA $037A : AND.b #$1F : BNE .cantDoAnyAction
        
        ; If the flag is set, don't read the A button.
        LDA $0379 : BNE .cantDoAnyAction
        
        ; How long has the B - button been pressed? (Less than 9 frames?)
        LDA $3C : CMP.b #$09 : BCC .swordWontInterfere
        
        ; Is the B button been released this frame?
        LDA $3A : AND.b #$80 : BEQ .swordWontInterfere
    
    .cantDoAnyAction
    
        RTS
    
    .swordWontInterfere
    
        LDX $036C
        
        ; Is link Holding a pot? Is he holding a wall?
        LDA $0308 : ORA $0376 : BNE .handsAreOccupied
        
        ; $3B5C0 IN ROM
        ; If the A button was down, then continue. If not, branch.
        JSR $B5C0 : BCC .cantDoAction
        
        ; Pull for rupees flag (if near one)
        LDA $03F8 : BEQ .notPullForRupeesAction
        
        ; What direction is Link facing? If he's not facing up, then...
        LDA $2F : BNE .notPullForRupeesAction
        
        ; The PullForRupees action
        LDX.b #$07
        
        BRL .attemptAction
    
    .notPullForRupeesAction
    
        LDA $02FA : BEQ .notMovingStatueAction
        
        ; Near a moveable statue (so pressing A will grab it)
        LDX.b #$06
        
        BRL .attemptAction
    
    .notMovingStatueAction
    
        ; Detection of a bomb or cane of somaria block?
        LDA $02EC : BNE .spriteLiftAction
        
        ; Detection of a sprite object
        LDA $0314 : BEQ .checkOtherActions
        
        LDA $0314 : STA $02F4
    
    .spriteLiftAction
    
        LDA $3C : BEQ .nu
        
        JSR $9D84 ; $39D84 IN ROM
    
    .nu
    
        LDA $0301 : ORA $037A : BEQ .notBoomerang
        
        STZ $0301
        STZ $037A
        
        JSR $A11F ; $3A11F IN ROM
        
        STZ $035F
        
        LDA $0C4A : CMP.b #$05 : BNE .notBoomerang
        
        STZ $0C4A
    
    .notBoomerang
    
        LDX.b #$01
        
        BRA .attemptAction
    
    .checkOtherActions
    
        JSR $D383 ; $3D383 IN ROM; Determines what type of action you desire to complete. Eg. Opening a chest, dashing, etc. Returns X as the index of that action.
    
    .attemptAction
    
        ; Check to see if we have the capability for this action.
        LDA $9BA2, X : AND $7EF379 : BEQ .cantDoAction
        
        ; Buffer $036C with the current action index.
        STX $036C
        
        TXA : ASL A : TAX
        
        JSR $9C5F ; $39C5F IN ROM; Do the action.
    
    .handsAreOccupied
    
        ; Remind me what action we just did, and mirror it to $0306.
        LDA $036C : STA $0306 : ASL A : TAX
        
        JMP ($9B92, X) ; SEE JUMP TABLE AT $39B92
    
    .cantDoAction
    
        STZ $3B
        
        RTS
    }

    ; $39C4F-$39C5E JUMP TABLE
    {
        ; Parameter: $036C
        
        ; Using the A button, Link:
        
        dw $AA6C ; = $3AA6C* ; ???
        dw Link_Lift          ; Picks up a pot or bush.
        dw $B281 ; = $3B281* ; Starts dashing
        dw $B2EE ; = $3B2EE* ; Grabs a wall
        dw Link_Read          ; Reads a sign.
        dw Link_Chest         ; Opens a chest.
        dw Link_MovableStatue ; Grabs a Moveable Statue
        dw $B3E5 ; = $3B3E5* ; Pull For Rupees / DW Dungeon 4 entrance
    }

    ; $39C5F-$39C62 LOCAL
    {
        JMP ($9C4F, X) ; SEE JUMP TABLE $39C4F
    
    .unused
    
        RTS
    }

; ==============================================================================

    ; $39C63-$39C65 DATA
    {
        ; \unused Afaik.
        db 0, 1, 1
    }

; ==============================================================================

    ; *$39C66-$39CBE LOCAL
    {
        LDA $67 : AND.b #$F0 : STA $67
        
        STZ $3C ; Initialize the the next spin attack counter.
        STZ $79 ; Stop the spin attack
        
        ; Checks if we need to fire a sword beam
        ; if(actual health >= (goal health - 4))
        LDA $7EF36C : SUB.b #$04 : CMP $7EF36D : BCS .cantShootBeam
        
        ; Check if we have a sword that can shoot teh beamz
        LDA $7EF359 : INC A : AND.b #$FE : BEQ .cantShootBeam
        
        LDA $7EF359 : CMP.b #$02 : BCC .cantShootBeam
    
    .nextSlot
    
        ; Master Sword or better
        LDX.b #$04
        
        ; Is the cane of byrna being used?
        LDA $0C4A, X : CMP.b #$31 : BEQ .cantShootBeam
        
        DEX : BPL .nextSlot
        
        LDY.b #$00
        
        JSL AddSwordBeam
    
    .cantShootBeam
    
        ; normal sword
        JSL Sound_SetSfxPanWithPlayerCoords
        
        PHA
        
        LDA $7EF359 : DEC A : TAX
        
        PLA
        
        CPX.b #$FE : BEQ .noSwordSound
        CPX.b #$FF : BEQ .noSwordSound
        
        ORA $9CD1, X : STA $012E
    
    .noSwordSound
    
        ; Start the spin attack delay counter / timer.
        LDX.b #$01 : STX $3D
    
    .easy_out
    
        RTS
    }

; ==============================================================================

    ; *$39CD9-$39D83 LOCAL
    {
        ; (RTS)
        LDA $3B : AND.b #$10 : BNE BRANCH_39C66_easy_out
        
        ; Is the B button being held down?
        BIT $3A : BMI .b_button_held_previous_frames
        
        ; Did the player just press B this frame?
        BIT $F4 : BPL BRANCH_39C66_easy_out
        
        LDX $6C : BEQ .not_in_doorway
        
        ; Seems like this checks the types of tiles in front of the player
        ; to see if we can bring the sword out.
        JSR $D73E   ; $3D73E IN ROM
        
        LDA $0E : AND.b #$30 : EOR.b #$30 : BEQ BRANCH_39C66_easy_out
    
    .not_in_doorway
    
        ; Indicate that the B button is now being held down
        LDA.b #$80 : TSB $3A
        
        ; Reinitialize spin attack variables and shoot a sword beam, if applicable
        JSR $9C66   ; $39C66 IN ROM
        
        ; Link can no longer change direction
        LDA.b #$01 : TSB $50
        
        STZ $2E
    
    .b_button_held_previous_frames
    
        BIT $F0 : BMI .b_button_wasnt_released
        
        LDA.b #$01 : TSB $3A
    
    .b_button_wasnt_released
    
        ; Does something more related to how Link's standing / collision with the floor
        JSR $AE65   ; $3AE65 IN ROM
        
        ; Stop any motion Link may have had
        LDA $67 : AND.b #$F0 : STA $67
        
        ; Count down the spin attack delay timer
        DEC $3D : BPL BRANCH_DELTA
        
        ; Count up the "frames B Button has been held" timer
        INC $3C
        
        LDA $3C : CMP.b #$09 : BCS .maybeDoSpinAttack
        
        TAX
        
        LDA $9CBF, X : STA $3D
        
        CPX.b #$05 : BNE BRANCH_ZETA
        
        LDA $7EF359 : BEQ BRANCH_THETA
        CMP.b #$01  : BEQ BRANCH_THETA
        CMP.b #$FF  : BEQ BRANCH_THETA
        
        LDY.b #$04
        LDA.b #$26
        
        JSL AddLinksSleepZs
    
    BRANCH_THETA:
    
        LDY.b #$01
        
        LDA $7EF359 : BEQ BRANCH_DELTA
        CMP.b #$FF  : BEQ BRANCH_DELTA
        CMP.b #$01  : BEQ BRANCH_IOTA
        
        LDY.b #$06
    
    BRANCH_IOTA:
    
        JSR $D077   ; $3D077 IN ROM
        
        BRA BRANCH_DELTA
        
        CPX.b #$04 : BCC BRANCH_DELTA
        
        LDA $3A : AND.b #$01 : BEQ BRANCH_DELTA
        
        BIT $F0 : BPL BRANCH_DELTA
        
        LDA $3A : AND.b #$FE : STA $3A
        
        BRL BRANCH_$39C66
    
    BRANCH_DELTA:
    
        JSR $9E63   ; $39E63 IN ROM
        
        RTS
    
    ; *$39D72 ALTERNATE ENTRY POINT
    .maybeDoSpinAttack
    
        ; B Button is still being held
        BIT $F0 : BMI BRANCH_$39D9F
        
        LDA $79 : CMP.b #$30 : BCC BRANCH_$39D84
        
        JSR $9D84   ; $39D84 IN ROM
        
        STZ $79
        
        BRL BRANCH_$3A77A
    }

; *$39D84-$39E62 LOCAL
{

BRANCH_EPSILON:

    ; Bring Link to stop
    STZ $5E
    
    LDA $48 : AND.b #$F6 : STA $48
    
    ; Stop any animations Link is doing
    STZ $3D
    STZ $3C
    
    ; Nullify button input on the B button
    LDA $3A : AND.b #$7E : STA $3A
    
    ; Make it so Link can change direction if need be
    LDA $50 : AND.b #$FE : STA $50
    
    BRL BRANCH_ALPHA

; *$39D9F ALTERNATE ENTRY POINT

    BIT $48 : BNE BRANCH_BETA
    
    LDA $48 : AND.b #$09 : BNE BRANCH_GAMMA

BRANCH_BETA:

    LDA $47    : BEQ BRANCH_DELTA
    CMP.b #$01 : BEQ BRANCH_EPSILON

BRANCH_GAMMA:

    LDA $3C : CMP.b #$09 : BNE BRANCH_ZETA
    
    LDX.b #$0A : STX $3C
    
    LDA $9CBF, X : STA $3D

BRANCH_ZETA:

    DEC $3D : BPL BRANCH_THETA
    
    LDA $3C : INC A : CMP.b #$0D : BNE BRANCH_KAPPA
    
    LDA $7EF359 : INC A : AND.b #$FE : BEQ BRANCH_LAMBDA
    
    LDA $48 : AND.b #$09 : BEQ BRANCH_LAMBDA
    
    LDY.b #$01
    LDA.b #$1B
    
    JSL AddWallTapSpark ; $49395 IN ROM
    
    LDA $48 : AND.b #$08 : BNE BRANCH_MUNU
    
    LDA $05 : JSR Player_DoSfx2
    
    BRA BRANCH_XI

BRANCH_MUNU:

    LDA.b #$06 : JSR Player_DoSfx2

BRANCH_XI:

    ; Do sword interaction with tiles
    LDY.b #$01
    
    JSR $D077   ; $3D077 IN ROM
    
BRANCH_LAMBDA:

    LDA.b #$0A

BRANCH_KAPPA:

    STA $3C : TAX
    
    LDA $9CBF, X : STA $3D
    
BRANCH_THETA:

    BRA BRANCH_RHO

BRANCH_DELTA:

    LDA.b #$09 : STA $3C
    
    LDA.b #$01 : TSB $50
    
    STZ $3D
    
    LDA $5E
    
    CMP.b #$04 : BEQ BRANCH_RHO
    CMP.b #$10 : BEQ BRANCH_RHO
    
    LDA.b #$0C : STA $5E
    
    LDA $7EF359 : INC A : AND.b #$FE : BEQ BRANCH_ALPHA
    
    LDX.b #$04

BRANCH_PHI:

    LDA $0C4A, X
    
    CMP.b #$30 : BEQ BRANCH_ALPHA
    CMP.b #$31 : BEQ BRANCH_ALPHA
    
    DEX : BPL BRANCH_PHI
    
    LDA $79 : CMP.b #$06 : BCC BRANCH_CHI
    
    LDA $1A : AND.b #$03 : BNE BRANCH_CHI
    
    JSL AncillaSpawn_SwordChargeSparkle

BRANCH_CHI:

    LDA $79 : CMP.b #$40 : BCS BRANCH_ALPHA
    
    INC $79 : LDA $79 : CMP.b #$30 : BNE BRANCH_ALPHA
    
    LDA.b #$37 : JSR Player_DoSfx2
    
    JSL AddChargedSpinAttackSparkle
    
    BRA BRANCH_ALPHA

BRANCH_RHO:

    JSR $9E63 ; $39E63 IN ROM

BRANCH_ALPHA:
    
    RTS
}

; *$39E63-$39EEB LOCAL
{
    ; sword
    LDA $7EF359 : BEQ BRANCH_39D84_BRANCH_ALPHA ; RTS
    CMP.b #$FF  : BEQ BRANCH_39D84_BRANCH_ALPHA
    
    CMP.b #$02 : BCS BRANCH_ALPHA

BRANCH_GAMMA:

    LDY.b #$27
    
    LDA $3C : STA $02 : STZ $03
    
    CMP.b #$09 : BEQ BRANCH_39D84_BRANCH_ALPHA : bCC BRANCH_BETA
    
    LDA $02 : SUB.b #$0A : STA $02
    
    LDY.b #$03

BRANCH_BETA:

    REP #$30
    
    LDA $2F : AND.w #$00FF : TAX
    
    LDA $0DA030, X : STA $04
    
    TYA : AND.w #$00FF : ASL A : ADD $04 : TAX
    
    LDA $0D9EF0, X : ADD $02 : TAX
    
    SEP #$20
    
    LDA $0D98F3, X : STA $44
    LDA $0D9AF2, X : STA $45
    
    SEP #$10
    
    RTS

BRANCH_ALPHA:

    LDA $3C : CMP.b #$09 : BCS BRANCH_GAMMA
    
    ASL A : STA $04
    
    LDA $2F : LSR A : STA $0E
    
    ASL #3 : ADD $0E : ASL A : ADD $04 : TAX
    
    LDA $0DAC45, X : CMP.b #$FF : BEQ BRANCH_DELTA
    
    TXA : LSR A : TAX
    
    LDA $0DAC8D, X : STA $44
    LDA $0DACB1, X : STA $45
    
parallel pool LinkItem_Rod:

.quick_return

    RTS

BRANCH_DELTA:

    BRL BRANCH_GAMMA
}

; ==============================================================================

    ; $39EEC-$39EEE DATA
    {
        db 3, 3, 5
    }

; ==============================================================================

    ; *$39EEF-$39F58 LOCAL
    LinkItem_Rod:
    {
        ; Called when the fire rod or ice rod is invoked.
        
        BIT $3A : BVS .y_button_held
        
        ; Can't use while standing in doorway.
        LDA $6C : BNE .quick_return
        
        JSR Link_CheckNewY_ButtonPress : BCC .quick_return
        
        LDX.b #$00
        
        JSR LinkItem_EvaluateMagicCost : BCC .insufficient_mp
        
        ; This is a debug variable, but apparently in addition to moving the
        ; HUD up 8 pixels, it also prevents you from firing the rod weapons...
        ; or?.... maybe it prevents you from doing it without holding the button.
        LDA $020B : BNE .insufficient_mp
        
        LDA.b #$01 : STA $0350
        
        JSR LinkItem_RodDiscriminator
        
        ; Delay the spin attack for some amount of time?
        LDA $9EEC : STA $3D
        
        STZ $2E
        STZ $0300
        STZ $0301
        
        LDA.b #$01 : TSB $0301
    
    .y_button_held
    
        JSR $AE65 ; $3AE65 IN ROM
        
        ; What's the point of this?
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL BRANCH_GAMMA
        
        LDA $0300 : INC A : STA $0300 : TAX
        
        LDA $9EEC, X : STA $3D
        
        CPX.b #$03 : BNE BRANCH_GAMMA
        
        STZ $5E
        STZ $0300
        STZ $3D
        STZ $0350
        
        LDA $0301 : AND.b #$FE : STA $0301
    
    .insufficient_mp
    
        LDA $3A : AND.b #$BF : STA $3A
    
    BRANCH_GAMMA:
    
        RTS
    }

; ==============================================================================

    ; $39F59-$39F5C JUMP TABLE
    pool LinkItem_RodDiscriminator:
    {
    
    .rods
        dw LinkItem_FireRod
        dw LinkItem_IceRod
    }

; ==============================================================================

    ; *$39F5D-$39F65 LOCAL
    LinkItem_RodDiscriminator:
    {
        LDA $0307 : DEC A : ASL A : TAX
        
        JMP (.rods, X)
    }

; ==============================================================================

    ; *$39F66-$39F6E JUMP LOCATION
    LinkItem_IceRod:
    {
        LDA.b #$0B
        LDY.b #$01
        
        JSL AddIceRodShot
        
        RTS
    }

; ==============================================================================

    ; *$39F6F-$39F77 LOCAL
    LinkItem_FireRod:
    {
        LDA.b #$02
        LDY.b #$01
        
        JSL AddFireRodShot
        
        RTS
    }

; ==============================================================================

    ; $39F78-$39F7A DATA
    {
        
    }

; ==============================================================================

    ; *$39F7B-$3A002 BRANCH LOCATION
    LinkItem_Hammer:
    {
        ; Hammer item code
        
        LDA $0301 : AND.b #$10 : BNE BRANCH_ALPHA
        
        BIT $3A : BVS BRANCH_BETA
        
        LDA $6C : BNE BRANCH_ALPHA
        
        JSR Link_CheckNewY_ButtonPress : BCS BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        BRL BRANCH_$39F58; (AN RTS)
    
    BRANCH_GAMMA:
    
        LDA $9F78 : STA $3D
        
        LDA.b #$01 : TSB $50
        
        STZ $2E
        
        LDA $0301 : AND.b #$00 : ORA.b #$02 : STA $0301
        
        STZ $0300

    BRANCH_BETA:

        JSR $AE65   ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL BRANCH_DELTA
        
        LDA $0300 : INC A : STA $0300 : TAX
        
        LDA $9F78, X : STA $3D
        
        CPX.b #$01 : BNE BRANCH_EPSILON
        
        PHX
        
        LDY.b #$03
        
        JSR $D077   ; $3D077 IN ROM
        
        LDY.b #$00
        LDA.b #$16
        
        JSR AddHitStars
        
        PLX
        
        LDA $012E : BNE BRANCH_EPSILON
        
        LDA.b #$10 : JSR Player_DoSfx2
        
        JSL Player_SpawnSmallWaterSplashFromHammer

    BRANCH_EPSILON:

        CPX.b #$03 : BNE BRANCH_DELTA
        
        STZ $0300
        STZ $3D
        
        LDA $3A : AND.b #$BF : STA $3A
        LDA $50 : AND.b #$FE : STA $50
        
        LDA $0301 : AND.b #$FD : STA $0301

    BRANCH_DELTA:

        RTS
    }

; ==============================================================================

    ; $3A003-$3A005
    pool LinkItem_Bow:
    {
        ; \task Rename the LinkItem "namespace" to PlayerItem
        ; \task Label this data and apply in routine.
        db 3, 3, 8
    }

; ==============================================================================

    ; *$3A006-$3A0BA LONG BRANCH LOCATION
    LinkItem_Bow:
    {
        ; Box and Arrow use code
        
        BIT $3A : BVS BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_$3A002   ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3A002
        
        LDA.b #$01 : TSB $50
        
        LDA $A003 : STA $3D
        
        STZ $2E
        STZ $0300
        
        LDA $0301 : AND.b #$00 : ORA.b #$10 : STA $0301
    
    BRANCH_ALPHA:
    
        JSR $AE65 ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL BRANCH_$3A002
        
        LDA $0300 : INC A : STA $0300 : TAX
        
        LDA $A003, X : STA $3D
        
        CPX.b #$03 : BNE BRANCH_BETA
        
        LDA $20 : STA $72
        LDA $21 : STA $73
        LDA $22 : STA $74
        LDA $23 : STA $75
        
        LDX $2F
        
        ; Spawn arrow
        LDY.b #$02
        LDA.b #$09
        
        JSL AddArrow : BCC BRANCH_GAMMA
        
        LDA $0B99 : BEQ BRANCH_DELTA
        
        DEC $0B99
        
        LDA $7EF377 : INC #2 : STA $7EF377
    
    BRANCH_DELTA:
    
        LDA $0B9A : BNE BRANCH_EPSILON
        
        LDA $7EF377 : BEQ BRANCH_EPSILON
        
        DEC A : STA $7EF377 : BNE BRANCH_GAMMA
        
        JSL HUD.RefreshIconLong
        
        BRA BRANCH_GAMMA
    
    BRANCH_EPSILON:
    
        STZ $0C4A, X
        
        LDA.b #$3C : JSR Player_DoSfx2
    
    BRANCH_GAMMA:
    
        STZ $0300
        STZ $3D
        
        LDA $3A : AND.b #$BF : STA $3A
        LDA $50 : AND.b #$FE : STA $50
        
        LDA $0301 : AND.b #$EF : STA $0301
        
        LDA $3C : CMP.b #$09 : BCC BRANCH_BETA
        
        LDA.b #$09 : STA $3C
    
    ; *$3A0BA ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        RTS
    }

    ; *$3A0BB-$3A137 JUMP LOCATION
    LinkItem_Boomerang:
    {
        ; Boomerang item use code
        BIT $3A : BVS BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_$3A0BA
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_BETA
        
        LDA $035F : BNE BRANCH_BETA
        
        STZ $2E
        
        LDA $0301 : AND.b #$00 : ORA.b #$80 : STA $0301
        
        STZ $0300
        
        LDA.b #$07 : STA $3D
        
        LDY.b #$00
        LDA.b #$05
        
        JSL AddBoomerang
        
        LDA $3C : CMP.b #$09 : BCS BRANCH_GAMMA
        
        LDA $72 : BNE BRANCH_ALPHA
        
        LDA $F0 : AND.b #$0F : STA $26
        
        BRA BRANCH_DELTA
    
    BRANCH_ALPHA:
    
        LDA.b #$01 : TSB $50
    
    BRANCH_DELTA:
    
        LDA $0301 : BEQ BRANCH_GAMMA
        
        JSR $AE65   ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL BRANCH_BETA
        
        LDA.b #$05 : STA $3D
        
        LDA $0300 : INC A : STA $0300 : CMP.b #$02 : BNE BRANCH_BETA
    
    ; *$3A11F ALTERNATE ENTRY POINT
    BRANCH_GAMMA:
    
        STZ $0301
        STZ $0300
        STZ $3D
        
        LDA $3A : AND.b #$BF : STA $3A : AND.b #$80 : BNE BRANCH_BETA
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; *$3A138-$3A15A JUMP LOCATION
    {
        ; Code for laying a bomb
        
        LDA $6C : BNE .cantLayBomb
        
        LDA $7EF3CC : CMP.b #$0D : BEQ .cantLayBomb
        
        JSR Link_CheckNewY_ButtonPress : BCC .cantLayBomb
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDY.b #$01
        LDA.b #$07
        
        JSL AddBlueBomb
        
        STZ $0301
    
    .cantLayBomb
    
        RTS
    }

; ==============================================================================

    ; *$3A15B-$3A249 JUMP LOCATION
    {
        ; Executes when we use a bottle
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3A15A ; (RTS)
        
        LDA $3A : AND.b #$BF : STA $3A
        
        ; Check if we have a bottle or not
        LDA $7EF34F : DEC A : TAX
        
        LDA $7EF35C, X : BEQ BRANCH_$3A15A ; (RTS)
        CMP.b #$03     : BCC BRANCH_ALPHA
        CMP.b #$03     : BEQ BRANCH_BETA
        CMP.b #$04     : BEQ BRANCH_GAMMA
        CMP.b #$05     : BEQ BRANCH_DELTA
        CMP.b #$06     : BEQ BRANCH_EPSILON
        
        BRL BRANCH_XI
    
    BRANCH_EPSILON:
    
        BRL BRANCH_LAMBDA
    
    BRANCH_BETA:
    
        LDA $7EF36C : CMP $7EF36D : BNE BRANCH_ZETA
    
    BRANCH_ALPHA:
    
        BRL BRANCH_$3A955
    
    BRANCH_ZETA:
    
        LDA.b #$02 : STA $7EF35C, X
        
        STZ $0301
        
        LDA.b #$04 : STA $11
        
        LDA $10 : STA $010C
        
        LDA.b #$0E : STA $10
        
        LDA.b #$07 : STA $0208
        
        JSL HUD.RebuildLong
        
        RTS
    
    BRANCH_GAMMA:
    
        LDA $7EF36E : CMP.b #$80 : BNE BRANCH_THETA
        
        BRL BRANCH_$3A955
    
    BRANCH_THETA:
    
        LDA $02 : STA $7EF35C, X
        
        STZ $0301
        
        ; submodule ????
        LDA.b #$08 : STA $11
        
        LDA $10 : STA $010C
        
        ; Go to text mode
        LDA.b #$0E : STA $10
        
        LDA.b #$07 : STA $0208
        
        JSL HUD.RebuildLong
        
        BRA BRANCH_IOTA
    
    BRANCH_DELTA:
    
        LDA $7EF36C : CMP $7EF36D : BNE .useBluePotion
        
        LDA $7EF36E : CMP.b #$80 : BNE .useBluePotion
        
        BRL BRANCH_$3A955
    
    .useBluePotion
    
        LDA.b #$02 : STA $7EF35C, X
        
        STZ $0301
        
        LDA.b #$09 : STA $11
        
        LDA $10 : STA $010C
        
        LDA.b #$0E : STA $10
        
        LDA.b #$07 : STA $0208
        
        JSL HUD.RebuildLong
        
        BRA BRANCH_IOTA
    
    BRANCH_LAMBDA:
    
        STZ $0301
        
        JSL PlayerItem_SpawnFaerie : BPL BRANCH_NU
        
        BRL BRANCH_$3A955
    
    BRANCH_NU:
    
        LDA.b #$02 : STA $7EF35C, X
        
        JSL HUD.RebuildLong
        
        BRA BRANCH_IOTA
    
    BRANCH_XI:
    
        STZ $0301
        
        JSL PlayerItem_ReleaseBee : BPL .bee_spawn_success
        
        BRL BRANCH_$3A955
    
    .bee_spawn_success
    
        LDA.b #$02 : STA $7EF35C, X
        
        JSL HUD.RebuildLong
    
    BRANCH_IOTA:
    
        RTS
    }

; ==============================================================================

    ; \unused Until proven otherwise...
    ; $3A24A-$3A24C DATA
    pool LinkItem_Lamp:
    {
        db $18, $10, $00
    }

; ==============================================================================

    ; *$3A24D-$3A288 LOCAL
    LinkItem_Lamp:
    {
        LDA $6C : BNE .no_input
        
        JSR Link_CheckNewY_ButtonPress : BCC .no_input
        
        ; \item(Lamp)
        LDA $7EF34A : BEQ .cant_use_lamp
        
        LDX.b #$06 : JSR LinkItem_EvaluateMagicCost : BCC .cant_use_lamp
        
        LDY.b #$00
        LDA.b #$1A
        
        JSL AddMagicPowder
        
        JSL Dungeon_LightTorch
        
        LDY.b #$02
        LDA.b #$2F
        
        JSL AddLampFlame
    
    .cant_use_lamp
    
        STZ $0301
        STZ $3A
        STZ $3C
        STZ $50
        
        LDA $3C : CMP.b #$09 : BNE .dont_reset_player_speed
        
        STZ $5E
    
    .dont_reset_player_speed
    .no_input
    
        RTS
    }

; ==============================================================================

    ; *$3A293-$3A312 JUMP LOCATION
    LinkItem_Mushroom:
    LinkItem_MagicPowder:
    {
        BIT $3A : BVS BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_$3A288 ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC .return
        
        LDA $7EF344 : CMP.b #$02 : BEQ .isMagicPowder
        
        LDA.b #$3C : JSR Player_DoSfx2
        
        BRA BRANCH_DELTA
    
    .isMagicPowder
    
        LDX.b #$02
        
        JSR LinkItem_EvaluateMagicCost : BCC BRANCH_DELTA
        
        LDA $A289 : STA $3D
        
        STZ $0300
        STZ $2E
        
        LDA $67 : AND.b #$F0 : STA $67
        
        STZ $0301
        
        LDA.b #$40 : TSB $0301
    
    BRANCH_ALPHA:
    
        STZ $30
        STZ $31
        STZ $67
        STZ $2A
        STZ $2B
        STZ $6B
        
        DEC $3D : BPL .return
        
        LDA $0300 : INC A : STA $0300 : TAX
        
        LDA $A289, X : STA $3D
        
        CPX.b #$04 : BNE BRANCH_EPSILON
        
        LDY.b #$00
        LDA.b #$1A
        
        JSL AddMagicPowder
    
    BRANCH_EPSILON:
    
        CPX.b #$09 : BNE .return
        
        LDA $11 : BNE BRANCH_DELTA
        
        LDY.b #$01
        
        JSR $D077 ; $3D077 IN ROM
        
        BRA BRANCH_DELTA
    
    BRANCH_DELTA:
    
        STZ $0301
        STZ $0300
        
        LDA $3A : AND.b #$BF : STA $3A
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$3A313-$3A31F LOCAL
    LinkItem_ShovelAndFlute:
    {
        ; Play flute or use the shovel
        
        ; What is the state of the flute?
        LDA $7EF34C : BEQ LinkItem_MagicPowder.return
        CMP.b #$01  : BEQ LinkItem_Shovel
                      BRL LinkItem_Flute
    }

; ==============================================================================

    ; *$3A32C-$3A3DA LONG BRANCH LOCATION
    LinkItem_Shovel:
    {
        ; Shovel item code
        
        BIT $3A : BVS BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_$3A312 ; (RTS, BASICALLY)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3A312
        
        LDA $A320 : STA $3D
        
        STZ $030D
        STZ $0300
        
        LDA.b #$01 : STA $037A
        
        LDA.b #$01 : TSB $50
        
        STZ $2E
    
    BRANCH_ALPHA:
    
        JSR $AE65 ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BMI BRANCH_BETA
        
        RTS
    
    BRANCH_BETA:
    
        LDX $030D : INX : STX $030D
        
        LDA $A320, X : STA $3D
        
        LDA $A326, X : STA $0300 : CMP.b #$01 : BNE BRANCH_GAMMA
        
        LDY.b #$02
        
        PHX
        
        JSR $D077   ; $3D077 IN ROM
        
        PLX
        
        LDA $04B2 : BEQ BRANCH_DELTA
        
        LDA.b #$1B : JSR Player_DoSfx3
        
        PHX
        
        ; Add recovered flute (from digging). Interesting...
        LDY.b #$00
        LDA.b #$36
        
        JSL AddRecoveredFlute
        
        PLX
    
    BRANCH_DELTA:
    
        LDA $0357 : ORA $035B : AND.b #$01 : BNE BRANCH_EPSILON
        
        PHX
        
        LDY.b #$00
        LDA.b #$16
        
        JSL AddHitStars
        
        PLX
        
        LDA.b #$05 : JSR Player_DoSfx2
        
        BRA BRANCH_GAMMA
    
    BRANCH_EPSILON:
    
        PHX
        
        ; Add shovel dirt? what? I thought these were aftermath tiles
        LDY.b #$00
        LDA.b #$17
        
        JSL AddShovelDirt
        
        LDA $03FC : BEQ .digging_game_inactive
        
        JSL DiggingGameGuy_AttemptPrizeSpawn
    
    .digging_game_inactive
    
        PLX
        
        LDA.b #$12 : JSR Player_DoSfx2
    
    BRANCH_GAMMA:
    
        CPX.b #$03 : BNE .return
        
        STZ $030D
        STZ $0300
        
        LDA $3A : AND.b #$80 : STA $3A
        
        STZ $037A
        
        LDA $50 : AND.b #$FE : STA $50
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$3A3DB-$3A45E LONG BRANCH LOCATION
    LinkItem_Flute:
    {
        ; Code for the flute item (with or without the bird activated)
        
        BIT $3A : BVC .y_button_not_held
        
        DEC $03F0 : LDA $03F0 : BNE LinkItem_Shovel.return
        
        LDA $3A : AND.b #$BF : STA $3A
    
    .y_button_not_held
    
        JSR Link_CheckNewY_ButtonPress : BCC LinkItem_Shovel.return
        
        ; Success... play the flute.
        LDA.b #$80 : STA $03F0
        
        LDA.b #$13 : JSR Player_DoSfx2
        
        ; Are we indoors?
        LDA $1B : BNE LinkItem_Shovel.return
        
        ; Are we in the dark world? The flute doesn't work there.
        LDA $8A : AND.b #$40 : BNE LinkItem_Shovel.return
        
        ; Also doesn't work in special areas like Master Sword area.
        LDA $10 : CMP.b #$0B : BEQ LinkItem_Shovel.return
        
        LDX.b #$04
    
    .next_ancillary_slot
    
        ; Is there already a travel bird effect in this slot?
        LDA $0C4A, X : CMP.b #$27 : BEQ LinkItem_Shovel.return
        
        ; If there isn't one, keep checking.
        DEX : BPL .next_ancillary_slot
        
        ; Paul's weathervane stuff Do we have a normal flute (without bird)?
        LDA $7EF34C : CMP.b #$02 : BNE .travel_bird_already_released
        
        REP #$20
        
        ; check the area, is it #$18 = 30?
        LDA $8A : CMP.w #$0018 : BNE .not_weathervane_trigger
        
        ; Y coordinate boundaries for setting it off.
        LDA $20
        
        CMP.w #$0760 : BCC .not_weathervane_trigger
        CMP.w #$07E0 : BCS .not_weathervane_trigger
        
        ; do if( (Ycoord >= 0x0760) && (Ycoord < 0x07e0
        LDA $22
        
        CMP.w #$01CF : BCC .not_weathervane_trigger
        CMP.w #$0230 : BCS .not_weathervane_trigger
        
        ; do if( (Xcoord >= 0x1cf) && (Xcoord < 0x0230)
        SEP #$20
        
        ; Apparently a special Overworld mode for doing this?
        LDA.b #$2D : STA $11
        
        ; Trigger the sequence to start the weathervane explosion.
        LDY.b #$00
        LDA.b #$37
        
        JSL AddWeathervaneExplosion
    
    .not_weathervane_trigger
    
        SEP #$20
        
        BRA .return
    
    .travel_bird_already_released
    
        LDY.b #$04
        LDA.b #$27
        
        JSL AddTravelBird
        
        STZ $03F8
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$3A45F-$3A470 LONG
    GanonEmerges_SpawnTravelBird:
    {
        PHB : PHK : PLB
        
        LDA.b #$13 : JSR Player_DoSfx2
        
        ; Add travel bird
        LDY.b #$04
        LDA.b #$27
        
        JSL AddTravelBird
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3A471-$3A493 JUMP LOCATION
    {
        ; Book of Mudora (0x0B)
        
        BIT $3A : BVS BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_$3A45E ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_ALPHA
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDA $02ED : BNE BRANCH_BETA
        
        LDA.b #$3C : JSR Player_DoSfx2
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        BRL BRANCH_$3AA6C
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$3A494-$3A4F6 JUMP LOCATION
    LinkItem_EtherMedallion:
    {
        JSR Link_CheckNewY_ButtonPress : BCC .cant_cast_no_sound
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDA $6C : BNE .cant_cast_play_sound
        
        LDA $0FFC : BNE .cant_cast_play_sound
        
        LDA $0403 : AND.b #$80 : BNE .cant_cast_play_sound
        
        LDA $7EF359 : INC A : AND.b #$FE : BEQ .cant_cast_play_sound
        
        LDA $7EF3D3 : BEQ .attempt_cast
        
        LDA $7EF3CC : CMP.b #$0D : BNE .attempt_cast
    
    .cant_cast_play_sound
    
        BRL BRANCH_$3A955
    
    .attempt_cast
    
        LDA $0C4A : ORA $0C4B : ORA $0C4C : BNE .cant_cast_no_sound
        
        LDX.b #$01 : JSR LinkItem_EvaluateMagicCost : BCC .cant_cast_no_sound
        
        LDA.b #$08 : STA $5D
        
        LDA.b #$01 : TSB $50
        
        LDA $A503 : STA $3D
        
        STZ $031C
        STZ $031D
        STZ $0324
        
        LDA.b #$23 : JSR Player_DoSfx3
    
    .cant_cast_no_sound
    
        RTS
    }

    ; $3A4F7-$03A502 DATA TABLE
    {
        db $00, $01, $02, $03
        db $00, $01, $02, $03
        db $04, $05, $06, $07
    }

    ; $3A503-$3A50E DATA TABLE
    {
        db $05, $05, $05, $05
        db $05, $05, $05, $05
        db $07, $07, $03, $03
    }

    ; *$3A50F-$3A568 JUMP LOCATION
    {
        ; ETHER MEDALLION MODE
        
        INC $0FC1
        
        DEC $3D : BPL BRANCH_ALPHA
        
        INC $031D : LDX $031D : CPX.b #$0B : BNE BRANCH_BETA
        
        LDX.b #$0B
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        CPX.b #$04 : BNE BRANCH_DELTA
        
        PHX
        
        LDA.b #$23 : JSR Player_DoSfx3
        
        PLX
    
    BRANCH_DELTA:
    
        CPX.b #$09 : BNE BRANCH_EPSILON
        
        LDA.b #$2C : JSR Player_DoSfx2
    
    BRANCH_EPSILON:
    
        CPX.b #$0C : BNE BRANCH_GAMMA
        
        LDA.b #$0A : STA $031D : TAX
    
    BRANCH_GAMMA:
    
        LDA $A503, X : STA $3D
        
        LDA $A4F7, X : STA $031C
        
        LDA $0324 : BNE BRANCH_ALPHA
        
        CPX.b #$0A : BNE BRANCH_ALPHA
        
        LDA.b #$01 : STA $0324
        
        LDY.b #$00
        LDA.b #$18
        
        JSL AddEtherSpell
        
        STZ $4D
        STZ $0046
    
    BRANCH_ALPHA:
    
        RTS
    }

    ; *$3A569-$3A5CE JUMP LOCATION
    {
        ; Bombos medallion (0x0E)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_ALPHA
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDA $6C : BNE BRANCH_BETA
        
        LDA $0FFC : BNE BRANCH_BETA
        
        LDA $0403 : AND.b #$80 : BNE BRANCH_BETA
        
        LDA $7EF359 : INC A : AND.b #$FE : BEQ BRANCH_BETA
        
        LDA $7EF3D3 : BEQ BRANCH_GAMMA
        
        LDA $7EF3CC : CMP.b #$0D : BNE BRANCH_GAMMA

    BRANCH_BETA:

        BRL BRANCH_$3A955

    BRANCH_GAMMA:

        LDA $0C4A : ORA $0C4B : ORA $0C4C : BNE BRANCH_ALPHA
        
        LDX.b #$01
        
        JSR LinkItem_EvaluateMagicCost : BCC BRANCH_ALPHA
        
        LDA.b #$09 : STA $5D
        
        LDA.b #$01 : TSB $50
        
        LDA $A5E3 : STA $3D
        
        LDA $A5CF : STA $031C
        
        STZ $031D
        STZ $0324
        
        LDA.b #$23 : JSR Player_DoSfx3

    BRANCH_ALPHA:

        RTS
    }

    ; *$3A5F7-$3A64A JUMP LOCATION
    {
        ; BOMBOS MEDALLION MODE
        
        INC $0FC1
        
        DEC $3D : BPL BRANCH_ALPHA
        
        INC $031D : LDX $031D : CPX.b #$04 : BNE BRANCH_BETA
        
        PHX
        
        LDA.b #$23 : JSR Player_DoSfx3
        
        PLX
    
    BRANCH_BETA:
    
        CPX.b #$0A : BNE BRANCH_GAMMA
        
        PHX
        
        LDA.b #$2C : JSR Player_DoSfx2
        
        PLX
    
    BRANCH_GAMMA:
    
        CPX.b #$14 : BNE BRANCH_DELTA
        
        LDA.b #$13 : STA $031D : TAX
    
    BRANCH_DELTA:
    
        LDA $A5E3, X : STA $3D
        
        LDA $A5CF, X : STA $031C
        
        LDA $0324 : BNE BRANCH_ALPHA
        
        CPX.b #$13 : BNE BRANCH_ALPHA
        
        LDA.b #$01 : STA $0324
        
        LDY.b #$00
        LDA.b #$19
        
        JSR AddBombosSpell
        
        STZ $4D
        STZ $0046
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$3A64B-$3A6BD JUMP LOCATION
    LinkItem_Quake:
    {
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_ALPHA
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDA $6C : BNE BRANCH_BETA
        
        LDA $0FFC : BNE BRANCH_BETA
        
        LDA $0403 : AND.b #$80 : BNE BRANCH_BETA
        
        LDA $7EF359 : INC A : AND.b #$FE : BEQ BRANCH_BETA
        
        LDA $7EF3D3 : BEQ BRANCH_GAMMA
        
        LDA $7EF3CC : CMP.b #$0D : BNE BRANCH_GAMMA
    
    BRANCH_BETA:
    
        BRL BRANCH_$3A955
    
    BRANCH_GAMMA:
    
        LDA $0C4A : ORA $0C4B : ORA $0C4C : BNE BRANCH_ALPHA
        
        LDX.b #$01
        
        JSR LinkItem_EvaluateMagicCost : BCC BRANCH_ALPHA
        
        LDA.b #$0A : STA $5D
        
        LDA.b #$01 : TSB $50
        
        LDA $A6CA : STA $3D
        
        LDA $A6BE : STA $031C
        
        STZ $031D
        STZ $0324
        STZ $46
        
        LDA.b #$28 : STA $0362 : STA $0363
        
        STZ $0364
        
        LDA.b #$23 : JSR Player_DoSfx3
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; *$3A6D6-$3A779 JUMP LOCATION
    {
        ; QUAKE MEDALLION CODE
        
        INC $0FC1
        
        STZ $27
        STZ $28
        
        LDA $031D : CMP.b #$0A : BNE BRANCH_ALPHA
        
        LDA $0362 : STA $29
        
        LDA $0363 : STA $02C7
        
        LDA $0364 : STA $24
        
        LDA.b #$02 : STA $00 : STA $4D
        
        JSR $8932   ; $38932 IN ROM
        JSL $07E370 ; $3E370 IN ROM
        
        LDA $29 : STA $0362
        
        LDA $02C7 : STA $0363
        
        LDA $24 : STA $0364 : BMI BRANCH_BETA
        
        LDY.b #$14
        
        LDA $29 : BPL BRANCH_GAMMA
        
        LDY.b #$15
    
    BRANCH_GAMMA:
    
        STY $031C
        
        BRA BRANCH_DELTA
    
    BRANCH_ALPHA:
    
        DEC $3D : BPL BRANCH_DELTA
    
    BRANCH_BETA:
    
        INC $031D
        
        LDX $031D : CPX.b #$04 : BNE BRANCH_EPSILON
        
        PHX
        
        LDA.b #$23 : JSR Player_DoSfx3
        
        PLX
    
    BRANCH_EPSILON:
    
        CPX.b #$0A : BNE BRANCH_ZETA
        
        PHX
        
        LDA.b #$2C : JSR Player_DoSfx2
        
        PLX
    
    BRANCH_ZETA:
    
        CPX.b #$0B : BNE BRANCH_THETA
        
        LDA.b #$0C : JSR Player_DoSfx2
    
    BRANCH_THETA:
    
        CPX.b #$0C : BNE BRANCH_IOTA
        
        LDA.b #$0B : STA $031D : TAX
    
    BRANCH_IOTA:
    
        LDA $A6CA, X : STA $3D
        
        LDA $A6BE, X : STA $031C
        
        LDA $0324 : BNE BRANCH_DELTA
        
        CPX.b #$0B : BNE BRANCH_DELTA
        
        ; "Thank you, [Name], I had a feeling you were getting close" Message
        LDA.b #$01 : STA $0324
        
        LDY.b #$00
        LDA.b #$1C
        
        JSL AddQuakeSpell
        
        STZ $4D
        STZ $0046
    
    BRANCH_DELTA:
    
        RTS
    }

    ; *$3A77A-$3A7AF LONG BRANCH LOCATION
    {
        LDY.b #$00 : TYX
        
        LDA $2A
        
        JSL AddSpinAttackStartSparkle
    
    ; *$3A7B3 ALTERNATE ENTRY POINT
    
        ; Enter spin attack mode.
        LDA.b #$03 : STA $5D
        
        LDA $2F : LSR A : TAX
        
        LDA $A800, X : STA $031E : TAX
        
        LDA $A7E8 : STA $3D
        
        LDA $A7B8, X : STA $031C : STA $031D, X
        
        ; Trigger the spin attack motion.
        LDA.b #$90 : STA $3C
        
        LDA.b #$01 : TSB $50
        
        LDA.b #$80 : STA $3A
        
        BRL BRANCH_$3A804 ; GO TO SPIN ATTACK MODE
    
    .unused
    
        RTS
    }

    ; *$3A7B0-$3A7B7 LONG
    {
        PHB : PHK : PLB
        
        JSR $A783 ; $3A783 IN ROM
        
        PLB
        
        RTL
    }

    ; *$3A804-$3A8EB JUMP LOCATION
    {
        ; Link mode 0x03 - Spin Attack Mode
        
        JSR $F514 ; $3F514 IN ROM
        
        ; Check to see if Link is in a ground state.
        LDA $4D : BEQ BRANCH_ALPHA
        
        LDX.b #$04
        ; He isn't.
    
    BRANCH_DELTA:
    
        LDA $0C4A, X
        
        CMP.b #$2A : BEQ BRANCH_BETA
        CMP.b #$2B : BNE BRANCH_GAMMA
    
    BRANCH_BETA:
    
        STZ $0C4A, X
    
    BRANCH_GAMMA:
    
        DEX : BPL BRANCH_DELTA
        
        STZ $25
        
        LDA $50 : AND.b #$FE : STA $50
        
        STZ $3D
        STZ $3C
        STZ $3A
        STZ $3B
        STZ $031C
        STZ $031D
        STZ $5E
        
        LDA $1B : BNE BRANCH_EPSILON
    
    BRANCH_EPSILON:
    
        LDA $0360 : BEQ BRANCH_ZETA
        
        LDA $55 : BEQ BRANCH_THETA
        
        JSR $AE54   ; $3AE54 IN ROM
    
    BRANCH_THETA:
    
        JSR $9D84   ; $39D84 IN ROM
        
        LDA.b #$01 : STA $037B
        
        STZ $0300
        
        LDA.b #$02 : STA $3D
        
        STZ $2E
        
        LDA $67 : AND.b #$F0 : STA $67
        
        LDA.b #$2B : JSR Player_DoSfx3
        
        LDA.b #$07 : STA $5D
        
        BRL Player_Electrocution
    
    BRANCH_ZETA:
    
        LDA.b #$02 : STA $5D
        
        BRL BRANCH_$386B5 ; GO TO RECOIL MODE
    
    BRANCH_ALPHA:
    
        LDA $46 : BEQ BRANCH_IOTA ; Link's movement data is being taken in.
        
        JSR $8711   ; $38711 IN ROM Link Can't move, do some other stuff.
        
        BRA BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        STZ $67 ; Not sure...
        
        JSL $07E245 ; $3E245 IN ROM
        JSR $B7C7   ; $3B7C7 IN ROM
        
        LDA.b #$03 : STA $5D
        
        STZ $0302
        
        JSR $E8F0 ; $3E8F0 IN ROM
    
    BRANCH_KAPPA:
    
        ; do we have to wait?
        DEC $3D : BPL BRANCH_LAMBDA; You need to wait to spin attack still...
        
        ; Step Link through the animation.
        ; On the second motion begin the spinning sound.
        LDA $031D : INC A : STA $031D : CMP.b #$02 : BNE BRANCH_MU
        
        LDA.b #$23 : JSR Player_DoSfx3
    
    BRANCH_MU:
    
        LDA $031D : CMP.b #$0C : BNE BRANCH_NU
        
        ; Do this if on the 12th step.
        LDA $50 : AND.b #$FE : STA $50
        
        STZ $3D
        STZ $3C
        STZ $031C
        STZ $031D
        
        LDA $5D : CMP.b #$1E : BEQ BRANCH_XI
        
        LDX.b #$00
        
        LDA $3C : BEQ BRANCH_OMICRON
        
        LDA $F0 : AND.b #$80 : TAX
    
    BRANCH_OMICRON:
    
        STX $3A
    
    BRANCH_XI:
    
        LDA.b #$00 : STA $5D
        
        BRA BRANCH_LAMBDA
    
    BRANCH_NU:
    
        ; $031E IS TYPICALLY 12, I.E. #$C
        LDA $031D : ADD $031E : TAX
        
        ; Determine which graphic to display while spinning.
        LDA $A7B8, X : STA $031C
        
        LDX $031D
        
        ; Determine the frame delay between changing the sprites.
        LDY $A7F4, X : STY $3D
        
        LDY.b #$08
        
        JSR $D077 ; $3D077 IN ROM
    
    BRANCH_LAMBDA:
    
        RTS
    }

    ; $3A8EC-$3A919 BLOCK
    {
        LDY.b #$00
        LDX.b #$01
        LDA.b #$2A
        
        JSL AddSpinAttackStartSparkle
        
        LDA.b #$1E : STA $5D
        
        LDA $2F : LSR A : TAX
        
        LDA $A800, X : STA $031E : TAX
        
        LDA $A7E8 : STA $3D
        
        LDA $A7B8, X : STA $031C
        
        STZ $031D
        
        LDA.b #$01 : TSB $50
        
        BRL BRANCH_$3A804 ; GO TO SPIN ATTACK MODE
    }

    ; *$3A91A-$3A9B0 JUMP LOCATION
    LinkItem_Mirror:
    {
        ; Magic Mirror routine
        
        ; Check for a press of the Y button.
        BIT $3A : BVS BRANCH_ALPHA
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3A8EB
        
        ; Seems the Kiki tagalong prevents you from warping?
        LDA $7EF3CC : CMP.b #$0A : BNE BRANCH_ALPHA
        
        REP #$20
        
        ; Probably Kiki bitching at you not to warp.
        LDA.w #$0121 : STA $1CF0
        
        SEP #$20
        
        JSL Main_ShowTextMessage
        
        BRL .cantWarp
    
    BRANCH_ALPHA: ; Y Button pressed.
    
        ; Erase all input except for the Y button.
        LDA $3A : AND.b #$BF : STA $3A
        
        ; If Link's standing in a doorway he can't warp
        LDA $6C : BNE BRANCH_BETA
        
        LDA $037F : BNE BRANCH_GAMMA
        
        ; Am I indoors?
        LDA $1B : BNE BRANCH_GAMMA
        
        ; Check if we're in the dark world.
        LDA $8A : AND.b #$40 : BNE BRANCH_GAMMA
    
    ; *$3A955 ALTERNATE ENTRY POINT
    BRANCH_BETA:
    
        ; Play the "you can't do that" sound.
        LDA.b #$3C : JSR Player_DoSfx2
        
        BRA .cantWarp
    
    ; *$3A95C ALTERNATE ENTRY POINT
    BRANCH_GAMMA:
    
        LDA $1B : BEQ .outdoors
        
        LDA $0FFC : BNE .cantWarp
        
        JSL Dungeon_SaveRoomData ; $121B1 IN ROM
        
        LDA $012E : CMP.b #$3C : BEQ .cantWarp
        
        STZ $05FC
        STZ $05FD
        
        BRA .cantWarp
    
    .outdoors
    
        LDA $10 : CMP.b #$0B : BEQ .inSpecialOverworld
        
        LDA $8A : AND.b #$40 : STA $7B : BEQ .inLightWorld
        
        ; If we're warping from the dark world to the light world
        ; we generate new coordinates for the warp vortex
        LDA $20 : STA $1ADF
        LDA $21 : STA $1AEF
        
        LDA $22 : STA $1ABF
        LDA $23 : STA $1ACF
    
    .inLightWorld
    
        LDA.b #$23
    
    ; *$3A99C ALTERNATE ENTRY POINT
    
        STA $11
        
        STZ $03F8
        
        LDA.b #$01 : STA $02DB
        
        STZ $B0
        STZ $27
        STZ $28
        
        ; Go into magic mirror mode.
        LDA.b #$14 : STA $5D
    
    .cantWarp
    .inSpecialOverworld
    
        RTS
    }

; ==============================================================================

    ; *$3A9B1-$3AA6B JUMP LOCATION
    {
        ; Link Mode 0x14 MAGIC MIRROR (And / or Whirpool warping?)
        
        JSL $07F1E6 ; $3F1E6 IN ROM
        JSR $D6F4   ; $3D6F4 IN ROM
        
        LDA $8A : AND.b #$40 : CMP $7B : BNE BRANCH_ALPHA
        
        BRL BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $0C : ORA $0E : STA $00 : AND.b #$0C : BEQ BRANCH_BETA
        
        ; Could have just used BIT, ya know.
        LDA $00 : AND.b #$03 : BNE BRANCH_GAMMA
        LDA $00 : AND.b #$0F : BEQ BRANCH_BETA
        
        LDX.b #$03
        LDY.b #$00
    
    BRANCH_EPSILON:
    
        LSR A : BCC BRANCH_DELTA
        
        INY
    
    BRANCH_DELTA:
    
        DEX : BPL BRANCH_EPSILON
        
        CPY.b #$02 : BCC BRANCH_BETA
    
    BRANCH_GAMMA:
    
        ; Signal a warp failure and send Link back to the world he came from
        LDA.b #$2C
        
        BRA BRANCH_3A99C
    
    BRANCH_BETA:
    
        LDY.b #$00
        LDX.b #$03
        
        LDA $0341
    
    .checkNextDeepWaterBit
    
        LSR A : BCC .deepWaterBitNotSet
        
        INY
    
    .deepWaterBitNotSet
    
        DEX : BPL .checkNextDeepWaterBit
        
        CPY.b #$02 : BCC BRANCH_KAPPA
        
        LDA $7EF356 : BNE .haveFlippers
        
        LDA $8A : AND.b #$40 : CMP $7B : BNE BRANCH_GAMMA
        
        JSL Link_CheckSwimCapability
        
        BRA BRANCH_KAPPA
    
    .haveFlippers
    
        LDA.b #$01 : STA $0345
        
        LDA $26 : STA $0340
        
        JSL Player_ResetSwimState
        
        LDA.b #$04 : STA $5D
        
        JSR $AE54 ; $3AE54 IN ROM
        
        STZ $5E
        
        BRA BRANCH_MU
    
    BRANCH_KAPPA:
    
        LDA $0345 : BEQ BRANCH_NU
        
        STZ $0345
        
        LDA $0340 : STA $26
    
    BRANCH_NU:
    
        STZ $0374
        STZ $0372
        STZ $5E
        STZ $3A
        STZ $3C
        STZ $50
        STZ $032B
        STZ $27
        
        LDA $8A : AND.b #$40 : CMP $7B : BEQ BRANCH_XI
        
        STZ $04AC
        STZ $04AD
    
    BRANCH_XI:
    
        LDY.b #$00
        
        LDA $7EF357 : BNE .playerHasMoonPearl
        
        LDA $8A : AND.b #$40 : BEQ .inLightWorld
        
        LDY.b #$17
    
    .playerHasMoonPearl
    .inLightWorld
    
        STY $5D
    
    BRANCH_MU:
    
        RTS
    }

; ==============================================================================

    ; *$3AA6C-$3AAA1 JUMP LOCATION LOCAL
    {
        ; Begin moving the Desert Palace barricades
        ; Put us in submodule 5 of text mode.
        LDA.b #$05 : STA $11
        
        LDA $10 : STA $010C
        
        ; Go to text mode
        LDA.b #$0E : STA $10
        
        LDA.b #$01 : STA $0FC1
        LDA.b #$16 : STA $030B
        
        STZ $030A
        
        LDA.b #$02 : STA $0308
        
        ; Lock Link's direction
        LDA.b #$01 : TSB $50
        
        STZ $2E
        
        ; Make it so Link is considered to not be walking at all.
        LDA $67 : AND.b #$F0 : STA $67
        
        ; Play that sad sanctuary-esque tune while the bubble comes up.
        LDA.b #$11 : STA $012D
        
        LDA.b #$F2 : STA $012C ; Halve the normal music's volume.
        
        RTS
    }

    ; *$3AAA2-$3AB24 LONG
    {
        PHB : PHK : PLB
        
        LDY.b #$00
        
        JSR $D077 ; $3D077 IN ROM
        
        STZ $2E
        
        LDA $7EF3CC : CMP.b #$0C : BEQ .thiefChest
                      CMP.b #$0D : BNE .notSuperBomb
        
        LDA.b #$FE : STA $04B4
        
        STZ $04B5
    
    .thiefChest
    
        ; Super bomb related
        LDA $7EF3D3 : BEQ .checkPlayerPoofPotential
        
        LDA.b #$00 : STA $7EF3D3
        
        BRA .terminateTagalong
    
    .notSuperBomb
    
        LDA $7EF3CC : CMP.b #$09 : BEQ .terminateTagalong
                      CMP.b #$0A : BNE .preserveTagalong
    
    .terminateTagalong
    
        LDA.b #$00 : STA $7EF3CC
        
        BRA .checkPlayerPoofPotential
    
    .preserveTagalong
    
        LDY.b #$07 : LDA $7EF3CC : CMP.b #$08 : BEQ .isDwarf
        LDY.b #$08               : CMP.b #$07 : BNE .checkPlayerPoofPotential
    
    .isDwarf
    
        TYA : STA $7EF3CC
        
        JSL Tagalong_LoadGfx
        
        LDY.b #$04
        LDA.b #$40
        
        JSL AddDwarfTransformationCloud
    
    .checkPlayerPoofPotential
    
        ; moon pearl
        LDA $7EF357 : BNE .hasMoonPearl
        
        LDY.b #$04
        LDA.b #$23
        
        JSL AddWarpTransformationCloud
        JSR $AE54   ; $3AE54 IN ROM
        
        STZ $02E2
        
        BRA .return
    
    .hasMoonPearl
    
        LDA $55 : BEQ .return
        
        JSR $AE47 ; $3AE47 IN ROM
        
        STZ $02E2
    
    .return
    
        PLB
        
        RTL
    }

    ; *$3AB25-$3AB6B JUMP LOCATION
    {
        LDA $3A : AND.b #$40 : BNE BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_ALPHA
        
        LDA $48 : AND.b #$02 : BNE BRANCH_ALPHA
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_ALPHA
        
        JSR Player_ResetSwimCollision
        
        STZ $0300
        
        LDA.b #$01 : TSB $50
        
        LDA.b #$07 : STA $3D
        
        STZ $2E
        
        LDA $67 : AND.b #$F0 : STA $67
        
        LDA $037A : AND.b #$00 : ORA.b #$04 : STA $037A
        
        ; hoooookshot
        LDA.b #$13 : STA $5D
        
        LDA.b #$01 : STA $037B
        
        LDY.b #$03
        LDA.b #$1F
        
        JSL AddHookshot
    
    BRANCH_ALPHA:
    
        RTS
    }

; *$3AB7C-$3ADBD JUMP LOCATION
{
    ; Link mode 0x13 - Hookshot
    
    STZ $0373
    STZ $4D
    STZ $46
    
    LDX.b #$04

BRANCH_BETA:

    LDA $0C4A, X : CMP.b #$1F : BEQ BRANCH_ALPHA
    
    DEX : BPL BRANCH_BETA
    
    DEC $3D : LDA $3D : BPL BRANCH_$3AB6B; (RTS)
    
    STZ $0300
    STZ $037B
    
    LDA $3A : AND.b #$BF : STA $3A
    LDA $50 : AND.b #$FE : STA $50
    
    LDA $037A : AND.b #$FB : STA $037A
    
    LDA.b #$00 : STA $5D
    
    LDA $3C : CMP.b #$09 : BCC BRANCH_GAMMA
    
    LDA.b #$09 : STA $3C

BRANCH_GAMMA:

    RTS

BRANCH_ALPHA:

    DEC $3D : BPL BRANCH_DELTA
    
    STZ $3D

BRANCH_DELTA:

    LDA $037E : BNE BRANCH_EPSILON
    
    LDA $20 : STA $3E
    LDA $22 : STA $3F
    
    STZ $30
    STZ $31
    
    BRL BRANCH_$3B7C7

BRANCH_EPSILON:

    STZ $02F5
    
    LDX $039D
    
    DEC $0C5E, X : BPL BRANCH_ZETA
    
    STZ $0C5E, X
    
    BRL BRANCH_XI

BRANCH_ZETA:

    LDA $0BFA, X : STA $00
    LDA $0C0E, X : STA $01
    
    LDA $0C04, X : STA $02
    LDA $0C18, X : STA $03
    
    LDY $0C72, X
    
    STZ $05
    
    LDA $AB6C, Y : STA $04 : BPL BRANCH_THETA
    
    LDA.b #$FF : STA $05

BRANCH_THETA:

    STZ $07
    
    LDA $AB70, Y : STA $06 : BPL BRANCH_IOTA
    
    LDA.b #$FF : STA $07

BRANCH_IOTA:

    STZ $27
    STZ $28
    
    LDA $AB74, Y : STA $08 : STZ $09
    LDA $AB78, Y : STA $0A : STZ $0B
    
    REP #$20
    
    LDA $00 : ADD $04 : SUB $20 : BPL BRANCH_KAPPA
    
    EOR.w #$FFFF : INC A

BRANCH_KAPPA:

    CMP.w #$0002 : BCC BRANCH_LAMBDA
    
    LDA $27 : AND.w #$FF00 : ORA $08 : STA $27

BRANCH_LAMBDA:

    LDA $02 : ADD $06 : SUB $22 : BPL BRANCH_MU
    
    EOR.w #$FFFF : INC A

BRANCH_MU:

    CMP.w #$0002 : BCC BRANCH_NU
    
    LDA $28 : AND.w #$FF00 : ORA $0A : STA $28

BRANCH_NU:

    SEP #$20
    
    LDA $27 : ORA $28 : BEQ BRANCH_XI
    
    BRL BRANCH_PSI

BRANCH_XI:

    ; Terminate the hookshot object if we have reached our destination.
    LDX $039D
    
    STZ $0C4A, X
    
    LDA $02D3 : STA $02D1
    
    LDA.b #$00 : STA $5D
    
    STZ $0300
    STZ $3D
    STZ $037E
    
    LDA $3A : AND.b #$BF : STA $3A
    
    LDA $50 : AND.b #$FE : STA $50
    
    LDA $037A : AND.b #$FB : STA $037A
    
    STZ $037B
    
    LDA $03A4, X : BEQ BRANCH_OMICRON
    
    LDA $0476 : EOR.b #$01 : STA $0476
    
    DEC $A4
    
    LDA $044A : BNE BRANCH_PI
    
    LDA $A0 : STA $048E
    
    ADD.b #$10 : STA $A0

BRANCH_PI:

    LDA $044A : CMP.b #$02 : BEQ BRANCH_RHO
    
    LDA $EE : EOR.b #$01 : STA $EE

BRANCH_RHO:

    JSL Dungeon_SaveRoomQuadrantData

BRANCH_OMICRON:

    JSR Player_TileDetectNearby
    
    LDA $0341 : AND.b #$0F : BEQ BRANCH_SIGMA
    
    LDA $0345 : BNE BRANCH_SIGMA
    
    LDA.b #$01 : STA $0345
    
    LDA $26 : STA $0340
    
    JSL Player_ResetSwimState
    
    LDA.b #$15
    LDY.b #$00
    
    JSL AddTransitionSplash ; $498FC IN ROM
    
    LDA.b #$04 : STA $5D
    
    JSR $AE54   ; $3AE54 IN ROM
    
    STZ $0308
    STZ $0309
    STZ $0376
    STZ $5E
    
    LDA $1B : BEQ BRANCH_TAU
    
    LDA.b #$01 : STA $EE

BRANCH_TAU:

    BRA BRANCH_UPSILON

BRANCH_SIGMA:

    LDA $59 : AND.b #$0F : BEQ BRANCH_PHI
    
    LDA.b #$09 : STA $5C
    
    STZ $5A
    
    LDA.b #$01 : STA $5B
    LDA.b #$01 : STA $5D
    
    BRA BRANCH_UPSILON

BRANCH_PHI:

    LDA $20 : STA $3E
    LDA $22 : STA $3F
    LDA $21 : STA $40
    LDA $23 : STA $41
    
    JSR $B7C7   ; $3B7C7 IN ROM
    
    BRL BRANCH_ALIF

BRANCH_UPSILON:

    LDA $3C : CMP.b #$09 : BCC BRANCH_CHI
    
    LDA.b #$09 : STA $3C

BRANCH_CHI:

    BRL BRANCH_THEL

BRANCH_PSI:

    JSL $07E370 ; $3E370 IN ROM
    
    LDY.b #$05
    
    JSR $D077   ; $3D077 IN ROM
    
    LDA $1B : BEQ BRANCH_OMEGA
    
    LDA $036D : LSR #4 : ORA $036D : ORA $036E : AND.b #$01 : BEQ BRANCH_OMEGA
    
    DEC $03F9 : BPL BRANCH_OMEGA
    
    LDA.b #$03 : STA $03F9
    
    LDA $037E : EOR.b #$02 : STA $037E

BRANCH_OMEGA:

    STZ $0351
    
    LDA $037E : AND.b #$02 : BNE BRANCH_ALIF
    
    LDA $0357 : AND.b #$01 : BEQ BRANCH_BET
    
    LDA.b #$02 : STA $0351
    
    ; $3D2C6 IN ROM
    JSR $D2C6 : BCS BRANCH_ALIF
    
    LDA.b #$1A : JSR Player_DoSfx2
    
    BRA BRANCH_ALIF

BRANCH_BET:

    LDA $0359 : ORA $0341 : AND.b #$01 : BEQ BRANCH_ALIF
    
    INC $0351
    
    LDA $8A : CMP.b #$70 : BNE BRANCH_DEL
    
    LDA.b #$1B : JSR Player_DoSfx2
    
    BRA BRANCH_ALIF

BRANCH_DEL:

    LDA.b #$1C : JSR Player_DoSfx2

BRANCH_ALIF:

    JSR $E8F0 ; $3E8F0 IN ROM
    
BRANCH_THEL:

    RTS
}

; ==============================================================================

    ; $3ADBE-$3ADC0 DATA
    pool LinkItem_Cape:
    {
    
    .mp_depletion_timers
        ; \note Higher timers mean it takes longer for a point of magic power
        ; to be consumed by the cape. Also note that the 1/4th magic consumption
        ; status isn't any better than 1/2 in this case.
        db 4, 8, 8
    }

; ==============================================================================

    ; *$3ADC1-$3AE61 JUMP LOCATION
    LinkItem_Cape:
    {
        ; Magic Cape routine
        
        ; Is the magic cape already activated?
        LDA $55 : BNE BRANCH_ALPHA
        
        DEC $02E2 : BMI BRANCH_BETA
        
        LDA $67 : AND.b #$F0 : STA $67
        
        BRL BRANCH_$3AE65
    
    BRANCH_BETA:
    
        STZ $02E2
        
        LDA $6C : BNE BRANCH_$3ADBD ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3ADBD
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDA $7EF36E : BEQ BRANCH_$3AE62
        
        STZ $0300
        
        LDA.b #$01 : STA $55
        
        LDA $7EF37B : TAY
        
        LDA $AEBE, Y : STA $4C
        
        LDA.b #$14 : STA $02E2
        
        LDY.b #$04
        LDA.b #$23
        
        JSL AddTransformationCloud
        
        LDA.b #$14 : JSR Player_DoSfx2
        
        BRA BRANCH_EPSILON
    
    BRANCH_ALPHA:
    
        ; Make Link invincible this frame.
        LDA.b #$01 : STA $037B
        
        JSR $AE65 ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67 : DEC $4C
        
        ; Wait this many frames to deplete magic.
        LDA $4C : BNE BRANCH_GAMMA
        
        ; Load Link's magic power reserves.
        LDA $7EF37B : TAY
        
        ; Load the next delay timer
        LDA .mp_depletion_timers, Y : STA $4C
        
        ; If the magic counter has totally depleted, branch.
        LDA $7EF36E : DEC A : STA $7EF36E : BEQ BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        DEC $02E2 : BPL BRANCH_EPSILON
        
        STZ $02E2
        
        ; Check the Y button.
        LDA $F4 : AND.b #$40 : BEQ BRANCH_EPSILON
    
    ; *$3AE47 ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        LDY.b #$04
        LDA.b #$23
        
        JSL AddTransformationCloud
        
        LDA.b #$15 : JSR Player_DoSfx2
    
    ; *$3AE54 ALTERNATE ENTRY POINT
    
        LDA.b #$20 : STA $02E2
        
        STZ $037B
        STZ $55
        STZ $0360
    
    BRANCH_EPSILON:
    
        RTS
    }

; ==============================================================================

    ; *$3AE62-$3AE64 BRANCH LOCATION
    {
        BRL BRANCH_$3B0D4
    }

; ==============================================================================

    ; *$3AE65-$3AE87 LOCAL
    {
        LDA $AD : CMP.b #$02 : BNE BRANCH_ALPHA
        
        LDA $0322 : AND.b #$03 : CMP.b #$03 : BNE BRANCH_ALPHA
        
        STZ $30
        STZ $31
        STZ $67
        STZ $2A
        STZ $2B
        STZ $6B
    
    BRANCH_ALPHA:
    
        ; Cane of Somaria transit lines?
        LDA $02F5 : BEQ BRANCH_BETA
        
        STZ $67
    
    BRANCH_BETA:
    
        RTS
    }
    
; ==============================================================================

    ; *$3AE88-$3AEBF LOCAL
    {
        LDA $0308 : AND.b #$80 : BEQ BRANCH_BETA
    
    ; *$3AE8F ALTERNATE ENTRY POINT

        ; Check Link's invincibility status.
        ; He's not in the cape form..
        LDA $55 : BEQ BRANCH_BETA
        
        ; He is in cape form (invisible and invincible).
        ; Does Link need to transform into the cape form?
        LDA $0304 : CMP.b #$13 : BNE BRANCH_BETA
        
        ; Link might need to transform, but if he's already transformed, then not.
        CMP $0303 : BNE BRANCH_GAMMA
        
        ; It seems to me that the load is unnecessary... correct me if I'm
        ; wrong.
        DEC $4C : LDA $4C : BNE BRANCH_DELTA
        
        LDA $7EF37B : TAY
        
        LDA LinkItem_Cape.mp_depletion_timers, Y : STA $4C
        
        LDA $7EF36E : BEQ BRANCH_DELTA
        
        DEC A : STA $7EF36E : BNE BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        JSR $AE47 ; $3AE47 IN ROM
    
    BRANCH_DELTA:
    
        RTS
    }

; ==============================================================================

    ; *$3AEC0-$3AF3A JUMP LOCATION
    LinkItem_CaneOfSomaria:
    {
        BIT $3A : BVS .y_button_held
        
        LDA $02F5 : BNE BRANCH_$3AE87 ; (RTS)
        
        LDA $6C : BNE BRANCH_$3AE87 ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3AE87 ; (RTS)
        
        LDX.b #$04
    
    .next_obj_slot
    
        LDA $0C4A, X : CMP.b #$2C : BEQ .is_somaria_block
        
        DEX : BPL .next_obj_slot
        
        LDX.b #$04
        
        JSR LinkItem_EvaluateMagicCost : BCC BRANCH_$3AE87 ; (RTS)
    
    .is_somaria_block
    
        LDA.b #$01 : STA $0350
        
        LDY.b #$01
        LDA.b #$2C
        
        JSL AddSomarianBlock
        
        LDA $9EEC : STA $3D
        
        STZ $2E
        STZ $0300
        STZ $0301
        
        LDA.b #$08 : TSB $037A
    
    .y_button_held
    
        JSR $AE65   ; $3AE65 IN ROM

        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL .return
        
        LDA $0300 : INC A : STA $0300 : TAX
        
        LDA $9EEC, X : STA $3D
        
        CPX.b #$03 : BNE .return
        
        STZ $5E
        STZ $0300
        STZ $3D
        STZ $0350
        
        LDA $3A : AND.b #$BF : STA $3A
        
        LDA $037A : AND.b #$F7 : STA $037A
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $3AF3B-$3AF3D DATA
    pool PlayerItem_CaneOfByrna:
    {
    
    ; \task Confirm this is an accurate label.
    .animation_delays
        db 19, 7, 13
    }

; ==============================================================================

    ; *$3AF3E-$3AFB4 JUMP LOCATION
    PlayerItem_CaneOfByrna:
    {
        ; Cane of Byrna
        
        ; $3AFB5 IN ROM; Check to see if it's okay to do
        JSR $AFB5 : BCS BRANCH_$3AF3A
        
        ; Check to see if the Y button is down.
        BIT $3A : BVS BRANCH_ALPHA ; Yes it's down
        
        LDA $6C : BNE BRANCH_$3AF3A ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3AF3A
        
        LDX.b #$08
        
        JSR LinkItem_EvaluateMagicCost : BCC BRANCH_BETA
        
        LDY.b #$00
        LDA.b #$30
        
        JSL AddCaneOfByrnaStart
        
        STZ $79
        
        LDA .animation_delays : STA $3D
        
        STZ $030D
        STZ $0300
        
        LDA.b #$08 : STA $037A
        
        LDA.b #$01 : TSB $50
        
        STZ $2E
    
    BRANCH_ALPHA:
    
        JSR $AE65 ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL BRANCH_GAMMA
        
        LDX $0300 : INX : STX $0300
        
        ; \bug(unconfirmed) It seems to me that you could run one past the end
        ; of the designated data for this... Though the resulting value is
        ; probably not used anyway. Still... unsafe! \task Check the status
        ; of this in a debugger.
        LDA .animation_delays, X : STA $3D
        
        CPX.b #$01 : BNE BRANCH_DELTA
        
        PHX
        
        LDA.b #$2A : JSR Player_DoSfx3
        
        PLX
    
    BRANCH_DELTA:
    
        CPX.b #$03 : BNE BRANCH_GAMMA
    
    BRANCH_BETA:
    
        STZ $030D
        STZ $0300
        
        LDA $3A : AND.b #$80 : STA $3A
        
        STZ $037A
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_GAMMA:
    
        RTS
    }

; ==============================================================================

    ; *$3AFB5-$3AFCB LOCAL
    {
        ; The labels are probably not correct yet, need some in game debugging
        ; to verify assumptions...
        
        ; Is link trying to cast the byrna spell?
        LDA $037A : AND.b #$08 : BNE .castingSpell
        
        LDX.b #$04
    
    .nextSlot
    
        LDA $0C4A, X : CMP.b #$31 : BEQ .byrnaEffectActive
        
        DEX : BPL .nextSlot

    ; yeah, so he's not done yet.
    .castingSpell
    
        ; This indicates to the caller that the Byrna spell is being started but is not yet 
        ; fully operational
        CLC
        
        RTS
    
    .byrnaEffectActive
    
        SEC
        
        RTS
    }

; ==============================================================================

    ; *$3AFF8-$3B072 LOCAL
    {
        BIT $3A : BVS BRANCH_ALPHA
        
        LDA $6C : BNE BRANCH_$3AFB4 ; (RTS)
        
        JSR Link_CheckNewY_ButtonPress : BCC BRANCH_$3AFB4 ; (RTS)
        
        LDA $2F : LSR A : TAY
        
        LDX $AFF4, Y
        
        LDA $AFCC, X : STA $0300
        
        LDA.b #$03 : STA $3D
        
        STZ $030D, X
        
        LDA.b #$10 : STA $037A
        
        LDA.b #$01 : TSB $50
        
        STZ $2E
        
        LDA.b #$32 : JSR Player_DoSfx2
    
    BRANCH_ALPHA:
    
        JSR $AE65 ; $3AE65 IN ROM
        
        LDA $67 : AND.b #$F0 : STA $67
        
        DEC $3D : BPL BRANCH_BETA
        
        LDX $030D : INX : STX $030D
        
        LDA.b #$03 : STA $3D
        
        LDA $2F : LSR A : TAY
        
        LDA $AFF4, Y : ADD $030D : TAY
        
        LDA $AFCC, Y : STA $0300
        
        CPX.b #$0A : BNE BRANCH_BETA
        
        STZ $030D
        STZ $0300
        
        LDA $3A : AND.b #$80 : STA $3A
        
        STZ $037A
        
        LDA $50 : AND.b #$FE : STA $50
        
        LDA.b #$80 : STA $44
                     STA $45
    
    BRANCH_BETA:
    
        RTS
    }

; ==============================================================================

    ; *$3B073-$3B086 LOCAL
    Link_CheckNewY_ButtonPress:
    {
        ; Check if the Y button is already down.
        BIT $3A : BVS .noNewInput
        
        ; Flag to see if Link is recoiling from damage or other stuff.
        LDA $46 : BNE .noNewInput
        
        ; Check joypad readings for new input during this frame.
        LDA $F4 : AND.b #$40 : BEQ .noNewInput
        
        TSB $3A
        
        SEC
        
        RTS
    
    .noNewInput
    
        ; I'm guessing this is like a cancel indicator.
        CLC
        
        RTS
    }

; ==============================================================================

    ; $3B087-$3B0AA DATA
    LinkItem_MagicCosts:
    {
        ; Magic costs for various items.
        
        ; Fire rod and ice rod
        db $10, $08, $04
        
        ; Medallion spells
        db $20, $10, $08
        
        ; Magic powder
        db $08, $04, $02
        
        ; Unused?
        db $08, $04, $02
        
        ; Cane of Somaria
        db $08, $04, $02
        db $10, $08, $04
        
        ; Torch
        db $04, $02, $02
        
        ; Unused?
        db $08, $04, $02
        
        ; Cane of Byrna
        db $10, $08, $04
    }
    
    ; $3B0A2-$3B0AA DATA
    LinkItem_MagicCostBaseIndices:
    {
        db $00, $03, $06, $09, $0c, $0f, $12, $15, $18
    }

; ==============================================================================

    ; *$3B0AB-$3B0E8 LOCAL
    LinkItem_EvaluateMagicCost:
    {
        STX $02
        
        ; Load an index into the table below
        LDA LinkItem_MagicCostBaseIndices, X : ADD $7EF37B : TAX
        
        ; This tells us how much magic to deplete.
        LDA LinkItem_MagicCosts, X : STA $00
        
        LDA $7EF36E : BEQ .notEnoughMagicPoints
        
        ; Subtract the amount off of the magic meter.
        ; Check to see if the amount is negative.
        SUB $00 : CMP.b #$80 : BCS .notEnoughMagicPoints
        
        ; Otherwise just take it like a man.
        STA $7EF36E
        
        ; Indicates success
        SEC
        
        RTS
    
    .notEnoughMagicPoints
    
        ; Load the item index.
        LDA $02 : CMP.b #$03 : BEQ BRANCH_BETA
    
    ; *$3B0D4 ALTERNATE ENTRY POINT
    
        ; You naughty boy you have no magic pwr!
        LDA.b #$3C : JSR Player_DoSfx2
        
        REP #$20
        
        ; Prints that annoying message saying you're out of magic power >:(
        LDA.w #$007B : STA $1CF0
        
        SEP #$20
        
        JSL Main_ShowTextMessage
    
    BRANCH_BETA:
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$3B0E9-$3B106 LONG
    LinkItem_ReturnUnusedMagic:
    {
        PHB : PHK : PLB
        
        LDA LinkItem_MagicCostBaseIndices, X : ADD $7EF37B : TAX
        
        LDA LinkItem_MagicCosts, X : STA $00
        
        LDA $7EF36E : ADD $00 : STA $7EF36E
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3B107-$3B11B LONG
    {
        STZ $030A
        STZ $3B
        STZ $0308
        STZ $0309
        STZ $0376
        
        LDA $50 : AND.b #$FE : STA $50
        
        RTL
    }

; ==============================================================================

    ; *$3B11C-$3B198 JUMP LOCATION LOCAL
    Link_Lift:
    {
        ; Code for picking things up
        LDA $0314 ; Flag for if there's a sprite to pick up
        ORA $02EC ; Flag for if there's an ancilla to pick up
        
        BNE BRANCH_ALPHA
        
        JSR $9D84 ; $39D84 IN ROM; Prep Link for picking things up
        
        STZ $3B
        
        LDX.b #$0F
    
    .nextSpriteSlot
    
        LDA $0DD0, X : BEQ .openSpriteSlot
        
        DEX : BPL .nextSpriteSlot
        
        BRA .noOpenSpriteSlots
    
    .openSpriteSlot
    
        LDA $0368
        
        CMP.b #$05 : BEQ .isLargeRock
        CMP.b #$06 : BNE .notLargeRock
    
    .isLargeRock
    
        LDA.b #$01 : STA $0300
        
        BRA BRANCH_THETA
    
    .notLargeRock
    
        LDA $1B : BEQ .outdoor_lifted_tile_replace_logic
        
        JSL Dungeon_RevealCoveredTiles
        
        BRA .determine_sprite_to_spawn
    
    .outdoor_lifted_tile_replace_logic
    
        JSL Overworld_LiftableTiles
    
    .determine_sprite_to_spawn
    
        LDX.b #$08
    
    .find_matching_tile_attrribute
    
        CMP $B1AD, X : BEQ .tile_attribute_match
        
        DEX : BPL .find_matching_tile_attrribute
    
    .noOpenSpriteSlots
    
        BRL BRANCH_$3B280 ; BRANCHES TO AN RTS
    
    .tile_attribute_match
    
        LDA.b #$01 : STA $0314
        
        TXA
        
        JSL Sprite_SpawnThrowableTerrain
        
        ; negate further A button presses
        ASL $F6 : LSR $F6
    
    BRANCH_ALPHA:
    
        STZ $0300
    
    BRANCH_THETA:
    
        STZ $3A
        
        ; Set an animation timer
        LDA $B199 : STA $030B
        
        ; Set it so Link is kneeling down to pick up the item
        LDA.b #$01 : STA $0309
        
        LDA.b #$80 : STA $0308
        
        STZ $030A
        
        LDA.b #$0C : STA $5E
        
        STZ $2E
        
        LDA $67 : AND.b #$F0 : STA $67
        
        LDA.b #$01 : TSB $50
    
    ; *$3B198 ALTERNATE ENTRY POINT
    
        RTS
    }

; ==============================================================================

    ; $3B199-$3B1C9 DATA
    {
        db  6,  7,  7,  5, 10,  0, 23,  0
        db 18, ...
    
    ; tile attributes to compare with... replacement tiles resulting from picking
    ; shit up?
    ; $3B1AD
        db $54, $52, $50, $FF, $51, $53, $55, $56
        db $57
    
    ; $3B1B6
        db $08, $18, $08, $18, $08, $20, $06, $08
        db $0D, $0D
    
    ; $3B1C0
        db $00, $01, $00, $01, $00, $01, $00, $01
        db $02, $03
    }

; ==============================================================================

    ; *$3B1CA-$3B280 JUMP LOCATION LOCAL
    {
        LDA $0308 : BEQ BRANCH_$3B198
        
        ; Is Link throwing an item?
        LDA $0309 : AND.b #$02 : BEQ .alpha
        
        LDA $030B : CMP.b #$05 : BCC .alpha
        
        LDA $B19C : STA $030B
    
    .alpha
    
        ; Is Link picking up an item?
        ; No...
        LDA $0309 : BEQ .notPickingSomethingUp
        
        JSR $AE65 ; $3AE65 IN ROM; Link is picking up an item, handle it.
    
    .notPickingSomethingUp
    
        ; Is Link still picking up something?
        LDA $0309 : AND.b #$01 : BEQ .notPickingUpInProgress
        
        STZ $2E
        STZ $2D
        
        ; Make it so Link does not appear to be walking
        LDA $67 : AND.b #$F0 : STA $67
    
    .notPickingUpInProgress
    
        ; Timer used for picking up the item and throwing it
        DEC $030B : LDA $030B : BNE BRANCH_$3B198
        
        LDA $0309 : AND.b #$02 : BEQ .delta
        
        STZ $0308
        STZ $48
        STZ $5E
        
        LDA $5D : CMP.b #$18 : BNE BRANCH_EPSILON
        
        LDA.b #$00 : STA $5D
        
        BRL BRANCH_EPSILON
    
    .delta
    
        LDA $0300 : BEQ BRANCH_ZETA
        
        INC A : CMP.b #$09 : BEQ BRANCH_EPSILON
        
        STA $0300 : TAX
        
        LDA $B1B6, X : STA $030B
        
        LDA $B1C0, X : STA $030A
        
        CPX.b #$06 : BNE BRANCH_THETA
        
        STZ $0B9C
        
        LDA $1B : BEQ .outdoors
        
        JSL Dungeon_RevealCoveredTiles
        
        BRA BRANCH_KAPPA
    
    .outdoors
    
        JSL Overworld_LiftableTiles
    
    BRANCH_KAPPA:
    
        AND.b #$0F : INC A : PHA
        
        ; Put Link into the "under a heavy rock" mode.
        LDA.b #$18 : STA $5D
        
        LDA.b #$01 : STA $0314
        
        PLA
        
        JSL Sprite_SpawnThrowableTerrain
        
        ASL $F6 : LSR $F6
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDX $030A : INX
        
        LDA $B199, X : STA $030B
        
        STX $030A : CPX.b #$03 : BNE BRANCH_THETA
    
    BRANCH_EPSILON:
    
        STZ $0309
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_THETA:
    
        RTS
    }

; ==============================================================================

    ; *$3B281-$3B2ED JUMP LOCATION LOCAL
    {
        LDA $02F5 : BNE BRANCH_$3B1CA_THETA
        
        LDA $0314 : ORA $02EC : BNE BRANCH_$3B1CA_THETA
        
        BIT $0308 : BMI BRANCH_$3B1CA_THETA
        
        LDA $1B : BNE BRANCH_ALPHA
    
    BRANCH_ALPHA:
    
        STZ $3B
        
        LDA.b #$1D : STA $0374
        
        LDA.b #$40 : STA $02F1
        
        ; i'm just faaaaalllling off a ledge
        LDA.b #$11 : STA $5D
        
        LDA.b #$01 : STA $0372
        
        LDA $3A : AND.b #$80 : STA $3A
        
        STZ $0308
        STZ $0301
        STZ $48
        STZ $6B
        
        LDA $7EF3CC : TAX
        
        CMP $8F68, X : BNE .tagalong_not_enabled_for_this
        
        ; Basically, only the old man makes it through here (tagalong 0x02)
        STZ $5E
        
        LDX $02CF
        
        ; \bug This is not cool, bro. Writing to bank 0x07?
        ; \tcrf Perhaps mentionable enough that maybe they wanted the player to
        ; lose the old man here?
        LDA $1A00, X : STA $F3CD
        LDA $1A14, X : STA $F3CE
        
        LDA $1A28, X : STA $F3CF
        LDA $1A3C, X : STA $F3D0
        
        LDA $EE : STA $F3D2
        
        LDA.b #$40 : STA $02D2
    
    ; *$3B2ED ALTERNATE ENTRY POINT
    .tagalong_not_enabled_for_this
    
        RTS
    }

; ==============================================================================

    ; *$3B2EE-$3B30F JUMP LOCATION
    {
        ; Link grabs a wall action
        LDA $3A : AND.b #$80 : BEQ .noCurrentAction
        
        LDA $3C : CMP.b #$09 : BCS BRANCH_$3B2ED
    
    .noCurrentAction
    
        LDA.b #$01 : STA $0376 : TSB $50
        
        STZ $2E
        STZ $030A
        
        LDA $B314 : STA $030B
        
        STZ $030D
        
        RTS
    }

; ==============================================================================

    ; *$3B322-$3B372 JUMP LOCATION
    {
        ; Pre grabbing a wall?
        
        LDA $67 : AND.b #$F0 : STA $67
        
        LDA $2F : LSR A : TAX
        
        LDA $F0 : AND.b #$0F : BEQ BRANCH_ALPHA
        
        AND $B310, X : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDX.b #$00
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        DEC $030B : BPL BRANCH_DELTA
        
        LDA $030D
        
        INX : CPX.b #$07 : BNE BRANCH_GAMMA
        
        LDX.b #$01
    
    BRANCH_GAMMA:
    
        STX $030D
        
        LDA $B31B, X : STA $030A
        LDA $B314, X : STA $030B
    
    BRANCH_DELTA:
    
        LDA $F2 : AND.b #$80 : BNE BRANCH_EPSILON
        
        STZ $030D
        STZ $030A
        STZ $0376
        STZ $3B
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_EPSILON:
    
        RTS
    }

; ==============================================================================

    ; *$3B373-$3B388 JUMP LOCATION
    Link_MovableStatue:
    {
        LDA.b #$02 : STA $0376
        
        LDA.b #$01 : TSB $50
        
        STZ $2E
        STZ $030A
        
        LDA $B314 : STA $030B
        
        STZ $030D
        
        RTS
    }

; ==============================================================================

    ; *$3B389-$3B3E4 JUMP LOCATION
    {
        LDA.b #$14 : STA $5E
        
        LDA $2F : LSR A : TAX
        
        LDA $F0 : AND.b #$0F : BEQ BRANCH_ALPHA
        
        AND $B310, X : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        STZ $67
        STZ $30
        STZ $31
        STZ $2E
        
        LDX.b #$00
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        STA $67
        
        DEC $030B : BPL BRANCH_DELTA
        
        LDX $030D : INX : CPX.b #$07 : BNE BRANCH_GAMMA
        
        LDX.b #$01
    
    BRANCH_GAMMA:
    
        STX $030D
        
        LDA $B31B, X : STA $030A
        
        LDA $B314, X : STA $030B
    
    BRANCH_DELTA:
    
        LDA $F2 : AND.b #$80 : BNE BRANCH_EPSILON
        
        STZ $5E
        STZ $02FA
        STZ $030D
        STZ $030A
        STZ $0376
        STZ $3B
        
        LDA $50 : AND.b #$FE : STA $50
    
    BRANCH_EPSILON:
    
        RTS
    }

; ==============================================================================

    ; *$3B3E5-$3B40C JUMP LOCATION
    {
        ; must be facing in the up direction in order to go rolling backwards
        LDA $2F : BNE .notFacingUp
        
        JSL Player_ResetState
        
        LDA.b #$02 : STA $0376 : TSB $50
        
        STZ $2E
        STZ $030A
        
        LDA $B314 : STA $030B
        
        STZ $030D
        
        ; Rolling backwards mode for Link.
        LDA.b #$1D : STA $5D
        
        STZ $27
        STZ $28
        STZ $3A
    
    ; *$3B40C ALTERNATE ENTRY POINT
    .notFacingUp
    
        RTS
    }

; ==============================================================================

    ; *$3B416-$3B4F1 JUMP LOCATION
    {
        JSR $F514 ; $3F514 IN ROM
        
        LDA $4D : BEQ .durp
        
        BRL BRANCH_$38130
    
    .durp
    
        LDA $0376 : BEQ BRANCH_ALPHA
        
        LDA $3A : BNE BRANCH_BETA
        
        BIT $F2 : BPL BRANCH_GAMMA
        
        LDA $F0 : AND.b #$04 : BEQ BRANCH_DELTA
        
        STA $3A
        
        LDA.b #$22 : JSR Player_DoSfx2
        
        BRA BRANCH_BETA
    
    BRANCH_GAMMA:
    
        STZ $0376
        STZ $030D
        
        LDA.b #$02 : STA $030B : STZ $030A
        
        STZ $50
        
        LDA.b #$00 : STA $5D
        
        BRA BRANCH_EPSILON
    
    BRANCH_BETA:
    
        DEC $030B : BPL BRANCH_DELTA
        
        INC $030D : LDX $030D
        
        LDA $B31B, X : STA $030A
        LDA $B314, X : STA $030B
        
        CPX.b #$07 : BNE BRANCH_DELTA
        
        STZ $0376
        STZ $030D
        
        LDA.b #$02 : STA $030B : STZ $030A
        
        LDA.b #$01 : STA $0308 : STZ $0309
        
        BRA BRANCH_ALPHA
    
    BRANCH_DELTA:
    
        BRA BRANCH_ZETA
    
    BRANCH_ALPHA:
    
        LDA $48 : AND.b #$09 : BNE BRANCH_THETA
        
        LDA $030D : CMP.b #$09 : BNE BRANCH_IOTA
        
        LDA $F4 : AND.b #$0F : BEQ BRANCH_KAPPA
    
    BRANCH_EPSILON:
    
        LDA.b #$00 : STA $5D
        
        BRL BRANCH_$38109 ; GO TO NORMAL MODE
    
    BRANCH_IOTA:
    
        LDY.b #$00
        LDA.b #$1E
        
        JSL AddDashingDust.notYetMoving
        
        DEC $030B : BPL BRANCH_LAMBDA
        
        INC $030D : LDX $030D
        
        LDA.b #$02 : STA $030B
        
        LDA $B400D, X : STA $030A
        
        LDA.b #$30 : STA $27
        
        CPX.b #$09 : BNE BRANCH_LAMBDA
    
    BRANCH_THETA:
    
        STZ $2F
        STZ $0308
        STZ $50
        
        LDA.b #$00 : STA $5D
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA:
    
        JSR $92A0 ; $392A0 IN ROM
        
        LDA $67 : AND.b #$03 : BNE BRANCH_NU
        
        STZ $28
    
    BRANCH_NU:
    
        LDA $67 : AND.b #$0C : BNE BRANCH_ZETA
        
        STZ $27
    
    BRANCH_ZETA:
    
        JSL $07E370 ; $3E370 IN ROM
    
    BRANCH_KAPPA:
    
        JSR $B7C7 ; $3B7C7 IN ROM
        JSR $E8F0 ; $3E8F0 IN ROM
    
    BRANCH_MU:
    
        RTS
    }

; ==============================================================================

    ; *$3B4F2-$3B527 JUMP LOCATION
    Link_Read:
    {
        REP #$30
        
        LDA $1B : AND.w #$00FF : BEQ .outdoors
        
        LDA $A0 : ASL A : TAY
        
        LDA Dungeon_SignText, Y
        
        BRA .showMessage
    
    .outdoors
    
        LDA $7EF3C5 : AND.w #$00FF : CMP.w #$0002 : BCS .savedZeldaOnce
        
        ; Only use one message for all "beginning" signs.
        ; That is, "The King will give 100 Rupees to..." message
        LDA.w #$003A
        
        BRA .showMessage
    
    .savedZeldaOnce
    
        LDA $8A : ASL A : TAY
        
        LDA Overworld_SignText, Y
    
    .showMessage
    
        STA $1CF0
        
        SEP #$30
        
        JSL Main_ShowTextMessage
        
        STZ $3B
    
    .return
    
        RTS
    }

; ==============================================================================

    ; $3B528-$3B573 DATA
    Link_ReceiveItemAlternates:
    {
        db -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
        db -1,  -1,  -1,  -1, $44,  -1,  -1,  -1
        
        db -1,  -1, $35,  -1,  -1,  -1,  -1,  -1
        db -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
        
        db -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
        db -1,  -1, $46,  -1,  -1,  -1,  -1,  -1
        
        db -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
        db -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
        
        db -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1
        db -1,  -1,  -1,  -1
    }

; ==============================================================================

    ; *$3B574-$3B5BF JUMP LOCATION
    Link_Chest:
    {
        ; Checks if we can open the chest, and sets up the transfer of the item to link's inventory.
        
        ; Not facing up... (can't open the chest)
        LDA $2F : BNE .cantAttempt
        
        ; Is Link already opening the chest?
        LDA $02E9 : BNE .cantAttempt
        
        ; Is Link in the auxiliary ground state?
        LDA $4D : BNE .cantAttempt
        
        ; Clear the A button location
        STZ $3B
        
        LDA $76
        
        ; Carry clear means failure. So branch if it failed.
        JSL Dungeon_OpenKeyedObject : BCC .cantOpen
        
        ; Set indicate that the Receive Item method is from a chest.
        LDA.b #$01 : STA $02E9
        
        ; Okay... so what item did we get?
        ; Items don't run into the negatives, so we messed up.
        LDY $0C : BMI .cantOpen
        
        ; Load an alternate item to use.
        ; If it's 0xFF it seems obvious it isn't an alternate b/c items can't be negative.
        LDA Link_ReceiveItemAlternates, Y : STA $03
        
        CMP.b #$FF : BEQ .dontUseAlternate
        
        TYA : ASL A : TAX
        
        ; Determine what memory location to give this item over to.
        ; Effective address at [$00] is $7E:???? as determined above.
        LDA ItemTargetAddr+0, X : STA $00
        LDA ItemTargetAddr+1, X : STA $01
        LDA.b #$7E              : STA $02
        
        ; Check what's at that location. Is it empty? (i.e. zero?)
        ; We don't have it yet.
        LDA [$00] : BEQ .dontUseAlternate
        
        ; If we do have it, load the alternate.
        LDY $03
    
    .dontUseAlternate
    
        ; Link is opening a chest.
        JSL Link_ReceiveItem
        
        BRA .return
    
    .cantOpen
    
        ; set item method to... from text?
        STZ $02E9
    
    .cantAttempt
    .return
    
        RTS
    }

; ==============================================================================

    ; *$3B5C0-$3B5D5 LOCAL
    {
        ; Is the A button already down?
        LDA $3B : AND.b #$80 : BNE .failure
        
        ; Can Link move?
        LDA $46 : BNE .failure
        
        ; Did the A button just go down this frame?
        ; No it was not pushed this frame
        LDA $F6 : AND.b #$80 : BEQ .failure
        
        ; Well, it was pushed this frame, so communicate that to $3B
        TSB $3B
        
        SEC
        
        RTS
    
    .failure
    
        ; Yep, it's down already.
        CLC
        
        RTS
    }

    ; *$3B5D6-$3B608 LONG
    {
        LDA $3B : AND.b #$80 : BEQ .aButtonNotDown
        
        ; axlr----, bystudlr's distant cousin
        LDA $F6 : AND.b #$80 : BEQ .aButtonNotDown
        
        LDA $0309 : AND.b #$01 : BNE .aButtonNotDown
        
        STZ $030D
        STZ $030E
        STZ $030A
        
        STZ $3B
        
        LDA $50 : AND.b #$FE : STA $50
        
        ; appears to be a debug variable, so it should always be zero.
        LDA $0305 : CMP.b #$01 : BNE .dontDisableMasks
        
        STZ $1E
        STZ $1F
    
    .dontDisableMasks
    
        SEC
        
        RTS
    
    .aButtonNotDown
    
        CLC
        
        RTS
    }

; *$3B64F-$3B7C2 LOCAL
{
    ; $3B97C IN ROM
    JSR $B97C : BCC .onlyOneBg

    JSR $B660 ; $3B660 IN ROM
    JSR $B9B3 ; $3B9B3 IN ROM

.onlyOneBg

    LDA $67 : AND.b #$0F : STA $67

; *$3B660 ALTERNATE ENTRY POINT

    LDA.b #$0F : STA $42 : STA $43
    
    STZ $6A
    
    ; Checking to see if either up or down was pressed.
    ; Yeah, one of them was.
    LDA $67 : AND.b #$0C : BNE .verticalWalking
    
    ; Neither up nor down was pressed.
    BRL BRANCH_ULTIMA

.verticalWalking

    INC $6A
    
    LDY.b #$00
    
    ; Walking in the up direction?
    AND.b #$08 : BNE .walkingUp
    
    ; Walking in the down direction
    LDY.b #$02

.walkingUp

    ; $66 = #$0 or #$1. #$1 if the down button, #$0 if the up button was pushed.
    TYA : LSR A : STA $66
    
    JSR $CE85 ; $3CE85 IN ROM
    
    LDA $0E : AND.b #$30 : BEQ BRANCH_DELTA
    
    LDA $62 : AND.b #$02 : BNE BRANCH_DELTA
    
    LDA $0E : AND.b #$30 : LSR #4 : AND $67 : BNE BRANCH_DELTA
    
    LDY.b #$02
    
    LDA $67
    
    AND.b #$03 : BEQ BRANCH_DELTA
    AND.b #$02 : BNE BRANCH_EPSILON
    
    LDY.b #$03
    
    BRA BRANCH_EPSILON

BRANCH_DELTA:

    LDA $046C : BEQ BRANCH_ZETA
    
    LDA $0E : AND.b #$03 : BNE BRANCH_THETA
    
    BRA BRANCH_IOTA

BRANCH_ZETA:

    ; If Link is in the ground state, then branch.
    LDA $4D : BEQ BRANCH_THETA
    
    LDA $0C : AND.b #$03 : BEQ BRANCH_THETA
    
    BRA BRANCH_MU

BRANCH_THETA:

    LDA $0E : AND.b #$03 : BEQ BRANCH_IOTA
    
    STZ $6B
    
    LDA $034A : BEQ BRANCH_MU
    
    LDA $02E8 : AND.b #$03 : BNE BRANCH_MU
    
    LDA $67 : AND.b #$03 : BEQ BRANCH_MU
    
    STZ $033C
    STZ $033D
    STZ $032F
    STZ $0330
    STZ $032B
    STZ $032C
    STZ $0334
    STZ $0335

BRANCH_MU:

    LDA.b #$01 : STA $0302
    
    LDY $66

BRANCH_EPSILON:

    LDA $B64B, Y : STA $42

BRANCH_IOTA:

    LDA $67 : AND.b #$03 : BNE BRANCH_LAMBDA
    
    BRL BRANCH_ULTIMA

BRANCH_LAMBDA:

    INC $6A
    
    LDY.b #$04
    
    AND.b #$02 : BNE BRANCH_NU
    
    LDY.b #$06

BRANCH_NU:

    TYA : LSR A : STA $66
    
    JSR $CEC9 ; $3CEC9 IN ROM
    
    LDA $0E : AND.b #$30 : BEQ BRANCH_XI
    
    LDA $62 : AND.b #$02 : BEQ BRANCH_XI
    
    LDA $0E : AND.b #$30 : LSR #2 : AND $67 : BNE BRANCH_XI
    
    LDY.b #$00
    
    LDA $67
    
    AND.b #$0C : BEQ BRANCH_XI
    AND.b #$08 : BNE BRANCH_OMICRON
    
    LDY.b #$01
    
    BRA BRANCH_OMICRON

BRANCH_XI:

    ; One BG collision
    LDA $046C : BEQ BRANCH_PI
    
    LDA $0E : AND.b #$03 : BNE BRANCH_RHO
    
    BRA BRANCH_SIGMA

BRANCH_PI:

    LDA $4D : BEQ BRANCH_RHO
    
    LDA $0C : AND.b #$03 : BEQ BRANCH_RHO

    BRA BRANCH_UPSILON

BRANCH_RHO:

    LDA $0E : AND.b #$03 : BEQ BRANCH_SIGMA
    
    STZ $6B
    
    LDA $034A : BEQ BRANCH_UPSILON
    
    LDA $02E8 : AND.b #$03 : BNE BRANCH_UPSILON
    
    ; Check if Link is walking in an vertical direction
    LDA $67 : AND.b #$0C : BEQ BRANCH_UPSILON
    
    STZ $033E
    STZ $033F
    STZ $0331
    STZ $0332
    STZ $032D
    STZ $032E
    STZ $0336
    STZ $0337

BRANCH_UPSILON:

    LDA.b #$01 : STA $0302
    
    LDY $66

BRANCH_OMICRON:

    LDA $B64B, Y : STA $43

BRANCH_SIGMA:

    LDA $67 : AND $42 : AND $43 : STA $67

BRANCH_ULTIMA:

    LDA $67 : AND.b #$0F : BEQ BRANCH_PHI
    
    LDA $6B : AND.b #$0F : BEQ BRANCH_PHI
    
    STA $67

BRANCH_PHI:

    ; Is this checking if Link is moving diagonally?
    LDA $6A : STZ $6A : CMP.b #$02 : BNE BRANCH_OMEGA
    
    LDY.b #$01
    
    LDA $2F : AND.b #$04 : BEQ BRANCH_ALIF
    
    LDY.b #$02

BRANCH_ALIF:

    STY $6A

BRANCH_OMEGA:

    RTS
}

; ==============================================================================

    ; $3B7C3-$3B7C6 DATA
    {
        ; \task Label this pool / routine.
        db 8, 4, 2, 1
    }

; ==============================================================================

    ; *$3B7C7-$3B955 LOCAL
    {
        ; Initialize the diagonal wall state
        STZ $6E
        
        ; ????
        STZ $38
        
        ; Detects forced diagonal movement, as when walking against a diagonal wall
        ; Branch if there is [forced] diagonal movement
        LDA $6B : AND.b #$30 : BNE BRANCH_ALPHA
        
        ; $3CCAB IN ROM; Handles left/right tiles and maybe up/down too
        JSR $CCAB
        
        LDA $6D : BEQ BRANCH_ALPHA
        
        BRL BRANCH_BETA
    
    BRANCH_ALPHA:
    
        ; $3B97C IN ROM
        JSR $B97C : BCC BRANCH_BETA
        
        ; "Check collision" as named in Hyrule Magic
        ; Keep in mind that outdoors, collisions are always 0, i.e. "normal"
        ; Why load it twice, homes?
        LDA $046C : CMP.b #$02 : BCC BRANCH_GAMMA
        LDA $046C : CMP.b #$03 : BEQ BRANCH_GAMMA
        
        LDA.b #$02 : STA $0315
        
        REP #$20
        
        JSR Player_TileDetectNearby
        
        SEP #$20
        
        LDA $0E : STA $0316 : BEQ BRANCH_GAMMA
        
        LDA $30 : STA $00
        
        ADC $0310 : STA $30
        
        LDA $31 : STA $01
        
        ADD $0312 : STA $31
        
        LDA $0E
        
        CMP.b #$0C : BEQ BRANCH_GAMMA
        CMP.b #$03 : BEQ BRANCH_GAMMA
        CMP.b #$0A : BEQ BRANCH_DELTA
        CMP.b #$05 : BEQ BRANCH_DELTA
        AND.b #$0C : BNE BRANCH_EPSILON
        
        LDA $0E : AND.b #$03 : BNE BRANCH_EPSILON
        
        BRA BRANCH_GAMMA
    
    BRANCH_EPSILON:
    
        LDA $00 : BNE BRANCH_DELTA
        
        LDA $01 : BEQ BRANCH_GAMMA
        
        LDA $0301 : BPL BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        JSR $B956 ; $3B956 IN ROM
        
        BRA BRANCH_ZETA
    
    BRANCH_DELTA:
    
        JSR $B969   ; $3B969 IN ROM
    
    BRANCH_ZETA:
    
        JSR $B9B3 ; $3B9B3 IN ROM
    
    BRANCH_BETA:
    
        ; Check the "collision" value (as in Hyrule Magic)
        LDA $046C
        
        CMP.b #$02 : BEQ BRANCH_THETA
        CMP.b #$03 : BEQ BRANCH_IOTA
        CMP.b #$04 : BEQ BRANCH_KAPPA
        
        ; Is there horizontal or vertical scrolling happening?
        LDA $30 : ORA $31 : BNE BRANCH_KAPPA
        
        LDA $5D
        
        CMP.b #$13 : BEQ BRANCH_LAMBDA
        CMP.b #$08 : BEQ BRANCH_LAMBDA
        CMP.b #$09 : BEQ BRANCH_LAMBDA
        CMP.b #$0A : BEQ BRANCH_LAMBDA
        CMP.b #$03 : BEQ BRANCH_LAMBDA
        
        JSR Player_TileDetectNearby
        
        LDA $59 : AND.b #$0F : BEQ BRANCH_LAMBDA
        
        LDA.b #$01 : STA $5D
        
        LDA $0372 : BNE BRANCH_LAMBDA
        
        LDA.b #$04 : STA $5E
    
    BRANCH_LAMBDA:
    
        BRL BRANCH_XI
    
    BRANCH_THETA:
    
        JSR Player_TileDetectNearby
        
        LDA $0E : ORA $0316 : CMP.b #$0F : BNE BRANCH_KAPPA
        
        LDA $031F : BNE BRANCH_MU
        
        LDA.b #$3A : STA $031F
    
    BRANCH_MU:
    
        LDA $67 : BNE BRANCH_KAPPA
        
        LDA $0310 : BEQ BRANCH_NU
        
        LDA $30 : EOR.b #$FF : INC A : STA $30
    
    BRANCH_NU:
    
        LDA $0312 : BEQ BRANCH_KAPPA
        
        LDA $31 : EOR.b #$FF : INC A : STA $31
    
    BRANCH_KAPPA:
    
        LDA.b #$01 : STA $0315
        
        JSR $B956 ; $3B956 IN ROM
        
        BRA BRANCH_XI
    
    BRANCH_IOTA:
    
        LDA.b #$01 : STA $0315
        
        JSR $B969 ; $3B969 IN ROM
    
    BRANCH_XI:
    
        LDY.b #$00
        
        JSR $D077 ; $3D077 IN ROM
        
        LDA $6A : BEQ BRANCH_OMICRON
        
        STZ $6B
    
    BRANCH_OMICRON:
    
        LDA $5D : CMP.b #$0B : BEQ BRANCH_PI
        
        LDY.b #$08
        
        LDA $20 : SUB $3E : STA $30 : BEQ BRANCH_PI : BMI BRANCH_RHO
        
        LDY.b #$04
    
    BRANCH_RHO:
    
        LDA $67 : AND.b #$03 : STA $67
        
        TYA : TSB $67
    
    BRANCH_PI:
    
        ; Two LDA's in a row?
        LDA.b #$02
        
        LDA $22 : SUB $3F : STA $31 : BEQ BRANCH_SIGMA : BMI BRANCH_TAU
        
        LDY.b #$01
    
    BRANCH_TAU:
    
        LDA $67 : AND.b #$0C : STA $67
        
        TYA : TSB $67
    
    BRANCH_SIGMA:
    
        LDA $1B : BEQ BRANCH_UPSILON
        
        LDA $046C : CMP.b #$04 : BNE BRANCH_UPSILON
        
        LDA $5D : CMP.b #$04 : BNE BRANCH_UPSILON
        
        LDY.b #$F7
        
        LDA $0310 : BEQ BRANCH_PHI : BMI BRANCH_CHI
        
        LDY.b #$FB
    
    BRANCH_CHI:
    
        EOR.b #$FF : INC A : ADD $30 : BNE BRANCH_PHI
        
        TYA : AND $67 : STA $67
    
    BRANCH_PHI:
    
        LDY.b #$FD
        
        LDA $0312 : BEQ BRANCH_UPSILON : BMI BRANCH_PSI
        
        LDY.b #$FE
    
    BRANCH_PSI:
    
        EOR.b #$FF : INC A : ADD $31 : BNE BRANCH_UPSILON
        
        TYA : AND $67 : STA $67
    
    BRANCH_UPSILON:
    
        RTS
    }

    ; *$3B956-$3B968 LOCAL
    {
        LDA $6B : AND.b #$20 : BNE BRANCH_ALPHA
        
        JSR $BA0A ; $3BA0A IN ROM
    
    BRANCH_ALPHA:
    
        LDA $6B : AND.b #$10 : BNE BRANCH_BETA
        
        JSR $C4D4 ; $3C4D4 IN ROM
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$3B969-$3B97B LOCAL
    {
        LDA $6B : AND.b #$10 : BNE BRANCH_ALPHA
        
        JSR $C4D4   ; $3C4D4 IN ROM
    
    BRANCH_ALPHA:
    
        LDA $6B : AND.b #$20 : BNE BRANCH_BETA
        
        JSR $BA0A   ; $3BA0A IN ROM
    
    BRANCH_BETA:
    
        RTS
    }

    ; *$3B97C-$3B9B2 LOCAL
    {
        ; Collision settings
        LDA $046C  : BEQ .oneBg
        CMP.b #$04 : BEQ .oneBg       ; moving water collision setting
        CMP.b #$02 : BCC .twoBgs
        CMP.b #$03 : BNE .uselessBranch
        
        ; No code here, just us mice!
    
    .uselessBranch
    
        REP #$20
        
        LDA $E6 : SUB $E8 : ADD $20 : STA $20 : STA $0318
        LDA $E0 : SUB $E2 : ADD $22 : STA $22 : STA $031A
        
        SEP #$20
    
    .twoBgs
    
        LDA.b #$01 : STA $EE
        
        SEC
        
        RTS
    
    .oneBg
    
        CLC
        
        RTS
    }

    ; *$3B9B3-$3B9F6 LOCAL
    {
        LDA $046C : CMP.b #$01 : BEQ BRANCH_ALPHA
        
        REP #$20
        
        LDA $20 : SUB $0318 : STA $00
        LDA $22 : SUB $031A : STA $02
        
        LDA $E8 : SUB $E6 : ADD $20 : STA $20
        LDA $E2 : SUB $E0 : ADD $22 : STA $22
        
        SEP #$20
        
        LDA $67 : BEQ BRANCH_ALPHA
        
        LDA $30 : ADD $00 : STA $30
        LDA $31 : ADD $02 : STA $31
    
    BRANCH_ALPHA:
    
        STZ $EE
        
        RTS
    }

; *$3BA0A-$3BEAE LOCAL
{
    LDA $30 : BNE .changeInYCoord
    
    RTS

.changeInYCoord

    LDA $6C : CMP.b #$01 : BNE .notInDoorway
    
    LDY.b #$00
    
    ; basically branch if it's a north facing door
    LDA $20 : CMP.b #$80 : BCC .setLastDirection
    
    BRA .lowerDoor

.notInDoorway

    ; Will indicate that the last movement was in the up direction
    LDY.b #$00
    
    LDA $30 : BMI .setLastDirection

.lowerDoor

    ; Since the change in Y coord was positive, it means we moved down
    LDY.b #$02

.setLastDirection

    TYA : LSR A : STA $66
    
    JSR $CDCB ; $3CDCB IN ROM
    
    LDA $1B : BNE .indoors
    
    BRL BRANCH_$3BEAF

.indoors

    LDA $0308 : BMI .carryingSomething
    
    LDA $46 : BEQ .notInRecoilState

.carryingSomething

    LDA $0E : LSR #4 : TSB $0E
    
    BRL BRANCH_NU

.notInRecoilState

    LDA $6C : CMP.b #$02 : BNE BRANCH_IOTA
    
    LDA $6A : BNE BRANCH_KAPPA
    
    LDA $046C : CMP.b #$03 : BNE BRANCH_LAMBDA
    
    LDA $EE : BEQ BRANCH_LAMBDA
    
    BRL BRANCH_TAU

BRANCH_LAMBDA:

    JSR $C29F ; $3C29F IN ROM
    
    BRL BRANCH_$3C23D

BRANCH_KAPPA:

    LDA $62 : BEQ BRANCH_IOTA
    
    JSR $C29F ; $3C29F IN ROM
    
    BRA BRANCH_MU

BRANCH_IOTA:

    LDA $0E : AND.b #$70 : BEQ BRANCH_NU
    
    STZ $05
    
    LDA $0F : AND.b #$07 : BEQ BRANCH_XI
    
    LDY.b #$00
    
    LDA $30 : BMI BRANCH_OMICRON
    
    LDY.b #$01

BRANCH_OMICRON:

    LDA $B7C3, Y : STA $49

BRANCH_XI:

    LDA.b #$01 : STA $6C
    
    STZ $03F3
    
    LDA $0E : AND.b #$70 : CMP.b #$70 : BEQ BRANCH_PI
    
    LDA $0E : AND.b #$05 : BNE BRANCH_RHO
    
    LDA $0E : AND.b #$20 : BNE BRANCH_PI
    
    BRA BRANCH_NU

BRANCH_RHO:

    STZ $6B
    
    JSR $C1E4 ; $3C1E4 IN ROM
    JSR $C1FF ; $3C1FF IN ROM
    
    STZ $6C
    
    LDA $0E : AND.b #$20 : BEQ BRANCH_PI
    
    LDA $0E : AND.b #$01 : BNE BRANCH_PI
    
    LDA $22 : AND.b #$07 : CMP.b #$01 : BNE BRANCH_PI
    
    LDA $22 : AND.b #$F8 : STA $22

BRANCH_PI:

    LDA $0315 : AND.b #$02 : BNE BRANCH_SIGMA
    
    LDA $50 : AND.b #$FD : STA $50

BRANCH_SIGMA:

    RTS

BRANCH_NU:

    LDA $0315 : AND.b #$02 : BNE BRANCH_MU
    
    STZ $6C

BRANCH_MU:

    LDA $0315 : AND.b #$02 : BNE BRANCH_TAU
    
    LDA $50 : AND.b #$FD : STA $50
    
    STZ $49
    STZ $EF

BRANCH_TAU:

    LDA $0E : AND.b #$07 : BNE BRANCH_UPSILON
    
    LDA $0C : AND.b #$05 : BEQ BRANCH_UPSILON
    
    STZ $03F3
    
    JSR $E076 ; $3E076 IN ROM
    
    LDA $6B : AND.b #$0F : BEQ BRANCH_UPSILON
    
    RTS

BRANCH_UPSILON:

    STZ $6B
    
    LDA $02E7 : AND.b #$20 : BEQ .dontOpenBigKeyLock
    
    LDA $0E : PHA
    LDA $0F : PHA
    
    LDA $02EA
    
    JSL Dungeon_OpenKeyedObject
    
    STZ $02EA
    
    PLA : STA $0F
    PLA : STA $0E

.dontOpenBigKeyLock

    LDA $EE : BNE BRANCH_CHI
    
    LDA $034C : AND.b #$07 : BEQ BRANCH_PSI
    
    LDA.b #$01 : TSB $0322
    
    BRA BRANCH_OMEGA

BRANCH_PSI:

    LDA $02E8 : AND.b #$07 : BNE BRANCH_OMEGA
    
    LDA $0E : AND.b #$02 : BNE BRANCH_OMEGA
    
    LDA $0322 : AND.b #$FE : STA $0322
    
    BRA BRANCH_OMEGA

BRANCH_CHI:

    LDA $0320 : AND.b #$07
    
    BEQ BRANCH_ULTIMA
    
    LDA.b #$02 : TSB $0322
    
    BRA BRANCH_OMEGA

BRANCH_ULTIMA

    LDA $0322 : AND.b #$FD : STA $0322

BRANCH_OMEGA:

    LDA $02F7 : AND.b #$22 : BEQ .no_blue_rupee_touch
    
    LDX.b #$00
    
    AND.b #$20 : BEQ .touched_upper_rupee_half
    
    LDX.b #$08

.touched_upper_rupee_half

    STX $00
    STZ $01
    
    LDA $66 : ASL A : TAY
    
    REP #$20
    
    ; Link gets 5 rupees... probably from rupee tiles in special rooms.
    LDA $7EF360 : ADD.w #$0005 : STA $7EF360
    
    ; This is intended to help calculate where to do the clearing update.
    LDA $20 : ADD $B9F7, Y : SUB $00 : STA $00
    
    LDA $22 : ADD $B9FF, Y : STA $02
    
    SEP #$20
    
    JSL Dungeon_ClearRupeeTile
    
    LDA.b #$0A : JSR Player_DoSfx3

.no_blue_rupee_touch

    LDY.b #$01
    
    LDA $03F1
    
    AND.b #$22 : BEQ BRANCH_BETA2
    AND.b #$20 : BEQ BRANCH_GAMMA2
    
    LDY.b #$02

BRANCH_GAMMA2:

    STY $03F3
    
    BRA BRANCH_DELTA2

BRANCH_BETA2:

    LDY.b #$03
    
    LDA $03F2
    
    AND.b #$22 : BEQ BRANCH_EPSILON2
    AND.b #$20 : BEQ BRANCH_ZETA2
    
    LDY.b #$04

BRANCH_ZETA2:

    STY $03F3
    
    BRA BRANCH_DELTA2

BRANCH_EPSILON2:

    LDA $02E8 : AND.b #$07 : BNE BRANCH_DELTA2
    
    LDA $0E : AND.b #$02 : BNE BRANCH_DELTA2
    
    STZ $03F3

BRANCH_DELTA2:

    LDA $036D : AND.b #$07 : CMP.b #$07 : BNE BRANCH_THETA2
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_THETA2
    
    JSR Player_HaltDashAttack
    
    INC $047A ; This increments when Link is ready to jump down from a ledge.
    
    LDA.b #$01 : STA $037B
    
    LDA.b #$02 : STA $4D
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    BRA BRANCH_IOTA2

BRANCH_THETA2:

    LDA $0341 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_KAPPA2
    
    LDA $0345 : BNE BRANCH_KAPPA2
    
    JSR Player_HaltDashAttack
    
    LDA $1D : BNE BRANCH_LAMBDA2
    
    JSL Player_LedgeJumpInducedLayerChange
    
    BRA BRANCH_IOTA2

BRANCH_LAMBDA2:

    LDA $01 : STA $0345
    
    LDA $26 : STA $0340
    
    STZ $0308
    STZ $0309
    STZ $0376
    STZ $5E
    
    JSL Player_ResetSwimState
    
    LDA.b #$20 : JSR Player_DoSfx2

BRANCH_IOTA2:

    LDA.b #$01 : STA $037B
    
    JSR $C2C3; $3C2C3 IN ROM
    
    BRA BRANCH_MU2

BRANCH_KAPPA2:

    LDA $0343 : AND.b #$02 : BEQ BRANCH_MU2
    
    LDA $0345 : BEQ BRANCH_MU2
    
    LDA $4D : BEQ BRANCH_NU2
    
    LDA.b #$06 : STA $0E
    
    BRA BRANCH_MU2

BRANCH_NU2:

    JSR Player_HaltDashAttack
    
    STZ $0345
    
    LDA $0340 : STA $26
    
    LDA.b #$15
    LDY.b #$00
    
    ; $498FC IN ROM
    JSL AddTransitionSplash : BCC BRANCH_XI2
    
    LDA.b #$01 : STA $0345
    
    LDA.b #$07 : STA $0E
    
    BRA BRANCH_MU2

BRANCH_XI2:

    LDA.b #$01 : STA $037B

BRANCH_MU2:

    JSR $C2C3 ; $3C2C3 IN ROM
    
    LDA $58 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_OMICRON2
    
    LDA $46 : BEQ BRANCH_PI2
    
    LDA $58 : AND.b #$07 : STA $0E
    
    BRL BRANCH_THEL

BRANCH_PI2:

    LDA $02C0 : AND.b #$77 : BEQ BRANCH_RHO2
    
    ; Link is going up a inter-floor staircase so far
    LDY.b #$08
    
    AND.b #$70 : BEQ BRANCH_SIGMA2
    
    ; bits in the upper nybble were set, link is going down an inter-floor staircase
    LDY.b #$10

BRANCH_SIGMA2:

    STY $11
    
    LDA.b #$07 : STA $10
    
    JSR Player_HaltDashAttack

BRANCH_RHO2:

    LDA $66 : AND.b #$02 : BNE BRANCH_OMICRON2
    
    LDA.b #$02 : STA $5E
    
    LDA.b #$01 : STA $57
    
    RTS

BRANCH_OMICRON2:

    LDA.b $5E : CMP.b #$02 : BNE BRANCH_TAU2
    
    LDX.b #$10
    
    LDA $0372 : BNE BRANCH_UPSILON2
    
    LDX.b #$00

BRANCH_UPSILON2:

    STX $5E

BRANCH_TAU2:

    LDA $57 : CMP.b #$01
    
    BNE BRANCH_PHI2
    
    LDX.b #$02 : STX $57

BRANCH_PHI2:

    LDA $59 : AND.b #$05 : BEQ BRANCH_CHI2
    
    LDA $0E : AND.b #$02 : BNE BRANCH_CHI2
    
    LDA $5D
    
    CMP.b #$05 : BEQ BRANCH_PSI2
    CMP.b #$02 : BEQ BRANCH_PSI2
    
    LDA.b #$09 : STA $5C
    
    STZ $5A
    
    LDA.b #$01 : STA $5B
    
    LDA.b #$01 : STA $5D

BRANCH_PSI2:

    RTS

BRANCH_CHI2:

    STZ $5A
    
    LDA $02E8 : AND.b #$07 : BEQ BRANCH_OMEGA2
    
    LDA $46 : ORA $031F : ORA $55 : BNE BRANCH_ALIF
    
    LDA $20
    
    LDY $66 : BNE BRANCH_BET
    
    AND.b #$04 : BEQ BRANCH_KAF
    
    BRA BRANCH_OMEGA2

BRANCH_BET:

    AND.b #$04 : BEQ BRANCH_OMEGA2

BRANCH_KAF:

    LDA $031F : BNE BRANCH_OMEGA2
    
    LDA $7EF35B : TAY
    
    LDA $BA07, Y : STA $0373
    
    JSR Player_HaltDashAttack
    JSR $AE54   ; $3AE54 IN ROM
    
    BRL BRANCH_$39222

BRANCH_ALIF:

    LDA $02E8 : AND.b #$07 : STA $0E

BRANCH_OMEGA2:

    LDA $046C  : BEQ BRANCH_DEL
    CMP.b #$04 : BEQ BRANCH_DEL
    
    LDA $EE : BNE BRANCH_THEL

BRANCH_DEL:

    LDA $5F : ORA $60 : BEQ BRANCH_SOD
    
    LDA $6A : BNE BRANCH_SOD
    
    LDA $5F : STA $02C2
    
    DEC $61 : BPL BRANCH_THEL
    
    REP #$20
    
    LDY.b #$0F
    
    LDA $5F

BRANCH_SIN:

    ASL A : BCC BRANCH_DOD
    
    PHA : PHY
    
    SEP #$20
    
    ; $3ED2C IN ROM
    JSR $ED2C : BCS BRANCH_TOD
    
    STX $0E
    
    TYA : ASL A : TAX
    
    ; $3ED3F IN ROM
    JSR $ED3F : BCS BRANCH_TOD
    
    LDA $0E : ASL A : TAY
    
    JSR $F0D9   ; $3F0D9 IN ROM
    
    TYX
    
    LDY $66
    
    TYA : ASL A : STA $05F8, X : STA $0478
    
    LDA $05F0, X
    
    CPY.b #$01 : BNE BRANCH_ZOD
    
    DEC A

BRANCH_ZOD:

    AND.b #$0F : STA $05E8, X

BRANCH_TOD:

    REP #$20

BRANCH_DOD:

    PLY : PLA
    
    DEY : BPL BRANCH_SIN
    
    SEP #$20

BRANCH_SOD:

    LDA.b #$15 : STA $61

; *$3BDB1 LONG BRANCH LOCATION
BRANCH_THEL:

    LDA $0E : AND.b #$07 : BNE BRANCH_RHA
    
    BRL BRANCH_NU3

BRANCH_RHA:

    LDA $5D : CMP.b #$04 : BNE BRANCH_ZHA
    
    LDA $0310 : BNE BRANCH_SHIN
    
    JSR Player_ResetSwimCollision

BRANCH_SHIN:

    LDA $6A : BEQ BRANCH_ZHA
    
    JSR $C1E4   ; $3C1E4 IN ROM
    
    BRA BRANCH_FATHA

BRANCH_ZHA:

    LDA $0E : AND.b #$02 : BNE BRANCH_KESRA
    
    LDA $0E : AND.b #$05 : CMP.b #$05 : BNE BRANCH_DUMMA

BRANCH_KESRA:

    LDA $0E : PHA
    
    JSR $C1A1 ; $3C1A1 IN ROM
    JSR $91F1 ; $391F1 IN ROM
    
    PLA : STA $0E
    
    LDA.b #$01 : STA $0302
    
    LDA $0E : AND.b #$02 : CMP.b #$02 : BNE BRANCH_YEH
    
    JSR $C1E4   ; $3C1E4 IN ROM
    
    BRA BRANCH_FATHA

BRANCH_YEH:

    LDA $6A : CMP.b #$01 : BNE BRANCH_EIN

BRANCH_GHEIN:

    BRL BRANCH_IOTA3

BRANCH_EIN:

    JSR $C1E4   ; $3C1E4 IN ROM
    
    LDA $6A : CMP.b #$02 : BEQ BRANCH_GHEIN

BRANCH_FATHA:

    LDA $0E : AND.b #$05 : CMP.b #$05 : BEQ BRANCH_JIIM
    
    AND.b #$04 : BEQ BRANCH_ALPHA3
    
    LDY.b #$01
    
    LDA $30 : BMI BRANCH_BETA3
    
    EOR.b #$FF : INC A

BRANCH_BETA3:

    BPL BRANCH_GAMMA3
    
    LDY.b #$FF

BRANCH_GAMMA3:

    STY $00 : STZ $01
    
    LDA $0E : AND.b #$02 : BNE BRANCH_DELTA3
    
    LDA $22 : AND.b #$07 : BNE BRANCH_EPSILON3
    
    JSR $C1A1   ; $3C1A1 IN ROM
    JSR $91F1   ; $391F1 IN ROM
    
    BRA BRANCH_DELTA3

BRANCH_ALPHA3:

    LDY.b #$01
    
    LDA $30 : BPL BRANCH_ZETA3
    
    EOR.b #$FF : INC A

BRANCH_ZETA3:

    BPL BRANCH_THETA3
    
    LDY.b #$FF

BRANCH_THETA3:

    STY $00 : STZ $01
    
    LDA $0E : AND.b #$02 : BNE BRANCH_DELTA3
    
    LDA $22 : AND.b #$07
    
    BNE BRANCH_EPSILON3

BRANCH_JIIM:

    JSR $C1A1 ; $3C1A1 IN ROM
    JSR $91F1 ; $391F1 IN ROM
    
    BRA BRANCH_DELTA3

BRANCH_EPSILON3:

    JSR $C229 ; $3C229 IN ROM
    JMP $D485 ; $3D485 IN ROM

BRANCH_DELTA3:

    LDA $66 : ASL A : CMP $2F : BNE BRANCH_IOTA3
    
    LDA $0315 : AND.b #$01 : ASL A : TSB $48
    
    LDA $3C : BNE BRANCH_KAPPA3
    
    DEC $0371 : BPL BRANCH_LAMBDA3

BRANCH_KAPPA3:

    LDY $0315
    
    LDA $02F6 : AND.b #$20 : BEQ BRANCH_MU3
    
    LDA $0315 : ASL #3 : TAY

BRANCH_MU3:

    TYA : TSB $48
    
    BRA BRANCH_IOTA3

BRANCH_NU3:

    LDA $EE : BNE BRANCH_LAMBDA3
    
    LDA $48 : AND.b #$F6 : STA $48

BRANCH_IOTA3:

    LDA.b #$20 : STA $0371
    
    LDA $48 : AND.b #$FD : STA $48

BRANCH_LAMBDA3:

    RTS
}

; *$3BEAF-$3C16C LONG BRANCH LOCATION
{
    ; This routine seems to occur whenever Link moves up or down one pixel
    
    LDA $5E : CMP.b #$02 : BNE .notOnStairs
    
    LDX.b #$10
    
    LDA $0372 : BNE .dashing
    
    LDX.b #$00

.dashing

    ; Set speed to either walking or dashing speed (probably in anticipation of us being off those stairs)
    STX $5E

.notOnStairs

    LDA $59 : AND.b #$05 : BEQ .safeFromHoles
    
    LDA $0E : AND.b #$02 : BNE .safeFromHoles
    
    ; Is Link on a turtle rock platform
    LDA $5D : CMP.b #$05 : BEQ .return
    
    ; Is Link in a recoil state?
    CMP.b #$02 : BEQ .return
    
    LDA.b #$09 : STA $5C
    
    STZ $5A
    
    LDA.b #$01 : STA $5B
    
    ; Put Link into the near a hole / falling into a hole state
    LDA.b #$01 : STA $5D

.return

    RTS

.safeFromHoles

    LDA $0366 : AND.b #$02 : BEQ .notNearReadableTile
    
    LDA $036A : LSR A : STA $0368
    
    BRA .nearReadableTile

.notNearReadableTile

    STZ $0368

.nearReadableTile

    ; See if Link is touching deep water tiles
    LDA $0341 : AND.b #$02 : BEQ .notTouchingWater
    
    BRA BRANCH_IOTA
    
    ; This location is currently considered to be unreachable unless we connect some more dots...
    
    LDA $0341 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_THETA

BRANCH_IOTA:

    LDA $0345 : BNE BRANCH_THETA
    
    LDA $4D : BNE BRANCH_THETA
    
    JSR $9D84 ; $39D84 IN ROM
    JSR Player_HaltDashAttack
    
    LDA.b #$01 : STA $0345
    
    LDA $26 : STA $0340
    
    STZ $0376
    STZ $5E
    
    JSL Player_ResetSwimState
    
    LDA $0351 : CMP.b #$01 : BNE BRANCH_KAPPA
    
    JSR $AE54 ; $3AE54 IN ROM
    
    ; Do we have the flippers?
    LDA $7EF356 : BEQ BRANCH_KAPPA
    
    LDA $02E0 : BNE BRANCH_THETA
    
    LDA.b #$04 : STA $5D
    
    BRA BRANCH_THETA

BRANCH_KAPPA:

    LDA.b #$20 : JSR Player_DoSfx2
    
    LDA $3E : STA $20
    LDA $40 : STA $21
    LDA $3F : STA $22
    LDA $41 : STA $23
    
    LDA.b #$01 : STA $037B
    
    JSR $C2C3 ; $3C2C3 IN ROM

.theta
.notTouchingWater

    LDA $0345 : BEQ BRANCH_LAMBDA
    
    LDA $036D : AND.b #$07 : BEQ BRANCH_MU
    
    STA $0E
    
    BRL BRANCH_$3BDB1

BRANCH_MU:

    LDA $58 : AND.b #$07 : CMP.b #$07 : BEQ BRANCH_NU
    
    LDA $0343 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_LAMBDA

BRANCH_NU:

    JSR Player_HaltDashAttack
    
    STZ $0345
    
    LDA $4D : BNE BRANCH_LAMBDA
    
    ; This section of code is what causes us to jump out of the water
    ; at a dock
    LDA $0340 : STA $26
    
    LDA.b #$01 : STA $037B
    
    LDA.b #$15
    LDY.b #$00
    
    ; Jump out of the water onto a docking area
    JSL AddTransitionSplash     ; $498FC IN ROM
    
    BRL BRANCH_$3C2C3

BRANCH_LAMBDA:

    LDA $036E : AND.b #$02 : BNE BRANCH_XI
    
    LDA $0370 : AND.b #$22 : BEQ BRANCH_OMICRON

BRANCH_XI:

    LDA.b #$07 : STA $0E
    
    BRL BRANCH_$3BDB1

BRANCH_OMICRON:

    LDA $036D : AND.b #$70 : BEQ BRANCH_PI
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_PI
    
    JSR Player_HaltDashAttack
    
    LDA.b #$01 : STA $037B : STA $78
    
    LDA.b #$0B : STA $5D
    
    STZ $46
    
    LDA.b #$FF : STA $0364 : STA $0365
    
    STZ $48
    STZ $5E
    
    LDY.b #$02
    LDX.b #$14
    
    LDA $0345 : BEQ BRANCH_RHO
    
    LDY.b #$04
    LDX.b #$0E

BRANCH_RHO:

    STX $0362
    STX $0363
    STY $4D
    
    RTS

BRANCH_PI:

    LDA $036D : AND.b #$07 : BEQ BRANCH_SIGMA
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_SIGMA
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    LDA.b #$01 : STA $037B
    
    JSR Player_HaltDashAttack
    
    STZ $48
    STZ $4E
    
    BRL BRANCH_$3C36C

BRANCH_SIGMA:

    LDA $0345 : BEQ BRANCH_TAU
    
    BRL BRANCH_PSI

BRANCH_TAU:

    LDA $036F : AND.b #$07 : BEQ BRANCH_UPSILON
    
    LDA $036D : AND.b #$77 : BNE BRANCH_UPSILON
    
    LDX.b #$04
    
    LDA $76 : CMP.b #$2F : BEQ BRANCH_PHI
    
    LDX.b #$01

BRANCH_PHI:

    TXA : AND $036F : BEQ BRANCH_UPSILON
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_UPSILON
    
    JSR Player_HaltDashAttack
    
    LDX.b #$10
    
    LDA $036F : AND.b #$04 : BNE BRANCH_CHI
    
    TXA : EOR.b #$FF : INC A : TAX

BRANCH_CHI:

    LDA.b #$01 : STA $037B
    
    STX $28
    
    STZ $48
    STZ $5E

    LDA.b #$01 : STA $037B : STA $78
    
    LDA.b #$02 : STA $4D
    
    LDA.b #$14 : STA $0362 : STA $0363
    
    LDA.b #$FF : STA $0364
    
    STZ $46
    
    LDA.b #$0E : STA $5D
    
    RTS

BRANCH_UPSILON:

    LDA $036E : AND.b #$70 : BEQ BRANCH_PSI
    
    LDA $036D : AND.b #$77 : BNE BRANCH_PSI
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_PSI
    
    JSR Player_HaltDashAttack
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    LDY.b #$03
    
    LDA $036E : AND.b #$40 : BNE BRANCH_OMEGA
    
    LDY.b #$02

BRANCH_OMEGA:

    STY $66
    
    LDA.b #$01 : STA $037B
    
    STZ $48
    STZ $5E
    
    BRL BRANCH_$3C64D

BRANCH_PSI:

    LDA $58 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_ALIF
    
    LDA $46 : BEQ BRANCH_BET
    
    LDA $58 : AND.b #$07
    
    STA $0E
    
    BRL BRANCH_$3BDB1

BRANCH_BET:

    LDA $66 : AND.b #$02 : BNE BRANCH_ALIF
    
    LDA.b #$02 : STA $5E
    
    ; Walking on basic stairs (near Eastern Palace)
    LDA.b #$01 : STA $57
    
    RTS

BRANCH_ALIF:

    LDA $5E : CMP.b #$02 : BNE BRANCH_DEL
    
    LDX.b #$10
    
    LDA $0372 : BNE .dashing
    
    LDX.b #$00

.dashing

    STX $5E

BRANCH_DEL:

    LDA $57 : CMP.b #$01 : BNE BRANCH_SIN
    
    LDX.b #$02 : STX $57

BRANCH_SIN:

    LDA $0C : AND.b #$05 : BEQ BRANCH_SHIN
    
    LDA $0E : AND.b #$07 : BNE BRANCH_SHIN
    
    JSR $E076 ; $3E076 IN ROM
    
    LDA $6B : AND.b #$0F : BEQ BRANCH_SHIN
    
    RTS

BRANCH_SHIN:

    STZ $6B
    
    ; the AND with 0x02 ensures that it's a centered push against the gravestone.
    LDA $02E7 : AND.b #$02 : BEQ .resetGravestoneCounter
    
    ; If the last direction Link moved was any direction other than up, we reset the counter
    LDA $66 : BNE .resetGravestoneCounter
    
    ; dashing?
    LDA $0372 : BNE .moveGravestone
    
    DEC $61 : BPL .dontMoveGravestone

.moveGravestone

    LDA $0E : PHA
    
    LDY.b #$04
    LDA.b #$24
    
    JSL AddGravestone
    
    PLA : STA $0E

.resetGravestoneCounter

    LDA.b #$34 : STA $61

.dontMoveGravestone

    LDA $02E8 : AND.b #$07 : BEQ BRANCH_ZOD
    
    LDA $46 : ORA $031F : ORA $55 : BNE BRANCH_HEH
    
    LDA $20
    
    LDY $66 : BNE BRANCH_JIIM
    
    AND.b #$04 : BEQ BRANCH_EIN
    
    BRA BRANCH_ZOD

BRANCH_JIIM:

    AND.b #$04 : BEQ BRANCH_ZOD

BRANCH_EIN:

    LDA $7EF35B : TAY
    
    LDA $BA07, Y : STA $0373
    
    JSR Player_HaltDashAttack
    JSR $AE54 ; $3AE54 IN ROM
    
    BRL BRANCH_$39222

BRANCH_HEH:

    LDA $02E8 : AND.b #$07 : STA $0E

BRANCH_ZOD:

    BRL BRANCH_$3BDB1
}

; ==============================================================================

    ; *$3C16D-$3C1A0 LOCAL
    {
        ; Check the sub sub mode we're in.
        LDA $4D : CMP.b #$01 : BEQ BRANCH_ALPHA
        
        ; Is Link running? Bypass waiting to jump off of a ledge. I think...
        LDA $0372 : BNE BRANCH_BETA
        
        DEC $0375 : BPL BRANCH_ALPHA
        
        LDA.b #$13 : STA $0375
        
        BRA BRANCH_GAMMA
    
    BRANCH_BETA:
    
        JSR $C189 ; $3C189 IN ROM
    
    BRANCH_GAMMA:
    
        SEC
        
        RTS
    
    ; *$3C189 ALTERNATE ENTRY POINT
    BRANCH_ALPHA:
    
        REP #$20
        
        ; Restore previous coordinates? (So as to not prematurely jump off
        ; of the ledge)?
        LDA $0FC4 : STA $20
        LDA $0FC2 : STA $22
        
        SEP #$20
        
        STZ $2A
        STZ $2B
        
        ; \optimize Zero length banch.
        LDA $1B : BNE .indoors
        
        ; What was here? Hrm.
        
    .indoors
    
    ; *$3C19F ALTERNATE ENTRY POINT
    
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$3C1A1-$3C1E3 LOCAL
    {
        ; Dashing?
        LDA $0372 : BEQ BRANCH_$3C19F
        
        ; Check if we just started dashing
        LDA $02F1 : CMP.b #$40 : BEQ BRANCH_$3C19F
        
        ; presumably this checks collision with rock piles?
        LDA $02EF : AND.b #$70 : BEQ BRANCH_3C19F
        
        JSL Overworld_SmashRockPile_normalCoords    ; $DC076 IN ROM
        
        BCC BRANCH_ALPHA
        
        JSR $C1C3 ; $3C1C3 IN ROM
    
    BRANCH_ALPHA:
    
        ; $DC063 IN ROM
        JSL Overworld_SmashRockPile_downOneTile : BCC BRANCH_BETA
    
    ; *$3C1C3 ALTERNATE ENTRY POINT
    
        LDX.b #$08
    
    BRANCH_DELTA:
    
        CMP $B1AD, X : BEQ BRANCH_GAMMA
        
        DEX : BPL BRANCH_DELTA
        
        BRA BRANCH_BETA
    
    BRANCH_GAMMA:
    
        CPX.b #$02 : BEQ BRANCH_EPSILON
        CPX.b #$04 : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        PHX
        
        LDA.b #$32 : JSR Player_DoSfx3
        
        PLX

    BRANCH_ZETA:

        TXA
        
        JSL Sprite_SpawnImmediatelySmashedTerrain

    BRANCH_BETA:

        RTS
    }

    ; *$3C1E4-$3C1FE LOCAL
    {
        REP #$20
        
        LDA $51 : AND.w #$0007
        
        LDY $30 : BPL BRANCH_ALPHA

        SUB.w #$0008

    BRANCH_ALPHA:

        EOR.w #$FFFF : INC A : ADD $20 : STA $20
        
        SEP #$20
        
        RTS
    }

    ; *$3C1FF-$3C23C LOCAL
    {
        LDA $0E : AND.b #$04 : BEQ BRANCH_ALPHA
        
        LDY.b #$01
        
        LDA $30 : BMI BRANCH_BETA
        
        EOR.b #$FF : INC A
    
    BRANCH_BETA:
    
        BPL BRANCH_GAMMA
        
        LDY.b #$FF
    
    BRANCH_GAMMA:
    
        STY $00
        STZ $01
        
        BRA BRANCH_DELTA
    
    BRANCH_ALPHA:
    
        LDY.b #$01
        
        LDA $30 : BPL BRANCH_EPSILON
        
        EOR.b #$FF : INC A
    
    BRANCH_EPSILON:
    
        BPL BRANCH_ZETA
        
        LDY.b #$FF
    
    BRANCH_ZETA:
    
        STY $00
        STZ $01
    
    ; *$3C229 ALTERNATE ENTRY POINT
    BRANCH_DELTA:
    
        REP #$20
        
        LDA $00 : CMP.w #$0080 : BCC BRANCH_THETA
        
        ORA.w #$FF00
    
    BRANCH_THETA:
    
        ADD $22 : STA $22
        
        SEP #$20
        
        RTS
    }

    ; *$3C23D-$3C29E LONG BRANCH LOCATION
    {
        LDA.b #$02 : TSB $50
        
        LDA $0E : LSR #4 : ORA $0E : AND.b #$0F : STA $00
        
        AND.b #$07 : BNE BRANCH_ALPHA
        
        STZ $6C
        
        BRA BRANCH_BETA

    BRANCH_ALPHA:

        LDA $22 : CMP.b #$80 : BCC BRANCH_GAMMA
        
        LDY.b #$01
        
        LDA $30 : BMI BRANCH_DELTA
        
        EOR.b #$FF : INC A

    BRANCH_DELTA:

        BPL BRANCH_EPSILON
        
        LDY.b #$FF

    BRANCH_EPSILON:

        STY $00
        STZ $01
        
        LDY.b #$04
        
        BRA BRANCH_ZETA

    BRANCH_GAMMA:

        LDY.b #$01
        
        LDA $30 : BPL BRANCH_THETA
        
        EOR.b #$FF : INC A

    BRANCH_THETA:

        BPL BRANCH_IOTA
        
        LDY.b #$FF

    BRANCH_IOTA:

        STY $00
        STZ $01
        
        LDY.b #$06

    BRANCH_ZETA:

        LDA $50 : AND.b #$01 : BNE BRANCH_KAPPA
        
        STY $2F

    BRANCH_KAPPA:

        REP #$20
        
        LDA $00 : CMP.w #$0080 : BCC BRANCH_LAMBDA
        
        ORA.w #$FF00

    BRANCH_LAMBDA:

        ADD $22 : STA $22
        
        SEP #$20

    BRANCH_BETA:

        RTS
    }

    ; *$3C29F-$3C2B9 LOCAL
    {
        REP #$20
        
        LDA $30 : AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_ALPHA
        
        ORA.w #$FF00
    
    BRANCH_ALPHA:
    
        EOR.w #$FFFF : INC A : ADD $20 : STA $20
        
        SEP #$20
        
        RTS
    }

    ; *$3C2C3-$3C30B LOCAL
    {
        LDA $1B : BNE BRANCH_ALPHA
        
        LDX.b #$02
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDX $1D
        
        LDA $047A : BEQ BRANCH_BETA
        
        LDY.b #$00
    
    BRANCH_BETA:
    
        STX $00
        
        LDA $C2BA, X : TAX
        
        LDA $66 : BNE BRANCH_GAMMA
        
        TXA : EOR.b #$FF : INC A : TAX
    
    BRANCH_GAMMA:
    
        STX $27
        
        STZ $28
        
        LDX $00
        
        LDA $C2B2, X : STA $29 : STA $02C7
        
        STZ $24
        STZ $25
        
        LDA $C2C0, X : STA $46
        
        LDA $4D : CMP.b #$02 : BEQ BRANCH_DELTA
        
        LDA.b #$01 : STA $4D
        
        STZ $0360
    
    BRANCH_DELTA:
    
        LDA.b #$06 : STA $5D
        
        RTS
    }

    ; *$3C36C-$3C408 LONG BRANCH LOCATION
    {
        LDA $20 : STA $32 : PHA
        LDA $21 : STA $33 : PHA
    
    BRANCH_ALPHA:
    
        REP #$20
        
        LDA $20 : SUB.w #$0010 : STA $20
        
        SEP #$20
        
        LDA $66 : ASL A : TAY
        
        JSR $CDCB ; $3CDCB IN ROM
        
        LDA $0343 : ORA $035B : ORA $0357 : ORA $0341 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_ALPHA
        
        LDA $0341 : AND.b #$07 : BEQ BRANCH_BETA
        
        LDA.b #$01 : STA $4D
        
        STZ $0360
        
        LDA.b #$01 : STA $0345
        
        LDA $26 : STA $0340
        
        JSL Player_ResetSwimState
        
        STZ $0376
        STZ $5E
    
    BRANCH_BETA:
    
        REP #$20
        
        LDA $20 : SUB.w #$0010 : STA $20
        
        LDA $32 : SUB $20      : STA $32
        
        SEP #$20
        
        PLA : STA $21
        PLA : STA $20
        
        LDA $32 : LSR #3 : TAY
        
        LDA $C30C, Y : TAX
        
        LDA $66 : BNE BRANCH_GAMMA
        
        TXA : EOR.b #$FF : INC A : TAX
    
    BRANCH_GAMMA:
    
        STX $27
        STZ $28
        
        LDA $C32C, Y : STA $29 : STA $02C7
        
        STZ $24 : STZ $25
        
        LDA $C34C, Y : STA $46
        
        LDA.b #$02 : STA $4D
        
        STZ $0360
        
        LDA.b #$06 : STA $5D
        
        RTS
    }

; *$3C46D-$3C4D3 LOCAL
{
    LDA $3E : PHA
    LDA $22 : PHA
    LDA $23 : PHA
    
    LDX $66 : PHX
    
    LDY.b #$01
    
    CPX.b #$02
    
    BNE BRANCH_ALPHA
    
    LDY.b #$FF

BRANCH_ALPHA:

    STY $28
    
    LDA.b #$00 : STA $66
    
    JSR $8E7B ; $38E7B IN ROM
    
    PLX
    
    PLA : STA $23
    PLA : STA $22
    PLA : STA $3E
    
    REP #$20
    
    LDA $32 : SUB $20 : LSR #3 : TAY
    
    LDA $32 : STA $20
    
    SEP #$20
    
    LDA $C409, Y : EOR.b #$FF : INC A : STA $27
    
    LDA $C429, Y
    
    CPX.b #$02
    
    BNE BRANCH_BETA
    
    EOR.b #$FF : INC A

BRANCH_BETA:

    STA $28
    
    LDA $C449, Y : STA $29 : STA $02C7
    
    STZ $24
    STZ $25
    STZ $0364
    
    LDA.b #$02 : STA $4D
    
    STZ $0360
    
    LDA.b #$0D : STA $5D
    
    RTS
}

; *$3C4D4-$3C8E8 LOCAL
{
    LDA $31 : BNE BRANCH_ALPHA
    
    RTS

BRANCH_ALPHA:

    LDA $6C : CMP.b #$02 : BNE BRANCH_BETA
    
    LDY.b #$04
    
    LDA $22 : CMP.b #$80 : BCC BRANCH_GAMMA
    
    BRA BRANCH_DELTA

BRANCH_BETA:

    LDY.b #$04
    
    LDA $31 : BMI BRANCH_GAMMA

BRANCH_DELTA:

    LDY.b #$06

BRANCH_GAMMA:

    TYA : LSR A : STA $66
    
    JSR $CE2A ; $3CE2A IN ROM; Has to do with detecting areas around chests.
    
    LDA $1B : BNE BRANCH_EPSILON
    
    BRL BRANCH_$3C8E9

BRANCH_EPSILON:

    LDA $0308 : BMI BRANCH_ZETA
    
    LDA $46 : BEQ BRANCH_THETA

BRANCH_ZETA:

    LDA $0E : LSR #4 : TSB $0E
    
    BRL BRANCH_RHO

BRANCH_THETA:

    LDA $6A : BNE BRANCH_IOTA
    
    STZ $57

BRANCH_IOTA:

    LDA $6C : CMP.b #$01 : BNE BRANCH_KAPPA
    
    LDA $6A : BNE BRANCH_KAPPA
    
    LDA $046C : CMP.b #$03 : BNE BRANCH_LAMBDA
    
    LDA $EE : BEQ BRANCH_LAMBDA
    
    BRL BRANCH_TAU

BRANCH_LAMBDA:

    JSR $CB84   ; $3CB84 IN ROM
    JSR $CBDD   ; $3CBDD IN ROM
    
    BRL BRANCH_$3D667

BRANCH_KAPPA:

    LDA $0E : AND.b #$70 : BEQ BRANCH_RHO
    
    STZ $05
    
    LDA $0F : AND.b #$07 : BEQ BRANCH_NU
    
    LDY.b #$02
    
    LDA $31 : BCC BRANCH_XI
    
    LDY.b #$03

BRANCH_XI:

    LDA $B7C3, Y : STA $49

BRANCH_NU:

    LDA.b #$02 : STA $6C
    
    STZ $03F3
    
    LDA $0E : AND.b #$70 : CMP.b #$70 : BEQ BRANCH_OMICRON
    
    LDA $0E : AND.b #$07 : BNE BRANCH_PI
    
    LDA $0E : AND.b #$70 : BNE BRANCH_OMICRON
    
    BRA BRANCH_RHO

BRANCH_PI:

    STZ $6B
    STZ $6C
    
    JSR $CB84   ; $3CB84 IN ROM
    JML $07CB9F ; $3CB9F IN ROM

BRANCH_OMICRON:

    LDA $0315 : AND.b #$02 : BNE BRANCH_SIGMA
    
    LDA $50 : AND.b #$FD : STA $50

BRANCH_SIGMA:

    RTS

BRANCH_RHO:

    LDA $0315 : AND.b #$02 : BNE BRANCH_TAU
    
    LDA $50 : AND.b #$FD : STA $50
    
    STZ $6C
    STZ $EF
    STZ $49

BRANCH_TAU:

    LDA $0E : AND.b #$02 : BNE BRANCH_UPSILON
    
    LDA $0C : AND.b #$05 : BEQ BRANCH_UPSILON
    
    STZ $03F3
    
    JSR $E112 ; $3E112 IN ROM
    
    LDA $6B : AND.b #$0F : BEQ BRANCH_UPSILON
    
    RTS

BRANCH_UPSILON:

    STZ $6B
    
    LDA $EE : BNE BRANCH_PHI
    
    LDA $034C : AND.b #$07 : BEQ BRANCH_CHI
    
    LDA.b #$01 : TSB $0322
    
    BRA BRANCH_PSI

BRANCH_CHI:

    LDA $02E8 : AND.b #$07 : BNE BRANCH_PSI
    
    LDA $0E : AND.b #$02 : BNE BRANCH_PSI
    
    LDA $0322 : AND.b #$FE : STA $0322
    
    BRA BRANCH_PSI

BRANCH_PHI:

    LDA $0320 : AND.b #$07 : BEQ BRANCH_OMEGA
    
    LDA.b #$02 : TSB $0322
    
    BRA BRANCH_PSI

BRANCH_OMEGA:

    ; Apparently they knew how to use TSB but now how to use TRB >___>
    ; LDA.b #$02 : TRB $0322 would have sooooo worked here
    LDA $0322 : AND.b #$FD : STA $0322

BRANCH_PSI:

    LDA $02F7 : AND.b #$22 : BEQ .no_blue_rupee_touch
    
    LDX.b #$00
    
    AND.b #$20 : BEQ .touched_upper_rupee_half
    
    LDX.b #$08

.touched_upper_rupee_half

    STX $00
    STZ $01
    
    LDA $66 : ASL A : TAY
    
    REP #$20
    
    LDA $7EF360 : ADD.w #$0005 : STA $7EF360
    
    ; Configure the address where the clearing of the rupee tile will occur.
    LDA $20 : ADD $B9F7, Y : SUB $00 : STA $00
    LDA $22 : ADD $B9FF, Y           : STA $02
    
    SEP #$20
    
    JSL Dungeon_ClearRupeeTile
    
    LDA.b #$0A : JSR Player_DoSfx3

.no_blue_rupee_touch

    LDY.b #$01
    
    LDA $03F1
    
    AND.b #$22 : BEQ BRANCH_DEL
    AND.b #$20 : BEQ BRANCH_THEL
    
    LDY.b #$02

BRANCH_THEL:

    STY $03F3

; *$3C64D LONG BRANCH LOCATION

    BRA BRANCH_SIN

BRANCH_DEL:

    LDY.b #$03
    
    LDA $03F2
    
    AND.b #$22 : BEQ BRANCH_SHIN
    AND.b #$20 : BEQ BRANCH_SOD
    
    LDY.b #$04

BRANCH_SOD:

    STY $03F3
    
    BRA BRANCH_SIN

BRANCH_SHIN:

    LDA $02E8 : AND.b #$07 : BNE BRANCH_SIN
    
    LDA $0E : AND.b #$02 : BNE BRANCH_SIN
    
    STZ $03F3

BRANCH_SIN:

    LDA $036E : AND.b #$07 : CMP.b #$07 : BNE BRANCH_DOD
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_DOD
    
    JSR Player_HaltDashAttack
    
    INC $047A
    
    LDA.b #$02 : STA $4D
    
    BRA BRANCH_TOD

BRANCH_DOD:

    LDA $0341 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_ZOD
    
    LDA $0345 : BNE BRANCH_ZOD
    
    LDA $5D : CMP.b #$06 : BEQ BRANCH_ZOD
    
    LDA $3E : STA $20
    LDA $40 : STA $21
    LDA $3F : STA $22
    LDA $41 : STA $23
    
    JSR Player_HaltDashAttack
    
    LDA $1D : BNE BRANCH_HEH
    
    JSL Player_LedgeJumpInducedLayerChange
    
    BRA BRANCH_TOD

BRANCH_HEH:

    LDA.b #$01 : STA $0345
    
    LDA $26 : STA $0340
    
    STZ $0308
    STZ $0309
    STZ $0376
    STZ $5E
    
    JSL Player_ResetSwimState

BRANCH_TOD:

    LDA.b #$01 : STA $037B
    
    JSR $CC3C ; $3CC3C IN ROM
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    BRA BRANCH_JIIM

BRANCH_ZOD:

    LDA $0343 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_JIIM
    
    LDA $0345 : BEQ BRANCH_JIIM
    
    LDA $4D : BEQ BRANCH_EIN
    
    LDA.b #$07 : STA $0E
    
    BRA BRANCH_JIIM

BRANCH_EIN:

    JSR Player_HaltDashAttack
    
    LDA $4D : BNE BRANCH_JIIM
    
    LDA $0340 : STA $26
    
    STZ $0345
    
    LDA.b #$15
    LDY.b #$00
    
    JSL AddTransitionSplash ; $498FC IN ROM
    
    LDA.b #$01 : STA $037B
    
    JSR $CC3C ; $3CC3C IN ROM

BRANCH_JIIM:

    LDA $59 : AND.b #$05 : BEQ BRANCH_GHEIN
    
    LDA $0E : AND.b #$02 : BNE BRANCH_GHEIN
    
    LDA $5D
    
    CMP.b #$05 : BEQ BRANCH_FATHA
    CMP.b #$02 : BEQ BRANCH_FATHA
    
    LDA.b #$09 : STA $5C
    
    STZ $5A
    
    LDA.b #$01 : STA $5B
    LDA.b #$01 : STA $5D

BRANCH_FATHA:

    RTS

BRANCH_GHEIN:

    STZ $5B
    
    LDA $02E8 : AND.b #$07 : BEQ BRANCH_KESRA
    
    LDA $46 : ORA $031F : ORA $55 : BNE BRANCH_DUMMA
    
    LDA $22
    
    LDY $66 : CPY.b #$02 : BNE BRANCH_YEH
    
    AND.b #$04 : BEQ BRANCH_WAW
    
    BRA BRANCH_KESRA

BRANCH_YEH:

    AND.b #$04 : BEQ BRANCH_KESRA

BRANCH_WAW:

    LDA $031F : BNE BRANCH_KESRA
    
    LDA $7EF35B : TAY
    
    LDA $BA07, Y : STA $0373
    
    JSR Player_HaltDashAttack
    JSR $AE54 ; $3AE54 IN ROM
    
    BRL BRANCH_$39222

BRANCH_DUMMA:

    LDA $02E8 : AND.b #$07 : STA $0E

BRANCH_KESRA:

    LDA $046C  : BEQ BRANCH_ALPHA2
    CMP.b #$04 : BEQ BRANCH_ALPHA2
    
    LDA $EE : BNE BRANCH_BETA2

BRANCH_ALPHA2:

    LDA $5F : ORA $60 : BEQ BRANCH_GAMMA2
    
    LDA $6A : BNE BRANCH_GAMMA2
    
    LDA $5F : STA $02C2
    
    DEC $61 : BPL BRANCH_BETA2
    
    REP #$20
    
    LDY.b #$0F
    
    LDA $5F

BRANCH_THETA2:

    ASL A : BCC BRANCH_DELTA2
    
    PHA : PHY
    
    SEP #$20
    
    ; $3ED2C IN ROM
    JSR $ED2C : BCS BRANCH_EPSILON2
    
    STX $0E
    
    TYA : ASL A : TAX
    
    ; $3ED3F IN ROM
    JSR $ED3F : BCS BRANCH_EPSILON2
    
    LDA $0E : ASL A : TAY
    
    JSR $F0D9 ; $3F0D9 IN ROM
    
    TYX
    
    LDY $66
    
    TYA : ASL A : STA $05F8, X : STA $0474
    
    LDA $05E4, X : CPY.b #$02 : BEQ BRANCH_ZETA2
    
    DEC A

BRANCH_ZETA2:

    AND.b #$0F : STA $05E8, X

BRANCH_EPSILON2:

    REP #$20
    
    PLY : PLA

BRANCH_DELTA2:

    DEY : BPL BRANCH_THETA2
    
    SEP #$20

BRANCH_GAMMA2:

    LDA.b #$15 : STA $61

BRANCH_BETA2:

    LDA $6A : BNE BRANCH_IOTA2
    
    STZ $57
    
    LDA $5E : CMP.b #$02 : BNE BRANCH_IOTA2
    
    STZ $5E

; *$3C7FC LONG BRANCH LOCATION
BRANCH_IOTA2:

    LDA $0E : AND.b #$07 : BNE BRANCH_KAPPA2
    
    BRL BRANCH_PI2

BRANCH_KAPPA2:

    LDA $5D : CMP.b #$04 : BNE BRANCH_LAMBDA2
    
    LDA $0312 : BNE BRANCH_LAMBDA2
    
    JSR Player_ResetSwimCollision

BRANCH_LAMBDA2:

    LDA $0E : AND.b #$02 : BEQ BRANCH_MU2
    
    LDA $0E : PHA
    
    JSR $C1A1 ; $3C1A1 IN ROM
    JSR $91F1 ; $391F1 IN ROM
    
    PLA : STA $0E

BRANCH_MU2:

    LDA.b #$01 : STA $0302
    
    LDA $0E : AND.b #$07 : CMP.b #$07 : BNE BRANCH_NU2
    
    JSR $CB84 ; $3CB84 IN ROM
    
    BRA BRANCH_XI2

BRANCH_NU2:

    LDA $6A : CMP.b #$02 : BNE BRANCH_OMICRON2

BRANCH_PI2:

    BRL BRANCH_ALPHA3

BRANCH_OMICRON2:

    JSR $CB84 ; $3CB84 IN ROM
    
    LDA $6A : CMP.b #$01 : BEQ BRANCH_PI2

BRANCH_XI2:

    LDA $0E : AND.b #$05 : CMP.b #$05 : BEQ BRANCH_RHO2
    
    AND.b #$04 : BEQ BRANCH_SIGMA2
    
    LDY.b #$01
    
    LDA $31 : BCC BRANCH_TAU2
    
    EOR.b #$FF : INC A

BRANCH_TAU2:

    BPL BRANCH_UPSILON2
    
    LDY.b #$FF

BRANCH_UPSILON2:

    STY $00 : STZ $01
    
    LDA $0E : AND.b #$02 : BNE BRANCH_PHI2
    
    LDA $20 : AND.b #$07 : BNE BRANCH_CHI2
    
    JSR $C1A1 ; $3C1A1 IN ROM
    JSR $91F1 ; $391F1 IN ROM
    
    BRA BRANCH_PHI2

BRANCH_SIGMA2:

    LDY.b #$01
    
    LDA $31 : BPL BRANCH_PSI2
    
    EOR.b #$FF : INC A

BRANCH_PSI2:

    BPL BRANCH_OMEGA2
    
    LDY.b #$FF

BRANCH_OMEGA2:

    STY $00 : STZ $01
    
    LDA $0E : AND.b #$02 : BNE BRANCH_PHI2
    
    LDA $20 : AND.b #$07 : BNE BRANCH_CHI2

BRANCH_RHO2:

    JSR $C1A1 ; $3C1A1 IN ROM
    JSR $91F1 ; $391F1 IN ROM
    
    BRA BRANCH_PHI2

BRANCH_CHI2:

    JSR $CBC9 ; $3CBC9 IN ROM
    JMP $D485 ; $3D485 IN ROM

BRANCH_PHI2:

    LDA $66 : ASL A : CMP $2F : BNE BRANCH_ALPHA3
    
    LDA $0315 : AND.b #$01 : ASL A : TSB $48
    
    LDA $3C : BNE BRANCH_BETA3
    
    DEC $0371 : BPL BRANCH_GAMMA3

BRANCH_BETA3:

    LDY $0315
    
    LDA $02F6 : AND.b #$20 : BEQ BRANCH_DELTA3
    
    LDA $0315 : ASL #3 : TAY

BRANCH_DELTA3:

    TYA : TSB $48
    
    BRA BRANCH_ALPHA3
    
    LDA $EE : BNE BRANCH_GAMMA3
    
    LDA $48 : AND.b #$F6 : STA $48

BRANCH_ALPHA3:

    LDA.b #$20 : STA $0371
    
    LDA $48 : AND.b #$FD : STA $48

BRANCH_GAMMA3:

    RTS
}

; *$3C8E9-$3CB83 LONG BRANCH LOCATION
{
    LDA $6A : BNE BRANCH_ALPHA
    
    STZ $57
    
    LDA $5E : CMP.b #$02 : BNE BRANCH_ALPHA
    
    STZ $5E

BRANCH_ALPHA:

    LDA $59 : AND.b #$05 : BEQ BRANCH_BETA
    
    LDA $0E : AND.b #$02 : BNE BRANCH_BETA
    
    LDA $5D
    
    CMP.b #$05 : BEQ BRANCH_GAMMA
    CMP.b #$02 : BEQ BRANCH_GAMMA
    
    LDA.b #$09 : STA $5C
    
    STZ $5A
    
    LDA.b #$01 : STA $5B
    
    LDA.b #$01 : STA $5D

BRANCH_GAMMA:

    RTS

BRANCH_BETA:

    LDA $0366 : AND.b #$02 : BEQ BRANCH_DELTA
    
    LDA $036A : ASL A : STA $0369
    
    BRA BRANCH_EPSILON

BRANCH_DELTA:

    STZ $0369

BRANCH_EPSILON:

    LDA $0341 : AND.b #$04 : BEQ BRANCH_ZETA
    
    BRA BRANCH_THETA
    
    LDA $0341 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_ZETA

BRANCH_THETA:

    LDA $0345 : BNE BRANCH_ZETA
    
    LDA $4D : BNE BRANCH_ZETA
    
    JSR Player_HaltDashAttack
    JSR $9D84 ; $39D84 IN ROM
    
    LDA.b #$01 : STA $0345
    
    LDA $26 : STA $0340
    
    JSL Player_ResetSwimState
    
    STZ $0376
    STZ $5E
    
    LDA $0351 : CMP.b #$01 : BNE BRANCH_IOTA
    
    JSR $AE54 ; $3AE54 IN ROM
    
    LDA $7EF356 : BEQ BRANCH_IOTA
    
    LDA $02E0 : BNE BRANCH_ZETA
    
    LDA.b #$04 : STA $5D
    
    BRA BRANCH_ZETA

BRANCH_IOTA:

    LDA $3E : STA $20
    LDA $40 : STA $21
    
    LDA $3F : STA $22
    LDA $41 : STA $23
    
    LDA.b #$01 : STA $037B
    
    JSR $CC3C ; $3CC3C IN ROM
    
    LDA.b #$20 : JSR Player_DoSfx2

BRANCH_ZETA:
    
    LDA $0345 : BEQ BRANCH_KAPPA
    
    LDA $036E : AND.b #$07 : CMP.b #$07 : BEQ BRANCH_LAMBDA
    
    BRA BRANCH_MU

BRANCH_KAPPA:

    LDA $036D : AND.b #$42 : BEQ BRANCH_MU

BRANCH_LAMBDA:

    LDA.b #$07 : STA $0E
    
    BRL BRANCH_$3C7FC

BRANCH_MU:

    LDA $0343 : AND.b #$07 : CMP.b #$07 : BNE BRANCH_NU
    
    LDA $0345 : BEQ BRANCH_NU
    
    JSR Player_HaltDashAttack
    
    LDA $4D : BNE BRANCH_NU
    
    LDA $0340 : STA $26
    
    STZ $0345
    
    LDA.b #$15
    LDY.b #$00
    
    JSL AddTransitionSplash  ; $498FC IN ROM
    
    LDA.b #$01 : STA $037B
    
    BRL BRANCH_$3CC3C

BRANCH_NU:

    LDA $036E : AND.b #$07 : BEQ BRANCH_XI
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_XI
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    LDX.b #$10
    
    LDA $66 : AND.b #$01 : BNE BRANCH_OMICRON
    
    TXA : EOR.b #$FF : INC A : TAX

BRANCH_OMICRON:

    STX $28
    
    JSR Player_HaltDashAttack
    
    LDA.b #$02 : STA $4D
    
    LDA.b #$14 : STA $0362 : STA $0363
    
    LDA.b #$FF : STA $0364
    
    LDA.b #$0C : STA $5D
    
    LDA.b #$01 : STA $037B : STA $78
    
    STZ $48
    STZ $5E
    
    LDA $1B
    
    BNE BRANCH_PI
    
    LDA.b #$02 : STA $EE

BRANCH_PI:

    LDA $66 : AND.b #$FD : ASL A : TAY
    
    LDA $22 : PHA
    LDA $23 : PHA
    
    JSR $8D2B   ; $38D2B IN ROM
    
    LDA.b #$01 : STA $66
    
    CPX.b #$FF
    
    BEQ BRANCH_RHO
    
    JSR $8B9B ; $38B9B IN ROM
    
    BRL BRANCH_SIGMA

BRANCH_RHO:

    JSR $8AD1; $38AD1 IN ROM

BRANCH_SIGMA:

    PLA : STA $23
    PLA : STA $22
    
    RTS

BRANCH_XI:

    LDA $0370 : AND.b #$77
    
    BEQ BRANCH_TAU
    
    JSR $C16D ; $3C16D IN ROM
    
    BCC BRANCH_TAU
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    LDX.b #$0F
    
    AND.b #$07
    
    BNE BRANCH_UPSILON
    
    LDX.b #$10

BRANCH_UPSILON:

    STX $5D
    
    LDX.b #$10
    
    LDA $66 : AND.b #$01
    
    BNE BRANCH_PHI
    
    LDX.b #$F0

BRANCH_PHI:

    STX $28
    
    JSR Player_HaltDashAttack
    
    LDA.b #$02 : STA $4D
    
    LDA.b #$14 : STA $0362 : STA $0363
    
    LDA.b #$FF : STA $0364
    
    STZ $46
    
    LDA.b #$01 : STA $037B : STA $78
    
    STZ $48
    STZ $5E
    
    RTS

BRANCH_TAU:

    LDA $036E : AND.b #$70 : BEQ BRANCH_CHI
    
    LDA $036E : AND.b #$07 : BNE BRANCH_CHI
    
    LDA $0370 : AND.b #$77 : BNE BRANCH_CHI
    
    LDA $5D : CMP.b #$0D : BEQ BRANCH_CHI
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_CHI
    
    LDA.b #$20 : JSR Player_DoSfx2
    
    JSR Player_HaltDashAttack
    
    LDA.b #$01 : STA $037B
    
    STZ $48
    STZ $5E
    
    BRL BRANCH_$3C46D

BRANCH_CHI:

    LDA $036F : AND.b #$07 : BEQ BRANCH_PSI
    
    LDA $036E : AND.b #$07 : BNE BRANCH_PSI
    
    LDA $0370 : AND.b #$77 : BNE BRANCH_PSI
    
    ; $3C16D IN ROM
    JSR $C16D : BCC BRANCH_PSI
    
    LDX.b #$10
    
    LDA $66 : AND.b #$01 : BNE BRANCH_OMEGA
    
    TXA : EOR.b #$FF : INC A : TAX

BRANCH_OMEGA:

    STX $28
    
    JSR Player_HaltDashAttack
    
    LDA.b #$02 : STA $4D
    
    LDA.b #$14 : STA $0362 : STA $0363
    
    LDA.b #$FF : STA $0364
    
    LDA.b #$0E : STA $5D
    
    STZ $46
    
    LDA.b #$01 : STA $037B : STA $78
    
    STZ $48
    STZ $5E
    
    RTS

BRANCH_PSI:

    LDA $0E : AND.b #$02 : BNE BRANCH_ALIF
    
    LDA $0C : AND.b #$05 : BEQ BRANCH_ALIF
    
    LDA $0372 : BEQ BRANCH_BET
    
    LDA $2F : AND.b #$04 : BEQ BRANCH_ALIF

BRANCH_BET:

    JSR $E112   ; $3E112 IN ROM
    
    LDA $6B : AND.b #$0F : BEQ BRANCH_ALIF
    
    RTS

BRANCH_ALIF:

    STZ $6B
    
    ; check for spike block interactions
    LDA $02E8 : AND.b #$07 : BEQ .noSpikeBlockInteraction
    
    ; link is flashing or otherwise invincible
    LDA $46 : ORA $031F : ORA $55 : BNE .ignoreSpikeBlocks
    
    LDA $22
    
    LDY $66 : CPY.b #$02 : BNE .didntMoveLeft
    
    ; this is a tad strange, seems like more of a tweak than anything else
    AND.b #$04 : BEQ .notOn4PixelGrid
    
    BRA .noSpikeBlockInteraction

.didntMoveLeft

    AND.b #$04 : BEQ .noSpikeBlockInteraction

.notOn4PixelGrid

    ; use armor value to determine damage to be doled out
    LDA $7EF35B : TAY
    
    LDA $BA07, Y : STA $0373
    
    JSR Player_HaltDashAttack
    
    BRL BRANCH_$39222

.ignoreSpikeBlocks

    LDA $02E8 : AND.b #$07 : STA $0E

.noSpikeBlockInteraction

    BRL BRANCH_$3C7FC
}

    ; *$3CB84-$3CB9E LOCAL
    {
        REP #$20
        
        LDA $22 : AND.w #$0007
        
        LDY $31 : BPL BRANCH_ALPHA
        
        SUB.w #$0008
    
    BRANCH_ALPHA:
    
        EOR.w #$FFFF : INC A : ADD $22 : STA $22
        
        SEP #$20
        
        RTS
    }

    ; $3CB9F-$3CBDC JUMP LOCATION
    {
        LDA $0E : AND.b #$04 : BEQ BRANCH_ALPHA
        
        LDY.b #$01
        
        LDA $31 : BMI BRANCH_BETA
        
        EOR.b #$FF : INC A
    
    BRANCH_BETA:
    
        BPL BRANCH_GAMMA
        
        LDY.b #$FF
    
    BRANCH_GAMMA:
    
        STY $00 : STZ $01
        
        BRA BRANCH_DELTA
    
    BRANCH_ALPHA:
    
        LDY.b #$01
        
        LDA $31 : BPL BRANCH_EPSILON
        
        EOR.b #$FF : INC A
    
    BRANCH_EPSILON:
    
        BPL BRANCH_ZETA
        
        LDY.b #$FF
    
    BRANCH_EPSILON:
    
        STY $00 : STZ $01
    
    BRANCH_DELTA:
    
    ; *$3CBC9 ALTERNATE ENTRY POINT
    
        REP #$20
        
        LDA $00 : CMP.w #$0080 : BCC BRANCH_THETA
        
        ORA.w #$FF00
    
    BRANCH_THETA:
    
        ADD $20 : STA $20
        
        SEP #$20
        
        RTS
    }

    ; *$3CBDD-$3CC32 LOCAL
    {
        LDA.b #$02 : TSB $50
        
        LDA $0E : LSR #4 : ORA $0E : AND.b #$0F : STA $00 : AND.b #$07 : BNE BRANCH_ALPHA
        
        STZ $6C
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $20 : CMP.b #$80 : BCC BRANCH_GAMMA
        
        LDA $31 : BMI BRANCH_DELTA
        
        EOR.b #$FF : INC A

    BRANCH_DELTA:

        STA $00 : STZ $01
        
        LDY.b #$00
        
        BRA BRANCH_EPSILON

    BRANCH_GAMMA:

        LDA $31 : BPL BRANCH_ZETA
        
        EOR.b #$FF : INC A

    BRANCH_ZETA:

        STA $00 : STZ $01
        
        LDY.b #$02

    BRANCH_EPSILON:

        LDA $50 : AND.b #$01 : BNE BRANCH_THETA
        
        STY $2F

    BRANCH_THETA:

        REP #$20
        
        LDA $00 : CMP.w #$0080 : BCC BRANCH_IOTA
        
        ORA.w #$FF00

    BRANCH_IOTA:

        ADD $20 : STA $20
        
        SEP #$20

    BRANCH_BETA:

        RTS
    }

    ; *$3CC3C-$3CC82 LOCAL
    {
        LDA $1B : BNE BRANCH_ALPHA
        
        LDX.b #$02
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDX $1D
        
        LDA $047A : BEQ BRANCH_BETA
        
        LDX.b #$00
    
    BRANCH_BETA:
    
        STX $00
        
        LDA $CC33, X : TAX
        
        LDA $66 : AND.b #$01 : BNE BRANCH_GAMMA
        
        TXA : EOR.b #$FF : INC A : TAX
    
    BRANCH_GAMMA:
    
        STX $28
        STZ $27
        
        LDX $00
        
        LDA $CC36, X : STA $29 : STA $02C7
        
        LDA $CC39, X : STA $46
        
        LDA.b $4D : CMP.b #$02 : BEQ BRANCH_DELTA
        
        LDA.b #$01 : STA $4D
        
        STZ $0360
    
    BRANCH_DELTA:
    
        LDA.b #$06 : STA $5D
        
        RTS
    }

    ; *$3CCAB-$3CD7A LOCAL
    {
        ; Denotes how much Link will move during the frame in a vertical direction (signed)
        LDA $30 : BEQ BRANCH_ALPHA
        
        ; this is reached if there is vertical movement
        LDA $31 : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        ; This is executed if there is no horizontal movement (vertical doesn't matter)
        
        BRL BRANCH_THETA
    
    BRANCH_BETA:
    
        ; Basically this code executes only if Link is moving diagonally
        
        ; $02DE[2] = mirror of Link's Y coordinate
        LDA $20 : STA $02DE
        LDA $21 : STA $02DF
        
        ; $02DC[2] = mirror of Link's X coordinate
        LDA $22 : STA $02DC
        LDA $23 : STA $02DD
        
        LDY.b #$04
        
        LDA $31 : BMI BRANCH_GAMMA ; Is Link moving to the left? If so, branch
        
        ; This probably sets up a different hit detection box b/c he's looking in a different direction
        LDY.b #$06
    
    BRANCH_GAMMA:
    
        JSR $CE2A ; $3CE2A IN ROM
        
        LDA $0C : AND.b #$05 : BEQ BRANCH_DELTA
        
        JSR $E112 ; $3E112 IN ROM
        
        LDA $6B : AND.b #$0F : BNE BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        BRL BRANCH_THETA
    
    BRANCH_EPSILON:
    
        REP #$20
        
        LDA $22 : SUB $02DC : STA $00
        
        LDA $02DC : STA $22
        
        SEP #$20
        
        LDA $00 : STA $31
        
        LDY.b #$00
        
        LDA $30 : BMI BRANCH_ZETA
        
        LDY.b #$02
    
    BRANCH_ZETA:
    
        JSR $CDCB ; $3CDCB IN ROM
        
        LDA $0C : AND.b #$05 : BEQ BRANCH_THETA
        
        JSR $E076 ; $3E076 IN ROM
        
        LDA $6B : AND.b #$0F : BEQ BRANCH_THETA
        
        ; Store the diagonal movement characteristics to $6D (but why?)
        LDA $6B : STA $6D
        
        REP #$20
        
        LDA $20 : SUB $02DE : STA $00
        
        SEP #$20
        
        LDA $00 : STA $30
        
        LDY $31 : BMI BRANCH_IOTA
        
        LDA $CC83, Y
        
        BRA BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        TYA : EOR.b #$FF : INC A : TAY
        
        LDA $CC8D, Y ; $3CC8D, Y THAT IS
    
    BRANCH_KAPPA:
    
        REP #$20
        
        AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_LAMBDA
        
        ORA.w #$FF00
    
    BRANCH_LAMBDA:
    
        ADD $22 : STA $22
        
        SEP #$20
        
        LDY $30 : BMI BRANCH_MU
        
        LDA $CC97, Y
        
        BRA BRANCH_NU
    
    BRANCH_MU:
    
        TYA : EOR.b #$FF : INC A : TAY
        
        LDA $CCA1, Y
    
    BRANCH_NU:
    
        REP #$20
        
        AND.w #$00FF : CMP.w #$0080 : BCC BRANCH_XI
        
        ORA.w #$FF00
    
    BRANCH_XI:
    
        ADD $20 : STA $20
        
        SEP #$20
        
        BRA BRANCH_OMICRON
    
    BRANCH_THETA:
    
        STZ $6D
    
    BRANCH_OMICRON:
    
        STZ $6B
        
        RTS
    }

    ; *$3CDCB-$3CE29 LOCAL
    {
        ; This probably the up/down movement handler analagous to $3CE2A below
        REP #$20
        
        JSR TileDetect_ResetState
        
        STZ $59
        
        LDA $20 : ADD $CB7B, Y : STA $51 : AND $EC : STA $00
        LDA $22 : ADD $CD89, Y : AND $EC : LSR #3  : STA $02
        LDA $22 : ADD $CD8B, Y : AND $EC : LSR #3  : STA $04
        LDA $22 : ADD $CD93, Y : AND $EC : LSR #3  : STA $74
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $02
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $74 : STA $02
        
        LDA.w #$0004 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

    ; *$3CE2A-$3CE84 LOCAL
    {
        ; Note, this routine only execute when Link is moving horizontally
        ; (Yes, it will execute if he's moving in a diagonal direction since that includes horizontal)
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        STZ $59
        
        LDA $22 : ADD $CD7B, Y : AND $EC : LSR #3 : STA $02
        
        LDA $20 : ADD $CD83, Y : AND $EC : STA $00
        
        LDA $20 : ADD $CD8B, Y : STA $51 : AND $EC : STA $04
        
        LDA $20 : ADD $CD93, Y : STA $53 : AND $EC : STA $08
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $00
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $08 : STA $00
        
        LDA.w #$0004 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

    ; *$3CE85-$3CEC8 LOCAL
    {
        REP #$20
        
        JSR TileDetect_ResetState
        
        STZ $59
        
        LDA $20 : ADD $CDA3, Y : AND $EC : STA $00
        
        LDA $22 : ADD $CDAB, Y : AND $EC : LSR #3 : STA $02
        LDA $22 : ADD $CDB3, Y : AND $EC : LSR #3 : STA $04
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $02
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

    ; *$3CEC9-$3CF09 LOCAL
    {
        REP #$20
        
        JSR TileDetect_ResetState
        
        STZ $59
        
        LDA $22 : ADD $CDA3, Y : AND $EC : LSR #3 : STA $02
        
        LDA $20 : ADD $CDAB, Y : AND $EC : STA $00
        
        LDA $20 : ADD $CDB3, Y : AND $EC : STA $04
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $00
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$3CF0A-$3CF11 LONG
    Player_TileDetectNearbyLong:
    {
        PHB : PHK : PLB
        
        JSR Player_TileDetectNearby
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3CF12-$3CF7D LOCAL
    Player_TileDetectNearby:
    {
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        LDA $22 : ADD $CD83 : AND $EC : LSR #3 : STA $02
        
        LDA $22 : ADD $CD93 : AND $EC : LSR #3 : STA $04
        
        LDA $20 : ADD $CD87 : AND $EC : STA $00 : STA $74
        
        LDA $20 : ADD $CD97 : AND $EC : STA $08
    
    ; *$3CF49 ALTERNATE ENTRY POINT
    
        REP #$10
        
        LDA.w #$0008 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $08 : STA $00
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $74 : STA $00
        
        LDA $04 : STA $02
        
        LDA.w #$0004 : STA $02
        
        JSR TileDetect_Execute
        
        LDA $08 : STA $00
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$3CF7E-$3CFCB LOCAL
    {
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        LDA $22 : ADD.w #$0000 : AND $EC : LSR #3 : STA $02
        LDA $22 : ADD.w #$0008 : AND $EC : LSR #3 : STA $04
        
        LDA $24 : AND.w #$00FF : CMP.w #$00FF : BNE BRANCH_ALPHA
        
        LDA.w #$0000
    
    BRANCH_ALPHA:
    
        ADD $20 : AND $EC : STA $00
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $02
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

    ; *$3D077-$3D2C5 LOCAL
    {
        ; Takes Y as an input ranging from 0x00 to 0x08
        ; The different behaviors with each has not been figured out yet
        
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        STY $00 : CPY.b #$08 : BNE .alpha
        
        ; Checking to see if a spin attack is still executing.
        LDA $031C : AND.w #$00FF : DEC #2 : BMI .stillSpinAttacking
        
        CMP.w #$0008 : BCS .stillSpinAttacking
        
        PHY
        
        TAY
        
        LDA $D06F, Y : AND.w #$00FF : ADD.w #$0040 : TAY
        
        BRA .delta
    
    .alpha
    
        PHY
        
        ; Use the direction link is facing and the action in question to form an index
        LDA $00 : AND.w #$00FF : ASL #3 : ADD $2F : TAY
    
    .delta
    
        ; Find some coordinates relative to Link, but depending on
        LDA $22 : ADD $D01C, Y : AND $EC : LSR #3 : STA $02
        
        LDA $20 : ADD $CFCC, Y : AND $EC : STA $00
        
        LDA.w #$0001 : STA $0A
        
        PLY
        
        REP #$10
        
        ; 0 - nothing, just standing there, 1 - sword, others - ????
        TYA
        
        CMP.w #$0001 : BEQ BRANCH_EPSILON
        CMP.w #$0002 : BEQ BRANCH_EPSILON
        CMP.w #$0003 : BEQ BRANCH_EPSILON
        CMP.w #$0006 : BEQ BRANCH_EPSILON
        CMP.w #$0007 : BEQ BRANCH_EPSILON
        CMP.w #$0008 : BEQ BRANCH_EPSILON
        
        ; action types 0x00, 0x05, and 0x04 end up here
        PHY
        
        JSR TileDetect_Execute
        
        PLY
        
        BRA BRANCH_MU
    
    BRANCH_EPSILON:
    
        SEP #$30
        
        JSR $DC4A ; $3DC4A IN ROM
    
    .stillSpinAttacking
    
        SEP #$30
    
    BRANCH_XI:
    
        BRL .return
    
    BRANCH_MU:
    
        SEP #$30
        
        CPY.b #$05 : BEQ BRANCH_XI
        
        LDA $0357 : AND.b #$10 : BEQ BRANCH_OMICRON
        
        LDA $20 : ADD.b #$08 : AND.b #$0F
        
        CMP.b #$04 : BCC BRANCH_PI
        CMP.b #$0B : BCC BRANCH_RHO
    
    BRANCH_PI:
    
        LDA $22 : AND.b #$0F
        
        CMP.b #$04 : BCC BRANCH_SIGMA
        CMP.b #$0C : BCC BRANCH_RHO
    
    BRANCH_SIGMA:
    
        LDA $031F : BNE BRANCH_RHO
        
        LDA $4D : BNE BRANCH_RHO
        
        LDA $1B : BEQ BRANCH_CHI
        
        JSL Dungeon_SaveRoomQuadrantData
        
        LDA.b #$33 : JSR Player_DoSfx2
        
        STZ $5E
        
        LDA.b #$15 : STA $11
        
        LDA $A0 : STA $A2
        
        LDA $7EC000 : STA $A0
        
        JSR $94F1 ; $394F1 IN ROM
        
        BRA BRANCH_RHO
    
    BRANCH_CHI:
    
        LDA $02DB : BNE BRANCH_RHO
        
        JSR $A95C ; $3A95C IN ROM
    
    BRANCH_RHO:
    
        BRL BRANCH_GAMMA
    
    BRANCH_OMICRON:
    
        STZ $02DB
        
        LDA $0357 : AND.b #$01 : BEQ BRANCH_ZETA
        
        LDA.b #$02 : STA $0351
        
        JSR $D2C6 ; $3D2C6 IN ROM
        
        BCS BRANCH_THETA
        
        LDA $4D : BNE BRANCH_THETA
        
        LDA.b #$1A : JSR Player_DoSfx2
    
    BRANCH_THETA:
    
        BRL BRANCH_KAPPA
    
    BRANCH_ZETA:
    
        LDA $0359 : AND.b #$01 : BEQ BRANCH_LAMBDA
        
        LDA.b #$01 : STA $0351
        
        LDA $1B : BNE BRANCH_IOTA
        
        LDA $0345 : BEQ BRANCH_IOTA
        
        LDA $02E0 : BNE BRANCH_IOTA
        
        LDA $7EF356 : BEQ BRANCH_THETA
        
        STZ $0345
        
        LDA $0340 : STA $26
        
        LDA.b #$00 : STA $5D
        
        BRL BRANCH_KAPPA
    
    BRANCH_IOTA:
    
        ; $3D2C6 IN ROM
        JSR $D2C6 : BCS BRANCH_TAU
        
        LDA $8A : CMP.b #$70 : BNE .notEvilSwamp
    
    BRANCH_LAMBDA:
    
        LDA.b #$1B : JSR Player_DoSfx2
        
        BRA BRANCH_TAU
    
    .notEvilSwamp
    
        LDA $4D : BNE BRANCH_TAU
        
        LDA.b #$1C : JSR Player_DoSfx2
    
    BRANCH_TAU:
    
        BRL BRANCH_KAPPA
        
        LDA $1B : BNE BRANCH_ALEPH
        
        LDA $0345 : BNE BRANCH_ALEPH
        
        LDA $0341 : AND.b #$01 : BEQ BRANCH_ALEPH
        
        LDA.b #$01 : STA $0351
        
        ; $3D2C6 IN ROM
        JSR $D2C6 : BCS BRANCH_BET
        
        ; Dat be sum swamp o' evil
        LDA $8A : CMP.b #$70 : BNE BRANCH_DALET
        
        LDA.b #$1B : JSR Player_DoSfx2
        
        BRA BRANCH_BET
    
    BRANCH_DALET:
    
        LDA $4D : BNE BRANCH_BET
        
        LDA.b #$1C : JSR Player_DoSfx2
    
    BRANCH_BET:
    
        BRL .return
    
    BRANCH_ALEPH:
    
        STZ $0351
        
        LDA $02EE : AND.b #$01
        
        BEQ .chet
        
        ; Only current documentation on this relates to the Desert Palace opening
        LDA.b #$01 : STA $02ED
        
        ; Our work is done here I guess?
        BRL .return
    
    .chet
    
        STZ $02ED
        
        LDA $02EE : AND.b #$10 : BEQ .noSpikeFloorDamage
        
        STZ $0373
        
        LDA $55 : BNE .noSpikeFloorDamage
        
        ; $3AFB5 IN ROM
        JSR $AFB5 : BCS .noSpikeFloorDamage
        
        ; Did Link just get damaged and is still flashing?
        LDA $031F : BNE .noSpikeFloorDamage
        
        STZ $03F7
        STZ $03F5
        STZ $03F6
        
        ; moon pearl
        LDA $7EF357 : BEQ .doesntHaveMoonPearl
        
        STZ $56
        STZ $02E0
    
    .doesntHaveMoonPearl
    
        ; armor level
        LDA $7EF35B : TAY
        
        ; Determine how much damage the spike floor will do to Link.
        LDA $D06C, Y : STA $0373
        
        BRL Player_HaltDashAttack
    
    .noSpikeFloorDamage
    
        LDA $0348 : AND.b #$11 : BEQ .notWalkingOnIce
        
        LDA $034A : BEQ BRANCH_AYIN
        
        LDA $6A : BEQ BRANCH_PEY
        
        LDA $0340 : STA $26
        
        BRL BRANCH_PEY
    
    BRANCH_AYIN:
    
        LDA $67 : AND.b #$0C : BEQ BRANCH_TSADIE
        
        LDA.b #$01 : STA $033D
        LDA.b #$80 : STA $033C
    
    BRANCH_TSADIE:
    
        LDA $67 : AND.b #$03 : BEQ BRANCH_QOF
        
        LDA.b #$01 : STA $033D
        LDA.b #$80 : STA $033C
    
    BRANCH_QOF:
    
        LDY.b #$01
        
        LDA $0348 : AND.b #$01 : BNE BRANCH_RESH
        
        LDY.b #$02
    
    BRANCH_RESH:
    
        STY $034A
        
        LDA $26 : STA $0340
        
        JSL Player_ResetSwimState
        
        BRL BRANCH_PEY
    
    .notWalkingOnIce
    
        LDA $5D : CMP.b #$04 : BEQ BRANCH_SIN
        
        LDA $034A : BEQ BRANCH_TAV
        
        LDA $0340 : STA $26
    
    BRANCH_TAV:
    
        JSL Player_ResetSwimState
    
    BRANCH_SIN:
    
        STZ $034A
    
    BRANCH_PEY:
    
        LDA $02E8 : AND.b #$10 : BEQ BRANCH_KAPPA
        
        LDA $031F : BNE BRANCH_KAPPA
        
        LDA.b #$3A : STA $031F
    
    BRANCH_KAPPA:
    .return
    
        RTS
    }

    ; *$3D2C6-$3D2E3 LOCAL
    {
        LDA $67 : AND.b #$0F : BEQ BRANCH_ALPHA
        
        LDA $5D : CMP.b #$11 : BEQ BRANCH_BETA
        
        LDA $1A : AND.b #$0F : BEQ BRANCH_GAMMA
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        LDA $1A : AND.b #$07 : BNE BRANCH_ALPHA
    
    BRANCH_GAMMA:
    
        CLC
        
        RTS
    
    BRANCH_ALPHA:
    
        SEC
        
        RTS
    }

    ; *$3D304-$3D364 LOCAL
    {
        REP #$20
        
        TYA : ASL #3 : STA $0A
        
        LDA $66 : ASL A : ADD $0A : TAY
        
        LDA $00 : STA $08
        LDA $02 : STA $04
        
        LDA $08 : ADD $D2F4, Y : AND $EC : LSR #3 : STA $02
        
        LDA $04 : ADD $D2E4, Y : AND $EC : STA $00
        
        ; $3E026 IN ROM
        JSR $E026 : BEQ BRANCH_ALPHA
        
        CPX.w #$0009 : BNE BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDA $08 : ADD $D2FC, Y : AND $EC : LSR #3 : STA $02
        
        LDA $04 : ADD $D2EC, Y : AND $EC : STA $00
        
        ; $3E026 IN ROM
        JSR $E026 : BEQ BRANCH_GAMMA
        
        CPX.w #$0009 : BNE BRANCH_BETA
    
    BRANCH_GAMMA:
    
        SEP #$30
        
        CLC
        
        RTS
    
    BRANCH_BETA:
    
        SEP #$30
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; *$3D383-$3D444 LOCAL
    {
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        ; Tell me what direction Link is facing and utilize it as an index.
        LDA $2F : TAY
        
        ; We're going to form a box based on which to detect a tile type we can interact with.
        LDA $20 : ADD $D365, Y : AND $EC : STA $00
        
        LDA $20 : ADD.w #$0014 : AND $EC : STA $04
        
        LDA $22 : ADD $D36D, Y : AND $EC : LSR #3 : STA $02
        
        LDA $22 : ADD.w #$0008 : AND $EC : LSR #3 : STA $08
        
        ; The basic idea is that we have a RECT structure with corners $00, $04, and 
        ; corners sort of defined by using offsets at $02, $08
        
        LDA.w #$0001 : STA $0A
        
        REP #$10
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $00
        LDA $08 : STA $02
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        ; By default, the assumption is that the action button is going to cause us to dash
        ; (There are other actions that have priority above this elsewhere though)
        LDX.b #$02
        
        LDA $0E : ORA $036D : AND.b #$01 : BEQ .notNearWall
        
        ; The action will be grabbing a wall since we're close to one and hitting the action button
        LDX.b #$03
    
    .notNearWall
    
        ; Are we indoors?
        LDA $1B : BEQ .outdoors
        
        ; We're indoors, save whatever action we anticipate doing.
        PHX
        
        JSL Dungeon_QueryIfTileLiftable : BCC .not_liftable
        
        PLX
        
        AND.b #$0F : TAY
        
        LDA $D37C, Y : STA $0368 : TAY
        
        BRA .check_lift_strength
    
    .not_liftable
    
        ; Remind me of the kind of action I was going to take.
        PLX
        
        ; Is a readable tile in our path?
        LDA $0366 : AND.b #$01 : BEQ .indoorDontRead
        
        ; Is link facing north?
        ; no, so don't read anything.
        LDA $2F : BNE .indoorDontRead
        
        LDA $036A : BNE .indoorDontRead
        
        ; Current action is reading something
        LDX.b #$04
    
    .indoorDontRead
    
        BRA .checkIfOpeningChest
    
    .outdoors
    
        ; Is a readable tile in our path?
        LDA $0366 : AND.b #$01 : BEQ .checkIfOpeningChest
        
        LDA $2F : BNE .checkIfLiftingObject
        
        LDA $036A : BNE .checkIfLiftingObject
        
        ; Current action is reading something
        LDX.b #$04
        
        BRA .checkIfOpeningChest
    
    .checkIfLiftingObject
    
        LDA $036A : LSR A : STA $0368 : TAY
    
    .check_lift_strength
    
        ; Subtract glove strength.
        LDA $D375, Y : SUB $7EF354 : BEQ .strongEnough : BPL .checkIfOpeningChest
    
    .strongEnough
    
        ; Current action is picking something up
        LDX.b #$01
    
    .checkIfOpeningChest
    
        ; Check to see if we're opening a chest.
        LDA $02E5 : AND.b #$01 : BEQ .notOpeningChest
        
        ; Current action is opening a chest
        LDX.b #$05
    
    .notOpeningChest
    
        RTS
    }

; ==============================================================================

    ; *$3D485-$3D555 LOCAL
    {
        LDA $00 : PHA
        
        LDA $66 : AND.b #$02 : BNE BRANCH_ALPHA
        
        LDX.b #$00
        
        LDA $66 : AND.b #$01 : BEQ BRANCH_BETA
        
        LDX.b #$04
    
    BRANCH_BETA:
    
        LDY.b #$00
        
        LDA $0E : AND.b #$04 : BNE BRANCH_GAMMA
        
        LDY.b #$02
    
    BRANCH_GAMMA:
    
        STY $00
        
        BRA BRANCH_DELTA
    
    BRANCH_ALPHA:
    
        LDX.b #$08
        
        LDA $66 : AND.b #$01 : BEQ BRANCH_EPSILON
        
        LDX.b #$0C
    
    BRANCH_EPSILON:
    
        LDY.b #$00
        
        LDA $0E : AND.b #$04 : BNE BRANCH_ZETA
        
        LDY.b #$02
    
    BRANCH_ZETA:
    
        STY $00
    
    BRANCH_DELTA:
    
        TXA : ADD $00 : TAY
        
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        LDA $20 : ADD $D445, Y : AND $EC :          STA $00
        LDA $22 : ADD $D455, Y : AND $EC : LSR #3 : STA $02
        
        LDA $20 : ADD $D465, Y : AND $EC :          STA $04
        LDA $22 : ADD $D475, Y : AND $EC : LSR #3 : STA $08
        
        LDA.w #$0001 : STA $0A
        
        REP #$10
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $00
        LDA $08 : STA $02
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$10
        
        PLA : STA $00
        
        LDA $0E : ORA $036E : AND.b #$03 : BNE BRANCH_THETA
        
        LDA $036D : ORA $0370 : AND.b #$33 : BEQ BRANCH_IOTA
    
    BRANCH_THETA:
    
        LDY.b #$00
        
        LDA $00 : EOR.b #$FF : INC A : STA $00 : CMP.b #$80 : BCC BRANCH_KAPPA
        
        LDY.b #$FF
    
    BRANCH_KAPPA:
    
        STY $01
        
        LDA $66 : AND.b #$02 : BEQ BRANCH_LAMBDA
        
        REP #$20
        
        LDA $00 : ADD $20 : STA $20
        
        BRA BRANCH_IOTA
    
    BRANCH_LAMBDA:
    
        REP #$20
        
        LDA $00 : ADD $22 : STA $22
    
    BRANCH_IOTA:
    
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; $3D556-$3D575 DATA
    {
    
    .xy_offsets_first
        dw 0, 0
        dw 7, 7
        dw 0, 15
        dw 0, 15
    
    .xy_offsets_second
        dw 0, 15
        dw 0, 15
        dw 0, 0
        dw 8, 8        
    }

; ==============================================================================

    ; *$3D576-$3D606 LONG
    Hookshot_CheckTileCollison:
    {
        PHB : PHK : PLB
        
        LDA $A0 : PHA
        LDA $EE : PHA
        
        LDA $03A4, X : BEQ BRANCH_ALPHA
        
        LDA $044A : BNE BRANCH_BETA
        
        LDA $A0 : ADD.b #$10 : STA $A0
    
    BRANCH_BETA:
    
        LDA $EE : EOR.b #$01 : STA $EE
    
    BRANCH_ALPHA:
    
        LDA $0BFA, X : STA $04
        LDA $0C0E, X : STA $05
        
        LDA $0C04, X : STA $08
        LDA $0C18, X : STA $09
        
        LDA $0C72, X : ASL #2 : STA $73
        
        PHX
        
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        SEP #$20
        
        LDA $046C : CMP.b #$02 : BNE .single_bg_collision
        
        LDA $04 : PHA
        LDA $05 : PHA
        
        LDA $08 : PHA
        LDA $09 : PHA
        
        LDA.b #$01 : STA $EE
        
        REP #$20
        
        LDA $E6 : SUB $E8 : ADD $04 : STA $04
        LDA $E0 : SUB $E2 : ADD $08 : STA $08
        
        SEP #$20
        
        JSR Hookshot_CheckSingleLayerTileCollision
        
        PLA : STA $09
        PLA : STA $08
        PLA : STA $05
        PLA : STA $04
        
        STZ $EE
    
    .single_bg_collision
    
        JSR Hookshot_CheckSingleLayerTileCollision
        
        PLX
        
        PLA : STA $EE
        PLA : STA $A0
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3D607-$3D656 LOCAL
    Hookshot_CheckSingleLayerTileCollision:
    {
        REP #$20
        
        LDA $73 : TAY
        
        LDA $04 : ADD .xy_offsets_first+0, Y : AND $EC : STA $00
        LDA $04 : ADD .xy_offsets_first+2, Y : AND $EC : STA $04
        
        LDA $08 : .xy_offsets_second+0, Y : AND $EC : LSR #3 : STA $02
        LDA $08 : .xy_offsets_second+2, Y : AND $EC : LSR #3 : STA $08
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        ; Use the other x, y coordinate pair.
        LDA $04 : STA $00
        LDA $08 : STA $02
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $3D657-$3D666 DATA
    {
    
    }

; ==============================================================================

    ;*$3D667-$3D6F3 LONG BRANCH LOCATION
    {
        LDA $00 : PHA
        
        LDA $66 : AND.b #$02 : BEQ BRANCH_ALPHA
        
        LDY.b #$02
        
        LDA $20 : CMP.b #$80 : BCC BRANCH_BETA
        
        LDY.b #$00
        
        BRA BRANCH_BETA
    
    BRANCH_ALPHA:
    
        LDY.b #$06
        
        LDA $22 : CMP.b #$80 : BCC BRANCH_BETA
        
        LDY.b #$04
    
    BRANCH_BETA:
    
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        LDA $20 : ADD $D657, Y : AND $EC : STA $00
        
        LDA $22 : ADD $D65F, Y : AND $EC : LSR #3 : STA $02
        
        LDA.w #$0001 : STA $0A
        
        REP #$10
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        PLA : STA $00
        
        LDA $0E : ORA $036E : AND.b #$03 : BNE BRANCH_GAMMA
        
        LDA $036D : ORA $0370 : AND.b #$33 : BEQ BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDY.b #$00
        
        LDA $00 : EOR.b #$FF : INC A : STA $00 : CMP.b #$80 : BCC BRANCH_EPSILON
        
        LDY.b #$FF
    
    BRANCH_EPSILON:
    
        STY $01
        
        LDA $66 : AND.b #$02 : BEQ BRANCH_ZETA
        
        REP #$20
        
        LDA $00 : ADD $20 : STA $20
        
        BRA BRANCH_DELTA
    
    BRANCH_ZETA:
    
        REP #$20
        
        LDA $00 : ADD $22 : STA $22
    
    BRANCH_DELTA:
    
        SEP #$20
        
        RTS
    }

    ; *$3D6F4-$3D72D JUMP LOCAL
    {
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        LDA $22 : ADD.w #$0002 : AND $EC : LSR #3 : STA $02
        LDA $22 : ADD.w #$000D : AND $EC : LSR #3 : STA $04
        
        LDA $20 : ADD.w #$000A : AND $EC : STA $00 : STA $74
        LDA $20 : ADD.w #$0015 : AND $EC : STA $08
        
        BRL BRANCH_$3CF49
    }

    ; *$3D73E-$3D797 LOCAL
    {
        STZ $59
        
        REP #$20
        
        JSR TileDetect_ResetState
        
        TXA : AND.w #$00FF : DEC A : ASL #2 : TAY
        
        LDA $22 : ADD $D736, Y : AND $EC : LSR #3 : STA $02
        LDA $22 : ADD $D738, Y : AND $EC : LSR #3 : STA $04
        
        LDA $20 : ADD $D72E, Y : AND $EC : STA $00
        LDA $20 : ADD $D730, Y : AND $EC : STA $08
        
        REP #$10
        
        LDA.w #$0001 : STA $0A
        
        JSR TileDetect_Execute
        
        LDA $04 : STA $02
        LDA $08 : STA $00
        
        LDA.w #$0002 : STA $0A
        
        JSR TileDetect_Execute
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$3D798-$3D7D7 LOCAL
    TileDetect_ResetState:
    {
        STZ $0C
        STZ $0E
        STZ $38
        STZ $58
        
        STZ $02C0
        
        STZ $5F
        STZ $62
        
        STZ $0320
        STZ $0341
        STZ $0343
        STZ $0348
        STZ $034C
        STZ $0357
        STZ $0359
        STZ $035B
        STZ $0366
        STZ $036D
        STZ $036F
        STZ $03E5
        STZ $03E7
        STZ $02EE
        STZ $02F6
        STZ $03F1
        
        RTS
    }

; ==============================================================================

    ; $3D7D8-$3D9D7 JUMP TABLE
    {
        ; Dungeon tile attribute handlers
        
        ; Parameter: The tile type Link is interacting with. Stored at $06
        
        dw $DC54 ; = $3DC54* ; 0x00 - Do nothing. Normal tile.
        dw $DC50 ; = $3DC50* ; 0x01 - Tests and sets bits from $0A into $0E
        dw $DC50 ; = $3DC50* ; 0x02 - Tests and sets bits from $0A into $0E
        dw $DC50 ; = $3DC50* ; 0x03 - Tests and sets bits from $0A into $0E
        dw $DC50 ; = $3DC50* ; 0x04 - Tests and sets bits from $0A into $0E
        dw $DC54 ; = $3DC54* ; 0x05 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x06 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x07 - Do nothing. Normal tile.
        
        dw $DC86 ; = $3DC86* ; 0x08 - Tests and sets bits from $0A into $58
        dw $DD1B ; = $3DD1B* ; 0x09 - Shallow water
        dw $DCBC ; = $3DCBC* ; 0x0A - Tests and sets bits from $0A into $0343
        dw $DC50 ; = $3DC50* ; 0x0B - Tests and sets bits from $0A into $0E
        dw $DC98 ; = $3DC98* ; 0x0C - Tests and sets bits from $0A into $0320
        dw $DDCA ; = $3DDCA* ; 0x0D - Tests and sets bits from $0A into $02EE (Spike floor)
        dw $DC9E ; = $3DC9E* ; 0x0E - Tests and sets bits from $0A into $0348
        dw $DCA4 ; = $3DCA4* ; 0x0F - Tests and sets bits from $0A into $0348
        
        dw $DC61 ; = $3DC61* ; 0x10 - Tests and sets bits from $0A into $0C
        dw $DC61 ; = $3DC61* ; 0x11 - Tests and sets bits from $0A into $0C
        dw $DC61 ; = $3DC61* ; 0x12 - Tests and sets bits from $0A into $0C
        dw $DC61 ; = $3DC61* ; 0x13 - Tests and sets bits from $0A into $0C
        dw $DC54 ; = $3DC54* ; 0x14 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x15 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x16 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x17 - Do nothing. Normal tile.
        
        dw $DC5D ; = $3DC5D* ; 0x18 - these are the slanted wall tiles that make you move diagonally when you move against them
        dw $DC5D ; = $3DC5D* ; 0x19 - also a slanted wall
        dw $DC5D ; = $3DC5D* ; 0x1A - also a slanted wall
        dw $DC5D ; = $3DC5D* ; 0x1B - also a slanted wall
        dw $DCC2 ; = $3DCC2* ; 0x1C - Top of water staircase
        dw $DC72 ; = $3DC72* ; 0x1D - these three are related
        dw $DC7D ; = $3DC7D* ; 0x1E - staircases (ladders really)
        dw $DC7D ; = $3DC7D* ; 0x1F - 
        
        dw $DC8B ; = $3DC8B* ; 0x20 - Hole
        dw $DC54 ; = $3DC54* ; 0x21 - Do nothing. Normal tile.
        dw $DC86 ; = $3DC86* ; 0x22 - Steps that slow Link down
        dw $DC54 ; = $3DC54* ; 0x23 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x24 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x25 - Do nothing. Normal tile.
        dw $DC50 ; = $3DC50* ; 0x26 - 
        dw $DDE1 ; = $3DDE1* ; 0x27 - Empty chest
        
        dw $DEBB ; = $3DEBB* ; 0x28 - Ledge leading up
        dw $DEAD ; = $3DEAD* ; 0x29 - Ledge leading down
        dw $DEC5 ; = $3DEC5* ; 0x2A - Ledge leading left
        dw $DEC5 ; = $3DEC5* ; 0x2B - Ledge leading right
        dw $DECF ; = $3DECF* ; 0x2C - Ledge leading up + left
        dw $DEDD ; = $3DEDD* ; 0x2D - Ledge leading down + left
        dw $DECF ; = $3DECF* ; 0x2E - Ledge leading up + right
        dw $DEDD ; = $3DEDD* ; 0x2F - Ledge leading down + right
        
        dw $DC86 ; = $3DC86* ; 0x30 - Up Staircase 0
        dw $DC86 ; = $3DC86* ; 0x31 - Up Staircase 1
        dw $DC86 ; = $3DC86* ; 0x32 - Up Staircase 2
        dw $DC86 ; = $3DC86* ; 0x33 - Up Staircase 3
        dw $DC86 ; = $3DC86* ; 0x34 - Down Staircase 0
        dw $DC86 ; = $3DC86* ; 0x35 - Down Staircase 1
        dw $DC86 ; = $3DC86* ; 0x36 - Down Staircase 2
        dw $DC86 ; = $3DC86* ; 0x37 - Down Staircase 3
        
        dw $DC54 ; = $3DC54* ; 0x38 - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile. (Straight up south staircase)
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile. (Star tile behavior handled elsewhere)
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile. (Star tile behavior handled elsewhere)
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile. (Unknown if this has other behavior)
        dw $DD9D ; = $3DD9D* ; 0x3d - (inter floor staircase?)
        dw $DDA1 ; = $3DDA1* ; 0x3e - (inter floor staircase?)
        dw $DDA1 ; = $3DDA1* ; 0x3f - (inter floor staircase?)
        
        dw $DE61 ; = $3DE61* ; 0x40 - Grass tile
        dw $DC54 ; = $3DC54* ; 0x41 - 
        dw $DC54 ; = $3DC54* ; 0x42 - 
        dw $DC50 ; = $3DC50* ; 0x43 - 
        dw $DDB1 ; = $3DDB1* ; 0x44 - spike block tile
        dw $DC54 ; = $3DC54* ; 0x45 - Do nothing. Normal tile.
        dw $DF11 ; = $3DF11* ; 0x46 - ????
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile.
        
        dw $DE67 ; = $3DE67* 0x48 - Aftermath tiles?
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DE67 ; = $3DE67* 0x4A - Same as 0x48 but this tile type doesn't seem to be used in the game anywhere
        dw $DEFF ; = $3DEFF* ; Warp Tile
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        
        dw $DE7E ; = $3DE7E* 0x50:
        dw $DE7E ; = $3DE7E*
        dw $DE7E ; = $3DE7E*
        dw $DE7E ; = $3DE7E*
        dw $DE7E ; = $3DE7E*
        dw $DE7E ; = $3DE7E*
        dw $DE7E ; = $3DE7E*
        dw $DF19 ; = $3DF19*
        
        dw $DD6A ; = $3DD6A* ; 0x58: chest attribute 0
        dw $DD6A ; = $3DD6A* ; 0x59: chest attribute 1
        dw $DD6A ; = $3DD6A* ; 0x5A: chest attribute 2
        dw $DD6A ; = $3DD6A* ; 0x5B: chest attribute 3
        dw $DD6A ; = $3DD6A* ; 0x5C: chest attribute 4
        dw $DD6A ; = $3DD6A* ; 0x5D: chest attribute 5
        dw $DC54 ; = $3DC54* ; 0x5E: Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0x5F: Do nothing. Normal tile.
        
        dw $DDF7 ; = $3DDF7* ; 0x60 - Blue rupees on ground tile
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; Do nothing. Normal tile.
        dw $DE45 ; = $3DE45* ; minigame chest
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DE17 ; = $3DE17*
        
        dw $DE29 ; 0x68: = $3DE29*
        dw $DE2D ; = $3DE2D*
        dw $DE35 ; = $3DE35*
        dw $DE3A ; = $3DE3A*
        dw $DC50 ; = $3DC50*
        dw $DC50 ; = $3DC50*
        dw $DC50 ; = $3DC50*
        dw $DC50 ; = $3DC50*
        
        dw $DD41 ; = $3DD41* 0x70:; pot attribute 0
        dw $DD41 ; = $3DD41* ; pot attribute 1
        dw $DD41 ; = $3DD41* ; pot attribute 2
        dw $DD41 ; = $3DD41* ; pot attribute 3
        dw $DD41 ; = $3DD41* ; pot attribute 4
        dw $DD41 ; = $3DD41* ; pot attribute 5
        dw $DD41 ; = $3DD41* ; pot attribute 6
        dw $DD41 ; = $3DD41* ; pot attribute 7
        
        dw $DD41 ; = $3DD41* ; 0x78 - pot attribute 8
        dw $DD41 ; = $3DD41* ; pot attribute 9
        dw $DD41 ; = $3DD41* ; pot attribute A
        dw $DD41 ; = $3DD41* ; pot attribute B
        dw $DD41 ; = $3DD41* ; pot attribute C
        dw $DD41 ; = $3DD41* ; pot attribute D
        dw $DD41 ; = $3DD41* ; pot attribute E
        dw $DD41 ; = $3DD41* ; pot attribute F
        
        dw $DD0A ; = $3DD0A*0x80:
        dw $DD0A ; = $3DD0A*
        dw $DCEA ; = $3DCEA*
        dw $DCEA ; = $3DCEA*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        
        dw $DD0A ; = $3DD0A* 0x88:
        dw $DD0A ; = $3DD0A* ; 0x89 - room link door
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DE4F ; = $3DE4F* ; 0x8E - overworld link door
        dw $DE4F ; = $3DE4F*
        
        dw $DCC8 ; = $3DCC8* ; 0x90:
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        
        dw $DCD4 ; = $3DCD4* ; 0x98:
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        
        dw $DD00 ; = $3DD00* 0xA0:; Used in the sewer / HC transition
        dw $DD00 ; = $3DD00*
        dw $DCE0 ; = $3DCE0*
        dw $DCE0 ; = $3DCE0*
        dw $DD00 ; = $3DD00*
        dw $DD00 ; = $3DD00*
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        
        dw $DCD4 ; = $3DCD4* 0xA8:Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        dw $DCD4 ; = $3DCD4* Do nothing. Normal tile.
        
        dw $DC8B ; = $3DC8B* ; 0xB0 - Hole tile (same as 0x20 but not sure of other differences :( )
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        
        dw $DC8B ; = $3DC8B* ; 0xB8 - hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC8B ; = $3DC8B* ; hole AI ''
        dw $DC54 ; = $3DC54* ; 0xBE - Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* ; 0xBF - Do nothing. Normal tile.
        
        dw $DCAE ; = $3DCAE* ; 0xC0 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC1 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC2 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC3 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC4 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC5 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC6 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC7 - Torch
        
        dw $DCAE ; = $3DCAE* ; 0xC8 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC9 - Torch
        dw $DCAE ; = $3DCAE* ; 0xCA - Torch
        dw $DCAE ; = $3DCAE* ; 0xCB - Torch
        dw $DCAE ; = $3DCAE* ; 0xCC - Torch
        dw $DCAE ; = $3DCAE* ; 0xCD - Torch
        dw $DCAE ; = $3DCAE* ; 0xCE - Torch
        dw $DCAE ; = $3DCAE* ; 0xCF - Torch
        
        dw $DC54 ; = $3DC54* 0xD0:Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        
        dw $DC54 ; = $3DC54* 0xD8:Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        
        dw $DC54 ; = $3DC54* 0xE0:Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        
        dw $DC54 ; = $3DC54* 0xE8: Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        dw $DC54 ; = $3DC54* Do nothing. Normal tile.
        
        dw $DDEB ; = $3DDEB* 0xF0 - Key Door 1
        dw $DDEB ; = $3DDEB* 0xF1 - Key Door 2
        dw $DDEB ; = $3DDEB* 0xF2 - ....
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        
        dw $DDEB ; = $3DDEB* 0xF8:
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
    }

; ==============================================================================

    ; *$3D9D8-$3DA29 LOCAL
    TileDetect_Execute:
    {
        ; Tile attribute handler
        
        ; Has $0A as a hidden argument.
        
        SEP #$30
        
        ; Are we indoors?
        LDA $1B : BNE .indoors
        
        ; Jump to routine that handles outdoor tile behaviors
        BRL BRANCH_$3DC2A
    
    .indoors
    
        ; Handle dungeon tile attributes
        ; some quick notes:
        ; $06[1] is the tile type (no, not the tile type multiplied by two)
        ; $0A[2] seems to be either 1, 2, 4, or 8. This is basically the tile's position relative to Link
        
        REP #$20
        
        ; It's Link's movement impetus (it makes him move in a given direction each frame)
        LDA $49 : AND.w #$00FF : STA $49
        
        LDA $00 : AND.w #$FFF8 : ASL #3 : STA $06
        
        LDA $02 : AND.w #$003F : ADD $06
        
        ; Which part of a two level room is Link on
        LDX $EE : BEQ .lowerFloor
        
        ; He's on the upper floor then.
        ; Add this offset in b/c BG0's tile attributes start at $7F3000
        ADD.w #$1000
    
    .lowerFloor
    
        REP #$10
        
        TAX
        
        ; Are we figuring out what sort of tile this is
        LDA $7F2000, X : PHA
        
        LDA $037F : AND.w #$00FF
        
        BEQ .playinByTheRules
        
        ; $037F being nonzero is a sort of a hidden cheat code
        PLA
        
        LDA.w #$0000
        
        BRA .walkThroughWallsCode
    
    .playinByTheRules
    
        ; Okay back to what kind of tile it was...
        PLA
    
    .walkThroughWallsCode
    
        ; Store the tile type at $06 and mirror it at $0114
        AND.w #$00FF : STA $06 : STA $0114
        
        ; Save the offset for the tile (i.e. its position in $7F2000)
        STX $BD
        
        ; Multiply this tile index by two and use it to run a service routine for that kind of tile.
        ASL A : TAX
        
        JMP ($D7D8, X) ; ($3D7D8, X) THAT IS
    }

; ==============================================================================

    ; $3DA2A-$3DC29 JUMP TABLE
    {
        ; Overworld Tile Attribute Jump Table
        
        dw $DE5B ; = $3DE5B* ; 0x00 - Normal tile (no interaction)
        dw $DC50 ; = $3DC50* ; 0x01 - Blocked
        dw $DC50 ; = $3DC50* ; 0x02 - Blocked
        dw $DC50 ; = $3DC50* ; 0x03 - Blocked
        dw $DC61 ; = $3DC61* ; 0x04 - ????
        dw $DE5B ; = $3DE5B* ; Normal tile (no interaction)
        dw $DE5B ; = $3DE5B* ; Normal tile
        dw $DE5B ; = $3DE5B*
        
        dw $DCB6 ; = $3DCB6* ; 0x08 - Deep water
        dw $DD1B ; = $3DD1B* ; 0x09 - Shallow water
        dw $DCBC ; = $3DCBC* ; 0x0A -
        dw $DD5C ; = $3DD5C* ; 0x0B - ????
        dw $DC98 ; = $3DC98* ; 0x0C - Moving floor (e.g. Mothula's room and the one in the Ice Palace)
        dw $DDCA ; = $3DDCA* ; 0x0D - Spike floors, not sure if any exist in Overworld (Didn't Parallel Worlds do this with Lava?)
        dw $DC9E ; = $3DC9E*
        dw $DCA4 ; = $3DCA4*
        
        dw $DC61 ; = $3DC61*$10:
        dw $DC61 ; = $3DC61*
        dw $DC61 ; = $3DC61*
        dw $DC61 ; = $3DC61*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DC5D ; = $3DC5D*$18:
        dw $DC5D ; = $3DC5D*
        dw $DC5D ; = $3DC5D*
        dw $DC5D ; = $3DC5D*
        dw $DCC2 ; = $3DCC2* ; 0x1C - Top of in room staircase
        dw $DC72 ; = $3DC72*
        dw $DC7D ; = $3DC7D*
        dw $DC7D ; = $3DC7D*
        
        dw $DC8B ; = $3DC8B* ; 0x20 - Hole tile
        dw $DE5B ; = $3DE5B*
        dw $DC86 ; = $3DC86* ; 0x22 - Wooden steps (slow you down)
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DC50 ; = $3DC50*
        dw $DDE1 ; = $3DDE1* ; 0x27 - (empty chest and maybe others)

        dw $DEBB ; = $3DEBB* ; 0x28 - Ledge leading up
        dw $DEAD ; = $3DEAD* ; 0x29 - Ledge leading down
        dw $DEC5 ; = $3DEC5* ; 0x2A - Ledge leading left
        dw $DEC5 ; = $3DEC5* ; 0x2B - Ledge leading right
        dw $DECF ; = $3DECF* ; 0x2C - Ledge leading up + left
        dw $DEDD ; = $3DEDD* ; 0x2D - Ledge leading down + left
        dw $DECF ; = $3DECF* ; 0x2E - Ledge leading up + right
        dw $DEDD ; = $3DEDD* ; 0x2F - Ledge leading down + right
                              
        dw $DC86 ; = $3DC86* ; 0x30 -
        dw $DC86 ; = $3DC86*
        dw $DC86 ; = $3DC86*
        dw $DC86 ; = $3DC86*
        dw $DC86 ; = $3DC86*
        dw $DC86 ; = $3DC86*
        dw $DC86 ; = $3DC86*
        dw $DC86 ; = $3DC86*
        
        dw $DE5B ; = $3DE5B* ; 0x38 - 
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DD9D ; = $3DD9D*
        dw $DDA1 ; = $3DDA1*
        dw $DDA1 ; = $3DDA1*
        
        dw $DE61 ; = $3DE61* ; 0x40:    Grass tile
        dw $DE5B ; = $3DE5B*
        dw $DF09 ; = $3DF09* ; 0x42: ????
        dw $DC50 ; = $3DC50*
        dw $DDB1 ; = $3DDB1* ; 0x44: Cactus tile
        dw $DE5B ; = $3DE5B*
        dw $DF11 ; = $3DF11* ; 0x46: ????
        dw $DE5B ; = $3DE5B*
        
        dw $DE67 ; = $3DE67* ; 0x48 - aftermath tiles of picking things up?
        dw $DE5B ; = $3DE5B*
        dw $DE67 ; = $3DE67* ; Same as 0x48 but this tile type doesn't seem to be used in the game anywhere
        dw $DEFF ; = $3DEFF* ; 0x4B - warp tile
        dw $DEE7 ; = $3DEE7* ; Unused, but would probably be for special mountain tiles too
        dw $DEE7 ; = $3DEE7* ; Unused, but would probably be for special mountain tiles too
        dw $DEF1 ; = $3DEF1* ; Certain mountain tiles
        dw $DEF1 ; = $3DEF1* ; Certain mountain tiles
        
        dw $DE7E ; = $3DE7E* ; 0x50 - bush
        dw $DE7E ; = $3DE7E* ; 0x51 - off color bush
        dw $DE7E ; = $3DE7E* ; 0x52 - small light rock
        dw $DE7E ; = $3DE7E* ; 0x53 - small heavy rock
        dw $DE7E ; = $3DE7E* ; 0x54 - sign
        dw $DE7E ; = $3DE7E* ; 0x55 - large light rock
        dw $DE7E ; = $3DE7E* ; 0x56 - large heavy rock
        dw $DF19 ; = $3DF19*
        
        dw $DD6A ; = $3DD6A* Chest block
        dw $DD6A ; = $3DD6A* Chest block
        dw $DD6A ; = $3DD6A* Chest block
        dw $DD6A ; = $3DD6A* Chest block
        dw $DD6A ; = $3DD6A* Chest block
        dw $DD6A ; = $3DD6A* Chest block
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE45 ; = $3DE45* ; 0x63 - Minigame chest tile
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE17 ; = $3DE17*
        
        dw $DE29 ; = $3DE29*
        dw $DE2D ; = $3DE2D*
        dw $DE35 ; = $3DE35*
        dw $DE3A ; = $3DE3A*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        dw $DD41 ; = $3DD41*
        
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DCEA ; = $3DCEA*
        dw $DCEA ; = $3DCEA*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DD0A ; = $3DD0A*
        dw $DE4F ; = $3DE4F*
        dw $DE4F ; = $3DE4F*

        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        dw $DCC8 ; = $3DCC8*
        
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        
        dw $DD00 ; = $3DD00*
        dw $DD00 ; = $3DD00*
        dw $DCE0 ; = $3DCE0*
        dw $DCE0 ; = $3DCE0*
        dw $DD00 ; = $3DD00*
        dw $DD00 ; = $3DD00*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        dw $DCD4 ; = $3DCD4*
        
        dw $DC8B ; = $3DC8B* ; 0xB0 - hole tile (somaria transit line, more likely though)
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DC8B ; = $3DC8B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DCAE ; = $3DCAE* ; 0xC0 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC1 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC2 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC3 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC4 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC5 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC6 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC7 - Torch
        
        dw $DCAE ; = $3DCAE* ; 0xC8 - Torch
        dw $DCAE ; = $3DCAE* ; 0xC9 - Torch
        dw $DCAE ; = $3DCAE* ; 0xCA - Torch
        dw $DCAE ; = $3DCAE* ; 0xCB - Torch
        dw $DCAE ; = $3DCAE* ; 0xCC - Torch
        dw $DCAE ; = $3DCAE* ; 0xCD - Torch
        dw $DCAE ; = $3DCAE* ; 0xCE - Torch
        dw $DCAE ; = $3DCAE* ; 0xCF - Torch
        
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        dw $DE5B ; = $3DE5B*
        
        dw $DDEB ; = $3DDEB* ; 0xF0 - Key door 1
        dw $DDEB ; = $3DDEB* ; 0xF1 - Key door 2
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
        dw $DDEB ; = $3DDEB*
    }

    ; *$3DC2A LONG BRANCH LOCATION
    {
        JSL Overworld_GetTileAttrAtLocation
    
    .do8x8TileInteraction
    
        REP #$30
        
        PHA
        
        LDA $037F : AND.w #$00FF : BEQ .playinByTheRules
        
        PLA : LDA.w #$0000
        
        BRA .walkThroughWallsCode
    
    .playinByTheRules
    
        PLA
    
    .walkThroughWallsCode
    
        AND.w #$00FF : STA $06 : ASL A : TAX
        
        JMP ($DA2A, X) ; ($3DA2A, X) THAT IS
    
    ; *$3DC4A-$3DC4F ALTERNATE ENTRY POINT
    
        JSL Overworld_Map16_ToolInteraction
        
        BRA .do8x8TileInteraction
    }

    ; *$3DC50-$3DC54 JUMP LOCATION
    {
        ; $0E is the collision bitfield
        LDA $0A : TSB $0E
    
    ; *$3DC54 ALTERNATE ENTRY POINT
    
        RTS
    }

    ; *$3DC5D-$3DC71 JUMP LOCATION
    {
        LDA $0A : TSB $38
    
    ; *$3DC61 ALTERNATE ENTRY POINT
    
        LDA $0A : TSB $0C
        
        LDA $06 : AND.w #$0003 : ASL A : TAY
        
        LDA $DC55, Y : STA $6E
        
        RTS
    }

    ; *$3DC72-$3DC7C JUMP LOCATION
    {
        ; Notice how in actuality this routine is identical to the following one.
        LDA $06 : STA $76
        
        LDA $0A : TSB $02C0
        
        *BRA BRANCH_$3DC86
    }

    ; *$3DC7D-$3DC8A JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : TSB $02C0
    
    ; *$3DC86 ALTERNATE ENTRY POINT / BRANCH LOCATION
    
        LDA $0A : TSB $58
        
        RTS
    }

    ; *$3DC8B-$3DC97 JUMP LOCATION
    {
        ; Hole tile or Somaria platform transit line tile
        
        ; I think this is saying that if Link's on a Somaria platform,
        ; we won't treat it as something he can fall into
        LDA $02F5 : AND.w #$00FF : BNE .cant_fall_into_pits
        
        LDA $04 : TSB $59
    
    .cant_fall_into_pits
    
        RTS
    }

    ; *$3DC98-$3DC9D JUMP LOCATION
    {
        LDA $0A : TSB $0320
        
        RTS
    }

    ; *$3DC9E-$3DCA3 JUMP LOCATION
    {
        LDA $0A : TSB $0348
        
        RTS
    }

    ; *$3DCA4-$3DCAD JUMP LOCATION
    {
        LDA $0A : ASL #4 : TSB $0348
        
        RTS
    }

    ; *$3DCAE-$3DCB5 JUMP LOCATION
    {
        ; Torch tiles
        
        LDA $0A : TSB $0E : TSB $02F6
        
        RTS
    }

    ; *$3DCB6-$3DCBB JUMP LOCATION
    {
        LDA $0A : TSB $0341
        
        RTS
    }

    ; *$3DCBC-$3DCC1 JUMP LOCATION
    {
        LDA $0A : TSB $0343
        
        RTS
    }

    ; *$3DCC2-$3DCC7 JUMP LOCATION
    {
        ; Water staircase tile
        LDA $0A : TSB $034C
        
        RTS
    }

    ; *$3DCC8-$3DCFF JUMP LOCATION
    {
        ; BG change
        LDA $EF : AND.w #$FF00 : ORA.w #$0001 : STA $EF
        
        BRA BRANCH_ALPHA
    
    ; *$3DCD4 ALTERNATE ENTRY POINT
    
        ; BG change and dungeon change (sewer/Hyrule Castle)
        LDA $EF : AND.w #$FF00 : ORA #$0003 : STA $EF
        
        BRA BRANCH_ALPHA
    
    ; *$3DCE0 ALTERNATE ENTRY POINT
    
        ; dungeon change
        LDA $EF : AND.w #$FF00 : ORA.w #$0002 : STA $EF
    
    ; *$3DCEA ALTERNATE ENTRY POINT
    
    BRANCH_ALPHA:
    
        LDA $0A : ASL #4 : TSB $0E
        
        LDA $0A : XBA : TSB $0E
        
        LDA $06 : AND.w #$0001 : ASL A : STA $62
        
        RTS
    }

; *$3DD00-$3DD1A JUMP LOCATION
{
        LDA $EF : AND.w #$FF00 : ORA.w #$0002 : STA $EF
    
    ; *$3DD0A ALTERNATE ENTRY POINT
    
        LDA $0A : ASL #4 : TSB $0E
        
        LDA $06 : AND.w #$0001 : ASL A : STA $62
        
        RTS
    }

    ; *$3DD1B-$3DD20 JUMP LOCATION
    {
        ; Shallow water tile
        LDA $0A : TSB $0359
        
        RTS
    }

; ==============================================================================

    ; $3DD21-$3DD40 DATA
    {
        dw $0001, $0002, $0004, $0008, $0010, $0020, $0040, $0080
        dw $0100, $0200, $0400, $0800, $1000, $2000, $4000, $8000
    }

; ==============================================================================

    ; *$3DD41-$3DD5B JUMP LOCATION
    {
        LDA $0A : AND.w #$0002 : BEQ BRANCH_ALPHA
        
        LDA $06 : AND.w #$000F : ASL A : TAY
        
        LDA $DD21, Y : TSB $5F
    
    BRANCH_ALPHA:
    
        LDA $0A : TSB $0E
        
        JSR $DDE5 ; $3DDE5 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$3DD5C-$3DD69 JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : ASL #4 : TSB $0341
        
        RTS
    }

; ==============================================================================

    ; *$3DD6A-$3DD9C JUMP LOCATION
    {
        ; Handler for chest tiles
        
        JSR $DDE5 ; $3DDE5 IN ROM; TSB to $02F6
        
        ; Store the tile type we're handling to $76.
        LDA $06 : STA $76
        
        ; Chest tile values range from 0x58 - 0x5D, so tell me which chest in the room it is.
        SUB.w #$0058 : ASL A : TAX
        
        ; Load from a listing of in room chest addresses.
        ; If top bit not set, then branch.
        LDA $06E0, X : CMP.w #$8000 : BCC .notBigKeyLock
        
        LDA $0A : TSB $0E
        
        ASL #4 : TSB $02E7
        
        AND.w #$0020 : BEQ .notCenteredTouch
        
        ; Store the tile type here
        LDA $06 : STA $02EA
    
    .notCenteredTouch
    
        RTS
    
    .notBigKeyLock
    
        ; Since it's not a big key lock, it must be a chest or big chest
        LDA $0A : TSB $02E5 : TSB $0E
        
        RTS
    }

    ; *$3DD9D-$3DDA0 JUMP LOCATION
    {
        LDA $06
        
        BRA .alpha
    
    ; *$3DDA1 ALTERNATE ENTRY POINT
    
        LDA $06
    
    .alpha
    
        STA $76
        
        LDA $0A : TSB $58
        
        ASL #4 : TSB $02C0
        
        RTS
    }

    ; *$3DDB1-$3DDC9 JUMP LOCATION
    {
        ; spike / cactus tile handler
        ; (invincible b/c he just beat a boss)
        LDA $0FFC : BNE .linkInvincible
        
        LDA $0403 : AND.w #$0080 : BEQ .didntGrabHeartContainer
    
    .linkInvincible
    
        LDA $0A : TSB $0E
        
        RTS
    
    .didntGrabHeartContainer
    
        LDA $0A : XBA : TSB $02E7
        
        RTS
    }

    ; *$3DDCA-$3DDE0 JUMP LOCATION
    {
        ; The invincibility mentioned in this routine occurs after beating a boss fight,
        ; not by using some item or anything like that.
        
        LDA $0FFC : BNE .Invincible
        
        LDA $0403 : AND.w #$0080 : BNE .invincible
        
        LDA $0A : ASL #4 : TSB $02EE
    
    .invincible
    
        RTS
    }

    ; *$3DDE1-$3DDEA JUMP LOCATION
    {
        LDA $0A : TSB $0E
    
    ; *$3DDE5 ALTERNATE ENTRY POINT
    
        LDA $0A : TSB $02F6
        
        RTS
    }

    ; *$3DDEB-$3DDF6 JUMP LOCATION
    {
        ; Key door, and maybe other types of tiles...
        LDA $0A : TSB $0E
        
        ASL #4 : TSB $02F6
        
        RTS
    }

    ; *$3DDF7-$3DE16 JUMP LOCATION
    {
        ; Blue Rupee tile
        
        LDX $BD
        
        ; We need this distinction to know how to update the tilemap.
        LDA $7F2040, X : AND.w #$00FF : CMP.w #$0060 : BNE .touched_lower_half
        
        ; Touched upper tile of the 16x8 rupee.
        LDA $0A : XBA : TSB $02F6
        
        RTS
    
    .touched_lower_half
    
        ; Touched lower half of the 16x8 rupee.
        LDA $0A : XBA : ASL #4 : TSB $02F6
        
        RTS
    }

    ; *$3DE17-$3DE28 JUMP LOCATION
    {
        ; tile attribute 0x67 handler.... (orange / blue barrier tiles)
        LDA $0A : TSB $0E : TSB $02F6
        
        LDA $0A : XBA : ASL #4 : TSB $02E7
        
        RTS
    }

    ; *$3DE29-$3DE44 JUMP LOCATION
    {
        LDA $0A
        
        BRA BRANCH_ALPHA
    
    ; *$3DE2D ALTERNATE ENTRY POINT
    
        LDA $0A : ASL #4
        
        BRA BRANCH_ALPHA
    
    ; *$3DE35 ALTERNATE ENTRY POINT
    
        LDA $0A : XBA
        
        BRA BRANCH_ALPHA
    
    ; *$3DE3A ALTERNATE ENTRY POINT
    
        LDA $0A : XBA : ASL #4
    
    BRANCH_ALPHA:
    
        TSB $03F1
        
        RTS
    }

    ; *$3DE45-$3DE4E JUMP LOCATION
    {
        JSR $DDE5 ; $3DDE5 IN ROM
        
        LDA $06 : STA $76
        
        BRL $3DD6A_notBigKeyLock
    }

    ; *$3DE4F-$3DE5A JUMP LOCATION
    {
        JSR $DD0A ; $3DD0A IN ROM
        
        LDA $0A : XBA : TSB $02EE
        
        STZ $62
        
        RTS
    }

    ; *$3DE5B-$3DE60 JUMP LOCATION
    {
        LDA $0A : TSB $0343
        
        RTS
    }

    ; *$3DE61-$3DE66 JUMP LOCATION
    {
        LDA $0A : TSB $0357
        
        RTS
    }

    ; *$3DE67-$3DE6F JUMP LOCATION
    {
        ; Aftermath tiles from destroying / picking things up?
        LDA $0A : TSB $035B : TSB $0343
        
        RTS
    }

    ; $3DE70-$3DE7D
    {
        dw $0054, $0052, $0050, $0051, $0053, $0055, $0056
    }

    ; *$3DE7E-$3DEAC JUMP LOCATION
    {
        LDX.w #$000C
    
    .nextTileType
    
        ; Load this tile's attribute value
        LDA $06 
        
        CMP $DE70, X : BNE .noMatch
        CMP.w #$0050 : BEQ .specialCase
        CMP.w #$0051 : BNE .notSpecialCase
    
    .specialCase
    
        ; The special cases are the two colors of bushes, btw
        ; The other things that set these particular bits are rockpiles
        LDA $0A : XBA : ASL #4 : TSB $02EE
    
    .notSpecialCase
    
        LDA $0A : TSB $0366
        
        STX $036A
        
        JSR $DDE1 ; $3DDE1 IN ROM
        
        RTS
    
    .noMatch
    
        DEX #2 : BPL .nextTileType
        
        RTS
    }

    ; *$3DEAD-$3DEBA JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : ASL #4 : TSB $036D
        
        RTS
    }

    ; *$3DEBB-$3DEC4 JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : TSB $036D
        
        RTS
    }

    ; *$3DEC5-$3DECE JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : TSB $036E
        
        RTS
    }

    ; *$3DECF-$3DEDC JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : ASL #4 : TSB $036E
        
        RTS
    }

    ; *$3DEDD-$3DEE6 JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : TSB $036F
        
        RTS
    }

    ; *$3DEE7-$3DEF0 JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : TSB $0370
        
        RTS
    }

    ; *$3DEF1-$3DFFE JUMP LOCATION
    {
        LDA $06 : STA $76
        
        LDA $0A : ASL #4 : TSB $0370
        
        RTS
    }

    ; *$3DEFF-$3DF08 JUMP LOCATION
    {
        LDA $0A : ASL #4 : TSB $0357
        
        RTS
    }

    ; *$3DF09-$3DF10 JUMP LOCATION
    {
        ; apparently a gravestone tile?
        
        LDA $0A : TSB $02E7 : TSB $0E
        
        RTS
    }

    ; *$3DF11-$3DF18 JUMP LOCATION
    {
        ; Desert palace trigger tile? (Book o' mudora inscription?)
        LDA $0A : TSB $02EE : TSB $0E
        
        RTS
    }

    ; *$3DF19-$3DF25 JUMP LOCATION
    {
        ; Rock pile tile
        LDA $0A : TSB $0E
        
        XBA : ASL #4 : TSB $02EE
        
        RTS
    }

    ; *$3E026-$3E051 LOCAL
    {
        LDA $00 : AND.w #$FFF8 : ASL #3 : STA $06
        
        LDA $02 : AND.w #$003F : ADD $06
        
        LDX $EE : BEQ .onBg2
        
        ADD.w #$1000
    
    .onBg2
    
        REP #$10
        
        TAX
        
        LDA $7F2000, X : AND.w #$00FF : TAX
        
        LDA $DF26, X : AND.w #$00FF
        
        RTS
    }

; *$3E076-$3E111 LOCAL
{
    LDA $51 : AND.b #$07 : STA $00
    
    LDY $22
    
    LDA $0C : AND.b #$04 : BEQ BRANCH_ALPHA
    
    DEY

BRANCH_ALPHA:

    LDA $6E : ASL #2 : STA $01
    
    TYA : AND.b #$07 : ADD $01 : TAX
    
    ; Check if we've hit one of those diagonal walls... (not really the diagonal ones but before them)
    LDA $38 : AND.b #$05 : BEQ BRANCH_BETA
    
    LDA $51 : AND.b #$07 : STA $02
    
    LDA $6E : AND.b #$02 : BNE BRANCH_GAMMA
    
    LDA.b #$08 : SUB $02
    
    BRA BRANCH_DELTA

BRANCH_GAMMA:

    LDA $02 : ADD.b #$08

BRANCH_DELTA:

    STA $02
    
    LDA $E052, X : SUB $02
    
    LDY $30 : BEQ BRANCH_EPSILON : BPL BRANCH_ZETA
    
    EOR.b #$FF

BRANCH_ZETA:

    INC A : STA $00
    
    BRA BRANCH_THETA

BRANCH_BETA:

    LDA $E052, X : SUB $00 : STA $00

BRANCH_THETA:

    LDA $30 : BEQ BRANCH_EPSILON : BPL BRANCH_IOTA
    
    LDA $00 : BEQ BRANCH_EPSILON : BMI BRANCH_EPSILON
    
    REP #$20
    
    AND.w #$00FF : ADD $20 : STA $20
    
    SEP #$20
    
    LDA.b #$08
    
    BRA BRANCH_KAPPA

BRANCH_IOTA:

    LDA $00 : BPL BRANCH_EPSILON
    
    REP #$20
    
    AND.w #$00FF : ORA.w #$FF00 : ADD $20 : STA $20
    
    SEP #$20
    
    LDA.b #$04

BRANCH_KAPPA:

    STA $6B
    
    LDY.b #$02
    
    LDA $0C : AND.b #$04
    
    BNE BRANCH_LAMBDA
    
    LDY.b #$03

BRANCH_LAMBDA:

    LDA $E072, Y : ORA.w #$0410
    
    RTL

BRANCH_EPSILON:

    RTS
}

; *$3E112-$3E1BD LOCAL/LONG SWITCHABLE
{
    LDA $22
    
    LDY $6E : CPY.b #$06 : BNE BRANCH_ALPHA
    
    DEC A

BRANCH_ALPHA:

    AND.b #$07 : STA $00
    
    LDX.b #$00
    
    LDA $0C : AND.b #$04 : BEQ BRANCH_BETA
    
    LDX.b #$02

BRANCH_BETA:

    LDA $6E : ASL #2 : STA $01
    
    LDA $51, X : AND.b #$07 : ADD $01 : TAX
    
    LDA $38 : AND.b #$05 : BEQ BRANCH_GAMMA
    
    LDA $22 : AND.b #$07
    
    LDY $6E : CPY.b #$04 : BEQ BRANCH_DELTA
    
    CPY.b #$06 : BEQ BRANCH_DELTA
    
    XBA
    
    TXA : EOR.b #$07 : TAX
    
    XBA : EOR.b #$FF : INC A
    
    BRA BRANCH_EPSILON

BRANCH_DELTA:

    SUB.b #$08 : EOR.b #$FF : INC A : STA $02
    
    LDA $E052, X : SUB $02

BRANCH_EPSILON:

    LDY $31 : BEQ BRANCH_ZETA : BPL BRANCH_THETA
    
    EOR.b #$FF : INC A

BRANCH_THETA:

    STA $00
    
    BRA BRANCH_IOTA

BRANCH_GAMMA:

    LDA $E052, X : SUB $00 : STA $00

BRANCH_IOTA:

    LDA $31 : BEQ BRANCH_ZETA : BPL BRANCH_KAPPA
    
    LDA $00 : BEQ BRANCH_ZETA : BMI BRANCH_ZETA
    
    REP #$20
    
    AND.w #$00FF : ADD $22 : STA $22
    
    SEP #$20
    
    LDA.b #$02
    
    BRA BRANCH_LAMBDA

BRANCH_EPSILON:

    LDA $00 : BPL BRANCH_ZETA
    
    REP #$20
    
    AND.w #$00FF : ORA.w #$FF00 : ADD $22 : STA $22
    
    SEP #$20
    
    LDA.b #$01

BRANCH_LAMBDA:

    STA $6B
    
    LDY.b #$00
    
    LDA $6E : AND.b #$02 : BNE BRANCH_MU
    
    LDY.b #$01

BRANCH_MU:

    LDA $E072, Y : ORA.w #$0420
    
    RTL

BRANCH_ZETA:

    RTS
}

; *$3E1BE-$3E226 LOCAL
{
    STZ $67
    
    LDY.b #$08
    
    LDA $27 : BEQ BRANCH_ALPHA : BMI BRANCH_BETA
    
    LDY.b #$04

BRANCH_BETA:

    JSR $E1D7 ; $3E1D7 IN ROM

BRANCH_ALPHA:

    LDY.b #$02
    
    LDA $28 : BEQ BRANCH_GAMMA : BMI BRANCH_DELTA
    
    LDY.b #$01

; *$3E1D7 ALTERNATE ENTRY POINT
BRANCH_DELTA:

    TYA : ORA $67 : STA $67
    
    STA $26

BRANCH_GAMMA:

    LDA $6B : AND.b #$0C : BEQ BRANCH_EPSILON
    
    LDA $6B : AND.b #$03 : BEQ BRANCH_EPSILON
    
    LDA $5D : CMP.b #$02 : BNE BRANCH_EPSILON
    
    LDA $28 : EOR.b #$FF : INC A : STA $28
    
    LDA $27 : EOR.b #$FF : INC A : STA $27

BRANCH_EPSILON:

    LDA $6C : CMP.b #$01 : BNE BRANCH_ZETA
    
    LDA $26 : AND.b #$0C : STA $26
    
    LDA $67 : AND.b #$0C : STA $67
    
    STZ $28

BRANCH_ZETA:

    LDA $6C : CMP.b #$02 : BNE BRANCH_THETA
    
    LDA $26 : AND.b #$03 : STA $26
    
    LDA $67 : AND.b #$03 : STA $67
    
    STZ $27

BRANCH_THETA:

    RTS
}

; ==============================================================================

    ; $3E227-$3E244 DATA
    pool 
    {
    
    .speed_table
        db $18
        db $10
        db $0A
        db $18
        db $10
        db $08
        db $08
        db $04
        db $0C
        db $10
        db $09
        db $19
        db $14
        db $0D
        db $10
        db $08
        db $40
        db $2A
        db $10
        db $08
        db $04
        db $02
        db $30
        db $18
        db $20
        db $15
        db $F0
        db $00
        db $F0
        db $01
    }

; ==============================================================================

    ; *$3E245-$3E405 LONG
    {
        PHB : PHK : PLB
        
        ; Branch if we're not in the text submodule.
        LDA $11 : CMP.b #$02 : BNE BRANCH_ALPHA
        
        ; Are we in message mode?
        LDA $10 : CMP.b #$0E : BEQ BRANCH_BETA
    
    BRANCH_ALPHA:
    
        ; Flag indicating that Link can move.
        LDA $0B7B : BEQ .playerCanMove
    
    BRANCH_BETA:
    
        ; Otherwise, Link can't move and has to stay in place.
        LDA $20 : STA $00 : STA $3E
        LDA $22 : STA $01 : STA $3F
        
        LDA $21 : STA $02 : STA $40
        LDA $23 : STA $03 : STA $41
        
        BRL BRANCH_ALIF
    
    .playerCanMove
    
        ; Is Link swimming?
        LDA $5D : CMP.b #$04 : BEQ .isSwimming
        
        ; Is Link moving already?
        LDA $034A : BEQ BRANCH_EPSILON
        
        ; Called if Link is on a collision course and hits a wall.
        LDA $0372 : BEQ .notDashVolatile
        
        ; Here, Link is moving, but has not hit a wall yet.
        LDA.b #$18 : STA $00
        
        BRA BRANCH_ZETA
    
    .isSwimming
    .notDashVolatile
    
        BRL BRANCH_3E42A
    
    BRANCH_EPSILON:
    
        ; The collision indicator.
        LDA $0372 : BEQ BRANCH_THETA
        
        STZ $57
        
        LDA $02F1 : CMP.b #$10 : BCS BRANCH_THETA
        
        BRL BRANCH_$3E545
    
    BRANCH_THETA:
    
        LDA $0316 : ORA $0317 : CMP.b #$0F : BNE BRANCH_IOTA
        
        BRL BRANCH_DIALPHA
    
    BRANCH_IOTA:
    
        LDA $5E : STA $00
        
        LDA $0351 : BEQ BRANCH_ZETA
        
        ; Pegasus dashing speed.
        LDA $5E : CMP.b #$10 : BNE BRANCH_LAMBDA
        
        ; Link is going fast.
        LDX.b #$16
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA:
    
        LDX.b #$0C
        
        LDA $5E : CMP.b #$0C : BNE BRANCH_MU
        
        LDX.b #$0E
    
    BRANCH_MU:
    
        STX $00
    
    BRANCH_ZETA:
    
        STZ $27
        STZ $28
        
        STZ $68
        STZ $69
        
        LDX.b #$00
        
        ; Filter out Up and down data.
        ; i.e. one of the left or right directions is down.
        LDA $67 : TAY : AND.b #$0C : BEQ BRANCH_NU
        
        TYA : AND.b #$03 : BEQ BRANCH_NU
        
        LDX.b #$01
    
    BRANCH_NU:
    
        TXA : ADD $00 : TAX
        
        LDA $5B    : BEQ BRANCH_XI
        CMP.b #$03 : BNE BRANCH_OMICRON    ; Is Link not in a falling state?
        
        ; Oh my, Link is in a falling state.
        LDA $57 : CMP.b #$30 : BCS BRANCH_PI
        
        ADC.b #$08 : STA $57
        
        BRA     
    
    BRANCH_PI:
    
        ; Reset it back to 0x20
        LDA.b #$20 : STA $57
        
        BRA BRANCH_OMICRON
    
    BRANCH_XI:
    
        LDA $57 : BEQ BRANCH_OMICRON
        
        LDX.b #$0A
        
        LDA $11 : CMP.b #$08 : BEQ BRANCH_RHO
        
        CMP.b #$10 : BEQ BRANCH_RHO
        
        LDX.b #$02
    
    BRANCH_RHO:
    
        LDA $67 : AND.b #$00 : BEQ BRANCH_SIGMA
        
        INX
    
    BRANCH_SIGMA:
    
        LDA $57
        
        CMP.b #$01 : BEQ BRANCH_OMICRON
        CMP.b #$10 : BCS BRANCH_TAU
        
        ADC.b #$01 : STA $57
        
        LDA.b #$00
        
        BRA BRANCH_UPSILON
    
    BRANCH_TAU:
    
        STZ $57
        STZ $5E
    
    BRANCH_OMICRON:
    
        ; $3E227, X in rom. Link's speed table.
        LDA $E227, X
    
    BRANCH_UPSILON:
    
        ADD $57 : STA $0A
                  STA $0B
        
        LDA.b #$03 : STA $0C
        LDA.b #$02 : STA $0D
        
        LDX.b #$01
    
    BRANCH_PSI:
    
        LDA $67
        
        AND $0C    : BEQ BRANCH_PHI
        AND.b #$0D : BEQ BRANCH_CHI
        
        LDA $0A, X : EOR.b #$FF : INC A : STA $0A, X
    
    BRANCH_CHI:
    
        ; Set Link's velocity in this direction (Y = 0 - up/down, 1 - left/right)
        LDA $0A, X : STA $27, X
    
    BRANCH_PHI:
    
        ASL $0C : ASL $0C
        ASL $0D : ASL $0D
        
        DEX : BPL BRANCH_PSI
        
        LDA.b #$FF : STA $29
                     STA $24
                     STA $25
        
        STZ $2C
        
        BRA BRANCH_OMEGA
    
    ; *$3E370 ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
    
    BRANCH_OMEGA:
    
        LDA $20 : STA $00 : STA $3E
        
        LDA $22 : STA $01 : STA $3F
        
        LDA $21 : STA $02 : STA $40
        
        LDA $23 : STA $03 : STA $41
        
        ; Is Link using the quake medallion?
        LDA $5D : CMP.b #$0A : BEQ BRANCH_KAPPA
        
        ; If it's 2, you can't move.    ; Hold Link in place.
        LDA $02F5 : CMP.b #$02 : BEQ BRANCH_ALIF
    
    BRANCH_KAPPA:
    
        LDY.b #$02
        LDX.b #$04
        
        LDA $4D : BNE BRANCH_KESRA
        
        LDY.b #$01
        LDX.b #$02
    
    BRANCH_KESRA:
    
        ; check velocities for different directions
        ; ($27 is horizontal, $28 is vertical, so Y is 0 or 1)
        LDA $0027, Y : ASL #4
        
        ADD $002A, Y : STA $002A, Y
        
        PHY : PHP
        
        LDA $0027, Y : LSR #4 : CMP.b #$08
        
        LDY.b #$00
        
        BCC BRANCH_FATHA
        
        ; If the velocity is negative, sign extend to 16 bit
        ORA.b #$F0 : LDY.b #$FF
    
    BRANCH_FATHA:
    
        PLP
        
              ADC $20, X : STA $20, X
        TYA : ADC $21, X : STA $21, X
        
        PLY : DEY
        
        ; Check next direction's recoil / impulse setting.
        DEX #2 : BPL BRANCH_KESRA
        
        JSR $E595 ; $3E595 IN ROM
        JSR $E5F0 ; $3E5F0 IN ROM
        
        BRA BRANCH_ALIF
    
    ; *$3E3DD ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
    
    BRANCH_ALIF:
    
        REP #$20
        
        LDA $20 : ADD $0B7E : STA $20
        
        LDA $22 : ADD $0B7C : STA $22
        
        SEP #$20
        
        ; This is bounds checking, to keep Link from advancing past a wall.
        ; Otherwise, Link and/or the camera will shake as he alternates between
        ; Getting through the wall and getting pushed back.
        LDA $20 : SUB $00 : STA $30
        
        LDA $22 : SUB $01 : STA $22
    
    BRANCH_DIALPHA:
    
        SEP #$20
        
        PLB
        
        RTL
    }

    ; *$3E42A-$3E540 LONG BRANCH LOCATION
    {
        STZ $27
        STZ $28
        
        SEP #$20
        
        LDX.b #$02
    
    BRANCH_LAMBDA:
    
        STZ $08, X
        
        DEC $0326, X : BPL BRANCH_ALPHA
        
        LDA.w #$0001 : STA $032B, X
        
        STZ $0326, X
    
    BRANCH_ALPHA:
    
        LDA $032B, X : ASL A : TAY
        
        LDA $034A : AND.w #$00FF : BEQ BRANCH_BETA
        
        ASL #3 : STA $00
        
        TYA : ADD $00 : TAY
    
    BRANCH_BETA:
    
        LDA $E406, Y : ADD $033C, X : BEQ BRANCH_GAMMA : BPL BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA $E41E, X : AND $67 : STA $67 : STA $26
        
        LDA $032B, X : CMP.w #$0002 : BNE BRANCH_EPSILON
        
        STZ $032B, X
        
        LDA $9639 : STA $0334, X
        
        LDA.w #$0002
        
        BRA BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        LDA.w #$0000 : STA $0334, X : STA $033B, X
        
        BRA BRANCH_ZETA
    
    BRANCH_DELTA:
    
        PHA
        
        TXA : ADD $0338, X : ASL A : TAY
        
        LDA $E422, Y : ORA $67 : STA $67
        
        PLA : CMP $0334, X : BCC BRANCH_ZETA
        
        LDA $0334, X
    
    BRANCH_ZETA:
    
        STZ $033C, X
        
        STA $08, X
        
        LDA $6A : BEQ BRANCH_THETA
        
        STA $08
        
        LSR #2 : STA $00
        
        LDA $08, X : SUB $00 : STA $08, X
    
    BRANCH_THETA:
    
        LDA $0338, X : AND.w #$00FF : BNE BRANCH_IOTA
        
        LDA $08, X : EOR.w #$FFFF : INC A : STA $08, X
    
    BRANCH_IOTA:
    
        DEX #2
        
        BMI BRANCH_KAPPA
        
        BRL BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        SEP #$20
        
        LDA $20 : STA $00 : STA $3E
        LDA $22 : STA $01 : STA $3F
        LDA $21 : STA $02 : STA $40
        LDA $23 : STA $03 : STA $41
        
        LDY.b #$01
        LDX.b #$02
    
    BRANCH_XI:
    
        LDA $08, X : ADC $002A, Y : STA $002A, Y
        
        PHY : PHP
        
        LDA $09, X : CMP.b #$08
        
        LDY.b #$00
        
        BCC BRANCH_MU
        
        ORA.b #$F0
        
        LDY.b #$FF
    
    BRANCH_MU:
    
        PLP
        
        ADC $20, X : STA $20, X
        
        TYA : ADC $21, X : STA $21, X
        
        PLY
        
        LDA $08, X : LSR #4 : STA $08, X
        
        LDA $09, X : BPL BRANCH_NU
        
        EOR.b #$FF : INC A
    
    BRANCH_NU:
    
        ASL #4 : ORA $08, X : STA $0027, X
        
        DEY
        
        DEX #2 : BPL BRANCH_XI
        
        LDA $046C : CMP.b #$04 : BNE BRANCH_OMICRON
        
        JSR $E5CD ; $3E5CD IN ROM
    
    BRANCH_OMICRON:
    
        STZ $68
        STZ $69
        
        BRL BRANCH_$3E3E0
    }

; ==============================================================================

    ; $3E541-$3E544 DATA
    {
        ; \unused Afaik
        db $40, $00, $10, $00
    }

; ==============================================================================

    ; *$3E545-$3E594 LONG BRANCH LOCATION
    {
        STZ $00
        STZ $01
        
        LDA $F0 : AND.b #$0F : BEQ BRANCH_ALPHA
        
        LDX.b #$80
        
        LDA $0351 : BEQ BRANCH_BETA
        
        LDX.b #$50
    
    BRANCH_BETA:
    
        STX $00
        
        LDA.b #$01 : STA $01
    
    BRANCH_ALPHA:
    
        STZ $27
        STZ $28
        STZ $08
        STZ $09
        STZ $0A
        STZ $0B
        
        LDX.b #$03
        
        LDA $67
    
    BRANCH_DELTA:
    
        LSR A : BCS BRANCH_GAMMA
        
        DEX : BPL BRANCH_DELTA
        
        PLB
        
        RTL
    
    BRANCH_GAMMA:
    
        TXY
        
        REP #$20
        
        LDA $00
        
        CPY.b #$00 : BEQ BRANCH_EPSILON
        CPY.b #$02 : BNE BRANCH_ZETA
    
    BRANCH_EPSILON:
    
        EOR.w #$FFFF : INC A
    
    BRANCH_ZETA:
    
        PHA
        
        TYA : AND.w #$0002 : TAX
        
        PLA : STA $08, X
        
        SEP #$20
        
        BRL BRANCH_$3E42A_KAPPA
    }

; ==============================================================================

    ; *$3E595-$3E5E3 LOCAL
    {
        LDA $046C : BEQ BRANCH_ALPHA
        
        LDA $24    : BEQ BRANCH_BETA
        CMP.b #$FF : BNE BRANCH_ALPHA
    
    BRANCH_BETA:
    
        LDA $0322 : AND.b #$03 : CMP.b #$03 : BNE BRANCH_ALPHA
        
        LDA $5D : CMP.b #$13 : BEQ BRANCH_ALPHA
        
        LDY.b #$08
        
        LDA $0310 : BEQ BRANCH_GAMMA : BMI BRANCH_DELTA
        
        LDY.b #$04
    
    BRANCH_DELTA:
    
        TYA : TSB $67
    
    BRANCH_GAMMA:
    
        LDY.b #$02
        
        LDA $0312 : BEQ BRANCH_EPSILON : BMI BRANCH_ZETA
        
        LDY.b #$01
    
    BRANCH_ZETA:
    
        TYA : TSB $67
    
    ; *$3E5CD ALTERNATIVE ENTRY POINT
    
        STZ $6A
    
    BRANCH_EPSILON:
    
        REP #$20
        
        LDA $20 : ADD $0310 : STA $20
        LDA $22 : ADD $0312 : STA $22
        
        SEP #$20
    
    BRANCH_ALPHA:
    
        RTS
    }

; ==============================================================================

    ; $3E5E4-$3E5EF DATA
    {
    
    ; \task Name this pool / routine.
    .walking_direction_flags
        db $08, $04, $02, $01
    
    .y_speeds
        db -8,  8,  0,  0
    
    .x_speeds
        db  0,  0, -8,  8
    }

; ==============================================================================

    ; *$3E5F0-$3E670 LOCAL
    {
        LDA $03F3 : BEQ BRANCH_$3E595_ALPHA
        
        LDA $24 : BEQ BRANCH_ALPHA
        
        CMP.b #$FF : BEQ BRANCH_$3E595_ALPHA
    
    BRANCH_ALPHA:
    
        LDA $0376 : AND.b #$01 : BEQ BRANCH_$3E595_ALPHA
        
        LDA $5D : CMP.b #$13 : BEQ BRANCH_$3E595_ALPHA
        
        LDA $4D : BEQ BRANCH_$3E595_ALPHA
        
        LDA $0372 : BEQ BRANCH_BETA
        
        LDA $02F1 : CMP.b #$20 : BNE BRANCH_BETA
        
        LDY $03F3 : DEY
        
        LDA $E5E4, Y : AND $67 : BEQ BRANCH_$3E595_ALPHA
    
    BRANCH_BETA:
    
        STZ $6A
        
        LDY $03F3 : DEY
        
        LDA $E5E4, Y : TSB $67
        
        LDA $E5E8, Y : STA $72
        
        LDA $E5EC, Y : STA $73
        
        LDX.b #$01
        LDY.b #$02
    
    BRANCH_DELTA:
    
        PHX
        
        LDA $72, X : ASL #4 : ADD $041C, X : STA $041C, X
        
        LDA $72, X
        
        PHP
        
        LDX.b #$00
        
        LSR #4
        
        PLP : BPL BRANCH_GAMMA
        
        ORA.b #$F0
        
        DEX
    
    BRANCH_GAMMA:
    
        ADC $0020, Y : STA $0020, Y
        
        TXA : ADC $0021, Y : STA $0021, Y
        
        PLX
        
        DEY #2
        
        DEX : BPL BRANCH_DELTA
        
        SEP #$20
        
        RTS
    }

    ; *$3E69D-$3E7CD LONG
    {
        PHB : PHK : PLB
        
        LDA.b #$04 : STA $26
        
        BRA BRANCH_STUPID
    
    ; *$3E6A6 ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
    
    BRANCH_STUPID:
    
        ; Is Link swimming?
        LDA $5D : CMP.b #$04 : BNE .notSwimming
        
        BRL BRANCH_$3E7FA
    
    .notSwimming
    
        ; Is Link moving / pushing?
        LDA $26 : BNE .isPushing
        
        BRL BRANCH_PSI
    
    .isPushing
    
        ; Store that push state
        STA $00
        
        ; Check the movement flag
        LDA $034A : BEQ .notMoving
        
        LDA $0340 : STA $00
    
    .notMoving
    
        ; Check if Link can change direction
        LDA $50 : BNE BRANCH_DELTA
        
        LDA $6A : BEQ BRANCH_EPSILON
        
        LDA $6C : BEQ BRANCH_ZETA
        
        ASL A : AND.b #$FC : TAY
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDA $2F : LSR A : TAX
        
        LDA $00 : AND $E671, X : BNE BRANCH_DELTA
    
    BRANCH_EPSILON:
    
        LDY.b #$04
        
        LDA $00 : AND.b #$0C : BEQ BRANCH_THETA
        
        LDY.b #$00
    
    BRANCH_THETA:
    
        ; check if moving in horizontal direction
        CPY.b #$04 : BEQ BRANCH_IOTA
        
        LDA $00 : AND.b #$04 : BNE BRANCH_KAPPA
        
        BRA BRANCH_LAMBDA
    
    BRANCH_IOTA:
    
        LDA $00 : AND.b #$01 : BEQ BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        INY #2
    
    BRANCH_LAMBDA:
    
        ; all this shit really comes down to is setting Link's direction
        ; but $26 and $2F have somewhat incompatible layouts, *sigh*
        STY $2F
        
        BRA BRANCH_DELTA
    
    ; *$3E704 ALTERNATE ENTRY POINT
    
        PHB : PHK : PLB
    
    BRANCH_DELTA:
    
        LDA $0372 : BEQ BRANCH_MU
        
        BRL BRANCH_$3E88F
    
    BRANCH_MU:
    
        LDA $2F : LSR A : TAX
        
        LDA $5E : CMP.b #$06 : BNE BRANCH_NU
        
        TXA : ADD.b #$04 : TAX
        
        BRA BRANCH_XI
    
    BRANCH_NU:
    
        LDA $034A : BEQ BRANCH_XI
        
        ; branch if no direction buttons are held down
        LDA $F0 : AND.b #$0F : BEQ BRANCH_PI
        
        TXA : ADD.b #$04 : TAX
    
    BRANCH_XI:
    
        LDA $5D : CMP.b #$17 : BNE BRANCH_RHO
        
        BRL BRANCH_$3E7CE
    
    BRANCH_RHO:
    
        LDA $11
        
        CMP.b #$0E : BEQ BRANCH_SIGMA
        CMP.b #$12 : BEQ BRANCH_TAU
        CMP.b #$13 : BNE BRANCH_UPSILON
    
    BRANCH_TAU:
    
        LDX.b #$0C
        
        BRA BRANCH_SIGMA
    
    BRANCH_UPSILON:
    
        LDA $0308 : AND.b #$80 : BNE BRANCH_SIGMA
        
        LDA $48 : AND.b #$8D : BEQ BRANCH_PHI
        
        LDX.b #$0C
        
        BRA BRANCH_SIGMA
    
    BRANCH_PHI:
    
        LDA $0351 : BNE BRANCH_SIGMA
        
        LDA $3C : BEQ BRANCH_CHI
    
    BRANCH_SIGMA:
    
        LDA $2E : CMP.b #$06 : BCS BRANCH_PI
        
        LDA $02F5 : CMP.b #$02 : BEQ BRANCH_PI
        
        LDA $E675, X : STA $00
        
        LDA $2D : ADD.b #$01 : STA $2D : CMP $00 : BCC BRANCH_PSI
        
        STZ $2D
        
        LDA $2E : INC A : CMP.b #$06 : BNE BRANCH_OMEGA
    
    BRANCH_PI:
    
        LDA.b #$00
    
    BRANCH_OMEGA:
    
        STA $2E
    
    BRANCH_PSI:
    
        PLB
        
        RTL
    
    BRANCH_CHI:
    
        LDX $2E
        
        LDA $5E : CMP.b #$06 : BNE BRANCH_ALIF
        
        TXA : ADD.b #$08 : TAX
    
    BRANCH_ALIF:
    
        LDA $034A : BEQ BRANCH_BET
        
        TXA : ADD.b #$08 : TAX
    
    BRANCH_BET:
    
        LDA $02F5 : CMP.b #$02 : BEQ BRANCH_DEL
        
        LDA $E685, X : STA $00
        
        LDA $2D : ADD.b #$01 : STA $2D : CMP $00 : BCC BRANCH_THEL
        
        STZ $2D
        
        LDA $2E : INC A : CMP.b #$09 : BNE BRANCH_RAH
        
        LDA.b #$01
    
    BRANCH_RAH:
    
        STA $2E
    
    BRANCH_THEL:
    
        PLB
        
        RTL
    
    ; *$3E7CE LONG BRANCH LOCATION
    
        LDA $2E : CMP.b #$04 : BCS BRANCH_ZAH
        
        LDA $02F5 : CMP.b #$02 : BEQ BRANCH_ZAH
        
        LDA $E675, X : STA $00
        
        LDA $2D : ADD.b #$01 : STA $2D : CMP $00 : BCC BRANCH_DEL
        
        STZ $2D
        
        LDA $2E : INC A : CMP.b #$04 : BNE BRANCH_SIN
    
    BRANCH_ZAH:
    
        LDA.b #$00
    
    BRANCH_SIN:
    
        STA $2E
    
    BRANCH_DEL:
    
        PLB
        
        RTL
    }

    ; *$3E7FA-$3E841 LONG BRANCH LOCATION
    {
        LDA $0340 : BEQ BRANCH_ALPHA
        
        LDA $50 : BNE BRANCH_ALPHA
        
        LDA $6A : BEQ BRANCH_BETA
        
        LDA $6C : BEQ BRANCH_GAMMA
        
        ASL A : AND.b #$FC : TAY
        
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA $2F : LSR A : TAX
        
        LDA $0340 : AND $E671, X : BNE BRANCH_ALPHA
    
    BRANCH_BETA:
    
        LDY.b #$04
        
        LDA $0340 : AND.b #$0C : BEQ BRANCH_DELTA
        
        LDY.b #$00
    
    BRANCH_DELTA:
    
        CPY.b #$04 : BEQ BRANCH_EPSILON
        
        LDA $0340 : AND.b #$04 : BNE BRANCH_ZETA
        
        BRA BRANCH_THETA
    
    BRANCH_EPSILON:
    
        LDA $0340 : AND.b #$01 : BEQ BRANCH_THETA
    
    BRANCH_ZETA:
    
        INY #2
    
    BRANCH_THETA:
    
        STY $2F
    
    BRANCH_ALPHA:
    
        PLB
        
        RTL
    }

    ; *$3E88F-$3E8EF LONG BRANCH LOCATION
    {
        LDX.b #$06
        
        LDA $0374 : BEQ BRANCH_ALPHA
    
    BRANCH_BETA:
    
        LDA $0374 : CMP $E881, X : BCC BRANCH_ALPHA
        
        DEX : BPL BRANCH_BETA
        
        INX
    
    BRANCH_ALPHA:
    
        LDA $3C : CMP.b #$09 : BCS BRANCH_GAMMA
        
        LDA $0351 : BNE BRANCH_GAMMA
        
        TXA : ASL #3 : TAX
        
        LDA $E842, X : STA $00
        
        LDA $2D : ADD.b #$01 : STA $2D : CMP $00 : BCC BRANCH_DELTA
        
        STZ $2D
        
        LDA $2E : INC A : CMP.b #$09 : BNE BRANCH_EPSILON
        
        LDA.b #$01
    
    BRANCH_EPSILON:
    
        BRA BRANCH_ZETA
    
    BRANCH_DELTA:
    
        BRA BRANCH_THETA
    
    BRANCH_GAMMA:
    
        LDA $E87A, X : STA $00
        
        LDA $2D : ADD.b #$01 : STA $2D : CMP $00 : BCC BRANCH_THETA
        
        STZ $2D
        
        LDA $2E : INC A : CMP.b #$06 : BCC BRANCH_ZETA
        
        LDA.b #$00
    
    BRANCH_ZETA:
    
        STA $2E
    
    BRANCH_THETA:
    
        PLB
        
        RTL
    }

    ; *$3E8F0-$3E900 LOCAL
    {
        ; If outdoors, ignore
        LDA $1B : BEQ .return
        
        ; I'll deal with this routine later >:(
        LDA $6C : BEQ .notInDoorway
        
        JML $07E901 ; $3E901 IN ROM
    
    .notInDoorway
    
        JSL $07E9D3 ; $3E9D3 IN ROM
    
    .return
    
        RTS
    }

    ; *$3E901-$3E9D2 JUMP LOCATION (LOCAL)
    {
        STZ $68
        STZ $69
        
        ; Check Link's push state for down/up presses
        LDA $26 : AND.b #$0C : BEQ BRANCH_ALPHA
        
        ; See if Link's in a vertical doorway
        LDX $6C : CPX.b #$01 : BNE BRANCH_ALPHA
        
        ; Check for down presses
        AND.b #$04 : BEQ BRANCH_BETA ; Not a down press
        
        REP #$20
        
        LDA $20 : ADD.w #$001C : STA $00 : AND.w #$00FC : BNE BRANCH_ALPHA
        
        SEP #$20
        
        LDA $01 : SUB $40 : STA $68
        
        BRA BRANCH_ALPHA
    
    BRANCH_BETA:
    
        REP #$20
        
        LDA $20 : SUB.w #$0012 : STA $00
        
        SEP #$20
        
        LDA $01 : SUB $40 : STA $68
    
    BRANCH_ALPHA:
    
        SEP #$20
        
        ; Check Link's push state for left/right presses
        LDA $26 : AND.b #$03 : BEQ BRANCH_GAMMA
        
        LDX $6C : CPX.b #$02 : BNE BRANCH_GAMMA
        
        AND.b #$01 : BEQ BRANCH_DELTA
        
        REP #$20
        
        LDA $22 : ADD.w #$0015 : STA $00 : AND.w #$00FC : BNE BRANCH_GAMMA
        
        SEP #$20
        
        LDA $01 : SUB $41 : STA $69
        
        BRA BRANCH_GAMMA
    
    BRANCH_DELTA:
    
        REP #$20
        
        LDA $22 : SUB.w #$0008 : STA $00
        
        SEP #$20
        
        LDA $01 : SUB $41 : STA $69
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        ; ????
        LDA $69 : BEQ .noHorizontalMovement : BMI .movedLeft
        
        ; NOTE! These are all intra-room transitions
        STZ $030B
        STZ $0308
        STZ $0309
        STZ $0376
        
        JSL $02B62E ; $1362E IN ROM ; Transition right
        
        RTS
    
    .movedLeft
    
        STZ $030B
        STZ $0308
        STZ $0309
        STZ $0376
        
        JSL $02B6CD ; $136CD IN ROM ; Transition left
        
        RTS
    
    .noHorizontalMovement
    
        LDA $68 : BEQ .noVerticalMovement : BPL .movedDown
        
        STZ $030B
        STZ $0308
        STZ $0309
        STZ $0376
        
        JSL $02B81C ; $1381C IN ROM
        
        RTS
    
    .movedDown:
    
        STZ $030B
        STZ $0308
        STZ $0309
        STZ $0376
        
        JSL $02B76E ; $1376E IN ROM
    
    .noVerticalMovement
    
        RTS
    }

; ==============================================================================

    ; *$3E9D3-$3EA05 LONG
    {
        PHB : PHK : PLB
        
        LDA $21 : SUB $40 : STA $68
        LDA $23 : SUB $41 : STA $69
        
        LDA $69 : BEQ .noHorizontalMovement
                  BMI .movedLeft
        
        JSL $02B8BD ; $138BD IN ROM
        
        BRA .noHorizontalMovement
    
    .movedLeft
    
        JSL $02B8F9 ; $138F9 IN ROM
    
    .noHorizontalMovement
    
        LDA $68 : BEQ .noVerticalMovement
                  BPL .movedDown
        
        JSL $02B919 ; $13919 IN ROM
        
        PLB
        
        RTL
    
    .movedDown
    
        JSL $02B909 ; $13909 IN ROM
    
    .noVerticalMovement
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3EA06-$3EA21 LONG
    Player_InitPrayingScene_HDMA:
    {
        ; This routine initializes the hdma table for Link praying to open
        ; the desert barrier. This code is not the same as that used to create
        ; the spotlight effects of entering or leaving a dungeon. That can
        ; be found in bank 0x00.
        
        JSL $02C7B8 ; $147B8 IN ROM
        
        PHB : PHK : PLB
        
        REP #$20
        
        LDA.w #$0026 : STA $067C
        
        SEP #$20
        
        STZ $067E
        
        JSL $07EA27 ; $3EA27 IN ROM
        
        INC $B0
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3EA22-$3EA26 DATA
    {
    
    ; \task Name this pool / routine.
    .timers
        db 22, 22, 22, 64, 1
    }

; ==============================================================================

    ; *$3EA27-$3EBD9 LONG
    {
        ; This routine seems to construct the hdma table that zeroes in or out
        ; on the player's position (e.g. when leaving a dungeon or entering
        ; one).
        
        PHB : PHK : PLB
        
        REP #$30
        
        STZ $04
        
        LDA $20 : SUB $E8 : ADD.w #$000C : STA $0E
        
        SUB $067C : STA $0674 : BPL BRANCH_ALPHA
        
        STA $04
    
    BRANCH_ALPHA:
    
        ADD $067C : ADD $067C : STA $0676
        
        LDA $22 : SUB $E2 : ADD.w #$0008 : STA $0670
        
        LDA.w #$0001 : STA $067A
    
    BRANCH_PHI:
    
        LDA.w #$0100 : STA $00 : STA $02
        
        LDA $0674 : BMI BRANCH_BETA
        
        LDA $04
        
        CMP $0674 : BCC BRANCH_GAMMA
        CMP $0676 : BCS BRANCH_GAMMA
    
    BRANCH_BETA:
    
        LDA $067C : CMP $067A : BCS BRANCH_DELTA
        
        LDA.w #$0001 : STA $067A
        
        STZ $0674
        
        LDA $0676 : STA $04 : CMP.w #$00E1 : BCC BRANCH_GAMMA
        
        BRL BRANCH_EPSILON
    
    BRANCH_DELTA:
    
        JSR $ECDC ; $3ECDC IN ROM
        
        LDA $06 : BNE BRANCH_ZETA
        
        STZ $0674
        
        BRA BRANCH_THETA
    
    BRANCH_ZETA:
    
        LDA $08 : ADD $0670 : STA $02
        
        LDA $0670 : SUB $08 : STA $00
    
    BRANCH_THETA:
    
        LDA $067A : AND.w #$00FF : STA $0A
        
        LDA $0E : SUB $0A : DEC A : ASL A : TAX
        
        BRA BRANCH_IOTA
    
    BRANCH_GAMMA:
    
        LDA $04 : DEC A : ASL A : TAX
    
    BRANCH_IOTA:
    
        LDA $00 : TAY : BMI BRANCH_KAPPA
        
        AND.w #$FF00 : BEQ BRANCH_LAMBDA
        
        CMP.w #$0100 : BNE BRANCH_KAPPA
        
        LDY.w #$00FF
        
        BRA BRANCH_LAMBDA
    
    BRANCH_KAPPA:
    
        LDY.w #$0000
    
    BRANCH_LAMBDA:
    
        TYA : AND.w #$00FF : STA $06
        
        LDA $02 : TAY
        
        AND.w #$FF00 : BEQ BRANCH_MU
        AND.w #$FF00 : BEQ BRANCH_NU ; \wtf what...?
        
        LDY.w #$00FF
        
        BRA BRANCH_MU
    
    BRANCH_NU:
    
        LDY.w #$0000
    
    BRANCH_MU:
    
        TYA : AND.w #$00FF : XBA : ORA $06 : STA $06
        
        CPX.w #$01C0 : BCS BRANCH_XI
        
        CMP.w #$FFFF : BNE BRANCH_OMICRON
        
        LDA.w #$00FF
    
    BRANCH_OMICRON:
    
        STA $1B00, X
    
    BRANCH_XI:
    
        LDA $0674 : BMI BRANCH_PI
        
        LDA $04
        
        CMP $0674 : BCC BRANCH_RHO
        CMP $0676 : BCS BRANCH_RHO
    
    BRANCH_PI:
    
        LDA $067A : AND.w #$00FF : DEC A : ADD $0E : TAX
        
        DEC A : ASL A : CMP.w #$01C0 : BCS BRANCH_SIGMA
        
        TAX
        
        LDA $06 : CMP.w #$FFFF : BNE BRANCH_TAU
        
        LDA.w #$00FF
    
    BRANCH_TAU:
    
        STA $1B00, X
    
    BRANCH_SIGMA:
    
        INC $067A
    
    BRANCH_RHO:
    
        INC $04 : LDA $04 : BMI BRANCH_UPSILON
        
        CMP.w #$00E1 : BCS BRANCH_EPSILON
    
    BRANCH_UPSILON:
    
        BRL BRANCH_PHI
    
    BRANCH_EPSILON:
    
        SEP #$30
        
        LDA $B0 : CMP.b #$04 : BNE BRANCH_CHI
        
        LDA $067E : CMP.b #$01 : BEQ .dont_check_button_input
        
        ; If the player hits any of the main buttons, praying time is over.
        LDA $F4 : ORA $F6 : AND.b #$C0 : BEQ .no_button_input
        
        LDA.b #$01 : STA $067E
        
        LSR $067C
    
    .no_button_input
    .dont_check_button_input
    
        LDA $067E : BEQ .dont_expand_spotlight
        
        LDA $067C : ADD.b #$08 : STA $067C : CMP.b #$C0 : BCC .dont_open_barrier
        
        LDA $02F0 : EOR.b #$01 : STA $02F0
        
        ; Return music volume to full.
        LDA.b #$F3 : STA $012C
        
        ; Reset ambient sfx.
        LDA.b #$00 : STA $012D
        
        STZ $0FC1
        STZ $030A
        STZ $3A
        STZ $0308
        
        LDA $50 : AND.b #$FE : STA $50
        
        STZ $B0
        STZ $11
        
        LDA $010C : STA $10
        
        STZ $1E
        
        STZ $1F
        
        STZ $96
        STZ $97
        STZ $98
        
        JSL ResetSpotlightTable
        
        BRA BRANCH_CHI
    
    .dont_open_barrier
    .dont_expand_spotlight
    
        DEC $3D : BPL BRANCH_CHI
        
        LDX $030A : INX : CPX.b #$04 : BEQ BRANCH_ALTIMA
        
        STX $030A
    
    BRANCH_ALTIMA:
    
        LDA $EA22, X : STA $3D
    
    BRANCH_CHI:
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3EBDA-$3ECDB DATA
    {
    
    
        db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
        db $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FE
        db $FD, $FD, $FD, $FD, $FC, $FC, $FC, $FB
        db $FB, $FB, $FA, $FA, $F9, $F9, $F8, $F8
        db $F7, $F7, $F6, $F6, $F5, $F5, $F4, $F3
        db $F3, $F2, $F1, $F1, $F0, $EF, $EE, $EE
        db $ED, $EC, $EB, $EA, $E9, $E9, $E8, $E7
        db $E6, $E5, $E4, $E3, $E2, $E1, $DF, $DE
        db $DD, $DC, $DB, $DA, $D8, $D7, $D6, $D5
        db $D3, $D2, $D0, $CF, $CD, $CC, $CA, $C9
        db $C7, $C6, $C4, $C2, $C1, $BF, $BD, $BB
        db $B9, $B7, $B6, $B4, $B1, $AF, $AD, $AB
        db $A9, $A7, $A4, $A2, $9F, $9D, $9A, $97
        db $95, $92, $8F, $8C, $89, $86, $82, $7F
        db $7B, $78, $74, $70, $6C, $67, $63, $5E
        db $59, $53, $4D, $46, $3F, $37, $2D, $1F
        db $00
    
    ; $3EC5B
        db $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FE
        db $FD, $FD, $FC, $FC, $FB, $FA, $F9, $F8
        db $F7, $F6, $F5, $F4, $F3, $F1, $F0, $EE
        db $ED, $EB, $E9, $E8, $E6, $E4, $E2, $DF
        db $DD, $DB, $D8, $D6, $D3, $D0, $CD, $CA
        db $C7, $C4, $C1, $BD, $B9, $B6, $B1, $AD
        db $A9, $A4, $9F, $9A, $95, $8F, $89, $82
        db $7B, $74, $6C, $63, $59, $4D, $3F, $2D
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00, $00, $00, $00, $00, $00, $00, $00
        db $00
    }

; ==============================================================================

    ; *$3ECDC-$3ED2B LOCAL
    {
        ; ( table[ ( (A / B) / 2) ] * B) >> 8
        
        SEP #$30
        
        LDA $067A : STA $4205
                    STZ $4204
        
        LDA $067C : STA $4206 : NOP #6
        
        REP #$20
        
        LDA $4214 : LSR A
        
        SEP #$20
        
        TAX
        
        LDY $EC5B, X
        
        LDA $067E : BEQ .contracting
        
        ; Use a different table if dilating.
        LDY $EBDA, X
    
    .contracting
    
        STY $06 : STY $4202
        
        LDA $067C : STA $4203 : NOP #4
        
        LDA $4217 : STA $08
        
        STZ $09
        STZ $07
        
        REP #$30
        
        LDA $067E : AND.w #$00FF : BEQ .dont_double_result
        
        ; Double the result if dilating.
        ASL $08
    
    .dont_double_result
    
        RTS
    }

; ==============================================================================

    ; *$3ED2C-$3ED3E LOCAL
    {
        LDX.b #$01
    
    .prev_slot
    
        LDA $05FC, X : BNE .nonempty_slot
        
        TYA : INC A : STA $05FC, X
        
        CLC
        
        RTS
    
    .nonempty_slot
    
        DEX : BPL .prev_slot
        
        SEC
        
        RTS
    }

; ==============================================================================

    ; *$3ED3F-$3EDB4 LOCAL
    {
        PHX : STX $72
        
        LDA $0E : PHA
        
        REP #$20
        
        LDA $0540, X : AND.w #$007E : ASL #2 : STA $00
        LDA $0540, X : AND.w #$1F80 : LSR #4 : STA $02
        
        SEP #$20
        
        LDA $0E : ASL A : TAX
        
        LDA $00 : STA $05E4, X
        
        LDA $01 : ADD $062D : STA $05E0, X : STA $01
        
        LDA $02 : STA $05F0, X
        
        LDA $03 : ADD $062F : STA $05EC, X : STA $03
        
        STZ $05E8, X
        STZ $05F4, X
        
        LDA $AE : CMP.b #$26 : BEQ BRANCH_ALPHA
        
        LDX $72
        
        LDA $0500, X : BNE BRANCH_ALPHA
        
        LDY.b #$00
        
        ; $3D304 IN ROM
        JSR $D304 : BCC BRANCH_BETA
    
    BRANCH_ALPHA:
    
        PLA : TAX
        
        STZ $05FC, X
        
        PLX
        
        SEC
        
        RTS
    
    BRANCH_BETA:
    
        ; Dragging noise? (Block moving?)
        LDA.b #$22 : JSR Player_DoSfx2
        
        PLA : STA $0E
        
        PLX
        
        LDA.b #$01 : STA $0500, X
        
        CLC
        
        RTS
    }

; ==============================================================================

    ; *$3EDB5-$3EDF3 LONG
    {
        ; Input parameters: Y
        
        SEP #$30
        
        PHB : PHK : PLB
        
        LDA $11 : BNE .return
        
        STY $00
        
        LDX.b #$01
        
        LDA $05FC, X : DEC A : ASL A : CMP $00 : BEQ .correct_index
        
        ; Otherwise, assume the slot indicates the object we're interested in.
        LDX.b #$00
    
    .correct_index
    
        TXA : ASL A : TAY
        
        LDA.b #$09 : STA $02C4 : STZ $02C3
        
        JSR $EE35 ; $3EE35 IN ROM
        
        LDA $05F0, Y : STA $72
        LDA $05EC, Y : STA $73
        
        LDA $05E4, Y : STA $74
        LDA $05E0, Y : STA $75
        
        JSR $EFB9 ; $3EFB9 IN ROM
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3EDF4-$3EDF8
    {
        db $09, $09, $09, $09, $09
    }

; ==============================================================================

    ; *$3EDF9-$3EE2F LONG
    {
        ; Appears to be involved with push blocks or falling push blocks.
        
        SEP #$30
        
        PHB : PHK : PLB : PHY
        
        STY $0E
        
        DEC $02C4 : BPL .not_finished
        
        INC $02C3 : LDX $02C3
        
        LDA $EDF4, X : STA $02C4
        
        CPX.b #$04 : BNE .not_finished
        
        TYX
        
        STZ $0500, X
        STZ $02C3
        
        LDX.b #$01
        
        LDA $05FC, X : DEC A : ASL A : CMP $0E : BEQ .correct_index
        
        LDX.b #$00
    
    .correct_index
    
        STZ $05FC, X
    
    .not_finished
    
        PLY : PLB
        
        RTL
    }

; ==============================================================================

    ; $3EE30-$3EE34 DATA
    {
        db $0C
        
        db $08, $04, $02, $01
    }

; ==============================================================================

    ; *$3EE35-$3EF60 LOCAL
    {
        STZ $27
        STZ $28
        
        LDA $EE30 : STA $0A : STA $0B
        
        LDA.b #$03 : STA $0C
        LDA.b #$02 : STA $0D
        
        LDA $05F8, Y : LSR A : TAX
        
        LDA $EE31, X : STA $00
        
        LDX.b #$01
    
    BRANCH_LAMBDA:
    
        LDA $00
        
        AND $0C : BEQ BRANCH_ALPHA
        AND $0D : BEQ BRANCH_BETA
        
        LDA $0A, X : EOR.b #$FF : INC A : STA $0A, X
    
    BRANCH_BETA:
    
        LDA $0A, X : STA $27, X
        
        BRA BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        ASL $0C : ASL $0C
        ASL $0D : ASL $0D
        
        DEX : BPL BRANCH_LAMBDA
    
    BRANCH_GAMMA:
    
        LDA $27, X : ASL #4 : ADD $05F4, Y : STA $05F4, Y
        
        PHP
        
        CPX.b #$01 : BEQ BRANCH_DELTA
        
        LDX.b #$00
        
        LDA $27 : LSR #4 : CMP.b #$08 : BCC BRANCH_EPSILON
        
        ORA.b #$F0
        
        LDX.b #$FF
    
    BRANCH_EPSILON:
    
        PLP
        
              ADC $05F0, Y : STA $05F0, Y
        TXA : ADC $05EC, Y : STA $05EC, Y
        
        LDA $05F0, Y : AND.b #$0F
        
        BRA BRANCH_ZETA
    
    BRANCH_DELTA:
    
        LDX.b #$00
        
        LDA $28 : LSR #4 : CMP.b #$08 : BCC BRANCH_MU
        
        ORA.b #$F0
        
        LDX.b #$FF
    
    BRANCH_MU:
    
        PLP
        
              ADC $05E4, Y : STA $05E4, Y
        TXA : ADC $05E0, Y : STA $05E0, Y
        
        LDA $05E4, Y : AND.b #$0F
    
    BRANCH_ZETA:
    
        TYX
        
        CMP $05E8, X : BNE BRANCH_THETA
        
        TXA : LSR A : TAX
        
        LDA $05FC, X : DEC A : ASL A : TAX
        
        INC $0500, X
        
        LDA $50 : AND.b #$FB : STA $50
        LDA $48 : AND.b #$FB : STA $48
    
    BRANCH_THETA:
    
        SEP #$20
        
        LDA $05E4, Y : STA $00
        LDA $05E0, Y : STA $01
        
        LDA $05F0, Y : STA $02
        LDA $05EC, Y : STA $03
        
        PHX
        
        LDX.b #$0F
    
    BRANCH_KAPPA:
    
        LDA $0DD0, X : CMP.b #$09 : BCC BRANCH_IOTA
        
        LDA $0D10, X : STA $04
        LDA $0D30, X : STA $05
        
        LDA $0D00, X : STA $06
        LDA $0D20, X : STA $07
        
        REP #$20
        
        LDA $00 : SUB $04 : ADD.w #$0010 : CMP.w #$0020 : BCS BRANCH_IOTA
        
        LDA $02 : SUB $06 : ADD.w #$0010 : CMP.w #$0020 : BCS BRANCH_IOTA
        
        SEP #$20
        
        LDA.b #$08 : STA $0EA0, X
        
        PHY
        
        LDA $05F8, Y : LSR A : TAY
        
        ; Push the sprite because a pushable block is colliding with it?
        LDA $EF61, Y : STA $0F40, X
        LDA $EF65, Y : STA $0F30, X
        
        PLY
    
    BRANCH_IOTA:
    
        SEP #$20
        
        DEX : BPL BRANCH_KAPPA
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; $3EF61-$3EFB8 DATA
    {
        ; \task Fill in this data and label it.
    }

; ==============================================================================

    ; *$3EFB9-$3F0AB LOCAL
    {
        PHY
        
        STY $0E
        
        STZ $0F
        
        LDA $21 : STA $40
        LDA $23 : STA $41
        
        REP #$20
        
        LDA $67 : AND.b #$000F
        
        LDY.b #$06
    
    BRANCH_BETA:
    
        LSR A : BCS BRANCH_ALPHA
        
        DEY #2 : BPL BRANCH_BETA
        
        BRL BRANCH_GAMMA
    
    BRANCH_ALPHA:
    
        LDA $0E : PHA
        
        LDA $EFA1, Y : STA $0C
        LDA $EFB1, Y : STA $0E
        
        LDA ($0C) : ADD $EF71, Y : STA $00
        LDA ($0C) : ADD $EF79, Y : STA $02
        LDA ($0E) : ADD $EF89, Y : STA $04
        LDA ($0E) : ADD $EF91, Y : STA $06
        
        LDA $EF99, Y : STA $0C
        LDA $EFA9, Y : STA $0E
        
        LDA ($0C) : ADD $EF69, Y : STA $08
        LDA ($0E) : ADD $EF81, Y : STA $0A
        
        LDA $48 : AND.w #$FFFB : STA $48
        
        PLA : STA $0E
        
        LDA $00
        
        CMP $04 : BCC BRANCH_DELTA
        CMP $06 : BCC BRANCH_EPSILON

    BRANCH_DELTA:

        LDA $02
        
        CMP $04 : BCC BRANCH_GAMMA
        CMP $06 : BCS BRANCH_GAMMA

    BRANCH_EPSILON:

        PHY : PHX
        
        LDX $0E
        
        LDA $2F : AND.w #$00FF : CMP $05F8, X : BNE BRANCH_ZETA
        
        LDY.b #$01
        
        TXA : LSR A : TAX
        
        LDA $05FC, X : BEQ BRANCH_THETA
        
        LDY.b #$04
    
    BRANCH_THETA:
    
        TYA : AND.w #$00FF : TSB $48
    
    BRANCH_ZETA:
    
        PLX : PLY
        
        TYA : AND.w #$0002 : BEQ BRANCH_IOTA
        
        LDA $08
        
        SUB $0A     : BCC BRANCH_GAMMA
        CMP.w #$0008 : BCS BRANCH_GAMMA
        
        EOR.w #$FFFF : INC A : STA $00
        
        ADD ($0C) : STA ($0C)
        
        BRA BRANCH_KAPPA

    BRANCH_IOTA:

        LDA $08 : SUB $0A : CMP.w #$FFF8 : BCC BRANCH_GAMMA
        
        EOR.w #$FFFF : INC A : STA $00
        
        ADD ($0C) : STA ($0C)
    
    BRANCH_KAPPA:
    
        SEP #$20
        
        LDX.b #$00
        
        TYA : AND.b #$04 : BEQ BRANCH_LAMBDA
        
        INX
    
    BRANCH_LAMBDA:
    
        LDA $30, X : ADD $00 : STA $30, X
    
    BRANCH_GAMMA:
    
        SEP #$20
        
        JSR $E8F0 ; $3E8F0 IN ROM
        
        PLY
        
        RTS
    }

; ==============================================================================

    ; *$3F0AC-$3F0CA LONG
    {
        ; Handles animation of moveable blocks and such?
        
        PHB : PHK : PLB
        
        LDA $05FC : ORA $05FD : BEQ .return
        
        LDX.b #$01
    
    .next_slot
    
        LDA $05FC, X : BEQ .empty_slot
        
        TXA : ASL A : TAY
        
        PHX
        
        JSR $F0D9 ; $3F0D9 IN ROM
        
        PLX
    
    .empty_slot
    
        DEX : BPL .next_slot
    
    .return
    
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3F0CB-$3F0D8
    pool 
    {
        ; Unused data?
        
        db $0C, $0C, $0C, $0C, $FF
    
    ; $3F0D0
        db $00, $01, $02, $03, $04, $00, $00, $00, $00
    }

; ==============================================================================

    ; *$3F0D9-$3F13B LOCAL
    {
        ; Appears to draw moving blocks or falling moving blocks or both.
        ; \task Name this routine.
        
        PHY
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
        
        PLY
        
        LDA $05F0, Y : STA $00
        LDA $05EC, Y : STA $01
        
        LDA $05E4, Y : STA $02
        LDA $05E0, Y : STA $03
        
        REP #$20
        
        LDA $00 : SUB $E8 : DEC A : STA $00
        
        LDA $02 : SUB $E2 : STA $02
        
        SEP #$20
        
        PHY
        
        LDY $02C3
        
        LDA $F0D0, Y : TAX
        
        LDY.b #$00
        
        LDA $F0CC, X : CMP.b #$FF : BNE .alpha
        
        BRA .beta
    
    .alpha
    
        ; The upper accumulator holds the sprite chr.
        XBA
        
        ; Write sprite's X coordinate
        LDA $02 : STA ($90), Y : INY
        
        ; Write sprite's Y coordinate
        LDA $00 : STA ($90), Y : INY
        
        ; swap in the upper accumulator, write sprite's chr.
        XBA : STA ($90), Y : INY
        
        ; Write sprite's properties.
        LDA.b #$20 : STA ($90), Y : INY
        
        TYA : SUB $04 : LSR #2 : TAY
        
        ; Write data to extended OAM portion.
        LDA.b #$02 : STA ($92), Y
    
    .beta
    
        PLY
        
        RTS
    }

; ==============================================================================

    ; *$3F13C-$3F1A2 LONG
    Init_Player:
    {
        PHB : PHK : PLB
        
        ; This routine basically initializes Link.
        ; Make Link face down initially
        LDA.b #$02 : STA $2F
        
        STZ $26     ; Link has no push state.
        STZ $0301
        STZ $037A
        STZ $020B
        STZ $0350
        STZ $030D
        STZ $030E
        STZ $030A
        STZ $02E1
        STZ $3B ; No A button.
        
        ; Zero out all except for the B button.
        LDA $3A : AND.b #$BF : STA $3A
        
        STZ $0308
        STZ $0309
        STZ $0376
        
        JSL Player_ResetSwimState

        LDA $50 : AND.b #$FE : STA $50
        
        STZ $25
        STZ $4D
        STZ $46
        STZ $031F
        STZ $0360
        STZ $02DA
        STZ $55
        
        JSR $AE54   ; $3AE54 IN ROM; more init...
        JSR $9D84   ; $39D84 IN ROM
        
        STZ $037B
        STZ $0300
        
        LDA $67 : AND.b #$F0 : STA $67
        
        STZ $02F2
        STZ $0079
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F1A3-$3F259 LONG
    Player_ResetState:
    {
        STZ $26
        STZ $67
        STZ $031F
        STZ $034A
        
        JSL Player_ResetSwimState
        
        STZ $02E1
        STZ $031F
        STZ $03DB
        STZ $02E0
        STZ $56
        STZ $03F5
        STZ $03F7
        STZ $03FC
        STZ $03F8
        STZ $03FA
        STZ $03E9
        STZ $0373
        STZ $031E
        STZ $02F2
        STZ $02F8
        STZ $02FA
        STZ $02E9
        STZ $02DB
    
    ; *$3F1E6 ALTERNATE ENTRY POINT
    ; called by mirror warping.
    
        STZ $02F5
        STZ $0079
        STZ $0302
        STZ $02F4
        STZ $48
        STZ $5A
        STZ $5B
        
        ; \wtf Why zeroed twice? probably a typo on the programmer's end.
        ; Or maybe it was aliased to two different names...
        STZ $5B
    
    ; *$3F1FA ALTERNATE ENTRY POINT
    ; called by some odd balls.
    
        STZ $036C
        STZ $031C
        STZ $031D
        STZ $0315
        STZ $03EF
        STZ $02E3
        STZ $02F6
        STZ $0301
        STZ $037A
        STZ $020B
        STZ $0350
        STZ $030D
        STZ $030E
        STZ $030A
        STZ $3B
        STZ $3A
        STZ $3C
        STZ $0308
        STZ $0309
        STZ $0376
        STZ $50
        STZ $4D
        STZ $46
        STZ $0360
        STZ $02DA
        STZ $55
        
        JSR $9D84  ; $39D84 IN ROM
        
        STZ $037B
        STZ $0300
        STZ $037E
        STZ $02EC
        STZ $0314
        STZ $03F8
        STZ $02FA
        
        RTL
    }

; ==============================================================================

    ; *$3F25A-$3F2C0 LONG
    {
        ; \task Name this routine. Seems to be important to straight inter room
        ; staircases.
        
        PHB : PHK : PLB
        
        LDX.b #$09
    
    .next_slot
    
        ; Search for Master sword charged sparkle?
        LDA $0C4A, X : CMP.b #$0D : BNE .not_fully_charged_sword_spark
        
        STZ $0C4A, X
    
    .not_fully_charged_sword_spark
    
        DEX : BPL .next_slot
        
        LDA $2E : CMP.b #$05 : BCC .dont_reset_counter
        
        STZ $2E
    
    .dont_reset_counter
    
        STZ $2A
        
        STZ $2B
        
        STZ $030A
        
        LDA.b #$1C : STA $0371
        
        LDA.b #$20 : STA $0378
        
        LDA.b #$01 : STA $037B
        
        LDA $0462 : AND.b #$04 : BEQ .delta
        
        LDA.b #$18 : JSR Player_DoSfx2
        
        BRA .epsilon
    
    .delta
    
        LDA.b #$16 : JSR Player_DoSfx2
    
    .epsilon
    
        STZ $01
        
        LDX.b #16
        
        LDA $0462 : AND.b #$04 : BEQ .zeta
        
        LDX.b #-15
        LDA.b #-1  : STA $01
    
    .zeta
    
        STX $00
        
        REP #$20
        
        ; Adjust X coordinate.... what?
        LDA $22 : ADD $00 : STA $53
        
        LDA $20 : STA $51
        
        SEP #$20
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F2C1-$3F390 LONG
    {
        ; \task Name this routine. Seems pretty important to spiral staircases.
        
        REP #$20
        
        LDA $22 : STA $0FC2
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        LDA $030A : BEQ BRANCH_ALPHA
        
        RTL
    
    BRANCH_ALPHA:
    
        STZ $0373
        STZ $46
        STZ $4D
        
        PHB : PHK : PLB
        
        LDA $0462 : AND.b #$04 : BEQ BRANCH_GAMMA
        
        LDA.b #$FE : STA $27
        
        DEC $0371 : BPL BRANCH_BETA
        
        STZ $0371
        
        LDA.b #0 : STA $27
        
        LDA.b #-2 : STA $28
    
    BRANCH_BETA:
    
        BRA BRANCH_DELTA
    
    BRANCH_GAMMA:
    
        LDA.b #-2 : STA $27
        
        DEC $0371 : BPL BRANCH_DELTA
        
        STZ $0371
        
        LDA.b #-2 : STA $27
        
        LDA.b #2 : STA $28
    
    BRANCH_DELTA:
    
        JSL $07E370 ; $3E370 IN ROM
        JSL $07E704 ; $3E704 IN ROM
        
        LDA $0371 : BNE BRANCH_ZETA
        
        DEC $0378 : BPL BRANCH_ZETA
        
        STZ $0378
        
        LDX.b #$04
        
        LDA $0462 : AND.b #$04 : BNE BRANCH_EPSILON
        
        LDX.b #$06
    
    BRANCH_EPSILON:
    
        STX $2F
    
    BRANCH_ZETA:
    
        LDA $22 : SUB $53 : BPL BRANCH_THETA
        
        EOR.b #$FF : INC A
    
    BRANCH_THETA:
    
        BNE BRANCH_MU
        
        REP #$20
        
        JSL $02921A ; $1121A IN ROM
        
        SEP #$20
        
        LDA $7EF3CC : BEQ BRANCH_IOTA
        
        JSL Tagalong_Init
    
    BRANCH_IOTA:
    
        LDA.b #-8 : STA $00
        LDA.b #-1 : STA $01
        
        LDA $0462 : AND.b #$04 : BNE BRANCH_KAPPA
        
        LDA.b #$0C : STA $00
                     STZ $01
    
    BRANCH_KAPPA:
    
        REP #$20
        
        LDA $22 : ADD $00 : STA $53
        
        SEP #$20
        
        LDA.b #$01 : STA $030A
        
        LDA.b #$06 : STA $0378
        
        ; See if this is a downward staircase
        LDA $0462 : AND.b #$04 : BNE BRANCH_LAMBDA
        ; Yes...
        
        LDA.b #$17 ; Play the up staircase sound.
        
        JSR $8028 ; Play a sound. (maybe the staircase steps sound?)
        
        BRA BRANCH_MU
    
    BRANCH_LAMBDA: ; Yep, downward staircase
    
        LDA.b #$19
        
        JSR $8028 ; Play a sound. (also a staircase step sound presumably)
    
    BRANCH_MU:
    
        SEP #$20
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F391-$3F3F2 LONG
    {
        ; \task Name this routine. Used by spiral staircases.
        
        PHB : PHK : PLB
        
        STZ $0373
        STZ $46
        STZ $4D
        STZ $037B
        
        REP #$20
        
        LDA $22 : STA $0FC2
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        DEC $0378 : BPL BRANCH_ALPHA
        
        STZ $0378
        
        ; Force player to look down after an amount of time?
        LDA.b #$02 : STA $2F
    
    BRANCH_ALPHA:
    
        LDA.b #0 : STA $27
        
        LDA.b #4 : STA $28
        
        LDA $0462 : AND.b #$04 : BEQ BRANCH_BETA
        
        LDA.b #2 : STA $27
        
        LDA.b #-4 : STA $28
    
    BRANCH_BETA:
    
        LDA $030A : CMP.b #$02 : BNE BRANCH_GAMMA
        
        LDA.b #16 : STA $27
        
        STZ $28
    
    BRANCH_GAMMA:
    
        JSL $07E370 ; $3E370 IN ROM
        JSL $07E704 ; $3E704 IN ROM
        
        LDA $22 : CMP $53 : BNE BRANCH_DELTA
        
        LDA.b #$02 : STA $030A
    
    BRANCH_DELTA:
    
        SEP #$20
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F3F3-$3F3FC LONG
    {
        ; \task Name this routine. It apparently has something to do with
        ; staircases, possibly spiral staircases in particular.
        
        ; \optimize Setting B register unnecessary. In fact, this whole call
        ; could probably just be inlined at the call site, unless they can't
        ; spare an extra byte at the site.
        PHB : PHK : PLB
        
        LDA.b #$07 : STA $0371
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $3F3FD-$3F42E LONG
    {
        ; \unused Pretty certain this is unused
        ; \task What would it be for, though? Looks like staircases. Hard to say
        ; if it's just unfinished / broken or if uninteresting...
        
        PHB : PHK : PLB
        
        REP #$20
        
        LDA $22 : STA $0FC2
        LDA $20 : STA $0FC4
        
        SEP #$20
        
        STZ $28
        
        LDY.b #$08
        
        LDA $11 : CMP.b #$12 : BNE .alpha
        
        LDY.b #$FE
        
        LDA $0462 : AND.b #$04 : BEQ .alpha
        
        LDY.b #$FA
    
    .alpha
    
        STY $27
        
        JSL $07E370 ; $3E370 in rom.
        JSL $07E704 ; $3E704 in rom.
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F42F-$3F438 LONG
    {
        PHB : PHK : PLB
        
        PHX
        
        JSR $E8F0 ;  $3E8F0 IN ROM
        
        PLX : PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F439-$3F46E LONG
    Player_IsScreenTransitionPermitted:
    {
        PHB : PHK : PLB
        
        LDA $5D
        
        CMP.b #$03 : BEQ .takeNoAction
        CMP.b #$08 : BEQ .takeNoAction
        CMP.b #$09 : BEQ .takeNoAction
        CMP.b #$0A : BEQ .takeNoAction
        
        ; Is Link recovering from being damaged / bounced back?
        LDA $46 : BEQ .actionIsPermitted
    
    .takeNoAction
    
        STZ $27
        STZ $28
        
        LDA.b #$03 : STA $02C6
        
        REP #$20
        
        LDA $0FC2 : STA $22
        LDA $0FC4 : STA $20
        
        SEP #$20
        
        SEC
        
        PLB
        
        RTL
    
    .actionIsPermitted
    
        CLC
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F46F-$3F49B LONG
    Tagalong_CanWeDisplayMessage:
    {
        ; Is link in his basic game state?
        LDA $5D
        
        CMP.b #$00 : BEQ .affirmative
        CMP.b #$04 : BEQ .affirmative
        CMP.b #$11 : BNE .negative
    
    .affirmative
    
        ; If the player has a sword and holds B.
        LDA $3A : AND.b #$80
        
        ORA $0377 ; Don't know.
        ORA $0301 ; Player is using Ice/Fire Rod, Hammer 
        ORA $037A ; Link is an odd position. (praying, etc)
        ORA $02EC ; Don't know.
        ORA $0314 ; Don't know.
        ORA $0308 ; Player is holding a pot.
        ORA $0376 ; Bit 0: Holding a wall. Bit 1: ????
        
        BNE .negative
        
        SEC ; Indicates TRUE
        
        RTL
    
    .negative
    
        CLC ; Indicates FALSE.
        
        RTL
    }

; ==============================================================================

    ; *$3F49C-$3F4CF LONG
    Player_ApproachTriforce:
    {
        ; \optimize No local data is used, so we don't have to do this.
        PHB : PHK : PLB
        
        LDA $20 : CMP.b #$98 : BCC .at_triforce_position
                  CMP.b #$A9 : BCS .not_on_stairs
        
        ; Use slower movement for player because they're moving on stairs.
        ; Or rather, this simulates moving on stairs.
        LDA.b #$14 : STA $5E
    
    .not_on_stairs
    
        LDA.b #$08 : STA $67
                     STA $26
        
        STZ $2F
        
        LDA.b #$40 : STA $3D
        
        BRA .return
    
    .at_triforce_position
    
        STZ $2E
        STZ $67
        STZ $26
        
        DEC $3D
        
        ; \optimize The decrement instruction above already sets flags, so
        ; no need to load this var here.
        LDA $3D : BNE .delay_triforce_hold
        
        LDA.b #$02 : STA $02DA
        
        INC $B0
    
    .delay_triforce_hold
    .return

        PLB
        
        RTL
    }

; ==============================================================================

    ; *$3F4D0-$3F4F0 LONG
    Sprite_CheckIfPlayerPreoccupied:
    {
        PHX
        
        LDA $4D : ORA $02DA : BNE .fail
        
        LDA $0308 : AND.b #$80 : BNE .fail
        
        LDX.b #$04
    
    .next_object
    
        ; Check to see if a the flute bird is in play. If it is, return failure
        LDA $0C4A, X : CMP.b #$27 : BEQ .fail
        
        DEX : BPL .next_object
        
        ; Success
        PLX
        
        CLC
        
        RTL
    
    .fail
    
        ; Failure
        PLX
        
        SEC
        
        RTL
    }

; ==============================================================================

    ; *$3F4F1-$3F513 LONG
    Player_IsPipeEnterable:
    {
        LDX.b #$04
    
    .next_slot
    
        LDA $0C4A, X : CMP.b #$31 : BNE .not_byrna_ancilla
        
        STZ $037A
        STZ $50
        STZ $0C4A, X
        
        BRA .byrna_ancilla_terminated
    
    .not_byrna_ancilla
    
        DEX : BPL .next_slot
    
    .byrna_ancilla_terminated
    
        LDA $0308 : AND.b #$80 : ORA $4D : BNE .in_special_state
        
        CLC
        
        RTL
    
    .in_special_state
    
        SEC
        
        RTL
    }

; ==============================================================================

    ; *$3F514-$3F51C LOCAL
    {
        LDA $1B : BNE .indoors
        
        ; \task Find out why you'd only do this when outdoors...
        
        ; Caches a bunch of gameplay vars. I don't know why this is necessary
        ; during gameplay because this routine is surely time consuming.
        
        JSL Player_CacheStatePriorToHandler
    
    .indoors
    
        RTS
    }
   
; ==============================================================================

    ; $3F51D-$3F61C
    Overworld_SignText:
    {
        dw $00A7, $00A7, $0048, $0040, $0040, $00A7, $00A7, $00A7
        dw $00A7, $00A7, $003C, $0040, $0040, $00A7, $00A7, $003E
        dw $003D, $0049, $0042, $0042, $00A7, $00A7, $003F, $00B0
        dw $003B, $003B, $00A7, $003B, $003B, $0044, $00A7, $00A7
        dw $003B, $003B, $00A7, $003B, $003B, $0045, $00A7, $00A7
        dw $00A7, $00A7, $00A7, $00A7, $00A7, $0041, $00A7, $00A7
        dw $00A7, $00A7, $00A7, $0042, $00A7, $0046, $0046, $00A7
        dw $00A7, $00A7, $0047, $0043, $00A7, $0046, $0046, $00A7
        dw $00A7, $00A7, $00A7, $00A7, $00A7, $00A7, $00A7, $00A7
        dw $00A7, $00A7, $00A8, $00A7, $00A7, $00A7, $00A7, $00A9
        dw $00A7, $00AA, $00AB, $00A7, $00A7, $00A7, $00A7, $00B1
        dw $00AF, $00AF, $00A7, $00A7, $00A7, $00A7, $00A7, $00A7
        dw $00AF, $00AF, $00A7, $00A7, $00A7, $00AC, $00A7, $00A7
        dw $00A7, $00A7, $00A7, $00A7, $00A7, $00AD, $00A7, $00A7
        dw $00A7, $00A7, $00A7, $00A7, $00A7, $00A7, $00A7, $00A7
        dw $00A7, $00A7, $00A7, $00AE, $00A7, $00A7, $00A7, $00A7
    }

; ==============================================================================

    ; $3F61D-$3F89C
    Dungeon_SignText:
    {
        dw $00B4, $00B4, $00B4, $00C7, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00C4, $00B4
        dw $00BE, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B5
        dw $00B9, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00C5, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00BF, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B9, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00BA, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00BF, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00C0, $00B4, $00B4, $00B4, $00C6
        dw $00B4, $00B4, $00B4, $00B4, $00C0, $00B4, $00C2, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00BB
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00C1, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00C3, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00C3, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B8, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B5, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $0179, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
        dw $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4, $00B4
    }

; ==============================================================================

    ; $3F89D-$3FFFF NULL (Can be used for expansion)
    {
        fillbyte $FF
        
        fill $763
    }
    
; ==============================================================================
