
    namespace "HUD"

; ==============================================================================

    ; $6DB40-$6DB74 DATA
    {
    .bcd_for_display_bombs_maybe_arrows
        db $10, $15, $20, $25, $30, $35, $40, $50
        
        db $0A, $0F, $14, $19, $1E, $23, $28, $32
    }


; ==============================================================================
    
    ; *$6DB75-$6DB7E LONG
    RefillLogicLong:
    {
        PHB : PHK : PLB

        LDA $0200

        BEQ RefillLogic

        PLB

        RTL
    }
    
; =============================================

    ; *$6DB7F-$6DB91 LONG
    RefreshIconLong:
    {
        ; Similar to RebuildLong but it checks to see if
        ; our equipped item has changed state first.
    
        PHB : PHK : PLB

        JSR Equipment_SearchForEquippedItem
        JSR Equipment_UpdateHUD
        JSR Rebuild

        SEP #$30

        STZ $0200

        PLB

        RTL
    }

; =============================================

    ; *$6DB92-$6DD29 BRANCH LOCATION
    RefillLogic:    
    {
        ; check the refill magic indicator
        LDA $7EF373

        BEQ .doneWithMagicRefill

        ; Check the current magic power level we have.
        ; Is it full?
        LDA $7EF36E : CMP.b #$80

        BCC .magicNotFull
        
        ; If it is full, freeze it at 128 magic pts.
        ; And stop this refilling nonsense.
        LDA.b #$80 : STA $7EF36E
        LDA.b #$00 : STA $7EF373
        
        BRA .doneWithMagicRefill
    
    .magicNotFull
    
        LDA $7EF373 : DEC A : STA $7EF373
        LDA $7EF36E : INC A : STA $7EF36E
        
        ; if((frame_counter % 4) != 0) don't refill this frame
        LDA $1A : AND.b #$03 : BNE .doneWithMagicRefill
        
        ; Is this sound channel in use?
        LDA $012E : BNE .doneWithMagicRefill
        
        ; Play the magic refill sound effect
        LDA.b #$2D : STA $012E
    
    .doneWithMagicRefill
    
        REP #$30
        
        ; Check current rupees (362) against goal rupees (360)
        ; goal refers to how many we really have and current refers to the
        ; number currently being displayed. When you buy something,
        ; goal rupees are decreased by, say, 100, but it takes a while for the 
        ; current rupees indicator to catch up. When you get a gift of 300
        ; rupees, the goal increases, and current has to catch up in the other direction.
        LDA $7EF362
        
        CMP $7EF360 : BEQ .doneWithRupeesRefill
                      BMI .addRupees
        DEC A       : BPL .subtractRupees
        
        LDA.w #$0000 : STA $7EF360
        
        BRA .subtractRupees
    
    .addRupees
    
        ; If current rupees <= 1000 (decimal)
        INC A : CMP.w #1000 : BCC .subtractRupees
        
        ; Otherwise just store 999 to the rupee amount
        LDA.w #999 : STA $7EF360
    
    .subtractRupees
    
        STA $7EF362
        
        SEP #$30
        
        LDA $012E : BNE .doneWithRupeesRefill
        
        ; looks like a delay counter of some sort between
        ; invocations of the rupee fill sound effect
        LDA $0CFD : INC $0CFD : AND.b #$07 : BNE .skipRupeeSound
        
        LDA.b #$29 : STA $012E
    
        BRA .skipRupeeSound
    
    .doneWithRupeesRefill
    
        SEP #$30
        
        STZ $0CFD
    
    .skipRupeeSound
    
        LDA $7EF375

        BEQ .doneRefillingBombs

        ; decrease the bomb refill counter
        LDA $7EF375 : DEC A : STA $7EF375

        ; use the bomb upgrade index to know what max number of bombs Link can carry is
        LDA $7EF370 : TAY

        ; if it matches the max, you can't have no more bombs, son. It's the law.
        LDA $7EF343 : CMP $DB48, Y : BEQ .doneRefillingBombs
        
        ; You like bombs? I got lotsa bombs!
        INC A : STA $7EF343

    .doneRefillingBombs

        ; check arrow refill counter
        LDA $7EF376
        
        BEQ .doneRefillingArrows
        
        LDA $7EF376 : DEC A : STA $7EF376
        
        ; check arrow upgrade index to see how our max limit on arrows, just like bombs.
        LDA $7EF371 : TAY 
        
        LDA $7EF377 : CMP $DB58, Y
        
        ; I reckon you get no more arrows, pardner.
        BEQ .arrowsAtMax
        
        INC A : STA $7EF377

    .arrowsAtMax

        ; see if we even have the bow.
        LDA $7EF340
        
        BEQ .doneRefillingArrows
        
        AND.b #$01 : CMP.b #$01
        
        BNE .doneRefillingArrows
        
        ; changes the icon from a bow without arrows to a bow with arrows.
        LDA $7EF340 : INC A : STA $7EF340
        
        JSL RefreshIconLong

    .doneRefillingArrows

        ; a frozen Link is an impervious Link, so don't beep.
        LDA $02E4
        
        BNE .doneWithWarningBeep
        
        ; if heart refill is in process, we don't beep
        LDA $7EF372
        
        BNE .doneWithWarningBeep
        
        LDA $7EF36C : LSR #3 : TAX
        
        ; checking current health against capacity health to see
        ; if we need to put on that annoying beeping noise.
        LDA $7EF36D : CMP $DB60, X
        
        BCS .doneWithWarningBeep
        
        LDA $04CA
        
        BNE .decrementBeepTimer
        
        ; beep incessantly when life is low
        LDA $012E
        
        BNE .doneWithWarningBeep
        
        LDA.b #$20 : STA $04CA
        LDA.b #$2B : STA $012E
    
    .decrementBeepTimer
    
        ; Timer for the low life beep sound
        DEC $04CA

    .doneWithWarningBeep

        ; if nonzero, indicates that a heart is being "flipped" over
        ; as in, filling up, currently
        LDA $020A
        
        BNE .waitForHeartFillAnimation
        
        ; If no hearts need to be filled, branch
        LDA $7EF372
        
        BEQ .doneRefillingHearts
        
        ; check if actual health matches capacity health
        LDA $7EF36D : CMP $7EF36C
        
        BCC .notAtFullHealth
        
        ; just set health to full in the event it overflowed past 0xA0 (20 hearts)
        LDA $7EF36C : STA $7EF36D
        
        ; done refilling health so deactivate the health refill variable
        LDA.b #$00 : STA $7EF372
        
        BRA .doneRefillingHearts

    .notAtFullHealth

        ; refill health by one heart
        LDA $7EF36D : ADD.b #$08 : STA $7EF36D
        
        LDA $012F
        
        BNE .soundChannelInUse
        
        ; play heart refill sound effect
        LDA.b #$0D : STA $012F

    .soundChannelInUse

        ; repeat the same logic from earlier, checking if health's at max and setting it to max
        ; if it overflowed
        LDA $7EF36D : CMP $7EF36C
        
        BCC .healthDidntOverflow
        
        LDA $7EF36C : STA $7EF36D

    .healthDidntOverflow

        ; subtract a heart from the refill variable
        LDA $7EF372 : SUB.b #$08 : STA $7EF372
        
        ; activate heart refill animation
        ; (which will cause a small delay for the next heart if we still need to fill some up.)
        INC $020A
        
        LDA.b #$07 : STA $0208

    .waitForHeartFillAnimation
    
        REP #$30
        
        LDA.w #$FFFF : STA $0E
        
        JSR Update_ignoreHealth
        JSR AnimateHeartRefill
        
        SEP #$30
        
        INC $16
        
        PLB
        
        RTL

    .doneRefillingHearts

        REP #$30
        
        LDA.w #$FFFF : STA $0E
        
        JSR Update_ignoreItemBox
        
        SEP #$30
        
        INC $16
        
        PLB
        
        RTL
    } 

; =============================================
    
    namespace off
    
; =============================================
    
    incsrc "equipment.asm"
    
; =============================================

    namespace "HUD"

; =============================================

    ; *$6F0F7-$6F127 LOCAL
    HexToDecimal:
    {
        ; This apparently is a hex to decimal converter for use with displaying numbers
        ; It's obviously slower with larger numbers... should find a way to speed it up. (already done)
        
        REP #$30
        
        STZ $0003
        
        ; The objects mentioned could be rupees, arrows, bombs, or keys.
        LDX.w #$0000
        LDY.w #$0002
    
    .nextDigit
    
        ; If number of objects left < 100, 10
        CMP $F9F9, Y : BCC .nextLowest10sPlace
        
        ; Otherwise take off another 100 objects from the total and increment $03
        ; $6F9F9, Y THAT IS, 100, 10
        SUB $F9F9, Y
        INC $03, X
        
        BRA .nextDigit
    
    .nextLowest10sPlace
    
        INX : DEY #2
        
        ; Move on to next digit (to the right)
        BPL .nextDigit
        
        ; Whatever is left is obviously less than 10, so store the digit at $05.
        STA $05
        
        SEP #$30
        
        ; Go through at most three digits.
        LDX.b #$02
    
    ; Repeat for all three digits.
    .setNextDigitTile
    
        ; Load each digit's computed value
        LDA $03, X : CMP.b #$7F
        
        BEQ .blankDigit
    
        ; #$0-9 -> #$90-#$99
        ORA.b #$90
    
    .blankDigit
    
        ; A blank digit.
        STA $03, X
        
        DEX : BPL .setNextDigitTile
        
        RTS
    }

; =============================================

    ; *$6F128-$6F14E LONG
    RefillHealth:
    {
        ; Check goal health versus actual health.
        ; if(actual < goal) then branch.
        LDA $7EF36D : CMP $7EF36C : BCC .refillAllHealth
        
        LDA $7EF36C : STA $7EF36D
        
        LDA.b #$00 : STA $7EF372
        
        ; ??? not sure what purpose this branch serves.
        LDA $020A : BNE .beta
        
        SEC
        
        RTL
    
    .refillAllHealth
    
        ; Fill up ze health.
        LDA.b #$A0 : STA $7EF372
    
    .beta
    
        CLC
        
        RTL
    }

; =============================================

    ; *$6F14F-$6F1B2 LOCAL
    AnimateHeartRefill:
    {
        SEP #$30
        
        ; $00[3] = $7EC768 (wram address of first row of hearts in tilemap buffer)
        LDA.b #$68 : STA $00
        LDA.b #$C7 : STA $01
        LDA.b #$7E : STA $02
        
        DEC $0208 : BNE .return
        
        REP #$30
        
        ; Y = ( ( ( (current_health & 0x00F8) - 1) / 8 ) * 2)
        LDA $7EF36D : AND.w #$00F8 : DEC A : LSR #3 : ASL A : TAY : CMP.w #$0014
        
        BCC .halfHealthOrLess
        
        SBC.w #$0014 : TAY
        
        ; $00[3] = $7EC7A8 (wram address of second row of hearts)
        LDA $00 : ADD.w #$0040 : STA $00

    .halfHealthOrless

        SEP #$30
        
        LDX $0209 : LDA $0DFA11, X : STA $0208
        
        TXA : ASL A : TAX
        
        LDA $0DFA09, X : STA [$00], Y
        
        INY : LDA $0DFA0A, X : STA [$00], Y
        
        LDA $0209 : INC A : AND.b #$03 : STA $0209
        
        BNE .return
        
        SEP #$30
        
        JSR Rebuild
        
        STZ $020A

    .return

        CLC
        
        RTS
    } 

; =============================================

    ; *$6F1B3-$6F1C8 LONG
    RefillMagicPower:
    {
        SEP #$30
        
        ; Check if Link's magic meter is full
        LDA $7EF36E : CMP.b #$80
        
        BCS .itsFull
        
        ; Tell the magic meter to fill up until it's full.
        LDA.b #$80 : STA $7EF373
        
        SEP #$30
        
        RTL
    
    .itsFull
    
        ; Set the carry, signifying we're done filling it.
        SEP #$31
        
        RTL
    }

; ==============================================================================

    namespace off

; ==============================================================================

    ; $6F1C9 DATA
    {
        ; ??? how long?
    }

; ==============================================================================

    ; $6FA15
    {
        db $00
        
        db $03, $02, $0E, $01, $0A
        db $05, $06, $0F, $10, $11
        db $09, $04, $08, $07, $0C
        db $0B, $12, $0D, $13, $14
        
        ; not sure what these are used for, if anything...
    
    ; $6FA2A
    
        db $00, $01, $06, $02, $07
        db $03, $05, $04, $08
    }


; ==============================================================================

    ; *$6FA33-$6FA57 LONG
    RestoreTorchBackground:
    {
        ; See if we have the torch...
        LDA $7EF34A : BEQ .doNothing
        
        ; See if this room has the 'lights out' property.
        LDA $7EC005 : BEQ .doNothing
        
        ; The rest of these variables, I'm not too sure about. Probably indicate
        ; that a torch bg object was place in the dungeon room.
        LDA $0458 : BNE .doNothing
        
        LDA $045A : BNE .doNothing
        
        INC $0458
        
        LDA $0414 : CMP.b #$02 : BEQ .doNothing
        
        LDA.b #$01 : STA $1D
    
    .doNothing
    
        RTL
    }
    
; ==============================================================================

    namespace "HUD"

; ==============================================================================

    ; *$6FA58-$6FA5F LONG
    RebuildLong:
    {
        PHB : PHK : PLB

        JSR Rebuild

        PLB

        RTL
    }

; ==============================================================================

    ; *$6FA60-$6FA6F LONG
    RebuildIndoor:
    {
        LDA.b #$00 : STA $7EC017
        
        LDA.b #$FF
    
    ; *$6FA68 ALTERNATE ENTRY POINT
    .palace
    
        ; When the dungeon loads, tells us how many keys we have.
        STA $7EF36F
    
    shared RebuildLong2:
    
        JSR Rebuild
        
        RTL
    }

; ==============================================================================

    ; *$6FA70-$6FA92 LOCAL
    Rebuild:
    {
        ; When the screen finishes transitioning from the menu to the main game screen
        ; this is called to refresh the HUD by drawing a template (some tiles are dynamic though)
        REP #$30
        
        PHB
        
        ; Preparing for the MVN transfer
        LDA.w #$0149
        LDX.w #.hud_tilemap
        LDY.w #$C700
        
        MVN $0D, $7E ; $Transfer 0x014A bytes from $6FE77 -> $7EC700
        
        PLB ; The above sets up a template for the status bar.
        
        PHB : PHK : PLB
        
        BRA .alpha
    
    ; *$6FA85 ALTERNATE ENTRY POINT
    .updateOnly
    
        REP #$30
        
        PHB : PHK : PLB
    
    .alpha
    
        JSR Update
        
        PLB
        
        SEP #$30
        
        INC $16 ; Indicate this shit needs drawing.
        
        RTS
    }

; ==============================================================================

    ; $6FA93-$6FAFC DATA
    {
        dw $F629, $F651, $F669, $F679, $F689, $F6A1, $F6B1, $F6C1
        dw $F6D1, $F6E1, $F6F1, $F701, $F711, $F731, $F741, $F751
        dw $F799, $F7A9, $F7B9, $F7C9, $F7E9, $F801, $F811, $F821
        dw $F831, $F839, $F861, $F881, $F751, $F751, $F751, $F751
        dw $F901
    
    ; $6FAD5
        dw $11C8, $11CE, $11D4, $11DA, $11E0, $1288, $128E, $1294
        dw $129A, $12A0, $1348, $134E, $1354, $135A, $1360, $1408
        dw $140E, $1414, $141A, $1420    
    }

; ==============================================================================

    ; *$6FAFD-$6FB90 LOCAL
    UpdateItemBox:
    {
        SEP #$30
        
        ; Dost thou haveth the the bow?
        LDA $7EF340 : BEQ .havethNoBow
        
        ; Dost thou haveth the silver arrows?
        ; (okay I'll stop soon)
        CMP.b #$03 : BCC .havethNoSilverArrows 
        
        ; Draw the arrow guage icon as silver rather than normal wood arrows.
        LDA.b #$86 : STA $7EC71E
        LDA.b #$24 : STA $7EC71F
        LDA.b #$87 : STA $7EC720
        LDA.b #$24 : STA $7EC721
        
        LDX.b #$04
        
        ; check how many arrows the player has
        LDA $7EF377 : BNE .drawBowItemIcon
        
        LDX.b #$03
        
        BRA .drawBowItemIcon
    
    .havethNoSilverArrows
    
        LDX.b #$02
        
        LDA $7EF377 : BNE .drawBowItemIcon
        
        LDX.b #$01
    
    .drawBowItemIcon
    
        ; values of X correspond to how the icon will end up drawn:
        ; 0x01 - normal bow with no arrows
        ; 0x02 - normal bow with arrows
        ; 0x03 - silver bow with no silver arrows
        ; 0x04 - silver bow with silver arrows
        TXA : STA $7EF340
    
    .havethNoBow
    
        REP #$30
        
        LDX $0202 : BEQ .noEquippedItem
        
        LDA $7EF33F, X : AND.w #$00FF
        
        CPX.w #$0004 : BNE .bombsNotEquipped
        
        LDA.w #$0001
        
    .bombsNotEquipped
    
        CPX.w #$0010 : BNE .bottleNotEquipped
        
        TXY : TAX : LDA $7EF35B, X : AND.w #$00FF : TYX
    
    .bottleNotEquipped
    
        STA $02
        
        TXA : DEC A : ASL A : TAX
        
        LDA $FA93, X : STA $04
        
        LDA $02 : ASL #3 : TAY
        
        ; These addresses form the item box graphics.
        LDA ($04), Y : STA $7EC74A : INY #2
        LDA ($04), Y : STA $7EC74C : INY #2
        LDA ($04), Y : STA $7EC78A : INY #2
        LDA ($04), Y : STA $7EC78C : INY #2
    
    .noEquippedItem
    
        RTS
    }

; =============================================

    ; *$6FB91-$6FCF9 LOCAL
    Update:
    {
        JSR UpdateItemBox
    
    ; *$6FB94 ALTERNATE ENTRY POINT
    .ignoreItemBox
    
        SEP #$30
        
        ; the hook for optimization was placed here...
        ; need to draw partial heart still though. update: optimization complete with great results
        LDA.b #$FD : STA $0A
        LDA.b #$F9 : STA $0B
        LDA.b #$0D : STA $0C
        
        LDA.b #$68 : STA $07
        LDA.b #$C7 : STA $08
        LDA.b #$7E : STA $09
        
        REP #$30
        
        ; Load Capacity health.
        LDA $7EF36C : AND.w #$00FF : STA $00 : STA $02 : STA $04
        
        ; First, just draw all the empty hearts (capacity health)
        JSR UpdateHearts
        
        SEP #$30
        
        LDA.b #$03 : STA $0A
        LDA.b #$FA : STA $0B
        LDA.b #$0D : STA $0C
        
        LDA.b #$68 : STA $07
        LDA.b #$C7 : STA $08
        LDA.b #$7E : STA $09
        
        ; Branch if at full health
        LDA $7EF36C : CMP $7EF36D : BEQ .healthUpdated
        
        ; Seems absurd to have a branch of zero bytes, right?
        SUB.b #$04 : CMP $7EF36D : BCS .healthUpdated
    
    .healthUpdated
    
        ; A = actual health + 0x03;
        LDA $7EF36D : ADD.b #$03
        
        REP #$30
        
        AND.w #$00FC : STA $00 : STA $04
        
        LDA $7EF36C : AND.w #$00FF : STA $02
        
        ; this time we're filling in the full and partially filled hearts (actual health)
        JSR UpdateHearts
    
    ; *$6FC09 ALTERNATE ENTRY POINT ; reentry hook
    .ignoreHealth
    
        REP #$30
        
        ; Magic amount indicator (normal, 1/2, or 1/4)
        LDA $7EF37B : AND.w #$00FF : CMP.w #$0001 : BCC .normalMagicMeter
        
        ; draws a 1/2 magic meter (note, we could add in the 1/4 magic meter here if 
        ; we really cared about that >_>
        LDA.w #$28F7 : STA $7EC704
        LDA.w #$2851 : STA $7EC706
        LDA.w #$28FA : STA $7EC708
    
    .normalMagicMeter
    
        ; check how much magic power the player has at the moment (ranges from 0 to 0x7F)
        ; X = ((MP & 0xFF)) + 7) & 0xFFF8)
        LDA $7EF36E : AND.w #$00FF : ADD.w #$0007 : AND.w #$FFF8 : TAX
        
        ; these four writes draw the magic power bar based on how much MP you have    
        LDA .mp_tilemap+0, X : STA $7EC746
        LDA .mp_tilemap+2, X : STA $7EC786
        LDA .mp_tilemap+4, X : STA $7EC7C6
        LDA .mp_tilemap+6, X : STA $7EC806
        
        ; Load how many rupees the player has
        LDA $7EF362
        
        JSR HexToDecimal
        
        REP #$30
        
        ; The tile index for the first rupee digit
        LDA $03 : AND.w #$00FF : ORA.w #$2400 : STA $7EC750
        
        ; The tile index for the second rupee digit
        LDA $04 : AND.w #$00FF : ORA.w #$2400 : STA $7EC752
        
        ; The tile index for the third rupee digit
        LDA $05 : AND.w #$00FF : ORA.w #$2400 : STA $7EC754
        
        ; Number of bombs Link has.
        LDA $7EF343 : AND.w #$00FF
        
        JSR HexToDecimal
        
        REP #$30
        
        ; The tile index for the first bomb digit
        LDA $04 : AND.w #$00FF : ORA.w #$2400 : STA $7EC758
        
        ; The tile index for the second bomb digit
        LDA $05 : AND.w #$00FF : ORA.w #$2400 : STA $7EC75A
        
        ; Number of Arrows Link has.
        LDA $7EF377 : AND.w #$00FF
        
        ; converts hex to up to 3 decimal digits
        JSR HexToDecimal
        
        REP #$30
        
        ; The tile index for the first arrow digit    
        LDA $04 : AND.w #$00FF : ORA.w #$2400 : STA $7EC75E
        
        ; The tile index for the second arrow digit   
        LDA $05 : AND.w #$00FF : ORA.w #$2400 : STA $7EC760
        
        LDA.w #$007F : STA $05
        
        ; Load number of Keys Link has
        LDA $7EF36F : AND.w #$00FF : CMP.w #$00FF : BEQ .noKeys
        
        JSR HexToDecimal
    
    .noKeys
    
        REP #$30
        
        ; The key digit, which is optionally drawn.
        ; Also check to see if the key spot is blank
        LDA $05 : AND.w #$00FF : ORA.w #$2400 : STA $7EC764
        
        CMP.w #$247F : BNE .dontBlankKeyIcon
        
        ; If the key digit is blank, also blank out the key icon.
        STA $7EC724
    
    .dontBlankKeyIcon
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6FDAB-$6FDEE LOCAL
    UpdateHearts:
    {
        ; Draws hearts in a painfully slow loop
        ; I used DMA to speed it up in my custom code
        ; (but still needs fixing to work on 1/1/1 hardware)
        
        LDX.w #$0000
    
    .nextHeart
    
        LDA $00 : CMP.w #$0008 : BCC .lessThanOneHeart
        
        ; Notice no SEC was needed since carry is assumedly set.
        SBC.w #$0008 : STA $00
        
        LDY.w #$0004
        
        JSR .drawHeart
        
        INX #2
        
        BRA .nextHeart
    
    .lessThanOneHeart
    
        CMP.w #$0005 : BCC .halfHeartOrLess
        
        LDY.w #$0004
        
        BRA .drawHeart
    
    .halfHeartOrLess
    
        CMP.w #$0001 : BCC .emptyHeart
        
        LDY.w #$0002
        
        BRA .drawHeart
    
    .emptyHeart
    
        RTS
    
    .drawHeart
    
        ; Compare number of hearts so far on current line to 10
        CPX.w #$0014 : BCC .noLineChange
        
        ; if not, we have to move down one tile in the tilemap
        LDX.w #$0000
        
        LDA $07 : ADD.w #$0040 : STA $07
    
    .noLineChange
    
        LDA [$0A], Y : TXY : STA [$07], Y
        
        RTS
    }

; ==============================================================================

    ; $6FDEF-$6FE76 DATA
    pool Update:
    {
    
    .mp_tilemap
        dw $3CF5, $3CF5, $3CF5, $3CF5
        dw $3CF5, $3CF5, $3CF5, $3C5F
        dw $3CF5, $3CF5, $3CF5, $3C4C
        dw $3CF5, $3CF5, $3CF5, $3C4D
        dw $3CF5, $3CF5, $3CF5, $3C4E
        dw $3CF5, $3CF5, $3C5F, $3C5E
        dw $3CF5, $3CF5, $3C4C, $3C5E
        dw $3CF5, $3CF5, $3C4D, $3C5E
        dw $3CF5, $3CF5, $3C4E, $3C5E
        dw $3CF5, $3C5F, $3C5E, $3C5E
        dw $3CF5, $3C4C, $3C5E, $3C5E
        dw $3CF5, $3C4D, $3C5E, $3C5E
        dw $3CF5, $3C4E, $3C5E, $3C5E
        dw $3C5F, $3C5E, $3C5E, $3C5E
        dw $3C4C, $3C5E, $3C5E, $3C5E
        dw $3C4D, $3C5E, $3C5E, $3C5E
        dw $3C4E, $3C5E, $3C5E, $3C5E    
    }

; ==============================================================================

    ; $6FE77-$6FFC0
    pool Rebuild:
    {
    
    .hud_tilemap
        dw $207F, $207F, $2850, $A856
        dw $2852, $285B, $285B, $285C
        dw $207F, $3CA8, $207F, $207F
        dw $2C88, $2C89, $207F, $20A7
        dw $20A9, $207F, $2871, $207F
        dw $207F, $207F, $288B, $288F
        dw $24AB, $24AC, $688F, $688B
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $2854, $2871
        dw $2858, $207F, $207F, $285D
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $2854, $304E
        dw $2858, $207F, $207F, $285D
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $2854, $305E
        dw $2859, $A85B, $A85B, $A85C
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $2854, $305E
        dw $6854, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $207F, $207F
        dw $207F, $207F, $A850, $2856
        dw $E850
    }

; ==============================================================================

    ; $6FFC1-$6FFFF NULL
    {
        padbyte $FF
        
        pad $0E8000
    
    }

; ==============================================================================

    namespace off
