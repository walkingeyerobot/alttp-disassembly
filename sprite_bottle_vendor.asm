
; ==============================================================================

    ; *$2EA71-$2EA78 LONG
    Sprite_BottleVendorLong:
    {
        ; Bottle vendor (0x75)
        
        PHB : PHK : PLB
        
        JSR Sprite_BottleVendor
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2EA79-$2EABD LOCAL
    Sprite_BottleVendor:
    {
        ; Note: $0E90 is 0 - normal, 1 - good bee is present, 0x80 - fish
        ; are present, 0x81 - fish and good bee are present, but fish overrides
        ; good bee for this sprite's behavior.
        
        JSR BottleVendor_Draw
        
        LDA $03 : ORA $01 : STA $0D90, X
        
        JSR Sprite2_CheckIfActive
        JSL BottleVendor_DetectFish
        JSL Sprite_PlayerCantPassThrough
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCC .player_available
        
        RTS
    
    .player_available
    
        JSL GetRandomInt : BNE .dont_reset_timer
        
        LDA.b #$01 : STA $0DC0, X
        
        LDA.b #$14 : STA $0DF0, X
    
    .dont_reset_timer
    
        LDA $0DF0, X : BNE .wait
        
        STZ $0DC0, X
    
    .wait
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw BottleVendor_Base
        dw BottleVendor_SellingBottle
        dw BottleVendor_GiveBottle
        dw BottleVendor_BuyingFromPlayer
        dw BottleVendor_DispenseRewardToPlayer
    }

; ==============================================================================

    ; *$2EABE-$2EAC6 BRANCH LOCATION
    BottleVendor_SoldOut:
    {
        ; "I'm sold out of bottles, come back later."
        LDA.b #$D4
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    }

; ==============================================================================

    ; *$2EAC7-$2EAEC JUMP LOCATION
    BottleVendor_Base:
    {
        ; \task Find out why it would check this... What is $0D90 really, for
        ; this sprite?
        LDA $0D90, X : BNE .off_screen
        
        LDA $0E90, X : BEQ .no_fish_or_good_bee
        
        LDA.b #$03 : STA $0D80, X
        
        RTS
    
    .no_fish_or_good_bee
    .off_screen
    
        LDA $7EF3C9 : AND.b #$02 : BNE BottleVendor_SoldOut
        
        ; "... I've got one on sale for the low, low price of 100 rupees!..."
        LDA.b #$D1
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_converse
        
        INC $0D80, X
    
    .didnt_converse
    
        RTS
    }

; ==============================================================================

    ; *$2EAED-$2EB16 JUMP LOCATION
    BottleVendor_SellingBottle:
    {
        LDA $1CE8 : BNE .no_selected
        
        REP #$20
        
        ; check if player has 100 rupees (bottle vendor?)
        LDA $7EF360 : CMP.w #$0064 : SEP #$30 : BCC .player_cant_afford
        
        ; "...Now, hold it above your head for the whole world to see, OK?..."
        LDA.b #$D2
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .player_cant_afford
    .no_selected
    
        ; "...Come back after you earn more Rupees.  It might still be here."
        LDA.b #$D3
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2EB17-$2EB3F JUMP LOCATION
    BottleVendor_GiveBottle:
    {
        ; \item(Bottle)
        LDY.b #$16
        
        STZ $02E9
        
        PHX
        
        JSL Link_ReceiveItem
        
        PLX
        
        LDA $7EF3C9 : ORA.b #$02 : STA $7EF3C9
        
        REP #$20
        
        LDA $7EF360 : SUB.w #$0064 : STA $7EF360
        
        SEP #$30
        
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2EB40-$2EB5C JUMP LOCATION
    BottleVendor_BuyingFromPlayer:
    {
        LDA $0E90, X : BMI .player_has_fish
        
        ; "Wow! I've never seen such a rare bug! I'll buy it for 100 rupees..."
        LDA.b #$D5
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    
    .player_has_fish
    
        ; "You have to give me this fish for this stuff, OK? Done!"
        LDA.b #$D6
        LDY.b #$00
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$2EB5D-$2EB86 JUMP LOCATION
    BottleVendor_DispenseRewardToPlayer:
    {
        LDY $0E90, X : BMI .player_has_fish
        
        DEY
        
        LDA.b #$00 : STA $0DD0, Y
        
        JSL BottleVendor_PayForGoodBee
        
        STZ $0E90, X
        STZ $0D80, X
        
        RTS
    
    .player_has_fish
    
        TYA : AND.b #$0F : TAY
        
        LDA.b #$00 : STA $0DD0, Y
        
        JSL BottleVendor_SpawnFishRewards
        
        STZ $0E90, X
        STZ $0D80, X
        
        RTS
    }

; ==============================================================================

    ; $2EB87-$2EBA6 DATA
    pool BottleVendor_Draw:
    {
    
    .animation_states
        dw 0, -7 : db $AC, $00, $00, $02
        dw 0,  0 : db $88, $00, $00, $02
        
        dw 0, -6 : db $AC, $00, $00, $02
        dw 0,  0 : db $A2, $00, $00, $02
    }

; ==============================================================================

    ; *$2EBA7-$2EBC6 LOCAL
    BottleVendor_Draw:
    {
        LDA.b #$02 : STA $06
                     STZ $07
        
        LDA $0DC0, X : ASL #4
        
        ; $2EB87 = .animation_states
        ADC.b #$87              : STA $08
        LDA.b #$EB : ADC.b #$00 : STA $09
        
        JSL Sprite_DrawMultiple.player_deferred
        JSL Sprite_DrawShadowLong
        
        RTS
    }

; ==============================================================================
