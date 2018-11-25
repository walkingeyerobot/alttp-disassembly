

; ==============================================================================

    ; *$6DD2A-$6DD31 JUMP LOCATION
    Messaging_Equipment:
    {
        ; Module E submodule 1 (Item submenu)
        
        PHB : PHK : PLB
        
        JSR Equipment_Local
        
        PLB
        
        RTL
    }

    ; start of namespace
    namespace "Equipment_"

; ==============================================================================

    ; *$6DD32-$6DD35 LONG
    UpdateEquippedItemLong:
    {
        JSR UpdateHUD_updateEquippedItem
        
        RTL
    }

; ==============================================================================
    
    ; *$6DD36-$6DD59 LOCAL
    Local:
    {
        ; Appears to be a simple debug frame counter (8-bit) for this submodule
        ; Of course, it loops back every 256 frames
        INC $0206
        
        LDA $0200
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw ClearTilemap       ; $DD5A = $6DD5A*
        dw Init               ; $DDAB = $6DDAB*
        dw BringMenuDown      ; $DE59 = $6DE59*
        dw ChooseNextMode     ; $DE6E = $6DE6E*
        dw NormalMenu         ; $DF15 = $6DF15*
        dw UpdateHUD          ; $DFA9 = $6DFA9*
        dw CloseMenu          ; $DFBA = $6DFBA*
        dw GotoBottleMenu     ; $DFFB = $6DFFB*
        dw InitBottleMenu     ; $E002 = $6E002*
        dw ExpandBottleMenu   ; $E08C = $6E08C*
        dw BottleMenu         ; $E0DF = $6E0DF*
        dw EraseBottleMenu    ; $E2FD = $6E2FD*
        dw RestoreNormalMenu  ; $E346 = $6E346*
    }

; ==============================================================================

    ; *$6DD5A-$6DDAA JUMP LOCATION
    ClearTilemap:
    {
        ; This routine sets up a DMA transfer from
        ; $7E1000 to $6800 (word address) in VRAM
        ; Basically clears out
        ; Also plays the menu coming down sound, then moves to the next step
        
        REP #$20
        
        LDX.b #$00
        
        ; value of a transparent tile
        LDA.b #$207F
    
    .clearVramBuffer
    
        STA $1000, X : STA $1080, X
        STA $1100, X : STA $1180, X
        STA $1200, X : STA $1280, X
        STA $1300, X : STA $1380, X
        STA $1400, X : STA $1480, X
        STA $1500, X : STA $1580, X
        STA $1600, X : STA $1680, X
        STA $1700, X : STA $1780, X
        
        INX #2 : CPX.b #$80
        
        BNE .clearVramBuffer
        
        SEP #$20
        
        ; play sound effect for opening item menu
        LDA.b #$11 : STA $012F
        
        ; tell NMI to update tilemap
        LDA.b #$01 : STA $17
        
        ; the region of tilemap to update is word address $6800 (this value 0x22 indexes into a table in NMI)
        LDA.b #$22 : STA $0116
        
        ; move to next step of the submodule
        INC $0200
        
        RTS
    }

; ==============================================================================
    
    ; *$6DDAB-$6DE58 JUMP LOCATION
    Init:
    {
        ; Module 0x0E.0x01.0x01
        
        JSR CheckEquippedItem ; $6E399 IN ROM; Handles which item to equip (if none is equipped)
        
        LDA.b #$01
        
        JSR GetPaletteMask ; $00[2] = 0xFFFF
        JSR DrawYButtonItems
        
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawUknownBox ; $6E647 IN ROM; Construct a portion of the menu.
        
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawAbilityText 
        JSR DrawAbilityIcons 
        JSR DrawProgressIcons
        JSR DrawMoonPearl
        JSR UnfinishedRoutine
        
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawEquipment
        JSR DrawShield
        JSR DrawArmor
        JSR DrawMapAndBigKey
        JSR DrawCompass
        
        LDX.b #$12
        
        LDA $7EF340
    
    ; check if we have any equippable items available
    .itemCheck
    
        ORA $7EF341, X : DEX
        
        BPL .itemCheck
        
        CMP.b #$00
        
        BEQ .noEquipableItems
        
        LDA $7EF35C : ORA $7EF35D : ORA $7EF35E : ORA $7EF35F
        
        BNE .haveBottleItems
        
        BRA .haveNoBottles
    
    .haveBottleItems
    
        LDA $7EF34F
        
        ; There is a difference between having bottled items and having 
        ; at least one bottle to put them in. $7EF34F acts as a flag for that.
        BNE .hasBottleFlag
        
        TAY
        
        INY
        LDA $7EF35C
        
        BNE .selectThisBottle
        
        INY
        LDA $7EF35D
        
        BNE .selectThisBottle
        
        INY
        LDA $7EF35E
        
        BNE .selectThisBottle
        
        INY
    
    .selectThisBottle
    
        TYA
    
    .haveNoBottles
    
        STA $7EF34F
    
    .hasBottleFlag
    
        JSR DoWeHaveThisItem
        
        BCS .weHaveIt
        
        JSR TryEquipNextItem
    
    .weHaveIt
    
        JSR DrawSelectedYButtonItem
        
        ; Does the player have a bottle equipped currently?
        LDA $0202 : CMP.b #$10
        
        BNE .equippedItemIsntBottle
        
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawBottleMenu
    
    .equippedItemIsntBottle
    .noEquipableItems
    
        ; Start a timer
        LDA.b #$10 : STA $0207
        
        ; Make NMI update BG3 tilemap
        LDA.b #$01 : STA $17
        
        ; update vram address $6800 (word)
        LDA.b #$22 : STA $0116
        
        ; move on to next step of the submodule
        INC $0200
        
        RTS
    }

; ==============================================================================

    ; *$6DE59-$6DE6D JUMP LOCATION
    BringMenuDown:
    {
        REP #$20
        
        LDA $EA : SUB.w #$0008 : STA $EA : CMP.w #$FF18
        
        SEP #$20
        
        BNE .notDoneScrolling
        
        INC $0200
    
    .notDoneScrolling
    
        RTS
    }
    
; ==============================================================================

    ; *$6DE6E-$6DEAF JUMP LOCATION
    ChooseNextMode:
    {
        ; Makes a determination whether to go to the normal menu handling mode
        ; or the bottle submenu handling mode.
        ; there's also mode 0x05... which appears to be hidden at this point.
        
        LDX.b #$12
        
        LDA $7EF340
    
    .haveAnyEquippable
    
        ORA $7EF341, X : DEX : BPL .haveAnyEquippable
        
        CMP.b #$00 : BEQ .haveNone
        
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
        
        JSR DoWeHaveThisItem : BCS .weHaveIt
        
        JSR TryEquipNextItem
    
    .weHaveIt
    
        JSR DrawSelectedYButtonItem
        
        ; Move to the next step of the submodule
        LDA.b #$04 : STA $0200
        
        LDA $0202 : CMP.b #$10 : BNE .notOnBottleMenu
        
        ; switch to the step of this submodule that handles when the
        ; bottle submenu is up
        LDA.b #$0A : STA $0200
    
    .notOnBottleMenu
    
        RTS
    
    .haveNone
    
        ; BYSTudlr
        LDA $F4 : BEQ .noButtonPress
        
        LDA.b #$05 : STA $0200
        
        RTS
    
    .noButtonPress
    
        RTS
    }

; ==============================================================================

    ; *$6DEB0-$6DEBC LOCAL
    DoWeHaveThisItem:
    {
        LDX $0202
        
        ; Check to see if we have this item...
        LDA $7EF33F, X
        
        BNE .haveThisItem
        
        CLC
        
        RTS
    
    .haveThisItem
    
        SEC
        
        RTS
    }

; ==============================================================================
    
    ; *$6DEBD-$6DECA LOCAL
    GoToPrevItem:
    {
        LDA $0202 : DEC A : CMP.b #$01 : BCS .dontReset
        
        LDA.b #$14
    
    .dontReset
    
        STA $0202
        
        RTS
    } 

; ==============================================================================
    
    ; *$6DECB-$6DED8 LOCAL
    GotoNextItem:
    {
        ; Load our currently equipped item, and move to the next one
        ; If we reach our limit (21), set it back to the bow and arrow slot.
        LDA $0202 : INC A : CMP.b #$15 : BCC .dontReset
        
        LDA.b #$01
    
    .dontReset
    
        ; Otherwise try to equip the item in the next slot
        STA $0202
        
        RTS
    }

; ==============================================================================
    
    ; *$6DED9-$6DEE1 LOCAL
    TryEquipPrevItem:
    {
    
    .keepLooking
    
        JSR GoToPrevItem
        
        JSR DoWeHaveThisItem : BCC .keepLooking
        
        RTS
    } 

; ==============================================================================
    
    ; *$6DEE2-$6DEEA JUMP LOCATION
    TryEquipNextItem:
    {
    
    .keepLooking
    
        JSR GoToNextItem
        
        JSR DoWeHaveThisItem : BCC .keepLooking
        
        RTS
    }

; ==============================================================================
    
    ; *$6DEEB-$6DEFF LOCAL
    TryEquipItemAbove:
    {
    
    .keepLooking
    
        JSR GoToPrevItem
        JSR GoToPrevItem
        JSR GoToPrevItem
        JSR GoToPrevItem
        JSR GoToPrevItem
        
        JSR DoWeHaveThisItem : BCC .keepLooking
        
        RTS
    } 

; ==============================================================================

    ; *$6DF00-$6DF14 LOCAL
    TryEquipItemBelow:
    {
    
    .keepLooking
    
        JSR GoToNextItem
        JSR GoToNextItem
        JSR GoToNextItem
        JSR GoToNextItem
        JSR GoToNextItem
        
        JSR DoWeHaveThisItem : BCC .keepLooking
        
        RTS
    }

; ==============================================================================

    ; *$6DF15-$6DFA8 JUMP LOCATION
    NormalMenu:
    {
        INC $0207
        
        ; BYSTudlr
        LDA $F0 : BNE .inputReceived
        
        ; Reset the ability to select a new item
        STZ $BD
    
    .inputReceived
    
        ; check if the start button was pressed this frame
        LDA $F4 : AND.b #$10 : BEQ .dontLeaveMenu
        
        ; bring the menu back up and play the vvvvoooop sound as it comes up.
        LDA.b #$05 : STA $0200
        LDA.b #$12 : STA $012F
        
        RTS
    
    .dontLeaveMenu
    
        ; After selecting a new item, you have to release all of the BYSTudlr inputs
        ; before you can select a new item. Notice how $BD gets set back low if you
        ; aren't holding any of those buttons.
        LDA $BD : BNE .didntChange
        
        LDA $0202 : STA $00
        
        ; Joypad 2.... interesting. It's checking the R button.
        LDA $F7 : AND.b #$10 : BEQ .dontBeAJackass
        
        ; Apparently pressing R on Joypad 2 (if it's enabled) deletes your currently selected item.
        ; Imagine playing the game with your friend constantly trying to delete your items
        ; Lots of punching would ensue.
        LDX $0202 
        
        LDA.b #$00 : STA $7EF33F, X
        
        ; unlike .movingOut, Anthony's Song.
        BRA .movingOn
    
    .dontBeAJackass
    
        ; BYSTudlr says that we're checking if the up direction is pressed!!!!!! RAWWWWWWWRRRHHGHGH!!!!!
        ; BYSTudrl sounds like a name, like Baiyst Yudler, a German superbrute that hacks roms by breaking them in two!!!!
        ; And then he breaks them into many other numbers bigger than two!!!!!
        LDA $F4 : AND.b #$08 : BEQ .notPressingUp
        
        JSR TryEquipItemAbove
        
        BRA .movingOn
    
    .notPressingUp
    
        ; Don't piss off BYSTudlr - he likes playing Mr. Potato Head.
        ; The problem is he skips the potato part and goes straight for the head.
        ; (In spite of this, I find most of his work quite artistic and tasteful.)
        LDA $F4 : AND.b #$04 : BEQ .notPressingDown
        
        JSR TryEquipItemBelow
        
        BRA .movingOut
    
    .notPressingDown
    
        ; BYSTudlr is not going to pump you up, girly man. His sensibilities are far more refined than that.
        LDA $F4 : AND.b #$02 : BEQ .notPressingLeft
        
        JSR TryEquipPrevItem
        
        BRA .movingOn
    
    .notPressingLeft
    
        ; When BYSTudlr gets really hungry he makes chicken soup.
        ; Recipe (translated from German): Fill bathtub with chicken broth. Put chickens in tub. Eat.
        LDA $F4 : AND.b #$01 : BEQ .notPressingRight
        
        JSR TryEquipNextItem
    
    .notPressingRight
    
        LDA $F4 : STA $BD
        
        ; check if the currently equipped item changed
        LDA $0202 : CMP.b $00 : BEQ .didntChange
        
        ; Reset a timer and play a sound effect
        LDA.b #$10 : STA $0207
        LDA.b #$20 : STA $012F
    
    .didntChange
    
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawYButtonItems
        JSR DrawSelectedYButtonItem
        
        ; check if we ended up selecting a bottle this frame
        LDA $0202 : CMP.b #$10 : BNE .didntSelectBottle
        
        ; switch to the bottle submenu handler
        LDA.b #$07 : STA $0200
    
    .didntSelectBottle
    
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
        
        RTS
    }

; ==============================================================================

    ; *$6DFA9-$6DFB9 LOCAL
    UpdateHUD:
    {
        ; Move on to next step.
        INC $0200
        
        JSR HUD.Rebuild.updateOnly
        
    ; *$6DFAF ALTERNATE ENTRY POINT
    .updateEquippedItem
    
        ; Using the item selected in the item menu,
        ; set a value that tells us what item to use during actual
        ; gameplay. (Y button items, btw)
        LDX $0202 
        
        LDA $0DFA15, X : STA $0303
        
        RTS
    }

; ==============================================================================

    ; *$6DFBA-$6DFFA JUMP LOCATION
    CloseMenu:
    {
    
    .scroll_up_additional_8_pixels
    
        REP #$20
        
        ; Scroll the menu back up so it's off screen (8 pixels at a time)
        LDA $EA : ADD.w #$0008 : STA $EA : SEP #$20 : BNE .notDoneScrolling
        
        JSR HUD.Rebuild
        
        ; reset submodule and subsubmodule indices
        STZ $0200
        STZ $11
        
        ; Go back to the module we came from
        LDA $010C : STA $10
        
        ; Why this is checked, I dunno. notice the huge whopping STZ $11 up above? Yeah, I thought so.
        LDA $11 : BEQ .noSpecialSubmode
        
        ; This seems random and out of place. There's not even a check to make sure we're indoors.
        ; Unless that LDA $11 up above was meant to be LDA $1B
        
        JSL RestoreTorchBackground
    
    .noSpecialSubmode
    
        LDA $0303
        
        CMP.b #$05 : BEQ .fireRod
        CMP.b #$06 : BEQ .iceRod
        
        LDA.b #$02 : STA $034B
        
        STZ $020B
        
        BRA .return

    .fireRod
    .iceRod

        ; Okay, so contrary to what I thought this did previously in the
        ; abstract, it actually positions the HUD up by 8 pixels higher than
        ; it would normally be if you select one of the rods and this variable
        ; $020B is also set. That's it.
        LDA $020B : BNE .scroll_up_additional_8_pixels
        
        STZ $034B
    
    .notDoneScrolling
    .return
    
        RTS
    }

; ==============================================================================

    ; *$6DFFB-$6E001 JUMP LOCATION
    GotoBottleMenu:
    {
        STZ $0205
        INC $0200
        
        RTS
    } 

; ==============================================================================

    ; *$6E002-$6E04F JUMP LOCATION
    InitBottleMenu:
    {
        REP #$30
        
        LDA $0205 : AND.w #$00FF : ASL #6 : TAX
        
        LDA.w #$207F 
        STA $12EA, X : STA $12EC, X : STA $12EE, X : STA $12F0, X
        STA $12F2, X : STA $12F4, X : STA $12F6, X : STA $12F8, X
        STA $12FA, X : STA $12FC, X
        
        SEP #$30
        
        INC $0205
        
        LDA $0205 : CMP.b #$13 : BNE .notDoneErasing
        
        INC $0200
        
        LDA.b #$11 : STA $0205
    
    .notDoneErasing
    
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
        
        RTS
    }

; ==============================================================================

    ; $6E050-$6E08B DATA
    {
        dw $28FB, $28F9, $28F9, $28F9, $28F9
        dw $28F9, $28F9, $28F9, $28F9, $68FB
        
    ; $6E064
        
        dw $28FC, $24F5, $24F5, $24F5, $24F5
        dw $24F5, $24F5, $24F5, $24F5, $68FC
        
    ; $6E078
    
        dw $A8FB, $A8F9, $A8F9, $A8F9, $A8F9
        dw $A8F9, $A8F9, $A8F9, $A8F9, $E8FB
    }

; ==============================================================================

    ; *$6E08C-$6E0DE JUMP LOCATION
    ExpandBottleMenu:
    {
        ; each frame of this causes the bottle menu frame
        ; to expand upward by by one tile
        
        REP #$30
        
        LDA $0205 : AND.w #$00FF : ASL #6 : TAX : PHX
        
        LDY.w #$0012
    
    .drawBottleMenuTop
    
        LDA $E050, Y : STA $12FC, X
        
        DEX #2 : DEY #2 : BPL .drawBottleMenuTop
        
        PLX 
        
        LDY.w #$0012
    
    ; each subsequent frame, this will overwrite the top of the menu
    ; from the previous frame until fully expanded
    .eraseOldTop
    
        LDA $E064, Y : STA $133C, X
        
        DEX #2
        
        DEY #2 : BPL .eraseOldTop
        
        LDX.w #$0012

    ; probably only really needs to be done during the first frame of this
    ; step of the submodule
    .drawBottleMenuBottom
    
        LDA $E078, X : STA $176A, X
        
        DEX #2 : BPL .drawBottleMenuBottom
        
        SEP #$30
        
        DEC $0205 : LDA $0205 : BPL .notDoneDrawing
        
        INC $0200
    
    .notDoneDrawing
    
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
    
        RTS
    }

; ==============================================================================

    ; *$6E0DF-$6E176 JUMP LOCATION
    BottleMenu:
    {
        INC $0207
        
        ; Check if the start button was pressed this frame
        LDA $F4 : AND.b #$10 : BEQ .dontCloseMenu
        
        ; close the item menu and play the vvvoooop sound as it goes up
        LDA.b #$12 : STA $012F
        LDA.b #$05 : STA $0200
        
        BRA .lookAtUpDownInput
    
    .dontCloseMenu
    
        LDA $F4 : AND.b #$03 : BEQ .noLeftRightInput
        
        LDA $F4 : AND.b #$02 : BEQ .noLeftInput
        
        JSR TryEquipPrevItem
        
        BRA .movingOn
    
    .noLeftInput
    
        LDA $F4 : AND.b #$01 : BEQ .noRightInput
        
        JSR TryEquipNextItem
    
    .noRightInput
    .movingOn
    
        ; play sound effect and start a timer to keep
        ; us from switching items for 16 frames.
        LDA.b #$10 : STA $0207
        LDA.b #$20 : STA $012F
        
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawYButtonItems
        JSR DrawSelectedYButtonItem
        
        ; Since left or right was pressed, we're exiting the bottle menu
        ; and going back to the normal menu.
        INC $0200
        
        STZ $0205
        
        RTS
    
    .noLeftRightInput
    .lookAtUpDownInput
    
        JSR UpdateBottleMenu
        
        LDA $F4 : AND.b #$0C : BNE .haveUpDownInput
        
        ; there's no input, so nothing happens.
        RTS
    
    .haveUpDownInput
    
        LDA $7EF34F : DEC A : STA $00 : STA $02
        
        LDA $F4 : AND.b #$08 : BEQ .haveUpInput
    
    .selectPrevBottle
    
        LDA $00 : DEC A : AND.b #$03 : STA $00 : TAX
        
        LDA $7EF35C, X : BEQ .selectPrevBottle
        
        BRA .bottleIsSelected
    
    .haveUpInput
    .selectNextBottle
    
        LDA $00 : INC A : AND.b #$03 : STA $00 : TAX
        
        LDA $7EF35C, X : BEQ .selectNextBottle
    
    .bottleIsSelected
    
        LDA $00 : CMP $02 : BEQ .sameBottleWhoCares
        
        ; record which bottle was just selected
        INC A : STA $7EF34F
        
        ; If it's not the same bottle we play the 
        ; obligatory item switch sound effect
        LDA.b #$10 : STA $0207
        LDA.b #$20 : STA $012F
    
    .sameBottleWhoCares
    
        RTS
    }

; ==============================================================================

    ; $6E177-$6E17E DATA

; ==============================================================================

    ; *$6E17F-$6E2FC LOCAL
    UpdateBottleMenu:
    {
        REP #$30
    
        LDX.w #$0000
        LDY.w #$0007
        LDA.w #$24F5
    
    .erase
    
        STA $132C, X : STA $136C, X
        STA $13AC, X : STA $13EC, X
        STA $142C, X : STA $146C, X
        STA $14AC, X : STA $14EC, X
        STA $152C, X : STA $156C, X
        STA $15AC, X : STA $15EC, X
        STA $162C, X : STA $166C, X
        STA $16AC, X : STA $16EC, X
        STA $172C, X 
        
        INX #2
        
        DEY : BPL .erase
        
        ; Draw the 4 bottle icons (if we don't have that bottle it just draws blanks)
        LDA.w #$1372 : STA $00
        LDA $7EF35C : AND.w #$00FF : STA $02
        LDA.w #$F751 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1472 : STA $00
        LDA $7EF35D : AND.w #$00FF : STA $02
        LDA.w #$F751 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1572 : STA $00
        LDA $7EF35E : AND.w #$00FF : STA $02
        LDA.w #$F751 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1672 : STA $00
        LDA $7EF35F : AND.w #$00FF : STA $02
        LDA.w #$F751 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1408 : STA $00
        
        LDA $7EF34F : AND.w #$00FF : TAX : BNE .haveBottleEquipped
        
        LDA.w #$0000
        
        BRA .drawEquippedBottle
    
    .haveBottleEquipped
    
        LDA $7EF35B, X : AND.w #$00FF
    
    .drawEquippedBottle
    
        STA $02
        
        LDA.w #$F751 : STA $04
        
        JSR DrawItem
        
        LDA $0202 : AND.w #$00FF : DEC A : ASL A : TAX
        
        LDY $FAD5, X
        
        LDA $0000, Y : STA $11B2
        LDA $0002, Y : STA $11B4
        LDA $0040, Y : STA $11F2
        LDA $0042, Y : STA $11F4
        
        LDA $7EF34F : DEC A : AND.w #$00FF : ASL A : TAY
        
        LDA $E177, Y : TAY
        
        LDA $0207 : AND.w #$0010 : BEQ .return
        
        LDA.w #$3C61 : STA $12AA, Y
        ORA.w #$4000 : STA $12AC, Y
        
        LDA.w #$3C70 : STA $12E8, Y
        ORA.w #$4000 : STA $12EE, Y
        
        LDA.w #$BC70 : STA $1328, Y
        ORA.w #$4000 : STA $132E, Y
        
        LDA.w #$BC61 : STA $136A, Y
        ORA.w #$4000 : STA $136C, Y
        
        LDA.w #$3C60 : STA $12A8, Y
        ORA.w #$4000 : STA $12AE, Y
        ORA.w #$8000 : STA $136E, Y
        EOR.w #$4000 : STA $1368, Y
        
        LDA $7EF34F : AND.w #$00FF : BEQ .noSelectedBottle
        
        TAX
        
        LDA $7EF35B, X : AND.w #$00FF : DEC A : ASL #5 : TAX
        
        LDY.w #$0000
    
    .writeBottleDescription
    
        LDA $F449, X : STA $122C, Y
        LDA $F459, X : STA $126C, Y
    
        INX #2
        INY #2 : CPY.w #$0010
        
        BCC .writeBottleDescription
    
    .return
    .noSelectedBottle
    
        SEP #$30
        
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
        
        RTS
    } 

; ==============================================================================

    ; *$6E2FD-$6E345 JUMP LOCATION
    EraseBottleMenu:
    {
        REP #$30
        
        ; erase the bottle menu
        LDA $0205 : AND.w #$00FF : ASL #6 : TAX
        
        LDA.w #$207F
        STA $12EA, X : STA $12EC, X : STA $12EE, X : STA $12F0, X
        STA $12F2, X : STA $12F4, X : STA $12F6, X : STA $12F8, X
        STA $12FA, X : STA $12FC, X
        
        SEP #$30
        
        INC $0205
        
        LDA $0205 : CMP.b #$13 : BNE .notDoneErasing
        
        ; move on to the next step of the submodule
        INC $0200
    
    .notDoneErasing
    
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
        
        RTS
    }

; ==============================================================================

    ; *$6E346-$6E371 JUMP LOCATION
    RestoreNormalMenu:
    {
        ; Updates just the portions of the screen that the bottle menu
        ; screws with.
        
        JSR DrawProgressIcons
        JSR DrawMoonPearl
        JSR UnfinishedRoutine
        
        LDA.b #$01
        
        JSR GetPaletteMask
        JSR DrawEquipment
        JSR DrawShield
        JSR DrawArmor
        JSR DrawMapAndBigKey
        JSR DrawCompass
        
        ; Switch to the normal menu submode.
        LDA.b #$04 : STA $0200
        
        ; Tell NMI to update BG3 tilemap next from by writing to address $6800 (word) in vram
        LDA.b #$01 : STA $17
        LDA.b #$22 : STA $0116
        
        RTS
    }

; ==============================================================================

    ; *$6E372-$6E394 LOCAL
    DrawItem:
    {
        LDA $02 : ASL #3 : TAY
        
        LDX $00
        
                 LDA ($04), Y : STA $0000, X
        INY #2 : LDA ($04), Y : STA $0002, X 
        INY #2 : LDA ($04), Y : STA $0040, X 
        INY #2 : LDA ($04), Y : STA $0042, X
        
        RTS
    } 

; ==============================================================================

    ; *$6E395-$6E398 LONG
    SearchForEquippedItemLong:
    {
        JSR SearchForEquippedItem
        
        RTL
    }

; ==============================================================================

    ; *$6E399-$6E3C7 LOCAL
    SearchForEquippedItem:
    {
        SEP #$30
        
        LDX.b #$12
        
        LDA $7EF340
    
    ; Go through all our equipable items, hoping to find at least one available
    .itemCheck
    
        ORA $7EF341, X : DEX : BPL .itemCheck
        
        CMP.b #$00 : BNE .equippableItemAvailable
        
        ; In this case we have no equippable items
        STZ $0202 : STZ $0203 : STZ $0204
    
    .weHaveThatItem
    
        RTS
    
    .equippableItemAvailable
    
        ; Is there an item currently equipped (in the HUD slot)?
        LDA $0202 : BNE .alreadyEquipped
        
        ; If not, set the equipped item to the Bow and Arrow (even if we don't actually have it)
        LDA.b #$01 : STA $0202
    
    .alreadyEquipped
    
        ; Checks to see if we actually have that item
        ; We're done if we have that item
        JSR DoWeHaveThisItem : BCS .wehaveThatItem
        
        JMP TryEquipNextItem
    }

; ==============================================================================

    ; *$6E3C8-$6E3D8 LOCAL
    GetPaletteMask:
    {
        ; basically if(A == 0) $00 = 0xE3FF; else $00 = 0xFFFF;
        ; if A was zero, this would be used to force a tilemap entry's palette to the 0th palette.
        
        SEP #$30
        
        LDX.b #$E3
        
        CMP.b #$00 : BEQ .alpha
        
        LDX.b #$FF
    
    .alpha
    
        STX $01
        
        LDA.b #$FF : STA $00
        
        RTS
    }

; ==============================================================================

    ;*$6E3D9-$6E646 LOCAL
    DrawYButtonItems:
    {
        REP #$30
        
        ; draw 4 corners of a box (for the equippable item section)
        LDA.w #$3CFB : AND $00 : STA $1142
        ORA.w #$8000 : STA $14C2
        ORA.w #$4000 : STA $14E6
        EOR.w #$8000 : STA $1166
        
        LDX.w #$0000
        LDY.w #$000C
    
    .drawVerticalEdges
    
        LDA.w #$3CFC : AND $00 : STA $1182, X
        ORA.w #$4000 : STA $11A6, X
        
        TXA : ADD.w #$0040 : TAX
        
        DEY : BPL .drawVerticalEdges
        
        LDX.w #$0000
        LDY.w #$0010
    
    .drawHorizontalEdges
    
        LDA.w #$3CF9 : AND $00 : STA $1144, X
        ORA.w #$8000 : STA $14C4, X
        
        INX #2
        
        DEY : BPL .drawHorizontalEdges
        
        LDX.w #$0000
        LDY.w #$0010
        LDA.w #$24F5
    
    .drawBoxInterior
    
        STA $1184, X : STA $11C4, X : STA $1204, X : STA $1244, X
        STA $1284, X : STA $12C4, X : STA $1304, X : STA $1344, X
        STA $1384, X : STA $13C4, X : STA $1404, X : STA $1444, X
        STA $1484, X
        
        INX #2
        
        DEY : BPL .drawBoxInterior
        
        ; Draw 'Y' button Icon?
        LDA.w #$3CF0 : STA $1184
        LDA.w #$3CF1 : STA $11C4
        LDA.w #$246E : STA $1146
        LDA.w #$246F : STA $1148
        
        ; Draw Bow and Arrow
        LDA.w #$11C8 : STA $00
        LDA $7EF340 : AND.w #$00FF : STA $02
        LDA.w #$F629 : STA $04
        
        JSR DrawItem
        
        ; Draw Boomerang
        LDA.w #$11CE : STA $00
        LDA $7EF341 : AND.w #$00FF : STA $02
        LDA.w #$F651 : STA $04
        
        JSR DrawItem
        
        ; Draw Hookshot
        LDA.w #$11D4 : STA $00
        LDA $7EF342 : AND.w #$00FF : STA $02
        LDA.w #$F669 : STA $04
        
        JSR DrawItem
        
        ; Draw Bombs
        LDA.w #$11DA : STA $00
        
        LDA $7EF343 : AND.w #$00FF : BEQ .gotNoBombs
        
        LDA.w #$0001
    
    .gotNoBombs
    
        STA $02
        
        LDA.w #$F679 : STA $04
        
        JSR DrawItem
        
        ; Draw mushroom or magic powder
        LDA.w #$11E0 : STA $00
        LDA $7EF344 : AND.w #$00FF : STA $02
        LDA.w #$F689 : STA $04
        
        JSR DrawItem
        
        ; Draw Fire Rod
        LDA.w #$1288 : STA $00
        LDA $7EF345 : AND.w #$00FF : STA $02
        LDA.w #$F6A1 : STA $04
        
        JSR DrawItem
        
        ; Draw Ice Rod
        LDA.w #$128E : STA $00
        LDA $7EF346 : AND.w #$00FF : STA $02
        LDA.w #$F6B1 : STA $04
        
        JSR DrawItem
        
        ; Draw Bombos Medallion
        LDA.w #$1294 : STA $00
        LDA $7EF347 : AND.w #$00FF : STA $02
        LDA.w #$F6C1 : STA $04
        
        JSR DrawItem
        
        ; Draw Ether Medallion
        LDA.w #$129A : STA $00
        LDA $7EF348 : AND.w #$00FF : STA $02
        LDA.w #$F6D1 : STA $04
        
        JSR DrawItem
        
        ; Draw Quake Medallion
        LDA.w #$12A0 : STA $00
        LDA $7EF349 : AND.w #$00FF : STA $02
        LDA.w #$F6E1 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1348 : STA $00
        LDA $7EF34A : AND.w #$00FF : STA $02
        LDA.w #$F6F1 : STA $04
        
        JSR DrawItem
        
        LDA.w #$134E : STA $00
        LDA $7EF34B : AND.w #$00FF : STA $02
        LDA.w #$F701 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1354 : STA $00
        LDA $7EF34C : AND.w #$00FF : STA $02
        LDA.w #$F711 : STA $04
        
        JSR DrawItem
        
        ; Bug Catching Net
        LDA.w #$135A : STA $00
        LDA $7EF34D : AND.w #$00FF : STA $02
        LDA.w #$F731 : STA $04
        
        JSR DrawItem
        
        ; Draw Book Of Mudora
        LDA.w #$1360 : STA $00
        LDA $7EF34E : AND.w #$00FF : STA $02
        LDA.w #$F741 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1408 : STA $00
        
        ; there is an active bottle
        LDA $7EF34F : AND.w #$00FF : TAX : BNE .haveSelectedBottle
        
        LDA.w #$0000
        
        BRA .noSelectedBottle
    
    .haveSelectedBottle
    
        LDA $7EF35B, X : AND.w #$00FF
        
    .noSelectedBottle
    
        STA $02
        
        LDA.w #$F751 : STA $04
        JSR DrawItem
        
        ; Draw Cane of Somaria
        LDA.w #$140E : STA $00
        LDA $7EF350 : AND.w #$00FF : STA $02
        LDA.w #$F799 : STA $04
        JSR DrawItem
        
        ; Draw Cane of Byrna
        LDA.w #$1414 : STA $00
        LDA $7EF351 : AND.w #$00FF : STA $02
        LDA.w #$F7A9 : STA $04
        JSR DrawItem
        
        ; Draw Magic Cape
        LDA.w #$141A : STA $00
        LDA $7EF352 : AND.w #$00FF : STA $02
        LDA.w #$F7B9 : STA $04
        JSR DrawItem
        
        ; Draw Magic Mirror
        LDA.w #$1420 : STA $00
        LDA $7EF353 : AND.w #$00FF : STA $02
        LDA.w #$F7C9 : STA $04
        JSR DrawItem
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6E647-$6E6B5 LOCAL
    DrawUnknownBox:
    {
        REP #$30
        
        ; draw 4 corners of a box
        LDA.w #$3CFB : AND $00 : STA $116A
        ORA.w #$8000 : STA $12AA
        ORA.w #$4000 : STA $12BC
        EOR.w #$8000 : STA $117C
        
        LDX.w #$0000 
        LDY.w #$0003
    
    ; the lines these tiles make are vertical
    .drawBoxVerticalSides
    
        LDA.w #$3CFC : AND $00 : STA $11AA, X
        ORA.w #$4000 : STA $11BC, X
        
        TXA : ADD.w #$0040 : TAX
        
        DEY : BPL .drawBoxVerticalSides
        
        LDX.w #$0000
        LDY.w #$0007
    
    ; I say horizontal b/c the lines the sides make are horizontal
    .drawBoxHorizontalSides
    
        LDA.w #$3CF9 : AND $00 : STA $116C, X
        ORA.w #$8000 : STA $12AC, X
        
        INX #2
        
        DEY : BPL .drawBoxHorizontalSides
        
        LDX.w #$0000
        LDY.w #$0007
        LDA.w #$24F5
    
    .drawBoxInterior
    
        STA $11AC, X : STA $11EC, X : STA $122C, X : STA $126C, X
        
        INX #2
        
        DEY : BPL .drawBoxInterior
        
        SEP #$30
        
        RTS
    }

; ==============================================================================
    
    ; *$6E6B6-$6E7B6 LOCAL
    DrawAbilityText:
    {
        REP #$30
        
        LDX.w #$0000
        LDY.w #$0010
        LDA.w #$24F5
    
    .drawBoxInterior
    
        STA $1584, X : STA $15C4, X
        STA $1604, X : STA $1644, X
        STA $1684, X : STA $16C4, X
        
        STA $1704, X : INX #2
        
        DEY : BPL .drawBoxInterior
        
        ; get data from ability variable (set of flags for each ability)
        LDA $7EF378 : AND.w #$FF00 : STA $02
        
        LDA.w #$0003 : STA $04
        
        LDY.w #$0000 : TYX
    
    .nextLine
    
        LDA.w #$0004 : STA $06
    
    .nextAbility
    
        ASL $02 : BCC .lacksAbility
        
        ; Draws the ability strings if Link has the ability
        ; (2 x 5 tile rectangle for each ability)
        LDA $F959, X : STA $1588, Y
        LDA $F95B, X : STA $158A, Y
        LDA $F95D, X : STA $158C, Y
        LDA $F95F, X : STA $158E, Y
        LDA $F961, X : STA $1590, Y
        LDA $F963, X : STA $15C8, Y
        LDA $F965, X : STA $15CA, Y
        LDA $F967, X : STA $15CC, Y
        LDA $F969, X : STA $15CE, Y
        LDA $F96B, X : STA $15D0, Y
    
    .lacksAbility
    
        TXA : ADD.w #$0014 : TAX
        TYA : ADD.w #$000A : TAY
        
        DEC $06 : BNE .nextAbility
        
        TYA : ADD.w #$0058 : TAY
        
        DEC $04 : BNE .nextLine
        
        ; draw the 4 corners of the box containing the ability tiles
        LDA.w #$24FB : AND $00 : STA $1542
        ORA.w #$8000 : STA $1742
        ORA.w #$4000 : STA $1766
        EOR.w #$8000 : STA $1566
        
        LDX.w #$0000
        LDY.w #$0006
    
    .drawVerticalEdges
    
        LDA.w #$24FC : AND $00 : STA $1582, X
        ORA.w #$4000 : STA $15A6, X
        
        TXA : ADD.w #$0040 : TAX
        
        DEY : BPL .drawVerticalEdges
        
        LDX.w #$0000
        LDY.w #$0010
    
    .drawHorizontalEdges
    
        LDA.w #$24F9 : AND $00 : STA $1544, X
        ORA.w #$8000 : STA $1744, X
        
        INX #2
        
        DEY : BPL .drawHorizontalEdges
        
        ; Draw 'A' button icon
        LDA.w #$A4F0 : STA $1584
        LDA.w #$24F2 : STA $15C4
        LDA.w #$2482 : STA $1546
        LDA.w #$2483 : STA $1548
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6E7B7-$6E819 LOCAL
    DrawAbilityIcons:
    {
        REP #$30
        
        LDA.w #$16D0 : STA $00
        LDA $7EF354 : AND.w #$00FF : STA $02
        LDA.w #$F7E9 : STA $04
        
        JSR DrawItem
        
        LDA.w #$16C8 : STA $00
        LDA $7EF355 : AND.w #$00FF : STA $02
        LDA.w #$F801 : STA $04
        
        JSR DrawItem
        
        LDA.w #$16D8 : STA $00
        LDA $7EF356 : AND.w #$00FF : STA $02
        LDA.w #$F811 : STA $04
        
        JSR DrawItem
        
        ; modify the lift ability text if you have
        ; a glove item
        LDA $7EF354
        
        AND.w #$00FF : BEQ .finished
        CMP.w #$0001 : BNE .titansMitt
        
        LDA.w #$0000
        
        JSR DrawGloveAbility
        
        BRA .finished
    
    .titansMitt
    
        LDA.w #$0001
        
        JSR DrawGloveAbility
    
    .finished
    
        SEP #$30
        
        RTS
    }

; ==============================================================================
    
    ; *$6E81A-$6E85F LOCAL
    DrawGloveAbility:
    {
        STA $00 
        ASL #2 : ADC $00 : ASL #2 : TAX
        
        LDA $F931, X : STA $1588
        LDA $F933, X : STA $158A
        LDA $F935, X : STA $158C
        LDA $F937, X : STA $158E
        LDA $F939, X : STA $1590
        LDA $F93B, X : STA $15C8
        LDA $F93D, X : STA $15CA
        LDA $F93F, X : STA $15CC
        LDA $F941, X : STA $15CE
        LDA $F943, X : STA $15D0
        
        RTS
    }

; ==============================================================================
    
    ; $6E860-$6E9C7 DATA

; ==============================================================================

    ; *$6E9C8-$6EB39 LOCAL
    DrawProgressIcons:
    {
        LDA $7EF3C5 : CMP.b #$03 : BCC .beforeAgahnim
        
        JMP .drawCrystals
    
    .beforeAgahnim
    
        REP #$30
        
        LDX.w #$0000
    
    .initPendantDiagram
    
        LDA $E860, X : STA $12EA, X
        LDA $E874, X : STA $132A, X
        LDA $E888, X : STA $136A, X
        LDA $E89C, X : STA $13AA, X
        LDA $E8B0, X : STA $13EA, X
        LDA $E8C4, X : STA $142A, X
        LDA $E8D8, X : STA $146A, X
        LDA $E8EC, X : STA $14AA, X
        LDA $E900, X : STA $14EA, X
        
        INX #2 : CPX.w #$0014 : BCC .initPendantDiagram
        
        LDA.w #$13B2               : STA $00
        LDA $7EF374 : AND.w #$0001 : STA $02
        LDA.w #$F8D1               : STA $04
        
        JSR DrawItem
        
        LDA.w #$146E : STA $00
        STZ $02
        
        LDA $7EF374 : AND.w #$0002 : BEQ .needWisdomPendant
        
        INC $02
    
    .needWisdomPendant
    
        LDA.w #$F8E1 : STA $04
        
        JSR DrawItem
        
        LDA.w #$1476 : STA $00
        STZ $02
        
        LDA $7EF374 : AND.w #$0004 : BEQ .needPowerPendant
        
        INC $02
    
    .needPowerPendant
    
        LDA.w #$F8F1 : STA $04
        
        JSR DrawItem
        
        SEP #$30
        
        RTS
    
    ; *$6EA62 ALTERNATE ENTRY POINT
    .drawCrystals
    
        REP #$30
        
        LDX.w #$0000
    
    .initCrystalDiagram
    
        LDA $E914, X : STA $12EA, X
        LDA $E928, X : STA $132A, X
        LDA $E93C, X : STA $136A, X
        LDA $E950, X : STA $13AA, X
        LDA $E964, X : STA $13EA, X
        LDA $E978, X : STA $142A, X
        LDA $E98C, X : STA $146A, X
        LDA $E9A0, X : STA $14AA, X
        LDA $E9B4, X : STA $14EA, X
        
        INX #2 : CPX.w #$0014
        
        BCC .initCrystalDiagram
        
        LDA $7EF37A : AND.w #$0001
        
        BEQ .miseryMireNotDone
        
        LDA.w #$2D44 : STA $13B0
        LDA.w #$2D45 : STA $13B2
    
    .miseryMireNotDone
    
        LDA $7EF37A : AND.w #$0002
        
        BEQ .darkPalaceNotDone
        
        LDA.w #$2D44 : STA $13B4
        LDA.w #$2D45 : STA $13B6
    
    .darkPalaceNotDone
    
        LDA $7EF37A : AND.w #$0004
        
        BEQ .icePalaceNotDone
        
        LDA.w #$2D44 : STA $142E
        LDA.w #$2D45 : STA $1430
    
    .icePalacenotDone
    
        LDA $7EF37A : AND.w #$0008
        
        BEQ .turtleRockNotDone
        
        LDA.w #$2D44 : STA $1432
        LDA.w #$2D45 : STA $1434
    
    .turtleRockNotDone
    
        LDA $7EF37A : AND.w #$0010
        
        BEQ .swampPalaceNotDone
        
        LDA.w #$2D44 : STA $1436
        LDA.w #$2D45 : STA $1438
    
    .swampPalaceNotDone
    
        LDA $7EF37A : AND.w #$0020
        
        BEQ .blindHideoutNotDone
        
        LDA.w #$2D44 : STA $14B0
        LDA.w #$2D45 : STA $14B2
    
    .blindHideoutNotDone
    
        LDA $7EF37A : AND.w #$0040
        
        BEQ .skullWoodsNotDone
        
        LDA.w #$2D44 : STA $14B4
        LDA.w #$2D45 : STA $14B6
    
    .skullWoodsNotdone
    
        SEP #$30
        
        RTS
    }

; ==============================================================================
    
    ; *$6EB3A-$6ECE8 LOCAL
    DrawSelectedYButtonItem:
    {
        REP #$30
        
        LDA $0202 : AND.w #$00FF : DEC A : ASL A : TAX
        
        LDY $FAD5, X
        LDA $0000, Y : STA $11B2
        LDA $0002, Y : STA $11B4
        LDA $0040, Y : STA $11F2
        LDA $0042, Y : STA $11F4
        
        LDA $0207 : AND.w #$0010 : BEQ .dontUpdate
        
        LDA.w #$3C61 : STA $FFC0, Y
        ORA.w #$4000 : STA $FFC2, Y
        
        LDA.w #$3C70 : STA $FFFE, Y
        ORA.w #$4000 : STA $0004, Y
        
        LDA.w #$BC70 : STA $003E, Y
        ORA.w #$4000 : STA $0044, Y
        
        LDA.w #$BC61 : STA $0080, Y
        ORA.w #$4000 : STA $0082, Y
        
        LDA.w #$3C60 : STA $FFBE, Y
        ORA.w #$4000 : STA $FFC4, Y
        ORA.w #$8000 : STA $0084, Y
        EOR.w #$4000 : STA $007E, Y
    
    .dontUpdate
    
        LDA $0202 : AND.w #$00FF : CMP.w #$0010 : BNE .bottleNotSelected
        
        LDA $7EF34F : AND.w #$00FF : BEQ .bottleNotSelected
        
        TAX
        
        LDA $7EF35B, X : AND.w #$00FF : DEC A : ASL #5 : TAX
        
        LDY.w #$0000
    
    .drawBottleDecription
    
        LDA $F449, X : STA $122C, Y
        LDA $F459, X : STA $126C, Y
        
        INX #2
        INY #2 : CPY.w #$0010
        
        BCC .drawBottleDescription
        
        JMP .finished
    
    .bottleNotSelected
    
        ; Magic Powder selected?
        LDA $0202 : AND.w #$00FF : CMP.w #$0005 : BNE .powderNotSelected
        
        LDA $7EF344 : AND.w #$00FF : DEC A : BEQ .powderNotSelected
        
        DEC A : ASL #5 : TAX
        
        LDY.w #$0000
    
    .writePowderDescription
    
        LDA $F549, X : STA $122C, Y
        LDA $F559, X : STA $126C, Y
        
        INX #2
        
        INY #2 : CPY.w #$0010 : BCC .writePowderDescription
        
        JMP .finished
    
    .powderNotSelected
    
        LDA $0202 : AND.w #$00FF : CMP.w #$0014 : BNE .mirrorNotSelected
        
        LDA $7EF353 : AND.w #$00FF : DEC A : BEQ .mirrorNotSelected
        
        DEC A : ASL #5 : TAX
        
        LDY.w #$0000
    
    .writeMirrorDescription
    
        LDA $F5A9, X : STA $122C, Y
        LDA $F5B9, X : STA $126C, Y
        
        INX #2
        
        INY #2 : CPY.w #$0010 : BCC .writeMirrorDescription
        
        JMP .finished
    
    .mirrorNotSelected
    
        LDA $0202 : AND.w #$00FF : CMP.w #$000D : BNE .fluteNotSelected
        
        LDA $7EF34C : AND.w #$00FF : DEC A : BEQ .fluteNotSelected
        
        DEC A : ASL #5 : TAX
        
        LDY.w #$0000
    
    .writeFluteDescription
    
        LDA $F569, X : STA $122C, Y
        LDA $F579, X : STA $126C, Y
        
        INX #2
        
        INY #2 : CPY.w #$0010 : BCC .writeFluteDescription
        
        BRA .finished
    
    .fluteNotSelected
    
        LDA $0202 : AND.w #$00FF : CMP.w #$0001 : BNE .bowNotSelected
        
        LDA $7EF340 : AND.w #$00FF : DEC A : BEQ .bowNotSelected
        
        DEC A : ASL #5 : TAX
        
        LDY.w #$0000
    
    .writeBowDescription
    
        LDA $F5C9, X : STA $122C, Y
        LDA $F5D9, X : STA $126C, Y
        
        INX #2
        
        INY #2 : CPY.w #$0010 : BCC .writeBowDescription
        
        BRA .finished
    
    .bowNotSelected
    
        TXA : ASL #4 : TAX
        
        LDY.w #$0000
    
    .writeDefaultDescription
    
        LDA $F1C9, X : STA $122C, Y
        LDA $F1D9, X : STA $126C, Y
        
        INX #2
        
        INY #2 : CPY.w #$0010 : BCC .writeDefaultDescription
    
    .finished
    
        SEP #$30
        
        RTS
    }

; ==============================================================================
 
    ; *$6ECE9-$6ED03 LOCAL
    DrawMoonPearl:
    {
        REP #$30
        
        LDA.w #$16E0               : STA $00
        LDA $7EF357 : AND.w #$00FF : STA $02
        LDA.w #$F821               : STA $04
        
        JSR DrawItem
        
        SEP #$30
        
        RTS
    } 

; ==============================================================================
    
    ; *$6ED04-$6ED08 LOCAL
    UnfinishedRoutine:
    {
        ; MOST WORTHLESS ROUTINE EVAR
        REP #$30
        
        SEP #$30
        
        RTS
    }

; ==============================================================================
    
    ; $6ED09-$6ED28 DATA

; ==============================================================================

    ; *$6ED29-$6EE20 LOCAL
    DrawEquipment:
    {
        REP #$30
        
        ; draw the 4 corners of the border for this section
        LDA.w #$28FB : AND $00 : STA $156A
        ORA.w #$8000 : STA $176A
        ORA.w #$4000 : STA $177C
        EOR.w #$8000 : STA $157C
        
        LDX.w #$0000
        LDY.w #$0006
    
    .drawVerticalEdges
    
        LDA.w #$28FC : AND $00 : STA $15AA, X
        ORA.w #$4000 : STA $15BC, X
        
        TXA : ADD.w #$0040 : TAX
        
        DEY : BPL .drawVerticalEdges
        
        LDX.w #$0000
        LDY.w #$0007
    
    .drawHorizontalEdges
    
        LDA.w #$28F9 : AND $00 : STA $156C, X
        ORA.w #$8000 : STA $176C, X
        
        INX #2 : DEY : BPL .drawHorizontalEdges
        
        LDX.w #$0000
        LDY.w #$0007
        LDA.w #$24F5
    
    .drawBoxInterior
    
        STA $15AC, X : STA $15EC, X : STA $162C, X : STA $166C, X
        STA $16AC, X : STA $16EC, X : STA $172C, X
        
        INX #2 : DEY : BPL .drawBoxInterior
        
        LDX.w #$0000
        LDY.w #$0007
    
        LDA.w #$28D7 : AND $00
    
    .drawDashedSeparator
    
        STA $166C, X
        
        INX #2 : DEY : BPL .drawDashedSeparator
        
        LDX.w #$0000
        LDY.w #$0007
    
    .drawBoxTitle
    
        LDA $ED09, X : AND $00 : STA $15AC, X
        LDA $ED19, X : AND $00 : STA $16AC, X
        
        INX #2 : DEY : BPL .drawBoxTitle
        
        ; check if we're in a real dungeon (palace) as opposed to just some
        ; house or cave
        LDA $040C : AND.w #$00FF : CMP.w #$00FF : BNE .inSpecificDungeon
        
        LDX.w #$0000
        LDY.w #$0007
        LDA.w #$24F5
    
    .drawUnknown
    
        STA $16AC, X
        
        INX #2 : DEY : BPL .drawUnknown
        
        LDA.w #$16F2 : STA $00
        LDA $7EF36B : AND.w #$00FF : STA $02
        LDA.w #$F911 : STA $04
        
        JSR DrawItem
    
    .inSpecificDungeon
    
        REP #$30
        
        LDA.w #$15EC : STA $00
        
        LDA $7EF359 : AND.w #$00FF : CMP.w #$00FF : BNE .hasSword
        
        LDA.w #$0000
    
    .hasSword
    
                       STA $02
        LDA.w #$F839 : STA $04
        
        JSR DrawItem
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6EE21-$6EE3B LOCAL
    DrawShield:
    {
        REP #$30
        
        LDA.w #$15F2                : STA $00
        LDA $7EF35A  : AND.w #$00FF : STA $02
        LDA.w #$F861                : STA $04
        
        JSR DrawItem
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6EE3C-$6EE56 LOCAL
    DrawArmor:
    {
        REP #$30
        
        LDA.w #$15F8                : STA $00
        LDA $7EF35B  : AND.w #$00FF : STA $02
        LDA.w #$F881                : STA $04
        
        JSR DrawItem
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6EE57-$6EEB5 LOCAL
    DrawMapAndBigKey:
    {
        REP #$30
        
        LDA $040C : AND.w #$00FF : CMP.w #$00FF : BEQ .notInPalace
        
        LSR A : TAX
        
        ; Check if we have the big key in this palace
        LDA $7EF366
    
    .locateBigKeyFlag
    
        ASL A : DEX : BPL .locateBigKeyFlag : BCC .dontHaveBigKey
        
        JSR CheckPalaceItemPossession
        
        REP #$30
        
        ; Draw the big key (or big key with chest if we've gotten the treasure) icon
        LDA.w #$16F8           : STA $00
        LDA.w #$0001 : ADD $02 : STA $02
        LDA.w #$F8A9           : STA $04
        
        JSR DrawItem
    
    .dontHaveBigKey
    .notInPalace
    
        LDA $040C : AND.w #$00FF : CMP.w #$00FF : BEQ .notInPalaceAgain
        
        LSR A : TAX
        
        ; Check if we have the map in this dungeon
        LDA $7EF368
    
    .locateMapFlag
    
        ASL A : DEX : BPL .locateMapFlag : BCC .dontHaveMap
        
        LDA.w #$16EC : STA $00
        LDA.w #$0001 : STA $02
        LDA.w #$F8C1 : STA $04
        
        JSR DrawItem
    
    .dontHaveMap
    .notInPalaceAgain
    
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6EEB6-$6EEDB LOCAL
    CheckPalaceItemPossession:
    {
        SEP #$30
        
        LDA $040C : LSR A
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw .no_item
        dw .no_item
        dw .bow
        dw .power_glove
        dw .no_item
        dw .hookshot
        dw .hammer
        dw .cane_of_somaria
        dw .fire_rod
        dw .blue_mail
        dw .moon_pearl
        dw .titans_mitt
        dw .mirror_shield
        dw .red_mail
    }

; ==============================================================================

    ; *$6EEDC-$6EEE0 JUMP LOCATION
    pool CheckPalaceItemPossession:
    {
    
    .failure
    
        STZ $02
        STZ $03
        
        RTS
    
    .bow
    
        LDA $7EF340
    
    .no_item
    .compare
    
        BEQ .failure
    
    .success
    
        LDA.b #$01 : STA $02
                     STZ $03
        
        RTS
    
    .power_glove
    
        LDA $7EF354 : BRA .compare
    
    .hookshot
    
        LDA $7EF342 : BRA .compare
    
    .hammer
    
        LDA $7EF34B : BRA .compare
    
    .cane_of_somaria
    
        LDA $7EF350 : BRA .compare
    
    .fire_rod
    
        LDA $7EF345 : BRA .compare
    
    .blue_mail
    
        LDA $7EF35B : BRA .compare
    
    .moon_pearl
    
        LDA $7EF357 : BRA .compare
    
    .titans_mitt
    
        LDA $7EF354 : DEC A : BRA .compare
    
    .mirror_shield
    
        LDA $7EF35A : CMP.b #$03 : BEQ .success
        
        STZ $02
        STZ $03
        
        RTS
    
    .red_mail
    
        LDA $7EF35B : CMP.b #$02 : BEQ .success
        
        STZ $02
        STZ $03
        
        RTS
    }

; ==============================================================================

    ; *$6EF39-$6EF66 LOCAL
    DrawCompass:
    {
        REP #$30
        
        LDA $040C : AND.w #$00FF : CMP.w #$00FF : BEQ .notInPalace
        
        LSR A : TAX
        
        LDA $7EF364
        
    .locateCompassFlag

        ASL A : DEX : BPL .locateCompassFlag
                      BCC .dontHaveCompass
        
        LDA.w #$16F2 : STA $00
        LDA.w #$0001 : STA $02
        LDA.w #$F899 : STA $04
        
        JSR DrawItem
        
    .dontHaveCompass
    .notInPalace
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$6EF67-$6F0F6 LOCAL
    DrawBottleMenu:
    {
        REP #$30
        
        LDA.w #$28FB : AND $00 : STA $12EA
        ORA.w #$8000           : STA $176A
        ORA.w #$4000           : STA $177C
        EOR.w #$8000           : STA $12FC
        
        LDX.w #$0000
        LDY.w #$0010
    
    .drawVerticalEdges
    
        LDA.w #$28FC : AND $00 : STA $132A, X
        ORA.w #$4000           : STA $133C, X
        
        TXA : ADD.w #$0040 : TAX
        
        DEY : BPL .drawVerticalEdges
        
        LDX.w #$0000
        LDY.w #$0007
    
    .drawHorizontalEdges
    
        LDA.w #$28F9 : AND $00 : STA $12EC, X
        ORA.w #$8000           : STA $176C, X
        
        INX #2
        
        DEY : BPL .drawHorizontalEdges
        
        LDX.w #$0000
        LDY.w #$0007
        LDA.w #$24F5
    
    ; fills in a region of 0x11 by 0x07 tiles with one tilemap value
    .drawBoxInterior
    
        STA $132C, X : STA $136C, X : STA $13AC, X : STA $13EC, X
        STA $142C, X : STA $146C, X : STA $14AC, X : STA $14EC, X
        STA $152C, X : STA $156C, X : STA $15AC, X : STA $15EC, X
        STA $162C, X : STA $166C, X : STA $16AC, X : STA $16EC, X
        STA $172C, X
        
        INX #2
        
        DEY : BPL .drawBoxInterior
        
        REP #$30
        
        ; Draw bottle 0
        LDA.w #$1372               : STA $00
        LDA $7EF35C : AND.w #$00FF : STA $02
        LDA.w #$F751               : STA $04
        
        JSR DrawItem
        
        ; Draw bottle 1
        LDA.w #$1472               : STA $00
        LDA $7EF35D : AND.w #$00FF : STA $02
        LDA.w #$F751               : STA $04
        
        JSR DrawItem
        
        ; Draw bottle 2
        LDA.w #$1572               : STA $00
        LDA $7EF35E : AND.w #$00FF : STA $02
        LDA.w #$F751               : STA $04
        
        JSR DrawItem
        
        ; Draw bottle 3
        LDA.w #$1672               : STA $00
        LDA $7EF35F : AND.w #$00FF : STA $02
        LDA.w #$F751               : STA $04
        
        JSR DrawItem
        
        ; Draw the currently selected bottle
        LDA.w #$1408 : STA $00
        
        LDA $7EF34F : AND.w #$00FF : TAX
        
        LDA $7EF35B, X : AND.w #$00FF : STA $02
        LDA.w #$F751                  : STA $04
        
        JSR DrawItem
        
        ; Take the currently selected item, and draw something with it, perhaps on the main menu region
        LDA $0202 : AND.w #$00FF : DEC A : ASL A : TAX
        
        LDY $FAD5, X 
        
        LDA $0000, Y : STA $11B2
        LDA $0002, Y : STA $11B4
        LDA $0040, Y : STA $11F2
        LDA $0042, Y : STA $11F4
        
        LDA $7EF34F : DEC A : AND.w #$00FF : ASL A : TAY
        
        LDA $E177, Y : TAY
        
        ; appears to be an extraneous load, perhaps something that was unfinished
        ; or meant to be taken out but it just never happened
        LDA $0207
        
        LDA.w #$3C61 : STA $12AA, Y
        ORA.w #$4000 : STA $12AC, Y
        
        LDA.w #$3C70 : STA $12E8, Y
        ORA.w #$4000 : STA $12EE, Y
        
        LDA.w #$BC70 : STA $1328, Y
        ORA.w #$4000 : STA $132E, Y
        
        LDA.w #$BC61 : STA $136A, Y
        ORA.w #$4000 : STA $136C, Y
        
        ; Draw the corners of the bottle submenu
        LDA.w #$3C60 : STA $12A8, Y
        ORA.w #$4000 : STA $12AE, Y
        ORA.w #$8000 : STA $136E, Y
        EOR.w #$4000 : STA $1368, Y
        
        SEP #$30
        
        LDA.b #$10 : STA $0207
        
        RTS
    }

; ==============================================================================

    namespace off



