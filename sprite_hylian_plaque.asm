
; ==============================================================================

    ; $F603C-$F6043 DATA
    pool HylianPlaque
    {
    
    .sword_messages_low
        db $B6, $B7
    
    .sword_messages_high
        db $00, $00
        
    .desert_messages_low
        db $BC, $BD
    
    .desert_messages_high
        db $00, $00        
    }

; ==============================================================================

    ; *$F6044-$F609E JUMP LOCATION
    Sprite_HylianPlaque:
    {
        JSL Sprite_PrepOamCoordLong
        JSR Sprite3_CheckIfActive
        
        LDA $02E4 : BNE .player_paused
        
        JSL Sprite_CheckIfPlayerPreoccupied : BCC .player_available
    
    .player_paused
    
        RTS
    
    .player_available
    
    ; \note Label not used, I just thought I'd put it there for informative
    ; purposes (kind of like what a plaque does, right? hehehheehehreh)
    shared HylianPlaque_MasterSword:
    
        ; Get rid of whatever pose the player was in...
        LDA $037A : AND.b #$DF : STA $037A
        
        LDA $8A : CMP.b #$30 : BEQ HylianPlaque_Desert
        
        LDA $2F : BNE .not_facing_up
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .dont_show_message
        
        LDA $0202 : CMP.b #$0F : BNE .book_of_mudora_not_equipped
        
        LDY.b #$01
        
        BIT $F4 : BVS .y_button_pressed
    
    .book_of_mudora_not_equipped
    
        LDA $F6 : BPL .dont_show_message
        
        LDY.b #$00
    
    .y_button_pressed
    
        CPY.b #$01 : BNE .no_pose_needed
        
        STZ $0300
        
        LDA.b #$20 : STA $037A
        
        STZ $012E
    
    .no_pose_needed
    
        LDA HylianPlaque.sword_messages_low, Y        : XBA
        LDA HylianPlaque.sword_messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
    
    .dont_show_message
    .not_facing_up
    
        RTS
    }
    
; ==============================================================================

    ; *$F609F-$F60DC JUMP LOCATION
    HylianPlaque_Desert:
    {
        LDA $2F : BNE .not_facing_up
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .dont_show_message
        
        LDA $0202 : CMP.b #$0F : BNE .book_of_mudora_not_equipped
        
        LDY.b #$01
        
        BIT $F4 : BVS .y_button_pressed

    .book_of_mudora_not_equipped

        LDA $F6 : BPL .dont_show_message
        
        LDY.b #$00
    
    ..y_button_pressed
    
        CPY.b #$01 : BNE .no_pose_needed
        
        STZ $0300
        
        LDA.b #$20 : STA $037A
        
        STZ $012E
        
        ; Call the routine that causes us to enter the desert palace opening
        ; submode of the player...
        JSL $07866D ; $3866D IN ROM
    
    .no_pose_needed
    
        LDA HylianPlaque.desert_messages_low, Y        : XBA
        LDA HylianPlaque.desert_messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
    
    .dont_show_message
    .not_facing_up
    
        RTS
    }

; ==============================================================================
