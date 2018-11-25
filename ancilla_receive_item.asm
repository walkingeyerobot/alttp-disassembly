
; ==============================================================================

    ; $442DD-$44389 DATA
    pool Ancilla_ReceiveItem:
    {
    
    .item_messages
        dw $FFFF, $0070, $0077, $0052, $FFFF, $0078, $0078, $0062
        dw $0061, $0066, $0069, $0053, $0052, $0056, $FFFF, $0064
        dw $0063, $0065, $0051, $0054, $0067, $0068, $006B, $0077
        dw $0079, $0055, $006E, $0058, $006D, $005D, $0057, $005E
        dw $FFFF, $0074, $0075, $0076, $FFFF, $005F, $0158, $FFFF
        dw $006A, $005C, $008F, $0071, $0072, $0073, $0071, $0072
        dw $0073, $006A, $006C, $0060, $FFFF, $FFFF, $FFFF, $0059
        dw $0084, $005A, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $0159
        dw $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
        dw $FFFF, $00DB, $0067, $007C
    
    .animation_tiles
        db $24, $25, $26
    
    .animation_timers
        db 9, 5, 5
    
    .default_oam_properties
        db $05, $01, $04
    
    .piece_of_heart_messages
        dw -1, $0155, $0156, $0157 
    
    .pendant_encouragement_message
        dw $005B, $0083
    }

; ==============================================================================

    ; *$4438A-$446F1 JUMP LOCATION
    Ancilla_ReceiveItem:
    {
        ; Special Object 0x22
        ; Items that we receive from various sources
        
        ; Usually induced by an instance of this object that is a crystal
        LDA $02E4 : CMP.b #$02 : BEQ .justDoGraphics
        
        LDA $11    : BEQ .allowedSubmodule
        CMP.b #$2B : BEQ .allowedSubmodule
        CMP.b #$09 : BEQ .allowedSubmodule
        CMP.b #$02 : BNE .justDoGraphics
        
        LDA.b #$10 : STA $0C68, X
    
    .justDoGraphics
    
        BRL .handleGraphics
    
    .allowedSubmodule
    
        INC $0FC1
        
        LDA $0C54, X : BEQ .fromTextOrObject
        CMP.b #$03   : BEQ .fromTextOrObject
        
        BRL .from_chest_or_sprite
    
    .fromTextOrObject
    
        LDA $0C5E, X : CMP.b #$01 : BNE .notMasterSword
        
        ; This should never happen, the way this is coded so far... >_<'''''''
        ; Fuck spaghetti code in the anushole
        LDA $0C54, X : CMP.b #$02 : BEQ .masterSwordFromSprite
        
        LDA $0C68, X : BEQ .timerFinished
        
        CMP.b #$11 : BNE .timerWait
        
        REP #$20
        
        ; Begin a timer.... presumably to activate Sahsralah telling you good
        ; job and shit.
        LDA.w #$0DF3 : STA $02CD
        
        SEP #$20
        
        ; Instantiate the boss victory tagalong
        ; (Sahasralah's disembodied voice in this case)
        LDA.b #$0E : STA $7EF3CC
    
    .times_up_2
    
        BRL .timesUp
    
    .notMasterSword
    .masterSwordFromSprite
    
        DEC $03B1, X : LDA $03B1, X : BEQ .timerFinished
                       CMP.b #$01   : BNE .timerWait
        
        LDA $0C5E, X : CMP.b #$37 : BEQ .isPendant
                       CMP.b #$38 : BEQ .isPendant
                       CMP.b #$39 : BNE .not_pendant
    
    .isPendant
    
        ; Wait for the music to stop ( I think )
        LDA $2140 : BEQ .wait_for_music
        
        INC $03B1, X
        
        BRA .timerWait
    
    .not_pendant
    .wait_for_music
    
        BRL .times_up_2
    
    .timerWait
    
        BRL .handleGraphics
    
    .timerFinished
    
        LDA $0C5E, X : CMP.b #$01 : BNE .notMasterSword2
        
        LDA $0C54, X : BNE .notFromText
        
        ; Since we got the master sword, 
        ; restore the main overworld song and the disable ambient sound effects
        LDA.b #$05 : STA $012D
        LDA.b #$02 : STA $012C
    
    .notMasterSword
    .notFromText
    
        LDY.b #$00
        
        LDA $0345 : BEQ .notInWater
        
        ; Restore Link to his swimming state
        LDY.b #$04
    
    .notInWater
    
        STY $5D
        
        STZ $02D8
        STZ $02DA
        STZ $037B
        
        JSL GiveRupeeGift ; $4AD6C IN ROM
    
    ; needs real name
    .optimus
    
        STZ $02E9
        
        LDA $0C5E, X : CMP.b #$17 : BNE .notPieceOfHeart
        
        ; Load the number of heart pieces collected so far
        LDA $7EF36B : BNE .notGrantingHeartContainer
        
        PHX
        
        LDY.b #$26
        
        ; Grant a heart container!!! yay
        JSL Link_ReceiveItem
        
        PLX
        
        STZ $0C4A, X
        
        STZ $0FC1
        
        RTS
    
    .notPieceOfHeart
    .notGrantingHeartContainer
    
        ; Heart container in chest, typically
        CMP.b #$26 : BEQ .heartContainerInChest
        CMP.b #$3F : BEQ .heartContainerInChest
        
        ; The type of heart container typically found on the ground after a boss fight
        CMP.b #$3E : BNE .notHeartContainer
        
        STZ $02E4
        
        ; Check if capatity health is at max.
        LDA $7EF36C : CMP.b #$A0 : BEQ .already20Hearts
        
        ; Give Link additional extra heart
        ADD.b #$08 : STA $7EF36C
        
        ; Fill in that one heart
        LDA $7EF372 : ADD.b #$08 : STA $7EF372
        
        BRA .playHeartContainerSfx
    
    .heartContainerInChest
    
        LDA $7EF36D : STA $00
        
        LDA $7EF36C : CMP.b #$A0 : BEQ .already20Hearts
        
        ; Give Link an additional heart
        ADD.b #$08 : STA $7EF36C
        
        ; Put Link's actual health at maximum
        SUB $00 : STA $00
        
        LDA $7EF372 : ADD $00 : STA $7EF372
    
    .playHeartContainerSfx
    
        LDA.b #$0D : JSR Ancilla_DoSfx3_NearPlayer
        
        BRA .objectFinished
    
    .notHeartContainer
    .already20Hearts
    
        CMP.b #$42 : BNE .notSingleHeartRefill
        
        ; Fill in one heart of actual health (using the heart refiller)
        LDA $7EF372 : ADD.b #$08 : STA $7EF372
        
        BRA .objectFinished
    
    .notSingleHeartRefill
    
        CMP.b #$45 : BNE .notSmallMagicRefill
        
        ; Refill 1/8 of our magic power
        LDA $7EF373 : ADD.b #$10 : STA $7EF373
        
        BRA .objectFinished
    
    .notSmallMagicRefill
    
        CMP.b #$22 : BEQ .armorUpgrade
        CMP.b #$23 : BNE .objectFinished
    
    .armorUpgrade
    
        PHX
        
        JSL Palette_ArmorAndGloves
        
        PLX
    
    .objectFinished
    
        STZ $0C4A, X
        
        STZ $0FC1
        
        LDA $0C54, X : CMP.b #$03 : BNE .noDefaultVictorySequence
        
        ; ether medallion
        ; bombos medallion
        LDY $0C5E, X : CPY .ether_medallion  : BEQ .noDefaultVictorySequence
                       CPY .bombos_medallion : BEQ .noDefaultVictorySequence
                       CPY .heart_container  : BEQ .noDefaultVictorySequence
                       CPY .crystal          : BEQ .noDefaultVictorySequence
        
        PHA : PHX
        
        JSL PrepDungeonExit
        
        PLX : PLA
    
    .noDefaultVictorySequence
    
        CMP.b #$02 : BEQ .fromSprite
        
        STZ $02E4
    
    .fromSprite
    
        RTS
    
    .from_chest_or_sprite
    
        ; Check timer
        DEC $03B1, X : LDA $03B1, X : BPL .stillInMotion
        
        BRL .optimus
    
    .stillInMotion
    
        CMP.b #$00 : BEQ .timesUp
        
        ; Give a rupee gift when the timer reaches value 0x28
        CMP.b #$28 : BNE .dontGiveRupees
        
        ; Check if item came from sprite
        LDA $0C54, X : CMP.b #$02 : BEQ .dontGiveRupees
        
        ; $4AD6C IN ROM
        JSL GiveRupeeGift : BCS .rupeesGiven
        
        LDA $0C5E, X : CMP.b #$17 : BNE .noSoundEffect
    
    .dontGiveRupees
    
        BRL .handleMovement
    
    .noSoundEffect
    .rupeesGiven
    
        LDA.b #$0F : JSR Ancilla_DoSfx3_NearPlayer
        
        BRA .dontGiveRupees
    
    .timesUp
    
        LDA $1B : BEQ .outdoors
        
        REP #$20
        
        LDA $A0
        
        CMP.w #$00FF : BEQ .shop
        CMP.w #$010F : BEQ .shop
        CMP.w #$0110 : BEQ .shop
        CMP.w #$0112 : BEQ .shop
        CMP.w #$011F : BNE .notShop
    
    .shop
    
        SEP #$20
        
        BRA .handleMovement
    
    .outdoors
    .notShop
    
        SEP #$20
        
        LDA $0C5E, X
        
        CMP.b #$38 : BEQ .checkIfLastPendant
        CMP.b #$39 : BNE .notPendant
    
    .checkIfLastPendant
    
        TAY
        
        LDA $7EF374 : AND.b #$07 : CMP.b #$07 : BNE .defaultTextHandler

        ; Determine which text message to play
        ; I assume this has something to do with the fact that if you haven't
        ; collected all 3 pendants, it tells you to go for the last one, or whatever.
        TYA : SUB.b #$38 : ASL A : TAY
        
        REP #$20
        
        LDA .pendant_encouragement_message, Y : STA $1CF0
        
        SEP #$20
        
        BRA .doTextMessage
    
    .notPendant
    
        LDA $0C54, X : CMP.b #$02 : BEQ .handleGraphics
        
        LDA $0C5E, X : CMP.b #$17 : BNE .defaultTextHandler
        
        ; Display a different text message depending on how many pieces of heart we have
        LDA $7EF36B : ASL A : TAY
        
        REP #$20
        
        LDA .piece_of_heart_messages, Y : CMP.w #$FFFF : BEQ .handleGraphics
        
        STA $1CF0
        
        SEP #$20
        
        BRA .doTextMessage
    
    .defaultTextHandler
    
        LDA $0C5E, X : ASL A : TAY
        
        REP #$20
        
        LDA .item_messages, Y : CMP.w #$FFFF : BEQ .handleGraphics
        
        ; Check if it's Sahasralah's speech after getting the master sword
        STA $1CF0 : CMP.w #$0070 : BNE .notGeezerSpeech
        
        SEP #$20
        
        ; Play the telepathic noise during the Sahasralah speech
        LDA.b #$09 : STA $012D
    
    .notGeezerSpeech
    
        SEP #$20
    
    .doTextMessage
    
        JSL Main_ShowTextMessage
        
        BRA .handleGraphics
    
    .handleMovement
    
        LDA $03B1, X : CMP.b #$18 : BCC .handleGraphics
        
        ; A = ($0C22, X) - 1
        LDA $0C22, X : ADD.b #$FF : CMP.b #$F8
        
        ; if(A < 0xF8)
        BCC .stopAccelerating
        
        STA $0C22, X
    
    .stopAccelerating
    
        ; Move the object's in the Y direction based on $0C22, X's value
        ; handles speed values for the object (velocity)
        JSR Ancilla_MoveVert
    
    .handleGraphics
    
        SEP #$20
        
        ; Is the item we wish to grant a Crystal?
        LDA $0C5E, X : CMP.b #$20 : BNE .dont_add_sparkle
        
        ; Set a timer to zero.
        STZ $029E, X 
        
        JSR Ancilla_AddSwordChargeSpark
        
        LDA $2140 : BNE .waitForSilence
        
        ; Play the boss victory tune.
        LDA.b #$1A : STA $012C
        
        ; Replace this 0x22 object with the 0x3E object (which is the 3D version of the crystal)
        BRL Ancilla_TransmuteToRisingCrystal
    
    .dont_add_sparkle
    .waitForSilence
    
        SEP #$20
        
        LDA $0C5E, X : CMP.b #$01 : BNE .checkIfRupee
        
        LDA .default_oam_properties : STA $0BF0, X
        
        LDA $0C54, X : CMP.b #$02 : BEQ .dontAnimateMasterSword
        
        LDA $0C68, X : CMP.b #$10 : BCC .waitAnimateMasterSword
        
        DEC $039F, X : BPL .dontAnimateMasterSword
        
        LDA.b #$02 : STA $039F, X
        
        LDA $03A4, X : INC A : CMP.b #$03 : BNE .dontResetSwordAnimation
    
    .waitAnimateMasterSword
    
        LDA.b #$00
    
    .dontResetSwordAnimation
    
        STA $03A4, X : TAY
        
        LDA .default_oam_properties, Y : STA $0BF0, X
    
    .checkIfRupee
    .dontAnimateMasterSword
    
        LDA $0C5E, X
        
        CMP.b #$34 : BEQ .animatedRupeeSprite
        CMP.b #$35 : BEQ .animatedRupeeSprite
        CMP.b #$36 : BNE .dontAnimateSprite
    
    .animatedRupeeSprite
    
        DEC $039F, X : BPL .dontAnimateSprite
        
        INC $03A4, X : LDA $03A4, X : CMP.b #$03 : BNE .dontResetAnimation
        
        LDA.b #$00 : STA $03A4, X
    
    .dontResetAnimation
    
        TAY
        
        ; Set a new countdown timer for the amount of time it takes to get to the next animation step.
        LDA .animation_timers, Y : STA $039F, X
        
        PHX
        
        ; Load a new tile for the rupee
        LDA .animation_tiles, Y : JSL GetAnimatedSpriteTile
        
        PLX
    
    .dontAnimateSprite
    
        JSR Ancilla_PrepAdjustedOamCoord
        
        REP #$20
        
        ; $08 = $00 + 0x08
        LDA $00 : ADD.b #$0008 : STA $08
        
        SEP #$20
    
    ; *$44690 ALTERNATE ENTRY POINT
    .draw
    
        PHX
        
        LDA $0BF0, X : STA $74
        
        LDA $0C5E, X : TAX
        
        LDY.b #$00
        
        ; Writes X and Y coordinates to OAM buffer
        JSR Ancilla_SetOam_XY
        
        ; always use the same character graphic (0x24)
        LDA.b #$24 : STA ($90), Y : INY
        
        LDA AddReceiveItem.properties, X : BPL .valid_upper_properties
        
        LDA $74
    
    .valid_upper_properties
    
        ASL A : ORA.b #$30 : STA ($90), Y : INY
        
        PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA .wide_item_flag, X : STA ($92), Y
        
        PLY
        
        ; If it's a 16x16 sprite, we'll only draw one, otherwise we'll end up drawing
        ; two 8x8 sprites stack on top of each other
        CMP.b #$02 : BEQ .large_sprite
        
        REP #$20
        
        ; Shift Y coordinate 8 pixels down
        LDA $08 : STA $00
        
        SEP #$20
        
        JSR Ancilla_SetOam_XY
        
        ; always use the same character graphic (0x34)
        LDA.b #$34 : STA ($90), Y : INY
        
        LDA AddReceiveItem.properties, X : BPL .valid_lower_properties
        
        LDA $74
    
    .valid_lower_properties
    
        ASL A : ORA.b #$30 : STA ($90), Y 
        
        INY : PHY
        
        TYA : SUB.b #$04 : LSR #2 : TAY
        
        LDA.b #$00 : STA ($92), Y
        
        PLY
    
    .large_sprite
    
        PLX
        
        RTS
    }

; ==============================================================================

