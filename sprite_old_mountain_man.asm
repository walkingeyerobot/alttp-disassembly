
; ==============================================================================

    ; *$F68F1-$F68F8 LONG
    SpritePrep_OldMountainManLong:
    {
        PHB : PHK : PLB
        
        JSR SpritePrep_OldMountainMan
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$F68F9-$F6937 LOCAL
    SpritePrep_OldMountainMan:
    {
        INC $0BA0, X
        
        LDA $A0 : CMP.b #$E4 : BNE .not_at_home
        
        LDA.b #$02 : STA $0E80, X
        
        RTS
    
    .not_at_home
    
        LDA $7EF3CC : CMP.b #$00 : BNE .already_have_tagalong
        
        LDA $7EF353 : CMP.b #$02 : BNE .dont_have_magic_mirror
        
        STZ $0DD0, X
    
    .dont_have_magic_mirror
    
        ; Temporarily set Link's tagalong status to that of the Old Man for
        ; the purpose of loading the tagalong graphics.
        LDA.b #$04 : STA $7EF3CC
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        LDA.b #$00 : STA $7EF3CC
        
        RTS
    
    .already_have_tagalong
    
        STZ $0DD0, X
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        RTS
    }

; ==============================================================================

    ; *$F6938-$F6988 LONG
    OldMountainMan_TransitionFromTagalong:
    {
        PHA
        
        LDA.b #$AD : JSL Sprite_SpawnDynamically
        
        PLA : PHX : TAX
        
        LDA $1A64, X : AND.b #$03 : STA $0EB0, Y
                                    STA $0DE0, Y
        
        LDA $1A00, X : ADD.b #$02 : STA $0D00, Y
        LDA $1A14, X : ADC.b #$00 : STA $0D20, Y
        
        LDA $1A28, X : ADD.b #$02 : STA $0D10, Y
        LDA $1A3C, X : ADC.b #$00 : STA $0D30, Y
        
        LDA $EE : STA $0F20, Y
        
        LDA.b #$01 : STA $0BA0, Y
                     STA $0E80, Y
        
        JSR OldMountainMan_FreezePlayer
        
        PLX
        
        LDA.b #$00 : STA $7EF3CC
        
        STZ $5E
        
        RTL
    }

; ==============================================================================

    ; *$F6989-$F6991 LOCAL
    OldMountainMan_FreezePlayer:
    {
        LDA.b #$01 : STA $02E4
                     STA $037B
        
        RTS
    }

; ==============================================================================

    ; *$F6992-$F69A5 JUMP LOCATION
    Sprite_OldMountainMan:
    {
        JSL OldMountainMan_Draw
        JSR Sprite3_CheckIfActive
        
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw OldMountainMan_Lost
        dw OldMountainMan_EnteringDomicile
        dw OldMountainMan_SittingAtHome
    }

; ==============================================================================

    ; *$F69A6-$F69B0 JUMP LOCATION
    OldMountainMan_Lost:
    {
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw OldMountainMan_Supplicate
        dw OldMountainMan_SwitchToTagalong
    }

; ==============================================================================

    ; *$F69B1-$F69D1 JUMP LOCATION
    OldMountainMan_Supplicate:
    {
        JSL Sprite_MakeBodyTrackHeadDirection
        JSR Sprite3_DirectionToFacePlayer
        
        TYA : EOR.b #$03 : STA $0EB0, X
        
        ; "I lost my lamp, blah blah blah"
        LDA.b #$9C
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        STA $0DE0, X
        STA $0EB0, X
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================

    ; *$F69D2-$F69E9 JUMP LOCATION
    OldMountainMan_SwitchToTagalong:
    {
        ; Set up the old man on the mountain as the tagalong
        LDA.b #$04 : STA $7EF3CC
        
        JSL Tagalong_SpawnFromSprite
        
        LDA.b #$05 : STA $7EF3C8
        
        STZ $0DD0, X
        
        ; caches some dungeon values. Not sure if this is really necessary,
        ; but it might be ancitipating that you suck at this game and will
        ; die while the old man is with you?
        JSL $0283B5 ; $103B5 IN ROM
        
        RTS
    }

; ==============================================================================

    ; *$F69EA-$F69FB JUMP LOCATION
    OldMountainMan_EnteringDomicile:
    {
        JSR Sprite3_Move
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw OldMountainMan_GrantMagicMirror
        dw OldMountainMan_ShuffleAway
        dw OldMountainMan_ApproachDoor
        dw OldMountainMan_MadeItInside
    }

; ==============================================================================

    ; *$F69FC-$F6A27 JUMP LOCATION
    OldMountainMan_GrantMagicMirror:
    {
        INC $0D80, X
        
        ; Grant the magic mirror...
        LDY.b #$1A
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        LDA.b #$01 : STA $7EF3C8
        
        JSR OldMountainMan_FreezePlayer
        
        LDA.b #$30 : STA $0DF0, X
        
        LDA.b #$08 : STA $0D50, X
        
        LSR A : STA $0D40, X
        
        LDA.b #$03 : STA $0EB0, X : STA $0DE0, X
        
        RTS
    }

; ==============================================================================

    ; *$F6A28-$F6A3E JUMP LOCATION
    OldMountainMan_ShuffleAway:
    {
        JSR OldMountainMan_FreezePlayer
        
        LDA $0DF0, X : BNE .delay
        
        INC $0D80, X
    
    .delay
    
        TXA : EOR $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; *$F6A3F-$F6AA2 JUMP LOCATION
    OldMountainMan_ApproachDoor:
    {
        STZ $0EB0, X
        STZ $0DE0, X
        
        LDY $0FDE
        
        LDA $0B18, Y : STA $00
        LDA $0B20, Y : STA $01
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        REP #$20
        
        LDA $00 : CMP $02 : SEP #$30 : BCC .not_north_enough_yet
        
        INC $0D80, X
        
        STZ $0D50, X
        STZ $0D40, X
        
        RTS
    
    .not_north_enough_yet
    
        LDA $0B08, Y : STA $04
        LDA $0B10, Y : STA $05
        
        LDA $0B18, Y : STA $06
        LDA $0B20, Y : STA $07
        
        LDA.b #$08 : JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        
        LDA $01 : STA $0D50, X
        
        TXA : EOR $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        JSR OldMountainMan_FreezePlayer
        
        RTS
    }

; ==============================================================================

    ; *$F6AA3-$F6AAC JUMP LOCATION
    OldMountainMan_MadeItInside:
    {
        STZ $0DD0, X
        
        STZ $02E4
        STZ $037B
        
        RTS
    }

; ==============================================================================

    ; $F6AAD-$F6AB2 DATA
    pool OldMountainMan_SittingAtHome:
    {
    
    .messages_low
        db $9E, $9F, $A0
    
    .messages_high
        db $00, $00, $00
    }

; ==============================================================================

    ; *$F6AB3-$F6AE6 JUMP LOCATION
    OldMountainMan_SittingAtHome:
    {
        JSL Sprite_PlayerCantPassThrough
        
        LDA $0D80, X : BEQ .dont_activate_health_refill
        
        LDA.b #$A0 : STA $7EF372
        
        STZ $0D80, X
    
    .dont_activate_health_refill
    
        LDY.b #$02
        
        LDA $7EF3C5 : CMP.b #$03 : BCS .player_beat_agahnim
        
        LDA $7EF357 : TAY
    
    .player_beat_agahnim
    
        LDA .messages_low, Y        : XBA
        LDA .messages_high, Y : TAY : XBA
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing : BCC .didnt_speak
        
        INC $0D80, X
    
    .didnt_speak
    
        RTS
    }

; ==============================================================================
